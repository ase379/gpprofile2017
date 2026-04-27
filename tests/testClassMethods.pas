unit testClassMethods;

/// <summary>
/// Tests parser coverage for class-based Delphi constructs:
/// - Abstract base classes and virtual methods
/// - Constructors and destructors
/// - Class methods and class static methods
/// - Property getters and setters
/// - Method overloading
/// - Class helpers
/// - Records with methods and operator overloading
/// - Override and virtual dispatch
/// </summary>

interface

type
  TAbstractBase = class
  public
    procedure AbstractMethod; virtual; abstract;
    function AbstractFunction: Integer; virtual; abstract;
    procedure VirtualMethod; virtual;
    class procedure ClassStaticProc; static;
    class function ClassFactory: TAbstractBase; virtual;
  end;

  TConcreteClass = class(TAbstractBase)
  private
    fField: Integer;
    fName: String;
    function GetField: Integer;
    procedure SetField(const aValue: Integer);
    function GetName: String;
  public
    constructor Create(const aField: Integer; const aName: String = '');
    destructor Destroy; override;
    procedure AbstractMethod; override;
    function AbstractFunction: Integer; override;
    procedure VirtualMethod; override;
    class function ClassFactory: TAbstractBase; override;
    function Overloaded(const aA, aB: Integer): Integer; overload;
    function Overloaded(const aValue: Double): Double; overload;
    procedure Overloaded(const aText: String); overload;
    property Field: Integer read GetField write SetField;
    property Name: String read GetName;
  end;

  TClassHelper = class helper for TConcreteClass
    procedure HelperProc;
    function HelperFunc: String;
    class procedure HelperClassProc;
  end;

  TRecordWithMethods = record
    Value: Integer;
    procedure Increment;
    procedure Decrement(const aSteps: Integer);
    function IsPositive: Boolean;
    function ToString: String;
    class operator Add(const aA, aB: TRecordWithMethods): TRecordWithMethods;
    class operator Equal(const aA, aB: TRecordWithMethods): Boolean;
  end;

procedure TestConcreteClassCreation;
procedure TestClassHelper;
procedure TestRecordWithMethods;
procedure TestClassStaticProc;
procedure TestOverloadedMethods;
procedure TestVirtualDispatch;

implementation

uses
  System.SysUtils;

{ TAbstractBase }

procedure TAbstractBase.VirtualMethod;
begin
end;

class procedure TAbstractBase.ClassStaticProc;
begin
end;

class function TAbstractBase.ClassFactory: TAbstractBase;
begin
  Result := nil;
end;

{ TConcreteClass }

constructor TConcreteClass.Create(const aField: Integer; const aName: String);
begin
  inherited Create;
  fField := aField;
  fName := aName;
end;

destructor TConcreteClass.Destroy;
begin
  inherited Destroy;
end;

function TConcreteClass.GetField: Integer;
begin
  Result := fField;
end;

procedure TConcreteClass.SetField(const aValue: Integer);
begin
  fField := aValue;
end;

function TConcreteClass.GetName: String;
begin
  Result := fName;
end;

procedure TConcreteClass.AbstractMethod;
begin
end;

function TConcreteClass.AbstractFunction: Integer;
begin
  Result := fField;
end;

procedure TConcreteClass.VirtualMethod;
begin
  inherited VirtualMethod;
end;

class function TConcreteClass.ClassFactory: TAbstractBase;
begin
  Result := TConcreteClass.Create(0);
end;

function TConcreteClass.Overloaded(const aA, aB: Integer): Integer;
begin
  Result := aA + aB;
end;

function TConcreteClass.Overloaded(const aValue: Double): Double;
begin
  Result := aValue * 2.0;
end;

procedure TConcreteClass.Overloaded(const aText: String);
begin
end;

{ TClassHelper }

procedure TClassHelper.HelperProc;
begin
  Field := Field + 1;
end;

function TClassHelper.HelperFunc: String;
begin
  Result := Name + ':' + IntToStr(Field);
end;

class procedure TClassHelper.HelperClassProc;
begin
end;

{ TRecordWithMethods }

procedure TRecordWithMethods.Increment;
begin
  Inc(Value);
end;

procedure TRecordWithMethods.Decrement(const aSteps: Integer);
begin
  Dec(Value, aSteps);
end;

function TRecordWithMethods.IsPositive: Boolean;
begin
  Result := Value > 0;
end;

function TRecordWithMethods.ToString: String;
begin
  Result := IntToStr(Value);
end;

class operator TRecordWithMethods.Add(const aA, aB: TRecordWithMethods): TRecordWithMethods;
begin
  Result.Value := aA.Value + aB.Value;
end;

class operator TRecordWithMethods.Equal(const aA, aB: TRecordWithMethods): Boolean;
begin
  Result := aA.Value = aB.Value;
end;

{ Test procedures }

procedure TestConcreteClassCreation;
var
  LObj: TConcreteClass;
begin
  LObj := TConcreteClass.Create(42, 'TestObj');
  try
    LObj.AbstractMethod;
    LObj.VirtualMethod;
    LObj.Field := 100;
  finally
    LObj.Free;
  end;
end;

procedure TestClassHelper;
var
  LObj: TConcreteClass;
begin
  LObj := TConcreteClass.Create(10);
  try
    LObj.HelperProc;
    LObj.HelperFunc;
    TClassHelper.HelperClassProc;
  finally
    LObj.Free;
  end;
end;

procedure TestRecordWithMethods;
var
  LRec, LRec2, LRec3: TRecordWithMethods;
begin
  LRec.Value := 5;
  LRec.Increment;
  LRec.Decrement(2);
  LRec.IsPositive;
  LRec.ToString;

  LRec2.Value := 3;
  LRec3 := LRec + LRec2;

  if LRec = LRec2 then
    ;
end;

procedure TestClassStaticProc;
var
  LBase: TAbstractBase;
begin
  TAbstractBase.ClassStaticProc;
  LBase := TConcreteClass.ClassFactory;
  LBase.Free;
end;

procedure TestOverloadedMethods;
var
  LObj: TConcreteClass;
begin
  LObj := TConcreteClass.Create(0);
  try
    LObj.Overloaded(1, 2);
    LObj.Overloaded(3.14);
    LObj.Overloaded('hello');
  finally
    LObj.Free;
  end;
end;

procedure TestVirtualDispatch;
var
  LBase: TAbstractBase;
begin
  LBase := TConcreteClass.Create(7);
  try
    LBase.VirtualMethod;
  finally
    LBase.Free;
  end;
end;

end.
