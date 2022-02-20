unit gpProf.DProjReader;

interface

uses
  SysUtils, Forms, Variants, XMLDoc, XMLIntf, Dialogs, System.Generics.Collections;

type
  DProjConfig = class
  public
    Condition : string;
    ConfigType : string; // Base, relase, debug...
    ConfigName : string; // internal name (cfg_1)..
    ConfigParentName : string; // internal parent config name
    PlatformName : string;
    IsEnabledConfig : boolean;
    ExeOutput : string; // the exe path (with inheritance)
    Defines : string;
    Namespaces : string;
  end;

  TDProjConfigs = class(TObjectList<DProjConfig>)
  private
    CurrentPlatForm : string;
    CurrentPlatFormCondition : string;
    CurrentConfigCondition : string;
    CurrentConfig : string;
    AppType : string;
  public
    function GetConfigNameFromConfigLine(const aConfigLine: string) : string;
    function GetConfigTypeFromConfigLine(const aConfigLine: string) : string;
    function GetPlatFormNameFromConfigLine(const aConfigLine: string) : string;

    function FindConfigByConfigName(const aConfigName : string) : DProjConfig;
    function FindConfigByCurrentSettings(): DProjConfig;

    procedure ApplySettingInheritance();
  end;

  TDProjReader = class
  private
    FFileName: TFileName;
    FXML: IXMLDocument;
    fDProjConfigs : TDProjConfigs;
    procedure LoadConfigs();

  public
    constructor Create(const aFN: TFileName);
    destructor Destroy; override;

    function Root: IXMLNodeList;
    function OutputDir(): String;
    function IsConsoleApp(const aDefaultIfNotFound: Boolean): Boolean;
    function GetSearchPath: String;
    function GetProjectDefines: string;
    function GetProjectNamespaces(): string;
    function GetPlatformOfCurrentConfig(): string;
  end;

function IfThen(const aCond: Boolean; const aIfTrue: String; const aIfFalse: string = ''): String;

implementation

uses
  System.StrUtils;

const
  gnPropertyGroup = 'PropertyGroup';

function IfThen(const aCond: Boolean; const aIfTrue: String; const aIfFalse: string = ''): String;
begin
  if aCond then
    Result := aIfTrue
  else
    Result := aIfFalse;
end;

{ TDProjReader }

constructor TDProjReader.Create(const aFN: TFileName);
begin
  if not FileExists(aFN) then
    raise Exception.Create('File not found "' + aFN + '".');
  FFileName := aFN;
  FXML := TXMLDocument.Create(Application);
  fDProjConfigs := TDProjConfigs.Create();
  FXML.LoadFromFile(aFN);
  LoadConfigs();
end;

destructor TDProjReader.Destroy;
begin
  FXML := nil;
  fDProjConfigs.free;
  inherited;
end;

function TDProjReader.GetPlatformOfCurrentConfig: string;
var
  LConfig : DProjConfig;
begin
  result := '';
  LConfig := fDProjConfigs.FindConfigByCurrentSettings();
  if assigned(LConfig) then
    Exit(LConfig.PlatformName);
end;

function TDProjReader.GetProjectDefines: string;
var
  LConfig : DProjConfig;
begin
  Result := '';
  LConfig := fDProjConfigs.FindConfigByCurrentSettings();
  if assigned(LConfig) then
    Exit(LConfig.Defines);
end;

function TDProjReader.GetProjectNamespaces: string;
var
  LConfig : DProjConfig;
begin
  Result := '';
  LConfig := fDProjConfigs.FindConfigByCurrentSettings();
  if assigned(LConfig) then
    Exit(LConfig.Namespaces);
end;

function TDProjReader.IsConsoleApp(const aDefaultIfNotFound: Boolean): Boolean;
begin
  result := sametext(fDProjConfigs.AppType, 'Console');
end;

procedure TDProjReader.LoadConfigs();
var
  i : integer;
  LPropertyGroupNode : IXMLNode;
  LChild : IXMLNode;
  LConfigName : string;
  LNewConfig : DProjConfig;
begin
  fDProjConfigs.Clear();
  for i := 0 to Root.Count-1 do
  begin
    LPropertyGroupNode := Root.Nodes[i];
    if LPropertyGroupNode.NodeName <> 'PropertyGroup' then
      Continue;

    // is it the base property group defining the ProjectGuid and the current platform and current config ?
    if LPropertyGroupNode.ChildValues['ProjectGuid'] <> null then
    begin
      if LPropertyGroupNode.ChildValues['Config'] <> null then
      begin
        LChild := LPropertyGroupNode.ChildNodes.Nodes['Config'];
        fDProjConfigs.CurrentConfig := LChild.Text;
        fDProjConfigs.CurrentConfigCondition := LChild.Attributes['Condition'];
      end;
      if LPropertyGroupNode.ChildValues['Platform'] <> null then
      begin
        LChild := LPropertyGroupNode.ChildNodes.Nodes['Platform'];
        fDProjConfigs.CurrentPlatForm := LChild.Text;
        fDProjConfigs.CurrentPlatFormCondition := LChild.Attributes['Condition'];
      end;
      if LPropertyGroupNode.ChildValues['AppType'] <> null then
      begin
        LChild := LPropertyGroupNode.ChildNodes.Nodes['AppType'];
        fDProjConfigs.AppType := LChild.Text;

      end;

    end;



    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take first nonempty OutputDir
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if LPropertyGroupNode.Attributes['Condition'] <> null then
    begin
      LConfigName := fDProjConfigs.GetConfigNameFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
      if (LPropertyGroupNode.ChildValues['Base'] <> Null) then
      begin
        // 'Base'marks the base config; thus create the node
        LNewConfig := DProjConfig.Create();
        LNewConfig.Condition := LPropertyGroupNode.Attributes['Condition'];
        LNewConfig.ConfigName := LConfigName;
        LNewConfig.ConfigType := fDProjConfigs.GetConfigTypeFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
        LNewConfig.PlatformName := fDProjConfigs.GetPlatFormNameFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
        if (LNewConfig.ConfigName <> 'Base') then // already reserverd for isBase
          if (LPropertyGroupNode.ChildValues[LNewConfig.ConfigName] <> Null) then
            LNewConfig.IsEnabledConfig := true;
        if (LPropertyGroupNode.ChildValues['CfgParent'] <> Null) then
          LNewConfig.ConfigParentName := LPropertyGroupNode.ChildValues['CfgParent'];
        if LPropertyGroupNode.ChildValues['DCC_Namespace'] <> Null then
            LNewConfig.Namespaces := LPropertyGroupNode.ChildValues['DCC_Namespace'];
        fDProjConfigs.add(LNewConfig);
      end
      else
      begin
        // Additionally Properties are marks, read them
        LNewConfig := fDProjConfigs.FindConfigByConfigName(LConfigName);
        if assigned(LNewConfig) then
        begin
          if LPropertyGroupNode.ChildValues['DCC_ExeOutput'] <> Null then
            LNewConfig.ExeOutput := LPropertyGroupNode.ChildValues['DCC_ExeOutput'];
          if LPropertyGroupNode.ChildValues['DCC_Define'] <> Null then
            LNewConfig.Defines := LPropertyGroupNode.ChildValues['DCC_Define'];
          if LPropertyGroupNode.ChildValues['DCC_Namespace'] <> Null then
            LNewConfig.Namespaces := LPropertyGroupNode.ChildValues['DCC_Namespace'];
        end;

      end;
    end;
  end;
  fDProjConfigs.ApplySettingInheritance();
end;

function TDProjReader.OutputDir(): String;
var
  i: Integer;
  LValue : String;
  LPropertyGroupNode : IXMLNode;
  LConfig : DProjConfig;
begin
  Result := '';
  LConfig := fDProjConfigs.FindConfigByCurrentSettings();
  if assigned(LConfig) then
    Exit(LConfig.ExeOutput);

  for i := 0 to Root.Count-1 do
  begin
    LPropertyGroupNode := Root.Nodes[i];
    if LPropertyGroupNode.NodeName <> 'PropertyGroup' then
      Continue;

    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take first nonempty OutputDir
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if LPropertyGroupNode.ChildValues['DCC_ExeOutput'] <> Null then
    begin
      LValue := LPropertyGroupNode.ChildValues['DCC_ExeOutput'];
      if (Result <> '') then
      begin
        if LValue <> Result then
          raise Exception.Create('Project "' + FFileName + '" - error: ' + #13#10 +
            'Output dir for exe-file differs for different configuration types (release/debug etc.)'+slineBreak+
            'Result was '+Result+', new node is '+ LValue);
      end;
      Result := LValue;
    end;
  end;
end;

function TDProjReader.GetSearchPath: String;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Root.Count-1 do
  begin
    if Root.Nodes[i].NodeName <> 'PropertyGroup' then
      Continue;

    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take DCC_UnitSearchPath from all PropertyGroups and concatenate them
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if Root.Nodes[i].ChildValues['DCC_UnitSearchPath'] <> Null then
      Result := Result + IfThen((Result<>'') and (Result[Length(Result)]<>';'), ';') +
         Root.Nodes[i].ChildValues['DCC_UnitSearchPath'];
  end;
end;

function TDProjReader.Root: IXMLNodeList;
begin
  Result := FXML.DocumentElement.ChildNodes;
end;

{ TDProjConfigs }

procedure MergeDefines(const anEntry, aBaseEntry : DProjConfig);

  function isInArray(const aTerm : string;const anArray : TArray<string>): Boolean;
  var
    LTerm : string;
    LEntry : string;
    I : Integer;
  begin
    result := false;
    LTerm := AnsiLowerCase(aTerm);
    for i := Low(anArray) to High(anArray) do
    begin
      LEntry := AnsiLowerCase(anArray[i]);
      if LEntry = LTerm then
        Exit(True);
    end;
  end;

var
  LEntryArray,
  LBaseEntryArray : TArray<string>;
  i : Integer;
  LOldLength : Integer;
begin
  if anEntry.Defines = '' then
    anEntry.Defines := aBaseEntry.Defines
  else
  begin
    LBaseEntryArray := aBaseEntry.Defines.Split([';'],TStringSplitOptions.ExcludeEmpty);
    LEntryArray := anEntry.Defines.Split([';'],TStringSplitOptions.ExcludeEmpty);
    for i := Low(LBaseEntryArray) to High(LBaseEntryArray) do
    begin
      if not isInArray(LBaseEntryArray[i], LEntryArray) then
      begin
        LOldLength := Length(LEntryArray);
        SetLength(LEntryArray, LOldLength+1);
        LEntryArray[LOldLength] := LBaseEntryArray[i];
      end;

    end;
    anEntry.Defines := '';
    for i := Low(LEntryArray) to High(LEntryArray) do
    begin
      if SameText(LEntryArray[i], '$(DCC_Define)')  then
        Continue;

      anEntry.Defines := anEntry.Defines + LEntryArray[i]+';';
    end;
    Delete(anEntry.Defines, Length(anEntry.Defines), 1);
  end;
end;

procedure TDProjConfigs.ApplySettingInheritance;

  procedure ApplyBaseRecursive(const anEntry : DProjConfig);
  var
    LBaseEntry : DProjConfig;
  begin
    if anEntry.ConfigParentName = '' then
      exit;

    LBaseEntry := FindConfigByConfigName(anEntry.ConfigParentName);
    ApplyBaseRecursive(LBaseEntry);
    if anEntry.ExeOutput = '' then
      anEntry.ExeOutput := LBaseEntry.ExeOutput;
    if anEntry.ConfigType = '' then
      anEntry.ConfigType := LBaseEntry.ConfigType;
    if anEntry.Namespaces = '' then
      anEntry.Namespaces := LBaseEntry.Namespaces;
    MergeDefines(anEntry, LBaseEntry);
  end;

var
  i : integer;
begin
  for i := self.Count-1 downto 0 do
    ApplyBaseRecursive(self[i]);
end;

function TDProjConfigs.FindConfigByConfigName(const aConfigName : string): DProjConfig;
var
  LEntry : DProjConfig;
begin
  result := nil;
  for LEntry in self do
    if LEntry.ConfigName = aConfigName then
      exit(LEntry);
end;


function TDProjConfigs.FindConfigByCurrentSettings(): DProjConfig;
var
  LEntry : DProjConfig;
begin
  result := nil;
  for LEntry in self do
    if LEntry.PlatformName = CurrentPlatForm then
      if LEntry.ConfigType = CurrentConfig then
        Exit(LEntry);
end;

function TDProjConfigs.GetConfigNameFromConfigLine(const aConfigLine: string) : string;

  function ReverseFind(const ASentence : string; const aChar : Char) : integer;
  var
    I : integer;
  begin
    result := -1;
    for i := Length(ASentence) downto 1 do
    begin
      if aSentence[i] = aChar then
        exit(i);
    end;
  end;

var
  LPreamble : string;
  LEndString : string;
  LPosAposStart : integer;
  LPosAposEnd : integer;
  LConfigName : string;
begin
  result := '';
  LPreamble := '''$(Config)''==''';
  LEndString := ')''!=''''';
  if aConfigLine.EndsWith(LEndString) then
  begin
    LPosAposEnd := Length(aConfigLine) - Length(LEndString);
    LPosAposStart := ReverseFind(Copy(aConfigLine, 1, Length(aConfigLine)-Length(LEndString)),'''');
    LConfigName := Copy(aConfigLine,LPosAposStart+1,LPosAposEnd-LPosAposStart+1);
    // remove "$(" at beginning and ")" end
    LConfigName := Copy(LConfigName, 3, Length(LConfigName)-3);
    result := LConfigName;
  end;
end;

function TDProjConfigs.GetConfigTypeFromConfigLine(const aConfigLine: string) : string;
var
  LPreamble : string;
  LPosAposStart : integer;
  LPosAposEnd : integer;
begin
  result := '';
  // find all Platform matches
  LPreamble := Copy(CurrentConfigCondition, 1,Length(CurrentConfigCondition)-1);
  //LPreamble := '''$(Config)''==''';
  if aConfigLine.Contains(LPreamble) then
  begin
    LPosAposEnd := PosEx('''', aConfigLine, Length(LPreamble)+1);
    LPosAposStart := PosEx(LPreamble, aConfigLine,1) + Length(LPreamble)-1;
    result := Copy(aConfigLine,LPosAposStart+1,LPosAposEnd-LPosAposStart-1);
  end;
end;

function TDProjConfigs.GetPlatFormNameFromConfigLine(const aConfigLine: string) : string;
var
  LPreamble : string;
  LPosAposStart : integer;
  LPosAposEnd : integer;
begin
  result := '';
  // find all Platform matches
  LPreamble := Copy(CurrentPlatFormCondition, 1,Length(CurrentPlatFormCondition)-1);

  if aConfigLine.Contains(LPreamble) then
  begin
    LPosAposStart := PosEx(LPreamble, aConfigLine,1) + Length(LPreamble)-1;
    LPosAposEnd := PosEx('''', aConfigLine, LPosAposStart+1);
    result := Copy(aConfigLine,LPosAposStart+1,LPosAposEnd-LPosAposStart-1);
  end;
end;

end.
