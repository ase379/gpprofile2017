unit DTstGen;

{$I EZDSLDEF.INC}
{---Place any compiler options you require here-----------------------}


{---------------------------------------------------------------------}
{$I EZDSLOPT.INC}

interface

uses
  {$IFDEF VER80}
  WinCrt,
  {$ENDIF}
  SysUtils;

procedure OpenLog;
procedure WriteLog(const S : string);
procedure WriteLogNoCR(const S : string);
procedure CloseLog;
  {-Logging routines}

{$IFDEF VER80}
procedure SetLength(var S : string; Len : byte);
  {-Delphi 1.0 only: set the length of a string}
{$ENDIF}

function RandomStr(Len : byte) : string;
  {-Create a string of length Len filled with random uppercase chars}

function NumToName(i : integer) : string;
  {-Create a string in English for the passed integer}

implementation

var
  F : text;

procedure OpenLog;
  begin
    {$IFDEF VER80}
    InitWinCrt;
    {$ENDIF}
    Assign(F, 'TEST.LOG');
    Rewrite(F);
  end;
procedure WriteLogNoCR(const S : string);
  begin
    write(F, S, ' ');
    write(S, ' ');
  end;
procedure WriteLog(const S : string);
  begin
    writeln(F, S);
    writeln(S);
  end;
procedure CloseLog;
  begin
    Close(F);
    writeln('TEST.LOG has been created; press <Enter> to continue');
    readln;
    {$IFDEF VER80}
    DoneWinCrt;
    {$ENDIF}
  end;

{$IFDEF VER80}
procedure SetLength(var S : string; Len : byte);
  begin
    S[0] := char(Len);
  end;
{$ENDIF}

function RandomStr(Len : byte) : string;
  var
    i : integer;
  begin
    SetLength(Result, Len);
    for i := 1 to Len do
      Result[i] := char(Random(26) + ord('A'));
  end;

function NumToName(i : integer) : string;
  const
    Name09 : array [0..9] of string[5] =
               ('zero', 'one', 'two', 'three', 'four', 'five',
                'six', 'seven', 'eight', 'nine');
    Name10s : array [2..9] of string[7] =
               ('twenty', 'thirty', 'forty', 'fifty',
                'sixty', 'seventy', 'eighty', 'ninety');
    NameTeens : array [0..9] of string[9] =
               ('ten', 'eleven', 'twelve', 'thirteen', 'fourteen', 'fifteen',
                'sixteen', 'seventeen', 'eighteen', 'nineteen');
    Name100 : string[9] = ' hundred';
    Name1000 : string[9] = ' thousand';
    NameBig : string[9] = 'very big';
    NameNeg : string[15] = 'less than zero';
  {------}
  procedure Cvt1000(var S : string; i : integer);
    var
      Work : integer;
    begin
      if (i >= 100) then
        begin
          Work := i div 100;
          S := S + ' ' + Name09[Work] + Name100;
          i := i mod 100;
        end;
      if (i >= 20) then
        begin
          S := S + ' ' + Name10s[i div 10];
          if (i mod 10) > 0 then
            S := S + ' ' + Name09[i mod 10];
        end
      else if (i >= 10) then
        S := S + ' ' + NameTeens[i - 10]
      else if (i > 0) then
        S := S + ' ' + Name09[i];
    end;
  {------}
  begin
    if (i < 0) then
      Result := NameNeg
    else if (i = 0) then
      Result := Name09[0]
    {$IFDEF VER90}
    else if (i > 1000000) then
      Result := NameBig
    {$ENDIF}
    else
      begin
        Result := '';
        {do thousands}
        if (i >= 1000) then
          begin
            Cvt1000(Result, i div 1000);
            Result := Result + Name1000;
            i := i mod 1000;
          end;
        {do rest}
        Cvt1000(Result, i);
      end;
    if (Result[1] = ' ') then
      Delete(Result, 1, 1);
  end;

end.
