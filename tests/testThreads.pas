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

uses
  System.SysUtils, gpprof;

{ TTestThread }

constructor TTestThread.Create;
begin
  inherited Create();
end;

procedure TTestThread.Execute;
begin
  NameThreadForDebugging('AwesomeThread', self.ThreadID);
   {>>GpProfile MP Enter} ProfilerEnterMP('MP_TestThreadExecute'); try {GpProfile MP Enter>>}
  NameThreadForDebugging('AwesomeThread-UnicodeChars-☺☼d156exÈ', self.ThreadID);
  self.namethreadfordebugging('AwesomeThread2-SelfNameReplacement', self.ThreadID);
  TThread.NameThreadForDebugging('AwesomeThread3-TThreadReplacement');
  Sleep(1000);
  {>>GpProfile MP Leave} finally ProfilerExitMP('MP_TestThreadExecute'); end; {GpProfile MP Leave>>}
  inherited;
end;

end.
