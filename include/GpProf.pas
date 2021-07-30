{$R-,C-,Q-,O+,H+}

(*
  1.11: 1999-08-12
    - Added support for Delphi 5.
  1.1: 1999-08-10
    - Fixed long-standing bug that caused corrupted profile file when profiling
      large projects.
  1.0.1: 1999-05-12
    - Support for DLL and package profiling (GetModuleName is used instead of
      ParamStr(0)).
    - Error is reported if <module>.gpi or <module>.gpd file is not found.
*)

unit gpprof;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}

uses System.Classes;

procedure ProfilerStart;
procedure ProfilerStop;
procedure ProfilerStartThread;
procedure ProfilerEnterProc(procID: integer);
procedure ProfilerExitProc(procID: integer);
procedure ProfilerTerminate;
procedure NameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
procedure NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;

implementation

uses
  SysUtils,
  windows,
  GpProfH,
  gpprofCommon,
  gpprof.prf;


var
  gPerformanceTracker : TPerformanceTracker;

procedure ProfilerStart;
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.ProfilerStart;
end; { ProfilerStart }


procedure ProfilerStop;
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.ProfilerStop;
end; { ProfilerStop }


procedure ProfilerStartThread;
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.ProfilerStartThread;
end; { ProfilerStartThread }


procedure profilerEnterProc(procID : integer);
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.profilerEnterProc(procID);
end; { ProfilerEnterProc }

procedure ProfilerExitProc(procID : integer);
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.profilerExitProc(procID);
end; { ProfilerExitProc }

procedure ProfilerTerminate;
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.ProfilerTerminate;
end; { ProfilerTerminate }

procedure NameThreadForDebugging(AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload;
begin
  if assigned(gPerformanceTracker) then
    NameThreadForDebugging(string(aThreadName), aThreadID);
end; { NameThreadForDebugging }


procedure NameThreadForDebugging(AThreadName: string; AThreadID: TThreadID = TThreadID(-1)); overload;
begin
  if assigned(gPerformanceTracker) then
    gPerformanceTracker.NameThreadForDebugging(AThreadName, AThreadID);
end; { NameThreadForDebugging }


initialization
  try
    // initalizes the prf core and loads the config. Throws upon error.
    gPerformanceTracker := TPerformanceTracker.Create();
    gpprof.NameThreadForDebugging('Main Application Thread', MainThreadID);
  except
    on e: exception do
    begin
      FreeAndNil(gPerformanceTracker);
      MessageBox(0, pWideChar(e.Message), 'GpProfile', MB_OK + MB_ICONERROR);
    end;
  end;

finalization
  FreeAndNil(gPerformanceTracker);
end.

