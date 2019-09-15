{$I OPTIONS.INC}

unit gppIDT;

interface

uses GpString,GpHugeF;

type
  IIDTableDumpableList = interface
  ['{BD8A181B-0A58-4622-AF13-32C9FA686F80}']
    procedure   Dump(var f: TGpHugeFile);
  end;

  IIDTableUnitList = interface(IIDTableDumpableList)
  ['{9617766A-5238-4C33-979C-11860B1DE595}']
    function Insert(const key, qual: String): integer;
  end;

  IIDTableClassList = interface(IIDTableDumpableList)
  ['{195AB08E-1C3B-4BE7-8550-41688A466BCB}']
    function Insert(const key: String; uid: integer): integer;
  end;

  IIDTableProcList = interface(IIDTableDumpableList)
  ['{7EBDE193-63D7-437F-BD71-98E3B2A4C791}']
    function Insert(const key: String; uid, cid, firstLn: integer): integer;
    procedure WriteProcSize(const fileName: string);
  end;

  TIDTable = class
  private
    idUnits: IIDTableUnitList;
    idClass: IIDTableClassList;
    idProcs: IIDTableProcList;
  public
    constructor Create;
    /// <summary>
    /// Registers the given procedure and returns the procedure id.
    /// </summary>
    function    RegisterProc(const unitName, unitFullName, procName: String; firstLn: integer): integer;
    procedure   Dump(const fileName: string);
  end;

implementation

uses
  Windows,
  SysUtils,
  IniFiles,
  GppTree,
  GpProfH,
  gppCommon;

type
  TIDTableEntry = class
  private
    eName: String;
    eID  : integer;
  public
    constructor Create(const name: String; id: integer);
  end;

  TIDTableUnitEntry = class(TIDTableEntry)
    eQual: String;
    constructor Create(const name, qual: String; id: integer); reintroduce;
  end;

  TIDTableClassEntry = class(TIDTableEntry)
    eUID: integer;
    constructor Create(const name: String; id, uid: integer);
  end;

  TIDTableProcEntry = class(TIDTableEntry)
    eUID    : integer;
    eCID    : integer;
    eFirstLn: integer;
    constructor Create(const name: String; id, uid, cid, firstLn: integer);
  end;

  TIDTableUnits = class(TRootNode<TIDTableUnitEntry>, IIDTableUnitList)
  private
    idCnt : integer;
    constructor Create; reintroduce;
    function    Insert(const key, qual: String): integer;
    procedure   Dump(var f: TGpHugeFile);
  protected
    function GetLookupKey(const aValue : TIDTableUnitEntry) : string; override;
  end;

  TIDTableClasses = class(TRootNode<TIDTableClassEntry>, IIDTableClassList)
  private
    idCnt : integer;
    constructor Create; reintroduce;
    function    Insert(const key: String; uid: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
  protected
    function GetLookupKey(const aValue : TIDTableClassEntry) : string; override;
  end;

  TIDTableProcedures = class(TRootNode<TIDTableProcEntry>, IIDTableProcList)
  private
    idCnt: integer;
    constructor Create; reintroduce;
    function    Insert(const key: String; uid, cid, firstLn: integer): integer;
    procedure   Dump(var f: TGpHugeFile);
    procedure   WriteProcSize(const fileName: string);
  protected
    function GetLookupKey(const aValue : TIDTableProcEntry) : string; override;
  end;

function TIDTCompare(const data1,data2: INode<TIDTableUnitEntry>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }

function TIDTCompare(const data1,data2: INode<TIDTableClassEntry>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }

function TIDTCompare(const data1,data2: INode<TIDTableProcEntry>): integer; overload;
begin
  Result := String.Compare(data1.Data.eName,data2.data.eName,true);
end; { TIDTCompare }


function TIDTIDCompare(const data1,data2: INode<TIDTableUnitEntry>): integer;  overload;
begin
  Result := TIDTableEntry(data1).eID - TIDTableEntry(data2).eID;
end; { TIDTCompare }

function TIDTIDCompare(const data1,data2: INode<TIDTableClassEntry>): integer;  overload;
begin
  Result := TIDTableEntry(data1).eID - TIDTableEntry(data2).eID;
end; { TIDTCompare }

function TIDTIDCompare(const data1,data2: INode<TIDTableProcEntry>): integer;  overload;
begin
  Result := TIDTableEntry(data1).eID - TIDTableEntry(data2).eID;
end; { TIDTCompare }

{ TIDTable }

function TIDTable.RegisterProc(const unitName, unitFullName, procName: String; firstLn: integer): integer;
var
  unitID: integer;
  clasID: integer;
  p     : integer;
begin
  unitID := idUnits.Insert(unitName, unitFullName);
  p := Pos('.',procName);
  if p > 0 then clasID := idClass.Insert(unitName+'.'+First(procName,p-1),unitID)
           else clasID := idClass.Insert(unitName+'.<>',unitID); // classless
  Result := idProcs.Insert(unitName+'.'+procName,unitID,clasID,firstLn);
end;

constructor TIDTable.Create;
begin
  idUnits := TIDTableUnits.Create;
  idClass := TIDTableClasses.Create;
  idProcs := TIDTableProcedures.Create;
  inherited Create;
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
    idUnits.Dump(f);
    idClass.Dump(f);
    idProcs.Dump(f);
  finally f.Free; end;
  with TIniFile.Create(fileName) do begin
    try WriteString('IDTables','TableName',fnm);
    finally Free; end;
  end;
  idProcs.WriteProcSize(fileName);
end;

{ TIDTableUnits }

constructor TIDTableUnits.Create;
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

procedure TIDTableUnits.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTableUnitEntry>.TEnumerator;
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
  LEnumor.Free;
end;

function TIDTableUnits.GetLookupKey(const aValue : TIDTableUnitEntry) : string;
begin
  result := AnsiLowerCase(aValue.eName);
end;

function TIDTableUnits.Insert(const key, qual: String): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTableUnitEntry>;
begin
  LSearchNode := TNode<TIDTableUnitEntry>.Create();
  LSearchNode.Data := TIDTableUnitEntry.Create(key,qual,idCnt);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

{ TIDTableClasses }

constructor TIDTableClasses.Create;
begin
  inherited Create();
  CompareFunc     := TIDTCompare;
  idCnt       := 1;
end;

procedure TIDTableClasses.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTableClassEntry>.TEnumerator;
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
  LEnumor.Free;
end;

function TIDTableClasses.GetLookupKey(const aValue: TIDTableClassEntry): string;
begin
  result := AnsiLowerCase(aValue.eName)
end;

function TIDTableClasses.Insert(const key: String; uid: integer): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTableClassEntry>;
begin
  LSearchNode := TNode<TIDTableClassEntry>.Create();
  LSearchNode.Data := TIDTableClassEntry.Create(key,idCnt,uid);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

{ TIDTableProcedures }

constructor TIDTableProcedures.Create;
begin
  inherited Create();
  CompareFunc := TIDTCompare;
  idCnt       := 1;
end;

procedure TIDTableProcedures.Dump(var f: TGpHugeFile);
var
  LEnumor: TRootNode<TIDTableProcEntry>.TEnumerator;
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
  LEnumor.Free;
end;

function TIDTableProcedures.GetLookupKey(const aValue: TIDTableProcEntry): string;
begin
  result := AnsiLowerCase(aValue.eName);
end;

function TIDTableProcedures.Insert(const key: String; uid, cid, firstLn: integer): integer;
var
  LSearchNode,
  LResultNode : INode<TIDTableProcEntry>;
begin
  LSearchNode := TNode<TIDTableProcEntry>.Create();
  LSearchNode.Data := TIDTableProcEntry.Create(key,idCnt,uid,cid,firstLn);
  if not FindNode(LSearchNode, LResultNode) then
  begin
    AppendNode(LSearchNode.data);
    result := LSearchNode.Data.eID;
    Inc(idCnt);
  end
  else
    result := LResultNode.Data.eID;
end;

procedure TIDTableProcedures.WriteProcSize(const fileName: string);
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

{ TIDTableEntry }

constructor TIDTableEntry.Create(const name: String; id: integer);
begin
  inherited Create;
  eName := name;
  eID := id;
end;


{ TIDTableProcEntry }

constructor TIDTableProcEntry.Create(const name: String; id, uid, cid, firstLn: integer);
begin
  inherited Create(name,id);
  eUID     := uid;
  eCID     := cid;
  eFirstLn := firstLn;
end;

{ TIDTableUnitEntry }

constructor TIDTableUnitEntry.Create(const name, qual: String; id: integer);
begin
  eQual := qual;
  inherited Create(name, id);
end;


{ TIDTableClassEntry }

constructor TIDTableClassEntry.Create(const name: String; id, uid: integer);
begin
  eUID := uid;
  inherited Create(name, id);
end;

end.