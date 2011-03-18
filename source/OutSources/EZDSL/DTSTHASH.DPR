program DTstHash;
  {-Test program for hash tables}

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
  EZDSLSup in 'EZDSLSUP.PAS',
  EZDSLHsh in 'EZDSLHSH.PAS',
  DTstGen in 'DTstGen.pas';

var
  HashTable, NewHashTable : THashTable;
  i : integer;
  Data : pointer;

begin
  OpenLog;
  try
    WriteLog('Starting tests');

    WriteLog('-------------HASH TABLE-------------');
    HashTable := nil;
    try
      WriteLog('First test: adding data');
      HashTable := THashTable.Create(false);
      HashTable.HashFunction := HashELF;
      with HashTable do begin
        WriteLog('...inserting names of first 30 numbers');
        for i := 1 to 30 do
          Insert(NumToName(i), pointer(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 1');
      end;

      WriteLog('Second test: finding names of zero, and first 30 numbers');
      with HashTable do begin
        WriteLog('...finding zero');
        if Search(NumToName(0), Data) then
          WriteLog('   Found! - error')
        else
          WriteLog('   Not found - correct');
        WriteLog('...finding first 30 numbers');
        for i := 1 to 30 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]))
        end;
        WriteLog('...end of test 2');
      end;

      WriteLog('Third test: deleting odd numbers, plus find test');
      with HashTable do begin
        WriteLog('...deleting');
        for i := 1 to 30 do
          if odd(i) then
            Erase(NumToName(i));
        WriteLog('...finding');
        for i := 1 to 30 do
          if odd(i) then begin
            if Search(NumToName(i), Data) then
              WriteLog(Format('   Found %d and shouldn''t have', [i]));
          end
          else begin
            if not Search(NumToName(i), Data) then
              WriteLog(Format('   Didn''t find %d and should have', [i]))
            else if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
          end;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 3');
      end;

      WriteLog('Fourth test: joining two hash tables');
      with HashTable do begin
        WriteLog('...empty first hash table');
        Empty;
        WriteLog('...adding first 15 numbers to first hash table');
        for i := 1 to 15 do
          Insert(NumToName(i), pointer(i));
        WriteLog('...adding second 15 numbers to second hash table');
        NewHashTable := THashTable.Create(false);
        NewHashTable.HashFunction := HashELF;
        for i := 16 to 30 do
          NewHashTable.Insert(NumToName(i), pointer(i));
        WriteLog('...join them');
        Join(NewHashTable);
        WriteLog('...finding all 30 numbers');
        for i := 1 to 30 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 4');
      end;

      WriteLog('Fifth test: grow and shrink');
      with HashTable do begin
        WriteLog('...empty hash table');
        Empty;
        WriteLog('...inserting names of first 1000 numbers');
        for i := 1 to 1000 do
          Insert(NumToName(i), pointer(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...finding first 1000 numbers');
        for i := 1 to 1000 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog('...deleting names of first 1000 numbers');
        for i := 1 to 1000 do
          Erase(NumToName(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 5');
      end;

    finally
      HashTable.Free;
    end;

    WriteLog('-------------HASH TABLE (ignore case)-------------');
    HashTable := nil;
    try
      WriteLog('First test: adding data');
      HashTable := THashTable.Create(false);
      HashTable.HashFunction := HashELF;
      HashTable.IgnoreCase := true;
      with HashTable do begin
        WriteLog('...inserting names of first 30 numbers');
        for i := 1 to 30 do
          Insert(NumToName(i), pointer(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 1');
      end;

      WriteLog('Second test: finding names of zero, and first 30 numbers');
      with HashTable do begin
        WriteLog('...finding zero');
        if Search(NumToName(0), Data) then
          WriteLog('   Found! - error')
        else
          WriteLog('   Not found - correct');
        WriteLog('...finding first 30 numbers');
        for i := 1 to 30 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]))
        end;
        WriteLog('...end of test 2');
      end;

      WriteLog('Third test: deleting odd numbers, plus find test');
      with HashTable do begin
        WriteLog('...deleting');
        for i := 1 to 30 do
          if odd(i) then
            Erase(NumToName(i));
        WriteLog('...finding');
        for i := 1 to 30 do
          if odd(i) then begin
            if Search(NumToName(i), Data) then
              WriteLog(Format('   Found %d and shouldn''t have', [i]));
          end
          else begin
            if not Search(NumToName(i), Data) then
              WriteLog(Format('   Didn''t find %d and should have', [i]))
            else if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
          end;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 3');
      end;

      WriteLog('Fourth test: joining two hash tables');
      with HashTable do begin
        WriteLog('...empty first hash table');
        Empty;
        WriteLog('...adding first 15 numbers to first hash table');
        for i := 1 to 15 do
          Insert(NumToName(i), pointer(i));
        WriteLog('...adding second 15 numbers to second hash table');
        NewHashTable := THashTable.Create(false);
        NewHashTable.HashFunction := HashELF;
        NewHashTable.IgnoreCase := false;
        for i := 16 to 30 do
          NewHashTable.Insert(NumToName(i), pointer(i));
        WriteLog('...join them');
        Join(NewHashTable);
        WriteLog('...finding all 30 numbers');
        for i := 1 to 30 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 4');
      end;

      WriteLog('Fifth test: grow and shrink');
      with HashTable do begin
        WriteLog('...empty hash table');
        Empty;
        WriteLog('...inserting names of first 1000 numbers');
        for i := 1 to 1000 do
          Insert(NumToName(i), pointer(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...finding first 1000 numbers');
        for i := 1 to 1000 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog('...changing hash function');
        HashTable.HashFunction := HashPJW;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...finding first 1000 numbers');
        for i := 1 to 1000 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog('...changing ignore case');
        HashTable.IgnoreCase := false;
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...finding first 1000 numbers');
        for i := 1 to 1000 do begin
          if not Search(NumToName(i), Data) then
            WriteLog(Format('   Didn''t find %d', [i]))
          else
            if (integer(Data) <> i) then
              WriteLog(Format('   Bad data at %d', [i]));
        end;
        WriteLog('...deleting names of first 1000 numbers');
        for i := 1 to 1000 do
          Erase(NumToName(i));
        WriteLog(Format('TableSize: %d', [TableSize]));
        WriteLog(Format('Count:     %d', [Count]));
        WriteLog('...end of test 5');
      end;

    finally
      HashTable.Free;
    end;
  finally
    CloseLog;
  end;
end.
