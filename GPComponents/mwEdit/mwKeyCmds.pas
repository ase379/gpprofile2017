{$I MWEDIT.INC}                                                                 //bds 1998-12-29 added

{$DEFINE MWE_SELECTION_MODE}

{
  Version: 0.11 (see VERSION.RTF for version history)

  Thanks to: Brad Stowers, Hideo Koiso
}

unit mwKeyCmds;

interface

uses
  Classes, Menus, SysUtils;

const
  //****************************************************************************
  // NOTE!  If you add an editor command, you must also update the
  //    EditorCommandStrs constant array in implementation section below, or the
  //    command will not show up in the IDE.
  //****************************************************************************

  // "Editor Commands".  Key strokes are translated from a table into these
  // I used constants instead of a set so that additional commands could be
  // added in descendants (you can't extend a set)
  ecNone            = 0;    // Nothing.  Useful for user event to handle command

  ecLeft            = 1;    // Move cursor left one char
  ecRight           = 2;    // Move cursor right one char
  ecUp              = 3;    // Move cursor up one line
  ecDown            = 4;    // Move cursor down one line
  ecWordLeft        = 5;    // Move cursor left one word
  ecWordRight       = 6;    // Move cursor right one word
  ecLineStart       = 7;    // Move cursor to beginning of line
  ecLineEnd         = 8;    // Move cursor to end of line
  ecPageUp          = 9;    // Move cursor up one page
  ecPageDown        = 10;   // Move cursor down one page
  ecPageLeft        = 11;   // Move cursor right one page
  ecPageRight       = 12;   // Move cursor left one page
  ecPageTop         = 13;   // Move cursor to top of page
  ecPageBottom      = 14;   // Move cursor to bottom of page
  ecEditorTop       = 15;   // Move cursor to absolute beginning
  ecEditorBottom    = 16;   // Move cursor to absolute end
  ecGotoXY          = 17;   // Move cursor to specific coordinates, Data = PPoint

//******************************************************************************
// Maybe the command processor should just take a boolean that signifies if
// selection is affected or not?
//******************************************************************************

  ecSelection       = 100;  // Add this to ecXXX command to get equivalent
                            // command, but with selection enabled. This is not
                            // a command itself.
  // Same as commands above, except they affect selection, too
  ecSelLeft         = ecLeft + ecSelection;
  ecSelRight        = ecRight + ecSelection;
  ecSelUp           = ecUp + ecSelection;
  ecSelDown         = ecDown + ecSelection;
  ecSelWordLeft     = ecWordLeft + ecSelection;
  ecSelWordRight    = ecWordRight + ecSelection;
  ecSelLineStart    = ecLineStart + ecSelection;
  ecSelLineEnd      = ecLineEnd + ecSelection;
  ecSelPageUp       = ecPageUp + ecSelection;
  ecSelPageDown     = ecPageDown + ecSelection;
  ecSelPageLeft     = ecPageLeft + ecSelection;
  ecSelPageRight    = ecPageRight + ecSelection;
  ecSelPageTop      = ecPageTop + ecSelection;
  ecSelPageBottom   = ecPageBottom + ecSelection;
  ecSelEditorTop    = ecEditorTop + ecSelection;
  ecSelEditorBottom = ecEditorBottom + ecSelection;
  ecSelGotoXY       = ecGotoXY + ecSelection;  // Data = PPoint

  ecSelectAll       = 199;  // Select entire contents of editor, cursor to end

  ecDeleteLastChar  = 401;  // Delete last char (i.e. backspace key)
  ecDeleteChar      = 402;  // Delete char at cursor (i.e. delete key)
  ecDeleteWord      = 403;  // Delete from cursor to end of word
  ecDeleteLastWord  = 404;  // Delete from cursor to start of word
  ecDeleteBOL       = 405;  // Delete from cursor to beginning of line
  ecDeleteEOL       = 406;  // Delete from cursor to end of line
  ecDeleteLine      = 407;  // Delete current line
  ecClearAll        = 408;  // Delete everything
  ecLineBreak       = 409;  // Break line at current position, move caret to new line
  ecInsertLine      = 410;  // Break line at current position, leave caret
  ecChar            = 411;  // Insert a character at current position

  ecImeStr          = 500;  // Insert character(s) from IME                     //hk 1999-05-10

  ecUndo            = 601;  // Perform undo if available
  ecRedo            = 602;  // Perform redo if available
  ecCut             = 603;  // Cut selection to clipboard
  ecCopy            = 604;  // Copy selection to clipboard
  ecPaste           = 605;  // Paste clipboard to current position
  ecScrollUp        = 606;  // Scroll up one line leaving cursor position unchanged.
  ecScrollDown      = 607;  // Scroll down one line leaving cursor position unchanged.
  ecScrollLeft      = 608;  // Scroll left one char leaving cursor position unchanged.
  ecScrollRight     = 609;  // Scroll right one char leaving cursor position unchanged.
  ecInsertMode      = 610;  // Set insert mode
  ecOverwriteMode   = 611;  // Set overwrite mode
  ecToggleMode      = 612;  // Toggle ins/ovr mode
  ecBlockIndent     = 613;  // Indent selection
  ecBlockUnindent   = 614;  // Unindent selection
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1999-1-25
  ecNormalSelect    = 615;  // Normal selection mode
  ecColumnSelect    = 616;  // Column selection mode
  ecLineSelect      = 617;  // Line selection mode
{$ENDIF}                                                                        //bds 1999-1-25

  ecGotoMarker0     = 701;  // Goto marker
  ecGotoMarker1     = 702;  // Goto marker
  ecGotoMarker2     = 703;  // Goto marker
  ecGotoMarker3     = 704;  // Goto marker
  ecGotoMarker4     = 705;  // Goto marker
  ecGotoMarker5     = 706;  // Goto marker
  ecGotoMarker6     = 707;  // Goto marker
  ecGotoMarker7     = 708;  // Goto marker
  ecGotoMarker8     = 709;  // Goto marker
  ecGotoMarker9     = 710;  // Goto marker
  ecSetMarker0      = 751;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker1      = 752;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker2      = 753;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker3      = 754;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker4      = 755;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker5      = 756;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker6      = 757;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker7      = 758;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker8      = 759;  // Set marker, Data = PPoint - X, Y Pos
  ecSetMarker9      = 760;  // Set marker, Data = PPoint - X, Y Pos

  ecUserFirst       = 1001; // Start of user-defined commands

type
  EmwKeyError = class(Exception);                                               //bds 1998-12-29

  TmwEditorCommand = type word;                                                 //bds 1998-12-23

  TmwKeyStroke = class(TCollectionItem)
  private
    FKey: word;          // Virtual keycode, i.e. VK_xxx
    FShift: TShiftState;
    FCommand: TmwEditorCommand;
    procedure SetKey(const Value: word);
    procedure SetShift(const Value: TShiftState);
    function GetShortCut: TShortCut;
    procedure SetShortCut(const Value: TShortCut);
    procedure SetCommand(const Value: TmwEditorCommand);
  protected
    {$IFDEF MWE_COMPILER_3_UP}                                                  //bds 1998-12-29
    function GetDisplayName: string; override;
    {$ENDIF}
  public
    procedure Assign(Source: TPersistent); override;

    // No duplicate checking is done if assignment made via these properties!   //bds 1998-12-29
    property Key: word
       read FKey write SetKey;
    property Shift: TShiftState
       read FShift write SetShift;
  published
    property ShortCut: TShortCut
       read GetShortCut write SetShortCut;
    property Command: TmwEditorCommand
       read FCommand write SetCommand;
  end;

  TmwKeyStrokes = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(Index: Integer): TmwKeyStroke;
    procedure SetItem(Index: Integer; Value: TmwKeyStroke);
  protected
    {$IFDEF MWE_COMPILER_3_UP}                                                  //bds 1998-12-29
    function GetOwner: TPersistent; override;
    {$ENDIF}
  public
    constructor Create(AOwner: TPersistent);
    function Add: TmwKeyStroke;
    procedure Assign(Source: TPersistent); override;
    function FindCommand(Cmd: TmwEditorCommand): integer;
    function FindShortcut(SC: TShortcut): integer;
    function FindKeycode(Code: word; SS: TShiftState): integer;
    procedure ResetDefaults;                                                    //bds 1998-12-29

    property Items[Index: Integer]: TmwKeyStroke
       read GetItem write SetItem; default;
  end;

// These are mainly for the TmwEditorCommand property editor, but could be
// useful elsewhere.
function EditorCommandToDescrString(Cmd: TmwEditorCommand): string;
function EditorCommandToCodeString(Cmd: TmwEditorCommand): string;
procedure GetEditorCommandValues(Proc: TGetStrProc);
function IdentToEditorCommand(const Ident: string; var Cmd: longint): boolean;  //bds 1998-12-29
function EditorCommandToIdent(Cmd: longint; var Ident: string): boolean;        //bds 1998-12-29

implementation

uses
  Windows;

{ Command mapping routines }

{begin}                                                                         //bds 1998-12-29
{$IFDEF MWE_COMPILER_2}
// This is defined in D3/C3 and up.
type
  TIdentMapEntry = record
    Value: TmwEditorCommand;
    Name: string;
  end;
{$ENDIF}
{end}                                                                           //bds 1998-12-29

const
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1999-1-25
  EditorCommandStrs: array[0..85] of TIdentMapEntry = (                         //hk 1999-05-10
{$ELSE}                                                                         //bds 1999-1-25
  EditorCommandStrs: array[0..82] of TIdentMapEntry = (                         //hk 1999-05-10
{$ENDIF}                                                                        //bds 1999-1-25
    (Value: ecNone; Name: 'ecNone'),
    (Value: ecLeft; Name: 'ecLeft'),
    (Value: ecRight; Name: 'ecRight'),
    (Value: ecUp; Name: 'ecUp'),
    (Value: ecDown; Name: 'ecDown'),
    (Value: ecWordLeft; Name: 'ecWordLeft'),
    (Value: ecWordRight; Name: 'ecWordRight'),
    (Value: ecLineStart; Name: 'ecLineStart'),
    (Value: ecLineEnd; Name: 'ecLineEnd'),
    (Value: ecPageUp; Name: 'ecPageUp'),
    (Value: ecPageDown; Name: 'ecPageDown'),
    (Value: ecPageLeft; Name: 'ecPageLeft'),
    (Value: ecPageRight; Name: 'ecPageRight'),
    (Value: ecPageTop; Name: 'ecPageTop'),
    (Value: ecPageBottom; Name: 'ecPageBottom'),
    (Value: ecEditorTop; Name: 'ecEditorTop'),
    (Value: ecEditorBottom; Name: 'ecEditorBottom'),
    (Value: ecGotoXY; Name: 'ecGotoXY'),
    (Value: ecSelLeft; Name: 'ecSelLeft'),
    (Value: ecSelRight; Name: 'ecSelRight'),
    (Value: ecSelUp; Name: 'ecSelUp'),
    (Value: ecSelDown; Name: 'ecSelDown'),
    (Value: ecSelWordLeft; Name: 'ecSelWordLeft'),
    (Value: ecSelWordRight; Name: 'ecSelWordRight'),
    (Value: ecSelLineStart; Name: 'ecSelLineStart'),
    (Value: ecSelLineEnd; Name: 'ecSelLineEnd'),
    (Value: ecSelPageUp; Name: 'ecSelPageUp'),
    (Value: ecSelPageDown; Name: 'ecSelPageDown'),
    (Value: ecSelPageLeft; Name: 'ecSelPageLeft'),
    (Value: ecSelPageRight; Name: 'ecSelPageRight'),
    (Value: ecSelPageTop; Name: 'ecSelPageTop'),
    (Value: ecSelPageBottom; Name: 'ecSelPageBottom'),
    (Value: ecSelEditorTop; Name: 'ecSelEditorTop'),
    (Value: ecSelEditorBottom; Name: 'ecSelEditorBottom'),
    (Value: ecSelGotoXY; Name: 'ecSelGotoXY'),
    (Value: ecSelectAll; Name: 'ecSelectAll'),
    (Value: ecDeleteLastChar; Name: 'ecDeleteLastChar'),
    (Value: ecDeleteChar; Name: 'ecDeleteChar'),
    (Value: ecDeleteWord; Name: 'ecDeleteWord'),
    (Value: ecDeleteLastWord; Name: 'ecDeleteLastWord'),
    (Value: ecDeleteBOL; Name: 'ecDeleteBOL'),
    (Value: ecDeleteEOL; Name: 'ecDeleteEOL'),
    (Value: ecDeleteLine; Name: 'ecDeleteLine'),
    (Value: ecClearAll; Name: 'ecClearAll'),
    (Value: ecLineBreak; Name: 'ecLineBreak'),
    (Value: ecInsertLine; Name: 'ecInsertLine'),
    (Value: ecChar; Name: 'ecChar'),
    (Value: ecImeStr; Name: 'ecImeStr'),                                        //hk 1999-05-10
    (Value: ecUndo; Name: 'ecUndo'),
    (Value: ecRedo; Name: 'ecRedo'),
    (Value: ecCut; Name: 'ecCut'),
    (Value: ecCopy; Name: 'ecCopy'),
    (Value: ecPaste; Name: 'ecPaste'),
    (Value: ecScrollUp; Name: 'ecScrollUp'),
    (Value: ecScrollDown; Name: 'ecScrollDown'),
    (Value: ecScrollLeft; Name: 'ecScrollLeft'),
    (Value: ecScrollRight; Name: 'ecScrollRight'),
    (Value: ecInsertMode; Name: 'ecInsertMode'),
    (Value: ecOverwriteMode; Name: 'ecOverwriteMode'),
    (Value: ecToggleMode; Name: 'ecToggleMode'),
    (Value: ecBlockIndent; Name: 'ecBlockIndent'),
    (Value: ecBlockUnindent; Name: 'ecBlockUnindent'),
{$IFDEF MWE_SELECTION_MODE}                                                     //bds 1999-1-25
    (Value: ecNormalSelect; Name: 'ecNormalSelect'),
    (Value: ecColumnSelect; Name: 'ecColumnSelect'),
    (Value: ecLineSelect; Name: 'ecLineSelect'),
{$ENDIF}                                                                        //bds 1999-1-25
    (Value: ecUserFirst; Name: 'ecUserFirst'),
    (Value: ecGotoMarker0; Name: 'ecGotoMarker0'),
    (Value: ecGotoMarker1; Name: 'ecGotoMarker1'),
    (Value: ecGotoMarker2; Name: 'ecGotoMarker2'),
    (Value: ecGotoMarker3; Name: 'ecGotoMarker3'),
    (Value: ecGotoMarker4; Name: 'ecGotoMarker4'),
    (Value: ecGotoMarker5; Name: 'ecGotoMarker5'),
    (Value: ecGotoMarker6; Name: 'ecGotoMarker6'),
    (Value: ecGotoMarker7; Name: 'ecGotoMarker7'),
    (Value: ecGotoMarker8; Name: 'ecGotoMarker8'),
    (Value: ecGotoMarker9; Name: 'ecGotoMarker9'),
    (Value: ecSetMarker0; Name: 'ecSetMarker0'),
    (Value: ecSetMarker1; Name: 'ecSetMarker1'),
    (Value: ecSetMarker2; Name: 'ecSetMarker2'),
    (Value: ecSetMarker3; Name: 'ecSetMarker3'),
    (Value: ecSetMarker4; Name: 'ecSetMarker4'),
    (Value: ecSetMarker5; Name: 'ecSetMarker5'),
    (Value: ecSetMarker6; Name: 'ecSetMarker6'),
    (Value: ecSetMarker7; Name: 'ecSetMarker7'),
    (Value: ecSetMarker8; Name: 'ecSetMarker8'),
    (Value: ecSetMarker9; Name: 'ecSetMarker9'));

procedure GetEditorCommandValues(Proc: TGetStrProc);
var
  i: integer;
begin
  for i := Low(EditorCommandStrs) to High(EditorCommandStrs) do
    Proc(EditorCommandStrs[I].Name);
end;

{begin}                                                                         //bds 1998-12-29
function IdentToEditorCommand(const Ident: string; var Cmd: longint): boolean;
{$IFDEF MWE_COMPILER_2}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF MWE_COMPILER_2}
  Result := FALSE;
  for I := Low(EditorCommandStrs) to High(EditorCommandStrs) do
    if CompareText(EditorCommandStrs[I].Name, Ident) = 0 then
    begin
      Result := TRUE;
      Cmd := EditorCommandStrs[I].Value;
      break;
    end;

  {$ELSE}
{end}                                                                           //bds 1998-12-29
    Result := IdentToInt(Ident, Cmd, EditorCommandStrs);
  {$ENDIF}                                                                      //bds 1998-12-29
end;

{begin}                                                                         //bds 1998-12-29
function EditorCommandToIdent(Cmd: longint; var Ident: string): boolean;
{$IFDEF MWE_COMPILER_2}
var
  I: Integer;
{$ENDIF}
begin
  {$IFDEF MWE_COMPILER_2}
  Result := FALSE;
  for I := Low(EditorCommandStrs) to High(EditorCommandStrs) do
    if EditorCommandStrs[I].Value = Cmd then
    begin
      Result := TRUE;
      Ident := EditorCommandStrs[I].Name;
      break;
    end;
  {$ELSE}
{end}                                                                           //bds 1998-12-29
  Result := IntToIdent(Cmd, Ident, EditorCommandStrs);
  {$ENDIF}                                                                      //bds 1998-12-29
end;

function EditorCommandToDescrString(Cmd: TmwEditorCommand): string;
begin
  // Doesn't do anything yet.
  Result := '';
end;

function EditorCommandToCodeString(Cmd: TmwEditorCommand): string;
begin
  if not EditorCommandToIdent(Cmd, Result) then
    Result := IntToStr(Cmd);
end;



{ TmwKeyStroke }

procedure TmwKeyStroke.Assign(Source: TPersistent);
begin
  if Source is TmwKeyStroke then
  begin
    Key := TmwKeyStroke(Source).Key;
    Shift := TmwKeyStroke(Source).Shift;
    Command := TmwKeyStroke(Source).Command;                                    //bds 1998-12-29
  end else
    inherited Assign(Source);
end;

{$IFDEF MWE_COMPILER_3_UP}                                                      //bds 1998-12-29 - added ifdef
function TmwKeyStroke.GetDisplayName: string;
begin
  Result := EditorCommandToCodeString(Command) + ' - ' + ShortCutToText(ShortCut);
  if Result = '' then
    Result := inherited GetDisplayName;
end;
{$ENDIF}

function TmwKeyStroke.GetShortCut: TShortCut;
begin
  Result := Menus.ShortCut(Key, Shift);
end;

procedure TmwKeyStroke.SetCommand(const Value: TmwEditorCommand);
begin
  if Value <> FCommand then
    FCommand := Value;
end;

procedure TmwKeyStroke.SetKey(const Value: word);
begin
  if Value <> FKey then
    FKey := Value;
end;


procedure TmwKeyStroke.SetShift(const Value: TShiftState);
begin
  if Value <> FShift then
    FShift := Value;
end;

procedure TmwKeyStroke.SetShortCut(const Value: TShortCut);
var
  NewKey: Word;
  NewShift: TShiftState;
  Dup: integer;                                                                 //bds 1998-12-29
begin
  {begin}                                                                       //bds 1998-12-29
  // Duplicate values of no shortcut are OK.
  if Value <> 0 then
  begin
    // Check for duplicate shortcut in the collection and disallow if there is.
    Dup := TmwKeyStrokes(Collection).FindShortcut(Value);
    if (Dup <> -1) and (Dup <> Self.Index) then
      raise EmwKeyError.Create('Shortcut already exists');
  end;
  {end}                                                                         //bds 1998-12-29

  Menus.ShortCutToKey(Value, NewKey, NewShift);
  if (NewKey <> Key) or (NewShift <> Shift) then
  begin
    Key := NewKey;
    Shift := NewShift;
  end;
end;

{ TmwKeyStrokes }

function TmwKeyStrokes.Add: TmwKeyStroke;
begin
  Result := TmwKeyStroke(inherited Add);
end;

procedure TmwKeyStrokes.Assign(Source: TPersistent);
var
  x: integer;
begin
  if Source is TmwKeyStrokes then
  begin
    Clear;
    for x := 0 to TmwKeyStrokes(Source).Count-1 do
    begin
      with Add do
        Assign(TmwKeyStrokes(Source)[x]);
    end;
  end else
    inherited Assign(Source);
end;

constructor TmwKeyStrokes.Create(AOwner: TPersistent);
begin
  inherited Create(TmwKeyStroke);
  FOwner := AOwner;
end;

function TmwKeyStrokes.FindCommand(Cmd: TmwEditorCommand): integer;
var
  x: integer;
begin
  Result := -1;
  for x := 0 to Count-1 do
    if Items[x].Command = Cmd then
    begin
      Result := x;
      break;
    end;
end;

function TmwKeyStrokes.FindKeycode(Code: word; SS: TShiftState): integer;
var
  x: integer;
begin
  Result := -1;
  for x := 0 to Count-1 do
    if (Items[x].Key = Code) and (Items[x].Shift = SS) then
    begin
      Result := x;
      break;
    end;
end;

function TmwKeyStrokes.FindShortcut(SC: TShortcut): integer;
var
  x: integer;
begin
  Result := -1;
  for x := 0 to Count-1 do
    if Items[x].Shortcut = SC then
    begin
      Result := x;
      break;
    end;
end;

function TmwKeyStrokes.GetItem(Index: Integer): TmwKeyStroke;
begin
 Result := TmwKeyStroke(inherited GetItem(Index));
end;

{$IFDEF MWE_COMPILER_3_UP}                                                      //bds 1998-12-29 - added ifdef
function TmwKeyStrokes.GetOwner: TPersistent;
begin
  Result := FOwner;
end;
{$ENDIF}

{begin}                                                                         //bds 1998-12-29
procedure TmwKeyStrokes.ResetDefaults;
  procedure AddKey(const ACmd: TmwEditorCommand; const AKey: word;
     const AShift: TShiftState);
  begin
    with Add do
    begin
      Key := AKey;
      Shift := AShift;
      Command := ACmd;
    end;
  end;
begin
  Clear;

  AddKey(ecUp, VK_UP, []);
  AddKey(ecSelUp, VK_UP, [ssShift]);
  AddKey(ecScrollUp, VK_UP, [ssCtrl]);
  AddKey(ecDown, VK_DOWN, []);
  AddKey(ecSelDown, VK_DOWN, [ssShift]);
  AddKey(ecScrollDown, VK_DOWN, [ssCtrl]);
  AddKey(ecLeft, VK_LEFT, []);
  AddKey(ecSelLeft, VK_LEFT, [ssShift]);
  AddKey(ecWordLeft, VK_LEFT, [ssCtrl]);
  AddKey(ecSelWordLeft, VK_LEFT, [ssShift,ssCtrl]);
  AddKey(ecRight, VK_RIGHT, []);
  AddKey(ecSelRight, VK_RIGHT, [ssShift]);
  AddKey(ecWordRight, VK_RIGHT, [ssCtrl]);
  AddKey(ecSelWordRight, VK_RIGHT, [ssShift,ssCtrl]);
  AddKey(ecPageDown, VK_NEXT, []);
  AddKey(ecSelPageDown, VK_NEXT, [ssShift]);
  AddKey(ecPageBottom, VK_NEXT, [ssCtrl]);
  AddKey(ecSelPageBottom, VK_NEXT, [ssShift,ssCtrl]);
  AddKey(ecPageUp, VK_PRIOR, []);
  AddKey(ecSelPageUp, VK_PRIOR, [ssShift]);
  AddKey(ecPageTop, VK_PRIOR, [ssCtrl]);
  AddKey(ecSelPageTop, VK_PRIOR, [ssShift,ssCtrl]);
  AddKey(ecLineStart, VK_HOME, []);
  AddKey(ecSelLineStart, VK_HOME, [ssShift]);
  AddKey(ecEditorTop, VK_HOME, [ssCtrl]);
  AddKey(ecSelEditorTop, VK_HOME, [ssShift,ssCtrl]);
  AddKey(ecLineEnd, VK_END, []);
  AddKey(ecSelLineEnd, VK_END, [ssShift]);
  AddKey(ecEditorBottom, VK_END, [ssCtrl]);
  AddKey(ecSelEditorBottom, VK_END, [ssShift,ssCtrl]);
  AddKey(ecToggleMode, VK_INSERT, []);
  AddKey(ecCopy, VK_INSERT, [ssCtrl]);
  AddKey(ecPaste, VK_INSERT, [ssShift]);
  AddKey(ecDeleteChar, VK_DELETE, []);
  AddKey(ecCut, VK_DELETE, [ssShift]);
  AddKey(ecDeleteLastChar, VK_BACK, []);
  AddKey(ecDeleteLastWord, VK_BACK, [ssCtrl]);
  AddKey(ecUndo, VK_BACK, [ssAlt]);
  AddKey(ecRedo, VK_BACK, [ssAlt,ssShift]);
  AddKey(ecLineBreak, VK_RETURN, []);
  AddKey(ecSelectAll, ord('A'), [ssCtrl]);
  AddKey(ecCopy, ord('C'), [ssCtrl]);
  AddKey(ecBlockIndent, ord('I'), [ssCtrl,ssShift]);
  AddKey(ecLineBreak, ord('M'), [ssCtrl]);
  AddKey(ecInsertLine, ord('N'), [ssCtrl]);
  AddKey(ecDeleteWord, ord('T'), [ssCtrl]);
  AddKey(ecBlockUnindent, ord('U'), [ssCtrl,ssShift]);
  AddKey(ecPaste, ord('V'), [ssCtrl]);
  AddKey(ecCut, ord('X'), [ssCtrl]);
  AddKey(ecDeleteLine, ord('Y'), [ssCtrl]);
  AddKey(ecDeleteEOL, ord('Y'), [ssCtrl,ssShift]);
  AddKey(ecUndo, ord('Z'), [ssCtrl]);
  AddKey(ecRedo, ord('Z'), [ssCtrl,ssShift]);
  AddKey(ecGotoMarker0, ord('0'), [ssCtrl]);
  AddKey(ecGotoMarker1, ord('1'), [ssCtrl]);
  AddKey(ecGotoMarker2, ord('2'), [ssCtrl]);
  AddKey(ecGotoMarker3, ord('3'), [ssCtrl]);
  AddKey(ecGotoMarker4, ord('4'), [ssCtrl]);
  AddKey(ecGotoMarker5, ord('5'), [ssCtrl]);
  AddKey(ecGotoMarker6, ord('6'), [ssCtrl]);
  AddKey(ecGotoMarker7, ord('7'), [ssCtrl]);
  AddKey(ecGotoMarker8, ord('8'), [ssCtrl]);
  AddKey(ecGotoMarker9, ord('9'), [ssCtrl]);
  AddKey(ecSetMarker0, ord('0'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker1, ord('1'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker2, ord('2'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker3, ord('3'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker4, ord('4'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker5, ord('5'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker6, ord('6'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker7, ord('7'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker8, ord('8'), [ssCtrl,ssShift]);
  AddKey(ecSetMarker9, ord('9'), [ssCtrl,ssShift]);
{begin}                                                                         //bds 1999-2-23
{$IFDEF MWE_SELECTION_MODE}
  AddKey(ecNormalSelect, ord('N'), [ssCtrl,ssShift]);
  AddKey(ecColumnSelect, ord('C'), [ssCtrl,ssShift]);
  AddKey(ecLineSelect, ord('L'), [ssCtrl,ssShift]);
{$ENDIF}
{end}                                                                           //bds 1999-2-23
end;
{end}                                                                           //bds 1998-12-29

procedure TmwKeyStrokes.SetItem(Index: Integer; Value: TmwKeyStroke);
begin
 inherited SetItem(Index, Value);
end;

{begin}                                                                         //bds 1998-12-29
initialization
  RegisterIntegerConsts(TypeInfo(TmwEditorCommand), IdentToEditorCommand,
     EditorCommandToIdent);
{end}                                                                           //bds 1998-12-29
end.
