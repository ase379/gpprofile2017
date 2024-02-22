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


const
  cProfUnitName  = 'GpProf';


implementation

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

end.
