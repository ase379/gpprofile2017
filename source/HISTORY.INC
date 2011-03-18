(*
  1.3.3: 1999-10-01
    - Total time (procedure+children) was calculated incorrectly for recursive
      procedures. Fixed.
    - Now compatible with Delphi 5.
  1.3.2: 1999-08-10
    - Fixed long-standing bug that caused corrupted profile file when profiling
      large projects.
    - Fixed yet another bug related to output directory processing.
    - Fixed yet another parser bug. Sometimes units were not properly parsed
      after instrumentation, which could cause various instrumentation-related
      problems.
    - Fixed bug in conditional directives processing. VERxxx was not defined if
      user never opened Preferences dialog.
    - Added setting to control instrumentation of pure assembler procedures.
      They are not instrumented by default anymore.
    - Parser changed to be more compatible with Delphi parser (which allows
      {$ENDIF<} (and variations) to be written instead of {$ENDIF}).
    - Fixed bug in nested $IFDEF parsing.
  1.3.1: 1999-06-30
    - Parser bug fixed: {$I *.INC} syntax was not processed correctly and caused
      unit with that directive not to be parsed.
    - Web-based forum created and hosted by Lars Akerman, author of CGI Expert.
      http://www.cgiexpert.com/scripts/externalforum.exe?forumname=gpprofile
    - Added menu entries for quick access to mailing list and support forum.
  1.3: 1999-06-19
    - Support for DLL profiling! Profiling starts when DLL is loaded and stops
      when DLL is unloaded.
    - Support for package profiling! Profiling starts when package is loaded and
      stops when package is unloaded.
    - Parser bug fixed. Code, instrumented with {$IFDEF GpProfile} markers could
      not be uninstrumented.
    - Parser bug fixed. Sometimes GpProfile could not find all files, included
      in the parsed project.
    - Parser bug fixed. Named used units were not found if path started with \
      character (example: test in '\dev\test.pas')
    - Small command line parser bug fixed.
    - Fixed several bugs related to output directory processing.
    - Source preview window is refreshed after instrumentation.
    - Better handling of ComCtl32 version problems.
    - Better error handling in file access procedures.
    - Better error handling in client module (gpprof.pas).
    - Included are few fixes, contributed by Frédéric Libaud,
      flibaud@club-internet.fr.
      - Fixed incorrect behaviour when output directory was a relative path.
      - Slight parser speedup.
  1.2.1: 15.4.1999
     - Parser bug fixed. $IFOPT compiler directive was not recognised and could
       cause wrongly instrumented source that couldn't be automatically
       uninstrumented.
     - Parser bug fixed. Sometimes units were excluded even if they were not
       listed in Excluded units list.
     - Parser bug fixed. External procedure declarations were incorrectly
       recognised as procedure headers.
     - Park button added to title bar.
  1.2: 20.3.1999
    - conditional compilation ($IF(N)DEF/$ELSE/$ENDIF, $DEFINE/$UNDEF) is fully
      supported
    - fixed bug in TGpArrowListView (arrows were not drawn correctly)
    - fixed bug in Instrument&Run and Run (sometimes GpProfile crashed instead
      of running Delphi)
    - fixed bug when fetching library search path from registry.
    - GpProfile now ignores all text following final "end."
    - user interface in Export slightly polished
    - color of background in source preview window is now shown correctly
    - small bugs in layout manager fixed
    - Caller/Called views are resized proportionally when form is resized
    - new menu entry in Delphi IDE: remove instrumentation
    - fixed bug when GpProfile would select wrong version of Delphi for a new
      project
  1.1: 22.12.1998
    - added ability to display and browse caller/called statistics
    - added ability to show/hide Source Preview window
    - source preview is now syntax highlighted (thanks to Martin Waldenburg and
      his TmwCustomEdit/TmwPasSyn components)
    - new free component used: TRotateLabel by Jörg Lingner
    - full source package includes help, generated with Time2HELP
      (www.time2help.com)
    - context sensitive help (kinda), accessible with F1 key
    - program history included in About box
    - due to new user interface layout all your layout settings will be lost;
      sorry
  1.0.1: 30.11.1998
    - added *LIMITED* support for $INCLUDE directive; included files are parsed
      but procedures in them cannot be instrumented
    - fixed two stupid bugs that made profiling almost impossible
    - executable renamed to GPPROF.EXE, help renamed accordingly
  1.0: 22.11.1998
    - bug fixed: compression and autostart settings were not correctly
      interpreted by the instrumented program
    - bug fixed: occasional 'List index out of bounds' error message fixed
    - profiling data is now stored in files <project_name>.inc and
      <project_name>.gpd (instead of gpprof.inc and gpprof.gpd) so you can with
      no problem profile projects located in same folder
    - small enhancements in user interface
    - new feature: metacomments (yeah, I know version 0.9 was supposed to be
      feature complete but I needed that); see documentation
    - another new feature: layouts; see documentation
    - bug fixed: listview arrow were painted incorrectly on nonstandard color
      schemes
    - bug fixed: uses clause was inserted in the wrong place if one
      uninstrumented and then reinstrumented (in same profiling session) unit
      with no uses clause in the implementation session
    - bug fixed: instrumented target hanged on exit if GpProfile was not running
    - bug fixed: case-sensitive comparitions removed from the parser
    - <projectname>.inc renamed to <projectname>.gpi
    - GpProfile now works correctly when exe is compiled into directory,
      diferent from the project directory gpprof (except that you cannot start
      GpProfile from the IDE Tools menu in this case)
    - ComCtrls95 not used anymore
    - added installation/uninstallation program, which automatically adds
      GpProfile to Delphi Tools and Search path
  0.9.0: 14.10.1998
    - bug fixed: stupid instrumentation bug causing .prf file corruption
      (present in all public releases so far)
    - bug fixed: source windows was not updated when browsing through the
      analysis result with cursor keys
    - parser improved: .DPR file (project source) can now be instrumented
    - Delphi 2 supported (thanks to Fulvio Guzzon)
    - mPasLex is removed from standard source distribution as it is again 
      available on the web
    - when .prf is loaded for the first time, it is overwritten with a very
      small digest; all next loadings are almost instantaneous
    - menus and toolbars reorganised
    - fixed invalid UI behaviour when all units were in directories different
      from project directory
    - workaround for Delphi compiler bug
    - bug fixed: sorting on Min/Call, Max/Call, and Avg/Call columns was not
      working
    - bug fixed: Min/Call, Max/Call, and Avg/Call are now correctly calculated
      for multithreaded targets
    - bug fixed: Instrument & Run and Run Delphi are now able to open projects
      with space character in project directory name
    - bug fixed: Analysis views are now filled correctly if profiling file is
      empty
    - bug fixed: code, injected in pure assembler procedures, is now working
    - feature fixed: Analysis views are now sorted case insensitive
    - new actions: Results.Rename/Move, Results.Make a copy,
      Results.Delete/Undelete
    - bug fixed: Show all folders state is now correctly remembered for each
      project
    - GPPROF.INC made into a Windows INI file; it now loaded at runtime
    - component IniOut not used anymore
    - better error handling when opening result files
    - window position&size is now correctly restored in all conditions
    - parser bug fixed: units with assembler parts are now correctly
      instrumented in all conditions
    - bug fixed: was trying to access protected parts of registry with full
      access; access failed when logged onto NT without administrator rights
    - source files are now rescanned automatically (when GpProfile gets focus
      and immediately before instrumentation), no manual rescan should be
      necessary anymore
    - new button Clear in Preferences dialog (Excluded units page)
    - tested with most important VCL units:
      ActnList, AxCtrls, BdeProv, Buttons, Checklst, Classes, Clipbrd, ComCtrls,
      Controls, Db, DBCGrids, DBClient, DBCommon, DBCtrls, DBGrids, DBLogDlg,
      DBPWDlg, DBTables, DdeMan, Dialogs, DSIntf, ExtCtrls, ExtDlgs, FileCtrl,
      Forms, Graphics, Grids, ImgList, Mask, Menus, MPlayer, OleCtnrs, OleCtrls,
      Outline, Printers, Provider, Registry, ScktComp, StdActns, StdCtrls,
      SyncObjs, ToolWin, TypInfo
  0.8.0: 6.10.1998
    - unnecessary hints in GpProf removed
    - Instrument & Run and Run Delphi are reusing existing Delphi instance when
      possible
    - new program icon (thanks to Uros Mesojedec)
    - simple source preview added
      - source preview does not work with pre-0.8 .PRF files when in Analysis
        mode
    - bug fixed: 'forward' declarations are now handled correctly
    - GpProfile now uses faster Pascal tokenizer (thanks to Martin Waldenburg);
      parsing is approx. 40% faster
      - tokenizer is included in the standard source distribution
      - for copyright see mPasLex.pas
    - internal overhead is more carefully calculated
      - results are more accurate
    - flushing profiled data to .prf file now has less effect on measurement
    - sadly, profiled application now work slower
    - .prf file loading is MUCH faster (up to 10x!)
  0.7.0: 29.9.1998
    - Help.About added
    - dependency on SyncObjs removed from GpProf
    - bug fixed: GpProfile was not able to open read-only profiling data files
    - version info resource included
    - library search path is fetched from the registry (in addition to search
      path specified in .DOF file)
    - bug fixed: right click on Analysis page before any .PRF file was loaded
      caused an access violation
    - .PRF files are now version-controlled, that should alleviate problems with
      future format changes
    - ability to rescan active .PRF file added
    - qualified uses syntax (unit in 'location') is now fully supported
    - fixed nasty re-instrumentation bug which was causing source and .prf
      corruption
    - bug fixed: overloaded procedures are now handled correctly
    - toolbar rearranged
    - plenty of instrumentation bugs fixed
  0.6.0: 27.9.1998
    - can instrument pure assembler procedures
    - toolbar slightly rearranged, one button glyph changed
    - uses clause properly uninstrumented in all cases
    - safer uninstrumentation (but still not perfect)
    - file access reworked, should have less effect on measurement
      - .prf files are now 50% - 70% smaller
      - .prf compression is settable (speed/size trade-off)
      - not compatible with older .prf format, sorry
    - expanded Preferences and Options
  0.5.0: 22.9.1998
    - first published version
*)
