unit gppmain.tree;

interface

uses
  VirtualTrees,

  gppmain.tree.types,
  gppresults;

type
  TSimpleStatsListTools = class
  private
    fList: TVirtualStringTree;
    fListType : TProfilingInfoTypeEnum;
    fProfileResults : TResults;
    fThreadIndex : Integer;
    fSortcols: array of TColumnIndex;
    function  GetThreadName(index: integer): string;

    procedure OnFreeNode(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure OnCompareNodes(Sender: TBaseVirtualTree; Node1, Node2: PVirtualNode;
      Column: TColumnIndex; var Result: Integer);
    procedure OnHeaderClick(Sender: TVTHeader; HitInfo: TVTHeaderHitInfo);

  public
    constructor Create(const aList: TVirtualStringTree;const aListType : TProfilingInfoTypeEnum);

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure AddEntry(const anEntryId : Cardinal);overload;
    procedure AddEntry(const anEntryId, anIndex : Cardinal);overload;

    function GetSelectedId(): Int64;
    function GetSelectedCaption(): string;

    function GetSelectedNode: PVirtualNode;

    function GetRowAsCsv(const aNode: PVirtualNode; const aDelimeter: char): string;

    property ThreadIndex : integer read fThreadIndex write fThreadIndex;
    property ProfileResults : TResults read fProfileResults write fProfileResults;
    property ListView : TVirtualStringTree read fList;

    class function FormatTime(const ticks,frequency: int64): string; overload;
    class function FormatTime(const value: double): string; overload;

    class function FormatCnt(const cnt: integer): string;
    class function FormatPerc(const per: real): string;

  end;

implementation

uses
  System.SysUtils,
  GpIFF,
  gpString;


procedure TSimpleStatsListTools.Clear;
begin
  fList.Clear();
end;

constructor TSimpleStatsListTools.Create(const aList: TVirtualStringTree; const aListType : TProfilingInfoTypeEnum);
begin
  fList := aList;
  fListType := aListType;
  fList.NodeDataSize := SizeOf(TProfilingInfoRec);
  fList.OnFreeNode := self.OnFreeNode;
  fList.OnCompareNodes := self.OnCompareNodes;
  fList.ongettext := OnGetText;
  fList.OnHeaderClick := self.OnHeaderClick;
end;

procedure TSimpleStatsListTools.BeginUpdate;
begin
  FList.BeginUpdate;
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions - [toReadOnly];
end;

procedure TSimpleStatsListTools.EndUpdate;
begin
  fList.TreeOptions.MiscOptions := fList.TreeOptions.MiscOptions + [toReadOnly];
  FList.EndUpdate;
end;



procedure TSimpleStatsListTools.AddEntry(const anEntryId : Cardinal);
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


procedure TSimpleStatsListTools.AddEntry(const anEntryId, anIndex : Cardinal);
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


class function TSimpleStatsListTools.FormatTime(const ticks, frequency: int64): string;
begin
  Result := FormatTime( ticks / frequency);
end;


class function TSimpleStatsListTools.FormatTime(const value: double): string;
begin
  Result := Format('%.6n',[value]);
end;

function TSimpleStatsListTools.GetRowAsCsv(const aNode: PVirtualNode;
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


function TSimpleStatsListTools.GetSelectedNode: PVirtualNode;
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

function TSimpleStatsListTools.GetSelectedId: int64;
var
  LNode : PVirtualNode;
begin
  result := -1;
  LNode := self.GetSelectedNode;
  if assigned(LNode) then
    Result := PProfilingInfoRec(LNode.GetData).GetId;
end;

function TSimpleStatsListTools.GetSelectedCaption(): string;
var
  LNode : PVirtualNode;
begin
  result := '';
  LNode := self.GetSelectedNode;
  if Assigned(LNode) then
    OnGetText(fList,LNode, 0, TVSTTextType.ttNormal,result);
end;

function TSimpleStatsListTools.GetThreadName(index: integer): string;
begin
  with fProfileResults.resThreads[index] do
  begin
    if teName = '' then
      Result := 'Thread '+IntToStr(index)
    else
      Result := teName;
  end;
end; { TfrmMain.GetThreadName }

class function TSimpleStatsListTools.FormatCnt(const cnt: integer): string;
begin
  Result := Format('%.0n',[int(cnt)]);
end;

class function TSimpleStatsListTools.FormatPerc(const per: real): string;
begin
  Result := Format('%2.1f %%',[per*100]);
end;

/// Events


procedure TSimpleStatsListTools.OnFreeNode(Sender: TBaseVirtualTree;
  Node: PVirtualNode);
var
  Data: Pointer;
begin
  Data := Node.GetData();
  if data <> nil then
    Finalize(Data^);
end;

procedure TSimpleStatsListTools.OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var
  LData : PProfilingInfoRec;
  totalTime: int64;
begin
  LData := node.GetData;
  if not assigned(fProfileResults) then
    exit;
  CellText := '';
  if LData.ProfilingType = pit_unit then
  begin
    totalTime := fProfileResults.resUnits[0].ueTotalTime[fThreadIndex];
    case Column of
      0: CellText := fProfileResults.resUnits[LData.UnitId].ueName;
      1: CellText := FormatPerc(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex]/totalTime);
      2: CellText := FormatTime(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := FormatCnt(fProfileResults.resUnits[LData.UnitId].ueTotalCnt[fThreadIndex]);
    end;

  end
  else if LData.ProfilingType = pit_class then
  begin
    totalTime := fProfileResults.resClasses[0].ceTotalTime[fThreadIndex];
    case Column of
      0:
      begin
        CellText :=IFF(Last(fProfileResults.resClasses[LData.ClassId].ceName,2)='<>',ButLast(fProfileResults.resClasses[LData.ClassId].ceName,1)+'classless procedures>',fProfileResults.resClasses[LData.ClassId].ceName);
      end;
      1:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resClasses[LData.ClassId].ceTotalTime[fThreadIndex]/totalTime);
      end;
      2: CellText := FormatTime(fProfileResults.resClasses[LData.ClassId].ceTotalTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := FormatCnt(fProfileResults.resClasses[LData.ClassId].ceTotalCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc then
  begin
    totalTime := fProfileResults.resProcedures[LData.ProcId].peProcTime[fThreadIndex];
    case Column of
      0:
      begin
        CellText := fProfileResults.resProcedures[LData.ProcId].peName;
      end;
      1:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resProcedures[LData.ProcId].peProcTime[fThreadIndex]/totalTime);
      end;
      2: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcChildTime[fThreadIndex],fProfileResults.resFrequency);
      4: CellText := FormatCnt(fProfileResults.resProcedures[LData.ProcId].peProcCnt[fThreadIndex]);
      5: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      6: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      7: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end
  else if LData.ProfilingType = pit_proc_callers then
  begin
    totalTime := fProfileResults.resProcedures[LData.CallerProcId].peProcTime[fThreadIndex];
    case Column of
      0:
      begin
        CellText :=fProfileResults.resProcedures[LData.CallerGraphIndex].peName;
      end;
      1:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcTime[fThreadIndex]/totalTime);
      end;
      2: CellText := FormatTime(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := FormatTime(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcChildTime[fThreadIndex],fProfileResults.resFrequency);
      4: CellText := FormatCnt(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcCnt[fThreadIndex]);
      5: CellText := FormatTime(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      6: CellText := FormatTime(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      7: CellText := FormatTime(fProfileResults.resCallGraph[LData.CallerGraphIndex,LData.CallerProcId].cgeProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end
  else if LData.ProfilingType = pit_thread then
  begin
    totalTime := fProfileResults.resThreads[0].teTotalTime;
    case Column of
      0:
      begin
        CellText := UIntToStr(fProfileResults.resThreads[LData.ThreadId].teThread);
      end;
      1: Celltext := GetThreadName(LData.ThreadId);
      2:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resThreads[LData.ThreadId].teTotalTime/totalTime);
      end;
      3: CellText := FormatTime(fProfileResults.resThreads[LData.ThreadId].teTotalTime,fProfileResults.resFrequency);
      4: CellText := FormatCnt(fProfileResults.resThreads[LData.ThreadId].teTotalCnt);
    end;
  end;
end;

procedure TSimpleStatsListTools.OnHeaderClick(Sender: TVTHeader;
  HitInfo: TVTHeaderHitInfo);
begin
(*  if not CtrlDown then //function I have to test Ctrl state.
  begin
    setlength(fSortCols,0);
  end;*)
  SetLength(fSortCols,length(fSortCols)+1);
  fSortCols[Length(fSortCols)-1] := HitInfo.Column;
  fList.SortTree(HitInfo.Column,Sender.SortDirection,True);

  if Sender.SortDirection=sdAscending then
    Sender.SortDirection:=sdDescending
  else
    Sender.SortDirection:=sdAscending;
  fList.Header.SortDirection := Sender.SortDirection;
  fList.Header.SortColumn := HitInfo.Column;
end;

procedure TSimpleStatsListTools.OnCompareNodes(Sender: TBaseVirtualTree;
  Node1, Node2: PVirtualNode; Column: TColumnIndex; var Result: Integer);
var
    i: integer;
    LData1: PProfilingInfoRec;
    LData2: PProfilingInfoRec;
begin
  if Length(fSortCols) > 0 then
  begin
    LData1 := FList.GetNodeData(Node1);
    LData2 := fList.GetNodeData(Node2);

    if Assigned(LData1) and Assigned(LData2) then
      for i := High(fSortCols) downto 0 do
      begin
        Result := CompareStr(FList.Text[Node1,i],FList.Text[Node2,i]);
        if Result <> 0 then
          Break;
      end;
  end;
end;

end.
