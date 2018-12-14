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
    procedure setMarquee(const Value: boolean);
    { Private declarations }
  public
    property Marquee : boolean read fMarquee write setMarquee;
  end;

var
  frmLoadProgress: TfrmLoadProgress;

implementation

{$R *.DFM}

procedure TfrmLoadProgress.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Hide;
end;

procedure TfrmLoadProgress.setMarquee(const Value: boolean);
const
  PBS_MARQUEE = $08;
  PBM_SETMARQUEE = WM_USER + 10;
var
  LOn : Integer;
  LNewStyle : NativeInt;
begin
  fMarquee := Value;
  LNewStyle := GetWindowLong(ProgressBar1.Handle, GWL_STYLE);
  LOn := Integer(FMarquee);

  if fMarquee then
  begin
    LNewStyle := LNewStyle Or PBS_MARQUEE;
  end
  else
  begin
    LNewStyle := LNewStyle AND PBS_MARQUEE;
  end;
  SetWindowLong(ProgressBar1.Handle, GWL_STYLE, LNewStyle Or PBS_MARQUEE);
  SendMessage(ProgressBar1.Handle, PBM_SETMARQUEE, LOn, 40);
end;

procedure TfrmLoadProgress.btnCancelLoadClick(Sender: TObject);
begin
  Hide;
end;

end.
