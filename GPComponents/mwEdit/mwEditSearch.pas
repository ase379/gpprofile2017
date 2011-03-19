{+--------------------------------------------------------------------------+
 | Class:       TmwEditSearch  ( TurboSearch )
 | Created:     8.97
 | Author:      Martin Waldenburg
 | Description: A very fast search engine, about twice as fast as Boyer-Moore,
 |              based on an article in the German magazine c't (8/97).
 |              The original is in 'C '. www.Heise.com.
 |              You can search case sensitive or case insensitive.
 |              Look_At is implemented.
 | Version:     2.4
 | Copyright (c) 1997 - 1999 Martin Waldenburg
 | All rights reserved.
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
 | 1. Software using this code must contain a visible line of credit,
 |    to Martin Waldenburg and the German magazine c't (8/97).
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
unit mwEditSearch;

// changes to use the engine with the mwCustomEdit component:                   //mh 1999-09-20
// - FindAll method and find result list
// - search for whole words

{$I mwEdit.inc}

interface

uses
  Windows,
  SysUtils,
  Messages,
  Classes,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  Menus;

procedure MakeCompTable(Sensitive: Boolean); Forward;
procedure MakeDelimiterTable;

type
  TmwEditSearch = class(Tobject)
  private
    Run: PChar;
    Origin: Pchar;
    TheEnd: PChar;
    Pat: string;
    fCount: Integer;
    fTextLen: Integer;
    Look_At: Integer;
    PatLen, PatLenPlus: Integer;
    Shift: array[0..255] of Integer;
    fSensitive: Boolean;
    fWhole: Boolean;
    fResults: TList;
    function GetFinished: Boolean;
    function GetResult(Index: integer): integer;
    function GetResultCount: integer;
    procedure initShiftTable(NewPattern: string);
    procedure SetPattern(const Value: string);
    procedure SetSensitive(const Value: Boolean);
  protected
  public
    constructor Create;
    destructor Destroy; override;
    function FindAll(const NewText: string): integer;
    function FindFirst(const NewText: string): Integer;
    procedure FixResults(First, Delta: integer);
    function Next: Integer;
    property Count: Integer read fCount write fCount;
    property Finished: Boolean read GetFinished;
    property Pattern: string read Pat write SetPattern;
    property Results[Index: integer]: integer read GetResult;
    property ResultCount: integer read GetResultCount;
    property Sensitive: Boolean read fSensitive write SetSensitive;
    property Whole: Boolean read fWhole write fWhole;
  published
  end;

implementation

var
  CompTableSensitive: boolean;
  CompTable: array[#0..#255] of Byte;
  DelimTable: array[#0..#255] of boolean;

constructor TmwEditSearch.Create;
begin
  inherited Create;
  fResults := TList.Create;
end;

procedure MakeCompTable(Sensitive: Boolean);
var
  I: Char;
begin
  if CompTableSensitive <> Sensitive then
  begin
    for I := #0 to #255 do CompTable[I] := ord(I);
    if not Sensitive then CharLowerBuff(PChar(@CompTable[#0]), 256);
  end;
end;

procedure MakeDelimiterTable;
var c: char;
begin
  for c := #0 to #255 do DelimTable[c] := not IsCharAlphaNumeric(c);
end;

function TmwEditSearch.GetFinished: Boolean;
begin
  if (Run >= TheEnd) or (PatLen >= fTextLen) then Result := True
  else Result := False;
end;

function TmwEditSearch.GetResult(Index: integer): integer;
begin
  Result := 0;
  if (Index >= 0) and (Index < fResults.Count) then
    Result := integer(fResults[Index]);
end;

function TmwEditSearch.GetResultCount: integer;
begin
  Result := fResults.Count;
end;

procedure TmwEditSearch.FixResults(First, Delta: integer);
var i: integer;
begin
  if (Delta <> 0) and (fResults.Count > 0) then begin
    i := Pred(fResults.Count);
    while i >= 0 do begin
      if integer(fResults[i]) <= First then break;
      fResults[i] := pointer(integer(fResults[i]) - Delta);
    end;
  end;
end;

procedure TmwEditSearch.initShiftTable(NewPattern: string);
var
  I: Byte;
begin
  if (Pat <> NewPattern) then begin
    Pat := NewPattern;
    PatLen := Length(Pat);
    if Patlen = 0 then raise Exception.Create('Pattern is empty');
    PatLenPlus := PatLen + 1;
    Look_At := 1;
    for I := 0 to 255 do Shift[I] := PatLenPlus;
    for I := 1 to PatLen do Shift[CompTable[Pat[i]]] := PatLenPlus - I;
    while Look_at < PatLen do
    begin
      if CompTable[Pat[PatLen]] = CompTable[Pat[PatLen - (Look_at)]] then exit;
      inc(Look_at);
    end;
  end;
end;

function TmwEditSearch.Next: Integer;
var
  I: Integer;
  J: PChar;

  function TestWholeWord: boolean;
  var Test: PChar;
  begin
    Test := Run - PatLen;
    Result := ((Test < Origin) or DelimTable[Test[0]]) and
              ((Run >= TheEnd) or DelimTable[Run[1]]);
  end;

begin
  Result := 0;
  inc(Run, PatLen);
  while Run < TheEnd do
  begin
    if CompTable[Pat[Patlen]] <> CompTable[Run^] then
      inc(Run, Shift[CompTable[(Run + 1)^]])
    else
    begin
      if (PatLen = 1) and (not fWhole or TestWholeWord) then
      begin
        inc(fCount);
        Result := Run - Origin + 1;
        exit;
      end;
      J := Run - PatLen + 1;
      I := 1;
      while CompTable[Pat[I]] = CompTable[J^] do
      begin
        inc(I);
        if (I = PatLen) and (not fWhole or TestWholeWord) then
        begin
          inc(fCount);
          Result := Run - Origin - Patlen + 2;
          exit;
        end;
        inc(J);
      end;
      inc(Run, Look_At + Shift[CompTable[(Run + Look_at)^]] - 1); // Suggestion of Angus Johnson
    end;
  end;
end;

destructor TmwEditSearch.Destroy;
begin
  fResults.Free;
  inherited Destroy;
end;

procedure TmwEditSearch.SetPattern(const Value: string);
begin
  initShiftTable(Value);
  fCount := 0;
end;

procedure TmwEditSearch.SetSensitive(const Value: Boolean);
begin
  fSensitive := Value;
  MakeCompTable(Value);
end;

function TmwEditSearch.FindAll(const NewText: string): integer;
var Found: integer;
begin
  // never shrink Capacity
  fResults.Count := 0;
  Found := FindFirst(NewText);
  while Found > 0 do
  begin
    fResults.Add(pointer(Found));
    Found := Next;
  end;
  Result := fResults.Count;
end;

function TmwEditSearch.FindFirst(const NewText: string): Integer;
begin
  Result := 0;
  fTextLen := Length(NewText);
  if fTextLen >= PatLen then
  begin
    Origin := PChar(NewText);
    TheEnd := Origin + fTextLen;
    Run := (Origin - 1);
    Result := Next;
  end;
end;

initialization
  CompTableSensitive := True; // force the table initialization
  MakeCompTable(False);
  MakeDelimiterTable;
end.

