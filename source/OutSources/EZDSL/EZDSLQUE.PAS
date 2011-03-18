{===EZDSLQUE==========================================================

Part of the Delphi Structures Library--the queue and deque.

EZDSLQUE is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Major new version, release for Delphi 3
13Mar96 JMB 2.00 release for Delphi 2.0
18Jun95 JMB 1.00 conversion of EZStrucs to Delphi
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLQue;

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
  TQueue = class(TAbstractContainer)
    {-Queue object}
    private
      qHead, qTail : PNode;

    public
      constructor Create(DataOwner : boolean); override;
      constructor Clone(Source     : TAbstractContainer;
                        DataOwner  : boolean;
                        NewCompare : TCompareFunc); override;

      procedure Append(aData : pointer);
      procedure Empty; override;
      function Examine : pointer;
      function Pop : pointer;
  end;

  TDeque = class(TQueue)
    {-Deque object}
    public
      procedure Push(aData : pointer);
  end;

{$IFDEF Win32}
type
  TThreadsafeQueue = class
    protected {private}
      qQueue : TQueue;
      qResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TQueue;
      procedure ReleaseAccess;
  end;

  TThreadsafeDeque = class
    protected {private}
      qDeque : TDeque;
      qResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : TDeque;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation


{===TQueue===========================================================}
constructor TQueue.Create(DataOwner : boolean);
begin
  acNodeSize := 8;
  inherited Create(DataOwner);
  qHead := acNewNode(nil);
  qHead^.Link := qHead;
  qTail := qHead;
  acCount := 0;
end;
{--------}
constructor TQueue.Clone(Source     : TAbstractContainer;
                         DataOwner  : boolean;
                         NewCompare : TCompareFunc);
var
  Node     : PNode;
  OldQueue : TQueue absolute Source;
  NewData  : pointer;
begin
  Create(DataOwner);
  Compare := NewCompare;
  DupData := OldQueue.DupData;
  DisposeData := OldQueue.DisposeData;

  if not (Source is TQueue) then
    RaiseError(escBadSource);

  if OldQueue.IsEmpty then Exit;

  Node := OldQueue.qHead^.Link;
  while (Node <> OldQueue.qHead) do begin
    if DataOwner then
      NewData := DupData(Node^.Data)
    else
      NewData := Node^.Data;
    try
      Append(NewData);
      Node := Node^.Link;
    except
      if DataOwner and Assigned(NewData) then
        DisposeData(NewData);
      raise;
    end;{try..except}
  end;
end;
{--------}
procedure TQueue.Append(aData : pointer);
var
  Node : PNode;
begin
  Node := acNewNode(aData);
  with qTail^ do begin
    Node^.Link := Link;
    Link := Node;
  end;
  qTail := Node;
end;
{--------}
procedure TQueue.Empty;
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
    if Assigned(qHead) then
      acDisposeNode(qHead);
end;
{--------}
function TQueue.Examine : pointer;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsEmpty, ascEmptyExamine);
  {$ENDIF}
  Result := qHead^.Link^.Data;
end;
{--------}
function TQueue.Pop : pointer;
var
  Node : PNode;
begin
  {$IFDEF DEBUG}
  EZAssert(not IsEmpty, ascEmptyPop);
  {$ENDIF}
  Node := qHead^.Link;
  qHead^.Link := Node^.Link;
  Result := Node^.Data;
  acDisposeNode(Node);
  if (acCount = 0) then
    qTail := qHead;
end;
{---------------------------------------------------------------------}


{===TDeque============================================================
A output restricted deque object.

This type of deque allows queue jumpers, ie data objects can also be
pushed into the front of the queue, giving it stack-like behaviour. It
is descended from the basic queue and inherits Pop and Append.
=====================================================================}
procedure TDeque.Push(aData : pointer);
var
  Node : PNode;
begin
  Node := acNewNode(aData);
  with qHead^ do begin
    Node^.Link := Link;
    Link := Node;
  end;
  if (qTail = qHead) then
    qTail := Node;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeQueue=================================================}
constructor TThreadsafeQueue.Create(aDataOwner : boolean);
begin
  inherited Create;
  qResLock := TezResourceLock.Create;
  qQueue := TQueue.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeQueue.Destroy;
begin
  qQueue.Free;
  qResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeQueue.AcquireAccess : TQueue;
begin
  qResLock.Lock;
  Result := qQueue;
end;
{--------}
procedure TThreadsafeQueue.ReleaseAccess;
begin
  qResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


{$IFDEF Win32}
{===TThreadsafeDeque=================================================}
constructor TThreadsafeDeque.Create(aDataOwner : boolean);
begin
  inherited Create;
  qResLock := TezResourceLock.Create;
  qDeque := TDeque.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeDeque.Destroy;
begin
  qDeque.Free;
  qResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeDeque.AcquireAccess : TDeque;
begin
  qResLock.Lock;
  Result := qDeque;
end;
{--------}
procedure TThreadsafeDeque.ReleaseAccess;
begin
  qResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


end.
