{$I OPTIONS.INC}

unit gppmain;

interface

uses
  Registry, Messages, Classes, Forms, Windows, SysUtils, Graphics, Controls,
  Dialogs, StdCtrls, Menus, ComCtrls, GpParser, ExtCtrls, gpMRU,
  ActnList, ImgList, Buttons, ToolWin, gppResults, Grids,
  DProjUnit, SynEdit,
  SynEditHighlighter, SynEditCodeFolding, SynHighlighterPas, System.ImageList,
  System.Actions,gppCurrentPrefs, VirtualTrees,
  virtualTree.tools.checkable,
  gppmain.FrameInstrumentation, gppmain.FrameAnalysis, gppmain.types;

type

  TfrmMain = class(TForm)
    OpenDialog: TOpenDialog;
    StatusBar: TStatusBar;
    ActionList1: TActionList;
    actInstrument: TAction;
    actOpen: TAction;
    actExit: TAction;
    actPreferences: TAction;
    Exit1: TMenuItem;
    Preferences1: TMenuItem;
    actRemoveInstrumentation: TAction;
    actRun: TAction;
    popRecent: TPopupMenu;
    actRescanProject: TAction;
    MRU: TGPMRUFiles;
    MainMenu1: TMainMenu;
    popDelphiVer: TPopupMenu;
    actOpenProfile: TAction;
    popRecentPrf: TPopupMenu;
    MRUPrf: TGPMRUFiles;
    actInstrumentRun: TAction;
    Help1: TMenuItem;
    About1: TMenuItem;
    actHideNotExecuted: TAction;
    actProjectOptions: TAction;
    actProfileOptions: TAction;
    actRescanProfile: TAction;
    actExportProfile: TAction;
    GpProfile1: TMenuItem;
    N1: TMenuItem;
    actMakeCopyProfile: TAction;
    actRenameMoveProfile: TAction;
    tbrInstrument: TToolBar;
    BtnOpenProject: TToolButton;
    btnRescanProject: TToolButton;
    btnInstrument: TToolButton;
    btnRemoveInstrumentation: TToolButton;
    btnProjectOptions: TToolButton;
    tbrAnalysis: TToolBar;
    btnOpenProfile: TToolButton;
    btnRescanProfile: TToolButton;
    btnExportProfile: TToolButton;
    btnRenameMoveProfile: TToolButton;
    btnMakeCopyProfile: TToolButton;
    btnInstrumentDelimiter1: TToolButton;
    btnInstrumentDelimiter2: TToolButton;
    btnAnalysisDelimiter1: TToolButton;
    actDelUndelProfile: TAction;
    btnDelUndelProfile: TToolButton;
    SaveDialog1: TSaveDialog;
    Panel0: TPanel;
    Panel1: TPanel;
    PageControl1: TPageControl;
    tabInstrumentation: TTabSheet;
    tabAnalysis: TTabSheet;
    pnlSourcePreview: TPanel;
    splitSourcePreview: TSplitter;
    actRescanChanged: TAction;
    actChangeLayout: TAction;
    actAddLayout: TAction;
    actDelLayout: TAction;
    actRenameLayout: TAction;
    actLayoutManager: TAction;
    popLayout: TPopupMenu;
    pnlLayout: TPanel;
    inpLayoutName: TEdit;
    BtnDeleteLayout: TButton;
    btnActivateLayout: TButton;
    btnRenameLayout: TButton;
    btnAddLayout: TButton;
    SpeedButton1: TSpeedButton;
    Contents1: TMenuItem;
    N3: TMenuItem;
    actHelpContents: TAction;
    actHelpShortcutKeys: TAction;
    actHelpAbout: TAction;
    imglListViews: TImageList;
    lvLayouts: TListView;
    actHelpQuickStart: TAction;
    QuickStart1: TMenuItem;
    Layout1: TMenuItem;
    LayoutManager1: TMenuItem;
    N7: TMenuItem;
    actShowHideSourcePreview: TAction;
    ShowSourcePreview1: TMenuItem;
    actShowHideCallers: TAction;
    actShowHideCallees: TAction;
    HideCallers1: TMenuItem;
    HideCalled1: TMenuItem;
    sourceCodeEdit: TSynEdit;
    actHelpOpenHome: TAction;
    actHelpWriteMail: TAction;
    N4: TMenuItem;
    GpProfileHomePage1: TMenuItem;
    WriteMailtoAuthor1: TMenuItem;
    Mailinglist1: TMenuItem;
    Forum1: TMenuItem;
    actHelpVisitForum: TAction;
    actHelpJoinMailingList: TAction;
    SynPasSyn: TSynPasSyn;
    ImageListMedium: TImageList;
    imgListInstrumentationSmall: TImageList;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    actLoadInstrumentationSelection: TAction;
    actSaveInstrumentationSelection: TAction;
    imgListAnalysisSmall: TImageList;
    imgListInstrumentationMedium: TImageList;
    procedure FormCreate(Sender: TObject);
    procedure MRUClick(Sender: TObject; LatestFile: String);
    procedure FormDestroy(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
    procedure actPreferencesExecute(Sender: TObject);
    procedure cbProfileChange(Sender: TObject);
    procedure actInstrumentExecute(Sender: TObject);
    procedure actOpenExecute(Sender: TObject);
    procedure actRescanProjectExecute(Sender: TObject);
    procedure actRemoveInstrumentationExecute(Sender: TObject);
    procedure actRunExecute(Sender: TObject);
    procedure actOpenProfileExecute(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure MRUPrfClick(Sender: TObject; LatestFile: String);
    procedure actInstrumentRunExecute(Sender: TObject);
    procedure btnCancelLoadClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure StatusBarResize(Sender: TObject);
    procedure actHideNotExecutedExecute(Sender: TObject);
    procedure actProjectOptionsExecute(Sender: TObject);
    procedure actRescanProfileExecute(Sender: TObject);
    procedure actExportProfileExecute(Sender: TObject);
    procedure mnuExportProfileClick(Sender: TObject);
    procedure actMakeCopyProfileExecute(Sender: TObject);
    procedure actDelUndelProfileExecute(Sender: TObject);
    procedure actRenameMoveProfileExecute(Sender: TObject);
    procedure actRescanChangedExecute(Sender: TObject);
    procedure AppShortcut(var Msg: TWMKey; var Handled: boolean);
    procedure actChangeLayoutExecute(Sender: TObject);
    procedure actLayoutManagerExecute(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure lbLayoutsClick(Sender: TObject);
    procedure actAddLayoutUpdate(Sender: TObject);
    procedure actRenameLayoutUpdate(Sender: TObject);
    procedure actChangeLayoutUpdate(Sender: TObject);
    procedure actDelLayoutUpdate(Sender: TObject);
    procedure inpLayoutNameKeyPress(Sender: TObject; var Key: Char);
    procedure actDelLayoutExecute(Sender: TObject);
    procedure actAddLayoutExecute(Sender: TObject);
    procedure lbLayoutsDblClick(Sender: TObject);
    procedure lbLayoutsKeyPress(Sender: TObject; var Key: Char);
    procedure actRenameLayoutExecute(Sender: TObject);
    procedure actHelpAboutExecute(Sender: TObject);
    procedure actHelpShortcutKeysExecute(Sender: TObject);
    procedure lvLayoutsSelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure actHelpContentsExecute(Sender: TObject);
    procedure CMDialogKey( Var msg: TCMDialogKey ); message CM_DIALOGKEY;
    procedure actHelpQuickStartExecute(Sender: TObject);
    procedure actShowHideSourcePreviewExecute(Sender: TObject);
    procedure actShowHideCallersExecute(Sender: TObject);
    procedure actShowHideCallersUpdate(Sender: TObject);
    procedure actShowHideCalleesExecute(Sender: TObject);
    procedure actShowHideCalleesUpdate(Sender: TObject);
    procedure lvCalleesClick(Sender: TObject);
    procedure splitCallersMoved(Sender: TObject);
    procedure clbUnitsKeyPress(Sender: TObject; var Key: Char);
    procedure clbClassesKeyPress(Sender: TObject; var Key: Char);
    procedure actLoadInstrumentationSelectionExecute(Sender: TObject);
    procedure actSaveInstrumentationSelectionExecute(Sender: TObject);
  private
    openProject               : TProject;
    openProfile               : TResults;
    currentProject            : string;
    currentProfile            : string;
    cancelLoading             : boolean;
    loadCanceled              : boolean;
    storedPanel1Width         : integer;
    delphiProcessInfo         : TProcessInformation;
    delphiAppWindow           : HWND;
    delphiEditWindow          : HWND;
    delphiThreadID            : DWORD;
    loadedSource              : string;
    undelProject              : string;
    activeLayout              : string;
    previewVisibleInstr       : boolean;
    previewVisibleAnalysis    : boolean;
    inLVResize                : boolean;
    FInstrumentationFrame     : TfrmMainInstrumentation;
    FProfilingFrame           : TfrmMainProfiling;
    procedure ExecuteAsync(const aProc,aOnFinishedProc: System.Sysutils.TProc;const aActionName : string);
    procedure ParseProject(const aProject: string; const aJustRescan: boolean);
    procedure LoadProject(fileName: string; defaultDelphi: string = '');
    procedure NotifyParse(const aUnitName: string);
    procedure NotifyInstrument(const aFullName, aUnitName: string; aParse: Boolean);

    procedure DelphiVerClick(Sender: TObject);
    procedure LayoutClick(Sender: TObject);
    procedure RebuildDelphiVer;
    procedure DisablePC;
    procedure EnablePC;
    procedure DisablePC2;
    procedure EnablePC2;
    procedure LoadProfile(fileName: string);
    procedure SetCaption;
    procedure SetSource;
    procedure ParseProfile(profile: string);
    function  ParseProfileCallback(percent: integer): boolean;
    procedure ParseProfileDone;
    procedure FillDelphiVer;
    function  GetSearchPath(const aProject: string): string;
    function  GetOutputDir(const aProject: string): string;
    procedure FindMyDelphi;
    procedure CloseDelphiHandles;
    procedure LoadSource(const fileName: String; focusOn: integer);
    procedure ClearSource;
    procedure QueryExport;
    procedure StatusPanel0(const msg: string; const beep: boolean);
    procedure ShowError(const Msg : string);
    function  ShowErrorYesNo(const Msg : string): integer;

    procedure SwitchDelMode(delete: boolean);
    procedure NoProfile;
    procedure ResetProfile();
    procedure DoInstrument;
    procedure RescanProject;
    procedure LoadMetrics(layoutName: string);
    procedure SaveMetrics(layoutName: string);
    procedure RebuildLayoutPopup(changeActive: boolean);
    function  IsLayout(layout: string): boolean;
    procedure SetChangeLayout(setRestore: boolean);
    procedure LoadLayouts;
    procedure UseDelphiSettings(delphiVer: integer);
    procedure RebuildDefines;
    procedure SlidersMoved;
    function  IsProjectConsole: boolean;
    function  ReplaceMacros(s: string): string;
    procedure ResetSourcePreview(reposition: boolean);
    procedure RestoreUIAfterParseProject;
    procedure WMDropFiles (var aMsg: TMessage); message WM_DROPFILES;
 end;

var
  frmMain: TfrmMain;

implementation

uses
  BdsProjUnit,
  BdsVersions,
  IniFiles,
  GpString,
  GpProfH,
  GpIFF,
  GpRegistry,
  gppCommon,
  gpversion,
  gpPreferencesDlg,
  gppLoadProgress,
  SimpleReportUnit,
  gppAbout,
  gppExport,
  gpPrfPlaceholders,
  UITypes,
  StrUtils,
  ioUtils,
  Diagnostics,
  Winapi.ActiveX,
  System.Threading, gppmain.dragNdrop;


{$R *.DFM}

{$I HELP.INC}

type
  PMap = ^TMap;
  TMap = record
    mapAppWindow : HWND;
    mapEditWindow: HWND;
  end;

function EnumMapThreadToWindows(window: HWND; lParam: PMap): boolean; stdcall;
var
  name: array [0..256] of char;
begin
  GetClassName(window,name,255);
  if name = 'TApplication' then lParam^.mapAppWindow := window
  else if name = 'TEditWindow' then lParam^.mapEditWindow := window;
  Result := true;
end; { EnumMapThreadToWindows }

procedure MapThreadToWindows(threadid: DWORD; var appWindow, editWindow: HWND);
var
  map: PMap;
begin
  New(map);
  try
    with map^ do begin
      mapAppWindow  := 0;
      mapEditWindow := 0;
      EnumThreadWindows(threadid,@EnumMapThreadToWindows,integer(map));
      appWindow  := mapAppWindow;
      editWindow := mapEditWindow;
    end;
  finally Dispose(map); end;
end; { MapThreadToWindow }

type
  PFind = ^TFind;
  TFind = record
    findTitle : shortstring;
    findProcID: DWORD;
  end;

function EnumFindMyDelphi(window: HWND; lParam: PFind): boolean; stdcall;
var
  name : array [0..256] of char;
  title: array [0..256] of char;
  findTileW : string;
  titleW : string;
begin
  GetClassName(window,name,255);
  GetWindowText(window,title,255);
  titleW := title;
  findTileW := UTF8ToUnicodeString(lParam^.findTitle);
  if (name = 'TAppBuilder') and (Pos(findTileW,UpperCase(titleW)) > 0) then begin
    lParam^.findProcID := GetWindowThreadProcessID(window,nil);
    Result := false;
  end
  else Result := true;
end; { EnumFindMyDelphi }

{========================= TfrmMain =========================}

procedure TfrmMain.CMDialogKey(var msg: TCMDialogKey);
var
  control: TWinControl;
begin
  with Msg do begin
    if (charcode = VK_TAB) and (GetKeyState(VK_CONTROL) < 0) then begin
      control:= ActiveControl;
      while Assigned(control) do begin
        if control is TPageControl then begin
          control.Perform(CM_DIALOGKEY, charcode, keydata);
          Exit;
        end
        else control := Control.Parent;
      end;
    end;
  end;
  inherited;
end; { TfrmMain.CMDialogKey }

procedure TfrmMain.FindMyDelphi;
var
  find: PFind;
begin
  delphiThreadID := 0;
  if ParamCount > 0 then begin
    New(find);
    try
      find^.findProcID := 0;
      find^.findTitle := UTF8Encode(' - '+UpperCase(FirstEl(ExtractFileName(ParamStr(1)),'.',-1)));
      EnumWindows(@EnumFindMyDelphi,integer(find));
      if find^.findProcID <> 0 then begin
        delphiThreadID := find^.findProcID;
        MapThreadToWindows(delphiThreadID,delphiAppWindow,delphiEditWindow);
      end;
    finally Dispose(find); end;
  end;
end; { TfrmMain.FindMyDelphi }


procedure TfrmMain.NotifyParse(const aUnitName: string);
begin
  TThread.Queue(nil,
    procedure
    begin
     StatusPanel0('Parsing ' + aUnitName, False);
     frmLoadProgress.Text := 'Parsing ' + aUnitName;
    end);
end; { TfrmMain.NotifyParse }

procedure TfrmMain.NotifyInstrument(const aFullName, aUnitName: string; aParse: Boolean);
begin
  TThread.Queue(nil,
  procedure
  begin
    if aParse then
      StatusPanel0('Parsing ' + aUnitName, False)
    else begin
      StatusPanel0('Instrumenting ' + aUnitName, False);
      frmLoadProgress.Text := 'Instrumenting ' + aUnitName;
      if AnsiSameText(aFullName, LoadedSource) then
        LoadedSource := ''; // force preview window reload
    end;
  end);

end; { TfrmMain.NotifyInstrument }


procedure TfrmMain.DisablePC;
begin
  PageControl1.Font.Color            := clBtnShadow;
  FInstrumentationFrame.DisablePC;
  if PageControl1.ActivePage = tabInstrumentation then
    sourceCodeEdit.Color := clBtnFace;
end; { TfrmMain.DisablePC }

procedure TfrmMain.EnablePC;
begin
  PageControl1.Font.Color            := clWindowText;               //
  FInstrumentationFrame.EnablePC();
  if PageControl1.ActivePage = tabInstrumentation then
    sourceCodeEdit.Color := SynPasSyn.SpaceAttri.Background;
  SetSource;
end; { TfrmMain.EnablePC }

procedure TFrmMain.RestoreUIAfterParseProject();
begin
  GetOutputDir(openProject.Name);
  StatusPanel0('Parsed', True);
  EnablePC;
  Enabled := true;

  actRescanProject.Enabled         := true;
  actRescanChanged.Enabled         := true;
  actInstrument.Enabled            := true;
  actInstrumentRun.Enabled         := true;
  actRemoveInstrumentation.Enabled := true;
  actRun.Enabled                   := true;
  actProjectOptions.Enabled        := true;
  actLoadInstrumentationSelection.Enabled := true;
  actSaveInstrumentationSelection.Enabled := true;
  FInstrumentationFrame.openProject := openProject;
  FInstrumentationFrame.FillUnitTree(not FInstrumentationFrame.chkShowAll.Checked);
end;

procedure TfrmMain.ParseProject(const aProject: string; const aJustRescan: boolean);
var
  vErrList: TStringList;
  LDefines : string;
begin
  Enabled := False;
  DisablePC;
  if not aJustRescan then
  begin
    FInstrumentationFrame.openProject := nil;
    FreeAndNil(openProject);
    InitProgressBar(self,'Parsing units...', true, false);
    FInstrumentationFrame.FillUnitTree(true); // clear all listboxes
    openProject := TProject.Create(aProject);
    CurrentProjectName := aProject;
    RebuildDefines;
    vErrList := TStringList.Create;
    LDefines := frmPreferences.ExtractDefines;
    ExecuteAsync(
      procedure
      begin
        openProject.Parse(GetProjectPref('ExcludedUnits',prefExcludedUnits),
                  GetSearchPath(aProject),
                  LDefines, NotifyParse,
                  GetProjectPref('MarkerStyle', prefMarkerStyle),
                  GetProjectPref('InstrumentAssembler', prefInstrumentAssembler),
                  vErrList);

      end,
      procedure
      begin
        TThread.Synchronize(nil, procedure
        begin
          HideProgressBar;
          if vErrList.Count > 0 then
          begin
            TfmSimpleReport.Execute(CurrentProjectName + '- error list', vErrList);
          end;
          vErrList.Free;
          RestoreUIAfterParseProject();
        end);
      end,
      'parsing');
  end
  else
  begin
    LDefines := frmPreferences.ExtractDefines;
    InitProgressBar(self,'Rescanning units...', true, false);
    RebuildDefines;
    LDefines := frmPreferences.ExtractDefines;
    ExecuteAsync(
      procedure
      begin
        openProject.Rescan(GetProjectPref('ExcludedUnits', prefExcludedUnits),
                   GetSearchPath(aProject),
                   LDefines,
                   GetProjectPref('MarkerStyle', prefMarkerStyle),
                   GetProjectPref('UseFileDate', prefUseFileDate),
                   GetProjectPref('InstrumentAssembler', prefInstrumentAssembler));
      end,
      procedure
      begin
        TThread.Synchronize(nil, procedure
        begin
          HideProgressBar;
          RestoreUIAfterParseProject();
        end);
      end,'rescanning');
  end;
  ShowProgressBar;
end; { TfrmMain.ParseProject }


function TfrmMain.IsProjectConsole: boolean;
begin
  Result := false;
  if assigned(openProject) then begin
    // Don't know why but ConsoleApp=1 means that app is NOT a console app!
    Result := not GetDOFSettingBool('Linker','ConsoleApp',true);
    // Also, CONSOLE is defined only if Linker option is set, not if
    // {$APPTYPE CONSOLE} is specified in main program!
    // Stupid, but that's how Delphi works.
  end;
end;

procedure TfrmMain.RebuildDefines;
begin
  with frmPreferences do begin
    ReselectCompilerVersion(selectedDelphi);
    cbStandardDefines.Checked    := GetProjectPref('StandardDefines',prefStandardDefines);
    cbConsoleDefines.Checked     := GetProjectPref('ConsoleDefines',IsProjectConsole);
    cbProjectDefines.Checked     := GetProjectPref('ProjectDefines',prefProjectDefines);
    cbDisableUserDefines.Checked := GetProjectPref('DisableUserDefines',prefDisableUserDefines);
    RebuildDefines(GetProjectPref('UserDefines',prefUserDefines));
  end;
end;

procedure TfrmMain.LoadProject(fileName: string; defaultDelphi: string = '');
begin
  if not FileExists(fileName) then
  begin
    StatusPanel0('File "'+fileName+'" does not exist!',true);
    raise Exception.Create('File "'+fileName+'" does not exist.');
  end
  else begin
    MRU.LatestFile := fileName;
    currentProject := ExtractFileName(fileName);
    ParseProject(fileName,false);
    if defaultDelphi = '' then
      defaultDelphi := RemoveDelphiPrefix(frmPreferences.cbxCompilerVersion.Items[prefCompilerVersion]);
    selectedDelphi := GetProjectPref('DelphiVersion',defaultDelphi);
    RebuildDelphiVer;
    FInstrumentationFrame.chkShowAll.Checked := GetProjectPref('ShowAllFolders',prefShowAllFolders);
    PageControl1.ActivePage := tabInstrumentation;
    SetCaption;
    SetSource;
  end;
end; { TfrmMain.LoadProject }

procedure TfrmMain.RebuildDelphiVer;
var
  i    : integer;
  found: boolean;
begin
  found := false;
  with popDelphiVer do begin
    for i := 0 to Items.Count-2 do Items[i].Checked := false;
    if Items.Count >= 1 then
      Items[Items.Count-1].Checked := true;
    for i := 0 to Items.Count-1 do begin
      if RemoveDelphiPrefix(Items[i].Caption) = selectedDelphi then
      begin
        Items[Items.Count-1].Checked := false;
        Items[i].Checked := true;
        found := true;
        system.break;
      end;
    end;

    if (not found) and (Items.Count >= 1) then begin
      selectedDelphi := RemoveDelphiPrefix(Items[Items.Count-1].Caption);
    end;
  end;
  Statusbar.Panels[1].Text := IFF(openProject = nil,'','Delphi '+selectedDelphi);
  if selectedDelphi <> '' then // <-- Added by Alisov A.
    UseDelphiSettings(Ord(selectedDelphi[1])-Ord(48));
end; { TfrmMain.RebuildDelphiVer }

procedure TfrmMain.DisablePC2;
begin
  tabAnalysis.Font.Color             := clBtnShadow;
  FProfilingFrame.Disable();
  if PageControl1.ActivePage = tabAnalysis then
    sourceCodeEdit.Color := clBtnFace;
end; { TfrmMain.DisablePC2 }

procedure TfrmMain.EnablePC2;
begin
  tabAnalysis.Font.Color             := clWindowText;
  StatusPanel0('',false);
  FProfilingFrame.Enable();
  if FProfilingFrame.Enable then
  begin
    if PageControl1.ActivePage = tabAnalysis then
      sourceCodeEdit.Color := SynPasSyn.SpaceAttri.Background;
    SetSource;
  end;
end;



{ TfrmMain.EnablePC2 }

function TfrmMain.ParseProfileCallback(percent: integer): boolean;
begin
  frmLoadProgress.ProgressBar1.Position := percent;
  Result := not frmLoadProgress.CancelPressed;
end; { TfrmMain.ParseProfileCallback }

procedure TfrmMain.ParseProfile(profile: string);
begin
  cancelLoading := false;
  Enabled := false;
  DisablePC2;
  ResetProfile();
  InitProgressBar(Self,'Parsing profiling results...',false, True);
  StatusPanel0('Loading '+profile,false);
  ExecuteAsync(
    procedure
    begin
      openProfile := TResults.Create(profile,ParseProfileCallback);
    end,
    procedure
    begin
      TThread.Synchronize(nil,ParseProfileDone);
    end,
    'loading profile'
  );
  ShowProgressBar;
end; { TfrmMain.ParseProfile }

procedure TfrmMain.ParseProfileDone();
var
  LOpenResult : boolean;
begin
  LOpenResult := false;
  if openProfile = nil then
  begin
    NoProfile;
    actDelUndelProfile.Enabled := false;
    StatusPanel0('Load error',true);
  end
  else
  begin
    loadCanceled := frmLoadProgress.CancelPressed;
    if not loadCanceled then begin
      if not openProfile.IsDigest then begin
        StatusPanel0('Saving digest',false);
        openProfile.SaveDigest(openProfile.FileName);
      end;
    end;
    StatusPanel0('Loaded',true);
    LOpenResult := true;
  end;
  HideProgressBar;
  if assigned(openProfile) then
  begin
    actProfileOptions.Enabled := true;
    FProfilingFrame.OpenProfile := openProfile;
  end;
  Show;
  FProfilingFrame.FillThreadCombos;
  if assigned(openProfile) then
    EnablePC2;
  Enabled := true;
  if LOpenResult then
  begin
    SetCaption;
    SetSource;
    actHideNotExecuted.Checked := GetProfilePref('HideNotExecuted', prefHideNotExecuted);
    FProfilingFrame.FillViews(1);
    FProfilingFrame.ClearBreakdown;
    actHideNotExecuted.Enabled   := true;
    actRescanProfile.Enabled     := true;
    actExportProfile.Enabled     := true;
    FProfilingFrame.mnuExportProfile.Enabled     := true;
    actRenameMoveProfile.Enabled := true;
    actMakeCopyProfile.Enabled   := true;
    actDelUndelProfile.Enabled   := true;
    SwitchDelMode(true);
  end;
end;




procedure TfrmMain.LoadProfile(fileName: string);
begin
  if not FileExists(fileName) then StatusPanel0('File '+fileName+' does not exist!',true)
  else begin
    MRUPrf.LatestFile := fileName;
    currentProfile := ExtractFileName(fileName);
    PageControl1.ActivePage := tabAnalysis;
    ClearSource;
    ParseProfile(fileName);

  end;
end; { TfrmMain.LoadProfile }

procedure TfrmMain.DelphiVerClick(Sender: TObject);
begin
  selectedDelphi := RemoveDelphiPrefix(TMenuItem(Sender).Caption);
  RebuildDelphiVer;
  SetProjectPref('DelphiVersion',selectedDelphi);
end;

procedure TfrmMain.LayoutClick(Sender: TObject);
begin
  SaveMetrics(activeLayout);
  inpLayoutName.Text := TMenuItem(Sender).Caption;
  RebuildLayoutPopup(true);
  inpLayoutName.Text := lvLayouts.Selected.Caption;
  LoadMetrics(inpLayoutName.Text);
end;

procedure TfrmMain.FillDelphiVer;
var
  s : TStringList;
  mn: TMenuItem;
  i : integer;
begin
  s := TStringList.Create;
  try
    FillInDelphiVersions(s);
    for i := 0 to s.Count-1 do begin
      mn := TMenuItem.Create(self);
      mn.Caption := 'Delphi &'+s[i];
      mn.OnClick := DelphiVerClick;
      popDelphiVer.Items.Insert(popDelphiVer.Items.Count,mn);
      frmPreferences.cbxCompilerVersion.Items.Add('Delphi '+s[i]);
      frmPreferences.cbxDelphiDefines.Items.Add('Delphi '+s[i]);
    end;
    if s.Count = 0 then
      actRun.OnExecute := nil;
    if s.Count >= 1 then
    begin
      if (prefCompilerVersion < 0) or (prefCompilerVersion >= s.Count) then
        prefCompilerVersion := s.Count-1;
      selectedDelphi := GetProjectPref('DelphiVersion', s[prefCompilerVersion]);
      RebuildDelphiVer;
    end;
  finally
    s.Free;
  end;
end; { TfrmMain.FillDelphiVer }


procedure TfrmMain.RebuildLayoutPopup(changeActive: boolean);
var
  mn      : TMenuItem;
  i       : integer;
  found   : boolean;
  ucLayout: string;
  lastName: string;
begin
  while popLayout.Items.Count > 0 do popLayout.Items.Remove(popLayout.Items[0]);
  if changeActive then begin
    with lvLayouts do for i := 0 to Items.Count-1 do
      with Items[i] do if ImageIndex = 2 then ImageIndex := 0;
    ucLayout := UpperCase(inpLayoutName.Text);
    found := false;
    lastName := '';
    for i := 0 to lvLayouts.Items.Count-1 do begin
      if lvLayouts.Items[i].ImageIndex <> 1 then begin
        if UpperCase(lvLayouts.Items[i].Caption) = ucLayout then begin
          found := true;
          break;
        end
        else lastName := lvLayouts.Items[i].Caption;
      end;
    end;
    if not found then inpLayoutName.Text := lastName;
  end;
  for i := 0 to lvLayouts.Items.Count-1 do begin
    if lvLayouts.Items[i].ImageIndex <> 1 then begin
      mn := TMenuItem.Create(self);
      mn.Caption := lvLayouts.Items[i].Caption;
      mn.OnClick := LayoutClick;
      if changeActive
        then mn.Checked := UpperCase(lvLayouts.Items[i].Caption) = ucLayout
        else mn.Checked := lvLayouts.Items[i].ImageIndex = 2;
      if mn.Checked then begin
        lvLayouts.Selected := lvLayouts.Items[i];
        lvLayouts.Selected.ImageIndex := 2;
      end;
      popLayout.Items.Insert(popLayout.Items.Count,mn);
    end;
  end;
end;


{ TfrmMain.RebuildLayoutPopup }

function TfrmMain.IsLayout(layout: string): boolean;
var
  i: integer;
begin
  IsLayout := true;
  layout := UpperCase(layout);
  for i := 0 to lvLayouts.Items.Count-1 do
    if UpperCase(lvLayouts.Items[i].Caption) = layout then Exit;
  IsLayout := false;
end; { TfrmMain.IsLayout }

procedure TfrmMain.LoadLayouts;
var
  layout: string;
  vSL   : TStringList;
  i     : integer;
begin
  with TGpRegistry.Create do begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey(cRegistryUI,true) then
      begin
        vSL := TStringList.Create;
        try
          GetKeyNames(vSL);
          for i := 0 to vSL.Count-1 do
            with lvLayouts.Items.Add do Caption := vSL[i];
        finally
          vSL.Free;
        end;

        if lvLayouts.Items.Count = 0 then
          with lvLayouts.Items.Add do
            Caption := cDefLayout;

        layout := TGpRegistryTools.GetPref(cRegistryUIsub, 'Layout', cDefLayout);
        if IsLayout(layout) then
          inpLayoutName.Text := layout
        else
          inpLayoutName.Text := lvLayouts.Items[0].Caption;
      end;
      RebuildLayoutPopup(true);
    finally
      Free;
    end;
  end;
end; { TfrmMain.LoadLayouts }

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  FInstrumentationFrame := TfrmMainInstrumentation.Create(self);
  FInstrumentationFrame.Parent := tabInstrumentation;
  FInstrumentationFrame.Align := alClient;
  FInstrumentationFrame.chkShowAll.OnClick := cbProfileChange;;
  FInstrumentationFrame.OnReloadSource := LoadSource;
  FInstrumentationFrame.OnShowStatusBarMessage := StatusPanel0;
  fProfilingFrame := TfrmMainProfiling.Create(self);
  fProfilingFrame.Parent := tabAnalysis;
  fProfilingFrame.Align := alClient;
  FProfilingFrame.actHideNotExecuted := actHideNotExecuted;
  FProfilingFrame.actShowHideCallers := actShowHideCallers;
  FProfilingFrame.actShowHideCallees := actShowHideCallees;
  fProfilingFrame.OnReloadSource := LoadSource;
  FProfilingFrame.mnuExportProfile.onClick := mnuExportProfileClick;
  FProfilingFrame.popAnalysisListview.Items[0].Action := actHideNotExecuted;
  Application.DefaultFont.Name :=  'Segoe UI';
  Application.DefaultFont.Size :=  8;
  inLVResize := false;
  Application.OnShortCut := AppShortcut;
  Application.HelpFile := ChangeFileExt(ParamStr(0),'.Chm');
  if not FileExists(Application.HelpFile) then Application.HelpFile := '';
  LoadLayouts;
  StatusBar.Font.Size := 10;
  ClearSource;
  FindMyDelphi;
  with delphiProcessInfo do begin
    hProcess := 0;
    hThread  := 0;
  end;
  LoadPreferences;
  PageControl1.ActivePage := tabInstrumentation;
  DisablePC2;
  DisablePC;
  loadCanceled := false;
  CurrentProjectName := '';

  MRU.RegistryKey := cRegistryRoot+'\MRU\DPR';
  MRU.LoadFromRegistry;
  MRUPrf.RegistryKey := cRegistryRoot+'\MRU\PRF';
  MRUPrf.LoadFromRegistry;
  undelProject := '';
  SlidersMoved;
  
  SetCaption();
  //LPercentage := Screen.PixelsPerInch * 100 / 96;

  if 1=0 then
  begin
    tbrInstrument.Images := imgListInstrumentationMedium;
  end;
  TDragNDropHandler.setDragNDropEnabled(self.Handle, true);
end;

procedure TfrmMain.MRUClick(Sender: TObject; LatestFile: String);
begin
  if (openProject = nil) or (openProject.Name <> LatestFile) then begin
    CloseDelphiHandles;
    LoadProject(LatestFile);
  end;
end;

procedure TfrmMain.SaveMetrics(layoutName: string);

  procedure PutHeader(reg: TGpRegistry; aVST: TVirtualStringTree; prefix: string);
  var
    i: integer;
  begin
    for i := 0 to aVST.Header.Columns.Count-1 do
      reg.WriteInteger(prefix+'Column'+IntToStr(i)+'Width',aVST.Header.Columns[i].Width);
  end; { PutColumns }


var
  reg: TGpRegistry;
  wp : TWindowPlacement;
begin
  reg := TGpRegistry.Create;
  try
    with reg do begin
      RootKey := HKEY_CURRENT_USER;
      OpenKey(cRegistryUI,true);
      WriteString('UIVer', cUIVersion);
      OpenKey(layoutName,true);
      WriteInteger('WindowState',Ord(WindowState));
      wp.Length := SizeOf(TWindowPlacement);
      if GetWindowPlacement(frmMain.Handle,@wp) then begin
        WriteInteger('FormLeft',wp.rcNormalPosition.Left);
        WriteInteger('FormTop',wp.rcNormalPosition.Top);
        WriteInteger('FormRight',wp.rcNormalPosition.Right);
        WriteInteger('FormBottom',wp.rcNormalPosition.Bottom);
      end;
      WriteInteger('pnlUnitsWidth',FInstrumentationFrame.pnlUnits.Width);
      WriteInteger('pnlClassesWidth',FInstrumentationFrame.pnlClasses.Width);
      WriteInteger('Panel2Height',pnlSourcePreview.Height);
      WriteBool('previewVisibleInstr',previewVisibleInstr);
      WriteBool('previewVisibleAnalysis',previewVisibleAnalysis);
      WriteInteger('pnlCallersHeight',FProfilingFrame.pnlCallers.Height);
      WriteInteger('pnlCalleesHeight',FProfilingFrame.pnlCallees.Height);
      WriteBool('pnlCallersVisible',FProfilingFrame.pnlCallers.Visible);
      WriteBool('pnlCalleesVisible',FProfilingFrame.pnlCallees.Visible);
      PutHeader(reg,FProfilingFrame.vstProcs,'lvProcs');
      PutHeader(reg,FProfilingFrame.vstClasses,'lvClasses');
      PutHeader(reg,FProfilingFrame.vstUnits,'lvUnits');
      PutHeader(reg,FProfilingFrame.vstThreads,'lvThreads');
      PutHeader(reg,FProfilingFrame.vstCallers,'lvCallers');
      PutHeader(reg,FProfilingFrame.vstCallees,'lvCallees');
    end;
  finally reg.Free; end;
end; { TfrmMain.SaveMetrics }

procedure TfrmMain.FormDestroy(Sender: TObject);
var
  i: integer;
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      for i := 0 to lvLayouts.Items.Count-1 do
        if lvLayouts.Items[i].ImageIndex = 1 then
          DeleteKey(cRegistryUI + '\' + lvLayouts.Items[i].Caption);
    finally
      Free;
    end;

  SwitchDelMode(true); // process pending delete
  CloseDelphiHandles;
  if activeLayout <> '' then begin
    SaveMetrics(activeLayout);
    TGpRegistryTools.SetPref(cRegistryUIsub,'Layout',activeLayout)
  end;
  MRU.SaveToRegistry;
  MRUPrf.SaveToRegistry;
  FreeAndNil(openProject);
  ResetProfile();
end;


procedure TfrmMain.actExitExecute(Sender: TObject);
begin
  Application.Terminate;
end;

procedure TfrmMain.actPreferencesExecute(Sender: TObject);
var
  oldProject: TProject;
begin
  oldProject := openProject;
  openProject := nil;
  try
    with frmPreferences do begin
      if ExecuteGlobalSettings then
        RebuildDelphiVer;
    end;
  finally openProject := oldProject; end;
end;

procedure TfrmMain.cbProfileChange(Sender: TObject);
begin
  FInstrumentationFrame.FillUnitTree(not FInstrumentationFrame.chkShowAll.Checked);
  SetProjectPref('ShowAllFolders',FInstrumentationFrame.chkShowAll.Checked);
end;


procedure TfrmMain.clbUnitsKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #32 then
    FInstrumentationFrame.clbUnitsClick();
  inherited;
end;

procedure TfrmMain.ExecuteAsync(const aProc, aOnFinishedProc: System.Sysutils.TProc;const aActionName : string);
var
  LTask : ITask;
  LExceptionMsg : string;
begin
  LTask := tTask.Create(procedure
    begin
      try
        Coinitialize(nil);
        try
          aProc();
        finally
          CoUninitialize
        end;
      except
        on E:Exception do
        begin
          LExceptionMsg := e.Message;
          TThread.Synchronize(nil,procedure
            begin
              StatusPanel0('Error while '+aActionName+': '+LExceptionMsg,false);
              ShowError('Error while '+aActionName+':'+sLineBreak+sLineBreak+LExceptionMsg);
            end
          );
        end;
      end;
      if assigned(aOnFinishedProc) then
      begin
        aOnFinishedProc;
      end;
    end);
  LTask.Start;
end;


procedure TfrmMain.DoInstrument;
var
  fnm   : string;
  outDir: string;
  LShowAll : Boolean;
  LDefines : string;
  LNeededTimeString : string;
begin
  InitProgressBar(self,'Instrumenting units...',true, false);
  outDir := GetOutputDir(openProject.Name);
  fnm := MakeSmartBackslash(outDir)+ChangeFileExt(ExtractFileName(openProject.Name),'.gpi');
  LShowAll := FInstrumentationFrame.chkShowAll.Checked;
  LDefines := frmPreferences.ExtractDefines;
  Enabled := false;
  LNeededTimeString := '';
  ExecuteAsync(
    procedure
    var
      LStopwatch : TStopwatch;
    begin
      LStopwatch := TStopWatch.StartNew();
      openProject.Instrument(not LShowAll,NotifyInstrument,
                         GetProjectPref('MarkerStyle',prefMarkerStyle),
                         GetProjectPref('KeepFileDate',prefKeepFileDate),
                         GetProjectPref('MakeBackupOfInstrumentedFile',prefKeepFileDate),
                         fnm,LDefines,
                         GetSearchPath(openProject.Name),
                         GetProjectPref('InstrumentAssembler',prefInstrumentAssembler));

      if FileExists(fnm) then
        with TIniFile.Create(fnm) do
          try
            WriteBool('Performance','ProfilingAutostart',GetProjectPref('ProfilingAutostart',prefProfilingAutostart));
            WriteBool('Performance','CompressTicks',GetProjectPref('SpeedSize',prefSpeedSize)>1);
            WriteBool('Performance','CompressThreads',GetProjectPref('SpeedSize',prefSpeedSize)>2);
            WriteString('Output','PrfOutputFilename',ResolvePrfProjectPlaceholders(GetProjectPref('PrfFilenameMakro',prefPrfFilenameMakro)));
          finally
            Free;
          end;
      LStopwatch.Stop;
      LNeededTimeString := LStopwatch.Elapsed.TotalSeconds.ToString();
    end,
    procedure
    begin
      TThread.Synchronize(nil,
      procedure
        begin
          Enabled := true;
          HideProgressBar();
          FInstrumentationFrame.ReloadSource;
          StatusPanel0('Instrumentation finished, it took '+LNeededTimeString+' seconds.',false);
        end
      );
    end,
     'instrumenting');
  ShowProgressBar();

end; { TfrmMain.DoInstrument }

procedure TfrmMain.actInstrumentExecute(Sender: TObject);
begin
  actRescanChanged.Execute;
  DoInstrument;
end;

procedure TfrmMain.actOpenExecute(Sender: TObject);
var
  LSourceFilename: TFileName;
  LFilename : string;
begin
  OpenDialog.DefaultExt := TUIStrings.DelphiProjectSourceDefaultExt;
  LFilename := '';
  if assigned(openProfile) then
    LFileName := ChangeFileExt(openProfile.FileName, TUIStrings.DelphiProjectSourceExt);
  OpenDialog.FileName := ExtractFilename(LFilename);
  OpenDialog.InitialDir := ExtractFileDir(LFilename);
  OpenDialog.Filter := TUIStrings.ProjectSelectionFilter();
  OpenDialog.Title := TUIStrings.LoadProjectCaption();
  if OpenDialog.Execute then
  begin
    LSourceFilename := OpenDialog.FileName;
    if AnsiLowerCase(ExtractFileExt(OpenDialog.FileName)) = TUIStrings.DelphiProjectExt then
    begin
      // convert to dpk if exists, else to dpr
      if FileExists(ChangeFileExt(LSourceFilename, TUIStrings.DelphiPackageSourceExt)) then
        LSourceFilename := ChangeFileExt(LSourceFilename, TUIStrings.DelphiPackageSourceExt)
      else
        LSourceFilename := ChangeFileExt(LSourceFilename, TUIStrings.DelphiProjectSourceExt);
    end;
    CloseDelphiHandles;
    LoadProject(LSourceFilename);
  end;
end;

procedure TfrmMain.actRescanProjectExecute(Sender: TObject);
begin
  LoadProject(openProject.Name);
end;



procedure TfrmMain.clbClassesKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #32 then
    FInstrumentationFrame.clbClassesClick(Sender);
  inherited;
end;

procedure TfrmMain.actRemoveInstrumentationExecute(Sender: TObject);
begin
  actRescanChanged.Execute;
  FInstrumentationFrame.RemoveInstrumentation(DoInstrument);
end;

procedure TfrmMain.actRunExecute(Sender: TObject);
var
  run        : string;
  startupInfo: TStartupInfo;
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('\SOFTWARE\Borland\Delphi\' + selectedDelphi) then
        run := ReadString('Delphi ' + FirstEl(selectedDelphi,'.',-1),'')
      else begin
        RootKey := HKEY_CURRENT_USER;
        if OpenKeyReadOnly('\SOFTWARE\Borland\BDS\' + DelphiVerToBDSVer(selectedDelphi)) then
          run := ReadString('App', '')
        else if OpenKeyReadOnly('\SOFTWARE\Embarcadero\BDS\' + DelphiVerToBDSVer(selectedDelphi)) then
          run := ReadString('App', '')
        else
          run := '';
      end;
    finally
      Free;
    end;

  if run = '' then
    raise Exception.Create('Can''t determine Delphi executable file location from registry.');

  if delphiThreadID <> 0 then // not first run =>
  begin // => check if Delphi is still alive
    MapThreadToWindows(delphiThreadID,delphiAppWindow,delphiEditWindow);
    if delphiAppWindow = 0 then
      CloseDelphiHandles // restart Delphi
    else begin
      if IsIconic(delphiAppWindow) then
        ShowWindow(delphiAppWindow,SW_RESTORE);
      SetForegroundWindow(delphiAppWindow); // New versions of Delphi have only app window :)
      if delphiEditWindow <> 0 then
        SetForegroundWindow(delphiEditWindow); // Old versions of Delphi (2-7) also have edit window
      Exit;
    end;
  end;

  with startupInfo do
  begin
    cb          := SizeOf(startupInfo);
    lpReserved  := nil;
    lpDesktop   := nil;
    lpTitle     := nil;
    dwFlags     := STARTF_USESHOWWINDOW+STARTF_FORCEONFEEDBACK;
    wShowWindow := SW_SHOWDEFAULT;
    cbReserved2 := 0;
    lpReserved2 := nil;
  end;
  run := '"' + run + '" "' + openProject.Name + '"';
  if not CreateProcess(nil,PChar(run),nil,nil,false,
           CREATE_DEFAULT_ERROR_MODE+CREATE_NEW_PROCESS_GROUP+NORMAL_PRIORITY_CLASS,
           nil,PChar(ExtractFilePath(openProject.Name)),startupInfo,
           delphiProcessInfo) then
  begin
    StatusPanel0(Format('Cannot run Delphi (%s): %s',[run,SysErrorMessage(GetLastError)]),true);
    delphiThreadID := 0;
  end
  else
    delphiThreadID := delphiProcessInfo.dwThreadId;
end;

procedure TfrmMain.actOpenProfileExecute(Sender: TObject);
begin
  with OpenDialog do
  begin
    Title := 'Load profile data...';
    DefaultExt := 'prf';
    if openProject = nil then FileName := '*.prf'
                         else FileName := ChangeFileExt(openProject.Name,'.prf');
    Filter     := 'Profile data|*.prf|Any file|*.*';
    if Execute then LoadProfile(FileName);
  end;
end;

procedure TfrmMain.ResetSourcePreview(reposition: boolean);
begin
  with actShowHideSourcePreview do begin
    Tag := 1-Ord(pnlSourcePreview.Visible);
    if Tag = 1 then begin
      Caption := 'Show &Source Preview';
      Hint    := 'Show source preview';
    end
    else begin
      Caption := 'Hide &Source Preview';
      Hint    := 'Hide source preview';
    end;
    ImageIndex := 20+Tag;
  end;
  if reposition then FProfilingFrame.RepositionSliders;
end; { TfrmMain.ResetSourcePreview }

procedure TfrmMain.PageControl1Change(Sender: TObject);
begin
  SetCaption;
  SetSource;
  if PageControl1.ActivePage = tabInstrumentation then
  begin
    FInstrumentationFrame.clbProcsClick(Sender);
    pnlSourcePreview.Visible := previewVisibleInstr;
    splitSourcePreview.Visible := previewVisibleInstr;
    ResetSourcePreview(true);
  end
  else begin
    FProfilingFrame.updatefocus;
    FProfilingFrame.lvProcsClick(Sender);
    pnlSourcePreview.Visible := previewVisibleAnalysis;
    splitSourcePreview.Visible := previewVisibleAnalysis;
    ResetSourcePreview(true);
  end;
end;


procedure TfrmMain.SetCaption;
begin
  Caption := 'GpProfile 2017 '+ GetVersion(verShort2to3)+' ';
  if PageControl1.ActivePage = tabInstrumentation then
    Caption := Caption+IFF(currentProject <> '',' - '+currentProject,'')
  else
    Caption := Caption+IFF(currentProfile <> '',' - '+currentProfile,'')+IFF(loadCanceled,' (incomplete)','');
  Application.Title := Caption;
end;

procedure TfrmMain.SetSource;
var
  enabled: boolean;
begin
  if PageControl1.ActivePage = tabInstrumentation
    then enabled := (currentProject <> '')
    else enabled := (currentProfile <> '');
  if enabled then begin
    sourceCodeEdit.Enabled := true;
    sourceCodeEdit.Color   := SynPasSyn.SpaceAttri.Background;
  end
  else begin
    ClearSource;
    sourceCodeEdit.Enabled := false;
    sourceCodeEdit.Color   := clBtnFace;
  end;
end;

procedure TfrmMain.MRUPrfClick(Sender: TObject; LatestFile: String);
begin
  if (openProfile = nil) or (openProfile.FileName <> LatestFile) or loadCanceled then
  try
    if not FileExists(LatestFile) then
      raise Exception.Create('File '+LatestFile+ ' not found.');
    LoadProfile(LatestFile);
  except on e:Exception do
    if ShowErrorYesNo('Error while loading file "'+LatestFile+'"'+slinebreak+'Delete it from the MRU list ?') = mrYes then
    begin
      MRUPrf.DeleteFromMenu(LatestFile);
      MRUPrf.SaveToRegistry();
      MRUPrf.LoadFromRegistry();
    end;
  end;
end;

procedure TfrmMain.actInstrumentRunExecute(Sender: TObject);
begin
  actRescanChanged.Execute;
  DoInstrument;
  actRun.Execute;
end;

procedure TfrmMain.btnCancelLoadClick(Sender: TObject);
begin
  cancelLoading := true;
end;

procedure TfrmMain.LoadMetrics(layoutName: string);

  procedure GetHeaders(reg: TGpRegistry; aVST: TVirtualStringTree; prefix: string);
  var
    i: integer;
  begin
    for i := 0 to aVST.Header.Columns.Count-1 do begin
      aVST.Header.Columns[i].Width := reg.ReadInteger(prefix+'Column'+IntToStr(i)+'Width',aVST.Header.Columns[i].Width);
    end;
  end; { GetColumns }


  function CheckCorrectUIVer: boolean;
  begin
    with TGpRegistry.Create do
      try
        RootKey := HKEY_CURRENT_USER;
        OpenKey(cregistryUI, True);
        if ReadString('UIVer','') = cUIVersion then
          Result := True
        else begin
          CloseKey;
          DeleteKey(cRegistryUI);
          LoadLayouts;
          Result := False;
        end;
      finally
        Free;
      end;
  end; { CheckCorrectUIVer }

var
  reg: TGpRegistry;
  wp : TWindowPlacement;
begin
  DisableAlign;
  try
    CheckCorrectUIVer;
    reg := TGpRegistry.Create;
    try
      with reg do begin
        RootKey := HKEY_CURRENT_USER;
        OpenKey(cRegistryUI+'\'+layoutName,true);
        WindowState := TWindowState(ReadInteger('WindowState', 0));
        wp.Length := SizeOf(TWindowPlacement);
        if GetWindowPlacement(frmMain.Handle,@wp) then begin
          wp.rcNormalPosition.Left   := ReadInteger('FormLeft',wp.rcNormalPosition.Left);
          wp.rcNormalPosition.Top    := ReadInteger('FormTop',wp.rcNormalPosition.Top);
          wp.rcNormalPosition.Right  := ReadInteger('FormRight',wp.rcNormalPosition.Right);
          wp.rcNormalPosition.Bottom := ReadInteger('FormBottom',wp.rcNormalPosition.Bottom);
          SetWindowPlacement(frmMain.Handle,@wp);
        end;
        FInstrumentationFrame.pnlUnits.Width   := ReadInteger('pnlUnitsWidth',FInstrumentationFrame.pnlUnits.Width);
        FInstrumentationFrame.pnlClasses.Width := ReadInteger('pnlClassesWidth',FInstrumentationFrame.pnlClasses.Width);
        pnlSourcePreview.Height := ReadInteger('Panel2Height',pnlSourcePreview.Height);
        previewVisibleInstr     := ReadBool('previewVisibleInstr',true);
        previewVisibleAnalysis  := ReadBool('previewVisibleAnalysis',true);
        FProfilingFrame.pnlCallers.Height       := ReadInteger('pnlCallersHeight',FProfilingFrame.pnlCallers.Height);
        FProfilingFrame.pnlCallees.Height       := ReadInteger('pnlCalleesHeight',FProfilingFrame.pnlCallees.Height);
        FProfilingFrame.splitCallers.Visible    := ReadBool('pnlCalleesVisible',false);
        FProfilingFrame.splitCallees.Visible    := ReadBool('pnlCallersVisible',false);
        FProfilingFrame.pnlCallees.Visible      := FProfilingFrame.splitCallers.Visible;
        FProfilingFrame.pnlCallers.Visible      := FProfilingFrame.splitCallees.Visible;
        FProfilingFrame.pnlBottom.Top           := 99999;
        if PageControl1.ActivePage = tabInstrumentation
          then pnlSourcePreview.Visible := previewVisibleInstr
          else pnlSourcePreview.Visible := previewVisibleAnalysis;
        splitSourcePreview.Visible := pnlSourcePreview.Visible;
        GetHeaders(reg,FProfilingFrame.vstProcs,'lvProcs');
        GetHeaders(reg,FProfilingFrame.vstClasses,'lvClasses');
        GetHeaders(reg,FProfilingFrame.vstUnits,'lvUnits');
        GetHeaders(reg,FProfilingFrame.vstThreads,'lvThreads');
        GetHeaders(reg,FProfilingFrame.vstCallers,'lvCallers');
        GetHeaders(reg,FProfilingFrame.vstCallees,'lvCallees');
        ResetSourcePreview(false);
        FProfilingFrame.ResetCallers;
        FProfilingFrame.ResetCallees;
      end;
    finally reg.Free; end;
  finally EnableAlign; end;
  Application.ProcessMessages;
  SlidersMoved;
  TGpRegistryTools.SetPref(cRegistryUIsub,'Layout',layoutName);
  activeLayout := layoutName;
end; { TfrmMain.LoadMetrics }

procedure TfrmMain.UseDelphiSettings(delphiVer: integer);
var
  s      : TStringList;
  setting: integer;
  i      : integer;
  verch  : char;
begin
  s := TStringList.Create;
  try
    FillInDelphiVersions(s);
    verch := Chr(delphiVer+Ord('0'));
    setting := s.Count-1;
    for i := 0 to s.Count-2 do
      if s[i][1] = verch then begin
        setting := i;
        break;
      end;
    SynPasSyn.UseUserSettings(setting);
    SetSource;
    sourceCodeEdit.Invalidate;
  finally s.Free; end;
end;



procedure TfrmMain.WMDropFiles(var aMsg: TMessage);
var
  LDragNDropHandler : TDragNDropHandler;
  LFilename : string;
begin
  LDragNDropHandler := TDragNDropHandler.Create(aMsg.WParam);
  try
    LDragNDropHandler.DetermineDroppedFiles();
    for LFilename in LDragNDropHandler.Filenames do
    begin
      if LFilename.EndsWith('.dpr', true) then
      begin
        LoadProject(LFilename);
        Break;
      end
      else if LFilename.EndsWith('.prf', True) then
      begin
        LoadProfile(LFilename);
        Break;
      end;
    end;
  finally
    LDragNDropHandler.free;
  end;
end;

{ TfrmMain.UseDelphiSettings }

procedure TfrmMain.FormShow(Sender: TObject);

const
  first: boolean = true;

  procedure ParseCommandLine;
  var
    defDelphi: string;
    ddel     : string;
    delphiVer: integer;
    dpkName  : string;
  begin
    if ParamCount <> 0 then begin
      defDelphi := '';
      delphiVer := 0;
      if ParamCount >= 1 then begin
        ddel := ParamStr(ParamCount);
        if UpperCase(Copy(ddel,1,8)) = '/DELPHI=' then begin
          ddel := ButFirst(ddel,8);
          if (Length(ddel) > 0) and (CharInSet(ddel[1],['2'..'9'])) then
          begin
            defDelphi := ddel;
            delphiVer := Ord(ddel[1])-Ord('0');
          end;
        end;
      end;
      UseDelphiSettings(delphiVer);
      if (ParamCount > 1) or (defDelphi = '') then begin
        dpkName := ChangeFileExt(ParamStr(1),'.dpk');
        if FileExists(dpkName)
          then LoadProject(dpkName,defDelphi)
          else LoadProject(ChangeFileExt(ParamStr(1),'.dpr'),defDelphi);
      end;
    end
    else begin
      UseDelphiSettings(0);
      SetSource;
    end;
  end; { ParseCommandLine }

begin
  if first then begin
    first := false;
    LoadMetrics(inpLayoutName.Text);
    FillDelphiVer;
    if (ParamCount = 1) and (UpperCase(ParamStr(1)) = '/FIRSTTIME') then begin
      frmAbout.Left := Left+((Width-frmAbout.Width) div 2);
      frmAbout.Top := Top+((Height-frmAbout.Height) div 2);
      frmAbout.ShowModal;
    end
    else ParseCommandLine;
    if HasParameter('/REMOVEINST') then begin
      actRemoveInstrumentation.Execute;
      actRun.Execute;
      Application.Terminate;
    end;
  end;
end;

procedure TfrmMain.StatusBarResize(Sender: TObject);
begin
  with StatusBar do begin
    if storedPanel1Width = 0
      then storedPanel1Width := Width-Panels[0].Width // first time
      else Panels[0].Width := Width-storedPanel1Width;
  end;
end;

procedure TfrmMain.actHideNotExecutedExecute(Sender: TObject);
begin
  actHideNotExecuted.Checked := not actHideNotExecuted.Checked;
  FProfilingFrame.FillViews;
  SetProfilePref('HideNotExecuted', actHideNotExecuted.Checked);
end;

procedure TfrmMain.actProjectOptionsExecute(Sender: TObject);
begin
  with frmPreferences do
  begin
    if ExecuteProjectSettings(FInstrumentationFrame.chkShowAll.Checked) then
    begin
      FInstrumentationFrame.chkShowAll.Checked := cbShowAllFolders.Checked;
      RebuildDelphiVer;
      if DefinesChanged then
        actRescanProject.Execute;
    end;
  end;
end;

function TfrmMain.ReplaceMacros(s: string): string;

  function GetDelphiXE2Var(const aVarName: string): string;
  begin
    if lowercase(aVarName) = 'platform' then Result:= 'Win32';
    if lowercase(aVarName) = 'config' then Result:= 'Release';
  end;

  function GetEnvVar(const aVarName: String): String;
  var
    vSize: Integer;
  begin
    Result := '';
    vSize := GetEnvironmentVariable(PChar(aVarName), nil, 0);
    if vSize > 0 then
    begin
      SetLength(Result, vSize);
      GetEnvironmentVariable(PChar(aVarName), PChar(Result), vSize);
      // Cut out #0 char
      if Result <> '' then
        Result := Copy(Result, 1, Length(Result)-1);
    end;
  end;

var
  vMacroValue: String;
  vMacros: array of String;
  vInMacro: Boolean;
  vMacroSt: Integer;
  i, p: Integer;
begin
  Result := s;

  // First, build full macros list from Search Path (macro is found by $(MacroName))
  vMacros := nil;
  vMacroSt := -1;
  vInMacro := False;
  for i := 1 to Length(Result) do
    if Copy((Result+' '), i, 2) = '$(' then
    begin
      vInMacro := True;
      vMacroSt := i;
    end
    else if vInMacro and (Result[i] = ')') then
    begin
      vInMacro := False;

      // Get macro name (without round brackets: $( ) )
      p := Length(vMacros);
      SetLength(vMacros, p+1);
      vMacros[p] := Copy(Result, vMacroSt+2, i-1-(vMacroSt+2)+1);
    end;

  for i := 0 to High(vMacros) do
  begin
    // NB! Paths from DCC_UnitSearchPath element of *.dproj file are already added,
    // so simply skip this macro
    if AnsiUpperCase(vMacros[i]) = 'DCC_UNITSEARCHPATH' then
      Continue;

    vMacroValue := GetEnvVar(vMacros[i]);
    if (vMacroValue = '') then vMacroValue:= GetDelphiXE2Var(vMacros[i]);
    // ToDo: Not all macros are possible to get throug environment variables
    // Neet to find out, how to resolve the rest macros
    if vMacroValue <> '' then
      Result := StringReplace(Result, '$(' + vMacros[i] + ')', vMacroValue, [rfReplaceAll]);
  end;
end; { TfrmMain.ReplaceMacros }

function TfrmMain.GetSearchPath(const aProject: string): string;
var
  vPath: string;
  vDofFN: TFileName;
  vDProjFN: TFileName;
  vBdsProjFN: TFileName;
  vDProj: TDProj;
  vBdsProj: TBdsProj;
  vOldCurDir: String;
  vFullPath: String;
  i: Integer;
begin
  vPath := '';

  // Get settings from obsolete dof-file
  vDofFN := ChangeFileExt(aProject, '.dof');
  if FileExists(vDofFN) then
    with TIniFile.Create(vDofFN) do
    try
      vPath := ReadString('Directories', 'SearchPath', '');
    finally
      Free;
    end;

  // Get settings from dproj-file
  vDProjFN := ChangeFileExt(aProject, '.dproj');
  if FileExists(vDProjFN) then
  begin
    vDProj := TDProj.Create(vDProjFN);
    try
      vPath := IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + vDProj.SearchPath;
    finally
      vDProj.Free;
    end;
  end;

  // Get settings from bdsproj-file
  vBdsProjFN := ChangeFileExt(aProject, '.bdsproj');
  if FileExists(vBdsProjFN) then
  begin
    vBdsProj := TBdsProj.Create(vBdsProjFN);
    try
      vPath := IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + vBdsProj.SearchPath;
    finally
      vBdsProj.Free;
    end;
  end;

  // Get settings from registry
  with TGpRegistry.Create do begin
    try
      //Path for Delphi XE2-XE3
      RootKey:= HKEY_CURRENT_USER;
      if OpenKeyReadOnly('HKEY_CURRENT_USER\Software\Embarcadero\BDS\'+DelphiVerToBDSVer(selectedDelphi)+'\Library\Win32') then begin
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('Search Path','');
        CloseKey;
      end;

      // Path for Delphi 2009-XE
      RootKey := HKEY_CURRENT_USER;
      if OpenKeyReadOnly('SOFTWARE\Embarcadero\BDS\' + DelphiVerToBDSVer(selectedDelphi) + '\Library') then
      begin
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('Search Path','');
        CloseKey;
      end;

      // Path for Delphi 2005-2007
      RootKey := HKEY_CURRENT_USER;
      if OpenKeyReadOnly('SOFTWARE\Borland\BDS\' + DelphiVerToBDSVer(selectedDelphi) + '\Library') then
      begin
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('Search Path','');
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('SearchPath','');
        CloseKey;
      end;

      // Path for Delphi 2-7
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('SOFTWARE\Borland\Delphi\'+selectedDelphi+'\Library') then
      begin
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('SearchPath','');
        vPath := vPath + IfThen((vPath <> '') and (vPath[Length(vPath)] <> ';'), ';') + ReadString('Search Path','');
        CloseKey;
      end;
    finally
      Free;
    end;
  end;

  // Substitute macros (environment variables) with their real values
  vPath := ReplaceMacros(vPath);

  // Transform all search paths into absolute
  Result := '';
  vOldCurDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFileDir(aProject)) then
    Assert(False);
  try
    for i := 1 to NumElements(vPath, ';', -1) do
    begin
      vFullPath := ExpandUNCFileName(NthEl(vPath, i, ';', -1));
      if DirectoryExists(vFullPath) then
        Result := Result + IfThen(Result <> '', ';') + vFullPath;
    end;
  finally
    SetCurrentDir(vOldCurDir);
  end;
end;


{ TfrmMain.GetSearchPath }

function TfrmMain.GetOutputDir(const aProject: string): string;
const
  cPlatform = '$(Platform)';
  cConfig = '$(Config)';
var
  vDProj: TDProj;
  vDProjFN: TFileName;
  vDofFN: TFileName;
  vBdsProjFN: TFileName;
  vBdsProj: TBdsProj;
  vOldCurDir: String;
begin
  Result := '';

  vDProjFN := ChangeFileExt(aProject, '.dproj');
  if FileExists(vDProjFN) then
  begin
    vDProj := TDProj.Create(vDProjFN);
    try
      Result := vDProj.OutputDir;
    finally
      vDProj.Free;
    end;
  end
  else begin
    vDofFN := ChangeFileExt(aProject, '.dof');
    if FileExists(vDofFN) then
      with TIniFile.Create(vDofFN) do
      try
        Result := ReadString('Directories', 'OutputDir', '');
      finally
        Free;
      end
    else begin
      vBdsProjFN := ChangeFileExt(aProject, '.bdsproj');
      if FileExists(vBdsProjFN) then
      begin
        vBdsProj := TBdsProj.Create(vBdsProjFN);
        try
          Result := vBdsProj.OutputDir;
        finally
          vBdsProj.Free;
        end
      end;
    end;
  end;

  Result := ReplaceMacros(Result);

  // If getting output dir was not successful - use project dir as output dir
  if Result = '' then
    Result := ExtractFilePath(aProject);

  // Transform path to absolute
  if not IsAbsolutePath(Result) then
  begin
    vOldCurDir := GetCurrentDir;
    try
      if not SetCurrentDir(ExtractFileDir(aProject)) then
        Assert(False);
      Result := ExpandUNCFileName(Result);
    finally
      SetCurrentDir(vOldCurDir)
    end;
  end;
  ProjectOutputDir := result;
end; { TfrmMain.GetOutputDir }

procedure TfrmMain.actRescanProfileExecute(Sender: TObject);
begin
  LoadProfile(openProfile.FileName);
end;

procedure TfrmMain.CloseDelphiHandles;
begin
  with delphiProcessInfo do begin
    if hProcess <> 0 then begin
      CloseHandle(hProcess);
      CloseHandle(hThread);
      hProcess := 0;
      hThread  := 0;
    end;
    delphiThreadID   := 0;
    delphiAppWindow  := 0;
    delphiEditWindow := 0;
  end;
end;


procedure TfrmMain.LoadSource(const fileName: string; focusOn: integer);
begin
  try
    if fileName <> '' then
    begin
      if fileName <> loadedSource then
      begin
        sourceCodeEdit.Lines.LoadFromFile(fileName);
        loadedSource := fileName;
      end;
      if focusOn < 0 then focusOn := 0;
      if focusOn >= sourceCodeEdit.Lines.Count then focusOn := sourceCodeEdit.Lines.Count-1;
      sourceCodeEdit.TopLine := focusOn+1;
      StatusPanel0(fileName,true);
    end;
  except sourceCodeEdit.Lines.Clear; end;
end; { TfrmMain.LoadSource }

procedure TfrmMain.ClearSource;
begin
  sourceCodeEdit.Lines.Clear;
  loadedSource := '';
  StatusPanel0('',true);
end; { TfrmMain.ClearSource }

procedure TfrmMain.actExportProfileExecute(Sender: TObject);
begin
  with frmExport do begin
    cbProcedures.Checked := true;
    cbClasses.Checked    := true;
    cbUnits.Checked      := true;
    cbThreads.Checked    := true;
    QueryExport;
  end;
end;

procedure TfrmMain.mnuExportProfileClick(Sender: TObject);
begin
  with frmExport do begin
    cbProcedures.Checked := false;
    cbClasses.Checked    := false;
    cbUnits.Checked      := false;
    cbThreads.Checked    := false;
    with FProfilingFrame.PageControl2 do begin
      if      ActivePage = FProfilingFrame.tabProcedures then cbProcedures.Checked := true
      else if ActivePage = FProfilingFrame.tabClasses    then cbClasses.Checked    := true
      else if ActivePage = FProfilingFrame.tabUnits      then cbUnits.Checked      := true
      else if ActivePage = FProfilingFrame.tabThreads    then cbThreads.Checked    := true;
    end;
    QueryExport;
  end;
end;


procedure TfrmMain.QueryExport;
begin
  with frmExport do begin
    Left := frmMain.Left+((frmMain.Width-Width) div 2);
    Top := frmMain.Top+((frmMain.Height-Height) div 2);
    if ShowModal = mrOK then begin
      if inpWhere.Text <> '' then
        FProfilingFrame.ExportTo(inpWhere.Text,cbProcedures.Checked,cbClasses.Checked,
                 cbUnits.Checked,cbThreads.Checked,rbCSV.Checked);
    end;
  end;
end;

procedure TfrmMain.StatusPanel0(const msg: string; const beep: boolean);
begin
  if (msg <> '') then begin
    StatusBar.Panels[0].Text := msg;
    if beep then MessageBeep($FFFFFFFF);
  end;
end;

procedure TfrmMain.ShowError(const Msg : string);
begin
  StatusPanel0(msg,true);
  MessageDlg(msg,TMsgDlgType.mtError,[mbOK],0,mbOk);
end;


function TfrmMain.ShowErrorYesNo(const Msg : string): integer;
begin
  result := MessageDlg(msg,TMsgDlgType.mtConfirmation,[TMsgDlgBtn.mbYes ,TMsgDlgBtn.mbNo],0,mbYes);
end;

procedure TfrmMain.SlidersMoved;
begin
  FProfilingFrame.SlidersMoved;
end;

procedure TfrmMain.actMakeCopyProfileExecute(Sender: TObject);
var LSrc : string;
  LFilename : string;
begin
  try
    LFilename := ButLast(openProfile.FileName,Length(ExtractFileExt(openProfile.FileName)))+
                FormatDateTime('_ddmmyy',Now)+'.prf';
    SaveDialog1.InitialDir := ExtractFileDir(LFilename);
    SaveDialog1.FileName := ExtractFilename(LFilename);
    SaveDialog1.Title := 'Make copy of '+openProfile.FileName+'...';
    SaveDialog1.Filter := 'Profile data|*.prf|Any file|*.*';
    if SaveDialog1.Execute then begin
      if ExtractFileExt(SaveDialog1.FileName) = '' then
        SaveDialog1.FileName := SaveDialog1.FileName + '.prf';
    LSrc := openProfile.FileName;
    TFile.Copy(LSrc,SaveDialog1.FileName,true);
    MRUPrf.LatestFile := SaveDialog1.FileName;
    MRUPrf.LatestFile := openProfile.FileName;
  end;
  except on e: Exception do
    begin
      ShowError(e.Message);
    end;
  end;
end;

procedure TfrmMain.actDelUndelProfileExecute(Sender: TObject);
var
  newProj: string;
begin
  try
    if undelProject = '' then begin // delete
      undelProject := ChangeFileExt(openProfile.FileName,'.~pr');
      TFile.Move(openProfile.FileName,undelProject);
      NoProfile;
      SwitchDelMode(false);
    end
    else begin
      newProj := ChangeFileExt(undelProject,'.prf');
      TFile.Move(undelProject,newProj);
      LoadProfile(newProj);
    end;
  except on e: Exception do
    begin
      ShowError(e.Message);
    end;
  end;
end;

procedure TfrmMain.SwitchDelMode(delete: boolean);
var
  proj: string;
begin
  if delete then begin
    if undelProject <> '' then DeleteFile(undelProject);
    undelProject := '';
    with actDelUndelProfile do begin
      Caption := '&Delete';
      ImageIndex := 14;
      Hint := 'Delete profile';
    end;
  end
  else begin
    with actDelUndelProfile do begin
      proj := ChangeFileExt(undelProject,'.prf');
      Caption := 'Un&delete '+proj;
      ImageIndex := 15;
      Hint := 'Undelete '+proj;
    end;
  end;
end;

procedure TfrmMain.actRenameMoveProfileExecute(Sender: TObject);
var
  LFilename : string;
begin
  try
    LFilename := ButLast(openProfile.FileName,Length(ExtractFileExt(openProfile.FileName)))+
                FormatDateTime('_ddmmyy',Now)+'.prf';
    SaveDialog1.InitialDir := ExtractFileDir(LFilename);
    SaveDialog1.FileName := ExtractFilename(LFilename);
    SaveDialog1.Title := 'Rename/Move '+openProfile.FileName+'...';
    SaveDialog1.Filter := 'Profile data|*.prf|Any file|*.*';
    if SaveDialog1.Execute then begin
      if ExtractFileExt(SaveDialog1.FileName) = '' then
        SaveDialog1.FileName := SaveDialog1.FileName + '.prf';
      TFile.Move(openProfile.FileName,SaveDialog1.FileName);
      openProfile.Rename(SaveDialog1.FileName);
      currentProfile := ExtractFileName(SaveDialog1.FileName);
      SetCaption;
      MRUPrf.LatestFile := SaveDialog1.FileName;
    end;
  except on e: Exception do
    begin
      ShowError(e.Message);
    end
  end;
end;

procedure TfrmMain.ResetProfile();
begin
  FProfilingFrame.resetprofile();
  FreeAndNil(openProfile);
end;

procedure TfrmMain.NoProfile;
begin
  ResetProfile();
  FProfilingFrame.FillThreadCombos;
  currentProfile := '';
  PageControl1.ActivePage := tabInstrumentation;
  PageControl1Change(self);
  SetCaption;
  SetSource;
  FProfilingFrame.FillViews(1);
  FProfilingFrame.ClearBreakdown;
  actHideNotExecuted.Enabled   := false;
  actRescanProfile.Enabled     := false;
  actExportProfile.Enabled     := false;
  FProfilingFrame.mnuExportProfile.Enabled     := false;
  actRenameMoveProfile.Enabled := false;
  actMakeCopyProfile.Enabled   := false;
  actProfileOptions.Enabled    := false;
  DisablePC2;
end;

procedure TfrmMain.actRescanChangedExecute(Sender: TObject);
begin
  RescanProject;
end;

procedure TfrmMain.AppShortcut(var Msg: TWMKey; var Handled: boolean);
begin
  if msg.CharCode = 112 then
    if frmAbout.Visible then Application.HelpContext(_WhatisGpProfile)
    else if frmPreferences.Visible then begin
      if not frmPreferences.tabInstrumentation.TabVisible then Application.HelpContext(_Options2)
      else if not frmPreferences.tabAnalysis.TabVisible then Application.HelpContext(_Options1)
      else Application.HelpContext(_Preferences);
    end
    else if frmExport.Visible then Application.HelpContext(_Export)
    else if pnlLayout.Visible then Application.HelpContext(_LayoutManager)
    else if PageControl1.ActivePage = tabInstrumentation then Application.HelpContext(_Instrumentation3)
    else Application.HelpContext(_Analysis3);
end; { TfrmMain.AppShortcut }

procedure TfrmMain.RescanProject;
begin
  if openProject = nil then
    Exit;

  if (not GetProjectPref('UseFileDate', prefUseFileDate)) or
    openProject.AnyChange(false) then
  begin
    FInstrumentationFrame.RescanProject(ParseProject);
    SetSource;
  end;
end;

procedure TfrmMain.actChangeLayoutExecute(Sender: TObject);
begin
  if (not pnlLayout.Visible) or
     (UpperCase(activeLayout) <> UpperCase(lvLayouts.Selected.Caption))
    then SaveMetrics(activeLayout);
  inpLayoutName.Text := lvLayouts.Selected.Caption;
  LoadMetrics(inpLayoutName.Text);
  RebuildLayoutPopup(true);
  SetChangeLayout(true);
end;

procedure TfrmMain.actLayoutManagerExecute(Sender: TObject);
begin
  pnlLayout.Visible := not pnlLayout.Visible;
end;

procedure TfrmMain.actLoadInstrumentationSelectionExecute(Sender: TObject);
var
  LFilename : String;
begin
  if openProject = nil then
    Exit;
  LFilename := ChangeFileExt(openProject.Name,TUIStrings.GPProfInstrumentationSelectionExt);
  OpenDialog.DefaultExt := 'gis';
  OpenDialog.FileName := ExtractFilename(LFilename);
  OpenDialog.InitialDir := ExtractFileDir(LFilename);
  OpenDialog.Filter := TUIStrings.InstrumentationSelectionFilter();
  OpenDialog.Title := 'Load instrumentation selection...';
  if OpenDialog.Execute then
  begin
    openProject.LoadInstrumentalizationSelection(OpenDialog.FileName);
    // an auto-click is done... ignore instrumentation upon select
    FInstrumentationFrame.TriggerSelectionReload;
  end;
end;

procedure TfrmMain.SpeedButton1Click(Sender: TObject);
begin
  pnlLayout.Hide;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
  FProfilingFrame.RepositionSliders;
end;


procedure TfrmMain.lbLayoutsClick(Sender: TObject);
begin
  if assigned(lvLayouts.Selected)
    then inpLayoutName.Text := lvLayouts.Selected.Caption;
end;

procedure TfrmMain.actAddLayoutUpdate(Sender: TObject);
begin
  actAddLayout.Enabled := ((inpLayoutName.Text <> '') and
                           (not IsLayout(inpLayoutName.Text)));
end;

procedure TfrmMain.actRenameLayoutUpdate(Sender: TObject);
begin
  actRenameLayout.Enabled := ((lvLayouts.Selected <> nil) and
                              (inpLayoutName.Text <> '') and
                              (not IsLayout(inpLayoutName.Text)) and
                              (lvLayouts.Selected.ImageIndex <> 1));
end;

procedure TfrmMain.actChangeLayoutUpdate(Sender: TObject);
begin
  actChangeLayout.Enabled := ((not pnlLayout.Visible) or
                              ((lvLayouts.Selected <> nil) and
                               (lvLayouts.Selected.ImageIndex <> 1)));
end;

procedure TfrmMain.actDelLayoutUpdate(Sender: TObject);
begin
  actDelLayout.Enabled := (lvLayouts.Selected <> nil);
end;

procedure TfrmMain.inpLayoutNameKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = '\' then Key := #0
  else if Key = #13 then begin
    actAddLayout.Execute;
    pnlLayout.Hide;
  end;
end;

procedure TfrmMain.actDelLayoutExecute(Sender: TObject);
var
  idx: integer;
begin
  if lvLayouts.Selected.ImageIndex = 1 then begin
    lvLayouts.Selected.ImageIndex := 0;
    RebuildLayoutPopup(false);
  end
  else begin
    activeLayout := '';
    lvLayouts.Selected.ImageIndex := 1;
    idx := lvLayouts.Items.IndexOf(lvLayouts.Selected);
    Inc(idx);
    if idx >= lvLayouts.Items.Count then idx := 0;
    if idx < lvLayouts.Items.Count then begin
      lvLayouts.Selected := lvLayouts.Items[idx];
      inpLayoutName.Text := lvLayouts.Items[idx].Caption;
    end
    else inpLayoutName.Text := '';
    RebuildLayoutPopup(true);
    if idx < lvLayouts.Items.Count then actChangeLayout.Execute;
  end;
  with actDelLayout do begin
    if lvLayouts.Selected.ImageIndex = 1 then begin
      Caption := 'Undelete';
      Hint    := 'Undelete layout';
    end
    else begin
      Caption := 'Delete';
      Hint    := 'Delete layout';
    end;
  end;
end;

procedure TfrmMain.actAddLayoutExecute(Sender: TObject);
begin
  SaveMetrics(activeLayout);
  lvLayouts.Selected := lvLayouts.Items.Add;
  lvLayouts.Selected.Caption := inpLayoutName.Text;
  activeLayout := inpLayoutName.Text;
  RebuildLayoutPopup(true);
end;

procedure TfrmMain.lbLayoutsDblClick(Sender: TObject);
begin
  if lvLayouts.Selected.ImageIndex <> 1 then begin
    inpLayoutName.Text := lvLayouts.Selected.Caption;
    actChangeLayout.Execute;
    pnlLayout.Hide;
  end;
end;

procedure TfrmMain.lbLayoutsKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    if lvLayouts.Selected <> nil then lbLayoutsDblClick(Sender);
end;

procedure TfrmMain.actRenameLayoutExecute(Sender: TObject);
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      MoveKey(cRegistryUI+'\'+lvLayouts.Selected.Caption, cRegistryUI+'\'+inpLayoutName.Text,true);
    finally
      Free;
    end;

  lvLayouts.Selected.Caption := inpLayoutName.Text;
  RebuildLayoutPopup(true);
end;

procedure TfrmMain.actHelpAboutExecute(Sender: TObject);
begin
  frmAbout.Left := Left+((Width-frmAbout.Width) div 2);
  frmAbout.Top := Top+((Height-frmAbout.Height) div 2);
  frmAbout.ShowModal;
end;

procedure TfrmMain.actHelpShortcutKeysExecute(Sender: TObject);
begin
  WinHelp(Handle,PChar(Application.HelpFile+'>Proc'),HELP_CONTEXT,_Shortcutkeys);
end;

procedure TfrmMain.lvLayoutsSelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  with actDelLayout do begin
    if Item.ImageIndex = 1 then begin
      Caption := 'Undelete';
      Hint    := 'Undelete layout';
    end
    else begin
      Caption := 'Delete';
      Hint    := 'Delete layout';
    end;
  end;
  with actChangeLayout do begin
    SetChangeLayout(Item.ImageIndex = 2);
  end;
end;

procedure TfrmMain.SetChangeLayout(setRestore: boolean);
begin
  with actChangeLayout do begin
    if setRestore then begin
      Caption := 'Restore';
      Hint    := 'Restore layout';
    end
    else begin
      Caption := 'Activate';
      Hint    := 'Activate layout';
    end;
  end;
end; { TfrmMain.SetChangeLayout }

procedure TfrmMain.actHelpContentsExecute(Sender: TObject);
begin
  Application.HelpCommand(HELP_FINDER,0);
end;

procedure TfrmMain.actHelpQuickStartExecute(Sender: TObject);
begin
  Application.HelpContext(_Handson);
end;



procedure TfrmMain.actShowHideSourcePreviewExecute(Sender: TObject);
begin
  pnlSourcePreview.Visible := not pnlSourcePreview.Visible;
  splitSourcePreview.Visible := pnlSourcePreview.Visible;
  if PageControl1.ActivePage = tabInstrumentation
    then previewVisibleInstr := pnlSourcePreview.Visible
    else previewVisibleAnalysis := pnlSourcePreview.Visible;
  ResetSourcePreview(true);
  if FProfilingFrame.pnlCallers.Height > FProfilingFrame.pnlTopTwo.Height then
    FProfilingFrame.pnlCallers.Height := FProfilingFrame.pnlTopTwo.Height div 2;
end;

procedure TfrmMain.actShowHideCallersExecute(Sender: TObject);
begin
  if FProfilingFrame.pnlCallers.Visible then begin
    FProfilingFrame.pnlCallers.Hide;
    FProfilingFrame.splitCallers.Hide;
  end
  else begin
    FProfilingFrame.splitCallers.Show;
    FProfilingFrame.pnlCallers.Show;
  end;
  FProfilingFrame.ResetCallers;
end;

procedure TfrmMain.actShowHideCallersUpdate(Sender: TObject);
begin
  actShowHideCallers.Enabled := (PageControl1.ActivePage = tabAnalysis) and
                                (FProfilingFrame.PageControl2.ActivePage = FProfilingFrame.tabProcedures);
end;

procedure TfrmMain.actSaveInstrumentationSelectionExecute(Sender: TObject);
var
  LFilename : string;
begin
  if openProject = nil then
    Exit;
  try
    LFilename := ChangeFileExt(openProject.Name,TUIStrings.GPProfInstrumentationSelectionExt);
    SaveDialog1.FileName := ExtractFileName(LFilename);
    SaveDialog1.InitialDir := ExtractFileDir(LFilename);
    SaveDialog1.Title := TUIStrings.SaveInstrumentationSelectionCaption;
    SaveDialog1.Filter := TUIStrings.InstrumentationSelectionFilter;
    if SaveDialog1.Execute then begin
      if ExtractFileExt(SaveDialog1.FileName) = '' then
        SaveDialog1.FileName := SaveDialog1.FileName + TUIStrings.GPProfInstrumentationSelectionExt;
    openProject.SaveInstrumentalizationSelection(SaveDialog1.FileName);
  end;
    except on e: Exception do
    begin
      ShowError(e.Message);
    end;
  end;
end;

procedure TfrmMain.actShowHideCalleesExecute(Sender: TObject);
begin
  if FProfilingFrame.pnlCallees.Visible then begin
    FProfilingFrame.pnlCallees.Hide;
    FProfilingFrame.splitCallees.Hide;
  end
  else begin
    FProfilingFrame.pnlCallees.Show;
    FProfilingFrame.splitCallees.Show;
  end;
  FProfilingFrame.pnlCallees.Top := 99999;
  FProfilingFrame.pnlBottom.Top := 99999;
  FProfilingFrame.ResetCallees;
end;

procedure TfrmMain.actShowHideCalleesUpdate(Sender: TObject);
begin
  actShowHideCallees.Enabled := (PageControl1.ActivePage = tabAnalysis) and
                                (FProfilingFrame.PageControl2.ActivePage = FProfilingFrame.tabProcedures);
end;


procedure TfrmMain.lvCalleesClick(Sender: TObject);
begin
  if assigned(openProfile) and (Sender is TListView) and assigned((Sender as TListView).Selected) then
    with openProfile do
      LoadSource(resUnits[resProcedures[integer((Sender as TListView).Selected.Data)].peUID].FilePath,
                 resProcedures[integer((Sender as TListView).Selected.Data)].peFirstLn);
end;

procedure TfrmMain.splitCallersMoved(Sender: TObject);
begin
  SlidersMoved;
end;



end.
