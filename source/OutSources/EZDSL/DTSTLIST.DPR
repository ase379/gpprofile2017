program Dtstlist;
  {-Test program for single/double/skip lists}

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
  EZDSLLst in 'EZDSLLST.PAS',
  EZDSLDbl in 'EZDSLDBL.PAS',
  EZDSLSkp in 'EZDSLSKP.PAS',
  EZDSLSup in 'EZDSLSUP.PAS',
  DTstGen in 'DTstGen.pas';

function PrintStrs(C : TAbstractContainer;
                   aData : pointer;
                   ExtraData : pointer) : boolean; far;
  var
    S : PEZString absolute aData;
  begin
    Result := true;
    WriteLog(S^);
  end;

var
  i : integer;
  LinkList, NewLinkList : TLinkList;
  DList, NewDList : TDList;
  SkipList, NewSkipList : TSkipList;
  S : PEZString;
  SavedS : string;
  Cursor    : TListCursor;
  StartTime : longint;
begin
  OpenLog;
  try
    WriteLog('Starting tests');

    WriteLog('-----------SINGLE LINKED LIST (unsorted)-----------');
    LinkList := nil;
    try
      WriteLog('First test: insertion & deletion');
      LinkList := TLinkList.Create(true);
      with LinkList do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertAfter(EZStrNew(NumToName(i)));
          WriteLog('...iterating them (should read ten..one)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...delete last, third from last; iterate');
          WriteLog('...(should read ten..four,two)');
          SetAfterLast;
          Prev;
          Erase;
          SetAfterLast;
          Prev; Prev;
          Erase;
          Iterate(PrintStrs, false, nil);
          WriteLog('...emptying; iterate (should be nothing)');
          Empty;
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: cloning, splitting and joining');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            begin
              SetAfterLast;
              InsertBefore(EZStrNew(NumToName(i)));
            end;
          WriteLog('...creating clone');
          NewLinkList := TLinkList.Clone(LinkList, true, Compare);
          try
            WriteLog('...iterating clone backwards');
            WriteLog('...(should read ten..one)');
            NewLinkList.Iterate(PrintStrs, true, nil);
          finally
            NewLinkList.Free;
          end;{try..finally}
          WriteLog('...splitting original list at "four" onwards');
          SetBeforeFirst;
          for i := 1 to 4 do
            Next;
          NewLinkList := Split;
          try
            WriteLog('...iterating original');
            WriteLog('...(should read one..three)');
            Iterate(PrintStrs, false, nil);
            WriteLog('...iterating split-off list');
            WriteLog('...(should read four..ten)');
            NewLinkList.Iterate(PrintStrs, false, nil);
            WriteLog('...joining split-off list in between one and two');
            SetBeforeFirst; Next;
            Join(NewLinkList);
            NewLinkList := nil;
            WriteLog('...iterating original');
            WriteLog('...(should read one,four..ten,two,three)');
            Iterate(PrintStrs, false, nil);
          finally
            NewLinkList.Free;
          end;{try..finally}
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: various basic navigation tests');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            begin
              SetAfterLast;
              InsertBefore(EZStrNew(NumToName(i)));
            end;
          WriteLog('...first element');
          SetBeforeFirst;
          Next;
          WriteLog(PEZString(Examine)^);
          WriteLog('...last element');
          SetAfterLast;
          Prev;
          WriteLog(PEZString(Examine)^);
          WriteLog('...using Next to move forward from start');
          WriteLog('...(should read one..ten)');
          SetBeforeFirst;
          Next;
          while not IsAfterLast do
            begin
              WriteLog(PEZString(Examine)^);
              Next;
            end;
          WriteLog('...using Prev to move backwards from end');
          WriteLog('...(should read ten..one)');
          Prev;
          while not IsBeforeFirst do
            begin
              WriteLog(PEZString(Examine)^);
              Prev;
            end;
          Empty;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: miscellaneous');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            begin
              SetAfterLast;
              InsertBefore(EZStrNew(NumToName(i)));
            end;
          WriteLog('...replace three with eleven');
          SetBeforeFirst;
          Next; Next; Next;
          S := PEZString(Replace(EZStrNew(NumToName(11))));
          WriteLog('...string returned ' + S^);
          EZStrDispose(S);
          WriteLog('...iterate (should read one,two,eleven,four..ten)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;
    finally
      LinkList.Free;
    end;

    WriteLog('-----------SINGLE LINKED LIST (sorted)-----------');
    LinkList := nil;
    try
      WriteLog('First test: insertion & deletion');
      LinkList := TLinkList.Create(true);
      with LinkList do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          IsSorted := true;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...iterating them');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...delete last, third from last; iterate');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,three)');
          SetAfterLast;
          Prev;
          Erase;
          SetAfterLast;
          Prev; Prev;
          Erase;
          Iterate(PrintStrs, false, nil);
          WriteLog('...emptying; iterate (should be nothing)');
          Empty;
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: cloning, splitting and joining');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewLinkList := TLinkList.Clone(LinkList, true, Compare);
          try
            WriteLog('...iterating clone backwards');
            WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
            NewLinkList.Iterate(PrintStrs, true, nil);
          finally
            NewLinkList.Free;
          end;{try..finally}
          WriteLog('...splitting original list at "nine" onwards');
          SetBeforeFirst;
          for i := 1 to 4 do
            Next;
          NewLinkList := Split;
          try
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four)');
            Iterate(PrintStrs, false, nil);
            WriteLog('...iterating split-off list');
            WriteLog('...(should read nine,one,seven,six,ten,three,two)');
            NewLinkList.Iterate(PrintStrs, false, nil);
            WriteLog('...joining split-off list in between eight and five');
            SetBeforeFirst; Next;
            Join(NewLinkList);
            NewLinkList := nil;
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
            Iterate(PrintStrs, false, nil);
          finally
            NewLinkList.Free;
          end;{try..finally}
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: various basic navigation tests');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...first element');
          SetBeforeFirst;
          Next;
          WriteLog(PEZString(Examine)^);
          WriteLog('...last element');
          SetAfterLast;
          Prev;
          WriteLog(PEZString(Examine)^);
          WriteLog('...using Next to move forward from start');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          SetBeforeFirst;
          Next;
          while not IsAfterLast do
            begin
              WriteLog(PEZString(Examine)^);
              Next;
            end;
          WriteLog('...using Prev to move backwards from end');
          WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
          Prev;
          while not IsBeforeFirst do
            begin
              WriteLog(PEZString(Examine)^);
              Prev;
            end;
          Empty;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: miscellaneous');
      with LinkList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...replace four with eleven');
          SetBeforeFirst;
          Next; Next; Next;
          S := PEZString(Replace(EZStrNew(NumToName(11))));
          WriteLog('...string returned ' + S^);
          EZStrDispose(S);
          WriteLog('...iterate');
          WriteLog('...(should read eight,eleven,five,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;
      (****
      WriteLog('Fifth test: megatest');
      with LinkList do
        begin
          WriteLog('...inserting 10,000 random strings');
          StartTime := GetTickCount;
          for i := 1 to 10000 do
            begin
              SavedS := RandomStr(10+Random(15));
              InsertSorted(EZStrNew(SavedS));
            end;
          WriteLog(IntToStr(GetTickCount));
          WriteLog(IntToStr(StartTime));
          WriteLog('...reading strings, checking sequence');
          SavedS := '';
          SetBeforeFirst;
          Next;
          while not IsAfterLast do
            begin
              S := PEZString(Examine);
              if (SavedS >= S^) then
                WriteLog('sequence error');
              SavedS := S^;
              Next;
            end;
          WriteLog('...end of test 5');
        end;
      ****)
    finally
      LinkList.Free;
    end;

    WriteLog('-----------DOUBLE LINKED LIST (unsorted)-----------');
    DList := nil;
    try
      WriteLog('First test: insertion & deletion');
      DList := TDList.Create(true);
      with DList do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertAfter(SetBeforeFirst, EZStrNew(NumToName(i)));
          WriteLog('...iterating them (should read ten..one)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...delete last, third from last; iterate');
          WriteLog('...(should read ten..four,two)');
          Cursor := Prev(SetAfterLast);
          Erase(Cursor);
          Cursor := Prev(Prev(SetAfterLast));
          Erase(Cursor);
          Iterate(PrintStrs, false, nil);
          WriteLog('...emptying; iterate (should be nothing)');
          Empty;
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: cloning, splitting and joining');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertBefore(SetAfterLast, EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewDList := TDList.Clone(DList, true, Compare);
          try
            WriteLog('...iterating clone backwards');
            WriteLog('...(should read ten..one)');
            NewDList.Iterate(PrintStrs, true, nil);
          finally
            NewDList.Free;
          end;{try..finally}
          WriteLog('...splitting original list at "four" onwards');
          Cursor := SetBeforeFirst;
          for i := 1 to 4 do
            Cursor := Next(Cursor);
          NewDList := Split(Cursor);
          try
            WriteLog('...iterating original');
            WriteLog('...(should read one..three)');
            Iterate(PrintStrs, false, nil);
            WriteLog('...iterating split-off list');
            WriteLog('...(should read four..ten)');
            NewDList.Iterate(PrintStrs, false, nil);
            WriteLog('...joining split-off list in between one and two');
            Cursor := Next(SetBeforeFirst);
            Join(Cursor, NewDList);
            NewDList := nil;
            WriteLog('...iterating original');
            WriteLog('...(should read one,four..ten,two,three)');
            Iterate(PrintStrs, false, nil);
          finally
            NewDList.Free;
          end;{try..finally}
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: various basic navigation tests');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertBefore(SetAfterLast, EZStrNew(NumToName(i)));
          WriteLog('...first element');
          Cursor := Next(SetBeforeFirst);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...last element');
          Cursor := Prev(SetAfterLast);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...using Next to move forward from start');
          WriteLog('...(should read one..ten)');
          Cursor := Next(SetBeforeFirst);
          while not IsAfterLast(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Next(Cursor);
            end;
          WriteLog('...using Prev to move backwards from end');
          WriteLog('...(should read ten..one)');
          Cursor := Prev(SetAfterLast);
          while not IsBeforeFirst(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Prev(Cursor);
            end;
          Empty;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: miscellaneous');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertBefore(SetAfterLast, EZStrNew(NumToName(i)));
          WriteLog('...replace three with eleven');
          Cursor := Next(Next(Next(SetBeforeFirst)));
          S := PEZString(Replace(Cursor, EZStrNew(NumToName(11))));
          WriteLog('...string returned ' + S^);
          EZStrDispose(S);
          WriteLog('...iterate (should read one,two,eleven,four..ten)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;
    finally
      DList.Free;
    end;

    WriteLog('-----------DOUBLE LINKED LIST (sorted)-----------');
    DList := nil;
    try
      WriteLog('First test: insertion & deletion');
      DList := TDList.Create(true);
      with DList do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          IsSorted := true;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...iterating them');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...delete last, third from last; iterate');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,three)');
          Cursor := Prev(SetAfterLast);
          Erase(Cursor);
          Cursor := Prev(Prev(SetAfterLast));
          Erase(Cursor);
          Iterate(PrintStrs, false, nil);
          WriteLog('...emptying; iterate (should be nothing)');
          Empty;
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: cloning, splitting and joining');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewDList := TDList.Clone(DList, true, Compare);
          try
            WriteLog('...iterating clone backwards');
            WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
            NewDList.Iterate(PrintStrs, true, nil);
          finally
            NewDList.Free;
          end;{try..finally}
          WriteLog('...splitting original list at "nine" onwards');
          Cursor := SetBeforeFirst;
          for i := 1 to 4 do
            Cursor := Next(Cursor);
          NewDList := Split(Cursor);
          try
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four)');
            Iterate(PrintStrs, false, nil);
            WriteLog('...iterating split-off list');
            WriteLog('...(should read nine,one,seven,six,ten,three,two)');
            NewDList.Iterate(PrintStrs, false, nil);
            WriteLog('...joining split-off list in between eight and five');
            Cursor := Next(SetBeforeFirst);
            Join(Cursor, NewDList);
            NewDList := nil;
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
            Iterate(PrintStrs, false, nil);
          finally
            NewDList.Free;
          end;{try..finally}
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: various basic navigation tests');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...first element');
          Cursor := Next(SetBeforeFirst);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...last element');
          Cursor := Prev(SetAfterLast);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...using Next to move forward from start');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Cursor := Next(SetBeforeFirst);
          while not IsAfterLast(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Next(Cursor);
            end;
          WriteLog('...using Prev to move backwards from end');
          WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
          Cursor := Prev(SetAfterLast);
          while not IsBeforeFirst(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Prev(Cursor);
            end;
          Empty;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: miscellaneous');
      with DList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            InsertSorted(EZStrNew(NumToName(i)));
          WriteLog('...replace four with eleven');
          Cursor := Next(Next(Next(SetBeforeFirst)));
          S := PEZString(Replace(Cursor, EZStrNew(NumToName(11))));
          WriteLog('...string returned ' + S^);
          EZStrDispose(S);
          WriteLog('...iterate');
          WriteLog('...(should read eight,eleven,five,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;

      WriteLog('Fifth test: megatest');
      with DList do
        begin
          WriteLog('...inserting 10,000 random strings');
          StartTime := GetTickCount;
          for i := 1 to 10000 do
            begin
              SavedS := RandomStr(10+Random(15));
              InsertSorted(EZStrNew(SavedS));
            end;
          WriteLog(IntToStr(GetTickCount));
          WriteLog(IntToStr(StartTime));
          WriteLog('...reading strings, checking sequence');
          SavedS := '';
          Cursor := Next(SetBeforeFirst);
          while not IsAfterLast(Cursor) do
            begin
              S := PEZString(Examine(Cursor));
              if (SavedS >= S^) then
                WriteLog('sequence error');
              SavedS := S^;
              Cursor := Next(Cursor);
            end;
          WriteLog('...end of test 5');
        end;
    finally
      DList.Free;
    end;

    WriteLog('-----------SKIP LIST-----------');
    SkipList := nil;
    try
      WriteLog('First test: insertion & deletion');
      SkipList := TSkipList.Create(true);
      with SkipList do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Cursor, EZStrNew(NumToName(i)));
          WriteLog('...iterating them');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...delete last, third from last; iterate');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,three)');
          Cursor := Prev(SetAfterLast);
          Erase(Cursor);
          Cursor := Prev(Prev(SetAfterLast));
          Erase(Cursor);
          Iterate(PrintStrs, false, nil);
          WriteLog('...emptying; iterate (should be nothing)');
          Empty;
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: cloning, splitting and joining');
      with SkipList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Cursor, EZStrNew(NumToName(i)));
          WriteLog('...creating clone');
          NewSkipList := TSkipList.Clone(SkipList, true, Compare);
          try
            WriteLog('...iterating clone backwards');
            WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
            NewSkipList.Iterate(PrintStrs, true, nil);
          finally
            NewSkipList.Free;
          end;{try..finally}
          WriteLog('...splitting original list at "nine" onwards');
          Cursor := SetBeforeFirst;
          for i := 1 to 4 do
            Cursor := Next(Cursor);
          NewSkipList := Split(Cursor);
          try
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four)');
            Iterate(PrintStrs, false, nil);
            WriteLog('...iterating split-off list');
            WriteLog('...(should read nine,one,seven,six,ten,three,two)');
            NewSkipList.Iterate(PrintStrs, false, nil);
            WriteLog('...joining split-off list in between eight and five');
            Cursor := Next(SetBeforeFirst);
            Join(NewSkipList);
            NewSkipList := nil;
            WriteLog('...iterating original');
            WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
            Iterate(PrintStrs, false, nil);
          finally
            NewSkipList.Free;
          end;{try..finally}
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: various basic navigation tests');
      with SkipList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Cursor, EZStrNew(NumToName(i)));
          WriteLog('...first element');
          Cursor := Next(SetBeforeFirst);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...last element');
          Cursor := Prev(SetAfterLast);
          WriteLog(PEZString(Examine(Cursor))^);
          WriteLog('...using Next to move forward from start');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Cursor := Next(SetBeforeFirst);
          while not IsAfterLast(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Next(Cursor);
            end;
          WriteLog('...using Prev to move backwards from end');
          WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
          Cursor := Prev(SetAfterLast);
          while not IsBeforeFirst(Cursor) do
            begin
              WriteLog(PEZString(Examine(Cursor))^);
              Cursor := Prev(Cursor);
            end;
          Empty;
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: miscellaneous');
      with SkipList do
        begin
          WriteLog('...inserting names of numbers');
          for i := 1 to 10 do
            Insert(Cursor, EZStrNew(NumToName(i)));
          WriteLog('...replace four with eleven');
          Cursor := Next(Next(Next(SetBeforeFirst)));
          S := PEZString(Replace(Cursor, EZStrNew(NumToName(11))));
          WriteLog('...string returned ' + S^);
          EZStrDispose(S);
          WriteLog('...iterate');
          WriteLog('...(should read eight,eleven,five,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;

      WriteLog('Fifth test: megatest');
      with SkipList do
        begin
          WriteLog('...inserting 30,000 random strings');
          StartTime := GetTickCount;
          for i := 1 to 30000 do
            begin
              SavedS := RandomStr(10+Random(15));
              Insert(Cursor, EZStrNew(SavedS));
            end;
          WriteLog(IntToStr(GetTickCount));
          WriteLog(IntToStr(StartTime));
          WriteLog('...reading strings, checking sequence');
          SavedS := '';
          Cursor := Next(SetBeforeFirst);
          while not IsAfterLast(Cursor) do
            begin
              S := PEZString(Examine(Cursor));
              if (SavedS >= S^) then
                WriteLog('sequence error');
              SavedS := S^;
              Cursor := Next(Cursor);
            end;
          WriteLog('...end of test 5');
        end;
    finally
      SkipList.Free;
    end;
  finally
    CloseLog;
  end;
end.

