{+--------------------------------------------------------------------------+
 | Unit:        mGenLex
 | Created:     7.98
 | Author:      Martin Waldenburg
 | Copyright    1998, all rights reserved.
 | Description: tokenlist used by the generator. Create by the generator itself.
 | Version:     0.6 Beta
 | Status       FreeWare
 | DISCLAIMER:  This is provided as is, expressly without a warranty of any kind.
 |              You use it at your own risc.
 +--------------------------------------------------------------------------+}
{Created by mwLexGen}
unit mGenLex;

interface

uses
  SysUtils, Windows, Messages, Classes, Controls, mwTLongIntList;

var
  Identifiers: array[#0..#255] of ByteBool;
  mHashTable: array[#0..#255] of Integer;

Type
  TIdTokenKind = (
    IdBeginFunc,
    IdBeginProc,
    IdBraceOpen,
    IdChars,
    IdCharset,
    IdCRLF,
    IdEndFunc,
    IdEndProc,
    IdIdent,
    IdIdentifier,
    IdIdentStart,
    IdKeys,
    IdNull,
    IdSensitive,
    IdSpace,
    IdStop,
    IdUnknown);

type
  TmwGenLex = class(TObject)
  private
    fOrigin: PChar;
    fProcTable: array[#0..#255] of procedure of Object;
    fFuncTable: array[#0..#255] of function: TIdTokenKind of Object;
    Run: LongInt;
    Walker: LongInt;
    Running: LongInt;
    fStringLen: Integer;
    fToIdent: PChar;
    fTokenizing: Boolean;
    FLinePosList: TLongIntList;
    FTokenPositionsList: TLongIntList;
    fIdentFuncTable: array[0..130] of function: TIdTokenKind of Object;
    function KeyHash(ToHash: PChar): Integer;
    function KeyComp(aKey: String): Boolean;
    function Func49:TIdTokenKind;
    function Func60:TIdTokenKind;
    function Func67:TIdTokenKind;
    function Func75:TIdTokenKind;
    function Func81:TIdTokenKind;
    function Func89:TIdTokenKind;
    function Func122:TIdTokenKind;
    function Func130:TIdTokenKind;
    procedure BraceOpenProc;
    function BraceOpenFunc:TIdTokenKind;
    procedure CRLFProc;
    function CRLFFunc:TIdTokenKind;
    procedure CharsetProc;
    function CharsetFunc:TIdTokenKind;
    procedure IdentProc;
    function IdentFunc:TIdTokenKind;
    procedure NullProc;
    function NullFunc:TIdTokenKind;
    procedure SpaceProc;
    function SpaceFunc:TIdTokenKind;
    procedure StopProc;
    function StopFunc:TIdTokenKind;
    procedure UnknownProc;
    function UnknownFunc: TIdTokenKind;
    function AltFunc: TIdTokenKind;
    procedure InitIdent;
    function IdentKind(MayBe: PChar): TIdTokenKind;
    procedure SetOrigin(NewValue: PChar);
    procedure SetRunPos(Value: Integer);
    procedure MakeMethodTables;
    function GetRunId: TIdTokenKind;
    function GetRunToken: String;
  protected
  public
    constructor Create;
    destructor Destroy; override;
    procedure Tokenize;
    procedure Next;
    property Origin: PChar read fOrigin write SetOrigin;
    property RunPos: Integer read Run write SetRunPos;
    function NextToken: String;
    property RunId: TIdTokenKind read GetRunId;
    property RunToken: String read GetRunToken;
  published 
  end;

implementation

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
    Case I in['_', 'a'..'z', 'A'..'Z'] of
      True: mHashTable[I] := Ord(J) - 64
    else mHashTable[I] := 0;
    end;
  end;
end;

procedure TmwGenLex.InitIdent;
var
  I: Integer;
begin
  for I := 0 to 130 do
    Case I of
      49: fIdentFuncTable[I] := Func49;
      60: fIdentFuncTable[I] := Func60;
      67: fIdentFuncTable[I] := Func67;
      75: fIdentFuncTable[I] := Func75;
      81: fIdentFuncTable[I] := Func81;
      89: fIdentFuncTable[I] := Func89;
      122: fIdentFuncTable[I] := Func122;
      130: fIdentFuncTable[I] := Func130;
    else fIdentFuncTable[I] := AltFunc;
    end;
end;

function TmwGenLex.KeyHash(ToHash: PChar): Integer;
begin
  Result := 0;
  while ToHash^ in ['_', '0'..'9', 'a'..'z', 'A'..'Z'] do
  begin
    inc(Result, mHashTable[ToHash^]);
    inc(ToHash);
  end;
  fStringLen := ToHash - fToIdent;
end; { KeyHash }

function TmwGenLex.KeyComp(aKey: String): Boolean;
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
end; { KeyComp }

function TmwGenLex.Func49: TIdTokenKind;
begin
  if KeyComp('Chars') then Result := IdChars else Result := IDIdentifier;
end;

function TmwGenLex.Func60: TIdTokenKind;
begin
  if KeyComp('Keys') then Result := IdKeys else Result := IDIdentifier;
end;

function TmwGenLex.Func67: TIdTokenKind;
begin
  if KeyComp('EndFunc') then Result := IdEndFunc else Result := IDIdentifier;
end;

function TmwGenLex.Func75: TIdTokenKind;
begin
  if KeyComp('EndProc') then Result := IdEndProc else Result := IDIdentifier;
end;

function TmwGenLex.Func81: TIdTokenKind;
begin
  if KeyComp('BeginFunc') then Result := IdBeginFunc else Result := IDIdentifier;
end;

function TmwGenLex.Func89: TIdTokenKind;
begin
  if KeyComp('BeginProc') then Result := IdBeginProc else Result := IDIdentifier;
end;

function TmwGenLex.Func122: TIdTokenKind;
begin
  if KeyComp('Sensitive') then Result := IdSensitive else Result := IDIdentifier;
end;

function TmwGenLex.Func130: TIdTokenKind;
begin
  if KeyComp('IdentStart') then Result := IdIdentStart else Result := IDIdentifier;
end;

function TmwGenLex.AltFunc: TIdTokenKind;
begin
  Result := IdIdentifier;
end;

function TmwGenLex.IdentKind(MayBe: PChar): TIdTokenKind;
var
  HashKey: Integer;
begin
  fToIdent := MayBe;
  HashKey := KeyHash(MayBe);
  if HashKey < 131 then Result := fIdentFuncTable[HashKey] else Result := IdIdentifier;
end;

procedure TmwGenLex.MakeMethodTables;
var
  I: Char;
begin
  for I := #0 to #255 do
    case I of
      '{':
        begin
          fProcTable[I] := BraceOpenProc;
          fFuncTable[I] := BraceOpenFunc;
        end;
      #10, #13:
        begin
          fProcTable[I] := CRLFProc;
          fFuncTable[I] := CRLFFunc;
        end;
      #39, '#':
        begin
          fProcTable[I] := CharsetProc;
          fFuncTable[I] := CharsetFunc;
        end;
      'A'..'Z', 'a'..'z', '_':
        begin
          fProcTable[I] := IdentProc;
          fFuncTable[I] := IdentFunc;
        end;
      #0:
        begin
          fProcTable[I] := NullProc;
          fFuncTable[I] := NullFunc;
        end;
      #1..#9, #11, #12, #14..#32:
        begin
          fProcTable[I] := SpaceProc;
          fFuncTable[I] := SpaceFunc;
        end;
      '|':
        begin
          fProcTable[I] := StopProc;
          fFuncTable[I] := StopFunc;
        end;
    else
      begin
        fProcTable[I] := UnknownProc;
        fFuncTable[I] := UnknownFunc;
      end;
    end;
end;

constructor TmwGenLex.Create;
begin
  inherited Create;
  InitIdent;
  MakeMethodTables;
  FTokenPositionsList := TLongIntList.Create;
  FLinePosList := TLongIntList.Create;
end; { Create }

destructor TmwGenLex.Destroy;
begin
  inherited Destroy;
  FTokenPositionsList.Free;
  FLinePosList.Free;
end; { Destroy }

procedure TmwGenLex.SetOrigin(NewValue: PChar);
begin
  fOrigin := NewValue;
  Run := 0;
  Walker := 0;
  FTokenPositionsList.Clear;
  FTokenPositionsList.Add(0);
  FLinePosList.Clear;
  FLinePosList.Add(0);
end; { SetOrigin }

procedure TmwGenLex.SetRunPos(Value: Integer);
begin
  Run := Value;
end;

procedure TmwGenLex.BraceOpenProc;
begin
  inc(Walker);
  while FOrigin[Walker] <> #0 do
    case FOrigin[Walker] of
      '}':
        begin
          inc(Walker);
          break;
        end;
      #10:
        begin
          inc(Walker);
          if fTokenizing then FLinePosList.Add(Walker);
        end;

      #13:
        begin
          if FOrigin[Walker + 1] = #10 then inc(Walker, 2) else inc(Walker);
          if fTokenizing then FLinePosList.Add(Walker);
        end;
    else inc(Walker);
    end;
end;

function TmwGenLex.BraceOpenFunc:TIdTokenKind;
begin
  Result := IDBraceOpen;
end;

procedure TmwGenLex.CRLFProc;
begin
  Case FOrigin[Walker] of
    #10: inc(Walker);
    #13:
      Case FOrigin[Walker + 1] of
        #10: inc(Walker, 2);
        else inc(Walker);
      end;
  end;
  if fTokenizing then FLinePosList.Add(Walker);
end;

function TmwGenLex.CRLFFunc:TIdTokenKind;
begin
  Result := IdCRLF;
end;

procedure TmwGenLex.CharsetProc;
begin
  while FOrigin[Walker] <> #0 do
  begin
    case FOrigin[Walker] of
      #10, #13: break;
      ':': if FOrigin[Walker + 1] = ':' then break else inc(Walker);
    else inc(Walker);
    end;
  end;
end;

function TmwGenLex.CharsetFunc:TIdTokenKind;
begin
  Result := IDCharSet;
end;

procedure TmwGenLex.IdentProc;
begin
  inc(Walker);
  while Identifiers[fOrigin[Walker]] do inc(Walker);
end;

function TmwGenLex.IdentFunc:TIdTokenKind;
begin
  Result := IdentKind((fOrigin + Running));
end;

procedure TmwGenLex.NullProc;
begin
  if fTokenizing then
    if not (FOrigin[Walker - 1] in [#10, #13]) then FLinePosList.Add(Walker);
end;

function TmwGenLex.NullFunc:TIdTokenKind;
begin
  Result := IdNull;
end;

procedure TmwGenLex.SpaceProc;
begin
  while fOrigin[Walker] in [#1..#9, #11, #12, #14..#32] do inc(Walker);
end;

function TmwGenLex.SpaceFunc:TIdTokenKind;
begin
  Result := IdSpace;
end;

procedure TmwGenLex.StopProc;
begin
  inc(Walker);
  while FOrigin[Walker] <> #0 do
    Case FOrigin[Walker] of
      #10: break;
      #13: break;
      '|':
        begin
          inc(Walker);
          break;
        end;
    else inc(Walker);
    end;
end;

function TmwGenLex.StopFunc:TIdTokenKind;
begin
  Result := IdUnknown;
  if FOrigin[Running + 1] = '>' then
    if FOrigin[Running + 2] = '<' then
      if FOrigin[Running + 3] = '|' then Result := IDStop;
end;

procedure TmwGenLex.UnknownProc;
begin
  inc(Walker);
end;

function TmwGenLex.UnknownFunc: TIdTokenKind;
begin
  Result := IdUnknown;
end;

function TmwGenLex.GetRunId: TIdTokenKind;
begin
  Running := FTokenPositionsList[Run];
  Result := fFuncTable[fOrigin[Running]];
end;

function TmwGenLex.GetRunToken: String;
var
  StartPos, EndPos, StringLen: Integer;
begin
  StartPos := FTokenPositionsList[Run];
  EndPos := FTokenPositionsList[Run + 1];
  StringLen := EndPos - StartPos;
  SetString(Result, (FOrigin + StartPos), Stringlen);
end;

procedure TmwGenLex.Tokenize;
begin
  fTokenizing := True;
  repeat
    fProcTable[fOrigin[Walker]];
    FTokenPositionsList.Add(Walker);
  until fOrigin[Walker] = #0;
  fTokenizing := False;
end;

procedure TmwGenLex.Next;
begin
  inc(Run);
end;

function TmwGenLex.NextToken: String;
var
  StartPos, EndPos, Len: LongInt;
begin
  StartPos := FTokenPositionsList[Run];
  EndPos := FTokenPositionsList[Run + 1];
  Len := EndPos - StartPos;
  SetString(Result, (FOrigin + StartPos), Len);
  inc(Run);
end;

Initialization
  MakeIdentTable;
end.
