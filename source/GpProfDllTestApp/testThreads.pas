unit testThreads;

interface

uses
  System.Classes;

type
  TTestThread = class(TThread)
  public
    constructor Create();
  protected
    procedure Execute; override;
  end;


procedure TestThreadsGlobalFunc();


implementation

uses
  System.SysUtils, GpProfDllClient;

procedure TestThreadsGlobalFunc();
begin
end;

{ TTestThread }

constructor TTestThread.Create;
begin
  inherited Create();
end;

procedure TTestThread.Execute;
var
  lPointer: Pointer;
  lCtx: IGpProfContext;
  lOuterScope: IMeasurePointScope;
  lInnerScope: IMeasurePointScope;
begin
  lCtx := AcquireGpProfContext;
  try
    if Assigned(lCtx) then lCtx.NameThread('AwesomeThread', self.ThreadID);
    if Assigned(lCtx) then lOuterScope := lCtx.CreateMeasurePointScope('MP_TestThreadExecuteOuter');
    if Assigned(lCtx) then lCtx.NameThread('AwesomeThread-UnicodeChars-☺☼d156exÈ', self.ThreadID);
    if Assigned(lCtx) then lInnerScope := lCtx.CreateMeasurePointScope('MP_TestThreadExecuteInner');
    self.namethreadfordebugging('AwesomeThread2-SelfNameReplacement', self.ThreadID);
    TThread.NameThreadForDebugging('AwesomeThread3-TThreadReplacement');
    Sleep(1000);
    GetMem(lPointer, 1024);
    lInnerScope := nil;
    Sleep(1000);
    FreeMem(lPointer);
    lOuterScope := nil;
  finally
    DisposeGpProfContext(lCtx);
  end;
  inherited;
end;

end.
