{$I OPTIONS.INC}

unit gpUnitWizard;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls, Menus, ImgList, ActnList, ShellAPI, ShlObj,
  System.Actions, System.ImageList, System.Generics.Collections,
  VirtualTrees, gpParser, virtualTree.tools.checkable;

type

  TfmUnitWizard = class(TForm)
    pnlBottom: TPanel;
    oxButton1: TButton;
    oxButton2: TButton;
    vstUnitDependencies: TVirtualStringTree;
    lblUnitDependencies: TLabel;
  private
    fInitialUnitName : string;
    fOpenProject : TProject;
    fVstSelectUnitTools : TCheckableListTools;
    fSelectedUnitNames : TDictionary<string, Cardinal>;
    procedure addUnit(const aParent : PVirtualNode; const aUnitName : string);
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
  fSelectedUnitNames := TDictionary<string, Cardinal>.Create;
end;

destructor TfmUnitWizard.Destroy;
begin
  fVstSelectUnitTools.free;
  fSelectedUnitNames.free;
  inherited;
end;

procedure TfmUnitWizard.fillInUnits();
var
  LEnum : TVTVirtualNodeEnumerator;
  LNewNode : PVirtualNode;
begin
  fVstSelectUnitTools.BeginUpdate;
  fVstSelectUnitTools.Clear();
  try
    LNewNode := fVstSelectUnitTools.AddEntry(nil,fInitialUnitName);
    addUnit(LNewNode,fInitialUnitName);
    LEnum := vstUnitDependencies.Nodes().GetEnumerator;
    while(LEnum.MoveNext) do
    begin
      // we are using a tree, so avoid the index
      vstUnitDependencies.Expanded[LEnum.Current] := True;
    end;
  finally
    fVstSelectUnitTools.EndUpdate;
  end;
end;

procedure TfmUnitWizard.addUnit(const aParent: PVirtualNode; const aUnitName: string);
var
  LUnit : TUnit;
  LCurrentEntry: INode<TUnit>;
  LNewNode : PVirtualNode;
begin
  if assigned(aparent) then
    vstUnitDependencies.Expanded[aparent] := true;

  LUnit := fopenProject.LocateUnit(aUnitName);
  if not assigned(LUnit) then
    raise Exception.Create('Error: Could not locate unit "'+aUnitName+'".');
  begin
    LCurrentEntry := LUnit.unUnits.FirstNode;
    while assigned(LCurrentEntry) do
    begin
      LNewNode := fVstSelectUnitTools.AddEntry(aParent,LCurrentEntry.Data.unName);
      vstUnitDependencies.CheckState[LNewNode] := TCheckState.csUncheckedNormal;
      addUnit(LNewNode,LCurrentEntry.Data.unName);
      LCurrentEntry := LCurrentEntry.NextNode;
    end;
  end;
end;

procedure TfmUnitWizard.MoveSelectionsToResultList();
var
  LEnum : TVTVirtualNodeEnumerator;
  LCheckedState : TCheckedState;
  LName : string;
begin
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
