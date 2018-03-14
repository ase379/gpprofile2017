unit gppmain.tree.types;

interface

type
  TProfilingInfoTypeEnum = (pit_unit, pit_class,pit_proc);
  PProfilingInfoRec = ^TProfilingInfoRec;
  TProfilingInfoRec = record
    function GetId : Integer;
    case ProfilingType: TProfilingInfoTypeEnum of
      pit_unit: (UnitId, ThreadUnitId: integer);
      pit_class: (ParentUnitId, ClassId, ThreadClassId: integer);
      pit_proc: (ParentClassId, ProcId, ThreadProcId: integer);
  end;


implementation

function TProfilingInfoRec.GetId : Integer;
begin
  case ProfilingType of
    pit_unit: Exit(Unitid);
    pit_class: Exit(ClassId);
    pit_proc: Exit(ProcId);
  else
     Exit(-1);
  end;
end;

end.
