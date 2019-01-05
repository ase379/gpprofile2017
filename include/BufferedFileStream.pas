unit BufferedFileStream;

interface

uses
  SysUtils, Math, Classes, Windows;

type
  TBaseCachedFileStream = class(TStream)
  private
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  protected
    FHandle: THandle;
    FOwnsHandle: Boolean;
    FCache: PByte;
    FCacheSize: Integer;
    FPosition: Int64;//the current position in the file (relative to the beginning of the file)
    FCacheStart: Int64;//the postion in the file of the start of the cache (relative to the beginning of the file)
    FCacheEnd: Int64;//the postion in the file of the end of the cache (relative to the beginning of the file)
    FFileName: string;
    FLastError: DWORD;
    procedure HandleError(const Msg: string);
    procedure RaiseSystemError(const Msg: string; LastError: DWORD); overload;
    procedure RaiseSystemError(const Msg: string); overload;
    procedure RaiseSystemErrorFmt(const Msg: string; const Args: array of const);
    function CreateHandle(FlagsAndAttributes: DWORD): THandle; virtual; abstract;
    function GetFileSize: Int64; virtual;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
    function FileRead(var Buffer; Count: Longword): Integer;
    function FileWrite(const Buffer; Count: Longword): Integer;
    function FileSeek(const Offset: Int64; Origin: TSeekOrigin): Int64;
  public
    constructor Create(const FileName: string); overload;
    constructor Create(const FileName: string; CacheSize: Integer); overload;
    constructor Create(const FileName: string; CacheSize: Integer; Handle: THandle); overload; virtual;
    destructor Destroy; override;
    property CacheSize: Integer read FCacheSize;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
  end;
  TBaseCachedFileStreamClass = class of TBaseCachedFileStream;

  IDisableStreamReadCache = interface
    ['{0B6D0004-88D1-42D5-BC0F-447911C0FC21}']
    procedure DisableStreamReadCache;
    procedure EnableStreamReadCache;
  end;

  TReadOnlyCachedFileStream = class(TBaseCachedFileStream, IDisableStreamReadCache)
  (* This class works by filling the cache each time a call to Read is made and
     FPosition is outside the existing cache.  By filling the cache we mean
     reading from the file into the temporary cache.  Calls to Read when
     FPosition is in the existing cache are then dealt with by filling the
     buffer with bytes from the cache.
  *)
  private
    FUseAlignedCache: Boolean;
    FViewStart: Int64;
    FViewLength: Int64;
    FDisableStreamReadCacheRefCount: Integer;
    procedure DisableStreamReadCache;
    procedure EnableStreamReadCache;
    procedure FlushCache;
  protected
    function CreateHandle(FlagsAndAttributes: DWORD): THandle; override;
    function GetFileSize: Int64; override;
  public
    constructor Create(const FileName: string; CacheSize: Integer; Handle: THandle); overload; override;
    property UseAlignedCache: Boolean read FUseAlignedCache write FUseAlignedCache;
    function Read(var Buffer; Count: Longint): Longint; override;
    procedure SetViewWindow(const ViewStart, ViewLength: Int64);
  end;

  TWriteCachedFileStream = class(TBaseCachedFileStream, IDisableStreamReadCache)
  (* This class works by caching calls to Write.  By this we mean temporarily
     storing the bytes to be written in the cache.  As each call to Write is
     processed the cache grows.  The cache is written to file when:
       1.  A call to Write is made when the cache is full.
       2.  A call to Write is made and FPosition is outside the cache (this
           must be as a result of a call to Seek).
       3.  The class is destroyed.

     Note that data can be read from these streams but the reading is not
     cached and in fact a read operation will flush the cache before
     attempting to read the data.
  *)
  private
    FFileSize: Int64;
    FReadStream: TReadOnlyCachedFileStream;
    FReadStreamCacheSize: Integer;
    FReadStreamUseAlignedCache: Boolean;
    procedure DisableStreamReadCache;
    procedure EnableStreamReadCache;
    procedure CreateReadStream;
    procedure FlushCache;
  protected
    function CreateHandle(FlagsAndAttributes: DWORD): THandle; override;
    function GetFileSize: Int64; override;
  public
    constructor Create(const FileName: string; CacheSize, ReadStreamCacheSize: Integer; ReadStreamUseAlignedCache: Boolean); overload;
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

implementation

function GetFileSizeEx(hFile: THandle; var FileSize: Int64): BOOL; stdcall; external kernel32;
function SetFilePointerEx(hFile: THandle; DistanceToMove: Int64; lpNewFilePointer: PInt64; dwMoveMethod: DWORD): BOOL; stdcall; external kernel32;

{ TBaseCachedFileStream }

constructor TBaseCachedFileStream.Create(const FileName: string);
begin
  Create(FileName, 0);
end;

constructor TBaseCachedFileStream.Create(const FileName: string; CacheSize: Integer);
begin
  Create(FileName, CacheSize, 0);
end;

constructor TBaseCachedFileStream.Create(const FileName: string; CacheSize: Integer; Handle: THandle);
const
  DefaultCacheSize = 16*1024;
  //16kb - this was chosen empirically - don't make it too large otherwise the progress report is 'jerky'
begin
  inherited Create;
  FFileName := FileName;
  FOwnsHandle := Handle=0;
  if FOwnsHandle then begin
    FHandle := CreateHandle(FILE_ATTRIBUTE_NORMAL);
  end else begin
    FHandle := Handle;
  end;
  FCacheSize := CacheSize;
  if FCacheSize<=0 then begin
    FCacheSize := DefaultCacheSize;
  end;
  GetMem(FCache, FCacheSize);
end;

destructor TBaseCachedFileStream.Destroy;
begin
  FreeMem(FCache);
  if FOwnsHandle and (FHandle<>0) then begin
    CloseHandle(FHandle);
  end;
  inherited;
end;

function TBaseCachedFileStream.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then begin
    Result := S_OK;
  end else begin
    Result := E_NOINTERFACE;
  end;
end;

function TBaseCachedFileStream._AddRef: Integer;
begin
  Result := -1;
end;

function TBaseCachedFileStream._Release: Integer;
begin
  Result := -1;
end;

procedure TBaseCachedFileStream.HandleError(const Msg: string);
begin
  if FLastError<>0 then begin
    RaiseSystemError(Msg, FLastError);
  end;
end;

procedure TBaseCachedFileStream.RaiseSystemError(const Msg: string; LastError: DWORD);
begin
  raise EStreamError.Create(Trim(Msg+'  ')+SysErrorMessage(LastError));
end;

procedure TBaseCachedFileStream.RaiseSystemError(const Msg: string);
begin
  RaiseSystemError(Msg, GetLastError);
end;

procedure TBaseCachedFileStream.RaiseSystemErrorFmt(const Msg: string; const Args: array of const);
begin
  RaiseSystemError(Format(Msg, Args));
end;

function TBaseCachedFileStream.GetFileSize: Int64;
begin
  if not GetFileSizeEx(FHandle, Result) then begin
    RaiseSystemErrorFmt('GetFileSizeEx failed for %s.', [FFileName]);
  end;
end;

procedure TBaseCachedFileStream.SetSize(NewSize: Longint);
begin
  SetSize(Int64(NewSize));
end;

procedure TBaseCachedFileStream.SetSize(const NewSize: Int64);
begin
  Seek(NewSize, soBeginning);
  if not Windows.SetEndOfFile(FHandle) then begin
    RaiseSystemErrorFmt('SetEndOfFile for %s.', [FFileName]);
  end;
end;

function TBaseCachedFileStream.FileRead(var Buffer; Count: Longword): Integer;
begin
  if Windows.ReadFile(FHandle, Buffer, Count, LongWord(Result), nil) then begin
    FLastError := 0;
  end else begin
    FLastError := GetLastError;
    Result := -1;
  end;
end;

function TBaseCachedFileStream.FileWrite(const Buffer; Count: Longword): Integer;
begin
  if Windows.WriteFile(FHandle, Buffer, Count, LongWord(Result), nil) then begin
    FLastError := 0;
  end else begin
    FLastError := GetLastError;
    Result := -1;
  end;
end;

function TBaseCachedFileStream.FileSeek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  if not SetFilePointerEx(FHandle, Offset, @Result, ord(Origin)) then begin
    RaiseSystemErrorFmt('SetFilePointerEx failed for %s.', [FFileName]);
  end;
end;

function TBaseCachedFileStream.Read(var Buffer; Count: Integer): Longint;
begin
  raise EAssertionFailed.Create('Cannot read from this stream');
end;

function TBaseCachedFileStream.Write(const Buffer; Count: Integer): Longint;
begin
  raise EAssertionFailed.Create('Cannot write to this stream');
end;

function TBaseCachedFileStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
//Set FPosition to the value specified - if this has implications for the
//cache then overriden Write and Read methods must deal with those.
begin
  case Origin of
  soBeginning:
    FPosition := Offset;
  soEnd:
    FPosition := GetFileSize+Offset;
  soCurrent:
    inc(FPosition, Offset);
  end;
  Result := FPosition;
end;

{ TReadOnlyCachedFileStream }

constructor TReadOnlyCachedFileStream.Create(const FileName: string; CacheSize: Integer; Handle: THandle);
begin
  inherited;
  SetViewWindow(0, inherited GetFileSize);
end;

function TReadOnlyCachedFileStream.CreateHandle(FlagsAndAttributes: DWORD): THandle;
begin
  Result := Windows.CreateFile(
    PChar(FFileName),
    GENERIC_READ,
    FILE_SHARE_READ,
    nil,
    OPEN_EXISTING,
    FlagsAndAttributes,
    0
  );
  if Result=INVALID_HANDLE_VALUE then begin
    RaiseSystemErrorFmt('Cannot open %s.', [FFileName]);
  end;
end;

procedure TReadOnlyCachedFileStream.DisableStreamReadCache;
begin
  inc(FDisableStreamReadCacheRefCount);
end;

procedure TReadOnlyCachedFileStream.EnableStreamReadCache;
begin
  dec(FDisableStreamReadCacheRefCount);
end;

procedure TReadOnlyCachedFileStream.FlushCache;
begin
  FCacheStart := 0;
  FCacheEnd := 0;
end;

function TReadOnlyCachedFileStream.GetFileSize: Int64;
begin
  Result := FViewLength;
end;

procedure TReadOnlyCachedFileStream.SetViewWindow(const ViewStart, ViewLength: Int64);
begin
  if ViewStart<0 then begin
    raise EAssertionFailed.Create('Invalid view window');
  end;
  if (ViewStart+ViewLength)>inherited GetFileSize then begin
    raise EAssertionFailed.Create('Invalid view window');
  end;
  FViewStart := ViewStart;
  FViewLength := ViewLength;
  FPosition := 0;
  FCacheStart := 0;
  FCacheEnd := 0;
end;

function TReadOnlyCachedFileStream.Read(var Buffer; Count: Longint): Longint;
var
  NumOfBytesToCopy, NumOfBytesLeft, NumOfBytesRead: Longint;
  CachePtr, BufferPtr: PByte;
begin
  if FDisableStreamReadCacheRefCount>0 then begin
    FileSeek(FPosition+FViewStart, soBeginning);
    Result := FileRead(Buffer, Count);
    if Result=-1 then begin
      Result := 0;//contract is to return number of bytes that were read
    end;
    inc(FPosition, Result);
  end else begin
    Result := 0;
    NumOfBytesLeft := Count;
    BufferPtr := @Buffer;
    while NumOfBytesLeft>0 do begin
      if (FPosition<FCacheStart) or (FPosition>=FCacheEnd) then begin
        //the current position is not available in the cache so we need to re-fill the cache
        FCacheStart := FPosition;
        if UseAlignedCache then begin
          FCacheStart := FCacheStart - (FCacheStart mod CacheSize);
        end;
        FileSeek(FCacheStart+FViewStart, soBeginning);
        NumOfBytesRead := FileRead(FCache^, CacheSize);
        if NumOfBytesRead=-1 then begin
          exit;
        end;
        Assert(NumOfBytesRead>=0);
        FCacheEnd := FCacheStart+NumOfBytesRead;
        if NumOfBytesRead=0 then begin
          FLastError := ERROR_HANDLE_EOF;//must be at the end of the file
          break;
        end;
      end;

      //read from cache to Buffer
      NumOfBytesToCopy := Min(FCacheEnd-FPosition, NumOfBytesLeft);
      CachePtr := FCache;
      inc(CachePtr, FPosition-FCacheStart);
      Move(CachePtr^, BufferPtr^, NumOfBytesToCopy);
      inc(Result, NumOfBytesToCopy);
      inc(FPosition, NumOfBytesToCopy);
      inc(BufferPtr, NumOfBytesToCopy);
      dec(NumOfBytesLeft, NumOfBytesToCopy);
    end;
  end;
end;

{ TWriteCachedFileStream }

constructor TWriteCachedFileStream.Create(const FileName: string; CacheSize, ReadStreamCacheSize: Integer; ReadStreamUseAlignedCache: Boolean);
begin
  inherited Create(FileName, CacheSize);
  FReadStreamCacheSize := ReadStreamCacheSize;
  FReadStreamUseAlignedCache := ReadStreamUseAlignedCache;
end;

destructor TWriteCachedFileStream.Destroy;
begin
  FlushCache;//make sure that the final calls to Write get recorded in the file
  FreeAndNil(FReadStream);
  inherited;
end;

function TWriteCachedFileStream.CreateHandle(FlagsAndAttributes: DWORD): THandle;
begin
  Result := Windows.CreateFile(
    PChar(FFileName),
    GENERIC_READ or GENERIC_WRITE,
    0,
    nil,
    CREATE_ALWAYS,
    FlagsAndAttributes,
    0
  );
  if Result=INVALID_HANDLE_VALUE then begin
    RaiseSystemErrorFmt('Cannot create %s.', [FFileName]);
  end;
end;

procedure TWriteCachedFileStream.DisableStreamReadCache;
begin
  CreateReadStream;
  FReadStream.DisableStreamReadCache;
end;

procedure TWriteCachedFileStream.EnableStreamReadCache;
begin
  Assert(Assigned(FReadStream));
  FReadStream.EnableStreamReadCache;
end;

function TWriteCachedFileStream.GetFileSize: Int64;
begin
  Result := FFileSize;
end;

procedure TWriteCachedFileStream.CreateReadStream;
begin
  if not Assigned(FReadStream) then begin
    FReadStream := TReadOnlyCachedFileStream.Create(FFileName, FReadStreamCacheSize, FHandle);
    FReadStream.UseAlignedCache := FReadStreamUseAlignedCache;
  end;
end;

procedure TWriteCachedFileStream.FlushCache;
var
  NumOfBytesToWrite: Longint;
begin
  if Assigned(FCache) then begin
    NumOfBytesToWrite := FCacheEnd-FCacheStart;
    if NumOfBytesToWrite>0 then begin
      FileSeek(FCacheStart, soBeginning);
      if FileWrite(FCache^, NumOfBytesToWrite)<>NumOfBytesToWrite then begin
        RaiseSystemErrorFmt('FileWrite failed for %s.', [FFileName]);
      end;
      if Assigned(FReadStream) then begin
        FReadStream.FlushCache;
      end;
    end;
    FCacheStart := FPosition;
    FCacheEnd := FPosition;
  end;
end;

function TWriteCachedFileStream.Read(var Buffer; Count: Integer): Longint;
begin
  FlushCache;
  CreateReadStream;
  Assert(FReadStream.FViewStart=0);
  if FReadStream.FViewLength<>FFileSize then begin
    FReadStream.SetViewWindow(0, FFileSize);
  end;
  FReadStream.Position := FPosition;
  Result := FReadStream.Read(Buffer, Count);
  inc(FPosition, Result);
end;

function TWriteCachedFileStream.Write(const Buffer; Count: Longint): Longint;
var
  NumOfBytesToCopy, NumOfBytesLeft: Longint;
  CachePtr, BufferPtr: PByte;
begin
  Result := 0;
  NumOfBytesLeft := Count;
  BufferPtr := @Buffer;
  while NumOfBytesLeft>0 do begin
    if ((FPosition<FCacheStart) or (FPosition>FCacheEnd))//the current position is outside the cache
    or (FPosition-FCacheStart=FCacheSize)//the cache is full
    then begin
      FlushCache;
      Assert(FCacheStart=FPosition);
    end;

    //write from Buffer to the cache
    NumOfBytesToCopy := Min(FCacheSize-(FPosition-FCacheStart), NumOfBytesLeft);
    CachePtr := FCache;
    inc(CachePtr, FPosition-FCacheStart);
    Move(BufferPtr^, CachePtr^, NumOfBytesToCopy);
    inc(Result, NumOfBytesToCopy);
    inc(FPosition, NumOfBytesToCopy);
    FCacheEnd := Max(FCacheEnd, FPosition);
    inc(BufferPtr, NumOfBytesToCopy);
    dec(NumOfBytesLeft, NumOfBytesToCopy);
  end;
  FFileSize := Max(FFileSize, FPosition);
end;

end.
