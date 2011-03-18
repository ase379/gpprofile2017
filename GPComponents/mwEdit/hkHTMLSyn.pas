Unit hkHTMLSyn;
{+--------------------------------------------------------------------------+
 | Unit:        hkHTMLSyn
 | Created:     03.99
 | Last change: 1999-09-24
 | Author:      Hideo Koiso (sprhythm@fureai.or.jp)
 | Copyright    1999, No rights reserved.
 | Description: A HTML HighLighter for Use with mwCustomEdit.
 | Version:     0.23 (for version history see version.rtf)
 | Status       Public Domain
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 |
 | Thanks to:   Primoz Gabrijelcic, Michael Hieke, Sebastien J. GROSS,
 |              Tony de Buys
 +--------------------------------------------------------------------------+}
{$I MWEDIT.INC}
Interface


Uses
  SysUtils,
  Windows,
  Messages,
  Classes,
  Controls,
  Graphics,
  Registry,
  mwHighlighter,
  mwExport,
  mwLocalStr;                                                                   //mh 1999-08-22


Var
  mHashTable:  Array[#0..#255] Of Integer;


{start}                                                                         //sjg 1999-06-22
Const
  MAX_ESCAPEAMPS = 151;

  EscapeAmps: Array[0..MAX_ESCAPEAMPS-1] Of PChar = (
    ('&amp;'),               {   &   }
    ('&lt;'),                {   >   }
    ('&gt;'),                {   <   }
    ('&quot;'),              {   "   }
    ('&trade;'),             {   ™   }
    ('&nbsp;'),              { space }
    ('&copy;'),              {   ©   }
    ('&reg;'),               {   ®   }
    ('&Agrave;'),            {   À   }
    ('&Aacute;'),            {   Á   }
    ('&Acirc;'),             {   Â   }
    ('&Atilde;'),            {   Ã   }
    ('&Auml;'),              {   Ä   }
    ('&Aring;'),             {   Å   }
    ('&AElig;'),             {   Æ   }
    ('&Ccedil;'),            {   Ç   }
    ('&Egrave;'),            {   È   }
    ('&Eacute;'),            {   É   }
    ('&Ecirc;'),             {   Ê   }
    ('&Euml;'),              {   Ë   }
    ('&Igrave;'),            {   Ì   }
    ('&Iacute;'),            {   Í   }
    ('&Icirc;'),             {   Î   }
    ('&Iuml;'),              {   Ï   }
    ('&ETH;'),               {   Ð   }
    ('&Ntilde;'),            {   Ñ   }
    ('&Ograve;'),            {   Ò   }
    ('&Oacute;'),            {   Ó   }
    ('&Ocirc;'),             {   Ô   }
    ('&Otilde;'),            {   Õ   }
    ('&Ouml;'),              {   Ö   }
    ('&Oslash;'),            {   Ø   }
    ('&Ugrave;'),            {   Ù   }
    ('&Uacute;'),            {   Ú   }
    ('&Ucirc;'),             {   Û   }
    ('&Uuml;'),              {   Ü   }
    ('&Yacute;'),            {   Ý   }
    ('&THORN;'),             {   Þ   }
    ('&szlig;'),             {   ß   }
    ('&agrave;'),            {   à   }
    ('&aacute;'),            {   á   }
    ('&acirc;'),             {   â   }
    ('&atilde;'),            {   ã   }
    ('&auml;'),              {   ä   }
    ('&aring;'),             {   å   }
    ('&aelig;'),             {   æ   }
    ('&ccedil;'),            {   ç   }
    ('&egrave;'),            {   è   }
    ('&eacute;'),            {   é   }
    ('&ecirc;'),             {   ê   }
    ('&euml;'),              {   ë   }
    ('&igrave;'),            {   ì   }
    ('&iacute;'),            {   í   }
    ('&icirc;'),             {   î   }
    ('&iuml;'),              {   ï   }
    ('&eth;'),               {   ð   }
    ('&ntilde;'),            {   ñ   }
    ('&ograve;'),            {   ò   }
    ('&oacute;'),            {   ó   }
    ('&ocirc;'),             {   ô   }
    ('&otilde;'),            {   õ   }
    ('&ouml;'),              {   ö   }
    ('&oslash;'),            {   ø   }
    ('&ugrave;'),            {   ù   }
    ('&uacute;'),            {   ú   }
    ('&ucirc;'),             {   û   }
    ('&uuml;'),              {   ü   }
    ('&yacute;'),            {   ý   }
    ('&thorn;'),             {   þ   }
    ('&yuml;'),              {   ÿ   }
    ('&iexcl;'),             {   ¡   }
    ('&cent;'),              {   ¢   }
    ('&pound;'),             {   £   }
    ('&curren;'),            {   ¤   }
    ('&yen;'),               {   ¥   }
    ('&brvbar;'),            {   ¦   }
    ('&sect;'),              {   §   }
    ('&uml;'),               {   ¨   }
    ('&ordf;'),              {   ª   }
    ('&laquo;'),             {   «   }
    ('&shy;'),               {   ¬   }
    ('&macr;'),              {   ¯   }
    ('&deg;'),               {   °   }
    ('&plusmn;'),            {   ±   }
    ('&sup2;'),              {   ²   }
    ('&sup3;'),              {   ³   }
    ('&acute;'),             {   ´   }
    ('&micro;'),             {   µ   }
    ('&middot;'),            {   ·   }
    ('&cedil;'),             {   ¸   }
    ('&sup1;'),              {   ¹   }
    ('&ordm;'),              {   º   }
    ('&raquo;'),             {   »   }
    ('&frac14;'),            {   ¼   }
    ('&frac12;'),            {   ½   }
    ('&frac34;'),            {   ¾   }
    ('&iquest;'),            {   ¿   }
    ('&times;'),             {   ×   }
    ('&divide'),             {   ÷   }
    ('&euro;'),              {   €   }
    //used by very old HTML editors
    ('&#9;'),                {  TAB  }
    ('&#127;'),              {      }
    ('&#128;'),              {   €   }
    ('&#129;'),              {      }
    ('&#130;'),              {   ‚   }
    ('&#131;'),              {   ƒ   }
    ('&#132;'),              {   „   }
    ('&ldots;'),             {   …   }
    ('&#134;'),              {   †   }
    ('&#135;'),              {   ‡   }
    ('&#136;'),              {   ˆ   }
    ('&#137;'),              {   ‰   }
    ('&#138;'),              {   Š   }
    ('&#139;'),              {   ‹   }
    ('&#140;'),              {   Œ   }
    ('&#141;'),              {      }
    ('&#142;'),              {   Ž   }
    ('&#143;'),              {      }
    ('&#144;'),              {      }
    ('&#152;'),              {   ˜   }
    ('&#153;'),              {   ™   }
    ('&#154;'),              {   š   }
    ('&#155;'),              {   ›   }
    ('&#156;'),              {   œ   }
    ('&#157;'),              {      }
    ('&#158;'),              {   ž   }
    ('&#159;'),              {   Ÿ   }
    ('&#161;'),              {   ¡   }
    ('&#162;'),              {   ¢   }
    ('&#163;'),              {   £   }
    ('&#164;'),              {   ¤   }
    ('&#165;'),              {   ¥   }
    ('&#166;'),              {   ¦   }
    ('&#167;'),              {   §   }
    ('&#168;'),              {   ¨   }
    ('&#170;'),              {   ª   }
    ('&#175;'),              {   »   }
    ('&#176;'),              {   °   }
    ('&#177;'),              {   ±   }
    ('&#178;'),              {   ²   }
    ('&#180;'),              {   ´   }
    ('&#181;'),              {   µ   }
    ('&#183;'),              {   ·   }
    ('&#184;'),              {   ¸   }
    ('&#185;'),              {   ¹   }
    ('&#186;'),              {   º   }
    ('&#188;'),              {   ¼   }
    ('&#189;'),              {   ½   }
    ('&#190;'),              {   ¾   }
    ('&#191;'),              {   ¿   }
    ('&#215;')               {   Ô   }
  );
{end}                                                                           //sjg 1999-06-22

  
Type
  TtkTokenKind = (
    tkAmpersand,
    tkASP,                                                                      //lad 1999-07-23
    tkComment,
    tkIdentifier,
    tkKey,
    tkNull,
    tkSpace,
    tkString,
    tkSymbol,
    tkText,
    tkUndefKey,
//    tkUnknown,                                                                //mh 1999-05-25
    tkValue
  );


  TRangeState = (
    rsAmpersand,                                                                //hk 1999-06-03
    rsASP,                                                                      //lad 1999-07-23                                                                      
    rsComment,
//    rsTag,                                                                    //mh 1999-05-25
    rsKey,
    rsParam,
    rsText,
    rsUnKnown,
    rsValue
  );


  TProcTableProc = Procedure Of Object;
  TIdentFuncTableFunc = Function: TtkTokenKind Of Object;


  ThkHTMLSyn = Class(TmwCustomHighLighter)
  Private
    fAndCode: Integer;
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: Array[#0..#255] Of TProcTableProc;
    Run: Longint;
    Temp: PChar;
    fStringLen: Integer;
    fToIdent: PChar;
    fIdentFuncTable: Array[0..243] Of TIdentFuncTableFunc;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
//    fEol: Boolean;                                                            //mh 1999-05-25
    fAndAttri: TmwHighLightAttributes;                                          //hk 1999-06-03
    fASPAttri: TmwHighLightAttributes;                                          //lad 1999-07-23
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fTextAttri: TmwHighLightAttributes;
    fUndefKeyAttri: TmwHighLightAttributes;                                     //hk 1999-05-26
    fValueAttri: TmwHighLightAttributes;
    fLineNumber: Integer;                                                       //gp 1999-05-05

//    Procedure AssignAttributes(Attributes: TmwHighLightAttributes);           //mh 1999-09-12
    Function KeyHash(ToHash: PChar): Integer;
    Function KeyComp(const aKey: String): Boolean;                              //mh 1999-08-22
    Function Func1: TtkTokenKind;
    Function Func2: TtkTokenKind;
    Function Func8: TtkTokenKind;
    Function Func9: TtkTokenKind;
    Function Func10: TtkTokenKind;
    Function Func11: TtkTokenKind;
    Function Func12: TtkTokenKind;
    Function Func13: TtkTokenKind;
    Function Func14: TtkTokenKind;
    Function Func16: TtkTokenKind;
    Function Func17: TtkTokenKind;
    Function Func18: TtkTokenKind;
    Function Func19: TtkTokenKind;
    Function Func20: TtkTokenKind;
    Function Func21: TtkTokenKind;
    Function Func23: TtkTokenKind;
    Function Func24: TtkTokenKind;
    Function Func25: TtkTokenKind;
    Function Func26: TtkTokenKind;
    Function Func27: TtkTokenKind;
    Function Func28: TtkTokenKind;
    Function Func29: TtkTokenKind;
    Function Func30: TtkTokenKind;
    Function Func31: TtkTokenKind;
    Function Func32: TtkTokenKind;
    Function Func33: TtkTokenKind;
    Function Func35: TtkTokenKind;
    Function Func37: TtkTokenKind;
    Function Func38: TtkTokenKind;
    Function Func39: TtkTokenKind;
    Function Func40: TtkTokenKind;
    Function Func41: TtkTokenKind;
    Function Func42: TtkTokenKind;
    Function Func43: TtkTokenKind;
    Function Func46: TtkTokenKind;
    Function Func47: TtkTokenKind;
    Function Func48: TtkTokenKind;
    Function Func49: TtkTokenKind;
    Function Func50: TtkTokenKind;
    Function Func52: TtkTokenKind;
    Function Func53: TtkTokenKind;
    Function Func55: TtkTokenKind;
    Function Func56: TtkTokenKind;
    Function Func57: TtkTokenKind;
    Function Func58: TtkTokenKind;
    Function Func61: TtkTokenKind;
    Function Func62: TtkTokenKind;
    Function Func64: TtkTokenKind;
    Function Func65: TtkTokenKind;
    Function Func66: TtkTokenKind;
    Function Func67: TtkTokenKind;
    Function Func70: TtkTokenKind;
    Function Func76: TtkTokenKind;
    Function Func78: TtkTokenKind;
    Function Func80: TtkTokenKind;
    Function Func81: TtkTokenKind;
    Function Func82: TtkTokenKind;
    Function Func83: TtkTokenKind;
    Function Func84: TtkTokenKind;
    Function Func85: TtkTokenKind;
    Function Func87: TtkTokenKind;
    Function Func89: TtkTokenKind;
    Function Func90: TtkTokenKind;
    Function Func91: TtkTokenKind;
    Function Func92: TtkTokenKind;
    Function Func93: TtkTokenKind;
    Function Func94: TtkTokenKind;
    Function Func105: TtkTokenKind;
    Function Func107: TtkTokenKind;
    Function Func114: TtkTokenKind;
    Function Func121: TtkTokenKind;
    Function Func123: TtkTokenKind;
    Function Func124: TtkTokenKind;
    Function Func130: TtkTokenKind;
    Function Func131: TtkTokenKind;
    Function Func132: TtkTokenKind;
    Function Func133: TtkTokenKind;
    Function Func134: TtkTokenKind;
    Function Func135: TtkTokenKind;
    Function Func136: TtkTokenKind;
    Function Func138: TtkTokenKind;
    Function Func139: TtkTokenKind;
    Function Func140: TtkTokenKind;
    Function Func141: TtkTokenKind;
    Function Func143: TtkTokenKind;
    Function Func145: TtkTokenKind;
    Function Func146: TtkTokenKind;
    Function Func149: TtkTokenKind;
    Function Func150: TtkTokenKind;
    Function Func151: TtkTokenKind;
    Function Func152: TtkTokenKind;
    Function Func153: TtkTokenKind;
    Function Func154: TtkTokenKind;
    Function Func155: TtkTokenKind;
    Function Func157: TtkTokenKind;
    Function Func159: TtkTokenKind;
    Function Func160: TtkTokenKind;
    Function Func161: TtkTokenKind;
    Function Func162: TtkTokenKind;
    Function Func163: TtkTokenKind;
    Function Func164: TtkTokenKind;
    Function Func168: TtkTokenKind;
    Function Func169: TtkTokenKind;
    Function Func170: TtkTokenKind;
    Function Func171: TtkTokenKind;
    Function Func172: TtkTokenKind;
    Function Func174: TtkTokenKind;
    Function Func175: TtkTokenKind;
    Function Func177: TtkTokenKind;
    Function Func178: TtkTokenKind;
    Function Func179: TtkTokenKind;
    Function Func180: TtkTokenKind;
    Function Func183: TtkTokenKind;
    Function Func186: TtkTokenKind;
    Function Func187: TtkTokenKind;
    Function Func188: TtkTokenKind;
    Function Func192: TtkTokenKind;
    Function Func198: TtkTokenKind;
    Function Func200: TtkTokenKind;
    Function Func202: TtkTokenKind;
    Function Func203: TtkTokenKind;
    Function Func204: TtkTokenKind;
    Function Func205: TtkTokenKind;
    Function Func207: TtkTokenKind;
    Function Func209: TtkTokenKind;
    Function Func211: TtkTokenKind;
    Function Func212: TtkTokenKind;
    Function Func213: TtkTokenKind;
    Function Func214: TtkTokenKind;
    Function Func215: TtkTokenKind;
    Function Func216: TtkTokenKind;
    Function Func227: TtkTokenKind;
    Function Func229: TtkTokenKind;
    Function Func236: TtkTokenKind;
    Function Func243: TtkTokenKind;
    Function AltFunc: TtkTokenKind;
    Function IdentKind(MayBe: PChar): TtkTokenKind;
    Procedure InitIdent;
    Procedure MakeMethodTables;
    procedure ASPProc;                                                          //lad 1999-07-23
    Procedure TextProc;
    Procedure CommentProc;
    Procedure BraceCloseProc;
    Procedure BraceOpenProc;
    Procedure CRProc;
    Procedure EqualProc;
    Procedure IdentProc;
    Procedure LFProc;
    Procedure NullProc;
    Procedure SpaceProc;
    Procedure StringProc;
//    Procedure HighLightChange(Sender:TObject);                                //mh 1999-08-22
//    Procedure SetHighLightChange;                                             //mh 1999-08-22
    Procedure AmpersandProc;                                                    //hk 1999-06-03
  Protected
    Function GetIdentChars: TIdentChars; Override;
    Function GetLanguageName: String; Override;
//    Function GetAttribCount: Integer; Override;                               //mh 1999-08-22
//    Function GetAttribute(Idx: Integer): TmwHighLightAttributes; Override;    //mh 1999-08-22
    Function GetCapability: THighlighterCapability; Override;
  Public
    Constructor Create(AOwner: TComponent); Override;
//    Destructor Destroy; Override;                                             //mh 1999-08-22
    Function GetEol: Boolean; Override;
    Function GetRange: Pointer; Override;
    Function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-05-05
    Function GetToken: String; Override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    Function GetTokenPos: Integer; Override;
    Procedure Next; Override;
//    Procedure SetCanvas(Value: TCanvas); Override;                            //mh 1999-09-12
    Procedure SetRange(Value: Pointer); Override;
    Procedure ReSetRange; Override;
    Property IdentChars;
    Procedure SetLineForExport(NewValue: String); Override;                     //hk 1999-06-16
    Procedure ExportNext; Override;                                             //hk 1999-06-16
  Published
    Property AndAttri: TmwHighLightAttributes Read fAndAttri Write fAndAttri;   //hk 1999-06-16
    property ASPAttri: TmwHighLightAttributes Read fASPAttri Write fASPAttri;   //lad 1999-07-23
    Property CommentAttri: TmwHighLightAttributes Read fCommentAttri Write fCommentAttri;
    Property IdentifierAttri: TmwHighLightAttributes Read fIdentifierAttri Write fIdentifierAttri;
    Property KeyAttri: TmwHighLightAttributes Read fKeyAttri Write fKeyAttri;
    Property SpaceAttri: TmwHighLightAttributes Read fSpaceAttri Write fSpaceAttri;
    Property SymbolAttri: TmwHighLightAttributes Read fSymbolAttri Write fSymbolAttri;
    Property TextAttri: TmwHighLightAttributes Read fTextAttri Write fTextAttri;
    Property UndefKeyAttri: TmwHighLightAttributes Read fUndefKeyAttri          //hk 1999-05-26
             Write fUndefKeyAttri;
    Property ValueAttri: TmwHighLightAttributes Read fValueAttri Write fValueAttri;
  End;



Var
  hkTagLex: ThkHTMLSyn;



Procedure Register;



Implementation



{  }
Procedure MakeIdentTable;
Var
  i: Char;
//  j: Char;                                                                    //hk 1999-05-27
Begin
  For i:=#0 To #255 Do Begin
//    j := UpperCase(i)[1];                                                     //hk 1999-05-27
    Case i Of
    'a'..'z', 'A'..'Z':
      Begin
//        mHashTable[i] := (Ord(j) - 64);                                       //hk 1999-05-27
        mHashTable[i] := (Ord(UpperCase(i)[1]) - 64)
      End;
    '!':
      Begin
        mHashTable[i] := $7B;
      End;
    '/':
      Begin
        mHashTable[i] := $7A;
      End;
    Else
      mHashTable[Char(i)] := 0;
    End;
  End;
End;


{  }
Procedure ThkHTMLSyn.InitIdent;
Var
  i: Integer;
Begin
  For i:=0 To 243 Do Begin
    Case i Of
    1:   fIdentFuncTable[i] := Func1;
    2:   fIdentFuncTable[i] := Func2;
    8:   fIdentFuncTable[i] := Func8;
    9:   fIdentFuncTable[i] := Func9;
    10:  fIdentFuncTable[i] := Func10;
    11:  fIdentFuncTable[i] := Func11;
    12:  fIdentFuncTable[i] := Func12;
    13:  fIdentFuncTable[i] := Func13;
    14:  fIdentFuncTable[i] := Func14;
    16:  fIdentFuncTable[i] := Func16;
    17:  fIdentFuncTable[i] := Func17;
    18:  fIdentFuncTable[i] := Func18;
    19:  fIdentFuncTable[i] := Func19;
    20:  fIdentFuncTable[i] := Func20;
    21:  fIdentFuncTable[i] := Func21;
    23:  fIdentFuncTable[i] := Func23;
    24:  fIdentFuncTable[i] := Func24;
    25:  fIdentFuncTable[i] := Func25;
    26:  fIdentFuncTable[i] := Func26;
    27:  fIdentFuncTable[i] := Func27;
    28:  fIdentFuncTable[i] := Func28;
    29:  fIdentFuncTable[i] := Func29;
    30:  fIdentFuncTable[i] := Func30;
    31:  fIdentFuncTable[i] := Func31;
    32:  fIdentFuncTable[i] := Func32;
    33:  fIdentFuncTable[i] := Func33;
    35:  fIdentFuncTable[i] := Func35;
    37:  fIdentFuncTable[i] := Func37;
    38:  fIdentFuncTable[i] := Func38;
    39:  fIdentFuncTable[i] := Func39;
    40:  fIdentFuncTable[i] := Func40;
    41:  fIdentFuncTable[i] := Func41;
    42:  fIdentFuncTable[i] := Func42;
    43:  fIdentFuncTable[i] := Func43;
    46:  fIdentFuncTable[i] := Func46;
    47:  fIdentFuncTable[i] := Func47;
    48:  fIdentFuncTable[i] := Func48;
    49:  fIdentFuncTable[i] := Func49;
    50:  fIdentFuncTable[i] := Func50;
    52:  fIdentFuncTable[i] := Func52;
    53:  fIdentFuncTable[i] := Func53;
    55:  fIdentFuncTable[i] := Func55;
    56:  fIdentFuncTable[i] := Func56;
    57:  fIdentFuncTable[i] := Func57;
    58:  fIdentFuncTable[i] := Func58;
    61:  fIdentFuncTable[i] := Func61;
    62:  fIdentFuncTable[i] := Func62;
    64:  fIdentFuncTable[i] := Func64;
    65:  fIdentFuncTable[i] := Func65;
    66:  fIdentFuncTable[i] := Func66;
    67:  fIdentFuncTable[i] := Func67;
    70:  fIdentFuncTable[i] := Func70;
    76:  fIdentFuncTable[i] := Func76;
    78:  fIdentFuncTable[i] := Func78;
    80:  fIdentFuncTable[i] := Func80;
    81:  fIdentFuncTable[i] := Func81;
    82:  fIdentFuncTable[i] := Func82;
    83:  fIdentFuncTable[i] := Func83;
    84:  fIdentFuncTable[i] := Func84;
    85:  fIdentFuncTable[i] := Func85;
    87:  fIdentFuncTable[i] := Func87;
    89:  fIdentFuncTable[i] := Func89;
    90:  fIdentFuncTable[i] := Func90;
    91:  fIdentFuncTable[i] := Func91;
    92:  fIdentFuncTable[i] := Func92;
    93:  fIdentFuncTable[i] := Func93;
    94:  fIdentFuncTable[i] := Func94;
    105: fIdentFuncTable[i] := Func105;
    107: fIdentFuncTable[i] := Func107;
    114: fIdentFuncTable[i] := Func114;
    121: fIdentFuncTable[i] := Func121;
    123: fIdentFuncTable[i] := Func123;
    124: fIdentFuncTable[i] := Func124;
    130: fIdentFuncTable[i] := Func130;
    131: fIdentFuncTable[i] := Func131;
    132: fIdentFuncTable[i] := Func132;
    133: fIdentFuncTable[i] := Func133;
    134: fIdentFuncTable[i] := Func134;
    135: fIdentFuncTable[i] := Func135;
    136: fIdentFuncTable[i] := Func136;
    138: fIdentFuncTable[i] := Func138;
    139: fIdentFuncTable[i] := Func139;
    140: fIdentFuncTable[i] := Func140;
    141: fIdentFuncTable[i] := Func141;
    143: fIdentFuncTable[i] := Func143;
    145: fIdentFuncTable[i] := Func145;
    146: fIdentFuncTable[i] := Func146;
    149: fIdentFuncTable[i] := Func149;
    150: fIdentFuncTable[i] := Func150;
    151: fIdentFuncTable[i] := Func151;
    152: fIdentFuncTable[i] := Func152;
    153: fIdentFuncTable[i] := Func153;
    154: fIdentFuncTable[i] := Func154;
    155: fIdentFuncTable[i] := Func155;
    157: fIdentFuncTable[i] := Func157;
    159: fIdentFuncTable[i] := Func159;
    160: fIdentFuncTable[i] := Func160;
    161: fIdentFuncTable[i] := Func161;
    162: fIdentFuncTable[i] := Func162;
    163: fIdentFuncTable[i] := Func163;
    164: fIdentFuncTable[i] := Func164;
    168: fIdentFuncTable[i] := Func168;
    169: fIdentFuncTable[i] := Func169;
    170: fIdentFuncTable[i] := Func170;
    171: fIdentFuncTable[i] := Func171;
    172: fIdentFuncTable[i] := Func172;
    174: fIdentFuncTable[i] := Func174;
    175: fIdentFuncTable[i] := Func175;
    177: fIdentFuncTable[i] := Func177;
    178: fIdentFuncTable[i] := Func178;
    179: fIdentFuncTable[i] := Func179;
    180: fIdentFuncTable[i] := Func180;
    183: fIdentFuncTable[i] := Func183;
    186: fIdentFuncTable[i] := Func186;
    187: fIdentFuncTable[i] := Func187;
    188: fIdentFuncTable[i] := Func188;
    192: fIdentFuncTable[i] := Func192;
    198: fIdentFuncTable[i] := Func198;
    200: fIdentFuncTable[i] := Func200;
    202: fIdentFuncTable[i] := Func202;
    203: fIdentFuncTable[i] := Func203;
    204: fIdentFuncTable[i] := Func204;
    205: fIdentFuncTable[i] := Func205;
    207: fIdentFuncTable[i] := Func207;
    209: fIdentFuncTable[i] := Func209;
    211: fIdentFuncTable[i] := Func211;
    212: fIdentFuncTable[i] := Func212;
    213: fIdentFuncTable[i] := Func213;
    214: fIdentFuncTable[i] := Func214;
    215: fIdentFuncTable[i] := Func215;
    216: fIdentFuncTable[i] := Func216;
    227: fIdentFuncTable[i] := Func227;
    229: fIdentFuncTable[i] := Func229;
    236: fIdentFuncTable[i] := Func236;
    243: fIdentFuncTable[i] := Func243;
    Else
      fIdentFuncTable[i] := AltFunc;
    End;
  End;
End;


{  }
Function ThkHTMLSyn.KeyHash(ToHash: PChar): Integer;
Begin
  Result := 0;
  While (ToHash^ In ['a'..'z', 'A'..'Z', '!', '/']) Do Begin
    Inc(Result, mHashTable[ToHash^]);
    Inc(ToHash);
  End;
  While (ToHash^ In ['0'..'9']) Do Begin
    Inc(Result, (Ord(ToHash^) - Ord('0')) );
    Inc(ToHash);
  End;
  fStringLen := (ToHash - fToIdent);
End;


{  }
Function ThkHTMLSyn.KeyComp(const aKey: String): Boolean;                       //mh 1999-08-22
Var
  i: Integer;
Begin
  Temp := fToIdent;
  If (Length(aKey) = fStringLen) Then Begin
    Result := True;
    For i:=1 To fStringLen Do Begin
      If (mHashTable[Temp^] <> mHashTable[aKey[i]]) Then Begin
        Result := False;
        Break;
      End;
      Inc(Temp);
    End;
  End Else Begin
    Result := False;
  End;
End;


{  }
Function ThkHTMLSyn.Func1: TtkTokenKind;
Begin
  If KeyComp('A') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func2: TtkTokenKind;
Begin
  If KeyComp('B') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func8: TtkTokenKind;
Begin
  If KeyComp('DD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func9: TtkTokenKind;
Begin
  If KeyComp('I') Or KeyComp('H1') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func10: TtkTokenKind;
Begin
  If KeyComp('H2') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func11: TtkTokenKind;
Begin
  If KeyComp('H3') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func12: TtkTokenKind;
Begin
  If KeyComp('H4') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func13: TtkTokenKind;
Begin
  If KeyComp('H5') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func14: TtkTokenKind;
Begin
  If KeyComp('H6') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;



{  }
Function ThkHTMLSyn.Func16: TtkTokenKind;
Begin
  If KeyComp('DL') Or KeyComp('P') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func17: TtkTokenKind;
Begin
  If KeyComp('KBD') Or KeyComp('Q') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func18: TtkTokenKind;
Begin
  If KeyComp('BIG') Or KeyComp('EM') Or KeyComp('HEAD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func19: TtkTokenKind;
Begin
  If KeyComp('S') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func20: TtkTokenKind;
Begin
  If KeyComp('BR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func21: TtkTokenKind;
Begin
  If KeyComp('DEL') Or KeyComp('LI') Or KeyComp('U') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func23: TtkTokenKind;
Begin
  If KeyComp('ABBR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func24: TtkTokenKind;
Begin
  If KeyComp('DFN') Or KeyComp('DT') Or KeyComp('TD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func25: TtkTokenKind;
Begin
  If KeyComp('AREA') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func26: TtkTokenKind;
Begin
  If KeyComp('HR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func27: TtkTokenKind;
Begin
  If KeyComp('BASE') Or KeyComp('CODE') Or KeyComp('OL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func28: TtkTokenKind;
Begin
  If KeyComp('TH') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func29: TtkTokenKind;
Begin
  If KeyComp('EMBED') Or KeyComp('IMG') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func30: TtkTokenKind;
Begin
  If KeyComp('COL') Or KeyComp('MAP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func31: TtkTokenKind;
Begin
  If KeyComp('DIR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func32: TtkTokenKind;
Begin
  If KeyComp('LABEL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func33: TtkTokenKind;
Begin
  If KeyComp('UL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func35: TtkTokenKind;
Begin
  If KeyComp('DIV') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func37: TtkTokenKind;
Begin
  If KeyComp('CITE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func38: TtkTokenKind;
Begin
  If KeyComp('THEAD') Or KeyComp('TR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func39: TtkTokenKind;
Begin
  If KeyComp('META') Or KeyComp('PRE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func40: TtkTokenKind;
Begin
  If KeyComp('TABLE') Or KeyComp('TT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func41: TtkTokenKind;
Begin
  If KeyComp('VAR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func42: TtkTokenKind;
Begin
  If KeyComp('INS') Or KeyComp('SUB') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func43: TtkTokenKind;
Begin
  If KeyComp('FRAME') Or KeyComp('WBR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func46: TtkTokenKind;
Begin
  If KeyComp('BODY') Or KeyComp('LINK') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func47: TtkTokenKind;
Begin
  If KeyComp('LEGEND') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func48: TtkTokenKind;
Begin
  If KeyComp('BLINK') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func49: TtkTokenKind;
Begin
  If KeyComp('NOBR') Or KeyComp('PARAM') Or KeyComp('SAMP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func50: TtkTokenKind;
Begin
  If KeyComp('SPAN') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func52: TtkTokenKind;
Begin
  If KeyComp('FORM') Or KeyComp('IFRAME') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func53: TtkTokenKind;
Begin
  If KeyComp('HTML') Or KeyComp('MENU') Or KeyComp('XMP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func55: TtkTokenKind;
Begin
  If KeyComp('FONT') Or KeyComp('OBJECT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func56: TtkTokenKind;
Begin
  If KeyComp('SUP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func57: TtkTokenKind;
Begin
  If KeyComp('SMALL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func58: TtkTokenKind;
Begin
  If KeyComp('NOEMBED') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func61: TtkTokenKind;
Begin
  If KeyComp('LAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func62: TtkTokenKind;
Begin
  If KeyComp('SPACER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func64: TtkTokenKind;
Begin
//  If KeyComp('CENTER') Then Begin
  If KeyComp('SELECT') Then Begin                                               //hk 1999-05-10
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func65: TtkTokenKind;
Begin
  If KeyComp('CENTER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func66: TtkTokenKind;
Begin
  If KeyComp('TBODY') Or KeyComp('TITLE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func67: TtkTokenKind;
Begin
  If KeyComp('KEYGEN') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func70: TtkTokenKind;
Begin
  If KeyComp('ADDRESS') Or KeyComp('APPLET') Or KeyComp('ILAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func76: TtkTokenKind;
Begin
  If KeyComp('NEXTID') Or KeyComp('TFOOT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func78: TtkTokenKind;
Begin
  If KeyComp('CAPTION') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func80: TtkTokenKind;
Begin
  If KeyComp('FIELDSET') Or KeyComp('INPUT') Or KeyComp('MARQUEE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func81: TtkTokenKind;
Begin
  If KeyComp('STYLE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func82: TtkTokenKind;
Begin
  If KeyComp('BASEFONT') Or KeyComp('BGSOUND') Or KeyComp('STRIKE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func83: TtkTokenKind;
Begin
  If KeyComp('COMMENT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func84: TtkTokenKind;
Begin
  If KeyComp('ISINDEX') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func85: TtkTokenKind;
Begin
  If KeyComp('SCRIPT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func87: TtkTokenKind;
Begin
  If KeyComp('SERVER') Or KeyComp('FRAMESET') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func89: TtkTokenKind;
Begin
  If KeyComp('ACRONYM') Or KeyComp('OPTION') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func90: TtkTokenKind;
Begin
  If KeyComp('LISTING') Or KeyComp('NOLAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func91: TtkTokenKind;
Begin
  If KeyComp('NOFRAMES') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func92: TtkTokenKind;
Begin
  If KeyComp('BUTTON') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func93: TtkTokenKind;
Begin
  If KeyComp('STRONG') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func94: TtkTokenKind;
Begin
  If KeyComp('TEXTAREA') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func105: TtkTokenKind;
Begin
  If KeyComp('MULTICOL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func107: TtkTokenKind;
Begin
  If KeyComp('COLGROUP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func114: TtkTokenKind;
Begin
  If KeyComp('NOSCRIPT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func121: TtkTokenKind;
Begin
  If KeyComp('BLOCKQUOTE') Or KeyComp('PLAINTEXT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func123: TtkTokenKind;
Begin
  If KeyComp('/A') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func124: TtkTokenKind;
Begin
  If KeyComp('/B') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func130: TtkTokenKind;
Begin
  If KeyComp('/DD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func131: TtkTokenKind;
Begin
  If KeyComp('/I') Or KeyComp('/H1') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func132: TtkTokenKind;
Begin
  If KeyComp('/H2') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func133: TtkTokenKind;
Begin
  If KeyComp('/H3') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func134: TtkTokenKind;
Begin
  If KeyComp('/H4') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func135: TtkTokenKind;
Begin
  If KeyComp('/H5') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func136: TtkTokenKind;
Begin
  If KeyComp('/H6') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func138: TtkTokenKind;
Begin
  If KeyComp('/DL') Or KeyComp('/P') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func139: TtkTokenKind;
Begin
  If KeyComp('/KBD') Or KeyComp('/Q') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func140: TtkTokenKind;
Begin
  If KeyComp('/BIG') Or KeyComp('/EM') Or KeyComp('/HEAD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func141: TtkTokenKind;
Begin
  If KeyComp('/S') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func143: TtkTokenKind;
Begin
  If KeyComp('/DEL') Or KeyComp('/LI') Or KeyComp('/U') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func145: TtkTokenKind;
Begin
  If KeyComp('/ABBR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func146: TtkTokenKind;
Begin
  If KeyComp('/DFN') Or KeyComp('/DT') Or KeyComp('/TD') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func149: TtkTokenKind;
Begin
  If KeyComp('/CODE') Or KeyComp('/OL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func150: TtkTokenKind;
Begin
  If KeyComp('/TH') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func151: TtkTokenKind;
Begin
  If KeyComp('/EMBED') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func152: TtkTokenKind;
Begin
  If KeyComp('/MAP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func153: TtkTokenKind;
Begin
  If KeyComp('/DIR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func154: TtkTokenKind;
Begin
  If KeyComp('/LABEL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func155: TtkTokenKind;
Begin
  If KeyComp('/UL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func157: TtkTokenKind;
Begin
  If KeyComp('/DIV') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func159: TtkTokenKind;
Begin
  If KeyComp('/CITE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func160: TtkTokenKind;
Begin
  If KeyComp('/THEAD') Or KeyComp('/TR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func161: TtkTokenKind;
Begin
  If KeyComp('/PRE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func162: TtkTokenKind;
Begin
  If KeyComp('/TABLE') Or KeyComp('/TT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func163: TtkTokenKind;
Begin
  If KeyComp('/VAR') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func164: TtkTokenKind;
Begin
  If KeyComp('/INS') Or KeyComp('/SUB') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func168: TtkTokenKind;
Begin
  If KeyComp('/BODY') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func169: TtkTokenKind;
Begin
  If KeyComp('/LEGEND') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func170: TtkTokenKind;
Begin
  If KeyComp('/BLINK') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func171: TtkTokenKind;
Begin
  If KeyComp('/NOBR') Or KeyComp('/SAMP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func172: TtkTokenKind;
Begin
  If KeyComp('/SPAN') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func174: TtkTokenKind;
Begin
  If KeyComp('/FORM') Or KeyComp('/IFRAME') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func175: TtkTokenKind;
Begin
  If KeyComp('/HTML') Or KeyComp('/MENU') Or KeyComp('/XMP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func177: TtkTokenKind;
Begin
  If KeyComp('/FONT') Or KeyComp('/OBJECT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func178: TtkTokenKind;
Begin
  If KeyComp('/SUP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func179: TtkTokenKind;
Begin
  If KeyComp('/SMALL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func180: TtkTokenKind;
Begin
  If KeyComp('/NOEMBED') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func183: TtkTokenKind;
Begin
  If KeyComp('/LAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func186: TtkTokenKind;
Begin
  If KeyComp('/SELECT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func187: TtkTokenKind;
Begin
  If KeyComp('/CENTER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func188: TtkTokenKind;
Begin
  If KeyComp('/TBODY') Or KeyComp('/TITLE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func192: TtkTokenKind;
Begin
  If KeyComp('/ADDRESS') Or KeyComp('/APPLET') Or KeyComp('/ILAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func198: TtkTokenKind;
Begin
  If KeyComp('/TFOOT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func200: TtkTokenKind;
Begin
  If KeyComp('/CAPTION') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func202: TtkTokenKind;
Begin
  If KeyComp('/FIELDSET') Or KeyComp('/MARQUEE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func203: TtkTokenKind;
Begin
  If KeyComp('/STYLE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func204: TtkTokenKind;
Begin
  If KeyComp('/STRIKE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func205: TtkTokenKind;
Begin
  If KeyComp('/COMMENT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func207: TtkTokenKind;
Begin
  If KeyComp('/SCRIPT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func209: TtkTokenKind;
Begin
  If KeyComp('/FRAMESET') Or KeyComp('/SERVER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func211: TtkTokenKind;
Begin
  If KeyComp('/ACRONYM') Or KeyComp('/OPTION') Or KeyComp('!DOCTYPE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func212: TtkTokenKind;
Begin
  If KeyComp('/LISTING') Or KeyComp('/NOLAYER') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func213: TtkTokenKind;
Begin
  If KeyComp('/NOFRAMES') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func214: TtkTokenKind;
Begin
  If KeyComp('/BUTTON') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func215: TtkTokenKind;
Begin
  If KeyComp('/STRONG') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func216: TtkTokenKind;
Begin
  If KeyComp('/TEXTAREA') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func227: TtkTokenKind;
Begin
  If KeyComp('/MULTICOL') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func229: TtkTokenKind;
Begin
  If KeyComp('/COLGROUP') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func236: TtkTokenKind;
Begin
  If KeyComp('/NOSCRIPT') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.Func243: TtkTokenKind;
Begin
  If KeyComp('/BLOCKQUOTE') Then Begin
    Result := tkKey;
  End Else Begin
    Result := tkUndefKey;
  End;
End;


{  }
Function ThkHTMLSyn.AltFunc: TtkTokenKind;
Begin
  Result := tkUndefKey;
End;


{  }
Procedure ThkHTMLSyn.MakeMethodTables;
Var
  i: Char;
Begin
  For i:=#0 To #255 Do Begin
    Case i Of
    #0:
      Begin
        fProcTable[i] := NullProc;
      End;
    #10:
      Begin
        fProcTable[i] := LFProc;
      End;
    #13:
      Begin
        fProcTable[i] := CRProc;
      End;
    #1..#9, #11, #12, #14..#32:
      Begin
        fProcTable[i] := SpaceProc;
      End;
    '&':                                                                        //hk 1999-06-03
      Begin
        fProcTable[i] := AmpersandProc;
      End;
    '"':
      Begin
        fProcTable[i] := StringProc;
      End;
    '<':
      Begin
        fProcTable[i] := BraceOpenProc;
      End;
    '>':
      Begin
        fProcTable[i] := BraceCloseProc;
      End;
    '=':
      Begin
        fProcTable[i] := EqualProc;
      End;
    Else
      fProcTable[i] := IdentProc;
    End;
  End;
End;



{  }
Constructor ThkHTMLSyn.Create(AOwner: TComponent);
Begin
  fASPAttri := TmwHighLightAttributes.Create(MWS_AttrASP);                      //lad 1999-07-23
  fASPAttri.Foreground := clBlack;                                              //lad 1999-07-23
  fASPAttri.Background := clYellow;                                             //lad 1999-07-23

  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);

  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  fIdentifierAttri.Style := [fsBold];

  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Style := [fsBold];
  fKeyAttri.Foreground := $00ff0080;

  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);

  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  fSymbolAttri.Style := [fsBold];

  fTextAttri := TmwHighLightAttributes.Create(MWS_AttrText);

  fUndefKeyAttri := TmwHighLightAttributes.Create(MWS_AttrUnknownWord);         //hk 1999-05-26
  fUndefKeyAttri.Style := [fsBold];
  fUndefKeyAttri.Foreground := clRed;

  fValueAttri := TmwHighLightAttributes.Create(MWS_AttrValue);
  fValueAttri.Foreground := $00ff8000;

  fAndAttri := TmwHighLightAttributes.Create(MWS_AttrEscapeAmpersand);
  fAndAttri.Style := [fsBold];
  fAndAttri.Foreground := $0000ff00;

  Inherited Create(AOwner);

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fASPAttri);                                                      //lad 1999-07-23
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fSymbolAttri);
  AddAttribute(fTextAttri);
  AddAttribute(fUndefKeyAttri);
  AddAttribute(fValueAttri);
  AddAttribute(fAndAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22
  InitIdent;
  MakeMethodTables;
  fRange := rsText;
  fDefaultFilter := MWS_FilterHTML;                                             //ajb 1999-09-14
End;


{begin}                                                                         //mh 1999-08-22
(*
{  }
Destructor ThkHTMLSyn.Destroy;
Begin
  fAndAttri.Free;
  fCommentAttri.Free;
  fIdentifierAttri.Free;
  fKeyAttri.Free;
  fSpaceAttri.Free;
  fSymbolAttri.Free;
  fTextAttri.Free;
  fUndefKeyAttri.Free;                                                          //hk 1999-05-26
  fValueAttri.Free;

  Inherited Destroy;
End;
*)
{end}                                                                           //mh 1999-08-22

(*                                                                              //mh 1999-09-12
{  }
Procedure ThkHTMLSyn.SetCanvas(Value: TCanvas);
Begin
  fCanvas := Value;
End;
*)

{  }
procedure ThkHTMLSyn.SetLine(NewValue: String; LineNumber:Integer); 
Begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;                                                              //mh 1999-05-25
  fLineNumber := LineNumber;                                                    //gp 1999-05-05
  Next;
End;


Procedure ThkHTMLSyn.ASPProc;                                                   // lad 1999-05-23
Begin
  fTokenID := tkASP;
  If (fLine[Run] In [#0, #10, #13]) Then Begin
    fProcTable[fLine[Run]];
    Exit;
  End;

  while not (fLine[Run] in [#0, #10, #13]) do begin
    if (fLine[Run] = '>') and (fLine[Run - 1] = '%')
    then begin
      fRange := rsText;
      Inc(Run);
      break;
    end;
    Inc(Run);
  end;
End;


{  }
Procedure ThkHTMLSyn.BraceCloseProc;
Begin
  fRange := rsText;
  fTokenId := tkSymbol;
  Inc(Run);
End;


{  }
Procedure ThkHTMLSyn.CommentProc;
Begin
  fTokenID := tkComment;

(*                                                                              //hk 1999-05-26
  Case fLine[Run] Of
  #0..#31:
    Begin
      fProcTable[fLine[Run]];
      Exit;
    End;
  End;
*)
  If (fLine[Run] In [#0, #10, #13]) Then Begin                                  //hk 1999-05-26
    fProcTable[fLine[Run]];
    Exit;
  End;

(*                                                                              //mh 1999-05-25
  While Not (FLine[Run] In [#0, #10, #13]) Do Begin
    Case FLine[Run] Of
    '>':
      Begin
        If (fLine[Run-1] = '-') And (fLine[Run-2] = '-') Then Begin
          fRange := rsText;                               { --> End of Comment }
          Inc(Run);
          Break;
        End Else Begin
          Inc(Run);
        End;
      End;
    Else
      Inc(Run);
    End;
  End;
*)
  while not (fLine[Run] in [#0, #10, #13]) do begin                             //mh 1999-05-25
    if (fLine[Run] = '>') and (fLine[Run - 1] = '-') and (fLine[Run - 2] = '-')
    then begin
      fRange := rsText;
      Inc(Run);
      break;
    end;
    Inc(Run);
  end;
{                                                                               //hk 1999-05-26
  if fRange = rsComment then fProcTable[fLine[Run]];                            //mh 1999-05-25
}
End;


{  }
Procedure ThkHTMLSyn.BraceOpenProc;
Begin
(*                                                                              //mh 1999-05-25
  If (fLine[Run+1] = '!') And (fLine[Run+2] = '-') And (fLine[Run+3] = '-') Then Begin
    fRange := rsComment;                               { <!-- Start of Comment }
    fTokenID := tkComment;
    Inc(Run, 4);
    While Not (FLine[Run] In [#0, #10, #13]) Do Begin
      Case FLine[Run] Of
      '>':
        Begin
          If (fLine[Run-1] = '-') And (fLine[Run-2] = '-') Then Begin
            fRange := rsText;
            Inc(Run);
            Break;
          End Else Begin
            Inc(Run);
          End;
        End;
      Else
        Inc(Run);
      End;
    End;
  End Else Begin
    fRange := rsKey;
    fTokenID := tkSymbol;
    Inc(Run);
  End;
*)
{begin}                                                                         //mh 1999-05-25
  Inc(Run);
  if (fLine[Run] = '!') and (fLine[Run + 1] = '-') and (fLine[Run + 2] = '-')
  then begin
    fRange := rsComment;
    fTokenID := tkComment;                                                      //hk 1999-05-26
    Inc(Run, 3);
//    CommentProc;                                                              //hk 1999-05-26
  end else begin
{begin}                                                                         //lad 1999-07-23
//    fRange := rsKey;
//    fTokenID := tkSymbol;
    if fLine[Run]= '%' then begin
      fRange := rsASP;
      fTokenID := tkASP;
      Inc(Run);
    end else begin
      fRange := rsKey;
      fTokenID := tkSymbol;
    end;
{end}                                                                           //lad 1999-07-23
  end;
{end}                                                                           //mh 1999-05-25
End;


{  }
Procedure ThkHTMLSyn.CRProc;
Begin
  fTokenID := tkSpace;
(*                                                                              //mh 1999-05-25
  Case FLine[Run + 1] Of
  #10:
    Inc(Run, 2);
  Else
    Inc(Run);
  End;
*)
  Inc(Run);
  if fLine[Run] = #10 then Inc(Run);
End;


{  }
Procedure ThkHTMLSyn.EqualProc;
Begin
  fRange := rsValue;
  fTokenID := tkSymbol;
  Inc(Run);
End;


{  }
Function ThkHTMLSyn.IdentKind(MayBe: PChar): TtkTokenKind;
Var
  hashKey: Integer;
Begin
  fToIdent := MayBe;
  hashKey := KeyHash(MayBe);
  If (hashKey < 244) Then Begin
    Result := fIdentFuncTable[hashKey];
  End Else Begin
    Result := tkIdentifier;
  End;
End;


{  }
Procedure ThkHTMLSyn.IdentProc;
Begin
  Case fRange Of
  rsKey:
    Begin
      fRange := rsParam;
      fTokenID := IdentKind((fLine + Run));
      Inc(Run, fStringLen);
    End;
  rsValue:
    Begin
      fRange := rsParam;
      fTokenID := tkValue;
      Repeat
        Inc(Run);
      Until (fLine[Run] In [#0..#32, '>']);
    End;
  Else
    fTokenID := tkIdentifier;
    Repeat
      Inc(Run);
    Until (fLine[Run] In [#0..#32, '=', '"', '>']);
  End;
End;


{  }
Procedure ThkHTMLSyn.LFProc;
Begin
  fTokenID := tkSpace;
  Inc(Run);
End;


{  }
Procedure ThkHTMLSyn.NullProc;
Begin
  fTokenID := tkNull;
//  fEol := True;                                                               //mh 1999-05-25
End;


{  }
Procedure ThkHTMLSyn.TextProc;
const StopSet = [#0..#31, '<', '&'];                                            //hk 1999-06-02
Var
  i: Integer;
Begin
(*                                                                              //mh 1999-05-25
  fTokenID := tkText;
  Case fLine[Run] Of
  #0..#32, '<':
    Begin
      fProcTable[fLine[Run]];
      Exit;
    End;
  End;

  While Not (fLine[Run] In [#0, #10, #13]) Do Begin
    Case fLine[Run] Of
    '<':
      Begin
        fRange := rsTag;
        Break;
      End;
    ' ':
      Begin
        Break;
      End;
    Else
      Inc(Run);
    End;
  End;
*)
{begin}                                                                         //hk 1999-06-03
  {begin}                                                                       //mh 1999-05-25
//  if fLine[Run] in StopSet then begin                                         //hk 1999-06-03
  if fLine[Run] in (StopSet - ['&']) then begin
    fProcTable[fLine[Run]];
    exit;
  end;
  {end}                                                                         //mh 1999-05-25

  fTokenID := tkText;
  While True Do Begin
    while not (fLine[Run] in StopSet) do Inc(Run);                              //mh 1999-05-25

    If (fLine[Run] = '&') Then Begin
      For i:=Low(EscapeAmps) To High(EscapeAmps) Do Begin
        If (StrLIComp((fLine + Run), PChar(EscapeAmps[i]), StrLen(EscapeAmps[i])) = 0) Then Begin
          fAndCode := i;
          fRange := rsAmpersand;
          Exit;
        End;
      End;

      Inc(Run);
    End Else Begin
      Break;
    End;
  End;
{end}                                                                           //hk 1999-06-03
End;


{  }
Procedure ThkHTMLSyn.AmpersandProc;                                             //hk 1999-06-03
Begin
  Case fAndCode Of
  Low(EscapeAmps)..High(EscapeAmps):
    Begin
      fTokenID := tkAmpersand;
      Inc(Run, StrLen(EscapeAmps[fAndCode]));
    End;
  End;
  fAndCode := -1;
  fRange := rsText;
End;


{  }
Procedure ThkHTMLSyn.SpaceProc;
Begin
  Inc(Run);
  fTokenID := tkSpace;
(*                                                                              //mh 1999-05-25
  While (FLine[Run] In [#1..#9, #11, #12, #14..#32]) Do Begin
    Inc(Run);
  End;
*)
  while fLine[Run] <= #32 do begin
//    if fLine[Run] in [#0, #10, #13] then break;
    if fLine[Run] in [#0, #9, #10, #13] then break;                             //hk 1999-06-02
    Inc(Run);
  end;
End;


{  }
Procedure ThkHTMLSyn.StringProc;
Begin
  If (fRange = rsValue) Then Begin
    fRange := rsParam;
    fTokenID := tkValue;
  End Else Begin
    fTokenID := tkString;
  End;
(*                                                                              //mh 1999-05-25
  Repeat
    Case FLine[Run] Of
    #0, #10, #13:
      Begin
        Break;
      End;
    End;
    Inc(Run);
  Until (FLine[Run] = '"');

  If (FLine[Run] <> #0) Then Begin
    Inc(Run);
  End;
*)
  Inc(Run);  // first '"'
  while not (fLine[Run] in [#0, #10, #13, '"']) do Inc(Run);
  if fLine[Run] = '"' then Inc(Run);  // last '"'
End;


{  }
(*                                                                              //mh 1999-09-12
Procedure ThkHTMLSyn.AssignAttributes(Attributes: TmwHighLightAttributes);
Begin
  If (fCanvas.Brush.Color <> Attributes.Background) Then Begin
    fCanvas.Brush.Color:= Attributes.Background;
  End;
  If (fCanvas.Font.Color <> Attributes.Foreground) Then Begin
    fCanvas.Font.Color:= Attributes.Foreground;
  End;
  If (fCanvas.Font.Style <> Attributes.Style) Then Begin
    fCanvas.Font.Style:= Attributes.Style;
  End;
(*
  fCanvas.Brush.Color:= Attributes.Background;
  fCanvas.Font.Color:= Attributes.Foreground;
  fCanvas.Font.Style:= Attributes.Style;
* )
End;
*)


{  }
Procedure ThkHTMLSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //gp 1999-05-05
Begin
  fTokenPos := Run;
  Case fRange Of
  rsText:
    Begin
      TextProc;
    End;
  rsComment:
    Begin
      CommentProc;
    End;
  rsASP:                                                                        //lad 1999-07-23
    Begin                                                                       //lad 1999-07-23
      ASPProc;                                                                  //lad 1999-07-23
    End;                                                                        //lad 1999-07-23
  Else
    fProcTable[fLine[Run]];
  End;
(*                                                                              //mh 1999-09-12
  If Assigned(fCanvas) Then Begin
    TokenID := GetTokenID;                                                      //gp 1999-05-05
    case TokenID of                                                             //gp 1999-05-05
      tkAmpersand:  AssignAttributes(fAndAttri);                                //hk 1999-06-03
      tkComment:    AssignAttributes(fCommentAttri);
      tkIdentifier: AssignAttributes(fIdentifierAttri);
      tkKey:        AssignAttributes(fKeyAttri);
      tkSpace:      AssignAttributes(fSpaceAttri);
      tkString:     AssignAttributes(fValueAttri);
      tkSymbol:     AssignAttributes(fSymbolAttri);
      tkText:       AssignAttributes(fTextAttri);
      tkUndefKey:   AssignAttributes(fUndefKeyAttri);                           //hk 1999-05-26
//      tkUnknown:    AssignAttributes(fSymbolAttri);                           //mh 1999-05-25
      tkValue:      AssignAttributes(fValueAttri);
    End;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-05-05 //mh 1999-08-22
  End;
*)
End;


{  }
Function ThkHTMLSyn.GetEol: Boolean;
Begin
(*                                                                              //mh 1999-05-25
  Result := False;
  If (fTokenId = tkNull) Then Begin
    Result := True;
  End;
*)
  Result := fTokenId = tkNull;
End;


{  }
Function ThkHTMLSyn.GetToken: String;
Var
  len: Longint;
Begin
  Len := (Run - fTokenPos);
  SetString(Result, (FLine + fTokenPos), len);
End;


{  }
Function ThkHTMLSyn.GetTokenID: TtkTokenKind;
Begin
  Result := fTokenId;
End;


function ThkHTMLSyn.GetTokenAttribute: TmwHighLightAttributes;                  //mh 1999-09-12
begin
  case fTokenID of
    tkAmpersand: Result := fAndAttri;
    tkASP: Result := fASPAttri;                                                 //lad 1999-07-23
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fValueAttri;
    tkSymbol: Result := fSymbolAttri;
    tkText: Result := fTextAttri;
    tkUndefKey: Result := fUndefKeyAttri;
    tkValue: Result := fValueAttri;
    else Result := nil;
  end;
end;

function ThkHTMLSyn.GetTokenKind: integer;                                      //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

{  }
Function ThkHTMLSyn.GetTokenPos: Integer;
Begin
  Result := fTokenPos;
End;


{  }
Function ThkHTMLSyn.GetRange: Pointer;
Begin
  Result := Pointer(fRange);
End;


{  }
Procedure ThkHTMLSyn.SetRange(Value: Pointer);
Begin
  fRange := TRangeState(Value);
End;


{  }
Procedure ThkHTMLSyn.ReSetRange;
Begin
  fRange:= rsText;
End;

{begin}                                                                         //mh 1999-08-22
(*
{  }
Procedure ThkHTMLSyn.HighLightChange(Sender:TObject);
Begin
  mwEditList.Invalidate;
End;
*)
{end}                                                                           //mh 1999-08-22

{  }
Function ThkHTMLSyn.GetIdentChars: TIdentChars;
Begin
  Result := ['0'..'9', 'a'..'z', 'A'..'Z'];                                     //hk 1999-06-20
//  Result := ['!', '/', '0'..'9', 'a'..'z', 'A'..'Z'];                           //hk 1999-05-10
End;

{begin}                                                                         //mh 1999-08-22
(*
{  }
Procedure ThkHTMLSyn.SetHighLightChange;
Begin
  fAndAttri.OnChange        := HighLightChange;                                 //hk 1999-06-03
  fCommentAttri.Onchange    := HighLightChange;
  fIdentifierAttri.Onchange := HighLightChange;
  fKeyAttri.Onchange        := HighLightChange;
  fSpaceAttri.Onchange      := HighLightChange;
  fSymbolAttri.Onchange     := HighLightChange;
  fTextAttri.Onchange       := HighLightChange;
  fUndefKeyAttri.Onchange   := HighLightChange;                                 //hk 1999-05-26
  fValueAttri.Onchange      := HighLightChange;
End;


{  }
Function ThkHTMLSyn.GetAttribCount: Integer;
Begin
  Result := 10;                                                                 //hk 1999-06-03
End;


{  }
Function ThkHTMLSyn.GetAttribute(Idx: Integer): TmwHighLightAttributes;
Begin
  Case Idx Of
  0: Result := fAndAttri;                                                       //hk 1999-06-03
  1: Result := fCommentAttri;
  2: Result := fIdentifierAttri;
  3: Result := fKeyAttri;
  4: Result := fSpaceAttri;
  5: Result := fValueAttri;
  6: Result := fSymbolAttri;
  7: Result := fTextAttri;
  8: Result := fUndefKeyAttri;                                                  //hk 1999-05-26
  9: Result := fValueAttri;
  Else
    Result := Nil;
  End;
End;
*)
{end}                                                                           //mh 1999-08-22

{  }
Function ThkHTMLSyn.GetLanguageName: String;
Begin
  Result := MWS_LangHTML;                                                       //mh 1999-09-24
End;


{  }
Function ThkHTMLSyn.GetCapability: THighlighterCapability;
Begin
  Result := Inherited GetCapability + [hcUserSettings, hcExportable];
End;


{  }
Procedure ThkHTMLSyn.SetLineForExport(NewValue: String);
Begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;
  ExportNext;
End;


{  }
Procedure ThkHTMLSyn.ExportNext;
Begin
  fTokenPos := Run;
  Case fRange Of
  rsText:
    Begin
      TextProc;
    End;
  rsComment:
    Begin
      CommentProc;
    End;
  Else
    fProcTable[fLine[Run]];
  End;

  If Assigned(Exporter) Then Begin
    With TmwCustomExport(Exporter) Do begin
      Case GetTokenID Of
        tkAmpersand:  FormatToken(GetToken, fAndAttri,        False, False);
        tkASP:        FormatToken(GetToken, fASPAttri,        True, False);     //hk 1999-09-21
        tkComment:    FormatToken(GetToken, fCommentAttri,    True,  False);
        tkIdentifier: FormatToken(GetToken, fIdentifierAttri, False, False);
        tkKey:        FormatToken(GetToken, fKeyAttri,        False, False);
        tkNull:       FormatToken('',       Nil,              False, False);
        tkSpace:      FormatToken(GetToken, fSpaceAttri,      False, True);
        tkString:     FormatToken(GetToken, fValueAttri,      True,  False);
        tkSymbol:     FormatToken(GetToken, fSymbolAttri,     True,  False);
        tkText:       FormatToken(GetToken, fTextAttri,       True,  False);
        tkValue:      FormatToken(GetToken, fValueAttri,      True,  False);
        tkUndefKey:   FormatToken(GetToken, fUndefKeyAttri,   True,  False);
      End;
    End;
  End;
End;


{  }
Procedure Register;
Begin
  RegisterComponents('mw', [ThkHTMLSyn]);
End;



Initialization
  MakeIdentTable;


End.

