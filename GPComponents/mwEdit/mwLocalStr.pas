{+-----------------------------------------------------------------------------+
 | Unit:        mwLocalStr
 | Created:     1999-08
 | Version:     0.86
 | Last change: 1999-09-25
 | Description: put all strings that might need localisation into this unit
 +----------------------------------------------------------------------------+}

unit mwLocalStr;

{$I MWEDIT.INC}

interface

{$IFDEF MWE_COMPILER_3_UP}
resourcestring
{$ELSE}
const
{$ENDIF}

{begin}                                                                         //sva 1999-09-16, Changed first chars to uppercase
  // names for highlighter attributes - general
  MWS_AttrAssembler            =  'Assembler';
  MWS_AttrAsm                  =  'Asm';
  MWS_AttrComment              =  'Comment';
  MWS_AttrIdentifier           =  'Identifier';
  MWS_AttrKey                  =  'Key';                                        //mh 1999-09-22
  MWS_AttrNumber               =  'Number';
  MWS_AttrOperator             =  'Operator';
  MWS_AttrPreprocessor         =  'Preprocessor';
  MWS_AttrReservedWord         =  'Reserved word';
  MWS_AttrSpace                =  'Space';
  MWS_AttrSymbol               =  'Symbol';
  MWS_AttrString               =  'String';
  MWS_AttrText                 =  'Text';

  // names for highlighter attributes - special
  MWS_AttrAsmComment           =  'Asm comment';
  MWS_AttrAsmKey               =  'Asm key';
  MWS_AttrASP                  =  'Asp';
  MWS_AttrDocumentation        =  'Documentation';
  MWS_AttrEscapeAmpersand      =  'Escape ampersand';
  MWS_AttrIllegalChar          =  'Illegal char';
  MWS_AttrInvalidSymbol        =  'Invalid symbol';
  MWS_AttrInternalFunction     =  'Internal function';
  MWS_AttrMessage              =  'Message';
  MWS_AttrNull                 =  'Null';
  MWS_AttrPragma               =  'Pragma';
  MWS_AttrRpl                  =  'Rpl';
  MWS_AttrRplKey               =  'Rpl key';
  MWS_AttrRplComment           =  'Rpl comment';
  MWS_AttrSecondReservedWord   =  'Second reserved word';
  MWS_AttrSystemValue          =  'System value';
  MWS_AttrUnknownWord          =  'Unknown word';
  MWS_AttrValue                =  'Value';
  MWS_AttrVariable             =  'Variable';
  MWS_AttrIcon                 =  'Icon reference';                             //sva 1999-09-16
  MWS_AttrBrackets             =  'Brackets';                                   //sva 1999-09-24
  MWS_AttrMiscellaneous        =  'Miscellaneous';                              //sva 1999-09-24
  MWS_AttrSystem               =  'System functions and variables';             //sva 1999-09-25
  MWS_AttrUser                 =  'User functions and variables';               //sva 1999-09-25
{end}                                                                           //sva 1999-09-16

  // mwCustomEdit scroll hint window caption
  MWS_ScrollInfoFmt            =  'TopLine: %d';

{begin}                                                                         //ajb 1999-09-14
  // Filters used for open/save dialog
  MWS_FilterPascal             =  'Pascal files (*.pas,*.dpr,*.dpk,*.inc)|*.pas;*.dpr;*.dpk;*.inc';
  MWS_FilterHP48               =  'HP48 files (*.s,*.sou,*.a,*.hp)|*.s;*.sou;*.a;*.hp';
  MWS_FilterCAClipper          =  'CA-Clipper files (*.prg, *.ch, *.inc)|*.prg;*.ch;*.inc';
  MWS_FilterCPP                =  'C++ files (*.cpp,*.h,*.hpp)|*.cpp;*.h;*.hpp';
  MWS_FilterJava               =  'Java files (*.java)|*.java';
  MWS_FilterPerl               =  'Perl files (*.pl,*.pm,*.cgi)|*.pl;*.pm;*.cgi';
  MWS_FilterAWK                =  'AWK Script (*.awk)|*.awk';
  MWS_FilterHTML               =  'HTML Document (*.htm,*.html)|*.htm;*.html';
  MWS_FilterVBScript           =  'VBScript files (*.vbs)|*.vbs';
  MWS_FilterGalaxy             =  'Galaxy files (*.gtv,*.galrep,*.txt)|*.gtv;*.galrep;*.txt';
  MWS_FilterPython             =  'Python files (*.py)|*.py';
  MWS_FilterSQL                =  'SQL files (*.sql)|*.sql';
  MWS_FilterHP                 =  'HP48 files (*.s,*.sou,*.a,*.hp)|*.S;*.SOU;*.A;*.HP';
  MWS_FilterTclTk              =  'Tcl/Tk files (*.tcl)|*.tcl';
  MWS_FilterRTF                =  'Rich Text Format (*.rtf)|*.rtf';
  MWS_FilterBatch              =  'MS-DOS Batch Files (*.bat)|*.bat';           //mh 1999-09-22
  MWS_FilterDFM                =  'Delphi/C++ Builder Form Files (*.dfm)|*.dfm';//mh 1999-09-22
  MWS_FilterX86Asm             =  'x86 Assembly Files (*.asm)|*.ASM';           //mh 1999-09-24
{end}                                                                           //ajb 1999-09-14

{begin}                                                                         //mh 1999-09-24
  // Language names. Maybe somebody wants them translated / more detailed...
  MWS_LangHP48                 =  'HP48';
  MWS_LangCAClipper            =  'CA-Clipper';
  MWS_LangCPP                  =  'C++';
  MWS_LangJava                 =  'Java';
  MWS_LangPerl                 =  'Perl';
  MWS_LangBatch                =  'MS-DOS Batch Language';
  MWS_LangDfm                  =  'Delphi/C++ Builder Form Definitions';
  MWS_LangAWK                  =  'AWK Script';
  MWS_LangHTML                 =  'HTML Document';
  MWS_LangVBSScript            =  'MS VBScript';
  MWS_LangGalaxy               =  'Galaxy';
  MWS_LangGeneral              =  'General';
  MWS_LangPascal               =  'ObjectPascal';
  MWS_LangX86Asm               =  'x86 Assembly Language';
  MWS_LangPython               =  'Python';
  MWS_LangTclTk                =  'Tcl/Tk';
  MWS_LangSQL                  =  'SQL';

  // Exporter names.
  MWS_ExportHTML               =  'HTML';
  MWS_ExportRTF                =  'RTF';
{end}                                                                           //mh 1999-09-24

implementation

end.
