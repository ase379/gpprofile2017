unit gppResults.procArrayTools;

interface

uses
  gppResults.types;

type
  TProcArrayTools = class
    class procedure AddProcRow(var aProcArray: TArray<TProcEntry>;const aProcedureName: String; const aProcedureId: Cardinal;
      const aTotalNumberOfThreads: Cardinal);
    class procedure AddThreadToExistsingProcRows(var aProcArray: TArray<TProcEntry>;const aTotalNumberOfThreads: Cardinal);
  end;

implementation

{ TProcArrayTools }

class procedure TProcArrayTools.AddProcRow(var aProcArray:TArray<TProcEntry>; const aProcedureName: String; const aProcedureId: Cardinal;
  const aTotalNumberOfThreads: Cardinal);
begin
  SetLength(aProcArray,Length(aProcArray)+1);
  aProcArray[aProcedureId].peName := utf8Encode(aProcedureName);
  setLength(aProcArray[aProcedureId].peProcTime, aTotalNumberOfThreads);
  setLength(aProcArray[aProcedureId].peProcTimeMin, aTotalNumberOfThreads);
  for var lNonTotalThreadId := Low(aProcArray[aProcedureId].peProcTimeMin)+1 to High(aProcArray[aProcedureId].peProcTimeMin) do
    aProcArray[aProcedureId].peProcTimeMin[lNonTotalThreadId] := High(uint64);

  setLength(aProcArray[aProcedureId].peProcTimeMax, aTotalNumberOfThreads);
  setLength(aProcArray[aProcedureId].peProcTimeAvg, aTotalNumberOfThreads);
  setLength(aProcArray[aProcedureId].peProcChildTime, aTotalNumberOfThreads);
  setLength(aProcArray[aProcedureId].peProcCnt, aTotalNumberOfThreads);
  setLength(aProcArray[aProcedureId].peCurrentCallDepth, aTotalNumberOfThreads);
end;

class procedure TProcArrayTools.AddThreadToExistsingProcRows(var aProcArray: TArray<TProcEntry>;
  const aTotalNumberOfThreads: Cardinal);
var
  i : integer;
begin
  for i := Low(aProcArray) to High(aProcArray) do
  begin
    SetLength(aProcArray[i].peProcTime,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peProcTimeMin,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peProcTimeMax,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peProcTimeAvg,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peProcChildTime,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peProcCnt,aTotalNumberOfThreads);
    SetLength(aProcArray[i].peCurrentCallDepth,aTotalNumberOfThreads);
    aProcArray[i].peProcTime[aTotalNumberOfThreads-1]      := 0;
    aProcArray[i].peProcTimeMin[aTotalNumberOfThreads-1]   := High(uint64);
    aProcArray[i].peProcTimeMax[aTotalNumberOfThreads-1]   := 0;
    aProcArray[i].peProcTimeAvg[aTotalNumberOfThreads-1]   := 0;
    aProcArray[i].peProcChildTime[aTotalNumberOfThreads-1] := 0;
    aProcArray[i].peProcCnt[aTotalNumberOfThreads-1]       := 0;
    aProcArray[i].peCurrentCallDepth[aTotalNumberOfThreads-1] := 0;
  end;
end;

end.
