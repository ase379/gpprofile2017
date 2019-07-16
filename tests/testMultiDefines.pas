unit testMultiDefines;

{$LEGACYIFEND}
interface

procedure TestMultidefinesDummy();
procedure TestFunctionIfIfdefWithIfEndAndEndIf();

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


// test for checking if nesting a $IF in a $IFDEF works with Closed $IFEND
procedure TestFunctionIfIfdefWithIfEndAndEndIf();
{$ifdef A}
begin
{$ELSE}
{$IF DEFINED(B)}
begin
{$ELSE}
var
  i : Integer;
begin
  i := 0;
{$IFEND}
{$IFEND}
end;

end.
