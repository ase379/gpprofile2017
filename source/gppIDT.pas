{$I OPTIONS.INC}

unit gppIDT;

interface

uses GpString;

type
  TIDTable = class
  private
    idUnits: TObject;
    idClass: TObject;
    idProcs: TObject;
  public
    constructor Create;
    destructor  Destroy; override;
    function    ConstructName(const unitName, unitFullName, procName: String; firstLn: integer): integer;
    procedure   Dump(const fileName: string);
  end;

implementation

uses
  Windows,
  SysUtils,
  IniFiles,
  GppTree,
  GpProfH,
  GpHugeF,
  gppCommon;

type
  TIDTE = class
    eName: String;
    eID  : integer;
    constructor Create(const name: String; id: integer);
  end;

  TIDTUE = class(TIDTE)
    eQual: String;
    constructor Create(const name, qual: String; id: integer); reintroduce;
  end;

  TIDTCE = class(TIDTE)
    eUID: integer;
    constructor Create(const name: String; id, uid: integer);
  end;

  TIDTPE = class(TIDTE)
    eUID    : integer;
    eCID    : integer;
    eFirstLn: integer;
    constructor Create(const name: String; id, uid, cid, firstLn: integer);
  end;

  TIDTU = class(TRootNode<TIDTUE>)
  private
    idCnt : integer;
    constructor Create; reintroduce;
    function    Insert(const key, qual: String): integer;
    procedure   Dump(var f: TGpHugeFile);
  protected
    function GetLookupKey(const aValue : TIDTUE) : string; override;
  end;

  TIDTC = class(TRootNode<TIDTCE>)
  private
    idCnt : integer;
    constructor Create; reintroduce;
    function    Insert(const key: String; uid: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
  protected
    function GetLookupKey(const aValue : TIDTCE) : string; override;
  end;

  TIDTP = class(TRootNode<TIDTPE>)
  private
    idCnt: integer;
    constructor Create; reintroduce;
    function    Insert(const key: String; uid, cid, firstLn: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
    procedure   WriteProcSize(const fileName: string);
  protected
    function GetLookupKey(const aValue : TIDTPE) : string; override;
  end;

function TIDTCompare(const data1,data2: INode<TIDTUE>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }

function TIDTCompare(const data1,data2: INode<TIDTCE>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }

function TIDTCompare(const data1,data2: INode<TIDTPE>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }


function TIDTIDCompare(const data1,data2: INode<TIDTUE>): integer;  overload;
begin
  Result := TIDTE(data1).eID - TIDTE(data2).eID;
end; { TIDTCompare }

function TIDTIDCompare(const data1,data2: INode<TIDTCE>): integer;  overload;
begin
  Result := TIDTE(data1).eID - TIDTE(data2).eID;
end; { TIDTCompare }

function TIDTIDCompare(const data1,data2: INode<TIDTPE>): integer;  overload;
begin
  Result := TIDTE(data1).eID - TIDTE(data2).eID;
end; { TIDTCompare }

{ TIDTable }

function TIDTable.ConstructName(const unitName, unitFullName, procName: String; firstLn: integer): integer;
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
  idUnits := TIDTU.Create;
  idClass := TIDTC.Create;
  idProcs := TIDTP.Create;
  inherited Create;
end;

destructor TIDTable.Destroy;
begin
  inherited Destroy;
  idUnits.Free;
  idClass.Free;
  idProcs.Free;
end;

procedure TIDTable.Dump(const fileName: string);
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
  inherited Create();
  CompareFunc := TIDTCompare;
  idCnt       := 1;
end;

procedure WriteTag   (f: TGpHugeFile; tag: byte);    begin f.BlockWriteUnsafe(Tag, Sizeof(Byte)); end;
procedure WriteInt   (f: TGpHugeFile; int: integer); begin f.BlockWriteUnsafe(Int, Sizeof(Integer)); end;

procedure WriteString(f: TGpHugeFile; str: ansistring);
begin
  WriteInt(f,Length(str));
  if Length(str) > 0 then
    f.BlockWriteUnsafe(str[1],Length(str)+1); // write zero-terminated
end; { WriteString }

procedure TIDTU.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTUE>.TEnumerator;
begin
  CompareFunc := TIDTIDCompare;
  WriteTag(f,PR_UNITTABLE);
  WriteInt(f,Count);
  LEnumor := self.GetEnumerator();
  while LEnumor.MoveNext do
  begin
    with LEnumor.Current.data do
    begin
      WriteString(f,eName);
      WriteString(f,eQual);
    end;
  end;
end;

function TIDTU.GetLookupKey(const aValue : TIDTUE) : string;
begin
  result := AnsiLowerCase(aValue.eName);
end;

function TIDTU.Insert(const key, qual: String): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTUE>;
begin
  LSearchNode := TNode<TIDTUE>.Create();
  LSearchNode.Data := TIDTUE.Create(key,qual,idCnt);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

{ TIDTC }

constructor TIDTC.Create;
begin
  inherited Create();
  CompareFunc     := TIDTCompare;
  idCnt       := 1;
end;

procedure TIDTC.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTCE>.TEnumerator;
begin
  CompareFunc := TIDTIDCompare;
  WriteTag(f,PR_CLASSTABLE);
  WriteInt(f,Count);
  LEnumor := GetEnumerator();
  while LEnumor.MoveNext do
  begin
    with LEnumor.Current.Data do
    begin
      WriteString(f,eName);
      WriteInt(f,eUID);
    end;
  end;
end;

function TIDTC.GetLookupKey(const aValue: TIDTCE): string;
begin
  result := AnsiLowerCase(aValue.eName)
end;

function TIDTC.Insert(const key: String; uid: integer): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTCE>;
begin
  LSearchNode := TNode<TIDTCE>.Create();
  LSearchNode.Data := TIDTCE.Create(key,idCnt,uid);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

{ TIDTP }

constructor TIDTP.Create;
begin
  inherited Create();
  CompareFunc := TIDTCompare;
  idCnt       := 1;
end;

procedure TIDTP.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTPE>.TEnumerator;
begin
  CompareFunc := TIDTIDCompare;
  WriteTag(f,PR_PROCTABLE);
  WriteInt(f,Count);
  LEnumor := self.GetEnumerator();
  while LEnumor.MoveNext do
  begin
    with LEnumor.Current.data do
    begin
      WriteString(f,eName);
      WriteInt(f,eUID);
      WriteInt(f,eCID);
      WriteInt(f,eFirstLn);
    end;
  end;
end;

function TIDTP.GetLookupKey(const aValue: TIDTPE): string;
begin
  result := AnsiLowerCase(aValue.eName);
end;

function TIDTP.Insert(const key: String; uid, cid, firstLn: integer): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTPE>;
begin
  LSearchNode := TNode<TIDTPE>.Create();
  LSearchNode.Data := TIDTPE.Create(key,idCnt,uid,cid,firstLn);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

procedure TIDTP.WriteProcSize(const fileName: string);
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

constructor TIDTE.Create(const name: String; id: integer);
begin
  inherited Create;
  eName := name;
  eID := id;
end;


{ TIDTPE }

constructor TIDTPE.Create(const name: String; id, uid, cid, firstLn: integer);
begin
  inherited Create(name,id);
  eUID     := uid;
  eCID     := cid;
  eFirstLn := firstLn;
end;

{ TIDTUE }

constructor TIDTUE.Create(const name, qual: String; id: integer);
begin
  eQual := qual;
  inherited Create(name, id);
end;


{ TIDTCE }

constructor TIDTCE.Create(const name: String; id, uid: integer);
begin
  eUID := uid;
  inherited Create(name, id);
end;

end.