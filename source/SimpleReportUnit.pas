unit SimpleReportUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, StdActns, ActnList, XPStyleActnCtrls, ActnMan,
  Menus, ImgList, ComCtrls;

type
  TfmSimpleReport = class(TForm)
    reReport: TRichEdit;
    ActionManager1: TActionManager;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    procedure btCloseClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
  public
    class function Execute(const aCaption: String; const vReport: TStrings;
      aDoShow: Boolean = True): TfmSimpleReport;
    function Lines: TStrings;
  end;

implementation

{$R *.dfm}

{ TfmSimpleReport }

class function TfmSimpleReport.Execute(const aCaption: String; const vReport: TStrings;
  aDoShow: Boolean = True): TfmSimpleReport;
begin
  Result := TfmSimpleReport.Create(Application.MainForm);
  // If main form is MDI => report is either,
  // else - normal form
  if aDoShow then
    if Application.MainForm.FormStyle = fsMDIForm then
      Result.FormStyle := fsMDIChild;
  with Result do
  try
    Caption := aCaption;
    reReport.Lines.Assign(vReport);
    reReport.CaretPos := Point(0, 0);
    SendMessage(reReport.Handle, EM_SCROLLCARET, 0, 0);
    if aDoShow and (Result.FormStyle <> fsMDIChild) then
      Result.Show;
  except
    Free;
    raise;
  end;
end;

procedure TfmSimpleReport.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfmSimpleReport.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then
    Close;
  if (Key = VK_RETURN) and (Shift = [ssCtrl]) then
    Close;
end;

procedure TfmSimpleReport.btCloseClick(Sender: TObject);
begin
  Close;
end;

function TfmSimpleReport.Lines: TStrings;
begin
  Result := reReport.Lines;
end;

end.
