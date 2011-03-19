program CodeEx;

uses
  Forms,
  CodeExMain in 'CodeExMain.pas' {CodeExplorer};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCodeExplorer, CodeExplorer);
  Application.Run;
end.
