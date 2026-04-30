{$R-,C-,Q-,O+,H+}

(*
  GpProfile DLL client — dynamic accessor for GpProfDll.dll.

  Drop-in replacement for GpProf.pas for modules that want to call into
  GpProfDll.dll at run time instead of statically linking the profiling
  instrumentation.  All public symbols mirror the GpProf.pas interface.

  Usage
  -----
    Replace  "uses GpProf"  with  "uses GpProfDllClient".
    Ensure GpProfDll.dll is present on the DLL search path at run time.
    If the DLL is not found, every profiling call is a safe no-op.

  Loading / unloading
  -------------------
    LoadLibrary   is called in the unit initialization section.
    FreeLibrary   is called in the unit finalization section.
    Each wrapper procedure checks Assigned(fn) before calling, so the unit
    is safe to use even when GpProfDll.dll is absent.

  Scope adapter
  -------------
    CreateMeasurePointScope creates a TMeasurePointScopeClient object in
    this module's heap.  ProfilerEnterMP / ProfilerExitMP are forwarded to
    the DLL through function pointers, so no Delphi interface reference ever
    crosses the DLL boundary.
*)

unit GpProfDllClient;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}

{$IF CompilerVersion > 19}
  {$DEFINE HAS_NAME_THREAD_FOR_DEBUGGING}
  {$DEFINE HAS_THREAD_ID_TYPE}
{$IFEND}

{$IFNDEF HAS_THREAD_ID_TYPE}
type
  TThreadID = Cardinal;
{$ENDIF}

type
  /// <summary>
  /// Marker interface for a measure point scope.
  /// Upon destruction, ProfilerExitMP is called through the DLL.
  /// </summary>
  IMeasurePointScope = interface
    ['{9F2A8B7C-1D3E-4F5A-8C6B-7E9D0A2B4C5F}']
  end;

  /// <summary>
  /// Object-oriented handle to the shared profiling context exposed by the DLL.
  /// Mirrors the old per-module state that every statically-linked GpProf unit
  /// used to own.  Acquire one per module via AcquireGpProfContext; release it
  /// by setting the variable to nil (reference-counted) or calling DisposeGpProfContext.
  /// </summary>
  IGpProfContext = interface
    ['{B2C3D4E5-F6A7-8B9C-0D1E-2F3A4B5C6D7E}']
    procedure Start;
    procedure Stop;
    procedure StartThread;
    procedure EnterProc(const aProcID: Cardinal);
    procedure ExitProc(const aProcID: Cardinal);
    procedure EnterMP(const aMeasurePointId: UTF8String);
    procedure ExitMP(const aMeasurePointId: UTF8String);
    function  CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;
    procedure Terminate;
{$IFDEF UNICODE}
    procedure NameThread(const AThreadName: AnsiString; AThreadID: TThreadID); overload;
    procedure NameThread(const AThreadName: string;     AThreadID: TThreadID); overload;
{$ELSE}
    procedure NameThread(const AThreadName: string; AThreadID: TThreadID);
{$ENDIF}
  end;

/// <summary>
/// Acquires a new IGpProfContext handle for the calling module.
/// Notifies the DLL that a client session has been opened (DllAcquireSession).
/// Release by setting the returned interface to nil, which calls DllReleaseSession.
/// Returns nil when the DLL could not be loaded.
/// </summary>
function AcquireGpProfContext: IGpProfContext;

/// <summary>
/// Convenience wrapper: sets Ctx to nil, which triggers reference-counted
/// destruction and calls DllReleaseSession in the DLL.
/// </summary>
procedure DisposeGpProfContext(var Ctx: IGpProfContext);

procedure ProfilerStart;
procedure ProfilerStop;
procedure ProfilerStartThread;

procedure ProfilerEnterProc(const aProcID: Cardinal);
procedure ProfilerExitProc(const aProcID: Cardinal);

procedure ProfilerEnterMP(const aMeasurePointId: UTF8String);
procedure ProfilerExitMP(const aMeasurePointId: UTF8String);

function  CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;

procedure ProfilerTerminate;

{$IFDEF UNICODE}
procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID = TThreadID(-1)); overload; inline;
procedure NameThreadForDebugging(const AThreadName: string;     AThreadID: TThreadID = TThreadID(-1)); overload;
{$ELSE}
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID = TThreadID(-1));
{$ENDIF}

implementation

uses
  Windows,
  SysUtils;

// ---------------------------------------------------------------------------
// DLL function-pointer types.
// No explicit calling convention is declared here so that Delphi uses the
// same default 'register' convention that GpProf.pas / GpProfDll.dll use.
// ---------------------------------------------------------------------------

type
  TProcNoArgs      = procedure;
  TProcCardinal    = procedure(const aProcID: Cardinal);
  TProcUTF8Str     = procedure(const aMeasurePointId: UTF8String);
  TProcTerminate   = procedure;
{$IFDEF UNICODE}
  TProcNameThreadA = procedure(const AThreadName: AnsiString; AThreadID: TThreadID);
  TProcNameThreadW = procedure(const AThreadName: string;     AThreadID: TThreadID);
{$ELSE}
  TProcNameThreadW = procedure(const AThreadName: string; AThreadID: TThreadID);
{$ENDIF}
  TFnAcquireSession = function: Pointer;
  TProcReleaseSession = procedure(session: Pointer);

var
  GpProfDllHandle     : HMODULE = 0;
  _ProfilerStart      : TProcNoArgs      = nil;
  _ProfilerStop       : TProcNoArgs      = nil;
  _ProfilerStartThread: TProcNoArgs      = nil;
  _ProfilerEnterProc  : TProcCardinal    = nil;
  _ProfilerExitProc   : TProcCardinal    = nil;
  _ProfilerEnterMP    : TProcUTF8Str     = nil;
  _ProfilerExitMP     : TProcUTF8Str     = nil;
  _ProfilerTerminate  : TProcTerminate   = nil;
{$IFDEF UNICODE}
  _NameThreadForDebuggingA: TProcNameThreadA = nil;
{$ENDIF}
  _NameThreadForDebuggingW: TProcNameThreadW = nil;
  _DllAcquireSession  : TFnAcquireSession    = nil;
  _DllReleaseSession  : TProcReleaseSession  = nil;

// ---------------------------------------------------------------------------
// Client-side scope adapter — no COM interface reference crosses the DLL boundary.
// ProfilerEnterMP is called by CreateMeasurePointScope before creating the
// scope object; ProfilerExitMP is called in the destructor.
// ---------------------------------------------------------------------------

type
  TMeasurePointScopeClient = class(TInterfacedObject, IMeasurePointScope)
  private
    fMeasurePointId: UTF8String;
  public
    constructor Create(const aMeasurePointId: UTF8String);
    destructor Destroy; override;
  end;

constructor TMeasurePointScopeClient.Create(const aMeasurePointId: UTF8String);
begin
  fMeasurePointId := aMeasurePointId;
end;

destructor TMeasurePointScopeClient.Destroy;
begin
  ProfilerExitMP(fMeasurePointId);
  inherited;
end;

// ---------------------------------------------------------------------------
// TGpProfContextClient — object-oriented wrapper around the DLL function
// pointers. One instance per module (obtained via AcquireGpProfContext).
// Holds an opaque session token returned by DllAcquireSession; releases it
// in the destructor via DllReleaseSession, notifying the DLL.
// ---------------------------------------------------------------------------

type
  TGpProfContextClient = class(TInterfacedObject, IGpProfContext)
  private
    fSessionToken: Pointer;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Start;
    procedure Stop;
    procedure StartThread;
    procedure EnterProc(const aProcID: Cardinal);
    procedure ExitProc(const aProcID: Cardinal);
    procedure EnterMP(const aMeasurePointId: UTF8String);
    procedure ExitMP(const aMeasurePointId: UTF8String);
    function  CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;
    procedure Terminate;
{$IFDEF UNICODE}
    procedure NameThread(const AThreadName: AnsiString; AThreadID: TThreadID); overload;
    procedure NameThread(const AThreadName: string;     AThreadID: TThreadID); overload;
{$ELSE}
    procedure NameThread(const AThreadName: string; AThreadID: TThreadID);
{$ENDIF}
  end;

constructor TGpProfContextClient.Create;
begin
  if Assigned(_DllAcquireSession) then
    fSessionToken := _DllAcquireSession()
  else
    fSessionToken := nil;
end;

destructor TGpProfContextClient.Destroy;
begin
  if Assigned(_DllReleaseSession) and (fSessionToken <> nil) then
    _DllReleaseSession(fSessionToken);
  fSessionToken := nil;
  inherited;
end;

procedure TGpProfContextClient.Start;
begin ProfilerStart; end;

procedure TGpProfContextClient.Stop;
begin ProfilerStop; end;

procedure TGpProfContextClient.StartThread;
begin ProfilerStartThread; end;

procedure TGpProfContextClient.EnterProc(const aProcID: Cardinal);
begin ProfilerEnterProc(aProcID); end;

procedure TGpProfContextClient.ExitProc(const aProcID: Cardinal);
begin ProfilerExitProc(aProcID); end;

procedure TGpProfContextClient.EnterMP(const aMeasurePointId: UTF8String);
begin ProfilerEnterMP(aMeasurePointId); end;

procedure TGpProfContextClient.ExitMP(const aMeasurePointId: UTF8String);
begin ProfilerExitMP(aMeasurePointId); end;

function TGpProfContextClient.CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;
begin
  ProfilerEnterMP(UTF8String(aMeasurePointId));
  Result := TMeasurePointScopeClient.Create(UTF8String(aMeasurePointId));
end;

procedure TGpProfContextClient.Terminate;
begin ProfilerTerminate; end;

{$IFDEF UNICODE}
procedure TGpProfContextClient.NameThread(const AThreadName: AnsiString; AThreadID: TThreadID);
begin NameThreadForDebugging(AThreadName, AThreadID); end;

procedure TGpProfContextClient.NameThread(const AThreadName: string; AThreadID: TThreadID);
begin NameThreadForDebugging(AThreadName, AThreadID); end;
{$ELSE}
procedure TGpProfContextClient.NameThread(const AThreadName: string; AThreadID: TThreadID);
begin NameThreadForDebugging(AThreadName, AThreadID); end;
{$ENDIF}

// ---------------------------------------------------------------------------
// AcquireGpProfContext / DisposeGpProfContext
// ---------------------------------------------------------------------------

function AcquireGpProfContext: IGpProfContext;
begin
  if GpProfDllHandle = 0 then
    Result := nil
  else
    Result := TGpProfContextClient.Create;
end;

procedure DisposeGpProfContext(var Ctx: IGpProfContext);
begin
  Ctx := nil;
end;

// ---------------------------------------------------------------------------
// Public API — thin wrappers delegating to the loaded DLL function pointers.
// Each wrapper is a safe no-op when the DLL was not loaded.
// ---------------------------------------------------------------------------

procedure ProfilerStart;
begin
  if Assigned(_ProfilerStart) then _ProfilerStart;
end;

procedure ProfilerStop;
begin
  if Assigned(_ProfilerStop) then _ProfilerStop;
end;

procedure ProfilerStartThread;
begin
  if Assigned(_ProfilerStartThread) then _ProfilerStartThread;
end;

procedure ProfilerEnterProc(const aProcID: Cardinal);
begin
  if Assigned(_ProfilerEnterProc) then _ProfilerEnterProc(aProcID);
end;

procedure ProfilerExitProc(const aProcID: Cardinal);
begin
  if Assigned(_ProfilerExitProc) then _ProfilerExitProc(aProcID);
end;

procedure ProfilerEnterMP(const aMeasurePointId: UTF8String);
begin
  if Assigned(_ProfilerEnterMP) then _ProfilerEnterMP(aMeasurePointId);
end;

procedure ProfilerExitMP(const aMeasurePointId: UTF8String);
begin
  if Assigned(_ProfilerExitMP) then _ProfilerExitMP(aMeasurePointId);
end;

function CreateMeasurePointScope(const aMeasurePointId: string): IMeasurePointScope;
begin
  ProfilerEnterMP(UTF8String(aMeasurePointId));
  Result := TMeasurePointScopeClient.Create(UTF8String(aMeasurePointId));
end;

procedure ProfilerTerminate;
begin
  if Assigned(_ProfilerTerminate) then _ProfilerTerminate;
end;

{$IFDEF UNICODE}
procedure NameThreadForDebugging(const AThreadName: AnsiString; AThreadID: TThreadID);
begin
  if Assigned(_NameThreadForDebuggingA) then
    _NameThreadForDebuggingA(AThreadName, AThreadID);
end;

procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID);
begin
  if Assigned(_NameThreadForDebuggingW) then
    _NameThreadForDebuggingW(AThreadName, AThreadID);
end;
{$ELSE}
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: TThreadID);
begin
  if Assigned(_NameThreadForDebuggingW) then
    _NameThreadForDebuggingW(AThreadName, AThreadID);
end;
{$ENDIF}

// ---------------------------------------------------------------------------
// DLL lifecycle
// ---------------------------------------------------------------------------

const
{$IFDEF WIN64}
  GPPROFLIB = 'GpProfDll64.dll';
{$ELSE}
  GPPROFLIB = 'GpProfDll32.dll';
{$ENDIF}

procedure LoadGpProfDll;
begin
  GpProfDllHandle := LoadLibrary(GPPROFLIB);
  if GpProfDllHandle = 0 then Exit;

  _ProfilerStart       := GetProcAddress(GpProfDllHandle, 'ProfilerStart');
  _ProfilerStop        := GetProcAddress(GpProfDllHandle, 'ProfilerStop');
  _ProfilerStartThread := GetProcAddress(GpProfDllHandle, 'ProfilerStartThread');
  _ProfilerEnterProc   := GetProcAddress(GpProfDllHandle, 'ProfilerEnterProc');
  _ProfilerExitProc    := GetProcAddress(GpProfDllHandle, 'ProfilerExitProc');
  _ProfilerEnterMP     := GetProcAddress(GpProfDllHandle, 'ProfilerEnterMP');
  _ProfilerExitMP      := GetProcAddress(GpProfDllHandle, 'ProfilerExitMP');
  _ProfilerTerminate   := GetProcAddress(GpProfDllHandle, 'ProfilerTerminate');
{$IFDEF UNICODE}
  _NameThreadForDebuggingA := GetProcAddress(GpProfDllHandle, 'NameThreadForDebuggingA');
{$ENDIF}
  _NameThreadForDebuggingW := GetProcAddress(GpProfDllHandle, 'NameThreadForDebuggingW');
  _DllAcquireSession       := GetProcAddress(GpProfDllHandle, 'DllAcquireSession');
  _DllReleaseSession       := GetProcAddress(GpProfDllHandle, 'DllReleaseSession');
end;

procedure UnloadGpProfDll;
begin
  if GpProfDllHandle = 0 then Exit;
  FreeLibrary(GpProfDllHandle);
  GpProfDllHandle      := 0;
  _ProfilerStart       := nil;
  _ProfilerStop        := nil;
  _ProfilerStartThread := nil;
  _ProfilerEnterProc   := nil;
  _ProfilerExitProc    := nil;
  _ProfilerEnterMP     := nil;
  _ProfilerExitMP      := nil;
  _ProfilerTerminate   := nil;
{$IFDEF UNICODE}
  _NameThreadForDebuggingA := nil;
{$ENDIF}
  _NameThreadForDebuggingW := nil;
  _DllAcquireSession       := nil;
  _DllReleaseSession       := nil;
end;

initialization
  LoadGpProfDll;

finalization
  UnloadGpProfDll;

end.
