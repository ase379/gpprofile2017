{$I OPTIONS.INC}

unit gppAbout;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls, Buttons;

type
  TfrmAbout = class(TForm)
    Panel1: TPanel;         
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    Image1: TImage;
    lblVersion: TLabel;
    Label3: TLabel;
    Bevel3: TBevel;
    Image2: TImage;
    Bevel1: TBevel;
    Label11: TLabel;
    TabSheet4: TTabSheet;
    RichEdit1: TRichEdit;
    TabSheet5: TTabSheet;
    RichEdit2: TRichEdit;
    Label4: TLabel;
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
{$R BAGGAGE.RES}

{$I HELP.INC}
{$I BAGGAGE.INC} // IDD_WHATSNEW, IDD_OPENSOURCE

procedure TfrmAbout.FormCreate(Sender: TObject);
var
  verInfo: TGpVersionInfo;
  stream : TResourceStream;
begin
  PageControl1.ActivePage := TabSheet1;
  verInfo := TGpVersionInfo.Create(ParamStr(0));
  try
    lblVersion.Caption := Format(lblVersion.Caption,[verInfo.GetVersion(IFF(verInfo.IsDebug,verFullDotted,verShort2to3))]);
    if verInfo.IsPrivateBuild then lblVersion.Caption := lblVersion.Caption + ' internal';
    if verInfo.IsPrerelease then lblVersion.Caption := lblVersion.Caption + ' beta';
  finally verInfo.Free; end;
  stream := TResourceStream.CreateFromID(HInstance, IDD_WHATSNEW, RT_RCDATA);
  try RichEdit1.Lines.LoadFromStream(stream);
  finally stream.Free; end;
  stream := TResourceStream.CreateFromID(HInstance, IDD_OPENSOURCE, RT_RCDATA);
  try RichEdit2.Lines.LoadFromStream(stream);
  finally stream.Free; end;
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
