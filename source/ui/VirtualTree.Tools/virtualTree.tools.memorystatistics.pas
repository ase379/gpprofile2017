unit virtualTree.tools.memorystatistics;

interface

uses
  System.Types,
  vcl.Graphics,
  VirtualTrees,
  gppresults,
  virtualTree.tools.base;

type
  TMemoryInfoTypeEnum = (pit_unit, pit_class,pit_proc,pit_proc_callers,pit_proc_callees,pit_thread);
  PMemoryInfoRec = ^TMemoryInfoRec;
  TMemoryInfoRec = record
    function GetId : Integer;
    procedure GetCallStackInfo(var aProcId: Int64;var aGraphIndex : integer);
    case ProfilingType: TMemoryInfoTypeEnum of
      pit_unit: (UnitId: integer);
      pit_class: (ClassId: integer);
      pit_proc: (ProcId: integer);
      pit_proc_callers: (CallerProcId: integer;CallerGraphIndex:integer);
      pit_proc_callees: (CalleeProcId: integer;CalleeGraphIndex:integer);
      pit_thread: (ThreadId: Cardinal);
  end;

  TColumnInfoType = (undefined,Text,Percent, Mem, Count);
  TSimpleMemStatsListTools = class(TVirtualTreeBaseTools)
  private
    fTreeType : TMemoryInfoTypeEnum;
    fProfileResults : TResults;
    fThreadIndex : Integer;
    function  GetThreadName(index: integer): string;
    /// <summary>
    ///   Gets the raw values. The values are returned as double. Thus, false is returned if not double compatible
    ///  type is stored for the cell (e.g. a string).
    /// </summary>
    function GetValue(const aData : PMemoryInfoRec; const aColumnIndex: integer; out aValue, aMax : double;out aColRenderType:TColumnInfoType): boolean;
    /// <summary>
    /// Returns the type of the column content.
    /// </summary>
    function GetColInfoType(const aData : PMemoryInfoRec;const aColumnIndex: integer): TColumnInfoType;
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
    constructor Create(const aList: TVirtualStringTree;const aListType : TMemoryInfoTypeEnum);

    procedure AddEntry(const anEntryId : Cardinal);overload;
    procedure AddEntry(const anEntryId, anIndex : Cardinal);overload;

    function GetSelectedId(): Int64;
    function SetSelectedId(const anId : Int64) : boolean;
    function GetSelectedCaption(): string;

    function GetSelectedNode: PVirtualNode;

    function GetRowAsCsv(const aNode: PVirtualNode; const aDelimeter: char): string;

    property ThreadIndex : integer read fThreadIndex write fThreadIndex;
    property ProfileResults : TResults read fProfileResults write fProfileResults;
    property ListView : TVirtualStringTree read fTree;
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
  COL_UNIT_TOTAL_MEM = 2;
  COL_UNIT_TOTAL_CALLS = 3;
  // col index for Class
  COL_CLASS_NAME = 0;
  COL_CLASS_TOTAL_PERC = 1;
  COL_CLASS_TOTAL_MEM = 2;
  COL_CLASS_TOTAL_CALLS = 3;
  // col index for Proc
  COL_PROC_NAME = 0;
  COL_PROC_TOTAL_PERC = 1;
  COL_PROC_TOTAL_MEM = 2;
  COL_PROC_TOTAL_CALLS = 3;
  // col index for thread
  COL_THREAD_ID = 0;
  COL_THREAD_NAME = 1;
  COL_THREAD_TOTAL_PERC = 2;
  COL_THREAD_TOTAL_TIME = 3;
  COL_THREAD_TOTAL_CALLS = 4;


constructor TSimpleMemStatsListTools.Create(const aList: TVirtualStringTree; const aListType : TMemoryInfoTypeEnum);
begin
  inherited Create(AList);
  fTreeType := aListType;
  fTree.NodeDataSize := SizeOf(TMemoryInfoRec);
  fTree.OnCompareNodes := self.OnCompareNodes;
  fTree.ongettext := OnGetText;
  fTree.OnAfterCellPaint := OnAftercellPaint;
  fTree.TreeOptions.SelectionOptions := fTree.TreeOptions.SelectionOptions + [TVTSelectionOption.toFullRowSelect];
end;

procedure TSimpleMemStatsListTools.AddEntry(const anEntryId : Cardinal);
var
  LData : PMemoryInfoRec;
  LNode : PVirtualNode;
begin
  LNode := fTree.AddChild(nil);
  LData := PMemoryInfoRec(LNode.GetData);
  LData.ProfilingType := fTreeType;
  case fTreeType of
    pit_unit : LData.UnitId := anEntryId;
    pit_class : LData.ClassId := anEntryId;
    pit_proc: LData.ProcId := anEntryId;
    pit_proc_callers,
    pit_proc_callees : raise Exception.Create('Caller and Callee must be added with an index.');
    pit_thread : LData.ThreadId := anEntryId;
  end;
end;


procedure TSimpleMemStatsListTools.AddEntry(const anEntryId, anIndex : Cardinal);
var
  LData : PMemoryInfoRec;
  LNode : PVirtualNode;
begin
  LNode := fTree.AddChild(nil);
  LData := PMemoryInfoRec(LNode.GetData);
  LData.ProfilingType := fTreeType;
  case fTreeType of
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


function TSimpleMemStatsListTools.GetRowAsCsv(const aNode: PVirtualNode;
  const aDelimeter: char): string;
var i :integer;
    lCellText : string;
begin
  result := '';
  for i := 0 to fTree.Header.Columns.Count-1 do
  begin
    OnGetText(fTree,aNode, i, TVSTTextType.ttNormal,lCellText);
    lCellText := StringReplace(lCellText, ',', '.', [rfReplaceAll]);
    result := result + lCellText + aDelimeter;
  end;
end;


function TSimpleMemStatsListTools.GetSelectedNode: PVirtualNode;
var
  LEnum : TVTVirtualNodeEnumerator;
begin
  result := nil;
  LEnum := fTree.SelectedNodes(false).GetEnumerator();
  while(LEnum.MoveNext) do
  begin
    Exit(LEnum.Current);
  end;
end;

function TSimpleMemStatsListTools.GetSelectedId: int64;
var
  LNode : PVirtualNode;
begin
  result := -1;
  LNode := self.GetSelectedNode;
  if assigned(LNode) then
    Result := PMemoryInfoRec(LNode.GetData).GetId;
end;

function TSimpleMemStatsListTools.SetSelectedId(const anId: Int64): boolean;
var
  LEnumor : TVTVirtualNodeEnumerator;
begin
  result := false;
  LEnumor := fTree.Nodes().GetEnumerator();
  while(LEnumor.MoveNext) do
  begin
    if PMemoryInfoRec(LEnumor.Current.GetData).GetId = anId then
    begin
      fTree.Selected[LEnumor.Current] := true;
      result := true;
    end
    else
      fTree.Selected[LEnumor.Current] := false;
  end;
end;

function TSimpleMemStatsListTools.GetSelectedCaption(): string;
var
  LNode : PVirtualNode;
begin
  result := '';
  LNode := self.GetSelectedNode;
  if Assigned(LNode) then
    OnGetText(fTree,LNode, 0, TVSTTextType.ttNormal,result);
end;

function TSimpleMemStatsListTools.GetThreadName(index: integer): string;
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

function TSimpleMemStatsListTools.GetColInfoType(const aData : PMemoryInfoRec;const aColumnIndex: integer): TColumnInfoType;
begin
  result := undefined;
  if aData.ProfilingType = pit_unit then
  begin
    case aColumnIndex of
      COL_UNIT_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_UNIT_TOTAL_MEM:
        result := TColumnInfoType.Mem;
      COL_UNIT_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end
  else if aData.ProfilingType = pit_class then
  begin
     case aColumnIndex of
      COL_CLASS_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_CLASS_TOTAL_MEM:
        result := TColumnInfoType.Mem;
      COL_CLASS_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end
  else if (aData.ProfilingType in [pit_proc,pit_proc_callers,pit_proc_callees]) then
  begin
    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_PROC_TOTAL_MEM:
        result := TColumnInfoType.Mem;
      COL_PROC_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end
  else if aData.ProfilingType = pit_thread then
  begin
    case aColumnIndex of
      COL_THREAD_TOTAL_PERC:
        result := TColumnInfoType.Percent;
      COL_THREAD_TOTAL_TIME:
        result := TColumnInfoType.Mem;
      COL_THREAD_TOTAL_CALLS:
        result := TColumnInfoType.Count;
    end;
  end;
  
end;

function TSimpleMemStatsListTools.GetValue(const aData : PMemoryInfoRec;const aColumnIndex: integer;out aValue, aMax : double; out aColRenderType:TColumnInfoType): boolean;
var
  LTotalMem : int64;
begin
  aValue := 0.0;
  aMax := 1.0;
  aColRenderType := GetColInfoType(aData,aColumnIndex);
  if aData.ProfilingType = pit_unit then
  begin
    LTotalMem := fProfileResults.resUnits[0].ueTotalMem[fThreadIndex];
    if LTotalMem = 0  then
      Exit(false);

    case aColumnIndex of
      COL_UNIT_TOTAL_PERC:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_UNIT_TOTAL_MEM:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalMem[fThreadIndex];
      end;
      COL_UNIT_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resUnits[aData.UnitId].ueTotalCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_class then
  begin
    LTotalMem := fProfileResults.resClasses[0].ceTotalMem[fThreadIndex];
    if LTotalMem = 0  then
      Exit(false);
     case aColumnIndex of
      COL_CLASS_TOTAL_PERC:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_CLASS_TOTAL_MEM:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalMem[fThreadIndex];
      end;
      COL_CLASS_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resClasses[aData.ClassId].ceTotalCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc then
  begin
    LTotalMem := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    if LTotalMem = 0  then
      Exit(false);

    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_MEM:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resProcedures[aData.ProcId].peProcCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc_callers then
  begin
    LTotalMem := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
    if LTotalMem = 0  then
      Exit(false);
    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_MEM:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CallerGraphIndex,aData.CallerProcId).ProcCnt[fThreadIndex]
      end;
    end;
  end
  else if aData.ProfilingType = pit_proc_callees then
  begin
    LTotalMem := fProfileResults.resProcedures[0].peProcMem[fThreadIndex];
    if LTotalMem = 0  then
      Exit(false);

    case aColumnIndex of
      COL_PROC_TOTAL_PERC:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_MEM:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcMem[fThreadIndex];
        aMax := LTotalMem;
      end;
      COL_PROC_TOTAL_CALLS:
      begin
        aValue := fProfileResults.CallGraphInfo.GetGraphInfo(aData.CalleeProcId,aData.CalleeGraphIndex).ProcCnt[fThreadIndex];
      end;
    end;
  end
  else if aData.ProfilingType = pit_thread then
  begin
    LTotalMem := fProfileResults.resThreads[0].teTotalMem;
    if LTotalMem = 0  then
      Exit(false);
    case aColumnIndex of
      COL_THREAD_TOTAL_PERC:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalMem;
        aMax := LTotalMem;
      end;
      COL_THREAD_TOTAL_TIME:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalMem;
        aMax := LTotalMem;
      end;
      COL_THREAD_TOTAL_CALLS:
      begin
        aValue := fProfileResults.resThreads[aData.ThreadId].teTotalCnt;
      end;

    end;
  end;
  Result := aColRenderType <> TColumnInfoType.undefined;
end;

procedure TSimpleMemStatsListTools.OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LData : PMemoryInfoRec;
  TotalMem: int64;
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
    TotalMem := fProfileResults.resUnits[0].ueTotalMem[fThreadIndex];
    case Column of
      COL_UNIT_NAME: CellText := fProfileResults.resUnits[LData.UnitId].Name;
      COL_UNIT_TOTAL_PERC: CellText := FormatPerc(fProfileResults.resUnits[LData.UnitId].ueTotalMem[fThreadIndex]/TotalMem);
      COL_UNIT_TOTAL_MEM: CellText := FormatTime(fProfileResults.resUnits[LData.UnitId].ueTotalMem[fThreadIndex]);
      COL_UNIT_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resUnits[LData.UnitId].ueTotalCnt[fThreadIndex]);
    end;

  end
  else if LData.ProfilingType = pit_class then
  begin
    TotalMem := fProfileResults.resClasses[0].ceTotalMem[fThreadIndex];
    case Column of
      COL_CLASS_NAME:
      begin
        CellText :=IFF(Last(fProfileResults.resClasses[LData.ClassId].Name,2)='<>',ButLast(fProfileResults.resClasses[LData.ClassId].Name,1)+'classless procedures>',fProfileResults.resClasses[LData.ClassId].Name);
      end;
      COL_CLASS_TOTAL_PERC:
      begin
        if TotalMem = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resClasses[LData.ClassId].ceTotalMem[fThreadIndex]/TotalMem);
      end;
      COL_CLASS_TOTAL_MEM: CellText := FormatTime(fProfileResults.resClasses[LData.ClassId].ceTotalMem[fThreadIndex]);
      COL_CLASS_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resClasses[LData.ClassId].ceTotalCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc then
  begin
    TotalMem := fProfileResults.resProcedures[0].peProcMem[fThreadIndex];
    case Column of
      COL_PROC_NAME:
      begin
        CellText := fProfileResults.resProcedures[LData.ProcId].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if TotalMem = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resProcedures[LData.ProcId].peProcMem[fThreadIndex]/TotalMem);
      end;
      COL_PROC_TOTAL_MEM: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcMem[fThreadIndex]);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resProcedures[LData.ProcId].peProcCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc_callers then
  begin
    TotalMem := fProfileResults.resProcedures[LData.CallerProcId].peProcMem[fThreadIndex];
    case Column of
      COL_PROC_NAME:
      begin
        CellText :=fProfileResults.resProcedures[LData.CallerGraphIndex].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if TotalMem = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcMem[fThreadIndex]/TotalMem);
      end;
      COL_PROC_TOTAL_MEM: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcMem[fThreadIndex]);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerGraphIndex,LData.CallerProcId).ProcCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc_callees then
  begin
    TotalMem := fProfileResults.CallGraphInfo.GetGraphInfo(LData.CallerProcId,0).ProcMem[fThreadIndex];

    case Column of
      COL_PROC_NAME:
      begin
        CellText :=fProfileResults.resProcedures[LData.CalleeGraphIndex].Name;
      end;
      COL_PROC_TOTAL_PERC:
      begin
        if TotalMem = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcMem[fThreadIndex]/TotalMem);
      end;

      COL_PROC_TOTAL_MEM: CellText := FormatTime(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcMem[fThreadIndex]);
      COL_PROC_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.CallGraphInfo.GetGraphInfo(LData.CalleeProcId,LData.CalleeGraphIndex).ProcCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_thread then
  begin
    TotalMem := fProfileResults.resThreads[0].teTotalMem;
    case Column of
      COL_THREAD_ID:
      begin
        CellText := UIntToStr(fProfileResults.resThreads[LData.ThreadId].teThread);
      end;
      COL_THREAD_NAME: Celltext := GetThreadName(LData.ThreadId);
      COL_THREAD_TOTAL_PERC:
      begin
        if TotalMem = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resThreads[LData.ThreadId].teTotalMem/TotalMem);
      end;
      COL_THREAD_TOTAL_TIME: CellText := FormatTime(fProfileResults.resThreads[LData.ThreadId].teTotalMem);
      COL_THREAD_TOTAL_CALLS: CellText := FormatCnt(fProfileResults.resThreads[LData.ThreadId].teTotalCnt);
    end;
  end;
end;




procedure TSimpleMemStatsListTools.OnCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
    LData1: PMemoryInfoRec;
    LData2: PMemoryInfoRec;
    LText1, LText2 : string;
    LValue1,LValue2 : double;
    LValueMax1,LValueMax2 : double;
    LColumnType : TColumnInfoType;
begin
  LData1 := fTree.GetNodeData(Node1);
  LData2 := fTree.GetNodeData(Node2);

  if Assigned(LData1) and Assigned(LData2) then
  begin
    // column 0 is always the text
    LText1 := fTree.Text[Node1,Column];
    LText2 := fTree.Text[Node2,Column];
    if GetValue(LData1,column,LValue1,LValueMax1, LColumnType) and
       GetValue(LData2,column,LValue2,LValueMax2,LColumnType) then
    begin
      result := CompareValue(LValue1,LValue2);
    end
    else
      result := CompareStr(LText1,LText2);
  end;
end;

procedure TSimpleMemStatsListTools.OnAftercellPaint(Sender: TBaseVirtualTree; TargetCanvas: TCanvas; Node: PVirtualNode;
  Column: TColumnIndex; CellRect: TRect);
var
  PBRect : TRect;
  Text : String;
  LData : PMemoryInfoRec;
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
        Pen.Color := fTree.Colors.BackGroundColor;
        Brush.Color := fTree.Colors.BackGroundColor;
        Brush.Style := bsSolid;
      end
      else
      begin
        if sender.Focused then
        begin
          Pen.Color := fTree.Colors.FocusedSelectionColor;
          Brush.Color := fTree.Colors.FocusedSelectionColor;
        end
        else
        begin
          Pen.Color := fTree.Colors.UnfocusedSelectionColor;
          Brush.Color := fTree.Colors.UnfocusedSelectionColor;
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
        TColumnInfoType.Mem : Text := FormatTime(LValue);
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


function TMemoryInfoRec.GetId : Integer;
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


procedure TMemoryInfoRec.GetCallStackInfo(var aProcId: Int64;var aGraphIndex : integer);
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

