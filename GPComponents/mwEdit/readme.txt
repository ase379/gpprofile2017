Hi all!

Now my part on mwEdit is done.
I'd like to invite the Delphi comunity to develop mwEdit further.
If there are significant enhancements say about 50% I'll abandon
all rights and put the source into Public Domain.
The enhancements counting for thesse 50% have not simple to be
addaptions of TmwPasSyn to other languages like C++ or Java,
which would be too easy.
Because I'm a very ill man, maintaining the source is to much
effort for me.
Martin Hieke has kindly offered to maintain the source.
If you have something to contribute send it to:
"Martin Hieke" <mghie@bigfoot.com>
Please, visually mark all changed parts with a comment! 

Martin

----------------------
Files in main folder:
  - cbHPSyn.pas:         HP48 assembler syntax highlighter TcbHPSyn, work of
                         Cyrille de Brebisson
  - cbHPSyn.dcr:         component icon for TcbHPSyn
  - cbUtils.pas:         fast string list (using hashing), used in cbHPSyn
  - cwCACSyn.pas:        CA-Clipper highlighter TcwCACSyn, work of Carlos 
                         Wijders
  - cwCACSyn.dcr:        component icon for TcwCACSyn
  - DBmwEdit.pas:        data-aware TmwCustomEdit descendant TDBmwEdit, work of
                         Vladimir Kuznetsov.
  - DBmwEdit.dcr:        component icon for TDBmwEdit
  - DcjCppSyn.pas:       C++ syntax highlighter TDcjCppSyn, work of Michael
                         Trier
  - DcjCppSyn.dcr:       component icon for TDcjCppSyn
  - DcjJavaSyn.pas:      Java syntax highlighter TDcjJavaSyn, work of Michael
                         Trier
  - DcjJavaSyn.dcr:      component icon for TDcjJavaSyn
  - DcjPerlSyn.pas:      Perl syntax highlighter TDcjPerlSyn, work of Michael
                         Trier
  - DcjPerlSyn.dcr:      component icon for TDcjPerlSyn
  - dmBatSyn.pas:		 DOS batch file highligher TdmBatSyn, work of David Muir
  - dmBatSyn.dcr:        component icon for TdmBatSyn
  - dmDFMSyn.pas:        DFM syntax highlighter TdmDFMSyn, work of David Muir
  - dmDFMSyn.dcr:        componen icon for TdmDFMSyn
  - hkAWKSyn.pas:        AWK highlighter ThkAWKSyn, work of Hideo Koiso
  - hkAWKSyn.dcr:        component icon for ThkAWKSyn
  - hkHTMLSyn.pas:       HTML highlighter ThkHTMLSyn, work of Hideo Koiso
  - hkHTMLSyn.dcr:       component icon for ThkHTMLSyn
  - lbVBSSyn.pas:        VBScript highlighter TlbVBSSyn, work of 
                         Luiz C. Vaz de Brito
  - lbVBSSyn.dcr:        component icon for TlbVBSSyn
  - mkGalaxySyn.pas:     Galaxy PBEM highlighter TmkGalaxySyn, work of 
                         Martijn van der Kooij
  - mkGalaxySyn.dcr:     component icon for TmkGalaxySyn
  - mwCompletionProposal.pas:
                         component to present a list of possible completion 
                         texts, work of Cyrille de Brebisson
  - mwCompletionProposal.dcr:
                         component icon for TmwCompletionProposal
  - mwCustomEdit.pas:    custom edit component TmwCustomEdit
  - mwCustomEdit.dcr:    component icon for TmwCustomEdit
  - mwCustomEdit.res:    bookmark images for TmwCustomEdit
  - mwDemo.ico:          demo program icon
  - mwEdit State Of Development.rtf: 
                         file with bugs, features under construction, features
                         requested etc.
  - mwEdit.inc:          common DEFINEs
  - mwEditReg.pas:       "one unit to bind them" - common Register for all
                         mwEdit components and property editors; all components
                         (but not property editors!) can still be installed
                         separately
  - mwEditReg.dcr:       all component icons
  - mwEditSearch.pas:    very fast search engine, work of Martin Waldenburg
  - mwEditStrings.pas:   string list container, work of Martin Waldenburg
  - mwExport.pas:        common exporter ancestor, work of James D. Jacobson
  - mwGeneralSyn.pas:    general syntax highlighter TmwGeneralSyn
  - mwGeneralSyn.dcr:    component icon for TmwGeneralSyn
  - mwHighlighter.pas:   common highlighter ancestor
  - mwHTMLExport.pas:	 HTML exporter TmwHTMLExport, work of James D. Jacobson
  - mwHTMLExport.dcr:    component icon for TmwHTMLExport
  - mwKeyCmdEditor.pas:  shortcut editor
  - mwKeyCmdEditor.dfm:  shortcut editor
  - mwKeyCmdsEditor.pas: custom keyboard assignment editor
  - mwKeyCmdsEditor.dfm: custom keyboard assignment editor
  - mwKeyCmds.pas:       keyboard processing part of TmwCustomEdit
  - mwLocalStr.pas:	 unit to hold all strings that might be localized, 
                         work of Michael Hieke
  - mwPasSyn.pas:        ObjectPascal syntax highlighter TmwPasSyn
  - mwPasSyn.dcr:        component icon for TmwPasSyn
  - mwRTFExport.pas:     RTF exporter TmwRTFExport, work of James D. Jacobson
  - mwRTFExport.dcr:     component icon for TmwRTFExport
  - mwSupportClasses.pas:supporting classes for mwCustomEdit
  - mwSupportProcs.pas:  supporting procedures for mwCustomEdit
  - nhAsmSyn.pas:        x86 assembly syntax highlighter TnhAsmSyn, work of
                         Nick Hoddinott
  - nhAsmSyn.dcr:        component icon for TnhAsmSyn
  - odPySyn.pas:         Python highlighter TodPySyn, work of Olivier Deckmyn
  - odPySyn.dcr:         component icon for TodPySyn
  - odPythonBehaviour.pas:
                         Python indentation component TodPythonBehaviour
  - odPythonBehaviour.dcr:
                         component icon for TodPythonBehaviour
  - pasting.txt:		 see version.rtf
  - readme.txt:          this file
  - siTCLTKSyn.pas:      TCL/TK syntaxt highlighter TsiTCLTKSyn, work of Igor 
                         Shitikov
  - siTCLTKSyn.dcr:      component icon for TsiTCLTKSyn
  - uTextDrawer.pas:     a helper class for drawing fixed-pitched font 
                         characters, work of Hanai Tohru
  - version.rtf:         version history, RTF format
  - wmSQLSyn.pas:        SQL highlighter TwmSQLSyn, work of Willo van der Merwe
  - wmSQLSyn.dcr:        component icon for TwmSQLSyn

Other folders:
  - BCB1Demo:            demo for Borland C++ Builder 1, work of Michael Trier
  - BCB3demo:            demo for Borland C++ Builder 3, work of Michael Trier
  - CodeExDemo:          simple Code Explorer - demo for OnToken event, work of
                         Andy Jeffries
  - CodeEx_CB:           simple Code Explorer, C++ Builder version, work of 
                         Jeff Corbets
  - Contribs:            contributions, not yet included in main package, see
                         index.txt
  - D4demo:              demo for Borland Delphi 4 (works in D2 and D3 too, just
                         ignore all errors when opening the project)
  - mwSynGen:            grammar generator, work of Martin Waldenburg
  - Packages:            design-time packages for D3, D4, D5, and CB4

