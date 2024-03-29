﻿unit testThreads;

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
  var lOuterScope := gpprof.CreateMeasurePointScope('MP_TestThreadExecuteOuter');
  NameThreadForDebugging('AwesomeThread-UnicodeChars-☺☼d156exÈ', self.ThreadID);
  var lInnerScope := gpprof.CreateMeasurePointScope('MP_TestThreadExecuteInner');
  self.namethreadfordebugging('AwesomeThread2-SelfNameReplacement', self.ThreadID);
  TThread.NameThreadForDebugging('AwesomeThread3-TThreadReplacement');
  Sleep(1000);
  lInnerScope := nil;
  Sleep(1000);
  lOuterScope := nil;
  inherited;
end;

end.
