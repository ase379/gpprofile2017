{$I MWEDIT.INC}
{---------------------------------------------------------------------------
 Python Language Syntax Parser

 Class:       TodPySyn
 Created:     not known
 Last change: 1999-09-24
 Author:      Olivier Deckmyn
 Version:     1.02 (for version history see version.rtf)

 odPySyn was created as a plug in component for the Syntax Editor mwEdit
 created by Martin Waldenburg and friends.  For more information on the
 mwEdit project, see the following website:

 http://www.eccentrica.org/gabr/mw/mwedit.htm

 Copyright © 1998, Olivier Deckmyn.  All Rights Reserved.
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
{---------------------------------------------------------------------------}
unit odPySyn;

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
    tkUnknown);

  TRangeState = (rsANil, rsComment, rsUnKnown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

type
  TodPySyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;                                                       //gp 1999-05-06
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
//    fEol: Boolean;                                                            //mh 1999-08-22
    fIdentFuncTable: array[0..101] of TIdentFuncTableFunc;
    fStringAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
//    procedure AssignAttributes(Attributes: TmwHighLightAttributes);           //mh 1999-09-12
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func15:TtkTokenKind;
    function Func21:TtkTokenKind;
    function Func23:TtkTokenKind;
    function Func31:TtkTokenKind;
    function Func32:TtkTokenKind;
    function Func33:TtkTokenKind;
    function Func37:TtkTokenKind;
    function Func39:TtkTokenKind;
    function Func41:TtkTokenKind;
    function Func45:TtkTokenKind;
    function Func49:TtkTokenKind;
    function Func52:TtkTokenKind;
    function Func54:TtkTokenKind;
    function Func55:TtkTokenKind;
    function Func57:TtkTokenKind;
    function Func63:TtkTokenKind;
    function Func73:TtkTokenKind;
    function Func77:TtkTokenKind;
    function Func79:TtkTokenKind;
    function Func91:TtkTokenKind;
    function Func96:TtkTokenKind;
    function Func101:TtkTokenKind;
    procedure SymbolProc;
    procedure CRProc;
    procedure CommentProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PointProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure String2Proc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
//    procedure HighLightChange(Sender:TObject);                                //mh 1999-08-22
//    procedure SetHighLightChange;                                             //mh 1999-08-22
  protected
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;
//    function GetAttribCount: integer; override;                               //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;    //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-08-22
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-05-06
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//  procedure SetCanvas(Value: TCanvas); override;                              //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    property IdentChars;
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
  end;

  procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TodPySyn]);
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
    Case I in ['_','A'..'Z','a'..'z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TodPySyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 101 do
    Case I of
      15: fIdentFuncTable[I] := Func15;
      21: fIdentFuncTable[I] := Func21;
      23: fIdentFuncTable[I] := Func23;
      31: fIdentFuncTable[I] := Func31;
      32: fIdentFuncTable[I] := Func32;
      33: fIdentFuncTable[I] := Func33;
      37: fIdentFuncTable[I] := Func37;
      39: fIdentFuncTable[I] := Func39;
      41: fIdentFuncTable[I] := Func41;
      45: fIdentFuncTable[I] := Func45;
      49: fIdentFuncTable[I] := Func49;
      52: fIdentFuncTable[I] := Func52;
      54: fIdentFuncTable[I] := Func54;
      55: fIdentFuncTable[I] := Func55;
      57: fIdentFuncTable[I] := Func57;
      63: fIdentFuncTable[I] := Func63;
      73: fIdentFuncTable[I] := Func73;
      77: fIdentFuncTable[I] := Func77;
      79: fIdentFuncTable[I] := Func79;
      91: fIdentFuncTable[I] := Func91;
      96: fIdentFuncTable[I] := Func96;
      101: fIdentFuncTable[I] := Func101;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TodPySyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TodPySyn.KeyComp(const aKey: String): Boolean;                         //mh 1999-08-22
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end; { KeyComp }

function TodPySyn.Func15: TtkTokenKind;
begin
  if KeyComp('Def') then Result := tkKey else
    if KeyComp('If') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func21: TtkTokenKind;
begin
  if KeyComp('Del') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func23: TtkTokenKind;
begin
  if KeyComp('In') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func31: TtkTokenKind;
begin
  if KeyComp('Len') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func32: TtkTokenKind;
begin
  if KeyComp('Elif') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func33: TtkTokenKind;
begin
  if KeyComp('Lambda') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func37: TtkTokenKind;
begin
  if KeyComp('Break') then Result := tkKey else
    if KeyComp('Exec') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func39: TtkTokenKind;
begin
  if KeyComp('For') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func41: TtkTokenKind;
begin
  if KeyComp('Else') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func45: TtkTokenKind;
begin
  if KeyComp('Range') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func49: TtkTokenKind;
begin
  if KeyComp('Global') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func52: TtkTokenKind;
begin
  if KeyComp('Raise') then Result := tkKey else
    if KeyComp('From') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func54: TtkTokenKind;
begin
  if KeyComp('Class') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func55: TtkTokenKind;
begin
  if KeyComp('Pass') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func57: TtkTokenKind;
begin
  if KeyComp('While') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func63: TtkTokenKind;
begin
  if KeyComp('Try') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func73: TtkTokenKind;
begin
  if KeyComp('Except') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func77: TtkTokenKind;
begin
  if KeyComp('Print') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func79: TtkTokenKind;
begin
  if KeyComp('Finally') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func91: TtkTokenKind;
begin
  if KeyComp('Import') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func96: TtkTokenKind;
begin
  if KeyComp('Return') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.Func101: TtkTokenKind;
begin
  if KeyComp('Continue') then Result := tkKey else Result := tkIdentifier;
end;

function TodPySyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TodPySyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 102 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TodPySyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '@',
      '&',
      '}',
      '{',
      ':',
      ',',
      ']',
      '[',
      '*',
      '^',
      ')',
      '(',
      ';',
      '/',
      '=',
      '-',
      '+': fProcTable[I] := SymbolProc;

      #13: fProcTable[I] := CRProc;
      '#': fProcTable[I] := CommentProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      '$': fProcTable[I] := IntegerProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '.': fProcTable[I] := PointProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      #39: fProcTable[I] := StringProc;
      '"': fProcTable[I] := String2Proc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TodPySyn.Create(AOwner: TComponent);
begin
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //mh 1999-08-22
  fCommentAttri.Foreground := clTeal;
  fCommentAttri.Style:= [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Style:= [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);
  fNumberAttri.Foreground := clBlue;
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);
  fStringAttri.Foreground := clBlue;
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  fRange := rsUnknown;

  inherited Create(AOwner);

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22

  InitIdent;
  MakeMethodTables;
  fDefaultFilter := MWS_FilterPython;                                           //ajb 1999-09-14
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TodPySyn.Destroy;
begin
  fCommentAttri.Free;
  fIdentifierAttri.Free;
  fKeyAttri.Free;
  fNumberAttri.Free;
  fSpaceAttri.Free;
  fStringAttri.Free;
  fSymbolAttri.Free;
  inherited Destroy;
end; { Destroy }
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
procedure TodPySyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TodPySyn.SetLine(NewValue: String; LineNumber:Integer);               //gp 1999-05-06
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TodPySyn.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TodPySyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TodPySyn.CommentProc;
begin
  fTokenID := tkComment;
  inc(Run);
  while not (FLine[Run] in [#13,#10,#0]) do inc(Run);
end;

procedure TodPySyn.GreaterProc;
begin
  Case FLine[Run + 1] of
    '=':
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TodPySyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TodPySyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
end;

procedure TodPySyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TodPySyn.LowerProc;
begin
  case FLine[Run + 1] of
    '=':
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '>':
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TodPySyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-08-22
end;

procedure TodPySyn.NumberProc;
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

procedure TodPySyn.PointProc;
begin
  case FLine[Run + 1] of
    '.':
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    ')':
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TodPySyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TodPySyn.String2Proc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = '"') and (FLine[Run + 2] = '"') then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = '"';
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TodPySyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #39) and (FLine[Run + 2] = #39) then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TodPySyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TodPySyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //gp 1999-05-06
begin

  fTokenPos := Run;
  fProcTable[fLine[Run]];
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //gp 1999-05-06
    case TokenID of                                                             //gp 1999-05-06
      tkComment:AssignAttributes(fCommentAttri);
      tkIdentifier:AssignAttributes(fIdentifierAttri);
      tkKey:AssignAttributes(fKeyAttri);
      tkNumber:AssignAttributes(fNumberAttri);
      tkSpace:AssignAttributes(fSpaceAttri);
      tkString:AssignAttributes(fStringAttri);
      tkSymbol:AssignAttributes(fSymbolAttri);
      tkUnknown:AssignAttributes(fSymbolAttri);
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-05-06 //mh 1999-08-22
  end;
*)
end;

function TodPySyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TodPySyn.GetRange: Pointer;
begin
 Result := Pointer(fRange);
end;

function TodPySyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TodPySyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TodPySyn.GetTokenAttribute: TmwHighLightAttributes;                    //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fSymbolAttri;
    else Result := nil;
  end;
end;

function TodPySyn.GetTokenKind: integer;                                        //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TodPySyn.GetTokenPos: Integer;
begin
 Result := fTokenPos;
end;

procedure TodPySyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TodPySyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //mh 1999-08-22
(*
procedure TodPySyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TodPySyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
*)
{end}                                                                           //mh 1999-08-22

function TodPySyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

{begin}                                                                         //mh 1999-08-22
(*
function TodPySyn.GetAttribCount: integer;
begin
  Result := 7;
end;

function TodPySyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin // sorted by name
  case idx of
    0 : result := fCommentAttri;
    1 : result := fIdentifierAttri;
    2 : result := fKeyAttri;
    3 : result := fNumberAttri;
    4 : result := fSpaceAttri;
    5 : result := fStringAttri;
    6 : result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TodPySyn.GetLanguageName: string;
begin
  Result := MWS_LangPython;                                                     //mh 1999-09-24
end;

function TodPySyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings];
end;

(*                                                                              //mh 1999-09-12
procedure TodPySyn.AssignAttributes(Attributes: TmwHighLightAttributes);
begin
 if fCanvas.Brush.Color<> Attributes.Background then fCanvas.Brush.Color:= Attributes.Background;
 if fCanvas.Font.Color<> Attributes.Foreground then fCanvas.Font.Color:= Attributes.Foreground;
 if fCanvas.Font.Style<> Attributes.Style then fCanvas.Font.Style:= Attributes.Style;
end;
*)

Initialization
  MakeIdentTable;
end.
