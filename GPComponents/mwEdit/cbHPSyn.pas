{+-----------------------------------------------------------------------------+
 | Class:       TcbHPSyn
 | Created:     not known
 | Last change: 1999-09-25
 | Author:      Cyrille de Brebisson [cyrille_de-brebisson@aus.hp.com]
 | Description: HP48 assembly syntax highliter
 | Version:     0.56
 | Copyright (c) 1998 Cyrille de Brebisson
 | All rights reserved.
 |
 | Thanks to: Primoz Gabrijelcic, Andy Jeffries
 |
 | Version history: see version.rtf
 |
 +----------------------------------------------------------------------------+}

unit cbHPSyn;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter, cbUtils, mwLocalStr;                                           //mh 1999-08-22

type
  TtkTokenKind = (tkAsmKey, tkAsm, tkAsmComment, tkRplKey, tkRpl, tkRplComment, tkNull, tkSpace);

{begin}                                                                         //gp 1998-12-27
var
  tkTokenName: array [TtkTokenKind] of string = (
                 MWS_AttrAsmKey, MWS_AttrAsm, MWS_AttrAsmComment,               //mh 1999-08-22
                 MWS_AttrRplKey, MWS_AttrRpl, MWS_AttrRplComment,
                 MWS_AttrNull, MWS_AttrSpace
               );

type
{end}                                                                           //gp 1998-12-27

  TRangeState = (rsAsm, rsRpl, rsComRpl);

  TTokenEvent = procedure(Sender: TObject; TokenKind: TtkTokenKind;             //aj 1999-02-22
    TokenText: String; LineNo: Integer) of Object;

  TcbHPSyn = Class(TmwCustomHighLighter)
  private
//    fCanvas: TCanvas;                                                         //mh 1999-09-25
    fRange: TRangeState;
    fLine: String;
    Run: LongInt;
    fTokenKind: TtkTokenKind;                                                   //mh 1999-08-22
    fTokenPos: Integer;
    fEol: Boolean;
    fOnToken: TTokenEvent;
    Attribs: array [TtkTokenKind] of TmwHighLightAttributes;
    FRplKeyWords: TSpeedStringList;
    FAsmKeyWords: TSpeedStringList;
    FBaseRange: TRangeState;
    fLineNumber: Integer;                                                       //aj 1999-02-22
    Function GetAttrib(Index: integer): TmwHighLightAttributes;                 //gp 1998-12-28
    Procedure SetAttrib(Index: integer; Value: TmwHighLightAttributes);         //gp 1998-12-28
    function IdentKind(s: String): TtkTokenKind;

    Function NullProc: TtkTokenKind;
    Function CRLFProc: TtkTokenKind;
    Function SpaceProc: TtkTokenKind;
    Function ParOpenProc: TtkTokenKind;
    Function RplComProc: TtkTokenKind;
    Function PersentProc: TtkTokenKind;
    Function IdentProc: TtkTokenKind;
    Procedure EndOfToken;
    procedure HighLightChange(Sender:TObject);                                  //gp 1998-12-27
    procedure SetHighLightChange;                                               //gp 1998-12-27
  protected
    function GetLanguageName: string; override;                                 //gp 1998-12-27, //gp 1999-1-10 - renamed
    function GetAttribCount: integer; override;                                 //gp 1998-12-27
    function GetAttribute(idx: integer): TmwHighLightAttributes; override;      //gp 1998-12-27
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy;                     override;
    function GetEol: Boolean;               override;
    procedure SetLine(NewValue: String; LineNumber:Integer); override;          //aj 1999-02-22
    function GetToken: String;              override;
    function GetTokenAttribute: TmwHighLightAttributes; override;               //mh 1999-09-25
    function GetTokenKind: integer;         override;                           //mh 1999-08-22
    function GetTokenPos: Integer;          override;
    procedure Next;                         override;
//    procedure SetCanvas(Value: TCanvas);    override;                         //mh 1999-09-25
    function GetRange: Pointer;             override;
    procedure SetRange(Value: Pointer);     override;
    procedure ReSetRange;                   override;
    function SaveToRegistry(RootKey: HKEY; Key: string): boolean; override;     //gp 1998-12-28 - changed into function, added RootKey
    function LoadFromRegistry(RootKey: HKEY; Key: string): boolean; override;   //gp 1998-12-28 - changed into function, added RootKey
    Procedure Assign(Source: TPersistent); Override;
    Property AsmKeyWords: TSpeedStringList read FAsmKeyWords;
    Property RplKeyWords: TSpeedStringList read FRplKeyWords;
  published
    Property AsmKey    : TmwHighLightAttributes index Ord(tkAsmKey)     read GetAttrib write SetAttrib; //gp 12/28/1998
    Property AsmTxt    : TmwHighLightAttributes index Ord(tkAsm)        read GetAttrib write SetAttrib; //gp 12/28/1998
    Property AsmComment: TmwHighLightAttributes index Ord(tkAsmComment) read GetAttrib write SetAttrib; //gp 12/28/1998
    Property RplKey    : TmwHighLightAttributes index Ord(tkRplKey)     read GetAttrib write SetAttrib; //gp 12/28/1998
    Property RplTxt    : TmwHighLightAttributes index Ord(tkRpl)        read GetAttrib write SetAttrib; //gp 12/28/1998
    Property RplComment: TmwHighLightAttributes index Ord(tkRplComment) read GetAttrib write SetAttrib; //gp 12/28/1998
    Property Space     : TmwHighLightAttributes index Ord(tkSpace)      read GetAttrib write SetAttrib; //gp 12/28/1998
    Property BaseRange : TRangeState read FBaseRange write FBaseRange;
    property OnToken   : TTokenEvent read fOnToken write fOnToken;              //aj 1999-02-22
  end;

procedure Register;

implementation

Const
  DefaultAsmKeyWords : String = '!RPL'#13#10'ENDCODE'#13#10'{'#13#10'}'#13#10+
                                'GOTO'#13#10'GOSUB'#13#10'GOSBVL'#13#10'GOVLNG'#13#10'GOLONG'#13#10'SKIP'+
                                #13#10'SKIPYES'+#13#10'->'#13#10'SKUB'#13#10'SKUBL'#13#10'SKC'#13#10'SKNC'#13#10'SKELSE'+
                                #13#10'SKEC'#13#10'SKENC'#13#10'SKLSE'#13#10+'GOTOL'#13#10'GOSUBL'#13#10+
                                'RTN'#13#10'RTNC'#13#10'RTNNC'#13#10'RTNSC'#13#10'RTNCC'#13#10'RTNSXM'#13#10'RTI';
  OtherAsmKeyWords: array [0..5] of string = ('UP', 'EXIT', 'UPC', 'EXITC', 'UPNC', 'EXITNC');
  DefaultRplKeyWords = 'CODE'#13#10'ASSEMBLE'#13#10'IT'#13#10'ITE'#13#10'case'#13#10'::'#13#10';'#13#10'?SEMI'#13#10''''#13#10'#=case'#13#10'{'#13#10'}';

procedure Register;
begin
  RegisterComponents('mw', [TcbHPSyn]);
end;

constructor TcbHPSyn.Create(AOwner: TComponent);
Var
  i: TtkTokenKind;
  j, k: integer;
begin
  for i:= low(TtkTokenKind) to High(TtkTokenKind) do
    Attribs[i]:= TmwHighLightAttributes.Create(tkTokenName[i]);                 //gp 1998-12-27                                                                                                                                                                                  
  inherited Create(AOwner);
  SetHighlightChange;                                                           //gp 1998-12-27
  FAsmKeyWords:= TSpeedStringList.Create;
  FAsmKeyWords.Text:= DefaultAsmKeyWords;
  for j:= low(OtherAsmKeyWords) to High(OtherAsmKeyWords) do
  Begin
    FAsmKeyWords.Add(TSpeedListObject.Create(OtherAsmKeyWords[j]));
    for k:= 1 to 8 do
      FAsmKeyWords.Add(TSpeedListObject.Create(OtherAsmKeyWords[j]+IntToStr(k)));
  end;
  FRplKeyWords:= TSpeedStringList.Create;
  FRplKeyWords.Text:= DefaultRplKeyWords;
  BaseRange:= rsRpl;
  fRange := rsRpl;
  fDefaultFilter := 'HP48 files (*.s,*.sou,*.a,*.hp)|*.S;*.SOU;*.A;*.HP';       //gp 1999-1-11
end; { Create }

destructor TcbHPSyn.Destroy;
var
  i: TtkTokenKind;
begin
  for i:= low(TtkTokenKind) to High(TtkTokenKind) do
    Attribs[i].Free;
  FAsmKeyWords.Free;
  FRplKeyWords.Free;
  inherited Destroy;
end; { Destroy }

{begin}                                                                         //mh 1999-09-25
(*
procedure TcbHPSyn.SetCanvas(Value: TCanvas);
begin
  fCanvas := Value;
end;
*)
{end}                                                                           //mh 1999-09-25

procedure TcbHPSyn.SetLine(NewValue: String; LineNumber:Integer);               //aj 1999-02-22
begin
  fLine := PChar(NewValue);
  Run := 1;
  fEol := False;
  fLineNumber := LineNumber;
  Next;
end; { SetLine }

function TcbHPSyn.RplComProc: TtkTokenKind;
begin
  Result := tkRplComment;
  If (Run>Length(fLine)) then
    Result:= NullProc
  else
    while Run<=Length(FLine) do
      case FLine[Run] of
        ')':
          begin
            inc(Run);
            if ((Run=1) and ((Length(fLine)=1) or (fLine[Run+1]<=' '))) or
               ((fLine[Run-1]<=' ') and ((Length(fLine)=Run) or (fLine[Run+1]<=' '))) then
            Begin
              fRange := rsRpl;
              break;
            end;
          end;
        #10, #13: Begin Result:= CRLFProc; break; end;
      else inc(Run);
      end;
end;

Function TcbHPSyn.ParOpenProc: TtkTokenKind;
begin
  if fRange = rsRpl then
    if ((Run=1) and ((Length(fLine)=1) or (fLine[Run+1]<=' '))) or
       ((fLine[Run-1]<=' ') and ((Length(fLine)=Run) or (fLine[Run+1]<=' '))) then
    Begin
      inc(Run);
      Result := tkRplComment;
      fRange := rsComRpl;
      while (Run<=Length(fLine)) do
        case FLine[Run] of
          ')':
            begin
              fRange := rsRpl;
              inc(Run);
              break;
            end;
          #10, #13: Begin Result:= CRLFProc; break; end;
        else inc(Run);
        end
    end
    else
      Result:= IdentProc
  else
    Result:= IdentProc;
end;

Function TcbHPSyn.PersentProc: TtkTokenKind;
begin
  if fRange = rsAsm then
  Begin
    inc(Run);
    Result := tkAsmComment;
    while (run<=Length(fLine)) do
      case FLine[Run] of
        #10, #13:
          begin
            inc(Run);
            break;
          end;
      else inc(Run);
      end;
  end else
    Result:= IdentProc;
end;

function TcbHPSyn.IdentKind(s: String): TtkTokenKind;
begin
  if fRange = rsAsm then
    if FAsmKeyWords.Find(s)<>nil then
      if (s='!RPL') or (s='ENDCODE') then
      Begin
        fRange := rsRpl;
        result:= tkAsmKey;
      end else
        result:= tkAsmKey
    else
      result:= tkAsm
  else
    if FRplKeyWords.Find(s)<>nil then
      if (s='CODE') or (s='ASSEMBLE') then
      Begin
        fRange := rsAsm;
        result:= tkAsmKey;
      end else
        result:= tkRplKey
    else
      result:= tkRpl;
end;

Function TcbHPSyn.IdentProc: TtkTokenKind;
var
  i: integer;
begin
  i:= Run;
  EndOfToken;
  Result := IdentKind(Copy(fLine, i, run-i));
end;

Function TcbHPSyn.CRLFProc: TtkTokenKind;
begin
  Result := tkSpace;
  inc(Run);
end;

Function TcbHPSyn.NullProc: TtkTokenKind;
begin
  Result := tkNull;
  fEol := True;
end;

Function TcbHPSyn.SpaceProc: TtkTokenKind;
begin
  inc(Run);
  while (Run<=Length(FLine)) and (FLine[Run] in [#1..#9, #11, #12, #14..#32]) do inc(Run);
  if fRange = rsAsm then
    Result:= tkAsm
  else
   Result := tkRpl;
end;

procedure TcbHPSyn.Next;
{begin}                                                                         //mh 1999-09-25
//var
//  Att: TmwHighLightAttributes;
//  tkk: TtkTokenKind;
begin
  fTokenPos := Run;
  if Run>Length(fLine) then      fTokenKind:= NullProc
  else if fRange = rsComRpl then fTokenKind:= RplComProc
  else if fLine[Run] in [#10, #13] then  fTokenKind:= CRLFProc
  else if fLine[Run] in [#1..#9, #11, #12, #14..#32] then fTokenKind:= SpaceProc
  else if fLine[Run] = '(' then  fTokenKind:= ParOpenProc
  else if fLine[Run] = '%' then  fTokenKind:= PersentProc
  else fTokenKind:= IdentProc;
(*
  if Assigned(fCanvas) then
  Begin
    att:= GetAttrib(Ord(fTokenKind));                                                  //gp 1998-12-27
    fCanvas.Brush.Color := att.Background;
    fCanvas.Font.Color  := att.Foreground;
    fCanvas.Font.Style  := att.Style;
//    DoOnToken(Ord(tkk), GetToken, fLineNumber);                                 //gp 1999-02-27
  end;
*)  
{end}                                                                           //mh 1999-09-25
end;

function TcbHPSyn.GetEol: Boolean;
begin
  Result:= fEol;
end;

function TcbHPSyn.GetToken: String;
var
  Len: LongInt;
  a: PChar;
begin
  a:= @(fLine[fTokenPos]);
  Len := Run - fTokenPos;
  SetString(Result, a, Len);
end;

function TcbHPSyn.GetTokenAttribute: TmwHighLightAttributes;                    //mh 1999-09-25
begin
  Result := GetAttrib(Ord(fTokenKind));
end;

function TcbHPSyn.GetTokenKind: integer;                                        //mh 1999-08-22
begin
  Result := Ord(fTokenKind);
end;

function TcbHPSyn.GetTokenPos: Integer;
begin
 Result := fTokenPos-1;
end;

function TcbHPSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

procedure TcbHPSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

procedure TcbHPSyn.ReSetRange;
begin
  fRange := BaseRange;
end;

function TcbHPSyn.GetAttrib(Index: integer): TmwHighLightAttributes;            //gp 1998-12-27
begin
  Result:= Attribs[TtkTokenKind(Index)];
end;

procedure TcbHPSyn.SetAttrib(Index: integer; Value: TmwHighLightAttributes);    //gp 1998-12-27
begin
  Attribs[TtkTokenKind(Index)].Assign(Value);
end;

procedure TcbHPSyn.EndOfToken;
begin
  while (Run<=Length(fLine)) and (FLine[Run]>' ') do
    Inc(Run);
end;

function TcbHPSyn.LoadFromRegistry(RootKey: HKEY; Key: string): boolean;        //gp 1998-12-28 - addapted to TBetterRegistry
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKeyReadOnly(Key) then begin
      if r.ValueExists('AsmKeyWordList')
        then AsmKeywords.Text:= r.ReadString({'HPSyntax',} 'AsmKeyWordList'{, AsmKeywords.Text});
      if r.ValueExists('RplKeyWordList')
        then RplKeywords.Text:= r.ReadString({'HPSyntax',} 'RplKeyWordList'{, RplKeywords.Text});
      Result := inherited LoadFromRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

function TcbHPSyn.SaveToRegistry(RootKey: HKEY; Key: string): boolean;          //gp 1998-12-28 - addapted to TBetterRegistry
var
  r: TBetterRegistry;
begin
  r:= TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKey(Key,true) then begin
      Result := true;
      r.WriteString({'HPSyntax',} 'AsmKeyWordList', AsmKeywords.Text);
      r.WriteString({'HPSyntax',} 'RplKeyWordList', RplKeywords.Text);
      Result := inherited SaveToRegistry(RootKey, Key);
    end
    else Result := false;
  finally r.Free; end;
end;

procedure TcbHPSyn.Assign(Source: TPersistent);
var
  i: TtkTokenKind;
begin
  if Source is TcbHPSyn then
  Begin
    for i:= Low(Attribs) to High(Attribs) do
    Begin
      Attribs[i].Background    := TcbHPSyn(source).Attribs[i].Background;
      Attribs[i].Foreground    := TcbHPSyn(source).Attribs[i].Foreground;
      Attribs[i].Style := TcbHPSyn(source).Attribs[i].Style;
    end;
    AsmKeyWords.Text:= TcbHPSyn(source).AsmKeyWords.Text;
    RplKeyWords.Text:= TcbHPSyn(source).RplKeyWords.Text;
  end else
    inherited Assign(Source);
end;

{begin}                                                                         //gp 1998-12-27
function TcbHPSyn.GetAttribCount: integer;
begin
  Result := Ord(High(Attribs))-Ord(Low(Attribs))+1;
end;

function TcbHPSyn.GetAttribute(idx: integer): TmwHighLightAttributes;
begin // sorted by name
  if (idx <= Ord(High(TtkTokenKind))) then Result := Attribs[TtkTokenKind(idx)]
                                      else Result := nil;
end;

function TcbHPSyn.GetLanguageName: string;                                      //gp 1999-1-10 - renamed
begin
  Result := MWS_LangHP48;                                                       //mh 1999-09-25
end;

procedure TcbHPSyn.HighLightChange(Sender:TObject);
begin
  mwEditList.Invalidate;                                                        //jdj 1998-12-18
end;

procedure TcbHPSyn.SetHighLightChange;
var
  i: TtkTokenKind;
begin
  for i:= Low(Attribs) to High(Attribs) do
    Attribs[i].OnChange := HighLightChange;
end;
{end}                                                                           //gp 1998-12-27

end.

