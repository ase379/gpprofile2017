unit gppCurrentPrefs;

interface

var
  CurrentProjectName        : string;
  prefExcludedUnits         : string;
  prefMarkerStyle           : integer;
  prefCompilerVersion       : integer;
  prefHideNotExecuted       : boolean;
  prefSpeedSize             : integer;
  prefShowAllFolders        : boolean;
  prefStandardDefines       : boolean;
  prefProjectDefines        : boolean;
  prefDisableUserDefines    : boolean;
  prefUserDefines           : string;
  prefKeepFileDate          : boolean;
  prefUseFileDate           : boolean;
  prefPrfFilenameMakro      : string;
  prefProfilingAutostart    : boolean;
  prefInstrumentAssembler   : boolean;

function GetDOFSettingBool(const section, key: string;  defval: boolean): boolean;


implementation

uses
  System.SysUtils,
  System.IniFiles;

function GetDOFSettingBool(const section, key: string;  defval: boolean): boolean;
begin
  Result := False;
  if CurrentProjectName <>'' then
    with TIniFile.Create(ChangeFileExt(CurrentProjectName,'.dof')) do
      try
        Result := ReadBool(section, key, defval);
      finally
        Free;
      end;
end;

end.
