{+-----------------------------------------------------------------------------+
 | Unit:        mwEditStrings
 | Created:     05.1999
 | Author:      Martin Waldenburg
 | Description: a alternative string list
 |
 | Version:     0.503
 | Copyright (c) 1999 Martin Waldenburg
 | No rights reserved.
 | Portions Copyright Inprise Corporation.
 | Thanks to: Michael Hieke
 +--------------------------------------------------------------------------+}
unit mwEditStrings;

{$R-}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TIndexEvent = procedure(Index: Integer) of object;

  PmwEditItem = ^TmwEditItem;
  TmwEditItem = record
    FString: string;
    Finfo: TObject;
    FObject: TObject;
  end;

  PEditItemArray = ^TEditItemArray;
  TEditItemArray = array[0..0] of PmwEditItem;

  TmwEditFileBuffer = class(TObject)
  private
    fBuffFile: File;
    fFileName: String;
    fLineStart: LongInt;
    fMaxMemorySize: Longint;
    fMemorySize: LongInt;
    fMemory: PChar;
    fMemoryPos: LongInt;
    fEof: Boolean;
    fSize: Longint;
    fUnixStyle: Boolean;
    function GetMemoryFull: Boolean;
    procedure SetMaxMemorySize(NewValue: Longint);
    function GetFileEof: Boolean;
    function GetPosition: Longint;
    procedure SetPosition(NewPos: Longint);
  protected
  public
    constructor create(FileName: string; ClearFile: Boolean);
    destructor destroy; override;
    procedure FillMemory;
    function ReadLine: PChar;
    procedure WriteLine(NewLine: String);
    procedure FlushMemory;
    procedure ResetBuff;
    property MaxMemorySize: Longint read fMaxMemorySize write SetMaxMemorySize;
    property Memory: PChar read fMemory;
    property MemoryFull: Boolean read GetMemoryFull;
    property Position: Longint read GetPosition write SetPosition;
    property FileEof: Boolean read GetFileEof;
    property Eof: Boolean read fEof;
    property Size: Longint read fSize;
    property UnixStyle: Boolean read fUnixStyle write fUnixStyle;
  published
  end;

  TmwEditItemList = class(TObject)
  private
    FCapacity: Integer;
    FCount: Integer;
    FList: PEditItemArray;
  protected
    function GetItems(Index: Integer): PmwEditItem;
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetItems(Index: Integer; Item: PmwEditItem);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(Item: PmwEditItem): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Expand(NewDelta: Integer);
    procedure Insert(Index: Integer; Item: PmwEditItem);
    procedure MultiDelete(Index, Number: Integer);
    procedure PrepareMultiInsert(Index, Number: Integer);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount;
    property Items[Index: Integer]: PmwEditItem read GetItems write SetItems; default;
  end;

  TmwEditStrings = class(TStrings)
  private
    FList: TmwEditItemList;
    FOnChange: TNotifyEvent;
    FOnChanging: TNotifyEvent;
    FOnDeleted: TIndexEvent;
    FOnPutted: TIndexEvent;
    FOnInserted: TIndexEvent;
    FOnLoaded: TNotifyEvent;
    FOnAdded: TNotifyEvent;
    FUpdateCount: Integer;
    fWriteUnixStyle: Boolean;
    fHandle: THandle;
    procedure PutNewItem(Index: Integer; const S: string);
    procedure WndProc(var Message: TMessage);
  protected
    procedure Changed; virtual;
    procedure Changing; virtual;
    function Get(Index: Integer): string; override;
    function GetCapacity: Integer; override;
    function GetCount: Integer; override;
    function GetInfo(Index: Integer): TObject;
    function GetObject(Index: Integer): TObject; override;
    procedure InsertItem(Index: Integer; const S: string);
    procedure Put(Index: Integer; const S: string); override;
    procedure PutInfo(Index: Integer; AInfo: TObject);
    procedure PutObject(Index: Integer; AObject: TObject); override;
    procedure SetCapacity(NewCapacity: Integer); override;
    procedure SetUpdateState(Updating: Boolean); override;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Add(const S: string): Integer; override;
    procedure BeginUpdate;
    procedure Clear; override;
    procedure Delete(Index: Integer); override;
    procedure DeleteBetween(Index1, Pos1, Index2, Pos2: Integer);
    procedure EndUpdate;
    procedure Exchange(Index1, Index2: Integer); override;
    procedure Insert(Index: Integer; const S: string); override;
    procedure InsertAt(Index, aPos: Integer; S: string);
    procedure InsertStrings(Index: Integer; StringsToInsert: TStrings);
    procedure InsertStringsBetween(Index1, Pos1, Index2, Pos2: Integer; StringsToInsert: TStrings);
    procedure LoadFromFile(const FileName: string); override;
    procedure MultiDelete(Index, Number: Integer);
    procedure SaveToFile(const FileName: string); override;
    procedure SetTextStr(const Value: string); override;
    property Handle: THandle read fHandle;
    property Infos[Index: Integer]: TObject read GetInfo write PutInfo;
    property WriteUnixStyle: Boolean read fWriteUnixStyle write fWriteUnixStyle;
    property OnAdded: TNotifyEvent read FOnAdded write FOnAdded;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnChanging: TNotifyEvent read FOnChanging write FOnChanging;
    property OnDeleted: TIndexEvent read FOnDeleted write FOnDeleted;
    property OnInserted: TIndexEvent read FOnInserted write FOnInserted;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnPutted: TIndexEvent read FOnPutted write FOnPutted;
  end;

implementation

{ TmwEditFileBuffer }

constructor TmwEditFileBuffer.create(FileName: string; ClearFile: Boolean);
var
  fHandle: Integer;
begin
  fFileName := FileName;
  if not ClearFile then
  if not FileExists(FileName) then
  begin
    fHandle := FileCreate(FileName);
    FileClose(fHandle);
  end;
  inherited create;
  AssignFile(fBuffFile, FileName);
  if ClearFile then Rewrite(fBuffFile, 1) else Reset(fBuffFile, 1);
  fSize := FileSize(fBuffFile);
  fEof := fSize = 0;
  MaxMemorySize := 4096;
  fMemorySize := 0;
  fMemoryPos := 0;
  fUnixStyle := False;
end;

destructor TmwEditFileBuffer.destroy;
begin
  ReallocMem(fMemory, 0);
  CloseFile(fBuffFile);
  inherited destroy;
end;

function TmwEditFileBuffer.GetFileEof: Boolean;
begin
  Result := Position = Size;
end;

procedure TmwEditFileBuffer.SetMaxMemorySize(NewValue: Longint);
begin
  if fMaxMemorySize <> NewValue then begin
    fMaxMemorySize := NewValue;
    ReallocMem(fMemory, fMaxMemorySize + 1);
  end;
end;

procedure TmwEditFileBuffer.FillMemory;
var
  Readed: LongInt;
begin
  BlockRead(fBuffFile, fMemory^, fMaxMemorySize, Readed);
  fMemorySize := Readed;
  if not FileEof then
  begin
    while (fMemory[fMemorySize - 1] in [#10, #13]) and (fMemorySize > 1) do dec(fMemorySize);
    while (not (fMemory[fMemorySize - 1] in [#10, #13])) and (fMemorySize > 1) do dec(fMemorySize);
  end;
  fMemory[fMemorySize] := #0;
  Position := Position - Readed + fMemorySize;
  fLineStart := 0;
end;

function TmwEditFileBuffer.GetMemoryFull: Boolean;
begin
  Result := fMemorySize > 0;
end;

function TmwEditFileBuffer.ReadLine: PChar;
var
  LineEnd: LongInt;
begin
  if fMemoryPos = fMemorySize then FillMemory;
  fMemoryPos := fLineStart;
  while fMemoryPos < fMemorySize do
    Case fMemory[fMemoryPos] of
      #13:
        begin
          LineEnd := fMemoryPos;
          Inc(fMemoryPos);
          if fMemory[fMemoryPos] = #10 then Inc(fMemoryPos);
          fMemory[LineEnd] := #0;
          break;
        end;
      #10:
        begin
          LineEnd := fMemoryPos;
          inc(fMemoryPos);
          fMemory[LineEnd] := #0;
          break;
        end;
    else inc(fMemoryPos);
    end;
  Result := (fMemory + fLineStart);
  fLineStart := fMemoryPos;
  if (fMemoryPos = fMemorySize) and FileEof then fEof := True;
end;

procedure TmwEditFileBuffer.WriteLine(NewLine: String);
var
  Count, Pos: Longint;
begin
  if fUnixStyle then NewLine := NewLine + #10 else
    NewLine := NewLine + #13#10;
  Count := Length(NewLine);
  if (fMemoryPos >= 0) and (Count > 0) then
  begin
    Pos := fMemoryPos + Count;
    if Pos > 0 then
    begin
      if Pos > FMaxMemorySize then
      begin
        FlushMemory;
      end;
      StrECopy((fMemory + fMemoryPos), PChar(NewLine));
      fMemoryPos := fMemoryPos + Count;
      fMemory[fMemoryPos] := #0;
    end;
  end;
end;

procedure TmwEditFileBuffer.FlushMemory;
var
  Written: LongInt;
begin
  BlockWrite(fBuffFile, fMemory^, fMemoryPos, Written);
  fMemoryPos := 0;
end;

procedure TmwEditFileBuffer.ResetBuff;
begin
  fEof := False;
  fMemorySize := 0;
  fMemoryPos := 0;
  Position := 0;
end;

function TmwEditFileBuffer.GetPosition: Longint;
begin
  Result := FilePos(fBuffFile);
end;

procedure TmwEditFileBuffer.SetPosition(NewPos: Longint);
begin
  Seek(fBuffFile, NewPos);
end;

{ TmwEditItemList }

constructor TmwEditItemList.Create;
begin
  inherited Create;
  FCapacity := 0;
  FCount := 0;
end;

destructor TmwEditItemList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TmwEditItemList.Add(Item: PmwEditItem): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Expand(0);
  fList[Result] := Item;
  Inc(FCount);
end;

procedure TmwEditItemList.Clear;
begin
  SetCapacity(0);
end;

procedure TmwEditItemList.Delete(Index: Integer);
begin
  Dec(FCount);
  if Index < FCount then
    System.Move(fList[Index + 1], fList[Index],
      (FCount - Index) * SizeOf(PmwEditItem));
end;

procedure TmwEditItemList.Expand(NewDelta: Integer);
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else Delta := 4;
  if Delta < NewDelta then Delta := NewDelta;
  SetCapacity(FCapacity + Delta);
end;

function TmwEditItemList.GetItems(Index: Integer): PmwEditItem;
begin
  Result := fList[Index];
end;

procedure TmwEditItemList.Insert(Index: Integer; Item: PmwEditItem);
begin
  if FCount = FCapacity then Expand(0);
  if Index < FCount then
    System.Move(fList[Index], fList[Index + 1],
      (FCount - Index) * SizeOf(PmwEditItem));
  fList[Index] := Item;
  Inc(FCount);
end;

procedure TmwEditItemList.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity < FCount then FCount := NewCapacity;
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(fList, NewCapacity * SizeOf(PmwEditItem));
    FCapacity := NewCapacity;
  end;
end;

procedure TmwEditItemList.SetItems(Index: Integer; Item: PmwEditItem);
begin
  fList[Index] := Item;
end;

procedure TmwEditItemList.MultiDelete(Index, Number: Integer);
begin
  Dec(FCount, Number);
  if Index < FCount then
    System.Move(fList[Index + Number], fList[Index],
      (FCount - Index) * SizeOf(PmwEditItem));
end;

procedure TmwEditItemList.PrepareMultiInsert(Index, Number: Integer);
begin
  if FCount + Number >= FCapacity then SetCapacity(Count + Number + 256);
  if Index < FCount then
    System.Move(fList[Index], fList[Index + Number],
      (FCount - Index) * SizeOf(PmwEditItem));
  Inc(FCount, Number);
end;

{$R+}

{ TmwEditStrings }

function TmwEditStrings.Add(const S: string): Integer;
begin
  BeginUpdate;
  Result := fList.Count;
  InsertItem(Result, S);
  if Assigned(FOnAdded) then FOnAdded(Self);
  EndUpdate;
end;

procedure TmwEditStrings.BeginUpdate;
begin
  if FUpdateCount = 0 then SetUpdateState(True);
  Inc(FUpdateCount);
end;

procedure TmwEditStrings.Changed;
begin
  if (FUpdateCount = 0) and Assigned(FOnChange) then FOnChange(Self);
end;

procedure TmwEditStrings.Changing;
begin
  if (FUpdateCount = 0) and Assigned(FOnChanging) then FOnChanging(Self);
end;

procedure TmwEditStrings.Clear;
var
  I, Last: Integer;
begin
  BeginUpdate;
  Last := fList.Count - 1;
  for I := 0 to Last do
    if Assigned(fList[I]) then Dispose(fList[I]);
  fList.Clear;
  EndUpDate;
end;

constructor TmwEditStrings.Create;
begin
  FList := TmwEditItemList.Create;
  inherited Create;
  fHandle := AllocateHwnd(WndProc);
end;

procedure TmwEditStrings.Delete(Index: Integer);
begin
  if (Index >= 0) and (Index < fList.Count) then
  begin
    BeginUpdate;
    if assigned(fList[Index]) then Dispose(fList[Index]);
    fList.Delete(Index);
    if Assigned(FOnDeleted) then fOnDeleted(Index);
    EndUpdate;
  end;
end;

procedure TmwEditStrings.DeleteBetween(Index1, Pos1, Index2,
  Pos2: Integer);
var
  TempStr1, TempStr2: String;
  StringLen: Integer;
begin
  if (Index1 >= 0) and (Index1 <= Index2) and (Index2 < fList.Count) then
  begin
    BeginUpdate;
    StringLen := Length(fList[Index1].fString);
    if Pos1 <= StringLen + 1 then
      TempStr1 := Copy(fList[Index1].fString, 1, Pos1 - 1) else
      TempStr2 := fList[Index1].fString + StringOfChar(' ', Pos1 - StringLen - 1);

    StringLen := Length(fList[Index2].fString);
    TempStr2 := Copy(fList[Index2].fString, Pos2, StringLen);

    fList[Index1].fString := TempStr1 + TempStr2;
    TempStr1 := '';
    TempStr2 := '';
    if Index1 < Index2 then MultiDelete(Index1 + 1, Index2 - Index1 - 1);
    EndUpdate;
  end;
end;

destructor TmwEditStrings.Destroy;
begin
  Clear;
  FList.Free;
  DeallocateHWnd(fHandle);
  inherited Destroy;
end;

procedure TmwEditStrings.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then SetUpdateState(False);
end;

procedure TmwEditStrings.Exchange(Index1, Index2: Integer);
var
  Temp: PmwEditItem;
begin
  if (Index1 < 0) or (Index1 >= Count) then exit;
  if (Index2 < 0) or (Index2 >= Count) then exit;
  BeginUpdate;
  Temp := FList[Index1];
  fList[Index1] := FList[Index2];
  fList[Index2] := Temp;
  EndUpdate;
end;

function TmwEditStrings.Get(Index: Integer): string;
begin
  if (Index < 0) or (Index >= fList.Count) then Result := '' else
    Result := FList[Index].FString;
end;

function TmwEditStrings.GetCapacity: Integer;
begin
  Result := fList.Capacity;
end;

function TmwEditStrings.GetCount: Integer;
begin
  Result := fList.Count;
end;

function TmwEditStrings.GetInfo(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= fList.Count) then Result := nil else
    Result := FList[Index].FInfo;
end;

function TmwEditStrings.GetObject(Index: Integer): TObject;
begin
  if (Index < 0) or (Index >= fList.Count) then Result := nil else
    Result := FList[Index].FObject;
end;

procedure TmwEditStrings.Insert(Index: Integer; const S: string);
begin
  if (Index >= 0) and (Index <= fList.Count) then
  begin
    BeginUpdate;
    InsertItem(Index, S);
    if Assigned(FOnInserted) then fOnInserted(Index);
    EndUpdate;
  end;
end;

procedure TmwEditStrings.InsertAt(Index, aPos: Integer; S: string);
var
  TempStr: String;
  StringLen: Integer;
begin
  if (Index >= 0) and (Index <= fList.Count) then
  begin
    if aPos < 1 then aPos := 1;
    TempStr := fList[Index].fString;
    StringLen := Length(TempStr);
    if aPos <= StringLen then
      System.Insert(TempStr, S, aPos) else
      if aPos = StringLen + 1 then TempStr := TempStr + S else
        TempStr := TempStr + StringOfChar(' ', aPos - StringLen - 1) + S;
    fList[Index].fString := TempStr;
    TempStr := '';
    EndUpdate;
  end;
end;

procedure TmwEditStrings.InsertItem(Index: Integer; const S: string);
var
  NewItem: PmwEditItem;
begin
  New(NewItem);
  NewItem.Finfo := nil;
  NewItem.FObject := nil;
  NewItem.FString := S;
  fList.Insert(Index, NewItem);
end;

procedure TmwEditStrings.InsertStrings(Index: Integer;
  StringsToInsert: TStrings);
var
  I, InsertIndex: Integer;
begin
  if (Index >= 0) and (Index <= fList.Count) then
  begin
    BeginUpdate;
    fList.PrepareMultiInsert(Index, StringsToInsert.Count);
    InsertIndex := Index;
    for I := 0 to StringsToInsert.Count - 1 do
    begin
      PutNewItem(InsertIndex, StringsToInsert[I]);
      inc(InsertIndex);
    end;
    EndUpdate;
  end;
end;

procedure TmwEditStrings.InsertStringsBetween(Index1, Pos1, Index2,
  Pos2: Integer; StringsToInsert: TStrings);
var
  TempStr1, TempStr2: String;
  StringLen: Integer;
  I, InsertIndex: Integer;
begin
  if (Index1 >= 0) and (Index1 <= Index2) and (Index2 < fList.Count) then
  begin
    BeginUpdate;
    StringLen := Length(fList[Index1].fString);
    if Pos1 <= StringLen + 1 then
      TempStr1 := Copy(fList[Index1].fString, 1, Pos1 - 1) else
      TempStr2 := fList[Index1].fString + StringOfChar(' ', Pos1 - StringLen - 1);
    StringLen := Length(fList[Index2].fString);
    TempStr2 := Copy(fList[Index2].fString, Pos2, StringLen);
    if StringsToInsert.Count < 2 then
    begin
      fList[Index1].fString := TempStr1 + StringsToInsert[0] + TempStr2;
      if Index1 < Index2 then MultiDelete(Index1 + 1, Index2 - Index1 - 1);
    end else
    begin
      fList[Index1].fString := TempStr1 + StringsToInsert[0];
      if Index1 < Index2 then MultiDelete(Index1 + 1, Index2 - Index1 - 1);
      fList.PrepareMultiInsert(Index1 + 1, StringsToInsert.Count - 1);
      InsertIndex := Index1 + 1;
      for I := 1 to StringsToInsert.Count - 2 do
      begin
        PutNewItem(InsertIndex, StringsToInsert[I]);
        inc(InsertIndex);
      end;
      PutNewItem(InsertIndex, StringsToInsert[StringsToInsert.Count - 1] + TempStr2);
    end;
    TempStr1 := '';
    TempStr2 := '';
    EndUpdate;
  end;
end;

procedure TmwEditStrings.LoadFromFile(const FileName: string);
var
  Reader: TmwEditFileBuffer;
  Max: Integer;
begin
  Reader := TmwEditFileBuffer.create(FileName, False);
  Max := Reader.Size;
  if Max > 524288 then Max := 524288;
  Reader.MaxMemorySize := Max;
  BeginUpdate;
  while not Reader.Eof do Add(Reader.ReadLine);
  EndUpdate;
  Reader.Free;
end;

procedure TmwEditStrings.MultiDelete(Index, Number: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index >= Count) then exit;
  if (Index + Number) > Count then Number := Count - Index;
  BeginUpdate;
  for I := Index to Index + Number - 1 do
    if Assigned(fList[I]) then Dispose(fList[I]);
  fList.MultiDelete(Index, Number);
  EndUpdate;
end;

procedure TmwEditStrings.Put(Index: Integer; const S: string);
begin
  if (Index >= 0) and (Index < fList.Count) then
  begin
    BeginUpdate;
    FList[Index].FString := S;
    if Assigned(FOnPutted) then fOnPutted(Index);
    EndUpdate;
  end;
end;

procedure TmwEditStrings.PutInfo(Index: Integer; AInfo: TObject);
begin
  if (Index >= 0) and (Index < fList.Count) then
  begin
    BeginUpDate;
    FList[Index].FInfo := AInfo;
    EndUpDate;
  end;
end;

procedure TmwEditStrings.PutNewItem(Index: Integer; const S: string);
var
  NewItem: PmwEditItem;
begin
  New(NewItem);
  NewItem.Finfo := nil;
  NewItem.FObject := nil;
  NewItem.FString := S;
  fList[Index] := NewItem;
end;
procedure TmwEditStrings.PutObject(Index: Integer; AObject: TObject);
begin
  if (Index >= 0) and (Index < fList.Count) then
  begin
    BeginUpDate;
    FList[Index].FObject := AObject;
    EndUpDate;
  end;
end;

procedure TmwEditStrings.SaveToFile(const FileName: string);
var
  Writer: TmwEditFileBuffer;
  I, Max: Integer;
begin
  Writer := TmwEditFileBuffer.create(FileName, True);
  Writer.UnixStyle := fWriteUnixStyle;
  if Count < 1024 then Max:= Length(Text) else Max := Count * 30;
  if Max > 524288 then Max := 524288;
  Writer.MaxMemorySize := Max;
  for I := 0 to Count - 1 do
    Writer.WriteLine(fList[I].fString);
  Writer.FlushMemory;
  Writer.Free;
end;

procedure TmwEditStrings.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity <> Capacity then
  begin
    BeginUpdate;
    fList.Capacity := NewCapacity;
    EndUpdate;
  end;
end;

procedure TmwEditStrings.SetTextStr(const Value: string);
begin
  BeginUpdate;
  inherited SetTextStr(Value);
  if Assigned(FOnLoaded) then FOnLoaded(Self);
  EndUpdate;
end;

procedure TmwEditStrings.SetUpdateState(Updating: Boolean);
begin
  if Updating then Changing else Changed;
end;

procedure TmwEditStrings.WndProc(var Message: TMessage);
begin

end;

end.

