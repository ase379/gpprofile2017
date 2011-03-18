{===EZDSLPQU==========================================================

Part of the Delphi Structures Library--the priority queue.

EZDSLPQU is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLPQu;

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
  TPriorityQueue = class(TAbstractContainer)
    {-Priority queue object}
    private
      pqRt : PNode;

    protected
      procedure acSort; override;

      procedure pqAppendPrim(aNode : PNode);
      procedure pqBubbleUp(Node : PNode);
      function pqGetNodeFromIndex(Inx : longint) : PNode;
      procedure pqSortTraverse(aNode : PNode);
      procedure pqTrickleDown(Node : PNode);

    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      procedure Append(aData : pointer);
      procedure Empty; override;
      function Examine : pointer;
      function Pop : pointer;
      function Replace(aData : pointer) : pointer;
  end;

{$IFDEF Win32}
type
  TThreadsafePriorityQueue = class
    protected {private}
      pqPriorityQueue : TPriorityQueue;
      pqResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TPriorityQueue;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{===TPriorityQueue====================================================
A priority queue

Much like an ordinary queue, expect that the smallest data object in
the queue is popped first. Another name for a priority queue is a
heap.

If the Compare method returns values in the 'normal' sense (ie -1 if
Data1 < Data2, etc), then data objects will be popped off smallest
first, ie in increasing order. If Compare returns values in the
'reverse' sense (ie -1 if Data1 > Data2, etc), then elements will be
popped off largest first, ie in decreasing order. Thus by carefully
selecting Compare, this object will provide a min-heap and a max-heap.
=====================================================================}
constructor TPriorityQueue.Create(DataOwner : boolean);
begin
  acNodeSize := 16;
  inherited Create(DataOwner);
  pqRt := acNewNode(nil);
  pqRt^.TLink[CLeft] := pqRt;
  pqRt^.TLink[CRight] := nil;
  acCount := 0;
  acIsSorted := true;
end;
{--------}
constructor TPriorityQueue.Clone(Source : TAbstractContainer;
                                 DataOwner : boolean;
                                 NewCompare : TCompareFunc);
var
  OldQueue : TPriorityQueue absolute Source;
  NodeInx  : longint;
  NewData  : pointer;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldQueue.DupData;
  DisposeData := OldQueue.DisposeData;

  if not (Source is TPriorityQueue) then
    RaiseError(escBadSource);

  if OldQueue.IsEmpty then Exit;

  for NodeInx := 1 to OldQueue.Count do begin
    if DataOwner then
      NewData := DupData(OldQueue.pqGetNodeFromIndex(NodeInx)^.Data)
    else
      NewData := OldQueue.pqGetNodeFromIndex(NodeInx)^.Data;
    try
      Append(NewData);
    except
      if DataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;
{--------}
procedure TPriorityQueue.acSort;
var
  OldRoot : PNode;
begin
  {Note: when this routine is called, the Compare method will have
         been replaced, and we have to 'sort' the queue}
  {detach the old tree from the priority queue}
  OldRoot := pqRt;
  {create a new root}
  pqRt := acNewNode(nil);
  pqRt^.TLink[CLeft] := pqRt;
  pqRt^.TLink[CRight] := nil;
  acCount := 0;
  {traverse the old tree and append the data to the new root}
  pqSortTraverse(OldRoot^.TLink[CRight]);
  {destroy the old root (increment the count afterwards, since the
   dispose-a-node routine will decrement it)}
  acDisposeNode(OldRoot);
  inc(acCount);
end;
{--------}
procedure TPriorityQueue.Append(aData : pointer);
var
  Node : PNode;
begin
  Node := acNewNode(aData);
  pqAppendPrim(Node);
end;
{--------}
procedure TPriorityQueue.Empty;
begin
  if IsDataOwner then begin
    while not IsEmpty do
      DisposeData(Pop)
  end
  else begin
    while not IsEmpty do
      Pop;
  end;
  if acInDone then
    if Assigned(pqRt) then
      acDisposeNode(pqRt);
end;
{--------}
function TPriorityQueue.Examine : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsEmpty, ascEmptyExamine);
  {$ENDIF}
  Result := pqRt^.TLink[CRight]^.Data;
end;
{--------}
function TPriorityQueue.Pop : pointer;
var
  Root,
  LastNode : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsEmpty, ascEmptyPop);
  {$ENDIF}
  Root := pqRt^.TLink[CRight];
  LastNode := pqGetNodeFromIndex(Count);
  Result := Root^.Data;
  Root^.Data := LastNode^.Data;
  with LastNode^.PLink^ do begin
    if Odd(Count) then
      TLink[CRight] := nil
    else
      TLink[CLeft] := nil;
  end;
  acDisposeNode(LastNode);
  if not IsEmpty then
    pqTrickleDown(Root);
end;
{--------}
procedure TPriorityQueue.pqAppendPrim(aNode : PNode);
var
  NewParent : PNode;
begin
  if (Count = 1) then
    NewParent := pqRt
  else
    NewParent := pqGetNodeFromIndex(Count shr 1);
  with NewParent^ do
    if Odd(Count) then
      TLink[CRight] := aNode
    else
      TLink[CLeft] := aNode;
  aNode^.PLink := NewParent;
  pqBubbleUp(aNode);
end;
{--------}
procedure TPriorityQueue.pqBubbleUp(Node : PNode);
var
  AllDone : boolean;
  OurData : pointer;
begin
  AllDone := false;
  OurData := Node^.Data;
  repeat
    with Node^ do begin
      {If our parent is 'larger' than we are, swap data and move up}
      if (PLink <> pqRt) and (Compare(PLink^.Data, OurData) > 0) then begin
        Node^.Data := PLink^.Data;
        Node := PLink;
      end
      else
        AllDone := true;
    end;
  until AllDone;
  Node^.Data := OurData;
end;
{--------}
function TPriorityQueue.pqGetNodeFromIndex(Inx : longint) : PNode;
{$IFNDEF Win32}
type
  LH = record L, H : word; end;
{$ENDIF}
var
  Temp : PNode;
  {$IFNDEF Win32}
  Mask : longint;
  {$ENDIF}
begin
  {$IFDEF DEBUG}
  EZAssert((0 < Inx) and (Inx <= Count), ascOutOfRange);
  {$ENDIF}
  Temp := pqRt;
  {$IFDEF Win32}
    asm
      mov eax, $40000000
      mov ecx, Inx
      mov edx, Temp
      jmp @@StartTest

    @@Again:
      shr eax, 1
    @@StartTest:
      test eax, ecx
      jz @@Again

    {The first walk is always right}
    @@WalkRight:
      mov edx, [edx].TNode.BLink  {BLink is equivalent to TLink[CRight]}

    @@TestForAnotherWalk:
      shr eax, 1
      jz @@AllDone
      test eax, ecx
      jnz @@WalkRight

    @@WalkLeft:
      mov edx, [edx].TNode.FLink  {FLink is equivalent to TLink[CLeft]}
      jmp @@TestForAnotherWalk

    @@AllDone:
      mov Temp, edx
    end;
  {$ELSE}
  if (LH(Inx).H = 0) then
    asm
      mov ax, $8000
      mov bx, Inx.Word[0]
      les di, Temp
      jmp @@StartTest

    @@Again:
      shr ax, 1
    @@StartTest:
      test ax, bx
      jz @@Again

    {The first walk is always right}
    @@WalkRight:
      les di, es:[di].TNode.BLink  {BLink is equivalent to TLink[CRight]}

    @@TestForAnotherWalk:
      shr ax, 1
      jz @@AllDone
      test ax, bx
      jnz @@WalkRight

    @@WalkLeft:
      les di, es:[di].TNode.FLink  {FLink is equivalent to TLink[CLeft]}
      jmp @@TestForAnotherWalk

    @@AllDone:
      mov Temp.Word[0], di
      mov Temp.Word[2], es
    end
  else
    begin
      {find first bit in Inx}
      Mask := $40000000;
      while ((Mask and Inx) = 0) do
        Mask := Mask shr 1;
      {walk the tree:
       if the next bit in Inx is zero go left, otherwise right }
      while (Mask <> 0) do begin
        if ((Mask and Inx) = 0) then
          Temp := Temp^.TLink[CLeft]
        else
          Temp := Temp^.TLink[CRight];
        Mask := Mask shr 1;
      end;
    end;
  {$ENDIF}
  Result := Temp;
end;
{--------}
procedure TPriorityQueue.pqSortTraverse(aNode : PNode);
begin
  {Note: this is a recursive routine. It is safe to use because the
         priority queue structure is very balanced, hence the
         recursion won't be that bad}
  if (aNode <> nil) then begin
    {traverse the left subtree}
    pqSortTraverse(aNode^.TLink[cLeft]);
    {traverse the right subtree}
    pqSortTraverse(aNode^.TLink[cRight]);
    {pretend we've just created this node and append it}
    inc(acCount);
    aNode^.TLink[cLeft] := nil;
    aNode^.TLink[cRight] := nil;
    pqAppendPrim(aNode);
  end;
end;
{--------}
procedure TPriorityQueue.pqTrickleDown(Node : PNode);
var
  Temp : PNode;
  AllDone : boolean;
  OurData : pointer;
begin
  if not Assigned(Node^.TLink[CLeft]) then Exit;
  AllDone := false;
  OurData := Node^.Data;
  repeat
    with Node^ do begin
      {Find our 'smaller' child}
      if (not Assigned(TLink[CRight])) or
         (Compare(TLink[CLeft]^.Data, TLink[CRight]^.Data) < 0) then
        Temp := TLink[CLeft]
      else
        Temp := TLink[CRight];
      {If our 'smaller' child is smaller than we are, swap the data,
       and move down}
      if (Compare(Temp^.Data, OurData) < 0) then begin
        Node^.Data := Temp^.Data;
        Node := Temp;
      end
      else
        AllDone := true;
    end;
  until AllDone or (not Assigned(Node^.TLink[CLeft]));
  Node^.Data := OurData;
end;
{--------}
function TPriorityQueue.Replace(aData : pointer) : pointer;
begin
  pqRt^.Data := aData;
  pqTrickleDown(pqRt);
  Result := pqRt^.Data;
  pqRt^.Data := nil;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafePriorityQueue=========================================}
constructor TThreadsafePriorityQueue.Create(aDataOwner : boolean);
begin
  inherited Create;
  pqResLock := TezResourceLock.Create;
  pqPriorityQueue := TPriorityQueue.Create(aDataOwner);
end;
{--------}
destructor TThreadsafePriorityQueue.Destroy;
begin
  pqPriorityQueue.Free;
  pqResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafePriorityQueue.AcquireAccess : TPriorityQueue;
begin
  pqResLock.Lock;
  Result := pqPriorityQueue;
end;
{--------}
procedure TThreadsafePriorityQueue.ReleaseAccess;
begin
  pqResLock.Unlock;
end;
{====================================================================}
{$ENDIF}

end.
