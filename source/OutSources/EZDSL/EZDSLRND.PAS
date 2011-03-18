{===EZDSLRND==========================================================

Part of the Delphi Structures Library--the random number generator

EZDSLRND is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLRnd;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here----------------------}


{--------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

uses
  {$IFDEF Win32}
  EZDSLThd,
  {$ENDIF}
  SysUtils;

type
  DWORD = longint;

type
  TEZRandomGenerator = class
    private
      rgList : pointer;
      {$IFDEF Win32}
      rgResLock   : TezResourceLock;
      {$ENDIF}
    protected
    public
      constructor Create;
        {-Create the generator}
      destructor Destroy; override;
        {-Destroy the generator}

      procedure AcquireAccess;
        {-Lock the generator in a multithreaded process}
      procedure ReleaseAccess;
        {-Unlock the generator in a multithreaded process}

      procedure SetSeed(const aSeed : longint);
        {-Reseed the generator, if aSeed is zero the generator reseeds
          from the system clock}

      function Random : double;
        {-Return a random number in the range: 0.0 <= R < 1.0}
      function RandomByte : byte;
        {-Return a random byte in the range: 0 <= R < 256}
      function RandomWord : word;
        {-Return a random word in the range: 0 <= R < 65536}
      function RandomLong : longint;
        {-Return a random longint in the range: 0 <= R < 2,147,483,648}
      function RandomDWord : DWORD;
        {-Return a random dword in the range: 0 <= R < 4,294,967,296}

      function RandomIntLimit(aUpperLimit : integer) : integer;
        {-Return a random integer in the range: 0 <= R < aUpperLimit}
        { NOTE: no check is made to see whether aUpperLimit > 0}
      function RandomIntRange(aLowerLimit, aUpperLimit : integer) : integer;
        {-Return a random integer in the range: aLowerLimit <= R < aUpperLimit}
        { NOTE: no check is made to see whether aUpperLimit > aLowerLimit}

      function RandomFloatLimit(aUpperLimit : double) : double;
        {-Return a random double in the range: 0.0 <= R < aUpperLimit}
        { NOTE: no check is made to see whether aUpperLimit > 0}
      function RandomFloatRange(aLowerLimit, aUpperLimit : double) : double;
        {-Return a random double in the range: aLowerLimit <= R < aUpperLimit}
        { NOTE: no check is made to see whether aUpperLimit > aLowerLimit}
  end;

implementation

{References:
  Random bit generator from Numerical Recipes in Pascal
  Additive random number generator from Knuth: Seminumerical
     Algorithms
 Random sequence validation:
  Output from TEZRandomGenerator has been validated with the DIEHARD
  suite, please see http://stat.fsu.edu/~geo/diehard.html for details}

uses
  {$IFDEF Win32}
  Windows; {for GetTickCount}
  {$ENDIF}
  {$IFDEF Windows}
  WinTypes, WinProcs; {for DOS3Call}
  {$ENDIF}

const
  {Values are selected from Knuth 3.2.2}
  TableMagic   = 24;
  TableEntries = 55;

const
  Scale : integer = -31;

type
  PrgTable = ^TrgTable;
  TrgTable = packed record
    tFrmOfs : integer;
    tToOfs  : integer;
    tEntries: array [0..pred(TableEntries)] of longint;
  end;

{===Helper routines==================================================}
function Random32Bit(aSeed : longint) : longint;
{$IFDEF Win32}
{Input:  EAX = current seed
 Output: EAX = 32-bit random value & new seed}
register;
asm
  push ebx
  mov ebx, eax
  mov ecx, 32         {use ecx as the count}
@@NextBit:
  mov edx, ebx
  mov eax, ebx
  shr edx, 1          {xor with bit 1 of seed}
  xor eax, edx
  shr edx, 1          {xor with bit 2 of seed}
  xor eax, edx
  shr edx, 2          {xor with bit 4 of seed}
  xor eax, edx
  shr edx, 2          {xor with bit 6 of seed}
  xor eax, edx
  shr edx, 25         {xor with bit 31 of seed}
  xor eax, edx
  and eax, 1          {isolate the new random bit}
  shl ebx, 1          {shift seed left by one}
  or ebx, eax         {add in the new bit to the seed as bit 0}
  dec ecx             {go get next random bit, until we've got them all}
  jnz @@NextBit
  mov eax, ebx        {return random bits}
  pop ebx
end;
{$ENDIF}
{$IFDEF Windows}
near; assembler;
asm
  mov dx, aSeed.Word[2]
  mov bx, aSeed.Word[0]
  mov cx, 32          {use cx as the count}
@@NextBit:
  mov si, bx
  mov ax, si          {get bit 0 of seed}
  shr si, 1           {xor with bit 1 of seed}
  xor ax, si
  shr si, 1           {xor with bit 2 of seed}
  xor ax, si
  shr si, 1           {xor with bit 4 of seed}
  shr si, 1
  xor ax, si
  shr si, 1           {xor with bit 6 of seed}
  shr si, 1
  xor ax, si
  mov si, dx          {xor with bit 31 of seed}
  shl si, 1
  rcl si, 1
  xor ax, si
  and ax, 1           {isolate the new random bit}
  shl bx, 1           {shift seed left by one}
  rcl dx, 1
  or bx, ax           {add in the new bit to the seed as bit 0}
  loop @@NextBit      {go get next random bit, until we've got them all}
  mov ax, bx          {return new seed}
end;
{$ENDIF}
{--------}
procedure InitTable(aTable : PrgTable; aSeed : longint);
var
  i : integer;
begin
  with aTable^ do begin
    tToOfs := pred(TableEntries);
    tFrmOfs := pred(TableMagic);
    for i := 0 to pred(TableEntries) do begin
      aSeed := Random32bit(aSeed);
      tEntries[i] := aSeed;
    end;
  end;
end;
{--------}
function GetNextRandomDWORD(aTable : PrgTable) : DWORD;
type
  DWArray = array [0..1] of word;
var
  i   : integer;
  ResultAsWords : DWArray absolute Result;
begin
  with aTable^ do begin
    for i := 0 to 1 do begin
      {$Q-} // Anton Alisov: disable integer overflow check, because next line
            // works proper only when this option is disabled 
      inc(tEntries[tToOfs], tEntries[tFrmOfs]);
      {$Q+}
      ResultAsWords[i] := DWArray(tEntries[tToOfs])[1];
      if (tToOfs = 0) then begin
        tToOfs := pred(TableEntries);
        dec(tFrmOfs);
      end
      else begin
        dec(tToOfs);
        if (tFrmOfs = 0) then
          tFrmOfs := pred(TableEntries)
        else
          dec(tFrmOfs);
      end;
    end;
  end;
end;
{--------}
(****
function GetNextRandomWord(aTable : PrgTable) : Word;
begin
  with aTable^ do begin
    inc(tEntries[tToOfs], tEntries[tFrmOfs]);
    Result := word(tEntries[tToOfs]);
    if (tToOfs = 0) then begin
      tToOfs := pred(TableEntries);
      dec(tFrmOfs);
    end
    else begin
      dec(tToOfs);
      if (tFrmOfs = 0) then
        tFrmOfs := pred(TableEntries)
      else
        dec(tFrmOfs);
    end;
  end;
end;
****)
{====================================================================}


{===TEZRandomGenerator===============================================}
constructor TEZRandomGenerator.Create;
begin
  inherited Create;
  GetMem(rgList, sizeof(TrgTable));
  SetSeed(0);
  {$IFDEF Win32}
  rgResLock := TezResourceLock.Create;
  {$ENDIF}
end;
{--------}
destructor TEZRandomGenerator.Destroy;
begin
  if (rgList <> nil) then
    FreeMem(rgList, sizeof(TrgTable));
  {$IFDEF Win32}
  rgResLock.Free;
  {$ENDIF}
  inherited Destroy;
end;
{--------}
procedure TEZRandomGenerator.AcquireAccess;
begin
  {$IFDEF Win32}
  rgResLock.Lock;
  {$ENDIF}
end;
{--------}
procedure TEZRandomGenerator.ReleaseAccess;
begin
  {$IFDEF Win32}
  rgResLock.Unlock;
  {$ENDIF}
end;
{--------}
function TEZRandomGenerator.Random : double;
{$IFDEF Win32}
register;
asm
  call RandomDword
  shr eax, 1
  push eax
  fild Scale
  fild dword ptr [esp]
  fscale
  fstp st(1)
  pop eax
end;
{$ENDIF}
{$IFDEF Windows}
assembler;
var
  R : longint;
  Scale : integer;
asm
  les di, Self
  push di
  push es
  call RandomDword
  shr dx, 1
  rcr ax, 1
  mov R.Word[0], ax
  mov R.Word[2], dx
  mov Scale, -31
  fild Scale
  fild R
  fscale
  fstp st(1)
  fwait
end;
{$ENDIF}
{--------}
function TEZRandomGenerator.RandomByte : byte;
begin
  Result := byte(GetNextRandomDWORD(PrgTable(rgList)));
end;
{--------}
function TEZRandomGenerator.RandomDWord : DWORD;
begin
  Result := GetNextRandomDWORD(PrgTable(rgList));
end;
{--------}
function TEZRandomGenerator.RandomFloatLimit(aUpperLimit : double) : double;
begin
  Result := Random * aUpperLimit;
end;
{--------}
function TEZRandomGenerator.RandomFloatRange(aLowerLimit, aUpperLimit : double) : double;
begin
  Result := (Random * (aUpperLimit - aLowerLimit)) + aLowerLimit;
end;
{--------}
function TEZRandomGenerator.RandomIntLimit(aUpperLimit : integer) : integer;
{$IFDEF Win32}
register;
asm
  push edx
  call RandomDWord
  pop edx
  mul edx
  mov eax, edx
end;
{$ENDIF}
{$IFDEF Windows}
assembler;
asm
  les di, Self
  push di
  push es
  call RandomDword
  mov ax, dx
  mul aUpperLimit
  mov ax, dx
end;
{$ENDIF}
{--------}
function TEZRandomGenerator.RandomIntRange(aLowerLimit, aUpperLimit : integer) : integer;
begin
  Result := RandomIntLimit(aUpperLimit - aLowerLimit) + aLowerLimit;
end;
{--------}
function TEZRandomGenerator.RandomLong : longint;
begin
  Result := GetNextRandomDWORD(PrgTable(rgList)) shr 1;
end;
{--------}
function TEZRandomGenerator.RandomWord : word;
begin
  Result := word(GetNextRandomDWORD(PrgTable(rgList)));
end;
{--------}
procedure TEZRandomGenerator.SetSeed(const aSeed : longint);
var
  SeedValue : longint;
begin
  if (aSeed <> 0) then
    SeedValue := aSeed
  else begin
    {$IFDEF Win32}
    SeedValue := GetTickCount;
    {$ELSE}
    asm
      mov ah, $2C
      call DOS3Call
      mov SeedValue.Word[0], cx
      mov SeedValue.Word[2], dx
    end;
    {$ENDIF}
  end;
  InitTable(PrgTable(rgList), SeedValue);
end;
{====================================================================}

end.

