{$I OPTIONS.INC}

unit gppAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons;

type
  TfrmAbout = class(TForm)
    Panel1: TPanel;
    Image1: TImage;
    lblVersion: TLabel;
    Label3: TLabel;
    Bevel3: TBevel;
    Image2: TImage;
    Bevel1: TBevel;
    Label11: TLabel;
    oxGraphicButton1: TBitBtn;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure urlHandsOnClick(Sender: TObject);
    procedure urlF1Click(Sender: TObject);
  private
  public
  end;

var
  frmAbout: TfrmAbout;

implementation

uses
  GpVersion,
  GpIFF;      

{$R *.DFM}

{$I HELP.INC}

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  verInfo: TGpVersionInfo;
begin
  verInfo := TGpVersionInfo.Create(ParamStr(0));
  try
    lblVersion.Caption := Format(lblVersion.Caption,[verInfo.GetVersion(verFullDotted)]);
    if verInfo.IsPrivateBuild then lblVersion.Caption := lblVersion.Caption + ' internal';
    if verInfo.IsPrerelease then lblVersion.Caption := lblVersion.Caption + ' beta';
  finally verInfo.Free; end;
end; { TfrmAbout.FormCreate }

procedure TfrmAbout.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then ModalResult := mrOK;
end; { TfrmAbout.FormKeyPress }

procedure TfrmAbout.urlHandsOnClick(Sender: TObject);
begin
  Application.HelpContext(_Handson);
end; { TfrmAbout.urlHandsOnClick }

procedure TfrmAbout.urlF1Click(Sender: TObject);
begin
  Application.HelpContext(_WhatisGpProfile);
end; { urlF1Click }

end.
