unit gpParser.BaseProject;

interface

uses
  System.Classes, System.Generics.Collections, gpParser.Types, System.Types;

type
  TBaseProject = class
  protected
    fFullUnitName : string;
  private
    fAPIIntro: string;
    fConditStart: string;
    fConditStartUses: string;
    fConditStartAPI: string;
    fConditEnd: string;
    fConditEndUses: string;
    fConditEndAPI: string;
    fNameThreadForDebugging: string;
    fCurrentThread : string;
    fTThread : string;
    fAppendUses: string;
    fCreateUses: string;
    fProfileEnterProc: string;
    fProfileExitProc: string;
    fProfileEnterAsm: string;
    fProfileExitAsm: string;
    fProfileAPI: string;
    fProjectName: string;
    fSelectedDelphiVersion : string;
    fIsConsoleProject : Boolean;
    fOutputDir : string;
    fSearchPathes : TStringDynArray;
    fNamespaces : TStringDynArray;

    fMissingUnitNames : TDictionary<String, Cardinal>;
    fExcludedUnitDict : TDictionary<string, Byte>;
  protected
    procedure PrepareComments(const aCommentType: TCommentType);
  public
    constructor Create(const aProjectName,aSelectedDelphiVersion : string);
    destructor Destroy; override;
    function GetFullUnitName(): string;
    procedure StoreExcludedUnits(aExclUnits: String);
    function IsAnExcludedUnit(const aUnitName : string):boolean;
    property prAPIIntro: string read fAPIIntro;
    property prMissingUnitNames : TDictionary<String, Cardinal> read fMissingUnitNames;
    property prConditStart: string read fConditStart;
    property prConditStartUses: string read fConditStartUses;
    property prConditStartAPI: string read fConditStartAPI;
    property prConditEnd: string read fConditEnd;
    property prConditEndUses: string read fConditEndUses;
    property prConditEndAPI: string read fConditEndAPI;
    property prNameThreadForDebugging: string read fNameThreadForDebugging;
    property prCurrentThread: string read fCurrentThread;
    property prtTThread: string read fTThread;
    property prAppendUses: string read fAppendUses;
    property prCreateUses: string read fCreateUses;
    property prProfileEnterProc: string read fProfileEnterProc;
    property prProfileExitProc: string read fProfileExitProc;
    property prProfileEnterAsm: string read fProfileEnterAsm;
    property prProfileExitAsm: string read fProfileExitAsm;
    property prProfileAPI: string read fProfileAPI;
    property Name: string read fProjectName;
    property IsConsoleProject : boolean read fIsConsoleProject;
    property OutputDir : string read fOutputDir;
    property SearchPathes : TStringDynArray read fSearchPathes;
    property Namespaces : TStringDynArray read fNamespaces;


    function LocateOrCreateUnit(const unitName, unitLocation: string;const excluded: boolean): TBaseUnit; virtual; abstract;
  end;

implementation

uses
  System.SysUtils, System.StrUtils, GpString, gpProf.ProjectAccessor, gpProf.bdsVersions;

{ TBaseProject }

constructor TBaseProject.Create(const aProjectName, aSelectedDelphiVersion : string);
var
  LProjectAccessor : TProjectAccessor;
  i : Integer;
begin
  inherited Create();
  fProjectName := aProjectName;
  fSelectedDelphiVersion := aSelectedDelphiVersion;

  fMissingUnitNames := TDictionary<String, Cardinal>.Create;
  fExcludedUnitDict := TDictionary<string, Byte>.Create();
  LProjectAccessor := nil;
  try
    LProjectAccessor := TProjectAccessor.Create(fProjectName);
    fIsConsoleProject := LProjectAccessor.IsConsoleProject(true);
    fOutputDir := LProjectAccessor.GetOutputDir(ProductNameToProductVersion(aSelectedDelphiVersion));
    fSearchPathes := SplitString(LProjectAccessor.GetSearchPath(aSelectedDelphiVersion), ';');
    fNamespaces := SplitString(LProjectAccessor.GetNamespaces(aSelectedDelphiVersion), ';');
    for i := Low(fSearchPathes) to high(fSearchPathes) do
      fSearchPathes[i] := Trim(fSearchPathes[i]);
    for i := Low(fNamespaces) to high(fNamespaces) do
      fNamespaces[i] := Trim(fNamespaces[i]);
  finally
    LProjectAccessor.free;
  end;
end;

destructor TBaseProject.Destroy;
begin
  fMissingUnitNames.free;
  fExcludedUnitDict.Free;
  inherited;
end;

function TBaseProject.GetFullUnitName: string;
begin
  result := fFullUnitName;
end;

function TBaseProject.IsAnExcludedUnit(const aUnitName: string): boolean;
begin
  result := fExcludedUnitDict.ContainsKey(UpperCase(aUnitName));
end;

procedure TBaseProject.PrepareComments(const aCommentType: TCommentType);
begin
  case aCommentType of
    Ct_Arrow:
      begin
        fConditStart := '{>>GpProfile}';
        fConditStartUses := '{>>GpProfile U}';
        fConditStartAPI := '{>>GpProfile API}';
        fConditEnd := '{GpProfile>>}';
        fConditEndUses := '{GpProfile U>>}';
        fConditEndAPI := '{GpProfile API>>}';
      end;
    Ct_IfDef:
      begin
        fConditStart := '{$IFDEF GpProfile}';
        fConditStartUses := '{$IFDEF GpProfile U}';
        fConditStartAPI := '{$IFDEF GpProfile API}';
        fConditEnd := '{$ENDIF GpProfile}';
        fConditEndUses := '{$ENDIF GpProfile U}';
        fConditEndAPI := '{$ENDIF GpProfile API}';
      end;
  end;
  fAppendUses := prConditStartUses + ' ' + cProfUnitName + ', ' +
    prConditEndUses;
  fCreateUses := prConditStartUses + ' uses ' + cProfUnitName + '; ' +
    prConditEndUses;
  fProfileEnterProc := prConditStart + ' ' + 'ProfilerEnterProc(%d); try ' +
    prConditEnd;
  fProfileExitProc := prConditStart + ' finally ProfilerExitProc(%d); end; ' +
    prConditEnd;
  fProfileEnterAsm := prConditStart +
    ' pushad; mov eax, %d; call ProfilerEnterProc; popad ' + prConditEnd;
  fProfileExitAsm := prConditStart +
    ' push eax; mov eax, %d; call ProfilerExitProc; pop eax ' + prConditEnd;
  fProfileAPI := prConditStartAPI + '%s' + prConditEndAPI;
  fAPIIntro := 'GPP:';
  fNameThreadForDebugging := 'namethreadfordebugging';
  fCurrentThread := 'currentthread';
  fTThread := 'tthread';
end;

procedure TBaseProject.StoreExcludedUnits(aExclUnits: String);
var
  LExcludedList : TStringList;
  i : Integer;
begin
  if Last(aExclUnits, 2) <> #13#10 then
    aExclUnits := aExclUnits + #13#10;
  if First(aExclUnits, 2) <> #13#10 then
    aExclUnits := #13#10 + aExclUnits;
  LExcludedList := TStringList.Create();
  LExcludedList.Duplicates := TDuplicates.dupIgnore;
  LExcludedList.CaseSensitive := false;
  LExcludedList.SetText(PWideChar(aExclUnits));
  for i := 0 to LExcludedList.Count -1 do
  begin
    if Length(Trim(LExcludedList[i])) = 0 then
      Continue;
    fExcludedUnitDict.AddOrSetValue(UpperCase(LExcludedList[i]),0);
  end;
  LExcludedList.Free;
end;

{ TProject.PrepareComments }


end.
