@echo off
:start
  set build_justone=1
  if %1.==gpprof. goto gpprof
  if %1.==gppunreg. goto gppunreg
  set build_justone=0

:gpprof
  echo Building GpProf
  echo.
    if exist gpprof.exe del gpprof.exe >nul
    if exist gpprof.cfg del gpprof.cfg >nul
  :gpprof_hpj2inc
    copy help\95nt\gpprof.hlp . >nul
    copy help\95nt\gpprof.cnt . >nul
    hpj2inc help\95nt\gpprof.hpj help.inc >build.log
    if not errorlevel 1 goto gpprof_brcc_baggage
    goto error
  :gpprof_brcc_baggage
    brcc32 -r baggage.rc >build.log
    if not errorlevel 1 goto gpprof_makeproj
    goto error
  :gpprof_makeproj
    makeprjres gpprof.dof gpprofile.ico gpprof.rc >build.log
    if not errorlevel 1 goto gpprof_brcc
    type build.log | more
    goto error
  :gpprof_brcc
    brcc32 gpprof.rc >build.log
    if not errorlevel 1 goto gpprof_dcc
    type build.log | more
    goto error
  :gpprof_dcc
    dcc32 -b -h- -w- -$r-,q-,c-,o+ %1 %2 %3 %4 %5 %6 %7 gpprof.dpr >build.log
    if not errorlevel 1 goto gpprof_dccok
    head build.log 1
    tail build.log 10
    goto error_nolog
  :gpprof_dccok
    tail build.log 1
    incver gpprof.dof
    echo.
  :gpprof_ok
    aspack gpprof.exe /r+ /b+ /d+ /e+
    if not exist g:\programs\gpprofile\gpprof.exe md g:\programs\gpprofile >nul
    copy gpprof.exe g:\programs\gpprofile >nul
    copy gpprof.hlp g:\programs\gpprofile >nul
    copy gpprof.cnt g:\programs\gpprofile >nul
    copy gpprof.pas x:\mstpl\gp >nul
    copy gpprofh.pas x:\mstpl\gp >nul
    if %build_justone=1 goto loop

:gppunreg
  rem gppUnreg is no longer needed
  goto loop
  echo Building gppUnreg
  echo.
    if exist gppunreg.exe del gppunreg.exe >nul
    if exist gppunreg.cfg del gppunreg.cfg >nul
  :gppunreg_dcc
    dcc32 -b -h- -w- -$r-,q-,c-,o+ %1 %2 %3 %4 %5 %6 %7 gppunreg.dpr >build.log
    if not errorlevel 1 goto gppunreg_dccok
    head build.log 1
    tail build.log 10
    goto error_nolog
  :gppunreg_dccok
    tail build.log 1
    echo.
  :gppunreg_ok
    if %build_justone=1 goto loop

:loop
  shift
  if %1.=. goto OK
  goto start

:error
  type build.log | more
:error_nolog
  echo.
  echo Error!
  goto exit

:OK
  if exist build.log erase build.log >nul
  set build_justone=
  echo Program(s) built successfully!

:exit
