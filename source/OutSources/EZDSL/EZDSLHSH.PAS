{===EZDSLHSH==========================================================

Part of the EZ Delphi Structures Library--the hash table

EZDSLHSH is Copyright (c) 1997 by  Julian M. Bucknall

VERSION HISTORY
14May98 JMB 3.01 Fix to mod in htlHash method 
19Apr98 JMB 3.00 Initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLHsh;

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
  EZDSLLst;

type
  THashFunction = function (const S : string) : longint;

type
  THashTable = class(TAbstractContainer)
    {-Hash table}
    private
      htlArray     : pointer;
      htlHashFunc  : THashFunction;
      htlIgnoreCase: boolean;
      htlTableSize : integer;

    protected
      procedure htlSetHashFunction(HF : THashFunction);
      procedure htlSetIgnoreCase(IC : boolean);
      procedure htlSetTableSize(aNewTableSize : integer);

      procedure htlDeletePrim(const aKey : string; AndErase : boolean);
      function htlFindPrim(const aKey : string; var aIndex : integer) : boolean;
      procedure htlGrowTable;
      function htlHash(const aKey : string) : integer;
      procedure htlMakeNewTable(aNewTableSize : integer);
      procedure htlShrinkTable;

    public
      constructor Create(DataOwner  : boolean); override;
      destructor Destroy; override;

      constructor Clone(Source : TAbstractContainer;
                        DataOwner : boolean; NewCompare : TCompareFunc); override;

      procedure Delete(const aKey : string);
      procedure Empty; override;
      procedure Erase(const aKey : string);
      function Examine(const aKey : string) : pointer;
      procedure Insert(const aKey : string; aData : pointer);
      function Iterate(Action : TIterator; Backwards : boolean;
                        ExtraData : pointer) : pointer;
      procedure Join(HashTable : THashTable);
      function Search(const aKey : string; var aData : pointer) : boolean;

      property HashFunction : THashFunction read htlHashFunc write htlSetHashFunction;
      property IgnoreCase : boolean read htlIgnoreCase write htlSetIgnoreCase;
      property TableSize : integer read htlTableSize write htlSetTableSize;
  end;

{$IFDEF Win32}
type
  TThreadsafeHashTable = class
    protected {private}
      htHashTable : THashTable;
      htResLock  : TezResourceLock;
    protected
    public
      constructor Create(aDataOwner : boolean);
      destructor Destroy; override;

      function AcquireAccess : THashTable;
      procedure ReleaseAccess;
  end;
{$ENDIF}

{---various hashes---}
function HashELF(const S : string) : longint;
function HashPJW(const S : string) : longint;
function HashBKDR(const S : string) : longint;

implementation

const
  MinTableSize = 11;   {arbitrary smallest table size}
  StartTableSize = 53; {arbitrary beginning table size}

type
  THashElementState = (hesEmpty, hesDeleted, hesInUse);

  THashElement = packed record
    {$IFDEF Windows}
    heString : PString;
    {$ELSE}
    heString : string;
    {$ENDIF}
    heData   : pointer;
    heState  : THashElementState;
    heFiller : array [0..2] of byte;
  end;

  PHashElementArray = ^THashElementArray;
  THashElementArray =
     array [0..pred(MaxInt div sizeof(THashElement))] of THashElement;


{===Helper routines==================================================}
function GetClosestPrime(N : longint) : longint;
{$I EZPrimes.inc}
const
  Forever = true;
var
  L, R, M : integer;
  RootN   : longint;
  IsPrime : boolean;
  DivisorIndex : integer;
begin
  {treat 2 as a special case}
  if (N = 2) then begin
    Result := N;
    Exit;
  end;
  {make the result equal to N, and if it's even, the next odd number}
  if Odd(N) then
    Result := N
  else
    Result := succ(N);
  {if the result is within our prime number table, use binary search
   to find the equal or next highest prime number}
  if (Result <= MaxPrime) then begin
    L := 0;
    R := pred(PrimeCount);
    while (L <= R) do begin
      M := (L + R) div 2;
      if (Result = Primes[M]) then
        Exit
      else if (Result < Primes[M]) then
        R := pred(M)
      else
        L := succ(M);
    end;
    Result := Primes[L];
    Exit;
  end;
  {the result is outside our prime number table range, use the
   standard method for testing primality (do any of the primes up to
   the root of the number divide it exactly?) and continue
   incrementing the result by 2 until it is prime}
  if (Result <= (MaxPrime * MaxPrime)) then begin
    while Forever do begin
      RootN := round(Sqrt(Result));
      DivisorIndex := 1; {ignore the prime number 2}
      IsPrime := true;
      while (DivisorIndex < PrimeCount) and (RootN > Primes[DivisorIndex]) do begin
        if ((Result div Primes[DivisorIndex]) * Primes[DivisorIndex] = Result) then begin
          IsPrime := false;
          Break;
        end;
        inc(DivisorIndex);
      end;
      if IsPrime then
        Exit;
      inc(Result, 2);
    end;
  end;
end;
{====================================================================}


{===Hash functions===================================================}
function HashPJW(const S : string) : longint;
{Note: this hash function is described in "Practical Algorithms For
       Programmers" by Andrew Binstock and John Rex, Addison Wesley}
const
  BitsInLongint = sizeof(longint) * 8;
  ThreeQuarters = (BitsInLongint * 3) div 4;
  OneEighth = BitsInLongint div 8;
  HighBits : longint =
             (not longint(0)) shl (BitsInLongint - OneEighth);
var
  i    : longint;
  Test : longint;
begin
  Result := 0;
  for i := 1 to length(S) do begin
    Result := (Result shl OneEighth) + ord(S[i]);
    Test := Result and HighBits;
    if (Test <> 0) then
      Result := (Result xor (Test shr ThreeQuarters)) and
                not HighBits;
  end;
end;
{--------}
function HashELF(const S : string) : longint;
{Note: this hash function is described in "Practical Algorithms For
       Programmers" by Andrew Binstock and John Rex, Addison Wesley,
       with modifications in Dr Dobbs Journal, April 1996}
var
  G : longint;
  i : integer;
begin
  Result := 0;
  for i := 1 to length(S) do begin
    Result := (Result shl 4) + ord(S[i]);
    G := Result and $F0000000;
    if (G <> 0) then
      Result := Result xor (G shr 24);
    Result := Result and (not G);
  end;
end;
{--------}
function HashBKDR(const S : string) : longint;
{Note: this hash function is described in "The C Programming Language"
       by Brian Kernighan and Donald Ritchie, Prentice Hall}
var
  i : integer;
begin
  Result := 0;
  for i := 1 to length(S) do begin
    Result := (Result * 31) + ord(S[i]);
  end;
end;
{====================================================================}


{===THashTable=======================================================}
constructor THashTable.Create(DataOwner  : boolean);
begin
  acNodeSize := 0;
  inherited Create(DataOwner);
  {create the table, default size is StartTableSize}
  GetMem(htlArray, StartTableSize * sizeof(THashElement));
  FillChar(htlArray^, StartTableSize * sizeof(THashElement), 0);
  htlTableSize := StartTableSize;
  {the default hash function is Kernighan and Ritchie's}
  htlHashFunc := HashBKDR;
end;
{--------}
constructor THashTable.Clone(Source : TAbstractContainer;
                  DataOwner : boolean; NewCompare : TCompareFunc);
var
  OldHashTable : THashTable absolute Source;
  InUseCount   : integer;
  Inx          : integer;
  NewData      : pointer;
begin
  if not (Source is THashTable) then
    RaiseError(escBadSource);

  Create(DataOwner);
  HashFunction := OldHashTable.HashFunction;
  IgnoreCase := OldHashTable.IgnoreCase;
  if Assigned(NewCompare) then
    Compare := NewCompare
  else
    Compare := OldHashTable.Compare;
  DupData := OldHashTable.DupData;
  DisposeData := OldHashTable.DisposeData;

  InUseCount := OldHashTable.Count;
  for Inx := 0 to pred(OldHashTable.TableSize) do begin
    with PHashElementArray(OldHashTable.htlArray)^[Inx] do begin
      if (heState = hesInUse) then begin
        if IsDataOwner then
          NewData := DupData(heData)
        else
          NewData := heData;
        try
          {$IFDEF Windows}
          Insert(heString^, NewData);
          {$ELSE}
          Insert(heString, NewData);
          {$ENDIF}
        except
          if IsDataOwner and Assigned(NewData) then
            DisposeData(NewData);
          raise;
        end;{try..except}
        dec(InUseCount);
        if (InUseCount = 0) then
          Break;
      end;
    end;
  end;
end;
{--------}
destructor THashTable.Destroy;
begin
  inherited Destroy;
  FreeMem(htlArray, htlTableSize * sizeof(THashElement));
end;
{--------}
procedure THashTable.Delete(const aKey : string);
begin
  htlDeletePrim(aKey, false);
end;
{--------}
procedure THashTable.Empty;
var
  Inx : integer;
begin
  for Inx := 0 to pred(htlTableSize) do begin
    with PHashElementArray(htlArray)^[Inx] do begin
      if (heState = hesInUse) then begin
        if IsDataOwner then
          DisposeData(heData);
        {$IFDEF Windows}
        DisposeStr(heString);
        {$ELSE}
        heString := '';
        {$ENDIF}
      end;
      heState := hesEmpty;
    end;
  end;
  acCount := 0;
end;
{--------}
procedure THashTable.Erase(const aKey : string);
begin
  htlDeletePrim(aKey, true);
end;
{--------}
function THashTable.Examine(const aKey : string) : pointer;
var
  Inx : integer;
begin
  if not htlFindPrim(aKey, Inx) then
    RaiseError(escKeyNotFound);
  Result := PHashElementArray(htlArray)^[Inx].heData;
end;
{--------}
procedure THashTable.htlDeletePrim(const aKey : string; AndErase : boolean);
var
  Inx : integer;
begin
  if not htlFindPrim(aKey, Inx) then
    RaiseError(escKeyNotFound);
  with PHashElementArray(htlArray)^[Inx] do begin
    if AndErase and IsDataOwner then
      DisposeData(heData);
    {$IFDEF Windows}
    DisposeStr(heString);
    {$ELSE}
    heString := '';
    {$ENDIF}
    heState := hesDeleted;
  end;
  dec(acCount);
  {if we have no elements left, quickly reset all elements to empty}
  if (Count = 0) then begin
    for Inx := 0 to pred(htlTableSize) do begin
      with PHashElementArray(htlArray)^[Inx] do
        heState := hesEmpty;
    end;
  end
  {shrink the table if we have some elements and we're under 1/6 full}
  else if (htlTableSize > MinTableSize) and
          ((Count * 6) < htlTableSize) then
    htlShrinkTable;
end;
{--------}
function THashTable.htlFindPrim(const aKey : string; var aIndex : integer) : boolean;
var
  FirstDeleted : integer;
  KeyHash      : integer;
  FirstKeyHash : integer;
begin
  {assume we'll fail}
  Result := false;
  {we may need to make note of the first deleted element we find, so
   set the variable to some impossible value so that we know whether
   we found one yet}
  FirstDeleted := -1;
  {calculate the hash for the string, make a note of it so we can find
   out when (if) we wrap around the table completely}
  KeyHash := htlHash(aKey);
  FirstKeyHash := KeyHash;
  {do forever - we'll be exiting out of the loop when needed}
  while true do begin
    {with the current element...}
    with PHashElementArray(htlArray)^[KeyHash] do
      case heState of
        hesEmpty   : begin
                       {the state is 'empty', we must stop the linear
                        probe and return either this index or the
                        first deleted one we encountered}
                       if (FirstDeleted <> -1) then
                         aIndex := FirstDeleted
                       else
                         aIndex := KeyHash;
                       Exit;
                     end;
        hesDeleted : begin
                       {the state is 'deleted', we must make a note of
                        this index if it's the first one we found and
                        continue the linear probe}
                       if (FirstDeleted = -1) then
                         FirstDeleted := KeyHash;
                     end;
        hesInUse   : begin
                       {the state is 'in use', we check to see if it's
                        our string, if it is, exit returning true and
                        the index}
                       if IgnoreCase then begin
                         {$IFDEF Windows}
                         if (AnsiCompareText(heString^, aKey) = 0) then begin
                         {$ELSE}
                         if (AnsiCompareText(heString, aKey) = 0) then begin
                         {$ENDIF}
                           aIndex := KeyHash;
                           Result := true;
                           Exit;
                         end;
                       end
                       else begin
                         {$IFDEF Windows}
                         if (heString^ = aKey) then begin
                         {$ELSE}
                         if (heString = aKey) then begin
                         {$ENDIF}
                           aIndex := KeyHash;
                           Result := true;
                           Exit;
                         end;
                       end;
                     end;
      else
        {bad news}
        RaiseError(escBadCaseSwitch);
      end;{case}
    {we didn't find the key or an empty slot this time around, so
     increment the index (taking care of the wraparound) and exit if
     we've got back to the start again}
    inc(KeyHash);
    if (KeyHash = htlTableSize) then
      KeyHash := 0;
    if (KeyHash = FirstKeyHash) then begin
      if (FirstDeleted <> -1) then
        aIndex := FirstDeleted
      else
        aIndex := -1; {this value means that the table is full}
      Exit;
    end;
  end;{forever loop}
end;
{--------}
procedure THashTable.htlGrowTable;
begin
  {make the table roughly twice as large as before}
  htlSetTableSize(htlTableSize * 2);
end;
{--------}
function THashTable.htlHash(const aKey : string) : integer;
var
  UCKey : string;
begin
  if not IgnoreCase then
    Result := htlHashFunc(aKey) mod htlTableSize
  else {ignore the case of characters} begin
    UCKey := AnsiUpperCase(aKey);
    Result := htlHashFunc(UCKey) mod htlTableSize;
  end;
  while (Result < 0) do                                        {!!.01}
    inc(Result, htlTableSize);                                 {!!.01}
end;
{--------}
procedure THashTable.htlMakeNewTable(aNewTableSize : integer);
var
  Inx          : integer;
  OldTableSize : integer;
  NewArray     : PHashElementArray;
  OldArray     : PHashElementArray;
  InUseCount   : integer;
begin
  {allocate a new array}
  GetMem(NewArray, aNewTableSize * sizeof(THashElement));
  FillChar(NewArray^, aNewTableSize * sizeof(THashElement), 0);
  {save the old array and element count and then set the object
   fields to the new values}
  OldArray := PHashElementArray(htlArray);
  OldTableSize := htlTableSize;
  htlArray := NewArray;
  htlTableSize := aNewTableSize;
  {save the actual count of InUse elements}
  InUseCount := Count;
  acCount := 0;
  {read through the old array and transfer over the strings/objects}
  for Inx := 0 to pred(OldTableSize) do begin
    with OldArray^[Inx] do begin
      if (heState = hesInUse) then begin
        {$IFDEF Windows}
        Insert(heString^, heData);
        DisposeStr(heString);
        {$ELSE}
        Insert(heString, heData);
        heString := '';
        {$ENDIF}
        dec(InUseCount);
        if (InUseCount = 0) then
          Break;
      end;
    end;
  end;
  {finally free the old array}
  FreeMem(OldArray, OldTableSize * sizeof(THashElement));
end;
{--------}
procedure THashTable.htlSetHashFunction(HF : THashFunction);
begin
  if Assigned(HF) then begin
    htlHashFunc := HF;
    htlMakeNewTable(htlTableSize);
  end;
end;
{--------}
procedure THashTable.htlSetIgnoreCase(IC : boolean);
begin
  if (htlIgnoreCase <> IC) then begin
    htlIgnoreCase := IC;
    htlMakeNewTable(htlTableSize);
  end;
end;
{--------}
procedure THashTable.htlSetTableSize(aNewTableSize : integer);
begin
  {force the hash table to be a prime at least MinTableSize, and if
   there's nothing to do, do it}
  aNewTableSize := GetClosestPrime(aNewTableSize);
  if (aNewTableSize < MinTableSize) then
    aNewTableSize := MinTableSize;
  if (aNewTableSize <> htlTableSize) then
    htlMakeNewTable(aNewTableSize);
end;
{--------}
procedure THashTable.htlShrinkTable;
begin
  {make the table roughly half as large as before}
  htlSetTableSize(htlTableSize div 2);
end;
{--------}
procedure THashTable.Insert(const aKey : string; aData : pointer);
var
  Inx : integer;
begin
  if htlFindPrim(aKey, Inx) then
    RaiseError(escInsertDup);
  if (Inx = -1) then
    RaiseError(escTableFull);
  with PHashElementArray(htlArray)^[Inx] do begin
    {$IFDEF Windows}
    heString := NewStr(aKey);
    {$ELSE}
    heString := aKey;
    {$ENDIF}
    heData := aData;
    heState := hesInUse;
  end;
  inc(acCount);
  {grow the table if we're over 2/3 full}
  if ((Count * 3) > (htlTableSize * 2)) then
    htlGrowTable;
end;
{--------}
function THashTable.Iterate(Action : TIterator; Backwards : boolean;
                            ExtraData : pointer) : pointer;
var
  Inx : integer;
begin
  Result := nil;
  if Backwards then begin
    for Inx := pred(htlTableSize) downto 0 do
      with PHashElementArray(htlArray)^[Inx] do begin
        if (heState = hesInUse) then
          if not Action(Self, heData, ExtraData) then begin
            Result := heData;
            Exit;
          end;
      end;
  end
  else {forwards} begin
    for Inx := 0 to pred(htlTableSize) do
      with PHashElementArray(htlArray)^[Inx] do begin
        if (heState = hesInUse) then
          if not Action(Self, heData, ExtraData) then begin
            Result := heData;
            Exit;
          end;
      end;
  end;
end;
{--------}
procedure THashTable.Join(HashTable : THashTable);
var
  Inx        : integer;
  InUseCount : integer;
begin
  if not Assigned(HashTable) then Exit;

  {$IFDEF DEBUG}
  EZAssert(HashTable.IsDataOwner = IsDataOwner, ascCannotJoinData);
  {$ENDIF}

  if (HashTable.Count > 0) then begin
    InUseCount := HashTable.Count;
    for Inx := 0 to pred(HashTable.htlTableSize) do begin
      with PHashElementArray(HashTable.htlArray)^[Inx] do begin
        if (heState = hesInUse) then begin
          {$IFDEF Windows}
          Insert(heString^, heData);
          DisposeStr(heString);
          {$ELSE}
          Insert(heString, heData);
          heString := '';
          {$ENDIF}
          heState := hesEmpty;
          dec(InUseCount);
          if (InUseCount = 0) then
            Break;
        end;
      end;
    end;
  end;
  HashTable.Free;
end;
{--------}
function THashTable.Search(const aKey : string; var aData : pointer) : boolean;
var
  Inx : integer;
begin
  if htlFindPrim(aKey, Inx) then begin
    Result := true;
    aData := PHashElementArray(htlArray)^[Inx].heData;
  end
  else begin
    Result := false;
    aData := nil;
  end;
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeHashTable=============================================}
constructor TThreadsafeHashTable.Create(aDataOwner : boolean);
begin
  inherited Create;
  htResLock := TezResourceLock.Create;
  htHashTable := THashTable.Create(aDataOwner);
end;
{--------}
destructor TThreadsafeHashTable.Destroy;
begin
  htHashTable.Free;
  htResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeHashTable.AcquireAccess : THashTable;
begin
  htResLock.Lock;
  Result := htHashTable;
end;
{--------}
procedure TThreadsafeHashTable.ReleaseAccess;
begin
  htResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


end.
