{$I OPTIONS.INC}
unit gpParser;

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  gppIDT,
  Dialogs,
  gppTree,
  gpFileEdit, gpParser.BaseProject, gpParser.types, gpParser.Units;

type
  TNotifyProc = procedure(const aUnitName: String) of object;
  TNotifyInstProc = procedure(const aFullName, aUnitName: String;aParse: boolean) of object;

  TProject = class;

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
  TUnitSelectionList = TObjectList<TUnitSelection>;

  TProject = class(TBaseProject)
  private
    prName: string;
    prUnit: TUnit;
    prUnits: TGlbUnitList;
  public
    constructor Create(projName: string);
    destructor Destroy; override;
    procedure Parse(aExclUnits: String;const aSearchPath, aConditionals: String; aNotify: TNotifyProc;
      aCommentType: TCommentType; aParseAsm: boolean;const anErrorList : TStrings);
    procedure Rescan(aExclUnits: String;const aSearchPath, aConditionals: string;
      aCommentType: TCommentType; aIgnoreFileDate: boolean; aParseAsm: boolean);
    property Name: string read prName;
    procedure GetUnitList(var aSL: TStringList;const aProjectDirOnly, aGetInstrumented: boolean);
    procedure GetProcList(unitName: string; s: TStringList;getInstrumented: boolean);
    function GetUnitPath(unitName: string): string;
    procedure InstrumentAll(Instrument, projectDirOnly: boolean);
    procedure InstrumentUnit(unitName: string; Instrument: boolean);
    procedure InstrumentProc(unitName, procName: string; Instrument: boolean);
    procedure InstrumentTUnit(anUnit: TUnit; Instrument: boolean);
    function AllInstrumented(projectDirOnly: boolean): boolean;
    function NoneInstrumented(projectDirOnly: boolean): boolean;
    function AnyInstrumented(projectDirOnly: boolean): boolean;
    procedure Instrument(aProjectDirOnly: boolean; aNotify: TNotifyInstProc;
      aCommentType: TCommentType; aKeepDate, aBackupFile: boolean;
      aIncFileName, aConditionals, aSearchPath: string; aParseAsm: boolean);
    function GetFirstLine(unitName, procName: string): Integer;
    function AnyChange(projectDirOnly: boolean): boolean;
    function LocateUnit(const aUnitName: string): TUnit;
    function IsMissingUnit(const aUnitName : string): Boolean;

    procedure LoadInstrumentalizationSelection(const aFilename : string);
    procedure SaveInstrumentalizationSelection(const aFilename : string);
    procedure ApplySelections(const aUnitSelections: TUnitSelectionList; const aOnlyCheckUnitName : boolean);

    function LocateOrCreateUnit(const unitName, unitLocation: string;const excluded: boolean): TBaseUnit; override;
  end;

implementation

uses
  System.AnsiStrings, Winapi.Windows,
  GpIFF, GpString, gppCommon, gppCurrentPrefs,
  Xml.XMLIntf, Xml.XMLDoc,
  gpParser.Procs;

{ ========================= TProject ========================= }

constructor TProject.Create(projName: string);
begin
  inherited Create();
  prUnits := TGlbUnitList.Create();
  prName := projName;
  prUnit := nil;
end; { TProject.Create }

destructor TProject.Destroy;
begin
  prUnits.Free;
end; { TProject.Destroy }

procedure TProject.Parse(aExclUnits: String;
  const aSearchPath, aConditionals: string; aNotify: TNotifyProc;
  aCommentType: TCommentType; aParseAsm: boolean; const anErrorList : TStrings);

  procedure DoNotify(const aUnitName: string);
  begin
    if assigned(aNotify) then
      aNotify(aUnitName)
  end;

  procedure DetermineNextUnitToBeParsed(var un: TUnit);
  var
    LUnitEnumor: TRootNode<TUnit>.TEnumerator;
    u1: TUnit;
  begin
    un := nil;
    LUnitEnumor := prUnits.GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      u1 := LUnitEnumor.Current.Data;
      if not(u1.unParsed or u1.unExcluded) then
      begin
        un := u1;
        Break;
      end;
    end;
    LUnitEnumor.Free;
  end;

var
  un: TUnit;
  vOldCurDir: string;
begin
  PrepareComments(aCommentType);
  if Last(aExclUnits, 2) <> #13#10 then
    aExclUnits := aExclUnits + #13#10;
  if First(aExclUnits, 2) <> #13#10 then
    aExclUnits := #13#10 + aExclUnits;
  prUnits.ClearNodes;
  prUnit := self.LocateOrCreateUnit(prName, '', False) as TUnit;
  prUnit.unInProjectDir := true;
  fFullUnitName := prUnit.unFullName;

  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.unFullName)) then
    Assert(False);
  try
    un := prUnit;
    repeat
      DoNotify(un.unName);
      try
        un.Parse(self, aExclUnits, aSearchPath, ExtractFilePath(prName),
          aConditionals, False, aParseAsm);
      except
        on e: EUnitInSearchPathNotFoundError do
        begin
          un.unParsed := true;
          anErrorList.Add(E.Message);
        end;
        on E: Exception do
          anErrorList.Add(E.Message);
      end;
      DetermineNextUnitToBeParsed(un);
    until (un = nil);
  finally
    SetCurrentDir(vOldCurDir);
  end;
end; { TProject.Parse }

procedure TProject.GetUnitList(var aSL: TStringList;
  const aProjectDirOnly, aGetInstrumented: boolean);
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  s: String;
begin
  aSL.Clear;
  with prUnits do
  begin
    LUnitEnumor := GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) and
        ((not aProjectDirOnly) or un.unInProjectDir) then
      begin
        s := un.unName;

        if aGetInstrumented then
          // Add 2 char flags to indicate, whether unit is fully instrumented or nothing is instrumented
          s := s + IntToStr(Ord(un.unAllInst)) + IntToStr(Ord(un.unNoneInst));

        aSL.Add(s);
      end;
    end;
    LUnitEnumor.Free;
  end;
end; { TProject.GetUnitList }

procedure TProject.GetProcList(unitName: string; s: TStringList;
  getInstrumented: boolean);
var
  un: TUnit;
  pr: TProc;
  LProcEnumor: TRootNode<TProc>.TEnumerator;
begin
  s.Clear;
  un := prUnits.Locate(unitName);
  if un <> nil then
  begin
    with un.unProcs do
    begin
      LProcEnumor := GetEnumerator();
      while LProcEnumor.MoveNext do
      begin
        pr := LProcEnumor.Current.Data;
        if getInstrumented then
          s.Add(pr.Name + IntToStr(Ord(pr.prInstrumented)))
        else
          s.Add(pr.Name);
      end;
    end;
    LProcEnumor.Free;
  end;
end; { TProject.GetProcList }

procedure TProject.InstrumentTUnit(anUnit: TUnit; Instrument: boolean);
begin
  anUnit.unAllInst := Instrument;
  anUnit.unNoneInst := not Instrument;
  anUnit.unProcs.SetAllInstrumented(Instrument)
end; { TProject.InstrumentTUnit }

procedure TProject.InstrumentAll(Instrument, projectDirOnly: boolean);
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  with prUnits do
  begin
    LUnitEnumor := GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if (not un.unExcluded) and (un.unProcs.Count > 0) then
        if (not projectDirOnly) or un.unInProjectDir then
          InstrumentTUnit(un, Instrument);
    end;
    LUnitEnumor.Free;
  end;
end; { TProject.InstrumentAll }

procedure TProject.InstrumentUnit(unitName: string; Instrument: boolean);
var
  un: TUnit;
begin
  un := prUnits.Locate(unitName);
  if un <> nil then
    InstrumentTUnit(un, Instrument);
end; { TProject.InstrumentUnit }

procedure TProject.InstrumentProc(unitName, procName: string;
  Instrument: boolean);
var
  un: TUnit;
  pr: TProc;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    raise Exception.Create('Trying to instrument unexistent unit!')
  else
  begin
    pr := un.LocateProc(procName);
    if pr = nil then
      raise Exception.Create('Trying to instrument unexistend procedure!')
    else
    begin
      pr.prInstrumented := Instrument;
      un.CheckInstrumentedProcs;
    end;
  end;
end; { TProject.InstrumentProc }

function TProject.AllInstrumented(projectDirOnly: boolean): boolean;
begin
  Result := prUnits.AreAllUnitsInstrumented(projectDirOnly);
end;

procedure TProject.Instrument(aProjectDirOnly: boolean;
  aNotify: TNotifyInstProc; aCommentType: TCommentType;
  aKeepDate, aBackupFile: boolean; aIncFileName, aConditionals,
  aSearchPath: string; aParseAsm: boolean);

  procedure DoNotify(const aFullname, aUnitName: string; const aParse : Boolean);
  begin
    if assigned(aNotify) then
      aNotify(aFullname,aUnitName,aParse);
  end;

var
  vOldCurDir: string;
  un: TUnit;
  idt: TIDTable;
  Rescan: TList;
  i: Integer;
  unAny: boolean;
  anyInst: boolean;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
begin
  PrepareComments(aCommentType);
  Rescan := TList.Create;
  try
    idt := TIDTable.Create;
    try
      vOldCurDir := GetCurrentDir;
      if not SetCurrentDir(ExtractFileDir(prUnit.unFullName)) then
        Assert(False);
      try
        with prUnits do
        begin
          anyInst := False;
          LUnitEnumor := GetEnumerator();
          while LUnitEnumor.MoveNext do
          begin
            un := LUnitEnumor.Current.Data;
            if (not un.unExcluded) and (un.unProcs.Count > 0) then
            begin
              DoNotify(un.unFullName, un.unName, False);

              unAny := un.AnyInstrumented;
              if unAny then
                anyInst := true;

              if un.AnyChange or unAny then
              begin
                un.Instrument(self, idt, aKeepDate, aBackupFile);
                Rescan.Add(un);
              end
              else
                un.ConstructNames(idt);
            end;
          end;
          LUnitEnumor.Free;
        end;
        if not ForceDirectories(ExtractFileDir(aIncFileName)) then
          raise Exception.Create('Could not create output folder ' +
            ExtractFileDir(aIncFileName) + ': ' +
            SysErrorMessage(GetLastError));
        idt.Dump(aIncFileName);
      finally
        SetCurrentDir(vOldCurDir);
      end;
    finally
      idt.Free;
    end;
    if not anyInst then
    begin
      System.SysUtils.DeleteFile(aIncFileName);
      System.SysUtils.DeleteFile(ChangeFileExt(aIncFileName, '.gpd'));
    end;
    for i := 0 to Rescan.Count - 1 do
    begin
      DoNotify(TUnit(Rescan[i]).unFullName, TUnit(Rescan[i]).unName, true);
      TUnit(Rescan[i]).Parse(self, '', aSearchPath, ExtractFilePath(prName),
        aConditionals, true, aParseAsm);
    end;
  finally
    Rescan.Free;
  end;
end; { TProject.Instrument }

function TProject.NoneInstrumented(projectDirOnly: boolean): boolean;
begin
  result := prUnits.IsNoUnitInstrumented(projectDirOnly)
end;

function TProject.GetUnitPath(unitName: string): string;
var
  un: TUnit;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    raise Exception.Create('Could not get filename for unit "'+unitName+'".')
  else
    Result := un.unFullName;
end; { TProject.GetUnitPath }

function TProject.GetFirstLine(unitName, procName: string): Integer;
var
  un: TUnit;
  pr: TProc;
begin
  un := prUnits.Locate(unitName);
  if un = nil then
    Result := -1
  else
  begin
    pr := un.LocateProc(procName);
    if pr = nil then
      Result := -1
    else
      Result := pr.prHeaderLineNum;
  end;
end; { TProject.GetFirstLine }

function TProject.AnyInstrumented(projectDirOnly: boolean): boolean;
begin
  Result := prUnits.IsAnyUnitInstrumented(projectDirOnly);
end;

procedure TProject.Rescan(aExclUnits: String;
  const aSearchPath, aConditionals: string;
  aCommentType: TCommentType; aIgnoreFileDate: boolean; aParseAsm: boolean);
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  vOldCurDir: string;
begin
  PrepareComments(aCommentType);
  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.unFullName)) then
    Assert(False);
  try
    if Last(aExclUnits, 2) <> #13#10 then
      aExclUnits := aExclUnits + #13#10;
    with prUnits do
    begin
      LUnitEnumor := GetEnumerator();
      while LUnitEnumor.MoveNext do
      begin
        un := LUnitEnumor.Current.Data;
        if (not un.unExcluded) and (un.unProcs.Count > 0) and
          (aIgnoreFileDate or (un.DidFileTimestampChange())) then
          un.Parse(self, aExclUnits, aSearchPath, ExtractFilePath(prName),
            aConditionals, true, aParseAsm);
      end;
    end;
  finally
    SetCurrentDir(vOldCurDir);
  end;
end;

procedure TProject.LoadInstrumentalizationSelection(const aFilename: string);

  procedure RaiseInvalidTagError(const anExpectedName,aFoundName : string);
  begin
    raise EReadError.Create('Error: Expected "'+anExpectedName+'", but found "'+aFoundName+'".');
  end;

  procedure RaiseMissingAttributeError(const anTagName, anAttributeName : string);
  begin
    raise EReadError.Create('Error: Expected attribute "'+anAttributeName+'" for tag "'+anTagName+'".');
  end;
var
  LUnitSelections: TUnitSelectionList;
  LXmlDocument : IXMLDocument;
  LUnitsNode,
  LUnitNode,
  LProcNode: IXMLNode;
  i,k,m : Integer;
  LTagName : string;
  LAttributeName : string;
  LUnitSelection : TUnitSelection;
begin
  LUnitSelections := TUnitSelectionList.Create(true);
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
      LUnitSelections.Add(LUnitSelection);
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
  ApplySelections(LUnitSelections, false);
  LUnitSelections.Free;
end;


procedure TProject.ApplySelections(const aUnitSelections: TUnitSelectionList; const aOnlyCheckUnitName : boolean);

  function GetSelectionOrNil(const aUnitName : string): TUnitSelection;
  var
    LSelection : TUnitSelection;
    LUnitName : string;

  begin
    result := nil;
    LUnitName := aUnitName.ToUpper();
    for LSelection in aUnitSelections do
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
  with prUnits do
  begin
    LUnitEnumor := GetEnumerator();
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
  end;
end; { TProject.ApplySelections }


procedure TProject.SaveInstrumentalizationSelection(const aFilename: string);
var
  LInstrumentedUnits : TStringList;
  LInstrumentedProcs : TStringList;
  LXmlDocument : IXMLDocument;
  RootNode,
  LUnitsNode,
  LUnitNode,
  LProcNode : IXMLNode;
  LUnitName,LUnitNameWithInstr : string;
  LProcName,LProcNameWithInstr : string;
  LNoUnits : boolean;
begin
  LXmlDocument := NewXMLDocument;
  LXmlDocument.Encoding := 'utf-8';
  LXmlDocument.Options := [doNodeAutoIndent]; // looks better in Editor ;)
  RootNode := LXmlDocument.AddChild('ISelection');
  LInstrumentedUnits := TStringList.Create();
  LInstrumentedProcs := TStringList.Create();
  GetUnitList(LInstrumentedUnits,false, true);
  LUnitsNode := RootNode.AddChild('Units');
  for LUnitNameWithInstr in LInstrumentedUnits do
  begin
    LUnitName := Copy(LUnitNameWithInstr,1,Length(LUnitNameWithInstr)-2);
    LNoUnits := (LUnitNameWithInstr[Length(LUnitNameWithInstr)] = '1');
    if not LNoUnits then
    begin
      LUnitNode := LUnitsNode.AddChild('Unit');
      LUnitNode.Attributes['Name'] := LUnitName;
      GetProcList(LUnitName,LInstrumentedProcs,true);
      for LProcNameWithInstr in LInstrumentedProcs do
      begin
        // evaluate instrumented prefix
        if LProcNameWithInstr.EndsWith('1') then
        begin
          LProcName := Copy(LProcNameWithInstr,1,Length(LProcNameWithInstr)-1);
          LProcNode := LUnitNode.AddChild('Procedure');
          LProcNode.Attributes['Name'] := LProcName;
        end;
      end;
    end;
  end;
  LInstrumentedUnits.free;
  LXmlDocument.SaveToFile(aFilename);
end;

{ TProject.Rescan }

function TProject.AnyChange(projectDirOnly: boolean): boolean;
begin
  Result := prUnits.DidAnyTimestampChange(projectDirOnly);
end;

function TProject.LocateOrCreateUnit(const unitName, unitLocation: string; const excluded: boolean): TBaseUnit;
begin
  Result := prUnits.LocateCreate(unitName, unitLocation, excluded);
end;

function TProject.LocateUnit(const aUnitName: string): TUnit;
begin
  Result := prUnits.Locate(aUnitName)
end;

function TProject.IsMissingUnit(const aUnitName : string): Boolean;
begin
  result := prMissingUnitNames.ContainsKey(aUnitName);
end;

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

end.
