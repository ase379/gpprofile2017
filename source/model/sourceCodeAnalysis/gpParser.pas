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
  gpParser.BaseProject, gpParser.types, gpParser.Units, gpParser.Selections, gppMain.FrameInstrumentation.SelectionInfo;

type
  TNotifyProc = procedure(const aUnitName: String) of object;
  TNotifyInstProc = procedure(const aFullName, aUnitName: String;aParse: boolean) of object;

  TProject = class;


  TProject = class(TBaseProject)
  private
    prUnit: TUnit;
    prUnits: TGlbUnitList;
  public
    constructor Create(const aProjectName: string;const aSelectedDelphiVersion : string);
    destructor Destroy; override;
    procedure Parse(aExclUnits: String;const aConditionals: String; aNotify: TNotifyProc;
      aCommentType: TCommentType; aParseAsm: boolean;const anErrorList : TStrings);
    procedure Rescan(aExclUnits: String;const aConditionals: string;
      aCommentType: TCommentType; aParseAsm: boolean);
    procedure GetUnitList(const aInfoList: TUnitInstrumentationInfoList;const aProjectDirOnly: boolean);
    procedure GetProcList(const aUnitName: string; const aProcInfoList : TProcedureInstrumentationInfoList);
    function GetUnitPath(unitName: string): string;
    procedure InstrumentAll(Instrument, projectDirOnly: boolean);
    procedure InstrumentUnit(const aUnitName: string; const aInstrument: boolean);
    procedure InstrumentProc(const aUnitName, aProcName: string; const aInstrument: boolean);
    procedure InstrumentTUnit(anUnit: TUnit; Instrument: boolean);
    function AllInstrumented(projectDirOnly: boolean): boolean;
    function NoneInstrumented(projectDirOnly: boolean): boolean;
    function AnyInstrumented(projectDirOnly: boolean): boolean;
    procedure Instrument(aProjectDirOnly: boolean; aExclUnits: String;aNotify: TNotifyInstProc;
      aCommentType: TCommentType; aBackupFile: boolean;
      aIncFileName, aConditionals: string; aParseAsm: boolean);
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
  gpParser.Procs;

{ ========================= TProject ========================= }

constructor TProject.Create(const aProjectName: string;const aSelectedDelphiVersion : string);
begin
  inherited Create(aProjectName,aSelectedDelphiVersion);
  prUnits := TGlbUnitList.Create(self);
end;

destructor TProject.Destroy;
begin
  prUnits.Free;
  inherited;
end;

procedure TProject.Parse(aExclUnits: String;
  const aConditionals: string; aNotify: TNotifyProc;
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
  StoreExcludedUnits(aExclUnits);

  prUnits.ClearNodes;
  prUnit := self.LocateOrCreateUnit(Name, '', False) as TUnit;
  prUnit.unInProjectDir := true;
  fFullUnitName := prUnit.FullName;

  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.FullName)) then
    Assert(False);
  try
    un := prUnit;
    repeat
      DoNotify(un.Name);
      try
        un.Parse(ExtractFilePath(Name), aConditionals, False, aParseAsm);
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

procedure TProject.GetUnitList(const aInfoList: TUnitInstrumentationInfoList;
  const aProjectDirOnly: boolean);
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  lEntry : TUnitInstrumentationInfo;
begin
  aInfoList.Clear;
  with prUnits do
  begin
    LUnitEnumor := GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      un := LUnitEnumor.Current.Data;
      if un.IsValidForInstrumentation() and
        ((not aProjectDirOnly) or un.unInProjectDir) then
      begin
        lEntry := TUnitInstrumentationInfo.create();
        lEntry.UnitName := un.Name;
        lEntry.IsFullyInstrumented := un.unAllInst;
        lEntry.IsNothingInstrumented := un.unNoneInst;
        aInfoList.Add(lEntry);
      end;
    end;
    LUnitEnumor.Free;
  end;
end; { TProject.GetUnitList }


procedure TProject.GetProcList(const aUnitName: string; const aProcInfoList : TProcedureInstrumentationInfoList);
var
  un: TUnit;
  pr: TProc;
  LProcEnumor: TRootNode<TProc>.TEnumerator;
  lDotPosition : integer;
begin
  un := prUnits.Locate(aUnitName);
  if un <> nil then
  begin
    with un.unProcs do
    begin
      LProcEnumor := GetEnumerator();
      while LProcEnumor.MoveNext do
      begin
        pr := LProcEnumor.Current.Data;
        begin
          lDotPosition := Pos('.', pr.Name);
          var lEntry := TProcedureInstrumentationInfo.create();
          if lDotPosition > 0 then
          begin
            lEntry.ClassName := Copy(pr.Name, 1, lDotPosition - 1);
            lEntry.ClassMethodName := Copy(pr.Name, lDotPosition+1, Length(pr.Name));
          end;
          lEntry.ProcedureName := pr.Name;
          lEntry.IsInstrumentedOrCheckedForInstrumentation := pr.prInstrumented;
          aProcInfoList.Add(lEntry);
        end;
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
      if un.IsValidForInstrumentation then
        if (not projectDirOnly) or un.unInProjectDir then
          InstrumentTUnit(un, Instrument);
    end;
    LUnitEnumor.Free;
  end;
end; { TProject.InstrumentAll }

procedure TProject.InstrumentUnit(const aUnitName: string; const aInstrument: boolean);
var
  lUnit: TUnit;
begin
  lUnit := prUnits.Locate(aUnitName);
  if assigned(lUnit) then
    InstrumentTUnit(lUnit, aInstrument);
end; { TProject.InstrumentUnit }

procedure TProject.InstrumentProc(const aUnitName, aProcName: string; const aInstrument: boolean);
var
  lUnit: TUnit;
  lProc: TProc;
begin
  lUnit := prUnits.Locate(aUnitName);
  if not assigned(lUnit) then
    raise Exception.Create('Trying to instrument unexistent unit!')
  else
  begin
    lProc := lUnit.LocateProc(aProcName);
    if not assigned(lProc) then
      raise Exception.Create('Trying to instrument unexistend procedure!')
    else
    begin
      lProc.prInstrumented := aInstrument;
      lUnit.CheckInstrumentedProcs;
    end;
  end;
end; { TProject.InstrumentProc }

function TProject.AllInstrumented(projectDirOnly: boolean): boolean;
begin
  Result := prUnits.AreAllUnitsInstrumented(projectDirOnly);
end;

procedure TProject.Instrument(aProjectDirOnly: boolean; aExclUnits: String;
  aNotify: TNotifyInstProc; aCommentType: TCommentType;
  aBackupFile: boolean; aIncFileName, aConditionals: string; aParseAsm: boolean);

  procedure DoNotify(const aFullname, aUnitName: string; const aParse : Boolean);
  begin
    if assigned(aNotify) then
      aNotify(aFullname,aUnitName,aParse);
  end;

var
  vOldCurDir: string;
  LUnit: TUnit;
  LProcIdTable: TIDTable;
  LIsAnyUnitInProjectInstrumented : Boolean;
  LIsAnyProcOfUnitInstrumented: boolean;
  LHasBeenReparsed : Boolean;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  LOldProcs : TProcList;
begin
  PrepareComments(aCommentType);
  StoreExcludedUnits(aExclUnits);

    LProcIdTable := TIDTable.Create;
    try
      vOldCurDir := GetCurrentDir;
      if not SetCurrentDir(ExtractFileDir(prUnit.FullName)) then
        Assert(False);
      try
        with prUnits do
        begin
          LIsAnyUnitInProjectInstrumented := False;
          LUnitEnumor := GetEnumerator();
          while LUnitEnumor.MoveNext do
          begin
            LUnit := LUnitEnumor.Current.Data;

            LHasBeenReparsed := LUnit.NeedsToBeReparsed();
            if LUnit.NeedsToBeReparsed() then
            begin
              LOldProcs := LUnit.unProcs.Clone;
              try
                LUnit.Parse(ExtractFilePath(Name),aConditionals, true, aParseAsm);
                LUnit.unProcs.ApplyProcSelectionIfExists(LOldProcs);
              finally
                LOldProcs.Free;
              end;
            end;

            if LUnit.IsValidForInstrumentation then
            begin
              DoNotify(LUnit.FullName, LUnit.Name, False);

              LIsAnyProcOfUnitInstrumented := LUnit.AnyInstrumented;
              if LIsAnyProcOfUnitInstrumented then
                LIsAnyUnitInProjectInstrumented := true;

              if LUnit.AnyChange or LIsAnyProcOfUnitInstrumented or LHasBeenReparsed then
              begin
                  LUnit.Instrument(LProcIdTable, aBackupFile);
              end
              else
                LUnit.RegisterProcs(LProcIdTable);
            end;
          end;
          LUnitEnumor.Free;
        end;
        if not ForceDirectories(ExtractFileDir(aIncFileName)) then
          raise Exception.Create('Could not create output folder ' +
            ExtractFileDir(aIncFileName) + ': ' +
            SysErrorMessage(GetLastError));
        LProcIdTable.Dump(aIncFileName);
      finally
        SetCurrentDir(vOldCurDir);
      end;
    finally
      LProcIdTable.Free;
    end;
    if not LIsAnyUnitInProjectInstrumented then
    begin
      System.SysUtils.DeleteFile(aIncFileName);
      System.SysUtils.DeleteFile(ChangeFileExt(aIncFileName, '.gpd'));
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
    Result := un.FullName;
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

procedure TProject.ApplySelections(const aUnitSelections: TUnitSelectionList; const aOnlyCheckUnitName: boolean);
begin
  aUnitSelections.ApplySelections(prUnits,aOnlyCheckUnitName);
end;

procedure TProject.Rescan(aExclUnits: String;
  const aConditionals: string;
  aCommentType: TCommentType; aParseAsm: boolean);
var
  un: TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  vOldCurDir: string;
begin
  PrepareComments(aCommentType);
  StoreExcludedUnits(aExclUnits);

  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFilePath(prUnit.FullName)) then
    Assert(False);
  LUnitEnumor := nil;
  try
    with prUnits do
    begin
      LUnitEnumor := GetEnumerator();
      while LUnitEnumor.MoveNext do
      begin
        un := LUnitEnumor.Current.Data;
        if un.NeedsToBeReparsed() then
          un.Parse(ExtractFilePath(Name), aConditionals, true, aParseAsm);
      end;
    end;
  finally
    LUnitEnumor.Free;
    SetCurrentDir(vOldCurDir);
  end;
end;

procedure TProject.LoadInstrumentalizationSelection(const aFilename: string);
var
  LUnitSelections: TUnitSelectionList;
begin
  LUnitSelections := TUnitSelectionList.Create(true);
  try
    LUnitSelections.LoadSelectionFile(aFilename);
    ApplySelections(LUnitSelections, false);
  finally
    LUnitSelections.Free;
  end;
end;

procedure TProject.SaveInstrumentalizationSelection(const aFilename: string);
var
  LInstrumentedUnits : TUnitInstrumentationInfoList;
  LInstrumentedProcs : TProcedureInstrumentationInfoList;
  LInstrumentedProc : TProcedureInstrumentationInfo;
  LSerializer : TUnitSelectionSerializer;
begin
  LInstrumentedUnits := TUnitInstrumentationInfoList.Create();
  LInstrumentedProcs := TProcedureInstrumentationInfoList.Create();
  LSerializer := TUnitSelectionSerializer.Create(aFilename);
  try
    GetUnitList(LInstrumentedUnits,false);

    for var LInfo in LInstrumentedUnits do
    begin
      if not LInfo.IsNothingInstrumented then
      begin
        LSerializer.AddUnit(LInfo.UnitName);
        GetProcList(LInfo.UnitName,LInstrumentedProcs);
        for LInstrumentedProc in LInstrumentedProcs do
        begin
          // evaluate instrumented prefix
          if LInstrumentedProc.IsInstrumentedOrCheckedForInstrumentation then
          begin
            LSerializer.AddProc(LInstrumentedProc.ProcedureName);
          end;
        end;
      end;
    end;
    LSerializer.Save;
  finally
    LSerializer.Free;
    LInstrumentedUnits.free;
    LInstrumentedProcs.Free;
  end;

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

end.
