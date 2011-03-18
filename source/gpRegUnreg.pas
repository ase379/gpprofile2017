{$I OPTIONS.INC}

unit gpRegUnreg;

interface

  // ToDo: make this obsolete code work for Delphi XE or get rid of it without remorse :)
  procedure RegisterGpProfile;
  procedure UnregisterGpProfile(exeName: string);
  procedure CleanRegistry;
  procedure DeleteDir(folder: string);

implementation

uses
  Windows,
  SysUtils,
  Registry,
  Classes,
  GpString,
  GpRegistry,
  gppCommon;

  procedure RegisterWithDelphi(delName: string);
  var
    count  : integer;
    i      : integer;
    gotgpp : integer;
    uexe   : string;
    lexe   : string;
    scnt   : string;
    ctype  : TRegDataType;
    rootDir: string;
    path   : string;
  begin
{$IFDEF LogRegister}GpLogEventEx(Format('RegisterWithDelphi(%s)',[delName]),FullLogName); {$ENDIF}  
    with TGpRegistry.Create do begin
      try
        RootKey := HKEY_CURRENT_USER;
        if OpenKey('\SOFTWARE\Borland\Delphi\'+delName+'\Transfer',false) then begin
{$IFDEF LogRegister}GpLogEventEx('Key opened',FullLogName); {$ENDIF}
          if GetDataSize('Count') < 0 then begin
            ctype := rdString; // works with all Delphis
            count := 0;
          end
          else begin
            ctype := GetDataType('Count');
            if ctype = rdString then count := StrToIntDef(ReadString('Count','0'),0)
            else if ctype = rdInteger then count := ReadInteger('Count',0)
            else Exit; // very weird key
          end;
{$IFDEF LogRegister}GpLogEventEx(Format('Count = %d',[count]),FullLogName); {$ENDIF}  
          gotgpp:= 0;
          uexe := UpperCase(ParamStr(0));
          for i := 0 to count-1 do begin
            if uexe = UpperCase(ReadVariant('Path'+IntToStr(i),'')) then Inc(gotgpp);
          end; // for
          if gotgpp = 0 then begin
            scnt := IntToStr(count);
            WriteVariant('Params'+scnt,'$EXENAME $SAVEALL /DELPHI='+delName);
            WriteVariant('Path'+scnt,ParamStr(0));
            WriteVariant('Title'+scnt,'GpProfile');
            WriteVariant('WorkingDir'+scnt,ExtractFilePath(ParamStr(0)));
            Inc(count);
          end;
          if gotgpp <= 1 then begin
            scnt := IntToStr(count);
            WriteVariant('Params'+scnt,'$EXENAME $SAVEALL /REMOVEINST /DELPHI='+delName);
            WriteVariant('Path'+scnt,ParamStr(0));
            WriteVariant('Title'+scnt,'GpProfile - remove instrumentation');
            WriteVariant('WorkingDir'+scnt,ExtractFilePath(ParamStr(0)));
            if ctype = rdString then WriteString('Count',IntToStr(count+1))
                                else WriteInteger('Count',count+1);
          end;
          CloseKey;
        end;
        RootKey := HKEY_LOCAL_MACHINE;
        if OpenKeyReadOnly('\SOFTWARE\Borland\Delphi\'+delName) then begin
          rootDir := ReadString('RootDir','');
          CloseKey;
        end;
        RootKey := HKEY_CURRENT_USER;
        if OpenKey('SOFTWARE\Borland\Delphi\'+delName+'\Library',false) then begin
          path := ReadVariant('SearchPath','');
          gotgpp := 0;
          lexe := ExtractFilePath(ParamStr(0));
          if (Length(lexe) > 0) and (lexe[Length(lexe)] = '\') then
            lexe := ButLast(lexe,1);
          uexe := UpperCase(lexe);
          for i := 1 to NumElements(path,';',Ord('"')) do begin
            if UpperCase(Replace(NthEl(path,i,';',Ord('"')),'$(DELPHI)',rootDir)) = uexe then begin
              gotgpp := 1;
              break;
            end;
          end; // for
          if gotgpp = 0 then
            WriteVariant('SearchPath',path+';'+lexe);
          CloseKey;
        end;
      finally Free; end;
    end;
{$IFDEF LogRegister}GpLogEventEx('RegisterWithDelphi out',FullLogName); {$ENDIF}  
  end; { RegisterWithDelphi }

  procedure RegisterGpProfile;
  var
    s: TStringList;
    i: integer;
  begin
{$IFDEF LogRegister}GpLogEventEx('RegisterGpProfile',FullLogName); {$ENDIF}  
    with TGpRegistry.Create do begin
      try
        RootKey := HKEY_LOCAL_MACHINE;
        s := TStringList.Create;
        try
          RootKey := HKEY_LOCAL_MACHINE;
          if OpenKeyReadOnly('\SOFTWARE\Borland\Delphi') then GetKeyNames(s);
{$IFDEF LogRegister}GpLogEventEx(Format('HKLM count = %d',[s.Count]),FullLogName); {$ENDIF}  
          for i := 0 to s.Count-1 do RegisterWithDelphi(s[i]);
        finally
          s.Free;
        end;
      finally
        Free;
      end;
    end;
{$IFDEF LogRegister}GpLogEventEx('RegisterGpProfile out',FullLogName); {$ENDIF}  
  end; { RegisterGPProfile }

  procedure UnregisterFromDelphi(delName: string; exeName: string);
  var
    count : integer;
    i     : integer;
    gppidx: integer;
    uexe  : string;
    i1,i2 : string;
    ctype : TRegDataType;
  begin
    with TGpRegistry.Create do begin
      try
        RootKey := HKEY_CURRENT_USER;
        if OpenKey('\SOFTWARE\Borland\Delphi\'+delName+'\Transfer',false) then begin
          if GetDataSize('Count') < 0 then begin
            ctype := rdString; // works with all Delphis
            count := 0;
          end
          else begin
            ctype := GetDataType('Count');
            if ctype = rdString then count := StrToIntDef(ReadString('Count','0'),0)
            else if ctype = rdInteger then count := ReadInteger('Count',0)
            else Exit; // very weird key
          end;
          repeat
            gppidx := -1;
            uexe := UpperCase(exeName);
            for i := 0 to count-1 do begin
              if uexe = UpperCase(ReadVariant('Path'+IntToStr(i),'')) then begin
                gppidx := i;
                break;
              end;
            end; // for
            if gppidx >= 0 then begin
              for i := gppidx+1 to count-1 do begin
                i1 := IntToStr(i);
                i2 := IntToStr(i-1);
                WriteVariant('Params'+i2,ReadVariant('Params'+i1,''));
                WriteVariant('Path'+i2,ReadVariant('Path'+i1,''));
                WriteVariant('Title'+i2,ReadVariant('Title'+i1,''));
                WriteVariant('WorkingDir'+i2,ReadVariant('WorkingDir'+i1,''));
              end;
              i1 := IntToStr(count-1);
              DeleteValue('Params'+i1);
              DeleteValue('Path'+i1);
              DeleteValue('Title'+i1);
              DeleteValue('WorkingDir'+i1);
              if ctype = rdString  then WriteString('Count',IntToStr(count-1))
                                  else WriteInteger('Count',count-1);
              Dec(count);
            end;
          until gppidx = -1;
        end;
      finally
        Free;
      end;
    end;
  end; { UnregisterFromDelphi }

  procedure UnregisterGpProfile(exeName: string);
  var
    vSL: TStringList;
    i: integer;
  begin
    with TGpRegistry.Create do begin
      try
        RootKey := HKEY_LOCAL_MACHINE;
        vSL := TStringList.Create;
        try
          if OpenKeyReadOnly('\SOFTWARE\Borland\Delphi') then
            GetKeyNames(vSL);
          for i := 0 to vSL.Count-1 do
            UnregisterFromDelphi(vSL[i], exeName);
        finally
          vSL.Free;
        end;
      finally
        Free;
      end;
    end;
  end; { UnregisterGPProfile }

  procedure CleanRegistry;
  begin
    with TGpRegistry.Create do
      try
        RootKey := HKEY_CURRENT_USER;
        DeleteKey(cRegistryRoot);
      finally
        Free;
      end;
  end; { CleanRegistry }

  procedure DeleteDir(folder: string);
  var
    err: integer;
    S  : TSearchRec;
  begin
    err := FindFirst(folder+'\*.*',0,S);
    if err = 0 then begin
      repeat
        SetFileAttributes(PChar(folder+'\'+S.Name),0);
        DeleteFile(folder+'\'+S.Name);
        err := FindNext(S);
      until err <> 0;
      FindClose(S);
    end;
    RmDir(folder);
  end;

end.
