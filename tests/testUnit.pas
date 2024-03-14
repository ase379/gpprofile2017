unit testUnit;

interface

procedure TestProcedure;
procedure TestFunction;
procedure TestFunctionNestedType;
/// <summary>
/// OLE based calls allow properties with END. Delphi fields and properties do not allow it.
///  The function simulations
/// </summary>
procedure TestFunctionWithEndFunctions;
procedure TestFunctionWithNestedVariantRecord();
procedure TestThread();

implementation

uses testThreads;

type
  tRecordWithEnd = class
    OLEApp : Variant;
  end;

procedure TestProcedure;
begin
end;


procedure TestFunction;
begin
end;

procedure TestFunctionWithEndFunctions;
var
  lRecordWithEnd : tRecordWithEnd;
begin
  lRecordWithEnd := default(tRecordWithEnd);
  lRecordWithEnd.OleApp.Selection.SetRange(lRecordWithEnd.OleApp.ActiveDocument.Range.End, lRecordWithEnd.OleApp.ActiveDocument.Range.End);
end;


procedure TestFunctionNestedType;
type
  TRecord = record
    A, B : integer;
  end;
begin
end;


procedure TestThread();
var lThread : TTestThread;
begin
  lThread := TTestThread.Create;
  lThread.WaitFor;
  lThread.free;
end;

procedure TestFunctionWithNestedVariantRecord();
type
  TDataRec = record
               Name: String;
               IsValid: Boolean;
               Data    : record
                             Byte1,
                             Byte2 : byte;
                           end;
end;
const
  cA1 = 1;
  cA2 = 2;
begin
end;

end.
