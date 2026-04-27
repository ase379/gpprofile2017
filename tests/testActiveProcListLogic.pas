unit testActiveProcListLogic;

/// <summary>
/// Logic tests for TActiveProcList, TProcProxy, TProcWithMemProxy,
/// TMeasurePointProxy, and TMeasurePointWithMemProxy:
/// - Append adds a proxy and LocateLast finds it
/// - Remove removes the proxy; LocateLast then returns nil
/// - LocateLast with multiple entries identifies the correct (last) one
/// - LocateLast with nested entries returns parent correctly
/// - Remove of a non-existent entry raises an exception
/// - Two entries with the same ProcId: LocateLast returns the most recently added
/// - UpdateDeadTime propagates to all active procs
/// - TProcProxy.Start captures the start timestamp
/// - TProcProxy.Stop computes total time correctly
/// - TProcProxy.UpdateDeadTime accumulates dead time
/// - TProcWithMemProxy.Start captures start memory
/// - TProcWithMemProxy.Stop computes total memory delta
/// - TMeasurePointProxy stores MeasurePointID
/// - TMeasurePointWithMemProxy stores MeasurePointID and handles memory
/// </summary>

interface

procedure RunActiveProcListTests;

implementation

uses
  System.SysUtils,
  gppResults.types,
  gppResults.procs;

procedure AssertEquals(const aExpected, aActual: int64; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected %d but got %d', [aMsg, aExpected, aActual]);
end;

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

{ TActiveProcList tests }

procedure TestAppendAndLocateLast;
var
  LList: TActiveProcList;
  LProxy: TProcProxy;
  LThis, LParent: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy := TProcProxy.Create(1, 10);
  try
    LList.Append(LProxy);

    LList.LocateLast(10, LThis, LParent);
    AssertNotNil(LThis,   'Should find appended proxy');
    AssertNil(LParent,    'No parent for first entry');

    if LThis <> LProxy then
      raise Exception.Create('LocateLast should return the appended proxy');
  finally
    LList.Remove(LProxy);
    LProxy.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestAppendAndLocateLast');
end;

procedure TestRemove;
var
  LList: TActiveProcList;
  LProxy: TProcProxy;
  LThis, LParent: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy := TProcProxy.Create(1, 10);
  try
    LList.Append(LProxy);
    LList.Remove(LProxy);

    LList.LocateLast(10, LThis, LParent);
    AssertNil(LThis, 'Should not find proxy after remove');
  finally
    LProxy.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestRemove');
end;

procedure TestRemoveNonExistentRaisesException;
var
  LList: TActiveProcList;
  LProxy: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy := TProcProxy.Create(1, 10);
  try
    AssertExceptionRaised(
      procedure begin LList.Remove(LProxy); end,
      'Remove of non-existent proxy');
  finally
    LProxy.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestRemoveNonExistentRaisesException');
end;

procedure TestLocateLastWithParent;
var
  LList: TActiveProcList;
  LProxy1, LProxy2: TProcProxy;
  LThis, LParent: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy1 := TProcProxy.Create(1, 10);
  LProxy2 := TProcProxy.Create(1, 20);
  try
    LList.Append(LProxy1);
    LList.Append(LProxy2);

    LList.LocateLast(20, LThis, LParent);
    if LThis <> LProxy2 then
      raise Exception.Create('LThis should be LProxy2');
    if LParent <> LProxy1 then
      raise Exception.Create('LParent should be LProxy1 (the only entry before LProxy2)');

    LList.LocateLast(10, LThis, LParent);
    if LThis <> LProxy1 then
      raise Exception.Create('LThis should be LProxy1');
    AssertNil(LParent, 'LProxy1 has no parent');
  finally
    LList.Remove(LProxy2);
    LList.Remove(LProxy1);
    LProxy2.Free;
    LProxy1.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestLocateLastWithParent');
end;

procedure TestLocateLastReturnsLastForDuplicateProcId;
var
  LList: TActiveProcList;
  LProxy1, LProxy2: TProcProxy;
  LThis, LParent: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy1 := TProcProxy.Create(1, 5);
  LProxy2 := TProcProxy.Create(1, 5);
  try
    LList.Append(LProxy1);
    LList.Append(LProxy2);

    LList.LocateLast(5, LThis, LParent);
    if LThis <> LProxy2 then
      raise Exception.Create('LocateLast should return the most recently added proxy with ProcId=5');
    if LParent <> LProxy1 then
      raise Exception.Create('Parent should be LProxy1 (the earlier entry with ProcId=5)');
  finally
    LList.Remove(LProxy2);
    LList.Remove(LProxy1);
    LProxy2.Free;
    LProxy1.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestLocateLastReturnsLastForDuplicateProcId');
end;

procedure TestLocateLastNotFoundReturnsNil;
var
  LList: TActiveProcList;
  LProxy: TProcProxy;
  LThis, LParent: TProcProxy;
begin
  LList := TActiveProcList.Create();
  LProxy := TProcProxy.Create(1, 10);
  try
    LList.Append(LProxy);
    LList.LocateLast(99, LThis, LParent);
    AssertNil(LThis,   'Should return nil for non-existent ProcId');
    AssertNil(LParent, 'Parent should be nil when not found');
  finally
    LList.Remove(LProxy);
    LProxy.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestLocateLastNotFoundReturnsNil');
end;

procedure TestUpdateDeadTimeAffectsAllEntries;
var
  LList: TActiveProcList;
  LProxy1, LProxy2: TProcProxy;
  LPkt: TResPacket;
begin
  LList := TActiveProcList.Create();
  LProxy1 := TProcProxy.Create(1, 10);
  LProxy2 := TProcProxy.Create(1, 20);
  try
    LList.Append(LProxy1);
    LList.Append(LProxy2);

    LPkt.rpMeasure1    := 100;
    LPkt.rpMeasure2    := 200;
    LPkt.rpNullOverhead := 5;
    LList.UpdateDeadTime(LPkt);

    // Each proxy's DeadTime should be (200-100)+5 = 105
    if LProxy1.DeadTime <> 105 then
      raise Exception.CreateFmt('LProxy1.DeadTime should be 105, got %d', [LProxy1.DeadTime]);
    if LProxy2.DeadTime <> 105 then
      raise Exception.CreateFmt('LProxy2.DeadTime should be 105, got %d', [LProxy2.DeadTime]);
  finally
    LList.Remove(LProxy2);
    LList.Remove(LProxy1);
    LProxy2.Free;
    LProxy1.Free;
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateDeadTimeAffectsAllEntries');
end;

{ TProcProxy tests }

procedure TestProcProxyStartCapturesTimestamp;
var
  LProxy: TProcProxy;
  LPkt: TResPacket;
  LMemPkt: TResMemPacket;
begin
  LProxy := TProcProxy.Create(1, 10);
  try
    LPkt.rpMeasure2    := 1000;
    LPkt.rpNullOverhead := 0;
    LMemPkt.rpMemWorkingSize := 0;
    LProxy.Start(LPkt, LMemPkt);
    if LProxy.StartTime <> 1000 then
      raise Exception.CreateFmt('StartTime should be 1000, got %d', [LProxy.StartTime]);
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestProcProxyStartCapturesTimestamp');
end;

procedure TestProcProxyStopComputesTotalTime;
var
  LProxy: TProcProxy;
  LPkt: TResPacket;
  LMemPkt: TResMemPacket;
begin
  LProxy := TProcProxy.Create(1, 10);
  try
    LMemPkt.rpMemWorkingSize := 0;

    LPkt.rpMeasure2    := 1000;
    LPkt.rpNullOverhead := 0;
    LProxy.Start(LPkt, LMemPkt);

    // TotalTime = rpMeasure1 - ppStartTime - DeadTime - ChildTime - NullOverhead
    // = 1500 - 1000 - 0 - 0 - 10 = 490
    LPkt.rpMeasure1    := 1500;
    LPkt.rpNullOverhead := 10;
    LProxy.Stop(LPkt, LMemPkt);

    if LProxy.TotalTime <> 490 then
      raise Exception.CreateFmt('TotalTime should be 490, got %d', [LProxy.TotalTime]);
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestProcProxyStopComputesTotalTime');
end;

procedure TestProcProxyStopNonNegativeTotalTime;
var
  LProxy: TProcProxy;
  LPkt: TResPacket;
  LMemPkt: TResMemPacket;
begin
  // When overhead causes negative time, result should be clamped to 0
  LProxy := TProcProxy.Create(1, 10);
  try
    LMemPkt.rpMemWorkingSize := 0;

    LPkt.rpMeasure2    := 1000;
    LPkt.rpNullOverhead := 0;
    LProxy.Start(LPkt, LMemPkt);

    // Extremely large null overhead -> would go negative -> should clamp to 0
    LPkt.rpMeasure1    := 1001;
    LPkt.rpNullOverhead := 500;
    LProxy.Stop(LPkt, LMemPkt);

    if LProxy.TotalTime < 0 then
      raise Exception.CreateFmt('TotalTime should be >= 0, got %d', [LProxy.TotalTime]);
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestProcProxyStopNonNegativeTotalTime');
end;

procedure TestProcProxyUpdateDeadTime;
var
  LProxy: TProcProxy;
  LPkt: TResPacket;
begin
  LProxy := TProcProxy.Create(1, 10);
  try
    LPkt.rpMeasure1    := 100;
    LPkt.rpMeasure2    := 200;
    LPkt.rpNullOverhead := 5;
    LProxy.UpdateDeadTime(LPkt);
    // DeadTime = (200 - 100) + 5 = 105
    if LProxy.DeadTime <> 105 then
      raise Exception.CreateFmt('DeadTime should be 105, got %d', [LProxy.DeadTime]);

    LProxy.UpdateDeadTime(LPkt);
    // DeadTime = 105 + 105 = 210
    if LProxy.DeadTime <> 210 then
      raise Exception.CreateFmt('DeadTime should be 210, got %d', [LProxy.DeadTime]);
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestProcProxyUpdateDeadTime');
end;

{ TProcWithMemProxy tests }

procedure TestProcWithMemProxyStartStop;
var
  LProxy: TProcWithMemProxy;
  LPkt: TResPacket;
  LMemPkt: TResMemPacket;
begin
  LProxy := TProcWithMemProxy.Create(1, 10);
  try
    LMemPkt.rpMemWorkingSize := 1000;
    LPkt.rpMeasure2    := 500;
    LPkt.rpNullOverhead := 0;
    LProxy.Start(LPkt, LMemPkt);

    AssertEquals(Cardinal(1000), LProxy.StartMem, 'StartMem after Start');

    LMemPkt.rpMemWorkingSize := 1500;
    LPkt.rpMeasure1    := 800;
    LPkt.rpNullOverhead := 5;
    LProxy.Stop(LPkt, LMemPkt);

    AssertEquals(Cardinal(1500), LProxy.EndMem,   'EndMem after Stop');
    AssertEquals(Cardinal(500),  LProxy.TotalMem,  'TotalMem = EndMem - StartMem');
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestProcWithMemProxyStartStop');
end;

{ TMeasurePointProxy tests }

procedure TestMeasurePointProxyCreation;
var
  LProxy: TMeasurePointProxy;
begin
  LProxy := TMeasurePointProxy.Create(3, 15, 'MP_TestPoint');
  try
    if LProxy.ThreadID <> 3 then
      raise Exception.CreateFmt('ThreadID should be 3, got %d', [LProxy.ThreadID]);
    if LProxy.ProcId <> 15 then
      raise Exception.CreateFmt('ProcId should be 15, got %d', [LProxy.ProcId]);
    AssertEquals('MP_TestPoint', LProxy.MeasurePointID, 'MeasurePointID');
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestMeasurePointProxyCreation');
end;

procedure TestMeasurePointWithMemProxyCreation;
var
  LProxy: TMeasurePointWithMemProxy;
begin
  LProxy := TMeasurePointWithMemProxy.Create(2, 7, 'MP_MemPoint');
  try
    if LProxy.ThreadID <> 2 then
      raise Exception.CreateFmt('ThreadID should be 2, got %d', [LProxy.ThreadID]);
    if LProxy.ProcId <> 7 then
      raise Exception.CreateFmt('ProcId should be 7, got %d', [LProxy.ProcId]);
    AssertEquals('MP_MemPoint', LProxy.MeasurePointID, 'MeasurePointID');
  finally
    LProxy.Free;
  end;
  Writeln('  PASS: TestMeasurePointWithMemProxyCreation');
end;

procedure RunActiveProcListTests;
begin
  Writeln('Running Active Proc List Logic Tests...');
  TestAppendAndLocateLast;
  TestRemove;
  TestRemoveNonExistentRaisesException;
  TestLocateLastWithParent;
  TestLocateLastReturnsLastForDuplicateProcId;
  TestLocateLastNotFoundReturnsNil;
  TestUpdateDeadTimeAffectsAllEntries;
  TestProcProxyStartCapturesTimestamp;
  TestProcProxyStopComputesTotalTime;
  TestProcProxyStopNonNegativeTotalTime;
  TestProcProxyUpdateDeadTime;
  TestProcWithMemProxyStartStop;
  TestMeasurePointProxyCreation;
  TestMeasurePointWithMemProxyCreation;
  Writeln('Active Proc List Logic Tests: ALL PASSED');
end;

end.
