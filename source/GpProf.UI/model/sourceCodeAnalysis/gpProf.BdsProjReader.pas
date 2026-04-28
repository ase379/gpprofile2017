unit gpProf.BdsProjReader;

interface

uses
  SysUtils, Forms, Variants, XMLDoc, XMLIntf, Dialogs;

type
  TBdsProjReader = class
  private
    FFileName: TFileName;
    FXML: IXMLDocument;
  public
    constructor Create(const aFN: TFileName);
    destructor Destroy; override;

    function Root: IXMLNodeList;
    function OutputDir: String;
    function GetProjectDefines: string;
    function GetSearchPath: String;
    function IsConsoleApp(const aDefaultIfNotFound: boolean): Boolean;
  end;

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

{ TBdsProjReader }

constructor TBdsProjReader.Create(const aFN: TFileName);
begin
  if not FileExists(aFN) then
    raise Exception.Create('File not found "' + aFN + '".');
  FFileName := aFN;
  FXML := TXMLDocument.Create(Application);
  FXML.LoadFromFile(aFN);
end;

destructor TBdsProjReader.Destroy;
begin
  FXML := nil;
  inherited;
end;

function TBdsProjReader.GetProjectDefines: string;
var
  i: Integer;
  Personalities,Directories:IXmlNodeList;
  Nd:IXmlNode;
begin
  Result := '';

  Personalities := Root.Nodes['Delphi.Personality'].ChildNodes;
  Directories := Personalities.Nodes['Directories'].ChildNodes;
  for i := 0 to Directories.Count-1 do
  begin
    Nd := Directories.Nodes[i];
    if (Nd.Attributes['Name'] = 'Conditionals') and (Nd.NodeValue <> Null) then
    begin
      Result := Result + IfThen((Result<>'') and (Result[Length(Result)]<>';'), ';') +
         Nd.NodeValue;
    end;
  end;
end;

function TBdsProjReader.IsConsoleApp(const aDefaultIfNotFound: boolean): Boolean;
var
  i: Integer;
  Personalities,Directories:IXmlNodeList;
  Nd:IXmlNode;
begin
  Result := false;
  Personalities := Root.Nodes['Delphi.Personality'].ChildNodes;
  Directories := Personalities.Nodes['Linker'].ChildNodes;
  for i := 0 to Directories.Count-1 do
  begin
    Nd := Directories.Nodes[i];
    if (Nd.Attributes['Name'] = 'ConsoleApp') and (Nd.NodeValue <> Null) then
    begin
      Result := Nd.NodeValue;
    end;
  end;
end;

function TBdsProjReader.OutputDir: String;
var
  i: Integer;
  Personalities,Directories:IXmlNodeList;
  Nd:IXmlNode;
begin
  Result := '';

  Personalities := Root.Nodes['Delphi.Personality'].ChildNodes;
  Directories := Personalities.Nodes['Directories'].ChildNodes;
  for i := 0 to Directories.Count-1 do
  begin
    Nd := Directories.Nodes[i];
    if (Nd.Attributes['Name'] = 'OutputDir') and (Nd.NodeValue <> Null) then
    begin
      Result := Nd.NodeValue;
    end;
  end;
end;

function TBdsProjReader.GetSearchPath: String;
var
  i: Integer;
  Personalities,Directories:IXmlNodeList;
  Nd:IXmlNode;
begin
  Result := '';

  Personalities := Root.Nodes['Delphi.Personality'].ChildNodes;
  Directories := Personalities.Nodes['Directories'].ChildNodes;
  for i := 0 to Directories.Count-1 do
  begin
    Nd := Directories.Nodes[i];
    if (Nd.Attributes['Name'] = 'SearchPath') and (Nd.NodeValue <> Null) then
    begin
      Result := Result + IfThen((Result<>'') and (Result[Length(Result)]<>';'), ';') +
         Nd.NodeValue;
    end;
  end;
end;

function TBdsProjReader.Root: IXMLNodeList;
begin
  Result := FXML.DocumentElement.ChildNodes;
end;

end.
