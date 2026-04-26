unit testGpProfDll;

(*
  Unit tests for the GpProfDll instrumentation DLL.

  These tests verify that all exported profiling functions can be called
  without raising exceptions. When no .GPI file is present for the DLL,
  prfDisabled is set to true and all operations are safe no-ops. The test
  suite therefore exercises the full public API in a controlled environment.
*)

interface

procedure TestProfilerStartStop;
procedure TestProfilerEnterExitProc;
procedure TestProfilerEnterExitMeasurePoint;
procedure TestMeasurePointScope;
procedure TestNameThreadForDebugging;

implementation

uses
  GpProf;

procedure TestProfilerStartStop;
begin
  ProfilerStart;
  ProfilerStop;
  ProfilerStart;
  ProfilerStop;
end;

procedure TestProfilerEnterExitProc;
begin
  ProfilerStart;
  ProfilerEnterProc(1);
  ProfilerEnterProc(2);
  ProfilerExitProc(2);
  ProfilerExitProc(1);
  ProfilerStop;
end;

procedure TestProfilerEnterExitMeasurePoint;
begin
  ProfilerStart;
  ProfilerEnterMP('TestMeasurePoint');
  ProfilerExitMP('TestMeasurePoint');
  ProfilerStop;
end;

procedure TestMeasurePointScope;
var
  lScope: IMeasurePointScope;
begin
  ProfilerStart;
  lScope := CreateMeasurePointScope('ScopeTest');
  lScope := nil; // release the last reference — reference-counting triggers the destructor, which calls ProfilerExitMP
  ProfilerStop;
end;

procedure TestNameThreadForDebugging;
begin
  // TThreadID(-1) names the calling thread (matches the default parameter value)
  NameThreadForDebugging('TestThread', TThreadID(-1));
end;

end.
