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
  Windows,
  GpProf in '..\..\include\GpProf.pas',
  GpProfH in '..\..\include\GpProfH.pas',
  GpProfCommon in '..\..\include\GpProfCommon.pas';

// ---------------------------------------------------------------------------
// Per-client session tracking.
//
// DllAcquireSession is called by GpProfDllClient.pas when a new context
// object is created (TGpProfContextClient.Create).  It returns an opaque
// token — a pointer to a small heap record with a magic signature — that
// the client holds as long as its IGpProfContext is alive.
//
// DllReleaseSession is called by TGpProfContextClient.Destroy.  It frees
// the token.  Both functions are exported so that GpProfDllClient.pas can
// bind them at run time via GetProcAddress.
// ---------------------------------------------------------------------------

type
  PGpProfSession = ^TGpProfSession;
  TGpProfSession = record
    Signature: Cardinal;   // sanity marker checked in DllReleaseSession
  end;

const
  SESSION_SIGNATURE = $47505253;  // sanity marker (0x47505253)

function DllAcquireSession: Pointer;
var
  s: PGpProfSession;
begin
  New(s);
  s^.Signature := SESSION_SIGNATURE;
  Result := s;
end;

procedure DllReleaseSession(session: Pointer);
var
  s: PGpProfSession;
begin
  s := PGpProfSession(session);
  if (s <> nil) and (s^.Signature = SESSION_SIGNATURE) then begin
    s^.Signature := 0;
    Dispose(s);
  end;
end;

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
  NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID) name 'NameThreadForDebuggingW',
  DllAcquireSession,
  DllReleaseSession;

begin
end.
