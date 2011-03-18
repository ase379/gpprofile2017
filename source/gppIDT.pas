{$I OPTIONS.INC}

unit gppIDT;

interface

uses GpString;

type
  TIDTable = class
  private
    idUnits: pointer;
    idClass: pointer;
    idProcs: pointer;
  public
    constructor Create;
    destructor  Destroy; override;
    function    ConstructName(unitName, unitFullName, procName: string; firstLn: integer): integer;
    procedure   Dump(fileName: string);
  end;

implementation

uses
  Windows,
  SysUtils,
  IniFiles,
  EZDSLBSE,
  EZDSLSUP,
  EZDSLSKP,
  GpProfH,
  GpHugeF,
  gppCommon;

type
  TIDTE = class
    eName: PChar;
    eID  : integer;
    constructor Create(name: string; id: integer);
    destructor  Destroy; override;
  end;

  TIDTUE = class(TIDTE)
    eQual: PChar;
    constructor Create(name, qual: string; id: integer); reintroduce;
    destructor  Destroy; override;
  end;

  TIDTCE = class(TIDTE)
    eUID: integer;
    constructor Create(name: string; id, uid: integer);
  end;

  TIDTPE = class(TIDTE)
    eUID    : integer;
    eCID    : integer;
    eFirstLn: integer;
    constructor Create(name: string; id, uid, cid, firstLn: integer);
  end;

  TIDTU = class(TSkipList)
    constructor Create; reintroduce;
    function    Insert(key, qual: string): integer;
    procedure   Dump(var f: TGpHugeFile);
  private
    idCnt : integer;
  end;

  TIDTC = class(TSkipList)
    constructor Create; reintroduce;
    function    Insert(key: string; uid: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
  private
    idCnt : integer;
  end;

  TIDTP = class(TSkipList)
    constructor Create; reintroduce;
    function    Insert(key: string; uid, cid, firstLn: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
    procedure   WriteProcSize(fileName: string);
  private
    idCnt: integer;
  end;

function TIDTCompare(data1, data2: pointer): integer;
begin
  Result := StrIComp(TIDTE(data1).eName,TIDTE(data2).eName);
end; { TIDTCompare }

function TIDTIDCompare(data1, data2: pointer): integer;
begin
  Result := TIDTE(data1).eID - TIDTE(data2).eID;
end; { TIDTCompare }

procedure TIDTUDispose(data: pointer);
begin
  TIDTUE(data).Destroy;
end; { TIDTUDispose }

procedure TIDTCDispose(data: pointer);
begin
  TIDTCE(data).Destroy;
end; { TIDTCDispose }

procedure TIDTPDispose(data: pointer);
begin
  TIDTPE(data).Destroy;
end; { TIDTPDispose }

{ TIDTable }

function TIDTable.ConstructName(unitName, unitFullName, procName: string; firstLn: integer): integer;
var
  unitID: integer;
  clasID: integer;
  p     : integer;
begin
  unitID := TIDTU(idUnits).Insert(unitName, unitFullName);
  p := Pos('.',procName);
  if p > 0 then clasID := TIDTC(idClass).Insert(unitName+'.'+First(procName,p-1),unitID)
           else clasID := TIDTC(idClass).Insert(unitName+'.<>',unitID); // classless
  Result := TIDTP(idProcs).Insert(unitName+'.'+procName,unitID,clasID,firstLn);
end;

constructor TIDTable.Create;
begin
  idUnits := pointer(TIDTU.Create);
  idClass := pointer(TIDTC.Create);
  idProcs := pointer(TIDTP.Create);
  inherited Create;
end;

destructor TIDTable.Destroy;
begin
  inherited Destroy;
  TIDTU(idUnits).Free;
  TIDTC(idClass).Free;
  TIDTP(idProcs).Free;
end;

procedure TIDTable.Dump(fileName: string);
var
  fnm: string;
  f  : TGpHugeFile;
begin
  DeleteFile(fileName);
  fnm := ChangeFileExt(fileName,'.gpd');
  f := TGpHugeFile.CreateEx(fnm,FILE_FLAG_SEQUENTIAL_SCAN+FILE_ATTRIBUTE_NORMAL);
  try
    f.RewriteBuffered(1);
    TIDTU(idUnits).Dump(f);
    TIDTC(idClass).Dump(f);
    TIDTP(idProcs).Dump(f);
  finally f.Free; end;
  with TIniFile.Create(fileName) do begin
    try WriteString('IDTables','TableName',fnm);
    finally Free; end;
  end;
  TIDTP(idProcs).WriteProcSize(fileName);
end;

{ TIDTU }

constructor TIDTU.Create;
begin
  inherited Create(true);
  Compare     := TIDTCompare;
  DisposeData := TIDTUDispose;
  idCnt       := 1;
end;

procedure WriteTag   (f: TGpHugeFile; tag: byte);    begin f.BlockWriteUnsafe(Tag, Sizeof(Byte)); end;
procedure WriteInt   (f: TGpHugeFile; int: integer); begin f.BlockWriteUnsafe(Int, Sizeof(Integer)); end;

procedure WriteString(f: TGpHugeFile; str: string);
begin
  WriteInt(f,Length(str));
  if Length(str) > 0 then
    f.BlockWriteUnsafe(str[1],Length(str)+1); // write zero-terminated
end; { WriteString }

procedure TIDTU.Dump(var f: TGpHugeFile);
var
  cursor: TListCursor;
begin
  Compare := TIDTIDCompare;
  WriteTag(f,PR_UNITTABLE);
  WriteInt(f,Count);
  cursor := Next(SetBeforeFirst);
  while not IsAfterLast(cursor) do begin
    with TIDTUE(Examine(cursor)) do begin
      WriteString(f,eName);
      WriteString(f,eQual);
    end;
    cursor := Next(cursor);
  end;
end;

function TIDTU.Insert(key, qual: string): integer;
var
  p     : TIDTUE;
  cursor: TListCursor;
begin
  p := TIDTUE.Create(key,qual,idCnt);
  if not Search(cursor,p) then begin
    inherited Insert(cursor,p);
    Inc(idCnt);
  end
  else p.Destroy;
  Result := TIDTUE(Examine(cursor)).eID;
end;

{ TIDTC }

constructor TIDTC.Create;
begin
  inherited Create(true);
  Compare     := TIDTCompare;
  DisposeData := TIDTCDispose;
  idCnt       := 1;
end;

procedure TIDTC.Dump(var f: TGpHugeFile);
var
  cursor: TListCursor;
begin
  Compare := TIDTIDCompare;
  WriteTag(f,PR_CLASSTABLE);
  WriteInt(f,Count);
  cursor := Next(SetBeforeFirst);
  while not IsAfterLast(cursor) do begin
    with TIDTCE(Examine(cursor)) do begin
      WriteString(f,eName);
      WriteInt(f,eUID);
    end;
    cursor := Next(cursor);
  end;
end;

function TIDTC.Insert(key: string; uid: integer): integer;
var
  p     : TIDTCE;
  cursor: TListCursor;
begin
  p := TIDTCE.Create(key,idCnt,uid);
  if not Search(cursor,p) then begin
    inherited Insert(cursor,p);
    Inc(idCnt);
  end
  else p.Destroy;
  Result := TIDTCE(Examine(cursor)).eID;
end;

{ TIDTP }

constructor TIDTP.Create;
begin
  inherited Create(true);
  Compare     := TIDTCompare;
  DisposeData := TIDTPDispose;
  idCnt       := 1;
end;

procedure TIDTP.Dump(var f: TGpHugeFile);
var
  cursor: TListCursor;
  p: TIDTPE;
begin
  Compare := TIDTIDCompare;
  WriteTag(f,PR_PROCTABLE);
  WriteInt(f,Count);
  cursor := Next(SetBeforeFirst);
  while not IsAfterLast(cursor) do begin
    p := TIDTPE(Examine(cursor));
    with p do begin
      WriteString(f,eName);
      WriteInt(f,eUID);
      WriteInt(f,eCID);
      WriteInt(f,eFirstLn);
    end;
    cursor := Next(cursor);
  end;
end;

function TIDTP.Insert(key: string; uid, cid, firstLn: integer): integer;
var
  p     : TIDTPE;
  cursor: TListCursor;
begin
  p := TIDTPE.Create(key,idCnt,uid,cid,firstLn);
  if not Search(cursor,p) then begin
    inherited Insert(cursor,p);
    Inc(idCnt);
  end
  else p.Destroy;
  Result := TIDTE(Examine(cursor)).eID;
end;

procedure TIDTP.WriteProcSize(fileName: string);
begin
  with TIniFile.Create(fileName) do begin
    try
      if      Count <=     $FF then WriteInteger('Procedures','ProcSize',1)
      else if Count <=   $FFFF then WriteInteger('Procedures','ProcSize',2)
      else if Count <= $FFFFFF then WriteInteger('Procedures','ProcSize',3)
      else                          WriteInteger('Procedures','ProcSize',4);
    finally Free; end;
  end;
end;

{ TIDTE }

constructor TIDTE.Create(name: string; id: integer);
begin
  inherited Create;
  GetMem(eName,Length(name)+1);
  StrPCopy(eName,name);
  eID := id;
end;

destructor TIDTE.Destroy;
begin
  FreeMem(eName);
  inherited Destroy;
end;

{ TIDTPE }

constructor TIDTPE.Create(name: string; id, uid, cid, firstLn: integer);
begin
  inherited Create(name,id);
  eUID     := uid;
  eCID     := cid;
  eFirstLn := firstLn;
end;

{ TIDTUE }

constructor TIDTUE.Create(name, qual: string; id: integer);
begin
  GetMem(eQual,Length(qual)+1);
  StrPCopy(eQual,qual);
  inherited Create(name, id);
end;

destructor TIDTUE.Destroy;
begin
  inherited Destroy;
  FreeMem(eQual);
end;

{ TIDTCE }

constructor TIDTCE.Create(name: string; id, uid: integer);
begin
  eUID := uid;
  inherited Create(name, id);
end;

end.
