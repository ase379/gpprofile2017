{$I OPTIONS.INC}

unit gpArrowListView;

// Modified by John Hamm, john@snapjax.com, added ability to update
// the arrows if system colors are changed.
// Based on work of Ronit Hitman (icnlist.zip on Delphi SuperPage).

interface

uses
  SysUtils,
  Windows,
  Messages,
  Classes,
  ComCtrls,
  Controls,
  Graphics;

type
  TGpLVColumnResizeEvent = procedure(Sender: TObject; columnIndex: integer) of object;

  TGpArrowListView = class(TListView)
  private
    arrowDown      : HBitmap;
    noArrow        : HBitmap;
    arrowUp        : HBitmap;
    FLastColumn    : TListColumn;
    FBitmap        : TBitmap;
    FMyHeaderHandle: HWND;
    FAtoZ          : boolean;
    FOnColumnResize: TGpLVColumnResizeEvent;
    FOnColumnTrack : TGpLVColumnResizeEvent;
    oldCol         : byte;
    tracking       : boolean;
    colWithArrow   : TListColumn;
    procedure   CMSysColorChange(var Message: TMessage); message CM_SYSCOLORCHANGE;
    procedure   WMNotify(var msg: TWMNotify); message WM_NOTIFY;
    procedure   WMParentNotify(var msg: TWMParentNotify); message WM_PARENTNOTIFY;
    procedure   WMPaint(var msg: TMessage); message WM_PAINT;
    function    ValidHeaderHandle: Boolean;
    procedure   RedrawArrow(Column: TListColumn);
    procedure   SetAtoZ(AToZ: boolean);
    function    GetSorted: integer;
  protected
    procedure   ColClick(Column: TListColumn); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;    
    procedure   Resort; virtual;
    procedure   SortOn(index: integer; atoz: boolean);
    property    AtoZOrder: boolean read FAtoZ write SetAtoZ;
    property    SortedOn: integer read GetSorted;
  published
    property    OnColumnResize: TGpLVColumnResizeEvent read FOnColumnResize write FOnColumnResize;
    property    OnColumnTrack: TGpLVColumnResizeEvent read FOnColumnTrack write FOnColumnTrack;
  end;

procedure Register;

implementation

uses
  CommCtrl;

{$R ARROWS.RES}

procedure Register;
begin
  RegisterComponents('Gp', [TGpArrowListView]);
end;

{ TGpArrowListView }

procedure TGpArrowListView.RedrawArrow(Column: TListColumn);
var
  hditem: THdItem;
  i     : byte;
begin
  if Column = nil then
    if Columns.Count = 0 then Exit
                         else Column := Columns[0];
  colWithArrow := Column;
  for i := 0 to Columns.Count-1 do begin
    FBitmap.ReleaseHandle;
    if I = Column.Index then begin
      if AtoZOrder then FBitmap.Handle := arrowDown
                   else FBitmap.Handle := arrowUp
    end
    else FBitmap.Handle := noArrow;
    hditem.Mask := HDI_FORMAT;
    Header_GetItem(GetDlgItem(Handle,0),I,hditem);
    hditem.Mask := HDI_BITMAP or HDI_FORMAT;
    hditem.fmt  := hditem.fmt or HDF_BITMAP;
    hditem.hbm  := FBitmap.Handle;
    Header_SetItem(GetDlgItem(Handle,0),I,hditem);
  end;
end; { TGpArrowListView.RedrawArrow }

procedure TGpArrowListView.ColClick(Column: TListColumn);
begin
  if oldCol = Column.Index then FAtoZ := not FAtoZ
                           else OldCol := Column.Index;
  CustomSort(nil, Column.Index);
  RedrawArrow(Column);
  FLastColumn := Column;
  inherited ColClick(Column);
end; { TGpArrowListView.ColClick }

procedure TGpArrowListView.WMParentNotify(var msg: TWMParentNotify);
begin
  with msg do
    if (Event = WM_CREATE) and (FMyHeaderHandle = 0) then begin
      FMyHeaderHandle := ChildWnd;
    end;
  inherited;
end;

function TGpArrowListView.ValidHeaderHandle: Boolean;
begin
  Result := FMyHeaderHandle <> 0;
end;

procedure TGpArrowListView.WMNotify(var msg: TWMNotify);
begin
  inherited;
  if ValidHeaderHandle then
    with msg.NMHdr^ do
      if hWndFrom = FMyHeaderHandle then begin
        if (code = HDN_BEGINTRACKA) or (code = HDN_BEGINTRACKW) then tracking := true
        else if (code = HDN_ENDTRACKA) or (code = HDN_ENDTRACKW) then begin
          with PHDNotify(Pointer(msg.NMHdr))^, PItem^ do begin
            Column[item].Width := cxy;
            if Assigned(FOnColumnResize) then FOnColumnResize(self,item);
            if (Mask and HDI_WIDTH) <> 0 then RedrawArrow(FLastColumn);
          end;
          tracking := false;
        end
        else if (code = HDN_DIVIDERDBLCLICKA) or (code = HDN_DIVIDERDBLCLICKW) then begin
          with PHDNotify(Pointer(msg.NMHdr))^ do begin
            Column[item].Width := ListView_GetColumnWidth(Handle, item);
            if Assigned(FOnColumnResize) then FOnColumnResize(self,item);
          end;
        end
        else if tracking and
                ((code = HDN_ITEMCHANGINGA) or (code = HDN_ITEMCHANGINGW) or
                 (code = HDN_ITEMCHANGEDA) or (code = HDN_ITEMCHANGEDW) or
                 (code = HDN_TRACKA) or (code = HDN_TRACKW)) then begin
          with PHDNotify(Pointer(msg.NMHdr))^, PItem^ do begin
            Column[item].Width := ListView_GetColumnWidth(Handle, item);
            if Assigned(FOnColumnTrack) then FOnColumnTrack(self,item);
            if (Mask and HDI_WIDTH) <> 0 then RedrawArrow(FLastColumn);
          end;
        end;
      end;
end; { TGPArrowListView.WMNotify }

procedure FixBitmap(hbmp: HBITMAP);
var
  colBtnFace  : DWORD;
  colHighlight: DWORD;
  colShadow   : DWORD;
  color       : DWORD;
  i,j         : integer;
  bmp         : TBitmap;
begin
  bmp := TBitmap.Create;
  try
    bmp.Handle := hbmp;
    colBtnFace   := GetSysColor(COLOR_BTNFACE);
    colHighlight := GetSysColor(COLOR_BTNHILIGHT);
    colShadow    := GetSysColor(COLOR_BTNSHADOW);
    for i := 0 to bmp.Width-1 do begin
      for j := 0 to bmp.Height-1 do begin
        color := bmp.Canvas.Pixels[i,j];
        if color = 0 then color := colShadow
        else if color = $FFFFFF then color := colHighlight
        else color := colBtnFace;
        bmp.Canvas.Pixels[i,j] := color
      end;
    end;
  finally bmp.ReleaseHandle; bmp.Free; end;
end; { FixBitmap }

constructor TGpArrowListView.Create(AOwner: TComponent);
begin
  tracking := false;
  arrowUp  := LoadBitmap(hInstance, 'ARROWUP');
  arrowDown:= LoadBitmap(hInstance, 'ARROWDOWN');
  noArrow  := LoadBitmap(hInstance, 'NOARROW');
  FixBitmap(arrowUp);
  FixBitmap(arrowDown);
  FixBitmap(noArrow);
  FBitmap  := TBitmap.Create;
  FAtoZ    := true;
  colWithArrow := nil;
  inherited Create(AOwner);
end; { TGpArrowListView.Create }

destructor TGpArrowListView.Destroy;
begin
  FBitmap.ReleaseHandle;
  FBitmap.Free;
  DeleteObject(arrowUp);
  DeleteObject(arrowDown);
  DeleteObject(noArrow);
  inherited Destroy;
end; { TGpArrowListView.Destroy }

procedure TGpArrowListView.SortOn(index: integer; atoz: boolean);
begin
  FAtoZ := AtoZ;
  CustomSort(nil, Index);
  RedrawArrow(Columns[index]);
  FLastColumn := Columns[index];
end;

procedure TGpArrowListView.SetAtoZ(AToZ: boolean);
begin
  if FAtoZ <> AtoZ then begin
    FAtoZ := AtoZ;
    RedrawArrow(FLastColumn);
  end;
end;

procedure TGpArrowListView.WMPaint(var msg: TMessage);
begin
  RedrawArrow(FLastColumn);
  inherited;
end;

procedure TGpArrowListView.Resort;
begin
  if FLastColumn <> nil then CustomSort(nil,FLastColumn.Index);
end;

function TGpArrowListView.GetSorted: integer;
begin
  if FLastColumn = nil then Result := -1
                       else Result := FLastColumn.Index;
end;

procedure TGpArrowListView.CMSysColorChange(var Message: TMessage);
begin
  DeleteObject(arrowUp);
  DeleteObject(arrowDown);
  DeleteObject(noArrow);
  arrowUp  := LoadBitmap(hInstance, 'ARROWUP');
  arrowDown:= LoadBitmap(hInstance, 'ARROWDOWN');
  noArrow  := LoadBitmap(hInstance, 'NOARROW');
  FixBitmap(arrowUp);
  FixBitmap(arrowDown);
  FixBitmap(noArrow);
  inherited;
end;

end.
