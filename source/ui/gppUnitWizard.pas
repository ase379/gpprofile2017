{$I OPTIONS.INC}

unit gppUnitWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, ActnList, ShellAPI, ShlObj,
  System.Actions, System.ImageList, System.Generics.Collections,
  VirtualTrees, gpParser, virtualTree.tools.checkable,
  gpParser.Units, VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree,
  VirtualTrees.AncestorVCL;

type

  TfmUnitWizard = class(TForm)
    pnlBottom: TPanel;
    oxButton1: TButton;
    oxButton2: TButton;
    vstUnitDependencies: TVirtualStringTree;
    lblUnitDependencies: TLabel;
    procedure vstUnitDependenciesExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode; var Allowed: Boolean);
  private
    fInitialUnitName : string;
    fOpenProject : TProject;
    fVstSelectUnitTools : TCheckableListTools;
    fLocateUnitCache : TDictionary<string, TUnit>;
    // lookup to speed up detection of double names
    fSelectedUnitNames : TDictionary<string, Cardinal>;
    // lookup to detect unit recursion
    fProcessedUnitNames : TDictionary<string, Cardinal>;
    procedure addUnit(const aParent : PVirtualNode; const aUnitName : string;const aDoRecursive: boolean);
    procedure fillInUnits();
    procedure MoveSelectionsToResultList();

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function Execute(const aOpenProject : TProject;const aInitialUnitName : string): Boolean;

    property SelectedUnitNames : TDictionary<string, Cardinal> read fSelectedUnitNames;
  end;

var
  fmUnitWizard: TfmUnitWizard;


implementation

uses gppTree;

{$R *.DFM}


{ TfmUnitWizard }


constructor TfmUnitWizard.Create(AOwner: TComponent);
begin
  inherited;
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
    addUnit(LNewNode,fInitialUnitName, false);
    vstUnitDependencies.Expanded[LNewNode] := True;
  finally
    fVstSelectUnitTools.EndUpdate;
  end;
end;

procedure TfmUnitWizard.addUnit(const aParent: PVirtualNode; const aUnitName: string; const aDoRecursive: boolean);

  function LocateUnit(): TUnit;
  begin
    if not fLocateUnitCache.TryGetValue(aUnitName, result) then
    begin
      result := fopenProject.LocateUnit(aUnitName);
      fLocateUnitCache.Add(aUnitName, result);
    end;
  end;

var
  LUnit : TUnit;
  LUnitEnumor: TRootNode<TUnit>.TEnumerator;
  LNewNode : PVirtualNode;
  LName : string;
  LRecursiveUnit : Boolean;
  LMissingUnit : Boolean;
begin
  fProcessedUnitNames.AddOrSetValue(aUnitName,fProcessedUnitNames.count);
  LUnit := LocateUnit();
  if not assigned(LUnit) then
    raise Exception.Create('Error: Could not locate unit "'+aUnitName+'".');
  begin
    LUnitEnumor := LUnit.unUnits.GetEnumerator();
    while LUnitEnumor.MoveNext do
    begin
      LNewNode := nil;
      LName := LUnitEnumor.Current.Data.unName;
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
            vstUnitDependencies.CheckState[LNewNode] := TCheckState.csCheckedNormal
          else
            vstUnitDependencies.CheckState[LNewNode] := TCheckState.csUncheckedNormal;
          if aDoRecursive then
             addUnit(LNewNode,LName,aDoRecursive)
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

procedure TfmUnitWizard.vstUnitDependenciesExpanding(Sender: TBaseVirtualTree; Node: PVirtualNode;
  var Allowed: Boolean);
begin
  if assigned(Node.Parent) then
    addUnit(Node,fVstSelectUnitTools.GetName(Node), False);
end;

function TfmUnitWizard.Execute(const aOpenProject: TProject; const aInitialUnitName: String): Boolean;

begin
  fOpenProject := aOpenProject;
  fInitialUnitName := aInitialUnitName;
  fillInUnits;
  result := ShowModal = mrOk;
  if result then
    MoveSelectionsToResultList();
end;

end.
