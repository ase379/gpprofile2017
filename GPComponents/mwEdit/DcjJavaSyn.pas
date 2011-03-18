{$I MWEDIT.INC}
{---------------------------------------------------------------------------
 Java Language Syntax Parser

 DcjJavaSyn was created as a plug in component for the Syntax Editor mwEdit
 created by Martin Waldenburg and friends.  For more information on the
 mwEdit project, see the following website:

 http://www.eccentrica.org/gabr/mw/mwedit.htm

 Copyright © 1998, Michael Trier.  All Rights Reserved.
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
{---------------------------------------------------------------------------

{---------------------------------------------------------------------------
 Java Language Syntax Parser v0.56
{---------------------------------------------------------------------------
 Revision History:
 0.54:    * Andy Jeffries, Primoz Gabrijelcic: Implemented OnToken event.
 0.53:    * Primoz Gabrijelcic: Moved most of DefaultFilter support to
            mwHighlighter.pas.
 0.52:    * Copied code in other parsers that was added by Primoz
            Gabrijelcic and James Jacobson.
 0.50:    * Initial version.
{---------------------------------------------------------------------------
 Known Problems:
   * A number beginning with a '.' will not be properly recognized as the
     start of the number.
{---------------------------------------------------------------------------}
unit DcjJavaSyn;

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
    tkDocument,
    tkIdentifier,
    tkInvalid,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown);

  TxtkTokenKind = (
    xtkAdd, xtkAddAssign, xtkAnd, xtkAndAssign, xtkAssign, xtkBitComplement,
    xtkBraceClose, xtkBraceOpen, xtkColon, xtkCondAnd, xtkCondOr, xtkDecrement,
    xtkDivide, xtkDivideAssign, xtkGreaterThan, xtkGreaterThanEqual, xtkIncOr,
    xtkIncOrAssign, xtkIncrement, xtkLessThan, xtkLessThanEqual,
    xtkLogComplement, xtkLogEqual, xtkMultiply, xtkMultiplyAssign, xtkNotEqual,
    xtkPoint, xtkQuestion, xtkRemainder, xtkRemainderAssign, xtkRoundClose,
    xtkRoundOpen, xtkSemiColon, xtkShiftLeft, xtkShiftLeftAssign, xtkShiftRight,
    xtkShiftRightAssign, xtkSquareClose, xtkSquareOpen, xtkSubtract,
    xtkSubtractAssign, xtkUnsignShiftRight, xtkUnsignShiftRightAssign, xtkXor,
    xtkXorAssign);

  TRangeState = (rsANil, rsComment, rsDocument, rsUnknown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

type
  TDcjJavaSyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    FRoundCount: Integer;
    FSquareCount: Integer;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    FExtTokenID: TxtkTokenKind;
    fEol: Boolean;
    fIdentFuncTable: array[0..172] of TIdentFuncTableFunc;
    fLineNumber: Integer;                                                       //aj 1999-02-22
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fCommentAttri: TmwHighLightAttributes;
    fDocumentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fInvalidAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
//  fDefaultFilter: string;                                                     //gp 1999-1-10 - removed

    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func17:TtkTokenKind;
    function Func21:TtkTokenKind;
    function Func32:TtkTokenKind;
    function Func34:TtkTokenKind;
    function Func40:TtkTokenKind;
    function Func42:TtkTokenKind;
    function Func45:TtkTokenKind;
    function Func46:TtkTokenKind;
    function Func47:TtkTokenKind;
    function Func48:TtkTokenKind;
    function Func51:TtkTokenKind;
    function Func52:TtkTokenKind;
    function Func54:TtkTokenKind;
    function Func56:TtkTokenKind;
    function Func59:TtkTokenKind;
    function Func60:TtkTokenKind;
    function Func61:TtkTokenKind;
    function Func62:TtkTokenKind;
    function Func63:TtkTokenKind;
    function Func65:TtkTokenKind;
    function Func66:TtkTokenKind;
    function Func68:TtkTokenKind;
    function Func69:TtkTokenKind;
    function Func71:TtkTokenKind;
    function Func76:TtkTokenKind;
    function Func77:TtkTokenKind;
    function Func78:TtkTokenKind;
    function Func84:TtkTokenKind;
    function Func85:TtkTokenKind;
    function Func86:TtkTokenKind;
    function Func88:TtkTokenKind;
    function Func89:TtkTokenKind;
    function Func90:TtkTokenKind;
    function Func92:TtkTokenKind;
    function Func97:TtkTokenKind;
    function Func98:TtkTokenKind;
    function Func102:TtkTokenKind;
    function Func104:TtkTokenKind;
    function Func109:TtkTokenKind;
    function Func115:TtkTokenKind;
    function Func116:TtkTokenKind;
    function Func119:TtkTokenKind;
    function Func129:TtkTokenKind;
    function Func136:TtkTokenKind;
    function Func172:TtkTokenKind;

    procedure CommentProc;

    procedure AndSymbolProc;
    procedure AsciiCharProc;
    procedure AtSymbolProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure CRProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure MultiplyProc;
    procedure NotSymbolProc;
    procedure NullProc;
    procedure NumberProc;
    procedure OrSymbolProc;
    procedure PlusProc;
    procedure PointProc;
    procedure PoundProc;
    procedure QuestionProc;
    procedure RemainderSymbolProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StringProc;
    procedure TildeProc;
    procedure XOrSymbolProc;
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
//  function GetDefaultFilter: string; override;                                //gp 1999-1-10 - removed
//  procedure SetDefaultFilter(Value: string); override;                        //gp 1999-1-10 - removed

    function GetExtTokenID: TxtkTokenKind;
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-08-22
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //aj 1999-02-22
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 199-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    property LanguageName;
    property AttrCount;
    property Attribute;
    property Capability;

    property ExtTokenID: TxtkTokenKind read GetExtTokenID;
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property DocumentAttri: TmwHighLightAttributes read fDocumentAttri write fDocumentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property InvalidAttri: TmwHighLightAttributes read fInvalidAttri write fInvalidAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
//  property DefaultFilter;                                                     //gp 1999-1-10 - removed
  end;

var
  DcjJavaLex: TDcjJavaSyn;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TDcjJavaSyn]);
end;

procedure MakeIdentTable;
var
  I: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '$', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    Case I in['_', '$', 'a'..'z', 'A'..'Z'] of
      True:
        begin
          if (I > #64) and (I < #91) then mHashTable[I] := Ord(I) - 64 else
            if (I > #96) then mHashTable[I] := Ord(I) - 95;
        end;
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TDcjJavaSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 172 do
    Case I of
      17: fIdentFuncTable[I] := Func17;
      21: fIdentFuncTable[I] := Func21;
      32: fIdentFuncTable[I] := Func32;
      34: fIdentFuncTable[I] := Func34;
      40: fIdentFuncTable[I] := Func40;
      42: fIdentFuncTable[I] := Func42;
      45: fIdentFuncTable[I] := Func45;
      46: fIdentFuncTable[I] := Func46;
      47: fIdentFuncTable[I] := Func47;
      48: fIdentFuncTable[I] := Func48;
      51: fIdentFuncTable[I] := Func51;
      52: fIdentFuncTable[I] := Func52;
      54: fIdentFuncTable[I] := Func54;
      56: fIdentFuncTable[I] := Func56;
      59: fIdentFuncTable[I] := Func59;
      60: fIdentFuncTable[I] := Func60;
      61: fIdentFuncTable[I] := Func61;
      62: fIdentFuncTable[I] := Func62;
      63: fIdentFuncTable[I] := Func63;
      65: fIdentFuncTable[I] := Func65;
      66: fIdentFuncTable[I] := Func66;
      68: fIdentFuncTable[I] := Func68;
      69: fIdentFuncTable[I] := Func69;
      71: fIdentFuncTable[I] := Func71;
      76: fIdentFuncTable[I] := Func76;
      77: fIdentFuncTable[I] := Func77;
      78: fIdentFuncTable[I] := Func78;
      84: fIdentFuncTable[I] := Func84;
      85: fIdentFuncTable[I] := Func85;
      86: fIdentFuncTable[I] := Func86;
      88: fIdentFuncTable[I] := Func88;
      89: fIdentFuncTable[I] := Func89;
      90: fIdentFuncTable[I] := Func90;
      92: fIdentFuncTable[I] := Func92;
      97: fIdentFuncTable[I] := Func97;
      98: fIdentFuncTable[I] := Func98;
      102: fIdentFuncTable[I] := Func102;
      104: fIdentFuncTable[I] := Func104;
      109: fIdentFuncTable[I] := Func109;
      115: fIdentFuncTable[I] := Func115;
      116: fIdentFuncTable[I] := Func116;
      119: fIdentFuncTable[I] := Func119;
      129: fIdentFuncTable[I] := Func129;
      136: fIdentFuncTable[I] := Func136;
      172: fIdentFuncTable[I] := Func172;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TDcjJavaSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '$', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TDcjJavaSyn.KeyComp(const aKey: String): Boolean;                      //mh 1999-08-22
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
      if Temp^ <> aKey[i] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end; { KeyComp }

function TDcjJavaSyn.Func17: TtkTokenKind;
begin
  if KeyComp('if') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func21: TtkTokenKind;
begin
  if KeyComp('do') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func32: TtkTokenKind;
begin
  if KeyComp('case') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func34: TtkTokenKind;
begin
  if KeyComp('char') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func40: TtkTokenKind;
begin
  if KeyComp('catch') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func42: TtkTokenKind;
begin
  if KeyComp('for') then Result := tkKey else
    if KeyComp('break') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func45: TtkTokenKind;
begin
  if KeyComp('else') then Result := tkKey else
    if KeyComp('new') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func46: TtkTokenKind;
begin
  if KeyComp('int') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func47: TtkTokenKind;
begin
  if KeyComp('final') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func48: TtkTokenKind;
begin
  if KeyComp('false') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func51: TtkTokenKind;
begin
  if KeyComp('package') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func52: TtkTokenKind;
begin
  if KeyComp('long') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func54: TtkTokenKind;
begin
  if KeyComp('void') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func56: TtkTokenKind;
begin
  if KeyComp('byte') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func59: TtkTokenKind;
begin
  if KeyComp('class') then Result := tkKey else
    if KeyComp('float') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func60: TtkTokenKind;
begin
  if KeyComp('this') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func61: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func62: TtkTokenKind;
begin
  if KeyComp('while') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func63: TtkTokenKind;
begin
  if KeyComp('null') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func65: TtkTokenKind;
begin
  if KeyComp('double') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func66: TtkTokenKind;
begin
  if KeyComp('try') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func68: TtkTokenKind;
begin
  if KeyComp('true') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func69: TtkTokenKind;
begin
  if KeyComp('public') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func71: TtkTokenKind;
begin
  if KeyComp('boolean') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func76: TtkTokenKind;
begin
  if KeyComp('default') then Result := tkKey else
    if KeyComp('const') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func77: TtkTokenKind;
begin
  if KeyComp('native') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func78: TtkTokenKind;
begin
  if KeyComp('static') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func84: TtkTokenKind;
begin
  if KeyComp('super') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func85: TtkTokenKind;
begin
  if KeyComp('short') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func86: TtkTokenKind;
begin
  if KeyComp('finally') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func88: TtkTokenKind;
begin
  if KeyComp('switch') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func89: TtkTokenKind;
begin
  if KeyComp('throw') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func90: TtkTokenKind;
begin
  if KeyComp('interface') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func92: TtkTokenKind;
begin
  if KeyComp('abstract') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func97: TtkTokenKind;
begin
  if KeyComp('import') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func98: TtkTokenKind;
begin
  if KeyComp('extends') then Result := tkKey else
    if KeyComp('private') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func102: TtkTokenKind;
begin
  if KeyComp('return') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func104: TtkTokenKind;
begin
  if KeyComp('volatile') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func109: TtkTokenKind;
begin
  if KeyComp('continue') then Result := tkKey else
    if KeyComp('throws') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func115: TtkTokenKind;
begin
  if KeyComp('protected') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func116: TtkTokenKind;
begin
  if KeyComp('instanceof') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func119: TtkTokenKind;
begin
  if KeyComp('strictfp') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func129: TtkTokenKind;
begin
  if KeyComp('transient') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func136: TtkTokenKind;
begin
  if KeyComp('implements') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.Func172: TtkTokenKind;
begin
  if KeyComp('synchronized') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjJavaSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TDcjJavaSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 173 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TDcjJavaSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '&': fProcTable[I] := AndSymbolProc;
      #39: fProcTable[I] := AsciiCharProc;
      '@': fProcTable[I] := AtSymbolProc;
      '}': fProcTable[I] := BraceCloseProc;
      '{': fProcTable[I] := BraceOpenProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := ColonProc;
      ',': fProcTable[I] := CommaProc;
      '=': fProcTable[I] := EqualProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z', '_', '$': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      '*': fProcTable[I] := MultiplyProc;
      '!': fProcTable[I] := NotSymbolProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '|': fProcTable[I] := OrSymbolProc;
      '+': fProcTable[I] := PlusProc;
      '.': fProcTable[I] := PointProc;
      '#': fProcTable[I] := PoundProc;
      '?': fProcTable[I] := QuestionProc;
      '%': fProcTable[I] := RemainderSymbolProc;
      ')': fProcTable[I] := RoundCloseProc;
      '(': fProcTable[I] := RoundOpenProc;
      ';': fProcTable[I] := SemiColonProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      ']': fProcTable[I] := SquareCloseProc;
      '[': fProcTable[I] := SquareOpenProc;
      #34: fProcTable[I] := StringProc;
      '~': fProcTable[I] := TildeProc;
      '^': fProcTable[I] := XOrSymbolProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TDcjJavaSyn.Create(AOwner: TComponent);
begin
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);
  fCommentAttri.Style := [fsItalic];
  fDocumentAttri := TmwHighLightAttributes.Create(MWS_AttrDocumentation);
  fDocumentAttri.Style := [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  fInvalidAttri := TmwHighLightAttributes.Create(MWS_AttrInvalidSymbol);
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Style := [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);
  fSpaceAttri.Foreground := clWindow;
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  fRange := rsUnknown;

  inherited Create(AOwner);
{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fDocumentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fInvalidAttri);
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
  fDefaultFilter := MWS_FilterJava;                                             //ajb 1999-09-14
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TDcjJavaSyn.Destroy;
begin
  fCommentAttri.Free;
  fDocumentAttri.Free;
  fIdentifierAttri.Free;
  fInvalidAttri.Free;
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
procedure TDcjJavaSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TDcjJavaSyn.SetLine(NewValue: String; LineNumber:Integer);            //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
  fEol := False;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TDcjJavaSyn.CommentProc;
begin
  if fRange = rsComment then
    fTokenID := tkComment
  else
    fTokenID := tkDocument;
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
      '*':
        if fLine[Run + 1] = '/' then
        begin
          inc(Run, 2);
          fRange := rsUnknown;
          break;
        end
        else inc(Run);
      #10: break;
      #13: break;
    else inc(Run);
    end;
end;

procedure TDcjJavaSyn.AndSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {and assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkAndAssign;
      end;
    '&':                               {conditional and}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkCondAnd;
      end;
  else                                 {and}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkAnd;
    end;
  end;
end;

procedure TDcjJavaSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
      #92:                             {backslash}
        {if we have an escaped single quote it doesn't count}
        if FLine[Run + 1] = #39 then inc(Run);
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TDcjJavaSyn.AtSymbolProc;
begin
  fTokenID := tkInvalid;
  inc(Run);
end;

procedure TDcjJavaSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
  FExtTokenID := xtkBraceClose;
end;

procedure TDcjJavaSyn.BraceOpenProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
  FExtTokenID := xtkBraceOpen;
end;

procedure TDcjJavaSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TDcjJavaSyn.ColonProc;
begin
  inc(Run);                            {colon - conditional}
  fTokenID := tkSymbol;
  FExtTokenID := xtkColon;
end;

procedure TDcjJavaSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkInvalid;
end;

procedure TDcjJavaSyn.EqualProc;
begin
  case FLine[Run + 1] of
    '=':                               {logical equal}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkLogEqual;
      end;
  else                                 {assign}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkAssign;
    end;
  end;
end;

procedure TDcjJavaSyn.GreaterProc;
begin
  Case FLine[Run + 1] of
    '=':                               {greater than or equal to}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkGreaterThanEqual;
      end;
    '>':
      begin
        Case FLine[Run + 2] of
          '=':                         {shift right assign}
            begin
            inc(Run, 3);
            FExtTokenID := xtkShiftRightAssign;
            end;
          '>':
            if FLine[Run + 3] = '=' then
            begin
              inc(Run, 4);             {unsigned shift right assign}
              FExtTokenID := xtkUnsignShiftRightAssign;
            end
            else
            begin
              inc(Run, 3);             {unsigned shift right}
              FExtTokenID := xtkUnsignShiftRight;
            end;
        else                           {shift right}
          begin
            inc(Run, 2);
            FExtTokenID := xtkShiftRight;
          end;
        end;
        fTokenID := tkSymbol;
      end;
  else                                 {greater than}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkGreaterThan;
    end;
  end;
end;

procedure TDcjJavaSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TDcjJavaSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TDcjJavaSyn.LowerProc;
begin
  case FLine[Run + 1] of
    '=':                               {less than or equal to}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkLessThanEqual;
      end;
    '<':
      begin
        if FLine[Run + 2] = '=' then   {shift left assign}
        begin
          inc(Run, 3);
          FExtTokenID := xtkShiftLeftAssign;
        end
        else                           {shift left}
        begin
          inc(Run, 2);
          FExtTokenID := xtkShiftLeft;
        end;
        fTokenID := tkSymbol;
      end;
  else                                 {less than}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkLessThan;
    end;
  end;
end;

procedure TDcjJavaSyn.MinusProc;
begin
  case FLine[Run + 1] of
    '=':                               {subtract assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkSubtractAssign;
      end;
    '-':                               {decrement}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkDecrement;
      end;
  else                                 {subtract}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkSubtract;
    end;
  end;
end;

procedure TDcjJavaSyn.MultiplyProc;
begin
  case FLine[Run + 1] of
    '=':                               {multiply assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkMultiplyAssign;
      end;
  else                                 {multiply}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkMultiply;
    end;
  end;
end;

procedure TDcjJavaSyn.NotSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {not equal}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkNotEqual;
      end;
  else                                 {logical complement}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkLogComplement;
    end;
  end;
end;

procedure TDcjJavaSyn.NullProc;
begin
  fTokenID := tkNull;
  fEol := True;
end;

procedure TDcjJavaSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in
      ['0'..'9', '.', '-', 'l', 'L', 'x', 'X', 'A'..'F', 'a'..'f'] do
  begin
    case FLine[Run] of
      '.':
        if FLine[Run + 1] = '.' then break;
    end;
    inc(Run);
  end;
end;

procedure TDcjJavaSyn.OrSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {inclusive or assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkIncOrAssign;
      end;
    '|':                               {conditional or}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkCondOr;
      end;
  else                                 {inclusive or}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkIncOr;
    end;
  end;
end;

procedure TDcjJavaSyn.PlusProc;
begin
  case FLine[Run + 1] of
    '=':                               {add assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkAddAssign;
      end;
    '+':                               {increment}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkIncrement;
      end;
  else                                 {add}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkAdd;
    end;
  end;
end;

procedure TDcjJavaSyn.PointProc;
begin
  inc(Run);                            {point}
  fTokenID := tkSymbol;
  FExtTokenID := xtkPoint;
end;

procedure TDcjJavaSyn.PoundProc;
begin
  inc(Run);
  fTokenID := tkInvalid;
end;

procedure TDcjJavaSyn.QuestionProc;
begin
  fTokenID := tkSymbol;                {question mark - conditional}
  FExtTokenID := xtkQuestion;
  inc(Run);
end;

procedure TDcjJavaSyn.RemainderSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {remainder assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkRemainderAssign;
      end;
  else                                 {remainder}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkRemainder;
    end;
  end;
end;

procedure TDcjJavaSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkRoundClose;
  dec(FRoundCount);
end;

procedure TDcjJavaSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := tkSymbol;
  FExtTokenID := xtkRoundOpen;
  inc(FRoundCount);
end;

procedure TDcjJavaSyn.SemiColonProc;
begin
  inc(Run);                            {semicolon}
  fTokenID := tkSymbol;
  FExtTokenID := xtkSemiColon;
end;

procedure TDcjJavaSyn.SlashProc;
begin
  case FLine[Run + 1] of
    '/':                               {c++ style comments}
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
        if fLine[Run+2] = '*' then     {documentation comment}
        begin
          fRange := rsDocument;
          fTokenID := tkDocument;
          inc(Run);
        end
        else                           {c style comment}
        begin
          fRange := rsComment;
          fTokenID := tkComment;
        end;

        inc(Run,2);
        while fLine[Run] <> #0 do
          case fLine[Run] of
            '*':
              if fLine[Run + 1] = '/' then
              begin
                inc(Run, 2);
                fRange := rsUnknown;
                break;
              end else inc(Run);
            #10: break;
            #13: break;
          else
            inc(Run);
          end;
      end;
    '=':                               {division assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkDivideAssign;
      end;
  else                                 {division}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkDivide;
    end;
  end;
end;

procedure TDcjJavaSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TDcjJavaSyn.SquareCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkSquareClose;
  dec(FSquareCount);
end;

procedure TDcjJavaSyn.SquareOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkSquareOpen;
  inc(FSquareCount);
end;

procedure TDcjJavaSyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #34) and (FLine[Run + 2] = #34) then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
      #92:                             {backslash}
        {if we have an escaped quote it doesn't count}
        if FLine[Run + 1] = #34 then inc(Run);
    end;
    inc(Run);
  until FLine[Run] = #34;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TDcjJavaSyn.TildeProc;
begin
  inc(Run);                            {bitwise complement}
  fTokenId := tkSymbol;
  FExtTokenID := xtkBitComplement;
end;

procedure TDcjJavaSyn.XOrSymbolProc;
begin
  Case FLine[Run + 1] of
    '=':                               {xor assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkXorAssign;
      end;
  else                                 {xor}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkXor;
    end;
  end;
end;

procedure TDcjJavaSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TDcjJavaSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //aj 1999-02-22
begin
  fTokenPos := Run;
  Case fRange of
    rsComment: CommentProc;
    rsDocument: CommentProc;
  else
    begin
      fRange := rsUnknown;
      fProcTable[fLine[Run]];
    end;
  end;
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //aj 1999-02-22
    case TokenID of                                                             //aj 1999-02-22
      tkComment:
        with fCanvas do
        begin
          Brush.Color:= fCommentAttri.Background;
          Font.Color:=  fCommentAttri.Foreground;
          Font.Style:=  fCommentAttri.Style;
        end;
      tkDocument:
        with fCanvas do
        begin
          Brush.Color:= fDocumentAttri.Background;
          Font.Color:=  fDocumentAttri.Foreground;
          Font.Style:=  fDocumentAttri.Style;
        end;
      tkIdentifier:
        with fCanvas do
        begin
          Brush.Color:= fIdentifierAttri.Background;
          Font.Color:=  fIdentifierAttri.Foreground;
          Font.Style:=  fIdentifierAttri.Style;
        end;
      tkInvalid:
        with fCanvas do
        begin
          Brush.Color:= fInvalidAttri.Background;
          Font.Color:=  fInvalidAttri.Foreground;
          Font.Style:=  fInvalidAttri.Style;
        end;
      tkKey:
        with fCanvas do
        begin
          Brush.Color:= fKeyAttri.Background;
          Font.Color:=  fKeyAttri.Foreground;
          Font.Style:=  fKeyAttri.Style;
        end;
      tkNumber:
        with fCanvas do
        begin
          Brush.Color:= fNumberAttri.Background;
          Font.Color:=  fNumberAttri.Foreground;
          Font.Style:=  fNumberAttri.Style;
        end;
      tkSpace:
        with fCanvas do
        begin
          Brush.Color:= fSpaceAttri.Background;
          Font.Color:=  fSpaceAttri.Foreground;
          Font.Style:=  fSpaceAttri.Style;
        end;
      tkString:
        with fCanvas do
        begin
          Brush.Color:= fStringAttri.Background;
          Font.Color:=  fStringAttri.Foreground;
          Font.Style:=  fStringAttri.Style;
        end;
      tkSymbol:
        with fCanvas do
        begin
          Brush.Color:= fSymbolAttri.Background;
          Font.Color:=  fSymbolAttri.Foreground;
          Font.Style:=  fSymbolAttri.Style;
        end;
      tkUnknown:
        with fCanvas do
        begin
          Brush.Color:= fInvalidAttri.Background;
          Font.Color:=  fInvalidAttri.Foreground;
          Font.Style:=  fInvalidAttri.Style;
        end;
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-27 //mh 1999-08-22
  end;
*)
end;

function TDcjJavaSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TDcjJavaSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TDcjJavaSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TDcjJavaSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TDcjJavaSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TDcjJavaSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TDcjJavaSyn.GetExtTokenID: TxtkTokenKind;
begin
  Result := FExtTokenID;
end;

function TDcjJavaSyn.GetTokenAttribute: TmwHighLightAttributes;                 //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkDocument: Result := fDocumentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkInvalid: Result := fInvalidAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fInvalidAttri;
    else Result := nil;
  end;
end;

function TDcjJavaSyn.GetTokenKind: integer;                                     //mh 199-08-22
begin
  Result := Ord(fTokenId);
end;

function TDcjJavaSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

{begin}                                                                         //mh 1999-08-22
(*
procedure TDcjJavaSyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TDcjJavaSyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fDocumentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fInvalidAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;

function TDcjJavaSyn.GetAttribCount: integer;
begin
  Result := 9;
end;

function TDcjJavaSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of
    0: Result := fCommentAttri;
    1: Result := fDocumentAttri;
    2: Result := fIdentifierAttri;
    3: Result := fInvalidAttri;
    4: Result := fKeyAttri;
    5: Result := fNumberAttri;
    6: Result := fSpaceAttri;
    7: Result := fStringAttri;
    8: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TDcjJavaSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '$', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TDcjJavaSyn.GetLanguageName: string;
begin
  Result := MWS_LangJava;
end;

//function TDcjJavaSyn.GetDefaultFilter: string;                                //gp 1999-1-10 - removed
//begin
//  Result := fDefaultFilter;
//end;

//procedure TDcjJavaSyn.SetDefaultFilter(Value: string);                        //gp 1999-1-10 - removed
//begin
//  if fDefaultFilter <> Value then fDefaultFilter := Value;
//end;


Initialization
  MakeIdentTable;
end.
