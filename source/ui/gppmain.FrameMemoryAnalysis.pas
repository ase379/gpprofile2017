unit gppmain.FrameMemoryAnalysis;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ExtCtrls, Vcl.Actnlist, vcl.menus,
  gppresults,virtualTree.tools.memorystatistics, System.Actions, System.ImageList, Vcl.ImgList, Vcl.WinXCtrls,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.AncestorVCL, VirtualTrees.BaseTree;

type
  {$SCOPEDENUMS ON}
  TReloadSourceEvent = procedure(const aPath : string; aLine : integer) of object;
  TfrmMemProfiling = class(TFrame)
    PageControl2: TPageControl;
    tabProcedures: TTabSheet;
    splitCallees: TSplitter;
    pnThreadProcs: TPanel;
    lblSelectThreadProc: TLabel;
    pnlBrowser: TPanel;
    ToolBar3: TToolBar;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    cbxSelectThreadProc: TComboBox;
    pnlTopTwo: TPanel;
    splitCallers: TSplitter;
    pnlCallers: TPanel;
    vstCallers: TVirtualStringTree;
    pnlCurrent: TPanel;
    vstProcs: TVirtualStringTree;
    pnlCallees: TPanel;
    vstCallees: TVirtualStringTree;
    tabClasses: TTabSheet;
    vstClasses: TVirtualStringTree;
    pnThreadClass: TPanel;
    Label1: TLabel;
    cbxSelectThreadClass: TComboBox;
    tabUnits: TTabSheet;
    pnThreadUnits: TPanel;
    Label2: TLabel;
    cbxSelectThreadUnit: TComboBox;
    vstUnits: TVirtualStringTree;
    tabThreads: TTabSheet;
    vstThreads: TVirtualStringTree;
    popBrowseNext: TPopupMenu;
    popBrowsePrevious: TPopupMenu;
    ActionList1: TActionList;
    actBrowsePrevious: TAction;
    actBrowseNext: TAction;
    imglButtons: TImageList;
    popAnalysisListview: TPopupMenu;
    mnuHideNotExecuted: TMenuItem;
    mnuExportProfile: TMenuItem;
    sbFilterCallees: TSearchBox;
    sbFilterProcs: TSearchBox;
    sbFilterCallers: TSearchBox;
    sbFilterClasses: TSearchBox;
    sbFilterUnits: TSearchBox;
    sbFilterThreads: TSearchBox;
    procedure splitCallersMoved(Sender: TObject);
    procedure cbxSelectThreadProcChange(Sender: TObject);
    procedure cbxSelectThreadUnitChange(Sender: TObject);
    procedure cbxSelectThreadClassChange(Sender: TObject);
    procedure PageControl2Change(Sender: TObject);
    procedure executeChange(Sender: TBaseVirtualTree);
    procedure vstCalleesNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure actBrowsePreviousExecute(Sender: TObject);
    procedure actBrowseNextExecute(Sender: TObject);
    procedure actBrowsePreviousUpdate(Sender: TObject);
    procedure actBrowseNextUpdate(Sender: TObject);
    procedure sbFilterCallersChange(Sender: TObject);
    procedure sbFilterProcsInvokeSearch(Sender: TObject);
    procedure sbFilterCalleesInvokeSearch(Sender: TObject);
    procedure sbFilterClassesInvokeSearch(Sender: TObject);
    procedure sbFilterUnitsInvokeSearch(Sender: TObject);
    procedure sbFilterThreadsInvokeSearch(Sender: TObject);
    procedure vstProcsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstCallersChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure vstCalleesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
  private
    callersPerc               : real;
    calleesPerc               : real;
    fvstUnitsTools : TSimpleMemStatsListTools;
    fvstClassesTools : TSimpleMemStatsListTools;
    fvstProcsTools : TSimpleMemStatsListTools;
    fvstProcsCallersTools : TSimpleMemStatsListTools;
    fvstProcsCalleesTools : TSimpleMemStatsListTools;
    fvstThreadsTools  : TSimpleMemStatsListTools;
    fCurrentProfile: TResults;
    factHideNotExecuted : TAction;
    fOnReloadSource : TReloadSourceEvent;
    procedure FillClassView(resortOn: integer = -1);
    procedure FillProcView(resortOn: integer = -1);
    procedure FillThreadView(resortOn: integer = -1);
    procedure FillUnitView(resortOn: integer = -1);
    procedure RedisplayCallers(resortOn: integer = -1);
    procedure RedisplayCallees(resortOn: integer = -1);
    procedure SelectProcs(pid: integer);
    procedure PopBrowser(popBrowser: TPopupMenu; var description: string; var procID: integer);
    procedure OnBrowserClick(Sender: TObject);
    procedure ClearCallersNCallees;
    procedure ClearBrowser(popBrowser: TPopupMenu);
    procedure Restack(fromPop, toPop: TPopupMenu; menuItem: TMenuItem);
    procedure RestackOne(fromPop, toPop: TPopupMenu);
    procedure PushBrowser(popBrowser: TPopupMenu; description: string; procID: integer);
    procedure InvokeFilter(const aSearchTerm: string; const aTreeTool: TSimpleMemStatsListTools;const column : integer = 0);
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Enable() : boolean;
    procedure Disable();
    procedure FillThreadCombos;
    procedure FillViews(resortOn: integer = -1);
    procedure UpdateFocus;

    procedure lvProcsClick(Sender: TObject);
    procedure ResetProfile;
    procedure ResetCallers;
    procedure ResetCallees;
    procedure SlidersMoved;
    procedure ClearBreakdown;
    procedure ExportTo(fileName: string; exportProcs, exportClasses, exportUnits, exportThreads, exportCSV: boolean);

    property CurrentProfile: TResults read fCurrentProfile write fCurrentProfile;
    property actHideNotExecuted : TAction read fActHideNotExecuted write fActHideNotExecuted;
    property OnReloadSource : TReloadSourceEvent read fOnReloadSource write fOnReloadSource;
   end;

implementation

uses
  gppExport, GpIFF, gpprofH, System.StrUtils, gppResults.callgraph,
  VirtualTrees.Types;

{$R *.dfm}


{ TfrmMainProfiling }

constructor TfrmMemProfiling.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  fvstUnitsTools   := TSimpleMemStatsListTools.Create(vstUnits,TMemoryInfoTypeEnum.pit_unit);
  fvstClassesTools := TSimpleMemStatsListTools.Create(vstClasses,TMemoryInfoTypeEnum.pit_class);
  fvstProcsTools   := TSimpleMemStatsListTools.Create(vstProcs,TMemoryInfoTypeEnum.pit_proc);
  fvstProcsCallersTools := TSimpleMemStatsListTools.Create(vstCallers,TMemoryInfoTypeEnum.pit_proc_callers);
  fvstProcsCalleesTools := TSimpleMemStatsListTools.Create(vstCallees,TMemoryInfoTypeEnum.pit_proc_callees);
  fvstThreadsTools := TSimpleMemStatsListTools.Create(vstThreads,TMemoryInfoTypeEnum.pit_thread);
  PageControl2.ActivePage := tabProcedures;

end;

destructor TfrmMemProfiling.Destroy;
begin
  FreeAndNil(fvstUnitsTools);
  FreeAndNil(fvstClassesTools);
  FreeAndNil(fvstProcsTools);
  FreeAndNil(fvstProcsCallersTools);
  FreeAndNil(fvstProcsCalleesTools);
  FreeAndNil(fvstThreadsTools);
  inherited;
end;

function TfrmMemProfiling.Enable(): boolean;
begin
  PageControl2.Font.Color            := clWindowText;
  result := cbxSelectThreadProc.Items.Count > 2;
  if result then
  begin
    cbxSelectThreadProc.Color  := clWindow;
    cbxSelectThreadClass.Color := clWindow;
    cbxSelectThreadUnit.Color  := clWindow;
  end;
end;

procedure TfrmMemProfiling.Disable;
begin
  PageControl2.Font.Color            := clBtnShadow;
  cbxSelectThreadProc.Color          := clBtnFace;
  cbxSelectThreadClass.Color         := clBtnFace;
  cbxSelectThreadUnit.Color          := clBtnFace;
end;

procedure TfrmMemProfiling.SlidersMoved;
begin
  callersPerc := pnlCallers.Height/tabProcedures.Height;
  calleesPerc := pnlCallees.Height/tabProcedures.Height;
  if (calleesPerc > 1) then
    calleesPerc := 0.25;
    if (callersPerc > 1) then
    callersPerc := 0.25;

end;

procedure TfrmMemProfiling.splitCallersMoved(Sender: TObject);
begin
  SlidersMoved;
end;

procedure TfrmMemProfiling.FillThreadCombos;
var
  i: integer;
  LCaption : String;
begin
  with cbxSelectThreadProc do begin
    Items.BeginUpdate;
    try
      Items.Clear;
      if assigned(fCurrentProfile) then begin
        Items.Add('All threads');
        with fCurrentProfile do begin
          for i := Low(resThreads)+1 to High(resThreads) do
          begin
            // first entries is handle 0 for unknown procs, skip it...
            LCaption := uintToStr(resThreads[i].teThread) + ' - ';
            if resThreads[i].Name = '' then
              LCaption := LCaption + 'Thread '+IntToStr(i)
            else
              LCaption := LCaption + resThreads[i].Name;
            Items.Add(LCaption)
          end;
        end;
      end;
      Enabled := (Items.Count > 2);
      ItemIndex := IFF(Enabled,0,1);
    finally Items.EndUpdate; end;
  end;
  cbxSelectThreadClass.Items.Assign(cbxSelectThreadProc.Items);
  cbxSelectThreadClass.Enabled   := cbxSelectThreadProc.Enabled;
  cbxSelectThreadClass.ItemIndex := cbxSelectThreadProc.ItemIndex;
  cbxSelectThreadUnit.Items.Assign(cbxSelectThreadProc.Items);
  cbxSelectThreadUnit.Enabled   := cbxSelectThreadProc.Enabled;
  cbxSelectThreadUnit.ItemIndex := cbxSelectThreadProc.ItemIndex;
  frmExport.expSelectThreadProc.Items.Assign(cbxSelectThreadProc.Items);
  frmExport.expSelectThreadProc.Items.Add('Summary');
  frmExport.expSelectThreadProc.Enabled := (frmExport.expSelectThreadProc.Items.Count > 3);
  frmExport.expSelectThreadProc.ItemIndex := cbxSelectThreadProc.ItemIndex;
end; { TfrmMainProfiling.FillThreadCombos }


procedure TfrmMemProfiling.FillViews(resortOn: integer = -1);
begin
  FillProcView(resortOn);
  FillClassView(resortOn);
  FillUnitView(resortOn);
  FillThreadView(resortOn);
  mnuExportProfile.Enabled     := true;
  SlidersMoved();
end;

procedure TfrmMemProfiling.UpdateFocus;
begin
  with PageControl2 do
    if      ActivePage = tabProcedures then
      vstProcs.SetFocus
    else if ActivePage = tabClasses then
      vstClasses.SetFocus
    else if ActivePage = tabUnits then
      vstUnits.SetFocus
    else if ActivePage = tabThreads then
      vstThreads.SetFocus;
end;

procedure TfrmMemProfiling.vstCalleesChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  executeChange(vstCallees);
end;

procedure TfrmMemProfiling.executeChange(Sender: TBaseVirtualTree);
var
  LProfilingType : TMemoryInfoTypeEnum;
  LEnum : TVTVirtualNodeEnumerator;
  LProcId : Int64;
  LGraphId : integer;
begin
  LProcId := -1;
  LGraphId := -1;
  LProfilingType := TMemoryInfoTypeEnum.pit_proc; // unused here..
  if assigned(fCurrentProfile) and (Sender is TVirtualStringTree) and ((Sender as TVirtualStringTree).SelectedCount>0) then
  begin
    LEnum := (Sender as TVirtualStringTree).SelectedNodes(false).GetEnumerator();
    while(LEnum.MoveNext) do
    begin
      LProfilingType := PMemoryInfoRec(LEnum.Current.GetData).ProfilingType;
      PMemoryInfoRec(LEnum.Current.GetData).GetCallStackInfo(LProcId,LGraphId);
      Break;
    end;
    with fCurrentProfile do
    begin
      if LProfilingType in [TMemoryInfoTypeEnum.pit_proc_callers,TMemoryInfoTypeEnum.pit_proc_callees] then
      begin
        OnReloadSource(resUnits[resProcedures[LGraphId].peUID].FilePath,
                   resProcedures[LGraphId].peFirstLn);
      end;
    end;
  end;
end;

procedure TfrmMemProfiling.vstCalleesNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
  LProfilingType : TMemoryInfoTypeEnum;
  LEnum : TVTVirtualNodeEnumerator;
  LCaption : string;
  LSelectedProcID : Int64;
  LCallStackID : integer;
  LSendingTree : TVirtualStringTree;
begin
  LSelectedProcID := -1;
  LCallStackID := -1;
  LProfilingType := TMemoryInfoTypeEnum.pit_proc; // unused here..
  if not (Sender is TVirtualStringTree) then
    raise Exception.Create('vstCalleesNodeDblClick: Sender is not a TVirtualStringTree.');
  LSendingTree := Sender as TVirtualStringTree;

  if LSendingTree.SelectedCount>0 then
  begin
    ClearBrowser(popBrowseNext);
    LEnum := LSendingTree.SelectedNodes(false).GetEnumerator();
    while(LEnum.MoveNext) do
    begin
      LProfilingType := PMemoryInfoRec(LEnum.Current.GetData).ProfilingType;
      PMemoryInfoRec(LEnum.Current.GetData).GetCallStackInfo(LSelectedProcID,LCallStackID);
      Break;
    end;
    if LCallStackID<>-1 then
      if LProfilingType in [TMemoryInfoTypeEnum.pit_proc_callers,TMemoryInfoTypeEnum.pit_proc_callees] then
      begin
        LCaption := fCurrentProfile.resProcedures[LCallStackID].Name;
        PushBrowser(popBrowsePrevious,LCaption,LCallStackID);
      end;
    SelectProcs(LCallStackID);
  end;
end;

procedure TfrmMemProfiling.vstCallersChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  executeChange(vstCallers);
end;

procedure TfrmMemProfiling.vstProcsChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  lvProcsClick(Sender);
end;

{ TfrmMainProfiling.FillViews }


procedure TfrmMemProfiling.FillThreadView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstThreadsTools.BeginUpdate;
  fvstThreadsTools.Clear();
  fvstThreadsTools.ThreadIndex := 0; // not needed

  fvstThreadsTools.ProfileResults := fCurrentProfile;
  with fCurrentProfile do begin
    try
      if assigned(fCurrentProfile) then begin
        for i := Low(resThreads)+1 to High(resThreads) do begin
          with resThreads[i] do begin
            if (not actHideNotExecuted.Checked) or (teTotalCnt > 0) then begin
              fvstThreadsTools.AddEntry(i);
            end;
          end;
        end;
      end;
    finally
      fvstThreadsTools.EndUpdate;
    end;
  end;
end; { TfrmMainProfiling.FillThreadView }



procedure TfrmMemProfiling.FillUnitView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstUnitsTools.BeginUpdate;
  fvstUnitsTools.Clear();
  fvstUnitsTools.ThreadIndex := cbxSelectThreadUnit.ItemIndex;
  fvstUnitsTools.ProfileResults := fCurrentProfile;
  with fCurrentProfile do begin
    try
      if cbxSelectThreadUnit.ItemIndex >= 0 then
	  begin
        for i := Low(resUnits)+1 to High(resUnits) do begin
          with resUnits[i] do begin
            if (not actHideNotExecuted.Checked) or (ueTotalCnt[cbxSelectThreadUnit.ItemIndex] > 0) then begin
              fvstUnitsTools.AddEntry(i);
            end;
          end;
        end;
      end;
    finally
      fvstUnitsTools.EndUpdate;
    end;
  end;
end; { TfrmMainProfiling.FillUnitView }



procedure TfrmMemProfiling.FillClassView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstClassesTools.BeginUpdate;
  fvstClassesTools.Clear();
  fvstClassesTools.ThreadIndex := cbxSelectThreadClass.ItemIndex;
  fvstClassesTools.ProfileResults := fCurrentProfile;
  with fCurrentProfile do begin
    try
      if cbxSelectThreadClass.ItemIndex >= 0 then
      begin
        for i := Low(resClasses)+1 to High(resClasses) do begin
          with resClasses[i] do begin
            if (not actHideNotExecuted.Checked) or (ceTotalCnt[cbxSelectThreadClass.ItemIndex] > 0) then
            begin
              fvstClassesTools.AddEntry(i);
            end;
          end;
        end;
      end;
    finally
      fvstClassesTools.EndUpdate;
    end;
  end;
end; { TfrmMainProfiling.FillClassView }


procedure TfrmMemProfiling.FillProcView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstProcsTools.BeginUpdate;
  fvstProcsTools.Clear();
  fvstProcsTools.ThreadIndex := cbxSelectThreadProc.ItemIndex;
  fvstProcsTools.ProfileResults := fCurrentProfile;
  with fCurrentProfile do begin
    try
      if cbxSelectThreadProc.ItemIndex >= 0 then
      begin
        for i := 1 to resProcedures.Count-1 do begin
          with resProcedures[i] do begin
            if (not actHideNotExecuted.Checked) or (peProcCnt[cbxSelectThreadProc.ItemIndex] > 0) then begin
              fvstProcsTools.AddEntry(i);
            end;
          end;
        end;
      end;
    finally
      fvstProcsTools.EndUpdate;
    end;
  end;
end; { TfrmMainProfiling.FillProcView }

procedure TfrmMemProfiling.lvProcsClick(Sender: TObject);
var
  uid: integer;
  LVST : TVirtualStringTree;
  LEnum : TVTVirtualNodeEnumerator;
  LData : PMemoryInfoRec;
  LSelectedID : integer;
begin
  LSelectedID := -1;
  if assigned(fCurrentProfile) then
    with PageControl2, ActivePage do
    begin
      if ActivePage <> tabThreads then
      begin
        if ActivePage = tabProcedures then
          LVST := vstProcs
        else if ActivePage = tabClasses then
          LVST := vstClasses
        else
          LVST := vstUnits;

        if Assigned(LVST) then
        begin
          LEnum := LVST.SelectedNodes(false).GetEnumerator();
          while(LEnum.MoveNext) do
          begin
            LData := PMemoryInfoRec(LEnum.Current.GetData);
            LSelectedID := LData.GetId;
          end;
        end;
        with fCurrentProfile do begin
        begin
          if LSelectedID >= 0 then
          begin
            if ActivePage = tabProcedures then begin
              RedisplayCallers;
              RedisplayCallees;
              OnReloadSource(resUnits[resProcedures[LSelectedID].peUID].FilePath,
                         resProcedures[LSelectedID].peFirstLn);
              Exit;
            end
            else if ActivePage = tabClasses then begin
              uid := resClasses[LSelectedID].ceUID;
              if uid >= 0 then
                OnReloadSource(resUnits[uid].FilePath,resClasses[LSelectedID].ceFirstLn);
              Exit;
            end
            else if ActivePage = tabUnits then
            begin
              OnReloadSource(resUnits[LSelectedID].FilePath,0);
              Exit;
            end;

          end;
        end;
      end;
    end;
  end;
  OnReloadSource('',0);
end;


procedure TfrmMemProfiling.SelectProcs(pid: integer);
var
  LEnumor : TVTVirtualNodeEnumerator;
  LData : PMemoryInfoRec;
begin
  LEnumor := vstProcs.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    LData := PMemoryInfoRec(LEnumor.Current.GetData());
    if LData.ProcId = pid then
    begin
      vstProcs.SetFocus;
      vstProcs.Selected[LEnumor.Current] := True;
      lvProcsClick(vstProcs);
      break;
    end;
  end;
end;



procedure TfrmMemProfiling.ResetProfile();
begin
  fCurrentProfile := nil;
  fvstUnitsTools.ProfileResults := nil;
  fvstClassesTools.ProfileResults := nil;
  fvstProcsTools.ProfileResults := nil;
  fvstProcsCallersTools.ProfileResults := nil;
  fvstProcsCalleesTools.ProfileResults := nil;
  fvstThreadsTools.ProfileResults := nil;
end;

procedure TfrmMemProfiling.RedisplayCallees(resortOn: integer = -1);
var
  callingPID: int64;
  i         : integer;
  LInfo     : TCallGraphInfo;
begin
  if pnlCallees.Visible and (vstProcs.SelectedCount>0) then
  begin
    fvstProcsCalleesTools.BeginUpdate;
    fvstProcsCalleesTools.Clear();
    fvstProcsCalleesTools.ThreadIndex := cbxSelectThreadProc.ItemIndex;
    fvstProcsCalleesTools.ProfileResults := fCurrentProfile;
    try
      with fCurrentProfile do
      begin
        if cbxSelectThreadProc.ItemIndex >= 0 then
        begin
          callingPID := fvstProcsTools.GetSelectedId;
          for i := 1 to CallGraphInfoCount do
          begin
            LInfo := CallGraphInfo.GetGraphInfo(callingPID,i);
            if assigned(LInfo) then
            begin
              if (not actHideNotExecuted.Checked) or (LInfo.ProcCnt[cbxSelectThreadProc.ItemIndex] > 0) then
              begin
                fvstProcsCalleesTools.AddEntry(callingPID,i);
              end;
            end; // with
          end; // if
          end; // for
        end;
    finally
      fvstProcsCalleesTools.EndUpdate;
    end;
  end;
end;

procedure TfrmMemProfiling.RedisplayCallers(resortOn: integer = -1);
var
  calledPID: int64;
  i        : integer;
  LInfo    : TCallGraphInfo;
begin
  if pnlCallers.Visible and (vstProcs.SelectedCount<>0) then
  begin
    fvstProcsCallersTools.BeginUpdate;
    fvstProcsCallersTools.Clear();
    fvstProcsCallersTools.ThreadIndex := cbxSelectThreadProc.ItemIndex;
    fvstProcsCallersTools.ProfileResults := fCurrentProfile;
    try
      if cbxSelectThreadProc.ItemIndex >= 0 then
      begin
        calledPID := fvstProcsTools.GetSelectedId();
        for i := 1 to fCurrentProfile.CallGraphInfoCount do
        begin
          LInfo := fCurrentProfile.CallGraphInfo.GetGraphInfo(i,calledPID);
          if assigned(LInfo) then
            if (not actHideNotExecuted.Checked) or (LInfo.ProcCnt[cbxSelectThreadProc.ItemIndex] > 0) then
              fvstProcsCallersTools.AddEntry(calledPID, i);
        end; // if
      end; // for
    finally
      fvstProcsCallersTools.EndUpdate;
    end;
  end;
end;

procedure TfrmMemProfiling.ResetCallers;
begin
  RedisplayCallers;
  SlidersMoved;
end;

procedure TfrmMemProfiling.ResetCallees;
begin
  RedisplayCallees;
  SlidersMoved;
end;


procedure TfrmMemProfiling.ExportTo(fileName: string; exportProcs, exportClasses,
  exportUnits, exportThreads, exportCSV: boolean);

  procedure LExport(var f: textfile; aLvTools:TSimpleMemStatsListTools; delim: char);
  var
    i   : integer;
    header: string;
    line  : string;
    lEnum : TVTVirtualNodeEnumerator;
  begin
    header := '';
    for i := 0 to aLvTools.ListView.Header.Columns.Count-1 do begin
      if header <> '' then header := header + delim;
      header := header + aLvTools.ListView.Header.Columns[i].Text;
    end;
    Writeln(f,header);
    lEnum := aLvTools.ListView.ChildNodes(nil).GetEnumerator;
    while(lEnum.MoveNext) do
    begin
      line := aLVTools.GetRowAsCsv(lEnum.Current,delim);
      Writeln(f,line);
    end;
    Writeln(f,delim);
  end; { _Export }

  procedure ExpProcedures(var f: textfile; delim: char);
  begin
    LExport(f,fvstProcsTools,delim);
  end; { ExpProcedures }

  procedure ExpClasses(var f: textfile; delim: char);
  begin
    LExport(f,fvstClassesTools, delim);
  end; { ExpClasses }

  procedure ExpUnits(var f: textfile; delim: char);
  begin
    LExport(f,fvstUnitsTools,delim);
  end; { ExpUnits }

  procedure ExpThreads(var f: textfile; delim: char);
  begin
    LExport(f,fvstThreadsTools,delim);
  end; { ExpThreads }

var
  f    : textfile;
  delim: char;

begin
//  kaj pa threadi?
  try
    if ExtractFileExt(fileName) = '' then
      if exportCSV then fileName := fileName + '.csv'
                   else fileName := fileName + '.txt';
    AssignFile(f,fileName);
    Rewrite(f);
    try
      if exportCSV then delim := ';' else delim := #9;
      if exportProcs   then ExpProcedures(f,delim);
      if exportClasses then ExpClasses(f,delim);
      if exportUnits   then ExpUnits(f,delim);
      if exportThreads then ExpThreads(f,delim);
    finally CloseFile(f); end;
  except Application.MessageBox(PChar('Cannot write to file '+fileName),'Export error',MB_OK); end;
end;


procedure TfrmMemProfiling.actBrowseNextExecute(Sender: TObject);
begin
  RestackOne(popBrowseNext,popBrowsePrevious);
end;

procedure TfrmMemProfiling.actBrowseNextUpdate(Sender: TObject);
begin
  actBrowseNext.Enabled := popBrowseNext.Items.Count > 0;
end;

procedure TfrmMemProfiling.actBrowsePreviousExecute(Sender: TObject);
begin
  RestackOne(popBrowsePrevious,popBrowseNext);
end;

procedure TfrmMemProfiling.actBrowsePreviousUpdate(Sender: TObject);
begin
  actBrowsePrevious.Enabled := popBrowsePrevious.Items.Count > 0;
end;

procedure TfrmMemProfiling.cbxSelectThreadClassChange(Sender: TObject);
begin
  FillClassView();
end;

procedure TfrmMemProfiling.cbxSelectThreadProcChange(Sender: TObject);
var
  LSelectedId : int64;
begin
  LSelectedId := fvstProcsTools.GetSelectedId();
  FillProcView();
  if fvstProcsTools.SetSelectedId(LSelectedId) then
  begin
    RedisplayCallees();
    RedisplayCallers();
  end
  else
    ClearCallersNCallees;
end;

procedure TfrmMemProfiling.cbxSelectThreadUnitChange(Sender: TObject);
begin
  FillUnitView();
end;

procedure TfrmMemProfiling.ClearBrowser(popBrowser: TPopupMenu);
begin
  while popBrowser.Items.Count > 0 do popBrowser.Items.Remove(popBrowser.Items[0]);
end;

procedure TfrmMemProfiling.ClearCallersNCallees();
begin
  fvstProcsCallersTools.Clear;
  fvstProcsCalleesTools.Clear();
end;

procedure TfrmMemProfiling.RestackOne(fromPop, toPop: TPopupMenu);
var
  description: string;
  procID     : integer;
  LNode : PVirtualNode;
begin
  LNode := fvstProcsTools.GetSelectedNode;
  if assigned(LNode) then
    PushBrowser(toPop,fvstProcsTools.GetSelectedCaption(),fvstProcsTools.GetSelectedId());
  PopBrowser(fromPop,description,procID);
  SelectProcs(procID);
end;

procedure TfrmMemProfiling.sbFilterCalleesInvokeSearch(Sender: TObject);
begin
  InvokeFilter(sbFilterCallees.Text, fvstProcsCalleesTools);
end;

procedure TfrmMemProfiling.sbFilterCallersChange(Sender: TObject);
begin
  InvokeFilter(sbFilterCallers.Text, fvstProcsCallersTools);
end;

procedure TfrmMemProfiling.sbFilterClassesInvokeSearch(Sender: TObject);
begin
  InvokeFilter(sbFilterClasses.Text, fvstClassesTools)
end;

procedure TfrmMemProfiling.sbFilterProcsInvokeSearch(Sender: TObject);
begin
  InvokeFilter(sbFilterProcs.Text, fvstProcsTools);
end;

procedure TfrmMemProfiling.sbFilterThreadsInvokeSearch(Sender: TObject);
begin
  InvokeFilter(sbFilterThreads.Text, fvstThreadsTools, 1);
end;

procedure TfrmMemProfiling.sbFilterUnitsInvokeSearch(Sender: TObject);
begin
  InvokeFilter(sbFilterUnits.Text, fvstUnitsTools);
end;

procedure TfrmMemProfiling.InvokeFilter(const aSearchTerm: string; const aTreeTool : TSimpleMemStatsListTools;const column : integer = 0);
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
        lVisible := ContainsText(aTreeTool.GetName(LEnumor.current,column),aSearchTerm);
      aTreeTool.SetVisible(LEnumor.Current, lVisible);
    end;
  finally
    aTreeTool.Tree.EndUpdate;
  end;
end;

procedure TfrmMemProfiling.Restack(fromPop, toPop: TPopupMenu;
  menuItem: TMenuItem);
var
  mustStop  : boolean;
  juggleDesc: string;
  jugglePID : integer;
begin
  juggleDesc := fvstProcsTools.GetSelectedCaption();
  jugglePID  := fvstProcsTools.GetSelectedId();
  repeat
    mustStop := (fromPop.Items[0] = menuItem);
    PushBrowser(toPop,juggleDesc,jugglePID);
    PopBrowser(fromPop,juggleDesc,jugglePID);
  until mustStop;
  SelectProcs(jugglePID);
end;

procedure TfrmMemProfiling.PageControl2Change(Sender: TObject);
begin
  if PageControl2.ActivePage = tabThreads then
    OnReloadSource('',0)
  else
    lvProcsClick(Sender);
end;

procedure TfrmMemProfiling.PopBrowser(popBrowser: TPopupMenu; var description: string; var procID: integer);
var
  newDesc: string;
begin
  with popBrowser.Items[0] do begin
    description := Caption;
    procID := HelpContext;
  end;
  popBrowser.Items.Remove(popBrowser.Items[0]);
  if popBrowser.Items.Count = 0 then newDesc := ''
                                else newDesc := popBrowser.Items[0].Caption;
  if popBrowser = popBrowseNext then
    actBrowseNext.Hint := Description
  else
    actBrowsePrevious.Hint := Description;
end;

procedure TfrmMemProfiling.PushBrowser(popBrowser: TPopupMenu; description: string;
  procID: integer);
var
  mn: TMenuItem;
begin
  mn := TMenuItem.Create(self);
  mn.Caption := description;
  mn.HelpContext := procID;
  mn.OnClick := OnBrowserClick;

  popBrowser.Items.Insert(0,mn);
  if popBrowser = popBrowseNext then
  begin
    actBrowseNext.Hint := description;
  end
  else
  begin
    actBrowsePrevious.Hint := description;
  end;
end;


procedure TfrmMemProfiling.OnBrowserClick(Sender: TObject);
begin
  if (Sender as TMenuItem).Parent = popBrowsePrevious.Items then
    Restack(popBrowsePrevious,popBrowseNext,Sender as TMenuItem)
  else
    Restack(popBrowseNext,popBrowsePrevious,Sender as TMenuItem);
end;



procedure TfrmMemProfiling.ClearBreakdown;
begin
  ClearBrowser(popBrowseNext);
  ClearBrowser(popBrowsePrevious);
  ClearCallersNCallees();
end;


end.
