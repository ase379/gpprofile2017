unit gppResults.callGraph;

interface

uses
  System.Generics.Collections;

type
  TCallGraphKey = record
  public
    ParentProcId : Integer;
    ProcId : Integer;
    constructor Create(aParentId, aChildId : integer);
  end;


  /// <summary>
  /// A list for counting the proc calls.
  /// The index is the thread number. 0 means "All Threads".
  /// </summary>
  tProcTimeList = class(TList<int64>)
  public
    /// <summary>
    /// Adds a time to the given index.
    /// If the anIndex is not 0, the sum(index 0) is incremented as well.
    /// </summary>
    procedure AddTime(const anIndex : integer;const aValueToBeAdded: int64);
    /// <summary>
    /// Set a time value for a given index.
    /// If the anIndex is not 0, the sum(index 0) is adjusted as well.
    /// </summary>
  procedure AssignTime(const anIndex : integer; const aValueToBeAssigned: int64);
  end;

  /// <summary>
  /// A list for counting the proc calls.
  /// The index is the thread number. 0 means "All Threads".
  /// </summary>
  tProcCountList = class(TList<integer>)
  public
    /// <summary>
    /// Adds a count to the given index.
    /// If the anIndex is not 0, the sum(index 0) is incremented as well.
    /// </summary>
    procedure AddCount(const anIndex : integer;const aValueToBeAdded: integer);

  end;
  /// <summary>
  /// The class describes the call graph info (which parent proc calls which child proc).
  /// The lists are as long as the number of threads.
  /// </summary>
  TCallGraphInfo = class
  public
    ProcTime     : tProcTimeList;   // 0 = sum
    ProcTimeMin  : tProcTimeList;   // 0 = unused
    ProcTimeMax  : tProcTimeList;   // 0 = unused
    ProcTimeAvg  : tProcTimeList;   // 0 = unused
    ProcChildTime: tProcTimeList;   // 0 = sum
    ProcCnt      : tProcCountList; // 0 = sum
    constructor Create(const aThreadCount: Integer);
    destructor Destroy; override;

    function ToInfoString(): string;
  end;

  /// <summary>
  /// The old implementation used a 2d vector to store the parent and child proc id.
  /// The cell contained the graph info record or nil. Column 0 was reserved for the total counts.
  /// This caused an OOM, cause 2d arrays tend to consume a lot of memory.
  /// This class represents a sparse array: all nils are ommited. Only valid values are stored
  /// inside.
  /// </summary>
  TCallGraphInfoDict = class(TObjectDictionary<TCallGraphKey,TCallGraphInfo>)
  public
    /// <summary>
    /// Returns the info for a given cell, nil if not found.
    /// </summary>
    function GetGraphInfo(const i,j: integer) : TCallGraphInfo;
    /// <summary>
    /// Returns the info for a given cell and creates a new one if not found.
    /// </summary>
    function GetOrCreateGraphInfo(const i,j,threads: integer) : TCallGraphInfo;
    /// <summary>
    /// returns all the children for a given parent proc.
    /// NOTE: The dictionary just holds references and does not own the infos.
    /// </summary>
    procedure FillInChildrenForParentId(const aDict : TCallGraphInfoDict;const i : integer);
  end;


implementation

uses
  System.Sysutils;


{ TCallGraphInfo }

constructor TCallGraphInfo.Create(const aThreadCount: Integer);
var
  i : integer;
begin
  inherited Create();
  ProcTime := tProcTimeList.Create();
  ProcTimeMin := tProcTimeList.Create();
  ProcTimeMax := tProcTimeList.Create();
  ProcTimeAvg := tProcTimeList.Create();
  ProcChildTime:= tProcTimeList.Create();
  ProcCnt := tProcCountList.Create();

  ProcTime.Count := aThreadCount;
  ProcTimeMin.Count := aThreadCount;
  ProcTimeMax.Count := aThreadCount;
  ProcTimeAvg.Count := aThreadCount;
  ProcChildTime.Count := aThreadCount;
  ProcCnt.Count := aThreadCount;

  // procTimeMin starts with the high value and is assigned with
  // the first lower value.
  for I := 0 to ProcTimeMin.Count-1 do
    ProcTimeMin[i] := High(int64);
end;

destructor TCallGraphInfo.Destroy;
begin
  ProcTime.free;
  ProcTimeMin.free;
  ProcTimeMax.free;
  ProcTimeAvg.free;
  ProcChildTime.free;
  ProcCnt.free;
  inherited;
end;


function TCallGraphInfo.ToInfoString: string;

  procedure OutputList(const aBuilder : TStringBuilder;const aListName : string;const aList : TProcTimeList); overload;
  var
    i : integer;
  begin
    aBuilder.Append(' '+aListName);
    for i  := 0 to ProcTimeMin.Count-1 do
      aBuilder.Append(aList[i].ToString()+',');
    aBuilder.AppendLine();
  end;

  procedure OutputList(const aBuilder : TStringBuilder;const aListName : string;const aList : TList<Integer>);overload;
  var
    i : integer;
  begin
    aBuilder.Append(' '+aListName);
    for i  := 0 to ProcTimeMin.Count-1 do
      aBuilder.Append(aList[i].ToString()+',');
    aBuilder.AppendLine();
  end;

var
  LBuilder : TStringBuilder;
begin
  LBuilder := TStringBuilder.Create(512);
  LBuilder.AppendLine('CallGraphInfo:');

  OutputList(LBuilder,'ProcTime:', ProcTime);
  OutputList(LBuilder,'ProcChildTime:', ProcChildTime);
  OutputList(LBuilder,'ProcTimeMin:', ProcTimeMin);
  OutputList(LBuilder,'ProcTimeMax:', ProcTimeMax);
  OutputList(LBuilder,'ProcTimeAvg:', ProcTimeAvg);
  OutputList(LBuilder,'ProcCnt:', ProcCnt);
  result := LBuilder.ToString();
  LBuilder.free;
end;

{ TCallGraphKey }

constructor TCallGraphKey.Create(aParentId, aChildId: integer);
begin
  self.ParentProcId := aParentId;
  self.ProcId := aChildId;
end;

{ TCallGraphInfoDict }

function TCallGraphInfoDict.GetGraphInfo(const i,j: integer) : TCallGraphInfo;
var
  LKey : TCallGraphKey;
begin
  LKey := TCallGraphKey.Create(i,j);
  if not TryGetValue(LKey, result) then
    result := nil;
end;

procedure TCallGraphInfoDict.FillInChildrenForParentId(const aDict : TCallGraphInfoDict;const i: integer);
var
  LPair : TPair<TCallGraphKey, TCallGraphInfo>;
begin
  aDict.Clear();
  for LPair in self do
  begin
    if LPair.Key.ParentProcId = i then
      aDict.Add(LPair.Key,LPair.Value);
  end;
end;

function TCallGraphInfoDict.GetOrCreateGraphInfo(const i,j,threads: integer) : TCallGraphInfo;
var
  LKey : TCallGraphKey;
begin
  LKey := TCallGraphKey.Create(i,j);
  if not TryGetValue(LKey, result) then
  begin
    result := TCallGraphInfo.Create(threads+1);
    Add(LKey, result);
  end;
end;

{ tProcTimeList }

procedure tProcTimeList.AddTime(const anIndex : integer;const aValueToBeAdded: int64);
begin
  self[anIndex] := self[anIndex] + aValueToBeAdded;
  if anIndex <> 0 then
    self[0] := self[0] + aValueToBeAdded;
end;

procedure tProcTimeList.AssignTime(const anIndex: integer; const aValueToBeAssigned: int64);
var
  LOldValue : int64;
begin
  LOldValue := self[anIndex];
  self[anIndex] := aValueToBeAssigned;
  if anIndex <> 0 then
  begin
    // subtract the subtracted value and add the new to have the proper sum.
    self[0] := self[0] - LOldValue + aValueToBeAssigned;
  end;
end;

{ tProcCountList }

procedure tProcCountList.AddCount(const anIndex, aValueToBeAdded: integer);
begin
  self[anIndex] := self[anIndex] + aValueToBeAdded;
  if anIndex <> 0 then
    self[0] := self[0] + aValueToBeAdded;
end;



end.
