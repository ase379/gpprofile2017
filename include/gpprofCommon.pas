unit GpProfCommon;

interface

  function ResolvePrfRuntimePlaceholders(const aFilenameWithPh: string): string;



implementation

uses windows, strUtils,sysutils,TlHelp32;

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

function getCurrentModulePath(): string;
var
  buf: array [0..256] of char;
begin
  GetModuleFileName(HInstance,buf,256);
  result := buf;
end;

function getCurrentModuleName(): string;
begin
  result := getCurrentModulePath();
  result := ChangeFileExt(ExtractFileName(result),'');
end;

function ResolvePrfRuntimePlaceholders(const aFilenameWithPh: string): string;
begin
  result := aFilenameWithPh;
  if HasPrfPlaceholder(result,'$(ProcessID)') then
    ReplacePrfPlaceholders(result,'$(ProcessID)',  UIntToStr (GetCurrentProcessID()));
  if HasPrfPlaceholder(result,'$(ProcessName)') then
    ReplacePrfPlaceholders(result,'$(ProcessName)', GetProcessNameByID(GetCurrentProcessID()));
  if HasPrfPlaceholder(result,'$(ModuleName)') then
    ReplacePrfPlaceholders(result,'$(ModuleName)', getCurrentModuleName());
  if HasPrfPlaceholder(result,'$(ModulePath)') then
    ReplacePrfPlaceholders(result,'$(ModulePath)', ChangeFileExt(getCurrentModulePath(),''));


end;

end.
 