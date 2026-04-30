unit testGpProfDllContext;

(*
  DUnit tests for the IGpProfContext / AcquireGpProfContext API in
  GpProfDllClient.pas.

  These tests run independently of GpProfDll32/64.dll.  When the DLL is
  absent (as in a headless CI build), GpProfDllClient's initialization
  silently skips DLL loading and every exported function returns nil /
  performs a no-op.  The tests below verify this graceful degradation.
*)

interface

uses
  TestFramework,
  GpProfDllClient;

type
  TTestGpProfContextAPI = class(TTestCase)
  published
    /// <summary>
    /// AcquireGpProfContext must return nil (not raise) when the DLL
    /// could not be found on the search path.
    /// </summary>
    procedure TestAcquireContextNilWhenDllAbsent;

    /// <summary>
    /// DisposeGpProfContext must be safe to call on a nil interface variable.
    /// </summary>
    procedure TestDisposeContextOnNilIsSafe;

    /// <summary>
    /// DisposeGpProfContext must set the variable to nil.
    /// </summary>
    procedure TestDisposeContextSetsVarNil;

    /// <summary>
    /// Calling DisposeGpProfContext twice on the same variable must not raise.
    /// </summary>
    procedure TestDisposeContextIdempotent;
  end;

implementation

{ TTestGpProfContextAPI }

procedure TTestGpProfContextAPI.TestAcquireContextNilWhenDllAbsent;
var
  lCtx: IGpProfContext;
begin
  // GpProfDll32/64.dll is not present in the test output directory so the
  // LoadLibrary in GpProfDllClient.initialization will fail silently.
  // AcquireGpProfContext checks GpProfDllHandle = 0 and returns nil.
  lCtx := AcquireGpProfContext;
  CheckNull(lCtx, 'AcquireGpProfContext must return nil when the DLL is absent');
end;

procedure TTestGpProfContextAPI.TestDisposeContextOnNilIsSafe;
var
  lCtx: IGpProfContext;
begin
  lCtx := nil;
  // Must not raise on a nil variable.
  DisposeGpProfContext(lCtx);
  CheckNull(lCtx, 'DisposeGpProfContext on nil must leave variable nil');
end;

procedure TTestGpProfContextAPI.TestDisposeContextSetsVarNil;
var
  lCtx: IGpProfContext;
begin
  lCtx := AcquireGpProfContext; // nil when DLL absent — that is fine
  DisposeGpProfContext(lCtx);
  CheckNull(lCtx, 'DisposeGpProfContext must set the variable to nil');
end;

procedure TTestGpProfContextAPI.TestDisposeContextIdempotent;
var
  lCtx: IGpProfContext;
begin
  lCtx := AcquireGpProfContext;
  DisposeGpProfContext(lCtx);
  // Second call on an already-nil variable must not raise.
  DisposeGpProfContext(lCtx);
  CheckNull(lCtx, 'Variable must remain nil after second DisposeGpProfContext call');
end;

initialization
  RegisterTest('GpProfContextAPI', TTestGpProfContextAPI.Suite);

end.
