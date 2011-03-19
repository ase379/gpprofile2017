(******************************************************************************)
(* mwEdit Include File.  This file was adapted from Brad Stowers' DFS.INC     *)
(* file and used with permission.  This will help reduce headaches when new   *)
(* versions of Delphi and C++Builder are released, among other things.        *)
(******************************************************************************)
(* Brad Stowers: bstowers@pobox.com                                           *)
(* Delphi Free Stuff: http://delphifreestuff.com/                             *)
(* February 24, 1999                                                          *)
(******************************************************************************)
(*                                                                            *)
(* Complete Boolean Evaluation compiler directive is turned off by including  *)
(*   this file.                                                               *)
(* The $ObjExportAll directive is turned on if compiling with C++Builder 3 or *)
(*   higher.  This is required for Delphi components built in Builder with    *)
(*   run-time packages.                                                       *)
(*                                                                            *)
(* Here is a brief explanation of what each of the defines mean:              *)
(* DELPHI_FREE_STUFF    : Always defined when DFS.INC is included             *)
(* MWE_WIN16            : Compilation target is 16-bit Windows                *)
(* MWE_WIN32            : Compilation target is 32-bit Windows                *)
(* MWE_USEDEFSHLOBJ     : The SHLOBJ.PAS version contains no none errors.     *)
(*                        Delphi 2.0x and C++Builder 1.0x shipped with a      *)
(*                        version of SHLOBJ.PAS that had many nasty errors.   *)
(*                        See my web site in the Hints section for how to fix *)
(* MWE_NO_COM_CLEANUP   : The version of the compiler being used does not     *)
(*                        require COM objects to be released; it is done      *)
(*                        automatically when they go "out of scope".          *)
(* MWE_COMPILER_1       : Delphi 1.0 is the compiler.  Note that C++B 1.0     *)
(*                        does NOT cause this to be defined.  It is really    *)
(*                        the 2.0 compiler.                                   *)
(* MWE_COMPILER_1_UP    : Delphi 1.0x or higher, or C++B 1.0x or higher is the*)
(*                        compiler.                                           *)
(* MWE_COMPILER_2       : Delphi 2.0x or C++B 1.0x is the compiler.           *)
(* MWE_COMPILER_2_UP    : Delphi 2.0x or higher, or C++B 1.0x or higher is the*)
(*                        compiler.                                           *)
(* MWE_COMPILER_3       : Delphi 3.0x or C++B 3.0x is the compiler.           *)
(* MWE_COMPILER_3_UP    : Delphi 3.0x or higher, or C++B 3.0x or higher is the*)
(*                        compiler.                                           *)
(* MWE_COMPILER_4       : Delphi 4.0x or C++B 4.0x is the compiler.           *)
(* MWE_COMPILER_4_UP    : Delphi 4.0x or higher, or C++B 4.0x or higher is    *)
(*                        the compiler.                                       *)
(* MWE_UNKNOWN_COMPILER : No sense could be made of the compiliation          *)
(*                        environment.                                        *)
(* MWE_CPPB             : Any version of C++B is being used.                  *)
(* MWE_CPPB_1           : C++B v1.0x is being used.                           *)
(* MWE_CPPB_3           : C++B v3.0x is being used.                           *)
(* MWE_CPPB_3_UP        : C++B v3.0x or higher is being used.                 *)
(* MWE_CPPB_4           : C++B v4.0x is being used.                           *)
(* MWE_CPPB_4_UP        : C++B v4.0x or higher is being used.                 *)
(* MWE_DELPHI           : Any version of Delphi is being used.                *)
(* MWE_DELPHI_1         : Delphi v1.0x is being used.                         *)
(* MWE_DELPHI_2         : Delphi v2.0x is being used.                         *)
(* MWE_DELPHI_2_UP      : Delphi v2.0x or higher is being used.               *)
(* MWE_DELPHI_3         : Delphi v3.0x is being used.                         *)
(* MWE_DELPHI_3_UP      : Delphi v3.0x or higher is being used.               *)
(* MWE_DELPHI_4         : Delphi v4.0x is being used.                         *)
(* MWE_DELPHI_4_UP      : Delphi v4.0x or higher is being used.               *)
(******************************************************************************)


{$DEFINE MWEDIT_INCLUDE}

{$IFDEF WIN32}
  {$DEFINE MWE_WIN32}
{$ELSE}
  {$DEFINE MWE_WIN16}
{$ENDIF}

{$IFDEF VER130}
  {$DEFINE MWE_COMPILER_5}
  {$DEFINE MWE_DELPHI}
  {$DEFINE MWE_DELPHI_5}
  {$DEFINE MWE_USEDEFSHLOBJ} { Only D3+ and C++B 3 have no errors in SHLOBJ }
{$ENDIF}

{$IFDEF VER125}
  {$DEFINE MWE_COMPILER_4}
  {$DEFINE MWE_CPPB}
  {$DEFINE MWE_CPPB_4}
  {$DEFINE MWE_USEDEFSHLOBJ} { Only D3+ and C++B 3+ have no errors in SHLOBJ }
{$ENDIF}

{$IFDEF VER120}
  {$DEFINE MWE_COMPILER_4}
  {$DEFINE MWE_DELPHI}
  {$DEFINE MWE_DELPHI_4}
  {$DEFINE MWE_USEDEFSHLOBJ} { Only D3+ and C++B 3 have no errors in SHLOBJ }
{$ENDIF}

{$IFDEF VER110}
  {$DEFINE MWE_COMPILER_3}
  {$DEFINE MWE_CPPB}
  {$DEFINE MWE_CPPB_3}
  {$DEFINE MWE_USEDEFSHLOBJ} { Only D3+ and C++B 3 have no errors in SHLOBJ }
{$ENDIF}

{$IFDEF VER100}
  {$DEFINE MWE_COMPILER_3}
  {$DEFINE MWE_DELPHI}
  {$DEFINE MWE_DELPHI_3}
  {$DEFINE MWE_USEDEFSHLOBJ} { Only D3+ and C++B 3 have no errors in SHLOBJ }
{$ENDIF}

{$IFDEF VER93}
  {$DEFINE MWE_COMPILER_2}  { C++B v1 compiler is really v2 }
  {$DEFINE MWE_CPPB}
  {$DEFINE MWE_CPPB_1}
  {.$DEFINE MWE_USEDEFSHLOBJ} { C++B 1 has the correct SHLOBJ.H, but
                                SHLOBJ.PAS has errors so this isn't defined }
{$ENDIF}

{$IFDEF VER90}
  {$DEFINE MWE_COMPILER_2}
  {$DEFINE MWE_DELPHI}
  {$DEFINE MWE_DELPHI_2}
{$ENDIF}

{$IFDEF VER80}
  {$DEFINE MWE_COMPILER_1}
  {$DEFINE MWE_DELPHI}
  {$DEFINE MWE_DELPHI_1}
{$ENDIF}

{$IFNDEF MWE_CPPB}
  {$IFNDEF MWE_DELPHI}
    { Don't know what it is.  Could be new version, or could be old BP. }
    {$DEFINE MWE_UNKNOWN_COMPILER}
  {$ENDIF}
{$ENDIF}

{$IFDEF MWE_COMPILER_1}
  {$DEFINE MWE_COMPILER_1_UP}
{$ENDIF}

{$IFDEF MWE_COMPILER_2}
  {$DEFINE MWE_COMPILER_1_UP}
  {$DEFINE MWE_COMPILER_2_UP}
{$ENDIF}

{$IFDEF MWE_COMPILER_3}
  {$DEFINE MWE_COMPILER_1_UP}
  {$DEFINE MWE_COMPILER_2_UP}
  {$DEFINE MWE_COMPILER_3_UP}
{$ENDIF}

{$IFDEF MWE_COMPILER_4}
  {$DEFINE MWE_COMPILER_1_UP}
  {$DEFINE MWE_COMPILER_2_UP}
  {$DEFINE MWE_COMPILER_3_UP}
  {$DEFINE MWE_COMPILER_4_UP}
{$ENDIF}

{$IFDEF MWE_COMPILER_5}
  {$DEFINE MWE_COMPILER_1_UP}
  {$DEFINE MWE_COMPILER_2_UP}
  {$DEFINE MWE_COMPILER_3_UP}
  {$DEFINE MWE_COMPILER_4_UP}
  {$DEFINE MWE_COMPILER_5_UP}
{$ENDIF}

{$IFDEF MWE_DELPHI_2}
  {$DEFINE MWE_DELPHI_2_UP}
{$ENDIF}

{$IFDEF MWE_DELPHI_3}
  {$DEFINE MWE_DELPHI_2_UP}
  {$DEFINE MWE_DELPHI_3_UP}
{$ENDIF}

{$IFDEF MWE_DELPHI_4}
  {$DEFINE MWE_DELPHI_2_UP}
  {$DEFINE MWE_DELPHI_3_UP}
  {$DEFINE MWE_DELPHI_4_UP}
{$ENDIF}

{$IFDEF MWE_DELPHI_5}
  {$DEFINE MWE_DELPHI_2_UP}
  {$DEFINE MWE_DELPHI_3_UP}
  {$DEFINE MWE_DELPHI_4_UP}
  {$DEFINE MWE_DELPHI_5_UP}
{$ENDIF}

{$IFDEF MWE_CPPB_3}
  {$DEFINE MWE_CPPB_3_UP}
{$ENDIF}

{$IFDEF MWE_COMPILER_3_UP}
  {$DEFINE MWE_NO_COM_CLEANUP}
{$ENDIF}

{$IFDEF MWE_CPPB_3_UP}
  // C++Builder requires this if you use Delphi components in run-time packages.
  {$ObjExportAll On}
{$ENDIF}

{------------------------------------------------------------------------------}
{ Please change this to suite your needs                                       } 
{------------------------------------------------------------------------------}

// support for different selection modes
{$DEFINE MWE_SELECTION_MODE}

// support for multibyte character sets
{$IFDEF MWE_COMPILER_3_UP}

{$DEFINE MWE_MBCSSUPPORT}

{$ENDIF}


