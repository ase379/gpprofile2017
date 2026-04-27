unit testProcEntriesLogic;

/// <summary>
/// Logic tests for TProcEntry and TProcEntryList:
/// - AddProcRow creates an entry with correct name, sizes, and initial ProcTimeMin values
/// - AddProcRow for multiple entries
/// - AddThreadToExistingProcRows extends arrays and initializes new thread slot
/// - ResetTotalValues zeroes totals and restores ProcTimeMin sentinel
/// - UpdateTotalValues accumulates time, child time, count, and memory across threads
/// - UpdateAverageTimeForEntryWithIndex computes correct average
/// - UpdateAverageTime computes total average from thread 0 data
/// - UpdateMinMaxTimeForEntryWithIndex propagates min/max to the total slot
/// - ResizeAndCreateProcs fills list with placeholder entries
/// </summary>

interface

procedure RunProcEntriesTests;

implementation

uses
  System.SysUtils,
  gppResults.types;

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

procedure TestAddProcRowCreatesValidEntry;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 3);
    if LList.Count <> 1 then
      raise Exception.CreateFmt('Expected 1 entry, got %d', [LList.Count]);

    LEntry := LList[0];
    AssertNotNil(LEntry, 'Entry should not be nil');
    AssertEquals('TestProc', LEntry.Name, 'Entry name');
    AssertEquals(3, Length(LEntry.peProcTime),       'peProcTime length');
    AssertEquals(3, Length(LEntry.peProcTimeMin),    'peProcTimeMin length');
    AssertEquals(3, Length(LEntry.peProcTimeMax),    'peProcTimeMax length');
    AssertEquals(3, Length(LEntry.peProcTimeAvg),    'peProcTimeAvg length');
    AssertEquals(3, Length(LEntry.peProcChildTime),  'peProcChildTime length');
    AssertEquals(3, Length(LEntry.peProcCnt),        'peProcCnt length');
    AssertEquals(3, Length(LEntry.peCurrentCallDepth),'peCurrentCallDepth length');
    AssertEquals(3, Length(LEntry.peProcMem),        'peProcMem length');

    // Non-total thread slots should be initialized to High(uint64)
    if LEntry.peProcTimeMin[1] <> High(uint64) then
      raise Exception.Create('peProcTimeMin[1] should be High(uint64)');
    if LEntry.peProcTimeMin[2] <> High(uint64) then
      raise Exception.Create('peProcTimeMin[2] should be High(uint64)');

    // Total slot (index 0) is initialized separately and may be High(uint64) as well
    AssertEquals(uint64(0), LEntry.peProcTime[0], 'peProcTime[0] should be 0');
    AssertEquals(uint64(0), LEntry.peProcCnt[0],  'peProcCnt[0] should be 0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestAddProcRowCreatesValidEntry');
end;

procedure TestAddMultipleProcRows;
var
  LList: TProcEntryList;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('Alpha',   1, 2);
    LList.AddProcRow('Beta',    2, 2);
    LList.AddProcRow('Gamma',   3, 2);
    AssertEquals(3, LList.Count, 'Count after three adds');
    AssertEquals('Alpha',  LList[0].Name, 'Entry 0 name');
    AssertEquals('Beta',   LList[1].Name, 'Entry 1 name');
    AssertEquals('Gamma',  LList[2].Name, 'Entry 2 name');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestAddMultipleProcRows');
end;

procedure TestAddThreadToExistingProcRows;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LList.AddThreadToExistsingProcRows(3);

    LEntry := LList[0];
    AssertEquals(3, Length(LEntry.peProcTime), 'peProcTime length after add thread');

    // New slot should be initialized correctly
    if LEntry.peProcTimeMin[2] <> High(uint64) then
      raise Exception.Create('New thread peProcTimeMin should be High(uint64)');
    AssertEquals(uint64(0),    LEntry.peProcTime[2],      'New thread peProcTime');
    AssertEquals(uint64(0),    LEntry.peProcTimeMax[2],   'New thread peProcTimeMax');
    AssertEquals(uint64(0),    LEntry.peProcTimeAvg[2],   'New thread peProcTimeAvg');
    AssertEquals(uint64(0),    LEntry.peProcChildTime[2], 'New thread peProcChildTime');
    AssertEquals(Cardinal(0),  LEntry.peProcCnt[2],       'New thread peProcCnt');
    AssertEquals(Cardinal(0),  LEntry.peProcMem[2],       'New thread peProcMem');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestAddThreadToExistingProcRows');
end;

procedure TestResetTotalValues;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    LEntry.peProcTime[0]      := 999;
    LEntry.peProcChildTime[0] := 888;
    LEntry.peProcMem[0]       := 777;
    LEntry.peProcTimeMin[0]   := 100;
    LEntry.peProcTimeMax[0]   := 500;

    LEntry.ResetTotalValues(False);

    AssertEquals(uint64(0),    LEntry.peProcTime[0],      'peProcTime[0] reset');
    AssertEquals(uint64(0),    LEntry.peProcChildTime[0], 'peProcChildTime[0] reset');
    AssertEquals(Cardinal(0),  LEntry.peProcMem[0],       'peProcMem[0] reset');
    if LEntry.peProcTimeMin[0] <> High(uint64) then
      raise Exception.Create('peProcTimeMin[0] should be High(uint64) after reset');
    AssertEquals(uint64(0), LEntry.peProcTimeMax[0], 'peProcTimeMax[0] reset');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestResetTotalValues');
end;

procedure TestResetTotalValuesDigest;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    LEntry.peProcTimeMin[0] := 100;
    LEntry.peProcTimeMax[0] := 500;

    // In digest mode, min/max should NOT be reset
    LEntry.ResetTotalValues(True);

    AssertEquals(uint64(100), LEntry.peProcTimeMin[0], 'peProcTimeMin[0] unchanged in digest');
    AssertEquals(uint64(500), LEntry.peProcTimeMax[0], 'peProcTimeMax[0] unchanged in digest');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestResetTotalValuesDigest');
end;

procedure TestUpdateTotalValues;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 3);
    LEntry := LList[0];

    LEntry.peProcTime[1]      := 100;
    LEntry.peProcChildTime[1] := 20;
    LEntry.peProcCnt[1]       := 5;
    LEntry.peProcMem[1]       := 1024;

    LEntry.peProcTime[2]      := 200;
    LEntry.peProcChildTime[2] := 40;
    LEntry.peProcCnt[2]       := 10;
    LEntry.peProcMem[2]       := 2048;

    LEntry.UpdateTotalValues(1);
    LEntry.UpdateTotalValues(2);

    AssertEquals(uint64(300), LEntry.peProcTime[0],      'Total proc time');
    AssertEquals(uint64(60),  LEntry.peProcChildTime[0], 'Total child time');
    AssertEquals(Cardinal(15), LEntry.peProcCnt[0],      'Total count');
    AssertEquals(Cardinal(3072), LEntry.peProcMem[0],    'Total memory');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateTotalValues');
end;

procedure TestUpdateAverageTimeForEntry;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    LEntry.peProcTime[1] := 300;
    LEntry.peProcCnt[1]  := 6;
    LEntry.UpdateAverageTimeForEntryWithIndex(1);
    AssertEquals(uint64(50), LEntry.peProcTimeAvg[1], 'Average for thread 1: 300/6=50');

    LEntry.peProcCnt[1] := 0;
    LEntry.UpdateAverageTimeForEntryWithIndex(1);
    AssertEquals(uint64(0), LEntry.peProcTimeAvg[1], 'Average for thread 1 with zero count');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateAverageTimeForEntry');
end;

procedure TestUpdateAverageTimeTotal;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    LEntry.peProcTime[0] := 600;
    LEntry.peProcCnt[0]  := 4;
    LEntry.UpdateAverageTime();
    AssertEquals(uint64(150), LEntry.peProcTimeAvg[0], 'Total average: 600/4=150');

    // If count is 0 but total min is sentinel, sentinel is cleared
    LEntry.peProcCnt[0]       := 0;
    LEntry.peProcTimeMin[0]   := High(uint64);
    LEntry.UpdateAverageTime();
    if LEntry.peProcTimeMin[0] <> 0 then
      raise Exception.Create('Sentinel should be cleared to 0 when count=0');
    AssertEquals(uint64(0), LEntry.peProcTimeAvg[0], 'Total average with zero count');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateAverageTimeTotal');
end;

procedure TestUpdateMinMaxForEntry;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    LEntry.peProcTimeMin[1] := 150;
    LEntry.peProcTimeMax[1] := 500;
    LEntry.peProcCnt[1]     := 3;

    LEntry.UpdateMinMaxTimeForEntryWithIndex(1);

    AssertEquals(uint64(150), LEntry.peProcTimeMin[0], 'Global min should be 150');
    AssertEquals(uint64(500), LEntry.peProcTimeMax[0], 'Global max should be 500');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateMinMaxForEntry');
end;

procedure TestUpdateMinMaxClearsHighSentinel;
var
  LList: TProcEntryList;
  LEntry: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.AddProcRow('TestProc', 1, 2);
    LEntry := LList[0];

    // Count = 0, so min/max propagation should not happen; sentinel should be cleared
    LEntry.peProcTimeMin[1] := High(uint64);
    LEntry.peProcCnt[1]     := 0;
    LEntry.UpdateMinMaxTimeForEntryWithIndex(1);

    if LEntry.peProcTimeMin[1] <> 0 then
      raise Exception.Create('Sentinel High(uint64) in slot 1 should be cleared to 0');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestUpdateMinMaxClearsHighSentinel');
end;

procedure TestResizeAndCreateProcs;
var
  LList: TProcEntryList;
  i: Integer;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.ResizeAndCreateProcs(5);
    AssertEquals(5, LList.Count, 'Count after resize to 5');
    for i := 0 to LList.Count - 1 do
    begin
      AssertNotNil(LList[i], 'Entry should not be nil');
      AssertEquals('All Threads Information', LList[i].Name,
        Format('Entry %d should have placeholder name', [i]));
    end;
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestResizeAndCreateProcs');
end;

procedure TestResizeAndCreateProcsIdempotent;
var
  LList: TProcEntryList;
  LFirst: TProcEntry;
begin
  LList := TProcEntryList.Create(True);
  try
    LList.ResizeAndCreateProcs(3);
    LFirst := LList[0];

    // Calling again should not replace existing entries
    LList.ResizeAndCreateProcs(3);
    if LList[0] <> LFirst then
      raise Exception.Create('ResizeAndCreateProcs should not replace existing entries');
  finally
    LList.Free;
  end;
  Writeln('  PASS: TestResizeAndCreateProcsIdempotent');
end;

procedure RunProcEntriesTests;
begin
  Writeln('Running Proc Entries Logic Tests...');
  TestAddProcRowCreatesValidEntry;
  TestAddMultipleProcRows;
  TestAddThreadToExistingProcRows;
  TestResetTotalValues;
  TestResetTotalValuesDigest;
  TestUpdateTotalValues;
  TestUpdateAverageTimeForEntry;
  TestUpdateAverageTimeTotal;
  TestUpdateMinMaxForEntry;
  TestUpdateMinMaxClearsHighSentinel;
  TestResizeAndCreateProcs;
  TestResizeAndCreateProcsIdempotent;
  Writeln('Proc Entries Logic Tests: ALL PASSED');
end;

end.
