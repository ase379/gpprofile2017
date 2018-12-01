unit DProjUnit;

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
  end;

  TDProjConfigs = class(TObjectList<DProjConfig>)
  private
    CurrentPlatForm : string;
    CurrentPlatFormCondition : string;
    CurrentConfigCondition : string;
    CurrentConfig : string;
  public
    function GetActiveConfig() : DProjConfig;
    function FindConfigByConfigName(const aConfigName : string) : DProjConfig;
    function FindConfigByCurrentSettings(): DProjConfig;

    procedure ApplySettingInheritance();
  end;

  TDProj = class
  private
    FFileName: TFileName;
    FXML: IXMLDocument;
    fDProjConfigs : TDProjConfigs;
    procedure LoadConfigs();

  public
    constructor Create(const aFN: TFileName);
    destructor Destroy; override;

    function Root: IXMLNodeList;
    function SearchPath: String;
    function OutputDir(): String;

    function XE2Config: string;
    function XE2Platform: string;
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

{ TDProj }

constructor TDProj.Create(const aFN: TFileName);
begin
  if not FileExists(aFN) then
    raise Exception.Create('File not found "' + aFN + '".');
  FFileName := aFN;
  FXML := TXMLDocument.Create(Application);
  fDProjConfigs := TDProjConfigs.Create();
  FXML.LoadFromFile(aFN);
  LoadConfigs();
end;

destructor TDProj.Destroy;
begin
  FXML := nil;
  fDProjConfigs.free;
  inherited;
end;

procedure TDProj.LoadConfigs();

  function GetConfigNameFromConfigLine(const aConfigLine: string) : string;

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

  const
    APOS = #27;
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

  function GetConfigTypeFromConfigLine(const aConfigLine: string) : string;
  var
    LPreamble : string;
    LPosAposStart : integer;
    LPosAposEnd : integer;
  begin
    result := '';
    // find all Platform matches
    LPreamble := Copy(fDProjConfigs.CurrentConfigCondition, 1,Length(fDProjConfigs.CurrentConfigCondition)-1);
    //LPreamble := '''$(Config)''==''';
    if aConfigLine.Contains(LPreamble) then
    begin
      LPosAposEnd := PosEx('''', aConfigLine, Length(LPreamble)+1);
      LPosAposStart := PosEx(LPreamble, aConfigLine,1) + Length(LPreamble)-1;
      result := Copy(aConfigLine,LPosAposStart+1,LPosAposEnd-LPosAposStart-1);
    end;
  end;

  function GetPlatFormNameFromConfigLine(const aConfigLine: string) : string;
  var
    LPreamble : string;
    LPosAposStart : integer;
    LPosAposEnd : integer;
  begin
    result := '';
    // find all Platform matches
    LPreamble := Copy(fDProjConfigs.CurrentPlatFormCondition, 1,Length(fDProjConfigs.CurrentPlatFormCondition)-1);

    if aConfigLine.Contains(LPreamble) then
    begin
      LPosAposStart := PosEx(LPreamble, aConfigLine,1) + Length(LPreamble)-1;
      LPosAposEnd := PosEx('''', aConfigLine, LPosAposStart+1);
      result := Copy(aConfigLine,LPosAposStart+1,LPosAposEnd-LPosAposStart-1);
    end;
  end;



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
    end;



    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take first nonempty OutputDir
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if LPropertyGroupNode.Attributes['Condition'] <> null then
    begin
      LConfigName := GetConfigNameFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
      if (LPropertyGroupNode.ChildValues['Base'] <> Null) then
      begin
        // 'Base'marks the base config; thus create the node
        LNewConfig := DProjConfig.Create();
        LNewConfig.Condition := LPropertyGroupNode.Attributes['Condition'];
        LNewConfig.ConfigName := LConfigName;
        LNewConfig.ConfigType := GetConfigTypeFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
        LNewConfig.PlatformName := GetPlatFormNameFromConfigLine(LPropertyGroupNode.Attributes['Condition']);
        if (LNewConfig.ConfigName <> 'Base') then // already reserverd for isBase
          if (LPropertyGroupNode.ChildValues[LNewConfig.ConfigName] <> Null) then
            LNewConfig.IsEnabledConfig := true;
        if (LPropertyGroupNode.ChildValues['CfgParent'] <> Null) then
          LNewConfig.ConfigParentName := LPropertyGroupNode.ChildValues['CfgParent'];
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
        end;

      end;
    end;
  end;
  fDProjConfigs.ApplySettingInheritance();
end;

function TDProj.OutputDir(): String;
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

function TDProj.XE2Config: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Root.Count-1 do
  begin
    if Root.Nodes[i].NodeName <> 'PropertyGroup' then
      Continue;

    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take first nonempty OutputDir
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if Root.Nodes[i].ChildValues['Config'] <> Null then
    begin
      if (Result <> '') and (Result <> Root.Nodes[i].ChildValues['Config']) then begin
        {do nothing}
      end
      else Result := Root.Nodes[i].ChildValues['Config'];
    end;
  end;
end;

function TDProj.XE2Platform: string;
var
  i: Integer;
begin
  Result := '';
  for i := 0 to Root.Count-1 do
  begin
    if Root.Nodes[i].NodeName <> 'PropertyGroup' then
      Continue;

    // NB! "Condition" attribute in PropertyGroup is not analyzed due to its complicated structure
    // In current realization simply take first nonempty OutputDir
    // (i.e. analysis of different config types (debug/release) is not implemented)
    if Root.Nodes[i].ChildValues['Platform'] <> Null then
    begin
      if (Result <> '') and (Result <> Root.Nodes[i].ChildValues['Platform']) then begin
        {do nothing}
      end
      else Result := Root.Nodes[i].ChildValues['Platform'];
    end;
  end;
end;

function TDProj.SearchPath: String;
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

function TDProj.Root: IXMLNodeList;
begin
  Result := FXML.DocumentElement.ChildNodes;
end;

{ TDProjConfigs }

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

function TDProjConfigs.GetActiveConfig: DProjConfig;
var
  LEntry : DProjConfig;
begin
  result := nil;
  for LEntry in self do
//    if LEntry.Condition.Contains(Self.CurrentConfig = aConfigName then
      exit(LEntry);
end;

end.
