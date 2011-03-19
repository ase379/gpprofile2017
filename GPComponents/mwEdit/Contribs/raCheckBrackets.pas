//------------------------------------------------------------------------------
//- created: Ra --> 1999-09-20
//------------------------------------------------------------------------------

unit raCheckBrackets;

interface
uses Classes, StdCtrls, mwCustomEdit;

type

  TraCheckBrackets = class(TComponent)
    protected
      FMemo       : TmwCustomEdit;

      procedure SetMemo(aMemo: TmwCustomEdit);
      procedure Notification(AComponent: TComponent; Operation: TOperation); override;
      procedure SearchForward(aopBracket: String);
      procedure SearchBackward(aopBracket: String);

    public
      constructor Create(AOwner: TComponent); override;
      destructor  Destroy; override;

      procedure FindBracket;

    published
      property Memo: TmwCustomEdit read FMemo write SetMemo;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('mw', [TraCheckBrackets]);
end;

//////////////////////////////////////////////
//
//   class TraCheckBrackets
//
//////////////////////////////////////////////

//------------------------------------------------------------------------------
constructor TraCheckBrackets.Create(AOwner: TComponent );
begin
  inherited Create( AOwner );
end;

//------------------------------------------------------------------------------
destructor  TraCheckBrackets.Destroy;
begin
  inherited Destroy;
end;

//------------------------------------------------------------------------------
procedure TraCheckBrackets.SetMemo(aMemo: TmwCustomEdit );
begin
  FMemo := aMemo;
end;

//------------------------------------------------------------------------------
procedure TraCheckBrackets.SearchForward(aopBracket: String);
var
    iStart     : Integer;
    iLength    : Integer;
    opBracket  : Integer;
    iCount     : Integer;
    sText      : String;
    sclBracket : String;
begin

    if aopBracket = '(' then sclBracket := ')'
  else
    if aopBracket = '[' then sclBracket := ']'
  else
    if aopBracket = '{' then sclBracket := '}';

  with FMemo do
  begin
    iStart    := GetSelStart;
    iLength   := GetTextLen - iStart;
    sText     := Copy(Text,iStart,iLength);
    opBracket := 0;

    //Count the Open-Brackets
    for iCount := 0 to iLength-1 do
      if sText[iCount] = aopBracket then inc(opBracket)
      else
      if sText[iCount] = sclBracket then Break;

    //Count the Close-Brackets
    for iCount := 0 to iLength-1 do
    begin
      if sText[iCount] = sclBracket then
      begin
        dec(opBracket);
        if opBracket = 0 then
        begin
          SetSelStart(iCount+iStart-1);
          SetSelEnd(iCount+iStart);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TraCheckBrackets.SearchBackward(aopBracket: String);
var
    iStart     : Integer;
    iEnd       : Integer;
    iLength    : Integer;
    opBracket  : Integer;
    iCount     : Integer;
    sText      : String;
    sclBracket : String;
begin

    if aopBracket = ')' then sclBracket := '('
  else
    if aopBracket = ']' then sclBracket := '['
  else
    if aopBracket = '}' then sclBracket := '{';

  with FMemo do
  begin
    iStart    := 0;
    iEnd      := GetSelEnd;
    iLength   := iEnd - iStart;
    sText     := Copy(Text,iStart,iLength);
    opBracket := 0;

    //Count the Close-Brackets
    for iCount := iLength-1 downto 0 do
      if sText[iCount] = aopBracket then inc(opBracket)
      else
      if sText[iCount] = sclBracket then Break;

    //Count the Open-Brackets
    for iCount := iLength-1 downto 0 do
    begin
      if sText[iCount] = sclBracket then
      begin
        dec(opBracket);
        if opBracket = 0 then
        begin
          SetSelStart(iCount+iStart+1);
          SetSelEnd(iCount+iStart);
        end;
      end;
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure TraCheckBrackets.FindBracket;
begin
  with FMemo do
    if (SelText = '(') or (SelText = '[') or (SelText = '{') then
      SearchForward(SelText)
    else
    if (SelText = ')') or (SelText = ']') or (SelText = '}') then
      SearchBackward(SelText);
end;

//------------------------------------------------------------------------------
procedure TraCheckBrackets.Notification(AComponent: TComponent; Operation: TOperation);
begin
  if Operation = opRemove then
    if FMemo = AComponent then
       FMemo := nil;
  inherited;
end;

end.
