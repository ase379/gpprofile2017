unit gppResult.measurePointRegistry;

interface

uses
   System.Generics.Collections;

type
  TMeasurePointRegistryEntry = class
    ProcId : Cardinal;
    MeasurePointId : String;
  end;

  TMeasurePointRegistry = class
  private
    fNameToEntryDict : TObjectDictionary<String, TMeasurePointRegistryEntry>;

  public
    constructor Create();
    destructor Destroy; override;

    function RegisterMeasurePoint(const aProcId : Cardinal; const aMeasurePointId : String): TMeasurePointRegistryEntry;
    procedure UnRegisterMeasurePoint(const aMeasurePointId : String);

    function GetMeasurePointEntry(const aMeasurePointId : String) : TMeasurePointRegistryEntry;

  end;

implementation

uses Sysutils;

{ TMeasurePointRegistry }

constructor TMeasurePointRegistry.Create;
begin
  inherited Create();
  fNameToEntryDict := TObjectDictionary<String, TMeasurePointRegistryEntry>.Create([doOwnsValues]);
end;

destructor TMeasurePointRegistry.Destroy;
begin
  fNameToEntryDict.Free;
  inherited;
end;

function TMeasurePointRegistry.RegisterMeasurePoint(const aProcId : Cardinal; const aMeasurePointId : String) : TMeasurePointRegistryEntry;
var
  lEntry : TMeasurePointRegistryEntry;
begin
  if fNameToEntryDict.TryGetValue(aMeasurePointId, lEntry) then
  begin
    var error := 'The Measure Point "'+aMeasurePointId+'" has been used multiple times.'+sLineBreak+
                'Please correct it, the name must be unique.';
    raise Exception.Create(error)
  end;
  result := TMeasurePointRegistryEntry.Create;
  result.ProcId := aProcId;
  result.MeasurePointId := aMeasurePointId;
  fNameToEntryDict.AddOrSetValue(aMeasurePointId, result);
end;

function TMeasurePointRegistry.GetMeasurePointEntry(const aMeasurePointId : String) : TMeasurePointRegistryEntry;
begin
  if not fNameToEntryDict.tryGetValue(aMeasurePointId, result) then
    result := nil;
end;

procedure TMeasurePointRegistry.UnRegisterMeasurePoint(const aMeasurePointId : String);
begin
  // do not unregister for finding double mp ids.
end;

end.
