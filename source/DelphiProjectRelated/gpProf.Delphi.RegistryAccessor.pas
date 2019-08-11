unit gpProf.Delphi.RegistryAccessor;

interface

uses
  System.Classes, System.Win.Registry, System.Generics.Collections, Winapi.Windows;

type
  TDelphiRegistryEntry = class
  private
    fProductVersion : string;
    fApp : string;
    function GetProductName: string;
  public
    constructor Create(const aProductVersion : string);
    property ProductVersion : string read fProductVersion;
    property ProductName : string read GetProductName;
    property App : string read fApp;
  end;
  TDelphiRegistryEntryList = TObjectList<TDelphiRegistryEntry>;

  TRegistryAccessor = class
  private
    fDelphiRegList : TDelphiRegistryEntryList;
    fCheckForExistingExe : Boolean;
    procedure FillInKeyNames(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey: string; const aTargetStringList: TStringList);
    function GetKeyValue(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey, aValue: string): string;

    function GetDelphiRegList(): TDelphiRegistryEntryList;

  public
    constructor Create();
    destructor Destroy; override;

    function GetByProductName(const aProductName : string) : TDelphiRegistryEntry;

    property CheckForExistingExe : Boolean read fCheckForExistingExe write fCheckForExistingExe;
    property RegistryEntries : TDelphiRegistryEntryList read GetDelphiRegList;
  end;


implementation

uses
  System.SysUtils, gpProf.bdsVersions;

const
  REG_PATH_EMBARCADERO_KEYS = '\SOFTWARE\Embarcadero\BDS';
  REG_PATH_BDS_KEYS = '\SOFTWARE\Borland\BDS';
  REG_PATH_BORLAND_23 = '\SOFTWARE\Borland\Delphi';

{ TRegistryAccessor }

constructor TRegistryAccessor.Create();
begin
  inherited Create();
  fCheckForExistingExe := True;
end;

destructor TRegistryAccessor.Destroy;
begin
  fDelphiRegList.Free;
  inherited;
end;

procedure TRegistryAccessor.FillInKeyNames(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey: string; const aTargetStringList: TStringList);
begin
  aTargetStringList.Clear;
  aRegistry.RootKey := aRootKey;
  if aRegistry.OpenKeyReadOnly(aKey) then
  begin
    try
      aRegistry.GetKeyNames(aTargetStringList);
    finally
      aRegistry.CloseKey;
    end;
  end;
end;


function TRegistryAccessor.GetKeyValue(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey, aValue: string): string;
begin
  result := '';
  aRegistry.RootKey := aRootKey;
  if aRegistry.OpenKeyReadOnly(aKey) then
  begin
    try
      result := aRegistry.ReadString(aValue);
    finally
      aRegistry.CloseKey;
    end;
  end;
end;

function TRegistryAccessor.GetByProductName(const aProductName: string): TDelphiRegistryEntry;
var
  i : Integer;
begin
  result := nil;
  for i := 0 to RegistryEntries.count-1 do
  begin
    if RegistryEntries[i].ProductName = aProductName then
      Exit(RegistryEntries[i]);
  end;
end;

function TRegistryAccessor.GetDelphiRegList(): TDelphiRegistryEntryList;
var

  LProductVersionNumbers: TStringList;
  LAppPath : string;
  LRegEntry : TDelphiRegistryEntry;
  LAddIt : Boolean;
  LProductVersion : string;
  LRegistry : TRegistry;
begin
  if assigned(fDelphiRegList) then
    Exit(fDelphiRegList);
  { returns the user settings that exist in the registry }
  LRegistry := TRegistry.Create(KEY_QUERY_VALUE or KEY_WOW64_64KEY);
  result := TDelphiRegistryEntryList.Create(true);
  LProductVersionNumbers := TStringList.Create;

  try
    // Enumerate Delphi versions 2+3
    FillInKeyNames(LRegistry, HKEY_LOCAL_MACHINE,REG_PATH_BORLAND_23,LProductVersionNumbers);
    for LProductVersion in LProductVersionNumbers do
    begin
      LAppPath := GetKeyValue(LRegistry, HKEY_LOCAL_MACHINE, REG_PATH_BORLAND_23+'\'+ LProductVersion,
                 'Delphi ' + GetMajorFromProductVersion(LProductVersion).ToString());
      LAddIt := true;
      if fCheckForExistingExe and not FileExists(LAppPath) then
        LAddIt := false;
      if LAddIt then
      begin
        LRegEntry := TDelphiRegistryEntry.Create(LProductVersion);
        LRegEntry.fApp := LAppPath;
        result.Add(LRegEntry);
      end;
    end;

    // Enumerate Delphi versions 4(-52005-2007
    FillInKeyNames(LRegistry, HKEY_CURRENT_USER,REG_PATH_BDS_KEYS,LProductVersionNumbers);
    for LProductVersion in LProductVersionNumbers do
    begin
      LAppPath := GetKeyValue(LRegistry, HKEY_LOCAL_MACHINE,REG_PATH_BDS_KEYS+'\'+LProductVersion,'App');
      LAddIt := true;
      if fCheckForExistingExe and not FileExists(LAppPath) then
        LAddIt := false;
      if LAddIt then
      begin
        LRegEntry := TDelphiRegistryEntry.Create(LProductVersion);
        LRegEntry.fApp := LAppPath;
        result.Add(LRegEntry);
      end;
    end;

     // Enumerate Delphi 2009-Rio
    FillInKeyNames(LRegistry, HKEY_CURRENT_USER,REG_PATH_EMBARCADERO_KEYS,LProductVersionNumbers);
    for LProductVersion in LProductVersionNumbers do
    begin
      LAppPath := GetKeyValue(LRegistry, HKEY_LOCAL_MACHINE,REG_PATH_EMBARCADERO_KEYS+'\'+LProductVersion,'App');
      LAddIt := true;
      if fCheckForExistingExe and not FileExists(LAppPath) then
        LAddIt := false;
      if LAddIt then
      begin
        LRegEntry := TDelphiRegistryEntry.Create(LProductVersion);
        LRegEntry.fApp := LAppPath;
        result.Add(LRegEntry);
      end;
    end;


  finally
    LProductVersionNumbers.Free;
    LRegistry.Free;
  end;
  // cache the result
  fDelphiRegList := result;
end;

{ TDelphiRegistryEntry }

constructor TDelphiRegistryEntry.Create(const aProductVersion: string);
begin
  inherited Create();
  fProductVersion := aProductVersion;
end;

function TDelphiRegistryEntry.GetProductName: string;
begin
  result := ProductVersionToProductName(fProductVersion);
end;

end.
