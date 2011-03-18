{+-----------------------------------------------------------------------------+
 | Class:       TlbVbsSyn
 | Created:     20.01.1999
 | Last change: 1999-09-24
 | Author:      Luiz C. Vaz de Brito
 | Description: MS VbScript Syntax Highliter
 |
 | Version:     0.13 (for version history see version.rtf)
 | Copyright (c) 1998 Luiz C. Vaz de Brito
 | No rights reserved.
 |
 | Thanks to: Primoz Gabrijelcic and Martin Waldenburg
 +--------------------------------------------------------------------------+}

unit lbVBSSyn;

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

  TRangeState = (rsANil, rsUnKnown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

type
  TlbVbsSyn = class(TmwCustomHighLighter)
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

    {Sintax Highlight Attributes}
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;                                                

    fIdentFuncTable: array[0..133] of TIdentFuncTableFunc;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func15:TtkTokenKind;
    function Func17:TtkTokenKind;
    function Func19:TtkTokenKind;
    function Func23:TtkTokenKind;
    function Func26:TtkTokenKind;
    function Func28:TtkTokenKind;
    function Func29:TtkTokenKind;
    function Func32:TtkTokenKind;
    function Func33:TtkTokenKind;
    function Func36:TtkTokenKind;
    function Func37:TtkTokenKind;
    function Func38:TtkTokenKind;
    function Func39:TtkTokenKind;
    function Func41:TtkTokenKind;
    function Func42:TtkTokenKind;
    function Func44:TtkTokenKind;
    function Func46:TtkTokenKind;
    function Func47:TtkTokenKind;
    function Func48:TtkTokenKind;
    function Func49:TtkTokenKind;
    function Func54:TtkTokenKind;
    function Func57:TtkTokenKind;
    function Func58:TtkTokenKind;
    function Func63:TtkTokenKind;
    function Func64:TtkTokenKind;
    function Func71:TtkTokenKind;
    function Func74:TtkTokenKind;
    function Func89:TtkTokenKind;
    function Func91:TtkTokenKind;
    function Func98:TtkTokenKind;
    function Func102:TtkTokenKind;
    function Func105:TtkTokenKind;
    function Func133:TtkTokenKind;
    procedure AmpersandProc;
    procedure ApostropheProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure CRProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure DateProc;
    procedure EqualProc;
    procedure ExponentiationProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PlusProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure StarProc;
    procedure StringProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
//    procedure AssignAttributes(Attributes: TmwHighLightAttributes);           //mh 1999-09-12

    {Highlighter Draw Stuff}
//    procedure HighLightChange(Sender: TObject);                               //mh 1999-08-22
//    procedure SetHighLightChange;                                             //mh 1999-08-22
  protected
    {General Stuff}
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;

//    function GetAttribCount: integer; override;                               //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;    //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 199-08-22
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-05-06
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;

    property IdentChars;
    property LanguageName;
    property AttrCount;
    property Attribute;
    property Capability;
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
  RegisterComponents('mw', [TlbVBSSyn]);
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
    Case I in['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TlbVbsSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 133 do
    Case I of
      15: fIdentFuncTable[I] := Func15;
      17: fIdentFuncTable[I] := Func17;
      19: fIdentFuncTable[I] := Func19;
      23: fIdentFuncTable[I] := Func23;
      26: fIdentFuncTable[I] := Func26;
      28: fIdentFuncTable[I] := Func28;
      29: fIdentFuncTable[I] := Func29;
      32: fIdentFuncTable[I] := Func32;
      33: fIdentFuncTable[I] := Func33;
      36: fIdentFuncTable[I] := Func36;
      37: fIdentFuncTable[I] := Func37;
      38: fIdentFuncTable[I] := Func38;
      39: fIdentFuncTable[I] := Func39;
      41: fIdentFuncTable[I] := Func41;
      42: fIdentFuncTable[I] := Func42;
      44: fIdentFuncTable[I] := Func44;
      46: fIdentFuncTable[I] := Func46;
      47: fIdentFuncTable[I] := Func47;
      48: fIdentFuncTable[I] := Func48;
      49: fIdentFuncTable[I] := Func49;
      54: fIdentFuncTable[I] := Func54;
      57: fIdentFuncTable[I] := Func57;
      58: fIdentFuncTable[I] := Func58;
      63: fIdentFuncTable[I] := Func63;
      64: fIdentFuncTable[I] := Func64;
      71: fIdentFuncTable[I] := Func71;
      74: fIdentFuncTable[I] := Func74;
      89: fIdentFuncTable[I] := Func89;
      91: fIdentFuncTable[I] := Func91;
      98: fIdentFuncTable[I] := Func98;
      102: fIdentFuncTable[I] := Func102;
      105: fIdentFuncTable[I] := Func105;
      133: fIdentFuncTable[I] := Func133;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TlbVbsSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TlbVbsSyn.KeyComp(const aKey: String): Boolean;                        //mh 1999-08-22
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

function TlbVbsSyn.Func15: TtkTokenKind;
begin
  if KeyComp('If') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func17: TtkTokenKind;
begin
  if KeyComp('Each') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func19: TtkTokenKind;
begin
  if KeyComp('Do') then Result := tkKey else
    if KeyComp('And') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func23: TtkTokenKind;
begin
  if KeyComp('End') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func26: TtkTokenKind;
begin
  if KeyComp('Dim') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func28: TtkTokenKind;
begin
  if KeyComp('Case') then Result := tkKey else
    if KeyComp('Call') then Result := tkKey else
      if KeyComp('Is') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func29: TtkTokenKind;
begin
  if KeyComp('On') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func32: TtkTokenKind;
begin
  if KeyComp('Mod') then Result := tkKey else
    if KeyComp('Get') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func33: TtkTokenKind;
begin
  if KeyComp('Or') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func36: TtkTokenKind;
begin
  if KeyComp('Rem') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func37: TtkTokenKind;
begin
  if KeyComp('Let') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func38: TtkTokenKind;
begin
  if KeyComp('Imp') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func39: TtkTokenKind;
begin
  if KeyComp('For') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func41: TtkTokenKind;
begin
  if KeyComp('Else') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func42: TtkTokenKind;
begin
  if KeyComp('Sub') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func44: TtkTokenKind;
begin
  if KeyComp('Eqv') then Result := tkKey else
    if KeyComp('Set') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func46: TtkTokenKind;
begin
  if KeyComp('Wend') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func47: TtkTokenKind;
begin
  if KeyComp('Then') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func48: TtkTokenKind;
begin
  if KeyComp('Erase') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func49: TtkTokenKind;
begin
  if KeyComp('ReDim') then Result := tkKey else
    if KeyComp('Not') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func54: TtkTokenKind;
begin
  if KeyComp('Class') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func57: TtkTokenKind;
begin
  if KeyComp('Xor') then Result := tkKey else
    if KeyComp('While') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func58: TtkTokenKind;
begin
  if KeyComp('Loop') then Result := tkKey else
    if KeyComp('Exit') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func63: TtkTokenKind;
begin
  if KeyComp('Next') then Result := tkKey else
    if KeyComp('Public') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func64: TtkTokenKind;
begin
  if KeyComp('Select') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func71: TtkTokenKind;
begin
  if KeyComp('Const') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func74: TtkTokenKind;
begin
  if KeyComp('Error') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func89: TtkTokenKind;
begin
  if KeyComp('Option') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func91: TtkTokenKind;
begin
  if KeyComp('Private') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func98: TtkTokenKind;
begin
  if KeyComp('Explicit') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func102: TtkTokenKind;
begin
  if KeyComp('Function') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func105: TtkTokenKind;
begin
  if KeyComp('Randomize') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.Func133: TtkTokenKind;
begin
  if KeyComp('property') then Result := tkKey else Result := tkIdentifier;
end;

function TlbVbsSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TlbVbsSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 134 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TlbVbsSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '&': fProcTable[I] := AmpersandProc;
      #39: fProcTable[I] := ApostropheProc;
      '}': fProcTable[I] := BraceCloseProc;
      '{': fProcTable[I] := BraceOpenProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := ColonProc;
      ',': fProcTable[I] := CommaProc;
      '#': fProcTable[I] := DateProc;
      '=': fProcTable[I] := EqualProc;
      '^': fProcTable[I] := ExponentiationProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '+': fProcTable[I] := PlusProc;
      '.': fProcTable[I] := PointProc;
      ')': fProcTable[I] := RoundCloseProc;
      '(': fProcTable[I] := RoundOpenProc;
      ';': fProcTable[I] := SemiColonProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      '*': fProcTable[I] := StarProc;
      #34: fProcTable[I] := StringProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TlbVbsSyn.Create(AOwner: TComponent);
begin
  fCommentAttri       := TmwHighLightAttributes.Create(MWS_AttrComment);
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri    := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  fKeyAttri           := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Style     := [fsBold];
  fNumberAttri        := TmwHighLightAttributes.Create(MWS_AttrNumber);
  fSpaceAttri         := TmwHighLightAttributes.Create(MWS_AttrSpace);
  fStringAttri        := TmwHighLightAttributes.Create(MWS_AttrString);
  fSymbolAttri        := TmwHighLightAttributes.Create(MWS_AttrSymbol);
//  SetHighlightChange;                                                         //mh 1999-08-22

  inherited Create(AOwner);

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22

  fRange              := rsUnknown;
  fDefaultFilter      := MWS_FilterVBScript;                                    //ajb 1999-09-14

  InitIdent;
  MakeMethodTables;
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TlbVbsSyn.Destroy;
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
procedure TlbVbsSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TlbVbsSyn.SetLine(NewValue: String; LineNumber:Integer);              //gp 1999-05-06
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  fLineNumber := LineNumber;                                                    //mh 1999-08-22
  Next;
end; { SetLine }

procedure TlbVbsSyn.AmpersandProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TlbVbsSyn.ApostropheProc;
begin
  fTokenID := tkComment;
  inc(Run);
  while FLine[Run] <> #0 do
    case FLine[Run] of
      #10: break;
      #13: break;
    else inc(Run);
    end;
end;

procedure TlbVbsSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TlbVbsSyn.BraceOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TlbVbsSyn.ColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.DateProc;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = '#';
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TlbVbsSyn.EqualProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.ExponentiationProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.GreaterProc;
begin
{begin}                                                                         //mh 1999-08-22
(*
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
*)
  fTokenID := tkSymbol;
  Inc(Run);
  if fLine[Run] = '=' then Inc(Run);
{end}                                                                           //mh 1999-08-22    
end;

procedure TlbVbsSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TlbVbsSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TlbVbsSyn.LowerProc;
begin
{begin}                                                                         //mh 1999-08-22
(*
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
*)
  fTokenID := tkSymbol;
  Inc(Run);
  if fLine[Run] in ['=', '>'] then Inc(Run);
{end}                                                                           //mh 1999-08-22
end;

procedure TlbVbsSyn.MinusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-08-22
end;

procedure TlbVbsSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', '.', 'e', 'E'] do inc(Run);
end;

procedure TlbVbsSyn.PlusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.PointProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := tkSymbol;
end;

procedure TlbVbsSyn.SemiColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.SlashProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TlbVbsSyn.StarProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TlbVbsSyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #34) and (FLine[Run + 2] = #34) then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #34;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TlbVbsSyn.UnknownProc;
begin
  fTokenID := tkIdentifier;
  inc(Run);
end;

procedure TlbVbsSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //gp 1999-05-06
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //gp 1999-05-06
    case TokenID of                                                             //gp 1999-05-06
      tkComment:     AssignAttributes(fCommentAttri);
      tkIdentifier:  AssignAttributes(fIdentifierAttri);
      tkKey:         AssignAttributes(fKeyAttri);
      tkNumber:      AssignAttributes(fNumberAttri);
      tkSpace:       AssignAttributes(fSpaceAttri);
      tkString:      AssignAttributes(fStringAttri);
      tkSymbol:      AssignAttributes(fSymbolAttri);
      tkUnknown:     AssignAttributes(fIdentifierAttri);
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-05-06 //mh 1999-08-22
  end;
*)
end;

function TlbVbsSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TlbVbsSyn.GetRange: Pointer;
begin
 Result := Pointer(fRange);
end;

function TlbVbsSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TlbVbsSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TlbVbsSyn.GetTokenAttribute: TmwHighLightAttributes;                   //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fIdentifierAttri;
    else Result := nil;
  end;
end;

function TlbVbsSyn.GetTokenKind: integer;                                       //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TlbVbsSyn.GetTokenPos: Integer;
begin
 Result := fTokenPos;
end;

procedure TlbVbsSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TlbVbsSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //mh 1999-08-22
(*
function TlbVbsSyn.GetAttribCount: integer;
begin
  Result := 7;
end;

function TlbVbsSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fKeyAttri;
    3: Result := fNumberAttri;
    4: Result := fSpaceAttri;
    5: Result := fStringAttri;
    6: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TlbVbsSyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings];
end;

function TlbVbsSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TlbVbsSyn.GetLanguageName: string;
begin
  Result := MWS_LangVBSScript;                                                  //mh 1999-09-24
end;

{begin}                                                                         //mh 1999-08-22
(*
procedure TlbVbsSyn.HighLightChange(Sender: TObject);
begin
  mwEditList.Invalidate;
end;

procedure TlbVbsSyn.SetHighLightChange;
begin
  fCommentAttri.OnChange    := HighLightChange;
  fIdentifierAttri.OnChange := HighLightChange;
  fKeyAttri.OnChange        := HighLightChange;
  fNumberAttri.OnChange     := HighLightChange;
  fSpaceAttri.OnChange      := HighLightChange;
  fStringAttri.OnChange     := HighLightChange;
  fSymbolAttri.OnChange     := HighLightChange;
end;
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
procedure TlbVbsSyn.AssignAttributes(Attributes: TmwHighLightAttributes);
begin
 with Attributes do
   begin
     if fCanvas.Brush.Color <> Background then fCanvas.Brush.Color := Background;
     if fCanvas.Font.Color  <> Foreground then fCanvas.Font.Color  := Foreground;
     if fCanvas.Font.Style  <> Style      then fCanvas.Font.Style  := Style;
   end;
end;
*)

Initialization
  MakeIdentTable;
end.
