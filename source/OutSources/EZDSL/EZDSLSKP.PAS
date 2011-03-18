{===EZDSLSKP==========================================================

Part of the Delphi Structures Library--the skip list.

EZDSLSKP is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
13Mar96 JMB 2.00 release for Delphi 2.0
12Nov95 JMB 1.01 fixed Iterate bug
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLSkp;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here----------------------}


{--------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

uses
  SysUtils,
  WinTypes,
  WinProcs,
  Classes,
  {$IFDEF Win32}
  EZDSLThd,
  {$ENDIF}
  EZDSLCts,
  EZDSLBse,
  EZDSLSup,
  EZDSLRnd;

type
  TSkipList = class(TAbstractContainer)
    {-Skip linked list object}
    private
      skBF, skAL  : PNode;
      skCurLevels : integer;
      skRandGen   : TEZRandomGenerator;
      skNewNodeLevel : integer;

    protected
      procedure acDisposeNode(aNode : PNode); override;
      function acNewNode(aData : pointer) : PNode; override;

      procedure acSort; override;

      function skCloneItem(SL : TAbstractContainer;
                           aData : pointer;
                           NSL : pointer) : boolean;
      function skMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
                            aBeforeNode2 : PNode; aCount2 : longint) : PNode;
      function skMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;

    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;
      destructor Destroy; override;

      function Delete(Cursor : TListCursor) : TListCursor;
      procedure Empty; override;
      function Erase(Cursor : TListCursor) : TListCursor;
      function Examine(Cursor : TListCursor) : pointer;
      procedure Insert(var Cursor : TListCursor; aData : pointer);
      function IsAfterLast(Cursor : TListCursor) : boolean;
      function IsBeforeFirst(Cursor : TListCursor) : boolean;
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : pointer;
      procedure Join(List : TSkipList);
      function Next(Cursor : TListCursor) : TListCursor;
      function Prev(Cursor : TListCursor) : TListCursor;
      function Replace(Cursor : TListCursor; aData : pointer) : pointer;
      function Search(var Cursor : TListCursor; aData : pointer) : boolean;
      function SetBeforeFirst : TListCursor;
      function SetAfterLast : TListCursor;
      function Split(Cursor : TListCursor) : TSkipList;
  end;

{$IFDEF Win32}
type
  TThreadsafeSkipList = class
    protected {private}
      slSkipList : TSkipList;
      slResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TSkipList;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{-An iterator for cloning a skip list}
function SkipListCloneItem(SL : TAbstractContainer;
                           aData : pointer;
                           NSL : pointer) : boolean; far;
var
  NewList : TSkipList absolute NSL;
  NewData : pointer;
  Dummy   : TListCursor;
begin
  Result := true;
  with NewList do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      Insert(Dummy, NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;

{=TSkipList===========================================================
A skip linked list

This is a special type of linked list of data objects. Compared with
TList and TDList, this implementation uses nodes of varying sizes. The
nodes have between 1 and 16 (skMaxLevels) of forward pointers, the
higher ones skipping over nodes with less forward pointers. This means
much faster search times, but slightly slower list update times (ie
insert and delete). Can cope with searching long lists without too
much degradation. Compared with a red-black binary search tree, this
type of data structure will consume more memory, will have faster
insert times, slower (?) delete times, and will have comparable
(amortised) search times.

Reference
  Scheiner: Skip Lists (DDJ January 1994)
=====================================================================}
constructor TSkipList.Create(DataOwner : boolean);
var
  Level : integer;
begin
  {Note: we cannot use a NodeStore as the nodes have different
         sizes, so set NodeSize to 0.}
  acNodeSize := 0;
  inherited Create(DataOwner);
  skRandGen := TEZRandomGenerator.Create;
  skRandGen.SetSeed(0);
  skNewNodeLevel := skMaxLevels;
  skBF := acNewNode(nil);
  acCount := 0;
  skNewNodeLevel := 1;
  skAL := acNewNode(nil);
  acCount := 0;
  for Level := 0 to pred(skMaxLevels) do
    skBF^.FwLink[Level] := skAL;
  skBF^.BkLink:= skBF;
  skAL^.FwLink[0] := skAL;
  skAL^.BkLink:= skBF;
  skCurLevels := 1;
  acIsSorted := true; {and this cannot be changed}
end;
{--------}
constructor TSkipList.Clone(Source : TAbstractContainer;
                            DataOwner : boolean;
                            NewCompare : TCompareFunc);
var
  OldList : TSkipList absolute Source;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldList.DupData;
  DisposeData := OldList.DisposeData;

  if not (Source is TSkipList) then
    RaiseError(escBadSource);

  if not OldList.IsEmpty then
    OldList.Iterate(SkipListCloneItem, false, Self);
end;
{--------}
destructor TSkipList.Destroy;
begin
  skRandGen.Free;
  inherited Destroy;
end;
{--------}
procedure TSkipList.acDisposeNode(aNode : PNode);
begin
  {$IFDEF DEBUG}
  EZAssert(Assigned(aNode), ascFreeNilNode);
  {$ENDIF}
  SafeFreeMem(aNode, aNode^.Size);
  if (acCount > 0) then
    dec(acCount);
end;
{--------}
function TSkipList.acNewNode(aData : pointer) : PNode;
var
  NodeBytes : integer;
begin
  {Note: we must override the default node allocation as the nodes
         vary in size. The object variable skNewNodeLevel is the
         number of forward links we must reserve.}
  {$IFDEF DEBUG}
  EZAssert((0 < skNewNodeLevel) and (skNewNodeLevel <= skMaxLevels), ascBadSkipLevel);
  {$ENDIF}
  {Note: the formula below translates to this table of node sizes
     SkipLevel:  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
    NodeSize16: 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76
    NodeSize32: 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 }
  NodeBytes := ((skNewNodeLevel+2) * sizeof(pointer)) + (sizeof(integer) * 2);
  SafeGetMem(Result, NodeBytes);
  with Result^ do begin
    Data := aData;
    Size := NodeBytes;
    Lvls := skNewNodeLevel;
  end;
  inc(acCount);
end;
{--------}
procedure TSkipList.acSort;
var
  i : integer;
  Dad, Son : PNode;
  PrevNodeAtLevel : array [0..pred(skMaxLevels)] of PNode;
begin
  {mergesort the linked list as a singly linked list}
  skMergeSort(skBF, Count);
  {now patch up the remaining forward links (ie, everything but
   forward link 0) and the back links}
  for i := 0 to pred(skMaxLevels) do
    PrevNodeAtLevel[i] := skBF;
  Son := skBF;
  while (Son <> skAL) do begin
    Dad := Son;
    Son := Dad^.FwLink[0];
    Son^.BkLink := Dad;
    for i := pred(Son^.Lvls) downto 1 do begin
      PrevNodeAtLevel[i]^.FwLink[i] := Son;
      PrevNodeAtLevel[i] := Son;
    end;
  end;
  {now tie up any loose ends by pointing the remaining forward links
   to the AfterLast node}
  for i := pred(skMaxLevels) downto 1 do
    PrevNodeAtLevel[i]^.FwLink[i] := skAL;
end;
{--------}
function TSkipList.Delete(Cursor : TListCursor) : TListCursor;
var
  aData     : pointer;
  Walker    : PNode;
  NextStep  : TListCursor;
  TempNode  : PNode;
  Level     : integer;
  CompResult: integer;
  PrevLink  : array [0..pred(skMaxLevels)] of PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascDeleteEdges);
  {$ENDIF}
  aData := Examine(Cursor);
  Walker := PNode(SetBeforeFirst);
  {note: the following for loop is executed at least once
         because skCurLevels >= 1}
  for Level := pred(skCurLevels) downto 0 do begin
    NextStep := TListCursor(Walker^.FwLink[Level]);
    if IsAfterLast(NextStep) then
      CompResult := -1
    else
      CompResult := Compare(aData, Examine(NextStep));
    while (CompResult > 0) do begin
      Walker := PNode(NextStep);
      NextStep := TListCursor(Walker^.FwLink[Level]);
      if IsAfterLast(NextStep) then
        CompResult := -1
      else
        CompResult := Compare(aData, Examine(NextStep));
    end;
    PrevLink[Level] := Walker;
  end;
  with PNode(Cursor)^ do begin
    TempNode := FwLink[0];
    TempNode^.BkLink := BkLink;
    PrevLink[0]^.FwLink[0] := FwLink[0];
    for Level := 1 to pred(Lvls) do
      PrevLink[Level]^.FwLink[Level] := FwLink[Level];
  end;
  acDisposeNode(PNode(Cursor));
  Result := TListCursor(TempNode);
end;
{--------}
procedure TSkipList.Empty;
var
  Temp,
  Cursor : TListCursor;
  Level  : integer;
begin
  {Note: it will be faster to delete nodes from first principles
         rather than repeatedly call the Erase method.}
  if not IsEmpty then begin
    Cursor := Next(SetBeforeFirst);
    while not IsAfterLast(Cursor) do begin
      Temp := Cursor;
      Cursor := Next(Cursor);
      if IsDataOwner then
        DisposeData(Examine(Temp));
      acDisposeNode(PNode(Temp));
    end;
  end;
  if acInDone then begin
    if Assigned(skBF) then
      acDisposeNode(skBF);
    if Assigned(skAL) then
      acDisposeNode(skAL);
  end
  else begin
    {patch everything up again}
    for Level := 0 to pred(skMaxLevels) do
      skBF^.FwLink[Level] := skAL;
    skAL^.BkLink:= skBF;
    skCurLevels := 1;
    acCount := 0;
  end;
end;
{--------}
function TSkipList.Erase(Cursor : TListCursor) : TListCursor;
var
  Data : pointer;
begin
  {Note: Delete requires the Data field so dispose the data
         afterwards}
  Data := Examine(Cursor);
  Result := Delete(Cursor);
  if IsDataOwner then
    DisposeData(Data);
end;
{--------}
function TSkipList.Examine(Cursor : TListCursor) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascExamineEdges);
  {$ENDIF}
  Result := PNode(Cursor)^.Data;
end;
{--------}
procedure TSkipList.Insert(var Cursor : TListCursor; aData : pointer);
var
  Walker    : PNode;
  NextStep  : TListCursor;
  TempNode  : PNode;
  Level     : integer;
  CompResult: integer;
  PrevLink  : array [0..pred(skMaxLevels)] of PNode;
begin
  {$IFDEF SuppressWarnings}
  CompResult := 0;
  {$ENDIF}
  Walker := PNode(SetBeforeFirst);
  {note: the following for loop is executed at least once
         because skCurLevels >= 1}
  for Level := pred(skCurLevels) downto 0 do begin
    NextStep := TListCursor(Walker^.FwLink[Level]);
    if IsAfterLast(NextStep) then
      CompResult := -1
    else
      CompResult := Compare(aData, Examine(NextStep));
    while (CompResult > 0) do begin
      Walker := PNode(NextStep);
      NextStep := TListCursor(Walker^.FwLink[Level]);
      if IsAfterLast(NextStep) then
        CompResult := -1
      else
        CompResult := Compare(aData, Examine(NextStep));
    end;
    PrevLink[Level] := Walker;
  end;
  {Note: Delphi 2/3 warns that CompResult might not have been
         initialized. Wrong, the above loop is performed at least
         once}
  if (CompResult = 0) then
    RaiseError(escInsertDup);
  Level := 1;
  while (Level < skMaxLevels) and (skRandGen.RandomByte < 64) do
    inc(Level);
  if (Level > skCurLevels) then begin
    PrevLink[skCurLevels] := skBF;
    inc(skCurLevels);
    Level := skCurLevels;
  end;
  skNewNodeLevel := Level;
  TempNode := acNewNode(aData);
  for Level := pred(skNewNodeLevel) downto 0 do
    with PrevLink[Level]^ do begin
      TempNode^.FwLink[Level] := FwLink[Level];
      FwLink[Level] := TempNode;
    end;
  with TempNode^.FwLink[0]^ do begin
    TempNode^.BkLink := BkLink;
    BkLink := TempNode;
  end;
  Cursor := TListCursor(TempNode);
end;
{--------}
function TSkipList.IsAfterLast(Cursor : TListCursor) : boolean;
begin
  Result := (PNode(Cursor) = skAL);
end;
{--------}
function TSkipList.IsBeforeFirst(Cursor : TListCursor) : boolean;
begin
  Result := (PNode(Cursor) = skBF);
end;
{--------}
function TSkipList.Iterate(Action : TIterator; Backwards : boolean;
                            ExtraData : pointer) : pointer;
var
  Walker : TListCursor;
begin
  if Backwards then begin
    Walker := Prev(SetAfterLast);
    while not IsBeforeFirst(Walker) do begin
      if Action(Self, Examine(Walker), ExtraData) then
        Walker := Prev(Walker)
      else begin
        Result := Examine(Walker);
        Exit;
      end;
    end;
  end
  else {not Backwards} begin
    Walker := Next(SetBeforeFirst);
    while not IsAfterLast(Walker) do begin
      if Action(Self, Examine(Walker), ExtraData) then
        Walker := Next(Walker)
      else begin
        Result := Examine(Walker);
        Exit;
      end;
    end;
  end;
  Result := nil;
end;
{--------}
procedure TSkipList.Join(List : TSkipList);
var
  Dummy,
  Walker : TListCursor;
  Data   : pointer;
begin
  if not Assigned(List) then Exit;

  {$IFDEF DEBUG}
  EZAssert(List.IsDataOwner = IsDataOwner, ascCannotJoinData);
  {$ENDIF}

  if not List.IsEmpty then begin
    Walker := List.Next(List.SetBeforeFirst);
    while not List.IsAfterLast(Walker) do begin
      Data := List.Examine(Walker);
      Walker := List.Delete(Walker);
      Insert(Dummy, Data);
    end;
  end;
  List.Free;
end;
{--------}
function TSkipList.Next(Cursor : TListCursor) : TListCursor;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsAfterLast(Cursor), ascAlreadyAtEnd);
  {$ENDIF}
  Result := TListCursor(PNode(Cursor)^.FwLink[0]);
end;
{--------}
function TSkipList.Prev(Cursor : TListCursor) : TListCursor;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsBeforeFirst(Cursor), ascAlreadyAtStart);
  {$ENDIF}
  Result := TLIstCursor(PNode(Cursor)^.BkLink);
end;
{--------}
function TSkipList.Replace(Cursor : TListCursor; aData : pointer) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascReplaceEdges);
  {$ENDIF}
  Result := Examine(Cursor);
  Cursor := Delete(Cursor);
  Insert(Cursor, aData);
end;
{--------}
function TSkipList.Search(var Cursor : TListCursor; aData : pointer) : boolean;
var
  Walker    : PNode;
  NextStep  : TListCursor;
  Level     : integer;
  CompResult: integer;
begin
  {$IFDEF SuppressWarnings}
  NextStep := 0;
  CompResult := 0;
  {$ENDIF}
  Walker := PNode(SetBeforeFirst);
  {note: the following for loop is executed at least once
         because skCurLevels >= 1}
  for Level := pred(skCurLevels) downto 0 do begin
    NextStep := TListCursor(Walker^.FwLink[Level]);
    if IsAfterLast(NextStep) then
      CompResult := -1
    else
      CompResult := Compare(aData, Examine(NextStep));
    while (CompResult > 0) do begin
      Walker := PNode(NextStep);
      NextStep := TListCursor(Walker^.FwLink[Level]);
      if IsAfterLast(NextStep) then
        CompResult := -1
      else
        CompResult := Compare(aData, Examine(NextStep));
    end;
  end;
  {Note: Delphi 2/3 warns that NextStep and CompResult might not have
         been initialized. Wrong, the above loop is performed at least
         once}
  Cursor := NextStep;
  Result := (CompResult = 0);
end;
{--------}
function TSkipList.SetBeforeFirst : TListCursor;
begin
  Result := TListCursor(skBF);
end;
{--------}
function TSkipList.SetAfterLast : TListCursor;
begin
  Result := TListCursor(skAL);
end;
{--------}
function TSkipList.skCloneItem(SL : TAbstractContainer;
                               aData : pointer;
                               NSL : pointer) : boolean;
var
  NewList : TSkipList absolute NSL;
  NewData : pointer;
  Dummy   : TListCursor;
begin
  Result := true;
  with NewList do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      Insert(Dummy, NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;
{--------}
function TSkipList.skMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
                                aBeforeNode2 : PNode; aCount2 : longint) : PNode;
var
  Last  : PNode;
  Temp  : PNode;
  Node1 : PNode;
  Node2 : PNode;
  Inx1  : longint;
  Inx2  : longint;
begin
  {Note: the way this routine is called means that the two sublists to
         be merged look like this
           BeforeNode1 -> SubList1 -> SubList2 -> rest of list
         In particular the last node of sublist2 points to the rest of
         the (unsorted) linked list.}
  {prepare for main loop}
  Last := aBeforeNode1;
  Inx1 := 0;
  Inx2 := 0;
  Node1 := aBeforeNode1^.FwLink[0];
  Node2 := aBeforeNode2^.FwLink[0];
  {picking off nodes one by one from each sublist, attach them in
   sorted order onto the link of the Last node, until we run out of
   nodes from one of the sublists}
  while (Inx1 < aCount1) and (Inx2 < aCount2) do begin
    if (Compare(Node1^.Data, Node2^.Data) <= 0) then begin
      Temp := Node1;
      Node1 := Node1^.FwLink[0];
      inc(Inx1);
    end
    else {Node1 > Node2} begin
      Temp := Node2;
      Node2 := Node2^.FwLink[0];
      inc(Inx2);
    end;
    Last^.FwLink[0] := Temp;
    Last := Temp;
  end;
  {if there are nodes left in the first sublist, merge them}
  if (Inx1 < aCount1) then begin
    while (Inx1 < aCount1) do begin
      Last^.FwLink[0] := Node1;
      Last := Node1;
      Node1 := Node1^.FwLink[0];
      inc(Inx1);
    end;
  end
  {otherwise there must be nodes left in the second sublist, so merge
   them}
  else begin
    while (Inx2 < aCount2) do begin
      Last^.FwLink[0] := Node2;
      Last := Node2;
      Node2 := Node2^.FwLink[0];
      inc(Inx2);
    end;
  end;
  {patch up link to rest of list}
  Last^.FwLink[0] := Node2;
  {return the last node}
  Result := Last;
end;
{--------}
function TSkipList.skMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;
var
  Count2   : longint;
  LastNode1: PNode;
  {$IFDEF Windows}
  DummyNode: PNode;
  {$ENDIF}
begin
  {recursion terminator: if there's only one thing to sort we're
   already sorted <g>}
  if (aCount <= 1) then begin
    Result := aBeforeNode^.FwLink[0];
    Exit;
  end;
  {split the current sublist into 2 'equal' halves}
  Count2 := aCount shr 1;
  aCount := aCount - Count2;
  {mergesort the first half, save last node of sorted sublist}
  LastNode1 := skMergeSort(aBeforeNode, aCount);
  {mergesort the second half, discard last node of sorted sublist}
  {$IFDEF Windows}
  DummyNode :=
  {$ENDIF}
  skMergeSort(LastNode1, Count2);
  {merge the two sublists, and return the last sorted node}
  Result := skMergeLists(aBeforeNode, aCount, LastNode1, Count2);
end;
{--------}
function TSkipList.Split(Cursor : TListCursor) : TSkipList;
var
  NewList   : TSkipList;
  Dummy     : TListCursor;
  Data      : pointer;
begin                                                       
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascSplitEdges);
  {$ENDIF}
  NewList := TSkipList(TAbstractContainerClass(ClassType).Create(IsDataOwner));
  NewList.Compare := Compare;
  NewList.DupData := DupData;
  NewList.DisposeData := DisposeData;
  Result := NewList;

  while not IsAfterLast(Cursor) do begin
    Data := Examine(Cursor);
    Cursor := Delete(Cursor);
    NewList.Insert(Dummy, Data);
  end;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeSkipList==============================================}
constructor TThreadsafeSkipList.Create(aDataOwner : boolean);
begin
  inherited Create;
  slResLock := TezResourceLock.Create;
  slSkipList := TSkipList.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeSkipList.Destroy;
begin
  slSkipList.Free;
  slResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeSkipList.AcquireAccess : TSkipList;
begin
  slResLock.Lock;
  Result := slSkipList;
end;
{--------}
procedure TThreadsafeSkipList.ReleaseAccess;
begin
  slResLock.Unlock;
end;
{====================================================================}
{$ENDIF}

end.

