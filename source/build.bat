@echo off
:start
  set build_justone=1
  if %1.==gpprof. goto gpprof
  set build_justone=0

:gpprof
  echo Building GpProf
  echo.
    if exist gpprof.exe del gpprof.exe >nul
    if exist gpprof.cfg del gpprof.cfg >nul
  :gpprof_brcc_baggage
    brcc32 -r baggage.rc >build.log
    if not errorlevel 1 goto gpprof_brcc
    goto error
  :gpprof_brcc
    brcc32 gpprof.rc >build.log
    if not errorlevel 1 goto gpprof_dcc
    type build.log | more
    goto error
  :gpprof_dcc
    DCC32.exe -Q -B gpprof.dpr >build.log
    if not errorlevel 1 goto gpprof_dccok
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
