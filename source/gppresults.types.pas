unit gppresults.types;

interface

type
  TProgressCallback = function (percent: integer): boolean of object;
  TResPacket = record
  public
    rpTag         : byte;
    rpThread      : integer;
    rpProcID      : integer;
    rpMeasure1    : int64;
    rpMeasure2    : int64;
    rpNullOverhead: int64;
    rpMeasurePointID : TGUID;
  end;

  TMeasurePointEntry = record
  public
    mpePkt : TResPacket;
    mpeName : AnsiString;
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

    constructor Create(const aThreadID, aProcID: integer);
    destructor  Destroy; override;
    procedure   Start(pkt: TResPacket);  virtual;
    procedure   Stop(var pkt: TResPacket); virtual;
    procedure   UpdateDeadTime(pkt: TResPacket);

    property ThreadID : Integer read ppThreadID;
    property ProcId : integer read ppProcID;
    property DeadTime : int64 read ppDeadTime;
    property StartTime : int64 read ppStartTime;
    property TotalTime : int64 read ppTotalTime;
    property ChildTime : int64 read ppChildTime write ppChildTime;
  end;

  TMeasurePointProxy = class(TProcProxy)
  private
    fMeasurePointGuid : TGUID;
  public
    constructor Create(const aThreadID: integer; const aMeasurePointGuid : TGUID);
    destructor  Destroy; override;

    property MeasurePointGuid : TGUID read fMeasurePointGuid;
  end;

  TActiveProcList = class
  private
    aplList : array of TProcProxy;
    aplCount: integer;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure   UpdateDeadTime(pkt: TResPacket);
    procedure   Append(proxy: TProcProxy);
    procedure   Remove(proxy: TProcProxy);
    procedure   LocateLast(const procID: integer; var this,parent: TProcProxy); overload;
    procedure   LocateLast(const aMeasurePointGuid: TGUID; var this,parent: TProcProxy); overload;

  end;


implementation

uses
  System.Classes, System.Sysutils;

const
  APL_QUANTUM   = 10;


{ TProcProxy }

constructor TProcProxy.Create(const aThreadID, aProcID: integer);
begin
  inherited Create;
  ppThreadID  := aThreadID;
  ppProcID    := aProcID;
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

{ TMeasurePointProxy }

constructor TMeasurePointProxy.Create(const aThreadID: integer; const aMeasurePointGuid : TGUID);
begin
  inherited Create(aThreadID, 0);
  ppThreadID  := aThreadID;
  fMeasurePointGuid := aMeasurePointGuid;
  ppDeadTime  := 0;
  ppStartTime := 0;
  ppTotalTime := 0;
  ppChildTime := 0;
end; { TMeasurePointProxy.Create }

destructor TMeasurePointProxy.Destroy;
begin
  inherited Destroy;
end; { TMeasurePointProxy.Destroy }


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

procedure TActiveProcList.LocateLast(const procID: integer; var this,parent: TProcProxy);
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

procedure TActiveProcList.LocateLast(const aMeasurePointGuid: TGUID; var this,parent: TProcProxy);
var
  i: integer;
  lProxy : TProcProxy;
  lMpProxy : TMeasurePointProxy;
begin
  for i := aplCount-1 downto Low(aplList) do
  begin
    lProxy := aplList[i];
    if lProxy is TMeasurePointProxy then
    begin
      lMpProxy := lProxy as TMeasurePointProxy;
      if lMpProxy.MeasurePointGuid = aMeasurePointGuid then begin
        this := lMpProxy;
        if i > Low(aplList) then
          parent := aplList[i-1]
        else
          parent := nil;
        Exit;
      end;

    end
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
end.
