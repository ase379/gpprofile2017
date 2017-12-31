unit bdsVersions;

interface


function DelphiVerToBDSVer(const aDelphiVer: string): string;
function BdsVerToDephiVer(const aBdsVersionString: string): string;

implementation


const SEATTLE = '10.0 Seattle';
      BERLIN = '10.1 Berlin';
      TOKYO = '11.0 Tokyo';


function DelphiVerToBDSVer(const aDelphiVer: string): string;
begin
  Result := '';
  if aDelphiVer = '2005' then
    Result := '3.0'
  else if aDelphiVer = '2006' then
    Result := '4.0'
  else if aDelphiVer = '2007' then
    Result := '5.0'
  else if aDelphiVer = '2009' then
    Result := '6.0'
  else if aDelphiVer = '2010' then
    Result := '7.0'
  else if aDelphiVer = 'XE' then
    Result := '8.0'
  else if aDelphiVer = 'XE2' then
    Result:= '9.0'
  else if aDelphiVer = 'XE3' then
    Result:= '10.0'
  else if aDelphiVer = 'XE4' then
    Result:= '11.0'
  else if aDelphiVer = 'XE5' then
    Result:= '12.0'
  else if aDelphiVer = 'XE6' then
    Result:= '14.0'
  else if aDelphiVer = 'XE7' then
    Result:= '15.0'
  else if aDelphiVer = 'XE8' then
    Result:= '16.0'
  else if aDelphiVer = SEATTLE then
    Result:= '17.0'
  else if aDelphiVer = BERLIN then
    Result:= '18.0'
  else if aDelphiVer = TOKYO then
    Result:= '19.0';
end;

function BdsVerToDephiVer(const aBdsVersionString: string): string;
begin
  result := '';
  if aBdsVersionString = '19.0' then
    exit(TOKYO)
  else if aBdsVersionString = '18.0' then
    exit(BERLIN)
  else if aBdsVersionString = '17.0' then
    exit(SEATTLE)
  else if aBdsVersionString = '16.0' then
    exit('XE8')
  else if aBdsVersionString = '15.0' then
    exit('XE7')
  else if aBdsVersionString = '14.0' then
    exit('XE6')
  else if aBdsVersionString = '12.0' then
    exit('XE5')
  else if aBdsVersionString = '11.0' then
    exit('XE4')
  else if aBdsVersionString = '10.0' then
    exit('XE3')
  else if aBdsVersionString = '9.0' then
    exit('XE2')
  else if aBdsVersionString = '8.0' then
    exit('XE')
  else if aBdsVersionString = '7.0' then
    exit('2010')
  else if aBdsVersionString = '6.0' then
    exit('2009')
  else
    exit('Embarcadero BDS ' +aBdsVersionString);
end;


end.
