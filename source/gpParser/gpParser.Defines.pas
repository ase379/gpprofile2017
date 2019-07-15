unit gpParser.Defines;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TSkippedCodeRec = record
  public
    SkippedCodeSegment : Boolean;
    IsIfOpt : Boolean;
  end;

  TSkippedCodeRecList = class
  private
    fSkippedList : TList<TSkippedCodeRec>;
    fSkippingCode : Boolean;
    procedure PushSkippingState(const isIfOPT: boolean);
    function  PopSkippingState: boolean;
    function  WasSkipping: boolean;
    function  InIFOPT: boolean;
  public
    constructor Create();
    destructor Destroy; override;

    procedure Reset();

    procedure TriggerIfDef(const aIsDefineSet : Boolean);
    procedure TriggerIfNDef(const aIsDefineSet : Boolean);
    procedure TriggerIfOpt();
    procedure TriggerElse();
    procedure TriggerEndIf();

    property SkippingCode : boolean read fSkippingCode write fSkippingCode;
  end;

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

{ TSkippedCodeRecList }

constructor TSkippedCodeRecList.Create;
begin
  inherited Create();
  fSkippedList := TList<TSkippedCodeRec>.Create();
end;

destructor TSkippedCodeRecList.Destroy;
begin
  fSkippedList.Free;
  inherited;
end;

procedure TSkippedCodeRecList.Reset;
begin
  fSkippedList.Clear;
  fSkippingCode := false;
end;


procedure TSkippedCodeRecList.TriggerElse;
begin
  if (not self.InIFOPT) and (not self.WasSkipping) then
    self.fSkippingCode := not self.fSkippingCode;
end;

procedure TSkippedCodeRecList.TriggerEndIf;
begin
  self.SkippingCode := self.PopSkippingState;
end;

procedure TSkippedCodeRecList.TriggerIfDef(const aIsDefineSet : Boolean);
begin
  self.PushSkippingState(False);
  self.fSkippingCode := self.fSkippingCode or (not aIsDefineSet);
end;

procedure TSkippedCodeRecList.TriggerIfNDef(const aIsDefineSet : Boolean);
begin
  self.PushSkippingState(False);
  self.SkippingCode := self.SkippingCode or aIsDefineSet;
end;

procedure TSkippedCodeRecList.TriggerIfOpt();
begin
  Self.PushSkippingState(true);
end;

procedure TSkippedCodeRecList.PushSkippingState(const isIfOPT: boolean);
var
  LRec : TSkippedCodeRec;
begin
  LRec := default(TSkippedCodeRec);
  LRec.SkippedCodeSegment := fSkippingCode;
  LRec.IsIfOpt := isIfOPT;
  fSkippedList.Add(LRec);
end;

function TSkippedCodeRecList.PopSkippingState: boolean;
var
  LRec : TSkippedCodeRec;
begin
  if fSkippedList.Count = 0 then
    Result := true // source damaged - skip the rest
  else
  begin
    LRec := fSkippedList.Last;
    fSkippedList.Delete(fSkippedList.Count - 1);
    Result := LRec.SkippedCodeSegment;
  end;
end;


function TSkippedCodeRecList.WasSkipping: boolean;
begin
  if fSkippedList.Count = 0 then
    Result := False
  else
    Result := fSkippedList.Last.SkippedCodeSegment;
end;

function TSkippedCodeRecList.InIFOPT: boolean;
begin
  if fSkippedList.Count = 0 then
    Result := False // should not happen, but ...
  else
    Result := fSkippedList.Last.IsIfOpt;
end;



end.
