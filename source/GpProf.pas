{$R-,C-,Q-,O+}

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
  GpProfH;

const
  BUF_SIZE = 64 * 1024; //64*1024;

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

var
  prfFile        : THandle;
  prfBuf         : pointer;
  prfBufOffs     : integer;
  prfLock        : TRTLCriticalSection;
  prfFreq        : TLargeInteger;
  prfCounter     : TLargeInteger;
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

  profProcSize          : integer;
  profCompressTicks     : boolean;
  profCompressThreads   : boolean;
  profProfilingAutostart: boolean;
  profTableName         : string;

{$IFDEF VER90}
type
  EWin32Error = class(Exception)
  public
    ErrorCode : DWord;
  end;

const
  SWin32Error    = 'Win32 Error.  Code: %d.'#10'%s';
  SUnkWin32Error = 'A Win32 API function failed';

procedure RaiseLastWin32Error;
var
  LastError: DWord;
  error    : EWin32Error;
begin
  LastError := GetLastError;
  if LastError <> ERROR_SUCCESS then
    error := EWin32Error.CreateFmt(SWin32Error, [LastError, SysErrorMessage(LastError)])
  else
    error := EWin32Error.Create(SUnkWin32Error);
  error.ErrorCode := LastError;
  raise error;
end;

{ Win32Check }

function Win32Check(RetVal: BOOL): BOOL;
begin
  if not RetVal then
    RaiseLastWin32Error;
  Result := RetVal;
end;
{$ENDIF VER90}

procedure FlushFile;
var
  written: DWORD;
begin
  Win32Check(WriteFile(prfFile, prfBuf^, BUF_SIZE, written, nil));
  prfBufOffs := 0;
  FillChar(prfBuf^, BUF_SIZE, 0);
end; { FlushFile }

function OffsetPtr(ptr: pointer; offset: DWORD): pointer;
begin
  Result := pointer(DWORD(ptr)+offset);
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

procedure WriteInt   (int: integer);  begin Transmit(int, SizeOf(integer)); end;
procedure WriteTag   (tag: byte);     begin Transmit(tag, SizeOf(byte)); end;
procedure WriteID    (id: integer);   begin Transmit(id, profProcSize); end;
procedure WriteBool  (bool: boolean); begin Transmit(bool, 1); end;

procedure WriteTicks(ticks: Comp);
type
  TTick = array [1..8] of Byte;
var
  diff: integer;
begin
  if not profCompressTicks then Transmit(ticks, Sizeof(Comp))
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

procedure WriteThread(thread: integer);
const
  marker: integer = 0;
var
  remap: integer;
begin
  if not profCompressThreads then Transmit(thread, Sizeof(integer))
  else begin
    remap := prfThreads.Remap(thread);
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
      WriteTag(PR_ENTERPROC);
      WriteThread(ct);
      WriteID(procID);
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
      WriteTag(PR_EXITPROC);
      WriteThread(ct);
      WriteID(procID);
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
    prfRunning          := profProfilingAutostart;
    prfCounter.QuadPart := 0;
    prfOnlyThread       := 0;
    prfThreads          := TThreadList.Create;
    prfMaxThreadNum     := 256;
    prfThreadBytes      := 1;
    prfLastTick         := -1;
    prfDoneMsg          := RegisterWindowMessage(CMD_MESSAGE);
    prfName             := CombineNames(prfModuleName, 'prf');
    prfBuf              := VirtualAlloc(nil, BUF_SIZE, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
    prfBufOffs          := 0;
    Win32Check(VirtualLock(prfBuf, BUF_SIZE));
    Win32Check(prfBuf <> nil);
    FillChar(prfBuf^, BUF_SIZE, 0);
    InitializeCriticalSection(prfLock);
    prfFile := CreateFile(PChar(prfName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
                          FILE_ATTRIBUTE_NORMAL + FILE_FLAG_WRITE_THROUGH +
                          FILE_FLAG_NO_BUFFERING, 0);
    Win32Check(prfFile <> INVALID_HANDLE_VALUE);
    QueryPerformanceFrequency(TInt64((@prfFreq)^));
  end;
end; { Initialize }

procedure WriteHeader;
begin
  WriteTag(PR_PRFVERSION);
  WriteInt(PRF_VERSION);
  WriteTag(PR_COMPTICKS);
  WriteBool(profCompressTicks);
  WriteTag(PR_COMPTHREADS);
  WriteBool(profCompressThreads);
  WriteTag(PR_FREQUENCY);
  WriteTicks(prfFreq.QuadPart);
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
  Win32Check(VirtualUnlock(prfBuf, BUF_SIZE));
  Win32Check(VirtualFree(prfBuf, 0, MEM_RELEASE));
  prfThreads.Free;
  DeleteCriticalSection(prfLock);
  PostMessage(HWND_BROADCAST, prfDoneMsg, CMD_DONE, 0);
end; { Finalize }

procedure ProfilerTerminate;
begin
  if not prfInitialized then Exit;
  ProfilerStop;
  prfInitialized := False;
  FlushCounter;
  WriteTag(PR_ENDDATA);
  Finalize;
end; { ProfilerTerminate }

initialization
  prfInitialized := false;
  Initialize;
  if not prfDisabled then begin
    WriteHeader;
    CopyTables;
    WriteCalibration;
    WriteTag(PR_STARTDATA);
    prfInitialized := true;
  end;
finalization
  ProfilerTerminate;
end.

