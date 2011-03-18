{===EZDSLBSE==========================================================

Part of the EZ Delphi Structures Library--the base class and node
store routines.

EZDSLBSE is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 DupData can be set at all times
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLBse;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here----------------------}


{--------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

{$IFDEF Win32}
{$R EZDSLCts.R32}
{$ELSE}
{$R EZDSLCts.R16}
{$ENDIF}

uses
  SysUtils,
  WinTypes,
  WinProcs,
  Classes,
  {$IFDEF Win32}
  EZDSLThd,
  {$ENDIF}
  EZDSLCts,
  EZDSLSup;

const
  skMaxLevels = 16;       {Maximum levels in a skip list}

type
  TAbstractContainer = class;
  TAbstractContainerClass = class of TAbstractContainer;
  PNode = ^TNode;

  TChild = (CLeft, CRight);
    {-Binary trees: flags for left and right children}
  TTraversalType = (ttPreOrder, ttInOrder, ttPostOrder, ttLevelOrder);
    {-Binary trees: methods of traversing their nodes}

  TListCursor = longint;
    {-Cursor for TDList and TSkipList (double linked & skip lists)}
  TTreeCursor = longint;
    {-Cursor for TBinTree and descendants (binary trees)}

  TDisposeDataProc = procedure (aData : pointer);
    {-Data disposal procedure type for containers}
  TCompareFunc = function (Data1, Data2 : pointer) : integer;
    {-Data comparison procedure type for containers}
  TDupDataFunc = function (aData : pointer) : pointer;
    {-Data duplication procedure type for containers}

  TIterator = function (C : TAbstractContainer;
                        aData : pointer;
                        ExtraData : pointer) : boolean;
    {-Iterator function called by Iterate for each item, must return
      true to continue iterating, false to stop}



  {--Internal object type definitions--}
  TNode = record
    {-Internal definition of a node}
    Data : pointer;
    case byte of                           {For...}
      0 : (Link : PNode);                  {Stacks, Queues, Deques, Lists}
      1 : (FLink, BLink : PNode);          {Doubly-linked lists}
      2 : (Size   : integer;               {Skip lists}
           Lvls   : integer;
           BkLink : PNode;
           FwLink : array [0..pred(skMaxLevels)] of PNode);
      3 : (TLink : array [TChild] of PNode;{Trees}
           case byte of
             0 : (PKC : longint);          {Binary Trees}
             1 : (PLink : PNode))          {Heaps}
  end;

  TNodeStore = class
    {-Internal object that maintains suballocation of nodes}
    private
      nsRefCount  : integer;
      nsNodeSize  : integer;
      nsBlock     : PNode;
      nsNodeStack : PNode;
      nsSpareNodeCount : longint;
      {$IFDEF Win32}
      nsResLock   : TezResourceLock;
      {$ENDIF}

    protected
      procedure nsGrowSpareNodeStack;

    public
      constructor Create(aNodeSize : integer);
      destructor Destroy; override;

      function Alloc : PNode;
      procedure Dealloc(aNode : PNode);
  end;


  {--Container object types--}
  TAbstractContainer = class(TPersistent)
    {-Ancestor object: methods will be overridden}
    private
      acCompare     : TCompareFunc;
      acDisposeData : TDisposeDataProc;
      acDupData     : TDupDataFunc;

      acNS          : TNodeStore;

    protected
      acCount       : longint;
      acIsDataOwner : boolean;
      acIsSorted    : boolean;
      acNodeSize    : integer;
      acInDone      : boolean;
      acCanChangeSorted : boolean;

      procedure acSetCompare(NewFunc : TCompareFunc);
      procedure acSetDisposeData(NewProc : TDisposeDataProc);
      procedure acSetDupData(NewFunc : TDupDataFunc);
      procedure acSetIsSorted(S : boolean); 

      procedure acDisposeNode(aNode : PNode); virtual;
      function acNewNode(aData : pointer) : PNode; virtual;

      procedure acSort; virtual;

    public
      {constructor/destructor}
      constructor Create(DataOwner : boolean); virtual;
      constructor Clone(Source     : TAbstractContainer;
                        DataOwner  : boolean;
                        NewCompare : TCompareFunc); virtual; abstract;
      destructor Destroy; override;

      {methods}
      procedure Empty; virtual; abstract;
      function IsEmpty : boolean;

      {properties}
      property Count : longint
         read acCount;

      property IsDataOwner : boolean
         read acIsDataOwner;

      property Compare : TCompareFunc
         read acCompare
         write acSetCompare;

      property DisposeData : TDisposeDataProc
         read acDisposeData
         write acSetDisposeData;

      property DupData : TDupDataFunc
         read acDupData
         write acSetDupData;

      property IsSorted : boolean
         read acIsSorted write acSetIsSorted;
  end;

implementation

{$IFDEF Win32}
var
{$ELSE}
const
{$ENDIF}
  ListInitialised : boolean = false;

const
  MinNodeSize = 8;
  MaxNodeSize = 64;
  NodeSizeDelta = 4;
  NumNodeSizes = succ((MaxNodeSize - MinNodeSize) div NodeSizeDelta);

var
  NodeStoreList : array [0..pred(NumNodeSizes)] of TNodeStore;

{===NodeStore helper routines========================================}
function GetNodeStore(Size : integer) : TNodeStore;
var
  Index : integer;
begin
  if (Size < MinNodeSize) then
    Size := MinNodeSize
  else if (Size > MaxNodeSize) then
    Size := MaxNodeSize;
  Size := (pred(Size + NodeSizeDelta) div NodeSizeDelta) * NodeSizeDelta;

  if not ListInitialised then begin
    FillChar(NodeStoreList, sizeof(NodeStoreList), 0);
    ListInitialised := true;
  end;

  Index := (Size - MinNodeSize) div NodeSizeDelta;

  Result := NodeStoreList[Index];
  if not Assigned(Result) then begin
    Result := TNodeStore.Create(Size);
    NodeStoreList[Index] := Result;
  end;
  inc(Result.nsRefCount);
end;
{--------}
procedure FreeNodeStore(NS : TNodeStore);
var
  Index : integer;
begin
  if Assigned(NS) then begin
    dec(NS.nsRefCount);
    if (NS.nsRefCount = 0) then begin
      Index := (NS.nsNodeSize - MinNodeSize) div NodeSizeDelta;
      NS.Destroy;
      NodeStoreList[Index] := nil;
    end;
  end;
end;
{====================================================================}


{=TNodeStore==========================================================
A node warehouse.

A node warehouse stores nodes for TAbstractContainer descendants.
Because the size of a node for a given container is fixed, the
TNodeStore can preallocate a single block of them, and dole them out
singly to the requesting container (ie suballocate the larger block
into smaller nodes). When a node is finished with, it is returned to
the store and will be doled out again. The node store manages two
structures: a very simple linked list of node blocks and a simple
stack of used nodes. The node block is 128 nodes large. This extra
effort is well rewarded, compared with allocating nodes when and
where needed from the heap manager, this is noticeably faster (15-
20% faster, dependent on the number of allocations/frees of nodes).

The node warehouses are stored in a simple array as a global resource.
For each node size there will be one node warehouse. There can be many
containers attached to each warehouse, the count is held in the
nsRefCount field. Every time a container gets attached to a node
warehouse nsRefCount is incremented, every time one is unlinked the
nsRefCount is decremented. If it reaches zero, it is freed. Node
warehouses are allocated with GetNodeStore and freed with
FreeNodeStore.

18Jun95 JMB
=====================================================================}
const
  cNumNodes = 128; {Best if it is a power of two}
{--------}
constructor TNodeStore.Create(aNodeSize : integer);
begin
  nsNodeSize := aNodeSize;
  nsGrowSpareNodeStack;
  {$IFDEF Win32}
  nsResLock := TezResourceLock.Create;
  {$ENDIF}
end;
{--------}
destructor TNodeStore.Destroy;
var
  Temp : PNode;
begin
  while Assigned(nsBlock) do begin
    Temp := nsBlock;
    nsBlock := Temp^.Link;
    SafeFreeMem(Temp, nsNodeSize * cNumNodes);
  end;
  {$IFDEF Win32}
  nsResLock.Free;
  {$ENDIF}
end;
{--------}
function TNodeStore.Alloc : PNode;
begin
  {$IFDEF Win32}
  nsResLock.Lock;
  try
  {$ENDIF}
  if (nsSpareNodeCount = 0) then
    nsGrowSpareNodeStack;
  Result := nsNodeStack;
  nsNodeStack := Result^.Link;
  FillChar(Result^, nsNodeSize, 0);
  dec(nsSpareNodeCount);
  {$IFDEF Win32}
  finally
    nsResLock.Unlock;
  end;{try..finally}
  {$ENDIF}
end;
{--------}
procedure TNodeStore.Dealloc(aNode : PNode);
begin
  {$IFDEF Win32}
  nsResLock.Lock;
  try
  {$ENDIF}
  if Assigned(aNode) then begin
    {$IFDEF DEBUG}
    FillChar(aNode^, nsNodeSize, $CC);
    {$ENDIF}
    aNode^.Link := nsNodeStack;
    nsNodeStack := aNode;
    inc(nsSpareNodeCount);
  end;
  {$IFDEF Win32}
  finally
    nsResLock.Unlock;
  end;{try..finally}
  {$ENDIF}
end;
{--------}
procedure TNodeStore.nsGrowSpareNodeStack;
var
  i : integer;
  Temp : PNode;
  Node : PNode;
  WalkerNode : PChar absolute Node; {for pointer arithmetic}
begin
  SafeGetMem(Temp, nsNodeSize * cNumNodes);
  Temp^.Link := nsBlock;
  nsBlock := Temp;
  Node := nsBlock;
  WalkerNode := WalkerNode + nsNodeSize; {alters Node}
  for i := 1 to pred(cNumNodes) do begin
    Node^.Link := nsNodeStack;
    nsNodeStack := Node;
    WalkerNode := WalkerNode + nsNodeSize; {alters Node}
  end;
  inc(nsSpareNodeCount, pred(cNumNodes));
end;
{====================================================================}


{===Data object routines=============================================}
function EZAbstractCompare(Data1, Data2 : pointer) : integer; far;
begin
  RaiseError(escNoCompare);
  Result := 0;
end;
{--------}
procedure EZAbstractDisposeData(aData : pointer); far;
begin
  RaiseError(escNoDisposeData);
end;
{--------}
function EZAbstractDupData(aData : pointer) : pointer; far;
begin
  RaiseError(escNoDupData);
  Result := nil;
end;
{====================================================================}


{===TAbstractContainer===============================================}
constructor TAbstractContainer.Create(DataOwner : boolean);
begin
  acIsDataOwner := DataOwner;
  acCompare := EZAbstractCompare;
  if DataOwner then
    acDisposeData := EZAbstractDisposeData
  else
    acDisposeData := EZNoDisposeData;
  acDupData := EZAbstractDupData;
  if (acNodeSize <> 0) then
    acNS := GetNodeStore(acNodeSize);
end;
{--------}
destructor TAbstractContainer.Destroy;
begin
  acInDone := true;
  Empty;
  FreeNodeStore(acNS);
end;
{--------}
procedure TAbstractContainer.acDisposeNode(aNode : PNode);
begin
  {$IFDEF DEBUG}
  EZAssert(Assigned(aNode), ascFreeNilNode);
  EZAssert((acNodeSize <> 0), ascFreeNodeSize0);
  {$ENDIF}
  acNS.Dealloc(aNode);
  if (acCount > 0) then
    dec(acCount);
end;
{--------}
function TAbstractContainer.acNewNode(aData : pointer) : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert((acNodeSize <> 0), ascNewNodeSize0);
  {$ENDIF}
  Result := acNS.Alloc;
  inc(acCount);
  Result^.Data := aData;
end;
{--------}
procedure TAbstractContainer.acSetCompare(NewFunc : TCompareFunc);
begin
  if Assigned(NewFunc) and (@NewFunc <> @EZAbstractCompare) then begin
    acCompare := NewFunc;
    if IsSorted and (acCount > 0) then
      acSort;
  end
  else {NewFunc is nil, or is equal to EZAbstractCompare} begin
    if IsSorted then
      RaiseError(escSortNeedsCmp);
    acCompare := EZAbstractCompare;
  end;
end;
{--------}
procedure TAbstractContainer.acSetDisposeData(NewProc : TDisposeDataProc);
begin
  if not IsDataOwner then
    acDisposeData := EZNoDisposeData
  else if Assigned(NewProc) then
    acDisposeData := NewProc
  else
    acDisposeData := EZAbstractDisposeData;
end;
{--------}
procedure TAbstractContainer.acSetDupData(NewFunc : TDupDataFunc);
begin
  if Assigned(NewFunc) then
    acDupData := NewFunc
  else
    acDupData := EZAbstractDupData;
end;
{--------}
procedure TAbstractContainer.acSetIsSorted(S : boolean);
begin
  if acCanChangeSorted and (S <> IsSorted) then begin
    if S and (@acCompare = @EZAbstractCompare) then
      RaiseError(escCmpNeeded);
    acIsSorted := S;
    if S and (acCount > 0) then
      acSort;
  end;
end;
{--------}
procedure TAbstractContainer.acSort;
begin
  {do nothing at this level}
end;
{--------}
function TAbstractContainer.IsEmpty : boolean;
begin
  Result := (acCount = 0);
end;
{====================================================================}

end.
