{+--------------------------------------------------------------------------+
 | Unit:        mkGalaxySyn
 | Created:     05.99
 | Last change: 1999-09-24
 | Author:      Martijn van der Kooij
 | Copyright    1998, No rights reserved.
 | Description: A galaxy HighLighter for Use with mwCustomEdit.
 |              The KeyWords in the string list KeyWords have to be UpperCase and sorted.
 |              Galaxy is a PBEM game for 10 to 500+ players.
 |              To see it working: http://members.tripod.com/~erisande/kooij.html
 | Version:     0.72
 | Status       Public Domain
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 |
 | Thanks to: Martin Waldenburg, Primoz Gabrijelcic
 +--------------------------------------------------------------------------+}
unit mkGalaxySyn;

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
    tkSpace,
    tkMessage,
    tkUnknown);
  TRangeState = (rsUnKnown, rsMessageStyle);
  TProcTableProc = procedure of Object;

type
  TmkGalaxySyn = class(TmwCustomHighLighter)
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
    fMessageAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fCommentAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyWords: TStrings;
    procedure PointCommaProc;                                                   //kvs 98-12-31
    procedure CRProc;
    procedure IdentProc;
    procedure LFProc;
    procedure NullProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure UnknownProc;
    procedure MakeMethodTables;
    function IsKeyWord(aToken: String): Boolean;
    procedure MessageStyleProc;
    procedure SetKeyWords(const Value: TStrings);
//    procedure HighLightChange(Sender:TObject);                                  //gp 1998-12-22 //mh 1999-08-22
//    procedure SetHighLightChange;                                               //gp 1998-12-22 //mh 1999-08-22
  protected
    function GetLanguageName: string; override;                                 //gp 1998-12-24, //gp 1999-1-10 - renamed
//    function GetAttribCount: integer; override;                                 //gp 1998-12-24 //mh 1999-08-22
//    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-24 //mh 1999-08-22
    function GetCapability: THighlighterCapability; override;                   //mvdk 1999-06-11
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ExportNext;override;                                              //mvdk 1999-06-11
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
    procedure SetLineForExport(NewValue: String); override;                     //mvdk 1999-06-11
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    function SaveToRegistry(RootKey: HKEY; Key: string): boolean; override;     //gp 1998-12-28
    function LoadFromRegistry(RootKey: HKEY; Key: string): boolean; override;   //gp 1998-12-28
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property KeyWords: TStrings read fKeyWords write SetKeyWords;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property MessageAttri: TmwHighLightAttributes read fMessageAttri write fMessageAttri;
//    property SymbolAttri: TmwHighLightAttributes read fSymbolAttri write fSymbolAttri;
  end;

procedure Register;

implementation

uses mwExport;                                                                  //mvdk 1999-06-11

procedure Register;
begin
  RegisterComponents('mw', [TmkGalaxySyn]);
end;

procedure MakeIdentTable;
var
  I, J: Char;
begin
  for I := #0 to #255 do
  begin
    Case I of
      '_', '0'..'9', 'a'..'z', 'A'..'Z', '#': Identifiers[I] := True;
    else Identifiers[I] := False;
    end;
    J := UpperCase(I)[1];
    Case I in ['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

function TmkGalaxySyn.IsKeyWord(aToken: String): Boolean;
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

procedure TmkGalaxySyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      ';': fProcTable[I] := PointCommaProc;                                      //kvs 12/31/98
      #13: fProcTable[I] := CRProc;
      '#','A'..'Z', 'a'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      #0: fProcTable[I] := NullProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      '@': fProcTable[I] := StringProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TmkGalaxySyn.Create(AOwner: TComponent);
begin
  fKeyWords := TStringList.Create;
  TStringList(fKeyWords).Sorted := True;                                        //jdj 1998-12-22
  TStringList(fKeyWords).Duplicates := dupIgnore;                               //jdj 1998-12-22
  TStringList(fKeyWords).CommaText :=
    '#END,#GALAXY,A,ANONYMOUS,AUTOUNLOAD,B,BATTLEPROTOCOL,C,CAP,CARGO,COL,' +
    'COMPRESS,D,DRIVE,E,EMP,F,FLEET,FLEETTABLES,G,GALAXYTV,GPLUS,GROUPFORECAST,' +
    'H,I,J,L,M,MACHINEREPORT,MAT,N,NAMECASE,NO,O,OPTIONS,P,PLANETFORECAST,' +
    'PRODTABLE,PRODUCE,Q,R,ROUTESFORECAST,S,SEND,SHIELDS,SHIPTYPEFORECAST,' +
    'SORTGROUPS,T,TWOCOL,U,UNDERSCORES,V,W,WAR,WEAPONS,X,Y,Z';
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);              //gp 1998-12-24 //mh 1999-08-22
  fCommentAttri.Style := [fsItalic];
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);        //gp 1998-12-24
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrReservedWord);             //gp 1998-12-24
  fKeyAttri.Style := [fsBold];
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);                  //gp 1998-12-24
  fMessageAttri := TmwHighLightAttributes.Create(MWS_AttrMessage);              //gp 1998-12-24
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);                //gp 1998-12-24
  inherited Create(AOwner);
{begin}                                                                         //mh 1999-08-22
  AddAttribute(fCommentAttri);
  AddAttribute(fIdentifierAttri);
  AddAttribute(fKeyAttri);
  AddAttribute(fSpaceAttri);
  AddAttribute(fMessageAttri);
  AddAttribute(fSymbolAttri);
//  SetHighlightChange;
  SetAttributesOnChange(DefHighlightChange);
{end}                                                                           //mh 1999-08-22  
  MakeMethodTables;
  fRange := rsUnknown;
  fDefaultFilter := MWS_FilterGalaxy;                                           //ajb 1999-09-14
end; { Create }

destructor TmkGalaxySyn.Destroy;
begin
  fKeyWords.Free;
  inherited Destroy;
end; { Destroy }

(*                                                                              //mh 1999-09-12
procedure TmkGalaxySyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end; { SetCanvas }
*)

procedure TmkGalaxySyn.SetLine(NewValue: String; LineNumber:Integer);          //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

procedure TmkGalaxySyn.MessageStyleProc;
begin
  fTokenID := tkMessage;
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

{begin}                                                                         //mvdk 1999-06-11
(*
  while FLine[Run] <> #0 do
    case FLine[Run] of
      '@':
        begin
          fRange := rsUnKnown;
          inc(Run);
          break;
        end;
      #10: break;

      #13: break;
    else inc(Run);
    end;
*)
  if (Run = 0) and (FLine[Run] = '@') then begin
    fRange := rsUnKnown;
    inc(Run);
  end else
    while FLine[Run] <> #0 do
      inc(Run);
{end}                                                                           //mvdk 1999-06-11
end;

procedure TmkGalaxySyn.PointCommaProc;                                         //kvs 98-12-31
begin
  fTokenID := tkComment;
  fRange := rsUnknown;
  inc(Run);
  while FLine[Run] <> #0 do begin
    fTokenID := tkComment;
    inc(Run);
  end;
end;

procedure TmkGalaxySyn.CRProc;
begin
  fTokenID := tkSpace;
  Case FLine[Run + 1] of
    #10: inc(Run, 2);
  else inc(Run);
  end;
end;

procedure TmkGalaxySyn.IdentProc;
begin
  while Identifiers[fLine[Run]] do inc(Run);
  if IsKeyWord(GetToken) then fTokenId := tkKey else fTokenId := tkIdentifier;
end;

procedure TmkGalaxySyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TmkGalaxySyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TmkGalaxySyn.SpaceProc;
begin
  inc(Run);
  fTokenID := tkSpace;
  while FLine[Run] in [#1..#9, #11, #12, #14..#32] do inc(Run);
end;

procedure TmkGalaxySyn.StringProc;
begin
{begin}                                                                         //mvdk 1999-06-11
(*
  if fTokenID <> tkMessage then begin
    fTokenID := tkMessage;
    fRange := rsMessageStyle;
    inc(Run);
    if (FLine[Run + 1] = '@') and (FLine[Run + 2] = '@') then inc(Run, 2);
    repeat
      case FLine[Run] of
        #0, #10, #13: break;
      end;
      inc(Run);
    until FLine[Run] = #0;
    if FLine[Run] <> #0 then inc(Run);
  end;
*)
  if (Run = 0) and (fTokenID <> tkMessage) then begin
    fTokenID := tkMessage;
    fRange := rsMessageStyle;
  end;
  inc(Run);
{end}                                                                           //mvdk 1999-06-11  
end;

procedure TmkGalaxySyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnKnown;
end;

procedure TmkGalaxySyn.Next;
// var                                                                          //mh 1999-09-12
//  TokenID: TtkTokenKind;                                                        //aj 1999-02-22
begin
  fTokenPos := Run;
  Case fRange of
    rsMessageStyle: MessageStyleProc;
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
      tkSpace:
        with fCanvas do
        begin
          Brush.Color := fSpaceAttri.Background;
          Font.Color := fSpaceAttri.Foreground;
          Font.Style := fSpaceAttri.Style;
        end;
      tkMessage:
        with fCanvas do
        begin
          Brush.Color := fMessageAttri.Background;
          Font.Color := fMessageAttri.Foreground;
          Font.Style := fMessageAttri.Style;
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

function TmkGalaxySyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;                                                  //mh 1999-08-22
//  Result := False;
//  if fTokenId = tkNull then Result := True;
end;

function TmkGalaxySyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TmkGalaxySyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TmkGalaxySyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TmkGalaxySyn.GetTokenAttribute: TmwHighLightAttributes;                //mh 1999-09-12
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkSpace: Result := fSpaceAttri;
    tkMessage: Result := fMessageAttri;
    tkUnknown: Result := fSymbolAttri;
    else Result := nil;
  end;
end;

function TmkGalaxySyn.GetTokenKind: integer;                                    //mh 1999-08-22
begin
  Result := Ord(fTokenId);
end;

function TmkGalaxySyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TmkGalaxySyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TmkGalaxySyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

{begin}                                                                         //jdj 1998-12-22 - rewritten
procedure TmkGalaxySyn.SetKeyWords(const Value: TStrings);
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
procedure TmkGalaxySyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;
end;

procedure TmkGalaxySyn.SetHighLightChange;
begin
  fCommentAttri.Onchange:= HighLightChange;
  fIdentifierAttri.Onchange:= HighLightChange;
  fKeyAttri.Onchange:= HighLightChange;
  fSpaceAttri.Onchange:= HighLightChange;
  fMessageAttri.Onchange:= HighLightChange;
  fSymbolAttri.Onchange:= HighLightChange;
end;
{end}                                                                           //gp 1998-12-22

{begin}                                                                         //gp 1998-12-24
function TmkGalaxySyn.GetAttribCount: integer;
begin
  Result := 6;
end;

function TmkGalaxySyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  case idx of // sorted by name
    0: Result := fCommentAttri;
    1: Result := fIdentifierAttri;
    2: Result := fKeyAttri;
    3: Result := fSpaceAttri;
    4: Result := fMessageAttri;
    5: Result := fSymbolAttri;
    else Result := nil;
  end;
end;
*)
{end}                                                                           //mh 1999-08-22

function TmkGalaxySyn.GetLanguageName: string;                                  //gp 1999-1-10 - renamed
begin
  Result := MWS_LangGalaxy;                                                     //mh 1999-09-24
end;
{end}                                                                           //gp 1998-12-24

function TmkGalaxySyn.LoadFromRegistry(RootKey: HKEY; Key: string): boolean;    //gp 1998-12-28
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

function TmkGalaxySyn.SaveToRegistry(RootKey: HKEY; Key: string): boolean;     //gp 1998-12-28
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

{begin}                                                                         //mvdk 1999-06-11
procedure TmkGalaxySyn.ExportNext;
begin
  fTokenPos := Run;
  Case fRange of
    rsMessageStyle: MessageStyleProc;
  else fProcTable[fLine[Run]];
  end;
  if Assigned(Exporter) then
    with TmwCustomExport(Exporter) do begin
      Case GetTokenID of
//        tkAsm:FormatToken(GetToken, fAsmAttri, False,False);
        tkComment: FormatToken(GetToken, fCommentAttri, True,False);
        tkIdentifier:FormatToken(GetToken, fIdentifierAttri, False,False);
        tkKey:FormatToken(GetToken, fKeyAttri, False,False);
//        tkNumber:FormatToken(GetToken, fNumberAttri, False,False);
        {Needed to catch Line breaks}
        tkNull:FormatToken('', nil, False,False);
        tkSpace:FormatToken(GetToken, fSpaceAttri, False,True);
        tkMessage:FormatToken(GetToken, fMessageAttri, True,False);
//        tkSymbol:FormatToken(GetToken, fSymbolAttri,True,False);
        tkUnknown:FormatToken(GetToken, fSymbolAttri, True,False);
      end;
    end; //with
end;

procedure TmkGalaxySyn.SetLineForExport(NewValue: String);
begin
  fLine := PChar(NewValue);
  Run := 0;
  ExportNext;
end;

function TmkGalaxySyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcExportable];
end;
{end}                                                                           //mvdk 1999-06-11

Initialization
  MakeIdentTable;
end.

