unit CodeExMain;

{******************************************************************************

 This demonstration and the appropriate code to support it in mwEditor were
 written by Andy Jeffries of Kwik-Rite Development (www.kwikrite.clara.net)

 This really is a work in progress, but it could be very useful in implementing
 your own full Code Explorer.

 Last update: 1999-05-07
 Version: 0.12 (for version history see version.rtf)

 Changes implented by Jacobs Jan on 05/11/1999 jacobs.jan@planetinternet.be:

  - Changed Listbox to Treeview, need lots of work and review of updateprocedure
  - Added possibility to alphasort the treeview
  - Changed Openprocedure to actionlist, for future ease ...

 Needed :

  Logic behind the tokens, need more information about them
  Help on where I should put refreshalltokens, because on scroll -> treeview gets
  messed up.  Possible solution : rewrite of updateprocedure.
  How do I check if a procedure is still in the source ???

 ******************************************************************************}

interface

uses
 Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
 StdCtrls, Buttons, mwHighlighter, mwPasSyn, ComCtrls, mwKeycmds,
 Menus, ExtCtrls, ToolWin, ActnList, mwCustomEdit, ImgList;

type
 TCodeExplorer = class(TForm)
  PascalHighLighter: TmwPasSyn;
  OpenDialog: TOpenDialog;
  StatusBar: TStatusBar;
  Splitter1: TSplitter;
  ToolBar1: TToolBar;
  ActionList: TActionList;
  Open: TAction;
  TreeView: TTreeView;
  Editor: TmwCustomEdit;
  ToolButton1: TToolButton;
  ToolButton2: TToolButton;
  ToolButton3: TToolButton;
  SortAlpha: TAction;
  RefreshTokens: TAction;
  MainMenu: TMainMenu;
  File1: TMenuItem;
  Openfile1: TMenuItem;
  Options1: TMenuItem;
  Alphasort1: TMenuItem;
  RefreshExplorer1: TMenuItem;
  Exit: TAction;
  N1: TMenuItem;
  Exit1: TMenuItem;
  ToolImages: TImageList;
  TreeImages: TImageList;
  ToolButton4: TToolButton;
  procedure PascalHighLighterToken(Sender: TObject; _TokenKind: Integer;
   TokenText: string; LineNo: Integer);
  procedure FormCreate(Sender: TObject);
  procedure TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
   Shift: TShiftState; X, Y: Integer);
  procedure OpenExecute(Sender: TObject);
  procedure SortAlphaExecute(Sender: TObject);
  procedure RefreshTokensExecute(Sender: TObject);
  procedure ExitExecute(Sender: TObject);
  procedure EditorSelectionChange(Sender: TObject);
 private
  procedure InsertIntoList(Item: string; LineNumber: Integer; Child: Boolean);
 public
  { Public declarations }
 end;
 
 TParseState = (psIdle, psInClassDef, psProcSeen, psWaitForSymbol);
 
const
 spPosition                   = 0; // These 2 constants define the panel index in the statusbar
 spFileName                   = 1; // for the text to display, so it is easy to change
 
var
 CodeExplorer                 : TCodeExplorer;
 ParseState                   : TParseState;
 ProcedureName                : string;
 
implementation

{$R *.DFM}


// *** JAN, 11 05 1999
// Custom Sort Procedure for treeview
function CustomSortProc(node1, node2: TTreenode; Data: Integer): Integer; stdcall;
begin
 Result := 0;
 if CodeExplorer.SortAlpha.Checked then //  if alphasort then do Ansicompare
 begin
  Result := ansistrIcomp(PChar(node1.Text), PChar(node2.Text));
 end
 else  // else sort on linenumbers
 begin
  if Integer(node1.Data) > Integer(node2.Data) then Result := 1;
  if Integer(node1.Data) < Integer(node2.Data) then Result := -1;
 end;
end;
// *** END JAN

procedure TCodeExplorer.PascalHighLighterToken(Sender: TObject; _TokenKind: Integer;
 TokenText: string; LineNo: Integer);
var
 TokenKind                    : mwPasSyn.TtkTokenKind absolute _TokenKind;
begin
 if (TokenKind = tkKey) and
  (Uppercase(TokenText) = 'CLASS') then
  ParseState := psInClassDef;

 if (TokenKind = tkKey) and
  (Uppercase(TokenText) = 'END') and
  (ParseState = psInClassDef) then
  ParseState := psIdle;

 if (TokenKind = tkKey) and
  (Uppercase(TokenText) = 'IMPLEMENTATION') then
  InsertIntoList(TokenText, LineNo, False);

 if ParseState <> psInClassDef then
 begin
  if (ParseState = psIdle) and
   (TokenKind = tkKey) and
   ((Uppercase(TokenText) = 'PROCEDURE') or
   (Uppercase(TokenText) = 'FUNCTION')) then
   ParseState := psProcSeen;

  if (ParseState = psProcSeen) and
   (TokenKind = tkIdentifier) then
  begin
   ProcedureName := TokenText;
   ParseState := psWaitForSymbol;
  end;

  if (ParseState = psWaitForSymbol) and
   (TokenKind = tkSymbol) and
   (TokenText = '.') then
   ParseState := psProcSeen;

  if (ParseState = psWaitForSymbol) and
   (TokenKind = tkSymbol) and
   (TokenText <> '.') then
  begin
   InsertIntoList(ProcedureName, LineNo, True);
   ParseState := psIdle;
  end;
 end;
end;

procedure TCodeExplorer.FormCreate(Sender: TObject);
begin
 ParseState := psIdle;
end;

// *** JAN 11 05 1999
// Changed this procedure this way that it supports treeview
// deleting of nodes is not more necessary because the sortproc
// moves nodes into rigth place.
// At this moment, a check is done on text, but this is not good enough
// The linenumber is stored into the data property (pointer, so integer is casted)
procedure TCodeExplorer.InsertIntoList(Item: string; LineNumber: Integer; Child: Boolean);
var
 CurrentItem                  : Integer;
 Added                        : Boolean;
 Node                         : TTreeNode;
begin
 Added := False;
 for CurrentItem := 0 to TreeView.Items.Count - 1 do
 begin
  if TreeView.Items[CurrentItem].Text = Item then // Procedure/function is in list
  begin
   TreeView.Items[CurrentItem].Data := Pointer(Linenumber); // Change Linenumber
   Added := True;
   break;
  end;
 end;
 if not added then // new procedure/function
 begin
  if child then // it is a procedure/function, so add node as child of topnode
  begin
   Node := TreeView.Items.AddChildObject(TreeView.TopItem, Item, Pointer(LineNumber));
   Node.ImageIndex := 1;
   Node.SelectedIndex := 1;
  end
  else // it is 'implementation', add it as first node
  begin
   Node := TreeView.Items.AddObject(TreeView.TopItem, Item, Pointer(LineNumber));
   Node.ImageIndex := 0;
   Node.SelectedIndex := 0;
  end;
  TreeView.TopItem.Expand(False);
  TreeView.CustomSort(@CustomSortProc, 0); // sort the list
 end;
end;

// On doubleclick of a node, jump to procedure
procedure TCodeExplorer.TreeViewMouseDown(Sender: TObject; Button: TMouseButton;
 Shift: TShiftState; X, Y: Integer);
var
 Node                         : TTreeNode;
begin
 if ssdouble in Shift then // mouse was doubleclicked ??
 begin
  Node := TreeView.GetNodeAt(X, Y); // get node at doubleclick position
  if Node <> nil then // "Houston, we have a node !!!"
  begin
   TreeView.Selected := Node; // set node selected
   Editor.TopLine := Integer(Node.Data) + 1; // Move procedure to top of editor
   Editor.CaretY := Integer(Node.Data) + 1; // Move caretposition to top of editor
   Editor.SetFocus; //  no comments :)
  end;
 end;
end;

// Open a file
procedure TCodeExplorer.OpenExecute(Sender: TObject);
begin
 if OpenDialog.Execute then
 begin
  TreeView.Items.BeginUpdate;
  TreeView.Items.Clear;
  Editor.Lines.LoadFromFile(OpenDialog.FileName);
  Statusbar.Panels[spFilename].Text := OpenDialog.FileName;
  TreeView.Items.EndUpdate;
 end;
end;

// Sort the treeview alphabetical
procedure TCodeExplorer.SortAlphaExecute(Sender: TObject);
begin
 SortAlpha.Checked := not SortAlpha.Checked;
 Treeview.Items.BeginUpdate;
 TreeView.CustomSort(@CustomSortProc, 0);
 TreeView.Items.EndUpdate;
end;

// Rebuild the treeview, remove non existing nodes
procedure TCodeExplorer.RefreshTokensExecute(Sender: TObject);
begin
 TreeView.Items.BeginUpdate;
 TreeView.Items.Clear;
 editor.RefreshAllTokens;
 TreeView.Items.EndUpdate;
end;

// Exit the application
procedure TCodeExplorer.ExitExecute(Sender: TObject);
begin
 Close;
end;

// Set caret position in statusbar
procedure TCodeExplorer.EditorSelectionChange(Sender: TObject);
begin
 StatusBar.Panels[spPosition].Text := Inttostr(Editor.CaretY - 1) + ' - ' + Inttostr(Editor.CaretX - 1);
end;
// *** END JAN

end.

