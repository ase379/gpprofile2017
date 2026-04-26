unit testGpProfDll;

(*
  DUnit test cases for the GpProfDll instrumentation DLL.

  When no .GPI file is present for the DLL, prfDisabled is set to true
  and all profiling calls are safe no-ops, so the tests are self-contained
  and can run without any special setup.
*)

interface

uses
  TestFramework,
  GpProf;

type
  TTestGpProfDll = class(TTestCase)
  published
    procedure TestProfilerStartStop;
    procedure TestProfilerEnterExitProc;
    procedure TestProfilerEnterExitMeasurePoint;
    procedure TestMeasurePointScope;
    procedure TestNameThreadForDebugging;
  end;

implementation

{ TTestGpProfDll }

procedure TTestGpProfDll.TestProfilerStartStop;
begin
  ProfilerStart;
  ProfilerStop;
  ProfilerStart;
  ProfilerStop;
end;

procedure TTestGpProfDll.TestProfilerEnterExitProc;
begin
  ProfilerStart;
  ProfilerEnterProc(1);
  ProfilerEnterProc(2);
  ProfilerExitProc(2);
  ProfilerExitProc(1);
  ProfilerStop;
end;

procedure TTestGpProfDll.TestProfilerEnterExitMeasurePoint;
begin
  ProfilerStart;
  ProfilerEnterMP('TestMeasurePoint');
  ProfilerExitMP('TestMeasurePoint');
  ProfilerStop;
end;

procedure TTestGpProfDll.TestMeasurePointScope;
var
  lScope: IMeasurePointScope;
begin
  ProfilerStart;
  lScope := CreateMeasurePointScope('ScopeTest');
  lScope := nil; // release the last reference — reference-counting triggers the destructor, which calls ProfilerExitMP
  ProfilerStop;
end;

procedure TTestGpProfDll.TestNameThreadForDebugging;
begin
  // TThreadID(-1) names the calling thread (matches the default parameter value)
  NameThreadForDebugging('TestThread', TThreadID(-1));
end;

initialization
  RegisterTest(TTestGpProfDll.Suite);

end.
