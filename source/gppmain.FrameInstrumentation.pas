unit gppmain.FrameInstrumentation;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ExtCtrls,
  virtualTree.tools.checkable,
  gpParser;

type
  TOnShowStatusBarMessage = procedure (const msg: string; const beep: boolean) of object;
  TReloadSourceEvent = procedure(const aPath : string; aLine : integer) of object;
  TOnDoInstrument = procedure() of object;
  TOnParseProject = procedure(const aProject: string; const aJustRescan: boolean) of object;

  TfrmMainInstrumentation = class(TFrame)
    Splitter1: TSplitter;
    Splitter2: TSplitter;
    pnlTop: TPanel;
    chkShowAll: TCheckBox;
    btnLoadInstrumentationSelection: TButton;
    btnSaveInstrumentationSelection: TButton;
    pnlUnits: TPanel;
    lblUnits: TStaticText;
    vstSelectUnits: TVirtualStringTree;
    pnlClasses: TPanel;
    lblClasses: TStaticText;
    vstSelectClasses: TVirtualStringTree;
    pnlProcs: TPanel;
    lblProcs: TStaticText;
    vstSelectProcs: TVirtualStringTree;
    procedure vstSelectProcsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectProcsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectClassesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectClassesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectUnitsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstSelectUnitsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    fVstSelectUnitTools       : TCheckableListTools;
    fVstSelectClassTools      : TCheckableListTools;
    fVstSelectProcTools       : TCheckableListTools;
    fopenProject : TProject;
    fOnShowStatusBarMessage : TOnShowStatusBarMessage;
    fOnReloadSource : TReloadSourceEvent;
    function  GetSelectedUnitName(): string;
    function  GetSelectedClassName(): string;
    function  GetSelectedUnitIndex(): integer;
    procedure SetSelectedUnitIndex(const anIndex : integer);

    procedure ClickProcs(index: integer; recreateCl: boolean);

    procedure DoOnUnitCheck(index: integer; instrument: boolean);

    procedure RecheckTopClass;
    procedure RecreateClasses(recheck: boolean); overload;
    procedure RecreateClasses(recheck: boolean;const aUnitName : string);overload;
    procedure RecreateProcs(const aProcName: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure DisablePC();
    procedure EnablePC;
    procedure ReloadSource;
    procedure ChangeClassSelectionWithoutEvent(const anIndex : integer);

    procedure clbProcsClick(Sender: TObject);
    procedure clbUnitsClick();
    procedure clbUnitsClickCheck(index: Integer);
    procedure clbClassesClick(Sender: TObject);
    procedure clbClassesClickCheck(Sender: TObject; index: Integer);

    procedure FillUnitTree(const aOnlyUnitsOfDPR: boolean);

    procedure RescanProject(const aOnRescan : TOnParseProject);
    procedure RemoveInstrumentation(const aOnDoInstrument : TOnDoInstrument);

    property openProject : TProject read fOpenProject write fOpenProject;
    property OnShowStatusBarMessage : TOnShowStatusBarMessage read fOnShowStatusBarMessage write fOnShowStatusBarMessage;
    property OnReloadSource : TReloadSourceEvent read fOnReloadSource write fOnReloadSource;
    property SelectedUnitIndex : integer read GetSelectedUnitIndex write SetSelectedUnitIndex;
  end;

implementation

uses
  GpString,
  gppMain.FrameInstrumentation.SelectionInfo;

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
  btnLoadInstrumentationSelection.Enabled := false;
  btnSaveInstrumentationSelection.Enabled := false;
  lblUnits.Enabled                   := false;
  lblClasses.Enabled                 := false;
  lblProcs.Enabled                   := false;
  vstSelectUnits.Enabled             := false;
  vstSelectClasses.Enabled           := false;
  vstSelectProcs.Enabled             := false;
end;

procedure TfrmMainInstrumentation.DoOnUnitCheck(index: integer; instrument: boolean);
var
  LEnumor : TVTVirtualNodeEnumerator;
  LFirstCheckedState : TCheckedState;
begin
  if index = 0 then
  begin
    vstSelectUnits.BeginUpdate;
    try
      LFirstCheckedState := fVstSelectUnitTools.getCheckedState(0);
      LEnumor := vstSelectUnits.Nodes().GetEnumerator();
      while (LEnumor.MoveNext) do
        if LEnumor.current.index <> 0 then
          fVstSelectUnitTools.SetCheckedState(LEnumor.Current.index, LFirstCheckedState);
    finally
      vstSelectUnits.EndUpdate;
    end;
    openProject.InstrumentAll(fVstSelectUnitTools.GetCheckedState(0) = TCheckedState.checked,not chkShowAll.Checked);
  end
  else
  begin
    if instrument then
      openProject.InstrumentUnit(fVstSelectUnitTools.GetName(index), fVstSelectUnitTools.GetCheckedState(index)=TCheckedState.checked);
    if openProject.AllInstrumented(not chkShowAll.Checked) then
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.checked)
    else if openProject.NoneInstrumented(not chkShowAll.Checked) then
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.unchecked)
    else
      fVstSelectUnitTools.SetCheckedState(0, TCheckedState.greyed);
  end;
end; { TfrmMain.DoOnUnitCheck }

procedure TfrmMainInstrumentation.EnablePC;
begin
  chkShowAll.Enabled                 := true;
  btnLoadInstrumentationSelection.Enabled := true;
  btnSaveInstrumentationSelection.Enabled := true;
  lblUnits.Enabled                   := true;
  lblClasses.Enabled                 := true;
  lblProcs.Enabled                   := true;
  vstSelectUnits.Enabled             := true;
  vstSelectClasses.Enabled           := true;
  vstSelectProcs.Enabled             := true;
end;

procedure TfrmMainInstrumentation.FillUnitTree(const aOnlyUnitsOfDPR: boolean);
var
  s    : TStringList;
  i    : integer;
  alli : boolean;
  nonei: boolean;
  allu : boolean;
  noneu: boolean;
  LFirstNode,
  LNode : PVirtualNode;
begin
  LFirstNode := nil;
  s := TStringList.Create;
  try
    fVstSelectUnitTools.BeginUpdate;
    fVstSelectUnitTools.Clear();
    try
      if openProject <> nil then
      begin
        openProject.GetUnitList(s, aOnlyUnitsOfDPR, true);
        s.Sorted := true;
        alli := true;
        nonei := true;
        LFirstNode := fVstSelectUnitTools.AddEntry('<all units>');
        for i := 0 to s.Count-1 do
        begin
          // Two last chars in each element of the list, returned by GetUnitList, are the two flags,
          // ("0" and "1"): first indicates "All Instrumented", second - "None instrumented" state
          LNode := fVstSelectUnitTools.AddEntry(ButLast(s[i], 2));
          allu  := (s[i][Length(s[i])-1] = '1');
          noneu := (s[i][Length(s[i])] = '1');
          if allu then
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csCheckedNormal;
            nonei := false;
          end
          else if noneu then
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csUncheckedNormal;
            alli := false;
          end
          else
          begin
            vstSelectUnits.CheckState[LNode] := TCheckState.csMixedNormal;
            alli := false;
            nonei:= false;
          end;
        end;
        if nonei then
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csUncheckedNormal
        else if alli  then
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csCheckedNormal
        else
          vstSelectUnits.CheckState[LFirstNode] := TCheckState.csMixedNormal;
      end;
    finally
      fVstSelectUnitTools.EndUpdate;
    end;
  finally
    s.free;
  end;
  if assigned(LFirstNode) then
  begin
    fVstSelectUnitTools.setSelectedIndex(0);
    clbUnitsClick();
  end;
end; { TfrmMain.FillUnitTree }

function TfrmMainInstrumentation.GetSelectedClassName: string;
begin
  result := fVstSelectClassTools.GetName(fVstSelectClassTools.GetSelectedIndex);
end;

function TfrmMainInstrumentation.GetSelectedUnitName: string;
begin
  result := fVstSelectUnitTools.GetName(fVstSelectUnitTools.GetSelectedIndex);
end;

procedure TfrmMainInstrumentation.vstSelectClassesAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbClassesClick(nil);
end;

procedure TfrmMainInstrumentation.vstSelectClassesChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbClassesClickCheck(nil, node.index);
  TThread.Queue(nil,
    procedure
    begin
       clbClassesClick(nil);
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
end;

procedure TfrmMainInstrumentation.vstSelectUnitsAddToSelection(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbUnitsClick();
end;

procedure TfrmMainInstrumentation.vstSelectUnitsChecked(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  clbUnitsClickCheck(node.index);
  TThread.Queue(nil,
    procedure
    begin
       clbUnitsClick();
    end
  );
  vstSelectUnits.Selected[node] := true;
end;

procedure TfrmMainInstrumentation.ClickProcs(index: integer; recreateCl: boolean);
var
  i : integer;
  un: TUnit;
  LFqProcName : string;
  LEnumor : TVTVirtualNodeEnumerator;

begin
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
        if GetSelectedClassName[1] = '<' then
          LFqProcName := fVstSelectProcTools.GetName(i)
        else
          LFqProcName := GetSelectedClassName + '.' + fVstSelectProcTools.GetName(i);
        fVstSelectProcTools.SetCheckedState(i, fVstSelectProcTools.GetCheckedState(0));
        openProject.InstrumentProc(GetSelectedUnitName, LFqProcName, fVstSelectProcTools.IsChecked(i));
      end;
    finally
      fVstSelectProcTools.EndUpdate;
    end;
  end
  else
  begin
    if GetSelectedClassName[1] = '<' then
      LFqProcName := fVstSelectProcTools.GetName(index)
    else
      LFqProcName := GetSelectedClassName + '.' + fVstSelectProcTools.GetName(index);
    openProject.InstrumentProc(GetSelectedUnitName, LFqProcName, fVstSelectProcTools.IsChecked(index));
    un := openProject.LocateUnit(GetSelectedUnitName);
    if un.unAllInst then
      fVstSelectProcTools.SetCheckedState(0, TCheckedState.checked)
    else if un.unNoneInst then
      fVstSelectProcTools.SetCheckedState(0, TCheckedState.unchecked)
    else
      fVstSelectProcTools.Getnode(0).CheckState := TCheckState.csCheckedDisabled;
  end;
  if recreateCl then
    RecreateClasses(true);
end;


procedure TfrmMainInstrumentation.RecreateClasses(recheck: boolean);
begin
  RecreateClasses(recheck, GetSelectedUnitName());
end;

procedure TfrmMainInstrumentation.RecheckTopClass;
var
  all : boolean;
  none: boolean;
  LState : TCheckedState;
  LSelectedIndex : cardinal;
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
    LCheckedState := fVstSelectClassTools.GetCheckedState(LEnum.Current.Index);
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
  fVstSelectClassTools.SetCheckedState(0, LState);

  LSelectedIndex := fVstSelectUnitTools.GetSelectedIndex;
  fVstSelectUnitTools.SetCheckedState(LSelectedIndex, LState);
  DoOnUnitCheck(LSelectedIndex,false);
end; { TfrmMain.RecheckTopClass }

procedure TfrmMainInstrumentation.RecreateClasses(recheck: boolean; const aUnitName : string);

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
  LInfoList: TClassInfoList;
  LInfo : TClassInfo;
  i : integer;
  LFoundNode : PVirtualNode;
  LUnitProcsList: TStringList;
const
  CLASSLESS_PROCEUDURES = '<classless procedures>';
  ALL_CLASSES = '<all classes>';
begin
  LInfoList := nil;
  LUnitProcsList := TStringList.Create;
  try
    LInfoList := nil; // in case of exception
    openProject.GetProcList(aUnitName,LUnitProcsList,true);
    LInfoList := GetClassesFromUnit(LUnitProcsList);
    fVstSelectClassTools.BeginUpdate;
    try
      try
        LFoundNode := nil;
        if not recheck then
          fVstSelectClassTools.Clear;
        for i := 0 to LInfoList.Count - 1 do
        begin
          LInfo := LInfoList[i];
          LFoundNode := nil;
          if not recheck then
            LFoundNode := fVstSelectClassTools.AddEntry(LInfo.anName);
          SearchAndConfigureItem(LFoundNode, LInfo, LInfo.anName);
        end;
        if not(LInfoList.ClasslessEntry.anAll and LInfoList.ClasslessEntry.anNone) then
        begin
          if not recheck then
            // need to insert it, we rebuid the items
            LFoundNode := fVstSelectClassTools.InsertEntry(0, CLASSLESS_PROCEUDURES);
          SearchAndConfigureItem(LFoundNode,  LInfoList.ClasslessEntry, CLASSLESS_PROCEUDURES);
        end;
        if not(LInfoList.AllClassesEntry.anAll and LInfoList.AllClassesEntry.anNone) then
        begin
          // need to insert it, we rebuid the items
          if not recheck then
            LFoundNode := fVstSelectClassTools.InsertEntry(0, ALL_CLASSES);
          // need to insert it, we rebuid the items
          SearchAndConfigureItem(LFoundNode, LInfoList.AllClassesEntry, ALL_CLASSES);
        end;
      finally
        vstSelectClasses.Invalidate;
      end;
      RecheckTopClass;
    finally
      fVstSelectClassTools.EndUpdate;
    end;

  finally
    LInfoList.Free;
    LUnitProcsList.free;
  end;
end;

procedure TfrmMainInstrumentation.clbClassesClick(Sender: TObject);
begin
  RecreateProcs(GetSelectedUnitName());
  ReloadSource;
end;

procedure TfrmMainInstrumentation.clbClassesClickCheck(Sender: TObject; index: Integer);
var
  un: TStringList;
  cl: string;
  i : integer;
  p : integer;
begin
  if fVstSelectClassTools.getCheckedState(index) = TCheckedState.greyed then
    fVstSelectClassTools.setCheckedState(index, TCheckedState.Checked);
  if index = 0 then
  begin
    fVstSelectUnitTools.SetCheckedState(fVstSelectUnitTools.GetSelectedIndex,fVstSelectClassTools.getCheckedState(index));
    clbUnitsClickCheck(fVstSelectUnitTools.GetSelectedIndex);
    RecreateClasses(true);
  end
  else
  begin
    un := TStringList.Create;
    try
      openProject.GetProcList(GetSelectedUnitName, un, false);
      cl := UpperCase(GetSelectedClassName());
      for i := 0 to un.Count - 1 do
      begin
        p := Pos('.', un[i]);
        if ((cl[1] = '<') and (p = 0)) or
          ((cl[1] <> '<') and (UpperCase(Copy(un[i], 1, p - 1)) = cl)) then
        begin
          openProject.InstrumentProc(GetSelectedUnitName, un[i],fVstSelectClassTools.getCheckedState(index) = TCheckedState.Checked);
        end;
      end;
    finally
      un.free;
    end;
    RecheckTopClass;
  end;
end;

procedure TfrmMainInstrumentation.clbProcsClick(Sender: TObject);
begin
  ReloadSource;
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

procedure TfrmMainInstrumentation.clbUnitsClick();
var
  LIndex : integer;
  LSelectedNode : PVirtualNode;

begin
  fVstSelectProcTools.BeginUpdate;
  try
    fVstSelectProcTools.Clear;
    fVstSelectClassTools.BeginUpdate;
    try
      fVstSelectClassTools.Clear;
      LIndex := 0;
      LSelectedNode := fVstSelectUnitTools.GetSelectedNode();
      if assigned(lSelectedNode) then
        LIndex := LSelectedNode.Index;
      // skip all items
      if LIndex > 0 then
      begin
        RecreateClasses(false);
        ChangeClassSelectionWithoutEvent(0);
        clbClassesClick(self);
        OnShowStatusBarMessage(openProject.GetUnitPath(fVstSelectUnitTools.GetName(lSelectedNode.Index)), false)
      end
      else if openProject <> nil then
        OnShowStatusBarMessage(openProject.Name, false);
      OnReloadSource('',0); // force reset
    finally
      fVstSelectClassTools.EndUpdate;
    end;
  finally
    fVstSelectProcTools.EndUpdate;
  end;
end;


procedure TfrmMainInstrumentation.clbUnitsClickCheck(index: Integer);
begin
  if fVstSelectUnitTools.GetCount() = 1 then
    fVstSelectUnitTools.SetCheckedState(index, TCheckedState.unchecked)
  else
  begin
    if fVstSelectUnitTools.GetCheckedState(index)=TCheckedState.greyed then
      fVstSelectUnitTools.SetCheckedState(index, TCheckedState.checked);
    DoOnUnitCheck(index,true);
  end;
end;

procedure TfrmMainInstrumentation.RecreateProcs(const aProcName: string);

  procedure ConfigureCheckBox(const anIndex : integer; const aAllI, aNoneI : boolean);
  var
    LNode : PVirtualNode;
  begin
    LNode := fVstSelectProcTools.GetNode(anIndex);
    if aAllI then
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.Checked)
    else if aNoneI then
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.unchecked)
    else
      fVstSelectProcTools.SetCheckedState(LNode, TCheckedState.greyed)
  end;

var
  LProcNameList    : TStringList;
  LIndex : integer;
  LInfo : TProcInfo;
  LInfoList : TProcInfoList;
begin
  LProcNameList := TStringList.Create;
  try
    openProject.GetProcList(GetSelectedUnitName(), LProcNameList, true);
    LProcNameList.Sorted := true;
    //clbProcs.Perform(WM_SETREDRAW, 0, 0);
    try
      fVstSelectProcTools.BeginUpdate;
      fVstSelectProcTools.Clear;
      try
        LInfoList := GetProcsFromUnit(LProcNameList,fVstSelectClassTools.GetSelectedIndex,GetSelectedClassName());
        for LInfo in LInfoList do
        begin
          LIndex := fVstSelectProcTools.AddEntry(LInfo.anName).Index;
          ConfigureCheckBox(LIndex, LInfo.anInstrument, not LInfo.anInstrument);
        end;
        if LInfoList.Count > 0 then
        begin
          if fVstSelectClassTools.GetSelectedIndex = 0 then
            fVstSelectProcTools.InsertEntry(0, '<all procedures>')
          else if GetSelectedClassName.StartsWith('<') then
            fVstSelectProcTools.InsertEntry(0, '<all classless procedures>')
          else
            fVstSelectProcTools.InsertEntry(0, '<all ' + GetSelectedClassName + ' methods>');
          ConfigureCheckBox(0,LInfoList.AllInstrumented, LInfoList.NoneInstrumented);
        end;
        LInfoList.free;
      finally
        fVstSelectProcTools.EndUpdate;
      end;
    finally
      //clbProcs.Perform(WM_SETREDRAW, 1, 0);
    end;
  finally
    LProcNameList.free;
  end;
end; procedure TfrmMainInstrumentation.ReloadSource;
var
  unt: string;
  cls: string;
  prc: string;
begin
  if vstSelectProcs.SelectedCount <= 0 then
    Exit;
  cls := GetSelectedClassName;
  if cls[1] = '<' then
    prc := fVstSelectProcTools.GetName(fVstSelectProcTools.GetSelectedIndex)
  else
    prc := cls + '.' + fVstSelectProcTools.GetName(fVstSelectProcTools.GetSelectedIndex);
  unt := GetSelectedUnitName;
  OnReloadSource(openProject.GetUnitPath(unt), openProject.GetFirstLine(unt, prc));
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
    clbUnitsClickCheck(0);
    clbUnitsClick();
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
    clbUnitsClick();
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

function TfrmMainInstrumentation.GetSelectedUnitIndex: integer;
begin
  result := fVstSelectUnitTools.GetSelectedIndex;
end;

procedure TfrmMainInstrumentation.SetSelectedUnitIndex(const anIndex: integer);
begin
  fVstSelectUnitTools.setSelectedIndex(anIndex);
end;

{ TfrmMain.RebloadSource }


end.
