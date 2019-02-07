unit gppCurrentPrefs;

interface

const
  { no tick or thread info compression}
  PREF_SPEEDSIZE_1 = 1;
  { tick compression, no thread info compression}
  PREF_SPEEDSIZE_2 = 2;
  { tick compression, thread compression}
  PREF_SPEEDSIZE_3 = 3;

  PREF_MAX_SPEEDSIZE = PREF_SPEEDSIZE_3;

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
  prefMakeBackupOfInstrumentedFile : boolean;

  // the selected compiler version
  selectedDelphi            : string;
  // the output dir as defined in the project
  ProjectOutputDir          : string;


procedure SetProjectPref(name: string; value: variant); overload;
function  GetProjectPref(name: string; defval: variant): variant; overload;
procedure DelProjectPref(name: string);
procedure SetProfilePref(name: string; value: variant); overload;
function  GetProfilePref(name: string; defval: variant): variant; overload;
function HasOpenProject: boolean;



function GetDOFSettingBool(const section, key: string;  defval: boolean): boolean;


procedure LoadPreferences;

/// saves the (global) preferences in the registry
procedure SavePreferences;


implementation

uses
  winapi.windows,
  System.SysUtils,
  System.IniFiles,
  gppCommon,
  gpiff,
  gpregistry,
  gpPrfPlaceholders, 
  GpString;

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

procedure LoadPreferences;
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey(cRegistryRoot+'\Preferences', True);
      try
        prefExcludedUnits      := ReadString ('ExcludedUnits',defaultExcludedUnits);
        prefMarkerStyle        := ReadInteger('MarkerStyle',0);
        prefSpeedSize          := ReadInteger('SpeedSize',PREF_SPEEDSIZE_1);
        prefCompilerVersion    := ReadInteger('CompilerVersion',-1);
        prefHideNotExecuted    := ReadBool   ('HideNotExecuted',true);
        prefShowAllFolders     := ReadBool   ('ShowAllFolders',false);
        prefStandardDefines    := ReadBool   ('StandardDefines',true);
        prefProjectDefines     := ReadBool   ('ProjectDefines',true);
        prefDisableUserDefines := ReadBool   ('DisableUserDefines',false);
        prefUserDefines        := ReadString ('UserDefines','');
        prefProfilingAutostart := ReadBool   ('ProfilingAutostart',true);
        prefInstrumentAssembler:= ReadBool   ('InstrumentAssembler',false);
        prefMakeBackupOfInstrumentedFile := ReadBool('MakeBackupOfInstrumentedFile', true);
        prefKeepFileDate       := ReadBool   ('KeepFileDate',false);
        prefUseFileDate        := ReadBool   ('UseFileDate',true);
        prefPrfFilenameMakro   := ReadString ('PrfFilenameMakro',TPrfPlaceholder.PrfPlaceholderToMacro(TPrfPlaceholderType.ModulePath));
      finally
        CloseKey;
      end;
    finally
      Free;
    end;
end; { LoadPreferences }

procedure SavePreferences;
begin
  with TGpRegistry.Create do begin
    RootKey := HKEY_CURRENT_USER;
    OpenKey(cRegistryRoot+'\Preferences',true);
    WriteString ('ExcludedUnits',      prefExcludedUnits);
    WriteInteger('MarkerStyle',        prefMarkerStyle);
    WriteInteger('SpeedSize',          prefSpeedSize);
    WriteInteger('CompilerVersion',    prefCompilerVersion);
    WriteBool   ('HideNotExecuted',    prefHideNotExecuted);
    WriteBool   ('ShowAllFolders',     prefShowAllFolders);
    WriteBool   ('StandardDefines',    prefStandardDefines);
    WriteBool   ('ProjectDefines',     prefProjectDefines);
    WriteBool   ('DisableUserDefines', prefDisableUserDefines);
    WriteString ('UserDefines',        prefUserDefines);
    WriteBool   ('ProfilingAutostart', prefProfilingAutostart);
    WriteBool   ('InstrumentAssembler',prefInstrumentAssembler);
    WriteBool   ('MakeBackupOfInstrumentedFile', prefMakeBackupOfInstrumentedFile);

    WriteBool   ('KeepFileDate',       prefKeepFileDate);
    WriteBool   ('UseFileDate',        prefUseFileDate);
    WriteString ('PrfFilenameMakro',   prefPrfFilenameMakro);
    Free;
  end;
end; { SavePreferences }

procedure SetProjectPref(name: string; value: variant);
begin
  TGpRegistryTools.SetPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name,value);
end; { SetProjectPref }

function GetProjectPref(name: string; defval: variant): variant;
begin
  if not HasOpenProject then 
    Result := defval
  else 
    Result := TGpRegistryTools.GetPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name,defval);
end; { GetProjectPref }

procedure DelProjectPref(name: string);
begin
  if HasOpenProject then TGpRegistryTools.DelPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name);
end; { DelProjectPref }

procedure SetProfilePref(name: string; value: variant);
begin
  TGpRegistryTools.SetPref('\Profiles\'+ReplaceAll(CurrentProjectName,'\','/'),name,value);
end; { SetProfilePref }

function GetProfilePref(name: string; defval: variant): variant;
begin
  if not HasOpenProject then 
    Result := defval
  else 
    Result := TGpRegistryTools.GetPref('\Profiles\'+ReplaceAll(CurrentProjectName,'\','/'),name,defval);
end; { GetProfilePref }

function HasOpenProject: boolean;
begin
  result := Length(Trim(CurrentProjectName)) <> 0;
end; { HasOpenProject }

end.
