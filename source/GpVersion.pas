{$I OPTIONS.INC}

unit gpversion;

interface

uses
  Windows;

const
  verFullDotted   = '%d.%d.%d.%d';     // 1.0.1.0 => 1.0.1.0
  verShort2to4    = '%d.%d%t.%d.%d';   // 1.0.1.0 => 1.0.1
  verShort2to3    = '%d.%d%t.%d';      // 1.0.1.0 => 1.0.1
  verTwoPlusAlpha = '%d.%.2d%a';       // 1.0.1.0 => 1.00a

type
  TGpVersionInfo = class
  private
    viVersionSize  : DWORD;
    viVersionInfo  : pointer;
    viFixedFileInfo: PVSFixedFileInfo;
    viFixedFileSize: UINT;
    viLangCharset  : string;
    function QueryValue(key: string): string;
    function GetComment: string;
    function GetProductName: string;
  public
    constructor Create(fileName: string; lang_charset: string = '040904E4');
    destructor  Destroy; override;
    function    GetVersion(formatString: string): string; overload;
    function    GetVersion: int64; overload;
    function    IsDebug: boolean;
    function    IsPrerelease: boolean;
    function    IsSpecialBuild: boolean;
    function    IsPrivateBuild: boolean;
    function    HasVersionInfo: boolean;
    property    Comment: string read GetComment;
    property    ProductName: string read GetProductName;
  end;

  function GetVersion(formatString: string): string; overload;
  function GetVersion: int64; overload;

implementation

uses
  SysUtils;

{ TGpVersionInfo }

constructor TGpVersionInfo.Create(fileName: string; lang_charset: string = '040904E4');
var
  hnd: DWORD;
begin
  inherited Create;
  viLangCharset := lang_charset;
  viVersionSize := GetFileVersionInfoSize(PChar(fileName),hnd);
  if viVersionSize > 0 then begin
    GetMem(viVersionInfo,viVersionSize);
    Win32Check(GetFileVersionInfo(PChar(fileName),0,viVersionSize,viVersionInfo));
    Win32Check(VerQueryValue(viVersionInfo,'\',pointer(viFixedFileInfo),viFixedFileSize));
  end;
end; { TGpVersionInfo.Create }

destructor TGpVersionInfo.Destroy;
begin
  FreeMem(viVersionInfo);
  inherited Destroy;
end; { TGpVersionInfo.Destroy }

function TGpVersionInfo.GetComment: string;
begin
  Result := QueryValue('Comments');
end; { TGpVersionInfo.GetComment }

function TGpVersionInfo.GetProductName: string;
begin
  Result := QueryValue('ProductName');
end; { TGpVersionInfo.GetProductName }

function TGpVersionInfo.GetVersion(formatString: string): string;

  function GetPart(var formatString: string): string;
  var
    i: integer;
  begin
    if formatString[1] <> '%' then Result := formatString[1]
    else begin
      i := 2;
      while (i < Length(formatString)) and (not (UpCase(formatString[i]) in ['A','D','T'])) do Inc(i);
      Result := Copy(formatString,1,i);
    end;
    formatString := Copy(formatString,Length(Result)+1,Length(formatString)-Length(Result));
  end; { GetPart }

  function GetVerPart(part: integer): word;
  begin
    case part of
      1: Result := LongRec(viFixedFileInfo^.dwFileVersionMS).Hi;
      2: Result := LongRec(viFixedFileInfo^.dwFileVersionMS).Lo;
      3: Result := LongRec(viFixedFileInfo^.dwFileVersionLS).Hi;
      4: Result := LongRec(viFixedFileInfo^.dwFileVersionLS).Lo;
      else Result := 0;
    end;
  end; { GetVerPart }

  function VerToAlpha(ver: word): string;
  begin
    if ver > 0 then begin
      if ver <= 26
        then Result := Chr(Ord('a')+ver-1)
        else Result := '?';
    end
    else Result := '';
  end; { VerToAlpha }

var
  part   : string;
  ftype  : char;
  veridx : integer;
  verpart: word;
  truncating    : boolean;
  lastTruncPoint: integer;

  function GetNextPart: word;
  begin
    Inc(veridx);
    verpart := GetVerPart(veridx);
    Result := verpart;
  end; { GetNextPart }

  procedure CheckTruncate;
  begin
    if truncating then
      if verpart > 0 then
        lastTruncPoint := Length(Result);
  end; { CheckTruncate }

begin
  Result := '';
  if not HasVersionInfo then Exit;
  veridx := 0;
  truncating := false;
  while formatString <> '' do begin
    part := GetPart(formatString);
    if part[1] <> '%' then Result := Result + part
    else begin
      ftype := part[Length(part)];
      case ftype of
        'd','D':
          begin
            Result := Result + Format(part,[GetNextPart]);
            CheckTruncate;
          end; //'d','D'
        'a':
          begin
            Result := Result + VerToAlpha(GetNextPart);
            CheckTruncate;
          end; //'a'
        'A':
          begin
            Result := Result + UpperCase(VerToAlpha(GetNextPart));
            CheckTruncate;
          end; //'A'
        't','T':
          begin
            lastTruncPoint := Length(Result);
            truncating := true;
          end; //'t','T'
        else Result := Result + part;
      end; //case
    end; //if
  end; //while
  if truncating then Result := Copy(Result,1,lastTruncPoint);
end; { TGpVersionInfo.GetVersion }

function TGpVersionInfo.GetVersion: int64;
var
  tmp: int64;
begin
  tmp := 0;
  if not HasVersionInfo then Exit;
  Int64Rec(tmp).Lo := viFixedFileInfo^.dwFileVersionLS;
  Int64Rec(tmp).Hi := viFixedFileInfo^.dwFileVersionMS;
  Result := tmp;
end; { TGpVersionInfo.GetVersion }

function TGpVersionInfo.HasVersionInfo: boolean;
begin
  Result := (viVersionSize > 0);
end; { TGpVersionInfo.HasVersionInfo }

function TGpVersionInfo.IsDebug: boolean;
begin
  with viFixedFileInfo^ do
    Result := ((VS_FF_DEBUG AND dwFileFlagsMask) <> 0) and
              ((VS_FF_DEBUG AND dwFileFlags) <> 0);
end; { TGpVersionInfo.IsDebug }

function TGpVersionInfo.IsPrerelease: boolean;
begin
  with viFixedFileInfo^ do
    Result := ((VS_FF_PRERELEASE AND dwFileFlagsMask) <> 0) and
              ((VS_FF_PRERELEASE AND dwFileFlags) <> 0);
end; { TGpVersionInfo.IsPrerelease }

function TGpVersionInfo.IsPrivateBuild: boolean;
begin
  with viFixedFileInfo^ do
    Result := ((VS_FF_PRIVATEBUILD AND dwFileFlagsMask) <> 0) and
              ((VS_FF_PRIVATEBUILD AND dwFileFlags) <> 0);
end; { TGpVersionInfo.IsPrivateBuild }

function TGpVersionInfo.IsSpecialBuild: boolean;
begin
  with viFixedFileInfo^ do
    Result := ((VS_FF_SPECIALBUILD AND dwFileFlagsMask) <> 0) and
              ((VS_FF_SPECIALBUILD AND dwFileFlags) <> 0);
end; { TGpVersionInfo.IsSpecialBuild }

function TGpVersionInfo.QueryValue(key: string): string;
var
  p   : PChar;
  clen: DWORD;
begin
  if VerQueryValue(viVersionInfo,PChar('\StringFileInfo\'+viLangCharset+'\'+key),pointer(p),clen)
    then Result := p
    else Result := '';
end; { TGpVersionInfo.QueryValue }

function GetVersion(formatString: string): string;
var
  ver: TGpVersionInfo;
begin
  ver := TGpVersionInfo.Create(ParamStr(0));
  try Result := ver.GetVersion(formatString);
  finally ver.Free; end;
end; { GetVersion }

function GetVersion: int64; overload;
var
  ver: TGpVersionInfo;
begin
  ver := TGpVersionInfo.Create(ParamStr(0));
  try Result := ver.GetVersion;
  finally ver.Free; end;
end; { GetVersion }

end.
