unit gppResults.procs;

interface

uses
  System.Generics.Collections,
  gppResults.types;

type

  TProcProxy = class
  private
    ppThreadID    : Cardinal;
    ppProcID      : Cardinal;
    ppDeadTime    : int64;
    ppStartTime   : int64;
    ppTotalTime   : int64;
    ppChildTime   : int64;
    ppTotalMem    : Cardinal;
  public
    constructor Create(const aThreadID, aProcID: Cardinal);
    destructor  Destroy; override;
    procedure   Start(const pkt: TResPacket; const memPkt: TResMemPacket);  virtual;
    procedure   Stop(var pkt: TResPacket; const memPkt: TResMemPacket); virtual;
    procedure   UpdateDeadTime(pkt: TResPacket);

    property ThreadID : Cardinal read ppThreadID;
    property ProcId : Cardinal read ppProcID;
    property DeadTime : int64 read ppDeadTime;
    property StartTime : int64 read ppStartTime;
    property TotalTime : int64 read ppTotalTime;
    property ChildTime : int64 read ppChildTime write ppChildTime;
    property TotalMem : Cardinal read ppTotalMem;

  end;


  TProcWithMemProxy = class(TProcProxy)
  private
    ppStartMem    : Cardinal;
    ppEndMem    : Cardinal;
  protected
  public
    procedure Start(const pkt: TResPacket; const memPkt: TResMemPacket);  override;
    procedure Stop(var pkt: TResPacket; const memPkt: TResMemPacket); override;
    property StartMem : Cardinal read ppStartMem write ppStartMem;
    property EndMem : Cardinal read ppEndMem write ppEndMem;
  end;

  TActiveProcList = class
  private
    fAplList : TList<TProcProxy>;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   UpdateDeadTime(pkt: TResPacket);
    procedure   Append(proxy: TProcProxy);
    procedure   Remove(proxy: TProcProxy);
    procedure   LocateLast(const aProcID: Cardinal; var this,parent: TProcProxy); overload;
  end;

  TMeasurePointProxy = class(TProcProxy)
  private
    fMeasurePointID : String;
  public
    constructor Create(const aThreadID, aProcID: Cardinal; const aMeasurePointID : String);
    property MeasurePointID : String read fMeasurePointID;
  end;


  TMeasurePointWithMemProxy = class(TProcWithMemProxy)
  private
    fMeasurePointID : String;
  public
    constructor Create(const aThreadID, aProcID: Cardinal; const aMeasurePointID : String);
    property MeasurePointID : String read fMeasurePointID;
  end;

implementation

uses
  Sysutils;


{ TProcProxy }

constructor TProcProxy.Create(const aThreadID, aProcID: Cardinal);
begin
  inherited Create;
  ppThreadID  := aThreadID;
  ppProcID    := aProcID;
end;

destructor TProcProxy.Destroy;
begin
  inherited Destroy;
end;

procedure TProcProxy.Start(const pkt: TResPacket; const memPkt: TResMemPacket);
begin
  ppStartTime := pkt.rpMeasure2;
end;

procedure TProcProxy.Stop(var pkt: TResPacket; const memPkt: TResMemPacket);
begin
  ppTotalTime := pkt.rpMeasure1-ppStartTime - ppDeadTime - ppChildTime - pkt.rpNullOverhead;
  pkt.rpNullOverhead := 2*pkt.rpNullOverhead;
  if ppTotalTime < 0 then
  begin // overcorrected
    ppTotalTime := 0;
    pkt.rpNullOverhead := pkt.rpNullOverhead + ppTotalTime;
  end;
end;

procedure TProcProxy.UpdateDeadTime(pkt: TResPacket);
begin
  ppDeadTime := ppDeadTime + (pkt.rpMeasure2-pkt.rpMeasure1) + pkt.rpNullOverhead;
end;

{ TActiveProcList }

procedure TActiveProcList.Append(proxy: TProcProxy);
begin
  fAplList.Add(proxy);
end;

constructor TActiveProcList.Create;
begin
  fAplList := TList<TProcProxy>.Create();
  fAplList.Capacity := 16;
end;

destructor TActiveProcList.Destroy;
begin
  fAplList.free;
  inherited Destroy;
end;


procedure TActiveProcList.LocateLast(const aProcId: Cardinal; var this,parent: TProcProxy);
var
  i: integer;
begin
   if (fAplList <> nil) and (fAplList.Count >= 0) then begin
    for i := fAplList.Count-1 downto 0 do
    begin
      if fAplList[i].ppProcID = aProcId then
      begin
        this := fAplList[i];
        if i > 0 then
          parent := fAplList[i-1]
        else
          parent := nil;
        Exit;
      end;
    end;
  end;
  this   := nil;
  parent := nil;
end; { TActiveProcList.LocateLast }



procedure TActiveProcList.Remove(proxy: TProcProxy);
var
  lFoundIndex: integer;
begin
  lFoundIndex := fAplList.Remove(proxy);
  if lFoundIndex < 0 then
    raise Exception.Create('gppResults.TActiveProcList.Remove: Entry not found!');
end;

procedure TActiveProcList.UpdateDeadTime(pkt: TResPacket);
var
  i: integer;
begin
  for i := fAplList.Count-1 downto 0 do
    fAplList[i].UpdateDeadTime(pkt);
end;


{ TMeasurePointProxy }

constructor TMeasurePointProxy.Create(const aThreadID, aProcID: Cardinal;const aMeasurePointID : String);
begin
  inherited Create(aThreadID, aProcID);
  ppThreadID  := aThreadID;
  fMeasurePointID := aMeasurePointID;
end; { TMeasurePointProxy.Create }



{ TMeasurePointWithMemProxy }

constructor TMeasurePointWithMemProxy.Create(const aThreadID, aProcID: Cardinal; const aMeasurePointID: String);
begin
  inherited Create(aThreadID, aProcID);
  ppThreadID  := aThreadID;
  fMeasurePointID := aMeasurePointID;
end;

{ TProcWithMemProxy }

procedure TProcWithMemProxy.Start(const pkt: TResPacket; const memPkt: TResMemPacket);
begin
  inherited;
  ppStartMem := memPkt.rpMemWorkingSize;
end;

procedure TProcWithMemProxy.Stop(var pkt: TResPacket; const memPkt: TResMemPacket);
begin
  inherited;
  ppEndMem := memPkt.rpMemWorkingSize;
  ppTotalMem := ppEndMem-ppStartMem;
end;

end.
