(*
  GpProfile DLL - DUnit test runner.

  Runs all registered DUnit tests for the GpProfDll profiling instrumentation.
*)

program GpProfDllTests;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  TextTestRunner,
  TestFramework,
  GpProf in '..\include\GpProf.pas',
  GpProfH in '..\include\GpProfH.pas',
  GpProfCommon in '..\include\GpProfCommon.pas',
  testGpProfDll in 'testGpProfDll.pas';

begin
  TextTestRunner.RunRegisteredTests;
end.
