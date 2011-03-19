{$I OPTIONS.INC}

unit GpString;

interface

function  MakeBackslash      (s: String): String;
function  MakeSmartBackslash (s: String): String;
function  NthEl        (x: string; elem: Integer; delim: char; checkQuote: integer): string;
function  NumElements  (x: string; delim: char; checkQuote: integer): Integer;
function  FirstEl      (x: string; delim: char; checkQuote: integer): string;
function  LastEl       (x: string; delim: char; checkQuote: integer): string;
function  ButFirstEl   (x: string; delim: char; checkQuote: integer): string;
function  ButLastEl    (x: string; delim: char; checkQuote: integer): string;
function  FirstNEl     (x: string; elem: Integer; delim: char; checkQuote: integer): string;
function  LastNEl      (x: string; elem: Integer; delim: char; checkQuote: integer): string;
function  ButFirstNEl  (x: string; elem: Integer; delim: char; checkQuote: integer): string;
function  ButLastNEl   (x: string; elem: Integer; delim: char; checkQuote: integer): string;
function  PosNthDelim  (x: string; elem: Integer; delim: char; checkQuote: integer): integer;
procedure SplitAtNthEl (x: string; elem: Integer; delim: char; checkQuote: integer;
                        var el1,el2: string);
function  Compress     (x: string): string;
function  TrimR        (x: string) : string;
function  TrimL        (x: string) : string;
function  ReplaceAll   (x: string; chOrig, chNew: char): string;
function  Replace      (x: string; before: string; after: string): string;
function  First        (x: string; num: integer): string;
function  Last         (x: string; num: integer): string;
function  ButFirst     (x: string; num: integer): string;
function  ButLast      (x: string; num: integer): string;

implementation

function MakeBackslash (s: String): String;
var
  w: Word;
begin
  if (Length (s) = 0) or (s[Length(s)] <> '\') then
    Result := s + '\'
  else begin
    w := Length (s)-1;
    while (w > 0) and (s[w] = '\') do
    begin
      SetLength (s, w);
      dec (w);
    end;
    Result := s;
  end;
end;

function MakeSmartBackslash (s: String): String;
begin
  if (Length (s) > 0) and (s[Length (s)] <> ':') then
    MakeSmartBackslash := MakeBackslash (s)
  else
    MakeSmartBackslash := s;
end;

function NthEl (x : string; elem: Integer; delim: char; checkQuote: integer): string;
label
  endFor;
var
  skip   : boolean;
  i      : integer;
  p1     : integer;
  p2     : integer;
  element: Integer;
  chk    : boolean;
  quote  : string;
begin
  skip    := false;
  element := 1;
  p1      := 0;
  p2      := -1;
  if (Length(x) >= 1) and (x[1] = delim) then
    if elem = 1 then p1 := 1;
  for i := 1 to Length(x) do begin
    if checkQuote = -1 then chk := false
    else begin
      chk   := true;
      quote := Chr(checkQuote);
    end;
    if chk and (x[i] = quote) then skip := not skip
    else if not skip then
      if x[i] = delim then begin
        Inc(element);
        if element = elem then p1 := i;
        if element = (elem+1) then begin
          p2 := i;
          goto endFor;
        end;
      end;
  end;
endFor:
  if (p1 = 0) and (p2 = -1) and (elem > 1) then begin
    NthEl := '';
    Exit;
  end;
  if p2 = -1 then p2 := Length(x)+1;
  Inc (p1);
  Dec (p2);
  NthEl := Copy(x,p1,p2-p1+1);
end; { function NthEl }

function NumElements (x: string; delim: char; checkQuote: integer): Integer;
var
  i    : integer;
  cElem: Integer;
  skip : boolean;
  chk  : boolean;
  quote: string;
begin
  if Length(x) = 0 then NumElements := 0
  else begin
    if checkQuote = -1 then chk := false
    else begin
      chk   := true;
      quote := Chr(checkQuote);
    end;
    cElem := 1;
    skip  := false;
    for i := 1 to Length(x) do begin
      if chk and (x[i] = quote) then skip := not skip
      else if not skip then
        if x[i] = delim then Inc (cElem);
    end;
    NumElements := cElem;
  end;
end; { function NumElements }

function FirstEl (x: string; delim: char; checkQuote: integer): string;
begin
  FirstEl := NthEl (x,1,delim,checkQuote);
end; { function FirstEl }

function LastEl (x: string; delim: char; checkQuote: integer): string;
begin
  LastEl := NthEl (x,NumElements(x,delim,checkQuote),delim,checkQuote);
end; { function LastEl }

function ButFirstEl (x: string; delim: char; checkQuote: integer): string;
begin
  ButFirstEl := Copy (x,Length(FirstEl(x,delim,checkQuote))+2, Length (x));
end; { function ButFirstEl }

function ButLastEl (x: string; delim: char; checkQuote: integer): string;
begin
  ButLastEl := Copy (x,1,Length(x)-Length(LastEl(x,delim,checkQuote))-1);
end; { function ButLastEl }

function PosNthDelim (x: string; elem: Integer; delim: char; checkQuote: integer): integer;
var
  skip   : boolean;
  i      : integer;
  element: Integer;
  chk    : boolean;
  quote  : string;
begin
  skip    := false;
  element := 0;
  for i := 1 to Length(x) do begin
    if checkQuote = -1 then chk := false
    else begin
      chk   := true;
      quote := Chr(checkQuote);
    end;
    if chk and (x[i] = quote) then skip := not skip
    else if not skip then
      if x[i] = delim then begin
        Inc(element);
        if element = elem then begin
          PosNthDelim := i;
          Exit;
        end;
      end;
  end;
  PosNthDelim := 0;
end; { function PosNthDelim }

function FirstNEl (x: string; elem: Integer; delim: char; checkQuote: integer): string;
var
  p: integer;
begin
  p := PosNthDelim (x,elem,delim,checkQuote);
  if p = 0 then FirstNEl := x
           else FirstNEl := Copy (x,1,p-1);
end; { function FirstNEl }

function LastNEl (x: string; elem: Integer; delim: char; checkQuote: integer): string;
var
  p: integer;
begin
  p := PosNthDelim (x,NumElements(x,delim,checkQuote)-elem,delim,checkQuote);
  if p = 0 then LastNEl := ''
           else LastNEl := Copy (x,p+1,Length (x));
end; { function LastNEl }

function ButFirstNEl (x: string; elem: Integer; delim: char; checkQuote: integer): string;
var
  p: integer;
begin
  p := PosNthDelim (x,elem,delim,checkQuote);
  if p = 0 then ButFirstNEl := x
           else ButFirstNEl := Copy (x,p+1,Length (x));
end; { function ButFirstNEl }

function ButLastNEl (x: string; elem: Integer; delim: char; checkQuote: integer): string;
begin
  ButLastNEl := FirstNEl (x,NumElements(x,delim,checkQuote)-elem,delim,checkQuote);
end; { function ButLastNEl }

procedure SplitAtNthEl (x: string; elem: Integer; delim: char; checkQuote: integer;
                        var el1,el2: string);
var
  p: integer;
begin
  p := PosNthDelim (x,elem,delim,checkQuote);
  if p = 0 then begin
    el1 := x;
    el2 := '';
  end
  else begin
    el1 := Copy(x,1,p-1);
    el2 := Copy(x,p+1,Length (x));
  end;
end; { procedure SplitAtNthEl }

function Compress (x: string): string;
var
  xLen: integer;
  j,i : word;
begin
  x := Replace(x,#9,#32);
  i := 1;
  xLen := Length (x);
  while i < xLen do
  begin
    if x[i] = ' ' then
    begin
      j := i+1;
      while (j <= xLen) and (x[j] = ' ') do Inc(j);
      if j > (i+1) then Delete (x,i+1,j-i-1);
    end;
    Inc (i);
    xLen := Length (x);
  end;
  Compress := TrimL(TrimR(x));
end; { function Compress }

function Replace (x: string; before: string; after: string): string;
var
  p: integer;
begin
  p := 1;
  while p <= Length(x) do begin
    if Copy(x,p,Length(before)) = before then begin
      Delete (x,p,Length(before));
      Insert (after,x,p);
      Inc (p,Length(after)-Length(before)+1);
    end
    else Inc(p);
  end;
  Replace := x;
end; { function Replace }

function ReplaceAll (x: string; chOrig, chNew: char): string;
var
  i: integer;
begin
  for i := 1 to Length(x) do
    if x[i] = chOrig then x[i] := chNew;
  ReplaceAll := x;
end; { function ReplaceAll }

function TrimR (x : string): string;
var
  lenx : Integer;
begin
  lenx := Length (x);
  while (lenx > 0) and (x[lenx] = ' ') do Dec(lenx);
  SetLength (x, lenx);
  TrimR := x;
end; { function TrimR }

function TrimL (x : string): string;
var
  lenx : integer;
  i: integer;
begin
  lenx := Length (x);
  i := 1;
  while (i <= lenx) and (x[i] = ' ') do Inc(i);
  TrimL := Copy (x, i, Length (x));
end; { function TrimL }

function First (x: string; num: integer): string;
begin
  if Length(x) <= num then First := x
  else First := Copy (x,1,num);
end; { function First }

function Last (x: string; num: integer): string;
begin
  if Length(x) <= num then Last := x
  else Last := Copy (x,Length(x)-num+1,num);
end; { function Last }

function ButFirst (x: string; num: integer): string;
begin
  if Length(x) <= num then ButFirst := ''
  else ButFirst := Copy (x,num+1,Length (x));
end; { function ButFirst }

function ButLast (x: string; num: integer): string;
begin
  if Length(x) <= num then ButLast := ''
  else ButLast := Copy (x,1,Length(x)-num);
end; { function ButLast }

end.
