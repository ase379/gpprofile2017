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

unit gpprof;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}

uses System.Classes;

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
function CreateMeasurePointScope(const aMeasurePointId : String): IMeasurePointScope;

procedure ProfilerTerminate;
procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;

implementation

uses
  System.Generics.Collections,
  Windows,
  psAPI,
  SysUtils,
  IniFiles,
  GpProfH,

  gpprofCommon;

const
  BUF_SIZE = 64 * 1024; //64*1024;

type
  TMeasurePointScope = class(TInterfacedObject, IMeasurePointScope)
  private
    fMeasurePointId : String;
  public
    constructor Create(const aMeasurePointId : String);
    destructor Destroy; override;
  end;

  TTLEl = record
    tleThread: integer;
    tleRemap : integer;
  end;

  PTLElements = ^TTLElements;
  TTLElements = array [0..0] of TTLEl;

  TThreadList = class
  private
    tlItems: PTLElements;
    tlCount: Cardinal;
    tlRemap: Cardinal;
    tlLast : Cardinal;
    tlLastR: Cardinal;
    function Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
  public
    constructor Create;
    destructor  Destroy; override;
    function    Remap(const aThreadId: Cardinal): integer;
    property    Count: Cardinal read tlCount;
  end;

  TThreadInformation = class
    ID : cardinal;
    Name : ansistring;
  end;

  TThreadInformationList = TObjectList<TThreadInformation>;

var
  prfFile        : THandle;
  prfBuf         : pointer;
  prfBufOffs     : integer;
  prfLock        : TRTLCriticalSection;
  prfFreq        : int64;
  prfCounter     : int64;
  prfModuleName  : string;
  prfName        : string;
  prfRunning     : boolean;
  prfLastTick    : int64;
  prfOnlyThread  : Cardinal;
  prfThreads     : TThreadList;
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

procedure FlushFile;
var
  written: DWORD;
begin
  Win32Check(WriteFile(prfFile, prfBuf^, BUF_SIZE, written, nil));
  prfBufOffs := 0;
  FillChar(prfBuf^, BUF_SIZE, 0);
end; { FlushFile }

function OffsetPtr(ptr: Pointer; offset: NativeUInt): Pointer;
begin
  Result := Pointer(NativeUInt(ptr) + offset);
end; { OffsetPtr }

procedure Transmit(const buf; count: DWORD);
var
  res    : boolean;
  place  : DWORD;
  bufp   : pointer;
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
      res := WriteFile(prfFile,prfBuf^,BUF_SIZE,written,nil);
      if not res then RaiseLastWin32Error;
      Dec(count,BUF_SIZE);
      bufp := OffsetPtr(bufp,BUF_SIZE);
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
procedure WriteInt   (int: integer);  begin Transmit(int, SizeOf(integer)); end;
procedure WriteCardinal   (value: Cardinal);  begin Transmit(value, SizeOf(Cardinal)); end;
procedure WriteTag   (tag: byte);     begin Transmit(tag, SizeOf(byte)); end;
procedure WriteID    (id: integer);   begin Transmit(id, profProcSize); end;
procedure WriteGuid    (guid: TGUID);   begin Transmit(guid, SizeOf(TGUID)); end;
procedure WriteBool  (bool: boolean); begin Transmit(bool, 1); end;
procedure WriteAnsiString  (const value: ansistring);
begin
  WriteCardinal(Length(value));
  if Length(Value)>0 then
    Transmit(value[1], Length(value));
end;

procedure WriteTicks(ticks: int64);
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

procedure FlushCounter;
begin
  if prfCounter <> 0 then begin
    WriteTicks(prfCounter);
    prfCounter := 0;
  end;
end; { FlushCounter }

procedure profilerEnterProc(const aProcID : Cardinal);
var
  ct : Cardinal;
  cnt: int64;
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
      WriteID(aProcID);
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
      WriteID(aProcID);
      WriteTicks(Cnt);
      if profProfilingMemoryEnabled then
        WriteMemWorkingSize();
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerExitProc }

function CreateMeasurePointScope(const aMeasurePointId : String): IMeasurePointScope;
begin
  result := TMeasurePointScope.Create(aMeasurePointId);
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

function CombineNames(fName, newExt: string): string;
begin
  Result := Copy(fName,1,Length(fName)-Length(ExtractFileExt(fName)))+'.'+newExt;
end; { CombineNames }

procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
begin
  NameThreadForDebugging(string(aThreadName), aThreadID);
end; { NameThreadForDebugging }


procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;
var LEntry : TThreadInformation;
begin
  TThread.NameThreadForDebugging(aThreadName, aThreadId);
  if not prfDisabled then
  begin
    LEntry := TThreadInformation.Create;
    LEntry.ID := AThreadId;
    LEntry.Name := utf8Encode(AThreadName);
    prfThreadsInfo.Add(LEntry);
  end;
end; { NameThreadForDebugging }


{ TThreadList }

constructor TThreadList.Create;
begin
  inherited Create;
  tlCount := 0;
  tlRemap := 0;
  tlItems := nil;
  tlLast := 0;
  tlLastR := 0;
end; { TThreadList.Create }

destructor TThreadList.Destroy;
begin
  if tlItems <> nil then Dispose(tlItems);
  inherited Destroy;
end; { TThreadList.Destroy }

function TThreadList.Remap(const aThreadId: Cardinal): integer;
var
  remap   : Cardinal;
  insert  : Cardinal;
  tmpItems: PTLElements;
begin
  if aThreadId = tlLast then
    Result := tlLastR
  else if not Search(aThreadId, remap, insert) then begin
    // reallocate tlItems
    GetMem(tmpItems, SizeOf(TTLEl)*(tlCount+1));
    if tlItems <> nil then begin
      Move(tlItems^, tmpItems^, Sizeof(TTLEl)*tlCount);
      FreeMem(tlItems);
    end;
    tlItems := tmpItems;
    // get new remap number
    Inc(tlRemap);
    if byte(tlRemap) = 0 then Inc(tlRemap);
    // insert new element
    if insert < tlCount then
      Move(tlItems^[insert], tlItems^[insert + 1], (tlCount-insert)*SizeOf(TTLEl));
    with tlItems^[Insert] do begin
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
    tlLastR := remap;
    Result  := remap;
  end;
end; { TThreadList.Remap }

function TThreadList.Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
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
end; { TThreadList.Search }

procedure ReadIncSettings;
var
  buf: array [0..256] of char;
  ini: string;
begin
  GetModuleFileName(HInstance,buf,256);
  prfModuleName := string(buf);
  prfDisabled := true;
  profProfilingAutostart := false;
  ini := Copy(prfModuleName,1,Length(prfModuleName)-Length(ExtractFileExt(prfModuleName)))+'.GPI';
  if not FileExists(ini) then
    MessageBox(0, PChar(Format('Cannot find initialization file %s! '+
      'Profiling will be disabled.', [ini])), 'GpProfile', MB_OK + MB_ICONERROR)
  else begin
    with TIniFile.Create(ini) do begin
      profTableName := ReadString('IDTables','TableName','');
      if profTableName <> '' then begin
        if not FileExists(profTableName) then
          MessageBox(0, PChar(Format('Cannot find data file %s! '+
            'Profiling will be disabled.', [profTableName])), 'GpProfile',
            MB_OK + MB_ICONERROR)
        else begin
          profProcSize           := ReadInteger('Procedures','ProcSize',4);
          profCompressTicks      := ReadBool('Performance','CompressTicks',false);
          profCompressThreads    := ReadBool('Performance','CompressThreads',false);
          profProfilingAutostart := ReadBool('Performance','ProfilingAutostart',true);
          profProfilingMemoryEnabled := ReadBool('Performance','ProfilingMemSupport',false);
          profPrfOutputFile := ReadString('Output','PrfOutputFilename','$(ModulePath)');
          profPrfOutputFile := ResolvePrfRuntimePlaceholders(profPrfOutputFile);
          prfDisabled            := false;
        end;
      end;
      Free;
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
  ReadIncSettings;
  try
    ReadIncSettings;
    if not prfDisabled then begin
      prfRunning          := profProfilingAutostart;
      prfCounter          := 0;
      prfOnlyThread       := 0;
      prfThreads          := TThreadList.Create;
      prfThreadsInfo      := TThreadInformationList.Create();
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
                            FILE_ATTRIBUTE_NORMAL + FILE_FLAG_WRITE_THROUGH +
                            FILE_FLAG_NO_BUFFERING, 0);
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
begin
  if not FileExists(profTableName) then prfDisabled := true
  else begin
    Assign(f,profTableName);
    Reset(f,1);
    try
      GetMem(p,FileSize(f));
      try
        BlockRead(f,p^,FileSize(f));
        Transmit(p^,FileSize(f));
      finally FreeMem(p); end;
    finally Close(f); end;
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
  FlushFile;
  Win32Check(CloseHandle(prfFile));
  FreeMem(prfBuf, BUF_SIZE);
  prfThreads.Free;
  prfThreadsInfo.free;
  DeleteCriticalSection(prfLock);
end; { Finalize }

procedure ProfilerTerminate;
var i : integer;
begin
  if not prfInitialized then Exit;
  ProfilerStop;
  prfInitialized := False;
  FlushCounter;
  WriteTag(PR_ENDDATA);

  WriteTag(PR_START_THREADINFO);
  WriteCardinal(prfThreadsInfo.count);
  for i := 0 to prfThreadsInfo.count-1 do
  begin
    WriteCardinal(prfThreadsInfo[i].ID);
    WriteAnsiString(prfThreadsInfo[i].Name);
  end;
  WriteInt(PR_END_THREADINFO);

  Finalize;

end; { ProfilerTerminate }


{ TMeasurePointScope }

constructor TMeasurePointScope.Create(const aMeasurePointId: String);

  procedure ProfilerEnterMP(const aMeasurePointId : String);
  var
    ct : Cardinal;
    cnt: int64;
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
        WriteAnsiString(utf8Encode(aMeasurePointId));
        WriteTicks(Cnt);
        if profProfilingMemoryEnabled then
          WriteMemWorkingSize();
        QueryPerformanceCounter(prfCounter);
      finally LeaveCriticalSection(prfLock); end;
    end;
  end;

begin
  fMeasurePointId := aMeasurePointId;
  ProfilerEnterMP(fMeasurePointId);
end;

destructor TMeasurePointScope.Destroy;
  procedure ProfilerExitMP(const aMeasurePointId : String);
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
        WriteTag(PR_EXIT_MP);
        WriteThread(ct);
        WriteAnsiString(utf8Encode(aMeasurePointId));
        WriteTicks(Cnt);
        if profProfilingMemoryEnabled then
          WriteMemWorkingSize();
        QueryPerformanceCounter(prfCounter);
      finally LeaveCriticalSection(prfLock); end;
    end;
  end;

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

