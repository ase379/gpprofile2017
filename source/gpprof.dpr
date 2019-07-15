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
  Vcl.HtmlHelpViewer,
  GpString,
  BdsProjUnit in 'BdsProjUnit.pas',
  gppmain.FrameInstrumentation in 'gppmain.FrameInstrumentation.pas' {frmMainInstrumentation: TFrame},
  gppTree in 'gppTree.pas',
  gppMain in 'gppMain.pas' {frmMain},
  gpFileEdit in 'gpFileEdit.pas',
  GpVersion in 'GpVersion.pas',
  gppIDT in 'gppIDT.pas',
  gpUnitWizard in 'gpUnitWizard.pas' {fmUnitWizard},
  gppcommon in 'gppcommon.pas',
  gppresults in 'gppresults.pas',
  gppExport in 'gppExport.pas' {frmExport},
  gppAbout in 'gppAbout.pas' {frmAbout},
  gpiff in 'gpiff.pas',
  GpHugeF in 'GpHugeF.pas',
  gppmain.types in 'gppmain.types.pas',
  gpPrfPlaceholders in 'gpPrfPlaceholders.pas',
  GpRegistry in 'GpRegistry.pas',
  gppCurrentPrefs in 'gppCurrentPrefs.pas',
  gppmain.dragNdrop in 'gppmain.dragNdrop.pas',
  gpPreferencesDlg in 'gpPreferencesDlg.pas' {frmPreferences},
  SimpleReportUnit in 'SimpleReportUnit.pas' {fmSimpleReport},
  gppLoadProgress in 'gppLoadProgress.pas' {frmLoadProgress},
  gppmain.FrameAnalysis in 'gppmain.FrameAnalysis.pas' {frmMainProfiling: TFrame},
  bdsVersions in 'bdsVersions.pas',
  gppMain.FrameInstrumentation.SelectionInfo in 'gppMain.FrameInstrumentation.SelectionInfo.pas',
  gpRegUnreg in 'gpRegUnreg.pas',
  gpPrfPlaceholderDlg in 'gpPrfPlaceholderDlg.pas' {frmPreferenceMacros},
  DProjUnit in 'DProjUnit.pas',
  CastaliaPasLex in 'CastaliaDelphiParser\CastaliaPasLex.pas',
  CastaliaPasLexTypes in 'CastaliaDelphiParser\CastaliaPasLexTypes.pas',
  gpParser.API in 'gpParser\gpParser.API.pas',
  gpParser.BaseProject in 'gpParser\gpParser.BaseProject.pas',
  gpParser.Defines in 'gpParser\gpParser.Defines.pas',
  gpParser in 'gpParser\gpParser.pas',
  gpParser.Procs in 'gpParser\gpParser.Procs.pas',
  gpParser.Selections in 'gpParser\gpParser.Selections.pas',
  gpParser.Types in 'gpParser\gpParser.Types.pas',
  gpParser.Units in 'gpParser\gpParser.Units.pas',
  virtualTree.tools.base in 'VirtualTree.Tools\virtualTree.tools.base.pas',
  virtualTree.tools.checkable in 'VirtualTree.Tools\virtualTree.tools.checkable.pas',
  virtualTree.tools.statistics in 'VirtualTree.Tools\virtualTree.tools.statistics.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmPreferenceMacros, frmPreferenceMacros);
  Application.CreateForm(TfmUnitWizard, fmUnitWizard);
  Application.CreateForm(TfrmLoadProgress, frmLoadProgress);
  Application.Run;
end.
