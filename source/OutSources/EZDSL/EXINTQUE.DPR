program EXIntQue;
  {-Example program to test the TIntHeap}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  DTstGen,
  EZIntQue;

var
  i   : integer;
  Que : TIntHeap;
  L   : longint;

begin
  OpenLog;
  try
    {initialise the queue to be a maxheap}
    WriteLog('MaxHeap test...');
    Que := TIntHeap.Create(false);
    try
      {add some longints onto the queue}
      for i := 1 to 100 do begin
        L := random(64000);
        Que.Add(L);
      end;
      {pop the 1st 10 longints off in ascending order, and write them out}
      for i := 1 to 10 do
        WriteLog(IntToStr(Que.Pop));
    finally
      {destroy the max heap}
      Que.Free;
    end;

    {initialise the queue to be a minheap}
    WriteLog('MinHeap test...');
    Que := TIntHeap.Create(true);
    try
      {add some longints onto the queue}
      for i := 1 to 100 do begin
        L := random(64000);
        Que.Add(L);
      end;
      {pop the 1st 10 longints off in descending order, and write them out}
      for i := 1 to 10 do
        WriteLog(IntToStr(Que.Pop));
    finally
      {destroy the min heap}
      Que.Free;
    end;
  finally
    CloseLog;
  end;
end.
