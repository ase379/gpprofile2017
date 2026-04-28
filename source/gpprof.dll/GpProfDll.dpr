{$R-,C-,Q-,O+,H+}

(*
  GpProfile DLL - profiling instrumentation bundled as a shared library.

  When profiling multiple DLLs, including GpProf.pas directly in each DLL
  results in a separate lock and log file per DLL. By linking all profiled
  modules against this shared DLL instead, only one lock and one log file are
  used across all modules in the process.
*)

library GpProfDll;

uses
  GpProf in '..\..\include\GpProf.pas',
  GpProfH in '..\..\include\GpProfH.pas',
  GpProfCommon in '..\..\include\GpProfCommon.pas';

exports
  ProfilerStart,
  ProfilerStop,
  ProfilerStartThread,
  ProfilerEnterProc,
  ProfilerExitProc,
  ProfilerEnterMP,
  ProfilerExitMP,
  CreateMeasurePointScope,
  ProfilerTerminate,
  NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID) name 'NameThreadForDebuggingA',
  NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID) name 'NameThreadForDebuggingW';

begin
end.
