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
  gppPreferencesDlg,
  gppAbout,
  gppExport,
  gppPrfPlaceholderDlg,
  gppUnitWizard,
  gppMain;

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmPreferences, frmPreferences);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmExport, frmExport);
  Application.CreateForm(TfrmPreferenceMacros, frmPreferenceMacros);
  Application.CreateForm(TfmUnitWizard, fmUnitWizard);
  Application.Run;
end.
