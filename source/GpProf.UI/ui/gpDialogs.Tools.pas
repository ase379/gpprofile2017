{$I OPTIONS.INC}

unit gpDialogs.Tools;

interface

uses
  System.Classes;


function GetFolderFromBrowseDialog(const aDefaultFolder, aTitle: string): string;
procedure FillInUnitList(const aListToBeFilled: TStringList);

implementation

uses
  System.SysUtils, Vcl.Forms,
  Vcl.Dialogs, FileCtrl, gpString;

function GetFolderFromBrowseDialog(const aDefaultFolder, aTitle: string): string;
var
  LFileDlg : TFileOpenDialog;
begin
  if Win32MajorVersion >= 6 then
  begin
    LFileDlg := TFileOpenDialog.Create(nil);
    try
      LFileDlg.Options := [fdoPickFolders];
      LFileDlg.Title := 'Select Directory';
      LFileDlg.Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem]; // YMMV
      LFileDlg.OkButtonLabel := 'Select';
      LFileDlg.DefaultFolder := aDefaultFolder;
      LFileDlg.FileName := aDefaultFolder;
      if LFileDlg.Execute then
        result := LFileDlg.FileName
      else
        result := '';
    finally
      LFileDlg.Free;
    end;
  end
  else
  begin
    if not SelectDirectory('Select Directory', ExtractFileDrive(aDefaultFolder), result,
             [sdNewUI, sdNewFolder]) then
      result := '';
  end;
end;

procedure FillInUnitList(const aListToBeFilled: TStringList);

var
  vSelDir: String;

  procedure Iterate(mask: string);
  var
    S  : TSearchRec;
    res: integer;

    procedure AddUnit(const unitName: string);
    begin
      if aListToBeFilled.IndexOf(unitName) < 0 then
        aListToBeFilled.Add(unitName);
    end; { AddUnit }

  begin
    res := System.SysUtils.FindFirst(MakeBackslash(vSelDir)+mask,0,S);
    if res = 0 then begin
      repeat
        AddUnit(UpperCase(ButLastEl(S.Name,'.',-1)));
        res := FindNext(S);
      until res <> 0;
      System.SysUtils.FindClose(S);
    end;
  end; { Iterate }

begin
  vSelDir := GetFolderFromBrowseDialog('Choose folder', '');
  if vSelDir <> '' then
  begin
    Iterate('*.pas');
    Iterate('*.dcu');
  end;
end;


end.
