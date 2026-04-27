program GPProfTester;


{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  testUnit in 'testUnit.pas',
  testThreads in 'testThreads.pas',
  testMultiDefines in 'testMultiDefines.pas',
  testClassMethods in 'testClassMethods.pas',
  testGenerics in 'testGenerics.pas',
  testAnonymousMethods in 'testAnonymousMethods.pas',
  testAsmRoutines in 'testAsmRoutines.pas',
  testNestedProcedures in 'testNestedProcedures.pas',
  testCallGraphLogic in 'testCallGraphLogic.pas',
  testMeasurePointRegistryLogic in 'testMeasurePointRegistryLogic.pas',
  testProcEntriesLogic in 'testProcEntriesLogic.pas',
  testActiveProcListLogic in 'testActiveProcListLogic.pas';

begin
  try
    // Parser test units: basic patterns
    TestProcedure;
    TestFunction;
    TestFunctionNestedType;
    TestFunctionWithEndFunctions;
    TestFunctionWithNestedVariantRecord;
    TestThread();

    // Parser test units: class methods and helpers
    TestConcreteClassCreation;
    TestClassHelper;
    TestRecordWithMethods;
    TestClassStaticProc;
    TestOverloadedMethods;
    TestVirtualDispatch;

    // Parser test units: generics
    TestGenericStack;
    TestGenericPair;
    TestGenericUtility;
    TestGenericFunctions;

    // Parser test units: anonymous methods
    TestAnonymousProcedure;
    TestAnonymousFunction;
    TestClosure;
    TestMethodReference;
    TestNestedAnonymousMethods;
    TestAnonymousMethodAsParameter;

    // Parser test units: ASM routines
    TestAsmCalls;

    // Parser test units: nested procedures
    TestNestedProcedure;
    TestNestedFunction;
    TestMultipleNestedAtSameLevel;
    TestDeepNesting;
    TestNestedAccessingOuter;
    TestNestedWithForwardDeclaration;

    // Logic unit tests
    RunCallGraphTests;
    RunMeasurePointRegistryTests;
    RunProcEntriesTests;
    RunActiveProcListTests;

    Writeln('All tests completed successfully.');
  except
    on E: Exception do
    begin
      Writeln('TEST FAILURE: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
