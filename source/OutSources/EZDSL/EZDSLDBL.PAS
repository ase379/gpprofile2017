{===EZDSLDBL==========================================================

Part of the Delphi Structures Library--the double linked list.

EZDSLDBL is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 improvements to Clone
13Mar96 JMB 2.00 release for Delphi 2.0
12Nov95 JMB 1.01 fixed Iterate bug
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLDbl;

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
  EZDSLSup,
  EZDSLBse;

type

  TDList = class(TAbstractContainer)
    {-Double linked list object}
    private
      dlBF, dlAL    : PNode;
    protected
      procedure acSort; override;

      procedure dlInsertBeforePrim(Cursor : TListCursor; aData : pointer);
      function dlMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
                            aBeforeNode2 : PNode; aCount2 : longint) : PNode;
      function dlMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;
    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      function Delete(Cursor : TListCursor) : TListCursor;
      procedure Empty; override;
      function Erase(Cursor : TListCursor) : TListCursor;
      function Examine(Cursor : TListCursor) : pointer;
      procedure InsertAfter(Cursor : TListCursor; aData : pointer);
      procedure InsertBefore(Cursor : TListCursor; aData : pointer);
      procedure InsertSorted(aData : pointer);
      function IsAfterLast(Cursor : TListCursor) : boolean;
      function IsBeforeFirst(Cursor : TListCursor) : boolean;
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : pointer;
      procedure Join(Cursor : TListCursor; List : TDList);
      function Next(Cursor : TListCursor) : TListCursor;
      function Prev(Cursor : TListCursor) : TListCursor;
      function Replace(Cursor : TListCursor; aData : pointer) : pointer;
      function Search(var Cursor : TListCursor; aData : pointer) : boolean;
      function SetBeforeFirst : TListCursor;
      function SetAfterLast : TListCursor;
      function Split(Cursor : TListCursor) : TDList;
  end;

{$IFDEF Win32}
type
  TThreadsafeDList = class
    protected {private}
      dlDList    : TDList;
      dlResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TDList;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{-An iterator for cloning a double linked list}
function DListCloneItem(SL : TAbstractContainer;
                        aData : pointer;
                        NSL : pointer) : boolean; far;
var
  NewList : TDList absolute NSL;
  NewData : pointer;
begin
  Result := true;
  with NewList do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      InsertBefore(SetAfterLast, NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;

{-An iterator for cloning a SORTED double linked list}
function DListSortedCloneItem(SL : TAbstractContainer;
                              aData : pointer;
                              NSL : pointer) : boolean; far;
var
  NewList : TDList absolute NSL;
  NewData : pointer;
begin
  Result := true;
  with NewList do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      InsertSorted(NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;

{===TDList===========================================================}
constructor TDList.Create(DataOwner : boolean);
begin
  acNodeSize := 12;
  inherited Create(DataOwner);
  dlBF := acNewNode(nil);
  acCount := 0;
  dlAL := acNewNode(nil);
  acCount := 0;
  dlBF^.FLink := dlAL;
  dlBF^.BLink:= dlBF;
  dlAL^.FLink := dlAL;
  dlAL^.BLink:= dlBF;
  acCanChangeSorted := true;
end;
{--------}
constructor TDList.Clone(Source : TAbstractContainer;
                         DataOwner : boolean;
                         NewCompare : TCompareFunc);
var
  OldList : TDList absolute Source;
begin
  Create(DataOwner);
  if Assigned(NewCompare) then
    Compare := NewCompare
  else
    Compare := OldList.Compare;
  DupData := OldList.DupData;
  DisposeData := OldList.DisposeData;
  IsSorted := OldList.IsSorted;

  if not (Source is TDList) then
    RaiseError(escBadSource);

  if OldList.IsEmpty then Exit;

  if IsSorted then
    OldList.Iterate(DListSortedCloneItem, false, Self)
  else
    OldList.Iterate(DListCloneItem, false, Self);
end;
{--------}
procedure TDList.acSort;
var
  Dad, Son : PNode;
begin
  if IsSorted then begin
    {mergesort the linked list as a singly linked list}
    dlMergeSort(dlBF, Count);
    {now patch up the back links}
    Son := dlBF;
    while (Son <> dlAL) do begin
      Dad := Son;
      Son := Dad^.FLink;
      Son^.BLink := Dad;
    end;
  end;
end;
{--------}
function TDList.Delete(Cursor : TListCursor) : TListCursor;
var
  Temp : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascDeleteEdges);
  {$ENDIF}
  Temp := PNode(Cursor);
  Cursor := Next(Cursor);
  Temp^.BLink^.FLink := PNode(Cursor);
  PNode(Cursor)^.BLink := Temp^.BLink;
  acDisposeNode(Temp);
  Result := Cursor;
end;
{--------}
procedure TDList.dlInsertBeforePrim(Cursor : TListCursor; aData : pointer);
var
  Node : PNode;
begin
  Node := acNewNode(aData);
  Node^.FLink := PNode(Cursor);
  Node^.BLink:= PNode(Cursor)^.BLink;
  PNode(Cursor)^.BLink := Node;
  Node^.BLink^.FLink := Node;
end;
{--------}
function TDList.dlMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
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
  Node1 := aBeforeNode1^.FLink;
  Node2 := aBeforeNode2^.FLink;
  {picking off nodes one by one from each sublist, attach them in
   sorted order onto the link of the Last node, until we run out of
   nodes from one of the sublists}
  while (Inx1 < aCount1) and (Inx2 < aCount2) do begin
    if (Compare(Node1^.Data, Node2^.Data) <= 0) then begin
      Temp := Node1;
      Node1 := Node1^.FLink;
      inc(Inx1);
    end
    else {Node1 > Node2} begin
      Temp := Node2;
      Node2 := Node2^.FLink;
      inc(Inx2);
    end;
    Last^.FLink := Temp;
    Last := Temp;
  end;
  {if there are nodes left in the first sublist, merge them}
  if (Inx1 < aCount1) then begin
    while (Inx1 < aCount1) do begin
      Last^.FLink := Node1;
      Last := Node1;
      Node1 := Node1^.FLink;
      inc(Inx1);
    end;
  end
  {otherwise there must be nodes left in the second sublist, so merge
   them}
  else begin
    while (Inx2 < aCount2) do begin
      Last^.FLink := Node2;
      Last := Node2;
      Node2 := Node2^.FLink;
      inc(Inx2);
    end;
  end;
  {patch up link to rest of list}
  Last^.FLink := Node2;
  {return the last node}
  Result := Last;
end;
{--------}
function TDList.dlMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;
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
    Result := aBeforeNode^.FLink;
    Exit;
  end;
  {split the current sublist into 2 'equal' halves}
  Count2 := aCount shr 1;
  aCount := aCount - Count2;
  {mergesort the first half, save last node of sorted sublist}
  LastNode1 := dlMergeSort(aBeforeNode, aCount);
  {mergesort the second half, discard last node of sorted sublist}
  {$IFDEF Windows}
  DummyNode :=
  {$ENDIF}
  dlMergeSort(LastNode1, Count2);
  {merge the two sublists, and return the last sorted node}
  Result := dlMergeLists(aBeforeNode, aCount, LastNode1, Count2);
end;
{--------}
procedure TDList.Empty;
var
  Cursor : TListCursor;
begin
  if not IsEmpty then begin
    Cursor := Next(SetBeforeFirst);
    while not IsAfterLast(Cursor) do
      Cursor := Erase(Cursor);
  end;
  if acInDone then begin
    if Assigned(dlBF) then
      acDisposeNode(dlBF);
    if Assigned(dlAL) then
      acDisposeNode(dlAL);
  end;
end;
{--------}
function TDList.Erase(Cursor : TListCursor) : TListCursor;
begin
  if IsDataOwner then
    DisposeData(Examine(Cursor));
  Result := Delete(Cursor);
end;
{--------}
function TDList.Examine(Cursor : TListCursor) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascExamineEdges);
  {$ENDIF}
  Result := PNode(Cursor)^.Data;
end;
{--------}
procedure TDList.InsertAfter(Cursor : TListCursor; aData : pointer);
var
  Node : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsSorted, ascIsSortedList);
  EZAssert(not IsAfterLast(Cursor), ascInsertEdges);
  {$ENDIF}
  Node := acNewNode(aData);
  Node^.FLink := PNode(Cursor)^.FLink;
  Node^.BLink:= PNode(Cursor);
  PNode(Cursor)^.FLink := Node;
  Node^.FLink^.BLink := Node;
end;
{--------}
procedure TDList.InsertBefore(Cursor : TListCursor; aData : pointer);
begin
  {$IFDEF DEBUG}
  EZAssert(not IsSorted, ascIsSortedList);
  EZAssert(not IsBeforeFirst(Cursor), ascInsertEdges);
  {$ENDIF}
  dlInsertBeforePrim(Cursor, aData);
end;
{--------}
procedure TDList.InsertSorted(aData : pointer);
var
  Walker    : TListCursor;
begin
  {$IFDEF DEBUG}
  EZAssert(IsSorted, ascIsNotSortedList);
  {$ENDIF}
  if Search(Walker, aData) then
    RaiseError(escInsertDup);
  dlInsertBeforePrim(Walker, aData);
end;
{--------}
function TDList.IsAfterLast(Cursor : TListCursor) : boolean;
begin
  Result := (PNode(Cursor) = dlAL);
end;
{--------}
function TDList.IsBeforeFirst(Cursor : TListCursor) : boolean;
begin
  Result := (PNode(Cursor) = dlBF);
end;
{--------}
function TDList.Iterate(Action : TIterator; Backwards : boolean;
                         ExtraData : pointer) : pointer;
var
  Walker : TListCursor;
begin
  if Backwards then begin
    Walker := Prev(SetAfterLast);
    while not IsBeforeFirst(Walker) do
      if Action(Self, Examine(Walker), ExtraData) then
        Walker := Prev(Walker)
      else begin
        Result := Examine(Walker);
        Exit;
      end;
  end
  else {not Backwards} begin
    Walker := Next(SetBeforeFirst);
    while not IsAfterLast(Walker) do
      if Action(Self, Examine(Walker), ExtraData) then
        Walker := Next(Walker)
      else begin
        Result := Examine(Walker);
        Exit;
      end;
  end;
  Result := nil;
end;
{--------}
procedure TDList.Join(Cursor : TListCursor; List : TDList);
var
  Walker : TListCursor;
  Data   : pointer;
begin
  if not Assigned(List) then Exit;

  {$IFDEF DEBUG}
  EZAssert(not IsAfterLast(Cursor), ascCannotJoinHere);
  EZAssert(List.IsDataOwner = IsDataOwner, ascCannotJoinData);
  {$ENDIF}

  if not List.IsEmpty then begin
    {if we are sorted, add new nodes in sorted order}
    if {Self.}IsSorted then begin
      Walker := List.Next(List.SetBeforeFirst);
      while not List.IsAfterLast(Walker) do begin
        Data := List.Examine(Walker);
        Walker := List.Delete(Walker);
        InsertSorted(Data);
      end;
    end
    else begin
      List.dlAL^.BLink^.FLink := PNode(Cursor)^.FLink;
      PNode(Cursor)^.FLink^.BLink := List.dlAL^.BLink;
      PNode(Cursor)^.FLink := List.dlBF^.FLink;
      PNode(Cursor)^.FLink^.BLink := PNode(Cursor);
      inc(acCount, List.Count);
      {patch up List to be empty}
      with List do begin
        dlBF^.FLink := dlAL;
        dlAL^.BLink := dlBF;
        acCount := 0;
      end;
    end;
  end;
  List.Free;
end;
{--------}
function TDList.Next(Cursor : TListCursor) : TListCursor;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsAfterLast(Cursor), ascAlreadyAtEnd);
  {$ENDIF}
  Result := TListCursor(PNode(Cursor)^.FLink);
end;
{--------}
function TDList.Prev(Cursor : TListCursor) : TListCursor;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsBeforeFirst(Cursor), ascAlreadyAtStart);
  {$ENDIF}
  Result := TListCursor(PNode(Cursor)^.BLink);
end;
{--------}
function TDList.Replace(Cursor : TListCursor; aData : pointer) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascReplaceEdges);
  {$ENDIF}
  if IsSorted then begin
    Result := Examine(Cursor);
    Delete(Cursor);
    InsertSorted(aData);
  end
  else with PNode(Cursor)^ do begin
    Result := Data;
    Data := aData;
  end;
end;
{--------}
function TDList.Search(var Cursor : TListCursor; aData : pointer) : boolean;
var
  Walker       : TListCursor;
  CompResult   : integer;
  StillLooking : boolean;
  Found        : boolean;
  i            : longint;
  L, R, M      : longint;
  CursorNumber : longint;
  StartNumber  : longint;
  TempCursor   : PNode;
  StartCursor  : PNode;
begin
  Walker := SetBeforeFirst;
  if IsSorted then begin
    if (Count = 0) then begin
      Result := false;
      Cursor := SetAfterLast;
      Exit;
    end;
    L := 0;
    R := pred(Count);
    CursorNumber := -1;
    StartNumber := -1;
    StartCursor := dlBF;
    TempCursor := dlBF;
    while (L <= R) do begin
      M := (L + R) shr 1;
      if (CursorNumber <= M) then begin
        StartCursor := TempCursor;
        StartNumber := CursorNumber;
      end
      else {CursorNumber > M} begin
        TempCursor := StartCursor;
      end;
      for i := 1 to (M - StartNumber) do
        TempCursor := TempCursor^.FLink;
      CursorNumber := M;
      CompResult := Compare(aData, TempCursor^.Data);
      if (CompResult < 0) then
        R := pred(M)
      else if (CompResult > 0) then
        L := succ(M)
      else begin
        Result := true;
        Exit;
      end;
    end;
    Result := false;
    Cursor := TListCursor(TempCursor);
    if (L > CursorNumber) then
      Cursor := Next(Cursor)
    else if (L < CursorNumber) then
      Cursor := Prev(Cursor);
  end
  else {the list is not sorted} begin
    StillLooking := true;
    Found := false;
    while StillLooking and (not Found) do begin
      Walker := Next(Walker);
      if IsAfterLast(Walker) then
        StillLooking := false
      else
        Found := (Compare(aData, Examine(Walker)) = 0);
    end;
    Cursor := Walker;
    Result := Found;
  end;
end;
{--------}
function TDList.SetBeforeFirst : TListCursor;
begin
  Result := TListCursor(dlBF);
end;
{--------}
function TDList.SetAfterLast : TListCursor;
begin
  Result := TListCursor(dlAL);
end;
{--------}
function TDList.Split(Cursor : TListCursor) : TDList;
var
  TempCount : longint;
  NewList   : TDList;
  Walker    : TListCursor;
  LastNodeLeftBehind,
  JoinNode,
  LastNode  : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst(Cursor)) and (not IsAfterLast(Cursor)), ascSplitEdges);
  {$ENDIF}
  NewList := TDList(TAbstractContainerClass(ClassType).Create(IsDataOwner));
  NewList.Compare := Compare;
  NewList.DupData := DupData;
  NewList.DisposeData := DisposeData;
  NewList.IsSorted := IsSorted;
  Result := NewList;

  LastNodeLeftBehind := PNode(Cursor)^.BLink;

  TempCount := 0;
  Walker := Cursor;
  JoinNode := PNode(Walker);
  while not IsAfterLast(Walker) do begin
    inc(TempCount);
    Walker := Next(Walker);
  end;

  LastNode := PNode(Prev(Walker));

  JoinNode^.BLink := NewList.dlBF;
  NewList.dlBF^.FLink := JoinNode;
  LastNode^.FLink := NewList.dlAL;
  NewList.dlAL^.BLink := LastNode;
  NewList.acCount := TempCount;

  dec(acCount, TempCount);
  LastNodeLeftBehind^.FLink := dlAL;
  dlAL^.BLink := LastNodeLeftBehind;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeDList=================================================}
constructor TThreadsafeDList.Create(aDataOwner : boolean);
begin
  inherited Create;
  dlResLock := TezResourceLock.Create;
  dlDList := TDList.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeDList.Destroy;
begin
  dlDList.Free;
  dlResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeDList.AcquireAccess : TDList;
begin
  dlResLock.Lock;
  Result := dlDList;
end;
{--------}
procedure TThreadsafeDList.ReleaseAccess;
begin
  dlResLock.Unlock;
end;
{====================================================================}
{$ENDIF}

end.
