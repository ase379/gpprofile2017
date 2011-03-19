{ TDBmwEdit - data aware TmwCustomEdit
  Author: Vladimir Kuznetsov (kuzn_vv@mail.ru)

  Seems to be properly work with all commands (keyboard and mouse).
 ( Tested in my free project Urep:
       http://www.freeyellow.com/members8/kuznvv/ )

 Add 2 not standard Events:
 OnLoadData - fire when new data loaded in TDBmwEdit
 OnUpdateInfo - fire when may be updated Cursor Pos or Insert Mode
     (for Make StatusBar like Delphi IDE)

  May reusing one HighLighter in many windows
  (see TDBmwEdit.Destroy)
}

unit DBmwEdit;

{$I mwEdit.inc}                                                                 //mh 1999-09-25 

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  db, dbtables, dbctrls, mwCustomEdit, mwKeyCmds;

type
  TDBmwEdit = class(TmwCustomEdit)
  private
    FDataLink: TFieldDataLink;
    FFocused: Boolean;
    FOldOnChange : TNotifyEvent;
    FBeginEdit: Boolean;
    FLoadData: TNotifyEvent;
    FUpdateInfo: TNotifyEvent;

    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    procedure UpdateData(Sender: TObject);
    procedure SetFocused(Value: Boolean);

    function GetDataField: string;
    function GetDataSource: TDataSource;
    function GetReadOnly: Boolean;
    procedure SetDataField(const Value: string);
    procedure SetDataSource(Value: TDataSource);
    procedure SetReadOnly(Value: Boolean);
    function GetField: TField;

    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit(var Message: TCMExit); message CM_EXIT;
    procedure CMGetDataLink(var Message: TMessage); message CM_GETDATALINK;
  protected
    procedure ProcessCommand(var Command: TmwEditorCommand; var AChar: char;
                             Data: pointer); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure NewOnChange(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure DragDrop(Source: TObject; X, Y: Integer); override;
    procedure CommandProcessor(Command: TmwEditorCommand; AChar: char;
                               Data: pointer); override;
    property Field: TField read GetField;
    procedure LoadMemo;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  published
    {kuzn_vv}
    property DataField: String read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property OnLoadData: TNotifyEvent read fLoadData write fLoadData;
    property OnUpdateInfo: TNotifyEvent read FUpdateInfo write FUpdateInfo;
    {TmwCustomEdit}
    property Align;
{$IFDEF MWE_COMPILER_4_UP}                                                      //mh 1999-09-25
    property Anchors;
    property Constraints;
{$ENDIF}    
    property BorderStyle;
    property BookMarkOptions;
    property CanUndo;
    property CanRedo;
    property Color;
    property Ctl3D;
    property Enabled;
    property ExtraLineSpacing;
    property Font;
    property Gutter;
    property HalfpageScroll;
    property Height;
    property HideSelection;
    property HighLighter;
    property BookmarkImages;
    property InsertCaret;
    property InsertMode;
    property Keystrokes;
    property LeftChar;
    property LineCount;
    property MaxUndo;
    property Name;
    property OverwriteCaret;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RightEdge;
    property RightEdgeColor;
    property ShowHint;
    property ScrollBars;
    property ScrollPastEOL;
    property ShowScrollHint;
    property SelectedColor;
    //property SelectionMode;
    property TabOrder;
    property TabIndent;
    property TabStop;
    property Tag;
    property TopLine;
    property Visible;
    property WantTabs;
    property Width;
    property OnChange;
    property OnClick;
    property OnCommandDone;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnPaint;
    property OnPlaceBookmark;
    property OnPrintStatus;
    property OnProcessCommand;
    property OnProcessUserCommand;
    property OnSelectionChange;
    property OnStartDrag;
  end;

procedure Register;

implementation

// {$R DBmwEdit.DCR}                                                            //mh 1999-09-24

procedure Register;
begin
  RegisterComponents('mw', [TDBmwEdit]);
end;


constructor TDBmwEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
end;

destructor TDBmwEdit.Destroy;
begin
  FDataLink.Free;
  FDataLink := nil;

// removed this because Highlighter.Canvas has been removed                     //mh 1999-09-24
  {kuzn_vv  : ! Important}
//  if assigned(HighLighter) then // for reusing HighLighter
//    HighLighter.SetCanvas(nil);
  inherited Destroy;
end;

procedure TDBmwEdit.Loaded;
begin
  inherited Loaded;
  if (csDesigning in ComponentState) then DataChange(Self);

  FOldOnChange := OnChange;
  OnChange := NewOnChange;
end;

procedure TDBmwEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = DataSource) then DataSource := nil;
end;

procedure TDBmwEdit.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  If Assigned(FUpdateInfo) then
      FUpdateInfo(Self);
end;

procedure TDBmwEdit.ProcessCommand(var Command: TmwEditorCommand; var AChar: char;
                             Data: pointer);
begin
  If (Command = ecChar) and (AChar=#27) then
    FDataLink.Reset
  Else If ((Command>=ecDeleteLastChar) and (Command<=ecInsertLine)) or
          ((Command>=ecImeStr) and (Command<=ecCut)) or
          ((Command = ecChar) and (AChar in [#32..#255])) or
          (Command = ecPaste) or
          (Command = ecBlockIndent) or
          (Command = ecBlockUnindent) then
    FDataLink.Edit;

  inherited;
end;

procedure TDBmwEdit.CommandProcessor(Command: TmwEditorCommand; AChar: char;
                               Data: pointer);
begin
  inherited;
  If Assigned(FUpdateInfo) then
    FUpdateInfo(Self);
end;

procedure TDBmwEdit.DragDrop(Source: TObject; X, Y: Integer);
begin
  FDataLink.Edit;
  inherited;
end;


procedure TDBmwEdit.NewOnChange(Sender: TObject);
begin
  FDataLink.Modified;
  if assigned(FOldOnChange) then
    FOldOnChange(Sender);
end;

function TDBmwEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDBmwEdit.SetDataSource(Value: TDataSource);
begin
  if not (FDataLink.DataSourceFixed and (csLoading in ComponentState)) then
    FDataLink.DataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
end;

function TDBmwEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

procedure TDBmwEdit.SetDataField(const Value: string);
begin
  FDataLink.FieldName := Value;
end;

function TDBmwEdit.GetReadOnly: Boolean;
begin
  Result := FDataLink.ReadOnly;
end;

procedure TDBmwEdit.SetReadOnly(Value: Boolean);
begin
  FDataLink.ReadOnly := Value;
end;

function TDBmwEdit.GetField: TField;
begin
  Result := FDataLink.Field;
end;

procedure TDBmwEdit.LoadMemo;
var
  BlobStream: TBlobStream;
  BlobField: TBlobField;
begin
  try
    BlobField := FDataLink.Field as TBlobField;
    BlobStream := TBlobStream.Create(BlobField, bmRead);
    Lines.BeginUpdate;
    Lines.LoadFromStream(BlobStream);
    Lines.EndUpdate;
    BlobStream.Free;
    Modified := false;
    ClearUndo;
  except
    { Memo too large }
    on E:EInvalidOperation do
      Lines.Text := Format('(%s)', [E.Message]);
  end;
  EditingChange(Self);
end;

procedure TDBmwEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
  begin
    if FBeginEdit then
    begin
      FBeginEdit := False;
      Exit;
    end;
{$IFDEF MWE_COMPILER_3_UP}                                                      //mh 1999-09-25
    if FDataLink.Field.IsBlob then
    begin
      LoadMemo;
    end else
{$ENDIF}
    begin
      Text := FDataLink.Field.Text
    end;
    If Assigned(FLoadData) then
      FLoadData(Self);
  end
  else
  begin
    if csDesigning in ComponentState then Text := Name else Text := '';
  end;
end;

procedure TDBmwEdit.EditingChange(Sender: TObject);
begin
  if FDataLink.Editing then
    FBeginEdit := True;
end;

procedure TDBmwEdit.UpdateData(Sender: TObject);
{$IFDEF MWE_COMPILER_3_UP}                                                      //mh 1999-09-25
var
  BlobStream: TBlobStream;
  BlobField: TBlobField;
begin
  if FDataLink.Field.IsBlob then
  begin
    BlobField := FDataLink.Field as TBlobField;
    BlobStream := TBlobStream.Create(BlobField, bmWrite);
    Lines.SaveToStream(BlobStream);
    BlobStream.Free;
  end else
{$ELSE}
begin
{$ENDIF}
    FDataLink.Field.AsString := Text;
end;

procedure TDBmwEdit.SetFocused(Value: Boolean);
begin
  if FFocused <> Value then
  begin
    FFocused := Value;
{$IFDEF MWE_COMPILER_3_UP}                                                      //mh 1999-09-25
    if not Assigned(FDataLink.Field) or not FDataLink.Field.IsBlob then
{$ENDIF}
      FDataLink.Reset;
  end;
end;

procedure TDBmwEdit.CMEnter(var Message: TCMEnter);
begin
  SetFocused(True);
  inherited;
end;

procedure TDBmwEdit.CMExit(var Message: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  except
    SetFocus;
    raise;
  end;
  SetFocused(False);
  inherited;
end;

procedure TDBmwEdit.CMGetDataLink(var Message: TMessage);
begin
  Message.Result := Integer(FDataLink);
end;






end.
