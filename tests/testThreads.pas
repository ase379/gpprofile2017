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

uses{>>GpProfile U} GpProf, {GpProfile U>>}
  System.SysUtils;

{ TTestThread }

constructor TTestThread.Create;
begin{>>GpProfile} ProfilerEnterProc(1); try {GpProfile>>}
  inherited Create();
{>>GpProfile} finally ProfilerExitProc(1); end; {GpProfile>>}end;

procedure TTestThread.Execute;
begin{>>GpProfile} ProfilerEnterProc(2); try {GpProfile>>}
  gpprof.NameThreadForDebugging('AwesomeThread', self.ThreadID);
  gpprof.NameThreadForDebugging('AwesomeThread-UnicodeChars-☺☼d156exÈ', self.ThreadID);
  {self.}gpprof.namethreadfordebugging('AwesomeThread2-SelfNameReplacement', self.ThreadID);
  {TThread.}gpprof.NameThreadForDebugging('AwesomeThread3-TThreadReplacement');
  Sleep(1000);
  inherited;
{>>GpProfile} finally ProfilerExitProc(2); end; {GpProfile>>}end;

end.
