(*

**************************************
     dmBatSyn.pas by David Muir
**************************************

Version 0.21
Last Edited: 1999-09-24
Copyright © 1999 David Muir.

Source and accompanying grammer file is distributed under the
Mozilla Public License v1.1 (see - http://www.mozilla.org/NPL/NPL-1_1Final.html)

Thanks to the entire mwEdit development team for creating an excellent suite of
components.

Please note:  the "dmBatSyn.msg" file contains errors that have been fixed in the
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

unit dmBatSyn;

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
    tkUnknown,
    tkVariable);

  TRangeState = (rsANil, rsUnKnown);

  TProcTableProc = procedure of Object;

  TIdentFuncTableFunc = function: TtkTokenKind of Object;

type
  TdmBatSyn = class(TmwCustomHighLighter)
  private
    fRange: TRangeState;
    fLine: PChar;
    fLineNumber: Integer;
    fExporter: TmwCustomExport;
    fProcTable: array[#0..#255] of TProcTableProc;
    Run: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenPos: Integer;
    FTokenID: TtkTokenKind;
    fIdentFuncTable: array[0..130] of TIdentFuncTableFunc;
    fCommentAttri: TmwHighLightAttributes;
    fIdentifierAttri: TmwHighLightAttributes;
    fKeyAttri: TmwHighLightAttributes;
    fNumberAttri: TmwHighLightAttributes;
    fSpaceAttri: TmwHighLightAttributes;
    fVariableAttri: TmwHighLightAttributes;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(const aKey: String): Boolean;
    function Func15: TtkTokenKind;
    function Func19: TtkTokenKind;
    function Func23: TtkTokenKind;
    function Func28: TtkTokenKind;
    function Func31: TtkTokenKind;
    function Func36: TtkTokenKind;
    function Func39: TtkTokenKind;
    function Func44: TtkTokenKind;
    function Func49: TtkTokenKind;
    function Func57: TtkTokenKind;
    function Func62: TtkTokenKind;
    function Func77: TtkTokenKind;
    function Func130: TtkTokenKind;
    procedure AmpersandProc;
    procedure CRProc;
    procedure CommentProc;
    procedure IdentProc;
    procedure LFProc;
    procedure NullProc;
    procedure NumberProc;
    procedure REMCommentProc;
    procedure SpaceProc;
    procedure UnknownProc;
    function AltFunc: TtkTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TtkTokenKind;
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
    property VariableAttri: TmwHighLightAttributes read fVariableAttri write fVariableAttri;
    property Exporter: TmwCustomExport read FExporter write FExporter;
  end;

procedure Register;

implementation

uses mwLocalStr;

procedure Register;
begin
  RegisterComponents('mw', [TdmBatSyn]);
end;

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

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
    Case I in ['_', 'A'..'Z', 'a'..'z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TdmBatSyn.InitIdent;
var
  I: Integer;
  pF: ^TIdentFuncTableFunc;
begin
  pF := @fIdentFuncTable;
  for I := Low(fIdentFuncTable) to High(fIdentFuncTable) do begin
    pF^ := AltFunc;
    Inc(pF);
  end;
  fIdentFuncTable[15] := Func15;
  fIdentFuncTable[19] := Func19;
  fIdentFuncTable[23] := Func23;
  fIdentFuncTable[28] := Func28;
  fIdentFuncTable[31] := Func31;
  fIdentFuncTable[36] := Func36;
  fIdentFuncTable[39] := Func39;
  fIdentFuncTable[44] := Func44;
  fIdentFuncTable[49] := Func49;
  fIdentFuncTable[57] := Func57;
  fIdentFuncTable[62] := Func62;
  fIdentFuncTable[77] := Func77;
  fIdentFuncTable[130] := Func130;
end;

function TdmBatSyn.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end;

function TdmBatSyn.KeyComp(const aKey: String): Boolean;
var
  I: Integer;
  Temp: PChar;
begin
  Temp := fToIdent;
  if Length(aKey) = fStringLen then
  begin
    Result := True;
    for i := 1 to fStringLen do
    begin
      if mHashTable[Temp^] <> mHashTable[aKey[i]] then
      begin
        Result := False;
        break;
      end;
      inc(Temp);
    end;
  end else Result := False;
end;

function TdmBatSyn.Func15: TtkTokenKind;
begin
  if KeyComp('if') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func19: TtkTokenKind;
begin
  if KeyComp('do') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func23: TtkTokenKind;
begin
  if KeyComp('in') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func28: TtkTokenKind;
begin
  if KeyComp('call') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func31: TtkTokenKind;
begin
  if KeyComp('echo') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func36: TtkTokenKind;
begin
  if KeyComp('rem') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func39: TtkTokenKind;
begin
  if KeyComp('for') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func44: TtkTokenKind;
begin
  if KeyComp('set') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func49: TtkTokenKind;
begin
  if KeyComp('not') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func57: TtkTokenKind;
begin
  if KeyComp('goto') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func62: TtkTokenKind;
begin
  if KeyComp('shift') then Result := tkKey else
    if KeyComp('pause') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func77: TtkTokenKind;
begin
  if KeyComp('exist') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.Func130: TtkTokenKind;
begin
  if KeyComp('errorlevel') then Result := tkKey else Result := tkIdentifier;
end;

function TdmBatSyn.AltFunc: TtkTokenKind;
begin
  Result := tkIdentifier;
end;

function TdmBatSyn.IdentKind(MayBe: PChar): TtkTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 131 then Result := fIdentFuncTable[HashKey] else Result := tkIdentifier;
end;

procedure TdmBatSyn.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '%': fProcTable[I] := AmpersandProc;
      #13: fProcTable[I] := CRProc;
      ':': fProcTable[I] := CommentProc;
      'A'..'Q', 'S'..'Z', 'a'..'q', 's'..'z', '_': fProcTable[I] := IdentProc;
      #10: fProcTable[I] := LFProc;
      #0: fProcTable[I] := NullProc;
      '0'..'9': fProcTable[I] := NumberProc;
      'R': fProcTable[I] := REMCommentProc;
      #1..#9, #11, #12, #14..#32: fProcTable[I] := SpaceProc;
    else fProcTable[I] := UnknownProc;
    end;
end;

constructor TdmBatSyn.Create(AOwner: TComponent);
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
  fVariableAttri := TmwHighLightAttributes.Create(MWS_AttrVariable);
  AddAttribute(fVariableAttri);
  SetAttributesOnChange(DefHighlightChange);
  InitIdent;
  MakeMethodTables;
  fDefaultFilter := MWS_FilterBatch;
  fRange := rsUnknown;
end;

procedure TdmBatSyn.SetLine(NewValue: String; LineNumber: Integer);
begin
  fLine := PChar(NewValue);
  Run := 0;
  fLineNumber := LineNumber;
  Next;
end;

procedure TdmBatSyn.AmpersandProc;
begin
  fTokenID := tkVariable;
  repeat
    Inc(Run);
  until not (fLine[Run] in ['0'..'9']);
end;

procedure TdmBatSyn.CRProc;
begin
  fTokenID := tkSpace;
  Inc(Run);
  if (fLine[Run] = #10) then Inc(Run);
end;

procedure TdmBatSyn.CommentProc;
begin
  fTokenID := tkIdentifier;
  Inc(Run);
  if fLine[Run] = ':' then begin
    fTokenID := tkComment;
    repeat
      Inc(Run);
    until (fLine[Run] in [#0, #10, #13]);
  end;
end;

procedure TdmBatSyn.IdentProc;
begin
  fTokenID := IdentKind((fLine + Run));
  Inc(Run, fStringLen);
  while Identifiers[fLine[Run]] do inc(Run);
end;

procedure TdmBatSyn.LFProc;
begin
  fTokenID := tkSpace;
  inc(Run);
end;

procedure TdmBatSyn.NullProc;
begin
  fTokenID := tkNull;
end;

procedure TdmBatSyn.NumberProc;
begin
  fTokenID := tkNumber;
  repeat
    Inc(Run);
  until not (fLine[Run] in ['0'..'9', '.']);
end;

procedure TdmBatSyn.REMCommentProc;
begin
  case FLine[Run + 1] of
    'E': case FLine[Run + 2] of
           'M': begin
                  Inc(Run, 3);
                  fTokenID := tkComment;
                  while FLine[Run] <> #0 do begin
                    case FLine[Run] of
                      #10, #13: break;
                    end; { case }
                    Inc(Run);
                  end; { while }
                end; { 'M' }
    end;
  end;
end;

procedure TdmBatSyn.SpaceProc;
begin
  fTokenID := tkSpace;
  repeat
    Inc(Run);
  until (fLine[Run] > #32) or (fLine[Run] in [#0, #10, #13]);
end;

procedure TdmBatSyn.UnknownProc;
begin
  inc(Run);
  fTokenID := tkUnknown;
end;

procedure TdmBatSyn.Next;
begin
  fTokenPos := Run;
  fProcTable[fLine[Run]];
end;

function TdmBatSyn.GetEol: Boolean;
begin
  Result := fTokenId = tkNull;
end;

function TdmBatSyn.GetRange: Pointer;
begin
  Result := Pointer(fRange);
end;

function TdmBatSyn.GetToken: String;
var
  Len: LongInt;
begin
  Len := Run - fTokenPos;
  SetString(Result, (FLine + fTokenPos), Len);
end;

function TdmBatSyn.GetTokenAttribute: TmwHighLightAttributes;
begin
  case fTokenID of
    tkComment: Result := fCommentAttri;
    tkIdentifier: Result := fIdentifierAttri;
    tkKey: Result := fKeyAttri;
    tkNumber: Result := fNumberAttri;
    tkSpace: Result := fSpaceAttri;
    tkUnknown: Result := fIdentifierAttri;
    tkVariable: Result := fVariableAttri;
    else Result := nil;
  end;
end;

function TdmBatSyn.GetTokenID: TtkTokenKind;
begin
  Result := fTokenId;
end;

function TdmBatSyn.GetTokenKind: integer;
begin
  Result := Ord(fTokenId);
end;

function TdmBatSyn.GetTokenPos: Integer;
begin
  Result := fTokenPos;
end;

procedure TdmBatSyn.ReSetRange;
begin
  fRange := rsUnknown;
end;

procedure TdmBatSyn.SetRange(Value: Pointer);
begin
  fRange := TRangeState(Value);
end;

function TdmBatSyn.GetIdentChars: TIdentChars;
begin
  Result := ['_', '0'..'9', 'a'..'z', 'A'..'Z'];
end;

function TdmBatSyn.GetLanguageName: string;
begin
  Result := MWS_LangBatch;
end;

function TdmBatSyn.GetCapability: THighlighterCapability;
begin
  Result := inherited GetCapability + [hcUserSettings, hcExportable];
end;

procedure TdmBatSyn.SetLineForExport(NewValue: String);
begin
  fLine := PChar(NewValue);
  Run := 0;
  ExportNext;
end;

procedure TdmBatSyn.ExportNext;
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
      tkVariable: TmwCustomExport(Exporter).FormatToken(GetToken, fVariableAttri, False, False);
    end;
end;

Initialization
  MakeIdentTable;
end.
