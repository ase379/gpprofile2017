{$I OPTIONS.INC}

unit gppUnitWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, ActnList, ShellAPI, ShlObj,
  System.Actions, System.ImageList, System.Generics.Collections,
  VirtualTrees, gpParser, virtualTree.tools.checkable,
  gpParser.Units, VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL, Vcl.ToolWin, Vcl.ActnMan, Vcl.ActnCtrls, Vcl.NumberBox;

type
  TOnSetCheckedStateOfNewItem = reference to procedure(const aNode : PVirtualNode);

  TfmUnitWizard = class(TForm)
    pnlBottom: TPanel;
    oxButton1: TButton;
    oxButton2: TButton;
    vstUnitDependencies: TVirtualStringTree;
    pnlTop: TPanel;
    btnDeselectLevels: TButton;
    numberLevelsApplied: TNumberBox;
    lblLevelsApplied: TLabel;
    btnSelectLevels: TButton;
    procedure vstUnitDependenciesExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
    procedure btnSelectLevelsClick(Sender: TObject);
    procedure vstUnitDependenciesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstUnitDependenciesRemoveFromSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure SelectChildrenUntilLevel(const aParentNode, aFirstChildNode: PVirtualNode; aLevel : integer; const aIsChecked: boolean);
    procedure btnDeselectLevelsClick(Sender: TObject);
    function LocateUnit(const aUnitName : String): TUnit;

  private
    fInitialUnitName : string;
    fOpenProject : TProject;
    fVstSelectUnitTools : TCheckableListTools;
    fLocateUnitCache : TDictionary<string, TUnit>;
    // lookup to speed up detection of double names
    fSelectedUnitNames : TDictionary<string, Cardinal>;
    // lookup to detect unit recursion
    fProcessedUnitNames : TDictionary<string, Cardinal>;
    fSelectedNode : pVirtualNode;
    procedure addChildNodes(const aParent : PVirtualNode; const aUnitName : string;const aDoRecursive: boolean);
    procedure fillInUnits();
    procedure MoveSelectionsToResultList();
    procedure EnableButtonsUponSelection();

  protected


  public
    constructor Create(AOwner: TComponent); overload; override;
    destructor Destroy; override;

    function Execute(const aOpenProject : TProject;const aInitialUnitName : string): Boolean;

    property SelectedUnitNames : TDictionary<string, Cardinal> read fSelectedUnitNames;
  end;

var
  fmUnitWizard: TfmUnitWizard;


implementation

uses gppTree, VirtualTrees.Types;

{$R *.DFM}


{ TfmUnitWizard }

function TfmUnitWizard.LocateUnit(const aUnitName : String): TUnit;
begin
  if not fLocateUnitCache.TryGetValue(aUnitName, result) then
  begin
    result := fopenProject.LocateUnit(aUnitName);
    fLocateUnitCache.Add(aUnitName, result);
  end;
  if not assigned(result) then
    raise Exception.Create('Error: Could not locate unit "'+aUnitName+'".');
end;

procedure TfmUnitWizard.SelectChildrenUntilLevel(const aParentNode, aFirstChildNode: PVirtualNode; aLevel : integer; const aIsChecked: boolean);

  procedure setItemChecked(const aUnitName : String);
  begin
    if aIsChecked then
      fSelectedUnitNames.AddOrSetValue(aUnitName, ord(aIsChecked))
    else
      fSelectedUnitNames.Remove(aUnitName);
  end;

  procedure RegisterAndExpandNode(const aParentNode : PVirtualNode; const aCurrentLevel : integer);
  var
    LUnit : TUnit;
    LUnitEnumor: TRootNode<TUnit>.TEnumerator;
    lAllowed : boolean;
  begin
    if aCurrentLevel >= numberLevelsApplied.ValueInt then
     exit;
    LUnit := LocateUnit(fVstSelectUnitTools.GetName(aParentNode));
    LUnitEnumor := LUnit.unUnits.GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      setItemChecked(LUnitEnumor.Current.Data.Name);
    end;
    vstUnitDependencies.Expanded[aParentNode] := aIsChecked;
    vstUnitDependenciesExpanding(vstUnitDependencies, aParentNode, lAllowed);
  end;

begin
  if not assigned(aFirstChildNode) then
    exit;
  if aLevel > numberLevelsApplied.ValueInt then
    exit;
  RegisterAndExpandNode(aParentNode, aLevel);
  var lNode := aFirstChildNode;
  while(assigned(lNode)) do
  begin
    RegisterAndExpandNode(lNode, aLevel+1);
    SelectChildrenUntilLevel(lNode, lNode.FirstChild, aLevel+1, aIsChecked);
    lNode := lNode.NextSibling;
  end;
end;

procedure TfmUnitWizard.btnDeselectLevelsClick(Sender: TObject);
begin
  vstUnitDependencies.BeginUpdate;

  SelectChildrenUntilLevel(fSelectedNode, fSelectedNode.FirstChild, 0, false);
  vstUnitDependencies.EndUpdate;
end;

procedure TfmUnitWizard.btnSelectLevelsClick(Sender: TObject);
begin
  vstUnitDependencies.BeginUpdate;
  SelectChildrenUntilLevel(fSelectedNode, fSelectedNode.FirstChild, 0, true);
  vstUnitDependencies.EndUpdate;
end;

constructor TfmUnitWizard.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  fVstSelectUnitTools := TCheckableListTools.Create(vstUnitDependencies, cid_Unit);
  vstUnitDependencies.TreeOptions.AutoOptions := vstUnitDependencies.TreeOptions.AutoOptions - [TVTAutoOption.toAutoTristateTracking];
  vstUnitDependencies.TreeOptions.SelectionOptions := vstUnitDependencies.TreeOptions.SelectionOptions - [TVTSelectionOption.toSyncCheckboxesWithSelection];
  fLocateUnitCache := TDictionary<string, TUnit>.Create();
  fSelectedUnitNames := TDictionary<string, Cardinal>.Create;
  fProcessedUnitNames := TDictionary<string, Cardinal>.Create;
end;

destructor TfmUnitWizard.Destroy;
begin
  fVstSelectUnitTools.free;
  fLocateUnitCache.free;
  fSelectedUnitNames.free;
  fProcessedUnitNames.Free;
  inherited;
end;

procedure TfmUnitWizard.EnableButtonsUponSelection();
begin
  var lIsAnySelected := vstUnitDependencies.SelectedCount > 0;
  if assigned(numberLevelsApplied) then
    numberLevelsApplied.Enabled := lIsAnySelected;
  if assigned(lblLevelsApplied) then
    lblLevelsApplied.Enabled := lIsAnySelected;

  if assigned(btnDeSelectLevels) then
    btnSelectLevels.Enabled := lIsAnySelected;
  if assigned(btnDeSelectLevels) then
    btnDeSelectLevels.Enabled := lIsAnySelected;
end;

procedure TfmUnitWizard.fillInUnits();
var
  LNewNode : PVirtualNode;
begin
  fVstSelectUnitTools.BeginUpdate;
  fVstSelectUnitTools.Clear();
  try
    LNewNode := fVstSelectUnitTools.AddEntry(nil,fInitialUnitName);
    if fSelectedUnitNames.ContainsKey(fInitialUnitName) then
      vstUnitDependencies.CheckState[LNewNode] := TCheckState.csCheckedNormal
    else
      vstUnitDependencies.CheckState[LNewNode] := TCheckState.csUncheckedNormal;
    addChildNodes(LNewNode,fInitialUnitName, false);
    vstUnitDependencies.Expanded[LNewNode] := True;
  finally
    fVstSelectUnitTools.EndUpdate;
  end;
end;

procedure TfmUnitWizard.addChildNodes(const aParent: PVirtualNode; const aUnitName: string; const aDoRecursive: boolean);
var
  LUnit : TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  LNewNode : PVirtualNode;
  LName : string;
  LRecursiveUnit : Boolean;
  LMissingUnit : Boolean;
begin
  fProcessedUnitNames.AddOrSetValue(aUnitName,fProcessedUnitNames.count);
  LUnit := LocateUnit(aUnitName);
  begin
    LUnitEnumor := LUnit.unUnits.GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      LNewNode := nil;
      LName := LUnitEnumor.Current.Data.Name;
      LMissingUnit := fOpenProject.IsMissingUnit(LName);
      if not LMissingUnit then
      begin
        LNewNode := fVstSelectUnitTools.GetChildByName(aParent, LName);
        if not assigned(LNewNode) then
        begin
          LNewNode := fVstSelectUnitTools.AddEntry(aParent,LName);
          LNewNode.CheckType := ctCheckBox;
        end;
      end;
      if Assigned(LNewNode) then
      begin
        LRecursiveUnit := fProcessedUnitNames.ContainsKey(LName);
        if LRecursiveUnit then
        begin
          vstUnitDependencies.CheckState[LNewNode] := TCheckState.csMixedDisabled;
        end
        else
        begin
          if fSelectedUnitNames.ContainsKey(LName) then
            fVstSelectUnitTools.SetCheckedState(LNewNode, TCheckedState.checked)
          else
            fVstSelectUnitTools.SetCheckedState(LNewNode, TCheckedState.unchecked);
          if aDoRecursive then
             addChildNodes(LNewNode,LName,aDoRecursive)
          else
          begin
            if LUnitEnumor.Current.Data.unUnits.Count > 0 then
              include(LNewNode.States, TVirtualNodeState.vsHasChildren)
          end;
        end;
      end;
    end;
    LUnitEnumor.Free;
  end;
  fProcessedUnitNames.Remove(aUnitName);
end;

procedure TfmUnitWizard.MoveSelectionsToResultList();
var
  LEnum : TVTVirtualNodeEnumerator;
  LCheckedState : TCheckedState;
  LName : string;
begin
  fSelectedUnitNames.Clear;
  LEnum := vstUnitDependencies.Nodes().GetEnumerator;
  while(LEnum.MoveNext) do
  begin
    // we are using a tree, so avoid the index
    LName := fVstSelectUnitTools.GetName(LEnum.Current);
    LCheckedState := fVstSelectUnitTools.GetCheckedState(LEnum.Current);
    if LCheckedState = TCheckedState.checked then
    begin
      if not fSelectedUnitNames.ContainsKey(LName) then
        fSelectedUnitNames.Add(LName, 0);
    end;
  end;
end;

procedure TfmUnitWizard.vstUnitDependenciesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  EnableButtonsUponSelection();
  fSelectedNode := node;
end;

procedure TfmUnitWizard.vstUnitDependenciesExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode;
  var Allowed: Boolean);
begin
  if assigned(Node.Parent) then
    addChildNodes(Node,fVstSelectUnitTools.GetName(Node), False);
end;

procedure TfmUnitWizard.vstUnitDependenciesRemoveFromSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  EnableButtonsUponSelection();
  if node = fSelectedNode then
    fSelectedNode := nil;
end;

function TfmUnitWizard.Execute(const aOpenProject: TProject; const aInitialUnitName: String): Boolean;
begin
  fOpenProject := aOpenProject;
  fInitialUnitName := aInitialUnitName;
  fillInUnits;
  EnableButtonsUponSelection();
  result := ShowModal = mrOk;
  if result then
    MoveSelectionsToResultList();
end;

end.
