{$I OPTIONS.INC}

unit GpRegistry;

interface

uses
  Registry, Variants;

type
  TGpRegistry = class(TRegistry)
    function  ReadString (name,defval: string): string;
    function  ReadInteger(name: string; defval: integer): integer;
    function  ReadBool   (name: string; defval: boolean): boolean;
    function  ReadDate   (name: string; defval: TDateTime): TDateTime;
    function  ReadInt64  (name: string; defval: int64): int64;
    function  ReadVariant(name: string; defval: variant): variant;
    procedure WriteInt64  (name: string; value: int64);
    procedure WriteVariant(name: string; value: variant);
  end;

implementation

uses
  SysUtils;

  function TGpRegistry.ReadString (name,defval: string): string;
  begin
    try
      if GetDataSize(name) < 0 then Abort; // D4 does not generate an exception!
      ReadString := inherited ReadString(name);
    except
      ReadString := defval;
    end;
  end; { TGpRegistry.ReadString }

  function TGpRegistry.ReadInteger (name: string; defval: integer): integer;
  begin
    try
      if GetDataSize(name) < 0 then Abort; // D4 does not generate an exception!
      ReadInteger := inherited ReadInteger(name); 
    except
      ReadInteger := defval;
    end;
  end; { TGpRegistry.ReadInteger }

  function TGpRegistry.ReadBool (name: string; defval: boolean): boolean;
  begin
    try
      if GetDataSize(name) < 0 then Abort; // D4 does not generate an exception!
      ReadBool := inherited ReadBool(name);
    except
      ReadBool := defval;
    end;
  end; { TGpRegistry.ReadBool }

  function TGpRegistry.ReadDate (name: string; defval: TDateTime): TDateTime;
  begin
    try
      if GetDataSize(name) < 0 then Abort; // D4 does not generate an exception!
      ReadDate := inherited ReadDate(name);
    except
      ReadDate := defval;
    end;
  end; { TGpRegistry.ReadDate }

  function TGpRegistry.ReadVariant(name: string; defval: variant): variant;
  begin
    case VarType(defval) of
      varInteger: Result := ReadInteger(name,defval);
      varBoolean: Result := ReadBool(name,defval);
      varString : Result := ReadString(name,defval);
      varDate   : Result := ReadDate(name,defval);
      else raise Exception.Create('TGpRegistry.ReadVariant: Invalid value type!');
    end;
  end;

  procedure TGpRegistry.WriteVariant(name: string; value: variant);
  begin
    case VarType(value) of
      varInteger: WriteInteger(name,value);
      varBoolean: WriteBool(name,value);
      varString : WriteString(name,value);
      varDate   : WriteDate(name,value);
      else raise Exception.Create('TGpRegistry.WriteVariant: Invalid value type!');
    end;
  end;

  function TGpRegistry.ReadInt64(name: string; defval: int64): int64;
  var
    tmp: int64;
    c  : integer;
  begin
    Val(ReadString(name,'!'),tmp,c);
    if c = 0
      then Result := tmp
      else Result := defval;
  end; { TGpRegistry.ReadInt64 }

  procedure TGpRegistry.WriteInt64(name: string; value: int64);
  begin
    WriteString(name,IntToStr(value));
  end; { TGpRegistry.WriteInt64 }

end.
