{===EZDSLLST==========================================================

Part of the Delphi Structures Library--the single linked list.

EZDSLLST is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 improvements to Clone
13Mar96 JMB 2.00 release for Delphi 2.0
12Nov95 JMB 1.01 fixed Iterate bug
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLLst;

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
  TLinkList = class(TAbstractContainer)
    {-Single linked list object}
    private
      llCursor, llBF, llAL  : PNode;
    protected
      procedure acSort; override;

      procedure llNextN(N : longint);
      procedure llPrevN(N : longint);
      procedure llInsertBeforePrim(aData : pointer);
      function llMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
                            aBeforeNode2 : PNode; aCount2 : longint) : PNode;
      function llMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;
    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      procedure Delete;
      procedure Empty; override;
      procedure Erase;
      function Examine : pointer;
      procedure InsertAfter(aData : pointer);
      procedure InsertBefore(aData : pointer);
      procedure InsertSorted(aData : pointer);
      function IsAfterLast : boolean;
      function IsBeforeFirst : boolean;
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : pointer;
      procedure Join(List : TLinkList);
      procedure Next;
      procedure Prev;
      function Replace(aData : pointer) : pointer;
      function Search(aData : pointer) : boolean;
      procedure SetBeforeFirst;
      procedure SetAfterLast;
      function Split : TLinkList;
  end;

{$IFDEF Win32}
type
  TThreadsafeLinkList = class
    protected {private}
      llLinkList : TLinkList;
      llResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TLinkList;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{-An iterator for cloning a single linked list}
function SListCloneItem(SL : TAbstractContainer;
                        aData : pointer;
                        NSL : pointer) : boolean; far;
var
  NewList : TLinkList absolute NSL;
  NewData : pointer;
begin
  {Note: assumes that NewList.IsAfterLast is true}
  Result := true;
  with NewList do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      InsertBefore(NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;

{-An iterator for cloning a SORTED single linked list}
function SListSortedCloneItem(SL : TAbstractContainer;
                              aData : pointer;
                              NSL : pointer) : boolean; far;
var
  NewList : TLinkList absolute NSL;
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

{====================================================================}


{===TLinkList========================================================}
constructor TLinkList.Create(DataOwner : boolean);
begin
  acNodeSize := 8;
  inherited Create(DataOwner);
  llBF := acNewNode(nil);
  acCount := 0;
  llAL := acNewNode(nil);
  acCount := 0;
  llBF^.Link := llAL;
  llAL^.Link := nil;
  llCursor := llBF;
  acCanChangeSorted := true;
end;
{--------}
constructor TLinkList.Clone(Source : TAbstractContainer;
                            DataOwner : boolean;
                            NewCompare : TCompareFunc);
var
  OldList : TLinkList absolute Source;
begin
  if not (Source is TLinkList) then
    RaiseError(escBadSource);

  Create(DataOwner);
  if Assigned(NewCompare) then
    Compare := NewCompare
  else
    Compare := OldList.Compare;
  DupData := OldList.DupData;
  DisposeData := OldList.DisposeData;
  IsSorted := OldList.IsSorted;

  if OldList.IsEmpty then Exit;

  SetAfterLast;
  if IsSorted then
    OldList.Iterate(SListSortedCloneItem, false, Self)
  else
    OldList.Iterate(SListCloneItem, false, Self);
end;
{--------}
procedure TLinkList.acSort;
begin
  if IsSorted then begin
    {move to the start, ie, make it a proper singly linked list}
    SetBeforeFirst;
    {now mergesort the linked list}
    llMergeSort(llBF, Count);
  end;
end;
{--------}
procedure TLinkList.Delete;
var
  Temp : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst) and (not IsAfterLast), ascDeleteEdges);
  {$ENDIF}
  Temp := llCursor^.Link;
  acDisposeNode(llCursor);
  llCursor := llBF^.Link;
  llBF^.Link := llCursor^.Link;
  llCursor^.Link := Temp;
end;
{--------}
procedure TLinkList.Empty;
begin
  if not IsEmpty then begin
    if IsBeforeFirst then
      Next;
    while not IsAfterLast do
      Erase;
    while not IsEmpty do begin
      Prev;
      Erase;
    end;
  end;
  if acInDone then begin
    if Assigned(llBF) then
      acDisposeNode(llBF);
    if Assigned(llAL) then
      acDisposeNode(llAL);
  end
  else begin
    llBF^.Link := llAL;
    llAL^.Link := nil;
    llCursor := llBF;
  end;
end;
{--------}
procedure TLinkList.Erase;
begin
  if IsDataOwner then
    DisposeData(Examine);
  Delete;
end;
{--------}
function TLinkList.Examine : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst) and (not IsAfterLast), ascExamineEdges);
  {$ENDIF}
  Result := llCursor^.Data;
end;
{--------}
procedure TLinkList.InsertAfter(aData : pointer);
var
  Node : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsSorted, ascIsSortedList);
  EZAssert(not IsAfterLast, ascInsertEdges);
  {$ENDIF}
  Node := acNewNode(aData);
  Node^.Link := llBF^.Link;
  llBF^.Link := Node;
end;
{--------}
procedure TLinkList.InsertBefore(aData : pointer);
begin
  {$IFDEF DEBUG}
  EZAssert(not IsSorted, ascIsSortedList);
  EZAssert(not IsBeforeFirst, ascInsertEdges);
  {$ENDIF}
  llInsertBeforePrim(aData);
end;
{--------}
procedure TLinkList.InsertSorted(aData : pointer);
begin
  {$IFDEF DEBUG}
  EZAssert(IsSorted, ascIsNotSortedList);
  {$ENDIF}
  if Search(aData) then
    RaiseError(escInsertDup);
  llInsertBeforePrim(aData);
end;
{--------}
function TLinkList.IsAfterLast : boolean;
begin
  Result := (llCursor = llAL);
end;
{--------}
function TLinkList.IsBeforeFirst : boolean;
begin
  Result := (llCursor = llBF);
end;
{--------}
function TLinkList.Iterate(Action : TIterator; Backwards : boolean;
                            ExtraData : pointer) : pointer;
begin
  if Backwards then begin
    SetAfterLast;
    Prev;
    while not IsBeforeFirst do begin
      if Action(Self, Examine, ExtraData) then
        Prev
      else begin
        Result := Examine;
        Exit;
      end;
    end;
  end
  else {not Backwards} begin
    SetBeforeFirst;
    Next;
    while not IsAfterLast do begin
      if Action(Self, Examine, ExtraData) then
        Next
      else begin
        Result := Examine;
        Exit;
      end;
    end;
  end;
  Result := nil;
end;
{--------}
procedure TLinkList.Join(List : TLinkList);
var
  JoinNode : PNode;
  Data     : pointer;
begin
  if not Assigned(List) then Exit;

  {$IFDEF DEBUG}
  EZAssert(not IsAfterLast, ascCannotJoinHere);
  EZAssert(List.IsDataOwner = IsDataOwner, ascCannotJoinData);
  {$ENDIF}

  if not List.IsEmpty then begin
    {prepare}
     with List do begin
       SetBeforeFirst;
       Next;
     end;
    {if we are sorted, add new nodes in sorted order}
    if {Self.}IsSorted then
      while not List.IsAfterLast do begin
        Data := List.Examine;
        List.Delete;
        InsertSorted(Data);
      end
    {if we are not sorted, add new nodes directly}
    else {Self is unsorted} begin
      JoinNode := List.llCursor;
      with List do begin
        SetAfterLast;
        Prev;
      end;
      JoinNode^.Link := llCursor;
      llCursor := List.llCursor;
      inc(acCount, List.Count);
      {patch up List to be empty}
      with List do begin
        llCursor := llBF;
        acCount := 0;
      end;
    end;
  end;
  List.Free;
end;
{--------}
procedure TLinkList.llInsertBeforePrim(aData : pointer);
var
  Node : PNode;
begin
  Node := acNewNode(aData);
  Node^.Link := llCursor^.Link;
  llCursor^.Link := Node;
end;
{--------}
procedure TLinkList.llNextN(N : longint);
var
  i          : longint;
  Temp       : PNode;
  TempCursor : PNode;
begin
  TempCursor := llCursor;
  try
    for i := 1 to N do begin
      if (TempCursor = llAL) then
        RaiseError(escCannotMoveHere);
      Temp := TempCursor;
      TempCursor := llBF^.Link;
      llBF^.Link := TempCursor^.Link;
      TempCursor^.Link := Temp;
    end;
  finally
    llCursor := TempCursor;
  end;
end;
{--------}
function TLinkList.llMergeLists(aBeforeNode1 : PNode; aCount1 : longint;
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
  Node1 := aBeforeNode1^.Link;
  Node2 := aBeforeNode2^.Link;
  {picking off nodes one by one from each sublist, attach them in
   sorted order onto the link of the Last node, until we run out of
   nodes from one of the sublists}
  while (Inx1 < aCount1) and (Inx2 < aCount2) do begin
    if (Compare(Node1^.Data, Node2^.Data) <= 0) then begin
      Temp := Node1;
      Node1 := Node1^.Link;
      inc(Inx1);
    end
    else {Node1 > Node2} begin
      Temp := Node2;
      Node2 := Node2^.Link;
      inc(Inx2);
    end;
    Last^.Link := Temp;
    Last := Temp;
  end;
  {if there are nodes left in the first sublist, merge them}
  if (Inx1 < aCount1) then begin
    while (Inx1 < aCount1) do begin
      Last^.Link := Node1;
      Last := Node1;
      Node1 := Node1^.Link;
      inc(Inx1);
    end;
  end
  {otherwise there must be nodes left in the second sublist, so merge
   them}
  else begin
    while (Inx2 < aCount2) do begin
      Last^.Link := Node2;
      Last := Node2;
      Node2 := Node2^.Link;
      inc(Inx2);
    end;
  end;
  {patch up link to rest of list}
  Last^.Link := Node2;
  {return the last node}
  Result := Last;
end;
{--------}
function TLinkList.llMergeSort(aBeforeNode : PNode; aCount : longint) : PNode;
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
    Result := aBeforeNode^.Link;
    Exit;
  end;
  {split the current sublist into 2 'equal' halves}
  Count2 := aCount shr 1;
  aCount := aCount - Count2;
  {mergesort the first half, save last node of sorted sublist}
  LastNode1 := llMergeSort(aBeforeNode, aCount);
  {mergesort the second half, discard last node of sorted sublist}
  {$IFDEF Windows}
  DummyNode :=
  {$ENDIF}
  llMergeSort(LastNode1, Count2);
  {merge the two sublists, and return the last sorted node}
  Result := llMergeLists(aBeforeNode, aCount, LastNode1, Count2);
end;
{--------}
procedure TLinkList.llPrevN(N : longint);
var
  i          : longint;
  Temp       : PNode;
  TempCursor : PNode;
begin
  TempCursor := llCursor;
  try
    for i := 1 to N do begin
      if (TempCursor = llBF) then
        RaiseError(escCannotMoveHere);
      Temp := TempCursor^.Link;
      TempCursor^.Link := llBF^.Link;
      llBF^.Link := TempCursor;
      TempCursor := Temp;
    end;
  finally
    llCursor := TempCursor;
  end;
end;
{--------}
procedure TLinkList.Next;
var
  Temp : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsAfterLast, ascAlreadyAtEnd);
  {$ENDIF}
  Temp := llCursor;
  llCursor := llBF^.Link;
  llBF^.Link := llCursor^.Link;
  llCursor^.Link := Temp;
end;
{--------}
procedure TLinkList.Prev;
var
  Temp : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsBeforeFirst, ascAlreadyAtStart);
  {$ENDIF}
  Temp := llCursor^.Link;
  llCursor^.Link := llBF^.Link;
  llBF^.Link := llCursor;
  llCursor := Temp;
end;
{--------}
function TLinkList.Replace(aData : pointer) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst) and (not IsAfterLast), ascReplaceEdges);
  {$ENDIF}
  if IsSorted then begin
    Result := Examine;
    Delete;
    InsertSorted(aData);
  end
  else with llCursor^ do begin
    Result := Data;
    Data := aData;
  end;
end;
{--------}
function TLinkList.Search(aData : pointer) : boolean;
var
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
  if IsSorted then begin
    if (Count = 0) then begin
      Result := false;
      SetAfterLast;
      Exit;
    end;
    if not IsBeforeFirst then
      SetBeforeFirst;
    L := 0;
    R := pred(Count);
    CursorNumber := -1;
    StartNumber := -1;
    StartCursor := llBF;
    TempCursor := llBF;
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
        TempCursor := TempCursor^.Link;
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
    if (L > CursorNumber) then
      inc(CursorNumber)
    else if (L < CursorNumber) then
      dec(CursorNumber);
    llNextN(CursorNumber+1);
  end
  else {the list is not currently sorted, search from the start} begin
    SetBeforeFirst;
    StillLooking := true;
    Found := false;
    while StillLooking and (not Found) do begin
      Next;
      if IsAfterLast then
        StillLooking := false
      else
        Found := (Compare(aData, Examine) = 0);
    end;
    Result := Found;
  end;
end;
{--------}
procedure TLinkList.SetAfterLast;
var
  TempCursor,
  NextLink,
  Temp : PNode;
begin
  {for speed reasons, code from first principles,
   this is equivalent to:
     while not IsAfterLast do Next;}
  NextLink := llBF^.Link;
  TempCursor := llCursor;
  while (TempCursor <> llAL) do begin
    Temp := TempCursor;
    TempCursor := NextLink;
    NextLink := TempCursor^.Link;
    TempCursor^.Link := Temp;
  end;
  llCursor := TempCursor;
  llBF^.Link := NextLink;
end;
{--------}
procedure TLinkList.SetBeforeFirst;
var
  TempCursor,
  NextLink,
  Temp : PNode;
begin
  {for speed reasons, code from first principles,
   this is equivalent to:
     while not IsBeforeFirst do Prev;}
  NextLink := llBF^.Link;
  TempCursor := llCursor;
  while (TempCursor <> llBF) do begin
    Temp := TempCursor^.Link;
    TempCursor^.Link := NextLink;
    NextLink := TempCursor;
    TempCursor := Temp;
  end;
  llCursor := TempCursor;
  llBF^.Link := NextLink;
end;
{--------}
function TLinkList.Split : TLinkList;
var
  TempCount : longint;
  NewList   : TLinkList;
  LastNodeLeftBehind,
  JoinNode  : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((not IsBeforeFirst) and (not IsAfterLast), ascSplitEdges);
  {$ENDIF}

  NewList := TLinkList(TAbstractContainerClass(ClassType).Create(IsDataOwner));
  NewList.Compare := Compare;
  NewList.DupData := DupData;
  NewList.DisposeData := DisposeData;
  NewList.IsSorted := IsSorted;
  Result := NewList;

  LastNodeLeftBehind := llCursor^.Link;

  TempCount := 0;
  JoinNode := llCursor;
  while not IsAfterLast do begin
    inc(TempCount);
    Next;
  end;

  JoinNode^.Link := NewList.llBF;
  NewList.llCursor := llAL^.Link;
  NewList.Next;
  NewList.acCount := TempCount;

  dec(acCount, TempCount);
  llAL^.Link := LastNodeLeftBehind;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeLinkList==============================================}
constructor TThreadsafeLinkList.Create(aDataOwner : boolean);
begin
  inherited Create;
  llResLock := TezResourceLock.Create;
  llLinkList := TLinkList.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeLinkList.Destroy;
begin
  llLinkList.Free;
  llResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeLinkList.AcquireAccess : TLinkList;
begin
  llResLock.Lock;
  Result := llLinkList;
end;
{--------}
procedure TThreadsafeLinkList.ReleaseAccess;
begin
  llResLock.Unlock;
end;
{====================================================================}
{$ENDIF}

end.
