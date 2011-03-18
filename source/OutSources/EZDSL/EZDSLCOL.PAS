{===EZDSLCOL==========================================================

Part of the EZ Delphi Structures Library--the collection classes.

EZDSLCOL is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 Clone & Assign always duped data objects
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLCol;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here----------------------}


{--------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

uses
  SysUtils,
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  WinTypes,
  WinProcs,
  {$ENDIF}
  Classes,
  EZDSLCts,
  EZDSLSup,
  EZDSLBse;

const
  ezcPageElementCount = 92;
  ezcPageArrayElementCount = 10922;
  ezcMaxCount = ezcPageElementCount * ezcPageArrayElementCount;

  coIndexError = -1;
  coOverflow   = -2;

type
  PezcPage = ^TezcPage;
  TezcPage = array [0..pred(ezcPageElementCount)] of pointer;

  PezcPageItem = ^TezcPageItem;
  TezcPageItem = record
    piUsedItems : integer;
    piItems     : PezcPage;
  end;

  PezcPageArray = ^TezcPageArray;
  TezcPageArray = array [0..pred(ezcPageArrayElementCount)] of TezcPageItem;

  TEZCollection = class(TAbstractContainer)
    private
      coPA : PezcPageArray;
      coSizeOfPA : Cardinal;
      coItemsInPA : integer;
      coMaxItemsInPA : integer;

      coCacheIndex     : longint;
      coCachePageNum   : integer;
      coCacheInxInPage : integer;

    protected
      function GetLimit : longint;

      procedure AddPageItem(AtIndex : integer);
      procedure DeletePageItem(AtIndex : integer);
      function GetPageGivenIndex(Index : longint;
                                  var InxInPage : integer) : integer;
      procedure GrowPageArray(NewNumElements : integer);
      procedure ValidateIndex(Index : longint);

    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;
      destructor Destroy; override;

      procedure Assign(Source : TPersistent); override;

      procedure Empty; override;

      function At(Index : longint) : pointer;
      procedure AtDelete(Index : longint);
      procedure AtFree(Index : longint);
      procedure AtInsert(Index : longint; Item : pointer);
      procedure AtPut(Index : longint; Item : pointer);
      procedure Delete(Item : pointer);
      procedure DeleteAll;
      procedure Free(Item : pointer);
      procedure FreeAll;
      function IndexOf(Item : pointer) : longint; virtual;
      procedure Insert(Item : pointer); virtual;
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : pointer;
      procedure Pack;

      property Limit : longint
         read GetLimit;

      property Items[Index : longint] : pointer
         read At
         write AtPut;
         default;
  end;

  TEZSortedCollection = class(TEZCollection)
    public
      constructor Create(DataOwner : boolean); override;

      function IndexOf(Item : pointer) : longint; override;
      procedure Insert(Item : pointer); override;
      function Search(Item : pointer; var Index : longint) : boolean; virtual;
  end;

  TEZStringCollection = class(TEZSortedCollection)
    public
      constructor Create(DataOwner : boolean); override;
  end;

  TEZStrZCollection = class(TEZSortedCollection)
    protected
    public
      constructor Create(DataOwner : boolean); override;
  end;

implementation

procedure RaiseCollError(Code : integer);
var
  SCode : integer;
begin
  case Code of
    coIndexError : SCode := escIndexError;
    coOverflow   : SCode := escTooManyItems;
  else
    SCode := escBadCaseSwitch;
  end;
  EZDSLSup.RaiseError(SCode);
end;

{===TEZCollection creation/destruction===============================}
constructor TEZCollection.Create(DataOwner : boolean);
begin
  acNodeSize := 0;
  inherited Create(DataOwner);

  GrowPageArray(1);
  AddPageItem(0);
end;
{--------}
constructor TEZCollection.Clone(Source : TAbstractContainer;
                                DataOwner : boolean; NewCompare : TCompareFunc);
var
  OldColl : TEZCollection absolute Source;
  NewData : pointer;
  i       : longint;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldColl.DupData;
  DisposeData := OldColl.DisposeData;

  if not (Source is TEZCollection) then
    RaiseError(escBadSource);

  if not OldColl.IsEmpty then begin
    for i := 0 to pred(OldColl.Count) do begin
      if DataOwner then
        NewData := DupData(OldColl.Items[i])
      else
        NewData := OldColl.Items[i];
      try
        Insert(NewData);
      except
        if DataOwner and Assigned(NewData) then
          DisposeData(NewData);
        raise;
      end;{try..except}
    end;
  end;
end;
{--------}
destructor TEZCollection.Destroy;
begin
  inherited Destroy;
  if Assigned(coPA) then begin
    DeletePageItem(0);
    FreeMem(coPA, coSizeOfPA);
  end;
end;
{====================================================================}


{===TEZCollection helper methods=====================================}
procedure TEZCollection.AddPageItem(AtIndex : integer);
var
  NewPage : PezcPage;
  NewMax  : integer;
begin
  {$IFDEF DEBUG}
  if (AtIndex > coItemsInPA) then
    raise Exception.Create('Bad AtIndex parm to AddPageItem');
  {$ENDIF}
  if (coItemsInPA = coMaxItemsInPA) then begin
    if (coMaxItemsInPA < ezcPageArrayElementCount) then begin
      case coMaxItemsInPA of
        1 : NewMax := 2;
        2 : NewMax := 4;
        4 : NewMax := 8;
        8 : NewMax := 16;
      else
        NewMax := coMaxItemsInPA + 16;
        if (NewMax > ezcPageArrayElementCount) then
          NewMax := ezcPageArrayElementCount;
      end;{case}
      GrowPageArray(NewMax);
    end
    else begin
      Pack;
      if (coItemsInPA = ezcPageArrayElementCount) then
        RaiseCollError(coOverflow);
    end;
  end;
  SafeGetMem(NewPage, ezcPageElementCount * sizeof(pointer));
  if (AtIndex < coItemsInPA) then
    Move(coPA^[AtIndex], coPA^[succ(AtIndex)], (coItemsInPA - AtIndex) * sizeof(TezcPageItem));
  with coPA^[AtIndex] do begin
    piUsedItems := 0;
    piItems := NewPage;
  end;
  inc(coItemsInPA);
end;
{--------}
procedure TEZCollection.DeletePageItem(AtIndex : integer);
begin
  {$IFDEF DEBUG}
  if (AtIndex >= coItemsInPA) then
    raise Exception.Create('Bad AtIndex parm to DeletePageItem');
  {$ENDIF}
  with coPA^[AtIndex] do
    FreeMem(piItems, ezcPageElementCount * sizeof(pointer));
  dec(coItemsInPA);
  if (AtIndex < coItemsInPA) then
    Move(coPA^[succ(AtIndex)], coPA^[AtIndex], (coItemsInPA - AtIndex) * sizeof(TezcPageItem));
end;
{--------}
function TEZCollection.GetPageGivenIndex(Index : longint;
                                          var InxInPage : integer) : integer;
const
  SizeOfPageItem = sizeof(TezcPageItem);
var
  PageNum    : integer;
  StartIndex : longint;
  GoForward  : boolean;
begin
  if (Index = coCacheIndex) then begin
    Result := coCachePageNum;
    InxInPage := coCacheInxInPage;
    Exit;
  end;
  if (Index < coCacheIndex) then begin
    if ((Index * 2) <= coCacheIndex) then begin
      {Index is closer to 0 than coCacheIndex}
      PageNum := 0;
      StartIndex := Index;
      GoForward := true;
    end
    else begin
      {Index is closer to coCacheIndex than 0}
      PageNum := coCachePageNum;
      StartIndex :=
         (coCacheIndex - coCacheInxInPage + coPA^[coCachePageNum].piUsedItems) -
         Index;
      GoForward := false;
    end;
  end
  else {Index > coCacheIndex} begin
    if (Index - coCacheIndex) <= (Count - Index - 1) then begin
      {Index is closer to coCacheIndex than Count}
      PageNum := coCachePageNum;
      StartIndex := Index - (coCacheIndex - coCacheInxInPage);
      GoForward := true;
    end
    else begin
      {Index is closer to Count than coCacheIndex}
      PageNum := pred(coItemsInPA);
      StartIndex := Count - Index;
      GoForward := false;
    end;
  end;
  {$IFDEF Win32}
  if GoForward then
    asm
      mov edx, Self
      mov edx, [edx].TEZCollection.coPA

      mov ecx, PageNum      {This assumes sizeof(TezcPageItem)=8}
      mov eax, ecx
      shl eax, 3
      add edx, eax

      mov eax, StartIndex
    @@NextPage:
      sub eax, [edx].TezcPageItem.piUsedItems
      jl @@FoundIt
      inc ecx
      add edx, SizeOfPageItem
      jmp @@NextPage
    @@FoundIt:
      add eax, [edx].TezcPageItem.piUsedItems
      mov edx, InxInPage
      mov [edx], eax
      mov @Result, ecx
    end
  else {go backwards}
    asm
      mov edx, Self
      mov edx, [edx].TEZCollection.coPA

      mov ecx, PageNum      {This assumes sizeof(TezcPageItem)=8}
      mov eax, ecx
      shl eax, 3
      add edx, eax

      mov eax, StartIndex
    @@NextPage:
      sub eax, [edx].TezcPageItem.piUsedItems
      jl @@FoundIt
      je @@FoundItAsZero
      dec ecx
      sub edx, SizeOfPageItem
      jmp @@NextPage
    @@FoundIt:
      neg eax
    @@FoundItAsZero:
      mov edx, InxInPage
      mov [edx], eax
      mov @Result, ecx
    end;
  {$ELSE}
  if GoForward then
    asm
      mov si, ds           {SI stores the Delphi data segment}
      lds di, Self
      lds di, [di].TEZCollection.coPA

      mov cx, PageNum      {This assumes sizeof(TezcPageItem)=6}
      mov ax, cx
      shl ax, 1
      add ax, cx
      shl ax, 1
      add di, ax

      xor bx, bx
      mov dx, StartIndex.Word[2]
      mov ax, StartIndex.Word[0]
    @@NextPage:
      sub ax, [di].TezcPageItem.piUsedItems
      sbb dx, bx
      jl @@FoundIt
      inc cx
      add di, SizeOfPageItem
      jmp @@NextPage
    @@FoundIt:
      add ax, [di].TezcPageItem.piUsedItems
      lds di, InxInPage
      mov [di], ax
      mov ds, si
      mov @Result, cx
    end
  else
    asm
      push ds
      lds di, Self
      lds di, [di].TEZCollection.coPA

      mov cx, PageNum      {This assumes sizeof(TezcPageItem)=6}
      mov ax, cx
      shl ax, 1
      add ax, cx
      shl ax, 1
      add di, ax

      xor bx, bx
      mov dx, StartIndex.Word[2]
      mov ax, StartIndex.Word[0]
    @@NextPage:
      sub ax, [di].TezcPageItem.piUsedItems
      sbb dx, bx
      jl @@FoundIt
      mov si, ax
      or si, dx
      je @@FoundItAsZero
      dec cx
      sub di, SizeOfPageItem
      jmp @@NextPage
    @@FoundIt:
      neg ax
    @@FoundItAsZero:
      lds di, InxInPage
      mov [di], ax
      pop ds
      mov @Result, cx
    end;
  {$ENDIF}
  coCacheIndex := Index;
  coCachePageNum := Result;
  coCacheInxInPage := InxInPage;
end;
{--------}
procedure TEZCollection.GrowPageArray(NewNumElements : integer);
var
  NewSize : Cardinal;
  NewPA   : PezcPageArray;
begin
  NewSize := NewNumElements * sizeof(TezcPageItem);
  SafeGetMem(NewPA, NewSize);
  if Assigned(coPA) then begin
    Move(coPA^, NewPA^, coItemsInPA * sizeof(TezcPageItem));
    FreeMem(coPA, coSizeOfPA);
  end;
  coPA := NewPA;
  coSizeOfPA := NewSize;
  coMaxItemsInPA := NewNumElements;
end;
{--------}
procedure TEZCollection.ValidateIndex(Index : longint);
begin
  if (Index < 0) or (Index >= Count) then
    RaiseCollError(coIndexError);
end;
{====================================================================}


{===TEZCollection item access========================================}
function TEZCollection.At(Index : longint) : pointer;
var
  PageNum : integer;
  InxInPage : integer;
begin
  ValidateIndex(Index);
  PageNum := GetPageGivenIndex(Index, InxInPage);
  Result := coPA^[PageNum].piItems^[InxInPage];
end;
{--------}
procedure TEZCollection.AtPut(Index : longint; Item : pointer);
var
  PageNum : integer;
  InxInPage : integer;
begin
  ValidateIndex(Index);
  PageNum := GetPageGivenIndex(Index, InxInPage);
  coPA^[PageNum].piItems^[InxInPage] := Item;
end;
{====================================================================}


{===TEZCollection property access====================================}
function TEZCollection.GetLimit : longint;
begin
  Result := longint(coMaxItemsInPA) * ezcPageElementCount;
end;
{====================================================================}


{===TEZCollection methods============================================}
procedure TEZCollection.Assign(Source : TPersistent);
var
  Src     : TEZCollection absolute Source;
  NewData : pointer;
  i       : longint;
begin
  if not (Source is TEZCollection) then
    Exit;
  Empty;
  acIsDataOwner := Src.IsDataOwner;
  Compare := Src.Compare;
  DupData := Src.DupData;
  DisposeData := Src.DisposeData;
  if not Src.IsEmpty then begin
    for i := 0 to pred(Src.Count) do begin
      if IsDataOwner then
        NewData := DupData(Src.Items[i])
      else
        NewData := Src.Items[i];
      try
        Insert(NewData);
      except
        if IsDataOwner then
          DisposeData(NewData);
      end;{try..except}
    end;
  end;
end;
{--------}
procedure TEZCollection.AtDelete(Index : longint);
var
  PageNum : integer;
  InxInPage : integer;
begin
  ValidateIndex(Index);
  PageNum := GetPageGivenIndex(Index, InxInPage);
  dec(acCount);
  with coPA^[PageNum] do begin
    dec(piUsedItems);
    if (piUsedItems = 0) then begin
      if (coItemsInPA > 1) then
        DeletePageItem(PageNum);
    end
    else if (InxInPage < piUsedItems) then
      Move(piItems^[succ(InxInPage)], piItems^[InxInPage],
           (piUsedItems - InxInPage) * sizeof(pointer));
  end;
  coCacheIndex := 0;
  coCachePageNum := 0;
  coCacheInxInPage := 0;
end;
{--------}
procedure TEZCollection.AtFree(Index : longint);
begin
  if IsDataOwner then
    DisposeData(Items[Index]);
  AtDelete(Index);
end;
{--------}
procedure TEZCollection.AtInsert(Index : longint; Item : pointer);
const
  HalfPageCount = ezcPageElementCount div 2;
var
  PageNum : integer;
  InxInPage : integer;
  AddingAtEnd : boolean;
begin
  {maximum count check}
  if (Count = ezcMaxCount) then
    RaiseCollError(coOverflow);
  {take care of special case-adding at end}
  if (Index = Count) then begin
    AddingAtEnd := true;
    PageNum := pred(coItemsInPA);
    InxInPage := coPA^[PageNum].piUsedItems;
  end
  {otherwise work out where to add it}
  else begin
    ValidateIndex(Index);
    AddingAtEnd := false;
    PageNum := GetPageGivenIndex(Index, InxInPage);
  end;

  {do we need a new page?}
  if (coPA^[PageNum].piUsedItems = ezcPageElementCount) then begin
    {add a new page after ours}
    AddPageItem(succ(PageNum));
    {if we are adding to the end, patch up the page number and index}
    if AddingAtEnd then begin
      PageNum := succ(PageNum);
      InxInPage := 0;
    end
    {if we were not adding at end, split the old page in two for efficiency}
    else begin
      Move(coPA^[PageNum].piItems^[HalfPageCount],
           coPA^[succ(PageNum)].piItems^[0],
           HalfPageCount * sizeof(pointer));
      coPA^[PageNum].piUsedItems := HalfPageCount;
      coPA^[succ(PageNum)].piUsedItems := HalfPageCount;
      if (InxInPage >= HalfPageCount) then begin
        dec(InxInPage, HalfPageCount);
        inc(PageNum);
      end;
    end;
  end;

  {insert the item now}
  with coPA^[PageNum] do begin
    if (InxInPage < piUsedItems) then
      Move(piItems^[InxInPage], piItems^[succ(InxInPage)],
           (piUsedItems - InxInPage) * sizeof(pointer));
    piItems^[InxInPage] := Item;
    inc(piUsedItems);
  end;
  inc(acCount);
  coCacheIndex := Index;
  coCachePageNum := PageNum;
  coCacheInxInPage := InxInPage;
end;
{--------}
procedure TEZCollection.Delete(Item : pointer);
var
  Index : longint;
begin
  Index := IndexOf(Item);
  if (Index <> -1) then
    AtDelete(Index);
end;
{--------}
procedure TEZCollection.DeleteAll;
var
  i : integer;
begin
  for i := pred(coItemsInPA) downto 1 do
    DeletePageItem(i);
  coPA^[0].piUsedItems := 0;
  acCount := 0;
  coCacheIndex := 0;
  coCachePageNum := 0;
  coCacheInxInPage := 0;
end;
{--------}
procedure TEZCollection.Empty;
begin
  FreeAll;
end;
{--------}
procedure TEZCollection.Free(Item : pointer);
var
  Index : longint;
begin
  Index := IndexOf(Item);
  if (Index <> -1) then
    AtFree(Index);
end;
{--------}
procedure TEZCollection.FreeAll;
var
  PageNum : integer;
  Inx     : integer;
begin
  if IsDataOwner then
    for PageNum := 0 to pred(coItemsInPA) do
      for Inx := 0 to pred(coPA^[PageNum].piUsedItems) do
        DisposeData(coPA^[PageNum].piItems^[Inx]);
  DeleteAll;
end;
{--------}
function TEZCollection.IndexOf(Item : pointer) : longint;
var
  PageNum : integer;
  Inx     : integer;
begin
  Result := -1;
  for PageNum := 0 to pred(coItemsInPA) do begin
    with coPA^[PageNum] do begin
      for Inx := 0 to pred(piUsedItems) do begin
        inc(Result);
        if (piItems^[Inx] = Item) then begin
          coCacheIndex := Result;
          coCachePageNum := PageNum;
          coCacheInxInPage := Inx;
          Exit;
        end;
      end;
    end;
  end;
  Result := -1;
end;
{--------}
procedure TEZCollection.Insert(Item : pointer);
begin
  AtInsert(Count, Item);
end;
{--------}
function TEZCollection.Iterate(Action    : TIterator;
                                Backwards : boolean;
                                ExtraData : pointer) : pointer;
var
  PageNum : integer;
  Inx     : integer;
begin
  if Backwards then begin
    for PageNum := pred(coItemsInPA) downto 0 do begin
      with coPA^[PageNum] do begin
        for Inx := pred(piUsedItems) downto 0 do begin
          if not Action(Self, piItems^[Inx], ExtraData) then begin
            Result := piItems^[Inx];
            Exit;
          end;
        end;
      end;
    end;
  end
  else begin
    for PageNum := 0 to pred(coItemsInPA) do begin
      with coPA^[PageNum] do begin
        for Inx := 0 to pred(piUsedItems) do begin
          if not Action(Self, piItems^[Inx], ExtraData) then begin
            Result := piItems^[Inx];
            Exit;
          end;
        end;
      end;
    end;
  end;
  Result := nil;
end;
{--------}
procedure TEZCollection.Pack;
var
  FromPage         : integer;
  ToPage           : integer;
  ItemsToGo        : integer;
  ItemsInToPage    : integer;
  ItemsInFromPage  : integer;
  StillPacking : boolean;
begin
  if (coItemsInPA = 1) then Exit;
  ToPage := -1;
  FromPage := 1;
  StillPacking := true;
  while StillPacking do begin
    inc(ToPage);
    ItemsInToPage := coPA^[ToPage].piUsedItems;
    ItemsToGo := ezcPageElementCount - ItemsInToPage;
    if (FromPage <= ToPage) then begin
      FromPage := succ(ToPage);
      if (FromPage = coItemsInPA) then
        StillPacking := false;
    end;
    while StillPacking and (ItemsToGo > 0) do begin
      ItemsInFromPage := coPA^[FromPage].piUsedItems;
      if (ItemsInFromPage <= ItemsToGo) then begin
        Move(coPA^[FromPage].piItems^[0], coPA^[ToPage].piItems^[ItemsInToPage],
             ItemsInFromPage * sizeof(pointer));
        inc(ItemsInToPage, ItemsInFromPage);
        coPA^[ToPage].piUsedItems := ItemsInToPage;
        dec(ItemsToGo, ItemsInFromPage);
        coPA^[FromPage].piUsedItems := 0;
        inc(FromPage);
        if (FromPage = coItemsInPA) then
          StillPacking := false;
      end
      else begin
        Move(coPA^[FromPage].piItems^[0], coPA^[ToPage].piItems^[ItemsInToPage],
             (ItemsToGo * sizeof(pointer)));
        coPA^[ToPage].piUsedItems := ezcPageElementCount;
        Move(coPA^[FromPage].piItems^[ItemsToGo], coPA^[FromPage].piItems^[0],
             (ItemsInFromPage - ItemsToGo) * sizeof(pointer));
        coPA^[FromPage].piUsedItems := ItemsInFromPage - ItemsToGo;
        ItemsToGo := 0;
      end;
    end;
  end;
  if (ToPage < pred(coItemsInPA)) then begin
    for FromPage := pred(coItemsInPA) downto succ(ToPage) do
      DeletePageItem(FromPage);
    GrowPageArray(coItemsInPA);
  end;
  coCacheIndex := 0;
  coCachePageNum := 0;
  coCacheInxInPage := 0;
end;
{====================================================================}


{====================================================================}
constructor TEZSortedCollection.Create(DataOwner : boolean);
begin
  inherited Create(DataOwner);
  acIsSorted := true;
end;
{--------}
function TEZSortedCollection.IndexOf(Item : pointer) : longint;
var
  Index : longint;
begin
  if Search(Item, Index) then
    Result := Index
  else
    Result := -1;
end;
{--------}
procedure TEZSortedCollection.Insert(Item : pointer);
var
  Index : longint;
begin
  if not Search(Item, Index) then
    AtInsert(Index, Item)
  else
    RaiseError(escInsertDup);
end;
{--------}
function TEZSortedCollection.Search(Item : pointer; var Index : longint) : boolean;
var
  L, R, M   : longint;
  PageNum   : integer;
  InxInPage : integer;
  CompResult : integer;
begin
  {check the obvious case}
  if (Count = 0) then begin
    Result := false;
    Index := 0;
    Exit;
  end;
  {standard binary search: Algorithms by Sedgewick}
  L := 0;
  R := pred(Count);
  repeat
    M := (L + R) div 2;
    PageNum := GetPageGivenIndex(M, InxInPage);
    CompResult := Compare(Item, coPA^[PageNum].piItems^[InxInPage]);
    if (CompResult = 0) then begin
      Result := true;
      Index := M;
      Exit;
    end
    else if (CompResult < 0) then
      R := M - 1
    else
      L := M + 1;
  until (L > R);
  Result := false;
  if (CompResult > 0) then
    Index := M + 1
  else
    Index := M;
end;
{====================================================================}

{===TEZStringCollection==============================================}
constructor TEZStringCollection.Create(DataOwner : boolean);
begin
  inherited Create(DataOwner);
  Compare := EZStrCompare;
  DupData := EZStrDupData;
  DisposeData := EZStrDisposeData;
end;
{====================================================================}


{===TEZStrZCollection================================================}
constructor TEZStrZCollection.Create(DataOwner : boolean);
begin
  inherited Create(DataOwner);
  Compare := EZStrZCompare;
  DupData := EZStrZDupData;
  DisposeData := EZStrZDisposeData;
end;
{====================================================================}

end.
