unit GpProfLists;

interface

uses
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

implementation

uses
  SysUtils,
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

end.