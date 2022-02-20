unit gpProf.Delphi.RegistryAccessor;

interface

uses
  System.Classes, System.Win.Registry, System.Generics.Collections, System.Generics.Defaults, Winapi.Windows;

type
  TDelphiRegistryEntry = class
  private
    fProductVersion : string;
    fApp : string;
    fSearchPathes : TDictionary<String, Byte>;
    fEnvironmentVariables: TDictionary<String, String>;
    function GetProductName: string;
    procedure AppendSearchPath(const aPartToBeAppended: string);
    function getSearchPath: string;
  public
    constructor Create(const aProductVersion : string);
    destructor Destroy; override;
    function GetEnvVar(const aVarName: String): String;
    property ProductVersion : string read fProductVersion;
    property ProductName : string read GetProductName;
    property App : string read fApp;
    property SearchPath : string read getSearchPath;
  end;
  TDelphiRegistryEntryList = TObjectList<TDelphiRegistryEntry>;

  TRegistryAccessor = class
  private
    fDelphiRegList : TDelphiRegistryEntryList;
    fCheckForExistingExe : Boolean;
    fPlatform: string;
    procedure FillInKeyNames(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey: string; const aTargetStringList: TStringList);
    function GetKeyValue(const aRegistry: TRegistry;const aRootKey: HKEY;const aKey, aValue: string): string;

    function GetDelphiRegList(): TDelphiRegistryEntryList;

  public
    constructor Create(const aPlatform: string);
    destructor Destroy; override;

    function GetByProductName(const aProductName : string) : TDelphiRegistryEntry;
    function GetByProductVersion(const aVersion : string) : TDelphiRegistryEntry;

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

constructor TRegistryAccessor.Create(const aPlatform: string);
begin
  inherited Create();
  fCheckForExistingExe := True;
  fPlatform := aPlatform;
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

function TRegistryAccessor.GetByProductVersion(const aVersion: string): TDelphiRegistryEntry;
var
  i : Integer;
begin
  result := nil;
  for i := 0 to RegistryEntries.count-1 do
  begin
    if RegistryEntries[i].fProductVersion = aVersion then
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
  LValueNames : TStringList;
  LName : string;
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

        if LRegistry.OpenKeyReadOnly(REG_PATH_BORLAND_23+'\'+LProductVersion+'\Library') then
        begin
          LRegEntry.AppendSearchPath(LRegistry.ReadString('SearchPath'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Search Path'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Browsing Path'));
          LRegistry.CloseKey;
        end;

        // TODO: Check if Delphi versions 2+3 have environment variables at this registry path
        if LRegistry.OpenKeyReadOnly(REG_PATH_BORLAND_23 +'\'+ LProductVersion +'\Environment Variables') then
        begin
          LValueNames := TStringList.Create();
          try
            LRegistry.GetValueNames(LValueNames);
            for LName in LValueNames do
            begin
              LRegEntry.fEnvironmentVariables.Add(LName, LRegistry.ReadString(LName));
            end;
          finally
            LValueNames.Free();
          end;
          LRegistry.CloseKey;
        end;

      end;
    end;

    // Enumerate Delphi versions 2005-2007
    FillInKeyNames(LRegistry, HKEY_CURRENT_USER,REG_PATH_BDS_KEYS,LProductVersionNumbers);
    for LProductVersion in LProductVersionNumbers do
    begin
      LAppPath := GetKeyValue(LRegistry, HKEY_CURRENT_USER,REG_PATH_BDS_KEYS+'\'+LProductVersion,'App');
      LAddIt := true;
      if fCheckForExistingExe and not FileExists(LAppPath) then
        LAddIt := false;
      if LAddIt then
      begin
        LRegEntry := TDelphiRegistryEntry.Create(LProductVersion);
        LRegEntry.fApp := LAppPath;
        result.Add(LRegEntry);
        if LRegistry.OpenKeyReadOnly(REG_PATH_BDS_KEYS +'\'+ LProductVersion + '\Library') then
        begin
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Search Path'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('SearchPath'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Browsing Path'));
          LRegistry.CloseKey;
        end;

        // TODO: Check if Delphi versions 2005-2007 have environment variables at this registry path
        if LRegistry.OpenKeyReadOnly(REG_PATH_BDS_KEYS +'\'+ LProductVersion +'\Environment Variables') then
        begin
          LValueNames := TStringList.Create();
          try
            LRegistry.GetValueNames(LValueNames);
            for LName in LValueNames do
            begin
              LRegEntry.fEnvironmentVariables.Add(LName, LRegistry.ReadString(LName));
            end;
          finally
            LValueNames.Free();
          end;
          LRegistry.CloseKey;
        end;
      end;
    end;

     // Enumerate Delphi 2009-Rio
    FillInKeyNames(LRegistry, HKEY_CURRENT_USER,REG_PATH_EMBARCADERO_KEYS,LProductVersionNumbers);
    for LProductVersion in LProductVersionNumbers do
    begin
      LAppPath := GetKeyValue(LRegistry, HKEY_CURRENT_USER,REG_PATH_EMBARCADERO_KEYS+'\'+LProductVersion,'App');
      LAddIt := true;
      if fCheckForExistingExe and not FileExists(LAppPath) then
        LAddIt := false;
      if LAddIt then
      begin
        LRegEntry := TDelphiRegistryEntry.Create(LProductVersion);
        LRegEntry.fApp := LAppPath;
        result.Add(LRegEntry);

        if LRegistry.OpenKeyReadOnly(REG_PATH_EMBARCADERO_KEYS +'\'+ LProductVersion + '\Library') then
        begin
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Search Path'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('SearchPath'));

          LRegistry.CloseKey;
        end;

        if LRegistry.OpenKeyReadOnly(REG_PATH_EMBARCADERO_KEYS +'\'+ LProductVersion +'\Library\'+fPlatform) then
        begin
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Search Path'));
          LRegEntry.AppendSearchPath(LRegistry.ReadString('Browsing Path'));
          LRegistry.CloseKey;
        end;

        if LRegistry.OpenKeyReadOnly(REG_PATH_EMBARCADERO_KEYS +'\'+ LProductVersion +'\Environment Variables') then
        begin
          LValueNames := TStringList.Create();
          try
            LRegistry.GetValueNames(LValueNames);
            for LName in LValueNames do
            begin
              LRegEntry.fEnvironmentVariables.Add(LName, LRegistry.ReadString(LName));
            end;
          finally
            LValueNames.Free();
          end;
          LRegistry.CloseKey;
        end;
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

procedure TDelphiRegistryEntry.AppendSearchPath(const aPartToBeAppended : string);
var
  LPathes : TArray<string>;
  i : Integer;
  LKey : string;
begin
  LPathes := aPartToBeAppended.Split([';']);
  for i := Low(LPathes) to High(LPathes) do
  begin
    LKey := Trim(LPathes[i]).ToLower;
    if not fSearchPathes.ContainsKey(LKey) then
      fSearchPathes.Add(LKey, 0);
  end;
end;

constructor TDelphiRegistryEntry.Create(const aProductVersion: string);
begin
  inherited Create();
  fProductVersion := aProductVersion;
  fSearchPathes := TDictionary<String, Byte>.Create();
  fEnvironmentVariables := TDictionary<String, String>.Create();
end;

destructor TDelphiRegistryEntry.Destroy;
begin
  fSearchPathes.Free;
  fEnvironmentVariables.Free;
  inherited;
end;

function TDelphiRegistryEntry.GetEnvVar(const aVarName: String): String;
var
  kv: TPair<String, String>;
begin
  Result := '';
  for kv in fEnvironmentVariables do
  begin
    if SameText(aVarName, kv.Key) then
    begin
      exit(kv.Value);
    end;
  end;
end;

function TDelphiRegistryEntry.GetProductName: string;
begin
  result := ProductVersionToProductName(fProductVersion);
end;

function TDelphiRegistryEntry.getSearchPath: string;
var
  LEnumerator : TDictionary<string,byte>.TKeyEnumerator;
begin
  result := '';
  LEnumerator := fSearchPathes.Keys.GetEnumerator();
  while(LEnumerator.MoveNext) do
  begin
    result := result + LEnumerator.Current + ';';
  end;
  LEnumerator.Free;
  if result.EndsWith(';') then
    Delete(result,Length(result),1);
end;

end.
