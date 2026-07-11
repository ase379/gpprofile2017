unit GpProfLists;

interface

{$INCLUDE GpProf.inc}

uses
  Windows,
  Contnrs;

type
  TTLEl = record
    tleThread: integer;
    tleRemap : integer;
  end;

  PTLElements = ^TTLElements;
  TTLElements = array [0..0] of TTLEl;

  TThreadIdList = class
  private
    tlItems: PTLElements;
    tlCount: Cardinal;
    tlCapacity: Integer;
    tlRemap: Cardinal;
    tlLast : Cardinal;
    tlLastR: Cardinal;
    function Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
    function GetItem(aIndex: Integer): TTLEl;
  public
    constructor Create;
    destructor  Destroy; override;
    function    Remap(const aThreadId: Cardinal): integer;
    property    Count: Cardinal read tlCount;
    property    Items[aIndex: Integer]: TTLEl read GetItem;
  end;

  TThreadInformation = class
    ID   : Cardinal;
    Name : UTF8String;
  end;

  TThreadInformationList = TObjectList;

  TMPLEl = record
    mpleId    : UTF8String;
    mpleRemap : integer;
  end;

  TMeasurePointList = class
  private
    mplCount    : integer;
    mplCapacity : integer;
    mplRemap    : integer;
    mplItems    : array of TMPLEl;
    mplLastIdx  : integer;
    mplLock     : TRTLCriticalSection;
    function Search(const aId: UTF8String; out aRemap, aInsert: integer): boolean;
    function GetItem(aIndex: Integer): TMPLEl;
  public
    constructor Create;
    destructor Destroy; override;
    function Remap(const aMeasurePointId: UTF8String): integer;
    procedure Lock; {$IFDEF HAS_INLINE}inline;{$ENDIF}
    procedure Unlock; {$IFDEF HAS_INLINE}inline;{$ENDIF}
    property Count: integer read mplCount;
    property Items[aIndex: Integer]: TMPLEl read GetItem;
  end;

implementation

uses
  SysUtils,
  {$IFDEF HAS_ANSISTRINGS_UNIT}
  AnsiStrings,
  {$ENDIF}
  GpProfCommon;

{ TThreadIdList }

constructor TThreadIdList.Create;
begin
  inherited Create;
  tlCount := 0;
  tlCapacity := 0;
  tlRemap := 0;
  tlItems := nil;
  tlLast := 0;
  tlLastR := 0;
end; { TThreadIdList.Create }

destructor TThreadIdList.Destroy;
begin
  if tlItems <> nil then
    FreeMem(tlItems);
  inherited Destroy;
end; { TThreadIdList.Destroy }

function TThreadIdList.GetItem(aIndex: Integer): TTLEl;
begin
  if (aIndex >= 0) and (aIndex < Integer(tlCount)) then
    Result := tlItems^[aIndex]
  else
    raise Exception.CreateFmt(Self.ClassName + ': Invalid Item Index %d (Count = %d)', [aIndex, tlCount]);
end; { TThreadIdList.GetItem }

function TThreadIdList.Remap(const aThreadId: Cardinal): integer;
var
  LRemap : Cardinal;
  LInsert: Cardinal;
  LNewCount: Integer;
begin
  if aThreadId = tlLast then
    Result := tlLastR
  else if not Search(aThreadId, LRemap, LInsert) then begin
    // grow tlItems
    LNewCount := tlCount + 1;
    if LNewCount > tlCapacity then
    begin
      tlCapacity := GrowCollection(tlCapacity, LNewCount);
      ReallocMem(tlItems, SizeOf(TTLEl)*tlCapacity);
    end;
    // get new remap number
    Inc(tlRemap);
    if byte(tlRemap) = 0 then Inc(tlRemap);
    // insert new element
    if LInsert < tlCount then
      Move(tlItems^[LInsert], tlItems^[LInsert + 1], (tlCount-LInsert)*SizeOf(TTLEl));
    with tlItems^[LInsert] do begin
      tleThread := aThreadId;
      tleRemap  := tlRemap;
    end;
    Inc(tlCount);
    tlLast  := aThreadId;
    tlLastR := tlRemap;
    Result  := tlRemap;
  end
  else begin
    tlLast  := aThreadId;
    tlLastR := LRemap;
    Result  := LRemap;
  end;
end; { TThreadIdList.Remap }

function TThreadIdList.Search(const aThreadId: Cardinal; var remap, insertIdx: Cardinal): boolean;
var
  l, m, h: Cardinal;
  mid    : Cardinal;
begin
  if tlCount = 0 then begin
    insertIdx := 0;
    Result := False;
  end
  else begin
    L := 0;
    H := tlCount - 1;
    repeat
      m := L + (H - L) div 2;
      mid := tlItems^[m].tleThread;
      if aThreadId = mid then begin
        remap := tlItems^[m].tleRemap;
        Result := True;
        Exit;
      end else if aThreadId < mid then H := m - 1
      else L := m + 1;
    until L > H;
    Result := False;
    if aThreadId > mid then insertIdx := m + 1
                    else insertIdx := m;
  end;
end; { TThreadIdList.Search }

{ TMeasurePointList }

constructor TMeasurePointList.Create;
begin
  inherited Create;
  mplLastIdx := -1;
  InitializeCriticalSection(mplLock);
end;

destructor TMeasurePointList.Destroy;
begin
  DeleteCriticalSection(mplLock);
  inherited;
end;

function TMeasurePointList.GetItem(aIndex: Integer): TMPLEl;
begin
  if (aIndex >= 0) and (aIndex < Integer(mplCount)) then
    Result := mplItems[aIndex]
  else
    raise Exception.CreateFmt(Self.ClassName + ': Invalid Item Index %d (Count = %d)', [aIndex, mplCount]);
end;

function TMeasurePointList.Search(const aId: UTF8String; out aRemap, aInsert: integer): boolean;
var
  lo, hi, mid, cmp: integer;
  pSearchId, pItemId: PAnsiChar;
begin
  lo := 0;
  hi := mplCount - 1;
  pSearchId := pointer(aId);
  while lo <= hi do begin
    mid := (lo + hi) div 2;
    pItemId := pointer(mplItems[mid].mpleId);
    cmp := {$IFDEF HAS_ANSISTRINGS_UNIT}AnsiStrings.{$ENDIF}StrComp(pItemId, pSearchId);
    if cmp < 0 then lo := mid + 1
    else if cmp > 0 then hi := mid - 1
    else begin
      aRemap  := mplItems[mid].mpleRemap;
      aInsert := mid;
      Result  := True;
      Exit;
    end;
  end;
  aInsert := lo;
  Result  := False;
end;

function TMeasurePointList.Remap(const aMeasurePointId: UTF8String): integer;
var
  LRemap : integer;
  LInsert: integer;
  LNewCount: integer;
begin
  if (mplLastIdx >= 0) and (mplLastIdx < mplCount) and (aMeasurePointId = mplItems[mplLastIdx].mpleId) then begin
    Result := mplItems[mplLastIdx].mpleRemap;
    Exit;
  end;
  if not Search(aMeasurePointId, LRemap, LInsert) then begin
    LNewCount := mplCount + 1;
    if LNewCount > mplCapacity then
    begin
      mplCapacity := GrowCollection(mplCapacity, LNewCount);
      SetLength(mplItems, mplCapacity);
    end;

    Inc(mplRemap);
    if byte(mplRemap) = 0 then Inc(mplRemap);

    if LInsert < mplCount then
    begin
      System.Move(mplItems[LInsert], mplItems[LInsert + 1], (mplCount - LInsert) * SizeOf(TMPLEl));
      Pointer(mplItems[LInsert].mpleId) := nil;
    end;

    mplItems[LInsert].mpleId    := aMeasurePointId;
    mplItems[LInsert].mpleRemap := mplRemap;

    Inc(mplCount);
    mplLastIdx := LInsert;
    Result     := mplRemap;
  end else begin
    mplLastIdx := LInsert;
    Result     := LRemap;
  end;
end;

procedure TMeasurePointList.Lock;
begin
  EnterCriticalSection(mplLock);
end;

procedure TMeasurePointList.Unlock;
begin
  LeaveCriticalSection(mplLock);
end;

end.