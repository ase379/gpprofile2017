unit testThreads;

interface

uses
  System.Classes;

type
  TTestThread = class(TThread)
  public
    constructor Create();
  protected
    procedure Execute; override;

  end;

implementation

{ TTestThread }

constructor TTestThread.Create;
begin
  inherited Create();
  FreeOnTerminate := true;
end;

procedure TTestThread.Execute;
begin
  NameThreadForDebugging('AwesomeThread', self.ThreadID);
  self.namethreadforDebugging('AwesomeThread', self.ThreadID); 
  Sleep(1000);
  inherited;
end;

end.
