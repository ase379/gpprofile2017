{---------------------------------------------------------------------------
 TCL/TK Language Syntax Parser

 siTCLTKSyn was created as a plug in component for the Syntax Editor mwEdit
 created by Martin Waldenburg and friends.  For more information on the
 mwEdit project, see the following website:

 http://www.eccentrica.org/gabr/mw/mwedit.htm

 Copyright © 1999, Igor Shitikov.  All Rights Reserved.
 Portions Copyright Martin Waldenburg.
 Initially Created with mwSynGen by Martin Waldenburg.

 Thanks to: Martin Waldenburg, Primoz Gabrijelcic, James Jacobson.

 Special thanks to Martin Waldenburg.  You are a genius.
{---------------------------------------------------------------------------
 This component can be freely used and distributed. Redistributions of
 source code must retain the above copyright notice. If the source is
 modified, the complete original and unmodified source code has to
 distributed with the modified version.
{---------------------------------------------------------------------------
 Please note:  This source code is provided as a teaching tool. If you
 decide that you want to use whole routines or modules directly in an
 application that you are creating, please give credit where it is due.
{---------------------------------------------------------------------------
 Date last modified: 1999-09-24
{---------------------------------------------------------------------------}

{---------------------------------------------------------------------------
 TCL/TK Language Syntax Parser v0.84
{---------------------------------------------------------------------------
 Revision History:
 0.82:    * Primoz Gabrijelcic: Implemented OnToken event.
---------------------------------------------------------------------------}
unit siTCLTKSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter, mwLocalStr;                                                    //mh 1999-08-22

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

Type
  TtkTokenKind = (
    tkComment,
    tkIdentifier,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown,
    tkSecondKey);

//  TCommentStyle = (csAnsiStyle, csPasStyle, csCStyle, csAsmStyle, csBasStyle);//kvs 98-12-31, //gp 1999-02-28 removed
//  CommentStyles = Set of TCommentStyle;                                       //gp 1999-02-28 - removed
  TRangeState = (rsANil, rsAnsi, rsPasStyle, rsCStyle, rsUnKnown);

  TProcTableProc = procedure of Object;

type
  TsiTCLTKSyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fLineNumber: Integer;                                                       //gp 1999-02-28
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fSecondKeyAttri: TmwHighLightAttributes;                                    //si: Attributes for SecondKeys
    fNumberAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyWords: TStrings;
    fSecondKeys: TStrings;                                                      //si: Added SecondKeys property
//  fComments: CommentStyles;                                                   //gp 1999-02-28 - removed
//  procedure AsciiCharProc;                                                    //gp 1999-02-28 - removed
    procedure BraceOpenProc;
    procedure PointCommaProc;                                                   //kvs 98-12-31
    procedure CRProc;
    procedure IdentProc;
//  procedure IntegerProc;                                                      //gp 1999-02-28 - removed
    procedure LFProc;
    procedure NullProc;
    procedure NumberProc;
    procedure RoundOpenProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure UnknownProc;
    procedure MakeMethodTables;
    procedure AnsiProc;
    procedure PasStyleProc;
    procedure CStyleProc;
    procedure SetKeyWords(const Value: TStrings);
    procedure SetSecondKeys(const Value: TStrings);
//    procedure HighLightChange(Sender:TObject);                                  //gp 1998-12-22 //mh 1999-08-22
//    procedure SetHighLightChange;                                               //gp 1998-12-22 //mh 1999-08-22
//  procedure SetComments(Value: CommentStyles);                                //jdj 1998-12-22, //gp 1999-02-28 - removed
  protected
    function GetLanguageName: string; override;                                 //gp 1998-12-24, //gp 1999-1-10 - renamed
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
//si: Made these functions public for convinience
    function IsKeyWord(aToken: String): Boolean;
    function IsSecondKeyWord(aToken: String): Boolean;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-02-28
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    function SaveToRegistry(RootKey: HKEY; Key: string): boolean; override;     //gp 1998-12-28
    function LoadFromRegistry(RootKey: HKEY; Key: string): boolean; override;   //gp 1998-12-28
  published
//  property Comments: CommentStyles read fComments write SetComments;          //jdj 1998-12-22 - added set, //gp 1999-02-28 - removed
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property KeyWords: TStrings read fKeyWords write SetKeyWords;
    property SecondKeyAttri: TmwHighLightAttributes read fSecondKeyAttri        //si: SecondKeys
               write fSecondKeyAttri;
    property SecondKeyWords: TStrings read fSecondKeys write SetSecondKeys;     //si: ....
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
  end;

procedure Register;

implementation

const
     TclTkKeysCount = 147;                                                      //si: 99-05-05
     TclTkKeys: array[1..TclTkKeysCount] of string = (
                                                      'AFTER',
                                                      'APPEND',
                                                      'ARRAY',
                                                      'BELL',
                                                      'BGERROR',
                                                      'BINARY',
                                                      'BIND',
                                                      'BINDIDPROC',
                                                      'BINDPROC',
                                                      'BINDTAGS',
                                                      'BITMAP',
                                                      'BREAK',
                                                      'BUTTON',
                                                      'CANVAS',
                                                      'CATCH',
                                                      'CD',
                                                      'CHECKBUTTON',
                                                      'CLIPBOARD',
                                                      'CLOCK',
                                                      'CLOSE',
                                                      'CONCAT',
                                                      'CONTINUE',
                                                      'DESTROY',
                                                      'ELSE',
                                                      'ENTRY',
                                                      'EOF',
                                                      'ERROR',
                                                      'EVAL',
                                                      'EVENT',
                                                      'EXEC',
                                                      'EXIT',
                                                      'EXPR',
                                                      'FBLOCKED',
                                                      'FCONFIGURE',
                                                      'FCOPY',
                                                      'FILE',
                                                      'FILEEVENT',
                                                      'FILENAME',
                                                      'FLUSH',
                                                      'FOCUS',
                                                      'FONT',
                                                      'FOR',
                                                      'FOREACH',
                                                      'FORMAT',
                                                      'FRAME',
                                                      'GETS',
                                                      'GLOB',
                                                      'GLOBAL',
                                                      'GRAB',
                                                      'GRID',
                                                      'HISTORY',
                                                      'HTTP',
                                                      'IF',
                                                      'IMAGE',
                                                      'INCR',
                                                      'INFO',
                                                      'INTERP',
                                                      'JOIN',
                                                      'LABEL',
                                                      'LAPPEND',
                                                      'LIBRARY',
                                                      'LINDEX',
                                                      'LINSERT',
                                                      'LIST',
                                                      'LISTBOX',
                                                      'LLENGTH',
                                                      'LOAD',
                                                      'LOADTK',
                                                      'LOWER',
                                                      'LRANGE',
                                                      'LREPLACE',
                                                      'LSEARCH',
                                                      'LSORT',
                                                      'MENU',
                                                      'MESSAGE',
                                                      'NAMESPACE',
                                                      'NAMESPUPD',
                                                      'OPEN',
                                                      'OPTION',
                                                      'OPTIONS',
                                                      'PACK',
                                                      'PACKAGE',
                                                      'PHOTO',
                                                      'PID',
                                                      'PKG_MKINDEX',
                                                      'PLACE',
                                                      'PROC',
                                                      'PUTS',
                                                      'PWD',
                                                      'RADIOBUTTON',
                                                      'RAISE',
                                                      'READ',
                                                      'REGEXP',
                                                      'REGISTRY',
                                                      'REGSUB',
                                                      'RENAME',
                                                      'RESOURCE',
                                                      'RETURN',
                                                      'RGB',
                                                      'SAFEBASE',
                                                      'SCALE',
                                                      'SCAN',
                                                      'SEEK',
                                                      'SELECTION',
                                                      'SEND',
                                                      'SENDOUT',
                                                      'SET',
                                                      'SOCKET',
                                                      'SOURCE',
                                                      'SPLIT',
                                                      'STRING',
                                                      'SUBST',
                                                      'SWITCH',
                                                      'TCL',
                                                      'TCLVARS',
                                                      'TELL',
                                                      'TEXT',
                                                      'THEN',
                                                      'TIME',
                                                      'TK',
                                                      'TK_BISQUE',
                                                      'TK_CHOOSECOLOR',
                                                      'TK_DIALOG',
                                                      'TK_FOCUSFOLLOWSMOUSE',
                                                      'TK_FOCUSNEXT',
                                                      'TK_FOCUSPREV',
                                                      'TK_GETOPENFILE',
                                                      'TK_GETSAVEFILE',
                                                      'TK_MESSAGEBOX',
                                                      'TK_OPTIONMENU',
                                                      'TK_POPUP',
                                                      'TK_SETPALETTE',
                                                      'TKERROR',
                                                      'TKVARS',
                                                      'TKWAIT',
                                                      'TOPLEVEL',
                                                      'TRACE',
                                                      'UNKNOWN',
                                                      'UNSET',
                                                      'UPDATE',
                                                      'UPLEVEL',
                                                      'UPVAR',
                                                      'VARIABLE',
                                                      'VWAIT',
                                                      'WHILE',
                                                      'WINFO',
                                                      'WM');                    //si: 99-05-05

procedure Register;
begin
  RegisterComponents('mw', [TsiTCLTKSyn]);
end;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpperCase(I)[1];
    Case I in ['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

function TsiTCLTKSyn.IsKeyWord(aToken: String): Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := fKeywords.Count - 1;
  Result := False;
  Token := UpperCase(aToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(fKeywords[i], Token);
    if Compare = 0 then
    begin
      Result := True;
      break;
    end
    else
      if Compare < 0 then First := I + 1 else Last := I - 1;
  end;
end; { IsKeyWord }

//si: 05/02/99
function TsiTCLTKSyn.IsSecondKeyWord(aToken: String): Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := fSecondKeys.Count - 1;
  Result := False;
  Token := UpperCase(aToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(fSecondKeys[i], Token);
    if Compare = 0 then
    begin
      Result := True;
      break;
    end
    else
      if Compare < 0 then First := I + 1 else Last := I - 1;
  end;
end; { IsSecondKeyWord }

procedure TsiTCLTKSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '#': fProcTable[I] := SlashProc{!@#$AsciiCharProc};                       //si: Comments for TCL/TK
      '{': fProcTable[I] := BraceOpenProc;
      ';': fProcTable[I] := PointCommaProc;                                     //kvs 98-12-31
      #13: fProcTable[I] := CRProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
//      '$': fProcTable[I] := IntegerProc;                                      //si: Removed for TCL
      #10: fProcTable[I] := LFProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '(': fProcTable[I] := RoundOpenProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      #34{!@#$#39}: fProcTable[I] := StringProc;                                //si: String in TCL are in ""
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TsiTCLTKSyn.Create(AOwner: TComponent);
var
   i: integer;
begin
  fKeyWords := TStringList.Create;
  TStringList(fKeyWords).Sorted := True;                                        //jdj 1998-12-22
  TStringList(fKeyWords).Duplicates := dupIgnore;                               //jdj 1998-12-22
  fSecondKeys := TStringList.Create;                                            //si: 99-05-02
  TStringList(fSecondKeys).Sorted := True;                                      //si: 99-05-02
  TStringList(fSecondKeys).Duplicates := dupIgnore;                             //si: 99-05-02
  for i := 1 to TclTkKeysCount do
    FKeyWords.Add(TclTkKeys[i]);
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style := [fsBold];
  fSecondKeyAttri := TmwHighLightAttributes.Create(MWS_AttrSecondReservedWord); //si: 99-05-02             //gp 1998-12-24
  fSecondKeyAttri.Style := [fsBold];                                            //si: 99-05-02
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  inherited Create(AOwner);
  fDefaultFilter := MWS_FilterTclTk;                                            //mh 1999-09-14

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fSecondKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22

  MakeMethodTables;
  fRange := rsUnknown;
end; { Create }

destructor TsiTCLTKSyn.Destroy;
begin
  fKeyWords.Free;
  fSecondKeys.Free;                                                             //si: 99-05-02
  inherited Destroy;
end; { Destroy }

(*                                                                              //mh 1999-09-12
procedure TsiTCLTKSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TsiTCLTKSyn.SetLine(NewValue: String; LineNumber:Integer);            //gp 1999-02-28
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TsiTCLTKSyn.AnsiProc;
begin
  fTokenID := tkComment;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        exit;
      end;
    #10:
      begin
        LFProc;
        exit;
      end;

    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while fLine[Run] <> #0 do
    case fLine[Run] of
      '*':
        if fLine[Run + 1] = ')' then
        begin
          fRange := rsUnKnown;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TsiTCLTKSyn.PasStyleProc;
begin
  fTokenID := tkComment;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        exit;
      end;
    #10:
      begin
        LFProc;
        exit;
      end;

    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while FLine[Run] <> #0 do
    case FLine[Run] of
      '}':
        begin
          fRange := rsUnKnown;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TsiTCLTKSyn.CStyleProc;
begin
  fTokenID := tkComment;
  case FLine[Run] of
    #0:
      begin
        NullProc;
        exit;
      end;
    #10:
      begin
        LFProc;
        exit;
      end;

    #13:
      begin
        CRProc;
        exit;
      end;
  end;

  while fLine[Run] <> #0 do
    case fLine[Run] of
      '*':
        if fLine[Run + 1] = '/' then
        begin
          fRange := rsUnKnown;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

(*                                                                              //gp 1999-02-28 - removed
procedure TsiTCLTKSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  inc(Run);
  while FLine[Run] in ['0'..'9'] do inc(Run);
end;
*)

procedure TsiTCLTKSyn.BraceOpenProc;
begin
(*if csPasStyle in fComments then                                               //gp 1999-02-28 - removed
  begin
    fTokenID := tkComment;
    fRange := rsPasStyle;
    inc(Run);
    while FLine[Run] <> #0 do
      case FLine[Run] of
        '}':
          begin
            fRange := rsUnKnown;
            inc(Run);
            break;
          end;
        #10: break;

        #13: break;
      else inc(Run);
      end;
  end else
  begin *)
    inc(Run);
    fTokenID := tkSymbol;
(*end;*)                                                                        //gp 1999-02-28 - removed
end;

procedure TsiTCLTKSyn.PointCommaProc;                                           //kvs 98-12-31
begin
(*if (csASmStyle in fComments) or (csBasStyle in fComments) then                //gp 1999-02-28 - removed
  begin
    fTokenID := tkComment;
    fRange := rsUnknown;
    inc(Run);
    while FLine[Run] <> #0 do
      begin
        fTokenID := tkComment;
        inc(Run);
      end;
  end else
  begin *)
    inc(Run);
    fTokenID := tkSymbol;
(*end;*)                                                                        //gp 1999-02-28 - removed
end;

procedure TsiTCLTKSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TsiTCLTKSyn.IdentProc;
begin
  while Identifiers[fLine[Run]] do inc(Run);
  if IsKeyWord(GetToken) then begin
    fTokenId := tkKey;
    Exit;
  end
  else fTokenId := tkIdentifier;                                                //si: 99-05-02
  if IsSecondKeyWord(GetToken)                                                  //si: 99-05-02
    then fTokenId := tkSecondKey                                                //si: 99-05-02
    else fTokenId := tkIdentifier;                                              //si: 99-05-02
end;

(*                                                                              //gp 1999-02-28 - removed
procedure TsiTCLTKSyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
end;
*)

procedure TsiTCLTKSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TsiTCLTKSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TsiTCLTKSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', '.', 'e', 'E'] do
  begin
    case FLine[Run] of
      '.':
        if FLine[Run + 1] = '.' then break;
    end;
    inc(Run);
  end;
end;

procedure TsiTCLTKSyn.RoundOpenProc;
begin
  inc(Run);
(*if csAnsiStyle in fComments then                                              //gp 1999-02-28 - removed
  begin
    case fLine[Run] of
      '*':
        begin
          fTokenID := tkComment;
          fRange := rsAnsi;
          inc(Run);
          while fLine[Run] <> #0 do
            case fLine[Run] of
              '*':
                if fLine[Run + 1] = ')' then
                begin
                  fRange := rsUnKnown;
                  inc(Run, 2);
                  break;
                end else inc(Run);
              #10: break;
              #13: break;
            else inc(Run);
            end;
        end;
      '.':
        begin
          inc(Run);
          fTokenID := tkSymbol;
        end;
    else
      begin
        FTokenID := tkSymbol;
      end;
    end;
  end else*)
  fTokenId := tkSymbol;
end;

procedure TsiTCLTKSyn.SlashProc;
begin
  case FLine[Run + 1] of
    '/':
      begin
        inc(Run, 2);
        fTokenID := tkComment;
        while FLine[Run] <> #0 do
        begin
          case FLine[Run] of
            #10, #13: break;
          end;
          inc(Run);
        end;
      end;
    '*':
      begin
(*      if csCStyle in fComments then                                           //gp 1999-02-28 - removed
        begin
          fTokenID := tkComment;
          fRange := rsCStyle;
          inc(Run);
          while fLine[Run] <> #0 do
            case fLine[Run] of
              '*':
                if fLine[Run + 1] = '/' then
                begin
                  fRange := rsUnKnown;
                  inc(Run, 2);
                  break;
                end else inc(Run);
              #10: break;
              #13: break;
            else inc(Run);
            end;
        end
        else
          begin *)                                                              //kvs 98-12-31
            inc(Run);    //added inc(Run)
            fTokenId := tkSymbol;
        (*end;*)                                                                //gp 1999-02-28 - removed
      end;
  else
    begin
{!@#$      inc(Run);                                                            //si: 99-05-02
      fTokenID := tkSymbol;}                                                    //si: 99-05-02
      fTokenID := tkComment;                                                    //si: 99-05-02
      while FLine[Run] <> #0 do                                                 //si: 99-05-02
      begin                                                                     //si: 99-05-02
        case FLine[Run] of                                                      //si: 99-05-02
          #10, #13: break;                                                      //si: 99-05-02
        end;                                                                    //si: 99-05-02
        inc(Run);                                                               //si: 99-05-02
      end;                                                                      //si: 99-05-02
    end;
  end;
end;

procedure TsiTCLTKSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TsiTCLTKSyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #34{!@#$#39}) and (FLine[Run + 2] = #34{!@#$#39})        //si: 99-05-02
    then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #34{!@#$#39};                                              //si: 99-05-02
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TsiTCLTKSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnKnown;
end;

procedure TsiTCLTKSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //gp 1999-02-28
begin
  fTokenPos := Run;
  Case fRange of
    rsAnsi: AnsiProc;
    rsPasStyle: PasStyleProc;
    rsCStyle: CStyleProc;
  else fProcTable[fLine[Run]];
  end;
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //gp 1999-02-28
    case TokenID of                                                             //gp 1999-02-28
      tkComment:
        with fCanvas do
        begin
          Brush.Color := fCommentAttri.Background;
          Font.Color := fCommentAttri.Foreground;
          Font.Style := fCommentAttri.Style;
        end;
      tkIdentifier:
        with fCanvas do
        begin
          Brush.Color := fIdentifierAttri.Background;
          Font.Color := fIdentifierAttri.Foreground;
          Font.Style := fIdentifierAttri.Style;
        end;
      tkKey:
        with fCanvas do
        begin
          Brush.Color := fKeyAttri.Background;
          Font.Color := fKeyAttri.Foreground;
          Font.Style := fKeyAttri.Style;
        end;
      tkSecondKey:                                                              //si: 99-05-02
        with fCanvas do                                                         //si: 99-05-02
        begin                                                                   //si: 99-05-02
          Brush.Color := fSecondKeyAttri.Background;                            //si: 99-05-02
          Font.Color := fSecondKeyAttri.Foreground;                             //si: 99-05-02
          Font.Style := fSecondKeyAttri.Style;                                  //si: 99-05-02
        end;                                                                    //si: 99-05-02
      tkNumber:
        with fCanvas do
        begin
          Brush.Color := fNumberAttri.Background;
          Font.Color := fNumberAttri.Foreground;
          Font.Style := fNumberAttri.Style;
        end;
      tkSpace:
        with fCanvas do
        begin
          Brush.Color := fSpaceAttri.Background;
          Font.Color := fSpaceAttri.Foreground;
          Font.Style := fSpaceAttri.Style;
        end;
      tkString:
        with fCanvas do
        begin
          Brush.Color := fStringAttri.Background;
          Font.Color := fStringAttri.Foreground;
          Font.Style := fStringAttri.Style;
        end;
      tkSymbol:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
      tkUnknown:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-28 //mh 1999-08-22
  end;
*)
end;

function TsiTCLTKSyn.GetEol: Boolean;
begin
  Result := False;
  if fTokenId = tkNull then Result := True;
end;

function TsiTCLTKSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TsiTCLTKSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TsiTCLTKSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TsiTCLTKSyn.GetTokenAttribute: TmwHighLightAttributes;                 //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkSecondKey: Result := fSecondKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fSymbolAttri;
    else Result := nil;
  end;
end;

function TsiTCLTKSyn.GetTokenKind: integer;                                     //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TsiTCLTKSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TsiTCLTKSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TsiTCLTKSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //jdj 1998-12-22 - rewritten
procedure TsiTCLTKSyn.SetKeyWords(const Value: TStrings);
var
  i: Integer;
begin
  if Value <> nil then
    begin
      Value.BeginUpdate;
      for i := 0 to Value.Count - 1 do
        Value[i] := UpperCase(Value[i]);
      Value.EndUpdate;
    end;
  fKeyWords.Assign(Value);
  DefHighLightChange(nil);
end;
{end}                                                                           //jdj 1998-12-22

procedure TsiTCLTKSyn.SetSecondKeys(const Value: TStrings);                     //si: 99-05-02
var
  i: Integer;
begin
  if Value <> nil then
    begin
      Value.BeginUpdate;
      for i := 0 to Value.Count - 1 do
        Value[i] := UpperCase(Value[i]);
      Value.EndUpdate;
    end;
  fSecondKeys.Assign(Value);
  DefHighLightChange(nil);
end;                                                                            //si: 99-05-02

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-22
procedure TsiTCLTKSyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TsiTCLTKSyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fSecondKeyAttri.Onchange:= HighLightChange;                                   //si: 99-05-02
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
{end}                                                                           //gp 1998-12-22
*)
{end}                                                                           //mh 1999-08-22

{begin}                                                                         //jdj 1998-12-22
(*                                                                              //gp 1999-02-28 - removed
procedure TsiTCLTKSyn.SetComments(Value: CommentStyles);
begin
  fComments := Value;
  HighLightChange(nil);
end;
*)
{end}                                                                           //jdj 1998-12-22

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-24
function TsiTCLTKSyn.GetAttribCount: integer;
begin                                                                           //si: 99-05-02
  Result := 8;
end;

function TsiTCLTKSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fNumberAttri;
    3: Result := fKeyAttri;
    4: Result := fSpaceAttri;
    5: Result := fStringAttri;
    6: Result := fSymbolAttri;
    7: Result := fSecondKeyAttri;                                               //si: 99-05-02
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TsiTCLTKSyn.GetLanguageName: string;                                   //gp 1999-1-10 - renamed
begin
  Result := MWS_LangTclTk;                                                      //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

function TsiTCLTKSyn.LoadFromRegistry(RootKey: HKEY; Key: string): boolean;     //gp 1998-12-28
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKeyReadOnly(Key) then begin
      if r.ValueExists('KeyWords') then KeyWords.Text:= r.ReadString('KeyWords');
      Result := inherited LoadFromRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

function TsiTCLTKSyn.SaveToRegistry(RootKey: HKEY; Key: string): boolean;     //gp 12/28/1998
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKey(Key,true) then begin
      Result := true;
      r.WriteString('KeyWords', KeyWords.Text);
      Result := inherited SaveToRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

Initialization
  MakeIdentTable;
end.
