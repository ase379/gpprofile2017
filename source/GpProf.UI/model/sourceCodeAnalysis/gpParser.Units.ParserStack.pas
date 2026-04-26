unit gpParser.Units.ParserStack;

interface

uses
  System.Classes, System.Generics.Collections, System.SysUtils, CastaliaPasLexTypes, CastaliaPasLex;

type
  TUnitParserStackEntry = class
  private
    fStream : TStream;
    fLexer : TmwPasLex;
    fFilename : string;
  public
    constructor Create(const aFilename : TFileName);
    destructor Destroy; override;

    property Stream : TStream read fStream;
    property Lexer : TmwPasLex read fLexer;
    property Filename : string read fFilename;
  end;

  TUnitParserStack = class
  private
    fList : TList<TUnitParserStackEntry>;
  public
    constructor Create();
    destructor Destroy; override;

    procedure Add(const aEntry : TUnitParserStackEntry);

    function HasEntries: Boolean;
    procedure RemoveLastEntry;
    function GetLastEntry : TUnitParserStackEntry;
  end;


implementation

{ TUnitParserStack }

constructor TUnitParserStack.Create;
begin
  inherited;
  fList := TList<TUnitParserStackEntry>.Create;
end;

destructor TUnitParserStack.Destroy;
begin
  FreeAndNil(fList);
  inherited;
end;

function TUnitParserStack.GetLastEntry: TUnitParserStackEntry;
begin
  result := nil;
  if HasEntries then
    result := fList.Last;
end;

function TUnitParserStack.HasEntries: Boolean;
begin
  result := fList.Count > 0;
end;

procedure TUnitParserStack.RemoveLastEntry;
begin
  if HasEntries then
    fList.Remove(fList.Last);
end;

procedure TUnitParserStack.Add(const aEntry : TUnitParserStackEntry);
begin
  fList.Add(aEntry);
end;

{ TUnitParserStackEntry }

constructor TUnitParserStackEntry.Create(const aFilename : TFileName);
var
  LStream : TMemoryStream;
  LZero: char;
begin
  inherited Create();
  fLexer := TmwPasLex.Create;
  LStream := TMemoryStream.Create();
  fStream := LStream;
  fFilename := aFilename;

  try
    LStream.LoadFromFile(aFilename);
  except
    FreeAndNil(fLexer);
    FreeAndNil(fStream);
    raise;
  end;
  fStream.Position := fStream.Size;
  LZero := #0;
  fStream.Write(LZero, 1);
  fLexer.Origin := pAnsichar(LStream.Memory);
  fLexer.RunPos := 0;
end;

destructor TUnitParserStackEntry.Destroy;
begin
  FreeAndNil(fLexer);
  FreeAndNil(fStream);
  inherited;
end;

end.
