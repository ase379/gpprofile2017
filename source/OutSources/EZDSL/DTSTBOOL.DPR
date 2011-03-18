program DTstBool;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  DTstGen in 'DTstGen.pas',
  Ezdslbar in 'Ezdslbar.pas';

function WriteIndexes(C : TBooleanArray;
                      aIndex : longint;
                      ExtraData : pointer) : boolean; far;
begin
  WriteLogNoCR(Format('%d', [aIndex]));
  Result := true;
end;

const
  BACapacity = 9995;

var
  BA : TBooleanArray;
  i  : longint;
  j  : longint;


begin
  OpenLog;
  try
    WriteLog('Starting tests');
    WriteLog('---BOOLEAN ARRAY---');
    WriteLog('first test: create 9995 booleans');
    BA := TBooleanArray.Create(BACapacity);
    try
      WriteLog('first test: done');
      WriteLog('second test: set every 7th to true, check');
      i := 0;
      while (i < BACapacity) do begin
        BA[i] := true;
        inc(i, 7);
      end;
      for i := 0 to pred(BACapacity) do
        if ((i mod 7) = 0) then begin
          if not BA[i] then
            WriteLog(Format('Error: Boolean %d is not set', [i]));
        end
        else begin
          if BA[i] then
            WriteLog(Format('Error: Boolean %d is set', [i]));
        end;
      WriteLog('second test: using NextTrue');
      i := 0;
      j := -1;
      j := BA.NextTrue(j);
      while j <> -1 do begin
        if j <> i then
          WriteLog('error in NextTrue');
        i := i + 7;
        j := BA.NextTrue(j);
      end;
      WriteLog('second test: using NextFalse');
      i := 1;
      j := -1;
      j := BA.NextFalse(j);
      while j <> -1 do begin
        if j <> i then
          WriteLog('error in NextFalse');
        inc(i);
        if (i mod 7) = 0 then inc(i);
        j := BA.NextFalse(j);
      end;
      WriteLog('second test: using PrevTrue');
      j := BA.Capacity;
      j := BA.PrevTrue(j);
      i := j;
      while j <> -1 do begin
        if j <> i then
          WriteLog('error in PrevTrue');
        i := j - 7;
        j := BA.PrevTrue(j);
      end;
      WriteLog('second test: using PrevFalse');
      j := BA.Capacity;
      j := BA.PrevFalse(j);
      i := j;
      while j <> -1 do begin
        if j <> i then
          WriteLog('error in PrevFalse');
        dec(i);
        if (i mod 7) = 0 then dec(i);
        j := BA.PrevFalse(j);
      end;
      WriteLogNoCR('second test: FirstFalse');
      WriteLog(Format('%d', [BA.FirstFalse]));
      WriteLogNoCR('second test: FirstTrue');
      WriteLog(Format('%d', [BA.FirstTrue]));
      WriteLogNoCR('second test: LasstFalse');
      WriteLog(Format('%d', [BA.LastFalse]));
      WriteLogNoCR('second test: LastTrue');
      WriteLog(Format('%d', [BA.LastTrue]));
      WriteLog(Format('Count: %d', [BA.Count]));
(*    BA.Iterate(WriteIndexes, false, nil);*)
(*    WriteLog('');                        *)
(*    BA.Iterate(WriteIndexes, true, nil); *)
(*    WriteLog('');                        *)
      WriteLog('second test: done');
      WriteLog('third test: set every 21st to false, check');
      i := 0;
      while (i < BACapacity) do begin
        BA[i] := false;
        inc(i, 21);
      end;
      for i := 0 to pred(BACapacity) do
        if ((i mod 7) = 0) then begin
          if ((i mod 21) = 0) then begin
            if BA[i] then
              WriteLog(Format('Error: Boolean %d is set', [i]));
          end
          else begin
            if not BA[i] then
              WriteLog(Format('Error: Boolean %d is not set', [i]));
          end;
        end
        else begin
          if BA[i] then
            WriteLog(Format('Error: Boolean %d is set', [i]));
        end;
      WriteLog(Format('Count: %d', [BA.Count]));  
(*    BA.Iterate(WriteIndexes, false, nil);*)
(*    WriteLog('');                        *)
(*    BA.Iterate(WriteIndexes, true, nil); *)
(*    WriteLog('');                        *)
      WriteLog('third test: done');
      WriteLog('fourth test: toggle every boolean, check');
      i := 0;
      while (i < BACapacity) do begin
        BA.Toggle(i);
        inc(i);
      end;
      for i := 0 to pred(BACapacity) do
        if ((i mod 7) = 0) then begin
          if ((i mod 21) = 0) then begin
            if not BA[i] then
              WriteLog(Format('Error: Boolean %d is not set', [i]));
          end
          else begin
            if BA[i] then
              WriteLog(Format('Error: Boolean %d is set', [i]));
          end;
        end
        else begin
          if not BA[i] then
            WriteLog(Format('Error: Boolean %d is not set', [i]));
        end;
      WriteLog(Format('Count: %d', [BA.Count]));
(*    BA.Iterate(WriteIndexes, false, nil);*)
(*    WriteLog('');                        *)
(*    BA.Iterate(WriteIndexes, true, nil); *)
(*    WriteLog('');                        *)
      WriteLog('fourth test: done');
      WriteLog('fourth test Part II: toggle every boolean, check');
      BA.ToggleAll;
      for i := 0 to pred(BACapacity) do
        if ((i mod 7) = 0) then begin
          if ((i mod 21) = 0) then begin
            if BA[i] then
              WriteLog(Format('Error: Boolean %d is set', [i]));
          end
          else begin
            if not BA[i] then
              WriteLog(Format('Error: Boolean %d is not set', [i]));
          end;
        end
        else begin
          if BA[i] then
            WriteLog(Format('Error: Boolean %d is set', [i]));
        end;
      WriteLog(Format('Count: %d', [BA.Count]));
      WriteLog('fourth test Part II: done');
      WriteLog('fifth test: set all true, check');
      BA.SetAllTrue;
      for i := 0 to pred(BACapacity) do
        if not BA[i] then
          WriteLog(Format('Error: Boolean %d is not set', [i]));
      WriteLog(Format('Count: %d', [BA.Count]));
      WriteLog('fifth test: done');
      WriteLog('sixth test: set all false, check');
      BA.SetAllFalse;
      for i := 0 to pred(BACapacity) do
        if BA[i] then
          WriteLog(Format('Error: Boolean %d is set', [i]));
      WriteLog(Format('Count: %d', [BA.Count]));
      WriteLog('sixth test: done');
    finally
      BA.Free;
    end;
  finally
    CloseLog;
  end;
end.
