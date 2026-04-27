unit testGenerics;

/// <summary>
/// Tests parser coverage for generic Delphi constructs:
/// - Generic classes with type parameters
/// - Generic methods (standalone generic functions)
/// - Generic classes with constraints
/// - Multiple type parameters
/// - Generic method in a non-generic class
/// </summary>

interface

type
  TStack<T> = class
  private
    fItems: TArray<T>;
    fCount: Integer;
  public
    procedure Push(const aItem: T);
    function Pop: T;
    function Peek: T;
    function IsEmpty: Boolean;
    property Count: Integer read fCount;
  end;

  TKeyValuePair<TKey, TValue> = class
  public
    Key: TKey;
    Value: TValue;
    constructor Create(const aKey: TKey; const aValue: TValue);
    function Describe: String;
  end;

  TGenericUtility = class
  public
    class function Min<T>(const aA, aB: T): T;
    class function Max<T>(const aA, aB: T): T;
    class procedure Swap<T>(var aA, aB: T);
  end;

function GenericMin<T>(const aA, aB: T): T;
function GenericMax<T>(const aA, aB: T): T;

procedure TestGenericStack;
procedure TestGenericPair;
procedure TestGenericUtility;
procedure TestGenericFunctions;

implementation

uses
  System.SysUtils, System.Generics.Defaults;

{ TStack<T> }

procedure TStack<T>.Push(const aItem: T);
begin
  if fCount = Length(fItems) then
    SetLength(fItems, fCount + 8);
  fItems[fCount] := aItem;
  Inc(fCount);
end;

function TStack<T>.Pop: T;
begin
  if fCount = 0 then
    raise Exception.Create('Stack is empty');
  Dec(fCount);
  Result := fItems[fCount];
end;

function TStack<T>.Peek: T;
begin
  if fCount = 0 then
    raise Exception.Create('Stack is empty');
  Result := fItems[fCount - 1];
end;

function TStack<T>.IsEmpty: Boolean;
begin
  Result := fCount = 0;
end;

{ TKeyValuePair<TKey, TValue> }

constructor TKeyValuePair<TKey, TValue>.Create(const aKey: TKey; const aValue: TValue);
begin
  inherited Create;
  Key := aKey;
  Value := aValue;
end;

function TKeyValuePair<TKey, TValue>.Describe: String;
begin
  Result := 'Pair';
end;

{ TGenericUtility }

class function TGenericUtility.Min<T>(const aA, aB: T): T;
var
  LComparer: IComparer<T>;
begin
  LComparer := TComparer<T>.Default;
  if LComparer.Compare(aA, aB) <= 0 then
    Result := aA
  else
    Result := aB;
end;

class function TGenericUtility.Max<T>(const aA, aB: T): T;
var
  LComparer: IComparer<T>;
begin
  LComparer := TComparer<T>.Default;
  if LComparer.Compare(aA, aB) >= 0 then
    Result := aA
  else
    Result := aB;
end;

class procedure TGenericUtility.Swap<T>(var aA, aB: T);
var
  LTemp: T;
begin
  LTemp := aA;
  aA := aB;
  aB := LTemp;
end;

{ Standalone generic functions }

function GenericMin<T>(const aA, aB: T): T;
var
  LComparer: IComparer<T>;
begin
  LComparer := TComparer<T>.Default;
  if LComparer.Compare(aA, aB) <= 0 then
    Result := aA
  else
    Result := aB;
end;

function GenericMax<T>(const aA, aB: T): T;
var
  LComparer: IComparer<T>;
begin
  LComparer := TComparer<T>.Default;
  if LComparer.Compare(aA, aB) >= 0 then
    Result := aA
  else
    Result := aB;
end;

{ Test procedures }

procedure TestGenericStack;
var
  LIntStack: TStack<Integer>;
  LStrStack: TStack<String>;
begin
  LIntStack := TStack<Integer>.Create;
  try
    LIntStack.Push(1);
    LIntStack.Push(2);
    LIntStack.Push(3);
    LIntStack.Peek;
    LIntStack.Pop;
    LIntStack.IsEmpty;
  finally
    LIntStack.Free;
  end;

  LStrStack := TStack<String>.Create;
  try
    LStrStack.Push('hello');
    LStrStack.Push('world');
    LStrStack.Pop;
    LStrStack.IsEmpty;
  finally
    LStrStack.Free;
  end;
end;

procedure TestGenericPair;
var
  LPair: TKeyValuePair<Integer, String>;
begin
  LPair := TKeyValuePair<Integer, String>.Create(1, 'one');
  try
    LPair.Describe;
  finally
    LPair.Free;
  end;
end;

procedure TestGenericUtility;
var
  LIntA, LIntB: Integer;
begin
  LIntA := 10;
  LIntB := 20;
  TGenericUtility.Min<Integer>(LIntA, LIntB);
  TGenericUtility.Max<Integer>(LIntA, LIntB);
  TGenericUtility.Swap<Integer>(LIntA, LIntB);
end;

procedure TestGenericFunctions;
begin
  GenericMin<Integer>(5, 10);
  GenericMax<Integer>(5, 10);
  GenericMin<String>('apple', 'banana');
  GenericMax<String>('apple', 'banana');
end;

end.
