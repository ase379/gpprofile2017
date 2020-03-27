unit gpProf.ProjectAccessor;

interface

uses
  system.Classes, System.generics.collections, gpProf.DofReader, gpProf.DProjReader, gpProf.BdsProjReader;

type
  TProjectType = (dofReader, bdsReader, dprojReader);
  TProjectAccessor = class
  private
    fFilename : string;
    fDProjReader : TDProjReader;
    fBdsProjReader : TBdsProjReader;
    fDofReader : TDofReader;

    function InnerReplaceMacros(const aMacro : string; const aProductVersion: string) : string;
    function ReplaceMacros(const aMacro : string; const aProductVersion: string) : string;
  public
    constructor Create(const aFilename : string);
    function IsConsoleProject(const aDefaultIfNotFound : boolean): boolean;
    function GetOutputDir(const aProductVersion: string): string;
    function GetProjectDefines(const aProductVersion: string): string;
    function GetSearchPath(const aDelphiCompilerVersion: string): string;
    function GetNamespaces(const aDelphiCompilerVersion: string): string;
  end;


implementation

uses
  System.Sysutils, System.Win.Registry, Winapi.Windows, gppmain.types, GpString, gppcommon, GpRegistry, gpProf.bdsVersions,
  gpProf.Delphi.RegistryAccessor;

{ TProjectAccessor }

constructor TProjectAccessor.Create(const aFilename: string);
var
  LFn : string;
  LFileFound : Boolean;
begin
  inherited Create();
  fFilename := aFilename;

  // try .dproj first... its the current version format
  LFn := ChangeFileExt(fFilename,TUIStrings.DelphiProjectExt);
  LFileFound := FileExists(LFn);
  if LFileFound then
    fDProjReader := TDProjReader.Create(LFn);
  if not LFileFound then
  begin
    // check .bdsproj format (2006 and earlier)
    LFn := ChangeFileExt(fFilename,TUIStrings.Delphi7OptionsExt);
    LFileFound := FileExists(LFn);
    if LFileFound then
      fBdsProjReader := TBdsProjReader.Create(LFn);
  end;
  if not LFileFound then
  begin
    // check .dof format ( delphi 7 and earlier)
    LFn := ChangeFileExt(fFilename,TUIStrings.Delphi7OptionsExt);
    LFileFound := FileExists(LFn);
    if LFileFound then
      fDofReader := TDofReader.Create(LFn);
  end;
end;

function TProjectAccessor.IsConsoleProject(const aDefaultIfNotFound : boolean): boolean;
begin
  result := aDefaultIfNotFound;
  if assigned(fDProjReader) then
    Result := fDProjReader.IsConsoleApp(aDefaultIfNotFound)
  else if assigned(fBdsProjReader) then
    Result := fBdsProjReader.IsConsoleApp(aDefaultIfNotFound)
  else if assigned(fDofReader) then
    Result := fDofReader.IsConsoleApp(aDefaultIfNotFound);
end;

function TProjectAccessor.ReplaceMacros(const aMacro: string; const aProductVersion: string): string;
var
  tmp: string;
begin
  Result := aMacro;
  tmp := '';
  while Result <> tmp do
  begin
    tmp := Result;
    Result := InnerReplaceMacros(Result, aProductVersion);
  end;
end;

function TProjectAccessor.InnerReplaceMacros(const aMacro: string; const aProductVersion: string): string;

  function GetDelphiXE2Var(const aVarName: string): string;
  begin
    if lowercase(aVarName) = 'platform' then Result:= 'Win32';
    if lowercase(aVarName) = 'config' then Result:= 'Release';
  end;

  function GetEnvVar(const aVarName: String): String;
  var
    LRegistryAccessor : TRegistryAccessor;
    LEntry : TDelphiRegistryEntry;
  begin
    Result := GetEnvironmentVariable(aVarName);

    if Result.Trim() = '' then
    begin
      LRegistryAccessor := TRegistryAccessor.Create('');
      try
        LEntry := LRegistryAccessor.GetByProductVersion(aProductVersion);
        Result := LEntry.GetEnvVar(aVarName);
      finally
        LRegistryAccessor.Free();
      end;
    end;
  end;

var
  vMacroValue: String;
  vMacros: array of String;
  vInMacro: Boolean;
  vMacroSt: Integer;
  i, p: Integer;
begin
  Result := aMacro;

  // First, build full macros list from Search Path (macro is found by $(MacroName))
  vMacros := nil;
  vMacroSt := -1;
  vInMacro := False;
  for i := 1 to Length(Result) do
    if Copy((Result+' '), i, 2) = '$(' then
    begin
      vInMacro := True;
      vMacroSt := i;
    end
    else if vInMacro and (Result[i] = ')') then
    begin
      vInMacro := False;

      // Get macro name (without round brackets: $( ) )
      p := Length(vMacros);
      SetLength(vMacros, p+1);
      vMacros[p] := Copy(Result, vMacroSt+2, i-1-(vMacroSt+2)+1);
    end;

  for i := 0 to High(vMacros) do
  begin
    // NB! Paths from DCC_UnitSearchPath element of *.dproj file are already added,
    // so simply skip this macro
    if AnsiUpperCase(vMacros[i]) = 'DCC_UNITSEARCHPATH' then
      Continue;
   
    vMacroValue := GetEnvVar(vMacros[i]);
    if (vMacroValue = '') then vMacroValue:= GetDelphiXE2Var(vMacros[i]);
    // ToDo: Not all macros are possible to get throug environment variables
    // Neet to find out, how to resolve the rest macros
    if vMacroValue <> '' then
      Result := StringReplace(Result, '$(' + vMacros[i] + ')', vMacroValue, [rfReplaceAll]);
  end;
end;


function TProjectAccessor.GetProjectDefines(const aProductVersion: string): string;
begin
  Result := '';

  if assigned(fDProjReader) then
  begin
    Result := fDProjReader.GetProjectDefines();
    Result := ReplaceMacros(Result, aProductVersion);
  end
  else if assigned(fBdsProjReader) then
    Result := fBdsProjReader.GetProjectDefines
  else if assigned(fDofReader) then
    Result := fDofReader.GetProjectDefines;
end;

function TProjectAccessor.GetNamespaces(const aDelphiCompilerVersion: string): string;
begin
  Result := '';

  if assigned(fDProjReader) then
  begin
    Result := fDProjReader.GetProjectNamespaces();
  end;
end;

function TProjectAccessor.GetSearchPath(const aDelphiCompilerVersion: string): string;

  function AppendPath(const aPath, aPartToBeAppended : string): string;
  begin
    result := aPath;
    if (Length(Result) > 0) then
      if not Result.EndsWith(';') then
        result := result + ';';
    result := result + aPartToBeAppended;
  end;

var
  LPath : string;
  LOldCurrentDir : string;
  LFullPath : string;
  LPlatform : string;
  i : Integer;
  LRegistryAccessor : TRegistryAccessor;
  LEntry : TDelphiRegistryEntry;
begin
  Result := '';
  LPath := '';
  LPlatform := '';

  if assigned(fDProjReader) then
  begin
    LPath := fDProjReader.GetSearchPath;
    LPlatform := fDProjReader.GetPlatformOfCurrentConfig();
  end
  else if assigned(fBdsProjReader) then
    LPath := fBdsProjReader.GetSearchPath
  else if assigned(fDofReader) then
    LPath := fDofReader.GetSearchPath;

  LRegistryAccessor := TRegistryAccessor.Create(LPlatform);
  try
    LEntry := LRegistryAccessor.GetByProductName(aDelphiCompilerVersion);
    if assigned(LEntry) then
      LPath := AppendPath(LPath, LEntry.SearchPath);
  finally
    LRegistryAccessor.Free;
  end;

  // Substitute macros (environment variables) with their real values
  LPath := ReplaceMacros(LPath, ProductNameToProductVersion(aDelphiCompilerVersion));

  // Transform all search paths into absolute
  Result := '';
  LOldCurrentDir := GetCurrentDir;
  if not SetCurrentDir(ExtractFileDir(fFilename)) then
    Assert(False);
  try
    for i := 1 to NumElements(LPath, ';', -1) do
    begin
      LFullPath := ExpandUNCFileName(NthEl(LPath, i, ';', -1));
      if DirectoryExists(LFullPath) then
        Result := AppendPath(Result, LFullPath);
    end;
  finally
    SetCurrentDir(LOldCurrentDir);
  end;
end;

function TProjectAccessor.GetOutputDir(const aProductVersion: string): string;
var
  vOldCurDir: String;
begin
  Result := '';

  if assigned(fDProjReader) then
    Result := fDProjReader.OutputDir
  else if assigned(fBdsProjReader) then
    Result := fBdsProjReader.OutputDir
  else if assigned(fDofReader) then
    Result := fDofReader.OutputDir;

  Result := ReplaceMacros(Result, aProductVersion);

  // If getting output dir was not successful - use project dir as output dir
  if Result = '' then
    Result := ExtractFilePath(FFilename);

  // Transform path to absolute
  if not IsAbsolutePath(Result) then
  begin
    vOldCurDir := GetCurrentDir;
    try
      if not SetCurrentDir(ExtractFileDir(fFilename)) then
        Assert(False);
      Result := ExpandUNCFileName(Result);
    finally
      SetCurrentDir(vOldCurDir)
    end;
  end;
end; { TfrmMain.GetOutputDir }

end.
