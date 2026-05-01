{$R-,C-,Q-,O+,H+}

(*
  1.11: 1999-08-12
    - Added support for Delphi 5.
  1.1: 1999-08-10
    - Fixed long-standing bug that caused corrupted profile file when profiling
      large projects.
  1.0.1: 1999-05-12
    - Support for DLL and package profiling (GetModuleName is used instead of
      ParamStr(0)).
    - Error is reported if <module>.gpi or <module>.gpd file is not found.
*)

unit GpProf;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}

{$INCLUDE GpProf.inc}

(******************************************************************************)

uses
  GpProfCommonTypes;

type
  /// <summary>
  /// Marker interface for a measure point scope. upon destruction, the scope will be stored.
  /// </summary>
  IMeasurePointScope = interface
  end;

procedure ProfilerStart;
procedure ProfilerStop;
procedure ProfilerStartThread;

procedure ProfilerEnterProc(const aProcID: Cardinal);
procedure ProfilerExitProc(const aProcID: Cardinal);

procedure ProfilerEnterMP(const aMeasurePointId: UTF8String);
procedure ProfilerExitMP(const aMeasurePointId: UTF8String);

function CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;

procedure ProfilerTerminate;

{$IFDEF UNICODE}
procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload; inline;
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;
{$ELSE}
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID = TThreadID(-1));
{$ENDIF}

implementation

uses
  Windows,
  Classes,
  Contnrs,
  SysUtils,
  IniFiles,
  GpProfH,
  GpProfCommon;

const
  BUF_SIZE = 64 * 1024; //64*1024;

type
  TMeasurePointScope = class(TInterfacedObject, IMeasurePointScope)
  private
    fMeasurePointId : UTF8String;
  public
    constructor Create(const aMeasurePointId : UTF8String);
    destructor Destroy; override;
  end;

  TTLEl = record
    tleThread: integer;
    tleRemap : integer;
  end;

  PTLElements = ^TTLElements;
  TTLElements = array [0..0] of TTLEl;

  TThreadIdList = class
  private
    tlItems: PTLElements;
    tlCount: Cardinal;
    tlCapacity: Integer;
    tlRemap: Cardinal;
    tlLast : Cardinal;
    tlLastR: Cardinal;
    function Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
    function GetItem(aIndex: Integer): TTLEl;
  public
    constructor Create;
    destructor  Destroy; override;
    function    Remap(const aThreadId: Cardinal): integer;
    property    Count: Cardinal read tlCount;
    property    Items[aIndex: Integer]: TTLEl read GetItem;
  end;

  TThreadInformation = class
    ID : cardinal;
    Name : UTF8String;
  end;

  TThreadInformationList = TObjectList;

var
  prfFile        : THandle;
  prfBuf         : pointer;
  prfBufOffs     : integer;
  prfLock        : TRTLCriticalSection;
  prfFreq        : TLargeInteger;
  prfCounter     : TLargeInteger;
  prfModuleName  : string;
  prfName        : string;
  prfRunning     : boolean;
  prfLastTick    : TLargeInteger;
  prfOnlyThread  : Cardinal;
  prfThreads     : TThreadIdList;
  prfThreadsInfo : TThreadInformationList;
  prfThreadBytes : integer;
  prfMaxThreadNum: Cardinal;
  prfInitialized : boolean;
  prfDisabled    : boolean;

  profProcSize          : integer;
  profCompressTicks     : boolean;
  profCompressThreads   : boolean;
  profProfilingAutostart: boolean;
  profProfilingMemoryEnabled: boolean;
  profPrfOutputFile     : string;
  profTableName         : string;

procedure FlushFile; inline;
var
  written: DWORD;
begin
  if WriteFile(prfFile, prfBuf^, BUF_SIZE, written, nil) then
  begin
    prfBufOffs := 0;
    FillChar(prfBuf^, BUF_SIZE, 0);
  end else
    RaiseLastWin32Error;
end; { FlushFile }

function OffsetPtr(ptr: Pointer; offset: NativeUInt): Pointer; inline;
begin
  Result := Pointer(NativeUInt(ptr) + offset);
end; { OffsetPtr }

procedure Transmit(const buf; count: DWORD);
var
  bufp   : pointer;
  place  : DWORD;
  written: DWORD;
begin
  place := BUF_SIZE-prfBufOffs;
  if place <= count then begin
    Move(buf,OffsetPtr(prfBuf,prfBufOffs)^,place); // fill the buffer
    prfBufOffs := BUF_SIZE;
    FlushFile;
    Dec(count,place);
    bufp := OffsetPtr(@buf,place);
    while count >= BUF_SIZE do begin
      Move(bufp^,prfBuf^,BUF_SIZE);
      if WriteFile(prfFile,prfBuf^,BUF_SIZE,written,nil) then
      begin
        Dec(count,BUF_SIZE);
        bufp := OffsetPtr(bufp,BUF_SIZE);
      end else
        RaiseLastWin32Error;
    end; //while
  end
  else bufp := @buf;
  if count > 0 then begin // store leftovers
    Move(bufp^,OffsetPtr(prfBuf,prfBufOffs)^,count);
    Inc(prfBufOffs,count);
  end;
end; { Transmit }

function GetMemWorkingSize() : Cardinal;
var
  MemoryManagerState: TMemoryManagerState;
  SmallBlockState: TSmallBlockTypeState;
  i: Integer;
begin
  GetMemoryManagerState( MemoryManagerState );
  Result := 0;
  for i := low(MemoryManagerState.SmallBlockTypeStates) to
        high(MemoryManagerState.SmallBlockTypeStates) do
    begin
    SmallBlockState := MemoryManagerState.SmallBlockTypeStates[i];
    Inc(Result,
    SmallBlockState.AllocatedBlockCount*SmallBlockState.UseableBlockSize);
    end;

  Inc(Result, MemoryManagerState.TotalAllocatedMediumBlockSize);
  Inc(Result, MemoryManagerState.TotalAllocatedLargeBlockSize);
end;

procedure WriteMemWorkingSize();
var
  lMemUsed : Cardinal;
begin
  lMemUsed := GetMemWorkingSize();
  Transmit(lMemUsed, sizeof(Cardinal));
end;

procedure WriteInt(int: integer); inline;
begin
  Transmit(int, SizeOf(integer));
end;

procedure WriteCardinal(value: Cardinal); inline;
begin
  Transmit(value, SizeOf(Cardinal));
end;

procedure WriteTag(tag: byte); inline;
begin
  Transmit(tag, SizeOf(byte));
end;

procedure WriteProcID(id: integer); inline;
begin
  Transmit(id, profProcSize);
end;

procedure WriteBool(bool: boolean); inline;
begin
  Transmit(bool, 1);
end;

procedure WriteUtf8String(const aValue: UTF8String); inline;
var
  len: integer;
begin
  len := Length(aValue);
  WriteCardinal(len);
  if len > 0 then
    Transmit(aValue[1], len);
end;

procedure WriteTicks(ticks: TLargeInteger);
type
  TTick = array [1..8] of Byte;
var
  diff: integer;
begin
  if not profCompressTicks then Transmit(ticks, Sizeof(ticks))
  else begin
    if prfLastTick = -1 then diff := 8
    else begin
      diff := 8;
      while (diff > 0) and (TTick(ticks)[diff] = TTick(prfLastTick)[diff]) do
        Dec(diff);
      Inc(diff);
    end;
    Transmit(diff, 1);
    Transmit(ticks, diff);
    prfLastTick := ticks;
  end;
end; { WriteTicks }

procedure WriteThread(const aThreadId: Cardinal);
const
  marker: integer = 0;
var
  remap: integer;
begin
  if not profCompressThreads then Transmit(aThreadId, Sizeof(integer))
  else begin
    remap := prfThreads.Remap(aThreadId);
    if prfThreads.Count >= prfMaxThreadNum then begin
      Transmit(marker, prfThreadBytes);
      prfMaxThreadNum := 2 * prfMaxThreadNum;
      prfThreadBytes := prfThreadBytes + 1;
    end;
    Transmit(remap, prfThreadBytes);
  end;
end; { WriteThread }

procedure FlushCounter; inline;
begin
  if prfCounter <> 0 then begin
    WriteTicks(prfCounter);
    prfCounter := 0;
  end;
end; { FlushCounter }

procedure ProfilerEnterProc(const aProcID : Cardinal);
var
  ct : Cardinal;
  cnt: TLargeInteger;
begin
  QueryPerformanceCounter(cnt);
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      WriteTag(PR_ENTERPROC);
      WriteThread(ct);
      WriteProcID(aProcID);
      WriteTicks(cnt);
      if profProfilingMemoryEnabled then
        WriteMemWorkingSize();
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerEnterProc }

procedure ProfilerExitProc(const aProcID : Cardinal);
var
  ct : Cardinal;
  cnt: TLargeinteger;
begin
  QueryPerformanceCounter(Cnt);
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      WriteTag(PR_EXITPROC);
      WriteThread(ct);
      WriteProcID(aProcID);
      WriteTicks(Cnt);
      if profProfilingMemoryEnabled then
        WriteMemWorkingSize();
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerExitProc }

function CreateMeasurePointScope(const aMeasurePointId : String): IMeasurePointScope;
begin
  result := TMeasurePointScope.Create(UTF8Encode(aMeasurePointId));
end;

procedure ProfilerStart;
begin
  if not prfDisabled then begin
    EnterCriticalSection(prfLock);
    try prfRunning := true;
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerStart }

procedure ProfilerStop;
begin
  if not prfDisabled then begin
    EnterCriticalSection(prfLock);
    try prfRunning := false;
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerStop }

procedure ProfilerStartThread;
begin
  EnterCriticalSection(prfLock);
  try
    prfRunning := true;
    prfOnlyThread := GetCurrentThreadID;
  finally LeaveCriticalSection(prfLock); end;
end; { ProfilerStartThread }

function CombineNames(const fName, newExt: string): string;
begin
  Result := Copy(fName,1,Length(fName)-Length(ExtractFileExt(fName)))+'.'+newExt;
end; { CombineNames }

{$IFDEF UNICODE}
procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID);
begin
  NameThreadForDebugging(string(aThreadName), aThreadID);
end; { NameThreadForDebugging }
{$ENDIF}

procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID);
var LEntry : TThreadInformation;
begin
  {$IFDEF HAS_NAME_THREAD_FOR_DEBUGGING}
  TThread.NameThreadForDebugging(aThreadName, aThreadId);
  {$ELSE}
  GpProfCommon.NameThreadForDebugging(aThreadName, aThreadId);
  {$ENDIF}
  if not prfDisabled then
  begin
    LEntry := TThreadInformation.Create;
    LEntry.ID := AThreadId;
    LEntry.Name := UTF8Encode(AThreadName);
    prfThreadsInfo.Add(LEntry);
  end;
end; { NameThreadForDebugging }

{ TThreadIdList }

constructor TThreadIdList.Create;
begin
  inherited Create;
  tlCount := 0;
  tlCapacity := 0;
  tlRemap := 0;
  tlItems := nil;
  tlLast := 0;
  tlLastR := 0;
end; { TThreadIdList.Create }

destructor TThreadIdList.Destroy;
begin
  if tlItems <> nil then FreeMem(tlItems);
  inherited Destroy;
end; { TThreadIdList.Destroy }

function TThreadIdList.GetItem(aIndex: Integer): TTLEl;
begin
  if aIndex < Integer(tlCount) then
    Result := tlItems^[aIndex]
  else
    raise Exception.CreateFmt(Self.ClassName + ': Invalid Item Index %d (Count = %d)', [aIndex, tlCount]);
end; { TThreadIdList.GetItem }

function TThreadIdList.Remap(const aThreadId: Cardinal): integer;
var
  LRemap : Cardinal;
  LInsert: Cardinal;
  LNewCount: Integer;
begin
  if aThreadId = tlLast then
    Result := tlLastR
  else if not Search(aThreadId, LRemap, LInsert) then begin
    // grow tlItems
    LNewCount := tlCount + 1;
    if LNewCount > tlCapacity then
    begin
      tlCapacity := GrowCollection(tlCapacity, LNewCount);
      ReallocMem(tlItems, SizeOf(TTLEl)*tlCapacity);
    end;
    // get new remap number
    Inc(tlRemap);
    if byte(tlRemap) = 0 then Inc(tlRemap);
    // insert new element
    if LInsert < tlCount then
      Move(tlItems^[LInsert], tlItems^[LInsert + 1], (tlCount-LInsert)*SizeOf(TTLEl));
    with tlItems^[LInsert] do begin
      tleThread := aThreadId;
      tleRemap  := tlRemap;
    end;
    Inc(tlCount);
    tlLast  := aThreadId;
    tlLastR := tlRemap;
    Result  := tlRemap;
  end
  else begin
    tlLast  := aThreadId;
    tlLastR := LRemap;
    Result  := LRemap;
  end;
end; { TThreadIdList.Remap }

function TThreadIdList.Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
var
  l, m, h: Cardinal;
  mid    : Cardinal;
begin
  if tlCount = 0 then begin
    insertIdx := 0;
    Result := False;
  end
  else begin
    L := 0;
    H := tlCount - 1;
    repeat
      m := L + (H - L) div 2;
      mid := tlItems^[m].tleThread;
      if aThreadId = mid then begin
        remap := tlItems^[m].tleRemap;
        Result := True;
        Exit;
      end else if aThreadId < mid then H := m - 1
      else L := m + 1;
    until L > H;
    Result := False;
    if aThreadId > mid then insertIdx := m + 1
                    else insertIdx := m;
  end;
end; { TThreadIdList.Search }

procedure ReadIncSettings;
var
  LBuf: array [0..256] of char;
  LIniFileName: string;
  LIni: TMemIniFile;
begin
  GetModuleFileName(HInstance,LBuf,256);
  prfModuleName := string(LBuf);
  prfDisabled := true;
  profProfilingAutostart := false;
  LIniFileName := Copy(prfModuleName,1,Length(prfModuleName)-Length(ExtractFileExt(prfModuleName)))+'.GPI';
  if not FileExists(LIniFileName) then
    MessageBox(0, PChar(Format('Cannot find initialization file %s! '+
      'Profiling will be disabled.', [LIniFileName])), 'GpProfile', MB_OK + MB_ICONERROR)
  else begin
    LIni := TMemIniFile.Create(LIniFileName);
    try
      profTableName := LIni.ReadString('IDTables','TableName','');
      if profTableName <> '' then begin
        if not FileExists(profTableName) then
          MessageBox(0, PChar(Format('Cannot find data file %s! '+
            'Profiling will be disabled.', [profTableName])), 'GpProfile',
            MB_OK + MB_ICONERROR)
        else begin
          profProcSize           := LIni.ReadInteger('Procedures','ProcSize',4);
          profCompressTicks      := LIni.ReadBool('Performance','CompressTicks',false);
          profCompressThreads    := LIni.ReadBool('Performance','CompressThreads',false);
          profProfilingAutostart := LIni.ReadBool('Performance','ProfilingAutostart',true);
          profProfilingMemoryEnabled := LIni.ReadBool('Performance','ProfilingMemSupport',false);
          profPrfOutputFile := LIni.ReadString('Output','PrfOutputFilename','$(ModulePath)');
          profPrfOutputFile := ResolvePrfRuntimePlaceholders(profPrfOutputFile);
          prfDisabled            := false;
        end;
      end;
    finally
      LIni.Free;
    end;
  end;
end; { ReadIncSettings }

procedure AppendToErrorLog(const aFilename, aMessage : string);
var
  myFile : TextFile;
begin
  AssignFile(myFile, aFilename);
  if FileExists(aFilename) then
    Append(myFile)
  else
    Rewrite(myFile);
  WriteLn(myFile, aMessage);
  CloseFile(myFile);
end;

procedure Initialize();
var
  LErrorPath : string;
begin
  try
    ReadIncSettings;
    if not prfDisabled then begin
      prfRunning          := profProfilingAutostart;
      prfCounter          := 0;
      prfOnlyThread       := 0;
      prfThreads          := TThreadIdList.Create;
      prfThreadsInfo      := TThreadInformationList.Create;
      prfMaxThreadNum     := 256;
      prfThreadBytes      := 1;
      prfLastTick         := -1;
      prfName             := CombineNames(prfModuleName, 'prf');
      if profPrfOutputFile <> '' then
        prfName := profPrfOutputFile + '.prf';
      GetMem(prfBuf,BUF_SIZE);
      Win32Check(prfBuf <> nil);
      prfBufOffs          := 0;
      FillChar(prfBuf^, BUF_SIZE, 0);
      InitializeCriticalSection(prfLock);
      prfFile := CreateFile(PChar(prfName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
                            FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
      Win32Check(prfFile <> INVALID_HANDLE_VALUE);
      QueryPerformanceFrequency(prfFreq);
    end;
  except
    on e: exception do
    begin
      LErrorPath := ChangeFileExt(prfName, '.err');
      AppendToErrorLog(LErrorPath, 'Error in initialize: '+e.message);
      raise;
    end;
  end;
end; { Initialize }

procedure WriteHeader;
begin
  WriteTag(PR_PRFVERSION);
  if profProfilingMemoryEnabled then
    WriteInt(PRF_VERSION_WITH_MEM)
  else
    WriteInt(PRF_VERSION);
  WriteTag(PR_COMPTICKS);
  WriteBool(profCompressTicks);
  WriteTag(PR_COMPTHREADS);
  WriteBool(profCompressThreads);
  WriteTag(PR_FREQUENCY);
  WriteTicks(prfFreq);
  WriteTag(PR_PROCSIZE);
  WriteInt(profProcSize);
  WriteTag(PR_ENDHEADER);
end; { WriteHeader }

procedure CopyTables;
var
  p: pointer;
  f: file;
  fs: integer;
begin
  if not FileExists(profTableName) then prfDisabled := true
  else begin
    Assign(f,profTableName);
    Reset(f,1);
    try
      fs := FileSize(f);
      if fs > 0 then
      begin
        GetMem(p,fs);
        try
          BlockRead(f,p^,fs);
          Transmit(p^,fs);
        finally
          FreeMem(p);
        end;
      end;
    finally
      Close(f);
    end;
  end;
end; { CopyTables }

procedure WriteCalibration;
var
  i  : integer;
  run: boolean;
begin
  run := prfRunning;
  prfRunning := True;
  WriteTag(PR_STARTCALIB);
  WriteInt(CALIB_CNT);
  for i := 1 to CALIB_CNT + 1 do begin
    ProfilerEnterProc(0);
    ProfilerExitProc(0);
  end;
  FlushCounter;
  WriteTag(PR_ENDCALIB);
  prfRunning := run;
end; { WriteCalibration }

procedure Finalize;
begin
  Win32Check(CloseHandle(prfFile));
  FreeMem(prfBuf, BUF_SIZE);
  prfThreads.Free;
  prfThreadsInfo.free;
  DeleteCriticalSection(prfLock);
end; { Finalize }

procedure ProfilerTerminate;
var
  i: integer;
  LItem: TThreadInformation;
  LThreadsIdItem: TTLEl;
begin
  if not prfInitialized then Exit;

  ProfilerStop;
  prfInitialized := False;

  EnterCriticalSection(prfLock);
  try
    FlushCounter;
    WriteTag(PR_ENDDATA);

    // write compressed thread ids
    if profCompressThreads then
    begin
      WriteTag(PR_START_THREAD_ID_LIST);
      WriteCardinal(prfThreads.Count);
      for i := 0 to prfThreads.Count-1 do
      begin
        LThreadsIdItem := prfThreads.Items[i];
        WriteCardinal(LThreadsIdItem.tleThread);
        WriteCardinal(LThreadsIdItem.tleRemap);
      end;
      WriteInt(PR_END_THREAD_ID_LIST);
    end;

    // write thread names
    WriteTag(PR_START_THREADINFO);
    WriteCardinal(prfThreadsInfo.count);
    for i := 0 to prfThreadsInfo.count-1 do
    begin
      LItem := TThreadInformation(prfThreadsInfo[i]);
      WriteCardinal(LItem.ID);
      WriteUtf8String(LItem.Name);
    end;
    WriteInt(PR_END_THREADINFO);

    FlushFile;
  finally
    LeaveCriticalSection(prfLock);
  end;

  Finalize;
end; { ProfilerTerminate }

procedure ProfilerEnterMP(const aMeasurePointId: UTF8String);
var
  ct : Cardinal;
  cnt: TLargeInteger;
begin
  QueryPerformanceCounter(cnt);
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      WriteTag(PR_ENTER_MP);
      WriteThread(ct);
      WriteUtf8String(aMeasurePointId);
      WriteTicks(Cnt);
      if profProfilingMemoryEnabled then
        WriteMemWorkingSize();
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

procedure ProfilerExitMP(const aMeasurePointId: UTF8String);
var
  ct : Cardinal;
  cnt: TLargeInteger;
begin
  QueryPerformanceCounter(Cnt);
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      WriteTag(PR_EXIT_MP);
      WriteThread(ct);
      WriteUtf8String(aMeasurePointId);
      WriteTicks(Cnt);
      if profProfilingMemoryEnabled then
        WriteMemWorkingSize();
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

{ TMeasurePointScope }

constructor TMeasurePointScope.Create(const aMeasurePointId: UTF8String);
begin
  inherited Create;
  fMeasurePointId := aMeasurePointId;
  ProfilerEnterMP(fMeasurePointId);
end;

destructor TMeasurePointScope.Destroy;
begin
  ProfilerExitMP(fMeasurePointId);
  inherited;
end;

initialization
  prfInitialized := false;
  Initialize;
  if not prfDisabled then begin
    WriteHeader;
    CopyTables;
    WriteCalibration;
    WriteTag(PR_STARTDATA);
    prfInitialized := true;
    gpprof.NameThreadForDebugging('Main Application Thread', MainThreadID);
  end;

finalization
  ProfilerTerminate;

end.

