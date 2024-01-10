unit gppResults.procs;

interface

uses
  System.Generics.Collections,
  gppResults.types;

type

  TProcProxy = class
  public
    ppThreadID    : integer;
    /// <summary>
    /// the procedure id
    /// </summary>
    ppProcID      : integer;
    ppDeadTime    : int64;
    ppStartTime   : int64;
    ppTotalTime   : int64;
    ppChildTime   : int64;
    ppStartMem    : Cardinal;
    ppEndMem    : Cardinal;
    ppDiffMem   : Cardinal;
    ppDiffMemChildren : Cardinal;
    constructor Create(threadID, procID: integer);
    destructor  Destroy; override;
    procedure   Start(pkt: TResPacket);
    procedure   Stop(var pkt: TResPacket);
    procedure   UpdateDeadTime(pkt: TResPacket);
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
    procedure   LocateLast(procID: integer; var this,parent: TProcProxy);
  end;

implementation

uses
  Sysutils;


{ TProcProxy }

constructor TProcProxy.Create(threadID, procID: integer);
begin
  inherited Create;
  ppThreadID  := threadID;
  ppProcID    := procID;
end;

destructor TProcProxy.Destroy;
begin
  inherited Destroy;
end;

procedure TProcProxy.Start(pkt: TResPacket);
begin
  ppStartTime := pkt.rpMeasure2;
  ppStartMem := pkt.rpMemWorkingSize;
end;

procedure TProcProxy.Stop(var pkt: TResPacket);
begin
  ppEndMem := pkt.rpMemWorkingSize;
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

procedure TActiveProcList.LocateLast(procID: integer; var this,parent: TProcProxy);
var
  i: integer;
begin
  if (fAplList <> nil) and (fAplList.Count >= 0) then begin
    for i := fAplList.Count-1 downto 0 do
    begin
      if fAplList[i].ppProcID = procID then
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
end;

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

end.
