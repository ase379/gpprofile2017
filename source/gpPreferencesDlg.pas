{$I OPTIONS.INC}

unit gpPreferencesDlg;

interface

uses
  Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, ActnList, System.Actions, System.ImageList;

type
  
  TfrmPreferences = class(TForm)
    Panel1: TPanel;
    oxButton1: TButton;
    oxButton2: TButton;
    PagePreferences: TPageControl;
    tabExcluded: TTabSheet;
    GroupBox2: TGroupBox;
    memoExclUnits: TMemo;
    tabInstrumentation: TTabSheet;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    cbxMarker: TComboBox;
    cbxCompilerVersion: TComboBox;
    Label4: TLabel;
    lblFasterTarget: TLabel;
    lblSmallerFile: TLabel;
    tbSpeedSize: TTrackBar;
    tabAnalysis: TTabSheet;
    grpAnalysisSettings: TGroupBox;
    cbHideNotExecuted: TCheckBox;
    GroupBox4: TGroupBox;
    cbProfilingAutostart: TCheckBox;
    cbShowAllFolders: TCheckBox;
    btnInstrumentationDefaults: TButton;
    btnAnalysisDefaults: TButton;
    tabDefines: TTabSheet;
    GroupBox5: TGroupBox;
    lvDefines: TListView;
    cbStandardDefines: TCheckBox;
    cbProjectDefines: TCheckBox;
    cbConsoleDefines: TCheckBox;
    btnAddDefine: TButton;
    btnRenameDefine: TButton;
    btnDeleteDefine: TButton;
    inpDefine: TEdit;
    btnDefinesDefaults: TButton;
    btnClear: TButton;
    btnAddFromFolder: TButton;
    btnUnitsDefaults: TButton;
    cbxDelphiDefines: TComboBox;
    imgDefines: TImageList;
    btnClearUserDefines: TButton;
    ActionList1: TActionList;
    actAddDefine: TAction;
    actRenameDefine: TAction;
    actDeleteDefine: TAction;
    actClearAllDefines: TAction;
    cbDisableUserDefines: TCheckBox;
    btnClearAllDefines: TButton;
    cbInstrumentAssembler: TCheckBox;
    GroupBox7: TGroupBox;
    Label6: TLabel;
    Panel2: TPanel;
    edtPerformanceOutputFilename: TEdit;
    btnPrfPlaceholderSelection: TButton;
    cbMakeBackupOfInstrumentedFile: TCheckBox;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnAddFromFolderClick(Sender: TObject);
    procedure lblFasterTargetClick(Sender: TObject);
    procedure lblSmallerFileClick(Sender: TObject);
    procedure btnInstrumentationDefaultsClick(Sender: TObject);
    procedure btnAnalysisDefaultsClick(Sender: TObject);
    procedure btnExcludedUnitsDefaultsClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure cbxCompilerVersionChange(Sender: TObject);
    procedure cbxDelphiDefinesChange(Sender: TObject);
    procedure cbStandardDefinesClick(Sender: TObject);
    procedure cbConsoleDefinesClick(Sender: TObject);
    procedure cbProjectDefinesClick(Sender: TObject);
    procedure actAddDefineUpdate(Sender: TObject);
    procedure actRenameDefineUpdate(Sender: TObject);
    procedure actDeleteDefineUpdate(Sender: TObject);
    procedure actClearAllDefinesUpdate(Sender: TObject);
    procedure actAddDefineExecute(Sender: TObject);
    procedure actDeleteDefineExecute(Sender: TObject);
    procedure actClearAllDefinesExecute(Sender: TObject);
    procedure actRenameDefineExecute(Sender: TObject);
    procedure lvDefinesClick(Sender: TObject);
    procedure btnDefinesDefaultsClick(Sender: TObject);
    procedure cbDisableUserDefinesClick(Sender: TObject);
    procedure btnClearUserDefinesClick(Sender: TObject);
    procedure btnPrfPlaceholderSelectionClick(Sender: TObject);
  private
    fIsGlobalPreferenceDialog : boolean;
    fDefinesChanged : boolean;
    procedure AddDefine(symbol: string; tag: integer);
    procedure RemoveDefine(symbol: string);
    procedure RemoveTag(tag: integer);
    function  LocateDefine(symbol: string): integer;
    procedure ResetCheckboxes;
    procedure ChangeTags(oldTag, newTag: integer);
    function  HasTag(tag: integer): boolean;
    procedure ResetDefaults(tabIndex: integer);


  public
    procedure ReselectCompilerVersion(var selectedDelphi: string);
    procedure RebuildDefines(userDefines: string);
    function  ExtractUserDefines: string;
    function  ExtractDefines: string;
    // extracts project and user defines
    function  ExtractAllDefines: string;

    function ExecuteGlobalSettings(): boolean;
    function ExecuteProjectSettings(const aShowAll: boolean): boolean;
    property IsGlobalPreferenceDialog : boolean read fIsGlobalPreferenceDialog write fIsGlobalPreferenceDialog;
    property DefinesChanged : boolean read fDefinesChanged write fDefinesChanged;
  end;

var
  frmPreferences: TfrmPreferences;


function ResolvePrfProjectPlaceholders(const aFilenameWithPh: string): string;


implementation

uses
  gpProf.bdsVersions,
  gpProf.ProjectAccessor,
  GpString,
  gppMain,
  gpRegistry,
  gppCurrentPrefs,
  gpPrfPlaceholders,
  gpPrfPlaceholderDlg,
  gpDialogs.Tools;

{$R *.DFM}

function ResolvePrfProjectPlaceholders(const aFilenameWithPh: string): string;
var LSubstitutes : TPrfPlaceholderValueDict;
begin
  // resolve the global or saved settings...
  LSubstitutes := TPrfPlaceholderValueDict.create();
  LSubstitutes.add(ProjectFilename, TSessionData.ProjectOutputDir);
  result := TPrfPlaceholder.ReplaceProjectMacros(aFilenameWithPh, LSubstitutes);
  LSubstitutes.free;
end;


const
  DEF_DELPHI  = 0;
  DEF_CONSOLE = 1;
  DEF_PROJECT = 2;
  DEF_USER    = 3;

  TAB_INDEX_INSTRUMENTATION = 0;
  TAB_INDEX_ANALYSIS = 1;
  TAB_INDEX_EXCLUDED_UNITS = 2;
  TAB_INDEX_DEFINES = 3;

procedure TfrmPreferences.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then ModalResult := mrCancel;
end;

procedure TfrmPreferences.FormCreate(Sender: TObject);
begin
  PagePreferences.ActivePage := tabInstrumentation; // just in case
  cbDisableUserDefinesClick(Self);
end;

procedure TfrmPreferences.btnAddFromFolderClick(Sender: TObject);
var
  sl: TStringList;
begin
  sl := TStringList.Create;
  try
    sl.Sorted := true;
    sl.Assign(memoExclUnits.Lines);
    FillInUnitList(sl);
    memoExclUnits.Lines.Assign(sl);
  finally sl.Free; end;
end;

procedure TfrmPreferences.lblFasterTargetClick(Sender: TObject);
begin
  with tbSpeedSize do
    if Position > Min then Position := Position - 1;
end;

procedure TfrmPreferences.lblSmallerFileClick(Sender: TObject);
begin
  with tbSpeedSize do
    if Position < Max then Position := Position + 1;
end;

procedure TfrmPreferences.btnInstrumentationDefaultsClick(Sender: TObject);
begin
  ResetDefaults(TAB_INDEX_INSTRUMENTATION);
end;

procedure TfrmPreferences.btnAnalysisDefaultsClick(Sender: TObject);
begin
  ResetDefaults(TAB_INDEX_ANALYSIS);
end;

procedure TfrmPreferences.btnExcludedUnitsDefaultsClick(Sender: TObject);
begin
  ResetDefaults(TAB_INDEX_EXCLUDED_UNITS);
end;

procedure TfrmPreferences.btnClearClick(Sender: TObject);
begin
  memoExclUnits.Clear;
end;

procedure TfrmPreferences.cbxCompilerVersionChange(Sender: TObject);
begin
  cbxDelphiDefines.ItemIndex := cbxCompilerVersion.ItemIndex;
end;

procedure TfrmPreferences.cbxDelphiDefinesChange(Sender: TObject);
begin
  if cbxCompilerVersion.ItemIndex <> cbxDelphiDefines.ItemIndex then begin
    cbxCompilerVersion.ItemIndex := cbxDelphiDefines.ItemIndex;
    RemoveTag(DEF_DELPHI);
    cbStandardDefinesClick(Sender);
  end;
end;

procedure TfrmPreferences.cbStandardDefinesClick(Sender: TObject);
var
  LProductName : string;
begin
  if cbStandardDefines.Checked then begin
    AddDefine('WIN32',DEF_DELPHI);
    AddDefine('CPU386',DEF_DELPHI);
    LProductName := RemoveHotkeyAndDelphiPrefix(cbxDelphiDefines.Text);
    AddDefine(DelphiProductToCompilerVersion(ProductNameToProduct(LProductName)), DEF_DELPHI);
  end
  else RemoveTag(DEF_DELPHI);
  cbxDelphiDefines.Enabled := cbStandardDefines.Checked;
end;

procedure TfrmPreferences.cbConsoleDefinesClick(Sender: TObject);
begin
  if cbConsoleDefines.Checked
    then AddDefine('CONSOLE',DEF_CONSOLE)
    else RemoveTag(DEF_CONSOLE);
end;

procedure TfrmPreferences.cbProjectDefinesClick(Sender: TObject);
var
  projcond: string;
  i       : integer;
  LAccessor : TProjectAccessor;
  LConditionals : string;
  LCompilerVersion : string;
begin
  if cbProjectDefines.Checked then
  begin
    LAccessor := TProjectAccessor.Create(TSessionData.CurrentProjectName);
    try
      LCompilerVersion := cbxCompilerVersion.Items[cbxCompilerVersion.ItemIndex].Replace('Delphi', '', [rfIgnoreCase, rfReplaceAll]).Trim();
      LConditionals := LAccessor.GetProjectDefines(ProductNameToProductVersion(LCompilerVersion));
    finally
      LAccessor.Free;
    end;
    projcond := ReplaceAll(LConditionals,',',';');
    for i := 1 to NumElements(projcond,';',-1) do
      AddDefine(NthEl(projcond,i,';',-1),DEF_PROJECT);
  end
  else RemoveTag(DEF_PROJECT);
end;

procedure TfrmPreferences.AddDefine(symbol: string; tag: integer);
var
  idx: integer;
begin
  symbol := UpperCase(symbol);
  idx := LocateDefine(symbol);
  if idx >= 0 then begin
    if tag = DEF_USER
      then ChangeTags(lvDefines.Items[idx].ImageIndex,DEF_USER)
      else lvDefines.Items[idx].ImageIndex := tag;
  end
  else begin
    lvDefines.Selected := lvDefines.Items.Add;
    lvDefines.Selected.Caption := symbol;
    lvDefines.Selected.ImageIndex := tag;
  end;
end;

procedure TfrmPreferences.RemoveDefine(symbol: string);
var
  idx: integer;
begin
  idx := LocateDefine(UpperCase(symbol));
  if idx >= 0 then begin
    ChangeTags(lvDefines.Items[idx].ImageIndex,DEF_USER);
    lvDefines.Items.Delete(idx);
  end;
end;

procedure TfrmPreferences.RemoveTag(tag: integer);
var
  i: integer;
begin
  i := 0;
  while i <= lvDefines.Items.Count-1 do
    if lvDefines.Items[i].ImageIndex = tag
      then lvDefines.Items.Delete(i)
      else Inc(i);
end;

procedure TfrmPreferences.actAddDefineUpdate(Sender: TObject);
begin
  actAddDefine.Enabled := ((inpDefine.Text <> '') and
                           (LocateDefine(UpperCase(inpDefine.Text)) < 0));
end;

procedure TfrmPreferences.actRenameDefineUpdate(Sender: TObject);
begin
  actRenameDefine.Enabled := ((lvDefines.Selected <> nil) and
                              (inpDefine.Text <> '') and
                              (LocateDefine(UpperCase(inpDefine.Text)) < 0));
end;

procedure TfrmPreferences.actDeleteDefineUpdate(Sender: TObject);
begin
  actDeleteDefine.Enabled := (lvDefines.Selected <> nil);
end;

procedure TfrmPreferences.actClearAllDefinesUpdate(Sender: TObject);
begin
  actClearAllDefines.Enabled := (lvDefines.Items.Count > 0);
end;

function TfrmPreferences.LocateDefine(symbol: string): integer;
var
  i: integer;
begin
  for i := 0 to lvDefines.Items.Count-1 do
    if symbol = lvDefines.Items[i].Caption then begin
      Result := i;
      Exit;
    end;
  Result := -1;
end;

procedure TfrmPreferences.actAddDefineExecute(Sender: TObject);
begin
  AddDefine(inpDefine.Text,DEF_USER);
end;

procedure TfrmPreferences.actDeleteDefineExecute(Sender: TObject);
begin
  RemoveDefine(inpDefine.Text);
  ResetCheckboxes;
end;

procedure TfrmPreferences.actClearAllDefinesExecute(Sender: TObject);
begin
  lvDefines.Items.Clear;
  ResetCheckboxes;
end;

procedure TfrmPreferences.actRenameDefineExecute(Sender: TObject);
begin
  ChangeTags(lvDefines.Selected.imageIndex,DEF_USER);
  lvDefines.Selected.Caption := UpperCase(inpDefine.Text);
  inpDefine.Text := '';
  ResetCheckboxes;
end;

procedure TfrmPreferences.lvDefinesClick(Sender: TObject);
begin
  if assigned(lvDefines.Selected) then
    inpDefine.Text := lvDefines.Selected.Caption;
end;

procedure TfrmPreferences.ResetCheckboxes;
begin
  cbStandardDefines.Checked := HasTag(DEF_DELPHI);
  cbConsoleDefines.Checked := HasTag(DEF_CONSOLE);
  cbProjectDefines.Checked := HasTag(DEF_PROJECT);
end;

procedure TfrmPreferences.ChangeTags(oldTag, newTag: integer);
var
  i: integer;
begin
  for i := 0 to lvDefines.Items.Count-1 do
    if lvDefines.Items[i].ImageIndex = oldTag
      then lvDefines.Items[i].ImageIndex := newTag;
end;

function TfrmPreferences.HasTag(tag: integer): boolean;
var
  i: integer;
begin
  Result := false;
  for i := 0 to lvDefines.Items.Count-1 do
    if lvDefines.Items[i].ImageIndex = tag then begin
      Result := true;
      Exit;
    end;
end;

procedure TfrmPreferences.btnDefinesDefaultsClick(Sender: TObject);
begin
  ResetDefaults(TAB_INDEX_DEFINES);
end;

procedure TfrmPreferences.RebuildDefines(userDefines: string);
var
  i: integer;
begin
  lvDefines.Items.Clear;
  cbStandardDefinesClick(Self);
  cbConsoleDefinesClick(Self);
  cbProjectDefinesClick(Self);
  cbDisableUserDefinesClick(Self);
  for i := 1 to NumElements(userDefines,';',-1) do
    AddDefine(NthEl(userDefines,i,';',-1),DEF_USER);
end;

function TfrmPreferences.ExtractUserDefines: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to lvDefines.Items.Count-1 do begin
    if lvDefines.Items[i].ImageIndex = DEF_USER then begin
      if Result <> '' then Result := Result + ';';
      Result := Result + lvDefines.Items[i].Caption;
    end;
  end;                        
end;

function TfrmPreferences.ExtractDefines: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to lvDefines.Items.Count-1 do begin
    if (lvDefines.Items[i].ImageIndex <> DEF_USER) or (not cbDisableUserDefines.Checked) then begin
      if Result <> '' then Result := Result + ';';
      Result := Result + lvDefines.Items[i].Caption;
    end;
  end;
end;


function TfrmPreferences.ExtractAllDefines: string;
var
  i: integer;
begin
  Result := '';
  for i := 0 to lvDefines.Items.Count-1 do
  begin
    if (lvDefines.Items[i].ImageIndex = DEF_USER) and (cbDisableUserDefines.Checked) then
      continue;
    if Result <> '' then
      Result := Result + ';';
    Result := Result + lvDefines.Items[i].Caption;
  end;
end;

procedure TfrmPreferences.cbDisableUserDefinesClick(Sender: TObject);
var
  image: TBitmap;
begin
  image := TBitmap.Create;
  try
    if cbDisableUserDefines.Checked then
      imgDefines.GetBitmap(DEF_USER+1,image)
    else imgDefines.GetBitmap(DEF_USER+2,image);
      imgDefines.Replace(DEF_USER,Image,nil);
    finally
      image.Free;
    end;
end;

procedure TfrmPreferences.btnClearUserDefinesClick(Sender: TObject);
begin
  RemoveTag(DEF_USER);
end;


procedure TfrmPreferences.btnPrfPlaceholderSelectionClick(Sender: TObject);
begin
  with frmPreferenceMacros do
  begin
    IsGlobalPreferenceDialog := self.IsGlobalPreferenceDialog;
    if Execute then
    begin
      edtPerformanceOutputFilename.Text := edtPerformanceOutputFilename.Text + GetSelectedMacro();
      if not IsGlobalPreferenceDialog then
        edtPerformanceOutputFilename.Text := ResolvePrfProjectPlaceholders(edtPerformanceOutputFilename.Text);
    end;
  end;
end;


procedure TfrmPreferences.ReselectCompilerVersion(
  var selectedDelphi: string);
var
  pos: integer;
begin
  pos := cbxCompilerVersion.Items.IndexOf('Delphi '+selectedDelphi);
  if (pos >= 0) and (pos < cbxCompilerVersion.Items.Count)
    then begin
      cbxCompilerVersion.ItemIndex := pos;
      cbxDelphiDefines.ItemIndex   := pos;
    end
    else begin
      cbxCompilerVersion.ItemIndex := cbxCompilerVersion.Items.Count-1;
      cbxDelphiDefines.ItemIndex   := cbxCompilerVersion.Items.Count-1;
      selectedDelphi := RemoveHotkeyAndDelphiPrefix(cbxCompilerVersion.Items[cbxCompilerVersion.ItemIndex]);
    end;
end; { TfrmPreferences.ReselectCompilerVersion }


procedure TfrmPreferences.ResetDefaults(tabIndex: integer);
begin
  with frmPreferences do begin
    case tabIndex of
      TAB_INDEX_INSTRUMENTATION:
      begin
        if (TGlobalPreferences.CompilerVersion < 0) or (TGlobalPreferences.CompilerVersion >= cbxCompilerVersion.Items.Count)
          then TGlobalPreferences.CompilerVersion := cbxCompilerVersion.Items.Count-1;
        cbxCompilerVersion.ItemIndex := TGlobalPreferences.CompilerVersion;
        cbxDelphiDefines.ItemIndex   := TGlobalPreferences.CompilerVersion;
        if (TGlobalPreferences.MarkerStyle < 0) or (TGlobalPreferences.MarkerStyle >= cbxMarker.Items.Count) then TGlobalPreferences.MarkerStyle := 0;
        cbxMarker.ItemIndex := TGlobalPreferences.MarkerStyle;
        if TGlobalPreferences.SpeedSize < tbSpeedSize.Min then TGlobalPreferences.SpeedSize := tbSpeedSize.Min
        else if TGlobalPreferences.SpeedSize > tbSpeedSize.Max then TGlobalPreferences.SpeedSize := tbSpeedSize.Max;
        tbSpeedSize.Position          := TGlobalPreferences.SpeedSize;
        cbShowAllFolders.Checked      := TGlobalPreferences.ShowAllFolders;
        cbProfilingAutostart.Checked  := TGlobalPreferences.ProfilingAutostart;
        cbInstrumentAssembler.Checked := TGlobalPreferences.InstrumentAssembler;
        cbMakeBackupOfInstrumentedFile.Checked := TGlobalPreferences.MakeBackupOfInstrumentedFile;
      end; // Instrumentation
      TAB_INDEX_ANALYSIS:
      begin
        cbHideNotExecuted.Checked := TGlobalPreferences.HideNotExecuted;
        edtPerformanceOutputFilename.text := TGlobalPreferences.PrfFilenameMakro;
        if not IsGlobalPreferenceDialog then
          edtPerformanceOutputFilename.text := ResolvePrfProjectPlaceholders(edtPerformanceOutputFilename.text);

      end; // Analysis
      TAB_INDEX_EXCLUDED_UNITS:
      begin
        memoExclUnits.Text := TGlobalPreferences.ExcludedUnits;
      end; // Excluded units
      TAB_INDEX_DEFINES:
      begin
        cbStandardDefines.Checked    := TGlobalPreferences.StandardDefines;
        With TProjectAccessor.Create(TSessionData.CurrentProjectName) do
        begin
          cbConsoleDefines.Checked     := IsConsoleProject(False);
          Free;
        end;
        cbProjectDefines.Checked     := TGlobalPreferences.ProjectDefines;
        cbDisableUserDefines.Checked := TGlobalPreferences.DisableUserDefines;
        RebuildDefines(TGlobalPreferences.UserDefines);
      end; // Conditional defines
    end; // case
  end; // with
end;



function TfrmPreferences.ExecuteGlobalSettings: boolean;
begin
  result := false;
  IsGlobalPreferenceDialog := true;
  cbHideNotExecuted.Checked    := TGlobalPreferences.HideNotExecuted;
  memoExclUnits.Text           := TGlobalPreferences.ExcludedUnits;
  Caption                      := 'GpProfile - Preferences';
  if (TGlobalPreferences.MarkerStyle < 0) or (TGlobalPreferences.MarkerStyle >= cbxMarker.Items.Count) then
    TGlobalPreferences.MarkerStyle := 0;
  cbxMarker.ItemIndex := TGlobalPreferences.MarkerStyle;
  if (TGlobalPreferences.CompilerVersion < 0) or (TGlobalPreferences.CompilerVersion >= cbxCompilerVersion.Items.Count)
    then TGlobalPreferences.CompilerVersion := cbxCompilerVersion.Items.Count-1;
  cbxCompilerVersion.ItemIndex := TGlobalPreferences.CompilerVersion;
  cbxDelphiDefines.ItemIndex   := TGlobalPreferences.CompilerVersion;
  if TGlobalPreferences.SpeedSize < tbSpeedSize.Min then TGlobalPreferences.SpeedSize := tbSpeedSize.Min
  else if TGlobalPreferences.SpeedSize > tbSpeedSize.Max then TGlobalPreferences.SpeedSize := tbSpeedSize.Max;
  cbShowAllFolders.Checked     := TGlobalPreferences.ShowAllFolders;
  edtPerformanceOutputFilename.text := TGlobalPreferences.PrfFilenameMakro;
  cbStandardDefines.Checked    := TGlobalPreferences.StandardDefines;
  cbDisableUserDefines.Checked := TGlobalPreferences.DisableUserDefines;
  cbConsoleDefines.Enabled     := false;
  cbProjectDefines.Checked     := TGlobalPreferences.ProjectDefines;
  RebuildDefines(TGlobalPreferences.UserDefines);
  cbProfilingAutostart.Checked  := TGlobalPreferences.ProfilingAutostart;
  cbInstrumentAssembler.Checked := TGlobalPreferences.InstrumentAssembler;
  cbMakeBackupOfInstrumentedFile.Checked := TGlobalPreferences.MakeBackupOfInstrumentedFile;
  tbSpeedSize.Position := TGlobalPreferences.SpeedSize;
  tabInstrumentation.Enabled         := true;
  tabInstrumentation.TabVisible      := true;
  tabAnalysis.Enabled                := true;
  tabAnalysis.TabVisible             := true;
  tabExcluded.Enabled                := true;
  tabExcluded.TabVisible             := true;
  tabDefines.Enabled                 := true;
  tabDefines.TabVisible              := true;
  btnInstrumentationDefaults.Visible := false;
  btnAnalysisDefaults.Visible        := false;
  btnUnitsDefaults.Visible           := false;
  btnDefinesDefaults.Visible         := false;
  Left := frmMain.Left+((frmMain.Width-Width) div 2);
  Top := frmMain.Top+((frmMain.Height-Height) div 2);
  if ShowModal = mrOK then begin
    TGlobalPreferences.MarkerStyle        := cbxMarker.ItemIndex;
    TGlobalPreferences.CompilerVersion    := cbxCompilerVersion.ItemIndex;
    TGlobalPreferences.HideNotExecuted    := cbHideNotExecuted.Checked;
    TGlobalPreferences.ExcludedUnits      := memoExclUnits.Text;
    TGlobalPreferences.SpeedSize          := tbSpeedSize.Position;
    TGlobalPreferences.ShowAllFolders     := cbShowAllFolders.Checked;
    TGlobalPreferences.PrfFilenameMakro   := edtPerformanceOutputFilename.text;

    TGlobalPreferences.StandardDefines    := cbStandardDefines.Checked;
    TGlobalPreferences.DisableUserDefines := cbDisableUserDefines.Checked;
    TGlobalPreferences.ProjectDefines     := cbProjectDefines.Checked;
    TGlobalPreferences.UserDefines        := ExtractUserDefines;
    TGlobalPreferences.ProfilingAutostart := cbProfilingAutostart.Checked;
    TGlobalPreferences.InstrumentAssembler:= cbInstrumentAssembler.Checked;
    TGlobalPreferences.MakeBackupOfInstrumentedFile := cbMakeBackupOfInstrumentedFile.Checked;
    TGlobalPreferences.SavePreferences;
    TSessionData.selectedDelphi := RemoveHotkeyAndDelphiPrefix(cbxCompilerVersion.Items[TGlobalPreferences.CompilerVersion]);
  end;
end;

function TfrmPreferences.ExecuteProjectSettings(const aShowAll: boolean): boolean;
var
  projMarker   : integer;
  projSpeedSize: integer;
  oldDefines   : string;
begin
  with frmPreferences do begin
    IsGlobalPreferenceDialog := false;
    Caption := 'GpProfile - Instrumentation options for '+TSessionData.CurrentProjectName;
    memoExclUnits.Text := TGlobalPreferences.GetProjectPref('ExcludedUnits',TGlobalPreferences.ExcludedUnits);
    projMarker := TGlobalPreferences.GetProjectPref('MarkerStyle',TGlobalPreferences.MarkerStyle);
    if (projMarker >= 0) and (projMarker < cbxMarker.Items.Count)
      then cbxMarker.ItemIndex := projMarker
      else cbxMarker.ItemIndex := 0;
    projSpeedSize := TGlobalPreferences.GetProjectPref('SpeedSize',TGlobalPreferences.SpeedSize);
    if projSpeedSize < tbSpeedSize.Min then projSpeedSize := tbSpeedSize.Min
    else if projSpeedSize > tbSpeedSize.Max then projSpeedSize := tbSpeedSize.Max;
    tbSpeedSize.Position := projSpeedSize;
    ReselectCompilerVersion(TSessionData.selectedDelphi);
    cbShowAllFolders.Checked           := aShowAll;
    edtPerformanceOutputFilename.text  := TGlobalPreferences.GetProjectPref('PrfFilenameMakro',TGlobalPreferences.PrfFilenameMakro);
    edtPerformanceOutputFilename.text := ResolvePrfProjectPlaceholders(edtPerformanceOutputFilename.text);
  
    cbProfilingAutostart.Checked       := TGlobalPreferences.GetProjectPref('ProfilingAutostart',TGlobalPreferences.ProfilingAutostart);
    cbInstrumentAssembler.Checked      := TGlobalPreferences.GetProjectPref('InstrumentAssembler',TGlobalPreferences.InstrumentAssembler);
    cbMakeBackupOfInstrumentedFile.Checked := TGlobalPreferences.GetProjectPref('MakeBackupOfInstrumentedFile',TGlobalPreferences.MakeBackupOfInstrumentedFile);
    cbConsoleDefines.Enabled           := true;
    RebuildDefines(TGlobalPreferences.GetProjectPref('UserDefines',TGlobalPreferences.UserDefines));
    tabInstrumentation.Enabled         := true;
    tabInstrumentation.TabVisible      := true;
    tabAnalysis.Enabled                := true;
    tabAnalysis.TabVisible             := true;
    grpAnalysisSettings.Enabled        := false;
    grpAnalysisSettings.Visible        := false;
    tabExcluded.Enabled                := true;
    tabExcluded.TabVisible             := true;
    tabDefines.Enabled                 := true;
    tabDefines.TabVisible              := true;
    btnInstrumentationDefaults.Visible := true;
    btnAnalysisDefaults.Visible        := true;
    btnUnitsDefaults.Visible           := true;
    btnDefinesDefaults.Visible         := true;
    Left := frmMain.Left+((frmMain.Width-Width) div 2);
    Top := frmMain.Top+((frmMain.Height-Height) div 2);
    oldDefines := ExtractDefines;
    result := ShowModal = mrOK; 
    if result then 
    begin
      TGlobalPreferences.SetProjectPref('MarkerStyle',cbxMarker.ItemIndex);
      TGlobalPreferences.SetProjectPref('SpeedSize',tbSpeedSize.Position);
      TGlobalPreferences.SetProjectPref('ShowAllFolders',cbShowAllFolders.Checked);
      TGlobalPreferences.SetProjectPref('PrfFilenameMakro',edtPerformanceOutputFilename.text);
      TGlobalPreferences.SetProjectPref('StandardDefines',cbStandardDefines.Checked);
      TGlobalPreferences.SetProjectPref('DisableUserDefines',cbDisableUserDefines.Checked);
      TGlobalPreferences.SetProjectPref('ConsoleDefines',cbConsoleDefines.Checked);
      TGlobalPreferences.SetProjectPref('ProjectDefines',cbProjectDefines.Checked);
      TGlobalPreferences.SetProjectPref('UserDefines',ExtractUserDefines);
      TGlobalPreferences.SetProjectPref('ProfilingAutostart',cbProfilingAutostart.Checked);
      TGlobalPreferences.SetProjectPref('InstrumentAssembler',cbInstrumentAssembler.Checked);
      TGlobalPreferences.SetProjectPref('MakeBackupOfInstrumentedFile',cbMakeBackupOfInstrumentedFile.Checked);
      TSessionData.selectedDelphi := RemoveHotkeyAndDelphiPrefix(cbxCompilerVersion.Items[cbxCompilerVersion.ItemIndex]);
      if memoExclUnits.Text = TGlobalPreferences.ExcludedUnits then
        TGlobalPreferences.DelProjectPref('ExcludedUnits')
      else
        TGlobalPreferences.SetProjectPref('ExcludedUnits',memoExclUnits.Text);
      fDefinesChanged := oldDefines <> ExtractDefines;
    end;
  end;
end;

end.
