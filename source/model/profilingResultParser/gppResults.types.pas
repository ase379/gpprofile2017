unit gppResults.types;

interface

uses
  System.Generics.Collections;

type
  TProcEntry = class
  private
    function GetName: String;
  public
    // utf8 encoded procedure name
    peName         : AnsiString;
    pePID          : integer;
    peUID          : integer;
    peCID          : integer;
    peFirstLn      : integer;
    peProcTime     : array {thread} of uint64;   // 0 = sum
    peProcTimeMin  : array {thread} of uint64;   // 0 = unused
    peProcTimeMax  : array {thread} of uint64;   // 0 = unused
    peProcTimeAvg  : array {thread} of uint64;   // 0 = unused
    peProcChildTime: array {thread} of uint64;   // 0 = sum
    peProcMem      : array of Cardinal;
    peProcCnt      : array {thread} of Cardinal; // 0 = sum
    peCurrentCallDepth : array {thread} of integer; // 0 = unused

    procedure ResetTotalValues(const aIsDigest: boolean);
    procedure UpdateTotalValues(const aIndex: Integer);
    procedure UpdateMinMaxTimeForEntryWithIndex(const aIndex: Integer);
    procedure UpdateAverageTimeForEntryWithIndex(const aIndex: Integer);
    procedure UpdateAverageTime();
    property Name : String read GetName;
  end;

  TProcEntryList = class(TObjectList<TProcEntry>)
  public
    procedure ResizeAndCreateProcs(const aNewSize : integer);


    procedure AddProcRow(const aProcedureName: String; const aProcedureId: Cardinal; const aTotalNumberOfThreads: Cardinal);

    procedure AddThreadToExistsingProcRows(const aTotalNumberOfThreads: Cardinal);

  end;

  TResPacket = record
  public
    rpTag         : byte;
    rpThread      : integer;
    rpProcID      : integer;
    rpMeasure1    : int64;
    rpMeasure2    : int64;
    rpNullOverhead: int64;
    rpMeasurePointID : String;
  end;

  TResMemPacket = record
    rpMemWorkingSize : Cardinal;
  end;

const
  NULL_ACCURACY = 1000;
  REPORT_EVERY  = 100; // samples read

implementation

{ TProcEntry }

procedure TProcEntry.ResetTotalValues(const aIsDigest: boolean);
begin
  peProcTime[Low(peProcTime)] := 0;
  peProcMem[Low(peProcMem)] := 0;
  peProcChildTime[Low(peProcChildTime)] := 0;
  if (not aIsDigest) then
  begin
    peProcTimeMin[Low(peProcTimeMin)] := High(uint64);
    peProcTimeMax[Low(peProcTimeMax)] := 0;
  end;
end;

procedure TProcEntry.UpdateAverageTime();
begin
  if peProcTimeMin[Low(peProcTimeMin)] = High(uint64) then
    peProcTimeMin[Low(peProcTimeMin)] := 0;
  if peProcCnt[Low(peProcTime)] = 0 then
    peProcTimeAvg[Low(peProcTime)] := 0
  else
    peProcTimeAvg[Low(peProcTime)] := peProcTime[Low(peProcTime)] div peProcCnt[Low(peProcTime)];
end;

procedure TProcEntry.UpdateMinMaxTimeForEntryWithIndex(const aIndex: Integer);
begin
  if peProcCnt[aIndex] > 0 then
  begin
    if peProcTimeMin[aIndex] < peProcTimeMin[Low(peProcTimeMin)] then
      peProcTimeMin[Low(peProcTimeMin)] := peProcTimeMin[aIndex];
    if peProcTimeMax[aIndex] > peProcTimeMax[Low(peProcTimeMax)] then
      peProcTimeMax[Low(peProcTimeMax)] := peProcTimeMax[aIndex];
  end;
  if peProcTimeMin[aIndex] = High(uint64) then
    peProcTimeMin[aIndex] := 0;
end;

procedure TProcEntry.UpdateAverageTimeForEntryWithIndex(const aIndex: Integer);
begin
  if peProcCnt[aIndex] = 0 then
    peProcTimeAvg[aIndex] := 0
  else
    peProcTimeAvg[aIndex] := peProcTime[aIndex] div peProcCnt[aIndex];
end;

procedure TProcEntry.UpdateTotalValues(const aIndex: Integer);
begin
  Inc(peProcTime[Low(peProcTime)],peProcTime[aIndex]);
  Inc(peProcMem[Low(peProcMem)],peProcMem[aIndex]);
  Inc(peProcChildTime[Low(peProcChildTime)],peProcChildTime[aIndex]);
  Inc(peProcCnt[Low(peProcCnt)],peProcCnt[aIndex]);
  // correct the proctime min after the first addition of time.
  if peProcTimeMin[Low(peProcTimeMin)] = High(uint64) then
    peProcTimeMin[Low(peProcTimeMin)] := 0;
end;

{ TProcEntry }

function TProcEntry.GetName: String;
begin
  result := Utf8ToString(peName);
end;



{ TProcEntryList }

procedure TProcEntryList.AddProcRow(const aProcedureName: String; const aProcedureId, aTotalNumberOfThreads: Cardinal);
var
  lNewEntry : TProcEntry;
begin
  lNewEntry := TProcEntry.Create();
  lNewEntry.peName := utf8Encode(aProcedureName);
  setLength(lNewEntry.peProcTime, aTotalNumberOfThreads);
  setLength(lNewEntry.peProcTimeMin, aTotalNumberOfThreads);
  setLength(lNewEntry.peProcMem, aTotalNumberOfThreads);
  for var lNonTotalThreadId := Low(lNewEntry.peProcTimeMin)+1 to High(lNewEntry.peProcTimeMin) do
    lNewEntry.peProcTimeMin[lNonTotalThreadId] := High(uint64);

  setLength(lNewEntry.peProcTimeMax, aTotalNumberOfThreads);
  setLength(lNewEntry.peProcTimeAvg, aTotalNumberOfThreads);
  setLength(lNewEntry.peProcChildTime, aTotalNumberOfThreads);
  setLength(lNewEntry.peProcCnt, aTotalNumberOfThreads);
  setLength(lNewEntry.peCurrentCallDepth, aTotalNumberOfThreads);
  self.Add(lNewEntry)
end;

procedure TProcEntryList.AddThreadToExistsingProcRows(const aTotalNumberOfThreads: Cardinal);
begin
  for var lEntry in self do
  begin
    SetLength(lEntry.peProcTime,aTotalNumberOfThreads);
    SetLength(lEntry.peProcTimeMin,aTotalNumberOfThreads);
    SetLength(lEntry.peProcTimeMax,aTotalNumberOfThreads);
    SetLength(lEntry.peProcTimeAvg,aTotalNumberOfThreads);
    SetLength(lEntry.peProcChildTime,aTotalNumberOfThreads);
    SetLength(lEntry.peProcCnt,aTotalNumberOfThreads);
    SetLength(lEntry.peCurrentCallDepth,aTotalNumberOfThreads);
    SetLength(lEntry.peProcMem,aTotalNumberOfThreads);
    lEntry.peProcTime[aTotalNumberOfThreads-1]      := 0;
    lEntry.peProcTimeMin[aTotalNumberOfThreads-1]   := High(uint64);
    lEntry.peProcTimeMax[aTotalNumberOfThreads-1]   := 0;
    lEntry.peProcTimeAvg[aTotalNumberOfThreads-1]   := 0;
    lEntry.peProcChildTime[aTotalNumberOfThreads-1] := 0;
    lEntry.peProcCnt[aTotalNumberOfThreads-1]       := 0;
    lEntry.peCurrentCallDepth[aTotalNumberOfThreads-1] := 0;
    lEntry.peProcMem[aTotalNumberOfThreads-1] := 0;
  end;
end;

procedure TProcEntryList.ResizeAndCreateProcs(const aNewSize: integer);
var
  i : integer;
begin
  Count := aNewSize;
  for I := 0 to Count-1 do
  begin
    if not assigned(self[i]) then
    begin
      self[i] := TProcEntry.Create();
      self[i].peName := 'All Threads Information';
    end;
  end;
end;

end.
