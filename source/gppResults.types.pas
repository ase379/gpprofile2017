unit gppResults.types;

interface

type
  TResPacket = record
  public
    rpTag         : byte;
    rpThread      : integer;
    rpProcID      : integer;
    rpMeasure1    : int64;
    rpMeasure2    : int64;
    rpNullOverhead: int64;
    rpMem         : uint64;
  end;

const
  APL_QUANTUM   = 10;
  NULL_ACCURACY = 1000;
  REPORT_EVERY  = 100; // samples read

implementation

end.
