unit gppResult.measurePointRegistry;

interface

uses
   System.Generics.Collections;

type
  TMeasurePointRegistry = class
  private
    fLastMeasurePointId : String;
    fLastMeasurePointProcId : Cardinal;
    function GetLastMeasurePointId: String;
    procedure SetLastMeasurePointId(const Value: String);
    function GetLastMeasurePointProcId: Cardinal;
    procedure SetLastMeasurePointProcId(const Value: Cardinal);
  public
    property LastMeasurePointId: String read GetLastMeasurePointId write SetLastMeasurePointId;
    property LastMeasurePointProcID: Cardinal read GetLastMeasurePointProcId write SetLastMeasurePointProcId;
  end;

implementation

uses Sysutils;

{ TMeasurePointRegistry }

function TMeasurePointRegistry.GetLastMeasurePointId: String;
begin
  result := fLastMeasurePointId;
end;

function TMeasurePointRegistry.GetLastMeasurePointProcId: Cardinal;
begin
  result := fLastMeasurePointProcId;
end;

procedure TMeasurePointRegistry.SetLastMeasurePointId(const Value: String);
begin
  fLastMeasurePointId := Value;
end;

procedure TMeasurePointRegistry.SetLastMeasurePointProcId(const Value: Cardinal);
begin
  fLastMeasurePointProcId := Value;
end;

end.
