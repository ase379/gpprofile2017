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
  tProcTimeList = class(TList<uint64>)
  private
    fUseMaxAsDefault: boolean;
  public

    /// <summary>
    /// Adds a time to the given index.
    /// If the anIndex is not 0, the sum(index 0) is incremented as well.
    /// </summary>
    procedure AddTime(const aThreadId: Cardinal;const aValueToBeAdded: uint64);
    /// <summary>
    /// Set a time value for a given index.
    /// If the anIndex is not 0, the sum(index 0) is adjusted as well.
    /// </summary>
    procedure AssignTime(const aThreadId : Cardinal; const aValueToBeAssigned: uint64);

    property UseMaxAsDefault : Boolean read fUseMaxAsDefault write fUseMaxAsDefault;
  end;

  /// <summary>
  /// A list for counting the proc calls.
  /// The index is the thread number. 0 means "All Threads".
  /// </summary>
  tProcCountList = class(TList<Cardinal>)
  public
    /// <summary>
    /// Adds a count to the given index.
    /// If the anIndex is not 0, the sum(index 0) is incremented as well.
    /// </summary>
    procedure AddCount(const aThreadId : Cardinal;const aValueToBeAdded: Cardinal);

  end;

  tProcMemList = class(TList<Cardinal>)
  public
    /// <summary>
    /// Adds a memory state to the given index.
    /// If the anIndex is not 0, the sum(index 0) is incremented as well.
    /// </summary>
    procedure AddMem(const aThreadId: Cardinal;const aValueToBeAdded: Cardinal);
    /// <summary>
    /// Set a memory state value for a given index.
    /// If the anIndex is not 0, the sum(index 0) is adjusted as well.
    /// </summary>
    procedure AssignMem(const aThreadId : Cardinal; const aValueToBeAssigned: Cardinal);
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
    ProcMem      : tProcMemList; // 0 = sum
    constructor Create(const aThreadCount: Cardinal);
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
  TCallGraphInfoDict = class
  private
    fParentProcToInfoDict : TObjectDictionary<integer,TList<TCallGraphInfo>>;
    fDict : TObjectDictionary<TCallGraphKey,TCallGraphInfo>;
  public
    procedure initGraphInfos();
    procedure CalculateAverage();

    procedure Add(const aKey: TCallGraphKey; const aInfo : TCallGraphInfo);

    procedure Clear();
    /// <summary>
    /// Returns the info for a given parent and its child proc id, nil if not found.
    /// </summary>
    function GetGraphInfo(const aParentProcId,aProcId: integer) : TCallGraphInfo;

    /// <summary>
    /// returns all the children for a given parent proc.
    /// NOTE: The list just holds references and is cached internally, so it does not need to be freed.
    /// </summary>
    function GetGraphInfoForParentProcId(const aParentProcId: integer) : TList<TCallGraphInfo>;

    /// <summary>
    /// Returns the info for a given cell and creates a new one if not found.
    /// </summary>
    function GetOrCreateGraphInfo(const aParentProcId,aProcId,aThreadId: integer) : TCallGraphInfo;

    constructor Create();
    destructor Destroy; override;

  end;


implementation

uses
  System.Sysutils;


{ TCallGraphInfo }

constructor TCallGraphInfo.Create(const aThreadCount: Cardinal);
var
  i : integer;
begin
  inherited Create();
  ProcTime := tProcTimeList.Create();
  ProcTimeMin := tProcTimeList.Create();
  ProcTimeMin.UseMaxAsDefault := true;
  ProcTimeMax := tProcTimeList.Create();
  ProcTimeAvg := tProcTimeList.Create();
  ProcChildTime:= tProcTimeList.Create();
  ProcCnt := tProcCountList.Create();
  ProcMem := tProcMemList.Create();

  ProcTime.Count := aThreadCount;
  ProcTimeMin.Count := aThreadCount;
  ProcTimeMax.Count := aThreadCount;
  ProcTimeAvg.Count := aThreadCount;
  ProcChildTime.Count := aThreadCount;
  ProcCnt.Count := aThreadCount;
  ProcMem.Count := aThreadCount;

  // procTimeMin starts with the high value and is assigned with
  // the first lower value.
  for I := 0 to ProcTimeMin.Count-1 do
    ProcTimeMin[i] := High(uint64);
end;

destructor TCallGraphInfo.Destroy;
begin
  ProcTime.free;
  ProcTimeMin.free;
  ProcTimeMax.free;
  ProcTimeAvg.free;
  ProcChildTime.free;
  ProcCnt.free;
  ProcMem.Free;
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

  procedure OutputList(const aBuilder : TStringBuilder;const aListName : string;const aList : TList<Cardinal>);overload;
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

function TCallGraphInfoDict.GetGraphInfo(const aParentProcId,aProcId: integer) : TCallGraphInfo;
var
  LKey : TCallGraphKey;
begin
  LKey := TCallGraphKey.Create(aParentProcId,aProcId);
  if not fDict.TryGetValue(LKey, result) then
    result := nil;
end;

function TCallGraphInfoDict.GetGraphInfoForParentProcId(const aParentProcId: integer) : TList<TCallGraphInfo>;
begin
  if not fParentProcToInfoDict.TryGetValue(aParentProcId, result) then
    result := nil;
end;


procedure TCallGraphInfoDict.Add(const aKey: TCallGraphKey; const aInfo : TCallGraphInfo);
var
  LInfoListForParentProcId : TList<TCallGraphInfo>;
begin
  fDict.Add(aKey, aInfo);
  if not fParentProcToInfoDict.TryGetValue(aKey.ParentProcId, LInfoListForParentProcId) then
  begin
    LInfoListForParentProcId := TList<TCallGraphInfo>.Create();
    fParentProcToInfoDict.Add(aKey.ParentProcId, LInfoListForParentProcId);
  end;
  LInfoListForParentProcId.Add(aInfo);
end;

constructor TCallGraphInfoDict.Create;
begin
  fDict := TObjectDictionary<TCallGraphKey,TCallGraphInfo>.Create([doOwnsValues]);
  fParentProcToInfoDict := TObjectDictionary<integer,TList<TCallGraphInfo>>.Create([doOwnsValues]);
end;

destructor TCallGraphInfoDict.Destroy;
begin
  fDict.Free;
  fParentProcToInfoDict.Free;
  inherited;
end;

procedure TCallGraphInfoDict.Clear;
begin
  fDict.Clear();
  fParentProcToInfoDict.Clear;
end;

procedure TCallGraphInfoDict.initGraphInfos();
var
  LPair : TPair<TCallGraphKey, TCallGraphInfo>;
  LInfo : TCallGraphInfo;
begin
  for LPair in fDict do
  begin
    LInfo := LPair.Value;
    LInfo.ProcTime.Add(0);
    LInfo.ProcTimeMin.Add(High(uint64));
    LInfo.ProcTimeMax.Add(0);
    LInfo.ProcTimeAvg.Add(0);
    LInfo.ProcChildTime.Add(0);
    LInfo.ProcCnt.Add(0);
    LInfo.ProcMem.Add(0);
  end;
end;

procedure TCallGraphInfoDict.CalculateAverage();
var
  LPair : TPair<TCallGraphKey, TCallGraphInfo>;
  LInfo : TCallGraphInfo;
  LProcTimeAvgAllThreads : uint64;
  j : integer;
begin
  for LPair in fDict do
  begin
    // omitting i=0, cause its the total time
    if LPair.Key.ParentProcId = 0 then
      Continue;
    LInfo := LPair.Value;
    if assigned(LInfo) then
    begin
      // collect all avg times....
      LProcTimeAvgAllThreads := 0;
      for j := 0 + 1 to LInfo.ProcTime.count - 1 do
      begin
        if LInfo.ProcTimeMin[j] = High(uint64) then
          LInfo.ProcTimeMin[j] := 0;
        if LInfo.ProcCnt[j] = 0 then
          LInfo.ProcTimeAvg[j] := 0
        else
          LInfo.ProcTimeAvg[j] := LInfo.ProcTime[j] div LInfo.ProcCnt[j];
        LProcTimeAvgAllThreads := LProcTimeAvgAllThreads + LInfo.ProcTimeAvg[j];
      end;
      LInfo.ProcTimeAvg[0] := LProcTimeAvgAllThreads;
    end;

  end;
end;

function TCallGraphInfoDict.GetOrCreateGraphInfo(const aParentProcId,aProcId,aThreadId: integer) : TCallGraphInfo;
var
  LKey : TCallGraphKey;
begin
  LKey := TCallGraphKey.Create(aParentProcId,aProcId);
  if not fDict.TryGetValue(LKey, result) then
  begin
    result := TCallGraphInfo.Create(aThreadId+1);
    Add(LKey, result);
  end;
end;

{ tProcTimeList }

procedure tProcTimeList.AddTime(const aThreadId : Cardinal;const aValueToBeAdded: uint64);
begin
  if aThreadId = 0 then
    raise Exception.Create('FehlermtProcTimeList.AddTime: ThreadId 0 is not allowed.');
  self[0] := self[0] + aValueToBeAdded;
  self[aThreadId] := self[aThreadId] + aValueToBeAdded;
end;

procedure tProcTimeList.AssignTime(const aThreadId: Cardinal; const aValueToBeAssigned: uint64);
begin
  if aThreadId = 0 then
    raise Exception.Create('FehlermtProcTimeList.AssignTime: ThreadId 0 is not allowed.');
  self[0] := aValueToBeAssigned;
  self[aThreadId] := aValueToBeAssigned;
end;

{ tProcCountList }

procedure tProcCountList.AddCount(const aThreadId, aValueToBeAdded: Cardinal);
begin
  if aThreadId = 0 then
    raise Exception.Create('tProcCountList.AddCount: ThreadId 0 is not allowed.');
  self[0] := self[0] + aValueToBeAdded;
  self[aThreadId] := self[aThreadId] + aValueToBeAdded;
end;



{ tProcMemList }

procedure tProcMemList.AddMem(const aThreadId, aValueToBeAdded: Cardinal);
begin
   if aThreadId = 0 then
    raise Exception.Create('tProcMemList.AddMem: ThreadId 0 is not allowed.');
  self[0] := self[0] + aValueToBeAdded;
  self[aThreadId] := self[aThreadId] + aValueToBeAdded;
end;

procedure tProcMemList.AssignMem(const aThreadId, aValueToBeAssigned: Cardinal);
begin
  if aThreadId = 0 then
    raise Exception.Create('tProcMemList.AssignMem: ThreadId 0 is not allowed.');
  self[0] := aValueToBeAssigned;
  self[aThreadId] := aValueToBeAssigned;
end;

end.
