{$I OPTIONS.INC}

unit gpFileEdit;

// not really suitable for large scale file editing because of stupid
// underlaying data structure; that can be easiliy changed, though

interface

uses
  Classes;

type
  TFileEdit = class
    constructor Create(fileName: string);
    destructor  Destroy; override;
    procedure   Insert(atOffset: integer; what: string);
    procedure   Remove(fromOffset, toOffset: integer);
    procedure   Execute(keepDate: boolean);
  private
    editFile: string;
    editList: TStringList;
    procedure   Schedule(cmd: pointer);
  end;

implementation

uses
  Windows,
  SysUtils;

type
  PFECmd = ^TFECmd;
  TFECmd = record
    fecCmd : (cmdInsert, cmdRemove);
    fecOfs1: integer;
    fecOfs2: integer;
    fecTxt : string;
  end;

{ TFileEdit }

  constructor TFileEdit.Create(fileName: string);
  begin
    editFile := fileName;
    editList := TStringList.Create;
    editList.Sorted := true;
  end; { TFileEdit.Create }

  destructor TFileEdit.Destroy;
  var
    i: integer;
  begin
    for i := 0 to editList.Count-1 do
      Dispose(PFECmd(editList.Objects[i]));
    editList.Free;
  end; { TFileEdit.Destroy }

  procedure TFileEdit.Execute(keepDate: boolean);
  var
    stream  : TMemoryStream;
    f       : file;
    i       : integer;
    fileDate: integer;

    function MakeCurP: pointer;
    begin
      Result := pointer(integer(stream.Memory)+stream.Position);
    end; { MakeCurP }

    procedure Remove(first,lastp1: integer);
    begin
      if first > stream.Position then BlockWrite(f,MakeCurP^,first-stream.Position);
      stream.Position := lastp1;
    end; { Remove }

    procedure Insert(position: integer; key: string);
    begin
      if position > stream.Position then begin
        BlockWrite(f,MakeCurP^,position-stream.Position);
        stream.Position := position;
      end;
      BlockWrite(f,key[1],Length(key));
    end; { Insert }

  begin { TFileEdit.Execute }
  {$IFDEF LogFEExecute}
    GpLogEvent(Format('TFileEdit.Execute: %s',[editFile]),FullLogName);
    GpLogEvent(Format('Chk1: LastError = %d',[GetLastError]),FullLogName);
  {$ENDIF}
    stream := TMemoryStream.Create;
    try
  {$IFDEF LogFEExecute} GpLogEvent('Chk2',FullLogName); {$ENDIF}
      stream.LoadFromFile(editFile);
  {$IFDEF LogFEExecute} GpLogEvent('Chk3',FullLogName); {$ENDIF}
      stream.Position := 0;
  {$IFDEF LogFEExecute} GpLogEvent('Chk4',FullLogName); {$ENDIF}
      Assign(f,editFile);
  {$IFDEF LogFEExecute} GpLogEvent('Chk5',FullLogName); {$ENDIF}
      Reset(f,1);
  {$IFDEF LogFEExecute} GpLogEvent('Chk6',FullLogName); {$ENDIF}
      if keepDate then
        fileDate := FileGetDate(TFileRec(f).Handle);
  {$IFDEF LogFEExecute} GpLogEvent('Chk7',FullLogName); {$ENDIF}
      Rewrite(f,1);
  {$IFDEF LogFEExecute} GpLogEvent('Chk8',FullLogName); {$ENDIF}
      try
  {$IFDEF LogFEExecute} GpLogEvent('Chk9',FullLogName); {$ENDIF}
        for i := 0 to editList.Count-1 do
          with PFECmd(editList.Objects[i])^ do begin
            if fecCmd = cmdInsert
              then Insert(fecOfs1,fecTxt)
              else Remove(fecOfs1,fecOfs2+1);
          end;
  {$IFDEF LogFEExecute} GpLogEvent('ChkA',FullLogName); {$ENDIF}
        BlockWrite(f,MakeCurP^,stream.Size-stream.Position);
  {$IFDEF LogFEExecute} GpLogEvent('ChkB',FullLogName); {$ENDIF}
        {$WARNINGS OFF}
        if keepDate then
          FileSetDate(TFileRec(f).Handle,fileDate);
  {$IFDEF LogFEExecute} GpLogEvent('ChkC',FullLogName); {$ENDIF}
      finally Close(f); end;
  {$IFDEF LogFEExecute} GpLogEvent('ChkD',FullLogName); {$ENDIF}
    finally stream.Free; end;
  {$IFDEF LogFEExecute} GpLogEvent('TFileEdit.Execute out',FullLogName); {$ENDIF}
  end; { TFileEdit.Execute }
  {$WARNINGS ON}

  procedure TFileEdit.Insert(atOffset: integer; what: string);
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

  procedure TFileEdit.Remove(fromOffset, toOffset: integer);
  var
    cmd: PFECmd;
  begin
    New(cmd);
    with cmd^ do begin
      fecCmd := cmdRemove;
      fecOfs1:= fromOffset;
      fecOfs2:= toOffset;
    end;
    Schedule(cmd);
  end; { TFileEdit.Remove }

  procedure TFileEdit.Schedule(cmd: pointer);
  begin
    with PFECmd(cmd)^ do begin
      editList.AddObject(Format('%10d%1d',[fecOfs1,Ord(fecCmd = cmdInsert)]),cmd);
    end;
  end; { TFileEdit.Schedule }

end.
