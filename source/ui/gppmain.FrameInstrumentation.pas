unit gppmain.FrameInstrumentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls,
  virtualTree.tools.checkable,System.Generics.Collections,
  gpParser, Vcl.Menus, Vcl.WinXCtrls, VirtualTrees.BaseAncestorVCL,
  VirtualTrees.BaseTree, VirtualTrees.AncestorVCL, gppMain.FrameInstrumentation.SelectionInfoIF;


type
  TOnShowStatusBarMessage = procedure (const msg: string; const beep: boolean) of object;
  TReloadSourceEvent = procedure(const aPath : string; aLine : integer) of object;
  TOnDoInstrument = procedure() of object;
  TOnParseProject = procedure(const aProject: string; const aJustRescan: boolean) of object;

  TfrmMainInstrumentation = class(TFrame)
    Splitter1: TSplitter;
    splitter2: TSplitter;
    pnlTop: TPanel;
    chkShowDirStructure: TCheckBox;
    pnlUnits: TPanel;
    lblUnits: TStaticText;
    vstSelectUnits: TVirtualStringTree;
    pnlClasses: TPanel;
    lblClasses: TStaticText;
    vstSelectClasses: TVirtualStringTree;
    pnlProcs: TPanel;
    lblProcs: TStaticText;
    vstSelectProcs: TVirtualStringTree;
    chkShowAll: TCheckBox;
    sbUnits: TSearchBox;
    sbProcedures: TSearchBox;
    sbClasses: TSearchBox;
    btnUnitSelectionWizard: TButton;
    procedure vstSelectProcsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectProcsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectClassesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectClassesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectUnitsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure chkShowDirStructureClick(Sender: TObject);
    procedure vstSelectUnitsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure btnSelectAllClick(Sender: TObject);
    procedure sbUnitsInvokeSearch(Sender: TObject);
    procedure sbClassesInvokeSearch(Sender: TObject);
    procedure sbProceduresInvokeSearch(Sender: TObject);
    procedure btnUnitSelectionWizardClick(Sender: TObject);
  private
    fVstSelectUnitTools       : TCheckableListTools;
    fVstSelectClassTools      : TCheckableListTools;
    fVstSelectProcTools       : TCheckableListTools;
    fopenProject : TProject;
    fOnShowStatusBarMessage : TOnShowStatusBarMessage;
    fOnReloadSource : TReloadSourceEvent;
    procedure InvokeSearch(const aSearchTerm: string; const aTreeTool: TCheckableListTools);
    function  GetSelectedUnitName(): string;
    function  DoesNodePointToAllItem(const aNode: PVirtualNode): boolean;
    function  DoesNodePointToDirectory(const aNode: PVirtualNode): boolean;
    function  GetClassSelectionInfoForSelectedNode: ISelectionInfo;
    function  GetClassSelectionInfoForNode(const aNode: PVirtualNode): ISelectionInfo;

    function  GetSelectedUnitIndex(): integer;
    procedure SetSelectedUnitIndex(const anIndex : integer);

    procedure ClickProcs(index: integer; recreateCl: boolean);

    procedure InstrumentUnit(const aNode: PVirtualNode; const aCheckState : TCheckedState);


    procedure UpdateCheckStateOfUnits();
    procedure UpdateCheckStateOfAllUnitsItem();
    procedure UpdateCheckStateOfDirectoryWithSpecificNode(const aDirNode: PVirtualNode);
    procedure UpdateCheckStateOfUnitsWithSpecificNode(const aUnitNode: PVirtualNode);
    procedure UpdateCheckStateOfClassesForUnit(const aUnitNode: PVirtualNode);
    /// <summary>
    /// Recreates information for the center list view showing the classes. The given unit name is then reclicked.
    /// </summary>
    procedure RecreateClasses(recheck: boolean;const aAffectedUnitNode: pVirtualNode);
    /// <summary>
    /// Recreates information for the right list view showing the procedures
    /// </summary>
    procedure RecreateProcs(const aUnitName: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DisablePC();
    procedure EnablePC;
    procedure ReloadSource;
    procedure ChangeClassSelectionWithoutEvent(const anIndex : integer);
    function  GetSelectedUnitNode(): pVirtualNode;

    procedure clbProcsClick(Sender: TObject);
    procedure clbUnitsClick(const aNode : pVirtualNode);
    procedure clbUnitsClickCheck(const aNode: PVirtualNode);
    procedure clbClassesClick(Sender: TObject);
    procedure clbClassesClickCheck(Sender: TObject; const aNode: PVirtualNode);

    procedure FillUnitTree(const aOnlyUnitsOfDPR: boolean;const aShowDirectories: boolean);

    procedure RescanProject(const aOnRescan : TOnParseProject);
    procedure RemoveInstrumentation(const aOnDoInstrument : TOnDoInstrument);

    procedure TriggerSelectionReload();

    property openProject : TProject read fOpenProject write fOpenProject;
    property OnShowStatusBarMessage : TOnShowStatusBarMessage read fOnShowStatusBarMessage write fOnShowStatusBarMessage;
    property OnReloadSource : TReloadSourceEvent read fOnReloadSource write fOnReloadSource;
    property SelectedUnitIndex : integer read GetSelectedUnitIndex write SetSelectedUnitIndex;
  end;

implementation

uses
  GpString, gppUnitWizard, gpParser.Units, gpParser.Selections,
  gppMain.FrameInstrumentation.SelectionInfo, System.StrUtils, System.Types,
  VirtualTrees.Types, gpParser.types;

{$R *.dfm}

{ TfrmMainInstrumentation }



constructor TfrmMainInstrumentation.Create(AOwner: TComponent);
begin
  inherited;
  fVstSelectUnitTools := TCheckableListTools.Create(vstSelectUnits, cid_Unit);
  fVstSelectClassTools := TCheckableListTools.Create(vstSelectClasses, cid_Class);
  fVstSelectProcTools := TCheckableListTools.Create(vstSelectProcs, cid_Procs);
end;

destructor TfrmMainInstrumentation.Destroy;
begin
  FreeAndNil(fVstSelectUnitTools);
  FreeAndNil(fVstSelectClassTools);
  FreeAndNil(fVstSelectProcTools);
  inherited;
end;

procedure TfrmMainInstrumentation.DisablePC;
begin
  chkShowAll.Enabled                 := false;
  chkShowDirStructure.Enabled        := false;
  lblUnits.Enabled                   := false;
  lblClasses.Enabled                 := false;
  lblProcs.Enabled                   := false;
  vstSelectUnits.Enabled             := false;
  vstSelectClasses.Enabled           := false;
  vstSelectProcs.Enabled             := false;
end;

procedure TfrmMainInstrumentation.InstrumentUnit(const aNode: PVirtualNode; const aCheckState : TCheckedState);
begin
  if DoesNodePointToAllItem(aNode) then
    openProject.InstrumentAll(aCheckState = TCheckedState.checked,not chkShowAll.Checked)
  else
  begin
    if TSpecialTagEnum.ste_UnitClassOrProc in fVstSelectUnitTools.GetSpecialTagSet(aNode) then
    begin
      var lUnitName := fVstSelectUnitTools.GetName(aNode);
      var lInstrument := aCheckState = TCheckedState.checked;
      openProject.InstrumentUnit(lUnitName, lInstrument);
    end;
  end;
end;

procedure TfrmMainInstrumentation.UpdateCheckStateOfUnits();
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  vstSelectUnits.BeginUpdate;
  try
    UpdateCheckStateOfAllUnitsItem();
    LEnumor := vstSelectUnits.Nodes().GetEnumerator();
    while (LEnumor.MoveNext) do
    begin
      UpdateCheckStateOfUnitsWithSpecificNode(LEnumor.Current)
    end;
  finally
    vstSelectUnits.EndUpdate;
  end;
end;

procedure TfrmMainInstrumentation.UpdateCheckStateOfAllUnitsItem();
begin
  vstSelectUnits.BeginUpdate;
  try
    var lProjectDirOnly := not chkShowAll.Checked;
    var lAllInstrumented := openProject.AllInstrumented(lProjectDirOnly);
    var lNoneInstrumented := openProject.NoneInstrumented(lProjectDirOnly);
    if lAllInstrumented then
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.checked)
    else if lNoneInstrumented then
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.unchecked)
    else
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.greyed);
  finally
    vstSelectUnits.EndUpdate;
  end;
end;

procedure TfrmMainInstrumentation.UpdateCheckStateOfUnitsWithSpecificNode(const aUnitNode: PVirtualNode);
begin
  vstSelectUnits.BeginUpdate;
  try
    UpdateCheckStateOfAllUnitsItem();
    var lProjectDirOnly := not chkShowAll.Checked;
    if assigned(aUnitNode) then
    begin
      if DoesNodePointToAllItem(aUnitNode) then
        exit;
      if DoesNodePointToDirectory(aUnitNode) then
        exit;

      var lUnitName := fVstSelectUnitTools.GetName(aUnitNode);
      var lUnit := openProject.GetUnit(lUnitName, lProjectDirOnly);
      if lUnit.unAllInst then
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.checked)
      else if lUnit.unNoneInst then
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.unchecked)
      else
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.greyed);

    end;
  finally
    vstSelectUnits.EndUpdate;
  end;
end;


procedure TfrmMainInstrumentation.UpdateCheckStateOfDirectoryWithSpecificNode(const aDirNode: PVirtualNode);
begin
  vstSelectUnits.BeginUpdate;
  try
    var lProjectDirOnly := not chkShowAll.Checked;
    if assigned(aDirNode) then
    begin
      if DoesNodePointToAllItem(aDirNode) then
        exit;
      var lUnitName := fVstSelectUnitTools.GetName(aUnitNode);
      var lUnit := openProject.GetUnit(lUnitName, lProjectDirOnly);
      if lUnit.unAllInst then
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.checked)
      else if lUnit.unNoneInst then
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.unchecked)
      else
        fVstSelectUnitTools.SetCheckedState(aUnitNode, TCheckedState.greyed);

    end;
  finally
    vstSelectUnits.EndUpdate;
  end;
end;

procedure TfrmMainInstrumentation.EnablePC;
begin
  chkShowAll.Enabled                 := true;
  chkShowDirStructure.Enabled        := true;
  lblUnits.Enabled                   := true;
  lblClasses.Enabled                 := true;
  lblProcs.Enabled                   := true;
  vstSelectUnits.Enabled             := true;
  vstSelectClasses.Enabled           := true;
  vstSelectProcs.Enabled             := true;
end;

procedure TfrmMainInstrumentation.FillUnitTree(const aOnlyUnitsOfDPR: boolean; const aShowDirectories: boolean);
var
  lUnitInfoList : TUnitInstrumentationInfoList;
  lAllInstrumented : boolean;
  nonei: boolean;
  LFirstNode,
  lDirectoryNode,
  lParentDirNode,
  LNode : PVirtualNode;
  lFullPath: String;
  lSplittedPath : TStringDynArray;
  j: Integer;
begin
  LFirstNode := nil;
  lUnitInfoList := TUnitInstrumentationInfoList.Create;
  try
    fVstSelectUnitTools.BeginUpdate;
    fVstSelectUnitTools.Clear();
    try
      if openProject <> nil then
      begin
        openProject.GetUnitList(lUnitInfoList, aOnlyUnitsOfDPR);
        lUnitInfoList.SortByName;
        lAllInstrumented := true;
        nonei := true;
        LFirstNode := fVstSelectUnitTools.AddEntry(nil,ALL_UNITS, [ste_AllItem]);
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
                lDirectoryNode := fVstSelectUnitTools.GetChildByName(lParentDirNode, lSplittedPath[j])
              else
                lDirectoryNode := fVstSelectUnitTools.GetNodeByName(lSplittedPath[j]);
              if lDirectoryNode = nil then
              begin
                lDirectoryNode := fVstSelectUnitTools.AddEntry(lParentDirNode, lSplittedPath[j], [ste_Directory]);
              end;
              if lParentDirNode = nil then
                vstSelectUnits.Expanded[lDirectoryNode] := true;
              lParentDirNode := lDirectoryNode;
            end;
            LNode := fVstSelectUnitTools.AddEntry(lDirectoryNode, lUnitInfo.UnitName);
          end
          else
          begin
            LNode := fVstSelectUnitTools.AddEntry(nil,lUnitInfo.UnitName);
          end;
          if lUnitInfo.IsFullyInstrumented then
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csCheckedNormal;
            nonei := false;
          end
          else if lUnitInfo.IsNothingInstrumented then
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csUncheckedNormal;
            lAllInstrumented := false;
          end
          else
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csMixedNormal;
            lAllInstrumented := false;
            nonei:= false;
          end;
        end;
        if nonei then
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csUncheckedNormal
        else if lAllInstrumented  then
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csCheckedNormal
        else
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csMixedNormal;
      end;
    finally
      fVstSelectUnitTools.EndUpdate;
    end;
  finally
    lUnitInfoList.free;
  end;
  btnUnitSelectionWizard.Enabled := false;
  if assigned(LFirstNode) then
  begin
    clbUnitsClick(LFirstNode);
  end;
end; { TfrmMain.FillUnitTree }

function TfrmMainInstrumentation.GetClassSelectionInfoForNode(const aNode: PVirtualNode): ISelectionInfo;
begin
  result := TSelectionInfo.Create(fVstSelectClassTools.GetName(aNode));
end;


function TfrmMainInstrumentation.GetClassSelectionInfoForSelectedNode: ISelectionInfo;
begin
  result := GetClassSelectionInfoForNode(fVstSelectClassTools.GetSelectedNode);
end;

function TfrmMainInstrumentation.DoesNodePointToDirectory(const aNode: PVirtualNode): boolean;
begin
  result := TSpecialTagEnum.ste_Directory in fVstSelectUnitTools.GetSpecialTagSet(aNode);
end;

function TfrmMainInstrumentation.DoesNodePointToAllItem(const aNode: PVirtualNode): boolean;
begin
  result := TSpecialTagEnum.ste_AllItem in fVstSelectUnitTools.GetSpecialTagSet(aNode);
end;

function TfrmMainInstrumentation.GetSelectedUnitName: string;
begin
  result := fVstSelectUnitTools.GetName(fVstSelectUnitTools.GetSelectedNode);
end;

function  TfrmMainInstrumentation.GetSelectedUnitNode(): pVirtualNode;
begin
  result := fVstSelectUnitTools.GetSelectedNode;
end;


procedure TfrmMainInstrumentation.btnUnitSelectionWizardClick(Sender: TObject);
var
  LEnum : TVTVirtualNodeEnumerator;
  LWizard : tfmUnitWizard;
  LUnitSelectionList : TUnitSelectionList;
  LUnitSelection : TUnitSelection;
  LKey : string;
  LCheckedState : TCheckedState;
  LName : string;
begin
  if not assigned(fopenProject) then
    exit;

  if not (fVstSelectUnitTools.GetSpecialTagSet(fVstSelectUnitTools.GetSelectedNode()) = []) then
      exit;

  LWizard := tfmUnitWizard.Create(nil);
  try
    LEnum := vstSelectUnits.Nodes().GetEnumerator;
    while(LEnum.MoveNext) do
    begin
      // we are using a tree, so avoid the index
      LName := fVstSelectUnitTools.GetName(LEnum.Current);
      LCheckedState := fVstSelectUnitTools.GetCheckedState(LEnum.Current);
      if LCheckedState = TCheckedState.checked then
        LWizard.SelectedUnitNames.AddOrSetValue(Lname, 1);
    end;

    if LWizard.Execute(fopenProject, GetSelectedUnitName()) then
    begin
      LUnitSelectionList := TUnitSelectionList.Create;
      try
        for LKey in LWizard.SelectedUnitNames.Keys do
        begin
          LUnitSelection := TUnitSelection.Create(LKey);
          LUnitSelection.SelectedProcedures.Add('*');
          LUnitSelectionList.Add(LUnitSelection)
        end;
        fopenProject.ApplySelections(LUnitSelectionList, true);
        TriggerSelectionReload();
      finally
        LUnitSelectionList.Free;
      end;
    end;
  finally
    LWizard.Free;
  end;
end;

procedure TfrmMainInstrumentation.vstSelectClassesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbClassesClick(nil);
end;

procedure TfrmMainInstrumentation.vstSelectClassesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbClassesClickCheck(Sender, node);
  TThread.Queue(nil,
    procedure
    begin
       clbClassesClick(Sender);
    end
  );
  vstSelectClasses.Selected[node] := true;
end;

procedure TfrmMainInstrumentation.vstSelectProcsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbProcsClick(nil);
end;

procedure TfrmMainInstrumentation.vstSelectProcsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  ClickProcs(node.index, true);
  TThread.Queue(nil,
    procedure
    begin
       clbProcsClick(nil);
    end
  );
  vstSelectProcs.Selected[node] := true;
  var lSelectedUnit := fVstSelectUnitTools.GetSelectedNode;
  if assigned(lSelectedUnit) then
  begin
    UpdateCheckStateOfClassesForUnit(lSelectedUnit);
    UpdateCheckStateOfUnitsWithSpecificNode(lSelectedUnit);
  end;
end;

procedure TfrmMainInstrumentation.vstSelectUnitsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbUnitsClick(node);
end;

procedure TfrmMainInstrumentation.vstSelectUnitsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbUnitsClickCheck(node);
  if node = fVstSelectUnitTools.GetSelectedNode then
  begin
    RecreateClasses(false, node);
    clbClassesClick(vstSelectClasses);
  end;
end;

procedure TfrmMainInstrumentation.ClickProcs(index: integer; recreateCl: boolean);
var
  i : integer;
  LUnit: TUnit;
  LFqProcName : string;
  LEnumor : TVTVirtualNodeEnumerator;
  lSelectedClassInfo : ISelectionInfo;
begin
  lSelectedClassInfo := GetClassSelectionInfoForSelectedNode();
  if fVstSelectProcTools.GetCheckedState(index) = TCheckedState.greyed then
    fVstSelectProcTools.SetCheckedState(index, TCheckedState.checked);
  if index = 0 then
  begin
    fVstSelectProcTools.BeginUpdate;
    try
      LEnumor := vstSelectProcs.Nodes().GetEnumerator();
      while (LEnumor.MoveNext) do
      begin
        i := LEnumor.current.index;
        // skip first, else the evalutation contains the evalutation result as input
        if i = 0 then
          continue;
        LFqProcName := lSelectedClassInfo.GetProcedureNameForSelection(fVstSelectProcTools.GetName(i));
        fVstSelectProcTools.SetCheckedState(i, fVstSelectProcTools.GetCheckedState(0));
        openProject.InstrumentProc(GetSelectedUnitName, LFqProcName, fVstSelectProcTools.IsChecked(i));
      end;
    finally
      fVstSelectProcTools.EndUpdate;
    end;
  end
  else
  begin
    LFqProcName := lSelectedClassInfo.GetProcedureNameForSelection(fVstSelectProcTools.GetName(index));
    openProject.InstrumentProc(GetSelectedUnitName, LFqProcName, fVstSelectProcTools.IsChecked(index));
    LUnit := openProject.LocateUnit(GetSelectedUnitName);
    if LUnit.unAllInst then
      fVstSelectProcTools.SetCheckedState(0, TCheckedState.checked)
    else if LUnit.unNoneInst then
      fVstSelectProcTools.SetCheckedState(0, TCheckedState.unchecked)
    else
      fVstSelectProcTools.Getnode(0).CheckState := TCheckState.csMixedNormal;
  end;
  if recreateCl then
  begin
    var lSelectedUnitNode := fVstSelectUnitTools.GetSelectedNode;
    RecreateClasses(true, lSelectedUnitNode);
    UpdateCheckStateOfUnitsWithSpecificNode(lSelectedUnitNode);
  end;

end;

procedure TfrmMainInstrumentation.UpdateCheckStateOfClassesForUnit(const aUnitNode : PVirtualNode);
var
  all : boolean;
  none: boolean;
  LState : TCheckedState;
  LEnum : TVTVirtualNodeEnumerator;
  LCheckedState : TCheckedState;
begin
  all := true;
  none := true;
  LEnum := vstSelectClasses.Nodes().GetEnumerator;
  while(LEnum.MoveNext) do
  begin
    if LEnum.Current.Index = 0 then
      continue;
    LCheckedState := fVstSelectClassTools.GetCheckedState(LEnum.Current);
    if (LCheckedState = TCheckedState.checked) or (LCheckedState = TCheckedState.greyed) then
      none := false;
    if (LCheckedState = TCheckedState.Unchecked) or (LCheckedState = TCheckedState.greyed) then
      all := false;
  end;
  if all then
    LState := TCheckedState.Checked
  else if none then
    LState := TCheckedState.unchecked
  else
    LState := TCheckedState.greyed;
  if fVstSelectClassTools.GetCount() > 0 then
    fVstSelectClassTools.SetCheckedState(0, LState);
end; { TfrmMain.UpdateCheckStateOfClassesForUnit }

procedure TfrmMainInstrumentation.RecreateClasses(recheck: boolean;const aAffectedUnitNode: pVirtualNode);

  procedure SearchAndConfigureItem(const aNode : PVirtualNode;const aSelection : TClassInfo; const aCaption : string);
  var
    LFoundNode : PVirtualNode;
  begin
    LFoundNode := aNode;
    if not assigned(LFoundNode) then
      LFoundNode := fVstSelectClassTools.GetNodeByName(aCaption);

    if assigned(LFoundNode) then
    begin
      if aSelection.anAll then
        fVstSelectClassTools.SetCheckedState(LFoundNode, TCheckedState.Checked)
      else if aSelection.anNone then
        fVstSelectClassTools.SetCheckedState(LFoundNode, TCheckedState.Unchecked)
      else
        fVstSelectClassTools.SetCheckedState(LFoundNode, TCheckedState.greyed);
    end;
  end;

var
  LClassInfoList: TClassInfoList;
  LInfo : TClassInfo;
  i : integer;
  LFoundNode : PVirtualNode;
  LProcsList: TProcedureInstrumentationInfoList;

begin
  LClassInfoList := nil;
  LProcsList := TProcedureInstrumentationInfoList.Create;
  try
    var lUnitName := fVstSelectUnitTools.GetName(aAffectedUnitNode);
    openProject.GetProcList(lUnitName,LProcsList);
    LClassInfoList := GetClassesFromUnit(LProcsList);
    fVstSelectClassTools.BeginUpdate;
    try
      try
        LFoundNode := nil;
        if not recheck then
          fVstSelectClassTools.Clear;
        for i := 0 to LClassInfoList.Count - 1 do
        begin
          LInfo := LClassInfoList[i];
          LFoundNode := nil;
          if not recheck then
            LFoundNode := fVstSelectClassTools.AddEntry(nil,LInfo.anName);
          SearchAndConfigureItem(LFoundNode, LInfo, LInfo.anName);
        end;
        if not(LClassInfoList.ClasslessEntry.anAll and LClassInfoList.ClasslessEntry.anNone) then
        begin
          if not recheck then
            // need to insert it, we rebuid the items
            LFoundNode := fVstSelectClassTools.InsertEntry(0, ALL_CLASSLESS_PROCEDURES, [ste_AllItem]);
          SearchAndConfigureItem(LFoundNode,  LClassInfoList.ClasslessEntry, ALL_CLASSLESS_PROCEDURES);
        end;
        if not(LClassInfoList.AllClassesEntry.anAll and LClassInfoList.AllClassesEntry.anNone) then
        begin
          // need to insert it, we rebuid the items
          if not recheck then
            LFoundNode := fVstSelectClassTools.InsertEntry(0, ALL_CLASSES, [ste_AllItem]);
          // need to insert it, we rebuid the items
          SearchAndConfigureItem(LFoundNode, LClassInfoList.AllClassesEntry, ALL_CLASSES);
        end;
      finally
        vstSelectClasses.Invalidate;
      end;
      UpdateCheckStateOfClassesForUnit(aAffectedUnitNode);
      UpdateCheckStateOfUnitsWithSpecificNode(aAffectedUnitNode);
    finally
      fVstSelectClassTools.EndUpdate;
    end;

  finally
    LClassInfoList.Free;
    LProcsList.free;
  end;
end;

procedure TfrmMainInstrumentation.chkShowDirStructureClick(Sender: TObject);
begin
  FillUnitTree(not chkShowAll.Checked, chkShowDirStructure.Checked);
end;

procedure TfrmMainInstrumentation.clbClassesClick(Sender: TObject);
begin
  RecreateProcs(GetSelectedUnitName());
  ReloadSource;
end;

procedure TfrmMainInstrumentation.clbClassesClickCheck(Sender: TObject; const aNode: PVirtualNode);
var
  lProcInstrumentationInfoList: TProcedureInstrumentationInfoList;
  lProcInstrumentationInfo: TProcedureInstrumentationInfo;
begin
  var lCurrentlySelectedUnitName := GetSelectedUnitName;
  if fVstSelectClassTools.getCheckedState(aNode) = TCheckedState.greyed then
    fVstSelectClassTools.setCheckedState(aNode, TCheckedState.Checked);

  lProcInstrumentationInfoList := nil;
  try
    var lDoInstrument := fVstSelectClassTools.getCheckedState(aNode) = TCheckedState.Checked;
    lProcInstrumentationInfoList := TProcedureInstrumentationInfoList.Create;
    openProject.GetProcList(lCurrentlySelectedUnitName, lProcInstrumentationInfoList);
    var lClassSelectionInfo := GetClassSelectionInfoForNode(aNode);
      for lProcInstrumentationInfo in lProcInstrumentationInfoList do
        if (lProcInstrumentationInfo.IsProcedureValidForSelectedClass(lClassSelectionInfo)) then
          openProject.InstrumentProc(lCurrentlySelectedUnitName, lProcInstrumentationInfo.ProcedureName,lDoInstrument);
  finally
    lProcInstrumentationInfoList.free;
  end;
  var lSelectedUnitNode := fVstSelectUnitTools.GetSelectedNode();
  UpdateCheckStateOfClassesForUnit(lSelectedUnitNode);
  UpdateCheckStateOfUnitsWithSpecificNode(lSelectedUnitNode);
end;

procedure TfrmMainInstrumentation.clbProcsClick(Sender: TObject);
begin
  ReloadSource;
end;

procedure TfrmMainInstrumentation.btnSelectAllClick(Sender: TObject);
begin
  vstSelectUnits.SetCheckStateForAll(csCheckedNormal, false);
end;

procedure TfrmMainInstrumentation.ChangeClassSelectionWithoutEvent(const anIndex : integer);
var
  LAddToSelectionEvent : TVTAddToSelectionEvent;
begin
  LAddToSelectionEvent := vstSelectClasses.OnAddToSelection;
  vstSelectClasses.OnAddToSelection := nil;
  fVstSelectClassTools.setSelectedIndex(anIndex);
  vstSelectClasses.OnAddToSelection := LAddToSelectionEvent;
end;

procedure TfrmMainInstrumentation.clbUnitsClick(const aNode : pVirtualNode);
var
  LSelectedNode : PVirtualNode;
  LUnitPath : string;
begin
  fVstSelectProcTools.BeginUpdate;
  try
    fVstSelectProcTools.Clear;
    fVstSelectClassTools.BeginUpdate;
    fVstSelectUnitTools.BeginUpdate();
    try
      fVstSelectClassTools.Clear;
      LUnitPath := '';
      LSelectedNode := aNode;
      // skip all items
      if Assigned(LSelectedNode) then
      begin
        RecreateClasses(false, aNode);
        ChangeClassSelectionWithoutEvent(0);
        clbClassesClick(self);
        if not (TSpecialTagEnum.ste_Directory in fVstSelectUnitTools.GetSpecialTagSet(lSelectedNode)) then
        begin
          if assigned(openProject.LocateUnit(fVstSelectUnitTools.GetName(lSelectedNode))) then
          begin
            LUnitPath := openProject.GetUnitPath(fVstSelectUnitTools.GetName(lSelectedNode));
            OnShowStatusBarMessage(LUnitPath, false);
          end;
        end;
      end
      else if openProject <> nil then
        OnShowStatusBarMessage(openProject.Name, false);
      OnReloadSource(LUnitPath,0); // force reset
      btnUnitSelectionWizard.Enabled := assigned(LSelectedNode) and (fVstSelectUnitTools.GetSpecialTagSet(LSelectedNode) = []);
    finally
      fVstSelectUnitTools.EndUpdate();
      fVstSelectClassTools.EndUpdate;
    end;
  finally
    fVstSelectProcTools.EndUpdate;
  end;
end;


procedure TfrmMainInstrumentation.clbUnitsClickCheck(const aNode: PVirtualNode);
begin
  var lCheckedState := fVstSelectUnitTools.GetCheckedState(aNode);
  InstrumentUnit(aNode, lCheckedState);
  if DoesNodePointToAllItem(aNode) then
  begin
    UpdateCheckStateOfUnits();
    var lSelectedUnitNode := fVstSelectUnitTools.GetSelectedNode;
    if assigned(lSelectedUnitNode) then
      clbUnitsClick(lSelectedUnitNode);
  end
  else
    UpdateCheckStateOfUnitsWithSpecificNode(aNode);
end;

procedure TfrmMainInstrumentation.RecreateProcs(const aUnitName: string);

  procedure ConfigureAllItemCheckBox(const anIndex : integer; const aIsAllInstrumented, aIsNoneInstrumented : boolean);
  var
    LNode : PVirtualNode;
  begin
    LNode := fVstSelectProcTools.GetNode(anIndex);
    if aIsAllInstrumented then
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.Checked)
    else if aIsNoneInstrumented then
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.unchecked)
    else
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.greyed)
  end;

  procedure ConfigureProcedureCheckBox(const anIndex : integer; const aIsInstrumented : boolean);
  var
    LNode : PVirtualNode;
  begin
    LNode := fVstSelectProcTools.GetNode(anIndex);
    if aIsInstrumented then
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.Checked)
    else
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.unchecked)
  end;

var
  LProcInstrumentationInfoList : TProcedureInstrumentationInfoList;
  LIndex : integer;
  LInfo : TProcInfo;
  LProcInfoList : TProcInfoList;
  lClassSelectionInfo : ISelectionInfo;
  lAffectedUnitNode : pVirtualNode;
begin
  lAffectedUnitNode := fVstSelectUnitTools.GetNodeByName(aUnitName);
  if assigned(lAffectedUnitNode) and DoesNodePointToDirectory(lAffectedUnitNode) then
    exit;

  LProcInstrumentationInfoList := TProcedureInstrumentationInfoList.Create;
  try
    openProject.GetProcList(GetSelectedUnitName(), LProcInstrumentationInfoList);
    LProcInstrumentationInfoList.SortByName;
      fVstSelectProcTools.BeginUpdate;
      fVstSelectProcTools.Clear;
      try
        lClassSelectionInfo := GetClassSelectionInfoForSelectedNode();
        LProcInfoList := GetProcsForClassFromUnit(LProcInstrumentationInfoList, lClassSelectionInfo);
        for LInfo in LProcInfoList do
        begin
          LIndex := fVstSelectProcTools.AddEntry(nil,LInfo.piName).Index;
          ConfigureProcedureCheckBox(LIndex, LInfo.piInstrument)
        end;
        if LProcInfoList.Count > 0 then
        begin
          if fVstSelectClassTools.GetSelectedIndex = 0 then
          begin
            // selection string is ALL_PROCEDURES
            fVstSelectProcTools.InsertEntry(0, ALL_PROCEDURES, [ste_AllItem]);
            ConfigureAllItemCheckBox(0,LProcInfoList.AllInstrumented, LProcInfoList.NoneInstrumented);
          end
          else if sameText(lClassSelectionInfo.SelectionString, ALL_CLASSLESS_PROCEDURES) then
          begin
            // selection string is ALL_CLASSLESS_PROCEDURES
            fVstSelectProcTools.InsertEntry(0, ALL_CLASSLESS_PROCEDURES, [ste_AllItem]);
            var lAllInstrumented := true;
            var lNoneInstrumented := true;
            LProcInfoList.AreAllClassMethodsInstrumented('', lAllInstrumented, lNoneInstrumented);
            ConfigureAllItemCheckBox(0,lAllInstrumented, lNoneInstrumented);
          end
          else
          begin
            // selection string is the class name
            fVstSelectProcTools.InsertEntry(0, GetAllClassMethodsString(lClassSelectionInfo.SelectionString), [ste_AllItem]);
            var lAllInstrumented := true;
            var lNoneInstrumented := true;
            LProcInfoList.AreAllClassMethodsInstrumented(lClassSelectionInfo.SelectionString, lAllInstrumented, lNoneInstrumented);
            ConfigureAllItemCheckBox(0,lAllInstrumented, lNoneInstrumented);
          end;
        end;
        LProcInfoList.free;
      finally
        fVstSelectProcTools.EndUpdate;
      end;
  finally
    LProcInstrumentationInfoList.free;
  end;
end;

procedure TfrmMainInstrumentation.ReloadSource;
var
  lSelectedUnitName: string;
  lClassSelectionInfo : ISelectionInfo;
  lSelectedProcedureName : String;
  lResolvedProcName: string;
begin
  if vstSelectProcs.SelectedCount <= 0 then
    Exit;
  lClassSelectionInfo := GetClassSelectionInfoForSelectedNode;
  lSelectedProcedureName := fVstSelectProcTools.GetName(fVstSelectProcTools.GetSelectedIndex);
  lResolvedProcName := lClassSelectionInfo.GetProcedureNameForSelection(lSelectedProcedureName);
  lSelectedUnitName := GetSelectedUnitName;
  OnReloadSource(openProject.GetUnitPath(lSelectedUnitName), openProject.GetFirstLine(lSelectedUnitName, lResolvedProcName));
end;

procedure TfrmMainInstrumentation.RemoveInstrumentation(const aOnDoInstrument : TOnDoInstrument);
var
  chk: boolean;
begin
  fVstSelectUnitTools.BeginUpdate;
  try
    chk := chkShowAll.Checked;
    chkShowAll.Checked := true;
    fVstSelectUnitTools.SetCheckedState(0,TCheckedState.unchecked);
    clbUnitsClickCheck(fVstSelectUnitTools.GetNode(0));
    clbUnitsClick(fVstSelectUnitTools.GetSelectedNode);
    aOnDoInstrument;
    chkShowAll.Checked := chk;
  finally
    fVstSelectUnitTools.EndUpdate;
  end;
end;

procedure TfrmMainInstrumentation.RescanProject(const aOnRescan: TOnParseProject);
var
  iiu,iic,iip: integer;
begin
  iiu :=  fVstSelectUnitTools.GetSelectedNode.index;
  iic := fVstSelectClassTools.GetSelectedIndex;
  iip := fVstSelectProcTools.GetSelectedIndex;
  aOnRescan(openProject.name, true);
  if (iiu < fVstSelectUnitTools.GetCount) and
    (fVstSelectUnitTools.GetCount > 0) then
  begin
    fVstSelectUnitTools.setSelectedIndex(iiu);
    clbUnitsClick(fVstSelectUnitTools.GetSelectedNode);
    if (iic < fVstSelectClassTools.GetCount) and (fVstSelectClassTools.GetCount > 0) then
    begin
      ChangeClassSelectionWithoutEvent(iic);
      clbClassesClick(self);

      if (iip < fVstSelectProcTools.GetCount()) and (fVstSelectProcTools.GetCount() > 0) then
      begin
        fVstSelectProcTools.setSelectedIndex(iip);
        clbProcsClick(self);
      end;
    end;
  end;
end;

procedure TfrmMainInstrumentation.InvokeSearch(const aSearchTerm: string; const aTreeTool: TCheckableListTools);
var
  LEnumor : TVTVirtualNodeEnumerator;
  lVisible : Boolean;
begin
  aTreeTool.Tree.BeginUpdate;
  try
    LEnumor := aTreeTool.Tree.Nodes().GetEnumerator();
    while (LEnumor.MoveNext) do
    begin
      if aSearchTerm.IsEmpty then
        lVisible := true
      else
        lVisible := ContainsText(aTreeTool.GetName(LEnumor.current),aSearchTerm);
      aTreeTool.SetVisible(LEnumor.Current, lVisible);
    end;
  finally
    aTreeTool.Tree.EndUpdate;
  end;
end;

procedure TfrmMainInstrumentation.sbClassesInvokeSearch(Sender: TObject);
begin
  InvokeSearch(sbClasses.Text, fVstSelectClassTools);
end;

procedure TfrmMainInstrumentation.sbProceduresInvokeSearch(Sender: TObject);
begin
  InvokeSearch(sbProcedures.Text, fVstSelectProcTools);
end;

procedure TfrmMainInstrumentation.sbUnitsInvokeSearch(Sender: TObject);
begin
  InvokeSearch(sbUnits.Text, fVstSelectUnitTools);
end;

function TfrmMainInstrumentation.GetSelectedUnitIndex: integer;
begin
  result := fVstSelectUnitTools.GetSelectedIndex;
end;

procedure TfrmMainInstrumentation.SetSelectedUnitIndex(const anIndex: integer);
begin
  fVstSelectUnitTools.setSelectedIndex(anIndex);
end;

procedure TfrmMainInstrumentation.TriggerSelectionReload;
var
  LLastSelectedIndex : integer;
  LOldEvent : TVTChangeEvent;
begin
    // an auto-click is done... ignore instrumentation upon select
  LLastSelectedIndex := SelectedUnitIndex;
  LOldEvent := vstSelectUnits.OnChecked;
  vstSelectUnits.OnChecked := nil;
  chkShowAll.OnClick(nil);     // triggers reload
  vstSelectUnits.OnChecked := LOldEvent;
  if LLastSelectedIndex <> -1 then
    SelectedUnitIndex := LLastSelectedIndex;
end;

{ TfrmMain.RebloadSource }


end.
