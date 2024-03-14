unit gpPrfPlaceholders;

interface

uses
  System.Generics.Collections;

type



  // the different placeholder types currently supported
  TPrfPlaceholderType = (undefined,ProjectFilename,ModuleName,ModulePath,ProcessName, ProcessID);
  // a set of placeholders
  TPrfPlaceholderTypeSet =set of TPrfPlaceholderType;
  // a table for the key value pair storing a placeholder and its substitute
  TPrfPlaceholderValueDict = TDictionary<TPrfPlaceholderType, string>;
  // a class for providing the placeholder functionalities
  TPrfPlaceholder = class
    class function PrfPlaceholderToMacro(const aPlaceholder : TPrfPlaceholderType) : string;
    class function MacroToPrfPlaceholder(const aMacro : string): TPrfPlaceholderType;
    class function IsPrfPlaceholderAProjectMacro(const aPlaceholder : TPrfPlaceholderType): boolean;
    class function IsPrfPlaceholderARuntimeMacro(const aPlaceholder : TPrfPlaceholderType): boolean;

    class function GetPrfPlaceholderProjectMacros(): TPrfPlaceholderTypeSet;
    class function GetPrfPlaceholderRuntimeMacros(): TPrfPlaceholderTypeSet;


    class function ReplaceProjectMacros(const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict) : string;
    class function ReplaceRuntimeMacros(const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict): string;
  end;

implementation

uses System.SysUtils,System.StrUtils,
    gpRegistry, gppCommon,GpIFF,GpString;

{ TPrfPlaceholderType }

class function TPrfPlaceholder.PrfPlaceholderToMacro(const aPlaceholder : TPrfPlaceholderType): string;
begin
  case aPlaceholder of
    TPrfPlaceholderType.ProjectFilename: result := '$(ProjectOutputName)';
    TPrfPlaceholderType.ProcessName: result := '$(ProcessName)';
    TPrfPlaceholderType.ProcessID: result := '$(ProcessID)';
    TPrfPlaceholderType.ModuleName : result := '$(ModuleName)';
    TPrfPlaceholderType.ModulePath : result := '$(ModulePath)';
    else
      result := '';
  end;
end;


class function TPrfPlaceholder.IsPrfPlaceholderAProjectMacro(const aPlaceholder : TPrfPlaceholderType): boolean;
begin
  case aPlaceholder of
    TPrfPlaceholderType.ProjectFilename: result := true;
    else
      result := false;
  end;
end;

class function TPrfPlaceholder.IsPrfPlaceholderARuntimeMacro(const aPlaceholder : TPrfPlaceholderType): boolean;
begin
  case aPlaceholder of
    TPrfPlaceholderType.ProcessName,
    TPrfPlaceholderType.ProcessID,
    TPrfPlaceholderType.ModuleName,
    TPrfPlaceholderType.ModulePath : result := true;
    else
      result := false;
  end;
end;


class function TPrfPlaceholder.GetPrfPlaceholderProjectMacros(): TPrfPlaceholderTypeSet;
var lPrf : TPrfPlaceholderType;
begin
  result := [];
  for lPrf := low(TPrfPlaceholderType) to high(TPrfPlaceholderType) do
  begin
    if IsPrfPlaceholderAProjectMacro(lPrf) then
      include(result, lprf);
  end;
end;



class function TPrfPlaceholder.GetPrfPlaceholderRuntimeMacros(): TPrfPlaceholderTypeSet;
var lPrf : TPrfPlaceholderType;
begin
  result := [];
  for lPrf := low(TPrfPlaceholderType) to high(TPrfPlaceholderType) do
  begin
    if IsPrfPlaceholderARuntimeMacro(lPrf) then
      include(result, lprf);
   end;
end;




class function TPrfPlaceholder.MacroToPrfPlaceholder(const aMacro : string): TPrfPlaceholderType;
var lPrf : TPrfPlaceholderType;
begin
  result := TPrfPlaceholderType.undefined;
  for lPrf := low(TPrfPlaceholderType) to high(TPrfPlaceholderType) do
    if Sametext(PrfPlaceholderToMacro(lPrf),aMacro) then
      exit(lPrf);
end;

class function TPrfPlaceholder.ReplaceProjectMacros(
  const aFilenameWithMacros: string;const aSubstitutes :TPrfPlaceholderValueDict): string;
var
  lPrf : TPrfPlaceholderType;
  lPrfMacro : string;
  lSubstitute : string;
  lPosition : integer;
begin
  result := aFilenameWithMacros;
  for lPrf := low(TPrfPlaceholderType) to high(TPrfPlaceholderType) do
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

class function TPrfPlaceholder.ReplaceRuntimeMacros(
  const aFilenameWithMacros: string; const aSubstitutes :TPrfPlaceholderValueDict): string;
var
  lPrf : TPrfPlaceholderType;
  lPrfMacro : string;
  lSubstitute : string;
  lPosition : integer;
begin
  result := aFilenameWithMacros;
  for lPrf := low(TPrfPlaceholderType) to high(TPrfPlaceholderType) do
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
