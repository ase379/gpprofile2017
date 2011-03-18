{===EZDSLBTR==========================================================

Part of the Delphi Structures Library--the binary tree, the binary
search tree and the red-black binary search tree.

EZDSLBTR is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
24May96 JMB 2.01 removal of (some) warnings for Delphi 2
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLBtr;

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
  EZDSLBse,
  EZDSLStk,
  EZDSLQue;

type
  TBinTree = class(TAbstractContainer)
    {-Binary tree object}
    private
      btRt           : PNode;
      btTravType     : TTraversalType;
      btUseRecursion : boolean;
    protected
      procedure btInsertPrim(var Cursor : TTreeCursor; aNode : PNode); virtual;
    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      function Delete(Cursor : TTreeCursor) : TTreeCursor; virtual;
      procedure Empty; override;
      function Erase(Cursor : TTreeCursor) : TTreeCursor;
      function Examine(Cursor : TTreeCursor) : pointer;
      procedure Insert(var Cursor : TTreeCursor; aData : pointer); virtual;
      function IsLeaf(Cursor : TTreeCursor) : boolean;
      function IsRoot(Cursor : TTreeCursor) : boolean;
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : TTreeCursor;
      procedure Join(Cursor : TTreeCursor; Tree : TBinTree); virtual;
      function Left(Cursor : TTreeCursor) : TTreeCursor;
      function Parent(Cursor : TTreeCursor) : TTreeCursor;
      function Replace(Cursor : TTreeCursor; aData : pointer) : pointer; virtual;
      function Right(Cursor : TTreeCursor) : TTreeCursor;
      function Root : TTreeCursor;
      function Search(var Cursor : TTreeCursor; aData : pointer) : boolean; virtual;

      property TraversalType : TTraversalType
         read btTravType
         write btTravType;
      property UseRecursion : boolean
         read btUseRecursion
         write btUseRecursion;
  end;

  TBinSearchTree = class(TBinTree)
    {-Binary search tree object}
    protected
      procedure acSort; override;
      procedure bsSortTraverse(aNode : PNode);
      procedure bsSwapData(OldCursor, NewCursor : TTreeCursor); virtual;
    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      function Delete(Cursor : TTreeCursor) : TTreeCursor; override;
      procedure Insert(var Cursor : TTreeCursor; aData : pointer); override;
      procedure Join(Cursor : TTreeCursor; Tree : TBinTree); override;
      function Replace(Cursor : TTreeCursor; aData : pointer) : pointer; override;
      function Search(var Cursor : TTreeCursor; aData : pointer) : boolean; override;
  end;

  TrbSearchTree = class(TBinSearchTree)
    {-Balanced binary search tree object (Red-black tree)}
    private
      rbDeletedNodeWasBlack : boolean;

    protected
      procedure btInsertPrim(var Cursor : TTreeCursor; aNode : PNode); override;
      procedure bsSwapData(OldCursor, NewCursor : TTreeCursor); override;
      function rbPromote(Cursor : TTreeCursor) : TTreeCursor;

    public
      function Delete(Cursor : TTreeCursor) : TTreeCursor; override;
  end;

{$IFDEF Win32}
type
  TThreadsafeBinTree = class
    protected {private}
      btBinTree : TBinTree;
      btResLock : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TBinTree;
      procedure ReleaseAccess;
  end;

  TThreadsafeBinSearchTree = class
    protected {private}
      bstBinSearchTree : TBinSearchTree;
      bstResLock       : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TBinSearchTree;
      procedure ReleaseAccess;
  end;

  TThreadsafeRBSearchTree = class
    protected {private}
      rbstrbSearchTree : TrbSearchTree;
      rbstResLock      : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TrbSearchTree;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{Notes: the TTreeCursor is a pointer and a boolean wrapped in one. In
        Delphi, pointers allocated on the heap have a granularity of
        4 bytes, ie their offset always has the lower 2 bits clear.
        We use bit 0 of the pointer as a left child, right child
        indicator (left = 0, right = 1). Thus the TTreeCursor is a
        pointer to the parent's node and an indicator to the relevant
        child.
        The parent link field of a node (the PKC) is a pointer and two
        booleans wrapped in one. The pointer is the parent's node as
        for TTreeCursors, bit 0 is the child (so a node always knows
        which child it is) and we use bit 1 of the pointer as a color
        bit for red-black trees (black = 0, red = 1). This by the way
        violates pure OOP design where ancestor aren't supposed to
        'know' about their descendants, but as I wrote the binary
        tree implementations in one go...
        Note that given a node you can easily calculate the
        TTreeCursor value for that node: just set the color bit of the
        PKC to 0 (the routine to use is Bleach).
        The following 6 routines all help maintain these 'packed'
        variables.                                                    }

{-Given a cursor, returns the address of node's parent node}
function Dad(X : TTreeCursor) : PNode;
{$IFDEF Win32}
begin
  Result := PNode(X and $FFFFFFFC);
end;
{$ELSE}
inline($58/            {pop ax      get offset}
       $25/$FC/$FF/    {and ax, XX  clear color and child bits}
       $5A);           {pop dx      get seg/sel}
{$ENDIF}
{--------}
{-Given a cursor, returns the child relationship the node has with its parent}
function Kid(X : TTreeCursor) : TChild;
{$IFDEF Win32}
begin
  Result := TChild(X and $1);
end;
{$ELSE}
inline($58/            {pop ax      get offset}
       $25/$01/$00/    {and ax, 1   isolate child bit}
       $5A);           {pop dx      toss seg/sel}
{$ENDIF}
{--------}
{-Given a cursor, returns the address of the node being pointed to}
function GetNode(Cursor : TTreeCursor) : PNode;
{$IFDEF Win32}
register;
asm
  mov edx, eax
  and edx, 1
  shl edx, 2
  and eax, $FFFFFFFC
  mov eax, [eax+edx+4]
end;
{$ELSE}
near; assembler;
asm
  mov ax, Cursor.Word[2]
  mov es, ax
  mov di, Cursor.Word[0]
  mov ax, di
  and ax, $FFFC
  xchg ax, di
  and ax, 1
  shl ax, 1
  shl ax, 1
  add di, ax
  mov ax, es:[di+4]
  mov dx, es:[di+6]
end;
{$ENDIF}
{--------}
{-Converts a parent node and child relationship into a cursor}
function Csr(P : PNode; C : TChild) : TTreeCursor;
{$IFDEF Win32}
begin
  Result := TTreeCursor(longint(P) or Ord(C))
end;
{$ELSE}
inline($58/            {pop ax      get child}
       $25/$01/$00/    {and ax, 1   isolate child bit}
       $5B/            {pop bx      get offset}
       $09/$D8/        {or ax, bx   xfer child bit}
       $5A);           {pop dx      get seg/sel}
{$ENDIF}
{--------}
{-Sets the cursor's color bit to zero}
function Bleach(Cursor : TTreeCursor) : TTreeCursor;
{$IFDEF Win32}
begin
  Result := (Cursor and $FFFFFFFD);
end;
{$ELSE}
inline ($58/           {pop ax      get offset}
        $25/$FD/$FF/   {and ax, XX  set off color bit}
        $5A);          {pop dx      get seg/sel}
{$ENDIF}
{--------}
{-Sets the cursor's color bit to the same as a PKC link}
function Dye(Cursor, PKC : TTreeCursor) : TTreeCursor;
{$IFDEF Win32}
begin
  Result := (Cursor and $FFFFFFFD) or (PKC and $2);
end;
{$ELSE}
inline ($58/             {pop ax      get color word}
        $25/$02/$00/     {and ax, 2   isolate color bit}
        $5B/             {pop bx      toss next}
        $5B/             {pop bx      get offset}
        $81/$E3/$FD/$FF/ {and bx, XX  kill color}
        $09/$D8/         {or ax, bx   xfer color bit}
        $5A);            {pop dx      get seg/sel}
{$ENDIF}

{===TBinTree==========================================================
A simple binary tree.

A binary tree is a data structure where each node has up to two
children, and one parent. This implementation makes a distinction
between external nodes (that have no children at all) and internal
nodes (that always have two children). External nodes are called
leaves. The object uses external cursors to navigate the tree (these
are NOT the nodes themselves). You position a given cursor in the tree
by moving it with the object's methods, and can use a cursor to insert
and delete data objects in the tree (although there are restrictions
on where this can happen).

The object has two iterators, and four methods to traverse the tree
with them. The four traversal methods are pre-order, in-order,
post-order and level-order. Note that traversals can be done either by
recursive routines or a TStack will be used to unravel the recursion.
This choice is set via the UseRecursion property.
=====================================================================}
constructor TBinTree.Create(DataOwner : boolean);
begin
  acNodeSize := 16;
  inherited Create(DataOwner);

  btTravType := ttInOrder;
  btUseRecursion := true;

  btRt := acNewNode(nil);
  acCount := 0;
end;
{--------}
constructor TBinTree.Clone(Source : TAbstractContainer;
                           DataOwner : boolean;
                           NewCompare : TCompareFunc);
var
  OldTree : TBinTree absolute Source;
  NewData : pointer;
  {------}
  procedure CloneTreeRecurse(OldWalker, NewWalker : TTreeCursor);
  var
    Temp, NewTemp : TTreeCursor;
  begin
    NewData := nil;
    try
      Temp := OldTree.Left(OldWalker);
      if not OldTree.IsLeaf(Temp) then begin
        if DataOwner then
          NewData := DupData(OldTree.Examine(Temp))
        else
          NewData := OldTree.Examine(Temp);
        NewTemp := Left(NewWalker);
        Insert(NewTemp, NewData);
        NewData := nil;
        CloneTreeRecurse(Temp, NewTemp);
      end;
      Temp := OldTree.Right(OldWalker);
      if not OldTree.IsLeaf(Temp) then begin
        if DataOwner then
          NewData := DupData(OldTree.Examine(Temp))
        else
          NewData := OldTree.Examine(Temp);
        NewTemp := Right(NewWalker);
        Insert(NewTemp, NewData);
        NewData := nil;
        CloneTreeRecurse(Temp, NewTemp);
      end;
    finally
      if DataOwner and Assigned(NewData) then
        DisposeData(NewData);
    end;{try..finally}
  end;
  {------}
  procedure CloneTreeNoRecurse;
  var
    StackOld, StackNew : TStack;
    OldWalker, NewWalker : TTreeCursor;
    Temp, NewTemp : TTreeCursor;
  begin
    StackOld := nil;
    StackNew := nil;
    NewData := nil;
    try
      StackOld := TStack.Create(false);
      StackNew := TStack.Create(false);
      if DataOwner then
        NewData := DupData(OldTree.Examine(OldTree.Root))
      else
        NewData := OldTree.Examine(OldTree.Root);
      NewTemp := Root;
      Insert(NewTemp, NewData);
      NewData := nil;
      StackOld.Push(pointer(OldTree.Root));
      StackNew.Push(pointer(Root));
      repeat
        OldWalker := TTreeCursor(StackOld.Pop);
        NewWalker := TTreeCursor(StackNew.Pop);
        Temp := OldTree.Left(OldWalker);
        if not OldTree.IsLeaf(Temp) then begin
          if DataOwner then
            NewData := DupData(OldTree.Examine(Temp))
          else
            NewData := OldTree.Examine(Temp);
          NewTemp := Left(NewWalker);
          Insert(NewTemp, NewData);
          NewData := nil;
          StackOld.Push(pointer(Temp));
          StackNew.Push(pointer(NewTemp));
        end;
        Temp := OldTree.Right(OldWalker);
        if not OldTree.IsLeaf(Temp) then begin
          if DataOwner then
            NewData := DupData(OldTree.Examine(Temp))
          else
            NewData := OldTree.Examine(Temp);
          NewTemp := Right(NewWalker);
          Insert(NewTemp, NewData);
          NewData := nil;
          StackOld.Push(pointer(Temp));
          StackNew.Push(pointer(NewTemp));
        end;
      until StackOld.IsEmpty;
    finally
      StackOld.Free;
      StackNew.Free;
      if DataOwner and Assigned(NewData) then
        DisposeData(NewData);
    end;{try..finally}
  end;
  {------}
var
  NewTemp : TTreeCursor;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldTree.DupData;
  DisposeData := OldTree.DisposeData;

  if not (Source is TBinTree) then
    RaiseError(escBadSource);

  if OldTree.IsEmpty then Exit;

  try
    NewData := nil;
    if UseRecursion then begin
      if DataOwner then
        NewData := DupData(OldTree.Examine(OldTree.Root))
      else
        NewData := OldTree.Examine(OldTree.Root);
      NewTemp := Root;
      Insert(NewTemp, NewData);
      NewData := nil;
      CloneTreeRecurse(OldTree.Root, Root);
    end
    else
      CloneTreeNoRecurse;
  except
    if DataOwner and Assigned(NewData) then
      DisposeData(NewData);
    raise;
  end;{try..except}
end;
{--------}
procedure TBinTree.btInsertPrim(var Cursor : TTreeCursor; aNode : PNode);
begin
  aNode^.PKC := Cursor;
  Dad(Cursor)^.TLink[Kid(Cursor)] := aNode;
end;
{--------}
function TBinTree.Delete(Cursor : TTreeCursor) : TTreeCursor;
var
  NewKid,
  LeftKid,
  RightKid : TTreeCursor;
  NodeToGo,
  Node : PNode;
begin
  if IsLeaf(Cursor) then
    RaiseError(escDelInvalidHere);
  RightKid := Right(Cursor);
  LeftKid := Left(Cursor);
  if not IsLeaf(RightKid) then begin
    if not IsLeaf(LeftKid) then
      RaiseError(escDelInvalidHere);
    NewKid := RightKid
  end
  else
    NewKid := LeftKid;
  Result := Cursor;
  Node := GetNode(NewKid);
  NodeToGo := GetNode(Cursor);
  Dad(Cursor)^.TLink[Kid(Cursor)] := Node;
  if not IsLeaf(NewKid) then
    with Node^ do
      PKC := Dye(Cursor, PKC);
  acDisposeNode(NodeToGo);
end;
{--------}
procedure TBinTree.Empty;
  {------}
  procedure RecursePostOrder(Cursor : TTreeCursor);
  begin
    if not IsLeaf(Cursor) then begin
      RecursePostOrder(Left(Cursor));
      RecursePostOrder(Right(Cursor));
      if IsDataOwner then
        DisposeData(Examine(Cursor));
      acDisposeNode(GetNode(Cursor));
    end;
  end;
  {------}
const
  Sentinel = nil;
var
  Walker : PNode;
  Stack  : TStack;
begin
  if UseRecursion then begin
    if not IsEmpty then begin
      RecursePostOrder(Root);
      btRt^.TLink[CRight] := nil;
    end;
  end
  else {no recursion} begin
    if not IsEmpty then begin
      Stack := TStack.Create(false);
      try
        Stack.Push(btRt^.TLink[cRight]);
        repeat
          Walker := PNode(Stack.Examine);
          if (Walker = Sentinel) then begin
            Stack.Pop; {the sentinel}
            Walker := PNode(Stack.Pop);
            if IsDataOwner then
              DisposeData(Walker^.Data);
            acDisposeNode(Walker);
          end
          else begin
            Stack.Push(Sentinel);
            if (Walker^.TLink[cRight] <> nil) then
              Stack.Push(Walker^.TLink[cRight]);
            if (Walker^.TLink[cLeft] <> nil) then
              Stack.Push(Walker^.TLink[cLeft]);
          end;
        until (Stack.IsEmpty);
      finally
        Stack.Free;
      end;{try..finally}
      btRt^.TLink[CRight] := nil;
    end;
  end;
  if acInDone then
    if Assigned(btRt) then
      acDisposeNode(btRt);
end;
{--------}
function TBinTree.Erase(Cursor : TTreeCursor) : TTreeCursor;
begin
  if IsDataOwner then
    DisposeData(Examine(Cursor));
  Result := Delete(Cursor);
end;
{--------}
function TBinTree.Examine(Cursor : TTreeCursor) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsEmpty, ascEmptyExamine);
  EZAssert(not IsLeaf(Cursor), ascExamineLeaf);
  {$ENDIF}
  Result := GetNode(Cursor)^.Data;
end;
{--------}
procedure TBinTree.Insert(var Cursor : TTreeCursor; aData : pointer);
var
  Node : PNode;
begin
  if not IsLeaf(Cursor) then
    RaiseError(escInsInvalidHere);
  Node := acNewNode(aData);
  btInsertPrim(Cursor, Node);
end;
{--------}
function TBinTree.IsLeaf(Cursor : TTreeCursor) : boolean;
begin
  Result := GetNode(Cursor) = nil;
end;
{--------}
function TBinTree.IsRoot(Cursor : TTreeCursor) : boolean;
begin
  Result := Dad(Cursor) = btRt;
end;
{--------}
function TBinTree.Iterate(Action : TIterator; Backwards : boolean;
                           ExtraData : pointer) : TTreeCursor;
const
  Sentinel = nil;
  {------}
  function TraverseLevelOrder : TTreeCursor;
  var
    Finished : boolean;
    Walker   : PNode;
    Queue    : TQueue;
  begin
    TraverseLevelOrder := 0;
    Finished := false;
    Queue := TQueue.Create(false);
    try
      Queue.Append(btRt^.TLink[cRight]);
      repeat
        Walker := PNode(Queue.Pop);
        if not Action(Self, Walker^.Data, ExtraData) then begin
          TraverseLevelOrder := Bleach(Walker^.PKC);
          Finished := true;
        end
        else if Backwards then begin
          if (Walker^.TLink[cRight] <> nil) then
            Queue.Append(Walker^.TLink[cRight]);
          if (Walker^.TLink[cLeft] <> nil) then
            Queue.Append(Walker^.TLink[cLeft]);
        end
        else begin
          if (Walker^.TLink[cLeft] <> nil) then
            Queue.Append(Walker^.TLink[cLeft]);
          if (Walker^.TLink[cRight] <> nil) then
            Queue.Append(Walker^.TLink[cRight]);
        end;
      until Finished or Queue.IsEmpty;
    finally
      Queue.Free;
    end;{try..finally}
  end;
  {------}
  function TraversePreOrderRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then
      if not Action(Self, Examine(Walker), ExtraData) then
        Result := Walker
      else begin
        Result := TraversePreOrderRecurse(Left(Walker));
        if (Result = 0) then
          Result := TraversePreOrderRecurse(Right(Walker));
      end;
  end;
  {------}
  function TraverseInOrderRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then begin
      Result := TraverseInOrderRecurse(Left(Walker));
      if (Result = 0) then
        if not Action(Self, Examine(Walker), ExtraData) then
          Result := Walker
        else
          Result := TraverseInOrderRecurse(Right(Walker));
    end;
  end;
  {------}
  function TraversePostOrderRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then begin
      Result := TraversePostOrderRecurse(Left(Walker));
      if (Result = 0) then begin
        Result := TraversePostOrderRecurse(Right(Walker));
        if (Result = 0) then
          if not Action(Self, Examine(Walker), ExtraData) then
            Result := Walker;
      end;
    end;
  end;
  {------}
  function TraversePreOrderRevRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then
      if not Action(Self, Examine(Walker), ExtraData) then
        Result := Walker
      else begin
        Result := TraversePreOrderRevRecurse(Right(Walker));
        if (Result = 0) then
          Result := TraversePreOrderRevRecurse(Left(Walker));
      end;
  end;
  {------}
  function TraverseInOrderRevRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then begin
      Result := TraverseInOrderRevRecurse(Right(Walker));
      if (Result = 0) then
        if not Action(Self, Examine(Walker), ExtraData) then
          Result := Walker
        else
          Result := TraverseInOrderRevRecurse(Left(Walker));
    end;
  end;
  {------}
  function TraversePostOrderRevRecurse(Walker : TTreeCursor) : TTreeCursor;
  begin
    Result := 0;
    if not IsLeaf(Walker) then begin
      Result := TraversePostOrderRevRecurse(Right(Walker));
      if (Result = 0) then begin
        Result := TraversePostOrderRevRecurse(Left(Walker));
        if (Result = 0) then
          if not Action(Self, Examine(Walker), ExtraData) then
            Result := Walker;
      end;
    end;
  end;
  {------}
  function TraversePreOrderNoRecurse : TTreeCursor;
  var
    Walker   : PNode;
    Stack    : TStack;
    Finished : boolean;
  begin
    Result := 0;
    Finished := false;
    Stack := TStack.Create(false);
    try
      Stack.Push(btRt^.TLink[cRight]);
      repeat
        Walker := PNode(Stack.Pop);
        if not Action(Self, Walker^.Data, ExtraData) then begin
          Result := Bleach(Walker^.PKC);
          Finished := true;
        end
        else if Backwards then begin
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
        end
        else begin
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
        end;
      until Finished or Stack.IsEmpty;
    finally
      Stack.Free;
    end;{try..finally}
  end;
  {------}
  function TraverseInOrderNoRecurse : TTreeCursor;
  var
    Walker   : PNode;
    Stack    : TStack;
    Finished : boolean;
  begin
    Result := 0;
    Finished := false;
    Stack := TStack.Create(false);
    try
      Stack.Push(btRt^.TLink[cRight]);
      repeat
        Walker := PNode(Stack.Pop);
        if (Walker = Sentinel) then begin
          Walker := PNode(Stack.Pop);
          if not Action(Self, Walker^.Data, ExtraData) then begin
            Result := Bleach(Walker^.PKC);
            Finished := true;
          end;
        end
        else if Backwards then begin
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
          Stack.Push(Walker);
          Stack.Push(Sentinel);
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
        end
        else begin
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
          Stack.Push(Walker);
          Stack.Push(Sentinel);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
        end;
      until Finished or Stack.IsEmpty;
    finally
      Stack.Free;
    end;{try..finally}
  end;
  {------}
  function TraversePostOrderNoRecurse : TTreeCursor;
  var
    Walker   : PNode;
    Stack    : TStack;
    Finished : boolean;
  begin
    Result := 0;
    Finished := false;
    Stack := TStack.Create(false);
    try
      Stack.Push(btRt^.TLink[cRight]);
      repeat
        Walker := PNode(Stack.Examine);
        if (Walker = Sentinel) then begin
          Stack.Pop; {the sentinel}
          Walker := PNode(Stack.Pop);
          if not Action(Self, Walker^.Data, ExtraData) then begin
            Result := Bleach(Walker^.PKC);
            Finished := true;
          end;
        end
        else if Backwards then begin
          Stack.Push(Sentinel);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
        end
        else begin
          Stack.Push(Sentinel);
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
        end;
      until Finished or Stack.IsEmpty;
    finally
      Stack.Free;
    end;{try..finally}
  end;
  {------}
begin
  if IsEmpty then
    Result := 0
  else if (btTravType = ttLevelOrder) then
    Result := TraverseLevelOrder
  else {non-empty & pre-, in- or post-order traversal} begin
    if UseRecursion then begin
      if Backwards then
        case btTravType of
          ttPreOrder   : Result := TraversePreOrderRevRecurse(Root);
          ttInOrder    : Result := TraverseInOrderRevRecurse(Root);
          ttPostOrder  : Result := TraversePostOrderRevRecurse(Root);
        else
          Result := 0;
          RaiseError(escBadCaseSwitch);
        end {case}
      else
        case btTravType of
          ttPreOrder   : Result := TraversePreOrderRecurse(Root);
          ttInOrder    : Result := TraverseInOrderRecurse(Root);
          ttPostOrder  : Result := TraversePostOrderRecurse(Root);
        else
          Result := 0;
          RaiseError(escBadCaseSwitch);
        end;{case}
    end
    else {no recursion} begin
      case btTravType of
        ttPreOrder   : Result := TraversePreOrderNoRecurse;
        ttInOrder    : Result := TraverseInOrderNoRecurse;
        ttPostOrder  : Result := TraversePostOrderNoRecurse;
      else
        Result := 0;
        RaiseError(escBadCaseSwitch);
      end;{case}
    end;
  end;
end;
{--------}
procedure TBinTree.Join(Cursor : TTreeCursor; Tree : TBinTree);
var
  RootNode : PNode;
begin
  if not IsLeaf(Cursor) then
    RaiseError(escInsInvalidHere);
  if Assigned(Tree) then begin
    if not Tree.IsEmpty then begin
      RootNode := GetNode(Tree.Root);
      RootNode^.PKC := Cursor;
      Dad(Cursor)^.TLink[Kid(Cursor)] := RootNode;
      inc(acCount, Tree.Count);
      {patch up Tree}
      with Tree do begin
        btRt^.TLink[CRight] := nil;
        acCount := 0;
      end;
    end;
    Tree.Free;
  end;
end;
{--------}
function TBinTree.Left(Cursor : TTreeCursor) : TTreeCursor;
begin
  if IsLeaf(Cursor) then
    RaiseError(escCannotMoveHere);
  Result := Csr(GetNode(Cursor), CLeft);
end;
{--------}
function TBinTree.Parent(Cursor : TTreeCursor) : TTreeCursor;
begin
  if IsRoot(Cursor) then
    RaiseError(escCannotMoveHere);
  Result := Bleach(Dad(Cursor)^.PKC);
end;
{--------}
function TBinTree.Replace(Cursor : TTreeCursor; aData : pointer) : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsLeaf(Cursor), ascExamineLeaf);
  {$ENDIF}
  with GetNode(Cursor)^ do begin
     Result := Data;
     Data := aData;
   end;
end;
{--------}
function TBinTree.Right(Cursor : TTreeCursor) : TTreeCursor;
begin
  if IsLeaf(Cursor) then
    RaiseError(escCannotMoveHere);
  Result := Csr(GetNode(Cursor), CRight);
end;
{--------}
function TBinTree.Root : TTreeCursor;
begin
  Result := Csr(btRt, CRight);
end;
{--------}
function TBinTree.Search(var Cursor : TTreeCursor; aData : pointer) : boolean;
  {------}
  function RecursePreOrder(Walker : TTreeCursor) : boolean;
  begin
    if IsLeaf(Walker) then
      RecursePreOrder := false
    else if (Compare(Examine(Walker), aData) = 0) then begin
      RecursePreOrder := true;
      Cursor := Walker;
    end
    else if RecursePreOrder(Left(Walker)) then
      RecursePreOrder := true
    else
      RecursePreOrder := RecursePreOrder(Right(Walker));
  end;
  {------}
var
  Walker: PNode;
  Stack : TStack;
  FoundIt : boolean;
begin
  if UseRecursion then begin
    Result := RecursePreOrder(Root);
  end
  else {no recursion} begin
    FoundIt := false;
    Stack := TStack.Create(false);
    try
      Stack.Push(btRt^.TLink[cRight]);
      repeat
        Walker := PNode(Stack.Pop);
        if (Compare(Walker^.Data, aData) = 0) then begin
          FoundIt := true;
          Cursor := Bleach(Walker^.PKC);
        end
        else begin
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
        end;
      until FoundIt or Stack.IsEmpty;
    finally
      Stack.Free;
    end;{try..finally}
    Result := FoundIt;
  end;
end;
{====================================================================}


{-An iterator for cloning a binary search tree}
function BSTreeCloneData(C : TAbstractContainer;
                         aData : pointer;
                         ExtraData : pointer) : boolean; far;
var
  NewTree : TBinTree absolute ExtraData;
  DummyCursor : TTreeCursor;
  NewData : pointer;
begin
  Result := true;
  with NewTree do begin
    if IsDataOwner then
      NewData := DupData(aData)
    else
      NewData := aData;
    try
      Insert(DummyCursor, NewData);
    except
      if IsDataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;

{-An iterator for joining a binary search tree}
function BSTreeJoinData(C : TAbstractContainer;
                        aData : pointer;
                        ExtraData : pointer) : boolean; far;
var
  OurTree : TBinSearchTree absolute ExtraData;
  DummyCursor : TTreeCursor;
begin
  Result := true;
  OurTree.Insert(DummyCursor, aData);
end;


{===TBinSearchTree====================================================
A binary search tree

A sorted binary tree where for any given data object, all data objects
in its left subtree are less than it, and all data objects in the
right subtree are greater than it. This ordering relies on the Compare
method to be overridden.
=====================================================================}
constructor TBinSearchTree.Create(DataOwner : boolean);
begin
  inherited Create(DataOwner);
  acIsSorted := true;
end;
{--------}
constructor TBinSearchTree.Clone(Source : TAbstractContainer;
                                 DataOwner : boolean;
                                 NewCompare : TCompareFunc);
var
  OldTree : TBinSearchTree absolute Source;
  SaveTravType : TTraversalType;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldTree.DupData;
  DisposeData := OldTree.DisposeData;

  if not (Source is TBinTree) then
    RaiseError(escBadSource);

  if OldTree.IsEmpty then Exit;

  SaveTravType := OldTree.TraversalType;
  OldTree.TraversalType := ttPostOrder;
  try
    OldTree.Iterate(BSTreeCloneData, false, Self);
  finally
    OldTree.TraversalType := SaveTravType;
  end;{try..finally}
end;
{--------}
procedure TBinSearchTree.acSort;
var
  OldRoot : PNode;
begin
  {Note: when this routine is called, the Compare method will have
         been replaced, and we have to 'sort' the tree}
  {detach the old tree from the object}
  OldRoot := btRt;
  {create a new root}
  btRt := acNewNode(nil);
  btRt^.TLink[CLeft] := btRt;
  btRt^.TLink[CRight] := nil;
  acCount := 0;
  {traverse the old tree and append the data to the new root}
  bsSortTraverse(OldRoot^.TLink[CRight]);
  {destroy the old root (increment the count afterwards, since the
   dispose-a-node routine will decrement it)}
  acDisposeNode(OldRoot);
  inc(acCount);
end;
{--------}
procedure TBinSearchTree.bsSortTraverse(aNode : PNode);
const
  Sentinel = nil;
var
  Walker : PNode;
  Stack  : TStack;
  Cursor : TTreeCursor;
begin
  if UseRecursion then begin
    if (aNode <> nil) then begin
      {traverse the left subtree}
      bsSortTraverse(aNode^.TLink[cLeft]);
      {traverse the right subtree}
      bsSortTraverse(aNode^.TLink[cRight]);
      {pretend we've just created this node and insert it}
      if Search(Cursor, aNode^.Data) then
        RaiseError(escInsertDup);
      inc(acCount);
      aNode^.TLink[cLeft] := nil;
      aNode^.TLink[cRight] := nil;
      btInsertPrim(Cursor, aNode);
    end;
  end
  else {no recursion} begin
    Stack := TStack.Create(false);
    try
      Stack.Push(aNode);
      repeat
        Walker := PNode(Stack.Examine);
        if (Walker = Sentinel) then begin
          Stack.Pop; {the sentinel}
          Walker := PNode(Stack.Pop); {the node}
          {pretend we've just created this node and insert it}
          if Search(Cursor, Walker^.Data) then
            RaiseError(escInsertDup);
          inc(acCount);
          Walker^.TLink[cLeft] := nil;
          Walker^.TLink[cRight] := nil;
          btInsertPrim(Cursor, Walker);
        end
        else begin
          Stack.Push(Sentinel);
          if (Walker^.TLink[cRight] <> nil) then
            Stack.Push(Walker^.TLink[cRight]);
          if (Walker^.TLink[cLeft] <> nil) then
            Stack.Push(Walker^.TLink[cLeft]);
        end;
      until (Stack.IsEmpty);
    finally
      Stack.Free;
    end;{try..finally}
  end;
end;
{--------}
procedure TBinSearchTree.bsSwapData(OldCursor, NewCursor : TTreeCursor);
var
  Data : pointer;
begin
  Data := GetNode(OldCursor)^.Data;
  GetNode(OldCursor)^.Data := GetNode(NewCursor)^.Data;
  GetNode(NewCursor)^.Data := Data;
end;
{--------}
function TBinSearchTree.Delete (Cursor : TTreeCursor) : TTreeCursor;
var
  Walker,
  LeftChild : TTreeCursor;
begin
  if IsLeaf(Cursor) then
    RaiseError(escDelInvalidHere);
  if IsLeaf(Left(Cursor)) or IsLeaf(Right(Cursor)) then
    Result := inherited Delete(Cursor)
  else {both children exist} begin
    Walker := Right(Cursor);
    LeftChild := Left(Walker);
    while not IsLeaf(LeftChild) do begin
      Walker := LeftChild;
      LeftChild := Left(Walker);
    end;
    bsSwapData(Cursor, Walker);
    Result := inherited Delete(Walker);
  end;
end;
{--------}
procedure TBinSearchTree.Insert(var Cursor : TTreeCursor; aData : pointer);
begin
  if Search(Cursor, aData) then
    RaiseError(escInsertDup);
  inherited Insert(Cursor, aData);
end;
{--------}
procedure TBinSearchTree.Join(Cursor : TTreeCursor; Tree : TBinTree);
begin
  if Assigned(Tree) then
    with Tree do begin
      TraversalType := ttPostOrder;
      Iterate(BSTreeJoinData, false, Self);
      acIsDataOwner := false;
      Free;
    end;
end;
{--------}
function TBinSearchTree.Replace(Cursor : TTreeCursor; aData : pointer) : pointer;
begin
  Result := Examine(Cursor);
  Delete(Cursor);
  Insert(Cursor, aData);
end;
{--------}
function TBinSearchTree.Search(var Cursor : TTreeCursor; aData : pointer) : boolean;
var
  CompResult : integer;
  Walker     : TTreeCursor;
begin
  Walker := Root;
  if IsLeaf(Walker) then
    Result := false
  else begin
    CompResult := Compare(aData, Examine(Walker));
    if (CompResult < 0) then
      Walker := Left(Walker)
    else if (CompResult > 0) then
      Walker := Right(Walker);
    while (not IsLeaf(Walker)) and (CompResult <> 0) do begin
      CompResult := Compare(aData, Examine(Walker));
      if (CompResult < 0) then
        Walker := Left(Walker)
      else if (CompResult > 0) then
        Walker := Right(Walker);
    end;
    Result := (CompResult = 0);
  end;
  Cursor := Walker;
end;
{====================================================================}

{$IFNDEF Win32}
type
  LH = record L, H : word; end;
{$ENDIF}

{===Red-black tree helper routines====================================
These routines help out the red-black tree methods. ColorBlack colors
the cursor black, ColorRed colors the cursor red. IsBlack returns true
if the cursor is black, whereas IsRed returns true if is red.
18Jun95 JMB
=====================================================================}
procedure ColorBlack(Cursor : TTreeCursor);
{$IFDEF Win32}
begin
  with GetNode(Cursor)^ do
    PKC := PKC and $FFFFFFFD;
end;
{$ELSE}
near;
begin
  with GetNode(Cursor)^ do
    LH(PKC).L := LH(PKC).L and $FFFD;
end;
{$ENDIF}
{--------}
function IsBlack(Cursor : TTreeCursor) : boolean;
{$IFDEF Win32}
var
  Temp : PNode;
begin
  Temp := GetNode(Cursor);
  if Assigned(Temp) then
    IsBlack := (Temp^.PKC and 2) = 0
  else
    IsBlack := true;
end;
{$ELSE}
near;
var
  Temp : PNode;
begin
  Temp := GetNode(Cursor);
  if Assigned(Temp) then
    IsBlack := (LH(Temp^.PKC).L and 2) = 0
  else
    IsBlack := true;
end;
{$ENDIF}
{--------}
procedure ColorRed(Cursor : TTreeCursor);
{$IFDEF Win32}
begin
  with GetNode(Cursor)^ do
    PKC := PKC or 2;
end;
{$ELSE}
near;
begin
  with GetNode(Cursor)^ do
    LH(PKC).L := LH(PKC).L or 2;
end;
{$ENDIF}
{--------}
function IsRed(Cursor : TTreeCursor) : boolean;
{$IFDEF Win32}
var
  Temp : PNode;
begin
  Temp := GetNode(Cursor);
  if Assigned(Temp) then
    IsRed := (Temp^.PKC and 2) <> 0
  else
    IsRed := false;
end;
{$ELSE}
near;
var
  Temp : PNode;
begin
  Temp := GetNode(Cursor);
  if Assigned(Temp) then
    IsRed := (LH(Temp^.PKC).L and 2) <> 0
  else
    IsRed := false;
end;
{$ENDIF}

{===TrbSearchTree=====================================================
A red-black binary search tree

A red-black tree is a binary search tree with inbuilt balancing
algorithms during Insert and Delete. This ensures that the tree does
not degenerate into a sorted linked list, maintaining its excellent
search times.

The tree is called red-black because certain data objects are labelled
Black and the others Red such that (1) every Red data object (that is
not at the root) has a Black parent, (2) each path from leaf to root
has the same number of Black data objects, and (3) each leaf is Black.
This set of rules ensures that the tree is (quite) balanced.

References
  Sedgewick: Algorithms
  Wood: Data Structures, Algorithms, and Performance

PS. I also apologise for the unpolitically correct terminology in this
source code! Thank you, Bryan, for pointing it out, but it's too late
now...
=====================================================================}
procedure TrbSearchTree.bsSwapData(OldCursor, NewCursor : TTreeCursor);
begin
  rbDeletedNodeWasBlack := IsBlack(NewCursor);
  inherited bsSwapData(OldCursor, NewCursor);
end;
{--------}
procedure TrbSearchTree.btInsertPrim(var Cursor : TTreeCursor; aNode : PNode);
var
  Pa, GrandPa, Uncle : TTreeCursor;
  Balanced : boolean;
begin
  inherited btInsertPrim(Cursor, aNode);
  ColorRed(Cursor);
  repeat
    Balanced := true;
    if not IsRoot(Cursor) then begin
      Pa := Parent(Cursor);
      if IsRed(Pa) then begin
        if IsRoot(Pa) then
          ColorBlack(Pa)
        else {Pa is not a root} begin
          GrandPa := Parent(Pa);
          ColorRed(GrandPa);
          if (Kid(Pa) = CLeft) then
            Uncle := Right(GrandPa)
          else
            Uncle := Left(GrandPa);
          if IsRed(Uncle) then begin
            ColorBlack(Pa);
            ColorBlack(Uncle);
            Cursor := GrandPa;
            Balanced := false;
          end
          else {Uncle is black} begin
            if (Kid(Cursor) = Kid(Pa)) then begin
              ColorBlack(Pa);
              rbPromote(Pa); {discard result}
            end
            else begin
              ColorBlack(Cursor);
              Cursor := rbPromote(rbPromote(Cursor));
            end;
          end;
        end;
      end;
    end;
  until Balanced;
end;
{--------}
function TrbSearchTree.Delete(Cursor : TTreeCursor) : TTreeCursor;
var
  Pa, Brother, Nephew1, Nephew2 : TTreeCursor;
  Balanced : boolean;
begin
  rbDeletedNodeWasBlack := IsBlack(Cursor);
  Cursor := inherited Delete(Cursor);
  Result := Cursor;
  repeat
    Balanced := true;
    if rbDeletedNodeWasBlack then begin
      if IsRed(Cursor) then
        ColorBlack(Cursor)
      else if not IsRoot(Cursor) then begin
        Pa := Parent(Cursor);
        if (Kid(Cursor) = CLeft) then
          Brother := Right(Pa)
        else
          Brother := Left(Pa);
        if IsRed(Brother) then begin
          if IsBlack(Pa) then
            ColorBlack(Brother);
          ColorRed(Pa);
          Brother := rbPromote(Brother);
          if (Kid(Cursor) = CLeft) then
            Cursor := Left(Left(Brother))
          else
            Cursor := Right(Right(Brother));
          Balanced := false;
        end
        else {Brother is black} begin
          if (Kid(Cursor) = CLeft) then
            Nephew1 := Right(Brother)
          else
            Nephew1 := Left(Brother);
          if IsRed(Nephew1) then begin
            ColorBlack(Nephew1);
            if IsRed(Pa) then
              ColorRed(Brother);
            ColorBlack(Pa);
            rbPromote(Brother); {discard result}
          end
          else {Nephew1 is black} begin
            if (Kid(Cursor) = CLeft) then
              Nephew2 := Left(Brother)
            else
              Nephew2 := Right(Brother);
            if IsRed(Nephew2) then begin
              if IsBlack(Pa) then
                ColorBlack(Nephew2);
              ColorBlack(Pa);
              rbPromote(rbPromote(Nephew2)); {discard result}
            end
            else {Nephew2 is black} begin
              if IsRed(Pa) then begin
                ColorBlack(Pa);
                ColorRed(Brother);
              end
              else {Pa is black} begin
                ColorRed(Brother);
                Cursor := Pa;
                Balanced := false;
              end;
            end;
          end;
        end;
      end;
    end;
  until Balanced;
end;
{--------}
function TrbSearchTree.rbPromote(Cursor : TTreeCursor) : TTreeCursor;
var
  NodeX,
  NodeP,
  XSon  : PNode;
begin
  NodeX := GetNode(Cursor);
  NodeP := Dad(Cursor);

  with NodeP^ do begin
    Dad(PKC)^.TLink[Kid(PKC)] := NodeX;
    NodeX^.PKC := Dye(PKC, NodeX^.PKC);
  end;

  if (Kid(Cursor) = CLeft) then begin
    XSon := NodeX^.TLink[CRight];
    NodeX^.TLink[CRight] := NodeP;
    NodeP^.PKC := Dye(Csr(NodeX, CRight), NodeP^.PKC);
    NodeP^.TLink[CLeft] := XSon;
    if (XSon <> nil) then
      XSon^.PKC := Dye(Cursor, XSon^.PKC);
  end
  else begin
    XSon := NodeX^.TLink[CLeft];
    NodeX^.TLink[CLeft] := NodeP;
    NodeP^.PKC := Dye(Csr(NodeX, CLeft), NodeP^.PKC);
    NodeP^.TLink[CRight] := XSon;
    if (XSon <> nil) then
      XSon^.PKC := Dye(Cursor, XSon^.PKC);
  end;

  Result := Bleach(NodeX^.PKC);
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeBinTree===============================================}
constructor TThreadsafeBinTree.Create(aDataOwner : boolean);
begin
  inherited Create;
  btResLock := TezResourceLock.Create;
  btBinTree := TBinTree.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeBinTree.Destroy;
begin
  btBinTree.Free;
  btResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeBinTree.AcquireAccess : TBinTree;
begin
  btResLock.Lock;
  Result := btBinTree;
end;
{--------}
procedure TThreadsafeBinTree.ReleaseAccess;
begin
  btResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


{$IFDEF Win32}
{===TThreadsafeBinSearchTree=========================================}
constructor TThreadsafeBinSearchTree.Create(aDataOwner : boolean);
begin
  inherited Create;
  bstResLock := TezResourceLock.Create;
  bstBinSearchTree := TBinSearchTree.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeBinSearchTree.Destroy;
begin
  bstBinSearchTree.Free;
  bstResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeBinSearchTree.AcquireAccess : TBinSearchTree;
begin
  bstResLock.Lock;
  Result := bstBinSearchTree;
end;
{--------}
procedure TThreadsafeBinSearchTree.ReleaseAccess;
begin
  bstResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


{$IFDEF Win32}
{===TThreadsaferbSearchTree==========================================}
constructor TThreadsaferbSearchTree.Create(aDataOwner : boolean);
begin
  inherited Create;
  rbstResLock := TezResourceLock.Create;
  rbstrbSearchTree := TrbSearchTree.Create(aDataOwner);
end;
{--------}
destructor TThreadsaferbSearchTree.Destroy;
begin
  rbstrbSearchTree.Free;
  rbstResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsaferbSearchTree.AcquireAccess : TrbSearchTree;
begin
  rbstResLock.Lock;
  Result := rbstrbSearchTree;
end;
{--------}
procedure TThreadsaferbSearchTree.ReleaseAccess;
begin
  rbstResLock.Unlock;
end;
{====================================================================}
{$ENDIF}

end.
