unit EZLngStk;
  {-Example unit defining a stack for strings}

  {Note: the raison d'etre of this object definition is to show how
         easy it is to define an object based on one of EZDSL classes.
         And one that you don't have to continually remember to
         typecast the objects when you're adding or removing them from
         the container; all the nastiness is hidden!}
  {Note: what people tend to forget is that long strings are pointers,
         pointing to a reference counted memory block on the heap. You
         cannot just copy over the pointer, because you will not
         increment the string's reference count. So the Push method
         cannot just copy over the pointer, it *must* copy the string
         in some sense, so that the reference count is incremented.
         Similarly on the Pop: we need to make sure we don't increment
         the reference count once too often.}

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}
{$H+ long strings required}

{$IFDEF VER80}
!! Error: This unit is for 32-bit Delphi *only*
{$ENDIF}

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

procedure EZLongStrDisposeData(aData : pointer);
begin
  string(aData) := '';
end;


{===TStringStack implementation======================================}
constructor TStringStack.Create;
begin
  Stack := TStack.Create(true);
  Stack.DisposeData := EZLongStrDisposeData;
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
begin
  Result := '';
  if not IsEmpty then begin
    {pop the string as a pointer}
    pointer(Result) := Stack.Pop;
  end;
end;
{--------}
procedure TStringStack.Push(const S : string);
var
  NewS : string;
begin
  {increment the reference count}
  NewS := S;
  {push the string as pointer}
  Stack.Push(pointer(NewS));
  {the compiler will set NewS to '' for us at the end statement and
   decrement the ref count, but we don't want it to: the stack now
   has one reference to the string; so fool the compiler}
  pointer(NewS) := nil;
end;
{====================================================================}

end.