program EXInsDup;
  {-Example program showing how to insert duplicate data objects,
    error checking has not been implemented.}

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
  EZDSLBse,
  EZDSLSup,
  EZDSLBtr;

type
  {A data object for non-duplicate strings}
  PNoDupStr = ^TNoDupStr;
  TNoDupStr = record
    Seq : longint;
    St  : TEZString;
  end;

  {A red black tree for storing non-duplicate strings}
  TStringRBTree = class(TrbSearchTree)
    private
      srbtSeq : longint;

    public
      constructor Create;
      procedure Insert (var Cursor : TTreeCursor; aData : pointer); override;
  end;

var
  DupCount : integer;

function NewNoDupStr(const S : string) : PNoDupStr;
{-Create a new no-dup string}
var
  P : PNoDupStr;
begin
  SafeGetMem(P, 5 + length(S));
  P^.Seq := 0;
  P^.St := S;
  NewNoDupStr := P;
end;

procedure DisposeNoDupStr(P : PNoDupStr);
{-Dispose of a no-dup string}
begin
  SafeFreeMem(P, 5 + length(P^.St));
end;

procedure MyDisposeData(aData : pointer); far;
{-Our container's data disposal routine}
begin
  DisposeNoDupStr(PNoDupStr(aData));
end;

function MyCompareData(Data1, Data2 : pointer) : integer; far;
{-Our container's comparison routine - it'll increment DupCount when
  two strings compare equal and then compare the sequence field}
var
  P1 : PNoDupStr absolute Data1;
  P2 : PNoDupStr absolute Data2;
  Res : integer;
begin
  Res := EZStrCompare(@P1^.St, @P2^.St);
  if (Res = 0) then begin
    inc(DupCount);
    if (P1^.Seq < P2^.Seq) then
      Res := -1
    else
      Res := 1;
  end;
  MyCompareData := Res;
end;

constructor TStringRBTree.Create;
{-Constructor for our container: zero the srbtSeq field, set our
  data routines}
begin
  inherited Create(true);
  srbtSeq := 0;
  acSetCompare(MyCompareData);
  acSetDisposeData(MyDisposeData);
end;

procedure TStringRBTree.Insert (var Cursor : TTreeCursor; aData : pointer);
{-Insert method for our container: sets the data object's sequence field
  before insertion}
begin
  inc(srbtSeq);
  PNoDupStr(aData)^.Seq := srbtSeq;
  inherited Insert(Cursor, aData);
end;

var
  i : longint;
  StrRBTree : TStringRBTree;
  Dummy : TTreeCursor;

begin
  OpenLog;
  try
    {create a new string tree}
    StrRBTree := TStringRBTree.Create;
    try
      {insert a bunch of string[3]'s - there are bound to be duplicates}
      DupCount := 0;
      with StrRBTree do
        for i := 1 to 2000 do
          Insert(Dummy, NewNoDupStr(RandomStr(3)));

      WriteLog(Format('There are %d duplicates in the tree', [DupCount]));
      WriteLog(Format('There are %d items in the tree', [StrRBTree.Count]));
    finally
      {destroy the tree}
      StrRBTree.Free;
    end;
  finally
    CloseLog;
  end;
end.
