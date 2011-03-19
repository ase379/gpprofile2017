{+--------------------------------------------------------------------------+
 | Unit:        mwSupportClasses
 | Last change: 1999-09-02
 | Description: Supporting classes for mwCustomEdit.
 | Version:     0.86
 +--------------------------------------------------------------------------+}

unit mwSupportClasses;

{$I MWEDIT.INC}

interface

uses Windows, Classes, Graphics;

type
  TmwSelectedColor = class(TPersistent)
  private
    fBG: TColor;
    fFG: TColor;
    fOnChange: TNotifyEvent;
    procedure SetBG(Value: TColor);
    procedure SetFG(Value: TColor);
  public
    constructor Create;
  published
    property Background: TColor read fBG write SetBG default clHighLight;
    property Foreground: TColor read fFG write SetFG default clHighLightText;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

  TmwGutter = class(TPersistent)
  private
    fColor: TColor;
    fWidth: integer;
    fShowLineNumbers: boolean;
    fDigitCount: integer;
    fLeadingZeros: boolean;
    fZeroStart: boolean;
    fLeftOffset: integer;
    fRightOffset: integer;
    fOnChange: TNotifyEvent;
    procedure SetColor(const Value: TColor);
    procedure SetDigitCount(Value: integer);
    procedure SetLeadingZeros(const Value: boolean);
    procedure SetLeftOffset(Value: integer);
    procedure SetRightOffset(Value: integer);
    procedure SetShowLineNumbers(const Value: boolean);
    procedure SetWidth(Value: integer);
    procedure SetZeroStart(const Value: boolean);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    function FormatLineNumber(Line: integer): string;
    function RealGutterWidth(CharWidth: integer): integer;
  published
    property Color: TColor read fColor write SetColor default clBtnFace;
    property DigitCount: integer read fDigitCount write SetDigitCount
                                                  default 4;
    property LeadingZeros: boolean read fLeadingZeros write SetLeadingZeros
                                                      default FALSE;
    property LeftOffset: integer read fLeftOffset write SetLeftOffset
                                                  default 16;
    property RightOffset: integer read fRightOffset write SetRightOffset
                                                    default 2;
    property ShowLineNumbers: boolean read fShowLineNumbers
                                      write SetShowLineNumbers default FALSE;
    property Width: integer read fWidth write SetWidth default 30;
    property ZeroStart: boolean read fZeroStart write SetZeroStart default FALSE;
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
  end;

implementation

uses SysUtils, mwSupportProcs;

{ TmwSelectedColor }

constructor TmwSelectedColor.Create;
begin
  inherited Create;
  fBG := clHighLight;
  fFG := clHighLightText;
end;

procedure TmwSelectedColor.SetBG(Value: TColor);
begin
  if (fBG <> Value) then begin
    fBG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwSelectedColor.SetFG(Value: TColor);
begin
  if (fFG <> Value) then begin
    fFG := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

{ TmwGutter }

constructor TmwGutter.Create;
begin
  inherited Create;
  fColor := clBtnFace;
  fWidth := 30;
  fShowLineNumbers := FALSE;
  fLeadingZeros := FALSE;
  fZeroStart := FALSE;
  fLeftOffset := 16;
  fDigitCount := 4;
  fRightOffset := 2;
end;

procedure TmwGutter.Assign(Source: TPersistent);
var src: TmwGutter absolute Source;
begin
  if Assigned(Source) and (Source is TmwGutter) then begin
    fColor := src.fColor;
    fWidth := src.fWidth;
    fShowLineNumbers := src.fShowLineNumbers;
    fLeadingZeros := src.fLeadingZeros;
    fZeroStart := src.fZeroStart;
    fLeftOffset := src.fLeftOffset;
    fDigitCount := src.fDigitCount;
    fRightOffset := src.fRightOffset;
    if Assigned(fOnChange) then fOnChange(Self);
  end else
    inherited;
end;

function TmwGutter.FormatLineNumber(Line: integer): string;
var i: integer;
begin
  if fZeroStart then Dec(Line);
  Str(Line : fDigitCount, Result);
  if fLeadingZeros then
    for i := 1 to fDigitCount - 1 do begin
      if (Result[i] <> ' ') then break;
      Result[i] := '0';
    end;
end;

function TmwGutter.RealGutterWidth(CharWidth: integer): integer;
begin
  if fShowLineNumbers then
    Result := fLeftOffset + fRightOffset + fDigitCount * CharWidth + 2
  else
    Result := fWidth;
end;

procedure TmwGutter.SetColor(const Value: TColor);
begin
  if fColor <> Value then begin
    fColor := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetDigitCount(Value: integer);
begin
  Value := MinMax(Value, 2, 12);
  if fDigitCount <> Value then begin
    fDigitCount := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetLeadingZeros(const Value: boolean);
begin
  if fLeadingZeros <> Value then begin
    fLeadingZeros := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetLeftOffset(Value: integer);
begin
  Value := Max(0, Value);
  if fLeftOffset <> Value then begin
    fLeftOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetRightOffset(Value: integer);
begin
  Value := Max(0, Value);
  if fRightOffset <> Value then begin
    fRightOffset := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetShowLineNumbers(const Value: boolean);
begin
  if fShowLineNumbers <> Value then begin
    fShowLineNumbers := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetWidth(Value: integer);
begin
  Value := Max(0, Value);
  if fWidth <> Value then begin
    fWidth := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

procedure TmwGutter.SetZeroStart(const Value: boolean);
begin
  if fZeroStart <> Value then begin
    fZeroStart := Value;
    if Assigned(fOnChange) then fOnChange(Self);
  end;
end;

end.
