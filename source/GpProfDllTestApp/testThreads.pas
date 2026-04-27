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
var lPointer : Pointer;
begin
  NameThreadForDebugging('AwesomeThread', self.ThreadID);
  var lOuterScope := GpProfDllClient.CreateMeasurePointScope('MP_TestThreadExecuteOuter');
  NameThreadForDebugging('AwesomeThread-UnicodeChars-☺☼d156exÈ', self.ThreadID);
  var lInnerScope := GpProfDllClient.CreateMeasurePointScope('MP_TestThreadExecuteInner');
  self.namethreadfordebugging('AwesomeThread2-SelfNameReplacement', self.ThreadID);
  TThread.NameThreadForDebugging('AwesomeThread3-TThreadReplacement');
  Sleep(1000);
  GetMem(lPointer, 1024);
  lInnerScope := nil;
  Sleep(1000);
  FreeMem(lPointer);
  lOuterScope := nil;
  inherited;
end;

end.
