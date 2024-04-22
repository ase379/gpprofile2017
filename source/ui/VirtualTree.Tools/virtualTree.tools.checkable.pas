unit virtualTree.tools.checkable;

interface

uses
  System.Generics.Collections,
  VirtualTrees,
  gppresults,
  virtualTree.tools.base;


type

  TSpecialTagEnum = (ste_AllItem, ste_Directory, ste_UnitClassOrProc);
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
    fTreeType : TCheckableItemDataEnum;
    fSortcols: array of TColumnIndex;

    procedure OnFreeNode(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure OnCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
  public
    constructor Create(const aTree: TVirtualStringTree; const aTreeType : TCheckableItemDataEnum);
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
    procedure SetCheckedStateForAllAndNone(const aNode: PVirtualNode; const aAllInstrumented, aNoneInstrumented: boolean); overload;
    procedure SetCheckedStateForAllAndNone(const aNodeIndex: integer; const aAllInstrumented, aNoneInstrumented: boolean); overload;

    function IsChecked(const anIndex : Cardinal): boolean;

    function DoesNodePointToAllItem(const aNode: PVirtualNode): boolean;
    function DoesNodePointToDirectory(const aNode: PVirtualNode): boolean;

  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString,
  VirtualTrees.Types;



function TCheckableListTools.AddEntry(const aParent : PVirtualNode;const aName : String): PVirtualNode;
begin
  result := AddEntry(aParent, aName, [ste_UnitClassOrProc]);
end;

function TCheckableListTools.AddEntry(const aParent: PVirtualNode; const aName: String; const aSpecialTagSet : TSpecialTagEnumSet): PVirtualNode;
var
  LData : PCheckableItemData;
begin
  result := fTree.AddChild(aParent);
  result.CheckType := ctTriStateCheckBox;
  LData := PCheckableItemData(result.GetData);
  case fTreeType of
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
  result := fTree.InsertNode(LPredecessor, TVTNodeAttachMode.amInsertBefore);
  result.CheckType := ctTriStateCheckBox;
  LData := PCheckableItemData(result.GetData);
  case fTreeType of
    cid_unit,
    cid_Class,
    cid_Procs :
    begin
      LData.Name := aName;
      LData.SpecialTagSet := aSpecialTagSet;
    end;
  end;
end;


constructor TCheckableListTools.Create(const aTree: TVirtualStringTree; const aTreeType : TCheckableItemDataEnum);
begin
  inherited Create(aTree);
  fTreeType := aTreeType;
  fTree.NodeDataSize := SizeOf(TCheckableItemData);
  fTree.OnFreeNode := self.OnFreeNode;
  fTree.OnCompareNodes := self.OnCompareNodes;
  fTree.ongettext := OnGetText;
  fTree.TreeOptions.MiscOptions := fTree.TreeOptions.MiscOptions + [TVTMiscOption.toCheckSupport];
  fTree.TreeOptions.SelectionOptions := fTree.TreeOptions.SelectionOptions + [TVTSelectionOption.toSyncCheckboxesWithSelection];
end;

destructor TCheckableListTools.Destroy;
begin
  inherited;
end;


function TCheckableListTools.DoesNodePointToAllItem(const aNode: PVirtualNode): boolean;
begin
  result := TSpecialTagEnum.ste_AllItem in GetSpecialTagSet(aNode);
end;

function TCheckableListTools.DoesNodePointToDirectory(const aNode: PVirtualNode): boolean;
begin
  result := TSpecialTagEnum.ste_Directory in GetSpecialTagSet(aNode);
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
  case fTreeType of
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
  case fTreeType of
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
end;

procedure TCheckableListTools.SetCheckedStateForAllAndNone(const aNodeIndex: integer; const aAllInstrumented, aNoneInstrumented: boolean);
begin
  if aAllInstrumented then
    SetCheckedState(aNodeIndex, TCheckedState.checked)
  else if aNoneInstrumented then
    SetCheckedState(aNodeIndex, TCheckedState.unchecked)
  else
    SetCheckedState(aNodeIndex, TCheckedState.greyed);
end;

procedure TCheckableListTools.SetCheckedStateForAllAndNone(const aNode: PVirtualNode; const aAllInstrumented, aNoneInstrumented: boolean);
begin
  if aAllInstrumented then
    SetCheckedState(aNode, TCheckedState.checked)
  else if aNoneInstrumented then
    SetCheckedState(aNode, TCheckedState.unchecked)
  else
    SetCheckedState(aNode, TCheckedState.greyed);
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
  case fTreeType of
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
    LData1 := fTree.GetNodeData(Node1);
    LData2 := fTree.GetNodeData(Node2);

    if Assigned(LData1) and Assigned(LData2) then
      for i := High(fSortCols) downto 0 do
      begin
        Result := CompareStr(fTree.Text[Node1,i],fTree.Text[Node2,i]);
        if Result <> 0 then
          Break;
      end;
  end;
end;

end.
