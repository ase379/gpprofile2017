unit testMeasurePointRegistryLogic;

/// <summary>
/// Logic tests for TMeasurePointRegistry:
/// - RegisterMeasurePoint returns a valid entry with correct ProcId and MeasurePointId
/// - GetMeasurePointEntry finds a registered entry
/// - GetMeasurePointEntry returns nil for unknown keys
/// - Duplicate registration raises an exception
/// - UnRegisterMeasurePoint does not remove entries (by design, to catch reuse)
/// - Multiple distinct entries are stored independently
/// </summary>

interface

procedure RunMeasurePointRegistryTests;

implementation

uses
  System.SysUtils,
  gppResult.measurePointRegistry;

procedure AssertEquals(const aExpected, aActual: Cardinal; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected %u but got %u', [aMsg, aExpected, aActual]);
end;

procedure AssertEquals(const aExpected, aActual: String; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected "%s" but got "%s"', [aMsg, aExpected, aActual]);
end;

procedure AssertNotNil(const aValue: TObject; const aMsg: string);
begin
  if aValue = nil then
    raise Exception.CreateFmt('%s: unexpected nil value', [aMsg]);
end;

procedure AssertNil(const aValue: TObject; const aMsg: string);
begin
  if aValue <> nil then
    raise Exception.CreateFmt('%s: expected nil but got non-nil', [aMsg]);
end;

procedure AssertExceptionRaised(const aProc: TProc; const aMsg: string);
var
  LRaised: Boolean;
begin
  LRaised := False;
  try
    aProc();
  except
    on E: Exception do
      LRaised := True;
  end;
  if not LRaised then
    raise Exception.CreateFmt('%s: expected an exception but none was raised', [aMsg]);
end;

procedure TestRegisterAndRetrieve;
var
  LRegistry: TMeasurePointRegistry;
  LEntry: TMeasurePointRegistryEntry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LEntry := LRegistry.RegisterMeasurePoint(42, 'MP_Test1');
    AssertNotNil(LEntry, 'RegisterMeasurePoint should return a non-nil entry');
    AssertEquals(Cardinal(42), LEntry.ProcId, 'ProcId should be 42');
    AssertEquals('MP_Test1', LEntry.MeasurePointId, 'MeasurePointId should be MP_Test1');

    LEntry := LRegistry.GetMeasurePointEntry('MP_Test1');
    AssertNotNil(LEntry, 'GetMeasurePointEntry should find the registered entry');
    AssertEquals(Cardinal(42), LEntry.ProcId, 'Retrieved ProcId should be 42');
    AssertEquals('MP_Test1', LEntry.MeasurePointId, 'Retrieved MeasurePointId should be MP_Test1');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestRegisterAndRetrieve');
end;

procedure TestGetNonExistentReturnsNil;
var
  LRegistry: TMeasurePointRegistry;
  LEntry: TMeasurePointRegistryEntry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LEntry := LRegistry.GetMeasurePointEntry('NonExistent');
    AssertNil(LEntry, 'GetMeasurePointEntry for non-existent key should return nil');

    LEntry := LRegistry.GetMeasurePointEntry('');
    AssertNil(LEntry, 'GetMeasurePointEntry for empty key should return nil');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestGetNonExistentReturnsNil');
end;

procedure TestDuplicateRegistrationRaisesException;
var
  LRegistry: TMeasurePointRegistry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LRegistry.RegisterMeasurePoint(1, 'MP_Duplicate');
    AssertExceptionRaised(
      procedure begin LRegistry.RegisterMeasurePoint(2, 'MP_Duplicate'); end,
      'Duplicate RegisterMeasurePoint should raise exception');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestDuplicateRegistrationRaisesException');
end;

procedure TestUnregisterDoesNotRemoveEntry;
var
  LRegistry: TMeasurePointRegistry;
  LEntry: TMeasurePointRegistryEntry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LRegistry.RegisterMeasurePoint(10, 'MP_Persist');
    LRegistry.UnRegisterMeasurePoint('MP_Persist');

    // By design, UnRegisterMeasurePoint is a no-op so the entry remains
    // (this prevents duplicates from being silently re-registered after removal)
    LEntry := LRegistry.GetMeasurePointEntry('MP_Persist');
    AssertNotNil(LEntry, 'Entry should still exist after UnRegisterMeasurePoint (by design)');
    AssertEquals(Cardinal(10), LEntry.ProcId, 'ProcId should still be 10 after unregister');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestUnregisterDoesNotRemoveEntry');
end;

procedure TestMultipleDistinctEntries;
var
  LRegistry: TMeasurePointRegistry;
  LEntry: TMeasurePointRegistryEntry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LRegistry.RegisterMeasurePoint(1, 'MP_A');
    LRegistry.RegisterMeasurePoint(2, 'MP_B');
    LRegistry.RegisterMeasurePoint(3, 'MP_C');

    LEntry := LRegistry.GetMeasurePointEntry('MP_A');
    AssertNotNil(LEntry, 'MP_A should be found');
    AssertEquals(Cardinal(1), LEntry.ProcId, 'MP_A ProcId');

    LEntry := LRegistry.GetMeasurePointEntry('MP_B');
    AssertNotNil(LEntry, 'MP_B should be found');
    AssertEquals(Cardinal(2), LEntry.ProcId, 'MP_B ProcId');

    LEntry := LRegistry.GetMeasurePointEntry('MP_C');
    AssertNotNil(LEntry, 'MP_C should be found');
    AssertEquals(Cardinal(3), LEntry.ProcId, 'MP_C ProcId');

    LEntry := LRegistry.GetMeasurePointEntry('MP_D');
    AssertNil(LEntry, 'MP_D should not be found');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestMultipleDistinctEntries');
end;

procedure TestRegisterWithProcIdZero;
var
  LRegistry: TMeasurePointRegistry;
  LEntry: TMeasurePointRegistryEntry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LEntry := LRegistry.RegisterMeasurePoint(0, 'MP_ZeroProcId');
    AssertNotNil(LEntry, 'Registration with ProcId=0 should succeed');
    AssertEquals(Cardinal(0), LEntry.ProcId, 'ProcId should be 0');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestRegisterWithProcIdZero');
end;

procedure TestDuplicateSameProcIdRaisesException;
var
  LRegistry: TMeasurePointRegistry;
begin
  LRegistry := TMeasurePointRegistry.Create();
  try
    LRegistry.RegisterMeasurePoint(5, 'MP_Same');
    // Same ProcId but same MeasurePointId is still a duplicate
    AssertExceptionRaised(
      procedure begin LRegistry.RegisterMeasurePoint(5, 'MP_Same'); end,
      'Duplicate MeasurePointId with same ProcId should raise exception');
  finally
    LRegistry.Free;
  end;
  Writeln('  PASS: TestDuplicateSameProcIdRaisesException');
end;

procedure RunMeasurePointRegistryTests;
begin
  Writeln('Running Measure Point Registry Logic Tests...');
  TestRegisterAndRetrieve;
  TestGetNonExistentReturnsNil;
  TestDuplicateRegistrationRaisesException;
  TestUnregisterDoesNotRemoveEntry;
  TestMultipleDistinctEntries;
  TestRegisterWithProcIdZero;
  TestDuplicateSameProcIdRaisesException;
  Writeln('Measure Point Registry Logic Tests: ALL PASSED');
end;

end.
