{+-----------------------------------------------------------------------------+
 | Class:       TmwSQLSyn
 | Created:     not known
 | Last change: 1999-09-24
 | Author:      Willo van der Merwe [willow@billcad.co.za]
 | Description: SQL syntax highliter
 | Version:     0.52
 | Copyright (c) 1999 Willo van der Merwe
 | All rights reserved.
 | Portions Copyright Martin Waldenburg.
 | Initially Created with mwSynGen by Martin Waldenburg.
 |
 | Thanks to: Primoz Gabrijelcic, Andy Jeffries
 |
 | Version history: see version.rtf
 |
 +----------------------------------------------------------------------------+}

unit wmSQLSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter, mwLocalStr;                                                    //mh 1999-08-22

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

Type
  TwmTokenKind = (
    wmComment,
    wmIdentifier,
    wmKey,
    wmNull,
    wmNumber,
    wmString,
    wmSymbol,
    wmUnknown);

  TRangeState = (rsANil, rsAnsiC, rsUnKnown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TwmTokenKind of Object;

type
  TwmSQLSyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    FRoundCount: Integer;
    FSquareCount: Integer;
    fStringLen: Integer;
    fLineNumber : Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    FTokenID: TwmTokenKind;
    fEol: Boolean;
    fIdentFuncTable: array[0..156] of TIdentFuncTableFunc;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func15:TwmTokenKind;
    function Func19:TwmTokenKind;
    function Func20:TwmTokenKind;
    function Func21:TwmTokenKind;
    function Func23:TwmTokenKind;
    function Func25:TwmTokenKind;
    function Func27:TwmTokenKind;
    function Func28:TwmTokenKind;
    function Func29:TwmTokenKind;
    function Func30:TwmTokenKind;
    function Func31:TwmTokenKind;
    function Func33:TwmTokenKind;
    function Func35:TwmTokenKind;
    function Func37:TwmTokenKind;
    function Func39:TwmTokenKind;
    function Func40:TwmTokenKind;
    function Func41:TwmTokenKind;
    function Func43:TwmTokenKind;
    function Func44:TwmTokenKind;
    function Func47:TwmTokenKind;
    function Func48:TwmTokenKind;
    function Func49:TwmTokenKind;
    function Func50:TwmTokenKind;
    function Func51:TwmTokenKind;
    function Func52:TwmTokenKind;
    function Func53:TwmTokenKind;
    function Func55:TwmTokenKind;
    function Func56:TwmTokenKind;
    function Func57:TwmTokenKind;
    function Func58:TwmTokenKind;
    function Func59:TwmTokenKind;
    function Func60:TwmTokenKind;
    function Func61:TwmTokenKind;
    function Func62:TwmTokenKind;
    function Func63:TwmTokenKind;
    function Func64:TwmTokenKind;
    function Func66:TwmTokenKind;
    function Func67:TwmTokenKind;
    function Func69:TwmTokenKind;
    function Func70:TwmTokenKind;
    function Func73:TwmTokenKind;
    function Func74:TwmTokenKind;
    function Func76:TwmTokenKind;
    function Func77:TwmTokenKind;
    function Func78:TwmTokenKind;
    function Func79:TwmTokenKind;
    function Func83:TwmTokenKind;
    function Func84:TwmTokenKind;
    function Func85:TwmTokenKind;
    function Func87:TwmTokenKind;
    function Func91:TwmTokenKind;
    function Func94:TwmTokenKind;
    function Func96:TwmTokenKind;
    function Func97:TwmTokenKind;
    function Func98:TwmTokenKind;
    function Func99:TwmTokenKind;
    function Func100:TwmTokenKind;
    function Func102:TwmTokenKind;
    function Func103:TwmTokenKind;
    function Func105:TwmTokenKind;
    function Func106:TwmTokenKind;
    function Func111:TwmTokenKind;
    function Func112:TwmTokenKind;
    function Func114:TwmTokenKind;
    function Func115:TwmTokenKind;
    function Func116:TwmTokenKind;
    function Func117:TwmTokenKind;
    function Func122:TwmTokenKind;
    function Func133:TwmTokenKind;
    function Func134:TwmTokenKind;
    function Func137:TwmTokenKind;
    function Func156:TwmTokenKind;
    procedure AndSymbolProc;
    procedure BackslashProc;
    procedure CRProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure CommentProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure OrSymbolProc;
    procedure PlusProc;
    procedure QuestionProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringInterpProc;
    procedure StringLiteralProc;
    procedure XOrSymbolProc;
    procedure UnknownProc;
    procedure AnsiCProc;
    function AltFunc: TwmTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TwmTokenKind;
    procedure MakeMethodTables;
  protected
    function GetLanguageName: string; override;
//    procedure HighLightChange(Sender:TObject);                                //mh 1999-08-22
//    procedure SetHighLightChange;                                             //mh 1999-08-22
//    function GetAttribCount: integer; override;                               //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;    //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-08-22

    function UseUserSettings(settingIndex: integer): boolean; override;
    procedure EnumUserSettings(settings: TStrings); override;

    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TwmTokenKind;
    procedure SetLine(NewValue : string; LineNumber : Integer);override;
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TwmSQLSyn]);
end;

procedure MakeIdentTable;
var
  I,J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpperCase(I)[1];
    Case I of
      'a'..'z', 'A'..'Z', '_': mHashTable[I] := Ord(J) - 64;
    else mHashTable[Char(I)] := 0;
    end;
  end;
end;

procedure TwmSQLSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 156 do
    Case I of
      15: fIdentFuncTable[I] := Func15;
      19: fIdentFuncTable[I] := Func19;
      20: fIdentFuncTable[I] := Func20;
      21: fIdentFuncTable[I] := Func21;
      23: fIdentFuncTable[I] := Func23;
      25: fIdentFuncTable[I] := Func25;
      27: fIdentFuncTable[I] := Func27;
      28: fIdentFuncTable[I] := Func28;
      29: fIdentFuncTable[I] := Func29;
      30: fIdentFuncTable[I] := Func30;
      31: fIdentFuncTable[I] := Func31;
      33: fIdentFuncTable[I] := Func33;
      35: fIdentFuncTable[I] := Func35;
      37: fIdentFuncTable[I] := Func37;
      39: fIdentFuncTable[I] := Func39;
      40: fIdentFuncTable[I] := Func40;
      41: fIdentFuncTable[I] := Func41;
      43: fIdentFuncTable[I] := Func43;
      44: fIdentFuncTable[I] := Func44;
      47: fIdentFuncTable[I] := Func47;
      48: fIdentFuncTable[I] := Func48;
      49: fIdentFuncTable[I] := Func49;
      50: fIdentFuncTable[I] := Func50;
      51: fIdentFuncTable[I] := Func51;
      52: fIdentFuncTable[I] := Func52;
      53: fIdentFuncTable[I] := Func53;
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
      66: fIdentFuncTable[I] := Func66;
      67: fIdentFuncTable[I] := Func67;
      69: fIdentFuncTable[I] := Func69;
      70: fIdentFuncTable[I] := Func70;
      73: fIdentFuncTable[I] := Func73;
      74: fIdentFuncTable[I] := Func74;
      76: fIdentFuncTable[I] := Func76;
      77: fIdentFuncTable[I] := Func77;
      78: fIdentFuncTable[I] := Func78;
      79: fIdentFuncTable[I] := Func79;
      83: fIdentFuncTable[I] := Func83;
      84: fIdentFuncTable[I] := Func84;
      85: fIdentFuncTable[I] := Func85;
      87: fIdentFuncTable[I] := Func87;
      91: fIdentFuncTable[I] := Func91;
      94: fIdentFuncTable[I] := Func94;
      96: fIdentFuncTable[I] := Func96;
      97: fIdentFuncTable[I] := Func97;
      98: fIdentFuncTable[I] := Func98;
      99: fIdentFuncTable[I] := Func99;
      100: fIdentFuncTable[I] := Func100;
      102: fIdentFuncTable[I] := Func102;
      103: fIdentFuncTable[I] := Func103;
      105: fIdentFuncTable[I] := Func105;
      106: fIdentFuncTable[I] := Func106;
      111: fIdentFuncTable[I] := Func111;
      112: fIdentFuncTable[I] := Func112;
      114: fIdentFuncTable[I] := Func114;
      115: fIdentFuncTable[I] := Func115;
      116: fIdentFuncTable[I] := Func116;
      117: fIdentFuncTable[I] := Func117;
      122: fIdentFuncTable[I] := Func122;
      133: fIdentFuncTable[I] := Func133;
      134: fIdentFuncTable[I] := Func134;
      137: fIdentFuncTable[I] := Func137;
      156: fIdentFuncTable[I] := Func156;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TwmSQLSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TwmSQLSyn.KeyComp(const aKey: String): Boolean;                        //mh 1999-08-22
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

function TwmSQLSyn.Func15: TwmTokenKind;
begin
  if KeyComp('IF') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func19: TwmTokenKind;
begin
  if KeyComp('AND') then Result := wmKey else
    if KeyComp('DO') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func20: TwmTokenKind;
begin
  if KeyComp('AS') then Result := wmKey else
    if KeyComp('CACHE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func21: TwmTokenKind;
begin
  if KeyComp('AT') then Result := wmKey else
    if KeyComp('OF') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func23: TwmTokenKind;
begin
  if KeyComp('END') then Result := wmKey else
    if KeyComp('IN') then Result := wmKey else
      if KeyComp('ASC') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func25: TwmTokenKind;
begin
  if KeyComp('ALL') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func27: TwmTokenKind;
begin
  if KeyComp('BY') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func28: TwmTokenKind;
begin
  if KeyComp('READ') then Result := wmKey else
    if KeyComp('IS') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func29: TwmTokenKind;
begin
  if KeyComp('NO') then Result := wmKey else
    if KeyComp('ON') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func30: TwmTokenKind;
begin
  if KeyComp('CHECK') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func31: TwmTokenKind;
begin
  if KeyComp('DESC') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func33: TwmTokenKind;
begin
  if KeyComp('OR') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func35: TwmTokenKind;
begin
  if KeyComp('TO') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func37: TwmTokenKind;
begin
  if KeyComp('LIKE') then Result := wmKey else
    if KeyComp('BEGIN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func39: TwmTokenKind;
begin
  if KeyComp('FOR') then Result := wmKey else
    if KeyComp('DEBUG') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func40: TwmTokenKind;
begin
  if KeyComp('ANY') then Result := wmKey else
    if KeyComp('TABLE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func41: TwmTokenKind;
begin
  if KeyComp('ELSE') then Result := wmKey else
    if KeyComp('KEY') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func43: TwmTokenKind;
begin
  if KeyComp('LEFT') then Result := wmKey else
    if KeyComp('CAST') then Result := wmKey else
      if KeyComp('PLAN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func44: TwmTokenKind;
begin
  if KeyComp('SET') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func47: TwmTokenKind;
begin
  if KeyComp('THEN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func48: TwmTokenKind;
begin
  if KeyComp('MERGE') then Result := wmKey else
    if KeyComp('DECLARE') then Result := wmKey else
      if KeyComp('JOIN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func49: TwmTokenKind;
begin
  if KeyComp('SCHEMA') then Result := wmKey else
    if KeyComp('ESCAPE') then Result := wmKey else
      if KeyComp('NOT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func50: TwmTokenKind;
begin
  if KeyComp('AFTER') then Result := wmKey else
    if KeyComp('WHEN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func51: TwmTokenKind;
begin
  if KeyComp('DELETE') then Result := wmKey else
    if KeyComp('FULL') then Result := wmKey else
      if KeyComp('BEFORE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func52: TwmTokenKind;
begin
  if KeyComp('FROM') then Result := wmKey else
    if KeyComp('SOME') then Result := wmKey else
      if KeyComp('CREATE') then Result := wmKey else
        if KeyComp('NAMES') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func53: TwmTokenKind;
begin
  if KeyComp('DROP') then Result := wmKey else
    if KeyComp('WAIT') then Result := wmKey else
      if KeyComp('DATABASE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func55: TwmTokenKind;
begin
  if KeyComp('SHARED') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func56: TwmTokenKind;
begin
  if KeyComp('DOMAIN') then Result := wmKey else
    if KeyComp('INDEX') then Result := wmKey else
      if KeyComp('LEVEL') then Result := wmKey else
        if KeyComp('ALTER') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func57: TwmTokenKind;
begin
  if KeyComp('WHILE') then Result := wmKey else
    if KeyComp('AUTO') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func58: TwmTokenKind;
begin
  if KeyComp('INTO') then Result := wmKey else
    if KeyComp('EXIT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func59: TwmTokenKind;
begin
  if KeyComp('VIEW') then Result := wmKey else
    if KeyComp('NULL') then Result := wmKey else
      if KeyComp('WHERE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func60: TwmTokenKind;
begin
  if KeyComp('ACTIVE') then Result := wmKey else
    if KeyComp('ORDER') then Result := wmKey else
      if KeyComp('BASE_NAME') then Result := wmKey else
        if KeyComp('GRANT') then Result := wmKey else
          if KeyComp('INNER') then Result := wmKey else
            if KeyComp('WITH') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func61: TwmTokenKind;
begin
  if KeyComp('HAVING') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func62: TwmTokenKind;
begin
  if KeyComp('RIGHT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func63: TwmTokenKind;
begin
  if KeyComp('USER') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func64: TwmTokenKind;
begin
  if KeyComp('SELECT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func66: TwmTokenKind;
begin
  if KeyComp('ONLY') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func67: TwmTokenKind;
begin
  if KeyComp('RETAIN') then Result := wmKey else
    if KeyComp('UPDATE') then Result := wmKey else
      if KeyComp('WORK') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func69: TwmTokenKind;
begin
  if KeyComp('DEFAULT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func70: TwmTokenKind;
begin
  if KeyComp('FILTER') then Result := wmKey else
    if KeyComp('SHADOW') then Result := wmKey else
      if KeyComp('USING') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func73: TwmTokenKind;
begin
  if KeyComp('UNION') then Result := wmKey else
    if KeyComp('COUNT') then Result := wmKey else
      if KeyComp('COMMIT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func74: TwmTokenKind;
begin
  if KeyComp('ROLLBACK') then Result := wmKey else
    if KeyComp('BETWEEN') then Result := wmKey else
      if KeyComp('FOREIGN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func76: TwmTokenKind;
begin
  if KeyComp('ASCENDING') then Result := wmKey else
    if KeyComp('REVOKE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func77: TwmTokenKind;
begin
  if KeyComp('GROUP') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func78: TwmTokenKind;
begin
  if KeyComp('COLUMN') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func79: TwmTokenKind;
begin
  if KeyComp('OUTER') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func83: TwmTokenKind;
begin
  if KeyComp('EXECUTE') then Result := wmKey else
    if KeyComp('INACTIVE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func84: TwmTokenKind;
begin
  if KeyComp('DESCENDING') then Result := wmKey else
    if KeyComp('TRIGGER') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func85: TwmTokenKind;
begin
  if KeyComp('INSERT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func87: TwmTokenKind;
begin
  if KeyComp('UNIQUE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func91: TwmTokenKind;
begin
  if KeyComp('EXTRACT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func94: TwmTokenKind;
begin
  if KeyComp('CURSOR') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func96: TwmTokenKind;
begin
  if KeyComp('EXISTS') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func97: TwmTokenKind;
begin
  if KeyComp('PARAMETER') then Result := wmKey else
    if KeyComp('COMPUTED') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func98: TwmTokenKind;
begin
  if KeyComp('DISTINCT') then Result := wmKey else
    if KeyComp('SUSPEND') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func99: TwmTokenKind;
begin
  if KeyComp('EXTERNAL') then Result := wmKey else
    if KeyComp('CURRENT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func100: TwmTokenKind;
begin
  if KeyComp('PRIMARY') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func102: TwmTokenKind;
begin
  if KeyComp('FUNCTION') then Result := wmKey else
    if KeyComp('COMMITTED') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func103: TwmTokenKind;
begin
  if KeyComp('GENERATOR') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func105: TwmTokenKind;
begin
  if KeyComp('PROCEDURE') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func106: TwmTokenKind;
begin
  if KeyComp('CONTAINING') then Result := wmKey else
    if KeyComp('PROTECTED') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func111: TwmTokenKind;
begin
  if KeyComp('EXCEPTION') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func112: TwmTokenKind;
begin
  if KeyComp('SNAPSHOT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func114: TwmTokenKind;
begin
  if KeyComp('ISOLATION') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func115: TwmTokenKind;
begin
  if KeyComp('PASSWORD') then Result := wmKey else
    if KeyComp('RETURNS') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func116: TwmTokenKind;
begin
  if KeyComp('CONDITIONAL') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func117: TwmTokenKind;
begin
  if KeyComp('POSITION') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func122: TwmTokenKind;
begin
  if KeyComp('PRIVILEGES') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func133: TwmTokenKind;
begin
  if KeyComp('CONSTRAINT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func134: TwmTokenKind;
begin
  if KeyComp('TRANSACTION') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func137: TwmTokenKind;
begin
  if KeyComp('UNCOMMITTED') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.Func156: TwmTokenKind;
begin
  if KeyComp('ENTRY_POINT') then Result := wmKey else Result := wmIdentifier;
end;

function TwmSQLSyn.AltFunc: TwmTokenKind;
begin
  Result := wmIdentifier;
end;

function TwmSQLSyn.IdentKind(MayBe: PChar): TwmTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 157 then Result := fIdentFuncTable[HashKey] else Result := wmIdentifier;
end;

procedure TwmSQLSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '&': fProcTable[I] := AndSymbolProc;
      '\': fProcTable[I] := BackslashProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := ColonProc;
      ',': fProcTable[I] := CommaProc;
      '#': fProcTable[I] := CommentProc;
      '=': fProcTable[I] := EqualProc;
      '>': fProcTable[I] := GreaterProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9', '.': fProcTable[I] := NumberProc;
      '|': fProcTable[I] := OrSymbolProc;
      '+': fProcTable[I] := PlusProc;
      '?': fProcTable[I] := QuestionProc;
      ')': fProcTable[I] := RoundCloseProc;
      '(': fProcTable[I] := RoundOpenProc;
      ';': fProcTable[I] := SemiColonProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      ']': fProcTable[I] := SquareCloseProc;
      '[': fProcTable[I] := SquareOpenProc;
      '*': fProcTable[I] := StarProc;
      #34: fProcTable[I] := StringInterpProc;
      #39: fProcTable[I] := StringLiteralProc;
      '^': fProcTable[I] := XOrSymbolProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

function TwmSQLSyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings];
end;

constructor TwmSQLSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  InitIdent;
  MakeMethodTables;
  fDefaultFilter := MWS_FilterSQL;                                              //ajb 1999-09-14
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style := [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22
  UseUserSettings(0);
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TwmSQLSyn.Destroy;
begin
  inherited Destroy;
end; { Destroy }
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
procedure TwmSQLSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TwmSQLSyn.SetLine(NewValue : string; LineNumber : Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fEol := False;
  fLineNumber := LineNumber;
  Next;
end;{ SetLine }

procedure TwmSQLSyn.AndSymbolProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.BackslashProc;
begin
  fTokenID := wmSymbol;                {reference}
  inc(Run);
end;

procedure TwmSQLSyn.CRProc;
begin
  fTokenID := wmSymbol;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TwmSQLSyn.ColonProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.CommaProc;
begin
  inc(Run);
  fTokenID := wmSymbol;                {comma}
end;

procedure TwmSQLSyn.CommentProc;
begin
  fTokenID := wmComment;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #0;
end;

procedure TwmSQLSyn.EqualProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.GreaterProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.IdentProc;
begin
  {regular identifier}
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TwmSQLSyn.LFProc;
begin
  fTokenID := wmSymbol;
  inc(Run);
end;

procedure TwmSQLSyn.LowerProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.MinusProc;
begin
  case FLine[Run + 1] of
    '-' :
      begin
        inc(Run, 2);
        fTokenID := wmComment;
        while FLine[Run] <> #0 do
          begin
            case FLine[Run] of
              #10, #13 : break;
            end;
            inc(Run);
          end;
      end;
    else
      begin
        inc(Run);
        fTokenID := wmSymbol;
      end;
  end;
end;

procedure TwmSQLSyn.NullProc;
begin
  fTokenID := wmNull;
  fEol := True;
end;

procedure TwmSQLSyn.NumberProc;
begin
  if FLine[Run] = '.' then
  begin
    case FLine[Run + 1] of
      '.':
        begin
          inc(Run, 2);
          if FLine[Run] = '.' then     {sed range}
            inc(Run);

          fTokenID := wmSymbol;        {range}
        end;
      '=':
        begin
          inc(Run, 2);
          fTokenID := wmSymbol;        {concatenation assign}
        end;
      'a'..'z', 'A'..'Z', '_':
        begin
          fTokenID := wmSymbol;        {concatenation}
          inc(Run);
        end;
    end;
  end;
  inc(Run);
  fTokenID := wmNumber;
  while FLine[Run] in
      ['0'..'9', '-', '_', '.', 'A'..'F', 'a'..'f', 'x', 'X'] do
  begin
    case FLine[Run] of
      '.':
        if FLine[Run + 1] = '.' then break;
      '-':                             {check for e notation}
        if not ((FLine[Run + 1] = 'e') or (FLine[Run + 1] = 'E')) then break;
    end;
    inc(Run);
  end;
end;

procedure TwmSQLSyn.OrSymbolProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.PlusProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.QuestionProc;
begin
  fTokenID := wmSymbol;                {conditional op}
  inc(Run);
end;

procedure TwmSQLSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
  dec(FRoundCount);
end;

procedure TwmSQLSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := wmSymbol;
  inc(FRoundCount);
end;

procedure TwmSQLSyn.SemiColonProc;
begin
  inc(Run);
  fTokenID := wmSymbol;                {semicolon}
end;

procedure TwmSQLSyn.SlashProc;
begin
  case FLine[Run + 1] of
    '/':                               {c++ style comments}
      begin
        inc(Run, 2);
        fTokenID := wmComment;
        while FLine[Run] <> #0 do
        begin
          case FLine[Run] of
            #10, #13: break;
          end;
          inc(Run);
        end;
      end;
    '*':                               {c style comments}
      begin
        fTokenID := wmComment;
        fRange := rsAnsiC;
        inc(Run);
        while fLine[Run] <> #0 do
          case fLine[Run] of
            '*':
              if fLine[Run + 1] = '/' then
              begin
                inc(Run, 2);
                fRange := rsUnKnown;
                break;
              end else inc(Run);
            #10: break;
            #13: break;
          else inc(Run);
          end;
      end;
  else                                 {division}
    begin
      inc(Run);
      fTokenID := wmSymbol;
    end;
  end;
end;

procedure TwmSQLSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TwmSQLSyn.SquareCloseProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
  dec(FSquareCount);
end;

procedure TwmSQLSyn.SquareOpenProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
  inc(FSquareCount);
end;

procedure TwmSQLSyn.StarProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.StringInterpProc;
begin
  fTokenID := wmString;
  if (FLine[Run + 1] = #34) and (FLine[Run + 2] = #34) then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
      #92:
        { backslash quote not the ending one }
        if FLine[Run + 1] = #34 then inc(Run);
    end;
    inc(Run);
  until FLine[Run] = #34;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TwmSQLSyn.StringLiteralProc;
begin
  fTokenID := wmString;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TwmSQLSyn.XOrSymbolProc;
begin
  inc(Run);
  fTokenID := wmSymbol;
end;

procedure TwmSQLSyn.UnknownProc;
begin
  inc(Run);
end;

procedure TwmSQLSyn.AnsiCProc;
begin
  fTokenID := wmComment;
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
          fRange := rsUnKnown;
          break;
        end
        else inc(Run);
      #10: break;
      #13: break;
    else inc(Run);
    end;
end;

procedure TwmSQLSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TwmTokenKind;
begin
  fTokenPos := Run;
  Case fRange of
    rsAnsiC: AnsiCProc;
    else
      fRange := rsUnknown;
      fProcTable[fLine[Run]];
  end;
(*
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;
    case TokenID of
      wmComment:
        with fCanvas do
        begin
          Brush.Color := fCommentAttri.Background;
          Font.Color := fCommentAttri.Foreground;
          Font.Style := fCommentAttri.Style;
        end;
      wmIdentifier:
        with fCanvas do
        begin
          Brush.Color := fIdentifierAttri.Background;
          Font.Color := fIdentifierAttri.Foreground;
          Font.Style := fIdentifierAttri.Style;
        end;
      wmKey:
        with fCanvas do
        begin
          Brush.Color := fKeyAttri.Background;
          Font.Color := fKeyAttri.Foreground;
          Font.Style := fKeyAttri.Style;
        end;
      wmNumber:
        with fCanvas do
        begin
          Brush.Color := fNumberAttri.Background;
          Font.Color := fNumberAttri.Foreground;
          Font.Style := fNumberAttri.Style;
        end;
      wmSymbol:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
      wmString:
        with fCanvas do
        begin
          Brush.Color := fStringAttri.Background;
          Font.Color := fStringAttri.Foreground;
          Font.Style := fStringAttri.Style;
        end;
      wmUnknown:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
    end;
//    DoOnToken(Ord(TokenId), GetToken, fLineNumber);                           //mh 1999-08-22
  end;
*)
end;

function TwmSQLSyn.GetEol: Boolean;
begin
  Result := fTokenId = wmNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = wmNull then Result := True;
end;

function TwmSQLSyn.GetRange: Pointer;
begin
 Result := Pointer(fRange);
end;

function TwmSQLSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TwmSQLSyn.GetTokenID: TwmTokenKind;
begin
  Result := fTokenId;
end;

function TwmSQLSyn.GetTokenAttribute: TmwHighLightAttributes;                   //mh 1999-09-12
begin
  case fTokenID of
    wmComment: Result := fCommentAttri;
    wmIdentifier: Result := fIdentifierAttri;
    wmKey: Result := fKeyAttri;
    wmNumber: Result := fNumberAttri;
    wmSymbol: Result := fSymbolAttri;
    wmString: Result := fStringAttri;
    wmUnknown: Result := fSymbolAttri;
    else Result := nil;
  end;
end;

function TwmSQLSyn.GetTokenKind: integer;                                       //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TwmSQLSyn.GetTokenPos: Integer;
begin
 Result := fTokenPos;
end;

procedure TwmSQLSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TwmSQLSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TwmSQLSyn.GetLanguageName: string;
begin
  Result := MWS_LangSQL;                                                        //mh 1999-09-24
end;

{begin}                                                                         //mh 1999-08-22
(*
function TwmSQLSyn.GetAttribCount: integer;
begin
  Result := 6;
end;

function TwmSQLSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fNumberAttri;
    3: Result := fKeyAttri;
    4: Result := fStringAttri;
    5: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TwmSQLSyn.UseUserSettings(settingIndex: integer): boolean;
// Possible parameter values:
//   index into TStrings returned by EnumUserSettings
// Possible return values:
//   true : settings were read and used
//   false: problem reading settings or invalid version specified - old settings
//          were preserved

  function ReadSQLSettings(settingIndex: integer): boolean;

    function ReadSQLSetting(settingTag: string; attri: TmwHighLightAttributes; key: string): boolean;
    var
      Reg : TBetterRegistry;
    begin { ReadSQLSetting }
      Result := false;
      Reg := TBetterRegistry.Create;
      try
        Reg.RootKey := HKEY_CURRENT_USER;
        try
          Reg.OpenKeyReadOnly( '\Software\mwEdit team\Highlighters\SQL\'+settingTag );
          attri.LoadFromRegistry(Reg);
          Result := true;
        except
        end;
      finally
        Reg.Free;
      end;
    end; { ReadSQLSetting }

  var
    tmpStringAttri    : TmwHighLightAttributes;
    tmpNumberAttri    : TmwHighLightAttributes;
    tmpKeyAttri       : TmwHighLightAttributes;
    tmpSymbolAttri    : TmwHighLightAttributes;
    tmpCommentAttri   : TmwHighLightAttributes;
    tmpIdentifierAttri: TmwHighLightAttributes;
    s                 : TStringList;

  begin { ReadSQLSettings }
    s := TStringList.Create;
    try
      EnumUserSettings(s);
      if settingIndex >= s.Count then
        Result := false
      else begin
        tmpStringAttri    := TmwHighLightAttributes.Create('');
        tmpNumberAttri    := TmwHighLightAttributes.Create('');
        tmpKeyAttri       := TmwHighLightAttributes.Create('');
        tmpSymbolAttri    := TmwHighLightAttributes.Create('');
        tmpCommentAttri   := TmwHighLightAttributes.Create('');
        tmpIdentifierAttri:= TmwHighLightAttributes.Create('');
        tmpStringAttri    .Assign(fStringAttri);
        tmpNumberAttri    .Assign(fNumberAttri);
        tmpKeyAttri       .Assign(fKeyAttri);
        tmpSymbolAttri    .Assign(fSymbolAttri);
        tmpCommentAttri   .Assign(fCommentAttri);
        tmpIdentifierAttri.Assign(fIdentifierAttri);
        Result := ReadSQLSetting(s[settingIndex],fCommentAttri,'Comment')       and
                  ReadSQLSetting(s[settingIndex],fIdentifierAttri,'Identifier') and
                  ReadSQLSetting(s[settingIndex],fKeyAttri,'Reserved word')     and
                  ReadSQLSetting(s[settingIndex],fNumberAttri,'Number')         and
                  ReadSQLSetting(s[settingIndex],fStringAttri,'String')         and
                  ReadSQLSetting(s[settingIndex],fSymbolAttri,'Symbol');
        if not Result then begin
          fStringAttri    .Assign(tmpStringAttri);
          fNumberAttri    .Assign(tmpNumberAttri);
          fKeyAttri       .Assign(tmpKeyAttri);
          fSymbolAttri    .Assign(tmpSymbolAttri);
          fCommentAttri   .Assign(tmpCommentAttri);
          fIdentifierAttri.Assign(tmpIdentifierAttri);
        end;
        tmpStringAttri    .Free;
        tmpNumberAttri    .Free;
        tmpKeyAttri       .Free;
        tmpSymbolAttri    .Free;
        tmpCommentAttri   .Free;
        tmpIdentifierAttri.Free;
      end;
    finally s.Free; end;
  end; { ReadSQLSettings }

begin
  Result := ReadSQLSettings(settingIndex);
end;

procedure TwmSQLSyn.EnumUserSettings(settings: TStrings);
begin
  { returns the user settings that exist in the registry }
  with TBetterRegistry.Create do begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKeyReadOnly('\Software\mwEdit team\Highlighters\SQL\') then begin
        try
          GetKeyNames(settings);
        finally
          CloseKey;
        end;
      end;
    finally
      Free;
    end;
  end;
end;

{begin}                                                                         //mh 1999-08-22
(*
procedure TwmSQLSyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TwmSQLSyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
*)
{end}                                                                           //mh 1999-08-22

Initialization
  MakeIdentTable;
end.
