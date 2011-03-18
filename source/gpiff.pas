{$I OPTIONS.INC}

unit GpIFF;

interface

  function IFF(condit: boolean; iftrue, iffalse: string): string; overload;
  function IFF(condit: boolean; iftrue, iffalse: integer): integer; overload;
  function IFF(condit: boolean; iftrue, iffalse: real): real; overload;
  function IFF(condit: boolean; iftrue, iffalse: boolean): boolean; overload;

implementation

  function IFF(condit: boolean; iftrue, iffalse: string): string;
  begin
    if condit then Result := iftrue
              else Result := iffalse;
  end; { IFF }

  function IFF(condit: boolean; iftrue, iffalse: integer): integer;
  begin
    if condit then Result := iftrue
              else Result := iffalse;
  end; { IFF }

  function IFF(condit: boolean; iftrue, iffalse: real): real;
  begin
    if condit then Result := iftrue
              else Result := iffalse;
  end; { IFF }

  function IFF(condit: boolean; iftrue, iffalse: boolean): boolean;
  begin
    if condit then Result := iftrue
              else Result := iffalse;
  end; { IFF }

end.
