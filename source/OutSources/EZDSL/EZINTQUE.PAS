unit EZIntQue;
  {-Example unit defining a priority queue (min/max heap) for integers}

  {Note: the raison d'etre of this object definition is to show how
         easy it is to define an object based on one of EZDSL classes.
         And one that you don't have to continually remember to
         typecast the objects when you're adding or removing them from
         the container; all the nastiness is hidden!}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

interface

uses
  EZDSLBse,
  EZDSLSup,
  EZDSLPQu;

type
  {A priority queue for storing longints}
  TIntHeap = class
    private
      Queue : TPriorityQueue;

    public
      constructor Create(Ascending : boolean);
        {-Initialise the queue for Ascending order}
      destructor Destroy; override;
        {-Destroy the queue}

      function Count : longint;
        {-Return the number of longints in the queue}
      function IsEmpty : boolean;
        {-Return true if the queue is empty}
      function Pop : longint;
        {-Return the longint at the front of the queue after popping it}
      procedure Add(const Value : longint);
        {-Add the longint to the queue}
  end;

implementation

function IntCompareUp(Data1, Data2 : pointer) : integer; far;
var
  L1 : longint absolute Data1;
  L2 : longint absolute Data2;
begin
  if (L1 < L2) then      IntCompareUp := -1
  else if (L1 = L2) then IntCompareUp := 0
  else                   IntCompareUp := 1
end;

function IntCompareDown(Data1, Data2 : pointer) : integer; far;
var
  L1 : longint absolute Data1;
  L2 : longint absolute Data2;
begin
  if (L1 < L2) then      IntCompareDown := 1
  else if (L1 = L2) then IntCompareDown := 0
  else                   IntCompareDown := -1
end;


{===TIntMaxHeap implementation=========================================}
constructor TIntHeap.Create(Ascending : boolean);
begin
  Queue := TPriorityQueue.Create(true);
  Queue.DisposeData := EZIntDisposeData;
  if Ascending then
    Queue.Compare := IntCompareUp
  else
    Queue.Compare := IntCompareDown;
end;
{--------}
destructor TIntHeap.Destroy;
begin
  Queue.Free;
end;
{--------}
function TIntHeap.Count : longint;
begin
  Count := Queue.Count;
end;
{--------}
function TIntHeap.IsEmpty : boolean;
begin
  IsEmpty := Queue.IsEmpty;
end;
{--------}
procedure TIntHeap.Add(const Value : longint);
begin
  Queue.Append(pointer(Value));
end;
{--------}
function TIntHeap.Pop : longint;
begin
  if IsEmpty then
    Pop := 0 {as good a value as any other!}
  else
    Pop := longint(Queue.Pop);
end;
{====================================================================}

end.