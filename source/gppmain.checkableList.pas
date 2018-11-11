unit gppmain.checkableList;

interface

uses
  System.Generics.Collections,
  VirtualTrees,
  gppresults;


type
  TCheckableItemDataEnum = (cid_Unit);
  PCheckableItemData = ^TCheckableItemData;
  TCheckableItemData = record
    Name : string;
  end;

  {$SCOPEDENUMS ON}
  TCheckedState = (unchecked, greyed, checked);
  {$SCOPEDENUMS OFF}
  TCheckableListTools = class
  private
    fList: TVirtualStringTree;
    fListType : TCheckableItemDataEnum;
    fSortcols: array of TColumnIndex;

    procedure OnFreeNode(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure OnCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    procedure OnHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);

  public
    constructor Create(const aList: TVirtualStringTree; const aListType : TCheckableItemDataEnum);
    destructor Destroy;override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    function AddEntry(const aName : String): PVirtualNode;

    function GetSelectedNode(): PVirtualNode;
    function GetCount: integer;

    function GetNode(const anIndex : Cardinal): PVirtualNode;
    function GetName(const anIndex : Cardinal): string;
    function GetCheckedState(const anIndex: Cardinal): TCheckedState;

    procedure SetCheckedState(const anIndex: Cardinal;const aCheckedState : TCheckedState);
  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString;


procedure TCheckableListTools.Clear;
begin
  fList.Clear();
end;

constructor TCheckableListTools.Create(const aList: TVirtualStringTree; const aListType : TCheckableItemDataEnum);
begin
  fList := aList;
  fListType := aListType;
  fList.NodeDataSize := SizeOf(TCheckableItemData);
  fList.OnFreeNode := self.OnFreeNode;
  fList.OnCompareNodes := self.OnCompareNodes;
  fList.ongettext := OnGetText;
  fList.OnHeaderClick := self.OnHeaderClick;
end;

destructor TCheckableListTools.Destroy;
begin
  inherited;
end;

procedure TCheckableListTools.BeginUpdate;
begin
  FList.BeginUpdate;
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions;
end;

procedure TCheckableListTools.EndUpdate;
begin
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions;
  FList.EndUpdate;
end;


function TCheckableListTools.GetSelectedNode: PVirtualNode;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnumor := fList.SelectedNodes().GetEnumerator();
  while(LEnumor.MoveNext) do
    Exit(LEnumor.Current);
end;

function TCheckableListTools.GetCount: integer;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := 0;
  LEnumor := fList.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
    inc(result);
end;


function TCheckableListTools.GetName(const anIndex: Cardinal): string;
var
  LNode : PVirtualNode;
begin
  result := '';
  LNode := GetNode(anIndex);
  if Assigned(LNode) then
    OnGetText(fList,LNode,0,TVSTTextType.ttNormal,Result);
end;

function TCheckableListTools.GetCheckedState(const anIndex: Cardinal): TCheckedState;
var
  LNode : PVirtualNode;
begin
  result := TCheckedState.unchecked;
  LNode := GetNode(anIndex);
  if Assigned(LNode) then
  begin
    case LNode.CheckState of
      TCheckState.csUncheckedNormal,
      TCheckState.csUncheckedPressed,
      TCheckState.csUncheckedDisabled : result := TCheckedState.unchecked;
      TCheckState.csCheckedNormal,
      TCheckState.csCheckedPressed,
      TCheckState.csCheckedDisabled : result := TCheckedState.checked;
      TCheckState.csMixedNormal,
      TCheckState.csMixedPressed,
      TCheckState.csMixedDisabled : result := TCheckedState.greyed;
    end;
  end;
end;

procedure TCheckableListTools.SetCheckedState(const anIndex: Cardinal;const aCheckedState : TCheckedState);
var
  LNode : PVirtualNode;
begin
  LNode := GetNode(anIndex);
  if Assigned(LNode) then
  begin
    case aCheckedState of
      TCheckedState.unchecked : LNode.CheckState := TCheckState.csUncheckedNormal;
      TCheckedState.checked : LNode.CheckState := TCheckState.csCheckedNormal;
      TCheckedState.greyed : LNode.CheckState := TCheckState.csMixedNormal;
    end;
  end;
end;

function TCheckableListTools.GetNode(const anIndex: Cardinal): PVirtualNode;
var
  I : Cardinal;
  LEnumor : TVTVirtualNodeEnumerator;
begin
  i := 0;
  result := nil;
  LEnumor := fList.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    if i = anIndex then
      Exit(LEnumor.Current);
    inc(i);
  end;
end;


function TCheckableListTools.AddEntry(const aName : String): PVirtualNode;
var
  LData : PCheckableItemData;
  LNode : PVirtualNode;
  LID : Int64;
begin

  LNode := flist.AddChild(nil);
  LNode.CheckType := ctTriStateCheckBox;
  LData := PCheckableItemData(LNode.GetData);
  case fListType of
    cid_unit :
    begin
      LData.Name := aName;
    end;
  end;
end;

/// Events


procedure TCheckableListTools.OnFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: PCheckableItemData;
begin
  Data := PCheckableItemData(Node.GetData());
  if data <> nil then
    Finalize(Data^);
end;

procedure TCheckableListTools.OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LData : PCheckableItemData;
begin
  LData := node.GetData;
  CellText := '';
  if fListType = cid_Unit then
  begin
    CellText := LData.Name;
  end;
end;

procedure TCheckableListTools.OnHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
  SetLength(fSortCols,length(fSortCols)+1);
  fSortCols[Length(fSortCols)-1] := HitInfo.Column;
  fList.SortTree(HitInfo.Column,Sender.SortDirection,True);

  if Sender.SortDirection=sdAscending then
    Sender.SortDirection:=sdDescending
  else
    Sender.SortDirection:=sdAscending;
  fList.Header.SortDirection := Sender.SortDirection;
  fList.Header.SortColumn := HitInfo.Column;
end;

procedure TCheckableListTools.OnCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
    i: integer;
    LData1: PCheckableItemData;
    LData2: PCheckableItemData;
begin
  if Length(fSortCols) > 0 then
  begin
    LData1 := FList.GetNodeData(Node1);
    LData2 := fList.GetNodeData(Node2);

    if Assigned(LData1) and Assigned(LData2) then
      for i := High(fSortCols) downto 0 do
      begin
        Result := CompareStr(FList.Text[Node1,i],FList.Text[Node2,i]);
        if Result <> 0 then
          Break;
      end;
  end;
end;

end.
