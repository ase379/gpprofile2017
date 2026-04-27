unit testNestedProcedures;

/// <summary>
/// Tests parser coverage for nested procedure/function constructs:
/// - Nested procedure inside a procedure
/// - Nested function inside a function
/// - Multiple nested procedures at the same level
/// - Deeply nested (3+ levels)
/// - Nested procedures with parameters
/// - Nested functions returning values
/// - Nested procedures accessing outer scope variables
/// </summary>

interface

procedure TestNestedProcedure;
procedure TestNestedFunction;
procedure TestMultipleNestedAtSameLevel;
procedure TestDeepNesting;
procedure TestNestedAccessingOuter;
procedure TestNestedWithForwardDeclaration;

implementation

uses
  System.SysUtils;

procedure TestNestedProcedure;
  procedure InnerProc;
  begin
  end;

  procedure InnerProcWithParams(const aValue: Integer; const aName: String);
  begin
  end;

begin
  InnerProc;
  InnerProcWithParams(42, 'test');
end;

procedure TestNestedFunction;
  function InnerFunc(const aValue: Integer): Integer;
  begin
    Result := aValue * 2;
  end;

  function InnerFuncNoParams: String;
  begin
    Result := 'inner';
  end;

  function InnerFuncWithResult(const aA, aB: Integer): Boolean;
  begin
    Result := aA > aB;
  end;

begin
  InnerFunc(5);
  InnerFuncNoParams;
  InnerFuncWithResult(3, 7);
end;

procedure TestMultipleNestedAtSameLevel;
  procedure First;
  begin
  end;

  procedure Second;
  begin
  end;

  procedure Third;
  begin
  end;

  function FourthFunc: Integer;
  begin
    Result := 0;
  end;

begin
  First;
  Second;
  Third;
  FourthFunc;
end;

procedure TestDeepNesting;
  procedure Level1;
    procedure Level2;
      procedure Level3;
        procedure Level4;
        begin
        end;
      begin
        Level4;
      end;
    begin
      Level3;
    end;
  begin
    Level2;
  end;

begin
  Level1;
end;

procedure TestNestedAccessingOuter;
var
  LOuterValue: Integer;
  LOuterName: String;

  procedure InnerModify;
  begin
    LOuterValue := LOuterValue + 1;
    LOuterName := LOuterName + '!';
  end;

  function InnerRead: String;
  begin
    Result := LOuterName + IntToStr(LOuterValue);
  end;

begin
  LOuterValue := 10;
  LOuterName := 'test';
  InnerModify;
  InnerModify;
  InnerRead;
end;

procedure TestNestedWithForwardDeclaration;
  procedure Inner1; forward;

  procedure Inner2;
  begin
    Inner1;
  end;

  procedure Inner1;
  begin
  end;

begin
  Inner2;
  Inner1;
end;

end.
