{$I MWEDIT.INC} //mt 12/16/1998 added
{---------------------------------------------------------------------------
 C++ Language Syntax Parser

 DcjSynCpp was created as a plug in component for the Syntax Editor mwEdit
 created by Martin Waldenburg and friends.  For more information on the
 mwEdit project, see the following website:

 http://www.eccentrica.org/gabr/mw/mwedit.htm

 Copyright © 1998, Michael Trier.  All Rights Reserved.
 Portions Copyright Martin Waldenburg.
 Initially Created with mwSynGen by Martin Waldenburg.

 Thanks to: Martin Waldenburg, Primoz Gabrijelcic, James Jacobson,
            Andy Jeffries.

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
 C++ Language Syntax Parser v0.76
{---------------------------------------------------------------------------
 Revision History:
 0.74:    * Andy Jeffries, Primoz Gabrijelcic: Implemented OnToken event.
 0.73:    * Primoz Gabrijelcic: Moved most of DefaultFilter support to
            mwHighlighter.pas.
 0.72:    * Implemented Extended Token ID support.
          * Added QuestionProc for conditional operator.
          * Added InvalidAttri for unknown characters.  Modified UseUserSettings
            to get the Illegal Char setting for InvalidAttri.
          * Added rsANil back in.
 0.70:    * Michael Trier: Removed rsANil from range types - not used.
          * Fixed problem with strings and chars to correctly interpreting
            escape characters \' and \".
          * Fixed sorting of GetAttribute.
          * Implemented DefaultFilter property. Changed Get Name to
            GetLanguageName.  Added LanguageName, Attribute, AttrCount, and
            Capability to the public section.
          * Added default foreground color of clWindow to SpaceAttri and
            removed space conversion code in GetToken method.
          * Removed nested comment support code.
 0.67:    * Primoz Gabrijelcic: Adapted code to mwCustomHighlighter changes.
            Implemented GetCapability.
 0.66:    * Primoz Gabrijelcic: Added attribute names. Implemented GetName,
            GetAttribCount, GetAttribute.
 0.65:    * Added IdentChars implementation to let the editor know which
            characters are non "whitespace".
 0.63:    * Small correction to fix problem with hex numbers
 0.62:    * Primoz Gabrijelcic on behalf of James Jacobson: Some changes that
            will update the Editor when any changes are made to the Highlighter.
            That is when any color or font style is changed and when the
            Highlighter is added or removed the Editor will be invalidated.
 0.61:    * Added the MWEDIT.INC file, removed the ObjectExportAll On
            statement, and changed the tab to mw.
 0.60:    * Primoz Gabrijelcic: added code to load setting from registry
 0.52:    * Altered UseDelphiSettings abstract function to use the new
            UseUserSettings.
          * Added EnumUserSettings function override.
          * Changed tabs to spaces.  Not ideal at this point.
          * Changed BG to Background, changed VG to Foreground.
 0.50:    * Initial version.
{---------------------------------------------------------------------------}

//mt 12/16/1998 removed {$ObjExportAll On} since it's defined in the include

unit DcjCppSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter, mwLocalStr; {gp 12/16/1998}                                    //mh 1999-08-22

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

Type
  TtkTokenKind = (
    tkAsm,
    tkComment,
    tkDirective,
    tkIdentifier,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown);

  //mt 1/2/1999
  TxtkTokenKind = (
    xtkAdd, xtkAddAssign, xtkAnd, xtkAndAssign, xtkArrow, xtkAssign,
    xtkBitComplement, xtkBraceClose, xtkBraceOpen, xtkColon, xtkComma,
    xtkDecrement, xtkDivide, xtkDivideAssign, xtkEllipse, xtkGreaterThan,
    xtkGreaterThanEqual, xtkIncOr, xtkIncOrAssign, xtkIncrement, xtkLessThan,
    xtkLessThanEqual, xtkLogAnd, xtkLogComplement, xtkLogEqual, xtkLogOr,
    xtkMod, xtkModAssign, xtkMultiplyAssign, xtkNotEqual, xtkPoint, xtkQuestion,
    xtkRoundClose, xtkRoundOpen, xtkScopeResolution, xtkSemiColon, xtkShiftLeft,
    xtkShiftLeftAssign, xtkShiftRight, xtkShiftRightAssign, xtkSquareClose,
    xtkSquareOpen, xtkStar, xtkSubtract, xtkSubtractAssign, xtkXor,
    xtkXorAssign);

  TRangeState = (rsANil, rsAnsiC, rsAnsiCAsm, rsAnsiCAsmBlock, rsAsm, rsAsmBlock,
      rsUnKnown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

  TDcjCppSyn = class(TmwCustomHighLighter)
  private
    fAsmStart: Boolean;
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
//    fEol: Boolean;                                                            //mh 1999-08-22
    fLineNumber: Integer;                                                       //aj 1999-02-22
    fIdentFuncTable: array[0..206] of TIdentFuncTableFunc;
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fAsmAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fDirecAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fInvalidAttri: TmwHighLightAttributes;                                      //mt 1999-1-2
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
//  fDefaultFilter: string;                                                     //mt 1999-1-2, //gp 1999-1-10 - moved to mwHighlighter

    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func17:TtkTokenKind;
    function Func21:TtkTokenKind;
    function Func32:TtkTokenKind;
    function Func34:TtkTokenKind;
    function Func36:TtkTokenKind;
    function Func40:TtkTokenKind;
    function Func42:TtkTokenKind;
    function Func45:TtkTokenKind;
    function Func46:TtkTokenKind;
    function Func48:TtkTokenKind;
    function Func52:TtkTokenKind;
    function Func54:TtkTokenKind;
    function Func57:TtkTokenKind;
    function Func58:TtkTokenKind;
    function Func59:TtkTokenKind;
    function Func60:TtkTokenKind;
    function Func61:TtkTokenKind;
    function Func62:TtkTokenKind;
    function Func64:TtkTokenKind;
    function Func65:TtkTokenKind;
    function Func66:TtkTokenKind;
    function Func67:TtkTokenKind;
    function Func68:TtkTokenKind;
    function Func69:TtkTokenKind;
    function Func71:TtkTokenKind;
    function Func74:TtkTokenKind;
    function Func75:TtkTokenKind;
    function Func76:TtkTokenKind;
    function Func78:TtkTokenKind;
    function Func79:TtkTokenKind;
    function Func81:TtkTokenKind;
    function Func82:TtkTokenKind;
    function Func85:TtkTokenKind;
    function Func86:TtkTokenKind;
    function Func88:TtkTokenKind;
    function Func89:TtkTokenKind;
    function Func92:TtkTokenKind;
    function Func97:TtkTokenKind;
    function Func98:TtkTokenKind;
    function Func100:TtkTokenKind;
    function Func101:TtkTokenKind;
    function Func102:TtkTokenKind;
    function Func104:TtkTokenKind;
    function Func105:TtkTokenKind;
    function Func106:TtkTokenKind;
    function Func107:TtkTokenKind;
    function Func109:TtkTokenKind;
    function Func110:TtkTokenKind;
    function Func115:TtkTokenKind;
    function Func116:TtkTokenKind;
    function Func123:TtkTokenKind;
    function Func125:TtkTokenKind;
    function Func141:TtkTokenKind;
    function Func206:TtkTokenKind;

    procedure AnsiCProc;

    procedure AndSymbolProc;
    procedure AsciiCharProc;
    procedure AtSymbolProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure CRProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure DirectiveProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure ModSymbolProc;
    procedure NotSymbolProc;
    procedure NullProc;
    procedure NumberProc;
    procedure OrSymbolProc;
    procedure PlusProc;
    procedure PointProc;
    procedure QuestionProc;                                                     //mt 1999-1-2
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure TildeProc;
    procedure XOrSymbolProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
//    procedure HighLightChange(Sender:TObject);                                  //jdj 1998-12-18 //mh 1999-08-22
//    procedure SetHighLightChange;                                               //jdj 1998-12-18 //mh 1999-08-22
  protected
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;                                 //gp 1998-12-24
                                                                                //mt 1999-1-2 change to GetLanguageName
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;                   //gp 1998-12-28
//  function GetDefaultFilter: string; override;                                //mt 1999-1-2, //gp 1999-1-10 - removed
//  procedure SetDefaultFilter(Value: string); override;                        //mt 1999-1-2, //gp 1999-1-10 - removed

    function GetExtTokenID: TxtkTokenKind;                                      //mt 1999-1-2
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-08-22
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //aj 1999-02-22
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    function UseUserSettings(settingIndex: integer): boolean; override;
    procedure EnumUserSettings(settings: TStrings); override;
    property IdentChars;
    property LanguageName;                                                      //mt 1999-1-2
    property AttrCount;                                                         //mt 1999-1-2
    property Attribute;                                                         //mt 1999-1-2
    property Capability;                                                        //mt 1999-1-2

    property ExtTokenID: TxtkTokenKind read GetExtTokenID;                      //mt 1999-1-2
  published
    property AsmAttri: TmwHighLightAttributes read fAsmAttri write fAsmAttri;
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property DirecAttri: TmwHighLightAttributes read fDirecAttri write fDirecAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property InvalidAttri: TmwHighLightAttributes read fInvalidAttri write fInvalidAttri;  //mt 1/2/1999
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
//  property DefaultFilter;                                                     //mt 1999-1-2, //gp 1999-1-10 - removed
  end;

var
  DcjCppLex: TDcjCppSyn;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TDcjCppSyn]);
end;

procedure MakeIdentTable;
var
  I: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    Case I in['_', 'a'..'z', 'A'..'Z'] of
      True:
        begin
          if (I > #64) and (I < #91) then mHashTable[I] := Ord(I) - 64 else
            if (I > #96) then mHashTable[I] := Ord(I) - 95;
        end;
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TDcjCppSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 206 do
    Case I of
      17: fIdentFuncTable[I] := Func17;
      21: fIdentFuncTable[I] := Func21;
      32: fIdentFuncTable[I] := Func32;
      34: fIdentFuncTable[I] := Func34;
      36: fIdentFuncTable[I] := Func36;
      40: fIdentFuncTable[I] := Func40;
      42: fIdentFuncTable[I] := Func42;
      45: fIdentFuncTable[I] := Func45;
      46: fIdentFuncTable[I] := Func46;
      48: fIdentFuncTable[I] := Func48;
      52: fIdentFuncTable[I] := Func52;
      54: fIdentFuncTable[I] := Func54;
      57: fIdentFuncTable[I] := Func57;
      58: fIdentFuncTable[I] := Func58;
      59: fIdentFuncTable[I] := Func59;
      60: fIdentFuncTable[I] := Func60;
      61: fIdentFuncTable[I] := Func61;
      62: fIdentFuncTable[I] := Func62;
      64: fIdentFuncTable[I] := Func64;
      65: fIdentFuncTable[I] := Func65;
      66: fIdentFuncTable[I] := Func66;
      67: fIdentFuncTable[I] := Func67;
      68: fIdentFuncTable[I] := Func68;
      69: fIdentFuncTable[I] := Func69;
      71: fIdentFuncTable[I] := Func71;
      74: fIdentFuncTable[I] := Func74;
      75: fIdentFuncTable[I] := Func75;
      76: fIdentFuncTable[I] := Func76;
      78: fIdentFuncTable[I] := Func78;
      79: fIdentFuncTable[I] := Func79;
      81: fIdentFuncTable[I] := Func81;
      82: fIdentFuncTable[I] := Func82;
      85: fIdentFuncTable[I] := Func85;
      86: fIdentFuncTable[I] := Func86;
      88: fIdentFuncTable[I] := Func88;
      89: fIdentFuncTable[I] := Func89;
      92: fIdentFuncTable[I] := Func92;
      97: fIdentFuncTable[I] := Func97;
      98: fIdentFuncTable[I] := Func98;
      100: fIdentFuncTable[I] := Func100;
      101: fIdentFuncTable[I] := Func101;
      102: fIdentFuncTable[I] := Func102;
      104: fIdentFuncTable[I] := Func104;
      105: fIdentFuncTable[I] := Func105;
      106: fIdentFuncTable[I] := Func106;
      107: fIdentFuncTable[I] := Func107;
      109: fIdentFuncTable[I] := Func109;
      110: fIdentFuncTable[I] := Func110;
      115: fIdentFuncTable[I] := Func115;
      116: fIdentFuncTable[I] := Func116;
      123: fIdentFuncTable[I] := Func123;
      125: fIdentFuncTable[I] := Func125;
      141: fIdentFuncTable[I] := Func141;
      206: fIdentFuncTable[I] := Func206;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TDcjCppSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TDcjCppSyn.KeyComp(const aKey: String): Boolean;                       //mh 1999-08-22
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

function TDcjCppSyn.Func17: TtkTokenKind;
begin
  if KeyComp('if') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func21: TtkTokenKind;
begin
  if KeyComp('do') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func32: TtkTokenKind;
begin
  if KeyComp('cdecl') then Result := tkKey else
    if KeyComp('case') then Result := tkKey else
      if KeyComp('_cdecl') then Result := tkKey else
        if KeyComp('__cdecl') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func34: TtkTokenKind;
begin
  if KeyComp('char') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func36: TtkTokenKind;
begin
  if KeyComp('asm') then
  begin
    Result := tkKey;
    fRange := rsAsm;
    fAsmStart := True;
  end else
    if KeyComp('_asm') then
    begin
      Result := tkKey;
      fRange := rsAsm;
      fAsmStart := True;
    end else
      if KeyComp('__asm') then
      begin
        Result := tkKey;
        fRange := rsAsm;
        fAsmStart := True;
      end else
        Result := tkIdentifier;
end;

function TDcjCppSyn.Func40: TtkTokenKind;
begin
  if KeyComp('catch') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func42: TtkTokenKind;
begin
  if KeyComp('for') then Result := tkKey else
    if KeyComp('break') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func45: TtkTokenKind;
begin
  if KeyComp('else') then Result := tkKey else
    if KeyComp('new') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func46: TtkTokenKind;
begin
  if KeyComp('__int8') then Result := tkKey else
    if KeyComp('__int16') then Result := tkKey else
      if KeyComp('int') then Result := tkKey else
        if KeyComp('__int32') then Result := tkKey else
          if KeyComp('__int64') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func48: TtkTokenKind;
begin
  if KeyComp('false') then Result := tkKey else
    if KeyComp('bool') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func52: TtkTokenKind;
begin
  if KeyComp('long') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func54: TtkTokenKind;
begin
  if KeyComp('void') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func57: TtkTokenKind;
begin
  if KeyComp('enum') then Result := tkKey else
    if KeyComp('delete') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func58: TtkTokenKind;
begin
  if KeyComp('_pascal') then Result := tkKey else
    if KeyComp('__pascal') then Result := tkKey else
      if KeyComp('pascal') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func59: TtkTokenKind;
begin
  if KeyComp('class') then Result := tkKey else
    if KeyComp('float') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func60: TtkTokenKind;
begin
  if KeyComp('this') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func61: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else
    if KeyComp('auto') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func62: TtkTokenKind;
begin
  if KeyComp('__thread') then Result := tkKey else
    if KeyComp('while') then Result := tkKey else
      if KeyComp('friend') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func64: TtkTokenKind;
begin
  if KeyComp('signed') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func65: TtkTokenKind;
begin
  if KeyComp('double') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func66: TtkTokenKind;
begin
  if KeyComp('__try') then Result := tkKey else
    if KeyComp('try') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func67: TtkTokenKind;
begin
  if KeyComp('__dispid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func68: TtkTokenKind;
begin
  if KeyComp('true') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func69: TtkTokenKind;
begin
  if KeyComp('public') then Result := tkKey else
    if KeyComp('inline') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func71: TtkTokenKind;
begin
  if KeyComp('__rtti') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func74: TtkTokenKind;
begin
  if KeyComp('__classid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func75: TtkTokenKind;
begin
  if KeyComp('__declspec') then Result := tkKey else
    if KeyComp('using') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func76: TtkTokenKind;
begin
  if KeyComp('const') then Result := tkKey else
    if KeyComp('default') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func78: TtkTokenKind;
begin
  if KeyComp('_stdcall') then Result := tkKey else
    if KeyComp('union') then Result := tkKey else
      if KeyComp('__stdcall') then Result := tkKey else
        if KeyComp('static') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func79: TtkTokenKind;
begin
  if KeyComp('__except') then Result := tkKey else
    if KeyComp('wchar_t') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func81: TtkTokenKind;
begin
  if KeyComp('mutable') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func82: TtkTokenKind;
begin
  if KeyComp('_fastcall') then Result := tkKey else
    if KeyComp('__fastcall') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func85: TtkTokenKind;
begin
  if KeyComp('short') then Result := tkKey else
    if KeyComp('typeid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func86: TtkTokenKind;
begin
  if KeyComp('sizeof') then Result := tkKey else
    if KeyComp('__finally') then Result := tkKey else
      if KeyComp('namespace') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func88: TtkTokenKind;
begin
  if KeyComp('switch') then Result := tkKey else
    if KeyComp('typedef') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func89: TtkTokenKind;
begin
  if KeyComp('throw') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func92: TtkTokenKind;
begin
  if KeyComp('extern') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func97: TtkTokenKind;
begin
  if KeyComp('__import') then Result := tkKey else
    if KeyComp('_import') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func98: TtkTokenKind;
begin
  if KeyComp('private') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func100: TtkTokenKind;
begin
  if KeyComp('template') then Result := tkKey else
    if KeyComp('__closure') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func101: TtkTokenKind;
begin
  if KeyComp('unsigned') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func102: TtkTokenKind;
begin
  if KeyComp('return') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func104: TtkTokenKind;
begin
  if KeyComp('volatile') then Result := tkKey else
    if KeyComp('_export') then Result := tkKey else
      if KeyComp('__export') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func105: TtkTokenKind;
begin
  if KeyComp('__published') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func106: TtkTokenKind;
begin
  if KeyComp('explicit') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func107: TtkTokenKind;
begin
  if KeyComp('typename') then Result := tkKey else
    if KeyComp('struct') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func109: TtkTokenKind;
begin
  if KeyComp('register') then Result := tkKey else
    if KeyComp('continue') then Result := tkKey else
      if KeyComp('__automated') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func110: TtkTokenKind;
begin
  if KeyComp('virtual') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func115: TtkTokenKind;
begin
  if KeyComp('protected') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func116: TtkTokenKind;
begin
  if KeyComp('operator') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func123: TtkTokenKind;
begin
  if KeyComp('dynamic_cast') then Result := tkKey else
    if KeyComp('const_cast') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func125: TtkTokenKind;
begin
  if KeyComp('static_cast') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func141: TtkTokenKind;
begin
  if KeyComp('__property') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.Func206: TtkTokenKind;
begin
  if KeyComp('reinterpret_cast') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjCppSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TDcjCppSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 207 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TDcjCppSyn.MakeMethodTables;
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
      '#': fProcTable[I] := DirectiveProc;
      '=': fProcTable[I] := EqualProc;
      '>': fProcTable[I] := GreaterProc;
      '?': fProcTable[I] := QuestionProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      '%': fProcTable[I] := ModSymbolProc;
      '!': fProcTable[I] := NotSymbolProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '|': fProcTable[I] := OrSymbolProc;
      '+': fProcTable[I] := PlusProc;
      '.': fProcTable[I] := PointProc;
      ')': fProcTable[I] := RoundCloseProc;
      '(': fProcTable[I] := RoundOpenProc;
      ';': fProcTable[I] := SemiColonProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      ']': fProcTable[I] := SquareCloseProc;
      '[': fProcTable[I] := SquareOpenProc;
      '*': fProcTable[I] := StarProc;
      #34: fProcTable[I] := StringProc;
      '~': fProcTable[I] := TildeProc;
      '^': fProcTable[I] := XOrSymbolProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TDcjCppSyn.Create(AOwner: TComponent);
begin
  fAsmAttri := TmwHighLightAttributes.Create(MWS_AttrAssembler);                //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24
  fCommentAttri.Style:= [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fInvalidAttri := TmwHighLightAttributes.Create(MWS_AttrIllegalChar);          //mt 1999-1-2
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style:= [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fSpaceAttri.Foreground := clWindow;                                           //mt 1999-1-2
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  fDirecAttri := TmwHighLightAttributes.Create(MWS_AttrPreprocessor);           //gp 1998-12-24
  inherited Create(AOwner);
{begin}                                                                         //mh 1999-08-22
  AddAttribute(fAsmAttri);
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fInvalidAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
  AddAttribute(fDirecAttri);
{end}                                                                           //mh 1999-08-22
//  SetHighlightChange;                                                           //jdj 1998-12-18 //mh 1999-08-22
  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
  fAsmStart := False;
  fDefaultFilter := MWS_FilterCPP;                                              //ajb 1999-09-14
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TDcjCppSyn.Destroy;
begin
  fAsmAttri.Free;
  fCommentAttri.Free;
  fIdentifierAttri.Free;
  fInvalidAttri.Free;                                                           //mt 1999-1-2
  fKeyAttri.Free;
  fNumberAttri.Free;
  fSpaceAttri.Free;
  fStringAttri.Free;
  fSymbolAttri.Free;
  fDirecAttri.Free;
  inherited Destroy;
end; { Destroy }
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
procedure TDcjCppSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TDcjCppSyn.SetLine(NewValue: String; LineNumber:Integer);             //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TDcjCppSyn.AnsiCProc;
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
      '*':
        if fLine[Run + 1] = '/' then
        begin
          inc(Run, 2);
            if fRange = rsAnsiCAsm then
              fRange := rsAsm
            else
              begin
              if fRange = rsAnsiCAsmBlock then
                fRange := rsAsmBlock
              else
                fRange := rsUnKnown;
              end;
            break;
        end
        else inc(Run);
      #10: break;
      #13: break;
    else inc(Run);
    end;
end;

procedure TDcjCppSyn.AndSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {and assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkAndAssign;
      end;
    '&':                               {logical and}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkLogAnd;
      end;
  else                                 {and}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkAnd;
    end;
  end;
end;

procedure TDcjCppSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
      #92:                             {backslash}                              //mt 1999-1-2
        {if we have an escaped single quote it doesn't count}
        if FLine[Run + 1] = #39 then inc(Run);
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TDcjCppSyn.AtSymbolProc;
begin
  fTokenID := tkUnknown;
  inc(Run);
end;

procedure TDcjCppSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
  FExtTokenID := xtkBraceClose;
  if fRange = rsAsmBlock then fRange := rsUnknown;
end;

procedure TDcjCppSyn.BraceOpenProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
  FExtTokenID := xtkBraceOpen;
  if fRange = rsAsm then
  begin
    fRange := rsAsmBlock;
    fAsmStart := True;
  end;
end;

procedure TDcjCppSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TDcjCppSyn.ColonProc;
begin
  Case FLine[Run + 1] of
    ':':                               {scope resolution operator}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkScopeResolution;
      end;
  else                                 {colon}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkColon;
    end;
  end;
end;

procedure TDcjCppSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkComma;
end;

procedure TDcjCppSyn.DirectiveProc;
begin
  fTokenID := tkDirective;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #0;
end;

procedure TDcjCppSyn.EqualProc;
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

procedure TDcjCppSyn.GreaterProc;
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
        if FLine[Run + 2] = '=' then   {shift right assign}
        begin
          inc(Run, 3);
          FExtTokenID := xtkShiftRightAssign;
        end
        else                           {shift right}
        begin
          inc(Run, 2);
          FExtTokenID := xtkShiftRight;
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

procedure TDcjCppSyn.QuestionProc;                                              //mt 1999-1-2
begin
  fTokenID := tkSymbol;                {conditional}
  FExtTokenID := xtkQuestion;
  inc(Run);
end;

procedure TDcjCppSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TDcjCppSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TDcjCppSyn.LowerProc;
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

procedure TDcjCppSyn.MinusProc;
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
    '>':                               {arrow}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkArrow;
      end;
  else                                 {subtract}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkSubtract;
    end;
  end;
end;

procedure TDcjCppSyn.ModSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {mod assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkModAssign;
      end;
  else                                 {mod}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkMod;
    end;
  end;
end;

procedure TDcjCppSyn.NotSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {not equal}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkNotEqual;
      end;
  else                                 {not}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkLogComplement;
    end;
  end;
end;

procedure TDcjCppSyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-08-22
end;

procedure TDcjCppSyn.NumberProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in
    //mt 12/20/1998 small correction here to fix problem with hex numbers
    ['0'..'9', 'A'..'F', 'a'..'f', '.', 'u', 'U', 'l', 'L', 'x', 'X'] do
  begin
    case FLine[Run] of
      '.':
        if FLine[Run + 1] = '.' then break;
    end;
    inc(Run);
  end;
end;

procedure TDcjCppSyn.OrSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {or assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkIncOrAssign;
      end;
    '|':                               {logical or}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkLogOr;
      end;
  else                                 {or}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkIncOr;
    end;
  end;
end;

procedure TDcjCppSyn.PlusProc;
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

procedure TDcjCppSyn.PointProc;
begin
  if (FLine[Run + 1] = '.') and (FLine[Run + 2] = '.') then
    begin                              {ellipse}
      inc(Run, 3);
      fTokenID := tkSymbol;
      FExtTokenID := xtkEllipse;
    end
  else                                 {point}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkPoint;
    end;
end;

procedure TDcjCppSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkRoundClose;
  dec(FRoundCount);
end;

procedure TDcjCppSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := tkSymbol;
  FExtTokenID := xtkRoundOpen;
  inc(FRoundCount);
end;

procedure TDcjCppSyn.SemiColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkSemiColon;
  if fRange = rsAsm then fRange := rsUnknown;
end;

procedure TDcjCppSyn.SlashProc;
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
    '*':                               {c style comments}
      begin
        fTokenID := tkComment;
        if fRange = rsAsm then
          fRange := rsAnsiCAsm
        else
          begin
          if fRange = rsAsmBlock then
            fRange := rsAnsiCAsmBlock
          else
            fRange := rsAnsiC;
          end;
        inc(Run, 2);
        while fLine[Run] <> #0 do
          case fLine[Run] of
            '*':
              if fLine[Run + 1] = '/' then
              begin
                inc(Run, 2);
                if fRange = rsAnsiCAsm then
                  fRange := rsAsm
                else
                  begin
                  if fRange = rsAnsiCAsmBlock then
                    fRange := rsAsmBlock
                  else
                    fRange := rsUnKnown;
                  end;
                break;
              end else inc(Run);
            #10: break;
            #13: break;
          else inc(Run);
          end;
      end;
    '=':                               {divide assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkDivideAssign;
      end;
  else                                 {divide}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkDivide;
    end;
  end;
end;

procedure TDcjCppSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TDcjCppSyn.SquareCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkSquareClose;
  dec(FSquareCount);
end;

procedure TDcjCppSyn.SquareOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  FExtTokenID := xtkSquareOpen;
  inc(FSquareCount);
end;

procedure TDcjCppSyn.StarProc;
begin
  case FLine[Run + 1] of
    '=':                               {multiply assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
        FExtTokenID := xtkMultiplyAssign;
      end;
  else                                 {star}
    begin
      inc(Run);
      fTokenID := tkSymbol;
      FExtTokenID := xtkStar;
    end;
  end;
end;

procedure TDcjCppSyn.StringProc;
begin
  fTokenID := tkString;
  if (FLine[Run + 1] = #34) and (FLine[Run + 2] = #34) then inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
      #92:                             {backslash}
        case FLine[Run + 1] of                                                  //mt 1999-1-2
          #10: inc(Run);               {line continuation character}
          #34: inc(Run);               {escaped quote doesn't count}
        end;
    end;
    inc(Run);
  until FLine[Run] = #34;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TDcjCppSyn.TildeProc;
begin
  inc(Run);                            {bitwise complement}
  fTokenId := tkSymbol;
  FExtTokenID := xtkBitComplement;
end;

procedure TDcjCppSyn.XOrSymbolProc;
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

procedure TDcjCppSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TDcjCppSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //aj 1999-02-22
begin
  fAsmStart := False;
  fTokenPos := Run;
  Case fRange of
    rsAnsiC: AnsiCProc;
    rsAnsiCAsm: AnsiCProc;
    rsAnsiCAsmBlock: AnsiCProc;
  else
    begin
      fRange := rsUnknown;                                                      //mt 1999-1-3
      fProcTable[fLine[Run]];
    end;
  end;
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //aj 1999-02-22
    case TokenID of                                                             //aj 1999-02-22
      tkAsm:
        with fCanvas do
        begin
          Brush.Color:= fAsmAttri.Background;
          Font.Color:=  fAsmAttri.Foreground;
          Font.Style:=  fAsmAttri.Style;
        end;
      tkComment:
        with fCanvas do
        begin
          Brush.Color:= fCommentAttri.Background;
          Font.Color:=  fCommentAttri.Foreground;
          Font.Style:=  fCommentAttri.Style;
        end;
      tkDirective:
        with fCanvas do
        begin
          Brush.Color:= fDirecAttri.Background;
          Font.Color:=  fDirecAttri.Foreground;
          Font.Style:=  fDirecAttri.Style;
        end;
      tkIdentifier:
        with fCanvas do
        begin
          Brush.Color:= fIdentifierAttri.Background;
          Font.Color:=  fIdentifierAttri.Foreground;
          Font.Style:=  fIdentifierAttri.Style;
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
      tkUnknown:                                                                //mt changed to support
        with fCanvas do                                                         // new invalid attri.
        begin
          Brush.Color:= fInvalidAttri.Background;                               //mt 1999-1-2
          Font.Color:=  fInvalidAttri.Foreground;                               //mt 1999-1-2
          Font.Style:=  fInvalidAttri.Style;                                    //mt 1999-1-2
        end;
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-27 //mh 1999-08-22
  end;
*)                                                                              //mh 1999-09-12
end;

function TDcjCppSyn.GetEol: Boolean;
begin
//  Result := False;                                                            //mh 1999-09-12
//  if fTokenId = tkNull then Result := True;
  Result := fTokenID = tkNull;
end;

function TDcjCppSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TDcjCppSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);                                  //mt 1999-1-2
end;

function TDcjCppSyn.GetTokenID: TtkTokenKind;
begin
  if ((fRange = rsAsm) or (fRange = rsAsmBlock)) and (not fAsmStart) then
    Case fTokenId of
      tkComment: Result := tkComment;
      tkNull: Result := tkNull;
      tkSpace: Result := tkSpace;
    else Result := tkAsm;
    end else Result := fTokenId;
end;

function TDcjCppSyn.GetExtTokenID: TxtkTokenKind;                               //mt 1999-1-2
begin
  Result := FExtTokenID;
end;

function TDcjCppSyn.GetTokenAttribute: TmwHighLightAttributes;                  //mh 1999-09-12
begin
  case fTokenID of
    tkAsm: Result := fAsmAttri;
    tkComment: Result := fCommentAttri;
    tkDirective: Result := fDirecAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fInvalidAttri;
    else Result := nil;
  end;
end;

function TDcjCppSyn.GetTokenKind: integer;                                      //mh 1999-08-22
begin
  Result := Ord(GetTokenID);
end;

function TDcjCppSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TDcjCppSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TDcjCppSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TDcjCppSyn.EnumUserSettings(settings: TStrings);
begin
  { returns the user settings that exist in the registry }
  with TBetterRegistry.Create do
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      if OpenKeyReadOnly('\SOFTWARE\Borland\C++Builder') then    //gp 12/16/1998
      begin
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

{begin}                                                          //gp 12/16/1998
function TDcjCppSyn.UseUserSettings(settingIndex: integer): boolean;
// Possible parameter values:
//   index into TStrings returned by EnumUserSettings
// Possible return values:
//   true : settings were read and used
//   false: problem reading settings or invalid version specified - old settings
//          were preserved

  function ReadCPPBSettings(settingIndex: integer): boolean;

    function ReadCPPBSetting(settingTag: string; attri: TmwHighLightAttributes; key: string): boolean;

      function ReadCPPB1(settingTag: string; attri: TmwHighLightAttributes; name: string): boolean;
      var
        i: integer;
      begin
        for i := 1 to Length(name) do
          if name[i] = ' ' then name[i] := '_';
        Result := attri.LoadFromBorlandRegistry(HKEY_CURRENT_USER,              //gp 1998-12-28
             '\SOFTWARE\Borland\C++Builder\'+settingTag+'\Highlight',name,true);
      end; { ReadCPPB1 }

      function ReadCPPB3OrMore(settingTag: string; attri: TmwHighLightAttributes; key: string): boolean;
      begin
        Result := attri.LoadFromBorlandRegistry(HKEY_CURRENT_USER,              //gp 1998-12-28
                 '\Software\Borland\C++Builder\'+settingTag+'\Editor\Highlight',
                 key,false);
      end; { ReadCPPB3OrMore }

    begin { ReadCPPBSetting }
      try
        if (settingTag[1] = '1')
          then Result := ReadCPPB1(settingTag,attri,key)
          else Result := ReadCPPB3OrMore(settingTag,attri,key);
      except Result := false; end;
    end; { ReadCPPBSetting }

  var
    tmpStringAttri    : TmwHighLightAttributes;
    tmpNumberAttri    : TmwHighLightAttributes;
    tmpKeyAttri       : TmwHighLightAttributes;
    tmpSymbolAttri    : TmwHighLightAttributes;
    tmpAsmAttri       : TmwHighLightAttributes;
    tmpCommentAttri   : TmwHighLightAttributes;
    tmpIdentifierAttri: TmwHighLightAttributes;
    tmpInvalidAttri   : TmwHighLightAttributes;                                 //mt 1999-1-2
    tmpSpaceAttri     : TmwHighLightAttributes;
    tmpDirecAttri     : TmwHighLightAttributes;
    s                 : TStringList;

  begin { ReadCPPBSettings }
    s := TStringList.Create;
    try
      EnumUserSettings(s);
      if settingIndex >= s.Count then Result := false
      else begin
        tmpStringAttri    := TmwHighLightAttributes.Create('');
        tmpNumberAttri    := TmwHighLightAttributes.Create('');
        tmpKeyAttri       := TmwHighLightAttributes.Create('');
        tmpSymbolAttri    := TmwHighLightAttributes.Create('');
        tmpAsmAttri       := TmwHighLightAttributes.Create('');
        tmpCommentAttri   := TmwHighLightAttributes.Create('');
        tmpIdentifierAttri:= TmwHighLightAttributes.Create('');
        tmpInvalidAttri   := TmwHighLightAttributes.Create('');                 //mt 1999-1-2
        tmpSpaceAttri     := TmwHighLightAttributes.Create('');
        tmpDirecAttri     := TmwHighLightAttributes.Create('');
        tmpStringAttri    .Assign(fStringAttri);
        tmpNumberAttri    .Assign(fNumberAttri);
        tmpKeyAttri       .Assign(fKeyAttri);
        tmpSymbolAttri    .Assign(fSymbolAttri);
        tmpAsmAttri       .Assign(fAsmAttri);
        tmpCommentAttri   .Assign(fCommentAttri);
        tmpIdentifierAttri.Assign(fIdentifierAttri);
        tmpInvalidAttri   .Assign(fInvalidAttri);                               //mt 1999-1-2
        tmpSpaceAttri     .Assign(fSpaceAttri);
        tmpDirecAttri     .Assign(fDirecAttri);
        if s[settingIndex][1] = '1'
          then Result := ReadCPPBSetting(s[settingIndex],fAsmAttri,'Plain text') // no Assembler setting in BCB1?
          else Result := ReadCPPBSetting(s[settingIndex],fAsmAttri,'Assembler');
        Result := Result                                                         and
                  ReadCPPBSetting(s[settingIndex],fCommentAttri,'Comment')       and
                  ReadCPPBSetting(s[settingIndex],fIdentifierAttri,'Identifier') and
                  ReadCPPBSetting(s[settingIndex],fInvalidAttri,'Illegal Char')  and //mt 1/2/1999
                  ReadCPPBSetting(s[settingIndex],fKeyAttri,'Reserved word')     and
                  ReadCPPBSetting(s[settingIndex],fNumberAttri,'Integer')        and
                  ReadCPPBSetting(s[settingIndex],fSpaceAttri,'Whitespace')      and
                  ReadCPPBSetting(s[settingIndex],fStringAttri,'String')         and
                  ReadCPPBSetting(s[settingIndex],fSymbolAttri,'Symbol')         and
                  ReadCPPBSetting(s[settingIndex],fDirecAttri,'Preprocessor');
        if not Result then begin
          fStringAttri    .Assign(tmpStringAttri);
          fNumberAttri    .Assign(tmpNumberAttri);
          fKeyAttri       .Assign(tmpKeyAttri);
          fSymbolAttri    .Assign(tmpSymbolAttri);
          fAsmAttri       .Assign(tmpAsmAttri);
          fCommentAttri   .Assign(tmpCommentAttri);
          fIdentifierAttri.Assign(tmpIdentifierAttri);
          fInvalidAttri.Assign(tmpInvalidAttri);                                //mt 1999-1-2
          fSpaceAttri     .Assign(tmpSpaceAttri);
          fDirecAttri     .Assign(tmpDirecAttri);
        end;
        tmpStringAttri    .Free;
        tmpNumberAttri    .Free;
        tmpKeyAttri       .Free;
        tmpSymbolAttri    .Free;
        tmpAsmAttri       .Free;
        tmpCommentAttri   .Free;
        tmpIdentifierAttri.Free;
        tmpInvalidAttri   .Free;                                                //mt 1999-1-2
        tmpSpaceAttri     .Free;
        tmpDirecAttri     .Free;
      end;
    finally s.Free; end;
  end; { ReadCPPBSettings }

begin
  Result := ReadCPPBSettings(settingIndex);
end; { TDcjCppSyn.UseUserSettings }
{end}                                                            //gp 12/16/1998

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                         //jdj 12/18/1998
procedure TDcjCppSyn.HighLightChange(Sender:TObject);
begin
{begin}                                                          //gp 12/22/1998
//  if Assigned(mwEdit) then {mwEdit is in TmwCustomHighLighter}
//    mwEdit.Invalidate;
  mwEditList.Invalidate;
{end}                                                            //gp 12/22/1998
end;

procedure TDcjCppSyn.SetHighLightChange;
begin
  fAsmAttri.Onchange:= HighLightChange;
  fCommentAttri.Onchange:= HighLightChange;
  fDirecAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fInvalidAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
*)
{end}                                                                           //mh 1999-08-22
{end}                                                           //jdj 12/18/1998

function TDcjCppSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-24
function TDcjCppSyn.GetAttribCount: integer;
begin
  Result := 10;
end;

function TDcjCppSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fAsmAttri;
    1: Result := fCommentAttri;
    2: Result := fDirecAttri;                                                   //mt 1999-1-2 fixed sorting
    3: Result := fIdentifierAttri;
    4: Result := fInvalidAttri;                                                 //mt 1999-1-2
    5: Result := fKeyAttri;
    6: Result := fNumberAttri;
    7: Result := fSpaceAttri;
    8: Result := fStringAttri;
    9: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TDcjCppSyn.GetLanguageName: string;                                    //mt 1999-1-2
begin
  Result := MWS_LangCPP;                                                        //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

function TDcjCppSyn.GetCapability: THighlighterCapability;                      //gp 1998-12-28
begin
  Result := inherited GetCapability + [hcUserSettings];
end;

//function TDcjCppSyn.GetDefaultFilter: string;                                 //mt 1999-1-2, //gp 1999-1-10 - removed
//begin
// Result := fDefaultFilter;
//end;

//procedure TDcjCppSyn.SetDefaultFilter(Value: string);                         //mt 1999-1-2, //gp 1999-1-10 - removed
//begin
//  if fDefaultFilter <> Value then fDefaultFilter := Value;
//end;


Initialization
  MakeIdentTable;
end.
