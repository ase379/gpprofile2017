program unreg;

uses
  Windows,
  GpRegistry,
  GpRegUnreg;

var
  iDir: string;

begin
  with TGpRegistry.Create do begin
    try
      RootKey := HKEY_CURRENT_USER;
      if OpenKey('SOFTWARE\Gp\GpProfile',false) then begin
        iDir := ReadString('InstallDir1','');
        if iDir <> '' then begin
          try
            UnregisterGpProfile(iDir+'\gpprof.exe');
            CleanRegistry;
            DeleteDir(iDir);
          except end;
        end;
        CloseKey;
      end;
    finally {TGpRegistry.}Free; end;
  end;
end.
