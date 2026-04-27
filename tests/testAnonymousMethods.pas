unit testAnonymousMethods;

/// <summary>
/// Tests parser coverage for anonymous method constructs:
/// - Anonymous procedures (procedure variables)
/// - Anonymous functions
/// - Closures capturing outer variables
/// - Method references (reference to procedure/function)
/// - Nested anonymous methods
/// - Anonymous methods passed as parameters
/// </summary>

interface

procedure TestAnonymousProcedure;
procedure TestAnonymousFunction;
procedure TestClosure;
procedure TestMethodReference;
procedure TestNestedAnonymousMethods;
procedure TestAnonymousMethodAsParameter;

implementation

uses
  System.SysUtils;

type
  TProcRef = reference to procedure;
  TIntFuncRef = reference to function: Integer;
  TIntProcRef = reference to procedure(const aValue: Integer);
  TStrFuncRef = reference to function(const aInput: String): String;

procedure ExecuteProc(const aProc: TProcRef);
begin
  aProc();
end;

function ApplyFunc(const aFunc: TIntFuncRef): Integer;
begin
  Result := aFunc();
end;

procedure TestAnonymousProcedure;
var
  LProc: TProcRef;
  LCount: Integer;
begin
  LCount := 0;
  LProc := procedure
           begin
             Inc(LCount);
           end;
  LProc();
  LProc();
end;

procedure TestAnonymousFunction;
var
  LFunc: TIntFuncRef;
  LResult: Integer;
begin
  LFunc := function: Integer
           begin
             Result := 42;
           end;
  LResult := LFunc();

  LFunc := function: Integer
           begin
             Result := LResult * 2;
           end;
  LFunc();
end;

procedure TestClosure;
var
  LCounter: Integer;
  LIncrement: TProcRef;
  LDecrement: TProcRef;
  LGetValue: TIntFuncRef;
begin
  LCounter := 0;

  LIncrement := procedure
                begin
                  Inc(LCounter);
                end;

  LDecrement := procedure
                begin
                  Dec(LCounter);
                end;

  LGetValue := function: Integer
               begin
                 Result := LCounter;
               end;

  LIncrement();
  LIncrement();
  LIncrement();
  LDecrement();
  LGetValue();
end;

procedure TestMethodReference;
var
  LProcs: TArray<TIntProcRef>;
  i: Integer;
begin
  SetLength(LProcs, 3);
  for i := 0 to High(LProcs) do
  begin
    LProcs[i] := procedure(const aValue: Integer)
                 begin
                 end;
    LProcs[i](i * 10);
  end;
end;

procedure TestNestedAnonymousMethods;
var
  LOuter: TProcRef;
  LInner: TProcRef;
  LSharedValue: Integer;
begin
  LSharedValue := 0;

  LOuter := procedure
            begin
              LInner := procedure
                        begin
                          Inc(LSharedValue, 10);
                        end;
              Inc(LSharedValue);
              LInner();
            end;

  LOuter();
  LOuter();
end;

procedure TestAnonymousMethodAsParameter;
var
  LFunc: TStrFuncRef;
begin
  ExecuteProc(procedure
              begin
              end);

  ApplyFunc(function: Integer
            begin
              Result := 99;
            end);

  LFunc := function(const aInput: String): String
           begin
             Result := UpperCase(aInput);
           end;
  LFunc('hello');
end;

end.
