unit gpProf.bdsVersions;

interface

uses
  system.Classes;

type
  TDelphiProduct =
  (
    unknown,
    Delphi1,
    Delphi2,
    Delphi3,
    Delphi4,
    Delphi5,
    Delphi6,
    Delphi7,
    Delphi8,
    Delphi2005,
    Delphi2006,
    Delphi2007,
    Delphi2009,
    Delphi2010,
    DelphiXE,
    DelphiXE2,
    DelphiXE3,
    DelphiXE4,
    DelphiXE5,
    DelphiXE6,
    DelphiXE7,
    DelphiXE8,
    DelphiSeattle,
    DelphiBelin,
    DelphiTokyo,
    DelphiRio,
    DelphiSydney,
    DelphiAlexandria
  );



function RemoveHotkeyAndDelphiPrefix(const aDelphiVer: string): string;
function ProductNameToProduct(const aProductName: string): TDelphiProduct;

function DelphiProductToProductName(const aProductName: TDelphiProduct): string;
function DelphiProductToCompilerVersion(const aProductName: TDelphiProduct): string;

/// <summary>
/// Transforms the product version to the product name, e.g. 20.0 to '10.3 Rio'
/// </summary>
function ProductVersionToProductName(const aProductVersionString: string): string;
function ProductNameToProductVersion(const aProductNameString: string): string;
/// <summary>
/// Gets the major version for the bds version, e.g. 19.0 -> 19
///  This can be used to compare the versions.
/// </summary>
function GetMajorFromProductVersion(const aProductVersionString : string) : Integer;
function GetMinorFromProductVersion(const aProductVersionString : string) : Integer;

implementation

uses
   System.Generics.Collections,
   System.SysUtils;

const SEATTLE = '10.0 Seattle';
      BERLIN = '10.1 Berlin';
      TOKYO = '10.2 Tokyo';
      RIO = '10.3 Rio';
      SYDNEY = '10.4 Sydney';
      ALEXANDRIA = '11.x Alexandria';

var
  ProductVersionMapping: TDictionary<String, String>;

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



// see https://theroadtodelphi.com/2010/10/27/detecting-installed-delphi-versions/
function ProductNameToProduct(const aProductName: string): TDelphiProduct;
var
  LProduct : TDelphiProduct;
begin
  result := TDelphiProduct.unknown;
  for LProduct := Low(TDelphiProduct) to High(TDelphiProduct) do
    if DelphiProductToProductName(LProduct) = aProductName then
      Exit(lProduct);
end;


function DelphiProductToProductName(const aProductName: TDelphiProduct): string;
begin
  /// remark: 'Delphi' is added on the fly with & or without &
  Result := '';
  case aProductName of
    unknown: result := 'unknown product version';
    Delphi1: result := '1';
    Delphi2: result := '2';
    Delphi3: result := '3';
    Delphi4: result := '4';
    Delphi5: result := '5';
    Delphi6: result := '6';
    Delphi7: result := '7';
    Delphi8: result := '8';
    Delphi2005: result := '2005';
    Delphi2006: result := '2006';
    Delphi2007: result := '2007';
    Delphi2009: result := '2009';
    Delphi2010: result := '2010';
    DelphiXE: result := 'XE';
    DelphiXE2: result := 'XE2';
    DelphiXE3: result := 'XE3';
    DelphiXE4: result := 'XE4';
    DelphiXE5: result := 'XE5';
    DelphiXE6: result := 'XE6';
    DelphiXE7: result := 'XE7';
    DelphiXE8: result := 'XE8';
    DelphiSeattle: result := '10 Seattle';
    DelphiBelin: result := BERLIN;
    DelphiTokyo: result := TOKYO;
    DelphiRio: result := RIO;
    DelphiSydney : result := SYDNEY;
    DelphiAlexandria : result := ALEXANDRIA;
  end;
end;

function DelphiProductToCompilerVersion(const aProductName: TDelphiProduct): string;
begin
  Result := '';
  case aProductName of
    unknown: result := 'unknown product compiler';
    Delphi1: result := 'VER80';
    Delphi2: result := 'VER90';
    Delphi3: result := 'VER100';
    Delphi4: result := 'VER120';
    Delphi5: result := 'VER130';
    Delphi6: result := 'VER140';
    Delphi7: result := 'VER150';
    Delphi8: result := 'VER160';
    Delphi2005: result := 'VER170';
    Delphi2006: result := 'VER180';
    Delphi2007: result := 'VER190';
    Delphi2009: result := 'VER200';
    Delphi2010: result := 'VER210';
    DelphiXE: result := 'VER220';
    DelphiXE2: result := 'VER230';
    DelphiXE3: result := 'VER240';
    DelphiXE4: result := 'VER250';
    DelphiXE5: result := 'VER260';
    DelphiXE6: result := 'VER270';
    DelphiXE7: result := 'VER280';
    DelphiXE8: result := 'VER290';
    DelphiSeattle: result := 'VER300';
    DelphiBelin: result := 'VER310';
    DelphiTokyo: result := 'VER320';
    DelphiRio: result := 'VER330';
    DelphiSydney: result := 'VER340';
    DelphiAlexandria: result := 'VER350';
  end;
end;


function ProductVersionToProductName(const aProductVersionString: string): string;
begin
  result := '';
  if not ProductVersionMapping.TryGetValue(aProductVersionString, Result) then
  begin
    exit('Embarcadero BDS ' +aProductVersionString);
  end;
end;

function ProductNameToProductVersion(const aProductNameString: string): string;
var
  kv: TPair<String, String>;
begin
  for kv in ProductVersionMapping do
  begin
    if SameText(kv.Value, aProductNameString) then
    begin
      Exit(kv.Key);
    end;
  end;

  Exit(aProductNameString.Replace('Embarcadero BDS', '', [rfReplaceAll, rfIgnoreCase]).Trim());
end;

Initialization

ProductVersionMapping := TDictionary<String, String>.Create();
ProductVersionMapping.add('22.0', ALEXANDRIA);
ProductVersionMapping.add('21.0', SYDNEY);
ProductVersionMapping.add('20.0', RIO);
ProductVersionMapping.add('19.0', TOKYO);
ProductVersionMapping.add('18.0', BERLIN);
ProductVersionMapping.add('17.0', SEATTLE);
ProductVersionMapping.add('16.0', 'XE8');
ProductVersionMapping.add('15.0', 'XE7');
ProductVersionMapping.add('14.0', 'XE6');
ProductVersionMapping.add('12.0', 'XE5');
ProductVersionMapping.add('11.0', 'XE4');
ProductVersionMapping.add('10.0', 'XE3');
ProductVersionMapping.add('9.0', 'XE2');
ProductVersionMapping.add('8.0', 'XE');
ProductVersionMapping.add('7.0', '2010');
ProductVersionMapping.add('6.0', '2009');

end.
