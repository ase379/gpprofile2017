(*
  GpProfile DLL - DUnit test runner.

  Runs all registered DUnit tests for the GpProfDll profiling instrumentation.
  Two build configurations are supported:
    - Default (Debug/Release): console runner using DUnit TextTestRunner.
    - DUnitX_GUI: VCL GUI runner using DUnitX.Loggers.GUI.VCL; DUnit tests
      are bridged to DUnitX via TDUnitXDUnitBridge.RegisterDUnitTests.
*)

program GpProfDllTests;

{$IFNDEF USE_DUNITX_GUI}
{$APPTYPE CONSOLE}
{$ENDIF}

{$R *.res}

uses
{$IFDEF USE_DUNITX_GUI}
  Vcl.Forms,
  DUnitX.Loggers.GUI.VCL,
  DUnitX.DUnitCompatibility,
{$ELSE}
  TextTestRunner,
{$ENDIF}
  TestFramework,
  GpProf in '..\include\GpProf.pas',
  GpProfH in '..\include\GpProfH.pas',
  GpProfCommon in '..\include\GpProfCommon.pas',
  GpProfDllClient in '..\include\GpProfDllClient.pas',
  testGpProfDll in 'testGpProfDll.pas',
  testGpProfDllContext in 'testGpProfDllContext.pas';

begin
{$IFDEF USE_DUNITX_GUI}
  TDUnitXDUnitBridge.RegisterDUnitTests;
  Application.Initialize;
  Application.CreateForm(TGUIVCLTestRunner, GUIVCLTestRunner);
  Application.Run;
{$ELSE}
  TextTestRunner.RunRegisteredTests;
{$ENDIF}
end.
