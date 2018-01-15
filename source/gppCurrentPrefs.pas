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
  prefPrfFilenameResolvedMakro : string;
  prefProfilingAutostart    : boolean;
  prefInstrumentAssembler   : boolean;

  // the selected compiler version
  selectedDelphi            : string;
  // the output dir as defined in the project
  ProjectOutputDir          : string;
  // the selected platform in the project
  XE2Platform               : string;
  XE2PlatformOverride       : string;
  // the selected config in the project
  XE2Config                 : string;
  XE2ConfigOverride         : string;




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
  gpPrfPlaceholders;

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
        prefSpeedSize          := ReadInteger('SpeedSize',1);
        prefCompilerVersion    := ReadInteger('CompilerVersion',-1);
        prefHideNotExecuted    := ReadBool   ('HideNotExecuted',true);
        prefShowAllFolders     := ReadBool   ('ShowAllFolders',false);
        prefStandardDefines    := ReadBool   ('StandardDefines',true);
        prefProjectDefines     := ReadBool   ('ProjectDefines',true);
        prefDisableUserDefines := ReadBool   ('DisableUserDefines',false);
        prefUserDefines        := ReadString ('UserDefines','');
        prefProfilingAutostart := ReadBool   ('ProfilingAutostart',true);
        prefInstrumentAssembler:= ReadBool   ('InstrumentAssembler',false);
        prefKeepFileDate       := ReadBool   ('KeepFileDate',false);
        prefUseFileDate        := ReadBool   ('UseFileDate',true);
        prefPrfFilenameMakro   := ReadString ('PrfFilenameMakro',TPrfPlaceholder.PrfPlaceholderToMacro(TPrfPlaceholderType.ModulePath));
      finally
        CloseKey;
      end;
    finally
      Free;
    end;
end; { TfrmMain.LoadPreferences }

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
    WriteBool   ('KeepFileDate',       prefKeepFileDate);
    WriteBool   ('UseFileDate',        prefUseFileDate);
    WriteString ('PrfFilenameMakro',   prefPrfFilenameMakro);
    Free;
  end;
end; { TfrmMain.SavePreferences }


end.
