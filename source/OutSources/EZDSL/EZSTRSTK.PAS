unit EZStrStk;
  {-Example unit defining a stack for strings}

  {Note: the raison d'etre of this object definition is to show how
         easy it is to define an object based on one of EZDSL classes.
         And one that you don't have to continually remember to
         typecast the objects when you're adding or removing them from
         the container; all the nastiness is hidden!}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

uses
  SysUtils,
  EZDSLSup,
  EZDSLStk;

type
  {A stack for storing strings}
  TStringStack = class
    private
      Stack : TStack;

    public
      constructor Create;
        {-Initialise the stack}
      destructor Destroy; override;
        {-Destroy the stack}

      function Count : longint;
        {-Return the number of strings in the stack}
      function IsEmpty : boolean;
        {-Return true if the stack is empty}
      function Pop : string;
        {-Return the string on the top of the stack after popping it}
      procedure Push(const S : string);
        {-Return true if the string was pushed onto the stack}
  end;

implementation


{===TStringStack implementation======================================}
constructor TStringStack.Create;
begin
  Stack := TStack.Create(true);
  Stack.DisposeData := EZStrDisposeData;
end;
{--------}
destructor TStringStack.Destroy;
begin
  Stack.Free;
end;
{--------}
function TStringStack.Count : longint;
begin
  Count := Stack.Count;
end;
{--------}
function TStringStack.IsEmpty : boolean;
begin
  IsEmpty := Stack.IsEmpty;
end;
{--------}
function TStringStack.Pop : string;
var
  PS : PEZString;
begin
  Result := '';
  if not IsEmpty then begin
    PS := PEZString(Stack.Pop);
    if Assigned(PS) then begin
      Result := PS^;
      Stack.DisposeData(PS);
    end;
  end;
end;
{--------}
procedure TStringStack.Push(const S : string);
var
  PS : PEZString;
begin
  PS := EZStrNew(S);
  try
    Stack.Push(PS);
  except
    Stack.DisposeData(PS);
    raise
  end; {try..except}
end;
{====================================================================}

end.