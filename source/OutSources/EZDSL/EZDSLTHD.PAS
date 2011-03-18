{===EZDSLTHD==========================================================

Part of the EZ Delphi Structures Library--the thread support routines

EZDSLTHD is Copyright (c) 1993-1998 by  Julian M. Bucknall

VERSION HISTORY
19Apr98 JMB 3.00 Initial release
=====================================================================}
{ Copyright (c) 1993-1998, Julian M. Bucknall. All Rights Reserved   }

unit EZDSLThd;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here----------------------}


{--------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFNDEF Win32}
  !! This unit is for 32-bit programming only
{$ENDIF}

interface

uses
  {$IFDEF Win32}
  Windows,
  {$ELSE}
  WinTypes,
  WinProcs,
  {$ENDIF}
  SysUtils;

type
  TezWaitResult = (                 {"Wait for" results...}
                   arSuccess,       {..successful}
                   arTimeout,       {..wait timed out}
                   arAbandoned,     {..object was abandoned}
                   arFailed);       {..call failed}

  TezEventResetType = (             {Types of Win32 Events...}
                       ertAuto,     {..autoreset event}
                       ertManual);  {..manual reset event}

type
  TezResourceLock = class
    {-Encapsulation of Win32's Critical Section}
    protected {private}
      rlCritSect : TRTLCriticalSection;
    protected
    public
      constructor Create;
      destructor Destroy; override;

      procedure Lock;
      procedure Unlock;
  end;

  TezWaitableObject = class
    {-A Win32 Kernel synchronization object that can be waited on to
      be signalled and that can be released}
    protected {private}
      woLastError : integer;
    protected
      woHandle    : THandle;

      procedure woResetError;
      procedure woRetrieveError;
    public
      destructor Destroy; override;

      function IsValid : boolean;
      function Release  : boolean; virtual;
      function WaitFor(aTimeOut : integer) : TezWaitResult;

      property Handle : THandle read woHandle;
      property LastError : integer read woLastError;
    end;

  TezMutex = class (TezWaitableObject)
    {-A Win32 Mutex}
    protected {private}
    protected
    public
      constructor Create(const aMutexName    : string;
                               aOpenExisting : boolean);
      function Release  : boolean; override;
  end;

  TezEvent = class (TezWaitableObject)
    {-A Win32 Event}
    protected {private}
    protected
    public
      constructor Create(const aEventName    : string;
                               aOpenExisting : boolean;
                               aResetType    : TezEventResetType;
                               aInitSignaled : boolean);
      function Pulse : boolean;
      function Reset : boolean;
      function Signal : boolean;
  end;

  TezSemaphore = class (TezWaitableObject)
    {-A Win32 Semaphore}
    protected {private}
    protected
    public
      constructor Create(const aSemaphoreName : string;
                               aOpenExisting  : boolean;
                               aInitCount     : integer;
                               aMaxCount      : integer);
      function Release  : boolean; override;
  end;


implementation

const
  SEMAPHORE_MODIFY_STATE = $0002; {missed out from Delphi's WINDOWS.PAS}


{===TezResourceLock==================================================}
constructor TezResourceLock.Create;
begin
  inherited Create;
  InitializeCriticalSection(rlCritSect);
end;
{--------}
destructor TezResourceLock.Destroy;
begin
  DeleteCriticalSection(rlCritSect);
  inherited Destroy;
end;
{--------}
procedure TezResourceLock.Lock;
begin
  EnterCriticalSection(rlCritSect);
end;
{--------}
procedure TezResourceLock.Unlock;
begin
  LeaveCriticalSection(rlCritSect);
end;
{====================================================================}


{===TezWaitableObject================================================}
destructor TezWaitableObject.Destroy;
begin
  if (woHandle <> INVALID_HANDLE_VALUE) then
    CloseHandle(woHandle);
  inherited Destroy;
end;
{--------}
function TezWaitableObject.IsValid : boolean;
begin
  if (Handle <> INVALID_HANDLE_VALUE) then begin
    Result := true;
    woLastError := 0;
  end
  else begin
    Result := false;
    woLastError := INVALID_HANDLE_VALUE;
  end;
end;
{--------}
function TezWaitableObject.Release  : boolean;
begin
  Result := true;
end;
{--------}
function TezWaitableObject.WaitFor(aTimeOut : integer) : TezWaitResult;
var
  WaitResult : integer;
begin
  woResetError;
  WaitResult := WaitForSingleObject(woHandle, aTimeOut);
  if (WaitResult = WAIT_OBJECT_0) then
    Result := arSuccess
  else if (WaitResult = WAIT_TIMEOUT) then
    Result := arTimeout
  else if (WaitResult = WAIT_ABANDONED) then
    Result := arAbandoned
  else begin
    Result := arFailed;
    woRetrieveError;
  end;
end;
{--------}
procedure TezWaitableObject.woResetError;
begin
  woLastError := 0;
end;
{--------}
procedure TezWaitableObject.woRetrieveError;
begin
  woLastError := Windows.GetLastError;
end;
{====================================================================}


{===TezMutex=========================================================}
constructor TezMutex.Create(const aMutexName    : string;
                                  aOpenExisting : boolean);
begin
  inherited Create;
  if aOpenExisting then
    woHandle := OpenMutex(MUTEX_ALL_ACCESS, false, PChar(aMutexName))
  else
    woHandle := CreateMutex(nil, false, PChar(aMutexName));
  if (woHandle = 0) then begin
    woHandle := INVALID_HANDLE_VALUE;
    woRetrieveError;
  end;
end;
{--------}
function TezMutex.Release : boolean;
begin
  Result := false;
  if IsValid then
    if ReleaseMutex(Handle) then
      Result := true
    else
      woRetrieveError;
end;
{====================================================================}


{===TezEvent=========================================================}
constructor TezEvent.Create(const aEventName    : string;
                                  aOpenExisting : boolean;
                                  aResetType    : TezEventResetType;
                                  aInitSignaled : boolean);
begin
  inherited Create;
  if aOpenExisting then
    woHandle := OpenEvent(EVENT_MODIFY_STATE, false, PChar(aEventName))
  else
    woHandle := CreateEvent(nil, (aResetType = ertManual),
                            aInitSignaled, PChar(aEventName));
  if (woHandle = 0) then begin
    woHandle := INVALID_HANDLE_VALUE;
    woRetrieveError;
  end;
end;
{--------}
function TezEvent.Pulse : boolean;
begin
  Result := false;
  if IsValid then
    if PulseEvent(Handle) then
      Result := true
    else
      woRetrieveError;
end;
{--------}
function TezEvent.Reset : boolean;
begin
  Result := false;
  if IsValid then
    if ResetEvent(Handle) then
      Result := true
    else
      woRetrieveError;
end;
{--------}
function TezEvent.Signal : boolean;
begin
  Result := false;
  if IsValid then
    if SetEvent(Handle) then
      Result := true
    else
      woRetrieveError;
end;
{====================================================================}


{===TezSemaphore=====================================================}
constructor TezSemaphore.Create(const aSemaphoreName : string;
                                      aOpenExisting  : boolean;
                                      aInitCount     : integer;
                                      aMaxCount      : integer);
begin
  inherited Create;
  if aOpenExisting then
    woHandle := OpenSemaphore(SEMAPHORE_MODIFY_STATE, false, PChar(aSemaphoreName))
  else
    woHandle := CreateSemaphore(nil, aInitCount, aMaxCount, PChar(aSemaphoreName));
  if (woHandle = 0) then begin
    woHandle := INVALID_HANDLE_VALUE;
    woRetrieveError;
  end;
end;
{--------}
function TezSemaphore.Release  : boolean;
begin
  Result := false;
  if IsValid then
    if ReleaseSemaphore(Handle, 1, nil) then
      Result := true
    else
      woRetrieveError;
end;
{====================================================================}


end.
