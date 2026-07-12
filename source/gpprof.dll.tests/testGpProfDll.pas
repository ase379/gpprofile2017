unit testGpProfDll;

(*
  DUnit test cases for the GpProf instrumentation unit.

  Tests are split into two suites:

  TTestGpProfCommon  – tests for GpProfCommon.ResolvePrfRuntimePlaceholders.
                       These are fully self-contained; no .GPI file is needed.

  TTestGpProfDll     – tests for the public GpProf API.
                       When no .GPI file is present, prfDisabled is set to true
                       and all profiling calls are safe no-ops.
*)

interface

uses
  TestFramework,
  GpProf,
  GpProfCommon;

type
  // -----------------------------------------------------------------------
  // Tests for GpProfCommon.ResolvePrfRuntimePlaceholders
  // -----------------------------------------------------------------------
  TTestGpProfCommon = class(TTestCase)
  published
    procedure TestNoPlaceholder;
    procedure TestProcessIDPlaceholder;
    procedure TestProcessNamePlaceholder;
    procedure TestModuleNamePlaceholder;
    procedure TestModulePathPlaceholder;
    procedure TestMultiplePlaceholders;
    procedure TestRepeatedPlaceholder;
  end;

  // -----------------------------------------------------------------------
  // Tests for the GpProf public profiling API
  // -----------------------------------------------------------------------
  TTestGpProfDll = class(TTestCase)
  published
    procedure TestProfilerStartStop;
    procedure TestProfilerStartStopIdempotent;
    procedure TestProfilerEnterExitProc;
    procedure TestProfilerEnterExitProcEdgeCaseIDs;
    procedure TestProfilerEnterExitMeasurePoint;
    procedure TestMeasurePointScopeNotNil;
    procedure TestMeasurePointScopeAutoExit;
    procedure TestMeasurePointScopeNested;
    procedure TestNameThreadForDebugging;
    procedure TestNameThreadForDebuggingMultiple;
  end;

implementation

uses
  Windows,
  SysUtils;

{ TTestGpProfCommon }

procedure TTestGpProfCommon.TestNoPlaceholder;
const
  CInput = 'some/path/without/placeholders';
begin
  CheckEquals(CInput, ResolvePrfRuntimePlaceholders(CInput),
    'A string with no placeholders must be returned unchanged');
end;

procedure TTestGpProfCommon.TestProcessIDPlaceholder;
var
  lResult: string;
  lPID: Cardinal;
begin
  lResult := ResolvePrfRuntimePlaceholders('$(ProcessID)');
  CheckFalse(lResult = '', '$(ProcessID) must be replaced with a non-empty string');
  CheckFalse(Pos('$(', lResult) > 0, 'Result must not contain an unresolved placeholder');
  lPID := StrToInt(lResult);
  CheckEquals(Integer(GetCurrentProcessID), Integer(lPID),
    '$(ProcessID) must equal the current process ID');
end;

procedure TTestGpProfCommon.TestProcessNamePlaceholder;
var
  lResult: string;
begin
  lResult := ResolvePrfRuntimePlaceholders('$(ProcessName)');
  CheckFalse(lResult = '', '$(ProcessName) must be replaced with a non-empty string');
  CheckFalse(Pos('$(', lResult) > 0, 'Result must not contain an unresolved placeholder');
  // The process name must not contain a path separator or a file extension dot.
  CheckFalse(Pos('\', lResult) > 0, 'Process name must not contain a backslash');
  CheckFalse(Pos('/', lResult) > 0, 'Process name must not contain a forward slash');
end;

procedure TTestGpProfCommon.TestModuleNamePlaceholder;
var
  lResult: string;
begin
  lResult := ResolvePrfRuntimePlaceholders('$(ModuleName)');
  CheckFalse(lResult = '', '$(ModuleName) must be replaced with a non-empty string');
  CheckFalse(Pos('$(', lResult) > 0, 'Result must not contain an unresolved placeholder');
  // Module name is the bare filename without path or extension.
  CheckFalse(Pos('\', lResult) > 0, 'Module name must not contain a backslash');
  CheckFalse(Pos('/', lResult) > 0, 'Module name must not contain a forward slash');
  CheckFalse(Pos('.', lResult) > 0, 'Module name must not contain an extension dot');
end;

procedure TTestGpProfCommon.TestModulePathPlaceholder;
var
  lResult: string;
begin
  lResult := ResolvePrfRuntimePlaceholders('$(ModulePath)');
  CheckFalse(lResult = '', '$(ModulePath) must be replaced with a non-empty string');
  CheckFalse(Pos('$(', lResult) > 0, 'Result must not contain an unresolved placeholder');
  // Module path is the full path without extension — it must contain a path separator.
  Check(Pos('\', lResult) > 0, 'Module path must contain at least one backslash');
  // The result must not end with a known binary extension.
  CheckFalse(SameText(ExtractFileExt(lResult), '.exe'), 'Module path must not include the .exe extension');
  CheckFalse(SameText(ExtractFileExt(lResult), '.dll'), 'Module path must not include the .dll extension');
end;

procedure TTestGpProfCommon.TestMultiplePlaceholders;
var
  lResult: string;
begin
  lResult := ResolvePrfRuntimePlaceholders('pid=$(ProcessID) name=$(ModuleName)');
  CheckFalse(Pos('$(', lResult) > 0, 'All placeholders must be resolved');
  // The literal separating text must still be present.
  Check(Pos('pid=', lResult) = 1, 'Prefix text must be preserved');
  Check(Pos(' name=', lResult) > 0, 'Separator text between placeholders must be preserved');
end;

procedure TTestGpProfCommon.TestRepeatedPlaceholder;
var
  lResult: string;
  lExpected: string;
  lPID: string;
begin
  lPID    := IntToStr(GetCurrentProcessID);
  lExpected := lPID + '-' + lPID;
  lResult   := ResolvePrfRuntimePlaceholders('$(ProcessID)-$(ProcessID)');
  CheckEquals(lExpected, lResult,
    'Both occurrences of the same placeholder must be replaced');
end;

{ TTestGpProfDll }

procedure TTestGpProfDll.TestProfilerStartStop;
begin
  // Basic start/stop round-trip must not raise.
  ProfilerStart;
  ProfilerStop;
end;

procedure TTestGpProfDll.TestProfilerStartStopIdempotent;
begin
  // Calling Start/Stop multiple times in a row must be safe.
  ProfilerStart;
  ProfilerStart;
  ProfilerStop;
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

procedure TTestGpProfDll.TestProfilerEnterExitProcEdgeCaseIDs;
begin
  // ID = 0 (calibration sentinel) and large IDs must be handled safely.
  ProfilerStart;
  ProfilerEnterProc(0);
  ProfilerExitProc(0);
  ProfilerEnterProc(High(Cardinal));
  ProfilerExitProc(High(Cardinal));
  ProfilerStop;
end;

procedure TTestGpProfDll.TestProfilerEnterExitMeasurePoint;
begin
  ProfilerStart;
  ProfilerEnterMP('TestMeasurePoint');
  ProfilerExitMP('TestMeasurePoint');
  ProfilerStop;
end;

procedure TTestGpProfDll.TestMeasurePointScopeNotNil;
var
  lScope: IMeasurePointScope;
begin
  lScope := CreateMeasurePointScope('ScopeNotNil');
  CheckNotNull(lScope, 'CreateMeasurePointScope must return a non-nil interface');
end;

procedure TTestGpProfDll.TestMeasurePointScopeAutoExit;
var
  lScope: IMeasurePointScope;
begin
  // Releasing the interface must not raise even when the profiler is disabled.
  ProfilerStart;
  lScope := CreateMeasurePointScope('AutoExit');
  lScope := nil; // triggers TMeasurePointScope.Destroy → ProfilerExitMP
  ProfilerStop;
end;

procedure TTestGpProfDll.TestMeasurePointScopeNested;
var
  lOuter: IMeasurePointScope;
  lInner: IMeasurePointScope;
begin
  // Nested scopes must be created and released in LIFO order without raising.
  ProfilerStart;
  lOuter := CreateMeasurePointScope('Outer');
  lInner := CreateMeasurePointScope('Inner');
  lInner := nil; // exit inner first
  lOuter := nil; // then exit outer
  ProfilerStop;
end;

procedure TTestGpProfDll.TestNameThreadForDebugging;
begin
  // TThreadID(-1) addresses the calling thread.
  NameThreadForDebugging('TestThread', TThreadID(-1));
end;

procedure TTestGpProfDll.TestNameThreadForDebuggingMultiple;
begin
  // Naming the same thread more than once must not raise.
  NameThreadForDebugging('FirstName',  TThreadID(-1));
  NameThreadForDebugging('SecondName', TThreadID(-1));
end;

initialization
  RegisterTest('GpProfCommon', TTestGpProfCommon.Suite);
  RegisterTest('GpProfDll',    TTestGpProfDll.Suite);

end.
