unit gpProf.DofReader;

interface

uses
  System.SysUtils, System.IniFiles, GpRegistry, Dialogs, System.Generics.Collections;

type
  TDofReader = class
  private
    fFilename : string;
    fIniFile : TIniFile;

  public
    constructor Create(const aFN: TFileName);
    destructor Destroy; override;

    function OutputDir(): String;
    function IsConsoleApp(const aDefaultIfNotFound: Boolean): Boolean;
    function GetProjectDefines(): string;
    function GetSearchPath() : string;
  end;
implementation

uses
  System.StrUtils;


{ TDofReader }

constructor TDofReader.Create(const aFN: TFileName);
begin
  if not FileExists(aFN) then
    raise Exception.Create('File not found "' + aFN + '".');
  FFileName := aFN;
  fIniFile := TIniFile.Create(aFN);
end;

destructor TDofReader.Destroy;
begin
  fIniFile.free;
  inherited;
end;

function TDofReader.GetProjectDefines: string;
begin
  result := fIniFile.ReadString('Directories','Conditionals','');
end;

function TDofReader.GetSearchPath: string;
begin
  result := fIniFile.ReadString('Directories', 'SearchPath', '');
end;

function TDofReader.IsConsoleApp(const aDefaultIfNotFound: Boolean): Boolean;
begin
  result := fIniFile.ReadBool('Linker', 'ConsoleApp', aDefaultIfNotFound)
end;

function TDofReader.OutputDir(): String;
begin
  Result := fIniFile.ReadString('Directories', 'OutputDir', '');;
end;

{ TDProjConfigs }


end.
