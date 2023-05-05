unit virtualTree.tools.timestatistics;

interface

uses
  System.Types,
  vcl.Graphics,
  VirtualTrees,
  gppresults,
  virtualTree.tools.base;

type
  TProfilingInfoTypeEnum = (pit_unit, pit_class,pit_proc,pit_proc_callers,pit_proc_callees,pit_thread);
  PProfilingInfoRec = ^TProfilingInfoRec;
  TProfilingInfoRec = record
    function GetId : Integer;
    procedure GetCallStackInfo(var aProcId: Int64;var aGraphIndex : integer);
    case ProfilingType: TProfilingInfoTypeEnum of
      pit_unit: (UnitId: integer);
      pit_class: (ClassId: integer);
      pit_proc: (ProcId: integer);
      pit_proc_callers: (CallerProcId: integer;CallerGraphIndex:integer);
      pit_proc_callees: (CalleeProcId: integer;CalleeGraphIndex:integer);
      pit_thread: (ThreadId: Cardinal);
  end;

  TColumnInfoType = (undefined,Text,Percent, Time, Count);
  TSimpleTimeStatsListTools = class(TVirtualTreeBaseTools)
  private
    fListType : TProfilingInfoTypeEnum;
    fProfileResults : TResults;
    fThreadIndex : Integer;
    function  GetThreadName(index: integer): string;
    /// <summary>
    ///   Gets the raw values. The values are returned as double. Thus, false is returned if not double compatible
    ///  type is stored for the cell (e.g. a string).
    /// </summary>
    function GetValue(const aData : PProfilingInfoRec; const aColumnIndex: integer; out aValue, aMax : double;out aColRenderType:TColumnInfoType): boolean;
    /// <summary>
    /// Returns the type of the column content.
    /// </summary>
    function GetColInfoType(const aData : PProfilingInfoRec;const aColumnIndex: integer): TColumnInfoType;
    /// <summary>
    /// Gets the column content as a string.
    /// </summary>
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    /// <summary>
    /// Compares the nodes for sorting.
    /// </summary>
    procedure OnCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    /// <summary>
    /// Adds the bar overlays to columns supporting the overlays.
    /// </summary>
    procedure OnAftercellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode; Column: TColumnIndex; CellRect: TRect);
  public
    constructor Create(const aList: TVirtualStringTree;const aListType : TProfilingInfoTypeEnum);

    procedure AddEntry(const anEntryId : Cardinal);overload;
    procedure AddEntry(const anEntryId, anIndex : Cardinal);overload;

    function GetSelectedId(): Int64;
    function SetSelectedId(const anId : Int64) : boolean;
    function GetSelectedCaption(): string;

    function GetSelectedNode: PVirtualNode;

    function GetRowAsCsv(const aNode: PVirtualNode; const aDelimeter: char): string;

    property ThreadIndex : integer read fThreadIndex write fThreadIndex;
    property ProfileResults : TResults read fProfileResults write fProfileResults;
    property ListView : TVirtualStringTree read fList;
  end;

implementation

uses
  System.math,
  winapi.windows,
  System.SysUtils,
  GpIFF,
  gpString,
  VirtualTrees.BaseTree, VirtualTrees.Types;

const
  // col index for Unit
  COL_UNIT_NAME = 0;
  COL_UNIT_TOTAL_PERC = 1;
  COL_UNIT_TOTAL_TIME = 2;
  COL_UNIT_TOTAL_CALLS = 3;
  // col index for Class
  COL_CLASS_NAME = 0;
  COL_CLASS_TOTAL_PERC = 1;
  COL_CLASS_TOTAL_TIME = 2;
  COL_CLASS_TOTAL_CALLS = 3;
  // col index for Proc
  COL_PROC_NAME = 0;
  COL_PROC_TOTAL_PERC = 1;
  COL_PROC_TOTAL_CHILD_PERC = 2;
  COL_PROC_TOTAL_TIME = 3;
  COL_PROC_TOTAL_CHILD_TIME = 4;
  COL_PROC_TOTAL_CALLS = 5;
  COL_PROC_MIN_TIME_PER_CALL = 6;
  COL_PROC_MAX_TIME_PER_CALL = 7;
  COL_PROC_AVG_TIME_PER_CALL = 8;
  // col index for thread
  COL_THREAD_ID = 0;
  COL_THREAD_NAME = 1;
  COL_THREAD_TOTAL_PERC = 2;
  COL_THREAD_TOTAL_TIME = 3;
  COL_THREAD_TOTAL_CALLS = 4;


constructor TSimpleTimeStatsListTools.Create(const aList: TVirtualStringTree; const aListType : TProfilingInfoTypeEnum);
begin
  inherited Create(AList);
  fListType := aListType;
  fList.NodeDataSize := SizeOf(TProfilingInfoRec);
  fList.OnCompareNodes := self.OnCompareNodes;
  fList.ongettext := OnGetText;
  fList.OnAfterCellPaint := OnAftercellPaint;
  fList.TreeOptions.SelectionOptions := fList.TreeOptions.SelectionOptions + [TVTSelectionOption.toFullRowSelect];
end;

procedure TSimpleTimeStatsListTools.AddEntry(const anEntryId : Cardinal);
var
  LData : PProfilingInfoRec;
  LNode : PVirtualNode;
begin
  LNode := flist.AddChild(nil);
  LData := PProfilingInfoRec(LNode.GetData);
  LData.ProfilingType := fListType;
  case fListType of
    pit_unit : LData.UnitId := anEntryId;
    pit_class : LData.ClassId := anEntryId;
    pit_proc: LData.ProcId := anEntryId;
    pit_proc_callers,
    pit_proc_callees : raise Exception.Create('Caller and Callee must be added with an index.');
    pit_thread : LData.ThreadId := anEntryId;
  end;
end;


procedure TSimpleTimeStatsListTools.AddEntry(const anEntryId, anIndex : Cardinal);
var
  LData : PProfilingInfoRec;
  LNode : PVirtualNode;
begin
  LNode := flist.AddChild(nil);
  LData := PProfilingInfoRec(LNode.GetData);
  LData.ProfilingType := fListType;
  case fListType of
    pit_unit : LData.UnitId := anEntryId;
    pit_class : LData.ClassId := anEntryId;
    pit_proc: LData.ProcId := anEntryId;
    pit_proc_callers :
      begin
        LData.CallerProcId := anEntryId;
        LData.CallerGraphIndex := anIndex;
      end;
    pit_proc_callees :
      begin
        LData.CalleeProcId := anEntryId;
        LData.CalleeGraphIndex := anIndex;
      end;
    pit_thread : LData.ThreadId := anEntryId;
  end;
end;


function TSimpleTimeStatsListTools.GetRowAsCsv(const aNode: PVirtualNode;
  const aDelimeter: char): string;
var i :integer;
    lCellText : string;
begin
  result := '';
  for i := 0 to fList.Header.Columns.Count-1 do
  begin
    OnGetText(fList,aNode, i, TVSTTextType.ttNormal,lCellText);
    lCellText := StringReplace(lCellText, ',', '.', [rfReplaceAll]);
    result := result + lCellText + aDelimeter;
  end;
end;


function TSimpleTimeStatsListTools.GetSelectedNode: PVirtualNode;
var
  LEnum : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnum := fList.SelectedNodes(false).GetEnumerator();
  while(LEnum.MoveNext) do
  begin
    Exit(LEnum.Current);
  end;
end;

function TSimpleTimeStatsListTools.GetSelectedId: int64;
var
  LNode : PVirtualNode;
begin
  result := -1;
  LNode := self.GetSelectedNode;
  if assigned(LNode) then
    Result := PProfilingInfoRec(LNode.GetData).GetId;
end;

function TSimpleTimeStatsListTools.SetSelectedId(const anId: Int64): boolean;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := false;
  LEnumor := fList.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    if PProfilingInfoRec(LEnumor.Current.GetData).GetId = anId then
    begin
      fList.Selected[LEnumor.Current] := true;
      result := true;
    end
    else
      fList.Selected[LEnumor.Current] := false;
  end;
end;

function TSimpleTimeStatsListTools.GetSelectedCaption(): string;
var
  LNode : PVirtualNode;
begin
  result := '';
  LNode := self.GetSelectedNode;
  if Assigned(LNode) then
    OnGetText(fList,LNode, 0, TVSTTextType.ttNormal,result);
end;

function TSimpleTimeStatsListTools.GetThreadName(index: integer): string;
begin
  with fProfileResults.resThreads[index] do
  begin
    if Name = '' then
      Result := 'Thread '+IntToStr(index)
    else
      Result := Name;
  end;
end; { TfrmMain.GetThreadName }

/// Events

function TSimpleTimeStatsListTools.GetColInfoType(const aData : PProfilingInfoRec;const aColumnIndex: integer): TColumnInfoType;
begin
  result := undefined;
  if aData.ProfilingType = pit_unit then
  begin
    case aColumnIndex of
      COL_UNIT_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_UNIT_TOTAL_TIME:
        result := TColumnInfoType.Time;
      COL_UNIT_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end
  else if aData.ProfilingType = pit_class then
  begin
     case aColumnIndex of
      COL_CLASS_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_CLASS_TOTAL_TIME:
        result := TColumnInfoType.Time;
      COL_CLASS_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end
  else if (aData.ProfilingType in [pit_proc,pit_proc_callers,pit_proc_callees]) then
  begin
    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_PROC_TOTAL_CHILD_PERC:
        result := TColumnInfoType.Percent;
      COL_PROC_TOTAL_TIME:
        result := TColumnInfoType.Time;
      COL_PROC_TOTAL_CHILD_TIME:
        result := TColumnInfoType.Time;
      COL_PROC_TOTAL_CALLS:
        result := TColumnInfoType.Count;
      COL_PROC_MIN_TIME_PER_CALL:
        result := TColumnInfoType.Time;
      COL_PROC_MAX_TIME_PER_CALL:
        result := TColumnInfoType.Time;
      COL_PROC_AVG_TIME_PER_CALL:
        result := TColumnInfoType.Time;
    end;
  end
  else if aData.ProfilingType = pit_thread then
  begin
    case aColumnIndex of
      COL_THREAD_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_THREAD_TOTAL_TIME:
        result := TColumnInfoType.Time;
      COL_THREAD_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end;
  
end;

function TSimpleTimeStatsListTools.GetValue(const aData : PProfilingInfoRec;const aColumnIndex: integer;out aValue, aMax : double; out aColRenderType:TColumnInfoType): boolean;
var
  LTotalTime : int64;
begin
  aValue := 0.0;
  aMax := 1.0;
  aColRenderType := GetColInfoType(aData,aColumnIndex);
  if aData.ProfilingType = pit_unit then
  begin
    LTotalTime := fProfileResults.resUnits[0].ueTotalTime[fThreadIndex];
    if LTotalTime = 0  then
      Exit(false);

    case aColumnIndex of
      COL_UNIT_TOTAL_PERC:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_UNIT_TOTAL_TIME:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalTime[fThreadIndex];
        aMax := fProfileResults.resFrequency;
      end;
      COL_UNIT_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_class then
  begin
    LTotalTime := fProfileResults.resClasses[0].ceTotalTime[fThreadIndex];
    if LTotalTime = 0  then
      Exit(false);
     case aColumnIndex of
      COL_CLASS_TOTAL_PERC:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_CLASS_TOTAL_TIME:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalTime[fThreadIndex];
        aMax := fProfileResults.resFrequency;
      end;
      COL_CLASS_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc then
  begin
    LTotalTime := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    if LTotalTime = 0  then
      Exit(false);

    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcChildTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_TIME:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcTime[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CHILD_TIME:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcChildTime[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcCnt[fThreadIndex];
      end;
      COL_PROC_MIN_TIME_PER_CALL:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcTimeMin[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_MAX_TIME_PER_CALL:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcTimeMax[fThreadIndex]/ fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_AVG_TIME_PER_CALL:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcTimeAvg[fThreadIndex]/ fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc_callers then
  begin
    LtotalTime := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    if LTotalTime = 0  then
      Exit(false);
    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcChildTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_TIME:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcTime[fThreadIndex]  / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CHILD_TIME:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcChildTime[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcCnt[fThreadIndex]
      end;
      COL_PROC_MIN_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcTimeMin[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_MAX_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcTimeMax[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_AVG_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcTimeAvg[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc_callees then
  begin
    LTotalTime := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    if LTotalTime = 0  then
      Exit(false);

    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcChildTime[fThreadIndex];
        aMax := LTotalTime;
      end;
      COL_PROC_TOTAL_TIME:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcTime[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CHILD_TIME:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcChildTime[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcCnt[fThreadIndex];
      end;
      COL_PROC_MIN_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcTimeMin[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_MAX_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcTimeMax[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_PROC_AVG_TIME_PER_CALL:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcTimeAvg[fThreadIndex] / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;

    end;
  end
  else if aData.ProfilingType = pit_thread then
  begin
    LTotalTime := fProfileResults.resThreads[0].teTotalTime;
    if LTotalTime = 0  then
      Exit(false);
    case aColumnIndex of
      COL_THREAD_TOTAL_PERC:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalTime;
        aMax := LTotalTime;
      end;
      COL_THREAD_TOTAL_TIME:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalTime / fProfileResults.resFrequency;
        aMax := LTotalTime / fProfileResults.resFrequency;
      end;
      COL_THREAD_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalCnt;
      end;

    end;
  end;
  Result := aColRenderType <> TColumnInfoType.undefined;
end;

procedure TSimpleTimeStatsListTools.OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LData : PProfilingInfoRec;
  totalTime: int64;
begin
  LData := node.GetData;
  if not assigned(fProfileResults) then
  begin
    CellText := '-';
    exit;
  end;
  CellText := '';
  if LData.ProfilingType = pit_unit then
  begin
    totalTime := fProfileResults.resUnits[0].ueTotalTime[fThreadIndex];
    case Column of
      COL_UNIT_NAME: CellText := fProfileResults.resUnits[LData.UnitId].Name;
      COL_UNIT_TOTAL_PERC: CellText := FormatPerc(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex]/totalTime);
      COL_UNIT_TOTAL_TIME: CellText := FormatTime(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex],fProfileResults.resFrequency);
      COL_UNIT_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resUnits[LData.UnitId].ueTotalCnt[fThreadIndex]);
    end;

  end
  else if LData.ProfilingType = pit_class then
  begin
    totalTime := fProfileResults.resClasses[0].ceTotalTime[fThreadIndex];
    case Column of
      COL_CLASS_NAME:
      begin
        CellText :=IFF(Last(fProfileResults.resClasses[LData.ClassId].Name,2)='<>',ButLast(fProfileResults.resClasses[LData.ClassId].Name,1)+'classless procedures>',fProfileResults.resClasses[LData.ClassId].Name);
      end;
      COL_CLASS_TOTAL_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resClasses[LData.ClassId].ceTotalTime[fThreadIndex]/totalTime);
      end;
      COL_CLASS_TOTAL_TIME: CellText := FormatTime(fProfileResults.resClasses[LData.ClassId].ceTotalTime[fThreadIndex],fProfileResults.resFrequency);
      COL_CLASS_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resClasses[LData.ClassId].ceTotalCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc then
  begin
    totalTime := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    case Column of
      COL_PROC_NAME:
      begin
        CellText := fProfileResults.resProcedures[LData.ProcId].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resProcedures[LData.ProcId].peProcTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resProcedures[LData.ProcId].peProcChildTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_TIME: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CHILD_TIME: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcChildTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resProcedures[LData.ProcId].peProcCnt[fThreadIndex]);
      COL_PROC_MIN_TIME_PER_CALL: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_MAX_TIME_PER_CALL: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_AVG_TIME_PER_CALL: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end
  else if LData.ProfilingType = pit_proc_callers then
  begin
    totalTime := fProfileResults.resProcedures[LData.CallerProcId].peProcTime[fThreadIndex];
    case Column of
      COL_PROC_NAME:
      begin
        CellText :=fProfileResults.resProcedures[LData.CallerGraphIndex].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcChildTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_TIME: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CHILD_TIME: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcChildTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcCnt[fThreadIndex]);
      COL_PROC_MIN_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_MAX_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_AVG_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end
  else if LData.ProfilingType = pit_proc_callees then
  begin
    totalTime := fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerProcId,0).ProcTime[fThreadIndex];

    case Column of
      COL_PROC_NAME:
      begin
        CellText :=fProfileResults.resProcedures[LData.CalleeGraphIndex].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_CHILD_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcChildTime[fThreadIndex]/totalTime);
      end;
      COL_PROC_TOTAL_TIME: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CHILD_TIME: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcChildTime[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcCnt[fThreadIndex]);
      COL_PROC_MIN_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_MAX_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      COL_PROC_AVG_TIME_PER_CALL: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end
  else if LData.ProfilingType = pit_thread then
  begin
    totalTime := fProfileResults.resThreads[0].teTotalTime;
    case Column of
      COL_THREAD_ID:
      begin
        CellText := UIntToStr(fProfileResults.resThreads[LData.ThreadId].teThread);
      end;
      COL_THREAD_NAME: Celltext := GetThreadName(LData.ThreadId);
      COL_THREAD_TOTAL_PERC:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resThreads[LData.ThreadId].teTotalTime/totalTime);
      end;
      COL_THREAD_TOTAL_TIME: CellText := FormatTime(fProfileResults.resThreads[LData.ThreadId].teTotalTime,fProfileResults.resFrequency);
      COL_THREAD_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resThreads[LData.ThreadId].teTotalCnt);
    end;
  end;
end;




procedure TSimpleTimeStatsListTools.OnCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
    LData1: PProfilingInfoRec;
    LData2: PProfilingInfoRec;
    LText1, LText2 : string;
    LValue1,LValue2 : double;
    LValueMax1,LValueMax2 : double;
    LColumnType : TColumnInfoType;
begin
  LData1 := FList.GetNodeData(Node1);
  LData2 := fList.GetNodeData(Node2);

  if Assigned(LData1) and Assigned(LData2) then
  begin
    // column 0 is always the text
    LText1 := FList.Text[Node1,Column];
    LText2 := FList.Text[Node2,Column];
    if GetValue(LData1,column,LValue1,LValueMax1, LColumnType) and
       GetValue(LData2,column,LValue2,LValueMax2,LColumnType) then
    begin
      result := CompareValue(LValue1,LValue2);
    end
    else
      result := CompareStr(LText1,LText2);
  end;
end;

procedure TSimpleTimeStatsListTools.OnAftercellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
var
  PBRect : TRect;
  Text : String;
  LData : PProfilingInfoRec;
  LValue, LMax : double;
  LCellInfo : TColumnInfoType;
  LRenderCell : Boolean;
  LNormalizedValue : double;
  LNodeIsSelected : boolean;
begin
  LData := node.GetData;
  if not assigned(fProfileResults) then
    exit;
  LRenderCell := GetValue(LData, Column, LValue, LMax, LCellInfo);
  if LRenderCell then
  begin
    case LCellInfo of
      TColumnInfoType.Percent: { process it};
      else
        exit;
    end;

    LNormalizedValue := LValue / LMax;
    PBRect := Rect(CellRect.Left + 1,
                CellRect.Top + 1,
                CellRect.Left + Round((CellRect.Right - CellRect.Left - 2) * (LNormalizedValue)),
                CellRect.Bottom - 1);
    
    with TargetCanvas do
    begin
      LNodeIsSelected := sender.Selected[node];
      if not LNodeIsSelected then
      begin
        Pen.Color := fList.Colors.BackGroundColor;
        Brush.Color := fList.Colors.BackGroundColor;
        Brush.Style := bsSolid;
      end
      else
      begin
        if sender.Focused then
        begin
          Pen.Color := fList.Colors.FocusedSelectionColor;
          Brush.Color := fList.Colors.FocusedSelectionColor;
        end
        else
        begin
          Pen.Color := fList.Colors.UnfocusedSelectionColor;
          Brush.Color := fList.Colors.UnfocusedSelectionColor;
        end;
        Brush.Style := bsSolid;
      end;
      FillRect(Rect(PBRect.Right,CellRect.Top,CellRect.Right,CellRect.Bottom));

      Pen.Color := clInactiveCaption;
      Pen.Style := psSolid;
      Brush.Style := bsClear;

      if PBRect.Right > PBRect.Left then
       Rectangle(PBRect);


      Brush.Color := clActiveCaption;
      Brush.Style := bsSolid;
      if PBRect.Right > PBRect.Left then
        FillRect(Rect(PBRect.Left + 2,
                    PBRect.Top + 2,
                    PBRect.Right - 2,
                    PBRect.Bottom - 2));

      case LCellInfo of
        TColumnInfoType.Text : Text := 'Value :'+LValue.ToString()+' , max:'+LMax.ToString();
        TColumnInfoType.Percent : Text := FormatPerc(LNormalizedValue);
        TColumnInfoType.Time : Text := FormatTime(LValue);
        TColumnInfoType.Count : Text := FormatCnt(Round(LValue));
      end;
      Font.Color := clWindowText;
      if LNodeIsSelected and sender.Focused then
        font.Color := clHighlightText;
      Brush.Style := bsClear;

      TextOut(CellRect.Left + ((CellRect.Right - CellRect.Left) div 2) - (TextWidth(Text) div 2),
              CellRect.Top + ((CellRect.Bottom - CellRect.Top) div 2) - (TextHeight(Text) div 2),
              Text);
    end;
  end;
end;


function TProfilingInfoRec.GetId : Integer;
begin
  case ProfilingType of
    pit_unit: Exit(Unitid);
    pit_class: Exit(ClassId);
    pit_proc: Exit(ProcId);
    pit_proc_callers: Exit(CallerProcId);
    pit_proc_callees: Exit(CalleeProcId);
    pit_thread : Exit(ThreadID);
  else
     Exit(-1);
  end;
end;


procedure TProfilingInfoRec.GetCallStackInfo(var aProcId: Int64;var aGraphIndex : integer);
begin
  case ProfilingType of
    pit_proc_callers:
    begin
       aProcId := self.CallerProcId;
       aGraphIndex := Self.CallerGraphIndex;
    end;
    pit_proc_callees:
    begin
       aProcId := self.CalleeProcId;
       aGraphIndex := Self.CalleeGraphIndex;
    end;
  else
    begin
       aProcId := -1;
       aGraphIndex := -1;
    end;
  end;
end;

end.

