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

  TProcedureMemCallList = class
  private
    fList : TObjectList<TMemConsumptionForProcedureCalls>;
    fLookupTable : TDictionary<integer, TMemConsumptionForProcedureCalls>;
    function GetCount(): integer;
    procedure SetCount(const aCount : integer);
  public
    constructor Create();
    destructor Destroy; override;
    procedure Clear();
    procedure Write(const aIndex : Integer; const anEntry : TMemConsumptionForProcedureCalls);
    function Read(const aIndex : Integer): TMemConsumptionForProcedureCalls;
    procedure AddEntryToProcList(const aProcId: integer; const aEntry: TMemConsumptionEntry);
    property Count: integer read GetCount write SetCount;
  end;


implementation

uses
  System.Sysutils;


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


constructor TProcedureMemCallList.Create;
begin
  fList := TObjectList<TMemConsumptionForProcedureCalls>.Create();
  fLookupTable := TDictionary<integer, TMemConsumptionForProcedureCalls>.Create;
end;

destructor TProcedureMemCallList.Destroy;
begin
  fLookupTable.Free;
  fList.Free;
  inherited;
end;


procedure TProcedureMemCallList.Clear;
begin
  fLookupTable.Clear;
  fList.Clear();
end;

function TProcedureMemCallList.GetCount: integer;
begin
  result := fList.Count;
end;

procedure TProcedureMemCallList.SetCount(const aCount: integer);
begin
  fList.Count := aCount;
end;


function TProcedureMemCallList.Read(const aIndex: Integer): TMemConsumptionForProcedureCalls;
begin
  result := flist[aIndex];
end;

procedure TProcedureMemCallList.Write(const aIndex: Integer; const anEntry: TMemConsumptionForProcedureCalls);
begin
  fList[aIndex] := anEntry;
  fLookupTable.AddOrSetValue(aIndex, anEntry);
end;

procedure TProcedureMemCallList.AddEntryToProcList(const aProcId: integer; const aEntry: TMemConsumptionEntry);
var
  lMemList : TMemConsumptionForProcedureCalls;
begin
  if not fLookupTable.TryGetValue(aProcId, lMemList) then
  begin
    lMemList := TMemConsumptionForProcedureCalls.Create(aProcId);
    fList.Add(lMemList);
    fLookupTable.Add(aProcId, lMemList);
  end;
  lMemList.Add(aEntry);
end;


end.
