unit gppMain.FrameInstrumentation.SelectionInfo;

interface

uses
  System.Classes, System.SysUtils, System.Generics.Collections, gpparser.types,
  gppMain.FrameInstrumentation.SelectionInfoIF;

type
  TSelectionInfo = class(TInterfacedObject, ISelectionInfo)
  private
    fSelectionString : String;
    fIsItem : boolean;
  protected
    function getIsItem : boolean;
    function getSelectionString : String;
    function GetProcedureNameForSelection(const aProcedureName: string): string;

  public
    constructor Create(const aSelectionString: String);
  end;

  TUnitInstrumentationInfo = class
    UnitName : string;
    IsFullyInstrumented: boolean;
    IsNothingInstrumented: boolean;
  end;

  TProcedureInstrumentationInfo = class
    ProcedureName : string;
    ClassName : string;
    ClassMethodName : string;
    IsInstrumentedOrCheckedForInstrumentation: boolean;
    function IsProcedureValidForSelectedClass(const aClassSelectionInfo: ISelectionInfo) : boolean;
  end;


  TUnitInstrumentationInfoList = class(TObjectList<TUnitInstrumentationInfo>)
  public
    procedure SortByName();
  end;


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


  TProcedureInstrumentationInfoList = class(TObjectList<TProcedureInstrumentationInfo>)
  public
    procedure SortByName();
  end;

  TProcInfo = class
  strict private
    fpiName: string;
    fpiClassName : String;
  public
    piInstrument : boolean;
    constructor Create(const aProcName,aClassName : string);

    property piName: string read fpiName;
    property piClassName: string read fpiClassName;
  end;

  TProcInfoList = class(TObjectList<TProcInfo>)
  private
    fAllInstrumented : boolean;
    fNoneInstrumented : boolean;
  public
    constructor Create();

    function GetIndexByName(const aName : string): integer;

    procedure UpdateInstrumentedState();

    procedure AreAllClassMethodsInstrumented(const aClassName: string; var aAllInstrumented, aNoneInstrumented: boolean);

    property AllInstrumented : boolean read fAllInstrumented write fAllInstrumented;
    property NoneInstrumented : boolean read fNoneInstrumented write fNoneInstrumented;
  end;
  { takes the procedures defined in a unit a gets the instrumentalization state.
    @returns list with instumentatization info.}
  function GetClassesFromUnit(const aProcInfoList : TProcedureInstrumentationInfoList): TClassInfoList;

  { takes the procedures defined in a unit a gets the instrumentalization state.
    @returns list with instumentatization info.}
  function GetProcsForClassFromUnit(const aProcInfoList : TProcedureInstrumentationInfoList; const aSelectionInfo: ISelectionInfo): TProcInfoList;

implementation

uses
  GpString, System.Generics.Defaults;

function GetClassesFromUnit(const aProcInfoList : TProcedureInstrumentationInfoList): TClassInfoList;
var
  lProcInstrumentationInfo : TProcedureInstrumentationInfo;
  LUnitProcName : string;
  LUnitProcNameDotPosition : integer;
  LCurrentEntry : TClassInfo;
  LIndexInClassList : integer;
begin
  result := TClassInfoList.Create();
  for lProcInstrumentationInfo in aProcInfoList do
  begin
    // the unitProcList has a all/none flag at the end. remove that.
    LUnitProcName := lProcInstrumentationInfo.Procedurename;
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
    if lProcInstrumentationInfo.IsInstrumentedOrCheckedForInstrumentation then
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

function GetProcsForClassFromUnit(const aProcInfoList : TProcedureInstrumentationInfoList; const aSelectionInfo : ISelectionInfo): TProcInfoList;
var
  lProcInstrumentationInfo : TProcedureInstrumentationInfo;
  LProcedureName : string;
  LProcInfo : TProcInfo;
begin
  result := TProcInfoList.Create();
  for lProcInstrumentationInfo in aProcInfoList do
  begin
    LProcedureName := lProcInstrumentationInfo.ProcedureName;
    if LProcedureName = '' then
      continue;
    if (not lProcInstrumentationInfo.IsProcedureValidForSelectedClass(aSelectionInfo)) then
      continue;
    if (not aSelectionInfo.IsItem) and not lProcInstrumentationInfo.ClassMethodName.IsEmpty then
      LProcInfo := TProcInfo.Create(lProcInstrumentationInfo.ClassMethodName, lProcInstrumentationInfo.ClassName)
    else
      LProcInfo := TProcInfo.Create(LProcedureName, lProcInstrumentationInfo.ClassName);
    LProcInfo.piInstrument := lProcInstrumentationInfo.IsInstrumentedOrCheckedForInstrumentation;
    result.Add(LProcInfo);
  end;
  result.UpdateInstrumentedState;
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

constructor TProcInfo.Create(const aProcName, aClassName: string);
begin
  inherited Create();
  fpiName := aProcName;
  fpiClassName := aClassName;
  piInstrument := true;
end;

{ TProcInfoList }

procedure TProcInfoList.AreAllClassMethodsInstrumented(const aClassName: string; var aAllInstrumented, aNoneInstrumented: boolean);
begin
  aAllInstrumented := true;
  aNoneInstrumented := true;
  for var LProcInfo in self do
  begin
    if not sameText(LProcInfo.piClassName, aClassname) then
      continue;

    if aAllInstrumented then
    begin
      if not LProcInfo.piInstrument then
        aAllInstrumented := false;
    end;
    if aNoneInstrumented then
    begin
      if LProcInfo.piInstrument then
        aNoneInstrumented := false;
    end;
  end;

end;

constructor TProcInfoList.Create();
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
    if Uppercase(self[i].piName) = LName then
      exit(i);
end;


procedure TProcInfoList.UpdateInstrumentedState;
var
  LProcInfo : TProcInfo;
begin
  fAllInstrumented := true;
  fNoneInstrumented := true;
  for LProcInfo in self do
  begin
    if fAllInstrumented then
    begin
      if not LProcInfo.piInstrument then
        fAllInstrumented := false;
    end;
    if fNoneInstrumented then
    begin
      if LProcInfo.piInstrument then
        fNoneInstrumented := false;
    end;
  end;
end;

{ tSelectionInfo }

constructor TSelectionInfo.Create(const aSelectionString: String);
begin
  fSelectionString := aSelectionString;
  fIsItem := aSelectionString.StartsWith('<') and aSelectionString.EndsWith('>');
end;

function TSelectionInfo.getIsItem: boolean;
begin
  result := fIsItem;
end;

function TSelectionInfo.GetProcedureNameForSelection(const aProcedureName: string): string;
begin
  if self.fIsItem then
    result := aProcedureName
  else
  begin
    if fSelectionString.IsEmpty() then
      result := aProcedureName
    else
      result := fSelectionString + '.' + aProcedureName;
  end;
end;

function TSelectionInfo.getSelectionString: String;
begin
  result := fSelectionString;
end;

{ TUnitInstrumentationInfoList }

procedure TUnitInstrumentationInfoList.SortByName;
begin
  Sort(TComparer<TUnitInstrumentationInfo>.Construct(
      function (const Left, Right: TUnitInstrumentationInfo): integer
      begin
          Result := CompareText(Left.UnitName,Right.UnitName);
      end));
end;

{ TProcedureInstrumentationInfoList }

procedure TProcedureInstrumentationInfoList.SortByName;
begin
Sort(TComparer<TProcedureInstrumentationInfo>.Construct(
      function (const Left, Right: TProcedureInstrumentationInfo): integer
      begin
          Result := CompareText(Left.ProcedureName,Right.ProcedureName);
      end));
end;

{ TProcedureInstrumentationInfo }

function TProcedureInstrumentationInfo.IsProcedureValidForSelectedClass(const aClassSelectionInfo : ISelectionInfo): boolean;
begin
  result := false;
  if aClassSelectionInfo.isItem then
  begin
    if sameText(aClassSelectionInfo.SelectionString, ALL_CLASSES) then
    begin
      result := true;
    end
    else if sameText(aClassSelectionInfo.SelectionString, ALL_CLASSLESS_PROCEDURES) then
    begin
      result := self.ClassName.IsEmpty;
    end;
  end
  else
  begin
    result := SameText(self.ClassName, aClassSelectionInfo.SelectionString);
  end;
end;

end.
