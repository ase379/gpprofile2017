unit testAsmRoutines;

/// <summary>
/// Tests parser coverage for assembler-based Delphi constructs:
/// - Pure ASM procedures (marked as pureAsm by the parser, not instrumented)
/// - Pure ASM functions
/// - Procedures containing inline ASM blocks (can be instrumented)
/// - Functions containing inline ASM blocks
/// The parser must correctly identify these and handle them without error.
/// </summary>

interface

function AsmAddIntegers(const aA, aB: Integer): Integer;
procedure AsmNopProcedure;
function ProcWithInlineAsmBlock(const aValue: Integer): Integer;
procedure ProcWithAsmAndPascal(var aBuffer: Byte);

procedure TestAsmCalls;

implementation

function AsmAddIntegers(const aA, aB: Integer): Integer;
asm
{$IFDEF CPUX64}
  MOV EAX, ECX
  ADD EAX, EDX
{$ELSE}
  MOV EAX, aA
  ADD EAX, aB
{$ENDIF}
end;

procedure AsmNopProcedure;
asm
  NOP
end;

function ProcWithInlineAsmBlock(const aValue: Integer): Integer;
begin
  Result := aValue;
  asm
    NOP
  end;
  Inc(Result);
end;

procedure ProcWithAsmAndPascal(var aBuffer: Byte);
begin
  aBuffer := 0;
  asm
    NOP
  end;
  aBuffer := aBuffer + 1;
end;

procedure TestAsmCalls;
var
  LSum: Integer;
  LResult: Integer;
  LByte: Byte;
begin
  LSum := AsmAddIntegers(10, 32);
  AsmNopProcedure;
  LResult := ProcWithInlineAsmBlock(LSum);
  LByte := 0;
  ProcWithAsmAndPascal(LByte);
end;

end.
