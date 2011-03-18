{$I OPTIONS.INC}

unit gppCallGraph;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  gppResults, ToolWin, ComCtrls, ExtCtrls, Menus, StdCtrls;

type
  TfrmCallGraph = class(TForm)
    Panel3: TPanel;
    pnlGraph: TPanel;
    tbrGraph: TToolBar;
    ToolButton1: TToolButton;
    MainMenu1: TMainMenu;
    CallGraph1: TMenuItem;
    Close1: TMenuItem;
    Graph1: TMenuItem;
    Zoomingetc1: TMenuItem;
    Item1: TMenuItem;
    Jumpto1: TMenuItem;
    N1: TMenuItem;
    Expandcollapsemovewhatever1: TMenuItem;
    Help1: TMenuItem;
    pnlItem: TPanel;
    tbrItem: TToolBar;
    ToolButton2: TToolButton;
    tbrHelp: TPanel;
    ToolBar1: TToolBar;
    ToolButton3: TToolButton;
    PopupMenu1: TPopupMenu;
    JumptoView1: TMenuItem;
    Panel2: TPanel;
    lblSelectThreadProc: TLabel;
    cbxSelectThreadCG: TComboBox;
    pnlBrowser: TPanel;
    ToolBar3: TToolBar;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    StatusBar: TStatusBar;
    lblInfo: TLabel;
    procedure Close1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Jumpto1Click(Sender: TObject);
    procedure cbxSelectThreadCGChange(Sender: TObject);
  private
    FLoadedProfile: TResults;
    procedure LoadProfile(profileName: string; profileData: TResults);
  public
    procedure ReloadProfile(profileName: string; profileData: TResults);
    procedure ClearProfile;
    procedure ZoomOnProcedure(procedureID,threadID: integer);
  end;

var
  frmCallGraph: TfrmCallGraph;

implementation

uses
  gppMain;

{$R *.DFM}

{ TfrmCallGraph }

procedure TfrmCallGraph.ClearProfile;
begin
  // do the cleanup
  lblInfo.Caption := 'No profile loaded';
  //
  Caption := 'GpProfile Call Graph Analyzer';
  FLoadedProfile := nil;
end;

procedure TfrmCallGraph.LoadProfile(profileName: string;
  profileData: TResults);
begin
  Caption := 'GpProfile Call Graph Analyzer - '+ExtractFileName(profileName);
  FLoadedProfile := profileData;
  // do the loading
  lblInfo.Caption := 'Loaded profile: '+ExtractFileName(profileName);
  //
end;

procedure TfrmCallGraph.ZoomOnProcedure(procedureID, threadID: integer);
begin
  lblInfo.Caption := Format('ZoomOnProcedure(%d,%d)',[procedureID,threadID]);
end;

procedure TfrmCallGraph.Close1Click(Sender: TObject);
begin
  Hide;
end;

procedure TfrmCallGraph.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure TfrmCallGraph.Jumpto1Click(Sender: TObject);
begin
//  frmMain.ZoomOnProcedure(selectedProcedureID, selectedThreadID);
  frmMain.ZoomOnProcedure(1,cbxSelectThreadCG.ItemIndex); 
end;

procedure TfrmCallGraph.ReloadProfile(profileName: string;
  profileData: TResults);
begin
  if assigned(FLoadedProfile) and (FLoadedProfile <> profileData) then ClearProfile;
  LoadProfile(profileName,profileData);
end;

procedure TfrmCallGraph.cbxSelectThreadCGChange(Sender: TObject);
begin
// new thread selected, redraw graph!
end;

end.
