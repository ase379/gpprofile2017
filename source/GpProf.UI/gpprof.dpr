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
  gpFileEdit in 'model\gpFileEdit.pas',
  GpHugeF in 'model\GpHugeF.pas',
  gpiff in 'model\gpiff.pas',
  gppcommon in 'model\gppcommon.pas',
  gppCurrentPrefs in 'model\gppCurrentPrefs.pas',
  gppIDT in 'model\gppIDT.pas',
  gppTree in 'model\gppTree.pas',
  GpRegistry in 'model\GpRegistry.pas',
  GpVersion in 'model\GpVersion.pas',
  gppResult.measurePointRegistry in 'model\profilingResultParser\gppResult.measurePointRegistry.pas',
  gppResults.callGraph in 'model\profilingResultParser\gppResults.callGraph.pas',
  gppresults in 'model\profilingResultParser\gppresults.pas',
  gppResults.procs in 'model\profilingResultParser\gppResults.procs.pas',
  gppResults.types in 'model\profilingResultParser\gppResults.types.pas',
  gpParser.API in 'model\sourceCodeAnalysis\gpParser.API.pas',
  gpParser.BaseProject in 'model\sourceCodeAnalysis\gpParser.BaseProject.pas',
  gpParser.Defines in 'model\sourceCodeAnalysis\gpParser.Defines.pas',
  gpParser in 'model\sourceCodeAnalysis\gpParser.pas',
  gpParser.Procs in 'model\sourceCodeAnalysis\gpParser.Procs.pas',
  gpParser.Selections in 'model\sourceCodeAnalysis\gpParser.Selections.pas',
  gpParser.TextReplacer in 'model\sourceCodeAnalysis\gpParser.TextReplacer.pas',
  gpParser.Types in 'model\sourceCodeAnalysis\gpParser.Types.pas',
  gpParser.Units.ParserStack in 'model\sourceCodeAnalysis\gpParser.Units.ParserStack.pas',
  gpParser.Units in 'model\sourceCodeAnalysis\gpParser.Units.pas',
  gpProf.BdsProjReader in 'model\sourceCodeAnalysis\gpProf.BdsProjReader.pas',
  gpProf.bdsVersions in 'model\sourceCodeAnalysis\gpProf.bdsVersions.pas',
  gpProf.Delphi.RegistryAccessor in 'model\sourceCodeAnalysis\gpProf.Delphi.RegistryAccessor.pas',
  gpProf.DofReader in 'model\sourceCodeAnalysis\gpProf.DofReader.pas',
  gpProf.DProjReader in 'model\sourceCodeAnalysis\gpProf.DProjReader.pas',
  gpProf.ProjectAccessor in 'model\sourceCodeAnalysis\gpProf.ProjectAccessor.pas',
  gpDialogs.Tools in 'ui\gpDialogs.Tools.pas',
  gppAbout in 'ui\gppAbout.pas' {frmAbout},
  gppExport in 'ui\gppExport.pas' {frmExport},
  gppLoadProgress in 'ui\gppLoadProgress.pas' {frmLoadProgress},
  gppmain.dragNdrop in 'ui\gppmain.dragNdrop.pas',
  gppmain.FrameInstrumentation in 'ui\gppmain.FrameInstrumentation.pas' {frmMainInstrumentation: TFrame},
  gppMain.FrameInstrumentation.SelectionInfo in 'ui\gppMain.FrameInstrumentation.SelectionInfo.pas',
  gppMain.FrameInstrumentation.SelectionInfoIF in 'ui\gppMain.FrameInstrumentation.SelectionInfoIF.pas',
  gppmain.FrameInstrumentation.UnitSelections in 'ui\gppmain.FrameInstrumentation.UnitSelections.pas',
  gppmain.FrameMemoryAnalysis in 'ui\gppmain.FrameMemoryAnalysis.pas' {frmMemProfiling: TFrame},
  gppmain.FramePerformanceAnalysis in 'ui\gppmain.FramePerformanceAnalysis.pas' {frmMainProfiling: TFrame},
  gppMain in 'ui\gppMain.pas' {frmMain},
  gppmain.types in 'ui\gppmain.types.pas',
  gppPreferencesDlg in 'ui\gppPreferencesDlg.pas' {frmPreferences},
  gppPrfPlaceholderDlg in 'ui\gppPrfPlaceholderDlg.pas' {frmPreferenceMacros},
  gpPrfPlaceholders in 'ui\gpPrfPlaceholders.pas',
  gppUnitWizard in 'ui\gppUnitWizard.pas' {fmUnitWizard},
  SimpleReportUnit in 'ui\SimpleReportUnit.pas' {fmSimpleReport},
  virtualTree.tools.base in 'ui\VirtualTree.Tools\virtualTree.tools.base.pas',
  virtualTree.tools.checkable in 'ui\VirtualTree.Tools\virtualTree.tools.checkable.pas',
  virtualTree.tools.memorystatistics in 'ui\VirtualTree.Tools\virtualTree.tools.memorystatistics.pas',
  virtualTree.tools.timestatistics in 'ui\VirtualTree.Tools\virtualTree.tools.timestatistics.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmPreferenceMacros, frmPreferenceMacros);
  Application.Run;
end.
