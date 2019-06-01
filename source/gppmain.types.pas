unit gppmain.types;

interface

const
  ANYFILE_FILTER = '*.*';
  ANYFILE_CAPTION = 'Any file';
  GPPROF_INSTRUMENTATION_SELECTION_EXT = '.gis';
  GPPROF_INSTRUMENTATION_SELECTION_FILTER = '*.gis';
  GPPROF_INSTRUMENTATION_SELECTION_CAPTION = 'GPProf instrumentation selection';


type
  TUIStrings = class
  public
    /// <summary>
    /// Returns the filter for the instrumentation selection (*.gis)
    /// </summary>
    class function InstrumentationSelectionFilter(): string;

    class function LoadInstrumentationSelectionCaption(): string;
    class function SaveInstrumentationSelectionCaption(): string;
  end;

implementation


class function TUIStrings.InstrumentationSelectionFilter(): string;

  function GetFilterString(const aCaption, aFilterExt : string): string;
  begin
    result := aCaption + ' (' + aFilterExt + ')|' + aFilterExt;
  end;

begin
  result := GetFilterString(GPPROF_INSTRUMENTATION_SELECTION_CAPTION, GPPROF_INSTRUMENTATION_SELECTION_FILTER);
  result := result + '|';
  result := result + GetFilterString(ANYFILE_CAPTION, ANYFILE_FILTER);
end;

class function TUIStrings.LoadInstrumentationSelectionCaption: string;
begin
  result := 'Load instrumentation selection...';
end;

class function TUIStrings.SaveInstrumentationSelectionCaption: string;
begin
  result := 'Save instrumentation selection...';
end;

end.
