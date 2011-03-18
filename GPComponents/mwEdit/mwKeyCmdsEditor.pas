{$I MWEDIT.INC}

unit mwKeyCmdsEditor;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, mwKeyCmds, Menus, StdCtrls;

type
  TmwKeystrokesEditorForm = class(TForm)
    KeyCmdList: TListView;
    btnAdd: TButton;
    btnEdit: TButton;
    btnDelete: TButton;
    btnOK: TButton;
    btnCancel: TButton;
    btnReset: TButton;
    procedure FormResize(Sender: TObject);
    procedure btnAddClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure btnDeleteClick(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FKeystrokes: TmwKeystrokes;
    procedure SetKeystrokes(const Value: TmwKeystrokes);
    procedure UpdateKeystrokesList;
    procedure WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo); message WM_GETMINMAXINFO;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Keystrokes: TmwKeystrokes read FKeystrokes write SetKeystrokes;
  end;

implementation

{$R *.DFM}

uses
  mwKeyCmdEditor;

{ TmwKeystrokesEditorForm }

constructor TmwKeystrokesEditorForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKeystrokes := NIL;
end;

destructor TmwKeystrokesEditorForm.Destroy;
begin
  FKeystrokes.Free;
  inherited Destroy;
end;

procedure TmwKeystrokesEditorForm.SetKeystrokes(const Value: TmwKeystrokes);
begin
  if FKeystrokes = NIL then
    FKeystrokes := TmwKeystrokes.Create(Self);
  FKeystrokes.Assign(Value);
  UpdateKeystrokesList;
end;

procedure TmwKeystrokesEditorForm.UpdateKeystrokesList;
var
  x: integer;
begin
  KeyCmdList.Items.BeginUpdate;
  try
    KeyCmdList.Items.Clear;
    for x := 0 to FKeystrokes.Count-1 do
    begin
      with KeyCmdList.Items.Add do
      begin
        Caption := EditorCommandToCodeString(FKeystrokes[x].Command);
        if FKeystrokes[x].ShortCut = 0 then
          SubItems.Add('<none>')
        else
          SubItems.Add(Menus.ShortCutToText(FKeystrokes[x].ShortCut));
      end;
    end;
  finally
    KeyCmdList.Items.EndUpdate;
  end;
end;

procedure TmwKeystrokesEditorForm.FormResize(Sender: TObject);
var
  x: integer;
begin
  for x := 0 to ControlCount-1 do
    if Controls[x] is TButton then
    begin
      Controls[x].Left := ClientWidth - Controls[x].Width - 7;
      if Controls[x] = btnOK then
        Controls[x].Top := ClientHeight - (Controls[x].Height * 2) - 10;
      if Controls[x] = btnCancel then
        Controls[x].Top := ClientHeight - Controls[x].Height - 3;
    end else if Controls[x] is TListView then
    begin
      Controls[x].Width := ClientWidth - 96;
      Controls[x].Height := ClientHeight - 8;
    end;
end;

procedure TmwKeystrokesEditorForm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
  inherited;
  Msg.MinMaxInfo.ptMinTrackSize := Point(300, 225);
end;

procedure TmwKeystrokesEditorForm.btnAddClick(Sender: TObject);
var
  NewStroke: TmwKeystroke;
begin
  with TmwKeystrokeEditorForm.Create(Self) do
    try
      Command := ecNone;
      Keystroke := 0;
      if ShowModal = mrOK then
      begin
        NewStroke := FKeystrokes.Add;
        NewStroke.Command := Command;
        try
          NewStroke.ShortCut := Keystroke;
        except
          on EmwKeyError do
            begin
              // Shortcut already exists in the collection!
              MessageDlg('The keystroke "' + Menus.ShortCutToText(Keystroke) +
                 '" is already assigned to another editor command.', mtError,
                 [mbOK], 0);
              NewStroke.Free;
              exit;
            end;
          // Some other kind of exception, we don't deal with it...
        end;

        with KeyCmdList.Items.Add do
        begin
          Caption := EditorCommandToCodeString(NewStroke.Command);
          if NewStroke.ShortCut = 0 then
            SubItems.Add('<none>')
          else
            SubItems.Add(Menus.ShortCutToText(NewStroke.ShortCut));
        end;
      end;
    finally
      Free;
    end;
end;

procedure TmwKeystrokesEditorForm.btnEditClick(Sender: TObject);
var
  SelItem: TListItem;
  OldShortcut: TShortcut;
begin
  SelItem := KeyCmdList.Selected;
  if SelItem = NIL then
  begin
    MessageBeep(1);
    exit;
  end;
  with TmwKeystrokeEditorForm.Create(Self) do
    try
      Command := FKeystrokes[SelItem.Index].Command;
      Keystroke := FKeystrokes[SelItem.Index].Shortcut;
      if ShowModal = mrOK then
      begin
        FKeystrokes[SelItem.Index].Command := Command;
        OldShortCut := FKeystrokes[SelItem.Index].ShortCut;
        try
          FKeystrokes[SelItem.Index].ShortCut := Keystroke;
        except
          on EmwKeyError do
            begin
              // Shortcut already exists in the collection!
              MessageDlg('The keystroke "' + Menus.ShortCutToText(Keystroke) +
                 '" is already assigned to another editor command.'#13#10 +
                 'The short cut for this item has not been changed.', mtError,
                 [mbOK], 0);
              FKeystrokes[SelItem.Index].ShortCut := OldShortCut;
            end;
          // Some other kind of exception, we don't deal with it...
        end;

        KeyCmdList.Items.BeginUpdate;
        try
          with SelItem do
          begin
            Caption := EditorCommandToCodeString(FKeystrokes[Index].Command);
            if FKeystrokes[Index].ShortCut = 0 then
              SubItems[0] := '<none>'
            else
              SubItems[0] := Menus.ShortCutToText(FKeystrokes[Index].Shortcut);
          end;
        finally
          KeyCmdList.Items.EndUpdate;
        end;
      end;
    finally
      Free;
    end;
end;

procedure TmwKeystrokesEditorForm.btnDeleteClick(Sender: TObject);
var
  SelItem: TListItem;
begin
  SelItem := KeyCmdList.Selected;
  if SelItem = NIL then
  begin
    MessageBeep(1);
    exit;
  end;
  FKeystrokes[SelItem.Index].Free;
  KeyCmdList.Items.Delete(SelItem.Index);
end;


procedure TmwKeystrokesEditorForm.btnResetClick(Sender: TObject);
begin
  FKeystrokes.ResetDefaults;
  UpdateKeystrokesList;
end;

procedure TmwKeystrokesEditorForm.FormCreate(Sender: TObject);
begin
  {$IFDEF MWE_COMPILER_3_UP}
  KeyCmdList.RowSelect := TRUE;
  {$ENDIF}
end;

end.
