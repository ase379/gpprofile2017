unit gppmain.FrameMemoryAnalysis;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, VirtualTrees, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ToolWin,
  Vcl.ExtCtrls, Vcl.Actnlist, vcl.menus,
  gppresults,virtualTree.tools.timestatistics, System.Actions, System.ImageList, Vcl.ImgList, Vcl.WinXCtrls,
  VirtualTrees.BaseAncestorVCL, VirtualTrees.BaseTree, VirtualTrees.AncestorVCL;

type
  {$SCOPEDENUMS ON}
  TShownInformationTypeEnum = (Performance, Memory);

  TReloadSourceEvent = procedure(const aPath : string; aLine : integer) of object;
  TfrmMemProfiling = class(TFrame)
    PageControl2: TPageControl;
    tabProcedures: TTabSheet;
    splitCallees: TSplitter;
    pnlTopTwo: TPanel;
    splitCallers: TSplitter;
    pnlCallers: TPanel;
    vstCallers: TVirtualStringTree;
    pnlCurrent: TPanel;
    vstProcs: TVirtualStringTree;
    pnlCallees: TPanel;
    vstCallees: TVirtualStringTree;
    pnlBottom: TPanel;
    tabClasses: TTabSheet;
    vstClasses: TVirtualStringTree;
    tabUnits: TTabSheet;
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
    pnThreadProcs: TPanel;
    pnlBrowser: TPanel;
    ToolBar3: TToolBar;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    procedure splitCallersMoved(Sender: TObject);
    procedure cbxSelectThreadProcChange(Sender: TObject);
    procedure cbxSelectThreadUnitChange(Sender: TObject);
    procedure cbxSelectThreadClassChange(Sender: TObject);
    procedure vstProcsNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
    procedure PageControl2Change(Sender: TObject);
    procedure vstCalleesNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
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
  private
    callersPerc               : real;
    calleesPerc               : real;
    fvstUnitsTools : TSimpleTimeStatsListTools;
    fvstClassesTools : TSimpleTimeStatsListTools;
    fvstProcsTools : TSimpleTimeStatsListTools;
    fvstProcsCallersTools : TSimpleTimeStatsListTools;
    fvstProcsCalleesTools : TSimpleTimeStatsListTools;
    fvstThreadsTools  : TSimpleTimeStatsListTools;
    fOpenProfile: TResults;
    fShownInformationType : TShownInformationTypeEnum;
    factHideNotExecuted : TAction;
    factShowHideCallers : TAction;
    factShowHideCallees : TAction;
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
    procedure InvokeFilter(const aSearchTerm: string; const aTreeTool: TSimpleTimeStatsListTools;const column : integer = 0);
  public

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function Enable() : boolean;
    procedure Disable();
    procedure FillViews(resortOn: integer = -1);
    procedure UpdateFocus;

    procedure lvProcsClick(Sender: TObject);
    procedure ResetProfile;
    procedure ResetCallers;
    procedure ResetCallees;
    procedure RepositionSliders;
    procedure SlidersMoved;
    procedure ClearBreakdown;
    procedure ExportTo(fileName: string; exportProcs, exportClasses, exportUnits, exportThreads, exportCSV: boolean);

    property OpenProfile: TResults read fOpenProfile write fOpenProfile;
    property ShownInformationType : TShownInformationTypeEnum read fShownInformationType write fShownInformationType;
    property actHideNotExecuted : TAction read fActHideNotExecuted write fActHideNotExecuted;
    property actShowHideCallers : TAction read factShowHideCallers write factShowHideCallers;
    property actShowHideCallees : TAction read factShowHideCallees write factShowHideCallees;
    property OnReloadSource : TReloadSourceEvent read fOnReloadSource write fOnReloadSource;
   end;

implementation

uses
  gppExport, GpIFF, gpprofH, System.StrUtils, gppResults.callgraph;

{$R *.dfm}


{ TfrmMemProfiling }

constructor TfrmMemProfiling.Create(AOwner: TComponent);
begin
  inherited Create(aOwner);
  fvstUnitsTools   := TSimpleTimeStatsListTools.Create(vstUnits,TProfilingInfoTypeEnum.pit_unit);
  fvstClassesTools := TSimpleTimeStatsListTools.Create(vstClasses,TProfilingInfoTypeEnum.pit_class);
  fvstProcsTools   := TSimpleTimeStatsListTools.Create(vstProcs,TProfilingInfoTypeEnum.pit_proc);
  fvstProcsCallersTools := TSimpleTimeStatsListTools.Create(vstCallers,TProfilingInfoTypeEnum.pit_proc_callers);
  fvstProcsCalleesTools := TSimpleTimeStatsListTools.Create(vstCallees,TProfilingInfoTypeEnum.pit_proc_callees);
  fvstThreadsTools := TSimpleTimeStatsListTools.Create(vstThreads,TProfilingInfoTypeEnum.pit_thread);
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
  result := true;
  PageControl2.Font.Color            := clWindowText;
end;

procedure TfrmMemProfiling.Disable;
begin
  PageControl2.Font.Color            := clBtnShadow;
end;


procedure TfrmMemProfiling.RepositionSliders;
begin
  pnlCallees.Height := Round(calleesPerc*tabProcedures.Height);
  pnlCallers.Height := Round(callersPerc*tabProcedures.Height);
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

procedure TfrmMemProfiling.FillViews(resortOn: integer = -1);
begin
  FillProcView(resortOn);
  FillClassView(resortOn);
  FillUnitView(resortOn);
  FillThreadView(resortOn);
  mnuExportProfile.Enabled     := true;
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

procedure TfrmMemProfiling.vstCalleesNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
  LProfilingType : TProfilingInfoTypeEnum;
  LEnum : TVTVirtualNodeEnumerator;
  LProcId : Int64;
  LGraphId : int16;
begin
  LProcId := -1;
  LGraphId := -1;
  LProfilingType := TProfilingInfoTypeEnum.pit_proc; // unused here..
  if assigned(openProfile) and (Sender is TVirtualStringTree) and ((Sender as TVirtualStringTree).SelectedCount>0) then
  begin
    LEnum := (Sender as TVirtualStringTree).SelectedNodes(false).GetEnumerator();
    while(LEnum.MoveNext) do
    begin
      LProfilingType := PProfilingInfoRec(LEnum.Current.GetData).ProfilingType;
      PProfilingInfoRec(LEnum.Current.GetData).GetCallStackInfo(LProcId,LGraphId);
      Break;
    end;
    with openProfile do
    begin
      if LProfilingType in [TProfilingInfoTypeEnum.pit_proc_callers,TProfilingInfoTypeEnum.pit_proc_callees] then
      begin
        OnReloadSource(resUnits[resProcedures[LGraphId].peUID].FilePath,
                   resProcedures[LGraphId].peFirstLn);
      end;
    end;
  end;
end;

procedure TfrmMemProfiling.vstCalleesNodeDblClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
var
  LProfilingType : TProfilingInfoTypeEnum;
  LEnum : TVTVirtualNodeEnumerator;
  LCaption : string;
  LSelectedProcID : Int64;
  LCallStackID : Int16;
  LSendingTree : TVirtualStringTree;
begin
  LSelectedProcID := -1;
  LCallStackID := -1;
  LProfilingType := TProfilingInfoTypeEnum.pit_proc; // unused here..
  if not (Sender is TVirtualStringTree) then
    raise Exception.Create('vstCalleesNodeDblClick: Sender is not a TVirtualStringTree.');
  LSendingTree := Sender as TVirtualStringTree;

  if LSendingTree.SelectedCount>0 then
  begin
    ClearBrowser(popBrowseNext);
    LEnum := LSendingTree.SelectedNodes(false).GetEnumerator();
    while(LEnum.MoveNext) do
    begin
      LProfilingType := PProfilingInfoRec(LEnum.Current.GetData).ProfilingType;
      PProfilingInfoRec(LEnum.Current.GetData).GetCallStackInfo(LSelectedProcID,LCallStackID);
      Break;
    end;
    if LCallStackID<>-1 then
      if LProfilingType in [TProfilingInfoTypeEnum.pit_proc_callers,TProfilingInfoTypeEnum.pit_proc_callees] then
      begin
        LCaption := openProfile.resProcedures[LCallStackID].Name;
        PushBrowser(popBrowsePrevious,LCaption,LCallStackID);
      end;
    SelectProcs(LCallStackID);
  end;
end;

procedure TfrmMemProfiling.vstProcsNodeClick(Sender: TBaseVirtualTree; const HitInfo: THitInfo);
begin
  lvProcsClick(Sender);
end;

{ TfrmMemProfiling.FillViews }


procedure TfrmMemProfiling.FillThreadView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstThreadsTools.BeginUpdate;
  fvstThreadsTools.Clear();
  fvstThreadsTools.ThreadIndex := 0; // not needed

  fvstThreadsTools.ProfileResults := openProfile;
  with openProfile do begin
    try
      if openProfile <> nil then begin
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
end; { TfrmMemProfiling.FillThreadView }



procedure TfrmMemProfiling.FillUnitView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstUnitsTools.BeginUpdate;
  fvstUnitsTools.Clear();
  fvstUnitsTools.ThreadIndex := 0;
  fvstUnitsTools.ProfileResults := openProfile;
  with openProfile do begin
    try
        for i := Low(resUnits)+1 to High(resUnits) do begin
          with resUnits[i] do begin
            if (not actHideNotExecuted.Checked) or (ueTotalCnt[0] > 0) then begin
              fvstUnitsTools.AddEntry(i);
            end;
          end;
        end;
    finally
      fvstUnitsTools.EndUpdate;
    end;
  end;
end; { TfrmMemProfiling.FillUnitView }



procedure TfrmMemProfiling.FillClassView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstClassesTools.BeginUpdate;
  fvstClassesTools.Clear();
  fvstClassesTools.ThreadIndex := 0;
  fvstClassesTools.ProfileResults := openProfile;
  with openProfile do begin
    try
      for i := Low(resClasses)+1 to High(resClasses) do begin
        with resClasses[i] do begin
          if (not actHideNotExecuted.Checked) or (ceTotalCnt[0] > 0) then
          begin
            fvstClassesTools.AddEntry(i);
          end;
        end;
      end;
    finally
      fvstClassesTools.EndUpdate;
    end;
  end;
end; { TfrmMemProfiling.FillClassView }


procedure TfrmMemProfiling.FillProcView(resortOn: integer = -1);
var
  i        : integer;
begin
  fvstProcsTools.BeginUpdate;
  fvstProcsTools.Clear();
  fvstProcsTools.ThreadIndex := 0;
  fvstProcsTools.ProfileResults := openProfile;
  with openProfile do begin
    try
      for i := Low(resProcedures)+1 to High(resProcedures) do begin
        with resProcedures[i] do begin
          if (not actHideNotExecuted.Checked) or (peProcCnt[0] > 0) then begin
            fvstProcsTools.AddEntry(i);
          end;
        end;
      end;
    finally
      fvstProcsTools.EndUpdate;
    end;
  end;
end; { TfrmMemProfiling.FillProcView }


procedure TfrmMemProfiling.lvProcsClick(Sender: TObject);
var
  uid: integer;
  LVST : TVirtualStringTree;
  LEnum : TVTVirtualNodeEnumerator;
  LData : PProfilingInfoRec;
  LSelectedID : integer;
begin
  LSelectedID := -1;
  if openProfile <> nil then
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
            LData := PProfilingInfoRec(LEnum.Current.GetData);
            LSelectedID := LData.GetId;
          end;
        end;
        with openProfile do begin
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
  LData : PProfilingInfoRec;
begin
  LEnumor := vstProcs.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    LData := PProfilingInfoRec(LEnumor.Current.GetData());
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
    fvstProcsCalleesTools.ThreadIndex := 0;
    fvstProcsCalleesTools.ProfileResults := openProfile;
    try
      with openProfile do
      begin
        if DigestVer < PRF_DIGESTVER_3 then
          Exit;
        callingPID := fvstProcsTools.GetSelectedId;
        for i := 1 to CallGraphInfoCount-1 do
        begin
          LInfo := CallGraphInfo.GetGraphInfo(callingPID,i);
          if assigned(LInfo) then
          begin
            if (not actHideNotExecuted.Checked) or (LInfo.ProcCnt[0] > 0) then
            begin
              fvstProcsCalleesTools.AddEntry(callingPID,i);
            end;
          end; // with
        end; // if
        end; // for
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
    fvstProcsCallersTools.ThreadIndex := 0;
    fvstProcsCallersTools.ProfileResults := openProfile;
    try
      with openProfile do
      begin
        if DigestVer < PRF_DIGESTVER_3 then
          Exit;
        calledPID := fvstProcsTools.GetSelectedId();
        for i := 1 to CallGraphInfoCount-1 do
        begin
          LInfo := CallGraphInfo.GetGraphInfo(i,calledPID);
          if assigned(LInfo) then
            if (not actHideNotExecuted.Checked) or (LInfo.ProcCnt[0] > 0) then
              fvstProcsCallersTools.AddEntry(calledPID, i);
        end; // if
      end;
    finally
      fvstProcsCallersTools.EndUpdate;
    end;
  end;
end;

procedure TfrmMemProfiling.ResetCallers;
begin
  with actShowHideCallers do begin
    Tag := 1-Ord(pnlCallers.Visible);
    if Tag = 1 then begin
      Caption := 'Show &Callers';
      Hint    := 'Show callers';
    end
    else begin
      Caption := 'Hide &Callers';
      Hint    := 'Hide callers';
    end;
    ImageIndex := 22+Tag;
  end;
  RedisplayCallers;
  SlidersMoved;
end; { TfrmMain.ResetCallers }

procedure TfrmMemProfiling.ResetCallees;
begin
  with actShowHideCallees do begin
    Tag := 1-Ord(pnlCallees.Visible);
    if Tag = 1 then begin
      Caption := 'Show Callees';
      Hint    := 'Show callees';
    end
    else begin
      Caption := 'Hide Callees';
      Hint    := 'Hide callees';
    end;
    ImageIndex := 24+Tag;
  end;
  RedisplayCallees;
  SlidersMoved;
end; { TfrmMain.ResetCallers }



procedure TfrmMemProfiling.ExportTo(fileName: string; exportProcs, exportClasses,
  exportUnits, exportThreads, exportCSV: boolean);

  procedure LExport(var f: textfile; aLvTools:TSimpleTimeStatsListTools; delim: char);
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

procedure TfrmMemProfiling.InvokeFilter(const aSearchTerm: string; const aTreeTool : TSimpleTimeStatsListTools;const column : integer = 0);
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
