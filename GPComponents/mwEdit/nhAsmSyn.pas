{+--------------------------------------------------------------------------+
 |                 x86 Assembly Language Syntax Parser v0.56                |
 +--------------------------------------------------------------------------+
 |
 | Description:   An x86 Assembly Language syntax parser for use
 |                with mwCustomEdit. Supports all x86 Op codes, plus Intel MMX
 |                and AMD 3D Now Op codes.
 |
 +--------------------------------------------------------------------------+
 | Unit:          nhAsmSyn
 | Created:       07/99
 | Last change:   1999-09-24
 | Author:        Nick Hoddinott (nickh@conceptdelta.com)
 | Copyright      (c) 1999 All rights reserved
 |                (Large!) Portions Copyright Martin Waldenburg
 | Version:       0.56
 | Status:        Public Domain
 | DISCLAIMER:    This is provided as is, expressly without a warranty of any kind.
 |                You use it at your own risc.
 |
 | Thanks to:     Martin Waldenburg, Dave Muir, Hideo Koiso
 +--------------------------------------------------------------------------+
 |Know problems:
 |
 +--------------------------------------------------------------------------+
 |Revision History:
 |
 | 0.56:    * Adapted to the new mwEdit version 0.86 - see //mh 1999-09-24
 | 0.55:    * Removed high level language keywords for time being.
 |            Added support for # and // comments. These are suppported by
 |            some assemblers.
 | 0.50:    * Initial version.
 +--------------------------------------------------------------------------+}


unit nhAsmSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry, mwHighlighter;

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
  TnhAsmSyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-24
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;                                                       //gp 1999-05-06
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
//    fEol: Boolean;                                                            //mh 1999-09-24

    {Syntax Highlight Attributes}
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;

    fIdentFuncTable: array[0..121] of TIdentFuncTableFunc;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-09-24

    function Func6:TtkTokenKind;
    function Func8:TtkTokenKind;
    function Func9:TtkTokenKind;
    function Func11:TtkTokenKind;
    function Func12:TtkTokenKind;
    function Func13:TtkTokenKind;
    function Func15:TtkTokenKind;
    function Func16:TtkTokenKind;
    function Func17:TtkTokenKind;
    function Func18:TtkTokenKind;
    function Func19:TtkTokenKind;
    function Func22:TtkTokenKind;
    function Func23:TtkTokenKind;
    function Func24:TtkTokenKind;
    function Func25:TtkTokenKind;
    function Func26:TtkTokenKind;
    function Func27:TtkTokenKind;
    function Func28:TtkTokenKind;
    function Func29:TtkTokenKind;
    function Func30:TtkTokenKind;
    function Func31:TtkTokenKind;
    function Func32:TtkTokenKind;
    function Func33:TtkTokenKind;
    function Func34:TtkTokenKind;
    function Func35:TtkTokenKind;
    function Func36:TtkTokenKind;
    function Func37:TtkTokenKind;
    function Func38:TtkTokenKind;
    function Func39:TtkTokenKind;
    function Func40:TtkTokenKind;
    function Func41:TtkTokenKind;
    function Func42:TtkTokenKind;
    function Func43:TtkTokenKind;
    function Func44:TtkTokenKind;
    function Func45:TtkTokenKind;
    function Func46:TtkTokenKind;
    function Func47:TtkTokenKind;
    function Func48:TtkTokenKind;
    function Func49:TtkTokenKind;
    function Func50:TtkTokenKind;
    function Func51:TtkTokenKind;
    function Func52:TtkTokenKind;
    function Func53:TtkTokenKind;
    function Func54:TtkTokenKind;
    function Func55:TtkTokenKind;
    function Func56:TtkTokenKind;
    function Func57:TtkTokenKind;
    function Func58:TtkTokenKind;
    function Func59:TtkTokenKind;
    function Func60:TtkTokenKind;
    function Func61:TtkTokenKind;
    function Func62:TtkTokenKind;
    function Func63:TtkTokenKind;
    function Func64:TtkTokenKind;
    function Func65:TtkTokenKind;
    function Func66:TtkTokenKind;
    function Func67:TtkTokenKind;
    function Func68:TtkTokenKind;
    function Func69:TtkTokenKind;
    function Func70:TtkTokenKind;
    function Func71:TtkTokenKind;
    function Func72:TtkTokenKind;
    function Func73:TtkTokenKind;
    function Func74:TtkTokenKind;
    function Func75:TtkTokenKind;
    function Func76:TtkTokenKind;
    function Func77:TtkTokenKind;
    function Func78:TtkTokenKind;
    function Func79:TtkTokenKind;
    function Func80:TtkTokenKind;
    function Func81:TtkTokenKind;
    function Func82:TtkTokenKind;
    function Func83:TtkTokenKind;
    function Func84:TtkTokenKind;
    function Func85:TtkTokenKind;
    function Func86:TtkTokenKind;
    function Func87:TtkTokenKind;
    function Func88:TtkTokenKind;
    function Func90:TtkTokenKind;
    function Func92:TtkTokenKind;
    function Func93:TtkTokenKind;
    function Func94:TtkTokenKind;
    function Func96:TtkTokenKind;
    function Func97:TtkTokenKind;
    function Func98:TtkTokenKind;
    function Func100:TtkTokenKind;
    function Func101:TtkTokenKind;
    function Func104:TtkTokenKind;
    function Func105:TtkTokenKind;
    function Func110:TtkTokenKind;
    function Func111:TtkTokenKind;
    function Func114:TtkTokenKind;
    function Func116:TtkTokenKind;
    function Func118:TtkTokenKind;
    function Func120:TtkTokenKind;
    function Func121:TtkTokenKind;

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
//    procedure AssignAttributes(Attributes: TmwHighLightAttributes);           //mh 1999-09-24

    {Highlighter Draw Stuff}
//    procedure HighLightChange(Sender: TObject);                               //mh 1999-09-24
//    procedure SetHighLightChange;                                             //mh 1999-09-24
  protected
    {General Stuff}
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;

//    function GetAttribCount: integer; override;                               //mh 1999-09-24
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;    //mh 1999-09-24
    function GetCapability: THighlighterCapability; override;
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-09-24
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-05-06
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-24
    function GetTokenKind: integer; override;                                   //mh 1999-09-24
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-24
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;

    property IdentChars;
    property LanguageName;
//    property AttrCount;                                                       //mh 1999-09-24
//    property Attribute;                                                       //mh 1999-09-24
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

uses mwLocalStr;                                                                //mh 1999-09-24

procedure Register;
begin
  RegisterComponents('mw', [TnhAsmSyn]);
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


procedure TnhAsmSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 121 do
    Case I of
      6: fIdentFuncTable[I] := Func6;
      8: fIdentFuncTable[I] := Func8;
      9: fIdentFuncTable[I] := Func9;
      11: fIdentFuncTable[I] := Func11;
      12: fIdentFuncTable[I] := Func12;
      13: fIdentFuncTable[I] := Func13;
      15: fIdentFuncTable[I] := Func15;
      16: fIdentFuncTable[I] := Func16;
      17: fIdentFuncTable[I] := Func17;
      18: fIdentFuncTable[I] := Func18;
      19: fIdentFuncTable[I] := Func19;
      22: fIdentFuncTable[I] := Func22;
      23: fIdentFuncTable[I] := Func23;
      24: fIdentFuncTable[I] := Func24;
      25: fIdentFuncTable[I] := Func25;
      26: fIdentFuncTable[I] := Func26;
      27: fIdentFuncTable[I] := Func27;
      28: fIdentFuncTable[I] := Func28;
      29: fIdentFuncTable[I] := Func29;
      30: fIdentFuncTable[I] := Func30;
      31: fIdentFuncTable[I] := Func31;
      32: fIdentFuncTable[I] := Func32;
      33: fIdentFuncTable[I] := Func33;
      34: fIdentFuncTable[I] := Func34;
      35: fIdentFuncTable[I] := Func35;
      36: fIdentFuncTable[I] := Func36;
      37: fIdentFuncTable[I] := Func37;
      38: fIdentFuncTable[I] := Func38;
      39: fIdentFuncTable[I] := Func39;
      40: fIdentFuncTable[I] := Func40;
      41: fIdentFuncTable[I] := Func41;
      42: fIdentFuncTable[I] := Func42;
      43: fIdentFuncTable[I] := Func43;
      44: fIdentFuncTable[I] := Func44;
      45: fIdentFuncTable[I] := Func45;
      46: fIdentFuncTable[I] := Func46;
      47: fIdentFuncTable[I] := Func47;
      48: fIdentFuncTable[I] := Func48;
      49: fIdentFuncTable[I] := Func49;
      50: fIdentFuncTable[I] := Func50;
      51: fIdentFuncTable[I] := Func51;
      52: fIdentFuncTable[I] := Func52;
      53: fIdentFuncTable[I] := Func53;
      54: fIdentFuncTable[I] := Func54;
      55: fIdentFuncTable[I] := Func55;
      56: fIdentFuncTable[I] := Func56;
      57: fIdentFuncTable[I] := Func57;
      58: fIdentFuncTable[I] := Func58;
      59: fIdentFuncTable[I] := Func59;
      60: fIdentFuncTable[I] := Func60;
      61: fIdentFuncTable[I] := Func61;
      62: fIdentFuncTable[I] := Func62;
      63: fIdentFuncTable[I] := Func63;
      64: fIdentFuncTable[I] := Func64;
      65: fIdentFuncTable[I] := Func65;
      66: fIdentFuncTable[I] := Func66;
      67: fIdentFuncTable[I] := Func67;
      68: fIdentFuncTable[I] := Func68;
      69: fIdentFuncTable[I] := Func69;
      70: fIdentFuncTable[I] := Func70;
      71: fIdentFuncTable[I] := Func71;
      72: fIdentFuncTable[I] := Func72;
      73: fIdentFuncTable[I] := Func73;
      74: fIdentFuncTable[I] := Func74;
      75: fIdentFuncTable[I] := Func75;
      76: fIdentFuncTable[I] := Func76;
      77: fIdentFuncTable[I] := Func77;
      78: fIdentFuncTable[I] := Func78;
      79: fIdentFuncTable[I] := Func79;
      80: fIdentFuncTable[I] := Func80;
      81: fIdentFuncTable[I] := Func81;
      82: fIdentFuncTable[I] := Func82;
      83: fIdentFuncTable[I] := Func83;
      84: fIdentFuncTable[I] := Func84;
      85: fIdentFuncTable[I] := Func85;
      86: fIdentFuncTable[I] := Func86;
      87: fIdentFuncTable[I] := Func87;
      88: fIdentFuncTable[I] := Func88;
      90: fIdentFuncTable[I] := Func90;
      92: fIdentFuncTable[I] := Func92;
      93: fIdentFuncTable[I] := Func93;
      94: fIdentFuncTable[I] := Func94;
      96: fIdentFuncTable[I] := Func96;
      97: fIdentFuncTable[I] := Func97;
      98: fIdentFuncTable[I] := Func98;
      100: fIdentFuncTable[I] := Func100;
      101: fIdentFuncTable[I] := Func101;
      104: fIdentFuncTable[I] := Func104;
      105: fIdentFuncTable[I] := Func105;
      110: fIdentFuncTable[I] := Func110;
      111: fIdentFuncTable[I] := Func111;
      114: fIdentFuncTable[I] := Func114;
      116: fIdentFuncTable[I] := Func116;
      118: fIdentFuncTable[I] := Func118;
      120: fIdentFuncTable[I] := Func120;
      121: fIdentFuncTable[I] := Func121;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;


function TnhAsmSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TnhAsmSyn.KeyComp(const aKey: String): Boolean;                        //mh 1999-09-24 (added const)
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

{----------Generated by mwSynGen ----------}

function TnhAsmSyn.Func6: TtkTokenKind;
begin
  if KeyComp('aad') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func8: TtkTokenKind;
begin
  if KeyComp('adc') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func9: TtkTokenKind;
begin
  if KeyComp('add') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func11: TtkTokenKind;
begin
  if KeyComp('ja') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func12: TtkTokenKind;
begin
  if KeyComp('jb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func13: TtkTokenKind;
begin
  if KeyComp('jc') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func15: TtkTokenKind;
begin
  if KeyComp('je') then Result := tkKey else
    if KeyComp('aam') then Result := tkKey else
      if KeyComp('fadd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func16: TtkTokenKind;
begin
  if KeyComp('jae') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func17: TtkTokenKind;
begin
  if KeyComp('jg') then Result := tkKey else
    if KeyComp('jbe') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func18: TtkTokenKind;
begin
  if KeyComp('lea') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func19: TtkTokenKind;
begin
  if KeyComp('cmc') then Result := tkKey else
    if KeyComp('and') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func22: TtkTokenKind;
begin
  if KeyComp('fld') then Result := tkKey else
    if KeyComp('jl') then Result := tkKey else
      if KeyComp('jge') then Result := tkKey else
        if KeyComp('fld1') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func23: TtkTokenKind;
begin
  if KeyComp('sbb') then Result := tkKey else
    if KeyComp('in') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func24: TtkTokenKind;
begin
  if KeyComp('fbld') then Result := tkKey else
    if KeyComp('cdq') then Result := tkKey else
      if KeyComp('fiadd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func25: TtkTokenKind;
begin
  if KeyComp('jna') then Result := tkKey else
    if KeyComp('jo') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func26: TtkTokenKind;
begin
  if KeyComp('neg') then Result := tkKey else
    if KeyComp('jnb') then Result := tkKey else
      if KeyComp('jp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func27: TtkTokenKind;
begin
  if KeyComp('jnc') then Result := tkKey else
    if KeyComp('jle') then Result := tkKey else
      if KeyComp('paddb') then Result := tkKey else
        if KeyComp('lahf') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func28: TtkTokenKind;
begin
  if KeyComp('call') then Result := tkKey else
    if KeyComp('fabs') then Result := tkKey else
      if KeyComp('cbw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func29: TtkTokenKind;
begin
  if KeyComp('js') then Result := tkKey else
    if KeyComp('pfacc') then Result := tkKey else
      if KeyComp('paddd') then Result := tkKey else
        if KeyComp('jne') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func30: TtkTokenKind;
begin
  if KeyComp('jnae') then Result := tkKey else
    if KeyComp('cwd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func31: TtkTokenKind;
begin
  if KeyComp('jng') then Result := tkKey else
    if KeyComp('pfadd') then Result := tkKey else
      if KeyComp('jnbe') then Result := tkKey else
        if KeyComp('fild') then Result := tkKey else
          if KeyComp('faddp') then Result := tkKey else
            if KeyComp('jpe') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func32: TtkTokenKind;
begin
  if KeyComp('sal') then Result := tkKey else
    if KeyComp('cmp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func33: TtkTokenKind;
begin
  if KeyComp('rcl') then Result := tkKey else
    if KeyComp('or') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func34: TtkTokenKind;
begin
  if KeyComp('sahf') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func35: TtkTokenKind;
begin
  if KeyComp('cwde') then Result := tkKey else
    if KeyComp('div') then Result := tkKey else
      if KeyComp('pi2fd') then Result := tkKey else
        if KeyComp('lds') then Result := tkKey else
          if KeyComp('pf2id') then Result := tkKey else
            if KeyComp('pand') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func36: TtkTokenKind;
begin
  if KeyComp('fchs') then Result := tkKey else
    if KeyComp('jz') then Result := tkKey else
      if KeyComp('jnl') then Result := tkKey else
        if KeyComp('jnge') then Result := tkKey else
          if KeyComp('les') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func37: TtkTokenKind;
begin
  if KeyComp('fcom') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func38: TtkTokenKind;
begin
  if KeyComp('sar') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func39: TtkTokenKind;
begin
  if KeyComp('rep') then Result := tkKey else
    if KeyComp('rcr') then Result := tkKey else
      if KeyComp('shl') then Result := tkKey else
        if KeyComp('jno') then Result := tkKey else
          if KeyComp('rcr') then Result := tkKey else
            if KeyComp('jmp') then Result := tkKey else
              if KeyComp('fldl2e') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func40: TtkTokenKind;
begin
  if KeyComp('ffree') then Result := tkKey else
    if KeyComp('jnp') then Result := tkKey else
      if KeyComp('hlt') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func41: TtkTokenKind;
begin
  if KeyComp('lock') then Result := tkKey else
    if KeyComp('fxch') then Result := tkKey else
      if KeyComp('fldlg2') then Result := tkKey else
        if KeyComp('fdiv') then Result := tkKey else
          if KeyComp('jnle') then Result := tkKey else
            if KeyComp('jpo') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func42: TtkTokenKind;
begin
  if KeyComp('ins') then Result := tkKey else
    if KeyComp('sub') then Result := tkKey else
      if KeyComp('xchg') then Result := tkKey else
        if KeyComp('scas') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func43: TtkTokenKind;
begin
  if KeyComp('f2xm1') then Result := tkKey else
    if KeyComp('jns') then Result := tkKey else
      if KeyComp('fcos') then Result := tkKey else
        if KeyComp('ret') then Result := tkKey else
          if KeyComp('int') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func44: TtkTokenKind;
begin
  if KeyComp('scasb') then Result := tkKey else
    if KeyComp('repe') then Result := tkKey else
      if KeyComp('insb') then Result := tkKey else
        if KeyComp('idiv') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func45: TtkTokenKind;
begin
  if KeyComp('leave') then Result := tkKey else
    if KeyComp('nop') then Result := tkKey else
      if KeyComp('rol') then Result := tkKey else
        if KeyComp('shr') then Result := tkKey else
          if KeyComp('fst') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func46: TtkTokenKind;
begin
  if KeyComp('mul') then Result := tkKey else
    if KeyComp('paddsb') then Result := tkKey else
      if KeyComp('insd') then Result := tkKey else
        if KeyComp('fscale') then Result := tkKey else
          if KeyComp('fcomi') then Result := tkKey else
            if KeyComp('scasd') then Result := tkKey else
              if KeyComp('ficom') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func47: TtkTokenKind;
begin
  if KeyComp('pop') then Result := tkKey else
    if KeyComp('arpl') then Result := tkKey else
      if KeyComp('fldpi') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func48: TtkTokenKind;
begin
  if KeyComp('paddw') then Result := tkKey else
    if KeyComp('fldcw') then Result := tkKey else
      if KeyComp('fldz') then Result := tkKey else
        if KeyComp('fldln2') then Result := tkKey else
          if KeyComp('fsin') then Result := tkKey else
            if KeyComp('fsub') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func49: TtkTokenKind;
begin
  if KeyComp('por') then Result := tkKey else
    if KeyComp('not') then Result := tkKey else
      if KeyComp('pandn') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func50: TtkTokenKind;
begin
  if KeyComp('jnz') then Result := tkKey else
    if KeyComp('lods') then Result := tkKey else
      if KeyComp('fidiv') then Result := tkKey else
        if KeyComp('fclex') then Result := tkKey else
          if KeyComp('emms') then Result := tkKey else
            if KeyComp('lods') then Result := tkKey else
              if KeyComp('mov') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func51: TtkTokenKind;
begin
  if KeyComp('fnop') then Result := tkKey else
    if KeyComp('ror') then Result := tkKey else
      if KeyComp('cmps') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func52: TtkTokenKind;
begin
  if KeyComp('fmul') then Result := tkKey else
    if KeyComp('iret') then Result := tkKey else
      if KeyComp('lodsb') then Result := tkKey else
        if KeyComp('popad') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func53: TtkTokenKind;
begin
  if KeyComp('wait') then Result := tkKey else
    if KeyComp('fcomp') then Result := tkKey else
      if KeyComp('cmpsb') then Result := tkKey else
        if KeyComp('fsave') then Result := tkKey else
          if KeyComp('popf') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func54: TtkTokenKind;
begin
  if KeyComp('movd') then Result := tkKey else
    if KeyComp('lodsd') then Result := tkKey else
      if KeyComp('fldl2t') then Result := tkKey else
        if KeyComp('fist') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func55: TtkTokenKind;
begin
  if KeyComp('cmpsd') then Result := tkKey else
    if KeyComp('imul') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func56: TtkTokenKind;
begin
  if KeyComp('bound') then Result := tkKey else
    if KeyComp('out') then Result := tkKey else
      if KeyComp('femms') then Result := tkKey else
        if KeyComp('iretd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func57: TtkTokenKind;
begin
  if KeyComp('xor') then Result := tkKey else
    if KeyComp('xlat') then Result := tkKey else
      if KeyComp('popfd') then Result := tkKey else
        if KeyComp('fisub') then Result := tkKey else
          if KeyComp('fptan') then Result := tkKey else
            if KeyComp('fdivp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func58: TtkTokenKind;
begin
  if KeyComp('pfmin') then Result := tkKey else
    if KeyComp('loop') then Result := tkKey else
      if KeyComp('into') then Result := tkKey else
        if KeyComp('fpatan') then Result := tkKey else
          if KeyComp('fprem1') then Result := tkKey else
            if KeyComp('psrad') then Result := tkKey else
              if KeyComp('repne') then Result := tkKey else
                if KeyComp('fucom') then Result := tkKey else
                  if KeyComp('finit') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func59: TtkTokenKind;
begin
  if KeyComp('fdivr') then Result := tkKey else
    if KeyComp('pfrcp') then Result := tkKey else
      if KeyComp('xlatb') then Result := tkKey else
        if KeyComp('fwait') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func60: TtkTokenKind;
begin
  if KeyComp('psubb') then Result := tkKey else
    if KeyComp('pfmax') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func61: TtkTokenKind;
begin
  if KeyComp('fimul') then Result := tkKey else
    if KeyComp('fcmovb') then Result := tkKey else
      if KeyComp('fstp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func62: TtkTokenKind;
begin
  if KeyComp('psubd') then Result := tkKey else
    if KeyComp('ficomp') then Result := tkKey else
      if KeyComp('enter') then Result := tkKey else
        if KeyComp('fcomip') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func63: TtkTokenKind;
begin
  if KeyComp('fbstp') then Result := tkKey else
    if KeyComp('fldenv') then Result := tkKey else
      if KeyComp('jcxz') then Result := tkKey else
        if KeyComp('loope') then Result := tkKey else
          if KeyComp('pslld') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func64: TtkTokenKind;
begin
  if KeyComp('push') then Result := tkKey else
    if KeyComp('fcmove') then Result := tkKey else
      if KeyComp('test') then Result := tkKey else
        if KeyComp('fnclex') then Result := tkKey else
          if KeyComp('fsubp') then Result := tkKey else
            if KeyComp('fsubp') then Result := tkKey else
              if KeyComp('pfsub') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func65: TtkTokenKind;
begin
  if KeyComp('scasw') then Result := tkKey else
    if KeyComp('insw') then Result := tkKey else
      if KeyComp('ftst') then Result := tkKey else
        if KeyComp('pmaddwd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func66: TtkTokenKind;
begin
  if KeyComp('fsubr') then Result := tkKey else
    if KeyComp('fcmovbe') then Result := tkKey else
      if KeyComp('pfcmpge') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func67: TtkTokenKind;
begin
  if KeyComp('fucomi') then Result := tkKey else
    if KeyComp('fnsave') then Result := tkKey else
      if KeyComp('paddsw') then Result := tkKey else
        if KeyComp('paddusb') then Result := tkKey else
          if KeyComp('movq') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func68: TtkTokenKind;
begin
  if KeyComp('fidivr') then Result := tkKey else
    if KeyComp('jecxz') then Result := tkKey else
      if KeyComp('fmulp') then Result := tkKey else
        if KeyComp('pfmul') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func69: TtkTokenKind;
begin
  if KeyComp('psrld') then Result := tkKey else
    if KeyComp('movs') then Result := tkKey else
      if KeyComp('fcompp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func70: TtkTokenKind;
begin
  if KeyComp('pushf') then Result := tkKey else
    if KeyComp('fistp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func71: TtkTokenKind;
begin
  if KeyComp('fstcw') then Result := tkKey else
    if KeyComp('movsb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func72: TtkTokenKind;
begin
  if KeyComp('fninit') then Result := tkKey else
    if KeyComp('pcmpeqb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func73: TtkTokenKind;
begin
  if KeyComp('fdecstp') then Result := tkKey else
    if KeyComp('movsd') then Result := tkKey else
      if KeyComp('lodsw') then Result := tkKey else
        if KeyComp('pxor') then Result := tkKey else
          if KeyComp('stos') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func74: TtkTokenKind;
begin
  if KeyComp('fucomp') then Result := tkKey else
    if KeyComp('pushfd') then Result := tkKey else
      if KeyComp('pcmpeqd') then Result := tkKey else
        if KeyComp('cmpsw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func75: TtkTokenKind;
begin
  if KeyComp('fdivrp') then Result := tkKey else
    if KeyComp('stosb') then Result := tkKey else
      if KeyComp('outs') then Result := tkKey else
        if KeyComp('fcmovnb') then Result := tkKey else
          if KeyComp('fisubr') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func76: TtkTokenKind;
begin
  if KeyComp('psllq') then Result := tkKey else
    if KeyComp('pfcmpeq') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func77: TtkTokenKind;
begin
  if KeyComp('loopne') then Result := tkKey else
    if KeyComp('stosd') then Result := tkKey else
      if KeyComp('pcmpgtb') then Result := tkKey else
        if KeyComp('outsb') then Result := tkKey else
          if KeyComp('psraw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func78: TtkTokenKind;
begin
  if KeyComp('fcmovne') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func79: TtkTokenKind;
begin
  if KeyComp('pcmpgtd') then Result := tkKey else
    if KeyComp('outsd') then Result := tkKey else
      if KeyComp('psubsb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func80: TtkTokenKind;
begin
  if KeyComp('fcmovu') then Result := tkKey else
    if KeyComp('fsqrt') then Result := tkKey else
      if KeyComp('fcmovnbe') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func81: TtkTokenKind;
begin
  if KeyComp('prefetch') then Result := tkKey else
    if KeyComp('psubw') then Result := tkKey else
      if KeyComp('pfcmpgt') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func82: TtkTokenKind;
begin
  if KeyComp('psllw') then Result := tkKey else
    if KeyComp('pfsubr') then Result := tkKey else
      if KeyComp('psrlq') then Result := tkKey else
        if KeyComp('fsubrp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func83: TtkTokenKind;
begin
  if KeyComp('fucomip') then Result := tkKey else
    if KeyComp('fyl2xp1') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func84: TtkTokenKind;
begin
  if KeyComp('loopz') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func85: TtkTokenKind;
begin
  if KeyComp('fnstcw') then Result := tkKey else
    if KeyComp('fsincos') then Result := tkKey else
      if KeyComp('frndint') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func86: TtkTokenKind;
begin
  if KeyComp('fstenv') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func87: TtkTokenKind;
begin
  if KeyComp('fincstp') then Result := tkKey else
    if KeyComp('fstsw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func88: TtkTokenKind;
begin
  if KeyComp('pavgusb') then Result := tkKey else
    if KeyComp('psrlw') then Result := tkKey else
      if KeyComp('paddusw') then Result := tkKey else
        if KeyComp('pfrcpit2') then Result := tkKey else
          if KeyComp('pfrcpit1') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func90: TtkTokenKind;
begin
  if KeyComp('fucompp') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func92: TtkTokenKind;
begin
  if KeyComp('fxtract') then Result := tkKey else
    if KeyComp('movsw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func93: TtkTokenKind;
begin
  if KeyComp('pmulhw') then Result := tkKey else
    if KeyComp('pcmpeqw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func94: TtkTokenKind;
begin
  if KeyComp('packsswb') then Result := tkKey else
    if KeyComp('fcmovnu') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func96: TtkTokenKind;
begin
  if KeyComp('packssdw') then Result := tkKey else
    if KeyComp('stosw') then Result := tkKey else
      if KeyComp('frstor') then Result := tkKey else
        if KeyComp('packuswb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func97: TtkTokenKind;
begin
  if KeyComp('pmullw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func98: TtkTokenKind;
begin
  if KeyComp('pcmpgtw') then Result := tkKey else
    if KeyComp('loopnz') then Result := tkKey else
      if KeyComp('outsw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func100: TtkTokenKind;
begin
  if KeyComp('psubsw') then Result := tkKey else
    if KeyComp('fnstenv') then Result := tkKey else
      if KeyComp('psubusb') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func101: TtkTokenKind;
begin
  if KeyComp('fnstsw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func104: TtkTokenKind;
begin
  if KeyComp('prefetchw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func105: TtkTokenKind;
begin
  if KeyComp('pfrsqit1') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func110: TtkTokenKind;
begin
  if KeyComp('punpckhdq') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func111: TtkTokenKind;
begin
  if KeyComp('pmulhrw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func114: TtkTokenKind;
begin
  if KeyComp('punpckhbw') then Result := tkKey else
    if KeyComp('punpckldq') then Result := tkKey else
      if KeyComp('pfrsqrt') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func116: TtkTokenKind;
begin
  if KeyComp('punpckhwd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func118: TtkTokenKind;
begin
  if KeyComp('punpcklbw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func120: TtkTokenKind;
begin
  if KeyComp('punpcklwd') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.Func121: TtkTokenKind;
begin
  if KeyComp('psubusw') then Result := tkKey else Result := tkIdentifier;
end;

function TnhAsmSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

{-------------------------------------------------}

function TnhAsmSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 122 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TnhAsmSyn.MakeMethodTables;
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

constructor TnhAsmSyn.Create(AOwner: TComponent);
begin
{begin}                                                                         //mh 1999-09-24
(*
  fCommentAttri       := TmwHighLightAttributes.Create('comment');
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri    := TmwHighLightAttributes.Create('identifier');
  fKeyAttri           := TmwHighLightAttributes.Create('reserved word');
  fKeyAttri.Style     := [fsBold];
  fNumberAttri        := TmwHighLightAttributes.Create('number');
  fSpaceAttri         := TmwHighLightAttributes.Create('space');
  fStringAttri        := TmwHighLightAttributes.Create('string');
  fSymbolAttri        := TmwHighLightAttributes.Create('symbols');
  SetHighlightChange;

  inherited Create(AOwner);

  fRange              := rsUnknown;
  fDefaultFilter      := 'x86 Assembly Files (*.asm)|*.ASM';

  InitIdent;
  MakeMethodTables;
*)
  inherited Create(AOwner);

  fCommentAttri       := TmwHighLightAttributes.Create(MWS_AttrComment);
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);
  fIdentifierAttri    := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  AddAttribute(fIdentifierAttri);
  fKeyAttri           := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Style     := [fsBold];
  AddAttribute(fKeyAttri);
  fNumberAttri        := TmwHighLightAttributes.Create(MWS_AttrNumber);
  AddAttribute(fNumberAttri);
  fSpaceAttri         := TmwHighLightAttributes.Create(MWS_AttrSpace);
  AddAttribute(fSpaceAttri);
  fStringAttri        := TmwHighLightAttributes.Create(MWS_AttrString);
  AddAttribute(fStringAttri);
  fSymbolAttri        := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  AddAttribute(fSymbolAttri);
  SetAttributesOnChange(DefHighlightChange);

  InitIdent;
  MakeMethodTables;
  fRange              := rsUnknown;
  fDefaultFilter      := MWS_FilterX86Asm;
end; { Create }

(*
destructor TnhAsmSyn.Destroy;
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

procedure TnhAsmSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)
{end}                                                                           //mh 1999-09-24

procedure TnhAsmSyn.SetLine(NewValue: String; LineNumber:Integer);              //gp 1999-05-06
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-09-24
  fLineNumber := LineNumber;                                                    //mh 1999-09-24
  Next;
end; { SetLine }

procedure TnhAsmSyn.AmpersandProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TnhAsmSyn.ApostropheProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TnhAsmSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TnhAsmSyn.BraceOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.CRProc;
begin
  fTokenID := tkSpace;
{begin}                                                                         //mh 1999-09-24
//  Case FLine[Run + 1] of
//    #10: inc(Run, 2);
//  else inc(Run);
//  end;
  Inc(Run);
  if fLine[Run] = #10 then Inc(Run);
{end}                                                                           //mh 1999-09-24
end;

procedure TnhAsmSyn.ColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.DateProc;
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

procedure TnhAsmSyn.EqualProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.ExponentiationProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.GreaterProc;
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

procedure TnhAsmSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TnhAsmSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TnhAsmSyn.LowerProc;
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

procedure TnhAsmSyn.MinusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-09-24
end;

procedure TnhAsmSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', '.', 'e', 'E'] do inc(Run);
end;

procedure TnhAsmSyn.PlusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.PointProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := tkSymbol;
end;

procedure TnhAsmSyn.SemiColonProc;
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

procedure TnhAsmSyn.SlashProc;
{added support for c++ sytle comments}
{which is supported by some assemblers}
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
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TnhAsmSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TnhAsmSyn.StarProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TnhAsmSyn.StringProc;
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

procedure TnhAsmSyn.UnknownProc;
begin
  fTokenID := tkIdentifier;
  inc(Run);
end;

procedure TnhAsmSyn.Next;
// var                                                                          //mh 1999-09-24
//  TokenID: TtkTokenKind;                                                        //gp 1999-05-06
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
(*                                                                              //mh 1999-09-24
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
    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-05-06
  end;
*)
end;

function TnhAsmSyn.GetEol: Boolean;
begin
//  Result := False;                                                            //mh 1999-09-24
//  if fTokenId = tkNull then Result := True;
  Result := fTokenId = tkNull;
end;

function TnhAsmSyn.GetRange: Pointer;
begin
 Result := Pointer(fRange);
end;

function TnhAsmSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TnhAsmSyn.GetTokenAttribute: TmwHighLightAttributes;                   //mh 1999-09-24
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

function TnhAsmSyn.GetTokenKind: integer;                                       //mh 1999-09-24
begin
  Result := Ord(fTokenId);
end;

function TnhAsmSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TnhAsmSyn.GetTokenPos: Integer;
begin
 Result := fTokenPos;
end;

procedure TnhAsmSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TnhAsmSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //mh 1999-09-24
(*
function TnhAsmSyn.GetAttribCount: integer;
begin
  Result := 7;
end;

function TnhAsmSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
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
{end}                                                                           //mh 1999-09-24

function TnhAsmSyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings];
end;

function TnhAsmSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TnhAsmSyn.GetLanguageName: string;
begin
  Result := MWS_LangX86Asm;                                                     //mh 1999-09-24
end;

{begin}                                                                         //mh 1999-09-24
(*
procedure TnhAsmSyn.HighLightChange(Sender: TObject);
begin
  mwEditList.Invalidate;
end;

procedure TnhAsmSyn.SetHighLightChange;
begin
  fCommentAttri.OnChange    := HighLightChange;
  fIdentifierAttri.OnChange := HighLightChange;
  fKeyAttri.OnChange        := HighLightChange;
  fNumberAttri.OnChange     := HighLightChange;
  fSpaceAttri.OnChange      := HighLightChange;
  fStringAttri.OnChange     := HighLightChange;
  fSymbolAttri.OnChange     := HighLightChange;
end;

procedure TnhAsmSyn.AssignAttributes(Attributes: TmwHighLightAttributes);
begin
 with Attributes do
   begin
     if fCanvas.Brush.Color <> Background then fCanvas.Brush.Color := Background;
     if fCanvas.Font.Color  <> Foreground then fCanvas.Font.Color  := Foreground;
     if fCanvas.Font.Style  <> Style      then fCanvas.Font.Style  := Style;
   end;
end;
*)
{end}                                                                           //mh 1999-09-24

Initialization
  MakeIdentTable;
end.
