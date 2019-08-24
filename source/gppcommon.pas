{$I OPTIONS.INC}

unit gppCommon;

interface

uses
  Windows;

const
  cRegistryRoot  = 'SOFTWARE\GpProfileReborn';
  cRegistryUIsub = 'UI';
  cRegistryUI    = cRegistryRoot + '\' + cRegistryUIsub;
  cUIVersion     = '1.0.3';
  cDefLayout     = 'default';

function GetDefaultExcludedUnits(): string;
procedure KillFile(fName: String);
function WinExecAndWait32(FileName: String; Visibility: integer): LongWord;
function HasParameter(const aParam: String): Boolean;
function IsAbsolutePath(const aPath: String): Boolean;

implementation

uses
  System.Classes, System.SysUtils, GpString, Vcl.Forms;

function GetDefaultExcludedUnits(): string;
var
  LExcludedUnitsFile : string;
  LStringList : TStringList;
begin
  result := '';
  LExcludedUnitsFile := ChangeFileExt(Application.ExeName, '.eul');
  if FileExists(LExcludedUnitsFile) then
  begin
    LStringList := TStringList.Create();
    LStringList.LoadFromFile(LExcludedUnitsFile);
    if LStringList.Count>0 then
    begin
      Result := result + sLineBreak + UpperCase(LStringList.GetText());
    end;
    LStringList.Free;
  end;
end;


procedure KillFile(fName: String);
begin
  if FileExists(fName) then begin
    SetFileAttributes(PChar(fName), 0);
    DeleteFile(fName);
  end;
end; { KillFile }

function WinExecAndWait32(FileName: String; Visibility: integer): LongWord;
var { by Pat Ritchey }
  zAppName   : array[0..512] of char;
  zCurDir    : array[0..255] of char;
  WorkDir    : String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
    zAppName, // pointer to command line string
    nil, // pointer to process security attributes
    nil, // pointer to thread security attributes
    false, // handle inheritance flag
    CREATE_NEW_CONSOLE or // creation flags
    NORMAL_PRIORITY_CLASS,
    nil, //pointer to new environment block
    nil, // pointer to current directory name
    StartupInfo, // pointer to STARTUPINFO
    ProcessInfo) // pointer to PROCESS_INF
  then Result := WAIT_FAILED
  else begin
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end; { WinExecAndWait32 }

function HasParameter(const aParam: String): boolean;
var
  i: integer;
begin
  for i := 1 to ParamCount do
    if AnsiSameText(ParamStr(i), aParam) then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end; { HasParameter }

function IsAbsolutePath(const aPath: String): Boolean;
begin
  Result := ((Length(aPath) > 0) and (charInSet(aPath[1],['/','\']))) or
            ((Length(aPath) > 1) and (CharInSet(aPath[2],[':'])));
end; { TfrmMain.IsAbsolutePath }

end.
