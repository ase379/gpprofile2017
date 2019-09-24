unit gppmain.types;

interface

type
  /// <summary>
  /// A class for handling the ui related strings.
  /// </summary>
  TUIStrings = class
  public

  const
    AnyFileFilter = '*.*';
    AnyFileCaption = 'Any file';
    GPProfInstrumentationSelectionExt = '.gis';
    GPProfInstrumentationSelectionFilter = '*.gis';
    GPProfInstrumentationSelectionCaption = 'GPProf instrumentation selection';

    DelphiProjectExt = '.dproj';
    DelphiProjectFilter = '*.dproj';
    DelphiProjectCaption = 'Delphi project file';

    DelphiBdsProjExt = '.bdsproj';

    Delphi7OptionsExt = '.dof';
    Delphi7OptionsFilter = '*.dof';
    Delphi7OptionsCaption = 'Delphi 7 options file';



    DelphiProjectSourceExt = '.dpr';
    DelphiProjectSourceFilter = '*.dpr';
    DelphiProjectSourceDefaultExt = 'dpr';
    DelphiProjectSourceCaption = 'Delphi project';
    DelphiPackageSourceExt = '.dpk';
    DelphiPackageSourceFilter = '*.dpk';
    DelphiPackageSourceCaption = 'Delphi package source file';



    /// <summary>
    /// Returns the filter for the instrumentation selection (*.gis)
    /// </summary>
    class function InstrumentationSelectionFilter(): string;

    /// <summary>
    /// Returns the caption for loading the instrumentation selection (*.gis)
    /// </summary>
    class function LoadInstrumentationSelectionCaption(): string;

    /// <summary>
    /// Returns the caption for saving instrumentation selection (*.gis)
    /// </summary>
    class function SaveInstrumentationSelectionCaption(): string;

    /// <summary>
    /// Returns the filter for the delphi project selection (*.dpr) or (*.dpk)
    /// </summary>
    class function ProjectSelectionFilter(): string;

    /// <summary>
    /// Returns the caption for loading the project (*.dpr) or (*.dpk)
    /// </summary>
    class function LoadProjectCaption(): string;

    class function ErrorLoading(const aFilename : string): string;

    class function ErrorLoadingMRUDeleteIt(const aFilename : string): string;
  end;

implementation

uses
  System.SysUtils;


{ Global }

function GetFilterString(const aCaption, aFilterExt : string): string;
begin
  result := aCaption + ' (' + aFilterExt + ')|' + aFilterExt;
end;

function AppendFilterString(const aStringA, aStringB: string): string;
var
  LValidA, LValidB : Boolean;
begin
  LValidA := Trim(aStringA) <> '';
  LValidB := Trim(aStringB) <> '';
  result := '';
  if LValidA and LValidB then
    result := aStringA + '|' + aStringB
  else
  begin
    if LValidA then
      result := aStringA
    else if LValidB then
      result := aStringB
  end;

end;

{ TUIStrings }
class function TUIStrings.ErrorLoading(const aFilename : string): string;
begin
  result := 'Error while loading file "'+aFilename+'".';
end;

class function TUIStrings.ErrorLoadingMRUDeleteIt(const aFilename : string): string;
begin
  result := 'Error while loading file "'+aFilename+'"'+slinebreak+'Delete it from the MRU list ?';
end;

class function TUIStrings.InstrumentationSelectionFilter(): string;
begin
  result := '';
  result := AppendFilterString(result,GetFilterString(GPProfInstrumentationSelectionCaption, GPProfInstrumentationSelectionFilter));
  result := AppendFilterString(Result,GetFilterString(AnyFileCaption, AnyFileFilter));
end;

class function TUIStrings.LoadInstrumentationSelectionCaption: string;
begin
  result := 'Load instrumentation selection...';
end;

class function TUIStrings.SaveInstrumentationSelectionCaption: string;
begin
  result := 'Save instrumentation selection...';
end;

class function TUIStrings.ProjectSelectionFilter(): string;
begin
  Result := '';
  result := AppendFilterString(result,GetFilterString(DelphiProjectCaption, DelphiProjectFilter));
  result := AppendFilterString(result,GetFilterString(DelphiProjectSourceCaption, DelphiProjectSourceFilter));
  result := AppendFilterString(result,GetFilterString(DelphiPackageSourceCaption, DelphiPackageSourceFilter));
  result := AppendFilterString(result,GetFilterString(AnyFileCaption, AnyFileFilter));
end;


class function TUIStrings.LoadProjectCaption: string;
begin
  Result := 'Load delphi project/package...'
end;


end.
