program EXLngSlk;
  {-Example program to show how to use a longstring stack}


{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

{$IFDEF Win32}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  DTstGen,
  EZDSLSup,
  EZLngStk;

var
  Stk : TStringStack;
  i   : integer;
  S   : string;

begin
  OpenLog;
  try
    WriteLog('String stack test');
    {initialise the stack}
    WriteLog('Creating the string stack');
    Stk := TStringStack.Create;
    try
      {push some strings onto the stack}
      WriteLog('Pushing 10 strings');
      for i := 1 to 10 do begin
        S := NumToName(i);
        WriteLog(S);
        Stk.Push(S);
        S := '';
      end;
      {pop the strings off, and write them out}
      WriteLog('Popping 10 strings');
      for i := 1 to 10 do
        WriteLog(Stk.Pop);
    finally
      {destroy the stack}
      Stk.Free;
    end;
  finally
    CloseLog;
  end;
end.
