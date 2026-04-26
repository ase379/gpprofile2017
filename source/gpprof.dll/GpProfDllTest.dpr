(*
  GpProfile DLL unit-test library.

  Exports each test procedure so that an external test runner (or the
  companion console harness) can load this DLL and invoke the individual
  tests by name.
*)

library GpProfDllTest;

{$R-,C-,Q-,O+,H+}

uses
  System.SysUtils,
  testGpProfDll in 'testGpProfDll.pas';

exports
  TestProfilerStartStop,
  TestProfilerEnterExitProc,
  TestProfilerEnterExitMeasurePoint,
  TestMeasurePointScope,
  TestNameThreadForDebugging;

begin
end.
