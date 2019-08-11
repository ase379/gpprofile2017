unit gpProf.bdsVersions;

interface

uses
  system.Classes;


function RemoveHotkeyAndDelphiPrefix(const aDelphiVer: string): string;
function ProductNameToProductVersion(const aProductName: string): string;
function ProductNameToCompilerVersion(const aProductName: string): string;

/// <summary>
/// Transforms the product version to the product name, e.g. 20.0 to '10.3 Rio'
/// </summary>
function ProductVersionToProductName(const aProductVersionString: string): string;
/// <summary>
/// Gets the major version for the bds version, e.g. 19.0 -> 19
///  This can be used to compare the versions.
/// </summary>
function GetMajorFromProductVersion(const aProductVersionString : string) : Integer;
function GetMinorFromProductVersion(const aProductVersionString : string) : Integer;

implementation

uses
   System.SysUtils;


const SEATTLE = '10.0 Seattle';
      BERLIN = '10.1 Berlin';
      TOKYO = '10.2 Tokyo';
      RIO = '10.3 Rio';

function RemoveHotkeyAndDelphiPrefix(const aDelphiVer: string): string;
begin
  Result := aDelphiVer;
  if aDelphiVer.startswith('Delphi &') then
    result := copy(aDelphiVer, Length('Delphi &')+1, Length(aDelphiVer))
  else
  begin
    if aDelphiVer.startswith('Delphi ') then
      result := copy(aDelphiVer, Length('Delphi ')+1, Length(aDelphiVer))
  end;
end;

function GetMajorFromProductVersion(const aProductVersionString : string) : Integer;
var
  LArray : TArray<string>;
begin
  LArray := aProductVersionString.Split(['.']);
  Result := LArray[0].ToInteger();
end;

function GetMinorFromProductVersion(const aProductVersionString : string) : Integer;
var
  LArray : TArray<string>;
begin
  LArray := aProductVersionString.Split(['.']);
  Result := LArray[1].ToInteger();
end;


function ProductNameToProductVersion(const aProductName: string): string;
begin
  Result := '';
  if aProductName = '2005' then
    Result := '3.0'
  else if aProductName = '2006' then
    Result := '4.0'
  else if aProductName = '2007' then
    Result := '5.0'
  else if aProductName = '2009' then
    Result := '6.0'
  else if aProductName = '2010' then
    Result := '7.0'
  else if aProductName = 'XE' then
    Result := '8.0'
  else if aProductName = 'XE2' then
    Result:= '9.0'
  else if aProductName = 'XE3' then
    Result:= '10.0'
  else if aProductName = 'XE4' then
    Result:= '11.0'
  else if aProductName = 'XE5' then
    Result:= '12.0'
  else if aProductName = 'XE6' then
    Result:= '14.0'
  else if aProductName = 'XE7' then
    Result:= '15.0'
  else if aProductName = 'XE8' then
    Result:= '16.0'
  else if aProductName = SEATTLE then
    Result:= '17.0'
  else if aProductName = BERLIN then
    Result:= '18.0'
  else if aProductName = TOKYO then
    Result:= '19.0'
  else if aProductName = RIO then
    Result:= '20.0';
end;

function ProductNameToCompilerVersion(const aProductName: string): string;
begin
  Result := '';
  if aProductName = '2005' then
    Result := 'VER170'
  else if aProductName = '2006' then
    Result := 'VER180'
  else if aProductName = '2007' then
    Result := 'VER180'
  else if aProductName = '2009' then
    Result := 'VER200'
  else if aProductName = '2010' then
    Result := 'VER210'
  else if aProductName = 'XE' then
    Result := 'VER220'
  else if aProductName = 'XE2' then
    Result:= 'VER230'
  else if aProductName = 'XE3' then
    Result:= 'VER240'
  else if aProductName = 'XE4' then
    Result:= 'VER250'
  else if aProductName = 'XE5' then
    Result:= 'VER260'
  else if aProductName = 'XE6' then
    Result:= 'VER270'
  else if aProductName = 'XE7' then
    Result:= 'VER280'
  else if aProductName = 'XE8' then
    Result:= 'VER290'
  else if aProductName = SEATTLE then
    Result:= 'VER300'
  else if aProductName = BERLIN then
    Result:= 'VER310'
  else if aProductName = TOKYO then
    Result:= 'VER320'
  else if aProductName = RIO then
    Result:= 'VER330';
end;


function ProductVersionToProductName(const aProductVersionString: string): string;
begin
  result := '';
  if aProductVersionString = '20.0' then
    exit(RIO)
  else if aProductVersionString = '19.0' then
    exit(TOKYO)
  else if aProductVersionString = '18.0' then
    exit(BERLIN)
  else if aProductVersionString = '17.0' then
    exit(SEATTLE)
  else if aProductVersionString = '16.0' then
    exit('XE8')
  else if aProductVersionString = '15.0' then
    exit('XE7')
  else if aProductVersionString = '14.0' then
    exit('XE6')
  else if aProductVersionString = '12.0' then
    exit('XE5')
  else if aProductVersionString = '11.0' then
    exit('XE4')
  else if aProductVersionString = '10.0' then
    exit('XE3')
  else if aProductVersionString = '9.0' then
    exit('XE2')
  else if aProductVersionString = '8.0' then
    exit('XE')
  else if aProductVersionString = '7.0' then
    exit('2010')
  else if aProductVersionString = '6.0' then
    exit('2009')
  else
    exit('Embarcadero BDS ' +aProductVersionString);
end;

end.
