{$I OPTIONS.INC}

unit gppExport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TfrmExport = class(TForm)
    grpWhat: TGroupBox;
    grpWhere: TGroupBox;
    cbProcedures: TCheckBox;
    cbClasses: TCheckBox;
    cbUnits: TCheckBox;
    cbThreads: TCheckBox;
    grpHow: TGroupBox;
    rbCSV: TRadioButton;
    rbTXT: TRadioButton;
    inpWhere: TEdit;
    btnBrowse: TButton;
    btnExport: TButton;
    btnCancel: TButton;
    SaveDialog1: TSaveDialog;
    expSelectThreadProc: TComboBox;
    procedure rbCSVClick(Sender: TObject);
    procedure btnBrowseClick(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure cbThreadsClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmExport: TfrmExport;

implementation

{$R *.DFM}

procedure TfrmExport.rbCSVClick(Sender: TObject);
const
  exit: boolean = false;
begin
  if not exit then begin
    exit := true;
    if sender = rbCSV
      then rbTXT.Checked := not rbCSV.Checked
      else rbCSV.Checked := not rbTXT.Checked;
    if rbCSV.Checked
      then SaveDialog1.Filter := 'CSV - comma delimited (*.csv)|*.csv|Any file|*.*'
      else SaveDialog1.Filter := 'TXT - tab delimited (*.txt)|*.txt|Any file|*.*';
    exit := false;
  end;
end;

procedure TfrmExport.btnBrowseClick(Sender: TObject);
begin
  if SaveDialog1.Execute then begin
    inpWhere.Text := SaveDialog1.FileName;
    if ExtractFileExt(inpWhere.Text) = '' then
      if rbCSV.Checked
        then inpWhere.Text := inpWhere.Text + '.csv'
        else inpWhere.Text := inpWhere.Text + '.txt';
  end;
end;

procedure TfrmExport.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then ModalResult := mrCancel;
end;

procedure TfrmExport.cbThreadsClick(Sender: TObject);
begin
  if expSelectThreadProc.Items.Count > 3
    then expSelectThreadProc.Enabled := cbThreads.Checked;
end;

end.
