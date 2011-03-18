Unit hkAWKSyn;
{+--------------------------------------------------------------------------+
 | Unit:        hkAWKSyn
 | Created:     03.99
 | Last change: 1999-09-24
 | Author:      Hideo Koiso (sprhythm@fureai.or.jp)
 | Copyright    1999, No rights reserved.
 | Description: A AWK HighLighter for Use with mwCustomEdit.
 | Version:     0.13
 | Status       Public Domain
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 |
 | Thanks to:   Primoz Gabrijelcic
 +--------------------------------------------------------------------------+}
// Regular-explession has not being highlighte yet.

{$I MWEDIT.INC}
Interface


Uses
  SysUtils,
  Windows,
  Messages,
  Classes,
  Controls,
  Graphics,
  RegisTry,
  mwHighlighter,
  mwExport,
  mwLocalStr;                                                                   //mh 1999-08-22


Type
  TtkTokenKind = (
    tkComment,
    tkIdentifier,
    tkInterFunc,
    tkKey,
    tkNull,
    tkNumber,
    tkSpace,
    tkString,
    tkSymbol,
    tkSysVar,
    tkUnknown
  );

  TRangeState = (rsUnKnown);


  TProcTableProc = Procedure Of Object;


  ThkAWKSyn = Class(TmwCustomHighLighter)
  Private
    AWKSyntaxList: TStringList;
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: Array[#0..#255] Of TProcTableProc;
    Run: Longint;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
//    fEol: Boolean;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fInterFuncAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fSysVarAttri: TmwHighLightAttributes;
    fLineNumber: Integer;                                                       //gp 1999-05-05
    Procedure AndProc;
//    Procedure AssignAttributes(Attributes: TmwHighLightAttributes);           //mh 1999-09-12
    Procedure CommentProc;
    Procedure CRProc;
    Procedure ExclamProc;
    Procedure FieldRefProc;
//    Procedure HighLightChange(Sender:TObject);                                //mh 1999-08-22
    Procedure IdentProc;
    Procedure LFProc;
    Procedure MakeMethodTables;
    Procedure MakeSyntaxList;
    Procedure MinusProc;
    Procedure NullProc;
    Procedure OpInputProc;
    Procedure OrProc;
    Procedure PlusProc;
    Procedure QuestionProc;
//    Procedure SetHighLightChange;                                             //mh 1999-08-22
    Procedure SpaceProc;
    Procedure StringProc;
    Procedure SymbolProc;
    Procedure NumberProc;
    Procedure BraceProc;
  Protected
    Function GetIdentChars: TIdentChars; override;
//    Function GetAttribCount: Integer; Override;                               //mh 1999-08-22
//    Function GetAttribute(Idx: Integer): TmwHighLightAttributes; Override;    //mh 1999-08-22
    Function GetCapability: THighlighterCapability; Override;
    Function GetLanguageName: String; Override;
  Public
    Constructor Create(AOwner: TComponent); Override;
    Destructor Destroy; Override;
    Function GetEol: Boolean; Override;
    Function GetRange: Pointer; Override;
    Function GetTokenID: TtkTokenKind;
    Function GetToken: String; Override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-12
    function GetTokenKind: integer; override;                                   //mh 1999-08-22
    Function GetTokenPos: Integer; Override;
    Procedure Next; Override;
    Procedure ReSetRange; Override;
//    Procedure SetCanvas(Value: TCanvas); Override;                            //mh 1999-09-12
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //gp 1999-05-05
    Procedure SetRange(Value: Pointer); Override;
    Procedure SetLineForExport(NewValue: String); Override;                     //hk 1999-06-14
    Procedure ExportNext; Override;                                             //hk 1999-06-14
  Published
    Property CommentAttri: TmwHighLightAttributes Read fCommentAttri Write fCommentAttri;
    Property IdentifierAttri: TmwHighLightAttributes Read fIdentifierAttri Write fIdentifierAttri;
    Property InterFuncAttri: TmwHighLightAttributes Read fInterFuncAttri Write fInterFuncAttri;
    Property KeyAttri: TmwHighLightAttributes Read fKeyAttri Write fKeyAttri;
    Property NumberAttri: TmwHighLightAttributes Read fNumberAttri Write fNumberAttri;
    Property SpaceAttri: TmwHighLightAttributes Read fSpaceAttri Write fSpaceAttri;
    Property SymbolAttri: TmwHighLightAttributes Read fSymbolAttri Write fSymbolAttri;
    Property SysVarAttri: TmwHighLightAttributes Read fSysVarAttri Write fSysVarAttri;
    Property StringAttri: TmwHighLightAttributes Read fStringAttri Write fStringAttri;
  End;



Var
  hkAWKLex: ThkAWKSyn;



Procedure Register;



Implementation


{  }
Procedure ThkAWKSyn.MakeSyntaxList;
Begin
  With AWKSyntaxList Do Begin

    Sorted := True;

    { *** Preferably sort and put previously. *** }
    AddObject('ARGC',       TObject(tkSysVar));
    AddObject('ARGIND',     TObject(tkSysVar));                { GNU Extention }
    AddObject('ARGV',       TObject(tkSysVar));
    AddObject('atan2',      TObject(tkInterFunc));
    AddObject('BEGIN',      TObject(tkKey));
    AddObject('break',      TObject(tkKey));
    AddObject('close',      TObject(tkInterFunc));
    AddObject('continue',   TObject(tkKey));
    AddObject('CONVFMT',    TObject(tkSysVar));              { POSIX Extention }
    AddObject('cos',        TObject(tkInterFunc));
    AddObject('delete',     TObject(tkInterFunc));
    AddObject('do',         TObject(tkKey));
    AddObject('else',       TObject(tkKey));
    AddObject('END',        TObject(tkKey));
    AddObject('ENVIRON',    TObject(tkSysVar));
    AddObject('ERRNO',      TObject(tkSysVar));                { GNU Extention }
    AddObject('exit',       TObject(tkKey));
    AddObject('exp',        TObject(tkInterFunc));
    AddObject('FIELDWIDTH', TObject(tkSysVar));                { GNU Extention }
    AddObject('FILENAME',   TObject(tkSysVar));
    AddObject('FNR',        TObject(tkSysVar));
    AddObject('for',        TObject(tkKey));
    AddObject('FS',         TObject(tkSysVar));
    AddObject('function',   TObject(tkKey));
    AddObject('getline',    TObject(tkKey));
    AddObject('gsub',       TObject(tkInterFunc));
    AddObject('if',         TObject(tkKey));
    AddObject('IGNORECASE', TObject(tkSysVar));
    AddObject('index',      TObject(tkInterFunc));
    AddObject('int',        TObject(tkInterFunc));
    AddObject('jindex',     TObject(tkInterFunc));                     { jgawk }
    AddObject('jlength',    TObject(tkInterFunc));                     { jgawk }
    AddObject('jsubstr',    TObject(tkInterFunc));                     { jgawk }
    AddObject('length',     TObject(tkInterFunc));
    AddObject('log',        TObject(tkInterFunc));
    AddObject('match',      TObject(tkInterFunc));
    AddObject('next',       TObject(tkUnknown)); { & next file (GNU Extention) }
    AddObject('NF',         TObject(tkSysVar));
    AddObject('NR',         TObject(tkSysVar));
    AddObject('OFMT',       TObject(tkSysVar));
    AddObject('OFS',        TObject(tkSysVar));
    AddObject('ORS',        TObject(tkSysVar));
    AddObject('print',      TObject(tkKey));
    AddObject('printf',     TObject(tkInterFunc));
    AddObject('rand',       TObject(tkInterFunc));
    AddObject('return',     TObject(tkKey));
    AddObject('RLENGTH',    TObject(tkSysVar));
    AddObject('RS',         TObject(tkSysVar));
    AddObject('RSTART',     TObject(tkSysVar));
    AddObject('sin',        TObject(tkInterFunc));
    AddObject('split',      TObject(tkInterFunc));
    AddObject('sprintf',    TObject(tkInterFunc));
    AddObject('sqrt',       TObject(tkInterFunc));
    AddObject('srand',      TObject(tkInterFunc));
    AddObject('strftime',   TObject(tkInterFunc));             { GNU Extention }
    AddObject('sub',        TObject(tkInterFunc));
    AddObject('SUBSEP',     TObject(tkSysVar));
    AddObject('substr',     TObject(tkInterFunc));
    AddObject('system',     TObject(tkInterFunc));
    AddObject('systime',    TObject(tkInterFunc));             { GNU Extention }
    AddObject('tolower',    TObject(tkInterFunc));
    AddObject('toupper',    TObject(tkInterFunc));
    AddObject('while',      TObject(tkKey));
  End;
End;


{  }
Procedure ThkAWKSyn.MakeMethodTables;
Var
  i: Char;
Begin
  For i:=#0 To #255 Do Begin
    Case i Of
    #0:
      fProcTable[i] := NullProc;
    #10:
      fProcTable[i] := LFProc;
    #13:
      fProcTable[i] := CRProc;
    #1..#9, #11, #12, #14..#32:
      fProcTable[i] := SpaceProc;
    '"', #$27:
      fProcTable[i] := StringProc;                                     { "..." }
    '(', ')', '[', ']':
      fProcTable[i] := BraceProc;                              { (, ), [ and ] }
    '#':
      fProcTable[i] := CommentProc;                                    { # ... }
    '$':
      fProcTable[i] := FieldRefProc;                                { $0 .. $9 }
    '+':
      fProcTable[i] := PlusProc;                                { +, ++ and += }
    '-':
      fProcTable[i] := MinusProc;                               { -, -- and -= }
    '!':
      fProcTable[i] := ExclamProc;                                  { ! and !~ }
    '?':
      fProcTable[i] := QuestionProc;                                      { ?: }
    '|':
      fProcTable[i] := OrProc;                                            { || }
    '&':
      fProcTable[i] := AndProc;                                           { && }
    '*', '/', '%', '^', '<', '=', '>':
      fProcTable[i] := OpInputProc;                      { *=, /=, %= ... etc. }
    'a'..'z', 'A'..'Z':
      fProcTable[i] := IdentProc;
    '0'..'9':
      fProcTable[i] := NumberProc;
    Else
      fProcTable[i] := SymbolProc;
    End;
  End;
End;



{  }
Procedure ThkAWKSyn.BraceProc;
Begin
  fTokenID := tkIdentifier;
  Inc(Run);
End;



{  }
Procedure ThkAWKSyn.NumberProc;
Begin
  fTokenID := tkNumber;
  Inc(Run);
  While (fLine[Run] In ['0'..'9']) Do Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.IdentProc;
Var
  i: Integer;
  idx: Integer;
  s: String;
Begin
  i := Run;
  While (fLine[i] In ['a'..'z', 'A'..'Z']) Do Begin
    Inc(i);
  End;
  SetLength(s, (i - Run));
  StrLCopy(PChar(s), (fLine+Run), (i - Run));
  Run := i;
  If AWKSyntaxList.Find(s, idx) And (AWKSyntaxList.Strings[idx] = s) Then Begin
    fTokenID := TtkTokenKind(AWKSyntaxList.Objects[idx]);
    If (fTokenID = tkUnKnown) Then Begin
      fTokenID := tkKey;
      If (fLine[i] = ' ') Then Begin
        While (fLine[i] = ' ') Do Begin
          Inc(i);
        End;
        If (fLine[i+0] = 'f') And
           (fLine[i+1] = 'i') And
           (fLine[i+2] = 'l') And
           (fLine[i+3] = 'e') And
           (fLine[i+4] In [#0..#32, ';']) Then Begin
           Run := (i + 4);
        End;
      End;
    End;
  End Else Begin
    fTokenID := tkIdentifier;
  End;
End;


{  }
Procedure ThkAWKSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //gp 1999-05-05
Begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
(*                                                                              //mh 1999-09-12
  If Assigned(fCanvas) Then Begin
    TokenID := GetTokenID;                                                      //gp 1999-05-05
    case TokenID of                                                             //gp 1999-05-05
      tkComment:    AssignAttributes(fCommentAttri);
      tkIdentifier: AssignAttributes(fIdentifierAttri);
      tkInterFunc:  AssignAttributes(fInterFuncAttri);
      tkKey:        AssignAttributes(fKeyAttri);
      tkNumber:     AssignAttributes(fNumberAttri);
      tkSpace:      AssignAttributes(fSpaceAttri);
      tkString:     AssignAttributes(fStringAttri);
      tkSymbol:     AssignAttributes(fSymbolAttri);
      tkSysVar:     AssignAttributes(fSysVarAttri);
    End;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-05-05 //mh 1999-08-22
  End;
*)  
End;


{  }
Procedure ThkAWKSyn.StringProc;
Begin
  Repeat
    Inc(Run);
    If (fLine[Run] = '"') And (fLine[Run-1] <> '\') Then Begin
      fTokenID := tkString;
      Inc(Run);
      Exit;
    End;
  Until (fLine[Run] In [#0..#31]);
  fTokenID := tkIdentifier;
End;


{  }
Procedure ThkAWKSyn.CommentProc;
Begin
  fTokenID := tkComment;
  While Not (fLine[Run] In [#0, #10, #13]) Do Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.FieldRefProc;
Begin
  Inc(Run);
  If (fLine[Run] In ['0'..'9']) And
     Not (fLine[Run+1] In ['0'..'9', 'a'..'z', 'A'..'Z']) Then Begin
    fTokenID := tkSymbol;
    Inc(Run);
  End Else Begin
    fTokenID := tkIdentifier;
  End;
End;


{  }
Procedure ThkAWKSyn.SymbolProc;
Begin
  fTokenID := tkSymbol;
  Inc(Run);
End;


{  }
Procedure ThkAWKSyn.PlusProc;
Begin
  fTokenID := tkSymbol;
  Inc(Run);
  If (fLine[Run] In ['+', '=']) Then Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.MinusProc;
Begin
  fTokenID := tkSymbol;
  Inc(Run);
  If (fLine[Run] In ['-', '=']) Then Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.OpInputProc;
Begin
  fTokenID := tkSymbol;
  Inc(Run);
  If (fLine[Run] = '=') Then Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.ExclamProc;
Begin
  fTokenID := tkSymbol;
  Inc(Run);
  If (fLine[Run] In ['=', '~']) Then Begin
    Inc(Run);
  End;
End;


{  }
Procedure ThkAWKSyn.QuestionProc;
Begin
  Inc(Run);
  If (fLine[Run] = ':') Then Begin
    fTokenID := tkSymbol;
    Inc(Run);
  End Else Begin
    fTokenID := tkIdentifier;
  End;
End;


{  }
Procedure ThkAWKSyn.OrProc;
Begin
  Inc(Run);
  If (fLine[Run] = '|') Then Begin
    fTokenID := tkSymbol;
    Inc(Run);
  End Else Begin
    fTokenID := tkIdentifier;
  End;
End;


{  }
Procedure ThkAWKSyn.AndProc;
Begin
  Inc(Run);
  If (fLine[Run] = '&') Then Begin
    fTokenID := tkSymbol;
    Inc(Run);
  End Else Begin
    fTokenID := tkIdentifier;
  End;
End;


{  }
Constructor ThkAWKSyn.Create(AOwner: TComponent);
Begin
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //mh 1999-08-22
  fCommentAttri.Foreground := clBlue;

  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);

  fInterFuncAttri :=  TmwHighLightAttributes.Create(MWS_AttrInternalFunction);
  fInterFuncAttri.Foreground := $00408080;
  fInterFuncAttri.Style := [fsBold];

  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);
  fKeyAttri.Foreground := $00FF0080;
  fKeyAttri.Style := [fsBold];

  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);

  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);

  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);
  fStringAttri.Foreground := clTeal;

  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  fSymbolAttri.Style := [fsBold];

  fSysVarAttri := TmwHighLightAttributes.Create(MWS_AttrSystemValue);
  fSysVarAttri.Foreground := $000080FF;
  fSysVarAttri.Style := [fsBold];


  Inherited Create(AOwner);

  AWKSyntaxList := TStringList.Create;
  MakeSyntaxList;

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fInterFuncAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
  AddAttribute(fSysVarAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22
  MakeMethodTables;
  fRange := rsUnknown;
  fDefaultFilter := MWS_FilterAWK;                                              //ajb 1999-09-14
End;


{  }
Destructor ThkAWKSyn.Destroy;
Begin
{begin}                                                                         //mh 1999-08-22
(*
  fCommentAttri.Free;
  fIdentifierAttri.Free;
  fInterFuncAttri.Free;
  fKeyAttri.Free;
  fNumberAttri.Free;
  fStringAttri.Free;
  fSpaceAttri.Free;
  fSymbolAttri.Free;
  fSysVarAttri.Free;
*)
{end}                                                                           //mh 1999-08-22
  AWKSyntaxList.Free;

  Inherited Destroy;
End;


(*                                                                              //mh 1999-09-12
{  }
Procedure ThkAWKSyn.SetCanvas(Value: TCanvas);
Begin
  fCanvas := Value;
End;
*)


{  }
procedure ThkAWKSyn.SetLine(NewValue: String; LineNumber:Integer);
Begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;
  fLineNumber := LineNumber;                                                    //gp 1999-05-05
  Next;
End;


{  }
Procedure ThkAWKSyn.CRProc;
Begin
  fTokenID := tkSpace;
{begin}                                                                         //mh 1999-08-22
  Inc(Run);
  if fLine[Run] = #10 then Inc(Run);
(*
  Case fLine[Run + 1] Of
  #10:
    Inc(Run, 2);
  Else
    Inc(Run);
  End;
*)
{end}                                                                           //mh 1999-08-22       
End;


{  }
Procedure ThkAWKSyn.LFProc;
Begin
  fTokenID := tkSpace;
  Inc(Run);
End;


{  }
Procedure ThkAWKSyn.NullProc;
Begin
  fTokenID := tkNull;
//  fEol := True;
End;


{  }
Procedure ThkAWKSyn.SpaceProc;
Begin
  Inc(Run);
  fTokenID := tkSpace;

  While (fLine[Run] In [#1..#9, #11, #12, #14..#32]) Do Begin
    Inc(Run);
  End;
End;


{  }
(*                                                                              //mh 1999-09-12
Procedure ThkAWKSyn.AssignAttributes(Attributes: TmwHighLightAttributes);
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
End;
*)

{  }
Function ThkAWKSyn.GetEol: Boolean;
Begin
{begin}                                                                         //mh 1999-08-22
(*
  Result := False;
  If (fTokenId = tkNull) Then Begin
    Result := True;
  End;
*)
  Result := fTokenID = tkNull;
{end}                                                                           //mh 1999-08-22    
End;


{  }
Function ThkAWKSyn.GetToken: String;
Var
  len: Longint;
Begin
  len := (Run - fTokenPos);
  SetString(Result, (fLine + fTokenPos), len);
End;


{  }
Function ThkAWKSyn.GetTokenID: TtkTokenKind;
Begin
  Result := fTokenId;
End;


function ThkAWKSyn.GetTokenAttribute: TmwHighLightAttributes;                   //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkInterFunc: Result := fInterFuncAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkSysVar: Result := fSysVarAttri;
    else Result := nil;
  end;
end;

function ThkAWKSyn.GetTokenKind: integer;                                       //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

{  }
Function ThkAWKSyn.GetTokenPos: Integer;
Begin
  Result := fTokenPos;
End;


{  }
Function ThkAWKSyn.GetRange: Pointer;
Begin
  Result := Pointer(fRange);
End;


{  }
Procedure ThkAWKSyn.SetRange(Value: Pointer);
Begin
  fRange := TRangeState(Value);
End;


{  }
Procedure ThkAWKSyn.ReSetRange;
Begin
  fRange:= rsUnknown;
End;

{begin}                                                                         //mh 1999-08-22
(*
{  }
Procedure ThkAWKSyn.HighLightChange(Sender:TObject);
Begin
  mwEditList.Invalidate;
End;
*)
{end}                                                                           //mh 1999-08-22

{  }
Function ThkAWKSyn.GetIdentChars: TIdentChars;
Begin
  Result := ['0'..'9', 'a'..'z', 'A'..'Z'];
End;

{begin}                                                                         //mh 1999-08-22
(*
{  }
Procedure ThkAWKSyn.SetHighLightChange;
Begin
  fCommentAttri.Onchange     := HighLightChange;
  fIdentifierAttri.Onchange  := HighLightChange;
  fInterFuncAttri.Onchange   := HighLightChange;
  fKeyAttri.Onchange         := HighLightChange;
  fNumberAttri.Onchange      := HighLightChange;
  fSpaceAttri.Onchange       := HighLightChange;
  fSymbolAttri.Onchange      := HighLightChange;
  fStringAttri.Onchange      := HighLightChange;
  fSysVarAttri.Onchange      := HighLightChange;
End;


{  }
Function ThkAWKSyn.GetAttribCount: Integer;
Begin
  Result := 9;
End;


{  }
Function ThkAWKSyn.GetAttribute(Idx: Integer): TmwHighLightAttributes;
Begin
  Case Idx Of
  0: Result := fCommentAttri;
  1: Result := fIdentifierAttri;
  2: Result := fInterFuncAttri;
  3: Result := fKeyAttri;
  4: Result := fNumberAttri;
  5: Result := fSpaceAttri;
  6: Result := fSymbolAttri;
  7: Result := fStringAttri;
  8: Result := fSysVarAttri;
  Else
    Result := Nil;
  End;
End;
*)
{end}                                                                           //mh 1999-08-22

{  }
Function ThkAWKSyn.GetLanguageName: String;
Begin
  Result := MWS_LangAWK;                                                        //mh 1999-09-24
End;


{  }
Function ThkAWKSyn.GetCapability: THighlighterCapability;
Begin
//  Result := Inherited GetCapability + [hcUserSettings];                       //hk 1999-06-14
  Result := Inherited GetCapability + [hcUserSettings, hcExportable];
End;


{  }
Procedure ThkAWKSyn.SetLineForExport(NewValue: String);                         //hk 1999-06-14
Begin
  fLine := PChar(NewValue);
  Run := 0;
//  fEol := False;
  ExportNext;
End;


{  }
Procedure ThkAWKSyn.ExportNext;                                                 //hk 1999-06-14
Begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];

  If Assigned(Exporter) Then Begin
    With TmwCustomExport(Exporter) Do begin
      Case GetTokenID Of
        tkComment:    FormatToken(GetToken, fCommentAttri,    False, False);
        tkIdentifier: FormatToken(GetToken, fIdentifierAttri, False, False);
        tkInterFunc:  FormatToken(GetToken, fInterFuncAttri,  False, False);
        tkKey:        FormatToken(GetToken, fKeyAttri,        False, False);
        tkNull:       FormatToken(GetToken, Nil,              False, False);
        tkNumber:     FormatToken(GetToken, fNumberAttri,     False, False);
        tkSpace:      FormatToken(GetToken, fSpaceAttri,      False, True);
        tkString:     FormatToken(GetToken, fStringAttri,     False, False);
        tkSymbol:     FormatToken(GetToken, fSymbolAttri,     False, False);
        tkSysVar:     FormatToken(GetToken, fSysVarAttri,     False, False);
      End;  
    End;
  End;
End;


{  }
Procedure Register;
Begin
  RegisterComponents('mw', [ThkAWKSyn]);
End;


End.

