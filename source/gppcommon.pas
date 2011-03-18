{$I OPTIONS.INC}

unit gppCommon;

interface

uses
  Windows;

const
  cRegistryRoot  = 'SOFTWARE\GpProfileReborn';
  cRegistryUIsub = 'UI';
  cRegistryUI    = cRegistryRoot + '\' + cRegistryUIsub;
  cProfUnitName  = 'GpProf';
  cUIVersion     = '1.0.3';
  cDefLayout     = 'default';

  // ToDo: 1) Move excluded units list into external configuration file
  // and get rid of saving excluded units list into registry.
  // Editing exluded units list should be done through editing of configuration file
  // 2) Try to get rid of necessity to use all caps in unit names
  defaultExcludedUnits = 'ACTIVEX'#13#10'ACTNLIST'#13#10'AREAEDIT'#13#10 +
    'ARROWCHA'#13#10'ARROWEDI'#13#10'AXCTRLS'#13#10'AXISINCR'#13#10 +
    'AXMAXMIN'#13#10'BAREDIT'#13#10'BDE'#13#10'BDECONST'#13#10'BDEMTS'#13#10 +
    'BDEPROV'#13#10'BISMTP'#13#10'BRUSHDLG'#13#10'BUBBLECH'#13#10 +
    'BUBBLEDI'#13#10'BUTTONS'#13#10'CALENDAR'#13#10'CGIAPP'#13#10'CHART'#13#10 +
    'CHECKLST'#13#10'CLASSES'#13#10'CLIPBRD'#13#10'COLORGRD'#13#10 +
    'COMCONST'#13#10'COMCORBA'#13#10'COMCTRLS'#13#10'COMMCTRL'#13#10 +
    'COMMDLG'#13#10'COMOBJ'#13#10'COMSERV'#13#10'COMSTRS'#13#10'CONSTS'#13#10 +
    'CONTROLS'#13#10'COPYPRSR'#13#10'CORBACON'#13#10'CORBAOBJ'#13#10 +
    'CORBARDM'#13#10'CORBASTD'#13#10'CORBAVCL'#13#10'CORBCNST'#13#10 +
    'CORBINIT'#13#10'CPL'#13#10'CUSTEDIT'#13#10'DATABKR'#13#10'DB'#13#10 +
    'DBACTNS'#13#10'DBCGRIDS'#13#10'DBCHART'#13#10'DBCLIENT'#13#10 +
    'DBCOMMON'#13#10'DBCONSTS'#13#10'DBCTRLS'#13#10'DBEDITCH'#13#10 +
    'DBEXCEPT'#13#10'DBGRIDS'#13#10'DBINPREQ'#13#10'DBLOGDLG'#13#10 +
    'DBLOOKUP'#13#10'DBOLECTL'#13#10'DBPWDLG'#13#10'DBTABLES'#13#10 +
    'DBWEB'#13#10'DCLUSR30'#13#10'DCLUSR40'#13#10'DDEMAN'#13#10'DDEML'#13#10 +
    'DDEREG'#13#10'DIALOGS'#13#10'DIROUTLN'#13#10'DLGS'#13#10'DRINTF'#13#10 +
    'DRTABLE'#13#10'DSGNINTF'#13#10'DSGNWNDS'#13#10'DSINTF'#13#10 +
    'DSNDBCST'#13#10'DSPROD'#13#10'EDITCHAR'#13#10'EDITINTF'#13#10 +
    'EXPTINTF'#13#10'EXTCTRLS'#13#10'EXTDLGS'#13#10'FILECTRL'#13#10 +
    'FILEINTF'#13#10'FLATSB'#13#10'FLINEEDI'#13#10'FORMS'#13#10'GANTTCH'#13#10 +
    'GANTTEDI'#13#10'GAUGES'#13#10'GRAPHICS'#13#10'GRIDS'#13#10'HTTPAPP'#13#10 +
    'IBCONST'#13#10'IBCTRLS'#13#10'IBEVNTS'#13#10'IBPROC32'#13#10 +
    'IEDITCHA'#13#10'IMAGEHLP'#13#10'IMGLIST'#13#10'IMM'#13#10'INIFILES'#13#10 +
    'ISAPI'#13#10'ISAPI2'#13#10'ISAPIAPP'#13#10'ISP3'#13#10'ISTREAMS'#13#10 +
    'JCONSTS'#13#10'JPEG'#13#10'LIBHELP'#13#10'LZEXPAND'#13#10'MAPI'#13#10 +
    'MASK'#13#10'MASKS'#13#10'MATH'#13#10'MCONNECT'#13#10'MENUS'#13#10 +
    'MESSAGES'#13#10'MIDASCON'#13#10'MIDCONST'#13#10'MMSYSTEM'#13#10 +
    'MPLAYER'#13#10'MSRVR'#13#10'MTSOBJ'#13#10'MTSRDM'#13#10'MTX'#13#10 +
    'MULTIMON'#13#10'MXARRAYS'#13#10'MXBUTTON'#13#10'MXCOMMON'#13#10 +
    'MXCONSTS'#13#10'MXDB'#13#10'MXDCUBE'#13#10'MXDSQL'#13#10'MXGRAPH'#13#10 +
    'MXGRID'#13#10'MXPBAR'#13#10'MXPIVSRC'#13#10'MXQEDCOM'#13#10 +
    'MXQPARSE'#13#10'MXSTORE'#13#10'MXTABLES'#13#10'NB30'#13#10'NMCONST'#13#10 +
    'NMDAYTIM'#13#10'NMECHO'#13#10'NMEXTSTR'#13#10'NMFNGR'#13#10'NMFTP'#13#10 +
    'NMHTML'#13#10'NMHTTP'#13#10'NMMSG'#13#10'NMNNTP'#13#10'NMPOP3'#13#10 +
    'NMSMTP'#13#10'NMSTRM'#13#10'NMTIME'#13#10'NMUDP'#13#10'NMURL'#13#10 +
    'NMUUE'#13#10'NS30FIX'#13#10'NSAPI'#13#10'OBJBRKR'#13#10'OCXREG'#13#10 +
    'OLE2'#13#10'OLEAUTO'#13#10'OLECONST'#13#10'OLECTL'#13#10'OLECTNRS'#13#10 +
    'OLECTRLS'#13#10'OLEDLG'#13#10'OPENGL'#13#10'ORBPAS'#13#10'OUTLINE'#13#10 +
    'PENDLG'#13#10'PENWIN'#13#10'PICEDIT'#13#10'PIEEDIT'#13#10'PRINTERS'#13#10 +
    'PROVIDER'#13#10'PROXIES'#13#10'PSOCK'#13#10'QR2CONST'#13#10 +
    'QR3CONST'#13#10'QRABOUT'#13#10'QRALIAS'#13#10'QRCOMPED'#13#10 +
    'QRCTRLS'#13#10'QRDATASU'#13#10'QRENVED'#13#10'QREXPBLD'#13#10 +
    'QREXPORT'#13#10'QREXPR'#13#10'QREXTRA'#13#10'QRHTML'#13#10'QRLABLED'#13#10 +
    'QRPREV'#13#10'QRPRGRES'#13#10'QRPRNSU'#13#10'QRPRNTR'#13#10'QRTEE'#13#10 +
    'QUICKRPT'#13#10'REGISTRY'#13#10'REGSTR'#13#10'REPORT'#13#10 +
    'RICHEDIT'#13#10'RSCONSTS'#13#10'SCKTCOMP'#13#10'SCONNECT'#13#10 +
    'SERIES'#13#10'SHAPEEDI'#13#10'SHAREMEM'#13#10'SHELLAPI'#13#10 +
    'SHLOBJ'#13#10'SMCONSTS'#13#10'SMINTF'#13#10'SPIN'#13#10'STDACTNS'#13#10 +
    'STDCTRLS'#13#10'STDVCL'#13#10'SVCMGR'#13#10'SYNCOBJS'#13#10 +
    'SYSCONST'#13#10'SYSINIT'#13#10'SYSTEM'#13#10'SYSUTILS'#13#10 +
    'TABNOTBK'#13#10'TABS'#13#10'TECANVAS'#13#10'TEEABOUT'#13#10 +
    'TEECONST'#13#10'TEEFUNCI'#13#10'TEEGALLY'#13#10'TEELISB'#13#10 +
    'TEENGINE'#13#10'TEEPREVI'#13#10'TEEPROCS'#13#10'TEESHAPE'#13#10 +
    'TEEXPORT'#13#10'TLHELP32'#13#10'TOOLINTF'#13#10'TOOLWIN'#13#10 +
    'TYPINFO'#13#10'URLMON'#13#10'VCLCOM'#13#10'VIRTINTF'#13#10'WEBCONST'#13#10 +
    'WINDOWS'#13#10'WININET'#13#10'WINSOCK'#13#10'WINSPOOL'#13#10'WINSVC'#13#10 +
    // Added by Alisov A., 2011.03.09
    'VARIANTS'#13#10'TYPES'#13#10'COLLECTIONS'#13#10'STRUTILS'#13#10'RTLCONSTS'#13#10 +
    'CONTNRS'#13#10'ACCCTRL'#13#10'ANSISTRINGS'#13#10'DATEUTILS'#13#10'VARUTILS'#13#10 +
    'WINTYPES'#13#10'WINPROCS'#13#10'ACTNMAN'#13#10'THEMES'#13#10'ACLAPI'#13#10'OLESERVER';

procedure KillFile(fName: String);
function WinExecAndWait32(FileName: String; Visibility: integer): LongWord;
function HasParameter(const aParam: String): Boolean;
function IsAbsolutePath(const aPath: String): Boolean;

implementation

uses
  SysUtils,
  GpString;

procedure KillFile(fName: String);
begin
  if FileExists(fName) then begin
    SetFileAttributes(PChar(fName), 0);
    DeleteFile(fName);
  end;
end; { KillFile }

function WinExecAndWait32(FileName: String; Visibility: integer): LongWord;
var { by Pat Ritchey }
  zAppName   : array[0..512] of char;
  zCurDir    : array[0..255] of char;
  WorkDir    : String;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  StrPCopy(zAppName, FileName);
  GetDir(0, WorkDir);
  StrPCopy(zCurDir, WorkDir);
  FillChar(StartupInfo, Sizeof(StartupInfo), #0);
  StartupInfo.cb := Sizeof(StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;
  if not CreateProcess(nil,
    zAppName, // pointer to command line string
    nil, // pointer to process security attributes
    nil, // pointer to thread security attributes
    false, // handle inheritance flag
    CREATE_NEW_CONSOLE or // creation flags
    NORMAL_PRIORITY_CLASS,
    nil, //pointer to new environment block
    nil, // pointer to current directory name
    StartupInfo, // pointer to STARTUPINFO
    ProcessInfo) // pointer to PROCESS_INF
  then Result := WAIT_FAILED
  else begin
    WaitforSingleObject(ProcessInfo.hProcess, INFINITE);
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end; { WinExecAndWait32 }

function HasParameter(const aParam: String): boolean;
var
  i: integer;
begin
  for i := 1 to ParamCount do
    if AnsiSameText(ParamStr(i), aParam) then
    begin
      Result := true;
      Exit;
    end;
  Result := false;
end; { HasParameter }

function IsAbsolutePath(const aPath: String): Boolean;
begin
  Result := ((Length(aPath) > 0) and (aPath[1] in ['/','\'])) or
            ((Length(aPath) > 1) and (aPath[2] = ':'));
end; { TfrmMain.IsAbsolutePath }

end.
