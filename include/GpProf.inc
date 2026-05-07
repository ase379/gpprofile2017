
// https://docwiki.embarcadero.com/RADStudio/en/Compiler_Versions

{$IF CompilerVersion >= 20} // Delphi 2009 and UP
  {$DEFINE HAS_UINT_TO_STR}
  {$DEFINE HAS_NAME_THREAD_FOR_DEBUGGING}
  {$DEFINE HAS_THREAD_ID_TYPE}
{$IFEND}

{$IF CompilerVersion >= 25} // Delphi XE4 and UP
  {$DEFINE HAS_ANSISTRINGS_UNIT}
{$IFEND}

{$IF CompilerVersion >= 33} // Delphi 10.3 and UP
  {$DEFINE HAS_GROW_COLLECTION}
{$IFEND}
