unit gpParser.Defines;

interface

uses
  System.Classes, System.Generics.Collections;

type
  TSkippedCodeIfType = (IFDEF_Based, IF_Based);
  TSkippedCodeEndType = (ENDIF_Based, IFEND_Based);

  TSkippedCodeRec = record
  public
    IFType : TSkippedCodeIfType;
    /// <summary>
    /// The skipped state of the entry.
    /// </summary>
    SkippedCodeSegment : Boolean;
    /// <summary>
    /// Describes whether the code is skipped/not skipped because of an IFOPT.
    /// </summary>
    IsIfOpt : Boolean;
  end;

  /// <summary>
  /// A class describing the conditional defines and the current skip state of the parser:
  /// whether code is skipped while reading or not.
  /// </summary>
  TSkippedCodeRecList = class
  private
    fSkippedList : TList<TSkippedCodeRec>;
    fSkippingCode : Boolean;
    procedure PushSkippingState(const aIfType : TSkippedCodeIfType;const isIfOPT: boolean);
    function  PopSkippingState(const aEndType : TSkippedCodeEndType): boolean;

    function  WasSkipping: boolean;
    function  InIFOPT: boolean;
  public
    constructor Create();
    destructor Destroy; override;

    /// <summary>
    /// Triggers a {$IFDEF a}
    /// </summary>
    procedure TriggerIfDef(const aIsDefineSet : Boolean);

    /// <summary>
    /// Triggers a {$IFNDEF a}
    /// </summary>
    procedure TriggerIfNDef(const aIsDefineSet : Boolean);

    /// <summary>
    /// Triggers a {$IFOPT R-}
    /// </summary>
    procedure TriggerIfOpt();

    /// <summary>
    /// Triggers a {$IF a AND b}
    /// </summary>
    procedure TriggerIf(const aIsDefineSet : Boolean);

    /// <summary>
    /// Triggers a {$ELSE}
    /// </summary>
    procedure TriggerElse();

    /// <summary>
    /// Triggers a {$ENDIF}
    /// </summary>
    procedure TriggerEndIf();

    /// <summary>
    /// Triggers a {$IFEND}
    /// </summary>
    procedure TriggerIfEnd();

    /// <summary>
    /// Describes whether code is currently skipped or not.
    /// </summary>
    property SkippingCode : boolean read fSkippingCode write fSkippingCode;
  end;

  TIfExpressionPart = (if_true, if_false, if_Or, if_And);
  TIfExpressionPartList = TList<TIfExpressionPart>;

  TDefineList = class
  strict private
    fDefines: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Define(const aCondition: string);
    procedure Undefine(const aCondition: string);
    function IsDefined(const aCondition: string): boolean;
    function IsTrue(const aList : TIfExpressionPartList): Boolean;
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

function TDefineList.IsTrue(const aList: TIfExpressionPartList): Boolean;
var
  I : integer;
  LLastOperator : TIfExpressionPart;
  LValue : TIfExpressionPart;
begin
  Result := aList.Count > 0;
  LLastOperator := if_true;  // make no sense, but must not be OR or AND
  for i := 0 to aList.Count-1 do
  begin
    LValue := aList[i];
    case LValue of
      if_Or,
      if_AND :
        begin
          LLastOperator := LValue;
        end;
      if_true,
      if_false:
        begin
          if i = 0 then
          begin
            result := (LValue = if_true);
          end
          else
          begin
            if LLastOperator = if_Or then
              Result := Result OR (LValue = if_true)
            else if LLastOperator = if_and then
              Result := Result AND (LValue = if_true);
          end;
        end;
    end;
  end;
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

procedure TSkippedCodeRecList.TriggerElse;
begin
  if (not self.InIFOPT) and (not self.WasSkipping) then
    self.fSkippingCode := not self.fSkippingCode;
end;

procedure TSkippedCodeRecList.TriggerEndIf;
begin
  self.SkippingCode := self.PopSkippingState(TSkippedCodeEndType.ENDIF_Based);
end;

procedure TSkippedCodeRecList.TriggerIf(const aIsDefineSet : Boolean);
begin
  self.PushSkippingState(IF_Based, false);
  self.fSkippingCode := self.fSkippingCode or (not aIsDefineSet);
end;

procedure TSkippedCodeRecList.TriggerIfEnd;
begin
  self.SkippingCode := self.PopSkippingState(TSkippedCodeEndType.IFEND_Based);
end;

procedure TSkippedCodeRecList.TriggerIfDef(const aIsDefineSet : Boolean);
begin
  self.PushSkippingState(IFDEF_Based, false);
  self.fSkippingCode := self.fSkippingCode or (not aIsDefineSet);
end;

procedure TSkippedCodeRecList.TriggerIfNDef(const aIsDefineSet : Boolean);
begin
  self.PushSkippingState(IFDEF_Based, false);
  self.SkippingCode := self.SkippingCode or aIsDefineSet;
end;

procedure TSkippedCodeRecList.TriggerIfOpt();
begin
  Self.PushSkippingState(IFDEF_Based, true);
end;

procedure TSkippedCodeRecList.PushSkippingState(const aIfType: TSkippedCodeIfType; const isIfOPT: boolean);
var
  LRec : TSkippedCodeRec;
begin
  LRec := default(TSkippedCodeRec);
  LRec.IFType := aIfType;
  LRec.SkippedCodeSegment := fSkippingCode;
  LRec.IsIfOpt := isIfOPT;
  fSkippedList.Add(LRec);
end;

function TSkippedCodeRecList.PopSkippingState(const aEndType: TSkippedCodeEndType): boolean;
var
  LRec : TSkippedCodeRec;
begin
  if fSkippedList.Count = 0 then
    Exit(True);    // source damaged - skip the rest
  // if based can be closed by endif or ifend
  case aEndType of
    ENDIF_Based,
    IFEND_Based :
    begin
      // - since XE4 or higher, the Delphi compilers were changed to accept either $IFEND or $ENDIF to close $IF
      //   statements.
      // - Before XE4, only $IFEND could be used to close $IF statements.
      //   The $LEGACYIFEND directive allows you to restore the old behavior, which is useful if your code is emitting
      //   E2029 related to nested $IF and $IFDEF statements.
      // -> as the project defines whether the code is compilable, we support the new style.
      LRec := fSkippedList.Last;
      fSkippedList.Remove(LRec);
      result := LRec.SkippedCodeSegment;
    end
  else
    raise Exception.Create('PopSkippingState: Invalid end type.');
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
