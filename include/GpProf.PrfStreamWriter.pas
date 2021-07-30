{$R-,C-,Q-,O+,H+}
unit GpProf.PrfStreamWriter;

interface

{$WARN SYMBOL_PLATFORM OFF}
{$WARN SYMBOL_DEPRECATED OFF}


uses
  GpProf.PrfTypes, GpProf.PrfConfig;

type
  TPrfStreamWriter = class
  private
    fPrfConfig : TPrfConfig;
    prfFile : THandle;
    prfBuf : pointer;
    prfBufOffs : integer;
    prfLastTick    : Comp;

    procedure FlushFile;
    function OffsetPtr(const ptr: pointer; const offset: Cardinal): pointer;
  public
    constructor Create(const aConfig : TPrfConfig;const prfName : string);
    destructor Destroy; override;

    procedure WriteInt   (const int: integer);
    procedure WriteCardinal   (const value: Cardinal);
    procedure WriteTag   (const tag: byte);
    procedure WriteID    (const id: integer);
    procedure WriteBool  (const bool: boolean);
    procedure WriteAnsiString  (const value: ansistring);
    procedure WriteTicks(const ticks: Comp);
    procedure WriteThread(const prfThreads : TThreadList;const thread: integer);
    procedure WriteBuffer(const buf; count: Cardinal);

    procedure WriteEnterProc(const prfThreads : TThreadList;const aThreadId, aProcId: integer; const aTick: Comp);
    procedure WriteExitProc(const prfThreads : TThreadList;const aThreadId, aProcId: integer; const aTick: Comp);

  end;

implementation

uses
  System.SysUtils, Winapi.Windows, GpProfH;

const
  BUF_SIZE = 64 * 1024; //64*1024;

constructor TPrfStreamWriter.Create(const aConfig : TPrfConfig;const prfName : string);
begin
  inherited Create();
  fPrfConfig := aConfig;
  prfLastTick         := -1;
  prfBuf              := VirtualAlloc(nil, BUF_SIZE, MEM_RESERVE + MEM_COMMIT, PAGE_READWRITE);
  prfBufOffs          := 0;
  Win32Check(VirtualLock(prfBuf, BUF_SIZE));
  Win32Check(prfBuf <> nil);
  FillChar(prfBuf^, BUF_SIZE, 0);
  prfFile := CreateFile(PChar(prfName), GENERIC_WRITE, 0, nil, CREATE_ALWAYS,
                        FILE_ATTRIBUTE_NORMAL + FILE_FLAG_WRITE_THROUGH +
                        FILE_FLAG_NO_BUFFERING, 0);
  Win32Check(prfFile <> INVALID_HANDLE_VALUE);

end;

destructor TPrfStreamWriter.Destroy;
begin
  FlushFile;
  Win32Check(CloseHandle(prfFile));
  Win32Check(VirtualUnlock(prfBuf, BUF_SIZE));
  Win32Check(VirtualFree(prfBuf, 0, MEM_RELEASE));
  inherited;
end;

procedure TPrfStreamWriter.WriteInt(const int: integer);
begin
  WriteBuffer(int, SizeOf(integer));
end;

procedure TPrfStreamWriter.WriteCardinal(const value: Cardinal);
begin
  WriteBuffer(value, SizeOf(Cardinal));
end;

procedure TPrfStreamWriter.WriteEnterProc(const prfThreads : TThreadList;const aThreadId, aProcId: integer; const aTick: Comp);
begin
 WriteTag(PR_ENTERPROC);
 WriteThread(prfThreads, aThreadId);
 WriteID(aProcId);
 WriteTicks(aTick);
end;

procedure TPrfStreamWriter.WriteExitProc(const prfThreads : TThreadList;const aThreadId, aProcId: integer; const aTick: Comp);
begin
 WriteTag(PR_EXITPROC);
 WriteThread(prfThreads, aThreadId);
 WriteID(aProcId);
 WriteTicks(aTick);
end;

procedure TPrfStreamWriter.WriteTag(const tag: byte);
begin
  WriteBuffer(tag, SizeOf(byte));
end;

procedure TPrfStreamWriter.WriteID(const id: integer);
begin
  WriteBuffer(id, fPrfConfig.profProcSize);
end;

procedure TPrfStreamWriter.WriteBool(const bool: boolean);
begin
  WriteBuffer(bool, 1);
end;

procedure TPrfStreamWriter.WriteAnsiString(const value: ansistring);
begin
  WriteCardinal(Length(value));
  if Length(Value)>0 then
    WriteBuffer(value[1], Length(value));
end;


procedure TPrfStreamWriter.FlushFile;
var
  written: Cardinal;
begin
  Win32Check(WriteFile(prfFile, prfBuf^, BUF_SIZE, written, nil));
  prfBufOffs := 0;
  FillChar(prfBuf^, BUF_SIZE, 0);
end; { FlushFile }

function TPrfStreamWriter.OffsetPtr(const ptr: pointer; const offset: Cardinal): pointer;
begin
  Result := pointer(Cardinal(ptr)+offset);
end; { OffsetPtr }

procedure TPrfStreamWriter.WriteBuffer(const buf; count: Cardinal);
var
  res    : boolean;
  place  : Cardinal;
  bufp   : pointer;
  written: Cardinal;
begin
  place := BUF_SIZE-prfBufOffs;
  if place <= count then begin
    Move(buf,OffsetPtr(prfBuf,prfBufOffs)^,place); // fill the buffer
    prfBufOffs := BUF_SIZE;
    FlushFile;
    Dec(count,place);
    bufp := OffsetPtr(@buf,place);
    while count >= BUF_SIZE do begin
      Move(bufp^,prfBuf^,BUF_SIZE);
      res := WriteFile(prfFile,prfBuf^,BUF_SIZE,written,nil);
      if not res then RaiseLastWin32Error;
      Dec(count,BUF_SIZE);
      bufp := OffsetPtr(bufp,BUF_SIZE);
    end; //while
  end
  else bufp := @buf;
  if count > 0 then begin // store leftovers
    Move(bufp^,OffsetPtr(prfBuf,prfBufOffs)^,count);
    Inc(prfBufOffs,count);
  end;
end; { WriteBuffer }


procedure TPrfStreamWriter.WriteTicks(const ticks: Comp);
type
  TTick = array [1..8] of Byte;
var
  diff: integer;
begin
  if not fPrfConfig.profCompressTicks then
    WriteBuffer(ticks, Sizeof(Comp))
  else begin
    if prfLastTick = -1 then
      diff := 8
    else begin
      diff := 8;
      while (diff > 0) and (TTick(ticks)[diff] = TTick(prfLastTick)[diff]) do
        Dec(diff);
      Inc(diff);
    end;
    WriteBuffer(diff, 1);
    WriteBuffer(ticks, diff);
    prfLastTick := ticks;
  end;
end; { WriteTicks }

procedure TPrfStreamWriter.WriteThread(const prfThreads : TThreadList;const thread: integer);
const
  marker: integer = 0;
var
  remap: integer;
begin
  if not fPrfConfig.profCompressThreads then
    WriteBuffer(thread, Sizeof(integer))
  else begin
    remap := prfThreads.Remap(thread);
    if prfThreads.Count >= fPrfConfig.prfMaxThreadNum then
    begin
      WriteBuffer(marker, fPrfConfig.prfThreadBytes);
      fPrfConfig.prfMaxThreadNum := 2 * fPrfConfig.prfMaxThreadNum;
      fPrfConfig.prfThreadBytes := fPrfConfig.prfThreadBytes + 1;
    end;
    WriteBuffer(remap, fPrfConfig.prfThreadBytes);
  end;
end; { WriteThread }

end.
