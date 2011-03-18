unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm2 = class(TForm)
    lbKeywords: TListBox;
    btnLoad: TButton;
    btnClose: TButton;
    OpenDialog1: TOpenDialog;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    procedure btnLoadClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.btnLoadClick(Sender: TObject);
begin
  if OpenDialog1.Execute then
    lbKeywords.Items.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm2.btnDeleteClick(Sender: TObject);
begin
  if lbKeywords.ItemIndex <> -1 then
    lbKeywords.Items.Delete(lbKeywords.ItemIndex);
end;

procedure TForm2.btnAddClick(Sender: TObject);
var
  val: string;
begin
  val := Inputbox('Add Reserved Word', 'Reserved Word:', '');
  if val <> '' then
    lbKeywords.Items.Add(val);
end;

procedure TForm2.btnEditClick(Sender: TObject);
var
  val: string;
begin
  if lbKeywords.ItemIndex <> -1 then begin
    val := Inputbox('Edit Reserved Word', 'Reserved Word:', lbKeywords.Items[lbKeywords.ItemIndex]);
    if val <> lbKeywords.Items[lbKeywords.ItemIndex] then
      lbKeywords.Items.Add(val);
  end;
end;

end.

