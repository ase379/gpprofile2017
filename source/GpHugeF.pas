{$I OPTIONS.INC}

unit GPHugeF;

(*
Interface to 64-bit file functions with some added functionality.
Written by Primoz Gabrijelcic. Free for personal and commercial use. No rights
reserved. May be freely modified and abused.

Tested with Delphi 3 & Delphi 4.

Program history

  2.22: 1999-06-14
    - better error reporting
  2.21: 21.12.1998
    - better error checking
  2.2: 14.12.1998
    - new function IsOpen
    - lots of SetLastError(0) calls added
  2.12: 28.10.1998
    - CreateEx enhanced
  2.11: 14.10.1998
    - error reporting in Block*Unsafe enhanced
  2.1: 13.10.1998
    - FilePos works in buffered mode
    - faster FilePos in unbuffered mode
    - Seek works in read buffered mode
      - in FILE_FLAG_NO_BUFFERING mode Seek works only when offset is on a
        sector boundary
      - Truncate works in read buffered mode (untested)
      - Dependance on MSString removed
  2.0: 8.10.1998
    - Win32 API error checking
    - sequential access buffering (ResetBuffered, RewriteBuffered)
    - buffered files can be safely accessed in FILE_FLAG_NO_BUFFERING mode
    - new procedures BlockReadUnsafe, BlockWriteUnsafe
  1.1: 5.10.1998
    - CreateEx constructor added
      - can specify attributes (for example FILE_FLAG_SEQUENTIAL_SCAN)
    - D4 compatible
  1.0: 15.9.1998
    - first published version
*)

interface

uses
  Windows;

type
  HugeInt = LONGLONG;

  TGpHugeFile = class
  private
    hfBlockSize  : DWORD;
    hfHandle     : THandle;
    hfName       : string;
    hfFlags      : DWORD;
    hfBuffered   : boolean;
    hfBufferSize : DWORD;
    hfLockBuffer : boolean;
    hfBuffer     : pointer;
    hfFlagNoBuf  : boolean;
    hfBufOffs    : DWORD;
    hfBufSize    : DWORD;
    hfBufFileOffs: HugeInt;
    hfBufFilePos : HugeInt;
    hfBufWrite   : boolean;
    hfDesiredAcc : DWORD;
    procedure Win32Check(condition: boolean; method: string);
    procedure CheckHandle;
    procedure AccessFile(blockSize: integer; reset: boolean);
    procedure AllocBuffer;
    procedure FreeBuffer;
    function  FlushBuffer: boolean;
    procedure Transmit(const buf; count: DWORD; var transferred: DWORD);
    procedure Fetch(var buf; count: DWORD; var transferred: DWORD);
    function  RoundToPageSize(bufSize: DWORD): DWORD;
    procedure _Seek(offset: HugeInt; movePointer: boolean);
  public
    constructor Create(fileName: string);
    constructor CreateEx(fileName: string;
                         FlagsAndAttributes: DWORD = FILE_ATTRIBUTE_NORMAL;
                         DesiredAccess: DWORD = GENERIC_READ+GENERIC_WRITE);
    procedure   Reset(blockSize: integer = 1);
    procedure   Rewrite(blockSize: integer = 1);
    procedure   ResetBuffered(blockSize: integer = 1; bufferSize: integer = 0; lockBuffer: boolean = false);
    procedure   RewriteBuffered(blockSize: integer = 1; bufferSize: integer = 0; lockBuffer: boolean = false);
    destructor  Destroy; override;
    function    FileExists: boolean;
    procedure   Close;
    function    FileSize: HugeInt;
    procedure   BlockWrite(const buf; count: DWORD; var transferred: DWORD);
    procedure   BlockRead(var buf; count: DWORD; var transferred: DWORD);
    procedure   BlockWriteUnsafe(const buf; count: DWORD);
    procedure   BlockReadUnsafe(var buf; count: DWORD);
    procedure   Seek(offset: HugeInt);
    function    FilePos: HugeInt;
    procedure   Truncate;
    procedure   Flush;
    function    IsOpen: boolean;
    property    FileName: string read hfName;
  end;

implementation

uses
  SysConst,
  SysUtils;

const
  BUF_SIZE = 64*1024; // 64 KB, small enough to be VirtualLock'd in NT 4

  constructor TGpHugeFile.CreateEx(fileName: string; FlagsAndAttributes, DesiredAccess: DWORD);
  begin
    hfName      := fileName;
    hfBlockSize := 1;
    hfHandle    := INVALID_HANDLE_VALUE;
    hfFlags     := FlagsAndAttributes;
    hfBuffered  := false;
    hfBuffer    := nil;
    hfDesiredAcc:= DesiredAccess;
    hfFlagNoBuf := ((FILE_FLAG_NO_BUFFERING AND FlagsAndAttributes) <> 0);
  end; { TGpHugeFile.CreateEx }

  constructor TGpHugeFile.Create(fileName: string);
  begin
    CreateEx(fileName,FILE_ATTRIBUTE_NORMAL,GENERIC_READ+GENERIC_WRITE);
  end; { TGpHugeFile.Create }

  destructor TGpHugeFile.Destroy;
  begin
    Close;
  end; { TGpHugeFile.Destroy }

  function TGpHugeFile.FileExists: boolean;
  begin
    FileExists := SysUtils.FileExists(hfName);
  end; { TGpHugeFile.FileExists }

  procedure TGpHugeFile.AccessFile(blockSize: integer; reset: boolean);
  var
    creat: DWORD;
  begin
    if blockSize <= 0 then raise Exception.Create('TGpHugeFile: BlockSize must be greater than zero!');
    hfBlockSize := blockSize;
    AllocBuffer;
    if reset then creat := OPEN_ALWAYS else creat := CREATE_ALWAYS;
    SetLastError(0);
    hfHandle := CreateFile(PChar(hfName),hfDesiredAcc,0,
                           nil,creat,hfFlags,0);
    Win32Check(hfHandle<>INVALID_HANDLE_VALUE,'AccessFile');
  end; { TGpHugeFile.AccessFile }

  procedure TGpHugeFile.Reset(blockSize: integer);
  begin
    Close;
    hfBuffered := false;
    AccessFile(blockSize,true);
    hfBufFilePos := 0;
  end; { TGpHugeFile.Reset }

  procedure TGpHugeFile.Rewrite(blockSize: integer);
  begin
    Close;
    hfBuffered := false;
    AccessFile(blockSize,false);
    hfBufFilePos := 0;
  end; { TGpHugeFile.Rewrite }

  procedure TGpHugeFile.ResetBuffered(blockSize, bufferSize: integer; lockBuffer: boolean);
  begin
    Close;
    hfBuffered   := true;
    hfBufferSize := bufferSize;
    hfLockBuffer := lockBuffer;
    AccessFile(blockSize,true);
    hfBufOffs     := 0;
    hfBufSize     := 0;
    hfBufFileOffs := 0;
    hfBufFilePos  := 0;
    hfBufWrite    := false;
  end; { TGpHugeFile.ResetBuffered }

  procedure TGpHugeFile.RewriteBuffered(blockSize, bufferSize: integer; lockBuffer: boolean);
  begin
    Close;
    hfBuffered   := true;
    hfBufferSize := bufferSize;
    hfLockBuffer := lockBuffer;
    AccessFile(blockSize,false);
    hfBufOffs     := 0;
    hfBufFileOffs := 0;
    hfBufFilePos  := 0;
    hfBufWrite    := true;
  end; { TGpHugeFile.RewriteBuffered }

  procedure TGpHugeFile.Close;
  begin
    if hfHandle <> INVALID_HANDLE_VALUE then begin
      FreeBuffer;
      CloseHandle(hfHandle);
      hfHandle := INVALID_HANDLE_VALUE;
    end;
  end; { TGpHugeFile.Close }

  procedure TGpHugeFile.CheckHandle;
  begin
    if hfHandle = INVALID_HANDLE_VALUE then raise Exception.Create('TGpHugeFile: File not open!');
  end; { TGpHugeFile.CheckHandle }

  function TGpHugeFile.FileSize: HugeInt;
  var
    size: LARGE_INTEGER;
  begin
    CheckHandle;
    SetLastError(0);
    size.LowPart := GetFileSize(hfHandle,@size.HighPart);
    Win32Check(size.LowPart<>$FFFFFFFF,'FileSize');
    if hfBlockSize <> 1
      then Result := Trunc(size.QuadPart/hfBlockSize)
      else Result := size.QuadPart;
  end; { TGpHugeFile.FileSize }

  procedure TGpHugeFile.BlockWrite(const buf; count: DWORD; var transferred: DWORD);
  var
    trans: DWORD;
  begin
    CheckHandle;
    if hfBlockSize <> 1 then count := count * hfBlockSize;
    if hfBuffered then Transmit(buf,count,trans)
    else begin
      SetLastError(0);
      Win32Check(WriteFile(hfHandle,buf,count,trans,nil),'BlockWrite');
      hfBufFilePos := hfBufFilePos + trans;
    end;
    if hfBlockSize <> 1 then transferred := trans div hfBlockSize
                        else transferred := trans;
  end; { TGpHugeFile.BlockWrite }

  procedure TGpHugeFile.BlockRead(var buf; count: DWORD; var transferred: DWORD);
  var
    trans: DWORD;
  begin
    CheckHandle;
    if hfBlockSize <> 1 then count := count * hfBlockSize;
    if hfBuffered then Fetch(buf,count,trans)
    else begin
      SetLastError(0);
      Win32Check(ReadFile(hfHandle,buf,count,trans,nil),'BlockRead');
      hfBufFilePos := hfBufFilePos + trans;
    end;
    if hfBlockSize <> 1 then transferred := trans div hfBlockSize
                        else transferred := trans;
  end; { TGpHugeFile.BlockRead }

  procedure TGpHugeFile._Seek(offset: HugeInt; movePointer: boolean);
  var
    off: LARGE_INTEGER;
  begin
    CheckHandle;
    if hfBlockSize <> 1 then off.QuadPart := offset*hfBlockSize
                        else off.QuadPart := offset;
    if hfBuffered then begin
      if hfBufWrite then raise Exception.Create('TGpHugeFile: Seek in buffered write mode!')
      else begin
        if not movePointer then begin
          if (off.QuadPart >= hfBufFileOffs) or
             (off.QuadPart < (hfBufFileOffs-hfBufSize)) then movePointer := true
          else hfBufOffs := off.QuadPart-(hfBufFileOffs-hfBufSize);
        end;
        if movePointer then begin
          SetLastError(0);
          Win32Check(SetFilePointer(hfHandle,off.LowPart,@off.HighPart,FILE_BEGIN)<>$FFFFFFFF,'Seek');
          hfBufFileOffs := off.QuadPart;
          hfBufFilePos  := off.QuadPart;
          hfBufOffs     := 0;
          hfBufSize     := 0;
        end;
      end;
    end
    else begin
      SetLastError(0);
      Win32Check(SetFilePointer(hfHandle,off.LowPart,@off.HighPart,FILE_BEGIN)<>$FFFFFFFF,'Seek');
    end;
    hfBufFilePos := off.QuadPart;
  end; { TGpHugeFile._Seek }

  procedure TGpHugeFile.Seek(offset: HugeInt);
  begin
    _Seek(offset,false);
  end; { TGpHugeFile.Seek }

  procedure TGpHugeFile.Truncate;
  begin
    CheckHandle;
    if hfBuffered then _Seek(FilePos,true);
    SetLastError(0);
    Win32Check(SetEndOfFile(hfHandle),'Truncate');
  end; { TGpHugeFile.Truncate }

  function TGpHugeFile.FilePos: HugeInt;
  begin
    CheckHandle;
    if hfBlockSize <> 1
      then Result := Trunc(hfBufFilePos/hfBlockSize)
      else Result := hfBufFilePos;
  end; { TGpHugeFile.FilePos }

  procedure TGpHugeFile.Flush;
  begin
    CheckHandle;
    SetLastError(0);
    Win32Check(FlushBuffer,'Flush');
    SetLastError(0);
    Win32Check(FlushFileBuffers(hfHandle),'Flush');
  end; {  TGpHugeFile.Flush  }

  function TGpHugeFile.RoundToPageSize(bufSize: DWORD): DWORD;
  var
    sysInfo: TSystemInfo;
  begin
    GetSystemInfo(sysInfo);
    Result := (((bufSize-1) div sysInfo.dwPageSize) + 1) * sysInfo.dwPageSize;
  end; { TGpHugeFile.RoundToPageSize }

  procedure TGpHugeFile.AllocBuffer;
  begin
    FreeBuffer;
    if hfBufferSize = 0 then hfBufferSize := BUF_SIZE;
    // round up buffer size to be the multiplier of page size
    // needed for FILE_FLAG_NO_BUFFERING access, does not hurt in other cases
    hfBufferSize := RoundToPageSize(hfBufferSize);
    SetLastError(0);
    hfBuffer := VirtualAlloc(nil,hfBufferSize,MEM_RESERVE+MEM_COMMIT,PAGE_READWRITE);
    Win32Check(hfBuffer<>nil,'AllocBuffer');
    if hfLockBuffer then begin
      SetLastError(0);
      Win32Check(VirtualLock(hfBuffer,hfBufferSize),'AllocBuffer');
      if hfBuffer = nil then raise Exception.Create('TGpHugeFile: failed to allocate buffer!');
    end;
  end; { TGpHugeFile.AllocBuffer }

  procedure TGpHugeFile.FreeBuffer;
  begin
    if hfBuffer <> nil then begin
      SetLastError(0);
      Win32Check(FlushBuffer,'FreeBuffer');
      if hfLockBuffer then begin
        SetLastError(0);
        Win32Check(VirtualUnlock(hfBuffer,hfBufferSize),'FreeBuffer');
      end;
      SetLastError(0);
      Win32Check(VirtualFree(hfBuffer,0,MEM_RELEASE),'FreeBuffer');
      hfBuffer := nil;
    end;
  end; { TGpHugeFile.FreeBuffer }

  function OffsetPtr(ptr: pointer; offset: DWORD): pointer;
  begin
    Result := pointer(DWORD(ptr)+offset);
  end; { OffsetPtr }

  procedure TGpHugeFile.Transmit(const buf; count: DWORD; var transferred: DWORD);
  var
    place  : DWORD;
    bufp   : pointer;
    send   : DWORD;
    written: DWORD;
  begin
    if not hfBufWrite then raise Exception.Create('TGpHugeFile: Write while in buffered read mode!');
    transferred := 0;
    place := hfBufferSize-hfBufOffs;
    if place <= count then begin
      Move(buf,OffsetPtr(hfBuffer,hfBufOffs)^,place); // fill the buffer
      hfBufOffs := hfBufferSize;
      hfBufFilePos := hfBufFileOffs+hfBufOffs;
      if not FlushBuffer then Exit;
      transferred := place;
      Dec(count,place);
      bufp := OffsetPtr(@buf,place);
      if count >= hfBufferSize then begin // transfer N*(buffer size)
        send := (count div hfBufferSize)*hfBufferSize;
        if not WriteFile(hfHandle,bufp^,send,written,nil) then Exit;
        hfBufFileOffs := hfBufFileOffs+written;
        hfBufFilePos := hfBufFileOffs;
        Inc(transferred,written);
        Dec(count,send);
        bufp := OffsetPtr(bufp,send);
      end;                           
    end
    else bufp := @buf;
    if count > 0 then begin // store leftovers
      Move(bufp^,OffsetPtr(hfBuffer,hfBufOffs)^,count);
      Inc(hfBufOffs,count);
      Inc(transferred,count);
      hfBufFilePos := hfBufFileOffs+hfBufOffs;
    end;
  end; { TGpHugeFile.Transmit }

  procedure TGpHugeFile.Fetch(var buf; count: DWORD; var transferred: DWORD);
  var
    got  : DWORD;
    bufp : pointer;
    read : DWORD;
    trans: DWORD;
  begin
    if hfBufWrite then raise Exception.Create('TGpHugeFile: Read while in buffered write mode!');
    transferred := 0;
    got := hfBufSize-hfBufOffs;
    if got <= count then begin
      if got > 0 then begin // read from buffer
        Move(OffsetPtr(hfBuffer,hfBufOffs)^,buf,got);
        transferred := got;
        Dec(count,got);
        hfBufFilePos := hfBufFileOffs-hfBufSize+hfBufOffs+got;
      end;
      bufp := OffsetPtr(@buf,got);
      hfBufOffs := 0;
      if count >= hfBufferSize then begin // read directly
        read := (count div hfBufferSize)*hfBufferSize;
        if not ReadFile(hfHandle,bufp^,read,trans,nil) then Exit;
        hfBufFileOffs := hfBufFileOffs+trans;
        hfBufFilePos := hfBufFileOffs;
        Inc(transferred,trans);
        Dec(count,read);
        bufp := OffsetPtr(bufp,read);
        if trans < read then Exit; // EOF
      end;
      // fill the buffer
      SetLastError(0);
      Win32Check(ReadFile(hfHandle,hfBuffer^,hfBufferSize,hfBufSize,nil),'Fetch');
      hfBufFileOffs := hfBufFileOffs+hfBufSize;
    end
    else bufp := @buf;
    if count > 0 then begin // read from buffer
      got := hfBufSize-hfBufOffs;
      if got < count then count := got;
      if count > 0 then Move(OffsetPtr(hfBuffer,hfBufOffs)^,bufp^,count);
      Inc(hfBufOffs,count);
      Inc(transferred,count);
      hfBufFilePos := hfBufFileOffs-hfBufSize+hfBufOffs;
    end;
  end; { TGpHugeFile.Fetch }

  function TGpHugeFile.FlushBuffer: boolean;
  var
    written: DWORD;
  begin
    if (hfBufOffs > 0) and hfBufWrite then begin
      if hfFlagNoBuf then hfBufOffs := RoundToPageSize(hfBufOffs);
      Result := WriteFile(hfHandle,hfBuffer^,hfBufOffs,written,nil);
      hfBufFileOffs := hfBufFileOffs+written;
      hfBufOffs     := 0;
      hfBufFilePos  := hfBufFileOffs;
      if hfFlagNoBuf then FillChar(hfBuffer^,hfBufferSize,0);
    end
    else Result := true;
  end; { TGpHugeFile.FlushBuffer }

  procedure TGpHugeFile.BlockReadUnsafe(var buf; count: DWORD);
  var
    transferred: DWORD;
  begin
    BlockRead(buf,count,transferred);
    if count <> transferred then begin
      if hfBuffered then raise Exception.Create('TGpHugeFile: End of file!')
                    else Win32Check(false,'BlockReadUnsafe');
    end;
  end; { TGpHugeFile.BlockReadUnsafe }

  procedure TGpHugeFile.BlockWriteUnsafe(const buf; count: DWORD);
  var
    transferred: DWORD;
  begin
    BlockWrite(buf,count,transferred);
    if count <> transferred then begin
      if hfBuffered then raise Exception.Create('TGpHugeFile: Write failed!')
                    else Win32Check(false,'BlockWriteUnsafe');
    end;
  end; { TGpHugeFile.BlockWriteUnsafe }

  function TGpHugeFile.IsOpen: boolean;
  begin
    Result := (hfHandle = INVALID_HANDLE_VALUE);
  end; { TGpHugeFile.IsOpen }

  procedure TGpHugeFile.Win32Check(condition: boolean; method: string);
  var
    LastError: DWORD;
    Error: EOSError;
  begin
    if not condition then begin
      LastError := GetLastError;
      if LastError <> ERROR_SUCCESS then
        Error := EOSError.CreateFmt('TGpHugeFile.%s(%s) failed. '+SWin32Error, [method,hfName,LastError,
         SysErrorMessage(LastError)])
      else
        Error := EOSError.CreateFmt('TGpHugeFile.%s(%s) failed. '+SUnkWin32Error, [method,hfName]);
       Error.ErrorCode := LastError;
      raise Error;
    end;
  end; { TGpHugeFile.Win32Check }

end.
