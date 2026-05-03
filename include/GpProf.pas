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
  GpProfLists,
  GpProfCommon;

const
  BUF_SIZE_DEFAULT = 64 * 1024; // 64 KB

type
  TMeasurePointScope = class(TInterfacedObject, IMeasurePointScope)
  private
    fMeasurePointId : UTF8String;
  public
    constructor Create(const aMeasurePointId : UTF8String);
    destructor Destroy; override;
  end;

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
  profBufSize           : integer = BUF_SIZE_DEFAULT;

procedure FlushFile; inline;
var
  written: DWORD;
begin
  if WriteFile(prfFile, prfBuf^, prfBufOffs, written, nil) then begin
    prfBufOffs := 0;
  end else
    RaiseLastWin32Error;
end; { FlushFile }

function OffsetPtr(ptr: Pointer; offset: NativeUInt): Pointer; inline;
begin
  Result := Pointer(NativeUInt(ptr) + offset);
end; { OffsetPtr }

procedure Transmit(const buf; count: integer);
var
  bufp   : pointer;
  place  : integer;
  written: DWORD;
begin
  place := profBufSize - prfBufOffs;
  if place <= count then begin
    Move(buf,OffsetPtr(prfBuf,prfBufOffs)^,place); // fill the buffer
    prfBufOffs := profBufSize;
    FlushFile;
    Dec(count,place);
    bufp := OffsetPtr(@buf,place);
    if count >= profBufSize then begin
      if WriteFile(prfFile, bufp^, count, written, nil) then begin
        count := 0;
      end else
        RaiseLastWin32Error;
    end;
  end else
    bufp := @buf;
  if count > 0 then begin // store leftovers
    Move(bufp^,OffsetPtr(prfBuf,prfBufOffs)^,count);
    Inc(prfBufOffs,count);
  end;
end; { Transmit }

function GetMemWorkingSize() : Cardinal;
var
  i: Integer;
  LState: TMemoryManagerState;
  LSmallBlocks: TSmallBlockTypeStates;
  LSmallBlock: ^TSmallBlockTypeState;
begin
  Result := 0;
  GetMemoryManagerState(LState);
  LSmallBlocks := LState.SmallBlockTypeStates;
  for i := Low(LSmallBlocks) to High(LSmallBlocks) do
  begin
    LSmallBlock := @LSmallBlocks[i];
    Inc(Result,LSmallBlock.AllocatedBlockCount*LSmallBlock.UseableBlockSize);
  end;
  Inc(Result,LState.TotalAllocatedMediumBlockSize);
  Inc(Result,LState.TotalAllocatedLargeBlockSize);
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

procedure ReadIncSettings;
var
  LBuf: array [0..256] of char;
  LIniFileName: string;
  LIni: TMemIniFile;
  LBufSizeKB: Integer;
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

          LBufSizeKB := BUF_SIZE_DEFAULT div 1024;
          profBufSize := LIni.ReadInteger('Output','BufSizeKB',LBufSizeKB);
          if (profBufSize >= LBufSizeKB) and (profBufSize < 1024 * 1024 {1 GB}) then
          begin
            profBufSize := profBufSize * 1024;
          end else
          begin
            MessageBox(0, PChar(Format('Invalid BufSizeKB value: %d, fallback to the default size %d KB',
              [profBufSize, LBufSizeKB])), 'GpProfile', MB_OK + MB_ICONERROR);
            profBufSize := BUF_SIZE_DEFAULT;
          end;

          prfDisabled := false;
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
      GetMem(prfBuf,profBufSize);
      Win32Check(prfBuf <> nil);
      prfBufOffs          := 0;
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
  FreeMem(prfBuf);
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

    // write thread names
    WriteTag(PR_START_THREADINFO);
    WriteCardinal(prfThreadsInfo.count);
    for i := 0 to prfThreadsInfo.count-1 do
    begin
      LItem := TThreadInformation(prfThreadsInfo[i]);
      WriteCardinal(LItem.ID);
      WriteUtf8String(LItem.Name);
    end;
    WriteTag(PR_END_THREADINFO);

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
      WriteTag(PR_END_THREAD_ID_LIST);
    end;

    if prfBufOffs > 0 then
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

