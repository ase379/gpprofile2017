
// https://docwiki.embarcadero.com/RADStudio/en/Compiler_Versions

{$IF CompilerVersion >= 17} // Delphi 2005 and UP
  {$DEFINE HAS_INLINE}
{$IFEND}

{$IF CompilerVersion >= 18} // Delphi 2006 and UP
  {$DEFINE HAS_MEMORY_MANAGER_STATE}
{$IFEND}

{$IF CompilerVersion >= 21} // Delphi 2010 and UP
  {$DEFINE HAS_UINT_TO_STR}
  {$DEFINE HAS_NAME_THREAD_FOR_DEBUGGING}
{$IFEND}

{$IF CompilerVersion >= 23} // Delphi XE2 and UP
  {$DEFINE HAS_THREAD_ID_TYPE}
{$IFEND}

{$IF CompilerVersion >= 25} // Delphi XE4 and UP
  {$DEFINE HAS_ANSISTRINGS_UNIT}
{$IFEND}

{$IF CompilerVersion >= 33} // Delphi 10.3 and UP
  {$DEFINE HAS_GROW_COLLECTION}
{$IFEND}
