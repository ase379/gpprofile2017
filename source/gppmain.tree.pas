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
    procedure OnFreeNode(Sender: TBaseVirtualTree;Node: PVirtualNode);
    procedure OnGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);

  public
    constructor Create(const aList: TVirtualStringTree;const aListType : TProfilingInfoTypeEnum);

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure AddEntry(const aParentId, anEntryId : Integer);

    property ThreadIndex : integer read fThreadIndex write fThreadIndex;
    property ProfileResults : TResults read fProfileResults write fProfileResults;

    class function FormatTime(const ticks,frequency: int64): string;
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
  fList.OnFreeNode := self.OnFreeNode;
  fList.ongettext := OnGetText;
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



procedure TSimpleStatsListTools.AddEntry(const aParentId, anEntryId : Integer);
var
  LData : PProfilingInfoRec;
  LNode : PVirtualNode;
begin
  LNode := flist.AddChild(nil);
  LData := PProfilingInfoRec(LNode.GetData);
  LData.ProfilingType := fListType;
  LData.ParentClassId := aParentId;
  LData.ProcId := anEntryId;
end;


class function TSimpleStatsListTools.FormatTime(const ticks, frequency: int64): string;
begin
  Result := Format('%.6n',[(ticks/frequency{fProfileResults.resFrequency)})]);
end;

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
  if LData.ThreadUnitId < 0 then
    exit;
  if LData.ProfilingType = pit_unit then
  begin
    totalTime := fProfileResults.resUnits[0].ueTotalTime[fThreadIndex];
    case Column of
      0: CellText := fProfileResults.resUnits[LData.UnitId].ueName;
      1: CellText := FormatPerc(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex]/totalTime);
      2: CellText := FormatTime(fProfileResults.resUnits[LData.UnitId].ueTotalTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := '-';
      4: CellText := FormatCnt(fProfileResults.resUnits[LData.UnitId].ueTotalCnt[fThreadIndex]);
      5: CellText := '-';
      6: CellText := '-';
      7: CellText := '-';
    end;

  end
  else if LData.ProfilingType = pit_class then
  begin
    totalTime := fProfileResults.resClasses[0].ceTotalTime[fThreadIndex];
    case Column of
      0:
      begin
        CellText :=IFF(Last(fProfileResults.resClasses[LData.UnitId].ceName,2)='<>',ButLast(fProfileResults.resClasses[LData.UnitId].ceName,1)+'classless procedures>',fProfileResults.resClasses[LData.UnitId].ceName);
      end;
      1:
      begin
        if totalTime = 0  then
          CellText := FormatPerc(0)
        else
          CellText := FormatPerc(fProfileResults.resClasses[LData.UnitId].ceTotalTime[fThreadIndex]/totalTime);
      end;
      2: CellText := FormatTime(fProfileResults.resClasses[LData.UnitId].ceTotalTime[fThreadIndex],fProfileResults.resFrequency);
      3: CellText := FormatCnt(fProfileResults.resClasses[LData.UnitId].ceTotalCnt[fThreadIndex]);
    end;
  end
  else if LData.ProfilingType = pit_proc then
  begin
    totalTime := fProfileResults.resProcedures[0].peProcTime[fThreadIndex];
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
      4: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcCnt[fThreadIndex],fProfileResults.resFrequency);
      5: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMin[fThreadIndex],fProfileResults.resFrequency);
      6: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeMax[fThreadIndex],fProfileResults.resFrequency);
      7: CellText := FormatTime(fProfileResults.resProcedures[LData.ProcId].peProcTimeAvg[fThreadIndex],fProfileResults.resFrequency);
    end;
  end;
end;



end.
