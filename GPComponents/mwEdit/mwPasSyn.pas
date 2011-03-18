{+-----------------------------------------------------------------------------+
 | Class:       TmwPasSyn
 | Created:     07.98 - 10.98
 | Last change: 1999-09-24
 | Author:      Martin Waldenburg
 | Description: A very fast SyntaxScanner for Pascal.
 | Version:     0.67 (for version history see version.rtf)
 | Copyright (c) 1998 Martin Waldenburg
 | All rights reserved.
 |
 | Thanks to: Primoz Gabrijelcic, Andy Jeffries, Michael Trier, James Jacobson
 |
 | LICENCE CONDITIONS
 |
 | USE OF THE ENCLOSED SOFTWARE
 | INDICATES YOUR ASSENT TO THE
 | FOLLOWING LICENCE CONDITIONS.
 |
 |
 |
 | These Licence Conditions are exlusively
 | governed by the Law and Rules of the
 | Federal Republic of Germany.
 |
 | Redistribution and use in source and binary form, with or without
 | modification, are permitted provided that the following conditions
 | are met:
 |
 | 1. Redistributions of source code must retain the above copyright
 |    notice, this list of conditions and the following disclaimer.
 |    If the source is modified, the complete original and unmodified
 |    source code has to distributed with the modified version.
 |
 | 2. Redistributions in binary form must reproduce the above
 |    copyright notice, these licence conditions and the disclaimer
 |    found at the end of this licence agreement in the documentation
 |    and/or other materials provided with the distribution.
 |
 | 3. Software using this code must contain a visible line of credit.
 |
 | 4. If my code is used in a "for profit" product, you have to donate
 |    to a registered charity in an amount that you feel is fair.
 |    You may use it in as many of your products as you like.
 |    Proof of this donation must be provided to the author of
 |    this software.
 |
 | 5. If you for some reasons don't want to give public credit to the
 |    author, you have to donate three times the price of your software
 |    product, or any other product including this component in any way,
 |    but no more than $500 US and not less than $200 US, or the
 |    equivalent thereof in other currency, to a registered charity.
 |    You have to do this for every of your products, which uses this
 |    code separately.
 |    Proof of this donations must be provided to the author of
 |    this software.
 |
 |
 | DISCLAIMER:
 |
 | THIS SOFTWARE IS PROVIDED BY THE AUTHOR 'AS IS'.
 |
 | ALL EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 | THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 | PARTICULAR PURPOSE ARE DISCLAIMED.
 |
 | IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 | INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 | (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 | OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 | INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 | WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 | NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 | THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 |
 |  Martin.Waldenburg@T-Online.de
 |
 +----------------------------------------------------------------------------+}

{$I MWEDIT.INC}                                                                 //mt 1998-12-16 added
//gp 12/16/1998 removed {$ObjExportAll On} since it's defined in the include

unit mwPasSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter,                                                                //gp 1998-12-16
  mwLocalStr,                                                                   //mh 1999-08-22
  mwExport;                                                                     //-jdj 1/19/1999

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

type
  TtkTokenKind = (
    tkAsm,
    tkComment,
    tkIdentifier,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown);

  TRangeState = (rsANil, rsAnsi, rsAnsiAsm, rsAsm, rsBor, rsBorAsm, rsProperty, rsUnKnown);

  // Do this in two parts with the type here and the array below                //mt 1998-12-10
  // this is required because the BCB header creater is buggy.
  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

//TmwHighLightAttributes = Class...                                             //gp 1998-12-16 - moved to mwHighlighter.pas
//TmwCustomHighLighter = Class...                                               //gp 1998-12-16 - moved to mwHighlighter.pas

  TmwPasSyn = Class(TmwCustomHighLighter)
  private
    fAsmStart: Boolean;
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;                                                       //aj 1999-02-22
    // Altered to use the above declared type                                   //mt 1998-12-10
    // this is required because the BCB header creater is buggy.
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    Temp: PChar;
    FRoundCount: Integer;
    FSquareCount: Integer;
    fStringLen: Integer;
    fToIdent: PChar;
    // Altered to use the above type                                            //mt 1998-12-10
    // this is required because the BCB header creater is buggy.
    fIdentFuncTable: array[0..191] of TIdentFuncTableFunc;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
//    fEol: Boolean;                                                            //mh 1999-08-22
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fStringAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fAsmAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fD4syntax: boolean;                                                         //gp 1999-03-06
//    procedure AssignAttributes(Attributes: TmwHighLightAttributes);             //mw 1999-01-11 //mh 1999-09-12
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func15: TtkTokenKind;
    function Func19: TtkTokenKind;
    function Func20: TtkTokenKind;
    function Func21: TtkTokenKind;
    function Func23: TtkTokenKind;
    function Func25: TtkTokenKind;
    function Func27: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func32: TtkTokenKind;
    function Func33: TtkTokenKind;
    function Func35: TtkTokenKind;
    function Func37: TtkTokenKind;
    function Func38: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func40: TtkTokenKind;
    function Func41: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func45: TtkTokenKind;
    function Func47: TtkTokenKind;
    function Func49: TtkTokenKind;
    function Func52: TtkTokenKind;
    function Func54: TtkTokenKind;
    function Func55: TtkTokenKind;
    function Func56: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func59: TtkTokenKind;
    function Func60: TtkTokenKind;
    function Func61: TtkTokenKind;
    function Func63: TtkTokenKind;
    function Func64: TtkTokenKind;
    function Func65: TtkTokenKind;
    function Func66: TtkTokenKind;
    function Func69: TtkTokenKind;
    function Func71: TtkTokenKind;
    function Func73: TtkTokenKind;
    function Func75: TtkTokenKind;
    function Func76: TtkTokenKind;
    function Func79: TtkTokenKind;
    function Func81: TtkTokenKind;
    function Func84: TtkTokenKind;
    function Func85: TtkTokenKind;
    function Func87: TtkTokenKind;
    function Func88: TtkTokenKind;
    function Func91: TtkTokenKind;
    function Func92: TtkTokenKind;
    function Func94: TtkTokenKind;
    function Func95: TtkTokenKind;
    function Func96: TtkTokenKind;
    function Func97: TtkTokenKind;
    function Func98: TtkTokenKind;
    function Func99: TtkTokenKind;
    function Func100: TtkTokenKind;
    function Func101: TtkTokenKind;
    function Func102: TtkTokenKind;
    function Func103: TtkTokenKind;
    function Func105: TtkTokenKind;
    function Func106: TtkTokenKind;
    function Func117: TtkTokenKind;
    function Func126: TtkTokenKind;
    function Func129: TtkTokenKind;
    function Func132: TtkTokenKind;
    function Func133: TtkTokenKind;
    function Func136: TtkTokenKind;
    function Func141: TtkTokenKind;
    function Func143: TtkTokenKind;
    function Func166: TtkTokenKind;
    function Func168: TtkTokenKind;
    function Func191: TtkTokenKind;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
    procedure AddressOpProc;
    procedure AsciiCharProc;
    procedure AnsiProc;
    procedure BorProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure ColonProc;
    procedure CommaProc;
    procedure CRProc;
    procedure EqualProc;
    procedure GreaterProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure LowerProc;
    procedure MinusProc;
    procedure NullProc;
    procedure NumberProc;
    procedure PlusProc;
    procedure PointerSymbolProc;
    procedure PointProc;
    procedure RoundCloseProc;
    procedure RoundOpenProc;
    procedure SemiColonProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure SquareCloseProc;
    procedure SquareOpenProc;
    procedure StarProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
//    procedure HighLightChange(Sender:TObject);                                  //jdj 1998-12-18
//    procedure SetHighLightChange;                                               //jdj 1998-12-18 //mh 1999-08-22
    procedure SetD4syntax(const Value: boolean);                                //gp 1999-03-06
  protected
    function GetIdentChars: TIdentChars; override;                              //mt 1998-12-22
    function GetLanguageName: string; override;                                 //gp 1998-12-24, //gp 1999-1-10 - renamed
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;                   //gp 1998-12-28
  public
    constructor Create(AOwner: TComponent); override;
//    destructor Destroy; override;                                             //mh 1999-08-22
    procedure ExportNext;override;                                              //-jdj 1/15/1999
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //aj 1999-02-22
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-02
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    function GetTokenPos: Integer; override;
    procedure Next; override;
//    procedure SetCanvas(Value: TCanvas); override;                            //mh 1999-09-12
    procedure SetLineForExport(NewValue: String);override;                      //-jdj 1/15/1999
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
//  function UseDelphiSettings(settingIndex: integer): boolean;                 //gp 1998-12-09, //mt 1998-12-14 - renamed
    function UseUserSettings(settingIndex: integer): boolean; override;         //mt 1998-12-14
    procedure EnumUserSettings(settings: TStrings); override;                   //mt 1998-12-14
    property IdentChars;                                                        //mt 1998-12-28
  published
    property AsmAttri: TmwHighLightAttributes read fAsmAttri write fAsmAttri;
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
    property D4syntax: boolean read FD4syntax write SetD4syntax default true;   //gp 1999-03-06
  end;

var
  mwPasLex: TmwPasSyn;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TmwPasSyn]);
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
    Case I of
      'a'..'z', 'A'..'Z', '_': mHashTable[I] := Ord(J) - 64;
    else mHashTable[Char(I)] := 0;
    end;
  end;
end;

procedure TmwPasSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 191 do
    Case I of
      15: fIdentFuncTable[I] := Func15;
      19: fIdentFuncTable[I] := Func19;
      20: fIdentFuncTable[I] := Func20;
      21: fIdentFuncTable[I] := Func21;
      23: fIdentFuncTable[I] := Func23;
      25: fIdentFuncTable[I] := Func25;
      27: fIdentFuncTable[I] := Func27;
      28: fIdentFuncTable[I] := Func28;
      32: fIdentFuncTable[I] := Func32;
      33: fIdentFuncTable[I] := Func33;
      35: fIdentFuncTable[I] := Func35;
      37: fIdentFuncTable[I] := Func37;
      38: fIdentFuncTable[I] := Func38;
      39: fIdentFuncTable[I] := Func39;
      40: fIdentFuncTable[I] := Func40;
      41: fIdentFuncTable[I] := Func41;
      44: fIdentFuncTable[I] := Func44;
      45: fIdentFuncTable[I] := Func45;
      47: fIdentFuncTable[I] := Func47;
      49: fIdentFuncTable[I] := Func49;
      52: fIdentFuncTable[I] := Func52;
      54: fIdentFuncTable[I] := Func54;
      55: fIdentFuncTable[I] := Func55;
      56: fIdentFuncTable[I] := Func56;
      57: fIdentFuncTable[I] := Func57;
      59: fIdentFuncTable[I] := Func59;
      60: fIdentFuncTable[I] := Func60;
      61: fIdentFuncTable[I] := Func61;
      63: fIdentFuncTable[I] := Func63;
      64: fIdentFuncTable[I] := Func64;
      65: fIdentFuncTable[I] := Func65;
      66: fIdentFuncTable[I] := Func66;
      69: fIdentFuncTable[I] := Func69;
      71: fIdentFuncTable[I] := Func71;
      73: fIdentFuncTable[I] := Func73;
      75: fIdentFuncTable[I] := Func75;
      76: fIdentFuncTable[I] := Func76;
      79: fIdentFuncTable[I] := Func79;
      81: fIdentFuncTable[I] := Func81;
      84: fIdentFuncTable[I] := Func84;
      85: fIdentFuncTable[I] := Func85;
      87: fIdentFuncTable[I] := Func87;
      88: fIdentFuncTable[I] := Func88;
      91: fIdentFuncTable[I] := Func91;
      92: fIdentFuncTable[I] := Func92;
      94: fIdentFuncTable[I] := Func94;
      95: fIdentFuncTable[I] := Func95;
      96: fIdentFuncTable[I] := Func96;
      97: fIdentFuncTable[I] := Func97;
      98: fIdentFuncTable[I] := Func98;
      99: fIdentFuncTable[I] := Func99;
      100: fIdentFuncTable[I] := Func100;
      101: fIdentFuncTable[I] := Func101;
      102: fIdentFuncTable[I] := Func102;
      103: fIdentFuncTable[I] := Func103;
      105: fIdentFuncTable[I] := Func105;
      106: fIdentFuncTable[I] := Func106;
      117: fIdentFuncTable[I] := Func117;
      126: fIdentFuncTable[I] := Func126;
      129: fIdentFuncTable[I] := Func129;
      132: fIdentFuncTable[I] := Func132;
      133: fIdentFuncTable[I] := Func133;
      136: fIdentFuncTable[I] := Func136;
      141: fIdentFuncTable[I] := Func141;
      143: fIdentFuncTable[I] := Func143;
      166: fIdentFuncTable[I] := Func166;
      168: fIdentFuncTable[I] := Func168;
      191: fIdentFuncTable[I] := Func191;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TmwPasSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  if ToHash^ in ['_', '0'..'9'] then inc(ToHash);
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TmwPasSyn.KeyComp(const aKey: String): Boolean;                        //mh 1999-08-22
var
  I: Integer;
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

function TmwPasSyn.Func15: TtkTokenKind;
begin
  if KeyComp('If') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func19: TtkTokenKind;
begin
  if KeyComp('Do') then Result := tkKey else
    if KeyComp('And') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func20: TtkTokenKind;
begin
  if KeyComp('As') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func21: TtkTokenKind;
begin
  if KeyComp('Of') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func23: TtkTokenKind;
begin
  if KeyComp('End') then
  begin
    Result := tkKey;
    fRange := rsUnknown;
  end else
    if KeyComp('In') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func25: TtkTokenKind;
begin
  if KeyComp('Far') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func27: TtkTokenKind;
begin
  if KeyComp('Cdecl') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func28: TtkTokenKind;
begin
  if KeyComp('Is') then Result := tkKey else
    if KeyComp('Read') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else
      if KeyComp('Case') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func32: TtkTokenKind;
begin
  if KeyComp('Label') then Result := tkKey else
    if KeyComp('Mod') then Result := tkKey else
      if KeyComp('File') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func33: TtkTokenKind;
begin
  if KeyComp('Or') then Result := tkKey else
    if KeyComp('Asm') then
    begin
      Result := tkKey;
      fRange := rsAsm;
      fAsmStart := True;
    end else Result := tkIdentifier;
end;

function TmwPasSyn.Func35: TtkTokenKind;
begin
  if KeyComp('Nil') then Result := tkKey else
    if KeyComp('To') then Result := tkKey else
      if KeyComp('Div') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func37: TtkTokenKind;
begin
  if KeyComp('Begin') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func38: TtkTokenKind;
begin
  if KeyComp('Near') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func39: TtkTokenKind;
begin
  if KeyComp('For') then Result := tkKey else
    if KeyComp('Shl') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func40: TtkTokenKind;
begin
  if KeyComp('Packed') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func41: TtkTokenKind;
begin
  if KeyComp('Else') then Result := tkKey else
    if KeyComp('Var') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func44: TtkTokenKind;
begin
  if KeyComp('Set') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func45: TtkTokenKind;
begin
  if KeyComp('Shr') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func47: TtkTokenKind;
begin
  if KeyComp('Then') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func49: TtkTokenKind;
begin
  if KeyComp('Not') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func52: TtkTokenKind;
begin
  if KeyComp('Pascal') then Result := tkKey else
    if KeyComp('Raise') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func54: TtkTokenKind;
begin
  if KeyComp('Class') then Result := tkKey
  else Result := tkIdentifier;
end;

function TmwPasSyn.Func55: TtkTokenKind;
begin
  if KeyComp('Object') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func56: TtkTokenKind;
begin
  if KeyComp('Index') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else
    if KeyComp('Out') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func57: TtkTokenKind;
begin
  if KeyComp('Goto') then Result := tkKey else
    if KeyComp('While') then Result := tkKey else
      if KeyComp('Xor') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func59: TtkTokenKind;
begin
  if KeyComp('Safecall') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func60: TtkTokenKind;
begin
  if KeyComp('With') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func61: TtkTokenKind;
begin
  if KeyComp('Dispid') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func63: TtkTokenKind;
var
  Temp: Integer;
begin
  if KeyComp('Public') then
  begin
    Result := tkKey;
    if Run = 0 then fRange := rsUnKnown else
    begin
      Temp := Run;
      while Run > 0 do
      begin
        dec(Run);
        Case fLine[Run] of
          #33..#255: Break;
        end;
      end;
      if Run = 0 then fRange := rsUnKnown;
      Run := Temp;
    end;
  end else
    if KeyComp('Record') then Result := tkKey else
      if KeyComp('Array') then Result := tkKey else
        if KeyComp('Try') then Result := tkKey else
          if KeyComp('Inline') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func64: TtkTokenKind;
begin
  if KeyComp('Unit') then Result := tkKey else
    if KeyComp('Uses') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func65: TtkTokenKind;
begin
  if KeyComp('Repeat') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func66: TtkTokenKind;
begin
  if KeyComp('Type') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func69: TtkTokenKind;
begin
  if KeyComp('Default') then Result := tkKey else
    if KeyComp('Dynamic') then Result := tkKey else
      if KeyComp('Message') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func71: TtkTokenKind;
begin
  if KeyComp('Stdcall') then Result := tkKey else
    if KeyComp('Const') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func73: TtkTokenKind;
begin
  if KeyComp('Except') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func75: TtkTokenKind;
begin
  if KeyComp('Write') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func76: TtkTokenKind;
begin
  if KeyComp('Until') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func79: TtkTokenKind;
begin
  if KeyComp('Finally') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func81: TtkTokenKind;
begin
  if KeyComp('Stored') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else
    if KeyComp('Interface') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func84: TtkTokenKind;
begin
  if KeyComp('Abstract') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func85: TtkTokenKind;
begin
  if KeyComp('Forward') then Result := tkKey else
    if KeyComp('Library') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func87: TtkTokenKind;
begin
  if KeyComp('String') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func88: TtkTokenKind;
begin
  if KeyComp('Program') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func91: TtkTokenKind;
var
  Temp: Integer;
begin
  if KeyComp('Downto') then Result := tkKey else
    if KeyComp('Private') then
    begin
      Result := tkKey;
      if Run = 0 then fRange := rsUnKnown else
      begin
        Temp := Run;
        while Run > 0 do
        begin
          dec(Run);
          Case fLine[Run] of
            #33..#255: Break;
          end;
        end;
        if Run = 0 then fRange := rsUnKnown;
        Run := Temp;
      end;
    end else Result := tkIdentifier;
end;

function TmwPasSyn.Func92: TtkTokenKind;
begin
  if D4syntax and KeyComp('overload') then Result := tkKey else
    if KeyComp('Inherited') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func94: TtkTokenKind;
begin
  if KeyComp('Assembler') then Result := tkKey else
    if KeyComp('Readonly') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else Result := tkIdentifier;
end;

function TmwPasSyn.Func95: TtkTokenKind;
begin
  if KeyComp('Absolute') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func96: TtkTokenKind;
var
  Temp: Integer;
begin
  if KeyComp('Published') then
  begin
    Result := tkKey;
    if Run = 0 then fRange := rsUnKnown else
    begin
      Temp := Run;
      while Run > 0 do
      begin
        dec(Run);
        Case fLine[Run] of
          #33..#255: Break;
        end;
      end;
      if Run = 0 then fRange := rsUnKnown;
      Run := Temp;
    end;
  end else
    if KeyComp('Override') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func97: TtkTokenKind;
begin
  if KeyComp('Threadvar') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func98: TtkTokenKind;
begin
  if KeyComp('Export') then Result := tkKey else
    if KeyComp('Nodefault') then
    begin
      if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
    end else Result := tkIdentifier;
end;

function TmwPasSyn.Func99: TtkTokenKind;
begin
  if KeyComp('External') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func100: TtkTokenKind;
begin
  if KeyComp('Automated') then
  begin
    if fRange = rsProperty then
    begin
      Result := tkKey;
      fRange := rsUnKnown;
    end else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func101: TtkTokenKind;
begin
  if KeyComp('Register') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func102: TtkTokenKind;
begin
  if KeyComp('Function') then
  begin
    Result := tkKey;
    fRange := rsUnKnown;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func103: TtkTokenKind;
begin
  if KeyComp('Virtual') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func105: TtkTokenKind;
begin
  if KeyComp('Procedure') then
  begin
    Result := tkKey;
    fRange := rsUnKnown;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func106: TtkTokenKind;
var
  Temp: Integer;
begin
  if KeyComp('Protected') then
  begin
    Result := tkKey;
    if Run = 0 then fRange := rsUnKnown else
    begin
      Temp := Run;
      while Run > 0 do
      begin
        dec(Run);
        Case fLine[Run] of
          #33..#255: Break;
        end;
      end;
      if Run = 0 then fRange := rsUnKnown;
      Run := Temp;
    end;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func117: TtkTokenKind;
begin
  if KeyComp('Exports') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func126: TtkTokenKind;
begin
  if D4syntax and KeyComp('Implements') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func129: TtkTokenKind;
begin
  if KeyComp('Dispinterface') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func132: TtkTokenKind;
begin
  if D4syntax and KeyComp('Reintroduce') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func133: TtkTokenKind;
begin
  if KeyComp('Property') then
  begin
    Result := tkKey;
    fRange := rsProperty;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func136: TtkTokenKind;
begin
  if KeyComp('Finalization') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func141: TtkTokenKind;
begin
  if KeyComp('Writeonly') then
  begin
    if fRange = rsProperty then Result := tkKey else Result := tkIdentifier;
  end else Result := tkIdentifier;
end;

function TmwPasSyn.Func143: TtkTokenKind;
begin
  if KeyComp('Destructor') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func166: TtkTokenKind;
begin
  if KeyComp('Constructor') then Result := tkKey else
    if KeyComp('Implementation') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func168: TtkTokenKind;
begin
  if KeyComp('Initialization') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.Func191: TtkTokenKind;
begin
  if KeyComp('Resourcestring') then Result := tkKey else
    if KeyComp('Stringresource') then Result := tkKey else Result := tkIdentifier;
end;

function TmwPasSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier
end;

function TmwPasSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 192 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TmwPasSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      #0: fProcTable[I] := NullProc;
      #10: fProcTable[I] := LFProc;
      #13: fProcTable[I] := CRProc;
      #1..#9, #11, #12, #14..#32:
        fProcTable[I] := SpaceProc;
      '#': fProcTable[I] := AsciiCharProc;
      '$': fProcTable[I] := IntegerProc;
      #39: fProcTable[I] := StringProc;
      '0'..'9': fProcTable[I] := NumberProc;
      'A'..'Z', 'a'..'z', '_':
        fProcTable[I] := IdentProc;
      '{': fProcTable[I] := BraceOpenProc;
      '}': fProcTable[I] := BraceCloseProc;
      '!', '"', '%', '&', '('..'/', ':'..'@', '['..'^', '`', '~':
        begin
          case I of
            '(': fProcTable[I] := RoundOpenProc;
            ')': fProcTable[I] := RoundCloseProc;
            '*': fProcTable[I] := StarProc;
            '+': fProcTable[I] := PlusProc;
            ',': fProcTable[I] := CommaProc;
            '-': fProcTable[I] := MinusProc;
            '.': fProcTable[I] := PointProc;
            '/': fProcTable[I] := SlashProc;
            ':': fProcTable[I] := ColonProc;
            ';': fProcTable[I] := SemiColonProc;
            '<': fProcTable[I] := LowerProc;
            '=': fProcTable[I] := EqualProc;
            '>': fProcTable[I] := GreaterProc;
            '@': fProcTable[I] := AddressOpProc;
            '[': fProcTable[I] := SquareOpenProc;
            ']': fProcTable[I] := SquareCloseProc;
            '^': fProcTable[I] := PointerSymbolProc;
          else fProcTable[I] := SymbolProc;
          end;
        end;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TmwPasSyn.Create(AOwner: TComponent);
begin
  fD4syntax := true;                                                            //gp 1999-03-06
  fAsmAttri := TmwHighLightAttributes.Create(MWS_AttrAssembler);                //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24
  fCommentAttri.Style:= [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style:= [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  inherited Create(AOwner);

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fAsmAttri);
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;                                                           //jdj 1998-12-18
  SetAttributesOnChange(DefHighlightChange);                                    
{end}                                                                           //mh 1999-08-22

  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
  fAsmStart := False;
  fDefaultFilter := MWS_FilterPascal;                                           //ajb 1999-09-14
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TmwPasSyn.Destroy;
begin
  fAsmAttri.Free;
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
procedure TmwPasSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end;
*)

procedure TmwPasSyn.SetLine(NewValue: String; LineNumber:Integer);              //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  fLineNumber := LineNumber;                                                    //aj 1999-02-22
  Next;
end; { SetLine }

procedure TmwPasSyn.AddressOpProc;
begin
  Case FLine[Run + 1] of
    '@':
      begin
        fTokenID := tkSymbol;
        inc(Run, 2);
      end;
  else
    begin
      fTokenID := tkSymbol;
      inc(Run);
    end;
  end;
end;

procedure TmwPasSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  inc(Run);
  while FLine[Run] in ['0'..'9'] do inc(Run);
end;

procedure TmwPasSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TmwPasSyn.BorProc;
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
          if fRange = rsBorAsm then fRange := rsAsm else fRange := rsUnKnown;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwPasSyn.BraceOpenProc;
begin
  fTokenID := tkComment;
  if fRange = rsAsm then fRange := rsBorAsm else fRange := rsBor;
  inc(Run);
  while FLine[Run] <> #0 do
    case FLine[Run] of
      '}':
        begin
          if fRange = rsBorAsm then fRange := rsAsm else fRange := rsUnKnown;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwPasSyn.ColonProc;
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

procedure TmwPasSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TmwPasSyn.EqualProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.GreaterProc;
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

procedure TmwPasSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TmwPasSyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
end;

procedure TmwPasSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TmwPasSyn.LowerProc;
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

procedure TmwPasSyn.MinusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-08-22
end;

procedure TmwPasSyn.NumberProc;
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

procedure TmwPasSyn.PlusProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.PointerSymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.PointProc;
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
        dec(FSquareCount);
      end;
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TmwPasSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  dec(FRoundCount);
end;

procedure TmwPasSyn.AnsiProc;
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
          if fRange = rsAnsiAsm then fRange := rsAsm else fRange := rsUnKnown;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwPasSyn.RoundOpenProc;
begin
  inc(Run);
  case fLine[Run] of
    '*':
      begin
        fTokenID := tkComment;
        if Frange = rsAsm then fRange := rsAnsiAsm else fRange := rsAnsi;
        inc(Run);
        while fLine[Run] <> #0 do
          case fLine[Run] of
            '*':
              if fLine[Run + 1] = ')' then
              begin
                if fRange = rsAnsiAsm then fRange := rsAsm else fRange := rsUnKnown;
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
        inc(FSquareCount);
      end;
  else
    begin
      FTokenID := tkSymbol;
      inc(FRoundCount);
    end;
  end;
end;

procedure TmwPasSyn.SemiColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.SlashProc;
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

procedure TmwPasSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TmwPasSyn.SquareCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  dec(FSquareCount);
end;

procedure TmwPasSyn.SquareOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  inc(FSquareCount);
end;

procedure TmwPasSyn.StarProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.StringProc;
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

procedure TmwPasSyn.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TmwPasSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

(*                                                                              //mh 1999-09-12
procedure TmwPasSyn.AssignAttributes(Attributes: TmwHighLightAttributes);       //mw 1999-01-11
begin
 if fCanvas.Brush.Color<> Attributes.Background then fCanvas.Brush.Color:= Attributes.Background;
 if fCanvas.Font.Color<> Attributes.Foreground then fCanvas.Font.Color:= Attributes.Foreground;
 if fCanvas.Font.Style<> Attributes.Style then fCanvas.Font.Style:= Attributes.Style;
end;
*)

procedure TmwPasSyn.Next;                                                       //mw 1999-01-11
// var TokenID: TtkTokenKind;                                                        //aj 1999-02-22 //mh 1999-09-02
begin
  fAsmStart := False;
  fTokenPos := Run;
  Case fRange of
    rsAnsi: AnsiProc;
    rsAnsiAsm: AnsiProc;
    rsBor: BorProc;
    rsBorAsm: BorProc;
  else fProcTable[fLine[Run]];
  end;
(*                                                                              //mh 1999-09-02
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //aj 1999-02-22
    case TokenID of                                                             //aj 1999-02-22
      tkAsm:AssignAttributes(fAsmAttri);
      tkComment:AssignAttributes(fCommentAttri);
      tkIdentifier:AssignAttributes(fIdentifierAttri);
      tkKey:AssignAttributes(fKeyAttri);
      tkNumber:AssignAttributes(fNumberAttri);
      tkSpace:AssignAttributes(fSpaceAttri);
      tkString:AssignAttributes(fStringAttri);
      tkSymbol:AssignAttributes(fSymbolAttri);
      tkUnknown:AssignAttributes(fSymbolAttri);
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-27 //mh 1999-08-22
  end;
*)
end;

function TmwPasSyn.GetEol: Boolean;
begin
//  Result := False;                                                            //mh 1999-09-12
//  if fTokenId = tkNull then Result := True;
  Result := fTokenID = tkNull;
end;

function TmwPasSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TmwPasSyn.GetTokenID: TtkTokenKind;
begin
  if (fRange = rsAsm) and (not fAsmStart) then
    Case fTokenId of
      tkComment: Result := tkComment;
      tkNull: Result := tkNull;
      tkSpace: Result := tkSpace;
    else Result := tkAsm;
    end else Result := fTokenId;
end;

function TmwPasSyn.GetTokenAttribute: TmwHighLightAttributes;                   //mh 1999-09-02
begin
  case GetTokenID of
    tkAsm: Result := fAsmAttri;
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

function TmwPasSyn.GetTokenKind: integer;                                       //mh 1999-08-22
begin
  Result := Ord(GetTokenID);
end;

function TmwPasSyn.GetTokenPos: Integer;
begin
 Result := fTokenPos;
end;

function TmwPasSyn.GetRange: Pointer;
begin
 Result := Pointer(fRange);
end;

procedure TmwPasSyn.SetRange(Value: Pointer);
begin
 fRange := TRangeState(Value);
end;

procedure TmwPasSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

{begin}                                                                         //gp 1998-12-09
procedure TmwPasSyn.EnumUserSettings(settings: TStrings);                       //mt 1998-12-14
begin
  { returns the user settings that exist in the registry }
  with TBetterRegistry.Create do 
  begin
    try
      RootKey := HKEY_LOCAL_MACHINE;
      // Комментарий от Алисова А.: вместо HKLM\SOFTWARE\Borland\Delphi
      // нужно искать версии современных Delphi в районе HKLM\SOFTWARE\Borland\BDS
      // (правда структура веток в реестре с появлением BDS, похоже, поменялась)
      if OpenKeyReadOnly('\SOFTWARE\Borland\Delphi') then
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

function TmwPasSyn.UseUserSettings(settingIndex: integer): boolean;             //mt 1998-12-14 - renamed, //gp 1998-12-16 - rewritten
// Possible parameter values:
//   index into TStrings returned by EnumUserSettings
// Possible return values:
//   true : settings were read and used
//   false: problem reading settings or invalid version specified - old settings
//          were preserved

  function ReadDelphiSettings(settingIndex: integer): boolean;

    function ReadDelphiSetting(settingTag: string; attri: TmwHighLightAttributes; key: string): boolean;

      function ReadDelphi2Or3(settingTag: string; attri: TmwHighLightAttributes; name: string): boolean;
      var
        i: integer;
      begin
        for i := 1 to Length(name) do
          if name[i] = ' ' then name[i] := '_';
        Result := attri.LoadFromBorlandRegistry(HKEY_CURRENT_USER,              //gp 1998-12-28
                '\Software\Borland\Delphi\'+settingTag+'\Highlight',name,true);
      end; { ReadDelphi2Or3 }

      function ReadDelphi4OrMore(settingTag: string; attri: TmwHighLightAttributes; key: string): boolean;
      begin
        Result := attri.LoadFromBorlandRegistry(HKEY_CURRENT_USER,              //gp 1998-12-28
               '\Software\Borland\Delphi\'+settingTag+'\Editor\Highlight',key,false);
      end; { ReadDelphi4OrMore }

    begin { ReadDelphiSetting }
      try
        if (settingTag[1] = '2') or (settingTag[1] = '3')
          then Result := ReadDelphi2Or3(settingTag,attri,key)
          else Result := ReadDelphi4OrMore(settingTag,attri,key);
      except Result := false; end;
    end; { ReadDelphiSetting }

  var
    tmpStringAttri    : TmwHighLightAttributes;
    tmpNumberAttri    : TmwHighLightAttributes;
    tmpKeyAttri       : TmwHighLightAttributes;
    tmpSymbolAttri    : TmwHighLightAttributes;
    tmpAsmAttri       : TmwHighLightAttributes;
    tmpCommentAttri   : TmwHighLightAttributes;
    tmpIdentifierAttri: TmwHighLightAttributes;
    tmpSpaceAttri     : TmwHighLightAttributes;
    s                 : TStringList;

  begin { ReadDelphiSettings }
    s := TStringList.Create;
    try
      EnumUserSettings(s);
      if (settingIndex < 0) or (settingIndex >= s.Count) then Result := false
      else begin
        tmpStringAttri    := TmwHighLightAttributes.Create('');
        tmpNumberAttri    := TmwHighLightAttributes.Create('');
        tmpKeyAttri       := TmwHighLightAttributes.Create('');
        tmpSymbolAttri    := TmwHighLightAttributes.Create('');
        tmpAsmAttri       := TmwHighLightAttributes.Create('');
        tmpCommentAttri   := TmwHighLightAttributes.Create('');
        tmpIdentifierAttri:= TmwHighLightAttributes.Create('');
        tmpSpaceAttri     := TmwHighLightAttributes.Create('');
        tmpStringAttri    .Assign(fStringAttri);
        tmpNumberAttri    .Assign(fNumberAttri);
        tmpKeyAttri       .Assign(fKeyAttri);
        tmpSymbolAttri    .Assign(fSymbolAttri);
        tmpAsmAttri       .Assign(fAsmAttri);
        tmpCommentAttri   .Assign(fCommentAttri);
        tmpIdentifierAttri.Assign(fIdentifierAttri);
        tmpSpaceAttri     .Assign(fSpaceAttri);
        Result := ReadDelphiSetting(s[settingIndex],fAsmAttri,'Assembler')         and
                  ReadDelphiSetting(s[settingIndex],fCommentAttri,'Comment')       and
                  ReadDelphiSetting(s[settingIndex],fIdentifierAttri,'Identifier') and
                  ReadDelphiSetting(s[settingIndex],fKeyAttri,'Reserved word')     and
                  ReadDelphiSetting(s[settingIndex],fNumberAttri,'Number')         and
                  ReadDelphiSetting(s[settingIndex],fSpaceAttri,'Whitespace')      and
                  ReadDelphiSetting(s[settingIndex],fStringAttri,'String')         and
                  ReadDelphiSetting(s[settingIndex],fSymbolAttri,'Symbol');
        if not Result then begin
          fStringAttri    .Assign(tmpStringAttri);
          fNumberAttri    .Assign(tmpNumberAttri);
          fKeyAttri       .Assign(tmpKeyAttri);
          fSymbolAttri    .Assign(tmpSymbolAttri);
          fAsmAttri       .Assign(tmpAsmAttri);
          fCommentAttri   .Assign(tmpCommentAttri);
          fIdentifierAttri.Assign(tmpIdentifierAttri);
          fSpaceAttri     .Assign(tmpSpaceAttri);
        end;
        tmpStringAttri    .Free;
        tmpNumberAttri    .Free;
        tmpKeyAttri       .Free;
        tmpSymbolAttri    .Free;
        tmpAsmAttri       .Free;
        tmpCommentAttri   .Free;
        tmpIdentifierAttri.Free;
        tmpSpaceAttri     .Free;
      end;
    finally s.Free; end;
  end; { ReadDelphiSettings }

begin
  Result := ReadDelphiSettings(settingIndex);
end; { TmwPasSyn.UseUserSettings }
{end}                                                                           //gp 1998-12-09

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //jdj 1998-12-18
procedure TmwPasSyn.HighLightChange(Sender:TObject);
begin
//if Assigned(mwEdit) then {mwEdit is in TmwCustomHighLighter}
//  mwEdit.Invalidate;
  mwEditList.Invalidate;                                                        //jdj 1998-12-18
end;

procedure TmwPasSyn.SetHighLightChange;
begin
  fAsmAttri.Onchange:= HighLightChange;
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
{end}                                                                           //jdj 1998-12-18
*)
{end}                                                                           //mh 1999-08-22

function TmwPasSyn.GetIdentChars: TIdentChars;                                  //mt 1998-12-22
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-24
function TmwPasSyn.GetAttribCount: integer;
begin
  Result := 8;
end;

function TmwPasSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin // sorted by name
  case idx of
    0: Result := fAsmAttri;
    1: Result := fCommentAttri;
    2: Result := fIdentifierAttri;
    3: Result := fNumberAttri;
    4: Result := fKeyAttri;
    5: Result := fSpaceAttri;
    6: Result := fStringAttri;
    7: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TmwPasSyn.GetLanguageName: string;
begin
  Result := MWS_LangPascal;                                                     //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

function TmwPasSyn.GetCapability: THighlighterCapability;                       //gp 1998-12-28
begin
  Result := inherited GetCapability + [hcUserSettings,hcExportable];            //gp 1999-05-06
end;

procedure TmwPasSyn.SetD4syntax(const Value: boolean);                          //gp 1999-03-06
begin
  FD4syntax := Value;
end;

procedure TmwPasSyn.SetLineForExport(NewValue: String);                         //-jdj 1/15/1999
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  ExportNext;
end; { SetLineForExport }

procedure TmwPasSyn.ExportNext;                                                 //-jdj 1/15/1999
begin
  fAsmStart := False;
  fTokenPos := Run;
  Case fRange of
    rsAnsi: AnsiProc;
    rsAnsiAsm: AnsiProc;
    rsBor: BorProc;
    rsBorAsm: BorProc;
  else fProcTable[fLine[Run]];
  end;
  if Assigned(Exporter) then
    with TmwCustomExport(Exporter) do begin
      Case GetTokenID of
        tkAsm:FormatToken(GetToken, fAsmAttri, False,False);
        tkComment:FormatToken(GetToken, fCommentAttri, True,False);
        tkIdentifier:FormatToken(GetToken, fIdentifierAttri, False,False);
        tkKey:FormatToken(GetToken, fKeyAttri, False,False);
        tkNumber:FormatToken(GetToken, fNumberAttri, False,False);
        {Needed to catch Line breaks}
        tkNull:FormatToken('', nil, False,False);
        tkSpace:FormatToken(GetToken, fSpaceAttri, False,True);
        tkString:FormatToken(GetToken, fStringAttri, True,False);
        tkSymbol:FormatToken(GetToken, fSymbolAttri,True,False);
        tkUnknown:FormatToken(GetToken, fSymbolAttri, True,False);
      end;
    end; //with
end;

initialization
  MakeIdentTable;
end.

