unit GpProfCommon;

interface

{$INCLUDE GpProf.inc}

function ResolvePrfRuntimePlaceholders(const aFilenameWithPh: string): string;

{$IFNDEF HAS_NAME_THREAD_FOR_DEBUGGING}
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: Cardinal);
{$ENDIF}

implementation

uses Windows, StrUtils, SysUtils, TlHelp32;

function HasPrfPlaceholder(var aText: string; const aKey: string): boolean;
var
  lPosition : integer;
begin
  lPosition := PosEx(aKey, aText);
  result := lPosition > 0;
end;

procedure ReplacePrfPlaceholders(var aText: string; const aKey, aNewValue: string);
var
  lPosition : integer;
begin
  lPosition := PosEx(aKey, aText);
  while lPosition > 0 do
  begin
    aText := ReplaceText(aText,aKey,aNewValue);
    lPosition := PosEx(aKey, aText);
  end;
end;

function GetProcessNameByID(const aPidToBeFound: Cardinal): string;
var
  proc: TPROCESSENTRY32;
  hSnap: HWND;
  LProcessFound: BOOL;
  PName: string;
begin
   proc.dwSize := SizeOf(Proc);
   hSnap := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
   try
     LProcessFound := Process32First(hSnap, proc);
     while Integer(LProcessFound) <> 0 do
     begin
        if aPidToBeFound = proc.th32ProcessID then
        begin
          PName := ChangeFileExt(proc.szExeFile,'');
          break;
        end;
        LProcessFound := Process32Next(hSnap, proc);
     end;
   finally
     CloseHandle(hSnap);
   end;
   Result := PName;
end;

function GetCurrentModulePath(): string;
var
  buf: array [0..256] of char;
begin
  GetModuleFileName(HInstance,buf,256);
  result := buf;
end;

function GetCurrentModuleName(): string;
begin
  result := GetCurrentModulePath();
  result := ChangeFileExt(ExtractFileName(result),'');
end;

{$IFNDEF HAS_UINT_TO_STR}
function UIntToStr(const aValue: Cardinal): string;
begin
  result := IntToStr(Int64(aValue));
end;
{$ENDIF}

function ResolvePrfRuntimePlaceholders(const aFilenameWithPh: string): string;
begin
  result := aFilenameWithPh;
  if HasPrfPlaceholder(result,'$(ProcessID)') then
    ReplacePrfPlaceholders(result,'$(ProcessID)', UIntToStr(GetCurrentProcessID()));
  if HasPrfPlaceholder(result,'$(ProcessName)') then
    ReplacePrfPlaceholders(result,'$(ProcessName)', GetProcessNameByID(GetCurrentProcessID()));
  if HasPrfPlaceholder(result,'$(ModuleName)') then
    ReplacePrfPlaceholders(result,'$(ModuleName)', GetCurrentModuleName());
  if HasPrfPlaceholder(result,'$(ModulePath)') then
    ReplacePrfPlaceholders(result,'$(ModulePath)', ChangeFileExt(GetCurrentModulePath(),''));
end;

{$IFNDEF HAS_NAME_THREAD_FOR_DEBUGGING}
procedure NameThreadForDebugging(const AThreadName: string; AThreadID: Cardinal);
type
  {$A8}
  TThreadNameInfo = record
    dwType     : DWORD;   // must be 0x1000
    szName     : LPCSTR;  // pointer to name (in user addr space)
    dwThreadID : DWORD;   // thread ID (-1 indicates caller thread)
    dwFlags    : DWORD;   // reserved for future use, must be zero
  end;
const
  MS_VC_EXCEPTION: DWORD = $406D1388;
var
  LName: AnsiString;
  LInfo: TThreadNameInfo;
begin
  LName := AnsiString(AThreadName);

  // This code is extremely strange, but it's the documented way of doing it
  // https://learn.microsoft.com/en-us/visualstudio/debugger/tips-for-debugging-threads

  LInfo.dwType     := $1000;
  LInfo.szName     := PAnsiChar(LName);
  LInfo.dwThreadID := AThreadID;
  LInfo.dwFlags    := 0;

  try
    RaiseException(MS_VC_EXCEPTION, 0, SizeOf(LInfo) div SizeOf(ULONG_PTR), @LInfo);
  except
    // do nothing
  end;
end;
{$ENDIF}

end.
 