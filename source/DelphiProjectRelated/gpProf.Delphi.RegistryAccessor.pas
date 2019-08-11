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
    function GetProductMajor: Integer;
    function GetProductMinor: Integer;
  public
    constructor Create(const aProductVersion : string);
    property ProductMajor : Integer read GetProductMajor;
    property ProductMinor : Integer read GetProductMinor;
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
  LRegistry : TRegistry;
  LProductVersionNumbers: TStringList;
  i: Integer;
  LAppPath : string;
  LRegEntry : TDelphiRegistryEntry;
  LAddIt : Boolean;
begin
  if assigned(fDelphiRegList) then
    Exit(fDelphiRegList);
  { returns the user settings that exist in the registry }
  result := TDelphiRegistryEntryList.Create(true);
  LProductVersionNumbers := TStringList.Create;
  LRegistry := TRegistry.Create();
  try
    // Enumerate Delphi 2009-Rio
    FillInKeyNames(LRegistry,HKEY_CURRENT_USER,'\SOFTWARE\Embarcadero\BDS',LProductVersionNumbers);
    for i := LProductVersionNumbers.Count-1 downto 0 do
    begin
      if LRegistry.OpenKeyReadOnly('\SOFTWARE\Embarcadero\BDS\'+LProductVersionNumbers[i]) then
      begin
        try
          LAppPath := LRegistry.ReadString('App');
          LAddIt := true;
          if fCheckForExistingExe and not FileExists(LAppPath) then
            LAddIt := false;
          if LAddIt then
          begin
            LRegEntry := TDelphiRegistryEntry.Create(LProductVersionNumbers[i]);
            LRegEntry.fApp := LAppPath;
            result.Add(LRegEntry);
          end;
        finally
          LRegistry.CloseKey;
        end;
      end;
    end;

    // Enumerate Delphi 2005-2007
    FillInKeyNames(LRegistry,HKEY_CURRENT_USER,'\SOFTWARE\Borland\BDS',LProductVersionNumbers);
    for i := 0 to LProductVersionNumbers.Count-1 do
    begin
      LRegEntry := TDelphiRegistryEntry.Create(LProductVersionNumbers[i]);
      result.Add(LRegEntry);
      if LRegistry.OpenKeyReadOnly('\SOFTWARE\Borland\BDS\'+LProductVersionNumbers[i]) then
      begin
        try
          LRegEntry.fApp := LRegistry.ReadString('App')
        finally
          LRegistry.CloseKey;
        end;
      end;
    end;

    // Enumerate Delphi versions 2-5
    FillInKeyNames(LRegistry,HKEY_LOCAL_MACHINE,'\SOFTWARE\Borland\Delphi',LProductVersionNumbers);
    for i := 0 to LProductVersionNumbers.Count-1 do
    begin
      LRegEntry := TDelphiRegistryEntry.Create(LProductVersionNumbers[i]);
      result.Add(LRegEntry);
      if LRegistry.OpenKeyReadOnly('\SOFTWARE\Borland\Delphi\'+LProductVersionNumbers[i]) then
      begin
        try
          LRegEntry.fApp := LRegistry.ReadString('Delphi ' + Result.Last.GetProductMajor().ToString());
        finally
          LRegistry.CloseKey;
        end;
      end;
    end;
  finally
    LRegistry.Free;
    LProductVersionNumbers.Free;
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

function TDelphiRegistryEntry.GetProductMajor: Integer;
var
  LArray : TArray<string>;
begin
  LArray := fProductVersion.Split(['.']);
  Result := LArray[0].ToInteger();
end;

function TDelphiRegistryEntry.GetProductMinor: Integer;
var
  LArray : TArray<string>;
begin
  LArray := fProductVersion.Split(['.']);
  Result := LArray[1].ToInteger();
end;

function TDelphiRegistryEntry.GetProductName: string;
begin
  result := ProductVersionToProductName(fProductVersion);
end;

end.
