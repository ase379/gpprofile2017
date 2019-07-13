unit gpParser.Defines;

interface

uses
  System.Classes;

type

  TDefineList = class
  strict private
    fDefines: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Define(const aCondition: string);
    procedure Undefine(const aCondition: string);
    function IsDefined(const aCondition: string): boolean;
    procedure Assign(const aConditions: string);

    class function ToKey(const aCondition: string): string; static;
  end;


implementation

uses
  System.SysUtils, GpString;

{ ========================= TDefineList ========================= }

constructor TDefineList.Create;
begin
  inherited Create;
  fDefines := TStringList.Create;
  fDefines.Sorted := true;
end;

procedure TDefineList.Define(const aCondition: string);
begin
  if not IsDefined(aCondition) then
    fDefines.Add(ToKey(aCondition));
end;

destructor TDefineList.Destroy;
begin
  fDefines.Free;
  inherited Destroy;
end;

function TDefineList.IsDefined(const aCondition: string): boolean;
begin
  Result := (fDefines.IndexOf(ToKey(aCondition)) >= 0);
end;

class function TDefineList.ToKey(const aCondition: string): string;
begin
  result := UpperCase(aCondition);
end;

procedure TDefineList.Undefine(const aCondition: string);
var
  idx: Integer;
begin
  idx := fDefines.IndexOf(ToKey(aCondition));
  if idx >= 0 then
    fDefines.Delete(idx);
end;

procedure TDefineList.Assign(const aConditions: string);
var
  i: Integer;
begin
  fDefines.Clear;
  for i := 1 to NumElements(aConditions, ';', -1) do
    Define(NthEl(aConditions, i, ';', -1));
end;




end.
