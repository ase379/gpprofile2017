{$I OPTIONS.INC}

unit gpFileEdit;

// not really suitable for large scale file editing because of stupid
// underlaying data structure; that can be easiliy changed, though

interface

uses
  Classes;

type
  TFileEdit = class
    constructor Create(const fileName: string);
    destructor  Destroy; override;
    procedure   Insert(const atOffset: int64; what: string);
    procedure   Remove(const fromOffset, toOffset: int64);
    procedure   RemoveOneChar(const fromOffset: int64);

    procedure   Execute();
    procedure   Clear();

  private
    editFile: string;
    editList: TStringList;
    procedure   Schedule(const cmd: pointer);
  end;

implementation

{$WARN SYMBOL_PLATFORM OFF} // for FileSetDate

uses
  Windows,SysUtils;

type
  PFECmd = ^TFECmd;
  TFECmd = record
    fecCmd : (cmdInsert, cmdRemove);
    fecOfs1: int64;
    fecOfs2: int64;
    fecTxt : string;
  end;

{ TFileEdit }

constructor TFileEdit.Create(const fileName: string);
begin
  editFile := fileName;
  editList := TStringList.Create;
  editList.Sorted := true;
end; { TFileEdit.Create }

destructor TFileEdit.Destroy;

begin
  Clear();
  editList.Free;
  inherited;
end; { TFileEdit.Destroy }


procedure TFileEdit.Clear();
var
  i: integer;
begin
  for i := 0 to editList.Count-1 do
    Dispose(PFECmd(editList.Objects[i]));
  editList.Clear();
end;

procedure TFileEdit.Execute();
var
  stream  : TMemoryStream;
  f       : file;
  i       : integer;

  function MakeCurP: pointer;
  begin
    Result := pointer(NativeUInt(stream.Memory)+NativeUInt(stream.Position));
  end; { MakeCurP }

  procedure Remove(first,lastp1: int64);
  begin
    if first > stream.Position then
      BlockWrite(f,MakeCurP^,first-stream.Position);
    stream.Position := lastp1;
  end; { Remove }

  procedure Insert(position: int64; key: ansistring);
  begin
    if position > stream.Position then
    begin
      BlockWrite(f,MakeCurP^,position-stream.Position);
      stream.Position := position;
    end;
    BlockWrite(f,key[1],Length(key));
  end; { Insert }

var
  lPeCmd : tFECmd;
begin { TFileEdit.Execute }

  stream := TMemoryStream.Create;
  try


    stream.LoadFromFile(editFile);
    stream.Position := 0;
    Assign(f,editFile);
    Reset(f,1);
    Rewrite(f,1);
    try
      for i := 0 to editList.Count-1 do
      begin
        lPeCmd := PFECmd(editList.Objects[i])^;
        if lPeCmd.fecCmd = cmdInsert then
          Insert(lPeCmd.fecOfs1,utf8Encode(lPeCmd.fecTxt))
        else
          Remove(lPeCmd.fecOfs1,lPeCmd.fecOfs2+1);
      end;
      BlockWrite(f,MakeCurP^,stream.Size-stream.Position);
    finally
      Close(f);
    end;
  finally
    stream.Free;
  end;
  Clear();
end; { TFileEdit.Execute }

procedure TFileEdit.Insert(const atOffset: int64; what: string);
var
  cmd: PFECmd;
begin
  New(cmd);
  with cmd^ do begin
    fecCmd := cmdInsert;
    fecOfs1:= atOffset;
    fecTxt := what;
  end;
  Schedule(cmd);
end; { TFileEdit.Insert }

procedure TFileEdit.RemoveOneChar(const fromOffset: int64);
begin
  Remove(fromOffset, fromOffset);
end;

procedure TFileEdit.Remove(const fromOffset, toOffset: int64);
var
  cmd: PFECmd;
begin
  if toOffset<fromOffset then
    raise Exception.Create('toOffset is before fromOffset.');  

  New(cmd);
  with cmd^ do begin
    fecCmd := cmdRemove;
    fecOfs1:= fromOffset;
    fecOfs2:= toOffset;
  end;
  Schedule(cmd);
end; { TFileEdit.Remove }

procedure TFileEdit.Schedule(const cmd: pointer);
begin
  with PFECmd(cmd)^ do begin
    editList.AddObject(Format('%10d%1d',[fecOfs1,Ord(fecCmd = cmdInsert)]),cmd);
  end;
end; { TFileEdit.Schedule }

end.
