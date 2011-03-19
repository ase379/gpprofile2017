{$I MWEDIT.INC}

unit mwKeyCmdEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, mwKeyCmds, Menus;

type
  TmwKeystrokeEditorForm = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    cmbCommand: TComboBox;
    hkKeystroke: THotKey;
    btnOK: TButton;
    btnCancel: TButton;
    bntClearKey: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure bntClearKeyClick(Sender: TObject);
  private
    procedure SetCommand(const Value: TmwEditorCommand);
    procedure SetKeystroke(const Value: TShortcut);
    procedure AddEditorCommand(const S: string);
    function GetCommand: TmwEditorCommand;
    function GetKeystroke: TShortcut;
  public
    property Command: TmwEditorCommand read GetCommand write SetCommand;
    property Keystroke: TShortcut read GetKeystroke write SetKeystroke;
  end;

var
  mwKeystrokeEditorForm: TmwKeystrokeEditorForm;

implementation

{$R *.DFM}

{ TForm2 }

procedure TmwKeystrokeEditorForm.SetCommand(const Value: TmwEditorCommand);
begin
  cmbCommand.Text := EditorCommandToCodeString(Value);
end;

procedure TmwKeystrokeEditorForm.SetKeystroke(const Value: TShortcut);
begin
  hkKeystroke.Hotkey := Value;
end;

procedure TmwKeystrokeEditorForm.FormCreate(Sender: TObject);
begin
  GetEditorCommandValues(AddEditorCommand);
end;

procedure TmwKeystrokeEditorForm.AddEditorCommand(const S: string);
begin
  cmbCommand.Items.Add(S);
end;

function TmwKeystrokeEditorForm.GetCommand: TmwEditorCommand;
var
  NewCmd: longint;
begin
  if not IdentToEditorCommand(cmbCommand.Text, NewCmd) then
  begin
     try
       NewCmd := StrToInt(cmbCommand.Text);
     except
       NewCmd := ecNone;
     end;
  end;
  Result := NewCmd;
end;

function TmwKeystrokeEditorForm.GetKeystroke: TShortcut;
begin
  Result := hkKeystroke.HotKey;
end;

procedure TmwKeystrokeEditorForm.FormKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
  // THotKey uses backspace to remove the current keystroke.  That would prevent
  // us from assigning backspace to anything.  We have to handle it here.
  if (Key = VK_BACK) and (hkKeystroke.Focused) then
  begin
    hkKeystroke.HotKey := Menus.ShortCut(Key, Shift);
    Key := 0;  // Eat the key so THotKey doesn't get it.
  end;
end;

procedure TmwKeystrokeEditorForm.bntClearKeyClick(Sender: TObject);
begin
  hkKeystroke.HotKey := 0;
end;

end.
