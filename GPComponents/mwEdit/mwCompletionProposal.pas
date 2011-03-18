{
  This unit is copyright Cyrille de Brebisson
}
unit mwCompletionProposal;

interface

uses graphics, forms, classes, stdctrls, controls, sysutils, mwCustomEdit, mwKeyCmds, windows;

type
  TCompletionProposalKeyPress = procedure (var Key: char) of object;
  TCompletionProposalPaintItem = Function (Key: String; Canvas: TCanvas; x, y: integer): Boolean of object;

  TCompletionProposalForm = class (TForm)
  Protected
    FCurrentString: String;
    FOnKeyPress: TCompletionProposalKeyPress;
    FOnKeyDelete: TNotifyEvent;
    FOnPaintItem: TCompletionProposalPaintItem;
    FItemList: TStrings;
    FPosition: Integer;
    FNbLinesInWindow: Integer;
    FFontHeight: integer;
    Scroll: TScrollBar;
    FOnValidate: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    FClSelect: TColor;
    FAnsi: boolean;
    procedure SetCurrentString(const Value: String);
    Procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: char); override;
    Procedure Paint; override;
    procedure ScrollGetFocus(Sender: TObject);
    Procedure Deactivate; override;
    procedure SelectPrec;
    procedure SelectNext;
    procedure ScrollChange(Sender: TObject);
    procedure SetItemList(const Value: TStrings);
    procedure SetPosition(const Value: Integer);
    procedure SetNbLinesInWindow(const Value: Integer);
    Procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    Procedure StringListChange(Sender: TObject);
  Public
    constructor Create(AOwner: Tcomponent); override;
    destructor destroy; override;
  Published
    Property CurrentString: String read FCurrentString write SetCurrentString;
    Property OnKeyPress: TCompletionProposalKeyPress read FOnKeyPress write FOnKeyPress;
    Property OnKeyDelete: TNotifyEvent read FOnKeyDelete write FOnKeyDelete;
    Property OnPaintItem: TCompletionProposalPaintItem read FOnPaintItem write FOnPaintItem;
    Property OnValidate: TNotifyEvent read FOnValidate write FOnValidate;
    Property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
    Property ItemList: TStrings read FItemList write SetItemList;
    Property Position: Integer read FPosition write SetPosition;
    Property NbLinesInWindow: Integer read FNbLinesInWindow write SetNbLinesInWindow;
    Property ClSelect: TColor read FClSelect write FClSelect;
    Property ffAnsi: boolean read fansi write fansi;
  end;

  TCompletionProposal = Class (TComponent)
  private
    Form: TCompletionProposalForm;
    FOnExecute: TNotifyEvent;
    function GetClSelect: TColor;
    procedure SetClSelect(const Value: TColor);
    function GetCurrentString: String;
    function GetItemList: TStrings;
    function GetNbLinesInWindow: Integer;
    function GetOnCancel: TNotifyEvent;
    function GetOnKeyPress: TCompletionProposalKeyPress;
    function GetOnPaintItem: TCompletionProposalPaintItem;
    function GetOnValidate: TNotifyEvent;
    function GetPosition: Integer;
    procedure SetCurrentString(const Value: String);
    procedure SetItemList(const Value: TStrings);
    procedure SetNbLinesInWindow(const Value: Integer);
    procedure SetOnCancel(const Value: TNotifyEvent);
    procedure SetOnKeyPress(const Value: TCompletionProposalKeyPress);
    procedure SetOnPaintItem(const Value: TCompletionProposalPaintItem);
    procedure SetPosition(const Value: Integer);
    procedure SetOnValidate(const Value: TNotifyEvent);
    function GetOnKeyDelete: TNotifyEvent;
    procedure SetOnKeyDelete(const Value: TNotifyEvent);
    procedure RFAnsi(const Value: boolean);
    function SFAnsi: boolean;
  Public
    Constructor Create(Aowner: TComponent); override;
    Destructor Destroy; Override;
    Procedure Execute(s: string; x, y: integer);
    Property OnKeyPress: TCompletionProposalKeyPress read GetOnKeyPress write SetOnKeyPress;
    Property OnKeyDelete: TNotifyEvent read GetOnKeyDelete write SetOnKeyDelete;
    Property OnValidate: TNotifyEvent read GetOnValidate write SetOnValidate;
    Property OnCancel: TNotifyEvent read GetOnCancel write SetOnCancel;
    Property CurrentString: String read GetCurrentString write SetCurrentString;
  Published
    Property OnExecute: TNotifyEvent read FOnExecute Write FOnExecute;
    Property OnPaintItem: TCompletionProposalPaintItem read GetOnPaintItem write SetOnPaintItem;
    Property ItemList: TStrings read GetItemList write SetItemList;
    Property Position: Integer read GetPosition write SetPosition;
    Property NbLinesInWindow: Integer read GetNbLinesInWindow write SetNbLinesInWindow;
    Property ClSelect: TColor read GetClSelect Write SetClSelect;
    Property AnsiStrings: boolean read SFAnsi Write RFAnsi;
  End;

  TMwCompletionProposal = class (TCompletionProposal)
  private
    FEditor: TmwCustomEdit;
    PrevEvent: TKeyEvent;
    PrevEvent1: TKeyPressEvent;
    NoNextKey: boolean;
    procedure SetEditor(const Value: TmwCustomEdit);
// moved to protected section to remove compiler hint                           //mh 1999-09-25
//    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure backspace(Senter: TObject);
    procedure Cancel(Senter: TObject);
    procedure Validate(Senter: TObject);
    procedure KeyPress(var Key: Char);
    Procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    Procedure EditorKeyPress(Sender: TObject; var Key: char);
    Function GetPreviousToken: string;
  protected                                                                     //mh 1999-09-25
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    Constructor Create(AOwner: TComponent); override;
  published
    Property Editor: TmwCustomEdit read FEditor write SetEditor;
  end;


  Procedure PretyTextOut(c: TCanvas; x, y: integer; s: String);

  Procedure register;

implementation

{ TCompletionProposalForm }

constructor TCompletionProposalForm.Create(AOwner: Tcomponent);
begin
{begin}                                                                         //mh 1999-09-25
// better way to create the form without loading the DFM
(*
  try
    inherited Create(aowner);
  except
  end;
*)
  CreateNew(AOwner);
{end}                                                                           //mh 1999-09-25

  FItemList:= TStringList.Create;
  BorderStyle:= bsNone;
  width:=262;
  Scroll:= TScrollBar.Create(self);
  Scroll.Kind:= sbVertical;
  Scroll.top:= 2;
  Scroll.left:= ClientWidth-Scroll.Width-2;
  Scroll.OnChange:= ScrollChange;
  Scroll.Parent:= self;
  Scroll.OnEnter:= ScrollGetFocus;
  Visible:= false;
  FFontHeight:= Canvas.TextHeight('Cyrille de Brebisson');
  NbLinesInWindow:= 6;
  ClSelect:= clAqua;
  TStringList(FItemList).OnChange:= StringListChange;
End;

procedure TCompletionProposalForm.Deactivate;
begin
  Visible:= False;
end;

destructor TCompletionProposalForm.destroy;
begin
  Scroll.Free;
  FItemList.Free;
  inherited destroy;
end;

procedure TCompletionProposalForm.KeyDown(var Key: Word; Shift: TShiftState);
begin
  case key of
    13: if Assigned(OnValidate) then
          OnValidate(Self);
    27,32: if Assigned(OnCancel) then
          OnCancel(Self);
    38: if ssCtrl in Shift then
           Position:= 0
        else
          SelectPrec;
    40: if ssCtrl in Shift then
           Position:= ItemList.count-1
        else
          SelectNext;
    8:  if Shift=[] then
        Begin
          if Length(CurrentString)<>0 then
            begin
              CurrentString:= copy(CurrentString,1,Length(CurrentString)-1);
              if Assigned(OnKeyDelete) then OnKeyDelete(Self);
            end;
          end;
  end;
  paint;
end;

procedure TCompletionProposalForm.KeyPress(var Key: char);
begin
  case key of    //
    #33..'z': Begin
                CurrentString:= CurrentString+key;
                if Assigned(OnKeyPress) then OnKeyPress(Key);
              end;
    #8: CurrentString:= CurrentString+key;
    else if Assigned(OnCancel) then OnCancel(Self);
  end;    // case
  paint;
end;

procedure TCompletionProposalForm.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  y:= (y-1) div FFontHeight;
  Position:= Scroll.Position+y;
end;

procedure TCompletionProposalForm.Paint;
var
  i: integer;
begin
  if ItemList.Count-NbLinesInWindow<0 then
    Scroll.Max:= 0
  else
    Scroll.Max:= ItemList.Count-NbLinesInWindow;
  Position:= Position;
  Scroll.LargeChange:= NbLinesInWindow;
  try
    canvas.pen.color:= ClBlack;
    canvas.brush.color:= color;
    canvas.Rectangle(0,0,Width,Height);
    For i:= 0 to NbLinesInWindow-1 do
    Begin
      if i+Scroll.Position=Position then
      Begin
        Canvas.Brush.Color:= ClSelect;
        Canvas.Pen.Color:= ClSelect;
        Canvas.Rectangle(1, FFontHeight*i+1, width-2, FFontHeight*(i+1)+1);
        Canvas.Pen.Color:= ClBlack;
      end else
        Canvas.Brush.Color:= Color;

      if i >= ItemList.Count then break;                                        //mh 1999-09-25
      
      if not Assigned(OnPaintItem) or not OnPaintItem(ItemList[Scroll.Position+i], Canvas, 1, FFontHeight*i+1) then
        PretyTextOut(Canvas, 1, FFontHeight*i+1, ItemList[Scroll.Position+i]);
    end;
    Canvas.Pen.Color:= ClBlack;
    Canvas.Moveto(0, 0);
    Canvas.LineTo(Width, 0);
    Canvas.LineTo(Width, Height);
    Canvas.LineTo(0, Height);
    Canvas.LineTo(0, 0);
  except
  end;
end;

procedure TCompletionProposalForm.ScrollChange(Sender: TObject);
begin
  if Position < Scroll.Position then
    Position:= Scroll.Position
  else if Position > Scroll.Position+NbLinesInWindow-1 then
    Position:= Scroll.Position+NbLinesInWindow-1;
  Paint;
end;

procedure TCompletionProposalForm.ScrollGetFocus(Sender: TObject);
begin
  ActiveControl:= nil;
end;

procedure TCompletionProposalForm.SelectNext;
begin
  if Position<ItemList.Count-1 then
    Position:= Position+1;
end;

procedure TCompletionProposalForm.SelectPrec;
begin
  if Position>0 then
    Position:= Position-1;
end;

procedure TCompletionProposalForm.SetCurrentString(const Value: String);
var
  i: integer;
begin
  FCurrentString := Value;
//  i:= Position;
  i:= 0;
  if ffansi then
    while (i<=ItemList.count-1) and (AnsiCompareText(ItemList[i],Value)<0) do
      inc(i)
  else
    while (i<=ItemList.count-1) and (ItemList[i]<Value) do
      inc(i);
  if i<=ItemList.Count-1 then
    Position:= i;
end;

procedure TCompletionProposalForm.SetItemList(const Value: TStrings);
begin
  FItemList.Assign(Value);
end;

procedure TCompletionProposalForm.SetNbLinesInWindow(const Value: Integer);
begin
  FNbLinesInWindow := Value;
  Height:= fFontHeight * NbLinesInWindow + 2;
  Scroll.Height:= Height-3;
end;

procedure TCompletionProposalForm.SetPosition(const Value: Integer);
begin
  if Value<=ItemList.Count-1 then
  Begin
    if FPosition<>Value then
    Begin
      FPosition := Value;
      if Position<Scroll.Position then
        Scroll.Position:= Position
      else
        if Scroll.Position < Position-NbLinesInWindow+1 then
          Scroll.Position:= Position-NbLinesInWindow+1;
      invalidate;
    end;
  end;
end;

procedure TCompletionProposalForm.StringListChange(Sender: TObject);
begin
  if ItemList.Count-NbLinesInWindow<0 then
    Scroll.Max:= 0
  else
    Scroll.Max:= ItemList.Count-NbLinesInWindow;
  Position:= Position;
end;

{ TCompletionProposal }

constructor TCompletionProposal.Create(Aowner: TComponent);
begin
  Inherited Create(AOwner);
  Form:= TCompletionProposalForm.Create(Self);
end;

destructor TCompletionProposal.Destroy;
begin
  form.Free;
  Inherited Destroy;
end;

procedure TCompletionProposal.Execute(s: string; x, y: integer);
begin
  form.top:= y;
  form.left:= x;
  CurrentString:= s;
  if assigned(OnExecute) then
    OnExecute(Self);
  form.Show;
end;

function TCompletionProposal.GetCurrentString: String;
begin
  result:= Form.CurrentString;
end;

function TCompletionProposal.GetItemList: TStrings;
begin
  result:= Form.ItemList;
end;

function TCompletionProposal.GetNbLinesInWindow: Integer;
begin
  Result:= Form.NbLinesInWindow;
end;

function TCompletionProposal.GetOnCancel: TNotifyEvent;
begin
  Result:= Form.OnCancel;
end;

function TCompletionProposal.GetOnKeyPress: TCompletionProposalKeyPress;
begin
  Result:= Form.OnKeyPress;
end;

function TCompletionProposal.GetOnPaintItem: TCompletionProposalPaintItem;
begin
  Result:= Form.OnPaintItem;
end;

function TCompletionProposal.GetOnValidate: TNotifyEvent;
begin
  Result:= Form.OnValidate;
end;

function TCompletionProposal.GetPosition: Integer;
begin
  Result:= Form.Position;
end;

procedure TCompletionProposal.SetCurrentString(const Value: String);
begin
  form.CurrentString:= Value;
end;

procedure TCompletionProposal.SetItemList(const Value: TStrings);
begin
  form.ItemList:= Value;
end;

procedure TCompletionProposal.SetNbLinesInWindow(const Value: Integer);
begin
  form.NbLinesInWindow:= Value;
end;

procedure TCompletionProposal.SetOnCancel(const Value: TNotifyEvent);
begin
  form.OnCancel:= Value;
end;

procedure TCompletionProposal.SetOnKeyPress(const Value: TCompletionProposalKeyPress);
begin
  form.OnKeyPress:= Value;
end;

procedure TCompletionProposal.SetOnPaintItem(const Value: TCompletionProposalPaintItem);
begin
  form.OnPaintItem:= Value;
end;

procedure TCompletionProposal.SetPosition(const Value: Integer);
begin
  form.Position:= Value;
end;

procedure TCompletionProposal.SetOnValidate(const Value: TNotifyEvent);
begin
  form.OnValidate:= Value;
end;

function TCompletionProposal.GetClSelect: TColor;
begin
  Result:= Form.ClSelect;
end;

procedure TCompletionProposal.SetClSelect(const Value: TColor);
begin
  Form.ClSelect:= Value;
end;

function TCompletionProposal.GetOnKeyDelete: TNotifyEvent;
begin
  result:= Form.OnKeyDelete;
end;

procedure TCompletionProposal.SetOnKeyDelete(const Value: TNotifyEvent);
begin
  form.OnKeyDelete:= Value;
end;

procedure TCompletionProposal.RFAnsi(const Value: boolean);
begin
  form.ffAnsi:= value;
end;

function TCompletionProposal.SFAnsi: boolean;
begin
  result:= form.ffansi;
end;

procedure Register;
begin
//  RegisterComponents('Exemples', [TCompletionProposal, TMwCompletionProposal]);//mh 1999-09-25
  RegisterComponents('mw', [TMwCompletionProposal]);
end;

Procedure PretyTextOut(c: TCanvas; x, y: integer; s: String);
var
  i: integer;
  b: TBrush;
  f: TFont;
Begin
  b:= TBrush.Create;
  b.Assign(c.Brush);
  f:= TFont.Create;
  f.Assign(c.Font);
  try
    i:= 1;
    while i<=Length(s) do
      case s[i] of
        #1: Begin C.Font.Color:= ord(s[i+1])+ord(s[i+2])*256+ord(s[i+3])*65536; inc(i, 4); end;
        #2: Begin C.Brush.Color:= ord(s[i+1])+ord(s[i+2])*256+ord(s[i+3])*65536; inc(i, 4); end;
        #3: Begin
              case s[i+1] of
                'B': c.Font.Style:= c.Font.Style+[fsBold];
                'b': c.Font.Style:= c.Font.Style-[fsBold];
                'U': c.Font.Style:= c.Font.Style+[fsUnderline];
                'u': c.Font.Style:= c.Font.Style-[fsUnderline];
                'I': c.Font.Style:= c.Font.Style+[fsItalic];
                'i': c.Font.Style:= c.Font.Style-[fsItalic];
              end;
              inc(i, 2);
            end;
        else
          C.TextOut(x, y, s[i]);
          x:= x+c.TextWidth(s[i]);
          inc(i);
      end;
  except
  end;
  c.Font.Assign(f);
  f.Free;
  c.Brush.Assign(b);
  b.Free;
end;

{ TMwCompletionProposal }

procedure TMwCompletionProposal.backspace(Senter: TObject);
begin
  if FEditor <> nil then FEditor.CommandProcessor(ecDeleteLastChar,#0,nil);
end;

procedure TMwCompletionProposal.Cancel(Senter: TObject);
begin
  if FEditor <> nil then FEditor.SetFocus;
end;

procedure TMwCompletionProposal.Validate(Senter: TObject);
begin
  if FEditor <> nil then
  Begin
    FEditor.BlockBegin:= Point(FEditor.CaretX - length(CurrentString) , FEditor.CaretY);
    FEditor.BlockEnd:= Point(FEditor.CaretX, FEditor.CaretY);
    FEditor.SelText:= ItemList[position];
    FEditor.SetFocus;
  end;
end;

Procedure TMwCompletionProposal.KeyPress(var Key: Char);
Begin
  if FEditor <> nil then FEditor.CommandProcessor(ecChar, Key, NIL);
end;

procedure TMwCompletionProposal.SetEditor(const Value: TmwCustomEdit);
begin
  if FEditor=value then exit;
  if FEditor <> nil then
  Begin
    FEditor.OnKeyDown:= PrevEvent;
    FEditor.OnKeyPress:= PrevEvent1;
  end;
  FEditor := Value;
  if Value <> nil then
  Begin
    Value.FreeNotification(Self);
    PrevEvent:= Value.OnKeyDown;
    PrevEvent1:= Value.OnKeyPress;
    Value.OnKeyDown:= EditorKeyDown;
    Value.OnKeyPress:= EditorKeyPress;
  end;
end;

procedure TMwCompletionProposal.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (AComponent = FEditor) then
    FEditor := nil;
end;

Constructor TMwCompletionProposal.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
  Form.OnKeyPress:= KeyPress;
  Form.OnKeyDelete:= backspace;
  Form.OnValidate:= validate;
  Form.OnCancel:= Cancel;
  NoNextKey:= false;
end;

{begin}                                                                         //mh 1999-09-25
(*
type
//  property TextHeight: integer read fTextHeight;                              //CdB 15/07/99
//  property TextOffset: integer read fTextOffset;                              //CdB 15/07/99

  TMymwCustomEdit = class(TmwCustomEdit)
  public
    property CharWidth;
    Property TextHeight;
    Property TextOffset;
  end;
*)

procedure TMwCompletionProposal.EditorKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
var
  p: TPoint;
//  e: TMymwCustomEdit;
begin
  if ([ssCtrl] = Shift) and (key=ord(' ')) then
  Begin
//    e:= TMymwCustomEdit(FEditor);
//    p.x := e.CaretX * e.CharWidth + e.TextOffset;
//    p.y := e.CaretY * e.TextHeight - e.TopLine * e.TextHeight + 1 + e.TextHeight;
//    p:= e.ClientToScreen(p);
    p := fEditor.ClientToScreen(Point(fEditor.CaretXPix, fEditor.CaretYPix));
{end}                                                                           //mh 1999-09-25
    Execute(GetPreviousToken, p.x, p.y);
    Key:= 0;
    NoNextKey:= true;
  End;
  if assigned(prevEvent) then
    PrevEvent(sender, key, shift);
end;

function TMwCompletionProposal.GetPreviousToken: string;
var
  s: String;
  i: integer;
begin
  if FEditor <> nil then
  Begin
    s:= FEditor.LineText;
    i:= FEditor.CaretX-1;
    if i>length(s) then
      result:= ''
    else begin
      while (i>0) and (s[i]>' ') and not(s[i] in [')', '(', '[', ']', '=']) do dec(i);
      result:= copy(s, i+1, FEditor.CaretX-i-1);
    end;
  end else result:= '';
end;

procedure TMwCompletionProposal.EditorKeyPress(Sender: TObject;
  var Key: char);
begin
  if NoNextKey then
  Begin
    key:= #0;
    NoNextKey:= false;
  end;
  if assigned(PrevEvent1) then
    PrevEvent1(sender, key);
end;

end.
