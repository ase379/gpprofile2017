program DTstStak;
  {-Test program for stacks, queues, deques, and priority queues}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  WinProcs,
  WinTypes,
  {$ENDIF}
  SysUtils,
  EZDSLCts in 'EZDSLCTS.PAS',
  EZDSLBse in 'EZDSLBSE.PAS',
  EZDSLStk in 'EZDSLSTK.PAS',
  EZDSLQue in 'EZDSLQUE.PAS',
  EZDSLPqu in 'EZDSLPQU.PAS',
  EZDSLSup in 'EZDSLSUP.PAS',
  DTstGen in 'DTstGen.pas';

function ReverseCompare(Data1, Data2 : pointer) : integer; far;
  begin
    Result := EZStrCompare(Data2, Data1);
  end;

var
  Stack, NewStack : TStack;
  Queue, NewQueue : TQueue;
  DeQue, NewDeQue : TDeQue;
  PrQueue, NewPrQueue : TPriorityQueue;
  i : integer;
  S : PEZString;
  SavedS : string;

begin
  OpenLog;
  try
    WriteLog('Starting tests');

    WriteLog('----------------STACK----------------');
    Stack := nil;
    try
      WriteLog('First test: push and pop');
      Stack := TStack.Create(true);
      with Stack do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Push(EZStrNew(NumToName(i)));
          WriteLog('...popping them (should read ten..one)');
          while not IsEmpty do
            begin
              S := PEZString(Pop);
              WriteLog(S^);
              EZStrDispose(S);
            end;
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: clone');
      with Stack do
        begin
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Push(EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewStack := TStack.Clone(Stack, true, Compare);
          try
            WriteLog('...popping 1st five strings from new stack');
            WriteLog('...(should read ten..six)');
            for i := 1 to 5 do
              begin
                S := PEZString(NewStack.Pop);
                WriteLog(S^);
                EZStrDispose(S);
              end;
          finally
            NewStack.Free;
          end;{try..finally}
          WriteLog('...end of test 2');
        end;
    finally
      Stack.Free;
    end;

    WriteLog('----------------QUEUE----------------');
    Queue := nil;
    try
      WriteLog('First test: append and pop');
      Queue := TQueue.Create(true);
      with Queue do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...appending names of numbers');
          for i := 1 to 10 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...popping them (should read one..ten)');
          while not IsEmpty do
            begin
              S := PEZString(Pop);
              WriteLog(S^);
              EZStrDispose(S);
            end;
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: clone');
      with Queue do
        begin
          WriteLog('...appending names of numbers');
          for i := 1 to 10 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewQueue := TQueue.Clone(Queue, true, Compare);
          try
            WriteLog('...popping 1st five strings from new queue');
            WriteLog('...(should read one..five)');
            for i := 1 to 5 do
              begin
                S := PEZString(NewQueue.Pop);
                WriteLog(S^);
                EZStrDispose(S);
              end;
          finally
            NewQueue.Free;
          end;{try..finally}
          WriteLog('...end of test 2');
        end;
    finally
      Queue.Free;
    end;

    WriteLog('----------------DEQUE----------------');
    Deque := nil;
    try
      WriteLog('First test: push/append and pop');
      Deque := TDeque.Create(true);
      with Deque do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...appending 1st 5 names of numbers');
          for i := 1 to 5 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...pushing 2nd 5 names of numbers');
          for i := 6 to 10 do
            Push(EZStrNew(NumToName(i)));
          WriteLog('...popping them (should read ten..six,one..five)');
          while not IsEmpty do
            begin
              S := PEZString(Pop);
              WriteLog(S^);
              EZStrDispose(S);
            end;
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: clone');
      with Deque do
        begin
          WriteLog('...appending 1st 5 names of numbers');
          for i := 1 to 5 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...pushing 2nd 5 names of numbers');
          for i := 6 to 10 do
            Push(EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewDeque := TDeque.Clone(Deque, true, Compare);
          try
            WriteLog('...popping 1st six strings from new deque');
            WriteLog('...(should read ten..six,one)');
            for i := 1 to 6 do
              begin
                S := PEZString(NewDeque.Pop);
                WriteLog(S^);
                EZStrDispose(S);
              end;
          finally
            NewDeque.Free;
          end;{try..finally}
          WriteLog('...end of test 2');
        end;
    finally
      Deque.Free;
    end;

    WriteLog('----------------PRIORITY QUEUE----------------');
    PrQueue := nil;
    try
      WriteLog('First test: append and pop');
      PrQueue := TPriorityQueue.Create(true);
      with PrQueue do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...appending names of numbers');
          for i := 1 to 10 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...popping them');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          while not IsEmpty do
            begin
              S := PEZString(Pop);
              WriteLog(S^);
              EZStrDispose(S);
            end;
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: clone');
      with PrQueue do
        begin
          WriteLog('...appending names of numbers');
          for i := 1 to 10 do
            Append(EZStrNew(NumToName(i)));
          WriteLog('...creating clone (but descending order)');
          NewPrQueue := TPriorityQueue.Clone(PrQueue, true, ReverseCompare);
          try
            WriteLog('...popping 1st five strings from new queue');
            WriteLog('...(should read two,three,ten,six,seven)');
            for i := 1 to 5 do
              begin
                S := PEZString(NewPrQueue.Pop);
                WriteLog(S^);
                EZStrDispose(S);
              end;
          finally
            NewPrQueue.Free;
          end;{try..finally}
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: reset Compare');
      with PrQueue do
        begin
          WriteLog('...resetting compare');
          Compare := ReverseCompare;
          WriteLog('...popping strings from resorted queue');
          WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
          for i := 1 to 10 do
            begin
              S := PEZString(Pop);
              WriteLog(S^);
              EZStrDispose(S);
            end;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: megatest');
      with PrQueue do
        begin
          Compare := EZStrCompare;
          WriteLog('...appending 30,000 random strings');
          for i := 1 to 30000 do
            begin
              SavedS := RandomStr(10+Random(15));
              Append(EZStrNew(SavedS));
            end;
          WriteLog('...popping strings, checking sequence');
          SavedS := '';
          while not IsEmpty do
            begin
              S := PEZString(Pop);
              if (SavedS > S^) then
                WriteLog('sequence error');
              SavedS := S^;
              EZStrDispose(S);
            end;
          WriteLog('...end of test 4');
        end;
    finally
      PrQueue.Free;
    end;
  finally
    CloseLog;
  end;
end.
