unit gppTree;

interface
uses
  System.Classes;

type
  INode<T: class> = interface
  ['{3BE01E57-FEF8-434F-B5D1-679748287C9F}']
    procedure SetData(const aValue : T);
    function GetData(): T;

    function NextNode: INode<T>;
    function PreviousNode: INode<T>;
    procedure setNextNode(const aNewNode : INode<T>);
    procedure setPreviousNode(const aNewNode : INode<T>);

    function HasNextNode:Boolean;
    function HasPreviousNode:Boolean;

    procedure setOwnsData(const aValue : boolean);
    function getOwnsData: boolean;

    property Data : T read GetData write setData;
    property OwnsData : boolean read getOwnsData write setOwnsData;
  end;

  TNode<T: class> = class(TInterfacedObject, INode<T>)
  private
    constructor Create(aValue: T);
  protected
    fOwnsData : boolean;
    fData : T;
    fNextNode : INode<T>;
    fPreviousNode : INode<T>;
    procedure SetData(const aValue : T);
    function GetData(): T;
    procedure setOwnsData(const aValue : boolean);
    function getOwnsData: boolean;
  public
    function NextNode: INode<T>;
    function PreviousNode: INode<T>;

    procedure setNextNode(const aNewNode : INode<T>);
    procedure setPreviousNode(const aNewNode : INode<T>);

    function HasNextNode:Boolean;
    function HasPreviousNode:Boolean;
  end;


  TRootNode<T: class> = class(TNode<T>)
  public type
    TCompareFunc = function (aNodeA, aNodeB : INode<T>) : integer;
  private
    fCompareFunc : TCompareFunc;
    fFirstNode : INode<T>;
    fTailNode : INode<T>;
    fIsSorted : boolean;
    fOwnsData : boolean;
    FCount : Cardinal;
    function MergeSortImpl(const aBeforeNode: INode<T>; aCount : cardinal) : INode<T>;
    function MergeListsImpl(aBeforeNode1 : INode<T>; aCount1 : longint;
                             aBeforeNode2 : INode<T>; aCount2 : longint) :  INode<T>;

  public
    constructor Create(const aDoOwnsData : boolean);
    destructor Destroy; override;

    function FirstNode : INode<T>;
    function FindNode(const aSearchNode : INode<T>; out aResultNode: INode<T>) : boolean;

    function AppendNode(const aValue:T) : INode<T>;
    procedure ClearNodes();
    procedure SortNodes();
    property CompareFunc : TCompareFunc read fCompareFunc write fCompareFunc;
    property Count : Cardinal read FCount;
  end;


implementation

uses
  Sysutils;

{ TNode }

constructor TNode<T>.Create(aValue: T);
begin
  fOwnsData := true;
  fData := aValue;
  fNextNode := nil;
  fPreviousNode := nil;
end;



function TNode<T>.HasPreviousNode: Boolean;
begin
  Result := PreviousNode <> nil;
end;

function TNode<T>.PreviousNode: INode<T>;
begin
  Result := fPreviousNode;
end;

function TNode<T>.HasNextNode: Boolean;
begin
  Result := NextNode <> nil;
end;

function TNode<T>.NextNode: INode<T>;
begin
  Result := fNextNode
end;


procedure TNode<T>.SetData(const aValue: T);
begin
  if assigned(fData) and (fData <> aValue) then
    raise exception.Create('Must free Instance before setting pointer.');
  fData := aValue;
end;


function TNode<T>.GetData: T;
begin
  result := fData;
end;


procedure TNode<T>.setOwnsData(const aValue: boolean);
begin
  fOwnsData := aValue;
end;

function TNode<T>.getOwnsData: boolean;
begin
  result := fOwnsData;
end;


{ TRootNode }



procedure TNode<T>.setNextNode(const aNewNode : INode<T>);
begin
  fNextNode := aNewNode;
end;


procedure TNode<T>.setPreviousNode(const aNewNode: INode<T>);
begin
  fPreviousNode := aNewNode;
end;

{ TRootNode<T> }

constructor TRootNode<T>.Create(const aDoOwnsData: boolean);
begin
  fOwnsData := aDoOwnsData;
end;

destructor TRootNode<T>.Destroy;

begin
  ClearNodes;
  inherited;
end;

procedure TRootNode<T>.ClearNodes;
var LCurrent : INode<T>;
    LBefore : INode<T>;
begin
  LCurrent := fFirstNode;

  while (assigned(LCurrent)) do
  begin
    LBefore := LCurrent;
    LCurrent := LBefore.NextNode;
    LBefore.setPreviousNode(nil);
    LBefore.setNextNode(nil);
  end;
  fTailNode := nil;
  fFirstNode := nil;
  fCount := 0;
end;


function TRootNode<T>.FirstNode : INode<T>;
begin
  result := fFirstNode;
end;


procedure TRootNode<T>.SortNodes;
var
  LCurrent : INode<T>;
  LTemp : INode<T>;
  Dad, Son : INode<T>;
begin
  if not fIsSorted then
    {Merge sort as single linked list}
    MergeSortImpl(self.fFirstNode, fCount);
    { repair backward refs}
    LCurrent := fFirstNode;
    while (LCurrent <> nil) do begin
      LTemp := LCurrent;
      LCurrent := LTemp.NextNode;
      if assigned(LCurrent) then
        LCurrent.SetPreviousNode(LTemp);
    end;
    fIsSorted := true;
end;


function TRootNode<T>.MergeSortImpl(const aBeforeNode: INode<T>; aCount : cardinal) : INode<T>;
var CountHalf : cardinal;
    LastNodeFirstHalf : INode<T>;
begin


  {recursion terminator: if there's only one thing to sort we're
   already sorted <g>}
  if (fCount <= 1) then begin
    Result := aBeforeNode;
    Exit;
  end;
  {split the current sublist into 2 'equal' halves}
  CountHalf := aCount shr 1;
  aCount := aCount - CountHalf;
  {mergesort the first half, save last node of sorted sublist}
  LastNodeFirstHalf := MergeSortImpl(aBeforeNode, aCount);
  {mergesort the second half, discard last node of sorted sublist}
  MergeSortImpl(LastNodeFirstHalf, CountHalf);
  {Merge the lists and return the last etry}
  Result := MergeListsImpl(aBeforeNode, aCount, LastNodeFirstHalf, CountHalf);
end;

function TRootNode<T>.MergeListsImpl(aBeforeNode1 : INode<T>; aCount1 : longint;
                             aBeforeNode2 : INode<T>; aCount2 : longint) :  INode<T>;
var
  Last  : INode<T>;
  Temp  : INode<T>;
  Node1 : INode<T>;
  Node2 : INode<T>;
  Idx1  : longint;
  Idx2  : longint;
begin
  {Note: the way this routine is called means that the two sublists to
         be merged look like this
           BeforeNode1 -> SubList1 -> SubList2 -> rest of list
         In particular the last node of sublist2 points to the rest of
         the (unsorted) linked list.}
  {prepare for main loop}
  Last := aBeforeNode1;
  Idx1 := 0;
  Idx2 := 0;
  Node1 := aBeforeNode1.NextNode;
  Node2 := aBeforeNode2.NextNode;
  {picking off nodes one by one from each sublist, attach them in
   sorted order onto the link of the Last node, until we run out of
   nodes from one of the sublists}
  while (Idx1 < aCount1) and (Idx2 < aCount2) do begin
    if (fCompareFunc(Node1, Node2) <= 0) then begin
      Temp := Node1;
      Node1 := Node1.NextNode;
      inc(Idx1);
    end
    else {Node1 > Node2} begin
      Temp := Node2;
      Node2 := Node2.PreviousNode;
      inc(Idx2);
    end;
    Last.SetNextNode(Temp);
    Last := Temp;
  end;
  {if there are nodes left in the first sublist, merge them}
  if (Idx1 < aCount1) then begin
    while (Idx1 < aCount1) do begin
      Last.setNextNode(Node1);
      Last := Node1;
      Node1 := Node1.NextNode;
      inc(Idx1);
    end;
  end
  {otherwise there must be nodes left in the second sublist, so merge
   them}
  else begin
    while (Idx2 < aCount2) do begin
      Last.setNextNode(Node2);
      Last := Node2;
      Node2 := Node2.NextNode;
      inc(Idx2);
    end;
  end;
  {patch up link to rest of list}
  Last.setNextNode(Node2);
  {return the last node}
  Result := Last;
end;

function TRootNode<T>.FindNode(const aSearchNode : INode<T>; out aResultNode: INode<T>) : boolean;
var
  LUnsortedCursor : INode<T>;
  CompResult   : integer;
  Found        : boolean;
  i            : longint;
  L, R, M      : longint;
  CursorNumber : longint;
  StartNumber  : longint;
  TempCursor   : INode<T>;
  StartCursor  : INode<T>;
begin
  aResultNode := nil;
  if fIsSorted then begin
    if (Count = 0) then begin
      Result := false;
      Exit;
    end;
    L := 0;
    R := pred(fCount);
    CursorNumber := -1;
    StartNumber := -1;
    StartCursor := fFirstNode;
    TempCursor := fFirstNode;
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
        TempCursor := TempCursor.NextNode;
      CursorNumber := M;
      CompResult := CompareFunc(aSearchNode, TempCursor);
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
    aResultNode := TempCursor;
    if assigned(aResultNode) then
    begin
      if (L > CursorNumber) then
        aResultNode := aResultNode.NextNode
      else if (L < CursorNumber) then
        aResultNode := aResultNode.PreviousNode;
    end;
  end
  else {the list is not sorted} begin
    Found := false;
    LUnsortedCursor := fFirstNode;
    while assigned(LUnsortedCursor) and (not Found) do begin
      if assigned(LUnsortedCursor) then
      begin
        Found := (CompareFunc(aSearchNode, LUnsortedCursor) = 0);
        if found then
          aResultNode := LUnsortedCursor;
        LUnsortedCursor := LUnsortedCursor.NextNode;
      end;

    end;
    Result := Found;
  end;
end;

function TRootNode<T>.AppendNode(const aValue: T): INode<T>;
var LOldTail : INode<T>;
begin
  LOldTail := fTailNode;
  result := TNode<T>.Create(AValue);
  result.OwnsData := fOwnsData;
  fTailNode := result;

  if assigned(LOldTail) then
    LOldTail.setNextNode(fTailNode);
  fTailNode.setPreviousNode(LOldTail);
  inc(FCount);
  fIsSorted := false;
  if assigned(fFirstNode) then
  begin
    if FCount = 2 then
      fFirstNode.setNextNode(result);
  end
  else
    fFirstNode := result;

end;





end.