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
end;

procedure TTestThread.Execute;
begin
  NameThreadForDebugging('AwesomeThread', self.ThreadID);
  self.namethreadfordebugging('AwesomeThread2☺☼d156exÈ', self.ThreadID);
  Sleep(1000);
  inherited;
end;

end.
