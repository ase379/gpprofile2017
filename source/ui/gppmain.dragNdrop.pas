unit gppmain.dragNdrop;

interface

uses
  System.Classes;

type
  TDragNDropHandler = class
  private
    var
      fFilenames : TStringList;
      fHandle : THandle;
    class var
      fDragNDropEnabled : Boolean;
      fDragNDropHandle : THandle;
  public
    constructor Create(const aHandle: THandle);
    destructor Destroy; override;
    procedure DetermineDroppedFiles ();

    property Filenames : TStringList read fFilenames;

    class procedure setDragNDropEnabled(const aHandle: THandle; const aValue : Boolean);
  end;



implementation

uses
  Winapi.Windows, Winapi.ShellAPI;

constructor TDragNDropHandler.Create(const aHandle : THandle);
begin
  inherited Create();
  fHandle := aHandle;
  fFilenames := TStringList.Create();
end;

destructor TDragNDropHandler.Destroy;
begin
  fFilenames.Free;
  inherited;
end;


procedure TDragNDropHandler.DetermineDroppedFiles();
var
  LCount : Integer;
  Index : Integer;
  Buffer : array [0..MAX_PATH] of Char;
begin
  LCount := DragQueryFile(fHandle, Cardinal(-1), nil, 0);
  fFilenames.Clear;
  fFilenames.BeginUpdate;
  try
    for Index := 0 to LCount - 1 do
      begin
        DragQueryFile(fHandle, Index, @Buffer, SizeOf(Buffer));
        fFilenames.Add(Buffer);
      end;
  finally
    fFilenames.EndUpdate;
  end;
end;

class procedure TDragNDropHandler.setDragNDropEnabled(const aHandle: THandle;const aValue: Boolean);
begin
  fDragNDropEnabled := aValue;
  fDragNDropHandle := aHandle;
  DragAcceptFiles (fDragNDropHandle, fDragNDropEnabled);
end;

end.
