unit DProjUnit;

interface

uses
  SysUtils, Forms, Variants, XMLDoc, XMLIntf, Dialogs;

type
  TDProj = class
  private
    FFileName: TFileName;
    FXML: IXMLDocument;
  public
    constructor Create(const aFN: TFileName);
    destructor Destroy; override;

    function Root: IXMLNodeList;
    function SearchPath: String;
    function OutputDir: String;
  end;

function IfThen(const aCond: Boolean; const aIfTrue: String; const aIfFalse: string = ''): String;
  
implementation

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
  FXML.LoadFromFile(aFN);
end;

destructor TDProj.Destroy;
begin
  FXML := nil;
  inherited;
end;

function TDProj.OutputDir: String;
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
    if Root.Nodes[i].ChildValues['DCC_ExeOutput'] <> Null then
    begin
      if (Result <> '') and (Result <> Root.Nodes[i].ChildValues['DCC_ExeOutput']) then
        raise Exception.Create('Project "' + FFileName + '" - error: ' + #13#10 +
          'Output dir for exe-file differs for different configuration types release/debug etc.)');

      Result := Root.Nodes[i].ChildValues['DCC_ExeOutput'];
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

end.
