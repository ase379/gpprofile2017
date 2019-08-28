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
    fCancelPressed : boolean;
    fProgressTaskbar : TTaskbar;
    procedure setMarquee(const Value: boolean);
    procedure setCancel(const Value: boolean);
    function getText: string;
    procedure setText(const Value: string);
    function getPercentage: Integer;
    procedure setPercentage(const Value: Integer);
    { Private declarations }
  public
    constructor Create(AOwner: TComponent);override;
    property Marquee : boolean read fMarquee write setMarquee;
    property Cancel : boolean read fCancel write setCancel;
    property Text : string read getText write setText;
    property CancelPressed : boolean read fCancelPressed;
    property Percentage : Integer read getPercentage write setPercentage;
    property ProgressTaskbar : TTaskBar read fProgressTaskbar write fProgressTaskbar;
  end;


  procedure InitProgressBar(const aOwner : TForm;const aTaskBar : TTaskbar;const aMessage : string;const aMarquee, aCancel: Boolean);
  procedure SetProgressBarPause();
  procedure SetProgressBarError();
  procedure SetProgressBarOverlayHint(const aHint : string);
  procedure ShowProgressBar();
  procedure HideProgressBar();


var
  frmLoadProgress: TfrmLoadProgress;

implementation

uses
  System.Win.ComObj;

{ global helpers }

procedure InitProgressBar(const aOwner : TForm;const aTaskBar : TTaskbar;const aMessage : string;const aMarquee, aCancel: Boolean);
begin
  if not assigned(frmLoadProgress) then
    frmLoadProgress := TfrmLoadProgress.Create(aOwner);
  frmLoadProgress.ProgressTaskbar := aTaskBar;
  frmLoadProgress.Marquee := aMarquee;
  frmLoadProgress.Cancel := aCancel;
  frmLoadProgress.Text := aMessage;
end;

procedure ShowProgressBar();
begin
  frmLoadProgress.Show;
end;

procedure SetProgressBarPercent(const aValue : Integer);
begin
  if assigned(frmLoadProgress.ProgressTaskbar) then
  begin
    frmLoadProgress.ProgressTaskbar.ProgressValue := aValue;
  end;
end;


procedure SetProgressBarPause();
begin
  if assigned(frmLoadProgress.ProgressTaskbar) then
    frmLoadProgress.ProgressTaskbar.ProgressState := TTaskBarProgressState.Paused;
end;

procedure SetProgressBarError();
begin
  if assigned(frmLoadProgress.ProgressTaskbar) then
    frmLoadProgress.ProgressTaskbar.ProgressState := TTaskBarProgressState.Error;
end;

procedure SetProgressBarOverlayHint(const aHint : string);
begin
  if assigned(frmLoadProgress.ProgressTaskbar) then
    frmLoadProgress.ProgressTaskbar.OverlayHint := aHint;

end;

procedure HideProgressBar();
begin
  frmLoadProgress.setMarquee(False);
  frmLoadProgress.Percentage := 0;
  if assigned(frmLoadProgress.ProgressTaskbar) then
    frmLoadProgress.ProgressTaskbar.ProgressState := TTaskBarProgressState.None;
  FreeAndNil(frmLoadProgress);
end;

{$R *.DFM}

procedure TfrmLoadProgress.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Hide;
end;

function TfrmLoadProgress.getPercentage: Integer;
begin
  result := frmLoadProgress.ProgressBar1.Position;
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
    if assigned(ProgressTaskbar) then
      ProgressTaskbar.ProgressState := TTaskBarProgressState.Indeterminate;
    ProgressBar1.Style := TProgressBarStyle.pbstMarquee;
  end
  else
  begin
    if assigned(ProgressTaskbar) then
    begin
      ProgressTaskbar.ProgressState := TTaskBarProgressState.Normal;
      ProgressTaskbar.ProgressMaxValue := 100;
    end;
    ProgressBar1.Style := TProgressBarStyle.pbstNormal;
  end;
end;

procedure TfrmLoadProgress.setPercentage(const Value: Integer);
begin
  ProgressBar1.Position := Value;
  if Assigned(ProgressTaskbar) then
  begin
    ProgressTaskbar.ProgressValue := ProgressTaskbar.ProgressValue+1;
    if ProgressTaskbar.ProgressValue >= ProgressTaskbar.ProgressMaxValue then
      ProgressTaskbar.ProgressValue := ProgressTaskbar.ProgressMaxValue;
  end;
end;

procedure TfrmLoadProgress.btnCancelLoadClick(Sender: TObject);
begin
  fCancelPressed := true;
  Hide;
end;

procedure TfrmLoadProgress.MarqueeTimerTimer(Sender: TObject);
begin
  if ProgressTaskbar.ProgressState <> TTaskBarProgressState.Indeterminate then
  begin
    ProgressTaskbar.ProgressValue := ProgressTaskbar.ProgressValue+1;
    if ProgressTaskbar.ProgressValue >= ProgressTaskbar.ProgressMaxValue then
      ProgressTaskbar.ProgressValue := 0;
  end;
end;

constructor TfrmLoadProgress.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  if aOwner is TForm then
  begin
    Left := TForm(AOwner).Left+((TForm(AOwner).Width-Width) div 2);
    Top := TForm(AOwner).Top+((TForm(AOwner).Height-Height) div 2);
  end;
end;


end.
