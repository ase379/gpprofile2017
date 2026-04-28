program GPProfTester;


{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  testUnit in 'testUnit.pas',
  testThreads in 'testThreads.pas',
  testMultiDefines in 'testMultiDefines.pas';

begin
  try
    TestProcedure;
    TestFunction;
    TestFunctionNestedType;
    TestThread();
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
