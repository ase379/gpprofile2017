{+-----------------------------------------------------------------------------+
 | Class:       TmwHtmlExport
 | Created:     1.1999
 | Author:      James D. Jacobson
 | All rights assigned to Martin Waldenburg 5.11.1999
 | Last change: 1999-09-24
 | Version:     1.04 (see VERSION.RTF for version history)
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
 |  A_mwHtmlExporter.RunExport(0, A_mwCustomEdit.Lines.Count -1,
 |                   A_mwCustomEdit,A_mwHighlighter);
 |   1. DoSomethingWithThe_Data_Property;
 |   2. A_mwHtmlExporter.SaveToFile(A_FileName);
 |   3. A_mwHtmlExporter.SaveToStream(A_Stream);
 |  mwHtmlExporter.Clear;
 |   Frees the data buffers memory, which can get vary large.
 |
 |  A_mwHtmlLExporter.CopyToClipboard(A_mwCustomEdit,A_mwHighlighter);
 |    Copies the selected text onto the Clipboard
 |    that can be pasted into a visual HTML editor.
 +----------------------------------------------------------------------------+}

unit mwHtmlExport;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls,
  mwExport, mwHighlighter;

type
  TmwFontSize = (fs01, fs02, fs03, fs04, fs05, fs06, fs07);
type
  TmwHtmlExport = class(TmwCustomExport)
  private
    { Private declarations }
    FBackGround: TColor;
    FFontSize: TmwFontSize;
    FPlainText: TColor;
    FClipboardFormat : Longint;                                                 //ajb 1999-06-16
    procedure SetBackGround(Value: TColor);
    procedure SetPlainText(Value: TColor);
  protected
    { Protected declarations }
    function GetData: string; override;
    function ColorToHtml(Color: TColor): string;
    procedure Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer); override;
    function GetCapability: string; override;
    function MakeHeader: string; override;
    function MakeFooter: string; override;
    function ScanTags(const S: string): string;
    function GetExporterName: string; override;                                 //gp 1999-05-06
    function GetClipboardFormat : Longint; override;                            //ajb 1999-06-16
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    procedure CopyToClipboardFormat(AmwEdit: TCustomControl;                    //ajb 1999-06-16
                                    AmwHighlighter: TmwCustomHighlighter;
                                    CbFormat : Longint); override;
    procedure CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter); override;
    procedure Clear; override;
    destructor Destroy; override;
    procedure FormatToken(Token: string; Attribute: TmwHighLightAttributes; Tags: Boolean; IsSpace: Boolean); override;
    property Data: string read GetData;
    property Capability: string read GetCapability;
  published
    { Published declarations }
    property BackGround: TColor read FBackGround write SetBackGround default clWhite;
    property PlainText: TColor read FPlainText write SetPlainText default clBlack;
    property FontSize: TmwFontSize read FFontSize write FFontSize default fs03;
    property Title;
  end;

procedure Register;

implementation

uses mwCustomEdit, mwLocalStr;                                                  //ajb 1999-09-14

//var                                                                           //ajb 1999-06-16
//  cbHTML: Longint;
const
  CR = #13#10;

procedure Register;
begin
  RegisterComponents('mw', [TmwHtmlExport]);
end;

function TmwHtmlExport.ColorToHtml(Color: TColor): string;
begin
  Result := '"#' + IntToHex(GetRValue(Color), 2) +
    IntToHex(GetGValue(Color), 2) +
    IntToHex(GetBValue(Color), 2) + '"';
end;

constructor TmwHtmlExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFontSize := fs03;
  FPlainText := clBlack;
  FBackGround := clWhite;
  fDefaultFilter := MWS_FilterHTML;                                             //ajb 1999-09-14
end;

procedure TmwHtmlExport.CopyToClipboardFormat(AmwEdit: TCustomControl;          //ajb 1999-06-16
                                              AmwHighlighter: TmwCustomHighlighter;
                                              CbFormat : Longint);
begin
  try
    inherited CopyToClipboardFormat(AmwEdit, AmwHighlighter, CbFormat);
    DoExportToClipboard(AmwEdit, AmwHighlighter);
    DoCopyToClipBoard(CbFormat);
    Clear;
  finally
    IsForClipboard := False;
  end;
end;

procedure TmwHtmlExport.CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
begin
  IsForClipboard := True;
  CopyToClipboardFormat(AmwEdit, AmwHighlighter, ClipboardFormat);              //ajb 1999-06-16
(*                                                                              //ajb 1999-06-16
  IsForClipboard := True;
  try
    inherited CopyToClipboard(AmwEdit, AmwHighlighter);
    DoExportToClipboard(AmwEdit, AmwHighlighter);
    DoCopyToClipBoard(ClipboardFormat);
    Clear;
  finally
    IsForClipboard := False;
  end;
*)
end;

procedure TmwHtmlExport.Clear;
begin
  inherited Clear;
end;

destructor TmwHtmlExport.Destroy;
begin
  inherited Destroy;
end;

procedure TmwHtmlExport.FormatToken(Token: string; Attribute: TmwHighLightAttributes; Tags: Boolean; IsSpace: Boolean);
var
  S: string;
  procedure BuildString;
  begin
    S := '';
    with Attribute do
      begin
        if (not IsSpace) and (ForeGround <> FPlainText) then
          S := '<font color=' + ColorToHtml(ForeGround) + '>';
        if (fsBold in Style) then
          S := S + '<b>';
        if (fsItalic in Style) then
          S := S + '<i>';
        if (fsUnderline in Style) then
          S := S + '<u>';
        if (fsStrikeOut in Style) then
          S := S + '<strike>';
        S := S + Token;
        if (fsStrikeOut in Style) then
          S := S + '</strike>';
        if (fsUnderline in Style) then
          S := S + '</u>';
        if (fsItalic in Style) then
          S := S + '</i>';
        if (fsBold in Style) then
          S := S + '</b>';
        if (not IsSpace) and (ForeGround <> FPlainText) then
          S := S + '</font>';
      end;
  end;

begin
  if Tags then
    Token := ScanTags(Token);
  if (Attribute <> nil) then
    BuildString
  else
    S := S + CR;
  if FData.Position + Length(S) > FData.Size then
    FData.SetSize(FData.Size + 1024);
  FData.Write(S[1], Length(S));
end;

function TmwHtmlExport.GetCapability: string;
begin
  Result := 'HTML';
end;

function TmwHtmlExport.GetData: string;
begin
  SetString(Result, PChar(FData.Memory), FData.Size);
end;

procedure TmwHtmlExport.Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer);
begin
  inherited Init(AmwEdit, AmwHighlighter, LineCount);
end;

function TmwHtmlExport.MakeFooter: string;
begin
  if IsForClipboard then                                                        //ajb 1999-06-16
    Result := '</body>' + CR + '</html>'
  else
    Result := '</basefont>' + CR + '</font>' +
      CR + '</code>' + '</pre>' + CR + '</body>' +
      CR + '</html>';
end;

function TmwHtmlExport.MakeHeader: string;
const                                                                           // ajb 1999-06-16
  DescriptionSize = 105;
  HeaderSize = 47;
  FooterSize1 = 58;
  FooterSize2 = 24;
var
  tS: string;
begin
  Result := '';
  if IsForClipboard then
    begin
      {begin}                                                                   // ajb 1999-06-16
      // Described in http://msdn.microsoft.com/library/sdkdoc/htmlclip/htmlclipboard.htm
      Result := 'Version:0.9' + CR;
      Result := Result + Format('StartHTML:%.10d', [DescriptionSize]) + CR;
      Result := Result + Format('EndHTML:%.10d', [DescriptionSize + HeaderSize + FData.Size + FooterSize1])  + CR;
      Result := Result + Format('StartFragment:%.10d', [DescriptionSize + HeaderSize]) + CR;
      Result := Result + Format('EndFragment:%.10d', [DescriptionSize + HeaderSize + FData.Size + FooterSize2]) + CR;
      {end}                                                                     // ajb 1999-06-16

      Result := Result + '<html>' + CR + '<head></head>' + '<body>' + '<!--StartFragment-->' + '<code><pre>';
      tS := '</pre></code><!--EndFragment-->';
      FData.Write(tS[1], Length(tS));
    end
  else
    begin
      Result := Sysutils.Format('<html>' + CR + '<head>' +
        CR + '<title>%s</title>' + CR + '</head>' +
        CR + '<!-- Generated by mwHtmlExport -->' +
        CR + '<body  text=' + ColorToHtml(FPlainText) + ' ' +
        'bgcolor=' + ColorToHtml(FBackGround) + '>' +
        CR + '<code>' + CR + '<pre>' + CR + '<basefont size=1 face="%s">' + CR +
        '<font size= +%d>' + CR,
        [Title, TmwCustomEdit(FControl).Font.Name, Ord(FFontSize)]);
    end;
end;

{$IFDEF MWE_COMPILER_3_UP}                                                      //mh 1999-08-19
{$DEFINE MWE_MBCSSUPPORT}                                                       //hk 1999-06-23
{$ENDIF}                                                                  
function TmwHtmlExport.ScanTags(const S: string): string;
var
  i: Integer;
{$IFDEF MWE_MBCSSUPPORT}                                                        //hk 1999-06-19
  m: Integer;
  cLeng: Integer;
  cType: PWordArray;
{$ENDIF}
const
  Chars = ['<', '>', '&', '"',
    '©', 'É', 'È', 'Ê', 'Ë', 'Ï', 'Î', 'Ç', 'À', 'Ü', 'Û',
    'é', 'è', 'ê', 'ë', 'ï', 'î', 'ç', 'à', 'ü', 'û'];
  Words: array[0..25] of string = ('&LT;', '&GT;', '&AMP;',
    '&QUOT;', '&COPY;', '&EACUTE;', '&eACUTE;', '&EGRAVE;',
    '&eGRAVE;', '&ECIRC;', '&eCIRC;', '&EUML;', '&eUML;',
    '&IUML;', '&iUML;', '&ICIRC;', '&iCIRC;', '&CCEDIL;',
    '&cCEDIL;', '&AGRAVE;', '&aGRAVE;', '&UUML;', '&uUML;',
    '&UCIRC;', '&uCIRC;', '_');
  function Tags: Cardinal;
  begin
    case S[i] of
      '<': Result := 0;
      '>': Result := 1;
      '&': Result := 2;
      '"': Result := 3;
      '©': Result := 4;
      'É': Result := 5;
      'é': Result := 6;
      'È': Result := 7;
      'è': Result := 8;
      'Ê': Result := 9;
      'ê': Result := 10;
      'Ë': Result := 11;
      'ë': Result := 12;
      'Ï': Result := 13;
      'ï': Result := 14;
      'Î': Result := 15;
      'î': Result := 16;
      'Ç': Result := 17;
      'ç': Result := 18;
      'À': Result := 19;
      'à': Result := 20;
      'Ü': Result := 21;
      'ü': Result := 22;
      'Û': Result := 23;
      'û': Result := 24;
      else
        Result := 25;
    end;
  end;

begin
  Result := S;
{begin}                                                                         //hk 1999-06-19
{$IFDEF MWE_MBCSSUPPORT}
  cLeng := ByteToCharLen(S, Length(S));
  GetMem(cType, SizeOf(Word) * cLeng);
  Try
    If Not GetStringTypeExA(
             LOCALE_SYSTEM_DEFAULT,
             CT_CTYPE3,
             PChar(S),
             Length(S),
             cType^) Then Begin
      Exit;
    End;

    For m:=cLeng DownTo 1 Do Begin
      i := CharToByteIndex(S, m);
      If ((cType^[m-1] And C3_FULLWIDTH) = 0) Then Begin
        If (S[i] In Chars) Then Begin
          Delete(Result, i, 1);
          Insert(Words[Tags], Result, i);
        End;
      End;
    End;
  Finally
    FreeMem(cType);
  End;
{$ELSE}
{end}                                                                           //hk 1999-06-19
  for i := Length(S) downto 1 do
    begin
      if S[i] in Chars then
        begin
          Delete(Result, i, 1);
          Insert(Words[Tags], Result, i);
        end;
    end;
{$ENDIF}
end;
{$UNDEF MWE_MBCSSUPPORT}                                                        //hk 1999-06-23

procedure TmwHtmlExport.SetBackGround(Value: TColor);
begin
  if (Value < clBlack) then
    begin
      Value := clWhite;
      PlainText := clBlack;
    end;
  FBackGround := Value;
end;

procedure TmwHtmlExport.SetPlainText(Value: TColor);
begin
  if (Value < clBlack) then
    begin
      Value := clBlack;
      BackGround := clWhite;
    end;
  FPlainText := Value;
end;

function TmwHtmlExport.GetExporterName: string;
begin
  Result := MWS_ExportHTML;                                                     //mh 1999-09-24
end;

function TmwHtmlExport.GetClipboardFormat : Longint;                            //ajb 1999-06-16
begin
  if FClipboardFormat = 0 then
    FClipboardFormat := RegisterClipboardFormat('HTML Format');
  result := FClipboardFormat;
end;

//initialization                                                                //ajb 1999-06-16
//  cbHTML := RegisterClipboardFormat('HTML Format');
end.

