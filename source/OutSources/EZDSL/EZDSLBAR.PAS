{===EZDSLBAR==========================================================

Part of the EZ Delphi Structures Library--the boolean array

EZDSLBAR is Copyright (c) 1998 by  Julian M. Bucknall

VERSION HISTORY
14May98 JMB 3.01 Initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EzdslBAr;

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
  TBooleanArray = class;

  TBooleanArrayIterator = function(C : TBooleanArray;
                                   aIndex : longint;
                                   ExtraData : pointer) : boolean;

  TBooleanArray = class(TPersistent)
    {-BooleanArray}
    private
      baArray      : PByteArray;
      baArrayOwner : boolean;
      baArraySize  : longint;
      baCapacity   : longint;
      baCount      : longint;

    protected
      function baGetFlag(aInx : longint) : boolean;
      procedure baSetFlag(aInx : longint; aValue : boolean);
      procedure baSetCapacity(aCapacity : longint);

      function baIterateFwd(aFromInx   : longint;
                            aValue     : boolean;
                            aAction    : TBooleanArrayIterator;
                            aExtraData : pointer) : longint;
      function baIterateBkwd(aFromInx   : longint;
                             aValue     : boolean;
                             aAction    : TBooleanArrayIterator;
                             aExtraData : pointer) : longint;
      procedure baRecount;
    public
      constructor Create(aCapacity : longint);
        {-create a new boolean array, aCapacity is the number of
          boolean values in the array}
      destructor Destroy; override;
        {-destroy the boolean array}

      procedure SwitchArrays(aNewArray   : PByteArray;
                             aCapacity   : longint);
        {-make the boolean array use another memory block for its
          values, of aCapacity bits}

      procedure AndArray(aArray : TBooleanArray);
        {-OR a boolean array with this one}
      procedure OrArray(aArray : TBooleanArray);
        {-AND a boolean array with this one}
      procedure XorArray(aArray : TBooleanArray);
        {-XOR a boolean array with this one}

      function Iterate(aAction    : TBooleanArrayIterator;
                       aValue     : boolean;
                       aBackwards : boolean;
                       aExtraData : pointer) : longint;
        {-iterate through the true booleans (aValue = true) or false
          ones, forwards or not (aBackwards), calling aAction for
          each, passing aExtraDatato the action function. Returns
          either the first boolean index for which the action function
          returned false, or -1 if none did}

      function FirstFalse : longint;
        {-return the index of the first false boolean}
      function FirstTrue : longint;
        {-return the index of the first true boolean}
      function LastFalse : longint;
        {-return the index of the last false boolean}
      function LastTrue : longint;
        {-return the index of the last true boolean}
      function NextFalse(aFromInx : longint) : longint;
        {-return the index of the next false boolean from the given
          boolean}
      function NextTrue(aFromInx : longint) : longint;
        {-return the index of the next true boolean from the given
          boolean}
      function PrevFalse(aFromInx : longint) : longint;
        {-return the index of the previous false boolean from the
          given boolean}
      function PrevTrue(aFromInx : longint) : longint;
        {-return the index of the previous true boolean from the given
          boolean}
      procedure SetAllFalse;
        {-set all booleans in array to false}
      procedure SetAllTrue;
        {-set all booleans in array to true}
      function Toggle(aInx : longint) : boolean;
        {-toggle the given boolean from false to true or vice versa}
      procedure ToggleAll;
        {-toggle all booleans from false to true or vice versa}

      property Flag[aInx : longint] : boolean read baGetFlag write baSetFlag; default;
        {-the array of booleans}
      property Count : longint read baCount;
        {-the number of true booleans}
      property Capacity : longint read baCapacity write baSetCapacity;
        {-the total number of booleans in the array}
  end;

{$IFDEF Win32}
type
  TThreadsafeBooleanArray = class
    protected {private}
      baBooleanArray  : TBooleanArray;
      baResLock : TezResourceLock;
    protected
    public
      constructor Create(aCapacity : longint);
      destructor Destroy; override;

      function AcquireAccess : TBooleanArray;
      procedure ReleaseAccess;
  end;
{$ENDIF}

implementation

{===Handy iterators==================================================}
function AlwaysStop(C : TBooleanArray;
                    aIndex : longint;
                    ExtraData : pointer) : boolean; far;
begin
  Result := false;
end;
{====================================================================}


{===TBooleanArray====================================================}
constructor TBooleanArray.Create(aCapacity : longint);
begin
  inherited Create;
  if (aCapacity <> 0) then
    baSetCapacity(aCapacity);
end;
{--------}
destructor TBooleanArray.Destroy;
begin
  if baArrayOwner and (baArray <> nil) then
    baSetCapacity(0);
  inherited Destroy;
end;
{--------}
procedure TBooleanArray.AndArray(aArray : TBooleanArray);
var
  i : integer;
begin
  {$IFDEF DEBUG}
  EZAssert(aArray <> nil, ascNilArray);
  EZAssert(Capacity = aArray.Capacity, ascNotSameSize);
  {$ENDIF}
  for i := 0 to pred(baArraySize) do
    baArray^[i] := baArray^[i] and aArray.baArray^[i];
end;
{--------}
function TBooleanArray.baGetFlag(aInx : longint) : boolean;
var
  Mask : byte;
begin
  if (aInx < 0) or (aInx >= Capacity) then
    RaiseError(escBadBooleanInx);
  if (baArray = nil) then
    Result := false
  else begin
    Mask := 1 shl (aInx and $7);
    Result := (baArray^[aInx shr 3] and Mask) <> 0;
  end;
end;
{--------}
function TBooleanArray.baIterateFwd(aFromInx   : longint;
                                    aValue     : boolean;
                                    aAction    : TBooleanArrayIterator;
                                    aExtraData : pointer) : longint;
var
  FullBytes : longint;
  ByteStart : longint;
  FirstBits : integer;
  Bit       : longint;
  i         : longint;
  CurByte   : byte;
begin
  {do the first 1 to 7 booleans first}
  ByteStart := (aFromInx+7) shr 3;
  FirstBits := aFromInx and $7;
  if (FirstBits <> 0) then begin
    for Bit := aFromInx to (aFromInx - FirstBits + 7) do
      if (Flag[Bit] = aValue) then
        if not aAction(Self, Bit, aExtraData) then begin
          Result := Bit;
          Exit;
        end;
  end;
  {do the complete bytes next}
  FullBytes := Capacity shr 3;
  for i := ByteStart to pred(FullBytes) do begin
    CurByte := baArray^[i];
    if (aValue and (CurByte <> 0)) or
       ((not aValue) and (CurByte <> $FF)) then begin
      for Bit := 0 to 7 do begin
        if (boolean(CurByte and 1) = aValue) then begin
          Result := (i shl 3) + Bit;
          if not aAction(Self, Result, aExtraData) then
            Exit;
        end;
        CurByte := CurByte shr 1;
      end;
    end;
  end;
  {now do the last 1 to 7 booleans}
  for Bit := (FullBytes * 8) to pred(Capacity) do
    if (Flag[Bit] = aValue) then
      if not aAction(Self, Bit, aExtraData) then begin
        Result := Bit;
        Exit;
      end;
  Result := -1;
end;
{--------}
function TBooleanArray.baIterateBkwd(aFromInx   : longint;
                                     aValue     : boolean;
                                     aAction    : TBooleanArrayIterator;
                                     aExtraData : pointer) : longint;
var
  FullBytes : longint;
  Bit       : longint;
  i         : longint;
  CurByte   : byte;
begin
  FullBytes := (aFromInx+1) shr 3;
  {do the last 1 to 7 booleans first, in reverse order}
  for Bit := aFromInx downto (FullBytes * 8) do
    if (Flag[Bit] = aValue) then
      if not aAction(Self, Bit, aExtraData) then begin
        Result := Bit;
        Exit;
      end;
  {now do the complete bytes in reverse order, and their bits in
   reverse order as well }
  for i := pred(Fullbytes) downto 0 do begin
    CurByte := baArray^[i];
    if (aValue and (CurByte <> 0)) or
       ((not aValue) and (CurByte <> $FF)) then begin
      for Bit := 7 downto 0 do begin
        if (((CurByte and $80) <> 0) = aValue) then begin
          Result := (i shl 3) + Bit;
          if not aAction(Self, Result, aExtraData) then
            Exit;
        end;
        CurByte := CurByte shl 1;
      end;
    end;
  end;
  Result := -1;
end;
{--------}
procedure TBooleanArray.baRecount;
{$I EZBitCnt.INC}
var
  i        : longint;
  NewCount : longint;
  FullBytes: longint;
begin
  {if there are no booleans, there can't be any true ones}
  if (Capacity = 0) then begin
    baCount := 0;
    Exit;
  end;
  {do the easy count first}
  NewCount := 0;
  FullBytes := Capacity shr 3;
  for i := 0 to pred(Fullbytes) do
    inc(NewCount, BitCount[baArray^[i]]);
  {now count the last 1 to 7 booleans}
  for i := (FullBytes * 8) to pred(Capacity) do
    if Flag[i] then
      inc(NewCount);
  baCount := NewCount;
end;
{--------}
procedure TBooleanArray.baSetFlag(aInx : longint; aValue : boolean);
var
  Mask : byte;
begin
  if (aInx < 0) or (aInx >= Capacity) then
    RaiseError(escBadBooleanInx);
  if (baArray <> nil) then begin
    if aValue then begin
      Mask := 1 shl (aInx and $7);
      if ((baArray^[aInx shr 3] and Mask) = 0) then
        inc(baCount);
      baArray^[aInx shr 3] := baArray^[aInx shr 3] or Mask;
    end
    else begin
      Mask := 1 shl (aInx and $7);
      if ((baArray^[aInx shr 3] and Mask) <> 0) then
        dec(baCount);
      baArray^[aInx shr 3] := baArray^[aInx shr 3] and (not Mask);
    end;
  end;
end;
{--------}
procedure TBooleanArray.baSetCapacity(aCapacity : longint);
var
  NewArray : PByteArray;
  NewSize  : longint;
begin
  {$IFDEF DEBUG}
  EZAssert(aCapacity >= 0, ascBadCapacity);
  {$ENDIF}
  if (aCapacity = baCapacity) then
    Exit;
  if (aCapacity = 0) then begin
    NewSize := 0;
    NewArray := nil;
  end
  else begin
    NewSize := (aCapacity + 7) shr 3;
    GetMem(NewArray, NewSize);
    if (baArray = nil) then
      FillChar(NewArray^, NewSize, 0)
    else begin
      if (NewSize <= baArraySize) then
        Move(baArray^, NewArray^, NewSize)
      else begin
        FillChar(NewArray^, NewSize, 0);
        Move(baArray^, NewArray^, baArraySize);
      end;
    end;
  end;
  if baArrayOwner and (baArray <> nil) then
    FreeMem(baArray, baArraySize);
  baArray := NewArray;
  baArraySize := NewSize;
  baCapacity := aCapacity;
  baArrayOwner := (aCapacity <> 0);
end;
{--------}
function TBooleanArray.Iterate(aAction    : TBooleanArrayIterator;
                               aValue     : boolean;
                               aBackwards : boolean;
                               aExtraData : pointer) : longint;
begin
  if (Capacity = 0) then
    Result := -1
  else begin
    if aBackwards then
      Result := baIterateBkwd(pred(Capacity), aValue, aAction, aExtraData)
    else
      Result := baIterateFwd(0, aValue, aAction, aExtraData)
  end;
end;
{--------}
function TBooleanArray.FirstFalse : longint;
begin
  if (Capacity = 0) or (Count = Capacity) then
    Result := -1
  else
    Result := baIterateFwd(0, false, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.FirstTrue : longint;
begin
  if (Capacity = 0) or (Count = 0) then
    Result := -1
  else
    Result := baIterateFwd(0, true, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.LastFalse : longint;
begin
  if (Capacity = 0) or (Count = Capacity) then
    Result := -1
  else
    Result := baIterateBkwd(pred(Capacity), false, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.LastTrue : longint;
begin
  if (Capacity = 0) or (Count = 0) then
    Result := -1
  else
    Result := baIterateBkwd(pred(Capacity), true, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.NextFalse(aFromInx : longint) : longint;
begin
  inc(aFromInx);
  if (aFromInx < 0) or (aFromInx >= Capacity) then
    Result := -1
  else
    Result := baIterateFwd(aFromInx, false, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.NextTrue(aFromInx : longint) : longint;
begin
  inc(aFromInx);
  if (aFromInx < 0) or (aFromInx >= Capacity) then
    Result := -1
  else
    Result := baIterateFwd(aFromInx, true, AlwaysStop, nil);
end;
{--------}
procedure TBooleanArray.OrArray(aArray : TBooleanArray);
var
  i : integer;
begin
  {$IFDEF DEBUG}
  EZAssert(aArray <> nil, ascNilArray);
  EZAssert(Capacity = aArray.Capacity, ascNotSameSize);
  {$ENDIF}
  for i := 0 to pred(baArraySize) do
    baArray^[i] := baArray^[i] or aArray.baArray^[i];
end;
{--------}
function TBooleanArray.PrevFalse(aFromInx : longint) : longint;
begin
  dec(aFromInx);
  if (aFromInx < 0) or (aFromInx >= Capacity) then
    Result := -1
  else
    Result := baIterateBkwd(aFromInx, false, AlwaysStop, nil);
end;
{--------}
function TBooleanArray.PrevTrue(aFromInx : longint) : longint;
begin
  dec(aFromInx);
  if (aFromInx < 0) or (aFromInx >= Capacity) then
    Result := -1
  else
    Result := baIterateBkwd(aFromInx, true, AlwaysStop, nil);
end;
{--------}
procedure TBooleanArray.SetAllFalse;
begin
  if (baArray <> nil) then begin
    FillChar(baArray^, baArraySize, 0);
    baCount := 0;
  end;
end;
{--------}
procedure TBooleanArray.SetAllTrue;
begin
  if (baArray <> nil) then begin
    FillChar(baArray^, baArraySize, $FF);
    baCount := baCapacity;
  end;
end;
{--------}
procedure TBooleanArray.SwitchArrays(aNewArray   : PByteArray;
                                     aCapacity   : longint);
begin
  if baArrayOwner and (baCapacity <> 0) then
    baSetCapacity(0);
  if (aNewArray = nil) then begin
    baArray := nil;
    baArraySize := 0;
    baCapacity := 0;
    baArrayOwner := false;
    baCount := 0;
  end
  else begin
    baArray := aNewArray;
    baArraySize := (aCapacity + 7) shr 3;
    baCapacity := aCapacity;
    baArrayOwner := false;
    baRecount;
  end;
end;
{--------}
function TBooleanArray.Toggle(aInx : longint) : boolean;
begin
  if (aInx < 0) or (aInx >= Capacity) then
    RaiseError(escBadBooleanInx);
  if (baArray = nil) then
    Result := false
  else begin
    Result := not baGetFlag(aInx);
    baSetFlag(aInx, Result);
  end;
end;
{--------}
procedure TBooleanArray.ToggleAll;
var
  i : longint;
begin
  if (baArray <> nil) then
    for i := 0 to pred(baArraySize) do
      baArray^[i] := not baArray^[i];
end;
{--------}
procedure TBooleanArray.XorArray(aArray : TBooleanArray);
var
  i : integer;
begin
  {$IFDEF DEBUG}
  EZAssert(aArray <> nil, ascNilArray);
  EZAssert(Capacity = aArray.Capacity, ascNotSameSize);
  {$ENDIF}
  for i := 0 to pred(baArraySize) do
    baArray^[i] := baArray^[i] xor aArray.baArray^[i];
end;
{====================================================================}


{$IFDEF Win32}
{===TThreadsafeBooleanArray=============================================}
constructor TThreadsafeBooleanArray.Create(aCapacity : longint);
begin
  inherited Create;
  baResLock := TezResourceLock.Create;
  baBooleanArray := TBooleanArray.Create(aCapacity);
end;
{--------}
destructor TThreadsafeBooleanArray.Destroy;
begin
  baBooleanArray.Free;
  baResLock.Free;
  inherited Destroy;
end;
{--------}
function TThreadsafeBooleanArray.AcquireAccess : TBooleanArray;
begin
  baResLock.Lock;
  Result := baBooleanArray;
end;
{--------}
procedure TThreadsafeBooleanArray.ReleaseAccess;
begin
  baResLock.Unlock;
end;
{====================================================================}
{$ENDIF}


end.
