unit testCallGraphLogic;

/// <summary>
/// Logic tests for the call graph data structures:
/// - tProcTimeList: AddTime, AssignTime, thread-zero guard
/// - tProcCountList: AddCount, thread-zero guard
/// - tProcMemList: AddMem, AssignMem, thread-zero guard
/// - TCallGraphInfo: creation, initialization of ProcTimeMin
/// - TCallGraphInfoDict: GetOrCreate, GetGraphInfo, GetGraphInfoForParentProcId,
///                       Clear, CalculateAverage, ToInfoString
/// </summary>

interface

procedure RunCallGraphTests;

implementation

uses
  System.SysUtils,
  System.Generics.Collections,
  gppResults.callGraph;

procedure AssertEquals(const aExpected, aActual: uint64; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected %d but got %d', [aMsg, aExpected, aActual]);
end;

procedure AssertEquals(const aExpected, aActual: Cardinal; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected %u but got %u', [aMsg, aExpected, aActual]);
end;

procedure AssertEquals(const aExpected, aActual: Integer; const aMsg: string); overload;
begin
  if aExpected <> aActual then
    raise Exception.CreateFmt('%s: expected %d but got %d', [aMsg, aExpected, aActual]);
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

{ tProcTimeList tests }

procedure TestProcTimeListAddTime;
var
  LList: tProcTimeList;
begin
  LList := tProcTimeList.Create();
  try
    LList.Count := 3;
    LList.AddTime(1, 100);
    AssertEquals(uint64(100), LList[0], 'Sum after first add');
    AssertEquals(uint64(100), LList[1], 'Thread 1 after first add');
    AssertEquals(uint64(0),   LList[2], 'Thread 2 unchanged after first add');

    LList.AddTime(2, 50);
    AssertEquals(uint64(150), LList[0], 'Sum after second add');
    AssertEquals(uint64(100), LList[1], 'Thread 1 unchanged after second add');
    AssertEquals(uint64(50),  LList[2], 'Thread 2 after second add');

    LList.AddTime(1, 25);
    AssertEquals(uint64(175), LList[0], 'Sum after third add');
    AssertEquals(uint64(125), LList[1], 'Thread 1 after third add');
    AssertEquals(uint64(50),  LList[2], 'Thread 2 unchanged after third add');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcTimeListAddTime');
end;

procedure TestProcTimeListAddTimeThreadZeroRaisesException;
var
  LList: tProcTimeList;
begin
  LList := tProcTimeList.Create();
  try
    LList.Count := 3;
    AssertExceptionRaised(
      procedure begin LList.AddTime(0, 100); end,
      'AddTime with ThreadId=0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcTimeListAddTimeThreadZeroRaisesException');
end;

procedure TestProcTimeListAssignTime;
var
  LList: tProcTimeList;
begin
  LList := tProcTimeList.Create();
  try
    LList.Count := 3;
    LList.AssignTime(1, 200);
    AssertEquals(uint64(200), LList[0], 'Sum after first assign');
    AssertEquals(uint64(200), LList[1], 'Thread 1 after first assign');
    AssertEquals(uint64(0),   LList[2], 'Thread 2 unchanged after first assign');

    LList.AssignTime(2, 100);
    AssertEquals(uint64(100), LList[0], 'Sum after second assign (overwritten by last)');
    AssertEquals(uint64(200), LList[1], 'Thread 1 unchanged after second assign');
    AssertEquals(uint64(100), LList[2], 'Thread 2 after second assign');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcTimeListAssignTime');
end;

procedure TestProcTimeListAssignTimeThreadZeroRaisesException;
var
  LList: tProcTimeList;
begin
  LList := tProcTimeList.Create();
  try
    LList.Count := 3;
    AssertExceptionRaised(
      procedure begin LList.AssignTime(0, 50); end,
      'AssignTime with ThreadId=0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcTimeListAssignTimeThreadZeroRaisesException');
end;

{ tProcCountList tests }

procedure TestProcCountListAddCount;
var
  LList: tProcCountList;
begin
  LList := tProcCountList.Create();
  try
    LList.Count := 3;
    LList.AddCount(1, 5);
    AssertEquals(Cardinal(5), LList[0], 'Sum after first add');
    AssertEquals(Cardinal(5), LList[1], 'Thread 1 after first add');
    AssertEquals(Cardinal(0), LList[2], 'Thread 2 unchanged');

    LList.AddCount(2, 3);
    AssertEquals(Cardinal(8), LList[0], 'Sum after second add');
    AssertEquals(Cardinal(5), LList[1], 'Thread 1 unchanged');
    AssertEquals(Cardinal(3), LList[2], 'Thread 2 after second add');

    LList.AddCount(1, 2);
    AssertEquals(Cardinal(10), LList[0], 'Sum after third add');
    AssertEquals(Cardinal(7),  LList[1], 'Thread 1 after third add');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcCountListAddCount');
end;

procedure TestProcCountListAddCountThreadZeroRaisesException;
var
  LList: tProcCountList;
begin
  LList := tProcCountList.Create();
  try
    LList.Count := 3;
    AssertExceptionRaised(
      procedure begin LList.AddCount(0, 1); end,
      'AddCount with ThreadId=0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcCountListAddCountThreadZeroRaisesException');
end;

{ tProcMemList tests }

procedure TestProcMemListAddMem;
var
  LList: tProcMemList;
begin
  LList := tProcMemList.Create();
  try
    LList.Count := 3;
    LList.AddMem(1, 1024);
    AssertEquals(Cardinal(1024), LList[0], 'Sum after first add');
    AssertEquals(Cardinal(1024), LList[1], 'Thread 1 after first add');
    AssertEquals(Cardinal(0),    LList[2], 'Thread 2 unchanged');

    LList.AddMem(2, 512);
    AssertEquals(Cardinal(1536), LList[0], 'Sum after second add');
    AssertEquals(Cardinal(1024), LList[1], 'Thread 1 unchanged');
    AssertEquals(Cardinal(512),  LList[2], 'Thread 2 after second add');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcMemListAddMem');
end;

procedure TestProcMemListAddMemThreadZeroRaisesException;
var
  LList: tProcMemList;
begin
  LList := tProcMemList.Create();
  try
    LList.Count := 3;
    AssertExceptionRaised(
      procedure begin LList.AddMem(0, 100); end,
      'AddMem with ThreadId=0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcMemListAddMemThreadZeroRaisesException');
end;

procedure TestProcMemListAssignMem;
var
  LList: tProcMemList;
begin
  LList := tProcMemList.Create();
  try
    LList.Count := 3;
    LList.AssignMem(1, 2048);
    AssertEquals(Cardinal(2048), LList[0], 'Sum after first assign');
    AssertEquals(Cardinal(2048), LList[1], 'Thread 1 after first assign');

    LList.AssignMem(2, 512);
    AssertEquals(Cardinal(512),  LList[0], 'Sum after second assign');
    AssertEquals(Cardinal(2048), LList[1], 'Thread 1 unchanged');
    AssertEquals(Cardinal(512),  LList[2], 'Thread 2 after assign');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcMemListAssignMem');
end;

procedure TestProcMemListAssignMemThreadZeroRaisesException;
var
  LList: tProcMemList;
begin
  LList := tProcMemList.Create();
  try
    LList.Count := 3;
    AssertExceptionRaised(
      procedure begin LList.AssignMem(0, 100); end,
      'AssignMem with ThreadId=0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestProcMemListAssignMemThreadZeroRaisesException');
end;

{ TCallGraphInfo tests }

procedure TestCallGraphInfoCreation;
var
  LInfo: TCallGraphInfo;
  i: Integer;
begin
  LInfo := TCallGraphInfo.Create(3);
  try
    AssertNotNil(LInfo.ProcTime,      'ProcTime list');
    AssertNotNil(LInfo.ProcCnt,       'ProcCnt list');
    AssertNotNil(LInfo.ProcTimeMin,   'ProcTimeMin list');
    AssertNotNil(LInfo.ProcTimeMax,   'ProcTimeMax list');
    AssertNotNil(LInfo.ProcTimeAvg,   'ProcTimeAvg list');
    AssertNotNil(LInfo.ProcChildTime, 'ProcChildTime list');
    AssertNotNil(LInfo.ProcMem,       'ProcMem list');

    AssertEquals(3, LInfo.ProcTime.Count,      'ProcTime.Count');
    AssertEquals(3, LInfo.ProcCnt.Count,       'ProcCnt.Count');
    AssertEquals(3, LInfo.ProcTimeMin.Count,   'ProcTimeMin.Count');
    AssertEquals(3, LInfo.ProcChildTime.Count, 'ProcChildTime.Count');

    for i := 0 to LInfo.ProcTimeMin.Count - 1 do
      if LInfo.ProcTimeMin[i] <> High(uint64) then
        raise Exception.CreateFmt('ProcTimeMin[%d] should be High(uint64)', [i]);

    for i := 0 to LInfo.ProcTime.Count - 1 do
      if LInfo.ProcTime[i] <> 0 then
        raise Exception.CreateFmt('ProcTime[%d] should be 0', [i]);
  finally
    LInfo.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoCreation');
end;

procedure TestCallGraphInfoToInfoString;
var
  LInfo: TCallGraphInfo;
  LStr: String;
begin
  LInfo := TCallGraphInfo.Create(2);
  try
    LStr := LInfo.ToInfoString();
    if Length(LStr) = 0 then
      raise Exception.Create('ToInfoString should return non-empty string');
    if Pos('CallGraphInfo:', LStr) = 0 then
      raise Exception.Create('ToInfoString should contain "CallGraphInfo:"');
    if Pos('ProcTime:', LStr) = 0 then
      raise Exception.Create('ToInfoString should contain "ProcTime:"');
  finally
    LInfo.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoToInfoString');
end;

{ TCallGraphInfoDict tests }

procedure TestCallGraphInfoDictGetOrCreate;
var
  LDict: TCallGraphInfoDict;
  LInfo1, LInfo2: TCallGraphInfo;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LInfo1 := LDict.GetOrCreateGraphInfo(1, 2, 2);
    AssertNotNil(LInfo1, 'First GetOrCreate returns non-nil');

    LInfo2 := LDict.GetOrCreateGraphInfo(1, 2, 2);
    if LInfo1 <> LInfo2 then
      raise Exception.Create('Same key should return the same object');

    LInfo2 := LDict.GetOrCreateGraphInfo(3, 2, 2);
    if LInfo1 = LInfo2 then
      raise Exception.Create('Different parent key should return different object');

    LInfo2 := LDict.GetOrCreateGraphInfo(1, 5, 2);
    if LInfo1 = LInfo2 then
      raise Exception.Create('Different child key should return different object');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictGetOrCreate');
end;

procedure TestCallGraphInfoDictGetGraphInfo;
var
  LDict: TCallGraphInfoDict;
  LResult: TCallGraphInfo;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LResult := LDict.GetGraphInfo(1, 2);
    AssertNil(LResult, 'Should be nil before any entry added');

    LDict.GetOrCreateGraphInfo(1, 2, 2);
    LResult := LDict.GetGraphInfo(1, 2);
    AssertNotNil(LResult, 'Should find entry after creation');

    LResult := LDict.GetGraphInfo(1, 3);
    AssertNil(LResult, 'Should be nil for non-existent child');

    LResult := LDict.GetGraphInfo(99, 2);
    AssertNil(LResult, 'Should be nil for non-existent parent');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictGetGraphInfo');
end;

procedure TestCallGraphInfoDictGetForParentProcId;
var
  LDict: TCallGraphInfoDict;
  LList: TList<TCallGraphInfo>;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LList := LDict.GetGraphInfoForParentProcId(1);
    AssertNil(LList, 'Should be nil before any entry added');

    LDict.GetOrCreateGraphInfo(1, 2, 2);
    LDict.GetOrCreateGraphInfo(1, 3, 2);
    LDict.GetOrCreateGraphInfo(2, 4, 2);

    LList := LDict.GetGraphInfoForParentProcId(1);
    AssertNotNil(LList, 'Should find list for parent 1');
    if LList.Count <> 2 then
      raise Exception.CreateFmt('Expected 2 children for parent 1, got %d', [LList.Count]);

    LList := LDict.GetGraphInfoForParentProcId(2);
    AssertNotNil(LList, 'Should find list for parent 2');
    if LList.Count <> 1 then
      raise Exception.CreateFmt('Expected 1 child for parent 2, got %d', [LList.Count]);

    LList := LDict.GetGraphInfoForParentProcId(99);
    AssertNil(LList, 'Should be nil for non-existent parent');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictGetForParentProcId');
end;

procedure TestCallGraphInfoDictClear;
var
  LDict: TCallGraphInfoDict;
  LResult: TCallGraphInfo;
  LList: TList<TCallGraphInfo>;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LDict.GetOrCreateGraphInfo(1, 2, 2);
    LDict.GetOrCreateGraphInfo(1, 3, 2);
    LDict.Clear();

    LResult := LDict.GetGraphInfo(1, 2);
    AssertNil(LResult, 'Should be nil after clear');

    LList := LDict.GetGraphInfoForParentProcId(1);
    AssertNil(LList, 'Parent list should be nil after clear');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictClear');
end;

procedure TestCallGraphInfoDictCalculateAverage;
var
  LDict: TCallGraphInfoDict;
  LInfo: TCallGraphInfo;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LInfo := LDict.GetOrCreateGraphInfo(1, 2, 2);
    LInfo.ProcTime.AddTime(1, 300);
    LInfo.ProcCnt.AddCount(1, 3);

    LDict.CalculateAverage();

    AssertEquals(uint64(100), LInfo.ProcTimeAvg[1], 'Average for thread 1: 300/3=100');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictCalculateAverage');
end;

procedure TestCallGraphInfoDictCalculateAverageZeroCnt;
var
  LDict: TCallGraphInfoDict;
  LInfo: TCallGraphInfo;
begin
  LDict := TCallGraphInfoDict.Create();
  try
    LInfo := LDict.GetOrCreateGraphInfo(1, 2, 2);
    // ProcCnt[1] = 0 (default)
    LDict.CalculateAverage();

    AssertEquals(uint64(0), LInfo.ProcTimeAvg[1], 'Average should be 0 when count is 0');
  finally
    LDict.Free;
  end;
  Writeln('  PASS: TestCallGraphInfoDictCalculateAverageZeroCnt');
end;

procedure RunCallGraphTests;
begin
  Writeln('Running Call Graph Logic Tests...');
  TestProcTimeListAddTime;
  TestProcTimeListAddTimeThreadZeroRaisesException;
  TestProcTimeListAssignTime;
  TestProcTimeListAssignTimeThreadZeroRaisesException;
  TestProcCountListAddCount;
  TestProcCountListAddCountThreadZeroRaisesException;
  TestProcMemListAddMem;
  TestProcMemListAddMemThreadZeroRaisesException;
  TestProcMemListAssignMem;
  TestProcMemListAssignMemThreadZeroRaisesException;
  TestCallGraphInfoCreation;
  TestCallGraphInfoToInfoString;
  TestCallGraphInfoDictGetOrCreate;
  TestCallGraphInfoDictGetGraphInfo;
  TestCallGraphInfoDictGetForParentProcId;
  TestCallGraphInfoDictClear;
  TestCallGraphInfoDictCalculateAverage;
  TestCallGraphInfoDictCalculateAverageZeroCnt;
  Writeln('Call Graph Logic Tests: ALL PASSED');
end;

end.
