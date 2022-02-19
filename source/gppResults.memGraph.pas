unit gppResults.memGraph;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TMemConsumptionEntry = record
    mceStartingMemWorkingSet : Cardinal;
    mceEndingMemWorkingSet : Cardinal;
    function GetMemConsumptionWithChildrem(): Cardinal;
  end;

  /// <summary>
  /// a list with the invokation as its index and the mem state.
  /// </summary>
  TMemConsumptionForProcedureCalls = class(TList<TMemConsumptionEntry>)
  private
    fProcId : integer;
  public
    constructor Create(const aProcId : integer);
    property ProcId : integer read fProcId;
  end;

  TProcedureMemCallList = class(TObjectList<TMemConsumptionForProcedureCalls>)

    function GetOrCreateListForProc(const aProcId : integer): TMemConsumptionForProcedureCalls;
  end;


implementation


{ TMemConsumptionEntry }

function TMemConsumptionEntry.GetMemConsumptionWithChildrem: Cardinal;
begin
  // as we subtract the ending and the starting, the children mem is included.
  result := mceEndingMemWorkingSet - mceStartingMemWorkingSet;
end;

{ TMemConsumptionForProcedureCalls }

constructor TMemConsumptionForProcedureCalls.Create(const aProcId: integer);
begin
  inherited Create();
  fProcId := aProcId;
end;

{ TProcedureMemCallList }

function TProcedureMemCallList.GetOrCreateListForProc(const aProcId: integer): TMemConsumptionForProcedureCalls;
var
  lEntry : TMemConsumptionForProcedureCalls;
begin
  for lEntry in self do
  begin
    if lEntry.fProcId = aProcId then
      exit(lEntry);
  end;
  lEntry := TMemConsumptionForProcedureCalls.Create(aProcId);
  self.Add(lEntry);
end;

end.
