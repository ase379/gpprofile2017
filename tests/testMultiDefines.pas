unit testMultiDefines;

interface

procedure TestMultidefinesDummy();

{$IFDEF Win32}
implementation

// some 32 bit code
{$ELSE}
implementation

// some 64 bit code
{$ENDIF}

// common code
procedure TestMultidefinesDummy();
begin
end;

end.
