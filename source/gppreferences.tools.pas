unit gppreferences.tools;

interface

uses
  System.Generics.Collections;

type



  TGPPrefTools = class
    class procedure SetPref(subkey, name: string; value: variant); overload;
    class function  GetPref(subkey, name: string; defval: variant): variant; overload;
    class procedure DelPref(subkey, name: string);
  end;

  TPrfPlaceholders = (undefined,ProjectFilename, ProcessName, ProcessID);
  TPrfPlaceholderValueDict = TDictionary<TPrfPlaceholders, string>;
  TPrfOutputPlaceholders = class
    class function PrfPlaceholderToMacro(const aPlaceholder : TPrfPlaceholders) : string;
    class function MacroToPrfPlaceholder(const aMacro : string): TPrfPlaceholders;
    class function IsPrfPlaceholderAProjectMacro(const aPlaceholder : TPrfPlaceholders): boolean;
    class function IsPrfPlaceholderARuntimeMacro(const aPlaceholder : TPrfPlaceholders): boolean;

    class function ReplaceProjectMacros(const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict) : string;
    class function ReplaceRuntimeMacros(const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict): string;


  end;

implementation

uses System.SysUtils,System.StrUtils,winapi.windows,
    gpRegistry, gppCommon,GpIFF,GpString;

class function TGPPrefTools.GetPref(subkey, name: string; defval: variant): variant;
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey(cRegistryRoot+IFF(First(subkey,1)='\','','\')+subkey,false) then
        Result := ReadVariant(name, defval)
      else
        Result := defval;
    finally
      Free;
    end;
end; { TfrmMain.GetPref }


class procedure TGPPrefTools.SetPref(subkey, name: string; value: variant);
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey(cRegistryRoot+IFF(First(subkey,1)='\','','\')+subkey,true);
      WriteVariant(name,value);
    finally
      Free;
    end;
end; { TGPPrefTools.SetPref }


class procedure TGPPrefTools.DelPref(subkey, name: string);
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey(cRegistryRoot + IFF(First(subkey, 1)='\', '', '\') + subkey, False) then
        DeleteValue(name);
    finally
      Free;
    end;
end; { TGPPrefTools.DelPref }


{ TPrfOutputPlaceholders }

class function TPrfOutputPlaceholders.PrfPlaceholderToMacro(const aPlaceholder : TPrfPlaceholders): string;
begin
  case aPlaceholder of
    TPrfPlaceholders.ProjectFilename: result := '$(ProjectFilename)';
    TPrfPlaceholders.ProcessName: result := '$(ProcessName)';
    TPrfPlaceholders.ProcessID: result := '$(ProcessID)';
    else
      result := '';
  end;
end;


class function TPrfOutputPlaceholders.IsPrfPlaceholderAProjectMacro(const aPlaceholder : TPrfPlaceholders): boolean;
begin
  case aPlaceholder of
    TPrfPlaceholders.ProjectFilename: result := true;
    else
      result := false;
  end;
end;

class function TPrfOutputPlaceholders.IsPrfPlaceholderARuntimeMacro(const aPlaceholder : TPrfPlaceholders): boolean;
begin
  case aPlaceholder of
    TPrfPlaceholders.ProcessName,
    TPrfPlaceholders.ProcessID: result := true;
    else
      result := false;
  end;
end;


class function TPrfOutputPlaceholders.MacroToPrfPlaceholder(const aMacro : string): TPrfPlaceholders;
var lPrf : TPrfPlaceholders;
begin
  result := TPrfPlaceholders.undefined;
  for lPrf := low(TPrfPlaceholders) to high(TPrfPlaceholders) do
    if Sametext(PrfPlaceholderToMacro(lPrf),aMacro) then
      exit(lPrf);
end;

class function TPrfOutputPlaceholders.ReplaceProjectMacros(
  const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict): string;
var
  lPrf : TPrfPlaceholders;
  lPrfMacro : string;
  lSubstitute : string;
  lPosition : integer;
begin
  result := aFilenameWithMacros;
  for lPrf := low(TPrfPlaceholders) to high(TPrfPlaceholders) do
  begin
    if not IsPrfPlaceholderAProjectMacro(lPrf) then
      continue;
    if not aSubstitutes.ContainsKey(lPrf) then
      continue;

    lPrfMacro := PrfPlaceholderToMacro(lPRF);
    lPosition := PosEx(lPrfMacro, result);
    while lPosition > 0 do
    begin
      lSubstitute := aSubstitutes[lPrf];
      result := ReplaceText(result,lPrfMacro,lSubstitute);
      lPosition := PosEx(lPrfMacro, result);
    end;
  end;
end;

class function TPrfOutputPlaceholders.ReplaceRuntimeMacros(
  const aFilenameWithMacros: string; const aSubstitutes :TPrfPlaceholderValueDict): string;
var
  lPrf : TPrfPlaceholders;
  lPrfMacro : string;
  lSubstitute : string;
  lPosition : integer;
begin
  result := aFilenameWithMacros;
  for lPrf := low(TPrfPlaceholders) to high(TPrfPlaceholders) do
  begin
    if not IsPrfPlaceholderARuntimeMacro(lPrf) then
      continue;
    if not aSubstitutes.ContainsKey(lPrf) then
      continue;

    lPrfMacro := PrfPlaceholderToMacro(lPRF);
    lPosition := PosEx(lPrfMacro, result);
    while lPosition > 0 do
    begin
      lSubstitute := aSubstitutes[lPrf];
      result := ReplaceText(result,lPrfMacro,lSubstitute);
      lPosition := PosEx(lPrfMacro, result);
    end;
  end;
end;

end.
