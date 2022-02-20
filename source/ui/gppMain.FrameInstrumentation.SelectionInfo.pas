unit gppMain.FrameInstrumentation.SelectionInfo;

interface

uses
  System.Classes, System.Generics.Collections;

type

  TClassInfo = class
    anName: string;
    anAll : boolean;
    anNone : boolean;
  end;

  TClassInfoList = class(TObjectList<TClassInfo>)
  private
    fAllClassesEntry : TClassInfo;
    fClasslessEntry : TClassInfo;
  public
    constructor Create();
    destructor Destroy; override;

    function GetIndexByName(const aName : string): integer;

    property ClasslessEntry : TClassInfo read fClasslessEntry;
    property AllClassesEntry : TClassInfo read fAllClassesEntry;

  end;

  TProcInfo = class
  public
    anName: string;
    anInstrument : boolean;
    constructor Create(const aProcName : string);

  end;

  TProcInfoList = class(TObjectList<TProcInfo>)
  private
    fAllInstrumented : boolean;
    fNoneInstrumented : boolean;
  public
    constructor Create();

    function GetIndexByName(const aName : string): integer;

    property AllInstrumented : boolean read fAllInstrumented write fAllInstrumented;
    property NoneInstrumented : boolean read fNoneInstrumented write fNoneInstrumented;
  end;
  { takes the procedures defined in a unit a gets the instrumentalization state.
    @returns list with instumentatization info.}
  function GetClassesFromUnit(const aUnitProcList : TStringList): TClassInfoList;

  { takes the procedures defined in a unit a gets the instrumentalization state.
    @returns list with instumentatization info.}
  function GetProcsFromUnit(const aUnitProcList : TStringList; const aSelectedClassIndex :integer; const aSelectedClassName : string): TProcInfoList;

implementation

uses
  system.Sysutils,
  GpString;

function GetClassesFromUnit(const aUnitProcList : TStringList): TClassInfoList;
var
  i : integer;
  LUnitProcName : string;
  LUnitProcNameDotPosition : integer;
  LCurrentEntry : TClassInfo;
  LIndexInClassList : integer;
begin
  result := TClassInfoList.Create();
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
        LCurrentEntry := TClassInfo.Create();
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

function GetProcsFromUnit(const aUnitProcList : TStringList; const aSelectedClassIndex :integer; const aSelectedClassName : string): TProcInfoList;
var
  i : integer;
  LUnitName : string;
  LUppercasedClassName : string;
  LDotPosition : integer;
  LProcInfo : TProcInfo;
begin
  result := TProcInfoList.Create();
  LUppercasedClassName := Uppercase(aSelectedClassName);
  for i := 0 to aUnitProcList.Count - 1 do
  begin
    LUnitName := ButLast(aUnitProcList[i], 1);
    if LUnitName <> '' then
    begin
      LDotPosition := Pos('.', LUnitName);
      if (aSelectedClassIndex = 0) or ((aSelectedClassName[1] = '<') and (LDotPosition = 0)) or
        ((aSelectedClassName[1] <> '<') and (UpperCase(First(LUnitName, LDotPosition - 1)) = LUppercasedClassName)) then
      begin
        if (aSelectedClassName[1] <> '<') and (LDotPosition > 0) then
          LProcInfo := TProcInfo.Create(ButFirst(LUnitName, LDotPosition))
        else
          LProcInfo := TProcInfo.Create(LUnitName);
        LProcInfo.anInstrument := Last(aUnitProcList[i], 1) = '1';
        if not LProcInfo.anInstrument then
        begin
          result.AllInstrumented := false;
        end
        else
        begin
          result.NoneInstrumented := false;
        end;
        result.Add(LProcInfo);
      end;
    end;
  end;
end;


{ TClassInfoList }

constructor TClassInfoList.Create;
begin
  inherited Create(true);
  fClasslessEntry := TClassInfo.Create();
  fClasslessEntry.anAll := true;
  fClasslessEntry.anNone := true;
  fAllClassesEntry := TClassInfo.Create();
  fAllClassesEntry.anAll := true;
  fAllClassesEntry.anNone := true;
end;

destructor TClassInfoList.Destroy;
begin
  fClasslessEntry.free;
  fAllClassesEntry.free;
  inherited;
end;

function TClassInfoList.GetIndexByName(const aName: string): integer;
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


{ TProcInfo }

constructor TProcInfo.Create(const aProcName: string);
begin
  inherited Create();
  anName := aProcName;
  anInstrument := true;
end;

{ TProcInfoList }

constructor TProcInfoList.Create;
begin
  inherited Create(true);
  fAllInstrumented := true;
  fNoneInstrumented := true;
end;

function TProcInfoList.GetIndexByName(const aName: string): integer;
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
