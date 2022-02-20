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
  gppResults.types;

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

  TProcEntry = record
  private
    function GetName: String;
  public
    peName         : AnsiString;
    pePID          : integer;
    peUID          : integer;
    peCID          : integer;
    peFirstLn      : integer;
    peProcTime     : array {thread} of int64;   // 0 = sum
    peProcTimeMin  : array {thread} of int64;   // 0 = unused
    peProcTimeMax  : array {thread} of int64;   // 0 = unused
    peProcTimeAvg  : array {thread} of int64;   // 0 = unused
    peProcChildTime: array {thread} of int64;   // 0 = sum
    peProcCnt      : array {thread} of integer; // 0 = sum
    peCurrentCallDepth : array {thread} of integer; // 0 = unused
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
    resPrfDigestVer   : integer;
    resCalibrCnt      : integer;
    resCurCalibr      : integer;
    resCalibration    : boolean;
    resCalPkt         : TResPacket;
    resCalDTime       : int64;
    resCalTime        : int64;
    resCalTime2       : int64;
    resCalMax         : int64;
    resCalCounter     : integer;
    procedure   RaiseFileCorruptedException(const aContext : String);

    procedure   CalibrationStep(pkt1, pkt2: TResPacket);
    procedure   ExitProcPkt(pkt: TResPacket);
    procedure   EnterProcPkt(pkt: TResPacket);
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
    function    ReadPacket(var pkt: TResPacket): boolean;
    procedure   UpdateRunningTime(proxy,parent: TProcProxy);
    function    ThCreateLocate(thread: integer): integer;
    function    ThCreate(thread: integer): integer;
    function    ThLocate(thread: integer): integer;
    procedure   EnterProc(proxy: TProcProxy; pkt: TResPacket);
    procedure   ExitProc(proxy,parent: TProcProxy; pkt: TResPacket);
  public
    resThreads   : array of TThreadEntry;
    resUnits     : array of TUnitEntry;
    resClasses   : array of TClassEntry;
    resProcedures: array of TProcEntry;
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
    procedure   AddEnterProc(pkt: TResPacket);
    procedure   AddExitProc(pkt: TResPacket);
    procedure   StartCalibration(calibCnt: integer);
    procedure   StopCalibration;
    procedure   RecalcTimes;
    /// <summary>
    /// Writes a digest (compressed) version of the given prf file. If the conversion is sucessfull, the prf will
    /// be replaced. Else the prf will stay as it is.
    /// </summary>
    procedure   SaveDigest(const aPrfFileName: string);
    procedure   Rename(fileName: string);
    property    FileName: String read resName;
    property    Version: integer read resPrfVersion;
    property    IsDigest: boolean read resPrfDigest;
    property    DigestVer: integer read resPrfDigestVer;
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
  resPrfDigestVer    := 0;
  resNullOverhead    := 0;
  resNullError       := 0;
  resNullErrorAcc    := 0;
  // dictionary owning the values; all sub dicts are just refs
  fCallGraphInfoDict := TCallGraphInfoDict.Create([doOwnsValues]);
  fProcedureMemCallList := TProcedureMemCallList.Create();
end; { TResults.Create }

constructor TResults.Create(fileName: String; callback: TProgressCallback);
begin
  Create();
  resName := fileName;
  resFile := TGpHugeFile.CreateEx(resName,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.ResetBuffered(1);
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
  fCallGraphInfoDict.free;
  fProcedureMemCallList.free;
  for i := Low(resThreads) to High(resThreads) do
    resThreads[i].teActiveProcs.Free;
  inherited Destroy;
end; { TResults.Destroy }

procedure TResults.ReadInt  (var int: integer);  begin resFile.BlockReadUnsafe(int,SizeOf(integer)); end;
procedure TResults.ReadCardinal(var value: Cardinal);  begin resFile.BlockReadUnsafe(value,SizeOf(Cardinal)); end;
procedure TResults.ReadInt64(var i64: int64);    begin resFile.BlockReadUnsafe(i64,SizeOf(int64)); end;
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
  elements: integer;
begin
  CheckTag(PR_UNITTABLE);
  ReadInt(elements);
  SetLength(resUnits,elements+1);      // resUnits[0] = Sum(resUnits[1:])
  for i := 1 to elements do begin
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
  ReadInt(elements);
  SetLength(resClasses,elements+1);    // resClasses[0] = Sum(resClasses[1:])
  for i := 1 to elements do begin
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
  ReadInt(elements);
  SetLength(resProcedures,elements+1); // resProcedures[0] = Sum(resProcedures[1:])
  for i := 1 to elements do begin
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
  fCallGraphInfoMaxElementCount := elements+1;
  for i := 1 to High(resClasses) do
    with resClasses[i] do
      if ceFirstLn = MaxLongint then ceFirstLn := -1;
end; 

{ TResult.LoadTables }

procedure TResults.LoadData(callback: TProgressCallback);
var
  pkt     : TResPacket;
  curPerc : integer;
  lastPerc: integer;
  filesz  : int64;
  fpstart : int64;
  cnt     : integer;
begin
  cnt      := 0;
  fpstart  := resFile.FilePos;
  filesz   := resFile.FileSize;
  lastPerc := -1;
  CheckTag(PR_STARTDATA);
  while ReadPacket(pkt) do begin
    Inc(cnt);
    if (cnt mod REPORT_EVERY) = 0 then begin
      Application.ProcessMessages;
      if @callback <> nil then begin
        curPerc := Round((resFile.FilePos-fpstart)/filesz*100);
        if curPerc <> lastPerc then begin
          lastPerc := curPerc;
          if not callback(curPerc) then break;
        end;
      end;
    end;
    with pkt do begin
      if rpTag = PR_ENTERPROC then begin
        // create new procedure proxy object
        EnterProcPkt(pkt);
      end
      else if rpTag = PR_EXITPROC then begin
        // find last proxy object with matching prProcID in active procedure queue
        // update relevant objects
        // destroy proxy object
        ExitProcPkt(pkt)
      end
      else raise Exception.Create('gppResults.TResults.LoadData: Invalid tag!');
    end;
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


procedure TResults.EnterProcPkt(pkt: TResPacket);
var
  proxy: TProcProxy;
begin
  proxy := TProcProxy.Create(ThCreateLocate(pkt.rpThread),pkt.rpProcID);
  EnterProc(proxy,pkt);
end; { TResults.EnterProcPkt }

procedure TResults.ExitProcPkt(pkt: TResPacket);
var
  proxy : TProcProxy;
  parent: TProcProxy;
begin
  resThreads[ThLocate(pkt.rpThread)].teActiveProcs.LocateLast(pkt.rpProcID,proxy,parent);
  if proxy = nil then
    raise Exception.Create('gppResults.TResults.ExitProcPkt: Entry not found!');
  ExitProc(proxy,parent,pkt);
  proxy.Destroy;
  inherited;
end; { TResults.ExitProcPkt }

procedure TResults.AddEnterProc(pkt: TResPacket);
begin
  if resCalibration
    then Move(pkt,resCalPkt,SizeOf(TResPacket))
    else EnterProcPkt(pkt);
end; { TResults.AddEnterProc }

procedure TResults.AddExitProc(pkt: TResPacket);
begin
  if resCalibration
    then CalibrationStep(resCalPkt,pkt)
    else ExitProcPkt(pkt);
end; { TResults.AddExitProc }

function TResults.ReadPacket(var pkt: TResPacket): boolean;
begin
  with pkt do begin
    ReadTag(rpTag);
    if (rpTag = PR_ENDDATA) or (rpTag = PR_ENDCALIB) then
      Result := false
    else
    begin
      ReadThread(rpThread);
      ReadID(rpProcID);
      ReadTicks(rpMeasure1);
      if (resPrfVersion = PRF_VERSION_WITH_MEM) then
        if (rpTag = PR_ENTERPROC) or (rpTag = PR_EXITPROC) then
          ReadCardinal(rpMemWorkingSize);
      ReadTicks(rpMeasure2);
      Result := true;
    end;
  end;
end; { TResults.ReadPacket }

procedure TResults.LoadHeader;
var
  tag: byte;
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
      PR_DIGESTVER  : ReadInt(resPrfDigestVer);
    end;
  until tag = PR_ENDHEADER;
end; { TResults.LoadHeader }

procedure TResults.UpdateRunningTime(proxy,parent: TProcProxy);
var
  LInfo : TCallGraphInfo;
  LThreadID : integer;
begin
  LThreadID := proxy.ppThreadID;
  // update resProcedures, resActiveProcs, and CallGraph
  // other structures will be recalculated at the end
  with resProcedures[proxy.ppProcID] do
  begin
    if assigned(parent) then
      parent.ppChildTime := parent.ppChildTime + proxy.ppTotalTime + proxy.ppChildTime;
    Inc(peProcTime[LThreadID],proxy.ppTotalTime);
    if proxy.ppTotalTime < peProcTimeMin[LThreadID] then
      peProcTimeMin[LThreadID] := proxy.ppTotalTime;
    if proxy.ppTotalTime > peProcTimeMax[LThreadID] then
      peProcTimeMax[LThreadID] := proxy.ppTotalTime;
    if peCurrentCallDepth[LThreadID] = 0 then
    begin
      Inc(peProcChildTime[LThreadID],proxy.ppChildTime);
      Inc(peProcChildTime[LThreadID],proxy.ppTotalTime);
    end;
    Inc(peProcCnt[LThreadID],1);
  end;

  // update all callstack related data.

  if assigned(parent) then
  begin
    // assemble callstack information
    LInfo := fCallGraphInfoDict.GetOrCreateGraphInfo(parent.ppProcID,proxy.ppProcID,High(resThreads));

    LInfo.ProcTime.AddTime(LThreadID,proxy.ppTotalTime);
    if proxy.ppTotalTime < LInfo.ProcTimeMin[LThreadID] then
      LInfo.ProcTimeMin.AssignTime(LThreadID,proxy.ppTotalTime);
    if proxy.ppTotalTime > LInfo.ProcTimeMax[LThreadID] then
      LInfo.ProcTimeMax.AssignTime(LThreadID, proxy.ppTotalTime);
    if resProcedures[proxy.ppProcID].peCurrentCallDepth[LThreadID] = 0 then
    begin
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ppChildTime);
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ppTotalTime);
    end
    else if (resProcedures[proxy.ppProcID].peCurrentCallDepth[LThreadID] = 1) and
            (parent.ppProcID = proxy.ppProcID) then
    begin
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ppChildTime);
      LInfo.ProcChildTime.AddTime(LThreadID,proxy.ppTotalTime);
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
  i  : integer;
  numth: integer;
  LPair : TPair<TCallGraphKey, TCallGraphInfo>;
  LInfo : TCallGraphInfo;
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
  for i := Low(resProcedures) to High(resProcedures) do begin
    with resProcedures[i] do begin
      SetLength(peProcTime,numth);
      SetLength(peProcTimeMin,numth);
      SetLength(peProcTimeMax,numth);
      SetLength(peProcTimeAvg,numth);
      SetLength(peProcChildTime,numth);
      SetLength(peProcCnt,numth);
      SetLength(peCurrentCallDepth,numth);
      peProcTime[numth-1]      := 0;
      peProcTimeMin[numth-1]   := High(int64);
      peProcTimeMax[numth-1]   := 0;
      peProcTimeAvg[numth-1]   := 0;
      peProcChildTime[numth-1] := 0;
      peProcCnt[numth-1]       := 0;
      peCurrentCallDepth[numth-1]      := 0;
    end;
  end;
  // resize fCallGraphInfoDict
  for LPair in fCallGraphInfoDict do
  begin
    LInfo := LPair.Value;
    LInfo.ProcTime.Add(0);
    LInfo.ProcTimeMin.Add(High(int64));
    LInfo.ProcTimeMax.Add(0);
    LInfo.ProcTimeAvg.Add(0);
    LInfo.ProcChildTime.Add(0);
    LInfo.ProcCnt.Add(0);
  end;
  Result := numth-1;
end; { TResults.ThCreate }

procedure TResults.RecalcTimes;
var
  i,j: integer;
  numth: integer;
  LPair : TPair<TCallGraphKey, TCallGraphInfo>;
  LInfo : TCallGraphInfo;
  LInfoChild : TCallGraphInfo;
  LChildrenDict : TCallGraphInfoDict;
  LProcTimeAvgAllThreads : int64;
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
      if (not IsDigest) or (DigestVer < PRF_DIGESTVER_2) then begin
        peProcTimeMin[Low(peProcTIme)] := High(int64);
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
        if peProcTimeMin[j] = High(int64) then peProcTimeMin[j] := 0;
        Inc(peProcChildTime[Low(peProcTime)],peProcChildTime[j]);
        Inc(peProcCnt[Low(peProcCnt)],peProcCnt[j]);
        Inc(resClasses[peCID].ceTotalTime[j],peProcTime[j]);
        Inc(resClasses[peCID].ceTotalCnt[j],peProcCnt[j]);
        Inc(resUnits[peUID].ueTotalTime[j],peProcTime[j]);
        Inc(resUnits[peUID].ueTotalCnt[j],peProcCnt[j]);
        if peProcCnt[j] = 0 then peProcTimeAvg[j] := 0
                            else peProcTimeAvg[j] := peProcTime[j] div peProcCnt[j];
      end;
      if peProcTimeMin[Low(peProcTime)] = High(int64) then
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
  for LPair in fCallGraphInfoDict do
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
        if LInfo.ProcTimeMin[j] = High(int64) then
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

  // fCallGraphInfo: calculate proc time for each thread
  LChildrenDict := TCallGraphInfoDict.Create();
  for i := 0+1 to fCallGraphInfoMaxElementCount-1 do
  begin
    LInfo := fCallGraphInfoDict.GetOrCreateGraphInfo(i,0,High(resThreads));
    LInfo.ProcTime[0] := 0;
    for j := Low(resThreads) + 1 to High(resThreads) do
    begin
      LInfo.ProcTime[j] := 0;
      fCallGraphInfoDict.FillInChildrenForParentId(LChildrenDict,i);
      for LPair in LChildrenDict do
      begin
        // LInfo already points at i,0...and the value is zero. So omit this.
        if LPair.Key.ProcId = 0 then
          Continue;
        LInfoChild := LPair.Value;
        if assigned(LInfoChild) then
        begin
          LInfo.ProcTime[j] := LInfo.ProcTime[j] + LInfoChild.ProcTime[j];
          LInfo.ProcTime[0] := LInfo.ProcTime[0] + LInfoChild.ProcTime[j];
        end; // if
      end; // for
    end; // for
  end; // for
  LChildrenDict.free;
end; { TResults.RecalcTimes }

procedure TResults.EnterProc(proxy: TProcProxy; pkt: TResPacket);
begin
  // update dead time in all active procedures
  // insert proxy object into active procedure queue
  // increment recursion level
  pkt.rpNullOverhead := 0;
  resThreads[proxy.ppThreadID].teActiveProcs.UpdateDeadTime(pkt);
  proxy.Start(pkt);
  resThreads[proxy.ppThreadID].teActiveProcs.Append(proxy);
  if proxy.ppProcID > Length(resProcedures) then
    raise EInvalidOp.Create('Error: Instrumentation count does not fit to the prf, please reinstrument.');
  Inc(resProcedures[proxy.ppProcID].peCurrentCallDepth[proxy.ppThreadID]);
end;

procedure TResults.ExitProc(proxy,parent: TProcProxy; pkt: TResPacket);
var
  lMemInvocationList : TMemConsumptionForProcedureCalls;
  lMemConsumptionEntry : TMemConsumptionEntry;
begin
  // decrement recursion level
  // remove proxy object from active procedure queue
  // update proxy end time
  // update time in procedure, class, unit and thread objects
  // update time in active procedures from the same thread
  // update dead time in all active procedures
  Dec(resProcedures[proxy.ppProcID].peCurrentCallDepth[proxy.ppThreadID]);
  resThreads[proxy.ppThreadID].teActiveProcs.Remove(proxy);
  pkt.rpNullOverhead := resNullOverhead;
  resNullErrorAcc := resNullErrorAcc + resNullError;
  if resNullErrorAcc > NULL_ACCURACY then begin
    Inc(pkt.rpNullOverhead,1);
    Dec(resNullErrorAcc,NULL_ACCURACY);
  end;
  proxy.Stop(pkt);
  UpdateRunningTime(proxy,parent);
  resThreads[proxy.ppThreadID].teActiveProcs.UpdateDeadTime(pkt);
  // update resource information after Stop();
  lMemInvocationList := fProcedureMemCallList.GetOrCreateListForProc(proxy.ppProcID);
  lMemConsumptionEntry := Default(TMemConsumptionEntry);
  lMemConsumptionEntry.mceStartingMemWorkingSet := proxy.ppStartMem;
  lMemConsumptionEntry.mceEndingMemWorkingSet := proxy.ppEndMem;
  lMemInvocationList.Add(lMemConsumptionEntry);
end; { TResults.ExitProc }

procedure TResults.LoadCalibration;
var
  cnt   : integer;
  start : TResPacket;
  stop  : TResPacket;
  time  : int64;
  time2 : int64;
  calCnt: integer;
  calCal: integer;
  calMax: integer;
  dtime : int64;
begin
  CheckTag(PR_STARTCALIB);
  ReadInt(calCnt);
  cnt    := 0;
  time   := High(time);
  calCal := calCnt div 50;
  while cnt < calCal do begin
    Inc(cnt);
    ReadPacket(start);
    if start.rpTag = PR_ENDCALIB then
      RaiseFileCorruptedException('Calibration: PR_ENDCALIB found, but expected start.');
    ReadPacket(stop);
    if stop.rpTag = PR_ENDCALIB then
      RaiseFileCorruptedException('Calibration: PR_ENDCALIB found, but expected end.');
    dtime := stop.rpMeasure1-start.rpMeasure2;
    if dtime < time then time := dtime;
  end;
  calMax := 2*time+1; // handle the "time=0" case gracefuly
  cnt  := 0;
  time := 0;
  time2:= 0;
  while ReadPacket(start) do begin
    ReadPacket(stop);
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

procedure TResults.SaveDigest(const aPrfFileName: string);
var
  i,j,k: integer;
  LInfo : TCallGraphInfo;
  lMemComsumptionList : TMemConsumptionForProcedureCalls;
  lMemComsumptionEntry : TMemConsumptionEntry;
  lDigestFilename : String;
begin
  lDigestFilename := aPrfFileName + '.dgst';
  resFile := TGpHugeFile.CreateEx(lDigestFilename,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.RewriteBuffered(1);
  try
    WriteTag(PR_DIGEST);
    WriteTag(PR_DIGESTVER);
    WriteInt(PRF_DIGESTVER_CURRENT);
    resPrfDigestVer := PRF_DIGESTVER_CURRENT;
    WriteTag(PR_ENDHEADER);
    WriteTag(PR_DIGFREQ);
    WriteInt64(resFrequency);
    WriteTag(PR_DIGTHREADS);
    WriteInt(High(resThreads)-Low(resThreads)+1);
    for i := Low(resThreads) to High(resThreads) do
      with resThreads[i] do begin
        WriteInt(teThread);
        WriteString(teName);
        WriteInt64(teTotalTime);
        WriteInt(teTotalCnt);
      end;
    WriteTag(PR_DIGUNITS);
    WriteInt(High(resUnits)-Low(resUnits)+1);
    for i := Low(resUnits) to High(resUnits) do
      with resUnits[i] do begin
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
    WriteInt(High(resClasses)-Low(resClasses)+1);
    for i := Low(resClasses) to High(resClasses) do
      with resClasses[i] do begin
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
    WriteInt(High(resProcedures)-Low(resProcedures)+1);
    for i := Low(resProcedures) to High(resProcedures) do
      with resProcedures[i] do begin
        WriteString(peName);
        if resPrfDigestVer >= PRF_DIGESTVER_4 then
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
    for i := 0 to fCallGraphInfoMaxElementCount-1 do
      for k := 0 to fCallGraphInfoMaxElementCount-1 do begin
      begin
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
      lMemComsumptionList := fProcedureMemCallList[i];
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
  lNumberOfMemEntries : Cardinal;
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
            if resPrfDigestVer >= PRF_DIGESTVER_4 then
              ReadInt(pePID);
            ReadInt(peUID);
            ReadInt(peCID);
            ReadInt(peFirstLn);
            ReadInt(num);
            SetLength(peProcTime,num);
            for j := Low(peProcTime) to High(peProcTime) do ReadInt64(peProcTime[j]);
            ReadInt(num);
            SetLength(peProcTimeMin,num);
            for j := Low(peProcTimeMin) to High(peProcTimeMin) do ReadInt64(peProcTimeMin[j]);
            ReadInt(num);
            SetLength(peProcTimeMax,num);
            for j := Low(peProcTimeMax) to High(peProcTimeMax) do ReadInt64(peProcTimeMax[j]);
            if DigestVer < PRF_DIGESTVER_1 then SetLength(peProcTimeAvg,num);
            ReadInt(num);
            SetLength(peProcChildTime,num);
            for j := Low(peProcChildTime) to High(peProcChildTime) do ReadInt64(peProcChildTime[j]);
            ReadInt(num);
            SetLength(peProcCnt,num);
            for j := Low(peProcCnt) to High(peProcCnt) do ReadInt(peProcCnt[j]);
            if DigestVer >= PRF_DIGESTVER_1 then begin
              ReadInt(num);
              SetLength(peProcTimeAvg,num);
              for j := Low(peProcTimeAvg) to High(peProcTimeAvg) do ReadInt64(peProcTimeAvg[j]);
            end;
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
        if resPrfDigestVer < PRF_DIGESTVER_4 then
          raise Exception.create('Digist Version is below 4, but found mem artefacts.');
        fProcedureMemCallList.Clear();
        ReadInt(LInt); // Count
        fProcedureMemCallList.Count := lInt;
        for i := 0 to fProcedureMemCallList.Count-1 do
        begin
          { Read the list of the proces with its invokations. }
          ReadInt(LInt); // procID
          // we could ask the mem core, but as the list is sorted, we create it be outselves.
          lMemComsumptionList := TMemConsumptionForProcedureCalls.Create(LInt);
          fProcedureMemCallList[i] := lMemComsumptionList; // define entry
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
  resFile.ResetBuffered(1);
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
  result := String(teName);
end;

{ TProcEntry }

function TProcEntry.GetName: String;
begin
  result := string(peName);
end;

{ TClassEntry }

function TClassEntry.GetName: String;
begin
  result := String(ceName);
end;



end.
