unit gppresults.types;

interface

type
  TProgressCallback = function (percent: integer): boolean of object;
  TResPacket = record
  public
    rpTag         : byte;
    rpThread      : integer;
    rpProcID      : integer;
    rpMeasure1    : int64;
    rpMeasure2    : int64;
    rpNullOverhead: int64;
    rpMemWorkingSize : Cardinal;
    rpMeasurePointID : String;
  end;


const
  NULL_ACCURACY = 1000;
  REPORT_EVERY  = 100; // samples read

implementation

uses
  System.Classes, System.Sysutils;

const
  APL_QUANTUM   = 10;


end.
