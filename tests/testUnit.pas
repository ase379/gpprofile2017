unit testUnit;

interface

procedure TestProcedure;
procedure TestFunction;
procedure TestFunctionNestedType;
procedure TestThread();

implementation

uses testThreads;

procedure TestProcedure;
begin
end;


procedure TestFunction;
begin
end;


procedure TestFunctionNestedType;
type
  TRecord = record
    A, B : integer;
  end;
begin
end;


procedure TestThread();
var lThread : TTestThread;
begin
  lThread := TTestThread.Create;
  //FreeOnTerminate is true
end;


end.
