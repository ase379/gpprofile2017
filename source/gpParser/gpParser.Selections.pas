unit gpParser.Selections;

interface

uses
  System.Classes,System.SysUtils, System.Generics.Collections,
  gpParser.Units, Xml.XMLIntf, Xml.XMLDoc;

type
  TUnitSelection = class
  private
    fUnitName : string;
    FSelectedProcedures : TStringList;
  public
    constructor Create(const aUnitName : string);
    destructor Destroy;override;

    property Name : string read fUnitName;
    property SelectedProcedures : TStringList read FSelectedProcedures write FSelectedProcedures;
  end;
  TUnitSelectionList = class(TObjectList<TUnitSelection>)
  private
    procedure RaiseInvalidTagError(const anExpectedName,aFoundName : string);
    procedure RaiseMissingAttributeError(const anTagName, anAttributeName : string);

  public
    procedure LoadSelectionFile(const aFilename : string);
    procedure ApplySelections(const aUnits : TUnitList; const aOnlyCheckUnitName : boolean);
  end;

  TUnitSelectionSerializer = class
  private
    fFilename : string;
    fXmlDocument : IXMLDocument;
    fRootNode : IXMLNode;
    fUnitsNode : IXMLNode;
    fUnitNode : IXMLNode;
  public
    constructor Create(const aFilename : string);
    destructor Destroy; override;
    procedure AddUnit(const aUnitName: string);
    procedure AddProc(const aProcName: string);
    procedure Save();
  end;


implementation

uses
  gppTree,  gpParser.Procs;

{ TUnitSelection }

constructor TUnitSelection.Create(const aUnitName : string);
begin
  inherited Create();
  FUnitName := aUnitName;
  FSelectedProcedures := TStringList.Create();;
end;

destructor TUnitSelection.Destroy;
begin
  FSelectedProcedures.Free;
  inherited;
end;

{ TUnitSelectionList }

procedure TUnitSelectionList.ApplySelections(const aUnits : TUnitList; const aOnlyCheckUnitName : boolean);

  function GetSelectionOrNil(const aUnitName : string): TUnitSelection;
  var
    LSelection : TUnitSelection;
    LUnitName : string;

  begin
    result := nil;
    LUnitName := aUnitName.ToUpper();
    for LSelection in self do
    begin
      if LSelection.Name.ToUpper = LUnitName then
        exit(LSelection);
    end;
  end;

  function GetProcSelectionOrNil(const aUnit:TUnitSelection ;const aProcName : string): string;
  var
    LCurrentProcName : string;
    LProcName : string;
  begin
    result := '';
    if assigned(aUnit) then
    begin
      if aOnlyCheckUnitName then
        Exit('*');
      LProcName := aProcName.ToUpper();
      for LCurrentProcName in aUnit.SelectedProcedures do
      begin
        if LCurrentProcName.ToUpper = LProcName then
          exit(LCurrentProcName);
      end;
    end;
  end;


var
  LUnitSelection : TUnitSelection;
  LProcSelection : string;
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  LProcEnumor: TRootNode<TProc>.TEnumerator;
  LAllCnt : Cardinal;
  LNone : boolean;
begin
  // update unit list selections
  LUnitEnumor := aUnits.GetEnumerator();
  while LUnitEnumor.MoveNext do
  begin
    un := LUnitEnumor.Current.Data;
    LUnitSelection := GetSelectionOrNil(un.unName);
    LAllCnt := 0;
    LNone := true;
    LProcEnumor := un.unProcs.GetEnumerator();
    while LProcEnumor.MoveNext do
    begin
      LProcSelection := '';
      if assigned(LUnitSelection)  then
        LProcSelection := GetProcSelectionOrNil(LUnitSelection,LProcEnumor.Current.Data.Name);
      LProcEnumor.Current.Data.prInstrumented := LProcSelection <> '';
      if LProcEnumor.Current.Data.prInstrumented then
      begin
        inc(LAllCnt);
        LNone := false;
      end;
    end;
    un.unAllInst := LAllCnt = un.unProcs.Count;
    un.unNoneInst := LNone;
  end;
  LUnitEnumor.Free;
end; { TProject.ApplySelections }

procedure TUnitSelectionList.RaiseInvalidTagError(const anExpectedName,aFoundName : string);
begin
  raise EReadError.Create('Error: Expected "'+anExpectedName+'", but found "'+aFoundName+'".');
end;

procedure TUnitSelectionList.RaiseMissingAttributeError(const anTagName, anAttributeName : string);
begin
  raise EReadError.Create('Error: Expected attribute "'+anAttributeName+'" for tag "'+anTagName+'".');
end;


procedure TUnitSelectionList.LoadSelectionFile(const aFilename: string);
var
  LXmlDocument : IXMLDocument;
  LUnitsNode,
  LUnitNode,
  LProcNode: IXMLNode;
  i,k,m : Integer;
  LTagName : string;
  LAttributeName : string;
  LUnitSelection : TUnitSelection;
begin
  Self.Clear;
  LXmlDocument := LoadXMLDocument(aFilename);
  for I := 0 to LXmlDocument.DocumentElement.ChildNodes.Count-1 do
  begin
    LUnitsNode := LXmlDocument.DocumentElement.ChildNodes[I];
    if LUnitsNode.LocalName <> 'Units' then
      RaiseInvalidTagError('Units',LUnitsNode.LocalName);
    for k := 0 to LUnitsNode.ChildNodes.Count-1 do
    begin
      LUnitNode := LUnitsNode.ChildNodes[k];
      LTagName := LUnitNode.LocalName;
      if LTagName <> 'Unit' then
        RaiseInvalidTagError('Unit',LTagName);
      LAttributeName := LUnitNode.Attributes['Name'];
      if LAttributeName = '' then
        RaiseMissingAttributeError('Unit','Name');
      LUnitSelection := TUnitSelection.Create(LAttributeName);
      self.Add(LUnitSelection);
      for m := 0 to LUnitNode.ChildNodes.Count-1 do
      begin
        LProcNode := LUnitNode.ChildNodes[m];
        LTagName := LProcNode.LocalName;
        if LTagName <> 'Procedure' then
          RaiseInvalidTagError('Unit',LTagName);
        LAttributeName := LProcNode.Attributes['Name'];
        if LAttributeName = '' then
          RaiseMissingAttributeError('Procedure','Name');
        LUnitSelection.SelectedProcedures.Add(LAttributeName);
      end;
    end;
  end;
end;



{ TUnitSelectionSerializer }

constructor TUnitSelectionSerializer.Create(const aFilename : string);
begin
  inherited Create();
  fFilename := aFilename;
  fXmlDocument := NewXMLDocument;
  fXmlDocument.Encoding := 'utf-8';
  fXmlDocument.Options := [doNodeAutoIndent]; // looks better in Editor ;)
  fRootNode := fXmlDocument.AddChild('ISelection');
  fUnitsNode := fRootNode.AddChild('Units');
end;

destructor TUnitSelectionSerializer.Destroy;
begin
  inherited;
end;


procedure TUnitSelectionSerializer.Save;
begin
  fXmlDocument.SaveToFile(fFilename);
end;

procedure TUnitSelectionSerializer.AddUnit(const aUnitName: string);
begin
  fUnitNode := fUnitsNode.AddChild('Unit');
  fUnitNode.Attributes['Name'] := aUnitName;
end;

procedure TUnitSelectionSerializer.AddProc(const aProcName: string);
var
  LProcNode : IXMLNode;
begin
  // evaluate instrumented prefix
  LProcNode := fUnitNode.AddChild('Procedure');
  LProcNode.Attributes['Name'] := aProcName;
end;

end.
