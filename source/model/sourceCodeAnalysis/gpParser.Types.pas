unit gpParser.Types;

interface

uses
  System.SysUtils, System.Generics.Collections;

type
  // Do not change order
  TCommentType = (Ct_Arrow = 0, Ct_IfDef = 1);

  // class TBaseUnit is needed for decoupling unit references between TProject and TUnit
  TBaseUnit = class(tobject);
  EUnitInSearchPathNotFoundError = class(Exception);

  TBooleanStack = class(TStack<Boolean>)
  public
    function PeekOrReturnFalseIfEmpy(): boolean;
    procedure PopIfNotEmpty();
  end;

  TUnitInstrumentationInfo = class
    UnitName : string;
    IsFullyInstrumented: boolean;
    IsNothingInstrumented: boolean;
  end;

  TProcedureInstrumentationInfo = class
    ProcedureName : string;
    ClassName : string;
    ClassMethodName : string;
    IsInstrumentedOrCheckedForInstrumentation: boolean;
  end;


  TUnitInstrumentationInfoList = class(TObjectList<TUnitInstrumentationInfo>)
  public
    procedure SortByName();
  end;

  TProcedureInstrumentationInfoList = class(TObjectList<TProcedureInstrumentationInfo>)
    procedure SortByName();
  end;

const
  cProfUnitName  = 'GpProf';


implementation

uses
  System.Generics.Defaults;

{ TBooleanStack }

function TBooleanStack.PeekOrReturnFalseIfEmpy: boolean;
begin
  result := false;
  if (self.Count > 0) then
    result := self.peek();
end;

procedure TBooleanStack.PopIfNotEmpty;
begin
 if (self.Count > 0) then
  self.Pop();
end;

{ TUnitInstrumentationInfoList }

procedure TUnitInstrumentationInfoList.SortByName;
begin
  Sort(TComparer<TUnitInstrumentationInfo>.Construct(
      function (const Left, Right: TUnitInstrumentationInfo): integer
      begin
          Result := CompareText(Left.UnitName,Right.UnitName);
      end));
end;

{ TProcedureInstrumentationInfoList }

procedure TProcedureInstrumentationInfoList.SortByName;
begin
Sort(TComparer<TProcedureInstrumentationInfo>.Construct(
      function (const Left, Right: TProcedureInstrumentationInfo): integer
      begin
          Result := CompareText(Left.ProcedureName,Right.ProcedureName);
      end));
end;

end.
