unit GpProfCommonTypes;

interface

{$INCLUDE GpProf.inc}

{$IFNDEF HAS_THREAD_ID_TYPE}
type
  TThreadID = Cardinal;
{$ENDIF}

{$IF CompilerVersion < 19}
type
  // fix Delphi 2007 invalid type declarations
  // https://blog.dummzeuch.de/2018/09/08/nativeint-nativeuint-type-in-various-delphi-versions/
  NativeInt = Integer;
  NativeUInt = Cardinal;
{$IFEND}

implementation

end.