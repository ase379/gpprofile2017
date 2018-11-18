unit gpParser.analysis;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TSelectionInformation = class
    anName: string;
    anAll : boolean;
    anNone : boolean;
  end;

  TSelectionInformationList = class(TObjectList<TSelectionInformation>)
  private
    fAllClassesEntry : TSelectionInformation;
    fClasslessEntry : TSelectionInformation;
  public
    constructor Create();
    destructor Destroy; override;

    function GetIndexByName(const aName : string): integer;

    property ClasslessEntry : TSelectionInformation read fClasslessEntry;
    property AllClassesEntry : TSelectionInformation read fAllClassesEntry;

  end;

  { takes the procedures defined in a unit a gets the instrumentalization state.
    @returns list with instumentatization info.}
  function GetClassesFromUnit(const aUnitProcList : TStringList): TSelectionInformationList;

implementation

uses
  system.Sysutils,
  GpString;

function GetClassesFromUnit(const aUnitProcList : TStringList): TSelectionInformationList;
var
  i : integer;
  LUnitProcName : string;
  LUnitProcNameDotPosition : integer;
  LCurrentEntry : TSelectionInformation;
  LIndexInClassList : integer;
begin
  result := TSelectionInformationList.Create();
  for i := 0 to aUnitProcList.Count - 1 do
  begin
    // the unitProcList has a all/none flag at the end. remove that.
    LUnitProcName := ButLast(aUnitProcList[i], 1);
    LUnitProcNameDotPosition := Pos('.', LUnitProcName);
    if LUnitProcNameDotPosition > 0 then
    begin
      LUnitProcName := Copy(LUnitProcName, 1, LUnitProcNameDotPosition - 1);
      LIndexInClassList := result.GetIndexByName(LUnitProcName);
      if LIndexInClassList = -1 then
      begin
        // Current Entry is put into object list
        LCurrentEntry := TSelectionInformation.Create();
        LCurrentEntry.anName := LUnitProcName;
        LCurrentEntry.anAll := true;
        LCurrentEntry.anNone := true;
        LIndexInClassList := result.Add(LCurrentEntry);
      end;
      LCurrentEntry := result[LIndexInClassList];
    end
    else
      LCurrentEntry := result.ClasslessEntry;
    if Last(aUnitProcList[i], 1) = '1' then
    begin
      LCurrentEntry.anNone := false;
      result.AllClassesEntry.anNone := false;
    end
    else
    begin
      LCurrentEntry.anAll := false;
      result.AllClassesEntry.anAll := false;
    end;
  end;
end;


{ TSelectionInformationList }

constructor TSelectionInformationList.Create;
begin
  inherited Create(true);
  fClasslessEntry := TSelectionInformation.Create();
  fClasslessEntry.anAll := true;
  fClasslessEntry.anNone := true;
  fAllClassesEntry := TSelectionInformation.Create();
  fAllClassesEntry.anAll := true;
  fAllClassesEntry.anNone := true;
end;

destructor TSelectionInformationList.Destroy;
begin
  fClasslessEntry.free;
  fAllClassesEntry.free;
  inherited;
end;

function TSelectionInformationList.GetIndexByName(const aName: string): integer;
var
  i : Integer;
  LName : string;
begin
  result := -1;
  LName := UpperCase(aName);
  for i := 0 to Self.Count-1 do
    if Uppercase(self[i].anName) = LName then
      exit(i);
end;


end.
