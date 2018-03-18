unit gppmain.tree.types;

interface

type
  TProfilingInfoTypeEnum = (pit_unit, pit_class,pit_proc,pit_thread);
  PProfilingInfoRec = ^TProfilingInfoRec;
  TProfilingInfoRec = record
    function GetId : Integer;
    case ProfilingType: TProfilingInfoTypeEnum of
      pit_unit: (UnitId: integer);
      pit_class: (ClassId: integer);
      pit_proc: (ProcId: integer);
      pit_thread: (ThreadId: Cardinal);
  end;


implementation

function TProfilingInfoRec.GetId : Integer;
begin
  case ProfilingType of
    pit_unit: Exit(Unitid);
    pit_class: Exit(ClassId);
    pit_proc: Exit(ProcId);
    pit_thread : Exit(ThreadID);
  else
     Exit(-1);
  end;
end;

end.
