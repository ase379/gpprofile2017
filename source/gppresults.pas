{$R-,I-,Q-.S-,O+}

unit gppResults;

interface

uses
  Windows,
  EZDSLDBL,
  GpHugeF;

type
  TProgressCallback = function (percent: integer): boolean of object;

  TResPacket = record
    rpTag         : byte;
    rpThread      : integer;
    rpProcID      : integer;
    rpMeasure1    : int64;
    rpMeasure2    : int64;
    rpNullOverhead: int64;
  end;

  TProcProxy = class
  private
    ppThreadID    : integer;
    ppProcID      : integer;
    ppDeadTime    : int64;
    ppStartTime   : int64;
    ppTotalTime   : int64;
    ppChildTime   : int64;
  public
    constructor Create(threadID, procID: integer);
    destructor  Destroy; override;
    procedure   Start(pkt: TResPacket);
    procedure   Stop(var pkt: TResPacket);
    procedure   UpdateDeadTime(pkt: TResPacket);
    procedure   UpdateRunningTime(proxy: TProcProxy);
  end;

  TActiveProcList = class
  private
    aplList : array of TProcProxy;
    aplCount: integer;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   UpdateDeadTime(pkt: TResPacket);
    procedure   UpdateRunningTime(proxy: TProcProxy);
    procedure   Append(proxy: TProcProxy);
    procedure   Remove(proxy: TProcProxy);
    procedure   LocateLast(procID: integer; var this,parent: TProcProxy);
  end;

  TThreadEntry = record
    teThread     : integer;
    teName       : string; // someday will be setable by API
    teTotalTime  : int64;
    teTotalCnt   : integer;
    teActiveProcs: TActiveProcList; 
  end;

  TUnitEntry = record
    ueName     : string;
    ueQual     : string;
    ueTotalTime: array {thread} of int64;   // 0 = sum
    ueTotalCnt : array {thread} of integer; // 0 = sum
  end;

  TClassEntry = record                                   
    ceName     : string;
    ceUID      : integer;
    ceFirstLn  : integer;
    ceTotalTime: array {thread} of int64;   // 0 = sum
    ceTotalCnt : array {thread} of integer; // 0 = sum
  end;

  TProcEntry = record
    peName         : string;
    peUID          : integer;
    peCID          : integer;
    peFirstLn      : integer;
    peProcTime     : array {thread} of int64;   // 0 = sum
    peProcTimeMin  : array {thread} of int64;   // 0 = unused
    peProcTimeMax  : array {thread} of int64;   // 0 = unused
    peProcTimeAvg  : array {thread} of int64;   // 0 = unused
    peProcChildTime: array {thread} of int64;   // 0 = sum
    peProcCnt      : array {thread} of integer; // 0 = sum
    peRecLevel     : array {thread} of integer; // 0 = unused
  end;

  PCallGraphEntry = ^TCallGraphEntry;
  TCallGraphEntry = record
    cgeProcTime     : array {thread} of int64;   // 0 = sum
    cgeProcTimeMin  : array {thread} of int64;   // 0 = unused
    cgeProcTimeMax  : array {thread} of int64;   // 0 = unused
    cgeProcTimeAvg  : array {thread} of int64;   // 0 = unused
    cgeProcChildTime: array {thread} of int64;   // 0 = sum
    cgeProcCnt      : array {thread} of integer; // 0 = sum
//    cgeRecLevel     : array {thread} of integer; // 0 = unused
  end;

  TResults = class
  private
    resFile           : TGpHugeFile;
    resName           : string;
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
    procedure   CalibrationStep(pkt1, pkt2: TResPacket);
    procedure   ExitProcPkt(pkt: TResPacket);
    procedure   EnterProcPkt(pkt: TResPacket);
    procedure   LoadHeader;
    procedure   LoadTables;
    procedure   LoadCalibration;
    procedure   LoadData(callback: TProgressCallback);
    procedure   LoadDigest(callback: TProgressCallback);
    procedure   ReadString(var str: string);
    procedure   ReadShortstring(var str: string);
    procedure   ReadInt(var int: integer);
    procedure   ReadInt64(var i64: int64);
    procedure   ReadBool(var bool: boolean);
    procedure   ReadTag(var tag: byte);
    procedure   ReadThread(var thread: integer);
    procedure   ReadTicks(var ticks: int64);
    procedure   ReadID(var id: integer);
    procedure   WriteTag(tag: byte);
    procedure   WriteInt(int: integer);
    procedure   WriteInt64(i64: int64);
    procedure   WriteString(str: string);
    procedure   CheckTag(tag: byte);
    function    ReadPacket(var pkt: TResPacket): boolean;
    procedure   UpdateRunningTime(proxy,parent: TProcProxy);
    function    ThCreateLocate(thread: integer): integer;
    function    ThCreate(thread: integer): integer;
    function    ThLocate(thread: integer): integer;
    procedure   EnterProc(proxy: TProcProxy; pkt: TResPacket);
    procedure   ExitProc(proxy,parent: TProcProxy; pkt: TResPacket);
    procedure   AllocCGEntry(i,j,threads: integer);
  public
    resThreads   : array of TThreadEntry;
    resUnits     : array of TUnitEntry;
    resClasses   : array of TClassEntry;
    resProcedures: array of TProcEntry;
    resCallGraph : array {procedure} of array {procedure} of PCallGraphEntry;
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
    procedure   SaveDigest(fileName: string);
    procedure   Rename(fileName: string);
    property    Name: string read resName;
    property    Version: integer read resPrfVersion;
    property    IsDigest: boolean read resPrfDigest;
    property    DigestVer: integer read resPrfDigestVer;
  end;

implementation

uses
  Forms,
  EZDSLBSE,
  SysUtils,
  GpProfH,
  gppCommon;

const
  APL_QUANTUM   = 10;
  NULL_ACCURACY = 1000;
  REPORT_EVERY  = 100; // samples read

{ TResults }

constructor TResults.Create;
begin
  inherited Create;
  try
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
  except Fail; end;
end; { TResults.Create }

constructor TResults.Create(fileName: string; callback: TProgressCallback);
begin
  Create();
  try
    resName := fileName;
    resFile := TGpHugeFile.CreateEx(resName,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
    resFile.ResetBuffered(1);
    try
      LoadHeader;
      if IsDigest then LoadDigest(callback)
      else begin
        LoadTables;
        if Version > 2 then LoadCalibration;
        LoadData(callback);
        RecalcTimes;
      end;
    finally resFile.Free; end;
  except Fail; end;
end; { TResults.Create }

destructor TResults.Destroy;
var
  i,j: integer;
begin
  for i := Low(resThreads) to High(resThreads) do resThreads[i].teActiveProcs.Free;
  for i := Low(resCallGraph) to High(resCallGraph) do 
    for j := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do 
      if assigned(resCallGraph[i,j]) then Dispose(resCallGraph[i,j]); 
  inherited Destroy;
end; { TResults.Destroy }

procedure TResults.ReadInt  (var int: integer);  begin resFile.BlockReadUnsafe(int,SizeOf(integer)); end;
procedure TResults.ReadInt64(var i64: int64);    begin resFile.BlockReadUnsafe(i64,SizeOf(int64)); end;
procedure TResults.ReadTag  (var tag: byte);     begin resFile.BlockReadUnsafe(tag,SizeOf(byte)); end;
procedure TResults.ReadID   (var id: integer);   begin id := 0; resFile.BlockReadUnsafe(id,resProcSize); end;
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

procedure TResults.ReadShortstring(var str: string);
var
  s: shortstring;
begin
  resFile.BlockReadUnsafe(s[0],1);
  resFile.BlockReadUnsafe(s[1],Ord(s[0]));
  str := s;
end; { TResults.ReadShortstring }

procedure TResults.ReadString(var str: string);
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
procedure TResults.WriteInt64(i64: int64);   begin resFile.BlockWriteUnsafe(i64,SizeOf(int64)); end;

procedure TResults.WriteString(str: string);
begin
  WriteInt(Length(str));
  if Length(str) > 0 then
    resFile.BlockWriteUnsafe(str[1],Length(str)+1); // write zero-terminated
end; { TResults.WriteString }

procedure TResults.CheckTag(tag: byte);
var
  fileTag: byte;
begin
  ReadTag(fileTag);
  if tag <> fileTag then raise Exception.Create('File corrupt!');
end; { TResults.CheckTag }

procedure TResults.LoadTables;
var
  i,j     : integer;
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
      SetLength(peRecLevel,1);         // placeholder for a unused entry
    end;
  end;
  SetLength(resCallGraph,elements+1,elements+1); // resCallGraph[0,x], resCallGraph[x,0] = unused (to match indexes in resProcedure)
  for i := Low(resCallGraph) to High(resCallGraph) do
    for j := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do
      resCallGraph[i,j] := nil;
  for i := 1 to High(resClasses) do
    with resClasses[i] do
      if ceFirstLn = MaxLongint then ceFirstLn := -1;
end; { TResult.LoadTables }

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
  if proxy = nil then raise Exception.Create('gppResults.TResults.ExitProcPkt: Entry not found!');
  ExitProc(proxy,parent,pkt);
  proxy.Destroy;
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
    if (rpTag = PR_ENDDATA) or (rpTag = PR_ENDCALIB) then Result := false
    else begin
      ReadThread(rpThread);
      ReadID(rpProcID);
      ReadTicks(rpMeasure1);
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
begin
  // update resProcedures, resActiveProcs, and resCallGraph
  // other structures will be recalculated at the end
  with resProcedures[proxy.ppProcID] do begin
    if assigned(parent)
      then parent.ppChildTime := parent.ppChildTime + proxy.ppTotalTime + proxy.ppChildTime;
    Inc(peProcTime[proxy.ppThreadID],proxy.ppTotalTime);
    if proxy.ppTotalTime < peProcTimeMin[proxy.ppThreadID] then
      peProcTimeMin[proxy.ppThreadID] := proxy.ppTotalTime;
    if proxy.ppTotalTime > peProcTimeMax[proxy.ppThreadID] then
      peProcTimeMax[proxy.ppThreadID] := proxy.ppTotalTime;
    if peRecLevel[proxy.ppThreadID] = 0 then begin
      Inc(peProcChildTime[proxy.ppThreadID],proxy.ppChildTime);
      Inc(peProcChildTime[proxy.ppThreadID],proxy.ppTotalTime);
    end;
    Inc(peProcCnt[proxy.ppThreadID],1);
  end;
//  resThreads[proxy.ppThreadID].teActiveProcs.UpdateRunningTime(proxy);        //gp 1999-09-28 - not needed anymore
  if assigned(parent) then begin
    AllocCGEntry(parent.ppProcID,proxy.ppProcID,High(resThreads));
    with resCallGraph[parent.ppProcID,proxy.ppProcID]^ do begin
      Inc(cgeProcTime[proxy.ppThreadID],proxy.ppTotalTime);
      Inc(cgeProcTime[0],proxy.ppTotalTime);
      if proxy.ppTotalTime < cgeProcTimeMin[proxy.ppThreadID] then
        cgeProcTimeMin[proxy.ppThreadID] := proxy.ppTotalTime;
      if proxy.ppTotalTime > cgeProcTimeMax[proxy.ppThreadID] then
        cgeProcTimeMax[proxy.ppThreadID] := proxy.ppTotalTime;
      if resProcedures[proxy.ppProcID].peRecLevel[proxy.ppThreadID] = 0 then begin
        Inc(cgeProcChildTime[proxy.ppThreadID],proxy.ppChildTime);
        Inc(cgeProcChildTime[proxy.ppThreadID],proxy.ppTotalTime);
      end
{begin}                                                                         //gp 1999-09-28
// Very dirty hack but it looks like it is OK. Actually I need a proxy mechanism at callgraph level, too.
      else if (resProcedures[proxy.ppProcID].peRecLevel[proxy.ppThreadID] = 1) and
              (parent.ppProcID = proxy.ppProcID) then begin
        Inc(cgeProcChildTime[proxy.ppThreadID],proxy.ppChildTime);
        Inc(cgeProcChildTime[proxy.ppThreadID],proxy.ppTotalTime);
      end;
{end}                                                                           //gp 1999-09-28
      Inc(cgeProcCnt[proxy.ppThreadID],1);
      Inc(cgeProcCnt[0],1);
    end;
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
  i,j  : integer;
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
  for i := Low(resProcedures) to High(resProcedures) do begin
    with resProcedures[i] do begin
      SetLength(peProcTime,numth);
      SetLength(peProcTimeMin,numth);
      SetLength(peProcTimeMax,numth);
      SetLength(peProcTimeAvg,numth);
      SetLength(peProcChildTime,numth);
      SetLength(peProcCnt,numth);
      SetLength(peRecLevel,numth);
      peProcTime[numth-1]      := 0;
      peProcTimeMin[numth-1]   := High(int64);
      peProcTimeMax[numth-1]   := 0;
      peProcTimeAvg[numth-1]   := 0;
      peProcChildTime[numth-1] := 0;
      peProcCnt[numth-1]       := 0;
      peRecLevel[numth-1]      := 0;
    end;
  end;
  // resize resCallGraph
  for i := Low(resCallGraph) to High(resCallGraph) do
    for j := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do
      if assigned(resCallGraph[i,j]) then
        with resCallGraph[i,j]^ do begin
          SetLength(cgeProcTime,numth);
          SetLength(cgeProcTimeMin,numth);
          SetLength(cgeProcTimeMax,numth);
          SetLength(cgeProcTimeAvg,numth);
          SetLength(cgeProcChildTime,numth);
          SetLength(cgeProcCnt,numth);
//          SetLength(cgeRecLevel,numth);
          cgeProcTime[numth-1]      := 0;
          cgeProcTimeMin[numth-1]   := High(int64);
          cgeProcTimeMax[numth-1]   := 0;
          cgeProcTimeAvg[numth-1]   := 0;
          cgeProcChildTime[numth-1] := 0;
          cgeProcCnt[numth-1]       := 0;
//          cgeRecLevel[numth-1]      := 0;
        end;
  Result := numth-1;
end; { TResults.ThCreate }

procedure TResults.RecalcTimes;
var
  i,j,k: integer;
  numth: integer;
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
      if (not IsDigest) or (DigestVer < 2) then begin
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
  // resCallGraph
  for i := Low(resCallGraph)+1 to High(resCallGraph) do begin
    for k := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do begin
      if assigned(resCallGraph[i,k]) then begin
        with resCallGraph[i,k]^ do begin
          for j := Low(cgeProcTime)+1 to High(cgeProcTime) do begin
            if cgeProcTimeMin[j] = High(int64) then cgeProcTimeMin[j] := 0;
            if cgeProcCnt[j] = 0 then cgeProcTimeAvg[j] := 0
                                 else cgeProcTimeAvg[j] := cgeProcTime[j] div cgeProcCnt[j];
          end;
        end; // with
      end; // if
    end; // for
  end; // for
  for i := Low(resCallGraph)+1 to High(resCallGraph) do begin
    AllocCGEntry(i,0,High(resThreads));
    resCallGraph[i,0]^.cgeProcTime[0] := 0;
    for j := Low(resThreads)+1 to High(resThreads) do begin
      resCallGraph[i,0]^.cgeProcTime[j] := 0;
      for k := Low(resCallGraph[i]) to High(resCallGraph[i]) do begin
        if assigned(resCallGraph[i,k]) then begin
          Inc(resCallGraph[i,0]^.cgeProcTime[j],resCallGraph[i,k]^.cgeProcTime[j]);
          Inc(resCallGraph[i,0]^.cgeProcTime[0],resCallGraph[i,k]^.cgeProcTime[j]);
        end; // if
      end; // for
    end; // for
  end; // for
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
  Inc(resProcedures[proxy.ppProcID].peRecLevel[proxy.ppThreadID]);
end;

procedure TResults.ExitProc(proxy,parent: TProcProxy; pkt: TResPacket);
begin
  // decrement recursion level
  // remove proxy object from active procedure queue
  // update proxy end time
  // update time in procedure, class, unit and thread objects
  // update time in active procedures from the same thread
  // update dead time in all active procedures
  Dec(resProcedures[proxy.ppProcID].peRecLevel[proxy.ppThreadID]);
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
    if start.rpTag = PR_ENDCALIB then raise Exception.Create('File corrupt!');
    ReadPacket(stop);
    if stop.rpTag = PR_ENDCALIB then raise Exception.Create('File corrupt!');
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
      if cnt > calCnt then raise Exception.Create('File corrupt!');
      time  := time + time2;
      time2 := dtime;
    end;
  end;
  resNullOverhead := Round(NULL_ACCURACY*time/(cnt-1));
  resNullError    := resNullOverhead mod NULL_ACCURACY;
  resNullOverhead := resNullOverhead div NULL_ACCURACY;
  resNullErrorAcc := 0;
end; { TResults.LoadCalibration }

procedure TResults.SaveDigest(fileName: string);
var
  i,j,k: integer;
begin
  resFile := TGpHugeFile.CreateEx(fileName,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  resFile.RewriteBuffered(1);
  try
    WriteTag(PR_DIGEST);
    WriteTag(PR_DIGESTVER);
    WriteInt(PRF_DIGESTVER);
    resPrfDigestVer := PRF_DIGESTVER;
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
        for j := Low(ueTotalTime) to High(ueTotalTime) do WriteInt64(ueTotalTime[j]);
        WriteInt(High(ueTotalCnt)-Low(ueTotalCnt)+1);
        for j := Low(ueTotalCnt) to High(ueTotalCnt) do WriteInt(ueTotalCnt[j]);
      end;
    WriteTag(PR_DIGCLASSES);
    WriteInt(High(resClasses)-Low(resClasses)+1);
    for i := Low(resClasses) to High(resClasses) do
      with resClasses[i] do begin
        WriteString(ceName);
        WriteInt(ceUID);
        WriteInt(ceFirstLn);
        WriteInt(High(ceTotalTime)-Low(ceTotalTime)+1);
        for j := Low(ceTotalTime) to High(ceTotalTime) do WriteInt64(ceTotalTime[j]);
        WriteInt(High(ceTotalCnt)-Low(ceTotalCnt)+1);
        for j := Low(ceTotalCnt) to High(ceTotalCnt) do WriteInt(ceTotalCnt[j]);
      end;
    WriteTag(PR_DIGPROCS);
    WriteInt(High(resProcedures)-Low(resProcedures)+1);
    for i := Low(resProcedures) to High(resProcedures) do
      with resProcedures[i] do begin
        WriteString(peName);
        WriteInt(peUID);
        WriteInt(peCID);
        WriteInt(peFirstLn);
        WriteInt(High(peProcTime)-Low(peProcTime)+1);
        for j := Low(peProcTime) to High(peProcTime) do WriteInt64(peProcTime[j]);
        WriteInt(High(peProcTimeMin)-Low(peProcTimeMin)+1);
        for j := Low(peProcTimeMin) to High(peProcTimeMin) do WriteInt64(peProcTimeMin[j]);
        WriteInt(High(peProcTimeMax)-Low(peProcTimeMax)+1);
        for j := Low(peProcTimeMax) to High(peProcTimeMax) do WriteInt64(peProcTimeMax[j]);
        WriteInt(High(peProcChildTime)-Low(peProcChildTime)+1);
        for j := Low(peProcChildTime) to High(peProcChildTime) do WriteInt64(peProcChildTime[j]);
        WriteInt(High(peProcCnt)-Low(peProcCnt)+1);
        for j := Low(peProcCnt) to High(peProcCnt) do WriteInt(peProcCnt[j]);
        WriteInt(High(peProcTimeAvg)-Low(peProcTimeAvg)+1);
        for j := Low(peProcTimeAvg) to High(peProcTimeAvg) do WriteInt64(peProcTimeAvg[j]);
      end;
    WriteTag(PR_DIGCALLG);
    for i := Low(resCallGraph) to High(resCallGraph) do
      for k := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do begin
        if assigned(resCallGraph[i,k]) then begin
          WriteInt(i);
          WriteInt(k);
          with resCallGraph[i,k]^ do begin
            WriteInt(High(cgeProcTime)-Low(cgeProcTime)+1);
            for j := Low(cgeProcTime) to High(cgeProcTime) do WriteInt64(cgeProcTime[j]);
            for j := Low(cgeProcTimeMin) to High(cgeProcTimeMin) do WriteInt64(cgeProcTimeMin[j]);
            for j := Low(cgeProcTimeMax) to High(cgeProcTimeMax) do WriteInt64(cgeProcTimeMax[j]);
            for j := Low(cgeProcChildTime) to High(cgeProcChildTime) do WriteInt64(cgeProcChildTime[j]);
            for j := Low(cgeProcCnt) to High(cgeProcCnt) do WriteInt(cgeProcCnt[j]);
            for j := Low(cgeProcTimeAvg) to High(cgeProcTimeAvg) do WriteInt64(cgeProcTimeAvg[j]);
          end;
        end;
      end;
    WriteInt(PR_DIGENDCG);
    // dump call graph
    WriteTag(PR_ENDDIGEST);
  finally resFile.Free; end;
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

  procedure CheckPerc;
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
  end; { CheckPerc }

begin
  fpstart  := resFile.FilePos;
  filesz   := resFile.FileSize;
  lastPerc := -1;
  cnt      := 0;
  repeat
    CheckPerc;
    ReadTag(tag);
    case tag of
      PR_DIGFREQ: ReadInt64(resFrequency);
      PR_DIGTHREADS: begin
        ReadInt(num);
        SetLength(resThreads,num);
        for i := Low(resThreads) to High(resThreads) do
          with resThreads[i] do begin
            CheckPerc;
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
            CheckPerc;
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
            CheckPerc;
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
        SetLength(resCallGraph,num,num);
        for i := Low(resCallGraph) to High(resCallGraph) do
          for j := Low(resCallGraph[Low(resCallGraph)]) to High(resCallGraph[Low(resCallGraph)]) do
            resCallGraph[i,j] := nil;
        for i := Low(resProcedures) to High(resProcedures) do
          with resProcedures[i] do begin
            CheckPerc;
            ReadString(peName);
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
            if DigestVer < 1 then SetLength(peProcTimeAvg,num);
            ReadInt(num);
            SetLength(peProcChildTime,num);
            for j := Low(peProcChildTime) to High(peProcChildTime) do ReadInt64(peProcChildTime[j]);
            ReadInt(num);
            SetLength(peProcCnt,num);
            for j := Low(peProcCnt) to High(peProcCnt) do ReadInt(peProcCnt[j]);
            if DigestVer >= 1 then begin
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
          AllocCGEntry(i,j,num);
          with resCallGraph[i,j]^ do begin
            SetLength(cgeProcTime,num);
            for j := Low(cgeProcTime) to High(cgeProcTime) do ReadInt64(cgeProcTime[j]);
            SetLength(cgeProcTimeMin,num);
            for j := Low(cgeProcTimeMin) to High(cgeProcTimeMin) do ReadInt64(cgeProcTimeMin[j]);
            SetLength(cgeProcTimeMax,num);
            for j := Low(cgeProcTimeMax) to High(cgeProcTimeMax) do ReadInt64(cgeProcTimeMax[j]);
            SetLength(cgeProcChildTime,num);
            for j := Low(cgeProcChildTime) to High(cgeProcChildTime) do ReadInt64(cgeProcChildTime[j]);
            SetLength(cgeProcCnt,num);
            for j := Low(cgeProcCnt) to High(cgeProcCnt) do ReadInt(cgeProcCnt[j]);
            SetLength(cgeProcTimeAvg,num);
            for j := Low(cgeProcTimeAvg) to High(cgeProcTimeAvg) do ReadInt64(cgeProcTimeAvg[j]);
          end;
        until false;
      end; // PR_DIGCALLG
    end; // case
  until tag = PR_ENDDIGEST;
end; { TResults.LoadDigest }

procedure TResults.Rename(fileName: string);
begin
  resName := fileName;
end;

procedure TResults.AllocCGEntry(i, j, threads: integer);
begin
  if resCallGraph[i,j] = nil then begin
    New(resCallGraph[i,j]);
    with resCallGraph[i,j]^ do begin
      SetLength(cgeProcTime,threads+1);
      SetLength(cgeProcTimeMin,threads+1);
      SetLength(cgeProcTimeMax,threads+1);
      SetLength(cgeProcTimeAvg,threads+1);
      SetLength(cgeProcChildTime,threads+1);
      SetLength(cgeProcCnt,threads+1);
//      SetLength(cgeRecLevel,threads+1);
    end;
  end;
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

{ TProcProxy }

constructor TProcProxy.Create(threadID, procID: integer);
begin
  inherited Create;
  ppThreadID  := threadID;
  ppProcID    := procID;
  ppDeadTime  := 0;
  ppStartTime := 0;
  ppTotalTime := 0;
  ppChildTime := 0;
end; { TProcProxy.Create }

destructor TProcProxy.Destroy;
begin
  inherited Destroy;
end; { TProcProxy.Destroy }

procedure TProcProxy.Start(pkt: TResPacket);
begin
  ppStartTime := pkt.rpMeasure2;
end; { TProcProxy.Start }

procedure TProcProxy.Stop(var pkt: TResPacket);
begin
  ppTotalTime := pkt.rpMeasure1-ppStartTime - ppDeadTime - ppChildTime - pkt.rpNullOverhead;
  pkt.rpNullOverhead := 2*pkt.rpNullOverhead;
  if ppTotalTime < 0 then begin // overcorrected
    ppTotalTime := 0;
    pkt.rpNullOverhead := pkt.rpNullOverhead + ppTotalTime;
  end;
end; { TProcProxy.Stop }

procedure TProcProxy.UpdateDeadTime(pkt: TResPacket);
begin
  ppDeadTime := ppDeadTime + (pkt.rpMeasure2-pkt.rpMeasure1) + pkt.rpNullOverhead;
end; { TProcProxy.UpdateDeadTime }

procedure TProcProxy.UpdateRunningTime(proxy: TProcProxy);
begin
// don't need this anymore
end; { TProcProxy.UpdateRunningTime }

{ TActiveProcList }

procedure TActiveProcList.Append(proxy: TProcProxy);
begin
  if aplCount > High(aplList) then SetLength(aplList,aplCount+APL_QUANTUM);
  aplList[aplCount] := proxy;
  Inc(aplCount);
end; { TActiveProcList.Append }

constructor TActiveProcList.Create;
begin
  SetLength(aplList,APL_QUANTUM); 
  aplCount := 0;
end; { TActiveProcList.Create }

destructor TActiveProcList.Destroy;
begin
  SetLength(aplList,0); 
  inherited Destroy;
end; { TActiveProcList.Destroy }

procedure TActiveProcList.LocateLast(procID: integer; var this,parent: TProcProxy);
var
  i: integer;
begin
  for i := aplCount-1 downto Low(aplList) do begin
    if aplList[i].ppProcID = procID then begin
      this := aplList[i];
      if i > Low(aplList) then parent := aplList[i-1]
                          else parent := nil;
      Exit;
    end;
  end;
  this   := nil;
  parent := nil;
end; { TActiveProcList.LocateLast }

procedure TActiveProcList.Remove(proxy: TProcProxy);
var
  i: integer;
begin
  for i := aplCount-1 downto Low(aplList) do begin // should be the last, but ...
    if aplList[i] = proxy then begin
      aplCount := i;
      Exit;
    end;
  end;
  raise Exception.Create('gppResults.TActiveProcList.Remove: Entry not found!');
end; { TActiveProcList.Remove }

procedure TActiveProcList.UpdateDeadTime(pkt: TResPacket);
var
  i: integer;
begin
  for i := aplCount-1 downto Low(aplList) do
    aplList[i].UpdateDeadTime(pkt);
end; { TActiveProcList.UpdateDeadTime }

procedure TActiveProcList.UpdateRunningTime(proxy: TProcProxy);
//var
//  i: integer;
begin
//  for i := aplCount-1 downto Low(aplList) do
//    aplList[i].UpdateRunningTime(proxy);
end; { TActiveProcList.UpdateRunningTime }

end.
