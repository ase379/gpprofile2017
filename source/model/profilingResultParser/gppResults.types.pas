unit gppResults.types;

interface

type
  TProcEntry = record
  private
    function GetName: String;
  public
    // utf8 encoded procedure name
    peName         : AnsiString;
    pePID          : integer;
    peUID          : integer;
    peCID          : integer;
    peFirstLn      : integer;
    peProcTime     : array {thread} of uint64;   // 0 = sum
    peProcTimeMin  : array {thread} of uint64;   // 0 = unused
    peProcTimeMax  : array {thread} of uint64;   // 0 = unused
    peProcTimeAvg  : array {thread} of uint64;   // 0 = unused
    peProcChildTime: array {thread} of uint64;   // 0 = sum
    peProcCnt      : array {thread} of Cardinal; // 0 = sum
    peCurrentCallDepth : array {thread} of integer; // 0 = unused
    property Name : String read GetName;
  end;

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

{ TProcEntry }

{ TProcEntry }

function TProcEntry.GetName: String;
begin
  result := Utf8ToString(peName);
end;



end.
