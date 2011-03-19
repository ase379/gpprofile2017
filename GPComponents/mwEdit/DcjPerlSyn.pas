{$I MWEDIT.INC}
{---------------------------------------------------------------------------
 Perl Language Syntax Parser

 DcjPerlSyn was created as a plug in component for the Syntax Editor mwEdit
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
 Perl Language Syntax Parser v0.60
{---------------------------------------------------------------------------
 Revision History:
 0.58:    * Primoz Gabrijelcic: Implemented OnToken event.
 0.57:    * Primoz Gabrijelcic: Moved most of DefaultFilter support to
            mwHighlighter.pas.
 0.56:    * Added InvalidAttri for unknown characters.
          * Removed rsANil enum - it's not used.
          * Implemented DefaultFilter property. Changed Get Name to
            GetLanguageName.  Added LanguageName, Attribute, AttrCount, and
            Capability to the public section.
 0.54:    * Primoz Gabrijelcic: Added attribute names. Implemented GetName,
            GetAttribCount, GetAttribute.
 0.53:    * Added IdentChars implementation to let the editor know which
            characters are non "whitespace".
 0.51:    * Primoz Gabrijelcic: removed EnumUserSettings and UserUserSettings,
            default handling is done in ancestor class;
            implemented changes that will update the Editor when any changes
            are made to the Highlighter. That is when any color or font style
            is changed and when the Highlighter is added or removed the Editor
            will be invalidated.
 0.50:    * Initial version.
{---------------------------------------------------------------------------
 Known Problems:
   * Using q, qq, qw, qx, m, s, tr will not properly parse the contained
     information.
   * Not very optimized.  I'm working on it.
{---------------------------------------------------------------------------}

unit DcjPerlSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, mwHighlighter,
  mwLocalStr;                                                                   //mh 1999-08-22

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
    tkOperator,
    tkPragma,
    tkSpace,
    tkString,
    tkSymbol,
    tkUnknown,
    tkVariable);

  TRangeState = (rsUnKnown);

  TProcTableProc = procedure of Object;
  TIdentFuncTableFunc = function: TtkTokenKind of Object;

type
  TDcjPerlSyn = class(TmwCustomHighLighter)
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
//    fEol: Boolean;                                                            //mh 1999-08-22
    fIdentFuncTable: array[0..2167] of TIdentFuncTableFunc;
    fLineNumber: Integer;                                                       //aj 1999-02-22
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fInvalidAttri: TmwHighLightAttributes;                                      //mt 1999-1-2
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fOperatorAttri: TmwHighLightAttributes;
    fPragmaAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fVariableAttri: TmwHighLightAttributes;
//  fDefaultFilter: string;                                                     //mt 1999-1-2, //gp 1999-1-10 - removed

    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    function Func109:TtkTokenKind;
    function Func113:TtkTokenKind;
    function Func196:TtkTokenKind;
    function Func201:TtkTokenKind;
    function Func204:TtkTokenKind;
    function Func207:TtkTokenKind;
    function Func209:TtkTokenKind;
    function Func211:TtkTokenKind;
    function Func214:TtkTokenKind;
    function Func216:TtkTokenKind;
    function Func219:TtkTokenKind;
    function Func221:TtkTokenKind;
    function Func224:TtkTokenKind;
    function Func225:TtkTokenKind;
    function Func226:TtkTokenKind;
    function Func230:TtkTokenKind;
    function Func232:TtkTokenKind;
    function Func233:TtkTokenKind;
    function Func248:TtkTokenKind;
    function Func254:TtkTokenKind;
    function Func255:TtkTokenKind;
    function Func257:TtkTokenKind;
    function Func262:TtkTokenKind;
    function Func263:TtkTokenKind;
    function Func269:TtkTokenKind;
    function Func280:TtkTokenKind;
    function Func282:TtkTokenKind;
    function Func306:TtkTokenKind;
    function Func307:TtkTokenKind;
    function Func310:TtkTokenKind;
    function Func314:TtkTokenKind;
    function Func317:TtkTokenKind;
    function Func318:TtkTokenKind;
    function Func320:TtkTokenKind;
    function Func322:TtkTokenKind;
    function Func325:TtkTokenKind;
    function Func326:TtkTokenKind;
    function Func327:TtkTokenKind;
    function Func330:TtkTokenKind;
    function Func331:TtkTokenKind;
    function Func333:TtkTokenKind;
    function Func335:TtkTokenKind;
    function Func337:TtkTokenKind;
    function Func338:TtkTokenKind;
    function Func340:TtkTokenKind;
    function Func345:TtkTokenKind;
    function Func346:TtkTokenKind;
    function Func368:TtkTokenKind;
    function Func401:TtkTokenKind;
    function Func412:TtkTokenKind;
    function Func413:TtkTokenKind;
    function Func415:TtkTokenKind;
    function Func419:TtkTokenKind;
    function Func420:TtkTokenKind;
    function Func421:TtkTokenKind;
    function Func424:TtkTokenKind;
    function Func425:TtkTokenKind;
    function Func426:TtkTokenKind;
    function Func428:TtkTokenKind;
    function Func430:TtkTokenKind;
    function Func431:TtkTokenKind;
    function Func432:TtkTokenKind;
    function Func433:TtkTokenKind;
    function Func434:TtkTokenKind;
    function Func436:TtkTokenKind;
    function Func437:TtkTokenKind;
    function Func438:TtkTokenKind;
    function Func439:TtkTokenKind;
    function Func440:TtkTokenKind;
    function Func441:TtkTokenKind;
    function Func442:TtkTokenKind;
    function Func444:TtkTokenKind;
    function Func445:TtkTokenKind;
    function Func447:TtkTokenKind;
    function Func448:TtkTokenKind;
    function Func456:TtkTokenKind;
    function Func458:TtkTokenKind;
    function Func470:TtkTokenKind;
    function Func477:TtkTokenKind;
    function Func502:TtkTokenKind;
    function Func522:TtkTokenKind;
    function Func523:TtkTokenKind;
    function Func525:TtkTokenKind;
    function Func527:TtkTokenKind;
    function Func530:TtkTokenKind;
    function Func531:TtkTokenKind;
    function Func534:TtkTokenKind;
    function Func535:TtkTokenKind;
    function Func536:TtkTokenKind;
    function Func537:TtkTokenKind;
    function Func539:TtkTokenKind;
    function Func542:TtkTokenKind;
    function Func543:TtkTokenKind;
    function Func545:TtkTokenKind;
    function Func546:TtkTokenKind;
    function Func547:TtkTokenKind;
    function Func548:TtkTokenKind;
    function Func549:TtkTokenKind;
    function Func552:TtkTokenKind;
    function Func555:TtkTokenKind;
    function Func556:TtkTokenKind;
    function Func557:TtkTokenKind;
    function Func562:TtkTokenKind;
    function Func569:TtkTokenKind;
    function Func570:TtkTokenKind;
    function Func622:TtkTokenKind;
    function Func624:TtkTokenKind;
    function Func627:TtkTokenKind;
    function Func630:TtkTokenKind;
    function Func632:TtkTokenKind;
    function Func637:TtkTokenKind;
    function Func640:TtkTokenKind;
    function Func642:TtkTokenKind;
    function Func643:TtkTokenKind;
    function Func645:TtkTokenKind;
    function Func647:TtkTokenKind;
    function Func648:TtkTokenKind;
    function Func649:TtkTokenKind;
    function Func650:TtkTokenKind;
    function Func651:TtkTokenKind;
    function Func652:TtkTokenKind;
    function Func655:TtkTokenKind;
    function Func656:TtkTokenKind;
    function Func657:TtkTokenKind;
    function Func658:TtkTokenKind;
    function Func665:TtkTokenKind;
    function Func666:TtkTokenKind;
    function Func667:TtkTokenKind;
    function Func672:TtkTokenKind;
    function Func675:TtkTokenKind;
    function Func677:TtkTokenKind;
    function Func687:TtkTokenKind;
    function Func688:TtkTokenKind;
    function Func716:TtkTokenKind;
    function Func719:TtkTokenKind;
    function Func727:TtkTokenKind;
    function Func728:TtkTokenKind;
    function Func731:TtkTokenKind;
    function Func734:TtkTokenKind;
    function Func740:TtkTokenKind;
    function Func741:TtkTokenKind;
    function Func743:TtkTokenKind;
    function Func746:TtkTokenKind;
    function Func749:TtkTokenKind;
    function Func750:TtkTokenKind;
    function Func752:TtkTokenKind;
    function Func753:TtkTokenKind;
    function Func754:TtkTokenKind;
    function Func759:TtkTokenKind;
    function Func761:TtkTokenKind;
    function Func762:TtkTokenKind;
    function Func763:TtkTokenKind;
    function Func764:TtkTokenKind;
    function Func765:TtkTokenKind;
    function Func768:TtkTokenKind;
    function Func769:TtkTokenKind;
    function Func773:TtkTokenKind;
    function Func774:TtkTokenKind;
    function Func775:TtkTokenKind;
    function Func815:TtkTokenKind;
    function Func821:TtkTokenKind;
    function Func841:TtkTokenKind;
    function Func842:TtkTokenKind;
    function Func845:TtkTokenKind;
    function Func853:TtkTokenKind;
    function Func855:TtkTokenKind;
    function Func857:TtkTokenKind;
    function Func860:TtkTokenKind;
    function Func864:TtkTokenKind;
    function Func867:TtkTokenKind;
    function Func868:TtkTokenKind;
    function Func869:TtkTokenKind;
    function Func870:TtkTokenKind;
    function Func873:TtkTokenKind;
    function Func874:TtkTokenKind;
    function Func876:TtkTokenKind;
    function Func877:TtkTokenKind;
    function Func878:TtkTokenKind;
    function Func881:TtkTokenKind;
    function Func883:TtkTokenKind;
    function Func890:TtkTokenKind;
    function Func892:TtkTokenKind;
    function Func906:TtkTokenKind;
    function Func933:TtkTokenKind;
    function Func954:TtkTokenKind;
    function Func956:TtkTokenKind;
    function Func965:TtkTokenKind;
    function Func968:TtkTokenKind;
    function Func974:TtkTokenKind;
    function Func978:TtkTokenKind;
    function Func981:TtkTokenKind;
    function Func985:TtkTokenKind;
    function Func986:TtkTokenKind;
    function Func988:TtkTokenKind;
    function Func1056:TtkTokenKind;
    function Func1077:TtkTokenKind;
    function Func1079:TtkTokenKind;
    function Func1084:TtkTokenKind;
    function Func1086:TtkTokenKind;
    function Func1091:TtkTokenKind;
    function Func1093:TtkTokenKind;
    function Func1095:TtkTokenKind;
    function Func1103:TtkTokenKind;
    function Func1105:TtkTokenKind;
    function Func1107:TtkTokenKind;
    function Func1136:TtkTokenKind;
    function Func1158:TtkTokenKind;
    function Func1165:TtkTokenKind;
    function Func1169:TtkTokenKind;
    function Func1172:TtkTokenKind;
    function Func1176:TtkTokenKind;
    function Func1202:TtkTokenKind;
    function Func1211:TtkTokenKind;
    function Func1215:TtkTokenKind;
    function Func1218:TtkTokenKind;
    function Func1223:TtkTokenKind;
    function Func1230:TtkTokenKind;
    function Func1273:TtkTokenKind;
    function Func1277:TtkTokenKind;
    function Func1283:TtkTokenKind;
    function Func1327:TtkTokenKind;
    function Func1343:TtkTokenKind;
    function Func1361:TtkTokenKind;
    function Func1379:TtkTokenKind;
    function Func1396:TtkTokenKind;
    function Func1402:TtkTokenKind;
    function Func1404:TtkTokenKind;
    function Func1409:TtkTokenKind;
    function Func1421:TtkTokenKind;
    function Func1425:TtkTokenKind;
    function Func1440:TtkTokenKind;
    function Func1520:TtkTokenKind;
    function Func1523:TtkTokenKind;
    function Func1673:TtkTokenKind;
    function Func1752:TtkTokenKind;
    function Func1762:TtkTokenKind;
    function Func1768:TtkTokenKind;
    function Func2167:TtkTokenKind;
    procedure AndSymbolProc;
    procedure BackslashProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
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
    procedure NotSymbolProc;
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
    procedure TildeProc;
    procedure XOrSymbolProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
    procedure MakeMethodTables;
//    procedure HighLightChange(Sender:TObject);                                  //gp 1998-12-22 //mh 1999-08-22
//    procedure SetHighLightChange;                                               //gp 1998-12-22 //mh 1999-08-22
  protected
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;                                 //gp 1998-12-24
                                                                                //mt 1999-1-2
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
//  function GetDefaultFilter: string; override;                                //mt 1999-1-2, //gp 1999-1-10 - removed
//  procedure SetDefaultFilter(Value: string); override;                        //mt 1999-1-2, //gp 1999-1-10 - removed
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
    property IdentChars;
    {begin}                                                      //gp 12/22/1998
    // not needed, default handling done in ancestor class
//  function UseUserSettings(settingIndex: integer): boolean; override;
//  procedure EnumUserSettings(settings: TStrings); override;
    {begin}                                                      //gp 12/22/1998
    property LanguageName;                                                      //mt 1999-1-2
    property AttrCount;                                                         //mt 1999-1-2
    property Attribute;                                                         //mt 1999-1-2
    property Capability;                                                        //mt 1999-1-2
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property InvalidAttri: TmwHighLightAttributes read fInvalidAttri write fInvalidAttri; //mt 1/2/1999
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property OperatorAttri: TmwHighLightAttributes read fOperatorAttri write fOperatorAttri;
    property PragmaAttri: TmwHighLightAttributes read fPragmaAttri write fPragmaAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
    property VariableAttri: TmwHighLightAttributes read fVariableAttri write fVariableAttri;
//  property DefaultFilter;                                                     //mt 1999-1-2, //gp 1999-1-10 - removed
  end;

var
  DcjPerlLex: TDcjPerlSyn;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TDcjPerlSyn]);
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
    Case I in['%', '@', '$', '_', 'a'..'z', 'A'..'Z'] of
      True:
        begin
          if (I > #64) and (I < #91) then mHashTable[I] := Ord(I) - 64 else
            if (I > #96) then mHashTable[I] := Ord(I) - 95;
        end;
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TDcjPerlSyn.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 2167 do
    Case I of
      109: fIdentFuncTable[I] := Func109;
      113: fIdentFuncTable[I] := Func113;
      196: fIdentFuncTable[I] := Func196;
      201: fIdentFuncTable[I] := Func201;
      204: fIdentFuncTable[I] := Func204;
      207: fIdentFuncTable[I] := Func207;
      209: fIdentFuncTable[I] := Func209;
      211: fIdentFuncTable[I] := Func211;
      214: fIdentFuncTable[I] := Func214;
      216: fIdentFuncTable[I] := Func216;
      219: fIdentFuncTable[I] := Func219;
      221: fIdentFuncTable[I] := Func221;
      224: fIdentFuncTable[I] := Func224;
      225: fIdentFuncTable[I] := Func225;
      226: fIdentFuncTable[I] := Func226;
      230: fIdentFuncTable[I] := Func230;
      232: fIdentFuncTable[I] := Func232;
      233: fIdentFuncTable[I] := Func233;
      248: fIdentFuncTable[I] := Func248;
      254: fIdentFuncTable[I] := Func254;
      255: fIdentFuncTable[I] := Func255;
      257: fIdentFuncTable[I] := Func257;
      262: fIdentFuncTable[I] := Func262;
      263: fIdentFuncTable[I] := Func263;
      269: fIdentFuncTable[I] := Func269;
      280: fIdentFuncTable[I] := Func280;
      282: fIdentFuncTable[I] := Func282;
      306: fIdentFuncTable[I] := Func306;
      307: fIdentFuncTable[I] := Func307;
      310: fIdentFuncTable[I] := Func310;
      314: fIdentFuncTable[I] := Func314;
      317: fIdentFuncTable[I] := Func317;
      318: fIdentFuncTable[I] := Func318;
      320: fIdentFuncTable[I] := Func320;
      322: fIdentFuncTable[I] := Func322;
      325: fIdentFuncTable[I] := Func325;
      326: fIdentFuncTable[I] := Func326;
      327: fIdentFuncTable[I] := Func327;
      330: fIdentFuncTable[I] := Func330;
      331: fIdentFuncTable[I] := Func331;
      333: fIdentFuncTable[I] := Func333;
      335: fIdentFuncTable[I] := Func335;
      337: fIdentFuncTable[I] := Func337;
      338: fIdentFuncTable[I] := Func338;
      340: fIdentFuncTable[I] := Func340;
      345: fIdentFuncTable[I] := Func345;
      346: fIdentFuncTable[I] := Func346;
      368: fIdentFuncTable[I] := Func368;
      401: fIdentFuncTable[I] := Func401;
      412: fIdentFuncTable[I] := Func412;
      413: fIdentFuncTable[I] := Func413;
      415: fIdentFuncTable[I] := Func415;
      419: fIdentFuncTable[I] := Func419;
      420: fIdentFuncTable[I] := Func420;
      421: fIdentFuncTable[I] := Func421;
      424: fIdentFuncTable[I] := Func424;
      425: fIdentFuncTable[I] := Func425;
      426: fIdentFuncTable[I] := Func426;
      428: fIdentFuncTable[I] := Func428;
      430: fIdentFuncTable[I] := Func430;
      431: fIdentFuncTable[I] := Func431;
      432: fIdentFuncTable[I] := Func432;
      433: fIdentFuncTable[I] := Func433;
      434: fIdentFuncTable[I] := Func434;
      436: fIdentFuncTable[I] := Func436;
      437: fIdentFuncTable[I] := Func437;
      438: fIdentFuncTable[I] := Func438;
      439: fIdentFuncTable[I] := Func439;
      440: fIdentFuncTable[I] := Func440;
      441: fIdentFuncTable[I] := Func441;
      442: fIdentFuncTable[I] := Func442;
      444: fIdentFuncTable[I] := Func444;
      445: fIdentFuncTable[I] := Func445;
      447: fIdentFuncTable[I] := Func447;
      448: fIdentFuncTable[I] := Func448;
      456: fIdentFuncTable[I] := Func456;
      458: fIdentFuncTable[I] := Func458;
      470: fIdentFuncTable[I] := Func470;
      477: fIdentFuncTable[I] := Func477;
      502: fIdentFuncTable[I] := Func502;
      522: fIdentFuncTable[I] := Func522;
      523: fIdentFuncTable[I] := Func523;
      525: fIdentFuncTable[I] := Func525;
      527: fIdentFuncTable[I] := Func527;
      530: fIdentFuncTable[I] := Func530;
      531: fIdentFuncTable[I] := Func531;
      534: fIdentFuncTable[I] := Func534;
      535: fIdentFuncTable[I] := Func535;
      536: fIdentFuncTable[I] := Func536;
      537: fIdentFuncTable[I] := Func537;
      539: fIdentFuncTable[I] := Func539;
      542: fIdentFuncTable[I] := Func542;
      543: fIdentFuncTable[I] := Func543;
      545: fIdentFuncTable[I] := Func545;
      546: fIdentFuncTable[I] := Func546;
      547: fIdentFuncTable[I] := Func547;
      548: fIdentFuncTable[I] := Func548;
      549: fIdentFuncTable[I] := Func549;
      552: fIdentFuncTable[I] := Func552;
      555: fIdentFuncTable[I] := Func555;
      556: fIdentFuncTable[I] := Func556;
      557: fIdentFuncTable[I] := Func557;
      562: fIdentFuncTable[I] := Func562;
      569: fIdentFuncTable[I] := Func569;
      570: fIdentFuncTable[I] := Func570;
      622: fIdentFuncTable[I] := Func622;
      624: fIdentFuncTable[I] := Func624;
      627: fIdentFuncTable[I] := Func627;
      630: fIdentFuncTable[I] := Func630;
      632: fIdentFuncTable[I] := Func632;
      637: fIdentFuncTable[I] := Func637;
      640: fIdentFuncTable[I] := Func640;
      642: fIdentFuncTable[I] := Func642;
      643: fIdentFuncTable[I] := Func643;
      645: fIdentFuncTable[I] := Func645;
      647: fIdentFuncTable[I] := Func647;
      648: fIdentFuncTable[I] := Func648;
      649: fIdentFuncTable[I] := Func649;
      650: fIdentFuncTable[I] := Func650;
      651: fIdentFuncTable[I] := Func651;
      652: fIdentFuncTable[I] := Func652;
      655: fIdentFuncTable[I] := Func655;
      656: fIdentFuncTable[I] := Func656;
      657: fIdentFuncTable[I] := Func657;
      658: fIdentFuncTable[I] := Func658;
      665: fIdentFuncTable[I] := Func665;
      666: fIdentFuncTable[I] := Func666;
      667: fIdentFuncTable[I] := Func667;
      672: fIdentFuncTable[I] := Func672;
      675: fIdentFuncTable[I] := Func675;
      677: fIdentFuncTable[I] := Func677;
      687: fIdentFuncTable[I] := Func687;
      688: fIdentFuncTable[I] := Func688;
      716: fIdentFuncTable[I] := Func716;
      719: fIdentFuncTable[I] := Func719;
      727: fIdentFuncTable[I] := Func727;
      728: fIdentFuncTable[I] := Func728;
      731: fIdentFuncTable[I] := Func731;
      734: fIdentFuncTable[I] := Func734;
      740: fIdentFuncTable[I] := Func740;
      741: fIdentFuncTable[I] := Func741;
      743: fIdentFuncTable[I] := Func743;
      746: fIdentFuncTable[I] := Func746;
      749: fIdentFuncTable[I] := Func749;
      750: fIdentFuncTable[I] := Func750;
      752: fIdentFuncTable[I] := Func752;
      753: fIdentFuncTable[I] := Func753;
      754: fIdentFuncTable[I] := Func754;
      759: fIdentFuncTable[I] := Func759;
      761: fIdentFuncTable[I] := Func761;
      762: fIdentFuncTable[I] := Func762;
      763: fIdentFuncTable[I] := Func763;
      764: fIdentFuncTable[I] := Func764;
      765: fIdentFuncTable[I] := Func765;
      768: fIdentFuncTable[I] := Func768;
      769: fIdentFuncTable[I] := Func769;
      773: fIdentFuncTable[I] := Func773;
      774: fIdentFuncTable[I] := Func774;
      775: fIdentFuncTable[I] := Func775;
      815: fIdentFuncTable[I] := Func815;
      821: fIdentFuncTable[I] := Func821;
      841: fIdentFuncTable[I] := Func841;
      842: fIdentFuncTable[I] := Func842;
      845: fIdentFuncTable[I] := Func845;
      853: fIdentFuncTable[I] := Func853;
      855: fIdentFuncTable[I] := Func855;
      857: fIdentFuncTable[I] := Func857;
      860: fIdentFuncTable[I] := Func860;
      864: fIdentFuncTable[I] := Func864;
      867: fIdentFuncTable[I] := Func867;
      868: fIdentFuncTable[I] := Func868;
      869: fIdentFuncTable[I] := Func869;
      870: fIdentFuncTable[I] := Func870;
      873: fIdentFuncTable[I] := Func873;
      874: fIdentFuncTable[I] := Func874;
      876: fIdentFuncTable[I] := Func876;
      877: fIdentFuncTable[I] := Func877;
      878: fIdentFuncTable[I] := Func878;
      881: fIdentFuncTable[I] := Func881;
      883: fIdentFuncTable[I] := Func883;
      890: fIdentFuncTable[I] := Func890;
      892: fIdentFuncTable[I] := Func892;
      906: fIdentFuncTable[I] := Func906;
      933: fIdentFuncTable[I] := Func933;
      954: fIdentFuncTable[I] := Func954;
      956: fIdentFuncTable[I] := Func956;
      965: fIdentFuncTable[I] := Func965;
      968: fIdentFuncTable[I] := Func968;
      974: fIdentFuncTable[I] := Func974;
      978: fIdentFuncTable[I] := Func978;
      981: fIdentFuncTable[I] := Func981;
      985: fIdentFuncTable[I] := Func985;
      986: fIdentFuncTable[I] := Func986;
      988: fIdentFuncTable[I] := Func988;
      1056: fIdentFuncTable[I] := Func1056;
      1077: fIdentFuncTable[I] := Func1077;
      1079: fIdentFuncTable[I] := Func1079;
      1084: fIdentFuncTable[I] := Func1084;
      1086: fIdentFuncTable[I] := Func1086;
      1091: fIdentFuncTable[I] := Func1091;
      1093: fIdentFuncTable[I] := Func1093;
      1095: fIdentFuncTable[I] := Func1095;
      1103: fIdentFuncTable[I] := Func1103;
      1105: fIdentFuncTable[I] := Func1105;
      1107: fIdentFuncTable[I] := Func1107;
      1136: fIdentFuncTable[I] := Func1136;
      1158: fIdentFuncTable[I] := Func1158;
      1165: fIdentFuncTable[I] := Func1165;
      1169: fIdentFuncTable[I] := Func1169;
      1172: fIdentFuncTable[I] := Func1172;
      1176: fIdentFuncTable[I] := Func1176;
      1202: fIdentFuncTable[I] := Func1202;
      1211: fIdentFuncTable[I] := Func1211;
      1215: fIdentFuncTable[I] := Func1215;
      1218: fIdentFuncTable[I] := Func1218;
      1223: fIdentFuncTable[I] := Func1223;
      1230: fIdentFuncTable[I] := Func1230;
      1273: fIdentFuncTable[I] := Func1273;
      1277: fIdentFuncTable[I] := Func1277;
      1283: fIdentFuncTable[I] := Func1283;
      1327: fIdentFuncTable[I] := Func1327;
      1343: fIdentFuncTable[I] := Func1343;
      1361: fIdentFuncTable[I] := Func1361;
      1379: fIdentFuncTable[I] := Func1379;
      1396: fIdentFuncTable[I] := Func1396;
      1402: fIdentFuncTable[I] := Func1402;
      1404: fIdentFuncTable[I] := Func1404;
      1409: fIdentFuncTable[I] := Func1409;
      1421: fIdentFuncTable[I] := Func1421;
      1425: fIdentFuncTable[I] := Func1425;
      1440: fIdentFuncTable[I] := Func1440;
      1520: fIdentFuncTable[I] := Func1520;
      1523: fIdentFuncTable[I] := Func1523;
      1673: fIdentFuncTable[I] := Func1673;
      1752: fIdentFuncTable[I] := Func1752;
      1762: fIdentFuncTable[I] := Func1762;
      1768: fIdentFuncTable[I] := Func1768;
      2167: fIdentFuncTable[I] := Func2167;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TDcjPerlSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['%', '@', '$', '_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, Integer(ToHash^));
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TDcjPerlSyn.KeyComp(const aKey: String): Boolean;                      //mh 1999-08-22
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

function TDcjPerlSyn.Func109: TtkTokenKind;
begin
  if KeyComp('m') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func113: TtkTokenKind;
begin
  if KeyComp('q') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func196: TtkTokenKind;
begin
  if KeyComp('$NR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func201: TtkTokenKind;
begin
  if KeyComp('$RS') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func204: TtkTokenKind;
begin
  if KeyComp('ge') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func207: TtkTokenKind;
begin
  if KeyComp('lc') then Result := tkKey else
    if KeyComp('if') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func209: TtkTokenKind;
begin
  if KeyComp('le') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func211: TtkTokenKind;
begin
  if KeyComp('ne') then Result := tkOperator else
    if KeyComp('do') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func214: TtkTokenKind;
begin
  if KeyComp('eq') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func216: TtkTokenKind;
begin
  if KeyComp('uc') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func219: TtkTokenKind;
begin
  if KeyComp('gt') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func221: TtkTokenKind;
begin
  if KeyComp('no') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func224: TtkTokenKind;
begin
  if KeyComp('lt') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func225: TtkTokenKind;
begin
  if KeyComp('or') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func226: TtkTokenKind;
begin
  if KeyComp('qq') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func230: TtkTokenKind;
begin
  if KeyComp('tr') then Result := tkKey else
    if KeyComp('my') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func232: TtkTokenKind;
begin
  if KeyComp('qw') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func233: TtkTokenKind;
begin
  if KeyComp('qx') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func248: TtkTokenKind;
begin
  if KeyComp('$GID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func254: TtkTokenKind;
begin
  if KeyComp('$ARG') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func255: TtkTokenKind;
begin
  if KeyComp('%INC') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func257: TtkTokenKind;
begin
  if KeyComp('$PID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func262: TtkTokenKind;
begin
  if KeyComp('$UID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func263: TtkTokenKind;
begin
  if KeyComp('$SIG') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func269: TtkTokenKind;
begin
  if KeyComp('$ENV') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func280: TtkTokenKind;
begin
  if KeyComp('$ORS') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func282: TtkTokenKind;
begin
  if KeyComp('@INC') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func306: TtkTokenKind;
begin
  if KeyComp('die') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func307: TtkTokenKind;
begin
  if KeyComp('and') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func310: TtkTokenKind;
begin
  if KeyComp('abs') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func314: TtkTokenKind;
begin
  if KeyComp('eof') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func317: TtkTokenKind;
begin
  if KeyComp('ref') then Result := tkKey else
    if KeyComp('chr') then Result := tkKey else
      if KeyComp('$EGID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func318: TtkTokenKind;
begin
  if KeyComp('vec') then Result := tkKey else
    if KeyComp('map') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func320: TtkTokenKind;
begin
  if KeyComp('cmp') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func322: TtkTokenKind;
begin
  if KeyComp('tie') then Result := tkKey else
    if KeyComp('log') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func325: TtkTokenKind;
begin
  if KeyComp('hex') then Result := tkKey else
    if KeyComp('ord') then Result := tkKey else
      if KeyComp('cos') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func326: TtkTokenKind;
begin
  if KeyComp('oct') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func327: TtkTokenKind;
begin
  if KeyComp('for') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func330: TtkTokenKind;
begin
  if KeyComp('sin') then Result := tkKey else
    if KeyComp('sub') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func331: TtkTokenKind;
begin
  if KeyComp('$EUID') then Result := tkVariable else
    if KeyComp('int') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func333: TtkTokenKind;
begin
  if KeyComp('use') then Result := tkKey else
    if KeyComp('exp') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func335: TtkTokenKind;
begin
  if KeyComp('pop') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func337: TtkTokenKind;
begin
  if KeyComp('not') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func338: TtkTokenKind;
begin
  if KeyComp('pos') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func340: TtkTokenKind;
begin
  if KeyComp('$ARGV') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func345: TtkTokenKind;
begin
  if KeyComp('xor') then Result := tkOperator else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func346: TtkTokenKind;
begin
  if KeyComp('$OFMT') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func368: TtkTokenKind;
begin
  if KeyComp('@ARGV') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func401: TtkTokenKind;
begin
  if KeyComp('$MATCH') then Result := tkVariable else
    if KeyComp('each') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func412: TtkTokenKind;
begin
  if KeyComp('read') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func413: TtkTokenKind;
begin
  if KeyComp('bind') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func415: TtkTokenKind;
begin
  if KeyComp('pack') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func419: TtkTokenKind;
begin
  if KeyComp('getc') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func420: TtkTokenKind;
begin
  if KeyComp('glob') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func421: TtkTokenKind;
begin
  if KeyComp('exec') then Result := tkKey else
    if KeyComp('rand') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func424: TtkTokenKind;
begin
  if KeyComp('seek') then Result := tkKey else
    if KeyComp('eval') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func425: TtkTokenKind;
begin
  if KeyComp('else') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func426: TtkTokenKind;
begin
  if KeyComp('chop') then Result := tkKey else
    if KeyComp('redo') then Result := tkKey else
      if KeyComp('send') then Result := tkKey else
        if KeyComp('$ERRNO') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func428: TtkTokenKind;
begin
  if KeyComp('kill') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func430: TtkTokenKind;
begin
  if KeyComp('grep') then Result := tkKey else
    if KeyComp('pipe') then Result := tkKey else
      if KeyComp('link') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func431: TtkTokenKind;
begin
  if KeyComp('time') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func432: TtkTokenKind;
begin
  if KeyComp('recv') then Result := tkKey else
    if KeyComp('join') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func433: TtkTokenKind;
begin
  if KeyComp('tell') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func434: TtkTokenKind;
begin
  if KeyComp('open') then Result := tkKey else
    if KeyComp('fork') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func436: TtkTokenKind;
begin
  if KeyComp('last') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func437: TtkTokenKind;
begin
  if KeyComp('wait') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func438: TtkTokenKind;
begin
  if KeyComp('dump') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func439: TtkTokenKind;
begin
  if KeyComp('less') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func440: TtkTokenKind;
begin
  if KeyComp('warn') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func441: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func442: TtkTokenKind;
begin
  if KeyComp('exit') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func444: TtkTokenKind;
begin
  if KeyComp('vars') then Result := tkPragma else
    if KeyComp('keys') then Result := tkKey else
      if KeyComp('stat') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func445: TtkTokenKind;
begin
  if KeyComp('subs') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func447: TtkTokenKind;
begin
  if KeyComp('next') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func448: TtkTokenKind;
begin
  if KeyComp('push') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func456: TtkTokenKind;
begin
  if KeyComp('sort') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func458: TtkTokenKind;
begin
  if KeyComp('sqrt') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func470: TtkTokenKind;
begin
  if KeyComp('atan2') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func477: TtkTokenKind;
begin
  if KeyComp('$PERLDB') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func502: TtkTokenKind;
begin
  if KeyComp('$SUBSEP') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func522: TtkTokenKind;
begin
  if KeyComp('chdir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func523: TtkTokenKind;
begin
  if KeyComp('local') then Result := tkKey else
    if KeyComp('chmod') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func525: TtkTokenKind;
begin
  if KeyComp('alarm') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func527: TtkTokenKind;
begin
  if KeyComp('flock') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func530: TtkTokenKind;
begin
  if KeyComp('undef') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func531: TtkTokenKind;
begin
  if KeyComp('elsif') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func534: TtkTokenKind;
begin
  if KeyComp('close') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func535: TtkTokenKind;
begin
  if KeyComp('mkdir') then Result := tkKey else
    if KeyComp('fcntl') then Result := tkKey else
      if KeyComp('chomp') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func536: TtkTokenKind;
begin
  if KeyComp('index') then Result := tkKey else
    if KeyComp('srand') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func537: TtkTokenKind;
begin
  if KeyComp('sleep') then Result := tkKey else
    if KeyComp('while') then Result := tkKey else
      if KeyComp('bless') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func539: TtkTokenKind;
begin
  if KeyComp('ioctl') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func542: TtkTokenKind;
begin
  if KeyComp('shift') then Result := tkKey else
    if KeyComp('rmdir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func543: TtkTokenKind;
begin
  if KeyComp('chown') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func545: TtkTokenKind;
begin
  if KeyComp('umask') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func546: TtkTokenKind;
begin
  if KeyComp('times') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func547: TtkTokenKind;
begin
  if KeyComp('reset') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func548: TtkTokenKind;
begin
  if KeyComp('semop') then Result := tkKey else
    if KeyComp('utime') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func549: TtkTokenKind;
begin
  if KeyComp('untie') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func552: TtkTokenKind;
begin
  if KeyComp('lstat') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func555: TtkTokenKind;
begin
  if KeyComp('write') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func556: TtkTokenKind;
begin
  if KeyComp('split') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func557: TtkTokenKind;
begin
  if KeyComp('print') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func562: TtkTokenKind;
begin
  if KeyComp('crypt') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func569: TtkTokenKind;
begin
  if KeyComp('study') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func570: TtkTokenKind;
begin
  if KeyComp('$WARNING') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func622: TtkTokenKind;
begin
  if KeyComp('$BASETIME') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func624: TtkTokenKind;
begin
  if KeyComp('locale') then Result := tkPragma else
    if KeyComp('accept') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func627: TtkTokenKind;
begin
  if KeyComp('caller') then Result := tkKey else
    if KeyComp('delete') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func630: TtkTokenKind;
begin
  if KeyComp('scalar') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func632: TtkTokenKind;
begin
  if KeyComp('rename') then Result := tkKey else
    if KeyComp('$PREMATCH') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func637: TtkTokenKind;
begin
  if KeyComp('fileno') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func640: TtkTokenKind;
begin
  if KeyComp('splice') then Result := tkKey else
    if KeyComp('select') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func642: TtkTokenKind;
begin
  if KeyComp('length') then Result := tkKey else
    if KeyComp('unpack') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func643: TtkTokenKind;
begin
  if KeyComp('gmtime') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func645: TtkTokenKind;
begin
  if KeyComp('semget') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func647: TtkTokenKind;
begin
  if KeyComp('msgget') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func648: TtkTokenKind;
begin
  if KeyComp('shmget') then Result := tkKey else
    if KeyComp('semctl') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func649: TtkTokenKind;
begin
  if KeyComp('socket') then Result := tkKey else
    if KeyComp('format') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func650: TtkTokenKind;
begin
  if KeyComp('rindex') then Result := tkKey else
    if KeyComp('msgctl') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func651: TtkTokenKind;
begin
  if KeyComp('shmctl') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func652: TtkTokenKind;
begin
  if KeyComp('msgsnd') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func655: TtkTokenKind;
begin
  if KeyComp('listen') then Result := tkKey else
    if KeyComp('chroot') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func656: TtkTokenKind;
begin
  if KeyComp('values') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func657: TtkTokenKind;
begin
  if KeyComp('unlink') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func658: TtkTokenKind;
begin
  if KeyComp('msgrcv') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func665: TtkTokenKind;
begin
  if KeyComp('strict') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func666: TtkTokenKind;
begin
  if KeyComp('unless') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func667: TtkTokenKind;
begin
  if KeyComp('import') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func672: TtkTokenKind;
begin
  if KeyComp('return') then Result := tkKey else
    if KeyComp('exists') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func675: TtkTokenKind;
begin
  if KeyComp('substr') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func677: TtkTokenKind;
begin
  if KeyComp('system') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func687: TtkTokenKind;
begin
  if KeyComp('$OS_ERROR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func688: TtkTokenKind;
begin
  if KeyComp('$DEBUGGING') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func716: TtkTokenKind;
begin
  if KeyComp('package') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func719: TtkTokenKind;
begin
  if KeyComp('defined') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func727: TtkTokenKind;
begin
  if KeyComp('$POSTMATCH') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func728: TtkTokenKind;
begin
  if KeyComp('foreach') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func731: TtkTokenKind;
begin
  if KeyComp('readdir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func734: TtkTokenKind;
begin
  if KeyComp('binmode') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func740: TtkTokenKind;
begin
  if KeyComp('shmread') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func741: TtkTokenKind;
begin
  if KeyComp('dbmopen') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func743: TtkTokenKind;
begin
  if KeyComp('seekdir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func746: TtkTokenKind;
begin
  if KeyComp('connect') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func749: TtkTokenKind;
begin
  if KeyComp('getppid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func750: TtkTokenKind;
begin
  if KeyComp('integer') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func752: TtkTokenKind;
begin
  if KeyComp('telldir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func753: TtkTokenKind;
begin
  if KeyComp('opendir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func754: TtkTokenKind;
begin
  if KeyComp('waitpid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func759: TtkTokenKind;
begin
  if KeyComp('lcfirst') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func761: TtkTokenKind;
begin
  if KeyComp('getpgrp') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func762: TtkTokenKind;
begin
  if KeyComp('sigtrap') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func763: TtkTokenKind;
begin
  if KeyComp('sysread') then Result := tkKey else
    if KeyComp('syscall') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func764: TtkTokenKind;
begin
  if KeyComp('reverse') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func765: TtkTokenKind;
begin
  if KeyComp('require') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func768: TtkTokenKind;
begin
  if KeyComp('ucfirst') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func769: TtkTokenKind;
begin
  if KeyComp('unshift') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func773: TtkTokenKind;
begin
  if KeyComp('setpgrp') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func774: TtkTokenKind;
begin
  if KeyComp('sprintf') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func775: TtkTokenKind;
begin
  if KeyComp('symlink') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func815: TtkTokenKind;
begin
  if KeyComp('$PROCESS_ID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func821: TtkTokenKind;
begin
  if KeyComp('$EVAL_ERROR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func841: TtkTokenKind;
begin
  if KeyComp('dbmclose') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func842: TtkTokenKind;
begin
  if KeyComp('readlink') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func845: TtkTokenKind;
begin
  if KeyComp('getgrgid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func853: TtkTokenKind;
begin
  if KeyComp('getgrnam') then Result := tkKey else
    if KeyComp('closedir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func855: TtkTokenKind;
begin
  if KeyComp('endgrent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func857: TtkTokenKind;
begin
  if KeyComp('getlogin') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func860: TtkTokenKind;
begin
  if KeyComp('formline') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func864: TtkTokenKind;
begin
  if KeyComp('getgrent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func867: TtkTokenKind;
begin
  if KeyComp('getpwnam') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func868: TtkTokenKind;
begin
  if KeyComp('$ACCUMULATOR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func869: TtkTokenKind;
begin
  if KeyComp('endpwent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func870: TtkTokenKind;
begin
  if KeyComp('truncate') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func873: TtkTokenKind;
begin
  if KeyComp('getpwuid') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func874: TtkTokenKind;
begin
  if KeyComp('constant') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func876: TtkTokenKind;
begin
  if KeyComp('setgrent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func877: TtkTokenKind;
begin
  if KeyComp('$FORMAT_NAME') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func878: TtkTokenKind;
begin
  if KeyComp('getpwent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func881: TtkTokenKind;
begin
  if KeyComp('$CHILD_ERROR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func883: TtkTokenKind;
begin
  if KeyComp('shmwrite') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func890: TtkTokenKind;
begin
  if KeyComp('setpwent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func892: TtkTokenKind;
begin
  if KeyComp('shutdown') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func906: TtkTokenKind;
begin
  if KeyComp('syswrite') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func933: TtkTokenKind;
begin
  if KeyComp('$INPLACE_EDIT') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func954: TtkTokenKind;
begin
  if KeyComp('localtime') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func956: TtkTokenKind;
begin
  if KeyComp('$PROGRAM_NAME') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func965: TtkTokenKind;
begin
  if KeyComp('endnetent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func968: TtkTokenKind;
begin
  if KeyComp('rewinddir') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func974: TtkTokenKind;
begin
  if KeyComp('getnetent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func978: TtkTokenKind;
begin
  if KeyComp('$REAL_USER_ID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func981: TtkTokenKind;
begin
  if KeyComp('quotemeta') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func985: TtkTokenKind;
begin
  if KeyComp('wantarray') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func986: TtkTokenKind;
begin
  if KeyComp('setnetent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func988: TtkTokenKind;
begin
  if KeyComp('$PERL_VERSION') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1056: TtkTokenKind;
begin
  if KeyComp('$REAL_GROUP_ID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1077: TtkTokenKind;
begin
  if KeyComp('socketpair') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1079: TtkTokenKind;
begin
  if KeyComp('$SYSTEM_FD_MAX') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1084: TtkTokenKind;
begin
  if KeyComp('endhostent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1086: TtkTokenKind;
begin
  if KeyComp('endservent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1091: TtkTokenKind;
begin
  if KeyComp('getsockopt') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1093: TtkTokenKind;
begin
  if KeyComp('gethostent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1095: TtkTokenKind;
begin
  if KeyComp('getservent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1103: TtkTokenKind;
begin
  if KeyComp('setsockopt') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1105: TtkTokenKind;
begin
  if KeyComp('sethostent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1107: TtkTokenKind;
begin
  if KeyComp('setservent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1136: TtkTokenKind;
begin
  if KeyComp('$LIST_SEPARATOR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1158: TtkTokenKind;
begin
  if KeyComp('$EXECUTABLE_NAME') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1165: TtkTokenKind;
begin
  if KeyComp('getpeername') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1169: TtkTokenKind;
begin
  if KeyComp('getsockname') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1172: TtkTokenKind;
begin
  if KeyComp('$FORMAT_FORMFEED') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1176: TtkTokenKind;
begin
  if KeyComp('diagnostics') then Result := tkPragma else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1202: TtkTokenKind;
begin
  if KeyComp('endprotoent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1211: TtkTokenKind;
begin
  if KeyComp('getprotoent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1215: TtkTokenKind;
begin
  if KeyComp('$FORMAT_TOP_NAME') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1218: TtkTokenKind;
begin
  if KeyComp('getpriority') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1223: TtkTokenKind;
begin
  if KeyComp('setprotoent') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1230: TtkTokenKind;
begin
  if KeyComp('setpriority') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1273: TtkTokenKind;
begin
  if KeyComp('$LAST_PAREN_MATCH') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1277: TtkTokenKind;
begin
  if KeyComp('getnetbyaddr') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1283: TtkTokenKind;
begin
  if KeyComp('getnetbyname') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1327: TtkTokenKind;
begin
  if KeyComp('$OUTPUT_AUTOFLUSH') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1343: TtkTokenKind;
begin
  if KeyComp('$EFFECTIVE_USER_ID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1361: TtkTokenKind;
begin
  if KeyComp('$FORMAT_LINES_LEFT') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1379: TtkTokenKind;
begin
  if KeyComp('$INPUT_LINE_NUMBER') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1396: TtkTokenKind;
begin
  if KeyComp('gethostbyaddr') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1402: TtkTokenKind;
begin
  if KeyComp('gethostbyname') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1404: TtkTokenKind;
begin
  if KeyComp('getservbyname') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1409: TtkTokenKind;
begin
  if KeyComp('$MULTILINE_MATCHING') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1421: TtkTokenKind;
begin
  if KeyComp('$EFFECTIVE_GROUP_ID') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1425: TtkTokenKind;
begin
  if KeyComp('$FORMAT_PAGE_NUMBER') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1440: TtkTokenKind;
begin
  if KeyComp('getservbyport') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1520: TtkTokenKind;
begin
  if KeyComp('getprotobyname') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1523: TtkTokenKind;
begin
  if KeyComp('$SUBSCRIPT_SEPARATOR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1673: TtkTokenKind;
begin
  if KeyComp('$FORMAT_LINES_PER_PAGE') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1752: TtkTokenKind;
begin
  if KeyComp('getprotobynumber') then Result := tkKey else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1762: TtkTokenKind;
begin
  if KeyComp('$INPUT_RECORD_SEPARATOR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func1768: TtkTokenKind;
begin
  if KeyComp('$OUTPUT_FIELD_SEPARATOR') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.Func2167: TtkTokenKind;
begin
  if KeyComp('$FORMAT_LINE_BREAK_CHARACTERS') then Result := tkVariable else Result := tkIdentifier;
end;

function TDcjPerlSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TDcjPerlSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 2168 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TDcjPerlSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '&': fProcTable[I] := AndSymbolProc;
      '\': fProcTable[I] := BackslashProc;
      '}': fProcTable[I] := BraceCloseProc;
      '{': fProcTable[I] := BraceOpenProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := ColonProc;
      ',': fProcTable[I] := CommaProc;
      '#': fProcTable[I] := CommentProc;
      '=': fProcTable[I] := EqualProc;
      '>': fProcTable[I] := GreaterProc;
      '%', '@', '$', 'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      '<': fProcTable[I] := LowerProc;
      '-': fProcTable[I] := MinusProc;
      '!': fProcTable[I] := NotSymbolProc;
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
      '~': fProcTable[I] := TildeProc;
      '^': fProcTable[I] := XOrSymbolProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TDcjPerlSyn.Create(AOwner: TComponent);
begin
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri.Style:= [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fInvalidAttri := TmwHighLightAttributes.Create(MWS_AttrIllegalChar);          //mt 1999-1-2
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style:= [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fOperatorAttri := TmwHighLightAttributes.Create(MWS_AttrOperator);            //gp 1998-12-24
  fPragmaAttri := TmwHighLightAttributes.Create(MWS_AttrPragma);                //gp 1998-12-24
  fPragmaAttri.Style := [fsBold];
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fSpaceAttri.Foreground := clWindow;
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  fVariableAttri := TmwHighLightAttributes.Create(MWS_AttrVariable);            //gp 1998-12-24
  fVariableAttri.Style := [fsBold];

  inherited Create(AOwner);
{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fInvalidAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fOperatorAttri);
  AddAttribute(fPragmaAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
  AddAttribute(fVariableAttri);
//  SetHighlightChange;                                                           //gp 1998-12-22
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22
  InitIdent;
  MakeMethodTables;
  fRange := rsUnknown;
  fDefaultFilter := MWS_FilterPerl;                                             //ajb 1999-09-14
end; { Create }

{begin}                                                                         //mh 1999-08-22
(*
destructor TDcjPerlSyn.Destroy;
begin
  fCommentAttri.Free;
  fIdentifierAttri.Free;
  fInvalidAttri.Free;                                                           //mt 1999-1-2
  fKeyAttri.Free;
  fNumberAttri.Free;
  fOperatorAttri.Free;
  fPragmaAttri.Free;
  fSpaceAttri.Free;
  fStringAttri.Free;
  fSymbolAttri.Free;
  fVariableAttri.Free;
  inherited Destroy;
end; { Destroy }
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
procedure TDcjPerlSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TDcjPerlSyn.SetLine(NewValue: String; LineNumber:Integer);            //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-08-22
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TDcjPerlSyn.AndSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {bit and assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '&':
      begin
        if FLine[Run + 2] = '=' then   {logical and assign}
          inc(Run, 3)
        else                           {logical and}
          inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {bit and}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.BackslashProc;
begin
  fTokenID := tkSymbol;                {reference}
  inc(Run);
end;

procedure TDcjPerlSyn.BraceCloseProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TDcjPerlSyn.BraceOpenProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TDcjPerlSyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TDcjPerlSyn.ColonProc;
begin
  Case FLine[Run + 1] of
    ':':                               {double colon}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {colon}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.CommaProc;
begin
  inc(Run);
  fTokenID := tkSymbol;                {comma}
end;

procedure TDcjPerlSyn.CommentProc;
begin
  fTokenID := tkComment;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #0;
end;

procedure TDcjPerlSyn.EqualProc;
begin
  case FLine[Run + 1] of
    '=':                               {logical equal}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '>':                               {digraph}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '~':                               {bind scalar to pattern}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {assign}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.GreaterProc;
begin
  Case FLine[Run + 1] of
    '=':                               {greater than or equal to}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '>':
      begin
        if FLine[Run + 2] = '=' then   {shift right assign}
          inc(Run, 3)
        else                           {shift right}
          inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {greater than}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.IdentProc;
begin
  Case FLine[Run] of
    '$':
      begin
        Case FLine[Run + 1] of
          '!'..'+', '-'..'@', '['..']', '_', '`', '|', '~':
            begin                      {predefined variables}
              inc(Run, 2);
              fTokenID := tkVariable;
              exit;
            end;
          '^':
            begin
              Case FLine[Run + 2] of
                'A', 'D', 'F', 'I', 'L', 'P', 'T', 'W', 'X':
                  begin                {predefined variables}
                    inc(Run, 3);
                    fTokenID := tkVariable;
                    exit;
                  end;
                #0, #10, #13:          {predefined variables}
                  begin
                    inc(Run, 2);
                    fTokenID := tkVariable;
                    exit;
                  end;
              end;
            end;
        end;
      end;
    '%':
      begin
        Case FLine[Run + 1] of
          '=':                         {mod assign}
            begin
              inc(Run, 2);
              fTokenID := tkSymbol;
              exit;
            end;
          #0, #10, #13:                {mod}
            begin
              inc(Run);
              fTokenID := tkSymbol;
              exit;
            end;
        end;
      end;
    'x':
      begin
        Case FLine[Run + 1] of
          '=':                         {repetition assign}
            begin
              inc(Run, 2);
              fTokenID := tkSymbol;
              exit;
            end;
          #0, #10, #13:                {repetition}
            begin
              inc(Run);
              fTokenID := tkSymbol;
              exit;
            end;
        end;
      end;
  end;
  {regular identifier}
  fTokenID := IdentKind((fLine + Run));
  inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TDcjPerlSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TDcjPerlSyn.LowerProc;
begin
  case FLine[Run + 1] of
    '=':
      begin
        if FLine[Run + 2] = '>' then   {compare - less than, equal, greater}
          inc(Run, 3)
        else                           {less than or equal to}
          inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '<':
      begin
        if FLine[Run + 2] = '=' then   {shift left assign}
          inc(Run, 3)
        else                           {shift left}
          inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {less than}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.MinusProc;
begin
  case FLine[Run + 1] of
    '=':                               {subtract assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '-':                               {decrement}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '>':                               {arrow}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {subtract}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.NotSymbolProc;
begin
  case FLine[Run + 1] of
    '~':                               {logical negated bind like =~}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '=':                               {not equal}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {not}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.NullProc;
begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-08-22
end;

procedure TDcjPerlSyn.NumberProc;
begin
  if FLine[Run] = '.' then
  begin
    case FLine[Run + 1] of
      '.':
        begin
          inc(Run, 2);
          if FLine[Run] = '.' then     {sed range}
            inc(Run);

          fTokenID := tkSymbol;        {range}
          exit;
        end;
      '=':
        begin
          inc(Run, 2);
          fTokenID := tkSymbol;        {concatenation assign}
          exit;
        end;
      'a'..'z', 'A'..'Z', '_':
        begin
          fTokenID := tkSymbol;        {concatenation}
          inc(Run);
          exit;
        end;
    end;
  end;
  inc(Run);
  fTokenID := tkNumber;
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

procedure TDcjPerlSyn.OrSymbolProc;
begin
  case FLine[Run + 1] of
    '=':                               {bit or assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '|':
      begin
        if FLine[Run + 2] = '=' then   {logical or assign}
          inc(Run, 3)
        else                           {logical or}
          inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {bit or}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.PlusProc;
begin
  case FLine[Run + 1] of
    '=':                               {add assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '+':                               {increment}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {add}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.QuestionProc;
begin
  fTokenID := tkSymbol;                {conditional op}
  inc(Run);
end;

procedure TDcjPerlSyn.RoundCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  dec(FRoundCount);
end;

procedure TDcjPerlSyn.RoundOpenProc;
begin
  inc(Run);
  FTokenID := tkSymbol;
  inc(FRoundCount);
end;

procedure TDcjPerlSyn.SemiColonProc;
begin
  inc(Run);
  fTokenID := tkSymbol;                {semicolon}
end;

procedure TDcjPerlSyn.SlashProc;
begin
  case FLine[Run + 1] of
    '=':                               {division assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {division}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TDcjPerlSyn.SquareCloseProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  dec(FSquareCount);
end;

procedure TDcjPerlSyn.SquareOpenProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
  inc(FSquareCount);
end;

procedure TDcjPerlSyn.StarProc;
begin
  case FLine[Run + 1] of
    '=':                               {multiply assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
    '*':                               
      begin
        if FLine[Run + 2] = '=' then   {exponentiation assign}
          inc(Run, 3)
        else                           {exponentiation}
          inc(Run, 2);
        fTokenID := tkSymbol;        
      end;
  else                                 {multiply}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.StringInterpProc;
begin
  fTokenID := tkString;
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

procedure TDcjPerlSyn.StringLiteralProc;
begin
  fTokenID := tkString;
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TDcjPerlSyn.TildeProc;
begin
  inc(Run);
  fTokenId := tkSymbol;
end;

procedure TDcjPerlSyn.XOrSymbolProc;
begin
  Case FLine[Run + 1] of
    '=':                               {xor assign}
      begin
        inc(Run, 2);
        fTokenID := tkSymbol;
      end;
  else                                 {xor}
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TDcjPerlSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TDcjPerlSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //aj 1999-02-22
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
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
      tkOperator:
        with fCanvas do
        begin
          Brush.Color:= fOperatorAttri.Background;
          Font.Color:=  fOperatorAttri.Foreground;
          Font.Style:=  fOperatorAttri.Style;
        end;
      tkPragma:
        with fCanvas do
        begin
          Brush.Color:= fPragmaAttri.Background;
          Font.Color:=  fPragmaAttri.Foreground;
          Font.Style:=  fPragmaAttri.Style;
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
          Brush.Color:= fInvalidAttri.Background;                               //mt 1999-1-2
          Font.Color:=  fInvalidAttri.Foreground;                               //mt 1999-1-2
          Font.Style:=  fInvalidAttri.Style;                                    //mt 1999-1-2
        end;
      tkVariable:
        with fCanvas do
        begin
          Brush.Color:= fVariableAttri.Background;
          Font.Color:=  fVariableAttri.Foreground;
          Font.Style:=  fVariableAttri.Style;
        end;
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-27 //mh 1999-08-22
  end;
*)
end;

function TDcjPerlSyn.GetEol: Boolean;
begin
  Result := fTokenID = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TDcjPerlSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TDcjPerlSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TDcjPerlSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TDcjPerlSyn.GetTokenAttribute: TmwHighLightAttributes;                 //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkOperator: Result := fOperatorAttri;
    tkPragma: Result := fPragmaAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fInvalidAttri;
    tkVariable: Result := fVariableAttri;
    else Result := nil;
  end;
end;

function TDcjPerlSyn.GetTokenKind: integer;                                     //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TDcjPerlSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TDcjPerlSyn.ReSetRange;
begin
  fRange:= rsUnknown;
end;

procedure TDcjPerlSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                          //gp 12/22/1998
// default handling is done in ancestor class
//procedure TDcjPerlSyn.EnumUserSettings(settings: TStrings);
//begin
//  { not supported }
//end;

//function TDcjPerlSyn.UseUserSettings(settingIndex: integer): boolean;
//begin
//  { not supported }
//  Result := false;
//end;
{end}                                                            //gp 12/22/1998

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                          //gp 12/22/1998
procedure TDcjPerlSyn.HighLightChange(Sender:TObject);
begin
{begin}                                                          //gp 12/22/1998
//  if Assigned(mwEdit) then {mwEdit is in TmwCustomHighLighter}
//    mwEdit.Invalidate;
  mwEditList.Invalidate;
{end}                                                            //gp 12/22/1998
end;

procedure TDcjPerlSyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fInvalidAttri.Onchange:= HighLightChange;                                     //mt 1999-1-2
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
  fOperatorAttri.Onchange:= HighLightChange;
  fPragmaAttri.Onchange:= HighLightChange;
  fVariableAttri.Onchange:= HighLightChange;
end;
{end}                                                            //gp 12/22/1998

{begin}                                                                         //gp 1998-12-24
function TDcjPerlSyn.GetAttribCount: integer;
begin
  Result := 11;
end;

function TDcjPerlSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fInvalidAttri;                                                 //mt 1999-1-2
    3: Result := fNumberAttri;
    4: Result := fOperatorAttri;
    5: Result := fPragmaAttri;
    6: Result := fKeyAttri;
    7: Result := fSpaceAttri;
    8: Result := fStringAttri;
    9: Result := fSymbolAttri;
    10: Result := fVariableAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TDcjPerlSyn.GetIdentChars: TIdentChars;
begin
  Result := ['%', '@', '$', '_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TDcjPerlSyn.GetLanguageName: string;                                   //mt 1999-1-2
begin
  Result := MWS_LangPerl;                                                       //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

//function TDcjPerlSyn.GetDefaultFilter: string;                                //mt 1999-1-2, //gp 1999-1-10 - removed
//begin
//  Result := fDefaultFilter;
//end;

//procedure TDcjPerlSyn.SetDefaultFilter(Value: string);                        //mt 1999-1-2, //gp 1999-1-10 - removed
//begin
//  if fDefaultFilter <> Value then fDefaultFilter := Value;
//end;

Initialization
  MakeIdentTable;
end.
