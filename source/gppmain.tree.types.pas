unit gppmain.tree.types;

interface

type
  TProfilingInfoTypeEnum = (pit_unit, pit_class,pit_proc,pit_proc_callers,pit_proc_callees,pit_thread);
  PProfilingInfoRec = ^TProfilingInfoRec;
  TProfilingInfoRec = record
    function GetId : Integer;
    procedure GetCallStackInfo(var aProcId: Int64;var aGraphIndex : Int16);
    case ProfilingType: TProfilingInfoTypeEnum of
      pit_unit: (UnitId: integer);
      pit_class: (ClassId: integer);
      pit_proc: (ProcId: integer);
      pit_proc_callers: (CallerProcId: integer;CallerGraphIndex:Int16);
      pit_proc_callees: (CalleeProcId: integer;CalleeGraphIndex:Int16);
      pit_thread: (ThreadId: Cardinal);
  end;


implementation

function TProfilingInfoRec.GetId : Integer;
begin
  case ProfilingType of
    pit_unit: Exit(Unitid);
    pit_class: Exit(ClassId);
    pit_proc: Exit(ProcId);
    pit_proc_callers: Exit(CallerProcId);
    pit_proc_callees: Exit(CalleeProcId);
    pit_thread : Exit(ThreadID);
  else
     Exit(-1);
  end;
end;


procedure TProfilingInfoRec.GetCallStackInfo(var aProcId: Int64;var aGraphIndex : Int16);
begin
  case ProfilingType of
    pit_proc_callers:
    begin
       aProcId := self.CallerProcId;
       aGraphIndex := Self.CallerGraphIndex;
    end;
    pit_proc_callees:
    begin
       aProcId := self.CalleeProcId;
       aGraphIndex := Self.CalleeGraphIndex;
    end;
  else
    begin
       aProcId := -1;
       aGraphIndex := -1;
    end;
  end;
end;

end.
