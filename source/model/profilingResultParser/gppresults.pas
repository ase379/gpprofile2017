{$R-,I-,Q-.S-,O+}

unit gppResults;

interface

uses
  Windows,
  GpHugeF,
  System.Generics.Collections,
  gppResults.procs,
  gppResults.callGraph,
  gppResults.memGraph,
  gppResults.types,
  gppResult.measurePointRegistry;

type
  TProgressCallback = function (percent: integer): boolean of object;


  TThreadEntry = record
  private
    function GetName: String;
  public
    teThread     : integer;
    teName       : AnsiString;
    teTotalTime  : int64;
    teTotalCnt   : integer;
    teActiveProcs: TActiveProcList;

    property Name : String read GetName;
  end;

  TUnitEntry = record
  private
    function GetPath: String;
    function GetName: String;
  public
    ueName     : AnsiString;
    ueQual     : AnsiString;
    ueTotalTime: array {thread} of int64;   // 0 = sum
    ueTotalCnt : array {thread} of integer; // 0 = sum

    property FilePath : String read GetPath;
    property Name : String read GetName;
  end;

  TClassEntry = record
  private
    function GetName: String;
  public
    ceName     : AnsiString;
    ceUID      : integer;
    ceFirstLn  : integer;
    ceTotalTime: array {thread} of int64;   // 0 = sum
    ceTotalCnt : array {thread} of integer; // 0 = sum

    property Name : String read GetName;
  end;

  TResults = class
  private
    resFile           : TGpHugeFile;
    resName           : String;
    resProcSize       : integer;
    resOldTicks       : int64;
    resThreadBytes    : integer;
    resCompressTicks  : boolean;
    resCompressThreads: boolean;
    resPrfVersion     : integer;
    resNullOverhead   : int64;
    resNullError      : integer;
    resNullErrorAcc   : integer;
    resPrfDigest      : boolean;
    resCalibrCnt      : integer;
    resCurCalibr      : integer;
    resCalibration    : boolean;
    resCalPkt         : TResPacket;
    resCalDTime       : int64;
    resCalTime        : int64;
    resCalTime2       : int64;
    resCalMax         : int64;
    resCalCounter     : integer;
    fMeasurePointRegistry : TMeasurePointRegistry;
    procedure   RaiseFileCorruptedException(const aContext : String);

    procedure   CalibrationStep(pkt1, pkt2: TResPacket);
    procedure   ExitProcPkt(const pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   EnterProcPkt(const pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   ExitMeasurePointPkt(pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   EnterMeasurePointPkt(pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   LoadHeader;
    procedure   LoadTables;
    procedure   LoadCalibration;
    procedure   LoadData(callback: TProgressCallback);
    procedure   LoadThreadInformation();
    procedure   LoadDigest(callback: TProgressCallback);
    procedure   ReadString(var str: AnsiString);
    procedure   ReadShortstring(var str: AnsiString);
    procedure   ReadInt(var int: integer);
    procedure   ReadCardinal(var value: Cardinal);
    procedure   ReadAnsiString(var avalue : AnsiString);
    procedure   ReadInt64(var i64: int64);
    procedure   ReadUInt64(var ui64: uint64);
    procedure   ReadBool(var bool: boolean);
    procedure   ReadTag(var tag: byte);
    procedure   ReadThread(var thread: integer);
    procedure   ReadTicks(var ticks: int64);
    procedure   ReadID(var id: integer);
    procedure   WriteTag(tag: byte);
    procedure   WriteInt(int: integer);
    procedure   WriteCardinal  (uint: Cardinal);
    procedure   WriteInt64(i64: int64);
    procedure   WriteString(str: ansistring);
    procedure   CheckTag(tag: byte);
    function    ReadPacket(var pkt: TResPacket; var pktMem: TResMemPacket): boolean;
    procedure   UpdateRunningTime(proxy,parent: TProcProxy);
    function    ThCreateLocate(thread: integer): integer;
    function    ThCreate(thread: integer): integer;
    function    ThLocate(thread: integer): integer;
    procedure   EnterProc(const proxy: TProcProxy; pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   ExitProc(const proxy,parent: TProcProxy; pkt: TResPacket; const mempkt: TResMemPacket);
  public
    resThreads   : array of TThreadEntry;
    resUnits     : array of TUnitEntry;
    resClasses   : array of TClassEntry;
    resProcedures: TArray<TProcEntry>;
    fCallGraphInfoDict : TCallGraphInfoDict;
    fCallGraphInfoMaxElementCount : Integer;
    /// <summary>
    /// the calls for the mem stack
    /// </summary>
    fProcedureMemCallList : TProcedureMemCallList;

    resFrequency : int64;
    constructor Create(fileName: string; callback: TProgressCallback); overload;
    constructor Create; overload;
    destructor  Destroy; override;
    procedure   AssignTables(tableFile: string);
    function    IsMemProfilingEnabled: boolean;
    procedure   AddEnterProc(pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   AddExitProc(pkt: TResPacket; const mempkt: TResMemPacket);
    procedure   StartCalibration(calibCnt: integer);
    procedure   StopCalibration;
    procedure   RecalcTimes;
    /// <summary>
    /// Writes a digest (compressed) version of the given prf file. If the conversion is sucessfull, the prf will
    /// be replaced. Else the prf will stay as it is.
    /// </summary>
    procedure   SaveDigest(const aPrfFileName: string; callback: TProgressCallback);
    procedure   Rename(fileName: string);
    property    FileName: String read resName;
    property    Version: integer read resPrfVersion;
    property    IsDigest: boolean read resPrfDigest;
    property    CallGraphInfo: TCallGraphInfoDict read fCallGraphInfoDict;
    property    CallGraphInfoCount: integer read fCallGraphInfoMaxElementCount;
    property    ProcedureMemCallList: TProcedureMemCallList read fProcedureMemCallList;
  end;

implementation

uses
  Forms,
  System.IOUtils,
  System.SysUtils,
  GpProfH,
  gppResults.procArrayTools,
  gppCommon;


{ TResults }

constructor TResults.Create;
begin
  inherited Create;
  SetLength(resThreads,1);
  resThreads[0].teThread      := 0; // impossible handle
  resThreads[0].teActiveProcs := nil;
  resOldTicks        := -1;
  resThreadBytes     := 1;
  resCompressTicks   := false;
  resCompressThreads := false;
  resPrfVersion      := 0;
  resPrfDigest       := false;
  resNullOverhead    := 0;
  resNullError       := 0;
  resNullErrorAcc    := 0;
  // dictionary owning the values; all sub dicts are just refs
  fCallGraphInfoDict := TCallGraphInfoDict.Create();
  fProcedureMemCallList := TProcedureMemCallList.Create();
  fMeasurePointRegistry := TMeasurePointRegistry.Create();
end; { TResults.Create }

constructor TResults.Create(fileName: String; callback: TProgressCallback);
begin
  Create();
  resName := fileName;
  resFile := TGpHugeFile.CreateEx(resName,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.ResetBuffered(1, 4*1024*1024);
  try
    LoadHeader;
    if IsDigest then
      LoadDigest(callback)
    else
    begin
      LoadTables;
      if Version > 2 then LoadCalibration;
      LoadData(callback);
      LoadThreadInformation();
      RecalcTimes;
    end;
  finally
    resFile.Free;
  end;
end; { TResults.Create }

destructor TResults.Destroy;
var
  i: integer;
begin
  fMeasurePointRegistry.free;
  fCallGraphInfoDict.free;
  fProcedureMemCallList.free;
  for i := Low(resThreads) to High(resThreads) do
    resThreads[i].teActiveProcs.Free;
  inherited Destroy;
end; { TResults.Destroy }

procedure TResults.ReadInt  (var int: integer);  begin resFile.BlockReadUnsafe(int,SizeOf(integer)); end;
procedure TResults.ReadCardinal(var value: Cardinal);  begin resFile.BlockReadUnsafe(value,SizeOf(Cardinal)); end;
procedure TResults.ReadInt64(var i64: int64);    begin resFile.BlockReadUnsafe(i64,SizeOf(int64)); end;
procedure TResults.ReadUInt64(var ui64: uint64);    begin resFile.BlockReadUnsafe(ui64,SizeOf(uint64)); end;
procedure TResults.ReadTag  (var tag: byte);     begin resFile.BlockReadUnsafe(tag,SizeOf(byte)); end;
procedure TResults.ReadID   (var id: integer);   begin id := 0; resFile.BlockReadUnsafe(id,resProcSize); end;
procedure TResults.ReadAnsiString(var avalue: AnsiString);
var LLength : Cardinal;
begin
  ReadCardinal(LLength);
  SetLength(AValue, LLength);
  if LLength > 0 then
    resFile.BlockReadUnsafe(AValue[1],LLength);
end;


procedure TResults.ReadBool (var bool: boolean); begin resFile.BlockReadUnsafe(bool,1); end;

procedure TResults.ReadTicks(var ticks: int64);
type
  TTick = array [1..8] of byte;
var
  count: byte;
begin
  if not resCompressTicks then resFile.BlockReadUnsafe(ticks,SizeOf(ticks))
  else begin
    ticks := resOldTicks;
    resFile.BlockReadUnsafe(count,1);
    resFile.BlockReadUnsafe(ticks,count);
    resOldTicks := ticks;
  end;
end; { TResults.ReadTicks }

procedure TResults.ReadThread(var thread: integer);
begin
  if not resCompressThreads then resFile.BlockReadUnsafe(thread,SizeOf(thread))
  else begin
    thread := 0;
    resFile.BlockReadUnsafe(thread,resThreadBytes);
    if thread = 0 then begin
      Inc(resThreadBytes);
      resFile.BlockReadUnsafe(thread,resThreadBytes);
    end;
  end;
end; { TResults.ReadThread }

procedure TResults.ReadShortstring(var str: AnsiString);
var
  s: shortstring;
begin
  resFile.BlockReadUnsafe(s[0],1);
  resFile.BlockReadUnsafe(s[1],Ord(s[0]));
  str := s;
end; { TResults.ReadShortstring }

procedure TResults.ReadString(var str: AnsiString);
var
  len: integer;
begin
  ReadInt(len);
  SetLength(str,len);
  if len > 0 then
    resFile.BlockReadUnsafe(str[1],len+1); // read zero-termination char too
end; { TResults.ReadString }

procedure TResults.WriteTag  (tag: byte);    begin resFile.BlockWriteUnsafe(tag,SizeOf(byte)); end;
procedure TResults.WriteInt  (int: integer); begin resFile.BlockWriteUnsafe(int,SizeOf(integer)); end;
procedure TResults.WriteCardinal  (uint: Cardinal); begin resFile.BlockWriteUnsafe(uint,SizeOf(Cardinal)); end;
procedure TResults.WriteInt64(i64: int64);   begin resFile.BlockWriteUnsafe(i64,SizeOf(int64)); end;

procedure TResults.WriteString(str: ansistring);
begin
  WriteInt(Length(str));
  if Length(str) > 0 then
    resFile.BlockWriteUnsafe(str[1],Length(str)+1); // write zero-terminated
end; { TResults.WriteString }

procedure TResults.RaiseFileCorruptedException(const aContext : String);
begin
  raise Exception.Create('File corrupted: '+aContext);
end;

procedure TResults.CheckTag(tag: byte);
var
  fileTag: byte;
begin
  ReadTag(fileTag);
  if tag <> fileTag then
    RaiseFileCorruptedException('Expected Tag '+tag.ToString+', but found tag '+filetag.ToString+'!');
end; { TResults.CheckTag }

procedure TResults.LoadTables;
var
  i     : integer;
  lNumberOfUnits: integer;
  lNumberOfClasses: integer;
  lNumberOfProcs: integer;
begin
  CheckTag(PR_UNITTABLE);
  ReadInt(lNumberOfUnits);
  SetLength(resUnits,lNumberOfUnits+1);      // resUnits[0] = Sum(resUnits[1:])
  for i := 1 to lNumberOfUnits do begin
    with resUnits[i] do begin
      if Version >= 4 then ReadString(ueName)
                      else ReadShortstring(ueName);
      if      Version >= 4 then ReadString(ueQual)
      else if Version > 1  then ReadShortstring(ueQual)
                           else ueQual := '';
      SetLength(ueTotalTime,1);        // placeholder for a summary entry
      SetLength(ueTotalCnt,1);
    end;
  end;
  CheckTag(PR_CLASSTABLE);
  ReadInt(lNumberOfClasses);
  SetLength(resClasses,lNumberOfClasses+1);    // resClasses[0] = Sum(resClasses[1:])
  for i := 1 to lNumberOfClasses do begin
    with resClasses[i] do begin
      if Version >= 4 then ReadString(ceName)
                      else ReadShortstring(ceName);
      if Version > 1 then ReadInt(ceUID)
                     else ceUID := -1;
      ceFirstLn := MaxLongint;
      SetLength(ceTotalTime,1);        // placeholder for a summary entry
      SetLength(ceTotalCnt,1);
    end;
  end;
  CheckTag(PR_PROCTABLE);
  ReadInt(lNumberOfProcs);
  SetLength(resProcedures,lNumberOfProcs+1); // resProcedures[0] = Sum(resProcedures[1:])
  for i := 1 to lNumberOfProcs do begin
    with resProcedures[i] do begin
      if Version >= 4 then ReadString(peName)
                      else ReadShortstring(peName);
      ReadInt(peUID);
      ReadInt(peCID);
      if Version > 1 then begin
        ReadInt(peFirstLn);
        if peFirstLn < resClasses[peCID].ceFirstLn then
          resClasses[peCID].ceFirstLn := peFirstLn;
      end
      else peFirstLn := -1;
      SetLength(peProcTime,1);         // placeholder for a summary entry
      SetLength(peProcTimeMin,1);      // placeholder for a unused entry
      SetLength(peProcTimeMax,1);      // placeholder for a unused entry
      SetLength(peProcTimeAvg,1);      // placeholder for a unused entry
      SetLength(peProcChildTime,1);    // placeholder for a summary entry
      SetLength(peProcCnt,1);          // placeholder for a summary entry
      SetLength(peCurrentCallDepth,1);         // placeholder for a unused entry
    end;
  end;
  fCallGraphInfoDict.Clear;
  fProcedureMemCallList.Clear();
  // max number elements is (elements+1)*(elements+1): 1 child per parent.
  fCallGraphInfoMaxElementCount := lNumberOfProcs;
  for i := 1 to High(resClasses) do
    with resClasses[i] do
      if ceFirstLn = MaxLongint then ceFirstLn := -1;
end;

{ TResult.LoadTables }

procedure TResults.LoadData(callback: TProgressCallback);
var
  pkt     : TResPacket;
  mempkt  : TResMemPacket;
  curPerc : integer;
  lastPerc: integer;
  filesz  : int64;
  fpstart : int64;
  cnt     : integer;
begin
  pkt := default(TResPacket);
  mempkt := default(TResMemPacket);
  cnt      := 0;
  fpstart  := resFile.FilePos;
  filesz   := resFile.FileSize;
  lastPerc := -1;
  CheckTag(PR_STARTDATA);
  while ReadPacket(pkt, mempkt) do
  begin
    Inc(cnt);
    if (cnt mod REPORT_EVERY) = 0 then
    begin
      Application.ProcessMessages;
      if @callback <> nil then begin
        curPerc := Round((resFile.FilePos-fpstart)/filesz*100);
        if curPerc <> lastPerc then begin
          lastPerc := curPerc;
          if not callback(curPerc) then break;
        end;
      end;
    end;
    if pkt.rpTag = PR_ENTERPROC then
    begin
        // create new procedure proxy object
      EnterProcPkt(pkt, mempkt);
    end
    else if pkt.rpTag = PR_EXITPROC then
    begin
      // find last proxy object with matching prProcID in active procedure queue
      // update relevant objects
      // destroy proxy object
      ExitProcPkt(pkt, mempkt)
    end
    else if pkt.rpTag = PR_ENTER_MP then
    begin
        // create new measure point proxy object
      EnterMeasurePointPkt(pkt, mempkt);
    end
    else if pkt.rpTag = PR_EXIT_MP then
    begin
      // find last proxy object with matching prProcID in active procedure queue
      // update relevant objects
      // destroy proxy object
      ExitMeasurePointPkt(pkt, mempkt);
    end
    else 
      raise Exception.Create('gppResults.TResults.LoadData: Invalid tag ('+pkt.rpTag.ToString()+').');
  end;
end; { TResults.LoadData }

procedure TResults.LoadThreadInformation;
var LTag : byte;
    LPos : HugeInt;
    LElementCount : Cardinal;
    LThreadID : Cardinal;
    LThreadName : AnsiString;
    i : cardinal;
    k : integer;
begin
  LPos := resFile.FilePos;
  if LPos = resFile.FileSize then
    exit;
  ReadTag(LTag);
  if LTag <> PR_START_THREADINFO then
  begin
    resFile.Seek(LPos);
    exit;
  end;
  ReadCardinal(LElementCount);
  if LElementCount > 0 then
  begin
    for i := 0 to LElementCount-1 do
    begin
      ReadCardinal(LThreadID);
      ReadAnsiString(LThreadName);
      k := ThLocate(LThreadID);
      if k <> -1 then
      begin
        if Length(resThreads[k].teName) > 0 then
          resThreads[k].teName := resThreads[k].teName + '; ';
        resThreads[k].teName := resThreads[k].teName + LThreadName;
      end;
    end;
  end;
  ReadTag(LTag);
  if lTag <> PR_END_THREADINFO then
    raise Exception.Create('Found PR_START_THREADINFO without PR_END_THREADINFO');
end; { TResults.LoadThreadInformation }


procedure TResults.EnterProcPkt(const pkt: TResPacket; const mempkt: TResMemPacket);
var
  proxy: TProcProxy;
begin
  if IsMemProfilingEnabled then
    proxy := TProcWithMemProxy.Create(ThCreateLocate(pkt.rpThread),pkt.rpProcID)
  else
    proxy := TProcProxy.Create(ThCreateLocate(pkt.rpThread),pkt.rpProcID);
  EnterProc(proxy,pkt, mempkt);
end; { TResults.EnterProcPkt }

procedure TResults.ExitProcPkt(const pkt: TResPacket; const mempkt: TResMemPacket);
var
  proxy : TProcProxy;
  parent: TProcProxy;
begin
  const tid = ThLocate(pkt.rpThread);
  if (tid >= 0) and (resThreads[tid].teActiveProcs <> nil) then
  begin
    resThreads[tid].teActiveProcs.LocateLast(pkt.rpProcID,proxy,parent);
    if proxy = nil then
      raise Exception.Create('gppResults.TResults.ExitProcPkt: Entry not found!');
    ExitProc(proxy,parent,pkt,mempkt);
    proxy.free;
    inherited;
  end;
end; { TResults.ExitProcPkt }

procedure TResults.EnterMeasurePointPkt(pkt: TResPacket; const mempkt: TResMemPacket);
var
  proxy: TProcProxy;
  lThreadId : Cardinal;
begin
  lThreadId := ThCreateLocate(pkt.rpThread);
  pkt.rpProcID := Length(resProcedures);
  if IsMemProfilingEnabled then
    proxy := TMeasurePointWithMemProxy.Create(lThreadId,pkt.rpProcID,pkt.rpMeasurePointID)
  else
    proxy := TMeasurePointProxy.Create(lThreadId,pkt.rpProcID,pkt.rpMeasurePointID);
  fMeasurePointRegistry.RegisterMeasurePoint(pkt.rpProcId, pkt.rpMeasurePointID);
  inc(fCallGraphInfoMaxElementCount);

  // the measure point needs to be inserted into the known procedures
  TProcArrayTools.AddProcRow(resProcedures, pkt.rpMeasurePointID, pkt.rpProcID, Length(resThreads));
  EnterProc(proxy,pkt, mempkt);
end; { TResults.EnterMeasurePointPkt }


procedure TResults.ExitMeasurePointPkt(pkt: TResPacket; const mempkt: TResMemPacket);
var
  lLastMeasurePointEntry : TMeasurePointRegistryEntry;
begin
  lLastMeasurePointEntry := fMeasurePointRegistry.GetMeasurePointEntry(pkt.rpMeasurePointID);

  pkt.rpProcID := lLastMeasurePointEntry.ProcId;
  ExitProcPkt(pkt, mempkt);
  inherited;
  fMeasurePointRegistry.UnRegisterMeasurePoint(pkt.rpMeasurePointID);

end; { TResults.ExitMeasurePointPkt }


procedure TResults.AddEnterProc(pkt: TResPacket; const mempkt: TResMemPacket);
begin
  if resCalibration
    then Move(pkt,resCalPkt,SizeOf(TResPacket))
    else EnterProcPkt(pkt, mempkt);
end; { TResults.AddEnterProc }

procedure TResults.AddExitProc(pkt: TResPacket; const mempkt: TResMemPacket);
begin
  if resCalibration
    then CalibrationStep(resCalPkt,pkt)
    else ExitProcPkt(pkt, mempkt);
end; { TResults.AddExitProc }

function TResults.IsMemProfilingEnabled: boolean;
begin
  result := resPrfVersion = PRF_VERSION_WITH_MEM;
end;

function TResults.ReadPacket(var pkt: TResPacket; var pktMem: TResMemPacket): boolean;
var
  lAnsiMeasurePointId : ansistring;
begin
  with pkt do begin
    ReadTag(rpTag);
    if (rpTag = PR_ENDDATA) or (rpTag = PR_ENDCALIB) then
      Result := false
    else if (rpTag = PR_ENTER_MP) or (rpTag = PR_EXIT_MP) then
    begin
      rpProcID := -1;
      ReadThread(rpThread);
      ReadAnsiString(lAnsiMeasurePointId);
      rpMeasurePointID := utf8ToString(lAnsiMeasurePointId);
      ReadTicks(rpMeasure1);
      if IsMemProfilingEnabled then
        ReadCardinal(pktMem.rpMemWorkingSize);
      ReadTicks(rpMeasure2);
      Result := true;
    end
    else
    begin
      ReadThread(rpThread);
      ReadID(rpProcID);
      ReadTicks(rpMeasure1);
      if IsMemProfilingEnabled then
        if (rpTag = PR_ENTERPROC) or (rpTag = PR_EXITPROC) then
          ReadCardinal(pktMem.rpMemWorkingSize);
      ReadTicks(rpMeasure2);
      Result := true;
    end;
  end;
end; { TResults.ReadPacket }

procedure TResults.LoadHeader;
var
  tag: byte;
  lDigestVersion : integer;
begin
  repeat
    ReadTag(tag);
    case tag of
      PR_PRFVERSION : ReadInt(resPrfVersion);
      PR_FREQUENCY  : ReadTicks(resFrequency);
      PR_PROCSIZE   : ReadInt(resProcSize);
      PR_COMPTICKS  : ReadBool(resCompressTicks);
      PR_COMPTHREADS: ReadBool(resCompressThreads);
      PR_DIGEST     : resPrfDigest := true;
      PR_DIGESTVER  : ReadInt(lDigestVersion);
    end;
  until tag = PR_ENDHEADER;
end; { TResults.LoadHeader }

procedure TResults.UpdateRunningTime(proxy,parent: TProcProxy);
var
  LInfo : TCallGraphInfo;
  LThreadID : integer;
begin
  LThreadID := proxy.ThreadID;
  // update resProcedures, resActiveProcs, and CallGraph
  // other structures will be recalculated at the end
  if assigned(parent) then
    parent.ChildTime := parent.ChildTime + proxy.TotalTime + proxy.ChildTime;
  Inc(resProcedures[proxy.ProcID].peProcTime[LThreadID],proxy.TotalTime);
  if proxy.TotalTime < resProcedures[proxy.ProcID].peProcTimeMin[LThreadID] then
    resProcedures[proxy.ProcID].peProcTimeMin[LThreadID] := proxy.TotalTime;
  if proxy.TotalTime > resProcedures[proxy.ProcID].peProcTimeMax[LThreadID] then
    resProcedures[proxy.ProcID].peProcTimeMax[LThreadID] := proxy.TotalTime;
  if resProcedures[proxy.ProcID].peCurrentCallDepth[LThreadID] = 0 then
  begin
    Inc(resProcedures[proxy.ProcID].peProcChildTime[LThreadID],proxy.ChildTime);
    Inc(resProcedures[proxy.ProcID].peProcChildTime[LThreadID],proxy.TotalTime);
  end;
  Inc(resProcedures[proxy.ProcID].peProcCnt[LThreadID],1);

  // update all callstack related data.
  if assigned(parent) then
  begin
    // assemble callstack information
    LInfo := fCallGraphInfoDict.GetOrCreateGraphInfo(parent.ProcID,proxy.ProcID,High(resThreads));

    LInfo.ProcTime.AddTime(LThreadID,proxy.TotalTime);
    if proxy.TotalTime < LInfo.ProcTimeMin[LThreadID] then
      LInfo.ProcTimeMin.AssignTime(LThreadID,proxy.TotalTime);
    if proxy.TotalTime > LInfo.ProcTimeMax[LThreadID] then
      LInfo.ProcTimeMax.AssignTime(LThreadID, proxy.TotalTime);
    if resProcedures[proxy.ProcID].peCurrentCallDepth[LThreadID] = 0 then
    begin
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ChildTime);
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.TotalTime);
    end
    else if (resProcedures[proxy.ProcID].peCurrentCallDepth[LThreadID] = 1) and
            (parent.ProcID = proxy.ProcID) then
    begin
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ChildTime);
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.TotalTime);
    end;
    LInfo.ProcCnt.AddCount(LThreadID,1);
  end;
end; { TResults.UpdateRunningTime }

function TResults.ThCreateLocate(thread: integer): integer;
begin
  Result := ThLocate(thread);
  if Result < 0 then Result := ThCreate(thread);
end; { TResults.ThCreateLocate }

function TResults.ThLocate(thread: integer): integer;
var
  i: integer;
begin
  Result := -1;
  for i := Low(resThreads) to High(resThreads) do begin
    if resThreads[i].teThread = thread then begin
      Result := i;
      Exit;
    end;
  end;
end; { TResults.ThLocate }

function TResults.ThCreate(thread: integer): integer;
var
  numth: integer;
begin
  numth := High(resThreads)+1;
  SetLength(resThreads,numth+1);
  Inc(numth);
  with resThreads[numth-1] do begin
    teThread      := thread;
    teName        := '';
    teActiveProcs := TActiveProcList.Create;
  end;
  // resize resProcedures
  TProcArrayTools.AddThreadToExistsingProcRows(resProcedures, numth);
  // resize fCallGraphInfoDict
  fCallGraphInfoDict.initGraphInfos();
  Result := numth-1;
end; { TResults.ThCreate }

procedure TResults.RecalcTimes;
var
  i,j: integer;
  numth: integer;
  LInfo : TCallGraphInfo;
  LInfoChild : TCallGraphInfo;
  LChildrenDict : TCallGraphInfoDict;
  lThreadIndex : integer;
begin
  numth := High(resThreads);
  // resize resUnits and resClasses
  for i := Low(resUnits) to High(resUnits) do begin
    with resUnits[i] do begin
      SetLength(ueTotalTime,numth+1);
      SetLength(ueTotalCnt,numth+1);
    end;
  end;
  for i := Low(resClasses) to High(resClasses) do begin
    with resClasses[i] do begin
      SetLength(ceTotalTime,numth+1);
      SetLength(ceTotalCnt,numth+1);
    end;
  end;
  // resProcedures
  for i := Low(resProcedures)+1 to High(resProcedures) do begin
    with resProcedures[i] do begin
      peProcTime[Low(peProcTime)] := 0;
      peProcChildTime[Low(peProcChildTime)] := 0;
      if (not IsDigest) then
      begin
        peProcTimeMin[Low(peProcTIme)] := High(uint64);
        peProcTimeMax[Low(peProcTIme)] := 0;
      end;
      for j := Low(peProcTime)+1 to High(peProcTime) do begin
        if peProcCnt[j] > 0 then begin
          if peProcTimeMin[j] < peProcTimeMin[Low(peProcTime)] then
            peProcTimeMin[Low(peProcTIme)] := peProcTimeMin[j];
          if peProcTimeMax[j] > peProcTimeMax[Low(peProcTime)] then
            peProcTimeMax[Low(peProcTIme)] := peProcTimeMax[j];
        end;
        Inc(peProcTime[Low(peProcTime)],peProcTime[j]);
        if peProcTimeMin[j] = High(uint64) then
          peProcTimeMin[j] := 0;
        Inc(peProcChildTime[Low(peProcTime)],peProcChildTime[j]);
        Inc(peProcCnt[Low(peProcCnt)],peProcCnt[j]);
        Inc(resClasses[peCID].ceTotalTime[j],peProcTime[j]);
        Inc(resClasses[peCID].ceTotalCnt[j],peProcCnt[j]);
        Inc(resUnits[peUID].ueTotalTime[j],peProcTime[j]);
        Inc(resUnits[peUID].ueTotalCnt[j],peProcCnt[j]);
        if peProcCnt[j] = 0 then peProcTimeAvg[j] := 0
                            else peProcTimeAvg[j] := peProcTime[j] div peProcCnt[j];
      end;
      if peProcTimeMin[Low(peProcTime)] = High(uint64) then
        peProcTimeMin[Low(peProcTime)] := 0;
      if peProcCnt[Low(peProcTime)] = 0
        then peProcTimeAvg[Low(peProcTime)] := 0
        else peProcTimeAvg[Low(peProcTime)] := peProcTime[Low(peProcTime)] div peProcCnt[Low(peProcTime)];
    end;
  end;
  for j := Low(resProcedures[Low(resProcedures)].peProcTime) to High(resProcedures[Low(resProcedures)].peProcTime) do begin
    resProcedures[Low(resProcedures)].peProcTime[j]      := 0;
    resProcedures[Low(resProcedures)].peProcChildTime[j] := 0;
    resProcedures[Low(resProcedures)].peProcCnt[j]       := 0;
    for i := Low(resProcedures)+1 to High(resProcedures) do begin
      Inc(resProcedures[Low(resProcedures)].peProcTime[j],resProcedures[i].peProcTime[j]);
      Inc(resProcedures[Low(resProcedures)].peProcChildTime[j],resProcedures[i].peProcChildTime[j]);
      Inc(resProcedures[Low(resProcedures)].peProcCnt[j],resProcedures[i].peProcCnt[j]);
    end;
  end;
  // resClasses
  for i := Low(resClasses)+1 to High(resClasses) do begin
    with resClasses[i] do begin
      ceTotalTime[Low(ceTotalTime)] := 0;
      ceTotalCnt[Low(ceTotalCnt)]   := 0;
      for j := Low(ceTotalTime)+1 to High(ceTotalTime) do begin
        Inc(ceTotalTime[Low(ceTotalTime)],ceTotalTime[j]);
        Inc(ceTotalCnt[Low(ceTotalCnt)],ceTotalCnt[j]);
      end;
    end;
  end;
  for j := Low(resClasses[Low(resClasses)].ceTotalTime) to High(resClasses[Low(resClasses)].ceTotalTime) do begin
    resClasses[Low(resClasses)].ceTotalTime[j] := 0;
    resClasses[Low(resClasses)].ceTotalCnt[j]  := 0;
    for i := Low(resClasses)+1 to High(resClasses) do begin
      Inc(resClasses[Low(resClasses)].ceTotalTime[j],resClasses[i].ceTotalTime[j]);
      Inc(resClasses[Low(resClasses)].ceTotalCnt[j],resClasses[i].ceTotalCnt[j]);
    end;
  end;
  // resUnits
  for i := Low(resUnits)+1 to High(resUnits) do begin
    with resUnits[i] do begin
      ueTotalTime[Low(ueTotalTime)] := 0;
      ueTotalCnt[Low(ueTotalTime)]  := 0;
      for j := Low(ueTotalTime)+1 to High(ueTotalTime) do begin
        Inc(ueTotalTime[Low(ueTotalTime)],ueTotalTime[j]);
        Inc(ueTotalCnt[Low(ueTotalCnt)],ueTotalCnt[j]);
      end;
    end;
  end;
  for j := Low(resUnits[Low(resUnits)].ueTotalTime) to High(resUnits[Low(resUnits)].ueTotalTime) do begin
    resUnits[Low(resUnits)].ueTotalTime[j] := 0;
    resUnits[Low(resUnits)].ueTotalCnt[j]  := 0;
    for i := Low(resUnits)+1 to High(resUnits) do begin
      Inc(resUnits[Low(resUnits)].ueTotalTime[j],resUnits[i].ueTotalTime[j]);
      Inc(resUnits[Low(resUnits)].ueTotalCnt[j],resUnits[i].ueTotalCnt[j]);
    end;
  end;
  // resThreads
  resThreads[Low(resThreads)].teTotalTime := 0;
  resThreads[Low(resThreads)].teTotalCnt := 0;
  for i := Low(resThreads)+1 to High(resThreads) do begin
    resThreads[i].teTotalTime := resUnits[Low(resUnits)].ueTotalTime[i];
    resThreads[i].teTotalCnt  := resUnits[Low(resUnits)].ueTotalCnt[i];
    Inc(resThreads[Low(resThreads)].teTotalTime,resThreads[i].teTotalTime);
    Inc(resThreads[Low(resThreads)].teTotalCnt,resThreads[i].teTotalCnt);
  end;

  // fCallGraphInfoDict: calculate average and min time
  fCallGraphInfoDict.CalculateAverage();

  // fCallGraphInfo: calculate proc time for each thread
  LChildrenDict := TCallGraphInfoDict.Create();
  for i := 1 to fCallGraphInfoMaxElementCount do
  begin
    LInfo := fCallGraphInfoDict.GetOrCreateGraphInfo(i,0,High(resThreads));
    LInfo.ProcTime[0] := 0;
    for lThreadIndex := Low(resThreads) + 1 to High(resThreads) do
    begin
      LInfo.ProcTime[lThreadIndex] := 0;
      var lList := fCallGraphInfoDict.GetGraphInfoForParentProcId(i);
      for LInfoChild in lList do
      begin
        if assigned(LInfoChild) then
        begin
          LInfo.ProcTime[lThreadIndex] := LInfo.ProcTime[lThreadIndex] + LInfoChild.ProcTime[lThreadIndex];
          LInfo.ProcTime[0] := LInfo.ProcTime[0] + LInfoChild.ProcTime[lThreadIndex];
        end; // if
      end; // for
    end; // for
  end; // for
  LChildrenDict.free;
end; { TResults.RecalcTimes }

procedure TResults.EnterProc(const proxy: TProcProxy; pkt: TResPacket; const mempkt: TResMemPacket);
begin
  // update dead time in all active procedures
  // insert proxy object into active procedure queue
  // increment recursion level
  pkt.rpNullOverhead := 0;
  resThreads[proxy.ThreadID].teActiveProcs.UpdateDeadTime(pkt);
  proxy.Start(pkt, mempkt);
  resThreads[proxy.ThreadID].teActiveProcs.Append(proxy);
  if proxy.ProcID > Cardinal(Length(resProcedures)) then
    raise EInvalidOp.Create('Error: Instrumentation count does not fit to the prf, please reinstrument.');
  Inc(resProcedures[proxy.ProcID].peCurrentCallDepth[proxy.ThreadID]);
end;

procedure TResults.ExitProc(const proxy,parent: TProcProxy; pkt: TResPacket; const mempkt: TResMemPacket);
var
  lMemConsumptionEntry : TMemConsumptionEntry;
begin
  // decrement recursion level
  // remove proxy object from active procedure queue
  // update proxy end time
  // update time in procedure, class, unit and thread objects
  // update time in active procedures from the same thread
  // update dead time in all active procedures
  Dec(resProcedures[proxy.ProcID].peCurrentCallDepth[proxy.ThreadID]);
  resThreads[proxy.ThreadID].teActiveProcs.Remove(proxy);
  pkt.rpNullOverhead := resNullOverhead;
  resNullErrorAcc := resNullErrorAcc + resNullError;
  if resNullErrorAcc > NULL_ACCURACY then begin
    Inc(pkt.rpNullOverhead,1);
    Dec(resNullErrorAcc,NULL_ACCURACY);
  end;
  proxy.Stop(pkt, mempkt);
  UpdateRunningTime(proxy,parent);
  resThreads[proxy.ThreadID].teActiveProcs.UpdateDeadTime(pkt);
  if IsMemProfilingEnabled() then
  begin
    lMemConsumptionEntry := Default(TMemConsumptionEntry);
    if proxy is TMeasurePointWithMemProxy then
    begin
      lMemConsumptionEntry.mceStartingMemWorkingSet := TMeasurePointWithMemProxy(proxy).StartMem;
      lMemConsumptionEntry.mceEndingMemWorkingSet := TMeasurePointWithMemProxy(proxy).EndMem;
    end
    else if proxy is TProcWithMemProxy then
    begin
      lMemConsumptionEntry.mceStartingMemWorkingSet := TProcWithMemProxy(proxy).StartMem;
      lMemConsumptionEntry.mceEndingMemWorkingSet := TProcWithMemProxy(proxy).EndMem;
    end
    else
      raise Exception.Create('The given proxy does not have memory information.');
    // update resource information after Stop();
    fProcedureMemCallList.AddEntryToProcList(proxy.ProcID, lMemConsumptionEntry);
  end;
end; { TResults.ExitProc }

procedure TResults.LoadCalibration;
var
  cnt   : integer;
  start : TResPacket;
  startMem : TResMemPacket;
  stop  : TResPacket;
  stopMem  : TResMemPacket;
  time  : int64;
  time2 : int64;
  calCnt: integer;
  calCal: integer;
  calMax: integer;
  dtime : int64;
begin
  start := default(TResPacket);
  startMem := default(TResMemPacket);
  stop := default(TResPacket);
  stopMem := default(TResMemPacket);
  CheckTag(PR_STARTCALIB);
  ReadInt(calCnt);
  cnt    := 0;
  time   := High(time);
  calCal := calCnt div 50;
  while cnt < calCal do begin
    Inc(cnt);
    ReadPacket(start, startMem);
    if start.rpTag = PR_ENDCALIB then
      RaiseFileCorruptedException('Calibration: PR_ENDCALIB found, but expected start.');
    ReadPacket(stop, stopmem);
    if stop.rpTag = PR_ENDCALIB then
      RaiseFileCorruptedException('Calibration: PR_ENDCALIB found, but expected end.');
    dtime := stop.rpMeasure1-start.rpMeasure2;
    if dtime < time then time := dtime;
  end;
  calMax := 2*time+1; // handle the "time=0" case gracefuly
  cnt  := 0;
  time := 0;
  time2:= 0;
  while ReadPacket(start, startmem) do begin
    ReadPacket(stop, stopmem);
    dtime := stop.rpMeasure1-start.rpMeasure2;
    if dtime <= calMax then begin
      Inc(cnt);
      if cnt > calCnt then
        RaiseFileCorruptedException('Calibration count is bigger than max calibration count.');
      time  := time + time2;
      time2 := dtime;
    end;
  end;
  resNullOverhead := Round(NULL_ACCURACY*time/(cnt-1));
  resNullError    := resNullOverhead mod NULL_ACCURACY;
  resNullOverhead := resNullOverhead div NULL_ACCURACY;
  resNullErrorAcc := 0;
end; { TResults.LoadCalibration }

procedure TResults.SaveDigest(const aPrfFileName: string; callback: TProgressCallback);
var
  lCount : uint64;
  lMaxCount : uint64;
  lPercentage : integer;
  llLastPercentage : integer;
  procedure incrementAndTriggerProgress();
  begin
    if @callback <> nil then
    begin
      inc(lCount);
      lPercentage := round((lCount / lMaxCount) * 100);
      if llLastPercentage <> lPercentage then
      begin
        Application.ProcessMessages;
        callback(round(lPercentage));
        Application.ProcessMessages;
      end;
      llLastPercentage := lPercentage;
    end;
  end;

var
  i,j,k: integer;
  LInfo : TCallGraphInfo;
  lMemComsumptionList : TMemConsumptionForProcedureCalls;
  //lMemComsumptionEntry : TMemConsumptionEntry;
  lDigestFilename : String;
const
  LAST_VALID_DIGESTVERSION = 4;
begin
  lDigestFilename := aPrfFileName + '.dgst';
  resFile := TGpHugeFile.CreateEx(lDigestFilename,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.RewriteBuffered(1, 4*1024*1024);

  try
    var lNumberOfUnits := High(resUnits)-Low(resUnits)+1;
    var lNumberOfClasses := High(resClasses)-Low(resClasses)+1;
    var lNumberOfProcedures := High(resProcedures)-Low(resProcedures)+1;
    var graphInfoCount := fCallGraphInfoMaxElementCount*fCallGraphInfoMaxElementCount+1;
    var memInfoCount := fProcedureMemCallList.Count;
    lCount := 0;
    lMaxCount := lNumberOfUnits + lNumberOfClasses + lNumberOfProcedures + graphInfoCount + memInfoCount;

    WriteTag(PR_DIGEST);
    WriteTag(PR_DIGESTVER);
    WriteInt(LAST_VALID_DIGESTVERSION);
    WriteTag(PR_ENDHEADER);
    WriteTag(PR_DIGFREQ);
    WriteInt64(resFrequency);
    WriteTag(PR_DIGTHREADS);
    WriteInt(High(resThreads)-Low(resThreads)+1);
    for i := Low(resThreads) to High(resThreads) do
      with resThreads[i] do begin
        incrementAndTriggerProgress();
        WriteInt(teThread);
        WriteString(teName);
        WriteInt64(teTotalTime);
        WriteInt(teTotalCnt);
      end;
    WriteTag(PR_DIGUNITS);
    WriteInt(lNumberOfUnits);
    for i := Low(resUnits) to High(resUnits) do
      with resUnits[i] do begin
        incrementAndTriggerProgress();
        WriteString(ueName);
        WriteString(ueQual);
        WriteInt(High(ueTotalTime)-Low(ueTotalTime)+1);
        for j := Low(ueTotalTime) to High(ueTotalTime) do
          WriteInt64(ueTotalTime[j]);
        WriteInt(High(ueTotalCnt)-Low(ueTotalCnt)+1);
        for j := Low(ueTotalCnt) to High(ueTotalCnt) do
          WriteInt(ueTotalCnt[j]);
      end;
    WriteTag(PR_DIGCLASSES);

    WriteInt(lNumberOfClasses);
    for i := Low(resClasses) to High(resClasses) do
      with resClasses[i] do begin
        incrementAndTriggerProgress();
        WriteString(ceName);
        WriteInt(ceUID);
        WriteInt(ceFirstLn);
        WriteInt(High(ceTotalTime)-Low(ceTotalTime)+1);
        for j := Low(ceTotalTime) to High(ceTotalTime) do
          WriteInt64(ceTotalTime[j]);
        WriteInt(High(ceTotalCnt)-Low(ceTotalCnt)+1);
        for j := Low(ceTotalCnt) to High(ceTotalCnt) do
          WriteInt(ceTotalCnt[j]);
      end;
    WriteTag(PR_DIGPROCS);
    WriteInt(lNumberOfProcedures);
    for i := Low(resProcedures) to High(resProcedures) do
      with resProcedures[i] do begin
        incrementAndTriggerProgress();
        WriteString(peName);
        WriteInt(pePID);
        WriteInt(peUID);
        WriteInt(peCID);
        WriteInt(peFirstLn);
        WriteInt(High(peProcTime)-Low(peProcTime)+1);
        for j := Low(peProcTime) to High(peProcTime) do
          WriteInt64(peProcTime[j]);
        WriteInt(High(peProcTimeMin)-Low(peProcTimeMin)+1);
        for j := Low(peProcTimeMin) to High(peProcTimeMin) do
          WriteInt64(peProcTimeMin[j]);
        WriteInt(High(peProcTimeMax)-Low(peProcTimeMax)+1);
        for j := Low(peProcTimeMax) to High(peProcTimeMax) do
          WriteInt64(peProcTimeMax[j]);
        WriteInt(High(peProcChildTime)-Low(peProcChildTime)+1);
        for j := Low(peProcChildTime) to High(peProcChildTime) do
          WriteInt64(peProcChildTime[j]);
        WriteInt(High(peProcCnt)-Low(peProcCnt)+1);
        for j := Low(peProcCnt) to High(peProcCnt) do
          WriteInt(peProcCnt[j]);
        WriteInt(High(peProcTimeAvg)-Low(peProcTimeAvg)+1);
        for j := Low(peProcTimeAvg) to High(peProcTimeAvg) do
          WriteInt64(peProcTimeAvg[j]);
      end;
    WriteTag(PR_DIGCALLG);
    for i := 0 to fCallGraphInfoMaxElementCount do
      for k := 0 to fCallGraphInfoMaxElementCount do begin
      begin
        incrementAndTriggerProgress();
        LInfo := fCallGraphInfoDict.GetGraphInfo(i,k);
        if Assigned(LInfo) then
        begin
          WriteInt(i);
          WriteInt(k);
          WriteInt(LInfo.ProcTime.Count); // number of threads
          for j := 0 to LInfo.ProcTime.Count-1 do
            WriteInt64(LInfo.ProcTime[j]);
          for j := 0 to LInfo.ProcTimeMin.Count-1 do
            WriteInt64(LInfo.ProcTimeMin[j]);
          for j := 0 to LInfo.ProcTimeMax.Count-1 do
            WriteInt64(LInfo.ProcTimeMax[j]);
          for j := 0 to LInfo.ProcChildTime.Count-1 do
            WriteInt64(LInfo.ProcChildTime[j]);
          for j := 0 to LInfo.ProcCnt.Count-1 do
            WriteInt(LInfo.ProcCnt[j]);
          for j := 0 to LInfo.ProcTimeAvg.Count-1 do
            WriteInt64(LInfo.ProcTimeAvg[j]);
        end;
      end;
    end;
    WriteInt(PR_DIGENDCG);
    WriteTag(PR_DIG_START_MEMG);
    WriteCardinal(fProcedureMemCallList.Count);
    for i := 0 to fProcedureMemCallList.Count-1 do
    begin
      incrementAndTriggerProgress();
      lMemComsumptionList := fProcedureMemCallList.Read(i);
      WriteInt(lMemComsumptionList.ProcId);
      WriteInt(lMemComsumptionList.Count);
      for j := 0 to lMemComsumptionList.Count-1 do
      begin
        WriteCardinal(lMemComsumptionList[j].mceStartingMemWorkingSet);
        WriteCardinal(lMemComsumptionList[j].mceEndingMemWorkingSet);
      end;
    end;
    WriteTag(PR_DIG_END_MEMG);
    // dump call graph
    WriteTag(PR_ENDDIGEST);
  finally
    resFile.Free;
  end;
  TFile.Delete(aPrfFilename);
  TFile.Move(lDigestFilename, aPrfFilename);

end; { TResults.SaveDigest }

procedure TResults.LoadDigest(callback: TProgressCallback);
var
  i       : integer;
  j       : integer;
  num     : integer;
  tag     : byte;
  cnt     : integer;
  filesz  : int64;
  fpstart : int64;
  curPerc : integer;
  lastPerc: integer;

  procedure UpdateStatus;
  begin
    Inc(cnt);
    if (cnt mod REPORT_EVERY) = 0 then begin
      Application.ProcessMessages;
      if @callback <> nil then begin
        curPerc := Round((resFile.FilePos-fpstart)/filesz*100);
        if curPerc <> lastPerc then begin
          lastPerc := curPerc;
          callback(curPerc);
        end;
      end;
    end;
  end; { UpdateStatus }

var
  LInfo : TCallGraphInfo;
  LInt64 : Int64;
  LInt : Integer;
  //lNumberOfMemEntries : Cardinal;
  lMemComsumptionList : TMemConsumptionForProcedureCalls;
  lMemComsumptionEntry : TMemConsumptionEntry;
begin
  fpstart  := resFile.FilePos;
  filesz   := resFile.FileSize;
  lastPerc := -1;
  cnt      := 0;
  repeat
    UpdateStatus;
    ReadTag(tag);
    case tag of
      PR_DIGFREQ: ReadInt64(resFrequency);
      PR_DIGTHREADS: begin
        ReadInt(num);
        SetLength(resThreads,num);
        for i := Low(resThreads) to High(resThreads) do
          with resThreads[i] do begin
            UpdateStatus;
            ReadInt(teThread);
            ReadString(teName);
            ReadInt64(teTotalTime);
            ReadInt(teTotalCnt);
          end;
      end; // PR_DIGTHREADS;
      PR_DIGUNITS: begin
        ReadInt(num);
        SetLength(resUnits,num);
        for i := Low(resUnits) to High(resUnits) do
          with resUnits[i] do begin
            UpdateStatus;
            ReadString(ueName);
            ReadString(ueQual);
            ReadInt(num);
            SetLength(ueTotalTime,num);
            for j := Low(ueTotalTime) to High(ueTotalTime) do ReadInt64(ueTotalTime[j]);
            ReadInt(num);
            SetLength(ueTotalCnt,num);
            for j := Low(ueTotalCnt) to High(ueTotalCnt) do ReadInt(ueTotalCnt[j]);
          end;
      end; // PR_DIGUNITS
      PR_DIGCLASSES: begin
        ReadInt(num);
        SetLength(resClasses,num);
        for i := Low(resClasses) to High(resClasses) do
          with resClasses[i] do begin
            UpdateStatus;
            ReadString(ceName);
            ReadInt(ceUID);
            ReadInt(ceFirstLn);
            ReadInt(num);
            SetLength(ceTotalTime,num);
            for j := Low(ceTotalTime) to High(ceTotalTime) do ReadInt64(ceTotalTime[j]);
            ReadInt(num);
            SetLength(ceTotalCnt,num);
            for j := Low(ceTotalCnt) to High(ceTotalCnt) do ReadInt(ceTotalCnt[j]);
          end;
      end; // PR_DIGCLASSES
      PR_DIGPROCS: begin
        ReadInt(num);
        SetLength(resProcedures,num);
        fCallGraphInfoMaxElementCount := num;
        fCallGraphInfoDict.Clear();
        for i := Low(resProcedures) to High(resProcedures) do
          with resProcedures[i] do begin
            UpdateStatus;
            ReadString(peName);
            ReadInt(pePID);
            ReadInt(peUID);
            ReadInt(peCID);
            ReadInt(peFirstLn);
            ReadInt(num);
            SetLength(peProcTime,num);
            for j := Low(peProcTime) to High(peProcTime) do ReadUInt64(peProcTime[j]);
            ReadInt(num);
            SetLength(peProcTimeMin,num);
            for j := Low(peProcTimeMin) to High(peProcTimeMin) do ReadUInt64(peProcTimeMin[j]);
            ReadInt(num);
            SetLength(peProcTimeMax,num);
            for j := Low(peProcTimeMax) to High(peProcTimeMax) do ReadUInt64(peProcTimeMax[j]);
            ReadInt(num);
            SetLength(peProcChildTime,num);
            for j := Low(peProcChildTime) to High(peProcChildTime) do ReadUInt64(peProcChildTime[j]);
            ReadInt(num);
            SetLength(peProcCnt,num);
            for j := Low(peProcCnt) to High(peProcCnt) do ReadCardinal(peProcCnt[j]);
            ReadInt(num);
            SetLength(peProcTimeAvg,num);
            for j := Low(peProcTimeAvg) to High(peProcTimeAvg) do ReadUInt64(peProcTimeAvg[j]);
          end;
      end; // PR_DIGPROCS
      PR_DIGCALLG: begin
        repeat
          ReadInt(i);
          if i = PR_DIGENDCG then break;
          ReadInt(j);
          ReadInt(num);
          LInfo := fCallGraphInfoDict.GetOrCreateGraphInfo(i,j,num);
          LInfo.ProcTime.Count := num;
          for j := 0 to LInfo.ProcTime.Count-1 do
          begin
            ReadInt64(LInt64);
            LInfo.ProcTime[j] := LInt64;
          end;
          LInfo.ProcTimeMin.Count := num;
          for j := 0 to LInfo.ProcTimeMin.Count-1 do
          begin
            ReadInt64(LInt64);
            LInfo.ProcTimeMin[j] := LInt64;
          end;
          LInfo.ProcTimeMax.Count := num;
          for j := 0 to LInfo.ProcTimeMax.Count-1 do
          begin
            ReadInt64(LInt64);
            LInfo.ProcTimeMax[j] := LInt64;
          end;
          LInfo.ProcChildTime.Count := num;
          for j := 0 to LInfo.ProcChildTime.Count-1 do
          begin
            ReadInt64(LInt64);
            LInfo.ProcChildTime[j] := LInt64;
          end;
          LInfo.ProcCnt.Count := num;
          for j := 0 to LInfo.ProcCnt.Count-1 do
          begin
            ReadInt(LInt);
            LInfo.ProcCnt[j] := LInt;
          end;
          LInfo.ProcTimeAvg.Count := num;
          for j := 0 to LInfo.ProcTimeAvg.Count-1 do
          begin
            ReadInt64(LInt64);
            LInfo.ProcTimeAvg[j] := LInt64;
          end;
        until false;
      end; // PR_DIGCALLG
      PR_DIG_START_MEMG:
      begin
        fProcedureMemCallList.Clear();
        ReadInt(LInt); // Count
        fProcedureMemCallList.Count := lInt;
        for i := 0 to fProcedureMemCallList.Count-1 do
        begin
          { Read the list of the proces with its invokations. }
          ReadInt(LInt); // procID
          // we could ask the mem core, but as the list is sorted, we create it be outselves.
          lMemComsumptionList := TMemConsumptionForProcedureCalls.Create(LInt);
          fProcedureMemCallList.Write(i, lMemComsumptionList); // define entry
          ReadInt(lInt); // Count
          lMemComsumptionList.Count := LInt; // init count and create empty records
          for j := 0 to lMemComsumptionList.Count-1 do
          begin
            ReadCardinal(lMemComsumptionEntry.mceStartingMemWorkingSet);
            ReadCardinal(lMemComsumptionEntry.mceEndingMemWorkingSet);
            lMemComsumptionList[j] := lMemComsumptionEntry;
          end;
        end;
      end;

    end; // case
  until tag = PR_ENDDIGEST;
end; { TResults.LoadDigest }

procedure TResults.Rename(fileName: string);
begin
  resName := fileName;
end;

procedure TResults.AssignTables(tableFile: string);
begin
  resPrfVersion := 4;
  resFile := TGpHugeFile.CreateEx(tableFile,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.ResetBuffered(1, 4*1024*1024);
  try
    LoadTables;
  finally resFile.Free; resFile := nil; end;
end; { TResults.AssignTables }

procedure TResults.StartCalibration(calibCnt: integer);
begin
  resCalibrCnt   := calibCnt div 50;
  resCurCalibr   := 0;
  resCalibration := true;
  resCalTime     := High(resCalTime);
end; { TResults.StopCalibration }

procedure TResults.StopCalibration;
begin
  resCalibration := false;
  resNullOverhead := Round(NULL_ACCURACY*resCalTime/(resCalCounter-1));
  resNullError    := resNullOverhead mod NULL_ACCURACY;
  resNullOverhead := resNullOverhead div NULL_ACCURACY;
  resNullErrorAcc := 0;
end; { TResults.StopCalibration }

procedure TResults.CalibrationStep(pkt1, pkt2: TResPacket);
begin
  Inc(resCurCalibr);
  if resCurCalibr < resCalibrCnt then begin
    resCalDTime := pkt2.rpMeasure1-pkt1.rpMeasure2;
    if resCalDTime < resCalTime then resCalTime := resCalDTime;
  end
  else begin
    if resCurCalibr = resCalibrCnt then begin
      resCalMax     := 2*resCalTime+1;
      resCalCounter := 0;
      resCalTime    := 0;
      resCalTime2   := 0;
    end;
    resCalDTime := pkt2.rpMeasure1-pkt1.rpMeasure2;
    if resCalDTime <= resCalMax then begin
      Inc(resCalCounter);
      resCalTime := resCalTime + resCalTime2;
      resCalTime2 := resCalDTime;
    end;
  end;
end; { TResults.CalibrationStep }


{ TUnitEntry }

function TUnitEntry.GetName: String;
begin
  result := String(ueName);
end;

function TUnitEntry.GetPath: String;
begin
  result := String(ueQual);
end;

{ TThreadEntry }

function TThreadEntry.GetName: String;
begin
  result := UTF8ToString(teName);
end;

{ TClassEntry }

function TClassEntry.GetName: String;
begin
  result := Utf8ToString(ceName);
end;



end.
