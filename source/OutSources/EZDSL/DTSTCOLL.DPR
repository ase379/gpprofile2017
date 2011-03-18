program Dtstcoll;
  {-Test program for collections}

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
  Ezdslcol in 'EZDSLCOL.PAS',
  EZDSLSup in 'EZDSLSUP.PAS',
  DTstGen in 'DTstGen.pas';

function ReverseCompare(Data1, Data2 : pointer) : integer; far;
  begin
    Result := EZStrCompare(Data2, Data1);
  end;

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
  NewColl, Coll : TEZCollection;
  NewSColl, SColl : TEZSortedCollection;
  i : integer;
  S : PEZString;
  SavedS : string;
begin
  OpenLog;
  try
    WriteLog('Starting tests');

    WriteLog('----------------COLLECTION (unsorted)----------------');
    Coll := nil;
    NewColl := nil;
    try
      WriteLog('First test: insertion; iterating');
      Coll := TEZCollection.Create(true);
      with Coll do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Insert(EZStrNew(NumToName(i)));
          WriteLog('...iterating through list (should read one..ten)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: deleting items 0..4 in order; iterating');
      with Coll do
        begin
          WriteLog('...deleting');
          for i := 0 to 4 do
            Free(Items[i]);
          WriteLog('...iterating through list');
          WriteLog('...(should read two,four,six,eight,ten)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: cloning');
      with Coll do
        begin
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Insert(EZStrNew(NumToName(i)));
          NewColl := TEZCollection.Clone(Coll, true, Compare);
          WriteLog('...iterating through cloned list');
          WriteLog('...(should read one..ten)');
          NewColl.Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: assignment');
      with Coll do
        begin
          WriteLog('...pushing names of numbers into clone');
          NewColl.Empty;
          for i := 11 to 20 do
            NewColl.Insert(EZStrNew(NumToName(i)));
          Assign(NewColl);
          WriteLog('...iterating through assigned list');
          WriteLog('...(should read eleven..twenty)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 4');
        end;
    finally
      TObject(Coll).Free;
      TObject(NewColl).Free;
    end;

    WriteLog('----------------COLLECTION (sorted)----------------');
    SColl := nil;
    NewSColl := nil;
    try
      WriteLog('First test: insertion; iterating');
      SColl := TEZSortedCollection.Create(true);
      with SColl do
        begin
          Compare := EZStrCompare;
          DupData := EZStrDupData;
          DisposeData := EZStrDisposeData;
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Insert(EZStrNew(NumToName(i)));
          WriteLog('...iterating through list');
          WriteLog('...(should read eight,five,four,nine,one,seven,six,ten,three,two)');
          Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 1');
        end;

      WriteLog('Second test: deleting items 0..4 in order; iterating');
      with SColl do
        begin
          WriteLog('...deleting');
          for i := 0 to 4 do
            Free(Items[i]);
          WriteLog('...iterating through list');
          WriteLog('...(should read five,nine,seven,ten,two)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 2');
        end;

      WriteLog('Third test: cloning');
      with SColl do
        begin
          WriteLog('...pushing names of numbers');
          for i := 1 to 10 do
            Insert(EZStrNew(NumToName(i)));
          NewSColl := TEZSortedCollection.Clone(SColl, true, ReverseCompare);
          WriteLog('...iterating through cloned list');
          WriteLog('...(should read two,three,ten,six,seven,one,nine,four,five,eight)');
          NewSColl.Iterate(PrintStrs, false, nil);
          WriteLog('...end of test 3');
        end;

      WriteLog('Fourth test: assignment');
      with SColl do
        begin
          WriteLog('...pushing names of numbers into clone');
          NewSColl.Empty;
          for i := 11 to 20 do
            NewSColl.Insert(EZStrNew(NumToName(i)));
          Assign(NewSColl);
          NewSColl.Empty;
          WriteLog('...iterating through assigned list');
          WriteLog('...(should read twenty,twelve,thirteen,sixteen,seventeen,');
          WriteLog('... nineteen,fourteen,fifteen,eleven,eighteen)');
          Iterate(PrintStrs, false, nil);
          Empty;
          WriteLog('...end of test 4');
        end;

      WriteLog('Fifth test: megatest; Pack');
      with SColl do
        begin
          Compare := EZStrCompare;
          WriteLog('...adding 30,000 random strings');
          for i := 1 to 30000 do
            begin
              SavedS := RandomStr(10+Random(15));
              Insert(EZStrNew(SavedS));
            end;
          WriteLog('...iterating strings, checking sequence');
          SavedS := '';
          for i := 0 to pred(Count) do
            begin
              S := PEZString(At(i));
              if (SavedS > S^) then
                begin
                  WriteLog('sequence error');
                  WriteLog(SavedS);
                  WriteLog(S^);
                end;
              SavedS := S^;
            end;
          WriteLog('...packing');
          Pack;
          WriteLog('...iterating strings again, checking sequence');
          SavedS := '';
          for i := 0 to pred(Count) do
            begin
              S := PEZString(At(i));
              if (SavedS > S^) then
                begin
                  WriteLog('sequence error');
                  WriteLog(SavedS);
                  WriteLog(S^);
                end;
              SavedS := S^;
            end;
          Empty;
          WriteLog('...end of test 5');
        end;
    finally
      TObject(SColl).Free;
      TObject(NewSColl).Free;
    end;
    
  finally
    CloseLog;
  end;
end.

