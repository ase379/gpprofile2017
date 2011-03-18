{$R-,C-,Q-,O+}

(*
  2.0: 
    - Most of the processing logic has been moved from gppResults to this file.
      Now profiling runs faster and with more accuracy!
      Drawback - new code works only in D4 (and above, of courese), D2 and D3
      clients have to use old code.
  1.0.1: 1999-05-12
    - Support for DLL and package profiling (GetModuleName is used instead of
      ParamStr(0)).
    - Error is reported if <module>.gpi or <module>.gpd file is not found.
*)

unit gpprof2;

interface

procedure ProfilerStart;
procedure ProfilerStop;
procedure ProfilerStartThread;
procedure ProfilerEnterProc(procID: integer);
procedure ProfilerExitProc(procID: integer);
procedure ProfilerTerminate;

implementation

uses
  Windows,
  SysUtils,
  IniFiles,
  Classes,
  GpProfH,
  gppResults;

const
  BUF_SIZE = 64 * 1024; //64*1024;

type
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

var
  prfLock        : TRTLCriticalSection;
  prfFreq        : int64;
  prfCounter     : int64;
  prfDoneMsg     : integer;
  prfModuleName  : string;
  prfName        : string;
  prfRunning     : boolean;
  prfLastTick    : Comp;
  prfOnlyThread  : integer;
  prfThreads     : TThreadList;
  prfThreadBytes : integer;
  prfMaxThreadNum: integer;
  prfInitialized : boolean;
  prfDisabled    : boolean;
  prfResults     : TResults;
  prfPktBuf      : TResPacket;
  prfTagBuf      : byte;

  profProcSize          : integer;
  profCompressTicks     : boolean;
  profCompressThreads   : boolean;
  profProfilingAutostart: boolean;
  profTableName         : string;

function OffsetPtr(ptr: pointer; offset: DWORD): pointer;
begin
  Result := pointer(DWORD(ptr)+offset);
end; { OffsetPtr }

procedure FlushCounter;
begin
  if prfCounter <> 0 then begin
    prfPktBuf.rpMeasure2 := prfCounter;
    if prfTagBuf = PR_ENTERPROC
      then prfResults.AddEnterProc(prfPktBuf)
      else prfResults.AddExitProc(prfPktBuf);
    prfCounter := 0;
  end;
end; { FlushCounter }

procedure ProfilerEnterProc(procID : integer);
var
  ct : integer;
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
      prfTagBuf := PR_ENTERPROC;
      prfPktBuf.rpThread   := ct;
      prfPktBuf.rpProcID   := procID;
      prfPktBuf.rpMeasure1 := cnt;
      QueryPerformanceCounter(prfCounter);
    finally LeaveCriticalSection(prfLock); end;
  end;
end; { ProfilerEnterProc }

procedure ProfilerExitProc(procID : integer);
var
  ct : integer;
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
      prfTagBuf := PR_EXITPROC;
      prfPktBuf.rpThread   := ct;
      prfPktBuf.rpProcID   := procID;
      prfPktBuf.rpMeasure1 := cnt;
      QueryPerformanceCounter(prfCounter);
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
          prfDisabled            := false;
        end;
      end;
      Free;
    end;
  end;
end; { ReadIncSettings }

procedure Initialize;
begin
  ReadIncSettings;
  if not prfDisabled then begin
    prfRunning      := profProfilingAutostart;
    prfCounter      := 0;
    prfOnlyThread   := 0;
    prfThreads      := TThreadList.Create;
    prfMaxThreadNum := 256;
    prfThreadBytes  := 1;
    prfLastTick     := -1;
    prfDoneMsg      := RegisterWindowMessage(CMD_MESSAGE);
    prfName         := CombineNames(prfModuleName, 'prf');
    prfResults      := TResults.Create;
    InitializeCriticalSection(prfLock);
    QueryPerformanceFrequency(prfFreq);
    prfResults.resFrequency := prfFreq;
  end;
end; { Initialize }

procedure CopyTables;
begin
  prfResults.AssignTables(profTableName);
end; { CopyTables }

procedure WriteCalibration;
var
  i  : integer;
  run: boolean;
begin
  run := prfRunning;
  prfRunning := True;
  prfResults.StartCalibration(CALIB_CNT);
  for i := 1 to CALIB_CNT + 1 do begin
    ProfilerEnterProc(0);
    ProfilerExitProc(0);
  end;
  FlushCounter;
  prfResults.StopCalibration;
  prfRunning := run;
end; { WriteCalibration }

procedure Finalize;
begin
  prfThreads.Free;
  DeleteCriticalSection(prfLock);
  prfResults.RecalcTimes;
  prfResults.SaveDigest(prfName);
  PostMessage(HWND_BROADCAST, prfDoneMsg, CMD_DONE, 0);
end; { Finalize }

procedure ProfilerTerminate;
begin
  if not prfInitialized then Exit;
  ProfilerStop;
  prfInitialized := False;
  FlushCounter;
  Finalize;
end; { ProfilerTerminate }

initialization
  prfInitialized := false;
  Initialize;
  if not prfDisabled then begin
    CopyTables;
    WriteCalibration;
    prfInitialized := true;
  end;
finalization
  ProfilerTerminate;
end.

