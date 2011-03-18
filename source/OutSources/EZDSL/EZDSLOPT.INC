{===EZDSLOPT.INC======================================================

Fixed compiler options for the EZ Delphi Structures Library.
DO NOT MODIFY ANYTHING IN THIS FILE.

EZDSLOPT.INC is Copyright (c) 1995,1997 by Julian M. Bucknall

VERSION HISTORY
26Sep97 JMB 3.00 Major new version, release for Delphi 3
13Mar96 JMB 1.00 release for Delphi 2.0
{=====================================================================}

{ Check for Delphi }

{------Fixed compiler options throughout EZDSL------------------------}

{---Delphi 1.0 specific---}
{$IFDEF VER80}
{$B-   Short-circuit boolean expressions }
{$G+   80286+ type instructions }
{$I+   I/O checking via exceptions }
{$V-   Disable var string checking }
{$W-   No Windows realmode stack frame }
{$X+   Enable extended syntax }
{$IFDEF DEBUG}
{$D+,L+  Enable debug information }
{$ELSE}
{$D-,L-  Disable debug information }
{$ENDIF}
{$ENDIF}

{---Delphi 2.0 specific---}
{$IFDEF VER90}
{$A+   Use DWORD alignment whereever possible }
{$B-   Short-circuit boolean expressions }
{$I+   I/O checking via exceptions }
{$V-   Disable var string checking }
{$W-   No Windows realmode stack frame }
{$X+   Enable extended syntax }
{$IFDEF DEBUG}
{$D+,L+  Enable debug information }
{$ELSE}
{$D-,L-  Disable debug information }
{$ENDIF}
{$ENDIF}

{---Delphi 3.0 specific---}
{$IFDEF VER100}
{$A+   Use DWORD alignment whereever possible }
{$B-   Short-circuit boolean expressions }
{$I+   I/O checking via exceptions }
{$V-   Disable var string checking }
{$W-   No Windows realmode stack frame }
{$X+   Enable extended syntax }
{$IFDEF DEBUG}
{$D+,L+  Enable debug information }
{$ELSE}
{$D-,L-  Disable debug information }
{$ENDIF}
{$ENDIF}

{---Hints and Warnings for Delphi 2/3}
{$IFNDEF VER80}
{$WARNINGS ON}
{$HINTS ON}
{$ENDIF}
{---------------------------------------------------------------------}

