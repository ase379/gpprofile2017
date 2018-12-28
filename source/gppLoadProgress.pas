{$I OPTIONS.INC}

unit gppLoadProgress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, System.Win.TaskbarCore, Vcl.Taskbar,
  winapi.shlobj;

type
  TfrmLoadProgress = class(TForm)
    pnlLoadResults: TPanel;
    ProgressBar1: TProgressBar;
    btnCancelLoad: TButton;
    Label1: TLabel;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelLoadClick(Sender: TObject);
    procedure MarqueeTimerTimer(Sender: TObject);
  private
    fMarquee : boolean;
    fCancel : Boolean;
    Taskbar1 : TTaskbar;
    procedure setMarquee(const Value: boolean);
    procedure setCancel(const Value: boolean);
    function getText: string;
    procedure setText(const Value: string);
    { Private declarations }
  public
    constructor Create(AOwner: TComponent);override;
    destructor Destroy; override;
    property Marquee : boolean read fMarquee write setMarquee;
    property Cancel : boolean read fCancel write setCancel;
    property Text : string read getText write setText;
  end;


  procedure ShowProgressBar(const aOwner : TForm;const aMessage : string;const aMarquee, aCancel: Boolean);
  procedure HideProgressBar();


var
  frmLoadProgress: TfrmLoadProgress;

implementation

uses
  System.Win.ComObj;

{ global helpers }

procedure ShowProgressBar(const aOwner : TForm;const aMessage : string;const aMarquee, aCancel: Boolean);
begin
  if not assigned(frmLoadProgress) then
    frmLoadProgress := TfrmLoadProgress.Create(aOwner);
  frmLoadProgress.Left := aOwner.Left+((aOwner.Width-frmLoadProgress.Width) div 2);
  frmLoadProgress.Top := aOwner.Top+((aOwner.Height-frmLoadProgress.Height) div 2);
  frmLoadProgress.Marquee := aMarquee;
  frmLoadProgress.Cancel := aCancel;
  frmLoadProgress.Text := aMessage;
  frmLoadProgress.Show;
  Application.ProcessMessages;
end;

procedure HideProgressBar();
begin
  FreeAndNil(frmLoadProgress);
end;

{$R *.DFM}

procedure TfrmLoadProgress.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Hide;
end;

function TfrmLoadProgress.getText: string;
begin
  result := Label1.Caption;
end;

procedure TfrmLoadProgress.setText(const Value: string);
begin
  Label1.Caption := value;
end;

procedure TfrmLoadProgress.setCancel(const Value: boolean);
begin
  fCancel := Value;
  if fCancel then
    btnCancelLoad.Show
  else
    btnCancelLoad.Hide;
end;

procedure TfrmLoadProgress.setMarquee(const Value: boolean);
begin
  fMarquee := Value;
  if fMarquee then
  begin
    Taskbar1.ProgressState := TTaskBarProgressState.Indeterminate;
    ProgressBar1.Style := TProgressBarStyle.pbstMarquee;
  end
  else
  begin
    Taskbar1.ProgressState := TTaskBarProgressState.Normal;
    ProgressBar1.Style := TProgressBarStyle.pbstNormal;
  end;
end;

procedure TfrmLoadProgress.btnCancelLoadClick(Sender: TObject);
begin
  Hide;
end;

procedure TfrmLoadProgress.MarqueeTimerTimer(Sender: TObject);
begin
  if Taskbar1.ProgressState <> TTaskBarProgressState.Indeterminate then
  begin
    Taskbar1.ProgressValue := Taskbar1.ProgressValue+1;
    if Taskbar1.ProgressValue >= Taskbar1.ProgressMaxValue then
    Taskbar1.ProgressValue := 0;
  end;
end;

constructor TfrmLoadProgress.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  Taskbar1 := TTaskbar.Create(aOwner);
  Taskbar1.ProgressState := TTaskBarProgressState.None;
end;

destructor TfrmLoadProgress.Destroy;
begin
  Taskbar1.ProgressState := TTaskBarProgressState.None;
  Taskbar1.free;
  inherited;
end;

end.
