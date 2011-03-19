{+-----------------------------------------------------------------------------+
 | Class:       TmwRtfExport
 | Created:     1.1999
 | Author:      James D. Jacobson
 | All rights assigned to Martin Waldenburg 5.11.1999
 | Last change: 1999-09-24
 | Version:     1.03 (see VERSION.RTF for version history)
 |------------------------------------------------------------------------------
 | Copyright (c) 1998 Martin Waldenburg
 | All rights reserved.
 |
 | The names of the unit and classes may not be changed.
 | No support will be provided by the author in any case.
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
 |    notice, the name of the author, this list of conditions and the
 |    following disclaimer.
 |    If the source is modified, the complete original and unmodified
 |    source code has to distributed with the modified version.
 |
 | 2. Redistributions in binary form must reproduce the above
 |    copyright notice, the name of the author, these licence conditions
 |    and the disclaimer found at the end of this licence agreement in
 |    the documentation and/or other materials provided with the distribution.
 |
 | 3. Software using this code must contain a visible line of credit.
 |
 | 4. If my code is used in a "for profit" product, you have to donate
 |    to a registered charity in an amount that you feel is fair.
 |    You may use it in as many of your products as you like.
 |    Proof of this donation must be provided to Martin Waldenburg.
 |
 | 5. If you for some reasons don't want to give public credit to the
 |    author, you have to donate three times the price of your software
 |    product, or any other product including this component in any way,
 |    but no more than $500 US and not less than $200 US, or the
 |    equivalent thereof in other currency, to a registered charity.
 |    You have to do this for every of your products, which uses this
 |    code separately.
 |    Proof of this donations must be provided to Martin Waldenburg.
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
 |------------------------------------------------------------------------------
 |
 | Usage:
 |  A_mwRtfExporter.RunExport(0, A_mwCustomEdit.Lines.Count -1,
 |                   A_mwCustomEdit,A_mwHighlighter);
 |   1. DoSomethingWithThe_Data_Property;
 |   2. A_mwRtfExporter.SaveToFile(A_FileName);
 |   3. A_mwRtfExporter.SaveToStream(A_Stream);
 |  mwRtfExporter.Clear;
 |   Frees the data buffers memory, which can get vary large.
 |
 |  A_mwRtfExporter.CopyToClipboard(A_mwCustomEdit,A_mwHighlighter);
 |    Copies the selected text onto the Clipboard
 |    that can be pasted into anything that accepts RTF.
 +----------------------------------------------------------------------------+}

unit mwRtfExport;

interface

uses Windows, Controls, Graphics, SysUtils, Classes, mwHighlighter, mwExport;

type
  TmwRtfExport = class(TmwCustomExport)
  private
    FColorList: TList;
    FFontSize: string;
    FClipboardFormat : Longint;
  protected
    function ColorToRTF(AColor: TColor): string;
    function GetCapability: string; override;
    function GetData: string; override;
    procedure Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer); override;
    function MakeFontTable: string;
    function MakeFooter: string; override;
    function MakeColorTable: string;
    function MakeHeader: string; override;
    function ScanTags(const S: string): string;
    function GetExporterName: string; override;                                 //gp 1999-05-06
    function GetClipboardFormat : Longint; override;                            //ajb 1999-06-16
  public
    constructor Create(AOwner: TComponent); override;
    procedure CopyToClipboardFormat(AmwEdit: TCustomControl;                    //ajb 1999-06-16
                                    AmwHighlighter: TmwCustomHighlighter;
                                    CbFormat : Longint); override;
    procedure CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter); override;
    procedure Clear; override;
    destructor Destroy; override;
    procedure FormatToken(Token: string; Attribute: TmwHighLightAttributes; Tags: Boolean; IsSpace: Boolean); override;
    property Capability: string read GetCapability;
    property Data: string read GetData;
  published
    property Title;
    property UseBackGround;
  end;

  procedure Register;

implementation

uses
  RichEdit, mwCustomEdit, mwLocalStr;                                           //ajb 1999-09-14

const
  CR = #13#10;

procedure Register;
begin
  RegisterComponents('mw', [TmwRtfExport]);
end;

constructor TmwRtfExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FColorList := TList.Create;
  FFontSize := '\fs10';
  fDefaultFilter := MWS_FilterRTF;                                              //ajb 1999-09-14
end;

procedure TmwRtfExport.Clear;
begin
  inherited Clear;
  FColorList.Clear;
end;

function TmwRtfExport.ColorToRTF(AColor: TColor): string;
var
  A: Integer;
begin
  A := ColorToRGB(AColor);
  Result := '\red' + IntToStr(GetRValue(A)) +
    '\green' + IntToStr(GetGValue(A)) +
    '\blue' + IntToStr(GetBValue(A)) + ';';
end;

procedure TmwRtfExport.CopyToClipboardFormat(AmwEdit: TCustomControl;           //ajb 1999-06-16
                                             AmwHighlighter: TmwCustomHighlighter;
                                             CbFormat : Longint);
begin
  inherited CopyToClipboardFormat(AmwEdit, AmwHighlighter, CbFormat);
  DoExportToClipboard(AmwEdit, AmwHighlighter);
  DoCopyToClipBoard(CbFormat);
  Clear;
end;

procedure TmwRtfExport.CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
begin
  IsForClipboard := True;
  CopyToClipboardFormat(AmwEdit, AmwHighlighter, ClipboardFormat);              //ajb 1999-06-16
(*                                                                              //ajb 1999-06-16
  inherited CopyToClipboard(AmwEdit, AmwHighlighter);
  DoExportToClipboard(AmwEdit, AmwHighlighter);
  DoCopyToClipBoard(ClipboardFormat);
  Clear;
*)
end;

destructor TmwRtfExport.Destroy;
begin
  FColorList.Free;
  inherited Destroy;
end;

procedure TmwRtfExport.FormatToken(Token: string; Attribute: TmwHighLightAttributes;
  Tags: Boolean; IsSpace: Boolean);
var
  Bg, Fg, tmpColor: Integer;
  S: string;
  function GetBackColor: string;
  begin
    Result := '';
    if UseBackGround then
      Result := '\cb' + IntToStr(Bg);
  end;

  function GetStyle: string;
  begin
    Result := '';
    with Attribute do
      begin
        if (fsBold in Style) then
          Result := '\b';
        if (fsItalic in Style) then
          Result := Result + '\i';
        if (fsUnderline in Style) then
          Result := Result + '\ul';
        if (fsStrikeOut in Style) then
          Result := Result + '\strike';
      end;
  end;
begin
  Bg := 0;
  Fg := 0;
  if Attribute <> nil then
    begin
      tmpColor := Attribute.Foreground;
      Fg := FColorList.IndexOf(Pointer(tmpColor));
      if (Fg = -1) then
        Fg := FColorList.Add(Pointer(tmpColor));
      if UseBackGround then
        begin
          tmpColor := Attribute.Background;
          Bg := FColorList.IndexOf(Pointer(tmpColor));
          if (Bg = -1) then
            Bg := FColorList.Add(Pointer(tmpColor));
        end;
    end;
  if Tags then
    Token := ScanTags(Token);
  if (Attribute = nil) then
    S := CR + '\par '
  else if AttributesChanged(Attribute) then
    begin
      S := '\plain' + FFontSize + GetBackColor +
        '\cf' + IntToStr(Fg) + GetStyle + ' ' + Token;
      if UseBackGround then
        S := S + '\plain\f0' + FFontSize;
    end
  else
    S := Token;
  if FData.Position + Length(S) > FData.Size then
    FData.SetSize(FData.Size + 1024);
  FData.Write(S[1], Length(S));
end;

function TmwRtfExport.GetCapability: string;
begin
  Result := 'RTF';
end;

function TmwRtfExport.GetData: string;
begin
  SetString(Result, PChar(FData.Memory), FData.Size);
end;

procedure TmwRtfExport.Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer);
begin
  inherited Init(AmwEdit, AmwHighlighter, LineCount);
  FFontSize := '\fs' + IntToStr(GetFontSize);
end;

function TmwRtfExport.MakeColorTable: string;
var
  i: Integer;
begin
  Result := '{\colortbl';
  for i := 0 to FColorList.Count - 1 do
    Result := Result + ColorToRTF(TColor(FColorList[i]));
  Result := Result + '}';
end;

function TmwRtfExport.MakeFontTable: string;
var
  TMLogFont: TLogFont;
begin
  Result := '{\fonttbl{\f0\fmodern ';
  GetObject(TmwCustomEdit(FControl).Font.Handle,
    SizeOf(TLogFont), @TMLogFont);
  Result := Result + TMLogFont.lfFaceName + ';}}';
end;

function TmwRtfExport.MakeHeader: string;
begin
  Result := SysUtils.Format('{\rtf1\ansi\deff0\deftab720' +
    MakeFontTable + CR + MakeColorTable +
    CR + '{\info{\comment Generated by mwRtfExport}' +
    CR + '{\title %s}}' +
    CR + '\deflang1033\pard\plain ' + CR, [Title]);
end;

function TmwRtfExport.MakeFooter: string;
begin
  Result := '}';
end;

function TmwRtfExport.ScanTags(const S: string): string;
var
  i: integer;
begin
  Result := S;
  i := 1;
  while i <= Length(Result) do
    begin
      if (Result[i] in ['\', '{', '}']) then
        begin
          Insert('\', Result, i);
          Inc(i);
        end;
      Inc(i);
    end;
end;

function TmwRtfExport.GetExporterName: string;
begin
  Result := MWS_ExportRTF;                                                      //mh 1999-09-24
end;

function TmwRtfExport.GetClipboardFormat : Longint;                             //ajb 1999-06-16
begin
  if FClipboardFormat = 0 then
    FClipboardFormat := RegisterClipboardFormat(CF_RTF);
  result := FClipboardFormat;
end;

end.

