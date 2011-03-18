{$I OPTIONS.INC}

unit gppPreferences;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, JvBrowseFolder, Menus, ImgList, ActnList;

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
    GroupBox3: TGroupBox;
    cbHideNotExecuted: TCheckBox;
    GroupBox4: TGroupBox;
    cbProfilingAutostart: TCheckBox;
    cbShowAllFolders: TCheckBox;
    btnInstrumentationDefaults: TButton;
    btnAnalysisDefaults: TButton;
    cbKeepFileDate: TCheckBox;
    cbUseFileDate: TCheckBox;
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
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure btnAddFromFolderClick(Sender: TObject);
    procedure lblFasterTargetClick(Sender: TObject);
    procedure lblSmallerFileClick(Sender: TObject);
    procedure btnInstrumentationDefaultsClick(Sender: TObject);
    procedure btnAnalysisDefaultsClick(Sender: TObject);
    procedure btnExcludedUnitsDefaultsClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure cbKeepFileDateClick(Sender: TObject);
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
  private
    procedure AddDefine(symbol: string; tag: integer);
    procedure RemoveDefine(symbol: string);
    procedure RemoveTag(tag: integer);
    function  LocateDefine(symbol: string): integer;
    procedure ResetCheckboxes;
    procedure ChangeTags(oldTag, newTag: integer);
    function  HasTag(tag: integer): boolean;
  public
    procedure ReselectCompilerVersion(var selectedDelphi: string);
    procedure RebuildDefines(userDefines: string);
    function  ExtractUserDefines: string;
    function  ExtractDefines: string;
  end;

var
  frmPreferences: TfrmPreferences;

implementation

uses
  GpString,
  gppComCtl,
  gppMain;

{$R *.DFM}

const
  DEF_DELPHI  = 0;
  DEF_CONSOLE = 1;
  DEF_PROJECT = 2;
  DEF_USER    = 3;

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
  vSelDir: String;

  procedure Iterate(mask: string);
  var
    S  : TSearchRec;
    res: integer;

    procedure AddUnit(unitName: string);
    begin
      if sl.IndexOf(unitName) < 0 then sl.Add(unitName);
    end; { AddUnit }

  begin
    res := FindFirst(MakeBackslash(vSelDir)+mask,0,S);
    if res = 0 then begin
      repeat
        AddUnit(UpperCase(FirstEl(S.Name,'.',-1)));
        res := FindNext(S);
      until res <> 0;
      FindClose(S);
    end;
  end; { Iterate }

begin
  sl := TStringList.Create;
  try
    sl.Sorted := true;
    sl.Assign(memoExclUnits.Lines);

    vSelDir := '';
    if BrowseForFolder('Choose folder', True, vSelDir) then
    begin
      Iterate('*.pas');
      Iterate('*.dcu');
    end;
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
  frmMain.ResetDefaults(0);
end;

procedure TfrmPreferences.btnAnalysisDefaultsClick(Sender: TObject);
begin
  frmMain.ResetDefaults(1);
end;

procedure TfrmPreferences.btnExcludedUnitsDefaultsClick(Sender: TObject);
begin
  frmMain.ResetDefaults(2);
end;

procedure TfrmPreferences.btnClearClick(Sender: TObject);
begin
  memoExclUnits.Clear;
end;

procedure TfrmPreferences.cbKeepFileDateClick(Sender: TObject);
begin
  if cbKeepFileDate.Checked then begin
    cbUseFileDate.Checked := false;
    cbUseFileDate.Enabled := false;
  end
  else begin
    cbUseFileDate.Checked := true;
    cbUseFileDate.Enabled := true;
  end;
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
begin
  if cbStandardDefines.Checked then begin
    AddDefine('WIN32',DEF_DELPHI);
    AddDefine('CPU386',DEF_DELPHI);
    if Pos('2',cbxDelphiDefines.Text) > 0 then AddDefine('VER90',DEF_DELPHI)
    else if Pos('3',cbxDelphiDefines.Text) > 0 then AddDefine('VER100',DEF_DELPHI)
    else if Pos('4',cbxDelphiDefines.Text) > 0 then AddDefine('VER120',DEF_DELPHI);
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
begin
  if cbProjectDefines.Checked then begin
    projcond := ReplaceAll(frmMain.GetDOFSetting('Directories','Conditionals',''),',',';');
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
  frmMain.ResetDefaults(3);
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

procedure TfrmPreferences.cbDisableUserDefinesClick(Sender: TObject);
var
  image: TBitmap;
begin
  try
    image := TBitmap.Create;
    try
      if cbDisableUserDefines.Checked
        then imgDefines.GetBitmap(DEF_USER+1,image)
        else imgDefines.GetBitmap(DEF_USER+2,image);
      imgDefines.Replace(DEF_USER,Image,nil);
    finally image.Free; end;
  except
    on E:EInvalidOperation do begin
      if not frmMain.GetPref('System','ShownComCtl32',false) then begin
        Application.CreateForm(TfrmComCtl, frmComCtl);
        frmComCtl.ShowModal;
        frmComCtl.Free;
        frmMain.SetPref('System','ShownComCtl32',true);
      end;
    end;
  end;
end;

procedure TfrmPreferences.btnClearUserDefinesClick(Sender: TObject);
begin
  RemoveTag(DEF_USER);
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
      selectedDelphi := ButFirst(cbxCompilerVersion.Items[cbxCompilerVersion.ItemIndex],Length('Delphi '));
    end;
end; { TfrmPreferences.ReselectCompilerVersion }

end.
