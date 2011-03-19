{+-----------------------------------------------------------------------------+
 | Created:     31.03.99
 | Last change: 1999-05-10
 | Author:      Olivier Deckmyn
 | Description: This simple component implements editing rules to apply to a
 |              python source file. Python has a unusual way to mark blocks
 |              (like begin/end in pascal) : it uses indentation. So the rule is
 |              after a ":" and a line break, we have to indent once.
 |
 | Version:     0.12 (see version.rtf for version history)
 | Copyright (c) 1998 Olivier Deckmyn
 | No rights reserved.
 |
 | Thanks to: Martin Waldenburg (as usual ;-) ), Primoz Gabrijelcic
 +----------------------------------------------------------------------------+}
unit odPythonBehaviour;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  mwCustomEdit, mwKeyCmds;

const
  ecPythonIndent = ecUserFirst + 1974;

type

  TodPythonBehaviour = class(TComponent)
  private
    { Déclarations privées }
    FEditor : TmwCustomEdit;
    FFormerKeyPress : TKeyPressEvent;
    FFormProcessUserCommand : TProcessCommandEvent;
    fIndent: integer;                                                           //gp 1999-05-10
  protected
    { Déclarations protégées }
    procedure SetEditor(Value: TmwCustomEdit); virtual;
    procedure doKeyPress(Sender: TObject; var Key: Char); virtual;
    procedure doProcessUserCommand(var Command: TmwEditorCommand; var AChar: Char; Data: Pointer); virtual;
  public
    { Déclarations publiques }
    procedure Loaded; override;
    procedure AttachFormerEvents;
    constructor Create(aOwner : TComponent); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    { Déclarations publiées }
    property Editor: TmwCustomEdit read FEditor write SetEditor;
    property Indent: integer read fIndent write fIndent default 4;              //gp 1999-05-10
  end;

procedure Register;

implementation

procedure TodPythonBehaviour.SetEditor(Value: TmwCustomEdit);
begin
  if FEditor <> Value then
  begin
    // First restore the former event handlers, if any
    if not (csDesigning in ComponentState) and not (csLoading in ComponentState) and assigned(FEditor)then
    begin
      if assigned(FFormerKeyPress) then
      begin
        FEditor.OnKeypress := FFormerKeyPress;
        FFormerKeyPress := nil;
      end;
      if assigned(FFormProcessUserCommand) then
      begin
        FEditor.OnProcessUserCommand := FFormProcessUserCommand;
        FFormProcessUserCommand := nil;
      end;
    end;
    // Set the new editor
    FEditor := Value;
    // Attach the new event handlers
    if not (csDesigning in ComponentState) and not (csLoading in ComponentState) then AttachFormerEvents;
  end;
end;  // SetEditor

procedure TodPythonBehaviour.doKeyPress(Sender: TObject; var Key: Char);
var
  i    : integer;
  lLine: String;
begin
  if assigned(FFormerKeyPress) then FFormerKeyPress(Sender, Key);

  if assigned(FEditor) and (Key=#13) then
  begin
    lLine := Trim(FEditor.Lines[FEditor.CaretY-2]);
    if Copy(lLine, Length(lLine),1)=':' then begin
      for i := 1 to fIndent do
        FEditor.CommandProcessor(ecPythonIndent, #0, nil);
    end;
  end;

end;

procedure TodPythonBehaviour.doProcessUserCommand(var Command: TmwEditorCommand; var AChar: Char; Data: Pointer);
begin
  if assigned(FFormProcessUserCommand) then FFormProcessUserCommand(Command, aChar, Data);

  if Command=ecPythonIndent then
  begin
    Command := ecChar;
    aChar := ' ';
  end;
end;

procedure TodPythonBehaviour.Loaded;
begin
  inherited Loaded;                                                             //gp 1999-05-06
  if not (csDesigning in ComponentState) then
  begin
    AttachFormerEvents;
  end;
end;

procedure TodPythonBehaviour.AttachFormerEvents;
begin
  if assigned(FEditor) then
  begin
    FFormerKeyPress := FEditor.OnKeyPress;
    FFormProcessUserCommand := FEditor.OnProcessUserCommand;
    FEditor.OnKeyPress := doKeyPress;
    FEditor.OnProcessUserCommand := doProcessUserCommand;
  end;
end;

constructor TodPythonBehaviour.Create(aOwner: TComponent);
begin
  inherited Create(AOwner);
  FFormerKeyPress := nil;
  FFormProcessUserCommand := nil;
  fIndent := 4;
end;

procedure Register;
begin
  RegisterComponents('mw', [TodPythonBehaviour]);
end;

procedure TodPythonBehaviour.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  if (Operation=opRemove) and (aComponent=FEditor)then
  FEditor := nil;    
end;

end.
