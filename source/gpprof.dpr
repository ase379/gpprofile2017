(*
GpProfile, profiler for Delphi. Copyright (C) 1998,1999 Primoz Gabrijelcic

License

  This program is free software; you can redistribute it and/or modify it under
  the terms of the GNU General Public License as published by the Free Software
  Foundation; either version 2 of the License, or (at your option) any later
  version.

  This program is distributed in the hope that it will be useful, but WITHOUT
  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

  You should have received a copy of the GNU General Public License along with
  this program; if not, write to the Free Software Foundation, Inc., 675 Mass
  Ave, Cambridge, MA 02139, USA.
*)

// #ToDoH Lower memory consumptions in gppResults before releasing fast version!

{$I HISTORY.INC}
{$I OPTIONS.INC}

program gpprof;

uses
  Forms,
  SysUtils,
  Windows,
  GpString,
  gpArrowListView,
  gppMain in 'gppMain.pas' {frmMain},
  gppPreferences in 'gppPreferences.pas' {frmPreferences},
  gpParser in 'gpParser.pas',
  gppIDT in 'gppIDT.pas',
  GpIFF in 'GpIFF.pas',
  gppResults in 'gppResults.pas',
  gppLoadProgress in 'gppLoadProgress.pas' {frmLoadProgress},
  gppAbout in 'gppAbout.pas' {frmAbout},
  gppExport in 'gppExport.pas' {frmExport},
  gpFileEdit in 'gpFileEdit.pas',
  gpRegUnreg in 'gpRegUnreg.pas',
  gppCommon in 'gppCommon.pas',
  gppCallGraph in 'gppCallGraph.pas' {frmCallGraph},
  gppComCtl in 'gppComCtl.pas' {frmComCtl},
  DProjUnit in 'DProjUnit.pas';

{$R *.RES}

  function Execute(const prog, params: string): boolean;
  var
    dir        : string;
    startupInfo: TStartupInfo;
    processInfo: TProcessInformation;
  begin
    with startupInfo do begin
      cb          := SizeOf(startupInfo);
      lpReserved  := nil;
      lpDesktop   := nil;
      lpTitle     := nil;
      dwFlags     := STARTF_USESHOWWINDOW+STARTF_FORCEOFFFEEDBACK;
      wShowWindow := SW_HIDE;
      cbReserved2 := 0;
      lpReserved2 := nil;
    end;
    dir := ExtractFilePath(prog);
    Result := CreateProcess(nil,PChar('"'+prog+'" '+params),nil,nil,false,
      CREATE_DEFAULT_ERROR_MODE+CREATE_NEW_PROCESS_GROUP+NORMAL_PRIORITY_CLASS,
      nil,PChar(dir),startupInfo, processInfo);
    if Result then begin
      CloseHandle(processInfo.hProcess);
      CloseHandle(processInfo.hThread);
    end
    else RaiseLastOSError;
  end; { Execute }

  function ProcessParameters: boolean;
  var
    i     : integer;
    oldGpp: string;
    cmd   : string;
  begin
    Result := false;
    for i := 1 to ParamCount do begin
      cmd := UpperCase(ParamStr(i));
      if cmd = '/REGISTER' then begin
        // upgrade from pre-1.0.1 version
        oldGpp := MakeSmartBackslash(ExtractFilePath(ParamStr(0)))+'GPPROF~1.EXE';
        if FileExists(oldGpp) then begin
          try
            WinExecAndWait32(oldGpp+' /unregister',SW_HIDE);
            KillFile(oldGpp);
            KillFile(ChangeFileExt(oldGpp,'.hlp'));
            KillFile(ChangeFileExt(oldGpp,'.cnt'));
            KillFile(ChangeFileExt(oldGpp,'.fts'));
            KillFile(ChangeFileExt(oldGpp,'.gid'));
          except end;
        end;
        RegisterGpProfile;
        Result := true;
      end
      else if cmd = '/UNREGISTER' then begin
        UnregisterGpProfile(ParamStr(0));
        Result := true;
      end
      else if cmd = '/FIRSTTIME_BG' then begin
        Execute(ParamStr(0),'/FIRSTTIME'); // bypass some stupid installer limitations
        Result := true;
      end;
    end;
  end; { ProcessParameters }

begin
  if not ProcessParameters then begin
    Application.Initialize;
    Application.Title := 'GpProfile';
    Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmLoadProgress, frmLoadProgress);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmCallGraph, frmCallGraph);
  Application.Run;
  end;
end.
