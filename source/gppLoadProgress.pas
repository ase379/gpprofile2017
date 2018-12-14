{$I OPTIONS.INC}

unit gppLoadProgress;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;

type
  TfrmLoadProgress = class(TForm)
    pnlLoadResults: TPanel;
    ProgressBar1: TProgressBar;
    btnCancelLoad: TButton;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure btnCancelLoadClick(Sender: TObject);
  private
    fMarquee : boolean;
    fCancel : Boolean;
    procedure setMarquee(const Value: boolean);
    procedure setCancel(const Value: boolean);
    { Private declarations }
  public
    property Marquee : boolean read fMarquee write setMarquee;
    property Cancel : boolean read fCancel write setCancel;
  end;

var
  frmLoadProgress: TfrmLoadProgress;

implementation

{$R *.DFM}

procedure TfrmLoadProgress.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Hide;
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
    ProgressBar1.Style := TProgressBarStyle.pbstMarquee
  else
    ProgressBar1.Style := TProgressBarStyle.pbstNormal;
end;

procedure TfrmLoadProgress.btnCancelLoadClick(Sender: TObject);
begin
  Hide;
end;

end.
