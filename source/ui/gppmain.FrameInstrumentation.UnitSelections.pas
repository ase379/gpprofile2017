unit gppmain.FrameInstrumentation.UnitSelections;

interface

uses
  virtualTree.tools.checkable, VirtualTrees, VirtualTrees.basetree, gpParser, gpParser.Units;

type
  TCheckableUnitTreeTools = class(TCheckableListTools)
  private
    fShowDirectoryStructure : boolean;
    fopenProject : TProject;
    procedure UpdateCheckStateOfUnits();
    procedure UpdateCheckStateOfAllUnitsItem();
    procedure UpdateCheckStateOfUnitsWithSpecificNode(const aUnitNode: PVirtualNode);

  public
    procedure FillUnitTree(const aOnlyUnitsOfDPR: boolean; const aShowDirectories: boolean);
    function MarkItemAsSelected(const aNode: PVirtualNode): boolean;
    property ShowDirectoryStructure: boolean read fShowDirectoryStructure write fShowDirectoryStructure;
    property OpenProject: TProject read fopenProject write fopenProject;
  end;

implementation

uses 
  VirtualTrees.Types, gppMain.FrameInstrumentation.SelectionInfoIF, gppMain.FrameInstrumentation.SelectionInfo, 
  System.StrUtils, System.Types;
  
{ TCheckableUnitTreeTools }

function TCheckableUnitTreeTools.MarkItemAsSelected(const aNode: PVirtualNode): boolean;
begin
  result := false;
  if DoesNodePointToAllItem(aNode) then
  begin
    UpdateCheckStateOfUnits();
    var lSelectedUnitNode := GetSelectedNode;
    if assigned(lSelectedUnitNode) then
      result := true;
  end
  else
  begin
    UpdateCheckStateOfUnitsWithSpecificNode(aNode);
    UpdateCheckStateOfAllUnitsItem();
  end;
end;

procedure TCheckableUnitTreeTools.UpdateCheckStateOfAllUnitsItem();
var
  lAllChecked : boolean;
  lNoneChecked : boolean;
  lNode : pVirtualNode;
begin
  BeginUpdate;
  try
    var lAllItemNode := GetNode(0);
    lAllChecked := true;
    lNoneChecked := true;

    var LEnumor := Tree.Nodes().GetEnumerator();
    while (LEnumor.MoveNext) do
    begin
      LNode := LEnumor.Current;
      if GetCheckedState(lNode) = TCheckedState.checked then
        lNoneChecked := false
      else if GetCheckedState(lNode) = TCheckedState.unchecked then
        lAllChecked := false;
    end;
    SetCheckedStateForAllAndNone(lAllItemNode, lAllChecked, lNoneChecked);
  finally
    EndUpdate;
  end;
end;

procedure TCheckableUnitTreeTools.FillUnitTree(const aOnlyUnitsOfDPR: boolean; const aShowDirectories: boolean);
var
  lUnitInfoList : TUnitInstrumentationInfoList;
  LFirstNode,
  lDirectoryNode,
  lParentDirNode,
  LNode : PVirtualNode;
  lFullPath: String;
  lSplittedPath : TStringDynArray;
  j: Integer;
begin
  lUnitInfoList := TUnitInstrumentationInfoList.Create;
  try
    BeginUpdate;
    Clear();
    try
      if openProject <> nil then
      begin
        openProject.GetUnitList(lUnitInfoList, aOnlyUnitsOfDPR);
        lUnitInfoList.SortByName;
        LFirstNode := AddEntry(nil,ALL_UNITS, [ste_AllItem]);
        for var lUnitInfo in lUnitInfoList do
        begin

          if aShowDirectories then
          begin
            lFullPath := openproject.GetUnitPath(lUnitInfo.UnitName);
            lSplittedPath := SplitString(lFullPath, '\');

            lDirectoryNode := nil;
            lParentDirNode := nil;
            for j := low(lSplittedPath) to high(lSplittedPath)-1 do
            begin
              if assigned(lParentDirNode) then
                lDirectoryNode := GetChildByName(lParentDirNode, lSplittedPath[j])
              else
                lDirectoryNode := GetNodeByName(lSplittedPath[j]);
              if lDirectoryNode = nil then
              begin
                lDirectoryNode := AddEntry(lParentDirNode, lSplittedPath[j], [ste_Directory]);
              end;
              if lParentDirNode = nil then
                Tree.Expanded[lDirectoryNode] := true;
              lParentDirNode := lDirectoryNode;
            end;
            LNode := AddEntry(lDirectoryNode, lUnitInfo.UnitName);
          end
          else
          begin
            LNode := AddEntry(nil,lUnitInfo.UnitName);
          end;
          if lUnitInfo.IsFullyInstrumented then
          begin
            Tree.CheckState[LNode] := TCheckState.csCheckedNormal;
          end
          else if lUnitInfo.IsNothingInstrumented then
          begin
            Tree.CheckState[LNode] := TCheckState.csUncheckedNormal;
          end
          else
          begin
            Tree.CheckState[LNode] := TCheckState.csMixedNormal;

          end;
        end;
        
        if lUnitInfoList.NoneInstrumented then
          Tree.CheckState[LFirstNode] := TCheckState.csUncheckedNormal
        else if lUnitInfoList.AllInstrumented  then
          Tree.CheckState[LFirstNode] := TCheckState.csCheckedNormal
        else
          Tree.CheckState[LFirstNode] := TCheckState.csMixedNormal;
      end;
    finally
      EndUpdate;
    end;
  finally
    lUnitInfoList.free;
  end;
  
end; { TfrmMain.FillUnitTree }


procedure TCheckableUnitTreeTools.UpdateCheckStateOfUnits();

  procedure UpdateParentForNodeWithSiblings(const aFirstChildNode : pVirtualNode);
  var
    lAllChecked : boolean;
    lNoneChecked : boolean;
    lNode : pVirtualNode;
  begin

    lAllChecked := true;
    lNoneChecked := true;
    lNode := aFirstChildNode;
    if not assigned(lNode) then
      exit;
    if assigned(lNode) and not assigned(lNode.Parent) then
      exit;

    while(assigned(lNode)) do
    begin
      if GetCheckedState(lNode) = TCheckedState.checked then
        lNoneChecked := false
      else if GetCheckedState(lNode) = TCheckedState.unchecked then
        lAllChecked := false;
      lNode := lNode.NextSibling;
    end;
    SetCheckedStateForAllAndNone(aFirstChildNode.parent, lAllChecked, lNoneChecked);

  end;

  procedure UpdateCheckedStatesForDirectories(const aNode : pVirtualNode);
  var
    lNode : pVirtualNode;
  begin
    lNode := aNode.FirstChild;
    while assigned(lNode) do
    begin
      UpdateCheckedStatesForDirectories(lNode);
      UpdateParentForNodeWithSiblings(lNode);
      lNode := lNode.NextSibling;
    end;
  end;


var
  LEnumor : TVTVirtualNodeEnumerator;
  lAllChecked : boolean;
  lNoneChecked : boolean;
begin
  BeginUpdate;
  try
    lAllChecked := true;
    lNoneChecked := true;
    var lHasDirectoryItems := false;
    LEnumor := Tree.Nodes().GetEnumerator();
    while (LEnumor.MoveNext) do
    begin
      if not lHasDirectoryItems and DoesNodePointToDirectory(LEnumor.Current) then
        lHasDirectoryItems := true;
      
      UpdateCheckStateOfUnitsWithSpecificNode(LEnumor.Current);

      if not DoesNodePointToAllItem(LEnumor.Current) then
      begin
        if GetCheckedState(LEnumor.Current) = TCheckedState.checked then
          lNoneChecked := false
        else if GetCheckedState(LEnumor.Current) = TCheckedState.unchecked then
          lAllChecked := false;
      end;
    end;
    if lHasDirectoryItems then
    begin
      var lAllItemNode := GetNode(0);
      var lNode := lAllItemNode.NextSibling;
      while assigned(lNode) do
      begin
        UpdateCheckedStatesForDirectories(lNode);
        lNode := lNode.NextSibling;
      end;
    end;
    SetCheckedStateForAllAndNone(GetNode(0), lAllChecked, lNoneChecked);
  finally
    EndUpdate;
  end;
end;

procedure TCheckableUnitTreeTools.UpdateCheckStateOfUnitsWithSpecificNode(const aUnitNode: PVirtualNode);
begin
  BeginUpdate;
  try
    if assigned(aUnitNode) then
    begin
      if DoesNodePointToAllItem(aUnitNode) then
        exit;
      if DoesNodePointToDirectory(aUnitNode) then
        exit;

      var lUnitName := GetName(aUnitNode);
      var lUnit := openProject.GetUnit(lUnitName, false);
      if lUnit.unAllInst then
        SetCheckedState(aUnitNode, TCheckedState.checked)
      else if lUnit.unNoneInst then
        SetCheckedState(aUnitNode, TCheckedState.unchecked)
      else
        SetCheckedState(aUnitNode, TCheckedState.greyed);
    end;
  finally
    EndUpdate;
  end;
end;

end.
