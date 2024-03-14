{$I OPTIONS.INC}

unit gppPrfPlaceholderDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, ActnList, ShellAPI, ShlObj,
  System.Actions, System.ImageList;

type

  TfrmPreferenceMacros = class(TForm)
    Panel1: TPanel;
    oxButton1: TButton;
    oxButton2: TButton;
    Panel2: TPanel;
    lbAvailableMacros: TLabel;
    cbAvailableMacros: TComboBox;
  private
     fIsGlobalPreferenceDialog : boolean;
  public
    function Execute: boolean;
    function GetSelectedMacro(): string;
    property IsGlobalPreferenceDialog : boolean read fIsGlobalPreferenceDialog write fIsGlobalPreferenceDialog;
  end;

var
  frmPreferenceMacros: TfrmPreferenceMacros;

implementation

uses
  gpPrfPlaceholders;

{$R *.DFM}

{ TfrmPreferenceMacros }

function TfrmPreferenceMacros.Execute: boolean;
var
  LPrfSet : TPrfPlaceholderTypeSet;
  LPrf : TPrfPlaceholderType;

begin
  cbAvailableMacros.Clear;
  if IsGlobalPreferenceDialog then
  begin
    LPrfSet := TPrfPlaceholder.GetPrfPlaceholderProjectMacros();
    for LPrf in LPrfSet do
      cbAvailableMacros.AddItem(TPrfPlaceholder.PrfPlaceholderToMacro(lPrf), Pointer(lPrf));
  end;
  LPrfSet := TPrfPlaceholder.GetPrfPlaceholderRuntimeMacros();
  for LPrf in LPrfSet do
    cbAvailableMacros.AddItem(TPrfPlaceholder.PrfPlaceholderToMacro(lPrf), Pointer(lPrf));
  if cbAvailableMacros.GetCount > 0 then
    cbAvailableMacros.ItemIndex := 0;
  result := ShowModal = mrOk;
end;

function TfrmPreferenceMacros.GetSelectedMacro: string;
begin
  result := cbAvailableMacros.text;
end;

end.
