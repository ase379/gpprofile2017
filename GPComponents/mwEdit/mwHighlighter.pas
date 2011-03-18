{+-----------------------------------------------------------------------------+
 | Class:       TmwCustomHighlighter
 | Created:     07.98 - 10.98
 | Last change: 1999-09-12
 | Author:      Martin Waldenburg
 | Description: Parent class for all highlighters.
 | Version:     0.67 (for version history see version.rtf)
 | Copyright (c) 1998 Martin Waldenburg
 | All rights reserved.
 |
 | Thanks to: Primoz Gabrijelcic, Michael Trier, James Jacobson,
 |            Cyrille de Brebisson, Andy Jeffries
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

{$I MWEDIT.INC}                                                                 //mt 1998-12-16
//mt 12/16/1998 removed {$ObjExportAll On} since it's defined in the include

unit mwHighlighter;

interface

uses
  Windows, SysUtils, Classes, Graphics, Registry, Controls;                     //jdj 1998-12-18 - added Controls

{$DEFINE _Gp_MustEnhanceRegistry}
{$IFDEF MWE_COMPILER_4_UP}                                                      //gp 1998-12-16
  {$UNDEF _Gp_MustEnhanceRegistry}
{$ENDIF}
type
  TBetterRegistry = class(TRegistry)
  {$IFDEF _Gp_MustEnhanceRegistry}
    function OpenKeyReadOnly(const Key: string): Boolean;
  {$ENDIF}
  end;

  TmwEditorList = class(TList)                                                  //jdj 12/18/1998, //-jdj 1/16/1999 Changed-NameClash
    procedure AddInstance(Control: TWinControl);
    procedure RemoveInstance(Control: TWinControl);
    procedure Invalidate;
  end;

  TmwHighLightAttributes = Class(TPersistent)
  private
    fBackground: TColor;                                                        //mt 1998-12-14 - renamed
    fForeground: TColor;                                                        //mt 1998-12-14 - renamed
    fStyle: TFontStyles;
    fOnChange: TNotifyEvent;                                                    //jdj 1998-12-18
    fName: string;                                                              //gp 1998-12-24
    procedure SetBackground(Value: TColor);                                     //jdj 1998-12-18
    procedure SetForeground(Value: TColor);                                     //jdj 1998-12-18
    procedure SetStyle(Value: TFontStyles);                                     //jdj 1998-12-18
    function GetStyleFromInt: integer;                                          //CdeB 1998-12-16
    procedure SetStyleFromInt(const Value: integer);                            //CdeB 1998-12-16
  protected
  public
    procedure Assign(Source: TPersistent); override;
    property Name: string read fName;                                           //gp 1998-12-24
    property OnChange: TNotifyEvent read fOnChange write fOnChange;             //jdj 1998-12-18
    function LoadFromBorlandRegistry(rootKey: HKEY;                             //gp 1998-12-16, //gp 1998-12-28 - made protected
               attrKey, attrName: string; oldStyle: boolean): boolean; virtual;
    function LoadFromRegistry(Reg: TBetterRegistry): boolean;                   //CdeB 1998-12-16, //gp 1998-12-28 - adapted to TBetterRegistry, changed into function
    function SaveToRegistry(Reg: TBetterRegistry): boolean;                     //CdeB 1998-12-16, //gp 1998-12-28 - adapted to TBetterRegistry, changed into function
  published
    constructor Create(attribName: string);                                     //gp 1998-12-24
    property Background: TColor read fBackground write SetBackground;           //mt 1998-12-14 - renamed, //jdj 1998-12-18 - added Set
    property Foreground: TColor read fForeground write SetForeground;           //mt 1998-12-14 - renamed, //jdj 1998-12-18 - added Set
    property Style: TFontStyles read fStyle write SetStyle;                     //jdj 1998-12-18 - added Set
    property IntegerStyle: integer read GetStyleFromInt write SetStyleFromInt;  //CdeB 1998-12-16
  end;

  TIdentChars = set of char;                                                    //mt 1998-12-22

  THighlighterCapabilities = (                                                  //gp 1998-12-28
    hcUserSettings, // supports Enum/UseUserSettings
    hcRegistry,     // supports LoadFrom/SaveToRegistry
    hcExportable                                                                //gp 1999-06-10
  );

  THighlighterCapability = set of THighlighterCapabilities;

  TTokenEvent = procedure(Sender: TObject; TokenKind: integer;                  //aj 1999-02-22, gp 1999-02-28
    TokenText: String; LineNo: Integer) of Object;

  TmwCustomHighLighter = Class(TComponent)
  private
    fAttributes: TStringList;                                                   //mh 1999-08-22
//  fmwEdit: TWinControl;                                                       //jdj 1998-12-18
    fmwEditList: TmwEditorList;                                                 //jdj 1998-12-18, //-jdj 1/16/1999 Changed-NameClash
    fOnToken: TTokenEvent;                                                      //aj 1999-02-22
    fExporter: TComponent;                                                      //-jdj 1999-03-09
  protected
    fDefaultFilter: string;                                                     //gp 1999-1-10
    function GetIdentChars: TIdentChars; virtual;                               //mt 1998-12-22
    function GetLanguageName: string; virtual; abstract;                        //gp 1998-12-24
                                                                                //mt 1999-1-2 change to GetLangaugeName
{begin}                                                                         //mh 1999-08-22
    procedure AddAttribute(AAttrib: TmwHighLightAttributes);
    procedure DefHighlightChange(Sender: TObject);
//    function GetAttribCount: integer; virtual; abstract;                        //gp 1998-12-24
//    function GetAttribute(idx: integer): TmwHighLightAttributes; virtual; abstract;
    function GetAttribCount: integer; virtual;
    function GetAttribute(idx: integer): TmwHighLightAttributes; virtual;
    procedure SetAttributesOnChange(AEvent: TNotifyEvent);
{end}                                                                           //mh 1999-08-22
    function GetCapability: THighlighterCapability; virtual;                    //gp 1998-12-28
    function GetDefaultFilter: string; virtual;                                 //mt 1999-1-2
    procedure SetDefaultFilter(Value: string); virtual;                         //mt 1999-1-2
//    procedure DoOnToken(TokenKind: integer; TokenText: String;                  //gp 1999-02-28 //mh 1999-08-22
//      LineNo: Integer);
  public
    constructor Create(AOwner: TComponent); override;                           //jdj 1998-12-18
    destructor Destroy; override;                                               //jdj 1998-12-18
    procedure ExportNext;virtual; abstract;                                     //-jdj 1/15/1999
    function GetEol: Boolean; virtual; abstract;
    function GetRange: Pointer; virtual; abstract;
    function GetToken: String; virtual; abstract;
    function GetTokenAttribute: TmwHighLightAttributes; virtual; abstract;      //mh 1999-09-12
    function GetTokenKind: integer; virtual; abstract;                          //mh 1999-08-22
    function GetTokenPos: Integer; virtual; abstract;
    procedure Next; virtual; abstract;
    procedure NextToEol;                                                        //mh 1999-08-22
    procedure ScanAllLineTokens(const Value: string; LineNumber: integer);      //mh 1999-08-22
//    procedure SetCanvas(Value: TCanvas); virtual; abstract;                   //mh 1999-09-12
    procedure SetLine(NewValue: String; LineNumber:Integer); virtual; abstract; //aj 1999-02-22
    procedure SetLineForExport(NewValue: String);virtual; abstract;             //-jdj 1/15/1999
    procedure SetRange(Value: Pointer); virtual; abstract;
    procedure ReSetRange; virtual; abstract;
    function UseUserSettings(settingIndex: integer): boolean; virtual;          //mt 1998-12-14
                                                                                //gp 1998-12-18 - removed "abstract"
    procedure EnumUserSettings(settings: TStrings); virtual;                    //mt 1998-12-14
                                                                                //gp 1998-12-18 - removed "abstract"
    // idx = 0..GetAttribCount-1                                                //gp 1998-12-24
    function LoadFromRegistry(RootKey: HKEY; Key: string): boolean; virtual;    //gp 1998-12-28
    function SaveToRegistry(RootKey: HKEY; Key: string): boolean; virtual;      //gp 1998-12-28
//  property mwEdit: TWinControl read fmwEdit write fmwEdit;                    //jdj 1998-12-18
    property mwEditList: TmwEditorList read FmwEditList;                        //jdj 1998-12-18, //-jdj 1999-01-16 Changed-NameClash
    property IdentChars: TIdentChars read GetIdentChars;                        //mt 1998-12-22
    property LanguageName: string read GetLanguageName;                         //gp 1998-12-24
                                                                                //mt 1999-1-2 change to GetLanguageName
    property AttrCount: integer read GetAttribCount;                            //gp 1998-12-24
    property Attribute[idx: integer]: TmwHighLightAttributes read GetAttribute; //gp 1998-12-24
    property Capability: THighlighterCapability read GetCapability;             //gp 1998-12-28
    property Exporter:TComponent read fExporter write fExporter;                //-jdj 1999-03-09
published
    property DefaultFilter: string read GetDefaultFilter write SetDefaultFilter;//mt 1999-01-02
    property OnToken: TTokenEvent read fOnToken write fOnToken;                 //aj 1999-02-22
  end;

implementation

{$IFDEF _Gp_MustEnhanceRegistry}
  function IsRelative(const Value: string): Boolean;
  begin
    Result := not ((Value <> '') and (Value[1] = '\'));
  end;

  function TBetterRegistry.OpenKeyReadOnly(const Key: string): Boolean;
  var
    TempKey: HKey;
    S: string;
    Relative: Boolean;
  begin
    S := Key;
    Relative := IsRelative(S);

    if not Relative then Delete(S, 1, 1);
    TempKey := 0;
    Result := RegOpenKeyEx(GetBaseKey(Relative), PChar(S), 0,
        KEY_READ, TempKey) = ERROR_SUCCESS;
    if Result then
    begin
      if (CurrentKey <> 0) and Relative then S := CurrentPath + '\' + S;
      ChangeKey(TempKey, S);
    end;
  end; { TBetterRegistry.OpenKeyReadOnly }
{$ENDIF _Gp_MustEnhanceRegistry}

{ TmwHighLightAttributes }

procedure TmwHighLightAttributes.Assign(Source: TPersistent);                   //gp 1998-12-09
begin
  if Source is TmwHighLightAttributes then begin
    fBackground    := (Source as TmwHighLightAttributes).fBackground;
    fForeground    := (Source as TmwHighLightAttributes).fForeground;
    fStyle         := (Source as TmwHighLightAttributes).fStyle;
    fName          := (Source as TmwHighLightAttributes).fName;                 //gp 1998-12-24
  end
  else inherited Assign(Source);
end;

constructor TmwHighLightAttributes.Create(attribName: string);                  //gp 1998-12-10, //gp 1998-12-24
begin
  inherited Create;
  Background := clWindow;
  Foreground := clWindowText;
  fName := attribName;                                                          //gp 1998-12-24
end;

function TmwHighLightAttributes.LoadFromBorlandRegistry(rootKey: HKEY;          //gp 1998-12-16, //gp 1998-12-28 - renamed
  attrKey, attrName: string; oldStyle: boolean): boolean;
  // How the highlighting information is stored:
  // Delphi 1.0:
  //   I don't know and I don't care.
  // Delphi 2.0 & 3.0:
  //   In the registry branch HKCU\Software\Borland\Delphi\x.0\Highlight
  //   where x=2 or x=3.
  //   Each entry is one string value, encoded as
  //     <foreground RGB>,<background RGB>,<font style>,<default fg>,<default Background>,<fg index>,<Background index>
  //   Example:
  //     0,16777215,BI,0,1,0,15
  //     foreground color (RGB): 0
  //     background color (RGB): 16777215 ($FFFFFF)
  //     font style: BI (bold italic), possible flags: B(old), I(talic), U(nderline)
  //     default foreground: no, specified color will be used (black (0) is used when this flag is 1)
  //     default background: yes, white ($FFFFFF, 15) will be used for background
  //     foreground index: 0 (foreground index (Pal16), corresponds to foreground RGB color)
  //     background index: 15 (background index (Pal16), corresponds to background RGB color)
  // Delphi 4.0:
  //   In the registry branch HKCU\Software\Borland\Delphi\4.0\Editor\Highlight.
  //   Each entry is subkey containing several values:
  //     Foreground Color: foreground index (Pal16), 0..15 (dword)
  //     Background Color: background index (Pal16), 0..15 (dword)
  //     Bold: fsBold yes/no, 0/True (string)
  //     Italic: fsItalic yes/no, 0/True (string)
  //     Underline: fsUnderline yes/no, 0/True (string)
  //     Default Foreground: use default foreground (clBlack) yes/no, False/-1 (string)
  //     Default Background: use default backround (clWhite) yes/no, False/-1 (string)
const
  Pal16: array [0..15] of TColor = (clBlack, clMaroon, clGreen, clOlive,
          clNavy, clPurple, clTeal, clDkGray, clLtGray, clRed, clLime,
          clYellow, clBlue, clFuchsia, clAqua, clWhite);

  function LoadOldStyle(rootKey: HKEY; attrKey, attrName: string): boolean;
  var
    descript : string;
    fgColRGB : string;
    bgColRGB : string;
    fontStyle: string;
    fgDefault: string;
    bgDefault: string;
    fgIndex16: string;
    bgIndex16: string;
    reg      : TBetterRegistry;

    function Get(var name: string): string;
    var
      p: integer;
    begin
      p := Pos(',',name);
      if p = 0 then p := Length(name)+1;
      Result := Copy(name,1,p-1);
      name := Copy(name,p+1,Length(name)-p);
    end; { Get }

  begin { LoadOldStyle }
    Result := false;
    try
      reg := TBetterRegistry.Create;
      reg.RootKey := rootKey;
      try
        with reg do begin
          if OpenKeyReadOnly(attrKey) then begin
            try
              if ValueExists(attrName) then begin
                descript := ReadString(attrName);
                fgColRGB  := Get(descript);
                bgColRGB  := Get(descript);
                fontStyle := Get(descript);
                fgDefault := Get(descript);
                bgDefault := Get(descript);
                fgIndex16 := Get(descript);
                bgIndex16 := Get(descript);
                if bgDefault = '1'
                  then Background := clWindow                                   //gp 1998-12-10
                  else Background := Pal16[StrToInt(bgIndex16)];
                if fgDefault = '1'
                  then Foreground := clWindowText                               //gp 1998-12-10
                  else Foreground := Pal16[StrToInt(fgIndex16)];
                Style := [];
                if Pos('B',fontStyle) > 0 then Style := Style + [fsBold];
                if Pos('I',fontStyle) > 0 then Style := Style + [fsItalic];
                if Pos('U',fontStyle) > 0 then Style := Style + [fsUnderline];
                Result := true;
              end;
            finally CloseKey; end;
          end; // if
        end; // with
      finally reg.Free; end;
    except end;
  end; { LoadOldStyle }

  function LoadNewStyle(rootKey: HKEY; attrKey, attrName: string): boolean;
  var
    fgIndex16    : DWORD;
    bgIndex16    : DWORD;
    fontBold     : string;
    fontItalic   : string;
    fontUnderline: string;
    fgDefault    : string;
    bgDefault    : string;
    reg          : TBetterRegistry;

    function IsTrue(value: string): boolean;
    begin
      Result := not ((UpperCase(value) = 'FALSE') or (value = '0')); 
    end; { IsTrue }

  begin
    Result := false;
    try
      reg := TBetterRegistry.Create;
      reg.RootKey := rootKey;
      try
        with reg do begin
          if OpenKeyReadOnly(attrKey+'\'+attrName) then begin
            try
              if ValueExists('Foreground Color')
                then fgIndex16 := ReadInteger('Foreground Color')
                else Exit;
              if ValueExists('Background Color')
                then bgIndex16 := ReadInteger('Background Color')
                else Exit;
              if ValueExists('Bold')
                then fontBold := ReadString('Bold')
                else Exit;
              if ValueExists('Italic')
                then fontItalic := ReadString('Italic')
                else Exit;
              if ValueExists('Underline')
                then fontUnderline := ReadString('Underline')
                else Exit;
              if ValueExists('Default Foreground')
                then fgDefault := ReadString('Default Foreground')
                else Exit;
              if ValueExists('Default Background')
                then bgDefault := ReadString('Default Background')
                else Exit;
              if IsTrue(bgDefault)
                then Background := clWindow                                     //gp 1998-12-10
                else Background := Pal16[bgIndex16];
              if IsTrue(fgDefault)
                then Foreground := clWindowText                                 //gp 1998-12-10
                else Foreground := Pal16[fgIndex16];
              Style := [];
              if IsTrue(fontBold) then Style := Style + [fsBold];
              if IsTrue(fontItalic) then Style := Style + [fsItalic];
              if IsTrue(fontUnderline) then Style := Style + [fsUnderline];
              Result := true;
            finally CloseKey; end;
          end; // if
        end; // with
      finally reg.Free; end;
    except end;
  end; { LoadNewStyle }

begin
  if oldStyle then Result := LoadOldStyle(rootKey, attrKey, attrName)
              else Result := LoadNewStyle(rootKey, attrKey, attrName);
end; { TmwHighLightAttributes.LoadFromBorlandRegistry }

{begin}                                                                         //jdj 1998-12-18
procedure TmwHighLightAttributes.SetBackground(Value: TColor);
begin
  if fBackGround <> Value then
    begin
      fBackGround := Value;
      if Assigned(fOnChange) then
        fOnChange(Self);
    end;
end;

procedure TmwHighLightAttributes.SetForeground(Value: TColor);
begin 
  if fForeGround <> Value then
    begin
      fForeGround := Value;
      if Assigned(fOnChange) then
        fOnChange(Self);
    end;
end;

procedure TmwHighLightAttributes.SetStyle(Value: TFontStyles);
begin 
  if fStyle <> Value then
    begin
      fStyle := Value;
      if Assigned(fOnChange) then
        fOnChange(Self);
    end;
end;
{end}                                                                           //jdj 1998-12-18

{begin}                                                                         //CdeB 1998-12-16, //gp 1998-12-28 - rewritten for TRegistry
function TmwHighLightAttributes.LoadFromRegistry(Reg: TBetterRegistry): boolean;
var
  key: string;
begin
  key := Reg.CurrentPath;
  if Reg.OpenKeyReadOnly(Name) then begin
    if Reg.ValueExists('Background') then Background := Reg.ReadInteger('Background');
    if Reg.ValueExists('Foreground') then Foreground := Reg.ReadInteger('Foreground');
    if Reg.ValueExists('Style') then IntegerStyle := Reg.ReadInteger('Style');
    reg.OpenKeyReadOnly('\'+key);
    Result := true;
  end
  else Result := false;
end;

function TmwHighLightAttributes.SaveToRegistry(Reg: TBetterRegistry): boolean;
var
  key: string;
begin
  key := Reg.CurrentPath;
  if Reg.OpenKey(Name,true) then begin
    Reg.WriteInteger('Background', Background);
    Reg.WriteInteger('Foreground', Foreground);
    Reg.WriteInteger('Style', IntegerStyle);
    reg.OpenKey('\'+key,false);
    Result := true;
  end
  else Result := false;
end;

function TmwHighLightAttributes.GetStyleFromInt: integer;
begin
  if fsBold in Style then Result:= 1 else Result:= 0;
  if fsItalic in Style then Result:= Result+2;
  if fsUnderline in Style then Result:= Result+4;
  if fsStrikeout in Style then Result:= Result+8;
end;

procedure TmwHighLightAttributes.SetStyleFromInt(const Value: integer);
begin
  if Value and $1 = 0 then  Style:= [] else Style:= [fsBold];
  if Value and $2 <> 0 then Style:= Style+[fsItalic];
  if Value and $4 <> 0 then Style:= Style+[fsUnderline];
  if Value and $8 <> 0 then Style:= Style+[fsStrikeout];
end;
{end}                                                                           //CdeB 1998-12-16

{ TmwCustomHighLighter }

{begin}                                                                         //jdj 1998-12-18
constructor TmwCustomHighLighter.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{begin}                                                                         //mh 1999-08-22
  fAttributes := TStringList.Create;
  fAttributes.Duplicates := dupIgnore;
  fAttributes.Sorted := TRUE;
{end}                                                                           //mh 1999-08-22
  fmwEditList := TmwEditorList.Create;                                          //-jdj 1/16/1999 Changed-NameClash
  fDefaultFilter := '';
end;

destructor TmwCustomHighLighter.Destroy;
var i: integer;                                                                 //mh 1999-08-22
begin
{begin}                                                                         //mh 1999-08-22
  for i := fAttributes.Count - 1 downto 0 do begin
    if (fAttributes.Objects[i] = nil) then continue;
    TmwHighLightAttributes(fAttributes.Objects[i]).Free;
  end;
  fAttributes.Free;
{end}                                                                           //mh 1999-08-22
  fmwEditList.Free;
  inherited Destroy;
end;
{end}                                                                           //jdj 1998-12-18

{begin}                                                                         //gp 1998-12-18
procedure TmwCustomHighLighter.EnumUserSettings(settings: TStrings);
begin
  settings.Clear;
end;

function TmwCustomHighLighter.UseUserSettings(
  settingIndex: integer): boolean;
begin
  Result := false;
end;

function TmwCustomHighLighter.GetIdentChars: TIdentChars;
begin
  Result := [#33..#255];
end;

procedure TmwCustomHighLighter.NextToEol;                                       //mh 1999-08-22
begin
  while not GetEol do Next;
end;

procedure TmwCustomHighLighter.ScanAllLineTokens(const Value: string;
                                                 LineNumber: integer);          //mh 1999-08-22
var sToken: string;
begin
  SetLine(Value, LineNumber);
  while not GetEOL do begin
    if Assigned(fOnToken) then begin
      sToken := GetToken;
      if (Length(sToken) > 0) then
        OnToken(Self, GetTokenKind, sToken, LineNumber);
    end;
    Next;
  end;
end;

{end}                                                                           //gp 1998-12-18

{TmwEditorList}

{begin}                                                                         //jdj 1998-12-18
procedure TmwEditorList.AddInstance(Control: TWinControl);                      //-jdj 1/16/1999 Changed-NameClash
begin
  if (IndexOf(Control) = -1) then
    Add(Control);
end;

procedure TmwEditorList.RemoveInstance(Control: TWinControl);                   //-jdj 1/16/1999 Changed-NameClash
var
  A: Integer;
begin
  A := IndexOf(Control);
  if (A <> -1) then
    Delete(A);
end;

procedure TmwEditorList.Invalidate;                                             //-jdj 1/16/1999 Changed-NameClash
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
    TWinControl(Items[i]).Invalidate;
end;
{end}                                                                           //jdj 1998-12-18

{begin}                                                                         //gp 1998-12-28
function TmwCustomHighLighter.LoadFromRegistry(RootKey: HKEY; Key: string): boolean;
var
  r: TBetterRegistry;
  i: integer;
begin
  r := TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKeyReadOnly(Key) then begin
      Result := true;
      for i := 0 to AttrCount-1 do
        Result := Result and Attribute[i].LoadFromRegistry(r);
    end
    else Result := false;
  finally r.Free; end;
end;

function TmwCustomHighLighter.SaveToRegistry(RootKey: HKEY; Key: string): boolean;
var
  r: TBetterRegistry;
  i: integer;
begin
  r := TBetterRegistry.Create;
  try
    r.RootKey := RootKey;
    if r.OpenKey(Key,true) then begin
      Result := true;
      for i := 0 to AttrCount-1 do
        Result := Result and Attribute[i].SaveToRegistry(r);
    end
    else Result := false;
  finally r.Free; end;
end;
{end}                                                                           //gp 1998-12-28

{begin}                                                                         //mh 1999-08-22
procedure TmwCustomHighLighter.AddAttribute(AAttrib: TmwHighLightAttributes);
begin
  fAttributes.AddObject(AAttrib.Name, AAttrib);
end;

procedure TmwCustomHighLighter.DefHighlightChange(Sender: TObject);
begin
  fmwEditList.Invalidate;
end;

function TmwCustomHighLighter.GetAttribCount: integer;
begin
  Result := fAttributes.Count;
end;

function TmwCustomHighLighter.GetAttribute(idx: integer): TmwHighLightAttributes;
begin
  Result := nil;
  if (idx >= 0) and (idx < fAttributes.Count) then
    Result := TmwHighLightAttributes(fAttributes.Objects[idx]);
end;

procedure TmwCustomHighLighter.SetAttributesOnChange(AEvent: TNotifyEvent);
var i: integer;
    attri: TmwHighLightAttributes;
begin
  for i := fAttributes.Count - 1 downto 0 do begin
    attri := TmwHighLightAttributes(fAttributes.Objects[i]);
    if Assigned(attri) then attri.OnChange := AEvent;
  end;
end;
{end}                                                                           //mh 1999-08-22

function TmwCustomHighLighter.GetCapability: THighlighterCapability;
begin
  Result := [hcRegistry]; //registry save/load supported by default
end;

function TmwCustomHighLighter.GetDefaultFilter: string;                         //mt 1999-1-2
begin
  Result := fDefaultFilter;                                                     //gp 1999-1-10
end;

procedure TmwCustomHighLighter.SetDefaultFilter(Value: string);                 //mt 1999-1-2
begin
  if fDefaultFilter <> Value then fDefaultFilter := Value;                      //gp 1999-1-10
end;

{begin}                                                                         //mh 1999-08-22
(*
procedure TmwCustomHighLighter.DoOnToken(TokenKind: integer;                    //gp 1999-02-28
  TokenText: String; LineNo: Integer);
begin
  if assigned(fOnToken) and (TokenText <> '') then
    OnToken(self,TokenKind,TokenText,LineNo);
end;
*)
{end}                                                                           //mh 1999-08-22

end.
