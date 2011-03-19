{Created by mwSynGen}
{+--------------------------------------------------------------------------+
 | Unit:        mwGeneralSyn
 | Created:     12.98
 | Last change: 1999-09-24
 | Author:      Martin Waldenburg
 | Copyright    1998, No rights reserved.
 | Description: A general HighLighter for Use with mwCustomEdit.
 |              The KeyWords in the string list KeyWords have to be UpperCase and sorted.
 | Version:     0.70
 | Status       Public Domain
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 |
 | Thanks to: Primoz Gabrijelcic, James Jacobson, Kees van Spelde, Andy Jeffries
 |
 | Version history: see version.rtf
 |
 +--------------------------------------------------------------------------+}
unit mwGeneralSyn;

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
  TCommentStyle = (csAnsiStyle, csPasStyle, csCStyle, csAsmStyle, csBasStyle);  //kvs 98-12-31
  //added csAsmStyle and csBasStyle to TCommentStyle
  CommentStyles = Set of TCommentStyle;
  TRangeState = (rsANil, rsAnsi, rsPasStyle, rsCStyle, rsUnKnown);
  TStringDelim = (sdSingleQuote, sdDoubleQuote);                                //gp 1999-08-27

  TProcTableProc = procedure of Object;

type
  TmwGeneralSyn = class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-12
    fRange: TRangeState;
    fLine: PChar;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fLineNumber : Integer;
    // Update GetAttribCount and GetAttribute if you add/remove/modify attributes.
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyWords: TStrings;
    fComments: CommentStyles;
    fStringDelimCh: char;                                                       //gp 1999-08-27
    procedure AsciiCharProc;
    procedure BraceOpenProc;
    procedure PointCommaProc;                                                   //kvs 98-12-31
    procedure CRProc;
    procedure IdentProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure NullProc;
    procedure NumberProc;
    procedure RoundOpenProc;
    procedure SlashProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure UnknownProc;
    procedure MakeMethodTables;
    function IsKeyWord(aToken: String): Boolean;
    procedure AnsiProc;
    procedure PasStyleProc;
    procedure CStyleProc;
    procedure SetKeyWords(const Value: TStrings);
//    procedure HighLightChange(Sender:TObject);                                  //gp 1998-12-22 //mh 1999-08-22
//    procedure SetHighLightChange;                                               //gp 1998-12-22 //mh 1999-08-22
    procedure SetComments(Value: CommentStyles);                                //jdj 1998-12-22
    function GetStringDelim: TStringDelim;                                      //gp 1999-08-27
    procedure SetStringDelim(const Value: TStringDelim);                        //jdj 1998-12-22 //gp 1999-08-27
  protected
    function GetLanguageName: string; override;                                 //gp 1998-12-24, //gp 1999-1-10 - renamed
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
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
    function SaveToRegistry(RootKey: HKEY; Key: string): boolean; override;     //gp 1998-12-28
    function LoadFromRegistry(RootKey: HKEY; Key: string): boolean; override;   //gp 1998-12-28
  published
    property Comments: CommentStyles read fComments write SetComments;          //jdj 1998-12-22 - added Set
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property KeyWords: TStrings read fKeyWords write SetKeyWords;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
    property StringDelim: TStringDelim read GetStringDelim write SetStringDelim //gp 1999-08-27
               default sdSingleQuote;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TmwGeneralSyn]);
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
    Case I in ['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

function TmwGeneralSyn.IsKeyWord(aToken: String): Boolean;
var
  First, Last, I, Compare: Integer;
  Token: String;
begin
  First := 0;
  Last := fKeywords.Count - 1;
  Result := False;
  Token := UpperCase(aToken);
  while First <= Last do
  begin
    I := (First + Last) shr 1;
    Compare := CompareStr(fKeywords[i], Token);
    if Compare = 0 then
    begin
      Result := True;
      break;
    end
    else
      if Compare < 0 then First := I + 1 else Last := I - 1;
  end;
end; { IsKeyWord }

procedure TmwGeneralSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '#': fProcTable[I] := AsciiCharProc;
      '{': fProcTable[I] := BraceOpenProc;
      ';': fProcTable[I] := PointCommaProc;                                      //kvs 12/31/98
      #13: fProcTable[I] := CRProc;
      'A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      '$': fProcTable[I] := IntegerProc;
      #10: fProcTable[I] := LFProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '(': fProcTable[I] := RoundOpenProc;
      '/': fProcTable[I] := SlashProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
//      #39: fProcTable[I] := StringProc;                                       //gp 1999-08-27
    else fProcTable[I] := UnknownProc;
    end;
  fProcTable[fStringDelimCh] := StringProc;                                     //gp 1999-08-27
end;

constructor TmwGeneralSyn.Create(AOwner: TComponent);
begin
  fKeyWords := TStringList.Create;
  TStringList(fKeyWords).Sorted := True;                                        //jdj 1998-12-22
  TStringList(fKeyWords).Duplicates := dupIgnore;                               //jdj 1998-12-22
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style := [fsBold];
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);                //gp 1998-12-24
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);                //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  inherited Create(AOwner);

{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fNumberAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fStringAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22

  fStringDelimCh := '''';                                                       //gp 1999-08-27
  MakeMethodTables;
  fRange := rsUnknown;
end; { Create }

destructor TmwGeneralSyn.Destroy;
begin
  fKeyWords.Free;
  inherited Destroy;
end; { Destroy }

(*                                                                              //mh 1999-09-12
procedure TmwGeneralSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TmwGeneralSyn.SetLine(NewValue: String; LineNumber:Integer);          //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TmwGeneralSyn.AnsiProc;
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
          fRange := rsUnKnown;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwGeneralSyn.PasStyleProc;
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
          fRange := rsUnKnown;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwGeneralSyn.CStyleProc;
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
        if fLine[Run + 1] = '/' then
        begin
          fRange := rsUnKnown;
          inc(Run, 2);
          break;
        end else inc(Run);
      #10: break;

      #13: break;
    else inc(Run);
    end;
end;

procedure TmwGeneralSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  inc(Run);
  while FLine[Run] in ['0'..'9'] do inc(Run);
end;

procedure TmwGeneralSyn.BraceOpenProc;
begin
  if csPasStyle in fComments then
  begin
    fTokenID := tkComment;
    fRange := rsPasStyle;
    inc(Run);
    while FLine[Run] <> #0 do
      case FLine[Run] of
        '}':
          begin
            fRange := rsUnKnown;
            inc(Run);
            break;
          end;
        #10: break;

        #13: break;
      else inc(Run);
      end;
  end else
  begin
    inc(Run);
    fTokenID := tkSymbol;
  end;
end;

procedure TmwGeneralSyn.PointCommaProc;                                         //kvs 98-12-31
begin
  if (csASmStyle in fComments) or (csBasStyle in fComments) then
  begin
    fTokenID := tkComment;
    fRange := rsUnknown;
    inc(Run);
    while FLine[Run] <> #0 do
      begin
        fTokenID := tkComment;
        inc(Run);
      end;
  end else
  begin
    inc(Run);
    fTokenID := tkSymbol;
  end;
end;

procedure TmwGeneralSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);                                                                     //mh 1999-08-30
  if fLine[Run] = #10 then Inc(Run);
end;

procedure TmwGeneralSyn.IdentProc;
begin
  while Identifiers[fLine[Run]] do inc(Run);
  if IsKeyWord(GetToken) then fTokenId := tkKey else fTokenId := tkIdentifier;
end;

procedure TmwGeneralSyn.IntegerProc;
begin
  inc(Run);
  fTokenID := tkNumber;
  while FLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f'] do inc(Run);
end;

procedure TmwGeneralSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TmwGeneralSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TmwGeneralSyn.NumberProc;
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

procedure TmwGeneralSyn.RoundOpenProc;
begin
  inc(Run);
  if csAnsiStyle in fComments then
  begin
    case fLine[Run] of
      '*':
        begin
          fTokenID := tkComment;
          fRange := rsAnsi;
          inc(Run);
          while fLine[Run] <> #0 do
            case fLine[Run] of
              '*':
                if fLine[Run + 1] = ')' then
                begin
                  fRange := rsUnKnown;
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
        end;
    else
      begin
        FTokenID := tkSymbol;
      end;
    end;
  end else fTokenId := tkSymbol;
end;

procedure TmwGeneralSyn.SlashProc;
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
    '*':
      begin
        if csCStyle in fComments then
        begin
          fTokenID := tkComment;
          fRange := rsCStyle;
          inc(Run);
          while fLine[Run] <> #0 do
            case fLine[Run] of
              '*':
                if fLine[Run + 1] = '/' then
                begin
                  fRange := rsUnKnown;
                  inc(Run, 2);
                  break;
                end else inc(Run);
              #10: break;
              #13: break;
            else inc(Run);
            end;
        end
        else
          begin                                                                 //kvs 98-12-31
            inc(Run);    //added inc(Run)
            fTokenId := tkSymbol;
          end;
      end;
  else
    begin
      inc(Run);
      fTokenID := tkSymbol;
    end;
  end;
end;

procedure TmwGeneralSyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TmwGeneralSyn.StringProc;
begin
  fTokenID := tkString;
//  if (FLine[Run + 1] = #39) and (FLine[Run + 2] = #39) then inc(Run, 2);      //gp 1999-08-27
  if (fLine[Run + 1] = fStringDelimCh) and (fLine[Run + 2] = fStringDelimCh) then Inc(Run, 2);
  repeat
    case FLine[Run] of
      #0, #10, #13: break;
    end;
    inc(Run);
  until FLine[Run] = #39;
  if FLine[Run] <> #0 then inc(Run);
end;

procedure TmwGeneralSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnKnown;
end;

procedure TmwGeneralSyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //aj 1999-02-22
begin
  fTokenPos := Run;
  Case fRange of
    rsAnsi: AnsiProc;
    rsPasStyle: PasStyleProc;
    rsCStyle: CStyleProc;
  else fProcTable[fLine[Run]];
  end;
(*                                                                              //mh 1999-09-12
  if Assigned(fCanvas) then begin
    TokenID := GetTokenID;                                                      //aj 1999-02-22
    case TokenID of                                                             //aj 1999-02-22
      tkComment:
        with fCanvas do
        begin
          Brush.Color := fCommentAttri.Background;
          Font.Color := fCommentAttri.Foreground;
          Font.Style := fCommentAttri.Style;
        end;
      tkIdentifier:
        with fCanvas do
        begin
          Brush.Color := fIdentifierAttri.Background;
          Font.Color := fIdentifierAttri.Foreground;
          Font.Style := fIdentifierAttri.Style;
        end;
      tkKey:
        with fCanvas do
        begin
          Brush.Color := fKeyAttri.Background;
          Font.Color := fKeyAttri.Foreground;
          Font.Style := fKeyAttri.Style;
        end;
      tkNumber:
        with fCanvas do
        begin
          Brush.Color := fNumberAttri.Background;
          Font.Color := fNumberAttri.Foreground;
          Font.Style := fNumberAttri.Style;
        end;
      tkSpace:
        with fCanvas do
        begin
          Brush.Color := fSpaceAttri.Background;
          Font.Color := fSpaceAttri.Foreground;
          Font.Style := fSpaceAttri.Style;
        end;
      tkString:
        with fCanvas do
        begin
          Brush.Color := fStringAttri.Background;
          Font.Color := fStringAttri.Foreground;
          Font.Style := fStringAttri.Style;
        end;
      tkSymbol:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
      tkUnknown:
        with fCanvas do
        begin
          Brush.Color := fSymbolAttri.Background;
          Font.Color := fSymbolAttri.Foreground;
          Font.Style := fSymbolAttri.Style;
        end;
    end;
//    DoOnToken(Ord(TokenID), GetToken, fLineNumber);                             //gp 1999-02-27 //mh 1999-08-22
  end;
*)
end;

function TmwGeneralSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TmwGeneralSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TmwGeneralSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TmwGeneralSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TmwGeneralSyn.GetTokenAttribute: TmwHighLightAttributes;               //mh 1999-09-12
begin
  case fTokenID of
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

function TmwGeneralSyn.GetTokenKind: integer;                                   //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TmwGeneralSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TmwGeneralSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TmwGeneralSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //jdj 1998-12-22 - rewritten
procedure TmwGeneralSyn.SetKeyWords(const Value: TStrings);
var
  i: Integer;
begin
  if Value <> nil then
    begin 
      Value.BeginUpdate;
      for i := 0 to Value.Count - 1 do
        Value[i] := UpperCase(Value[i]);
      Value.EndUpdate;
    end;
  fKeyWords.Assign(Value);
  DefHighLightChange(nil);
end;
{end}                                                                           //jdj 1998-12-22

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-22
procedure TmwGeneralSyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TmwGeneralSyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fNumberAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fStringAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
{end}                                                                           //gp 1998-12-22
*)
{end}                                                                           //mh 1999-08-22

{begin}                                                                         //jdj 1998-12-22
procedure TmwGeneralSyn.SetComments(Value: CommentStyles);
begin
  fComments := Value;
  DefHighLightChange(nil);
end;
{end}                                                                           //jdj 1998-12-22

{begin}                                                                         //mh 1999-08-22
(*
{begin}                                                                         //gp 1998-12-24
function TmwGeneralSyn.GetAttribCount: integer;
begin
  Result := 7;
end;

function TmwGeneralSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fNumberAttri;
    3: Result := fKeyAttri;
    4: Result := fSpaceAttri;
    5: Result := fStringAttri;
    6: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TmwGeneralSyn.GetLanguageName: string;                                 //gp 1999-1-10 - renamed
begin
  Result := MWS_LangGeneral;                                                    //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

function TmwGeneralSyn.LoadFromRegistry(RootKey: HKEY; Key: string): boolean;   //gp 1998-12-28
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKeyReadOnly(Key) then begin
      if r.ValueExists('KeyWords') then KeyWords.Text:= r.ReadString('KeyWords');
      Result := inherited LoadFromRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

function TmwGeneralSyn.SaveToRegistry(RootKey: HKEY; Key: string): boolean;     //gp 1998-12-28
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKey(Key,true) then begin
      Result := true;
      r.WriteString('KeyWords', KeyWords.Text);
      Result := inherited SaveToRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

{begin}                                                                         //gp 1999-08-27
function TmwGeneralSyn.GetStringDelim: TStringDelim;
begin
  if fStringDelimCh = ''''
    then Result := sdSingleQuote
    else Result := sdDoubleQuote;
end;

procedure TmwGeneralSyn.SetStringDelim(const Value: TStringDelim);
var
  newCh: char;
begin
  case Value of
    sdSingleQuote: newCh := '''';
    else newCh := '"';
  end; //case
  if newCh <> fStringDelimCh then begin
    fStringDelimCh := newCh;
    MakeMethodTables;
  end;
end;
{end}                                                                           //gp 1999-08-27

Initialization
  MakeIdentTable;
end.

