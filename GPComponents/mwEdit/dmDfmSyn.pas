(*

**************************************
     dmDfmSyn.pas by David Muir
**************************************

Version 0.21
Last Edited: 1999-09-24
Copyright © 1999 David Muir.

Source and accompanying grammer file is distributed under the
Mozilla Public License v1.1 (see - http://www.mozilla.org/NPL/NPL-1_1Final.html)

Thanks to the entire mwEdit development team for creating an excellent suite of
components.

Please note:  the "dmDfmSyn.msg" file contains errors that have been fixed in the
	      dmBatSyn.pas file.  Do not use mwSysGen.exe with grammer file and
              expect the resulting file to compile/work correctly.

License Notes:

The contents of this file are subject to the Netscape Public License Version 1.1 (the "License");
you may not use this file except in compliance with the License.

You may obtain a copy of the License at http://www.mozilla.org/NPL/NPL-1_1Final.html

Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND,
either express or implied. See the License for the specific language governing rights and limitations
under the License.

The Original Code is: Main.pas from Compiler IDE

The Initial Developer of the Original Code is David Muir.
Portions created by David Muir are Copyright © 1999 David Muir, All Rights Reserved.

Contributor(s): David Muir, Michael Hieke.

*)

unit dmDfmSyn;

{$I mwEdit.inc}
{$B-}

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, Graphics, Registry,
  mwHighlighter, mwExport;

type
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

  TRangeState = (rsANil, rsComment, rsUnKnown);

  TProcTableProc = procedure of Object;

type
  TdmDfmSyn = class(TmwCustomHighLighter)
  private
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;
    fExporter: TmwCustomExport;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fStringAttri: TmwHighLightAttributes;
    fSymbolAttri: TmwHighLightAttributes;
    procedure AltProc;
    procedure AsciiCharProc;
    procedure BraceCloseProc;
    procedure BraceOpenProc;
    procedure CommentProc;
    procedure CRProc;
    procedure EndProc;
    procedure IntegerProc;
    procedure LFProc;
    procedure NullProc;
    procedure NumberProc;
    procedure ObjectProc;
    procedure SpaceProc;
    procedure StringProc;
    procedure SymbolProc;
    procedure UnknownProc;
    procedure MakeMethodTables;
  protected
    function GetIdentChars: TIdentChars; override;
    function GetLanguageName: string; override;
    function GetCapability: THighlighterCapability; override;
  public
    constructor Create(AOwner: TComponent); override;
    function GetEol: Boolean; override;
    function GetRange: Pointer; override;
    function GetTokenID: TtkTokenKind;
    procedure SetLine(NewValue: String; LineNumber: Integer); override;
    procedure ExportNext; override;
    procedure SetLineForExport(NewValue: String); override;
    function GetToken: String; override;
    function GetTokenAttribute: TmwHighLightAttributes; override;
    function GetTokenKind: integer; override;
    function GetTokenPos: Integer; override;
    procedure Next; override;
    procedure SetRange(Value: Pointer); override;
    procedure ReSetRange; override;
    property IdentChars;
  published
    property CommentAttri: TmwHighLightAttributes read fCommentAttri write fCommentAttri;
    property IdentifierAttri: TmwHighLightAttributes read fIdentifierAttri write fIdentifierAttri;
    property KeyAttri: TmwHighLightAttributes read fKeyAttri write fKeyAttri;
    property NumberAttri: TmwHighLightAttributes read fNumberAttri write fNumberAttri;
    property SpaceAttri: TmwHighLightAttributes read fSpaceAttri write fSpaceAttri;
    property StringAttri: TmwHighLightAttributes read fStringAttri write fStringAttri;
    property Exporter: TmwCustomExport read FExporter write FExporter;
  end;

function LoadDFMFile2Strings(const AFile: string; AStrings: TStrings): integer; //mh 1999-09-22

procedure Register;

implementation

uses mwLocalStr;

procedure Register;
begin
  RegisterComponents('mw', [TdmDfmSyn]);
end;

function LoadDFMFile2Strings(const AFile: string; AStrings: TStrings): integer; //mh 1999-09-22
var Src, Dest: TStream;
begin
  Result := 0;
  AStrings.Clear;
  try
    Src := TFileStream.Create(AFile, fmOpenRead or fmShareDenyWrite);
    try
      Dest := TMemoryStream.Create;
      try
        ObjectResourceToText(Src, Dest);
        Dest.Seek(0, 0);
        AStrings.LoadFromStream(Dest);
      finally
        Dest.Free;
      end;
    finally
      Src.Free;
    end;
  except
    on E: EInOutError do Result := -E.ErrorCode;
    else Result := -1;
  end;
end;

procedure TdmDfmSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '#': fProcTable[I] := AsciiCharProc;
      '}': fProcTable[I] := BraceCloseProc;
      '{': fProcTable[I] := BraceOpenProc;
      #13: fProcTable[I] := CRProc;
      'A'..'Z', 'a'..'z', '_':
        if I in ['e', 'E'] then fProcTable[I] := EndProc
        else if I in ['o', 'O'] then fProcTable[I] := ObjectProc
        else fProcTable[I] := AltProc;
      '$': fProcTable[I] := IntegerProc;
      #10: fProcTable[I] := LFProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      '(', ')', '/', '=', '<', '>', '.', ',', '[', ']':
        fProcTable[I] := SymbolProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
      #39: fProcTable[I] := StringProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TdmDfmSyn.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fCommentAttri := TmwHighLightAttributes.Create(MWS_AttrComment);
  fCommentAttri.Style := [fsItalic];
  AddAttribute(fCommentAttri);
  fIdentifierAttri := TmwHighLightAttributes.Create(MWS_AttrIdentifier);
  AddAttribute(fIdentifierAttri);
  fKeyAttri := TmwHighLightAttributes.Create(MWS_AttrKey);
  AddAttribute(fKeyAttri);
  fNumberAttri := TmwHighLightAttributes.Create(MWS_AttrNumber);
  AddAttribute(fNumberAttri);
  fSpaceAttri := TmwHighLightAttributes.Create(MWS_AttrSpace);
  AddAttribute(fSpaceAttri);
  fStringAttri := TmwHighLightAttributes.Create(MWS_AttrString);
  AddAttribute(fStringAttri);
  fSymbolAttri := TmwHighLightAttributes.Create(MWS_AttrSymbol);
  AddAttribute(fSymbolAttri);
  SetAttributesOnChange(DefHighlightChange);
  MakeMethodTables;
  fDefaultFilter := MWS_FilterDFM;
  fRange := rsUnknown;
end;

procedure TdmDfmSyn.SetLine(NewValue: String; LineNumber: Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TdmDfmSyn.AltProc;
begin
  fTokenID := tkIdentifier;
  repeat
    Inc(Run);
  until not (fLine[Run] in ['_', '0'..'9', 'a'..'z', 'A'..'Z']);
end;

procedure TdmDfmSyn.AsciiCharProc;
begin
  fTokenID := tkString;
  repeat
    Inc(Run);
  until not (fLine[Run] in ['0'..'9']);
end;

procedure TdmDfmSyn.BraceCloseProc;
begin
  inc(Run);
  fRange := rsUnknown;
  fTokenId := tkIdentifier;
end;

procedure TdmDfmSyn.BraceOpenProc;
begin
  fRange := rsComment;
  CommentProc;
end;

procedure TdmDfmSyn.CommentProc;
begin
  fTokenID := tkComment;
  repeat
    inc(Run);
    if fLine[Run] = '}' then begin
      Inc(Run);
      fRange := rsUnknown;
      break;
    end;
  until fLine[Run] in [#0, #10, #13];
end;

procedure TdmDfmSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
  if (fLine[Run] = #10) then Inc(Run);
end;

procedure TdmDfmSyn.EndProc;
begin
  if (fLine[Run + 1] in ['n', 'N']) and
     (fLine[Run + 2] in ['d', 'D']) and
     not (fLine[Run + 3] in ['_', '0'..'9', 'a'..'z', 'A'..'Z'])
  then begin
    fTokenID := tkKey;
    Inc(Run, 3);
  end else
    AltProc;
end;

procedure TdmDfmSyn.IntegerProc;
begin
  fTokenID := tkNumber;
  repeat
    inc(Run);
  until not (fLine[Run] in ['0'..'9', 'A'..'F', 'a'..'f']);
end;

procedure TdmDfmSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TdmDfmSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TdmDfmSyn.NumberProc;
begin
  fTokenID := tkNumber;
  repeat
    Inc(Run);
    if fLine[Run] = '.' then begin
      if fLine[Run + 1] <> '.' then Inc(Run);
      break;
    end;
  until not (fLine[Run] in ['0'..'9', 'e', 'E']);
end;

procedure TdmDfmSyn.ObjectProc;
begin
  if (fLine[Run + 1] in ['b', 'B']) and
     (fLine[Run + 2] in ['j', 'J']) and
     (fLine[Run + 3] in ['e', 'E']) and
     (fLine[Run + 4] in ['c', 'C']) and
     (fLine[Run + 5] in ['t', 'T']) and
     not (fLine[Run + 6] in ['_', '0'..'9', 'a'..'z', 'A'..'Z'])
  then begin
    fTokenID := tkKey;
    Inc(Run, 6);
  end else
    AltProc;
end;

procedure TdmDfmSyn.SpaceProc;
begin
  fTokenID := tkSpace;
  repeat
    Inc(Run);
  until (fLine[Run] > #32) or (fLine[Run] in [#0, #10, #13]);
end;

procedure TdmDfmSyn.StringProc;
begin
  fTokenID := tkString;
  repeat
    Inc(Run);
    if fLine[Run] = '''' then begin
      Inc(Run);
      if fLine[Run] <> '''' then break
    end;
  until fLine[Run] in [#0, #10, #13];
end;

procedure TdmDfmSyn.SymbolProc;
begin
  inc(Run);
  fTokenID := tkSymbol;
end;

procedure TdmDfmSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TdmDfmSyn.Next;
begin
  fTokenPos := Run;
  if fRange = rsComment then begin
    if fLine[Run] = #0 then NullProc
                       else CommentProc;
  end else
    fProcTable[fLine[Run]];
end;

function TdmDfmSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;
end;

function TdmDfmSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TdmDfmSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TdmDfmSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TdmDfmSyn.GetTokenAttribute: TmwHighLightAttributes;
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkString: Result := fStringAttri;
    tkSymbol: Result := fSymbolAttri;
    tkUnknown: Result := fIdentifierAttri;
    else Result := nil;
  end;
end;

function TdmDfmSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenID);
end;

function TdmDfmSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TdmDfmSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TdmDfmSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TdmDfmSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TdmDfmSyn.GetLanguageName: string;
begin
  Result := MWS_LangDfm;
end;

function TdmDfmSyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings, hcExportable];
end;

procedure TdmDfmSyn.SetLineForExport(NewValue: String);
begin
  fLine := PChar(NewValue);
  Run := 0;
  ExportNext;
end;

procedure TdmDfmSyn.ExportNext;
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
  if Assigned(Exporter) then
    Case GetTokenID of
      tkComment: TmwCustomExport(Exporter).FormatToken(GetToken, fCommentAttri, True, False);
      tkIdentifier: TmwCustomExport(Exporter).FormatToken(GetToken, fIdentifierAttri, False, False);
      tkKey: TmwCustomExport(Exporter).FormatToken(GetToken, fKeyAttri, False, False);
      tkNumber: TmwCustomExport(Exporter).FormatToken(GetToken, fNumberAttri, False, False);
      tkSpace: TmwCustomExport(Exporter).FormatToken(GetToken, fSpaceAttri, False, True);
      tkString: TmwCustomExport(Exporter).FormatToken(GetToken, fStringAttri, True, False);
    end;
end;

end.
