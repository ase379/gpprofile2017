unit gppmain.tree.types;

interface

type
  TProfilingInfoTypeEnum = (pit_unit, pit_class,pit_proc);
  PProfilingInfoRec = ^TProfilingInfoRec;
  TProfilingInfoRec = record
    case ProfilingType: TProfilingInfoTypeEnum of
      pit_unit: (UnitId, ThreadUnitId: integer);
      pit_class: (ParentUnitId, ClassId, ThreadClassId: integer);
      pit_proc: (ParentClassId, ProcId, ThreadProcId: integer);
  end;


implementation

end.
