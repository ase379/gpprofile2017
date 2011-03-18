{+-----------------------------------------------------------------------------+
 | Class:       TmwCustomExport
 | Created:     1.1999
 | Author:      James D. Jacobson
 | All rights assigned to Martin Waldenburg 5.11.1999
 | Last change: 1999-08-22
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
+--------------------------------------------------------------------------+}

unit mwExport;

interface

uses Windows, Controls, Graphics, SysUtils, Classes, mwHighlighter;

type
  TAttribRec = record
    Bg: Integer;
    Fg: Integer;
    Fs: TFontStyles;
  end;
type
  TmwCustomExport = class(TComponent)
  private
    FLastAttr: TAttribRec;
    FFontSize: Integer;
    FTitle: string;
    FUseBackGround: Boolean;
    FIsForClipboard: Boolean;                                                   // ajb 1999-06-16
    procedure SetTitle(Value: string);
  protected
    FDefaultFilter: string;                                                     // ajb 1999-09-14
    FData: TMemoryStream;
    FControl: TCustomControl;
    function AttributesChanged(Attribute: TmwHighLightAttributes): Boolean;
    procedure DoCopyToClipboard(AFormat: Longint);
    procedure DoExportToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
    procedure InsertHeaderFooter(var Header, Footer: string);
    function GetCapability: string; virtual; abstract;
    function GetData: string; virtual; abstract;
    function GetFontSize: Integer;
    procedure Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer); virtual;
    function MakeHeader: string; virtual; abstract;
    function MakeFooter: string; virtual; abstract;
    property Data: string read GetData;
    property Title: string read FTitle write SetTitle;
    property UseBackGround: Boolean read FUseBackGround write FUseBackGround;
    function GetExporterName: string; virtual; abstract;                        //gp 1999-05-06
    function GetClipboardFormat : Longint; virtual;                             //ajb 1999-06-16
    function GetDefaultFilter: string; virtual;                                 // ajb 1999-09-14
    procedure SetDefaultFilter(Value: string); virtual;                         // ajb 1999-09-14

  public
    constructor Create(AOwner: TComponent); override;
    procedure CopyToClipboardFormat(AmwEdit: TCustomControl;                    //ajb 1999-06-16
                                    AmwHighlighter: TmwCustomHighlighter;
                                    CbFormat : Longint); virtual;
    procedure CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter); virtual;
    procedure Clear; virtual;
    destructor Destroy; override;
    procedure FormatToken(Token: string; Attribute: TmwHighLightAttributes; Tags: Boolean; IsSpace: Boolean); virtual; abstract;
    procedure RunExport(StartLine, StopLine: Integer; AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
    procedure RunExportBlock(ExportStart, ExportEnd: TPoint; AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);

    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    property ExporterName: string read GetExporterName;                         //gp 1999-05-06
    property IsForClipboard: boolean read FIsForClipboard write FIsForClipboard default false; //ajb 1999-06-16
    property ClipboardFormat : Longint read GetClipboardFormat;                 //ajb 1999-06-16
    property DefaultFilter: string read GetDefaultFilter write SetDefaultFilter;//ajb 1999-09-14

  end;

implementation

uses mwCustomEdit, Clipbrd;

const
  cnUntitled = '(Untitled)';

function TmwCustomExport.AttributesChanged(Attribute: TmwHighLightAttributes): Boolean;
begin
  with Attribute, FLastAttr do
    begin
      Result := not ((Foreground = Fg) and
        (BackGround = Bg) and (Style = Fs));
      Fg := Foreground;
      Bg := BackGround;
      Fs := Style;
    end;
end;

procedure TmwCustomExport.Clear;
begin
  FData.Clear;
  FFontSize := 0;
  FillChar(FLastAttr, SizeOf(TAttribRec), 0);
end;


procedure TmwCustomExport.CopyToClipboardFormat(AmwEdit: TCustomControl;        //ajb 1999-06-16
                                                  AmwHighlighter: TmwCustomHighlighter;
                                                  CbFormat : Longint);
begin
{}
end;

procedure TmwCustomExport.CopyToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
begin
{}
end;

procedure TmwCustomExport.DoCopyToClipboard(AFormat: Longint);
var
{Adapted from code by: Peter Below}
{Forums: borland.public.delphi.vcl.components.using}
  Hnd: THandle;
  P: PChar;
begin
  FData.Position := 0;
  Hnd := GlobalAlloc(GHND or GMEM_DDESHARE,
    FData.Size);
  if Hnd <> 0 then
    begin
      P := GlobalLock(Hnd);
      if P <> nil then
        begin
          try
            FData.Read(P^, FData.Size);
            FData.Position := 0;
          finally
            GlobalUnlock(Hnd);
          end;
//          Clipboard.Open;                                                     //ajb 1999-06-16
//          try                                                                 //ajb 1999-06-16
            Clipboard.SetAsHandle(AFormat, Hnd);
//          finally                                                             //ajb 1999-06-16
//            Clipboard.Close;                                                  //ajb 1999-06-16
//          end;                                                                //ajb 1999-06-16
        end
      else
        begin
          GlobalFree(Hnd);
          OutOfMemoryError;
        end;
    end
  else
    OutOfMemoryError;
end;

procedure TmwCustomExport.DoExportToClipboard(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
var
  I, A: Integer;
  SelStart, SelEnd: TPoint;
  tS, ts1: string;
  tmpEdit: TmwCustomEdit;
begin
  tmpEdit := AmwEdit as TmwCustomEdit;
  SelStart := tmpEdit.BlockBegin;
  SelEnd := tmpEdit.BlockEnd;
  if ((SelStart.x = SelEnd.x) and (SelStart.y = SelEnd.y)) then
    Abort;
  Init(tmpEdit, AmwHighlighter, (SelEnd.y - SelStart.y) + 1);
  AmwHighlighter.SetRange(tmpEdit.Lines.Objects[SelStart.y - 1]);
  A := SelEnd.x;
  for i := SelStart.y - 1 to SelEnd.y - 1 do
    begin
      tS := tmpEdit.Lines[i];
      if (i = SelStart.y - 1) then
        begin
          Delete(tS, 1, SelStart.x - 1);
          Dec(A, SelStart.x - 1)
        end;
      if (i = SelEnd.y - 1) then
        Delete(tS, A, MaxInt);
      AmwHighlighter.SetLineForExport(tS);
      while not AmwHighlighter.GetEol do
        AmwHighlighter.ExportNext;
    end;
  FData.SetSize(FData.Position - 2);
  tS := MakeHeader;
  tS1 := MakeFooter;
  InsertHeaderFooter(ts, ts1);
end;

constructor TmwCustomExport.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FData := TMemoryStream.Create;
  FTitle := cnUntitled;
end;

destructor TmwCustomExport.Destroy;
begin
  FData.Free;
  inherited Destroy;
end;

function TmwCustomExport.GetFontSize: Integer;
begin
  Result := TmwCustomEdit(FControl).Font.Size * 2
end;

procedure TmwCustomExport.Init(AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter; LineCount: Integer);
begin
  if (AmwEdit = nil) or (AmwHighlighter = nil) or
    not ((AmwEdit is TmwCustomEdit) or
    (AmwHighlighter is TmwCustomHighlighter)) then
    raise Exception.Create('Invalid Parameter');
  AmwHighlighter.Exporter := Self;
  TmwCustomEdit(FControl) := AmwEdit as TmwCustomEdit;
  Clear;
  FData.SetSize(LineCount * 100);
end;

procedure TmwCustomExport.InsertHeaderFooter(var Header, Footer: string);
var
  OldSize: Integer;
  P: PChar;
begin
  if (Length(Header) <> 0) then
    begin
      OldSize := FData.Position;
      FData.SetSize(FData.Position + Length(Header));
      P := FData.Memory;
      Inc(P, Length(Header));
      Move(FData.Memory^, P^, OldSize);
      FData.Position := 0;
      FData.Write(Header[1], Length(Header));
    end;
  if (Length(Footer) <> 0) then
    begin
      FData.Seek(0, soFromEnd);
      FData.Write(Footer[1], Length(Footer));
    end;
end;

procedure TmwCustomExport.RunExport(StartLine, StopLine: Integer; AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
var
  i: Integer;
  tmpEdit: TmwCustomEdit;
  tS, ts1: string;
begin
  tmpEdit := (AmwEdit as TmwCustomEdit);
  Init(tmpEdit, AmwHighlighter, (StopLine - StartLine) + 1);
  AmwHighlighter.SetRange(tmpEdit.Lines.Objects[StartLine]);
  try
    for i := StartLine to StopLine do
      begin
        AmwHighlighter.SetLineForExport(tmpEdit.Lines[i]);
        while not AmwHighlighter.GetEol do
          AmwHighlighter.ExportNext;
      end;
    tS := MakeHeader;
    tS1 := MakeFooter;
    InsertHeaderFooter(ts, ts1);
  except
    FData.Clear;
    raise;
  end;
end;

procedure TmwCustomExport.RunExportBlock(ExportStart, ExportEnd: TPoint; AmwEdit: TCustomControl; AmwHighlighter: TmwCustomHighlighter);
var
  A, i: Integer;
  tmpEdit: TmwCustomEdit;
  tS, ts1: string;
  line : string;
begin
  if ((ExportStart.x = ExportEnd.x) and (ExportStart.y = ExportEnd.y)) then
    Abort;
  tmpEdit := (AmwEdit as TmwCustomEdit);
  Init(tmpEdit, AmwHighlighter, (ExportEnd.y - ExportStart.y) + 1);
  AmwHighlighter.SetRange(tmpEdit.Lines.Objects[ExportStart.y - 1]);
  A := ExportEnd.x;
  try
    for i := ExportStart.y - 1 to ExportEnd.y - 1 do
      begin
        line := tmpEdit.Lines[i];
        if (i = ExportStart.y - 1) then
        begin
          Delete(line, 1, ExportStart.x - 1);
          Dec(A, ExportStart.x - 1)
        end;
        if (i = ExportEnd.y - 1) then
          Delete(line, A, MaxInt);
        AmwHighlighter.SetLineForExport(line);
        while not AmwHighlighter.GetEol do
          AmwHighlighter.ExportNext;
      end;
    tS := MakeHeader;
    tS1 := MakeFooter;
    InsertHeaderFooter(ts, ts1);
  except
    FData.Clear;
    raise;
  end;
end;

procedure TmwCustomExport.SaveToFile(const FileName: string);
begin
  FData.Position := 0;
  FData.SaveToFile(FileName);
end;

procedure TmwCustomExport.SaveToStream(Stream: TStream);
begin
  FData.Position := 0;
  FData.SaveToStream(Stream);
end;

procedure TmwCustomExport.SetTitle(Value: string);
begin
  if Value <> '' then
    FTitle := Value
  else
    FTitle := cnUntitled;
end;

function TmwCustomExport.GetClipboardFormat : Longint;                          //ajb 1999-06-16
begin
  result := CF_TEXT; // will probably be overriden
end;

{begin}                                                                         //ajb 1999-09-14
function TmwCustomExport.GetDefaultFilter: string;
begin
  Result := fDefaultFilter;
end;

procedure TmwCustomExport.SetDefaultFilter(Value: string);
begin
  if fDefaultFilter <> Value then fDefaultFilter := Value;
end;
{end}                                                                           //ajb 1999-09-14

end.

