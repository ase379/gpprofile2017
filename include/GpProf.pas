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

procedure ProfilerStart;
procedure ProfilerStop;
procedure ProfilerStartThread;
procedure ProfilerEnterProc(procID: integer);
procedure ProfilerExitProc(procID: integer);
procedure ProfilerTerminate;
procedure NameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
procedure NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;

implementation

uses
  System.Generics.Collections,
  Windows,
  SysUtils,
  IniFiles,
  GpProfWriter,
  GpProfH,
  gpprofCommon;


type
{$IFNDEF VER100}{$IFNDEF VER110}{$DEFINE NeedTLI}{$ENDIF}{$ENDIF}
{$IFDEF NeedTLI}
  TInt64 = int64;
  TLargeInteger = record
    case integer of
      0: (LowPart: DWord; HighPart: LongInt);
      1: (QuadPart: Comp);
  end;
{$ELSE}
  TInt64 = TLargeInteger;
{$ENDIF}

  TTLEl = record
    tleThread: integer;
    tleRemap : integer;
  end;

  PTLElements = ^TTLElements;
  TTLElements = array [0..0] of TTLEl;

  TThreadList = class
  private
    tlItems: PTLElements;
    tlCount: integer;
    tlRemap: integer;
    tlLast : integer;
    tlLastR: integer;
    function Search(thread: integer; var remap, insertIdx: integer): boolean;
  public
    constructor Create;
    destructor  Destroy; override;
    function    Remap(thread: integer): integer;
    property    Count: integer read tlCount;
  end;

  TThreadInformation = class
    ID : cardinal;
    Name : ansistring;
  end;

  TThreadInformationList = TObjectList<TThreadInformation>;

var
  prfWriter      : TBufferedWriter;
  prfLock        : TRTLCriticalSection;
  prfFreq        : TLargeInteger;
  prfCounter     : TLargeInteger;
  prfModuleName  : string;
  prfName        : string;
  prfRunning     : boolean;
  prfLastTick    : Comp;
  prfOnlyThread  : integer;
  prfThreads     : TThreadList;
  prfThreadsInfo : TThreadInformationList;
  prfThreadBytes : integer;
  prfMaxThreadNum: integer;
  prfInitialized : boolean;
  prfDisabled    : boolean;

  profProcSize          : integer;
  profCompressTicks     : boolean;
  profCompressThreads   : boolean;
  profProfilingAutostart: boolean;
  profPrfOutputFile     : string;
  profTableName         : string;



procedure WriteTicks(ticks: Comp);
type
  TTick = array [1..8] of Byte;
var
  diff: integer;
begin
  if not profCompressTicks then prfWriter.Transmit(ticks, Sizeof(Comp))
  else begin
    if prfLastTick = -1 then diff := 8
    else begin
      diff := 8;
      while (diff > 0) and (TTick(ticks)[diff] = TTick(prfLastTick)[diff]) do
        Dec(diff);
      Inc(diff);
    end;
    prfWriter.Transmit(diff, 1);
    prfWriter.Transmit(ticks, diff);
    prfLastTick := ticks;
  end;
end; { WriteTicks }

procedure WriteThread(thread: integer);
const
  marker: integer = 0;
var
  remap: integer;
begin
  if not profCompressThreads then prfWriter.Transmit(thread, Sizeof(integer))
  else begin
    remap := prfThreads.Remap(thread);
    if prfThreads.Count >= prfMaxThreadNum then begin
      prfWriter.Transmit(marker, prfThreadBytes);
      prfMaxThreadNum := 2 * prfMaxThreadNum;
      prfThreadBytes := prfThreadBytes + 1;
    end;
    prfWriter.Transmit(remap, prfThreadBytes);
  end;
end; { WriteThread }

procedure FlushCounter;
begin
  if prfCounter.QuadPart <> 0 then begin
    WriteTicks(prfCounter.QuadPart);
    prfCounter.QuadPart := 0;
  end;
end; { FlushCounter }

procedure profilerEnterProc(procID : integer);
var
  ct : integer;
  cnt: TLargeinteger;
begin
  QueryPerformanceCounter(TInt64((@cnt)^));
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      prfWriter.WriteTag(PR_ENTERPROC);
      WriteThread(ct);
      prfWriter.WriteID(procID);
      WriteTicks(Cnt.QuadPart);
      QueryPerformanceCounter(TInt64((@prfCounter)^));
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerEnterProc }

procedure ProfilerExitProc(procID : integer);
var
  ct : integer;
  cnt: TLargeinteger;
begin
  QueryPerformanceCounter(TInt64((@Cnt)^));
  ct := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = ct)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      prfWriter.WriteTag(PR_EXITPROC);
      WriteThread(ct);
      prfWriter.WriteID(procID);
      WriteTicks(Cnt.QuadPart);
      QueryPerformanceCounter(TInt64((@prfCounter)^));
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerExitProc }

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

procedure NameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
begin
  NameThreadForDebugging(string(aThreadName), aThreadID);
end; { NameThreadForDebugging }


procedure NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;
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

function TThreadList.Remap(thread: integer): integer;
var
  remap   : integer;
  insert  : integer;
  tmpItems: PTLElements;
begin
  if thread = tlLast then Result := tlLastR
  else if not Search(thread, remap, insert) then begin
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
      tleThread := thread;
      tleRemap  := tlRemap;
    end;
    Inc(tlCount);
    tlLast  := thread;
    tlLastR := tlRemap;
    Result  := tlRemap;
  end
  else begin
    tlLast  := thread;
    tlLastR := remap;
    Result  := remap;
  end;
end; { TThreadList.Remap }

function TThreadList.Search(thread: integer; var remap, insertIdx: integer): boolean;
var
  l, m, h: integer;
  mid    : integer;
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
      if thread = mid then begin
        remap := tlItems^[m].tleRemap;
        Result := True;
        Exit;
      end else if thread < mid then H := m - 1
      else L := m + 1;
    until L > H;
    Result := False;
    if thread > mid then insertIdx := m + 1
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
  Append(myFile);
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
      prfCounter.QuadPart := 0;
      prfOnlyThread       := 0;
      prfThreads          := TThreadList.Create;
      prfThreadsInfo      := TThreadInformationList.Create();
      prfMaxThreadNum     := 256;
      prfThreadBytes      := 1;
      prfLastTick         := -1;
      prfName             := CombineNames(prfModuleName, 'prf');
      if profPrfOutputFile <> '' then
        prfName := profPrfOutputFile + '.prf';
      InitializeCriticalSection(prfLock);
      prfWriter := TBufferedWriter.Create(prfName, profProcSize);
      QueryPerformanceFrequency(TInt64((@prfFreq)^));
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
  prfWriter.WriteTag(PR_PRFVERSION);
  prfWriter.WriteInt(PRF_VERSION);
  prfWriter.WriteTag(PR_COMPTICKS);
  prfWriter.WriteBool(profCompressTicks);
  prfWriter.WriteTag(PR_COMPTHREADS);
  prfWriter.WriteBool(profCompressThreads);
  prfWriter.WriteTag(PR_FREQUENCY);
  WriteTicks(prfFreq.QuadPart);
  prfWriter.WriteTag(PR_PROCSIZE);
  prfWriter.WriteInt(profProcSize);
  prfWriter.WriteTag(PR_ENDHEADER);
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
        prfWriter.Transmit(p^,FileSize(f));
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
  prfWriter.WriteTag(PR_STARTCALIB);
  prfWriter.WriteInt(CALIB_CNT);
  for i := 1 to CALIB_CNT + 1 do begin
    ProfilerEnterProc(0);
    ProfilerExitProc(0);
  end;
  FlushCounter;
  prfWriter.WriteTag(PR_ENDCALIB);
  prfRunning := run;
end; { WriteCalibration }

procedure Finalize;
begin
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
  prfWriter.WriteTag(PR_ENDDATA);

  prfWriter.WriteTag(PR_START_THREADINFO);
  prfWriter.WriteCardinal(prfThreadsInfo.count);
  for i := 0 to prfThreadsInfo.count-1 do
  begin
    prfWriter.WriteCardinal(prfThreadsInfo[i].ID);
    prfWriter.WriteAnsiString(prfThreadsInfo[i].Name);
  end;
  prfWriter.WriteInt(PR_END_THREADINFO);
  Finalize;

end; { ProfilerTerminate }


initialization
  prfInitialized := false;
  Initialize;
  if not prfDisabled then begin
    WriteHeader;
    CopyTables;
    WriteCalibration;
    prfWriter.WriteTag(PR_STARTDATA);
    prfInitialized := true;
    gpprof.NameThreadForDebugging('Main Application Thread', MainThreadID);
  end;
finalization
  ProfilerTerminate;
end.

