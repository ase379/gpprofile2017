unit virtualTree.tools.checkable;

interface

uses
  System.Generics.Collections,
  VirtualTrees,
  gppresults,
  virtualTree.tools.base;


type

  TSpecialTagEnum = (ste_Directory, ste_AllItem);
  TSpecialTagEnumSet = set of TSpecialTagEnum;


  TCheckableItemDataEnum = (cid_Unit, cid_Class, cid_Procs);
  PCheckableItemData = ^TCheckableItemData;
  TCheckableItemData = record
    Name : string;
    SpecialTagSet : TSpecialTagEnumSet;
  end;

  {$SCOPEDENUMS ON}
  TCheckedState = (unchecked, greyed, checked);
  {$SCOPEDENUMS OFF}
  TCheckableListTools = class(TVirtualTreeBaseTools)
  private
    fListType : TCheckableItemDataEnum;
    fSortcols: array of TColumnIndex;

    procedure OnFreeNode(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure OnCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
  public
    constructor Create(const aList: TVirtualStringTree; const aListType : TCheckableItemDataEnum);
    destructor Destroy;override;
    function AddEntry(const aParent : PVirtualNode;const aName : String): PVirtualNode;overload;
    function AddEntry(const aParent : PVirtualNode;const aName : String; const aSpecialTagSet : TSpecialTagEnumSet):PVirtualNode;overload;

    function GetName(const aNode : PVirtualNode;const column : integer = 0) : string; override;

    function InsertEntry(const anIndex : integer; const aName : string; const aSpecialTagSet : TSpecialTagEnumSet):PVirtualNode;

    function GetSpecialTagSet(const aNode : PVirtualNode) : TSpecialTagEnumSet;

    function GetCheckedState(const anIndex: Cardinal): TCheckedState; overload;
    function GetCheckedState(const aNode: PVirtualNode): TCheckedState; overload;
    procedure SetCheckedState(const anIndex: Cardinal;const aCheckedState : TCheckedState); overload;
    procedure SetCheckedState(const aNode: PVirtualNode;const aCheckedState : TCheckedState); overload;

    function IsChecked(const anIndex : Cardinal): boolean;
  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString;



function TCheckableListTools.AddEntry(const aParent : PVirtualNode;const aName : String): PVirtualNode;
begin
  result := AddEntry(aParent, aName, []);
end;

function TCheckableListTools.AddEntry(const aParent: PVirtualNode; const aName: String; const aSpecialTagSet : TSpecialTagEnumSet): PVirtualNode;
var
  LData : PCheckableItemData;
begin
  result := flist.AddChild(aParent);
  result.CheckType := ctTriStateCheckBox;
  LData := PCheckableItemData(result.GetData);
  case fListType of
    cid_unit,
    cid_Class,
    cid_Procs :
    begin
      LData.Name := aName;
      lData.SpecialTagSet := aSpecialTagSet;
    end;
  end;
end;


function TCheckableListTools.InsertEntry(const anIndex: integer; const aName: string; const aSpecialTagSet : TSpecialTagEnumSet): PVirtualNode;
var
  LData : PCheckableItemData;
  LPredecessor : PVirtualNode;
begin
  LPredecessor := GetNode(anIndex);
  result := flist.InsertNode(LPredecessor, TVTNodeAttachMode.amInsertBefore);
  result.CheckType := ctTriStateCheckBox;
  LData := PCheckableItemData(result.GetData);
  case fListType of
    cid_unit,
    cid_Class,
    cid_Procs :
    begin
      LData.Name := aName;
      LData.SpecialTagSet := aSpecialTagSet;
    end;
  end;
end;


constructor TCheckableListTools.Create(const aList: TVirtualStringTree; const aListType : TCheckableItemDataEnum);
begin
  inherited Create(aList);
  fListType := aListType;
  fList.NodeDataSize := SizeOf(TCheckableItemData);
  fList.OnFreeNode := self.OnFreeNode;
  fList.OnCompareNodes := self.OnCompareNodes;
  fList.ongettext := OnGetText;
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions + [TVTMiscOption.toCheckSupport];
  fList.TreeOptions.SelectionOptions := fList.TreeOptions.SelectionOptions + [TVTSelectionOption.toSyncCheckboxesWithSelection];
end;

destructor TCheckableListTools.Destroy;
begin
  inherited;
end;


function TCheckableListTools.GetCheckedState(const anIndex: Cardinal): TCheckedState;
var
  LNode : PVirtualNode;
begin
  result := TCheckedState.unchecked;
  LNode := GetNode(anIndex);
  if Assigned(LNode) then
    result := GetCheckedState(LNode);
end;


function TCheckableListTools.GetCheckedState(const aNode: PVirtualNode): TCheckedState;
begin
  result := TCheckedState.unchecked;
  if Assigned(aNode) then
  begin
    case aNode.CheckState of
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

function TCheckableListTools.GetSpecialTagSet(const aNode: PVirtualNode): TSpecialTagEnumSet;
var
  LData : PCheckableItemData;
begin
  case fListType of
    cid_unit,
    cid_Class,
    cid_Procs :
    begin
      LData := PCheckableItemData(aNode.GetData);
      result := lData.SpecialTagSet;
    end
    else
      result := [];
  end;
end;

function TCheckableListTools.GetName(const aNode: PVirtualNode;const column : integer = 0): string;
var
  LData : PCheckableItemData;
begin
  if not Assigned(aNode) then
    Exit('');
  case fListType of
    cid_unit,
    cid_Class,
    cid_Procs :
    begin
      LData := PCheckableItemData(aNode.GetData);
      result := lData.Name;
    end
    else
      result := inherited GetName(aNode, column);
  end;
end;

procedure TCheckableListTools.SetCheckedState(const anIndex: Cardinal;const aCheckedState : TCheckedState);
begin
  SetCheckedState(GetNode(anIndex), aCheckedState);
end;

procedure TCheckableListTools.SetCheckedState(const aNode: PVirtualNode; const aCheckedState: TCheckedState);
begin
  if not Assigned(aNode) then
    raise EArgumentException.Create('TCheckableListTools: Node is nil.');
  case aCheckedState of
    TCheckedState.unchecked : aNode.CheckState := TCheckState.csUncheckedNormal;
    TCheckedState.checked : aNode.CheckState := TCheckState.csCheckedNormal;
    TCheckedState.greyed : aNode.CheckState := TCheckState.csMixedNormal;
  end;
  FList.InvalidateNode(aNode);
end;

function TCheckableListTools.IsChecked(const anIndex: Cardinal): boolean;
begin
  result := Self.GetCheckedState(anIndex) = TCheckedState.checked;
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
  case fListType of
    cid_Unit,
    cid_Class,
    cid_Procs:
    begin
      CellText := LData.Name;
    end;
  end;
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
