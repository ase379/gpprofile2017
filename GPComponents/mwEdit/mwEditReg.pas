{+-----------------------------------------------------------------------------+
 | Created:     1998-12-16
 | Last change: 1999-09-24
 | Author:      Primoz Gabrijelcic
 | Description: One unit to bind them - common Register for all mwEdit
 |              components
 | Version:     0.19
 | Copyright (c) 1998 Primoz Gabrijelcic
 | No rights reserved.
 |
 | Thanks to: Brad Stowers
 |
 | Version history: see version.rtf
 |
 +----------------------------------------------------------------------------+}

unit mwEditReg;

interface

procedure Register;

implementation

{begin}                                                                         //bds 1998-12-16
uses
  Dialogs, Forms, Graphics,
  mwKeyCmds, Classes,                                                           //bds 1998-12-23
  mwKeyCmdsEditor,                                                              //bds 1998-12-29
  mwCustomEdit, mwPasSyn, DcjCppSyn, DcjPerlSyn, mwGeneralSyn, cbHPSyn,
  DcjJavaSyn,                                                                   //mt 1999-01-02
  cwCACSyn,                                                                     //gp 1999-01-10
  wmSQLSyn,                                                                     //gp 1999-02-28
  hkHTMLSyn,                                                                    //gp 1999-05-05
  hkAWKSyn,                                                                     //gp 1999-05-05
  siTclTksyn,                                                                   //si 1999-05-02
  lbVBSSyn,                                                                     //gp 1999-05-06
  odPySyn, odPythonBehaviour,                                                   //od 1999-03-28
  mkGalaxySyn,                                                                  //gp 1999-06-10
  mwRTFExport,                                                                  //gp 1999-06-10
  mwHTMLExport,                                                                 //gp 1999-06-10
  DBmwEdit,                                                                     //mh 1999-09-24
  dmBatSyn,                                                                     //mh 1999-09-24
  dmDfmSyn,                                                                     //mh 1999-09-24
  nhAsmSyn,                                                                     //mh 1999-09-25
  mwCompletionProposal;                                                         //mh 1999-09-25

procedure Register;
begin
  mwCustomEdit.Register;
  mwPasSyn.Register;
  DcjCppSyn.Register;
  DcjPerlSyn.Register;                                                          //gp 1998-12-30
  mwGeneralSyn.Register;                                                        //gp 1998-12-30
  cbHPSyn.Register;                                                             //gp 1998-12-30
  DcjJavaSyn.Register;                                                          //mt 1999-01-02
  cwCACSyn.Register;                                                            //gp 1999-01-10
  wmSQLSyn.Register;                                                            //gp 1999-02-28
  siTclTksyn.Register;                                                          //si 199-05-02
  hkHTMLSyn.Register;                                                           //gp 1999-05-05
  hkAWKSyn.Register;                                                            //gp 1999-05-05
  lbVBSSyn.Register;                                                            //gp 1999-05-06
  odPySyn.Register;                                                             //gp 1999-05-06
  odPythonBehaviour.Register;                                                   //gp 1999-05-06
  mkGalaxySyn.Register;                                                         //gp 1999-06-10
  mwRTFExport.Register;                                                         //gp 1999-06-10
  mwHTMLExport.Register;                                                        //gp 1999-06-10
  DBmwEdit.Register;                                                            //mh 1999-09-24
  dmBatSyn.Register;                                                            //mh 1999-09-24
  dmDfmSyn.Register;                                                            //mh 1999-09-24
  nhAsmSyn.Register;                                                            //mh 1999-09-25
  mwCompletionProposal.Register;                                                //mh 1999-09-25
end; { Register }

(* This moved to mwKeyCmds.pas because it has to be there under D3.             //bds 1998-12-29
{begin}                                                                         //bds 1998-12-23
initialization
  RegisterIntegerConsts(TypeInfo(TmwEditorCommand), IdentToEditorCommand,
     EditorCommandToIdent);
{end}                                                                           //bds 1998-12-23
*)                                                                              //bds 1998-12-29
end.
