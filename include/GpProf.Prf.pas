{$R-,C-,Q-,O+,H+}
unit Gpprof.prf;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}


uses System.Classes, GpProf.PrfStreamWriter, GpProf.PrfConfig, System.Sysutils,
  Windows,GpProf.PrfTypes;

type
  /// <summary>
  /// A performance tracker using functions calls togehter with the tickcount to profile the function invokation
  /// time. Thus, the result file (the Profiling Result File, prf) contains a dump of the call tree and the time
  ///  needed for each call in the tree.
  ///  The tree furthermore contains additional data about the threads.
  /// </summary>
  TPerformanceTracker = class
  private
    // a lock for async operations
    prfLock        : TRTLCriticalSection;
    // the frequency of the cpu as a ration for the speed
    prfFreq        : TLargeInteger;
    // the count
    prfCounter     : TLargeInteger;
    // the name of the prf
    prfName        : string;
    // true if running
    prfRunning     : boolean;
    // the the thread id of the thread currently processed
    prfOnlyThread  : integer;
    // a list of all threads and its ids
    prfThreads     : TThreadList;
    // a info list storing the thread data
    prfThreadsInfo : TThreadInformationList;
    // true if disabled.
    prfDisabled    : boolean;

    fPrfConfig : TPrfConfig;
    fPrfStreamWriter : TPrfStreamWriter;
    procedure FlushCounter();
    procedure InitConfig();

  public
    constructor Create();
    destructor Destroy; override;


    procedure ProfilerStart;
    procedure ProfilerStop;
    procedure ProfilerStartThread;
    procedure ProfilerEnterProc(procID: integer);
    procedure ProfilerExitProc(procID: integer);
    procedure ProfilerTerminate;
    procedure NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;

  end;

implementation

uses
  GpProfH;




{ TPrfWriter }



constructor TPerformanceTracker.Create;

  procedure CopyTables;
  var
    p: pointer;
    f: file;
  begin
    if not FileExists(fPrfConfig.ProfTableName) then prfDisabled := true
    else
    begin
      Assign(f,fPrfConfig.ProfTableName);
      Reset(f,1);
      try
        GetMem(p,FileSize(f));
        try
          BlockRead(f,p^,FileSize(f));
          fPrfStreamWriter.WriteBuffer(p^,FileSize(f));

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
    fPrfStreamWriter.WriteTag(PR_STARTCALIB);
    fPrfStreamWriter.WriteInt(CALIB_CNT);
    for i := 1 to CALIB_CNT + 1 do
    begin
      ProfilerEnterProc(0);
      ProfilerExitProc(0);
    end;
    FlushCounter;
    fPrfStreamWriter.WriteTag(PR_ENDCALIB);
    prfRunning := run;
  end; { WriteCalibration }
begin
  fPrfConfig := TPrfConfig.Create();
  InitializeCriticalSection(prfLock);

  // load config
  InitConfig();
  fPrfStreamWriter := TPrfStreamWriter.Create(fPrfConfig, prfName);

  /// writes the format header
  fPrfStreamWriter.WriteTag(PR_PRFVERSION);
  fPrfStreamWriter.WriteInt(PRF_VERSION);
  fPrfStreamWriter.WriteTag(PR_COMPTICKS);
  fPrfStreamWriter.WriteBool(fPrfConfig.ProfCompressTicks);
  fPrfStreamWriter.WriteTag(PR_COMPTHREADS);
  fPrfStreamWriter.WriteBool(fPrfConfig.profCompressThreads);
  fPrfStreamWriter.WriteTag(PR_FREQUENCY);
  fPrfStreamWriter.WriteTicks(prfFreq.QuadPart);
  fPrfStreamWriter.WriteTag(PR_PROCSIZE);
  fPrfStreamWriter.WriteInt(fPrfConfig.profProcSize);
  fPrfStreamWriter.WriteTag(PR_ENDHEADER);

  CopyTables;
  WriteCalibration;
  fPrfStreamWriter.WriteTag(PR_STARTDATA);
end;

destructor TPerformanceTracker.Destroy;
begin
  ProfilerTerminate;
  inherited;
end;


procedure TPerformanceTracker.FlushCounter;
begin
  if prfCounter.QuadPart <> 0 then begin
    fPrfStreamWriter.WriteTicks(prfCounter.QuadPart);
    prfCounter.QuadPart := 0;
  end;
end;

procedure TPerformanceTracker.InitConfig;

  function CombineNames(fName, newExt: string): string;
  begin
    Result := Copy(fName,1,Length(fName)-Length(ExtractFileExt(fName)))+'.'+newExt;
  end; { CombineNames }


  procedure AppendToErrorLog(const aFilename, aMessage : string);
  var
    myFile : TextFile;
  begin
    AssignFile(myFile, aFilename);
    Append(myFile);
    WriteLn(myFile, aMessage);
    CloseFile(myFile);
  end;

var
  buf: array [0..256] of char;
  ini: string;
  prfModuleName : string;
  LErrorPath : string;
  lError : string;
begin
  GetModuleFileName(HInstance,buf,256);
  prfModuleName := string(buf);
  prfName := CombineNames(prfModuleName, 'prf');

  ini := Copy(prfModuleName,1,Length(prfModuleName)-Length(ExtractFileExt(prfModuleName)))+'.GPI';
  if not FileExists(ini) then
  begin
    LErrorPath := ChangeFileExt(prfName, '.err');
    lError := Format('Cannot find initialization file %s! '+ 'Profiling will be disabled.', [ini]);
    AppendToErrorLog(LErrorPath, 'Error in initialize: '+lError);
    raise Exception.Create(lError);
  end;
  fPrfConfig.LoadFromFile(ini);
  if not prfDisabled then begin
      prfRunning          := fPrfConfig.ProfProfilingAutostart;
      prfCounter.QuadPart := 0;
      prfOnlyThread       := 0;
      prfThreads          := TThreadList.Create;
      prfThreadsInfo      := TThreadInformationList.Create();
      if fPrfConfig.profPrfOutputFile <> '' then
        prfName := fPrfConfig.profPrfOutputFile + '.prf';

      QueryPerformanceFrequency(TInt64((@prfFreq)^));
    end;
end;

procedure TPerformanceTracker.NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID);
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
end;



procedure TPerformanceTracker.ProfilerEnterProc(procID: integer);
var
  lCurrentThreadId : integer;
  cnt: TLargeinteger;
begin
  QueryPerformanceCounter(TInt64((@cnt)^));
  lCurrentThreadId := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = lCurrentThreadId)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      fPrfStreamWriter.WriteEnterProc(prfThreads, lCurrentThreadId, procId,cnt.QuadPart);
      QueryPerformanceCounter(TInt64((@prfCounter)^));
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

procedure TPerformanceTracker.ProfilerExitProc(procID: integer);
var
  lCurrentThreadId : integer;
  cnt: TLargeinteger;
begin
  QueryPerformanceCounter(TInt64((@Cnt)^));
  lCurrentThreadId := GetCurrentThreadID;
{$B+}
  if prfRunning and ((prfOnlyThread = 0) or (prfOnlyThread = lCurrentThreadId)) then begin
{$B-}
    EnterCriticalSection(prfLock);
    try
      FlushCounter;
      fPrfStreamWriter.WriteExitProc(prfThreads, lCurrentThreadId, procID, cnt.QuadPart);
      QueryPerformanceCounter(TInt64((@prfCounter)^));
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

procedure TPerformanceTracker.ProfilerStart;
begin
  if not prfDisabled then begin
    EnterCriticalSection(prfLock);
    try prfRunning := true;
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

procedure TPerformanceTracker.ProfilerStartThread;
begin
  EnterCriticalSection(prfLock);
  try
    prfRunning := true;
    prfOnlyThread := GetCurrentThreadID;
  finally LeaveCriticalSection(prfLock); end;
end;

procedure TPerformanceTracker.ProfilerStop;
begin
  if not prfDisabled then
  begin
    EnterCriticalSection(prfLock);
    try prfRunning := false;
    finally LeaveCriticalSection(prfLock); end;
  end;
end;

procedure TPerformanceTracker.ProfilerTerminate;
var
  i : integer;
begin
  ProfilerStop;
  if assigned(fPrfStreamWriter) then
  begin
    FlushCounter;
    fPrfStreamWriter.WriteTag(PR_ENDDATA);

    fPrfStreamWriter.WriteTag(PR_START_THREADINFO);
    fPrfStreamWriter.WriteCardinal(prfThreadsInfo.count);
    for i := 0 to prfThreadsInfo.count-1 do
    begin
      fPrfStreamWriter.WriteCardinal(prfThreadsInfo[i].ID);
      fPrfStreamWriter.WriteAnsiString(prfThreadsInfo[i].Name);
    end;
    fPrfStreamWriter.WriteInt(PR_END_THREADINFO);
  end;
  FreeAndNil(fPrfConfig);
  FreeAndNil(fPrfStreamWriter);
  prfThreads.Free;
  prfThreadsInfo.free;
  DeleteCriticalSection(prfLock);
end;

end.
