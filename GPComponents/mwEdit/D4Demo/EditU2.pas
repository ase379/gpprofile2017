{+-----------------------------------------------------------------------------+
 | Created:     not known
 | Last change: 1999-09-12
 | Author:      Primoz Gabrijelcic
 | Description: mwEdit demo - main unit
 | Version:     0.43 (see version.rtf for version history)
 | Copyright (c) 1998 Primoz Gabrijelcic
 | No rights reserved.
 |
 | Thanks to: Carlos Wijders, Brad Stowers, Heedong Lim
 |
 | Known issues:
 |  - OnChange is not generated on Load
 |  - ScrollBar scroll is not generating any event (except OnPaint)
 |
 +----------------------------------------------------------------------------+}

unit EditU2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ComCtrls, Menus, mwPasSyn, mwCustomEdit, mwHighlighter,
  DcjCppSyn, Spin, DcjPerlSyn, mwGeneralSyn, mwKeyCmds, cbHPSyn,
  mwKeyCmdsEditor, {$IFNDEF MWE_COMPILER_4_UP}ImgList,{$ENDIF} Buttons,
  DcjJavaSyn, cwCACSyn, siTCLTKSyn, wmSQLSyn, hkAWKSyn, hkHTMLSyn, odPySyn,
  odPythonBehaviour, lbVBSSyn, {dxDBDateEdit, Mask, dxDateEdit, }mkGalaxySyn,   //eb 1999-08-25
  mwRtfExport, mwExport, mwHtmlExport, dmBatSyn, dmDfmSyn, nhAsmSyn;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;                                       
    PageControl1: TPageControl;
    tabBookmarks: TTabSheet;
    cbEnableKeys: TCheckBox;
    cbGlyphsVisible: TCheckBox;
    Label4: TLabel;
    inpLeftMargin: TSpinEdit;
    tabGutter: TTabSheet;
    Label5: TLabel;
    tabHighlighter: TTabSheet;
    Label3: TLabel;
    cbxHighlighterSelect: TComboBox;
    cbxSettingsSelect: TComboBox;
    Label1: TLabel;
    tabCaret: TTabSheet;
    cbxInsertCaret: TComboBox;
    Label7: TLabel;
    Label8: TLabel;
    cbxOverwriteCaret: TComboBox;
    cbInsertMode: TCheckBox;
    tabUndo: TTabSheet;
    btnUndo: TButton;
    tabFile: TTabSheet;
    btnLoad: TButton;
    tabInfo: TTabSheet;
    Label9: TLabel;
    Label10: TLabel;
    inpLineText: TEdit;
    Label11: TLabel;
    inpMaxUndo: TSpinEdit;
    cbReadonly: TCheckBox;
    tabDisplay: TTabSheet;
    cbHideSelection: TCheckBox;
    Label12: TLabel;
    inpRightEdge: TSpinEdit;
    Label13: TLabel;
    cbScrollPastEOL: TCheckBox;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    outFilename: TLabel;
    tabAbout: TTabSheet;
    Label17: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    outLineCount: TEdit;
    tabEvents: TTabSheet;
    cbxScrollBars: TComboBox;
    cbxColor: TComboBox;
    cbxForeground: TComboBox;
    cbxBackground: TComboBox;
    btnFont: TButton;
    FontDialog1: TFontDialog;
    cbxGutterColor: TComboBox;
    inpLeftChar: TSpinEdit;
    inpTopLine: TSpinEdit;
    inpCaretX: TSpinEdit;
    inpCaretY: TSpinEdit;
    cbEnableEventLog: TCheckBox;
    lbEventLog: TListBox;
    Label2: TLabel;
    Label19: TLabel;
    Memo1: TMemo;
    cbxAttrSelect: TComboBox;
    cbxAttrBackground: TComboBox;
    cbxAttrForeground: TComboBox;
    Label23: TLabel;
    Label24: TLabel;
    grbAttrStyle: TGroupBox;
    btnKeywords: TButton;
    grbAttrComments: TGroupBox;
    cbStyleStrikeOut: TCheckBox;
    cbStyleUnderline: TCheckBox;
    cbStyleItalic: TCheckBox;
    cbStyleBold: TCheckBox;
    DcjCppSyn1: TDcjCppSyn;
    DcjPerlSyn1: TDcjPerlSyn;
    mwGeneralSyn1: TmwGeneralSyn;
    cbHPSyn1: TcbHPSyn;
    btnSaveToReg: TButton;
    btnLoadFromReg: TButton;
    StatusBar: TStatusBar;
    mwEdit: TmwCustomEdit;
    TabSheet1: TTabSheet;
    KeyCmdList: TListView;
    btnEdit: TButton;
    ImageList1: TImageList;
    cbInternalImages: TCheckBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    Label25: TLabel;
    inpXOffset: TSpinEdit;
    Label26: TLabel;
    inpExtraLineSpacing: TSpinEdit;
    DcjJavaSyn1: TDcjJavaSyn;
    btnRedo: TButton;
    cwCACSyn1: TcwCACSyn;
    cbCommentsBas: TCheckBox;
    cbCommentsAsm: TCheckBox;
    cbCommentsPas: TCheckBox;
    cbCommentsAnsi: TCheckBox;
    cbCommentsC: TCheckBox;
    Label22: TLabel;
    wmSQLSyn1: TwmSQLSyn;
    siTCLTKSyn1: TsiTCLTKSyn;
    btnPrint: TButton;
    mwPasSyn1: TmwPasSyn;
    cbLineNumbers: TCheckBox;
    cbLeadingZeros: TCheckBox;
    cbZeroStart: TCheckBox;
    hkAWKSyn1: ThkAWKSyn;
    odPySyn1: TodPySyn;
    cbMouse: TCheckBox;
    cbDrag: TCheckBox;
    cbKeyboard: TCheckBox;
    cbOther: TCheckBox;
    btnClear: TButton;
    hkHTMLSyn1: ThkHTMLSyn;
    odPythonBehaviour1: TodPythonBehaviour;
    tabExporter: TTabSheet;
    cbxExporterSelect: TComboBox;
    Label27: TLabel;
    btnExportToClip: TButton;
    lbVbsSyn1: TlbVbsSyn;
    tabEdit: TTabSheet;
    cbAutoindent: TCheckBox;
    Label28: TLabel;
    cbxREColor: TComboBox;
    cbHalfpageScroll: TCheckBox;
    cbWantTabs: TCheckBox;
    Label6: TLabel;
    inpGutterWidth: TSpinEdit;
    Label29: TLabel;
    inpTabIndent: TSpinEdit;
    mkGalaxySyn1: TmkGalaxySyn;
    Label30: TLabel;
    inpDigitCount: TSpinEdit;
    Label31: TLabel;
    inpLeftOffset: TSpinEdit;
    inpRightOffset: TSpinEdit;
    Label32: TLabel;
    mwHtmlExport1: TmwHtmlExport;
    mwRtfExport1: TmwRtfExport;
    btnExportAllToClip: TButton;
    FindDialog1: TFindDialog;
    ReplaceDialog1: TReplaceDialog;
    tabSearch: TTabSheet;
    btnSearch: TButton;
    btnSearchNext: TButton;
    btnSearchPrev: TButton;
    lblSearchResult: TLabel;
    btnReplace: TButton;
    dmBatSyn1: TdmBatSyn;
    dmDfmSyn1: TdmDfmSyn;
    nhAsmSyn1: TnhAsmSyn;
    procedure btnLoadClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbxSettingsSelectChange(Sender: TObject);
    procedure btnUndoClick(Sender: TObject);
    procedure mwEditEnter(Sender: TObject);
    procedure mwEditKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mwEditChange(Sender: TObject);
    procedure cbxHighlighterSelectChange(Sender: TObject);
    procedure cbReadonlyClick(Sender: TObject);
    procedure cbHideSelectionClick(Sender: TObject);
    procedure cbScrollPastEOLClick(Sender: TObject);
    procedure inpRightEdgeChange(Sender: TObject);
    procedure cbxScrollBarsChange(Sender: TObject);
    procedure cbxColorChange(Sender: TObject);
    procedure cbxForegroundChange(Sender: TObject);
    procedure cbxBackgroundChange(Sender: TObject);
    procedure btnFontClick(Sender: TObject);
    procedure cbxInsertCaretChange(Sender: TObject);
    procedure cbxOverwriteCaretChange(Sender: TObject);
    procedure cbInsertModeClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure cbxGutterColorChange(Sender: TObject);
    procedure inpGutterWidthChange(Sender: TObject);
    procedure cbEnableKeysClick(Sender: TObject);
    procedure cbGlyphsVisibleClick(Sender: TObject);
    procedure inpLeftMarginChange(Sender: TObject);
    procedure inpMaxUndoChange(Sender: TObject);
    procedure inpLineTextKeyPress(Sender: TObject; var Key: Char);
    procedure mwEditClick(Sender: TObject);
    procedure inpLeftCharChange(Sender: TObject);
    procedure inpTopLineChange(Sender: TObject);
    procedure inpCaretXChange(Sender: TObject);
    procedure inpCaretYChange(Sender: TObject);
    procedure cbEnableEventLogClick(Sender: TObject);
    procedure mwEditDblClick(Sender: TObject);
    procedure mwEditDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure mwEditDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure mwEditEndDrag(Sender, Target: TObject; X, Y: Integer);
    procedure mwEditExit(Sender: TObject);
    procedure mwEditKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure mwEditKeyPress(Sender: TObject; var Key: Char);
    procedure mwEditPaint(Sender: TObject; ACanvas: TCanvas);
    procedure mwEditStartDrag(Sender: TObject;
      var DragObject: TDragObject);
    procedure cbxAttrSelectChange(Sender: TObject);
    procedure cbxAttrBackgroundChange(Sender: TObject);
    procedure cbCommentsCClick(Sender: TObject);
    procedure btnKeywordsClick(Sender: TObject);
    procedure mwEditProcessCommand(var Command: TmwEditorCommand;
      var AChar: Char; Data: Pointer);
    procedure mwEditProcessUserCommand(var Command: TmwEditorCommand;
      var AChar: Char; Data: Pointer);
    procedure btnSaveToRegClick(Sender: TObject);
    procedure btnLoadFromRegClick(Sender: TObject);
    procedure btnEditClick(Sender: TObject);
    procedure cbInternalImagesClick(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure mwEditPlaceMark(var mark: TMark);
    procedure inpXOffsetChange(Sender: TObject);
    procedure inpExtraLineSpacingChange(Sender: TObject);
    procedure btnRedoClick(Sender: TObject);
    procedure btnPrintClick(Sender: TObject);
    procedure mwEditCommandDone(Sender: TObject);
    procedure mwEditPrintStatus(Sender: TComponent; Status: TmwPrintStatus;
      PageNumber: Integer; var Abort: Boolean);
    procedure cbLineNumbersClick(Sender: TObject);
    procedure cbLeadingZerosClick(Sender: TObject);
    procedure cbZeroStartClick(Sender: TObject);
    procedure mwEditMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure mwEditMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure mwEditMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btnClearClick(Sender: TObject);
    procedure cbAutoindentClick(Sender: TObject);
    procedure cbxREColorChange(Sender: TObject);
    procedure cbHalfpageScrollClick(Sender: TObject);
    procedure inpTabIndentChange(Sender: TObject);
    procedure cbWantTabsClick(Sender: TObject);
    procedure mwEditSelectionChange(Sender: TObject);
    procedure inpDigitCountChange(Sender: TObject);
    procedure inpLeftOffsetChange(Sender: TObject);
    procedure inpRightOffsetChange(Sender: TObject);
    procedure cbxExporterSelectChange(Sender: TObject);
    procedure btnExportToClipClick(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure btnSearchNextClick(Sender: TObject);
    procedure DoFindText(Sender: TObject);
    procedure btnReplaceClick(Sender: TObject);
    procedure DoReplaceText(Sender: TObject);
  private
    fName: string;
    markButtons: array [0..4] of TSpeedButton;
    disableMarkButtons: boolean;
    procedure LoadSettings;
    function ColorToIndex(col: TColor): integer;
    function IndexToColor(index: integer): TColor;
    procedure LoadInfo;
    procedure EnumerateHighlighters;
    procedure UpdateKeystrokesList;
    procedure ReloadAttributes;
    procedure ResetMarkButtons;
    procedure RebuildMarks;
    procedure RecalcLeftMargin;
    procedure EnumerateExporters;
  public
  end;

var
  Form1: TForm1;

implementation

uses Unit2;

{$R *.DFM}

procedure TForm1.btnLoadClick(Sender: TObject);

  function MatchesExtension(ext: string; light: TmwCustomHighlighter): boolean;
  var
    fext  : string;
    idx   : integer;
    ucext : string;
    filter: string;
    p     : integer;
  begin
    Result := false;
    ucext := UpperCase(ext);
    p := Pos('.',ucext);
    if p > 0 then ucext := Copy(ucext,p+1,Length(ucext)-p);
    p := Pos('|',light.DefaultFilter);
    if p > 0 then begin
      filter := Copy(light.DefaultFilter,p+1,Length(light.DefaultFilter)-p);
      while filter <> '' do begin
        p := Pos(';',filter);
        if p = 0 then p := Length(filter)+1;
        fext := Copy(filter,1,p-1);
        filter := Copy(filter,p+1,Length(filter)-p);
        p := Pos('.',fext);
        if p > 0 then fext := Copy(fext,p+1,Length(fext)-p);
        if UpperCase(fext) = ucext then begin
          idx := cbxHighlighterSelect.Items.IndexOf(light.LanguageName);
          if idx >= 0 then cbxHighlighterSelect.ItemIndex := idx;
          cbxHighlighterSelectChange(Sender);
          Result := true;
        end;
      end; //while
    end
  end; { MatchesExtension }

var
  i  : integer;
  ext: string;
begin
  if OpenDialog1.Execute then
  begin
    fName := OpenDialog1.FileName;
    outFilename.Caption := fName;
    outFilename.Visible := true;
    ext := UpperCase(ExtractFileExt(fName));
    for i := 0 to ComponentCount-1 do
      if Components[i] is TmwCustomHighLighter then begin
        if MatchesExtension(ext,Components[i] as TmwCustomHighlighter) then break;
      end;
    btnPrint.Enabled := true;
    if mwEdit.HighLighter = dmDfmSyn1 then LoadDFMFile2Strings(fName, mwEdit.Lines) //mh 1999-09-22
                                      else mwEdit.Lines.LoadFromFile(fName);
    mwEdit.Modified := false;
    mwEdit.ClearUndo;
    inpLineText.Text := mwEdit.LineText;
    mwEdit.SetFocus;
  end;
end;

procedure TForm1.EnumerateHighlighters;
var
  i: integer;
begin
  cbxHighlighterSelect.Items.Add('(none)');
  OpenDialog1.Filter := '';
  for i := 0 to ComponentCount-1 do
    if Components[i] is TmwCustomHighLighter then begin
      cbxHighlighterSelect.Items.Add((Components[i] as TmwCustomHighLighter).LanguageName);
      if (Components[i] as TmwCustomHighLighter).DefaultFilter <> '' then begin
        if OpenDialog1.Filter <> '' then OpenDialog1.Filter := OpenDialog1.Filter + '|';
        OpenDialog1.Filter := OpenDialog1.Filter + (Components[i] as TmwCustomHighLighter).DefaultFilter;
      end;
    end;
  if OpenDialog1.Filter <> '' then OpenDialog1.Filter := OpenDialog1.Filter + '|';
  OpenDialog1.Filter := OpenDialog1.Filter + 'All files (*.*)|*.*';
end;

procedure TForm1.EnumerateExporters;
var
  i: integer;
begin
  cbxExporterSelect.Items.Add('(none)');
  for i := 0 to ComponentCount-1 do
    if Components[i] is TmwCustomExport then
      cbxExporterSelect.Items.Add((Components[i] as TmwCustomExport).ExporterName);
  cbxExporterSelect.ItemIndex := 0;
  cbxExporterSelectChange(self);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  markButtons[0] := SpeedButton1;
  markButtons[1] := SpeedButton2;
  markButtons[2] := SpeedButton3;
  markButtons[3] := SpeedButton4;
  markButtons[4] := SpeedButton5;
  PageControl1.ActivePage := tabFile;
  EnumerateHighlighters;
  EnumerateExporters;
  UpdateKeystrokesList;
  FontDialog1.Font.Assign(mwEdit.Font);                                         //mh 1999-09-12
end;

procedure TForm1.cbxSettingsSelectChange(Sender: TObject);
var
  ok: boolean;
begin
  with cbxSettingsSelect do begin
    ok := mwEdit.Highlighter.UseUserSettings(ItemIndex);
    if ok
      then StatusBar.SimpleText := 'Success'
      else StatusBar.SimpleText := 'Failure';
    ReloadAttributes;
    if fName <> '' then begin
      mwEdit.Invalidate;
      mwEdit.SetFocus;
    end;
  end;
end;

procedure TForm1.btnUndoClick(Sender: TObject);
begin
  mwEdit.Undo;
  mwEdit.SetFocus;
end;

procedure TForm1.mwEditEnter(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnEnter');
  btnUndo.Enabled := mwEdit.CanUndo;
  btnRedo.Enabled := mwEdit.CanRedo;
end;

procedure TForm1.mwEditKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnKeyUp');
  btnUndo.Enabled := mwEdit.CanUndo;
  btnRedo.Enabled := mwEdit.CanRedo;
  cbInsertMode.Checked := mwEdit.InsertMode;
  LoadInfo;
end;

procedure TForm1.mwEditChange(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnChange');
  btnUndo.Enabled := mwEdit.CanUndo;
  btnRedo.Enabled := mwEdit.CanRedo;
  if mwEdit.Modified then begin
    with outFilename do
      if Caption[Length(Caption)] <> ')' then
        Caption := fname + ' (modified)'
  end
  else begin
    with outFilename do
      if Caption[Length(Caption)] = ')' then
        Caption := fname;
  end;
  LoadInfo;
end;

procedure TForm1.ReloadAttributes;
var
  i: integer;
begin
  if cbxHighlighterSelect.ItemIndex > 0 then begin
    cbxAttrSelect.Items.Clear;
    for i := 0 to mwEdit.HighLighter.AttrCount - 1 do
      cbxAttrSelect.Items.Add(mwEdit.HighLighter.Attribute[i].Name);
    cbxAttrSelect.ItemIndex := 0;
  end;
  cbxAttrSelectChange(Self);
end; 

procedure TForm1.cbxHighlighterSelectChange(Sender: TObject);
var
  i: integer;                                                                   //Carlos 1998-27-12
begin
  mwEdit.Highlighter := nil;
  for i := 0 to ComponentCount-1 do
    if (Components[i] is TmwCustomHighLighter) and
       ((Components[i] as TmwCustomHighLighter).LanguageName = cbxHighlighterSelect.Text) then begin
      mwEdit.Highlighter := (Components[i] as TmwCustomHighLighter);
      break;
    end;
  cbxExporterSelect.Enabled := assigned(mwEdit.Highlighter) and (hcExportable in mwEdit.Highlighter.Capability);
  btnExportToClip.Enabled := cbxExporterSelect.Enabled and (cbxExporterSelect.ItemIndex > 0);
  btnExportAllToClip.Enabled := btnExportToClip.Enabled;
  StatusBar.SimpleText := '';
  mwEdit.Invalidate;
  cbxSettingsSelect.Items.Clear;
  if assigned(mwEdit.Highlighter) and (hcUserSettings in mwEdit.Highlighter.Capability) then begin
    mwEdit.HighLighter.EnumUserSettings(cbxSettingsSelect.Items);
  end;
  cbxSettingsSelect.Enabled := (cbxSettingsSelect.Items.Count > 0);
  btnSaveToReg.Enabled := assigned(mwEdit.Highlighter) and (hcRegistry in mwEdit.Highlighter.Capability);
  btnLoadFromReg.Enabled := btnSaveToReg.Enabled;
  {begin}                                                                       //Carlos 1998-27-12
  cbxAttrSelect.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  cbxAttrForeground.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  cbxAttrBackground.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  grbAttrStyle.Enabled := (cbxHighlighterSelect.ItemIndex > 0);
  grbAttrComments.Enabled := mwEdit.Highlighter is TmwGeneralSyn;
  btnKeywords.Enabled := grbAttrComments.Enabled;
  if grbAttrComments.Enabled then begin
     cbCommentsAnsi.Checked := (csAnsiStyle in (mwEdit.HighLighter as TmwGeneralSyn).Comments);
     cbCommentsPas.Checked  := (csPasStyle in (mwEdit.HighLighter as TmwGeneralSyn).Comments);
     cbCommentsC.Checked    := (csCStyle in (mwEdit.HighLighter as TmwGeneralSyn).Comments);
     cbCommentsAsm.Checked  := (csAsmStyle in (mwEdit.HighLighter as TmwGeneralSyn).Comments);
     cbCommentsBas.Checked  := (csBasStyle in (mwEdit.HighLighter as TmwGeneralSyn).Comments);
  end;
  ReloadAttributes;
  {end}                                                                         //Carlos 1998-27-12
  if cbxHighlighterSelect.Text = odPySyn1.LanguageName
    then odPythonBehaviour1.Editor := mwEdit
    else odPythonBehaviour1.Editor := nil;
  mwEdit.SetFocus;
end;

procedure TForm1.cbReadonlyClick(Sender: TObject);
begin
  mwEdit.Readonly := cbReadonly.Checked;
  mwEdit.SetFocus;
end;

const
  Colors: array[1..42 {sic!}] of TColor = (clBlack, clMaroon, clGreen, clOlive,
    clNavy, clPurple, clTeal, clDkGray, clLtGray, clRed, clLime,
    clYellow, clBlue, clFuchsia, clAqua, clWhite, clScrollBar,
    clBackground, clActiveCaption, clInactiveCaption, clMenu, clWindow,
    clWindowFrame, clMenuText, clWindowText, clCaptionText,
    clActiveBorder, clInactiveBorder, clAppWorkSpace, clHighlight,
    clHighlightText, clBtnFace, clBtnShadow, clGrayText, clBtnText,
    clInactiveCaptionText, clBtnHighlight, cl3DDkShadow, cl3DLight,
    clInfoText, clInfoBk, clNone);

function TForm1.ColorToIndex(col: TColor): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to 42 do
    if Colors[i] = col then begin
      Result := i - 1;
      Exit;
    end;
end;

function TForm1.IndexToColor(index: integer): TColor;
begin
  Result := Colors[index + 1];
end;

procedure TForm1.LoadSettings;
begin
  cbReadonly.Checked := mwEdit.Readonly;
  cbHideSelection.Checked := mwEdit.HideSelection;
  cbAutoindent.Checked := mwEdit.Autoindent;
  cbWantTabs.Checked := mwEdit.WantTabs;
  inpTabIndent.Value := mwEdit.TabIndent;
  cbScrollPastEOL.Checked := mwEdit.ScrollPastEOL;
  cbHalfpageScroll.Checked := mwEdit.HalfpageScroll;
  btnFont.Caption := mwEdit.Font.Name + ' ' + IntToStr(mwEdit.Font.Size);
  inpRightEdge.Value := mwEdit.RightEdge;
  inpExtraLineSpacing.Value := mwEdit.ExtraLineSpacing;
  cbxScrollBars.ItemIndex := Ord(mwEdit.Scrollbars);
  cbxColor.ItemIndex := ColorToIndex(mwEdit.Color);
  cbxREColor.ItemIndex := ColorToIndex(mwEdit.RightEdgeColor);
  cbxForeground.ItemIndex := ColorToIndex(mwEdit.SelectedColor.Foreground);
  cbxBackground.ItemIndex := ColorToIndex(mwEdit.SelectedColor.Background);
  cbxInsertCaret.ItemIndex := Ord(mwEdit.InsertCaret);
  cbxOverwriteCaret.ItemIndex := Ord(mwEdit.OverwriteCaret);
  cbInsertMode.Checked := mwEdit.InsertMode;
  inpGutterWidth.Value := mwEdit.Gutter.Width;                                  //gp 1999-06-10
  inpDigitCount.Value := mwEdit.Gutter.DigitCount;                              //gp 1999-06-10
  inpLeftOffset.Value := mwEdit.Gutter.LeftOffset;                              //gp 1999-06-10
  inpRightOffset.Value := mwEdit.Gutter.RightOffset;                            //gp 1999-06-10
  cbLineNumbers.Checked := mwEdit.Gutter.ShowLineNumbers;                       //gp 1999-06-10
  cbLeadingZeros.Checked := mwEdit.Gutter.LeadingZeros;                         //gp 1999-06-10
  cbZeroStart.Checked := mwEdit.Gutter.ZeroStart;                               //gp 1999-06-10
  cbxGutterColor.ItemIndex := ColorToIndex(mwEdit.Gutter.Color);                //gp 1999-06-10
  cbGlyphsVisible.Checked := mwEdit.BookMarkOptions.GlyphsVisible;
  cbEnableKeys.Checked := mwEdit.BookMarkOptions.EnableKeys;
  inpLeftMargin.Value := mwEdit.BookMarkOptions.LeftMargin;
  inpXOffset.Value := mwEdit.BookmarkOptions.XOffset;
  inpMaxUndo.Value := mwEdit.MaxUndo;
  {begin}                                                                       //Carlos 1998-27-12
  cbxAttrForeground.Items.Assign(cbxColor.Items);
  cbxAttrBackground.Items.Assign(cbxColor.Items);
  cbxAttrSelect.ItemIndex := 0;
  cbxAttrSelectChange(Self);
  {end}                                                                         //Carlos 1998-27-12
end;

procedure TForm1.cbHideSelectionClick(Sender: TObject);
begin
  mwEdit.HideSelection := cbHideSelection.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.cbScrollPastEOLClick(Sender: TObject);
begin
  mwEdit.ScrollPastEOL := cbScrollPastEOL.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.inpRightEdgeChange(Sender: TObject);
begin
  try mwEdit.RightEdge := inpRightEdge.Value;
  except
  end;
  mwEdit.SetFocus;
end;

procedure TForm1.cbxScrollBarsChange(Sender: TObject);
begin
  mwEdit.Scrollbars := TScrollStyle(cbxScrollBars.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbxColorChange(Sender: TObject);
begin
  mwEdit.Color := IndexToColor(cbxColor.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbxForegroundChange(Sender: TObject);
begin
  mwEdit.SelectedColor.Foreground := IndexToColor(cbxForeground.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbxBackgroundChange(Sender: TObject);
begin
  mwEdit.SelectedColor.Background := IndexToColor(cbxBackground.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.btnFontClick(Sender: TObject);
begin
  if FontDialog1.Execute then begin
    mwEdit.Font.Assign(FontDialog1.Font);
    LoadSettings;
    mwEdit.SetFocus;
  end;
end;

procedure TForm1.cbxInsertCaretChange(Sender: TObject);
begin
  mwEdit.InsertCaret := TCaretType(cbxInsertCaret.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbxOverwriteCaretChange(Sender: TObject);
begin
  mwEdit.OverwriteCaret := TCaretType(cbxOverwriteCaret.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbInsertModeClick(Sender: TObject);
begin
  mwEdit.InsertMode := cbInsertMode.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.FormShow(Sender: TObject);
const
  first: boolean = true;
begin
  if first then begin
    first := false;
    cbxHighlighterSelect.ItemIndex := 0;
    cbxHighlighterSelectChange(Sender);
    LoadSettings;
  end;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
  inpGutterWidth.MaxValue := mwEdit.Width + 1;
  if inpGutterWidth.Value > inpGutterWidth.MaxValue then
    inpGutterWidth.Value := inpGutterWidth.MaxValue;
end;

procedure TForm1.cbxGutterColorChange(Sender: TObject);
begin
  mwEdit.Gutter.Color := IndexToColor(cbxGutterColor.ItemIndex);                //gp 1999-06-10
  mwEdit.SetFocus;
end;

procedure TForm1.inpGutterWidthChange(Sender: TObject);
begin
  try mwEdit.Gutter.Width := inpGutterWidth.Value;                              //gp 1999-06-10
  except end;
  RecalcLeftMargin;
  mwEdit.SetFocus;
end;

procedure TForm1.cbEnableKeysClick(Sender: TObject);
begin
  mwEdit.BookMarkOptions.EnableKeys := cbEnableKeys.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.cbGlyphsVisibleClick(Sender: TObject);
begin
  mwEdit.BookMarkOptions.GlyphsVisible := cbGlyphsVisible.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.inpLeftMarginChange(Sender: TObject);
begin
  try mwEdit.BookMarkOptions.LeftMargin := inpLeftMargin.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.inpMaxUndoChange(Sender: TObject);
begin
  try mwEdit.MaxUndo := inpMaxUndo.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.inpLineTextKeyPress(Sender: TObject; var Key: Char);
begin
  mwEdit.LineText := inpLineText.Text;
  mwEdit.SetFocus;
end;

procedure TForm1.mwEditClick(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbMouse.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnClick');
  LoadInfo;
end;

procedure TForm1.LoadInfo;
begin
  inpLineText.Text := mwEdit.LineText;
  inpLeftChar.Value := mwEdit.LeftChar;
  inpTopLine.Value := mwEdit.TopLine;
  inpCaretX.Value := mwEdit.CaretX;
  inpCaretY.Value := mwEdit.CaretY;
  outLineCount.Text := IntToStr(mwEdit.LineCount);
  ResetMarkButtons;
end;

procedure TForm1.inpLeftCharChange(Sender: TObject);
begin
  try mwEdit.LeftChar := inpLeftChar.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.inpTopLineChange(Sender: TObject);
begin
  try mwEdit.TopLine := inpTopLine.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.inpCaretXChange(Sender: TObject);
begin
  try mwEdit.CaretX := inpCaretX.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.inpCaretYChange(Sender: TObject);
begin
  try mwEdit.CaretY := inpCaretY.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.cbEnableEventLogClick(Sender: TObject);
begin
  mwEdit.SetFocus;
end;

procedure TForm1.mwEditDblClick(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbMouse.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnDblClick');
end;

procedure TForm1.mwEditDragDrop(Sender, Source: TObject; X, Y: Integer);
begin
  if cbEnableEventLog.Checked and cbDrag.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnDragDrop');
end;

procedure TForm1.mwEditDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  if cbEnableEventLog.Checked and cbDrag.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnDragOver');
end;

procedure TForm1.mwEditEndDrag(Sender, Target: TObject; X, Y: Integer);
begin
  if cbEnableEventLog.Checked and cbDrag.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnEndDrag');
end;

procedure TForm1.mwEditExit(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnExit');
end;

procedure TForm1.mwEditKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnKeyDown');
end;

procedure TForm1.mwEditKeyPress(Sender: TObject; var Key: Char);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnKeyPress');
end;

procedure TForm1.mwEditPaint(Sender: TObject; ACanvas: TCanvas);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnPaint');
end;

procedure TForm1.mwEditStartDrag(Sender: TObject;
  var DragObject: TDragObject);
begin
  if cbEnableEventLog.Checked and cbDrag.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnStartDrag');
end;

{begin}                                                                         //Carlos 1998-27-12

procedure TForm1.cbxAttrSelectChange(Sender: TObject);
var
  Attr: TmwHighLightAttributes;
begin
  Attr := TmwHighLightAttributes.Create('');
  try                                                                           //pv 1999-07-06
    if assigned(mwEdit.Highlighter) then
      Attr.Assign(mwEdit.Highlighter.Attribute[cbxAttrSelect.ItemIndex]);
    cbxAttrForeground.ItemIndex := ColorToIndex(Attr.Foreground);
    cbxAttrBackground.ItemIndex := ColorToIndex(Attr.Background);
    cbStyleBold.Checked := (fsBold in Attr.Style);
    cbStyleItalic.Checked := (fsItalic in Attr.Style);
    cbStyleUnderLine.Checked := (fsUnderline in Attr.Style);
    cbStyleStrikeOut.Checked := (fsStrikeOut in Attr.Style);
  finally                                                                       //pv 1999-07-06
    Attr.Free;
  end;
end;

procedure TForm1.cbxAttrBackgroundChange(Sender: TObject);
var
  Attr: TmwHighLightAttributes;
  AttrStyle: TFontStyles;
begin
  Attr := TmwHighLightAttributes.Create(cbxAttrSelect.Items[cbxAttrSelect.ItemIndex]);
  try                                                                           //mh 1999-09-12
    AttrStyle := [];
    Attr.Foreground := IndexToColor(cbxAttrForeground.ItemIndex);
    Attr.Background := IndexToColor(cbxAttrBackground.ItemIndex);
    if cbStyleBold.Checked then
      Include(AttrStyle, fsBold);
    if cbStyleItalic.Checked then
      Include(AttrStyle, fsItalic);
    if cbStyleUnderLine.Checked then
      Include(AttrStyle, fsUnderline);
    if cbStyleStrikeOut.Checked then
      Include(AttrStyle, fsStrikeOut);
    Attr.Style := AttrStyle;
    if Assigned(mwEdit.HighLighter) then                                        //mh 1999-09-12
      mwEdit.HighLighter.Attribute[cbxAttrSelect.ItemIndex].Assign(Attr);
    mwEdit.Invalidate;
  finally                                                                       //mh 1999-09-12
    Attr.Free;
  end;
end;

procedure TForm1.cbCommentsCClick(Sender: TObject);
var
  CmntSet: CommentStyles;
begin
  CmntSet := [];
  if cbCommentsAnsi.Checked then Include(CmntSet, csAnsiStyle);
  if cbCommentsPas.Checked  then Include(CmntSet, csPasStyle);
  if cbCommentsC.Checked    then Include(CmntSet, csCStyle);
  if cbCommentsAsm.Checked  then Include(CmntSet, csAsmStyle);
  if cbCommentsBas.Checked  then Include(CmntSet, csBasStyle);
  (mwEdit.HighLighter as TmwGeneralSyn).Comments := CmntSet;
  mwEdit.Invalidate;
end;

procedure TForm1.btnKeywordsClick(Sender: TObject);
begin
  form2.lbKeywords.Items.Assign((mwEdit.HighLighter as TmwGeneralSyn).Keywords);
  if Form2.ShowModal = mrOk then
    (mwEdit.HighLighter as TmwGeneralSyn).Keywords := Form2.lbKeywords.Items;
end;

{end}                                                                           //Carlos 1998-27-12

procedure TForm1.mwEditProcessCommand(var Command: TmwEditorCommand;
  var AChar: Char; Data: Pointer);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnProcessCommand');
end;

procedure TForm1.mwEditProcessUserCommand(var Command: TmwEditorCommand;
  var AChar: Char; Data: Pointer);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnProcessUserCommand');
end;

procedure TForm1.btnSaveToRegClick(Sender: TObject);
begin
  if mwEdit.Highlighter.SaveToRegistry(HKEY_CURRENT_USER,'\Software\mwEdit team\Highlighters\'+cbxHighlighterSelect.Text)
    then StatusBar.SimpleText := 'Success'
    else StatusBar.SimpleText := 'Failure';
end;

procedure TForm1.btnLoadFromRegClick(Sender: TObject);
begin
  if mwEdit.Highlighter.LoadFromRegistry(HKEY_CURRENT_USER,'\Software\mwEdit team\Highlighters\'+cbxHighlighterSelect.Text) then begin
    StatusBar.SimpleText := 'Success';
    cbxAttrSelectChange(Self);
  end
  else StatusBar.SimpleText := 'Failure';
end;

procedure TForm1.UpdateKeystrokesList;
var
  x: integer;
begin
  KeyCmdList.Items.BeginUpdate;
  try
    KeyCmdList.Items.Clear;
    for x := 0 to mwEdit.Keystrokes.Count-1 do
    begin
      with KeyCmdList.Items.Add do
      begin
        Caption := EditorCommandToCodeString(mwEdit.Keystrokes[x].Command);
        if mwEdit.Keystrokes[x].ShortCut = 0 then
          SubItems.Add('<none>')
        else
          SubItems.Add(Menus.ShortCutToText(mwEdit.Keystrokes[x].ShortCut));
      end;
    end;
  finally
    KeyCmdList.Items.EndUpdate;
  end;
end;

procedure TForm1.btnEditClick(Sender: TObject);
var
  Dlg: TmwKeystrokesEditorForm;
begin
  Application.CreateForm(TmwKeystrokesEditorForm, Dlg);
  try
    Dlg.Caption := 'mwEdit Keystroke Editor';
    Dlg.Keystrokes := mwEdit.Keystrokes;
    if Dlg.ShowModal = mrOk then
    begin
      mwEdit.Keystrokes := Dlg.Keystrokes;
      UpdateKeystrokesList;
    end;
  finally
    Dlg.Free;
  end;
end;

procedure TForm1.cbInternalImagesClick(Sender: TObject);
begin
  RebuildMarks;
  mwEdit.SetFocus;
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
var
  mark: TMark;
begin
  if not disableMarkButtons then begin
    with mwEdit do begin
      Marks.ClearLine(CaretY);
      if (Sender as TSpeedButton).Down then begin
        mark := TMark.Create(mwEdit);
        with mark do begin
          Line := CaretY;
          Column := CaretX;
          ImageIndex := (Sender as TSpeedButton).Tag;
          IsBookmark := false;
          Visible := true;
          InternalImage := (BookmarkImages = nil);
        end;
        Marks.Place(mark);
      end;
    end;
  end;
end;

procedure TForm1.mwEditPlaceMark(var mark: TMark);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnPlaceMark');
  if mark.IsBookmark then mark.InternalImage := cbInternalImages.Checked;
end;

procedure TForm1.ResetMarkButtons;
var
  marks: TMarks;
  i: integer;
begin
  disableMarkButtons := true;
  try
    mwEdit.Marks.GetMarksForLine(mwEdit.CaretY,marks);
    for i := 0 to 4 do markButtons[i].Down := false;
    for i := 1 to maxMarks do begin
      if not assigned(marks[i]) then break;
      if not marks[i].IsBookmark then
        markButtons[marks[i].ImageIndex-10].Down := true;
    end;
  finally disableMarkButtons := false; end;
end;

procedure TForm1.inpXOffsetChange(Sender: TObject);
begin
  try mwEdit.BookMarkOptions.XOffset := inpXOffset.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.RebuildMarks;
var
  i: integer;
begin
  with mwEdit do begin
    BeginUpdate;
    try
      for i := 0 to Marks.Count-1 do
        with Marks[i] do
          if IsBookmark then InternalImage := cbInternalImages.Checked;
    finally EndUpdate; end;
  end;
end;

procedure TForm1.inpExtraLineSpacingChange(Sender: TObject);
begin
  try mwEdit.ExtraLineSpacing := inpExtraLineSpacing.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.btnRedoClick(Sender: TObject);
begin
  mwEdit.Redo;
  mwEdit.SetFocus;
end;

procedure TForm1.btnPrintClick(Sender: TObject);
var
  Options: TmwPrintOptions;
begin
  Options.SelectedOnly := mwEdit.SelAvail;
  Options.Highlighted := mwEdit.HighLighter <> NIL;
  Options.WrapLongLines := FALSE; // Not implemented yet!
  Options.Copies := 1;
  Options.PrintRange := Rect(0,0,0,0); // Not using it here.
  Options.MarginUnits := muThousandthsOfInches;
  Options.Margins := Rect(500, 500, 500, 500); // 1/2 inch margins
{ For you metric folks.
  Options.MarginUnits := muMillimeters;
  Options.Margins := Rect(30,30,30,30); // 3 centimeter margins
}
  Options.Header := TStringList.Create;
  Options.Footer := TStringList.Create;
  {begin}                                                                       //hdl 1999-05-11
  try
    Options.Title := 'This is title';

    Options.Header.AddObject('Title: $title$', TObject(hfaCenter));
    Options.Header.AddObject('Printing Time and Date: $time$ $date$',TObject(hfaLeft));
    Options.Header.Add('');

    Options.Footer.Add('');
    Options.Footer.AddObject('Page Number: $pagenum$ Printing Date/Time: $datetime$', TObject(hfaRight));
  {end}                                                                         //hdl 1999-05-11
    // Use whatever font the editor has.
    mwEdit.Print(NIL, Options);
  finally
    Options.Header.Free;
    Options.Footer.Free;
  end;
end;

procedure TForm1.mwEditCommandDone(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbKeyboard.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnCommandDone');
end;

procedure TForm1.mwEditPrintStatus(Sender: TComponent;
  Status: TmwPrintStatus; PageNumber: Integer; var Abort: Boolean);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnPrintStatus');
end;

procedure TForm1.cbLineNumbersClick(Sender: TObject);
begin
  mwEdit.Gutter.ShowLineNumbers := cbLineNumbers.Checked;                       //gp 1999-06-10
  mwEdit.SetFocus;
end;

procedure TForm1.cbLeadingZerosClick(Sender: TObject);
begin
  mwEdit.Gutter.LeadingZeros := cbLeadingZeros.Checked;                         //gp 1999-06-10
  mwEdit.SetFocus;
end;

procedure TForm1.cbZeroStartClick(Sender: TObject);
begin
  mwEdit.Gutter.ZeroStart := cbZeroStart.Checked;                               //gp 1999-06-10
  mwEdit.SetFocus;
end;

procedure TForm1.mwEditMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if cbEnableEventLog.Checked and cbMouse.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnMouseDown');
end;

procedure TForm1.mwEditMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if cbEnableEventLog.Checked and cbMouse.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnMouseMove');
end;

procedure TForm1.mwEditMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if cbEnableEventLog.Checked and cbMouse.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnMouseUp');
end;

procedure TForm1.btnClearClick(Sender: TObject);
begin
  lbEventLog.Clear;
end;

procedure TForm1.cbAutoindentClick(Sender: TObject);
begin
  mwEdit.Autoindent := cbAutoindent.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.cbxREColorChange(Sender: TObject);
begin
  mwEdit.RightEdgeColor := IndexToColor(cbxREColor.ItemIndex);
  mwEdit.SetFocus;
end;

procedure TForm1.cbHalfpageScrollClick(Sender: TObject);
begin
  mwEdit.HalfpageScroll := cbHalfpageScroll.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.inpTabIndentChange(Sender: TObject);
begin
  try mwEdit.TabIndent := inpTabIndent.Value;
  except end;
  mwEdit.SetFocus;
end;

procedure TForm1.cbWantTabsClick(Sender: TObject);
begin
  mwEdit.WantTabs := cbWantTabs.Checked;
  mwEdit.SetFocus;
end;

procedure TForm1.mwEditSelectionChange(Sender: TObject);
begin
  if cbEnableEventLog.Checked and cbOther.Checked then
    lbEventLog.Items.Insert(0, TimeToStr(Now) + ' OnSelectionChange');
end;

procedure TForm1.inpDigitCountChange(Sender: TObject);
begin
  try mwEdit.Gutter.DigitCount := inpDigitCount.Value;
  except end;
  RecalcLeftMargin;
  mwEdit.SetFocus;
end;

procedure TForm1.inpLeftOffsetChange(Sender: TObject);
begin
  try mwEdit.Gutter.LeftOffset := inpLeftOffset.Value;
  except end;
  RecalcLeftMargin;
  mwEdit.SetFocus;
end;

procedure TForm1.inpRightOffsetChange(Sender: TObject);
begin
  try mwEdit.Gutter.RightOffset := inpRightOffset.Value;
  except end;
  RecalcLeftMargin;
  mwEdit.SetFocus;
end;

procedure TForm1.RecalcLeftMargin;
begin
  inpLeftMargin.MaxValue := mwEdit.Gutter.Width;
  if inpLeftMargin.Value > inpLeftMargin.MaxValue then
    inpLeftMargin.Value := inpLeftMargin.MaxValue;
end;

procedure TForm1.cbxExporterSelectChange(Sender: TObject);
begin
  btnExportToClip.Enabled := cbxExporterSelect.ItemIndex > 0;
  btnExportAllToClip.Enabled := btnExportToClip.Enabled;
end;

procedure TForm1.btnExportToClipClick(Sender: TObject);
var
  i: integer;
begin
  mwEdit.Highlighter.Exporter := nil;
  for i := 0 to ComponentCount-1 do
    if (Components[i] is TmwCustomExport) and
       ((Components[i] as TmwCustomExport).ExporterName = cbxExporterSelect.Text) then begin
      mwEdit.Highlighter.Exporter := (Components[i] as TmwCustomExport);
      break;
    end;
  if assigned(mwEdit.Highlighter.Exporter) then begin
    if Sender = btnExportAllToClip then mwEdit.SelectAll;
    TmwCustomExport(mwEdit.Highlighter.Exporter).CopyToClipboard(mwEdit,mwEdit.Highlighter);
    mwEdit.Highlighter.Exporter := nil;
    if Sender = btnExportAllToClip then mwEdit.BlockEnd := mwEdit.BlockBegin;
  end;
end;

procedure TForm1.btnSearchClick(Sender: TObject);
begin
  FindDialog1.Execute;
  btnSearchNext.Enabled := TRUE;
  btnSearchPrev.Enabled := TRUE;
end;

procedure TForm1.btnSearchNextClick(Sender: TObject);
begin
  if (Sender = btnSearchNext) then
    FindDialog1.Options := FindDialog1.Options + [frDown]
  else if (Sender = btnSearchPrev) then
    FindDialog1.Options := FindDialog1.Options - [frDown];
  DoFindText(Sender);
  mwEdit.SetFocus;
end;

procedure TForm1.DoFindText(Sender: TObject);
var rOptions: TmwSearchOptions;
    dlg: TFindDialog;
    sSearch: string;
begin
  if Sender = ReplaceDialog1 then dlg := ReplaceDialog1
                             else dlg := FindDialog1;
  sSearch := dlg.FindText;
  if Length(sSearch) = 0 then begin
    Beep;
    lblSearchResult.Caption := 'Can''t search for empty text!';
    lblSearchResult.Visible := TRUE;
  end else begin
    rOptions := [];
    if not (frDown in dlg.Options) then
      Include(rOptions, mwsoBackwards);
    if frMatchCase in dlg.Options then
      Include(rOptions, mwsoMatchCase);
    if frWholeWord in dlg.Options then
      Include(rOptions, mwsoWholeWord);
    if mwEdit.SearchReplace(sSearch, '', rOptions) = 0 then begin
      Beep;
      lblSearchResult.Caption := 'SearchText ''' + sSearch + ''' not found!';
      lblSearchResult.Visible := TRUE;
    end else
      lblSearchResult.Visible := FALSE;
  end;
end;

procedure TForm1.btnReplaceClick(Sender: TObject);
begin
  ReplaceDialog1.Execute;
end;

procedure TForm1.DoReplaceText(Sender: TObject);
var rOptions: TmwSearchOptions;
    sSearch: string;
begin
  sSearch := ReplaceDialog1.FindText;
  if Length(sSearch) = 0 then begin
    Beep;
    lblSearchResult.Caption := 'Can''t replace an empty text!';
    lblSearchResult.Visible := TRUE;
  end else begin
    rOptions := [mwsoReplace];
    if frMatchCase in ReplaceDialog1.Options then
      Include(rOptions, mwsoMatchCase);
    if frWholeWord in ReplaceDialog1.Options then
      Include(rOptions, mwsoWholeWord);
    if frReplaceAll in ReplaceDialog1.Options then
      Include(rOptions, mwsoReplaceAll);
    if mwEdit.SearchReplace(sSearch, ReplaceDialog1.ReplaceText, rOptions) = 0
    then begin
      Beep;
      lblSearchResult.Caption := 'SearchText ''' + sSearch +
                                 ''' could not be replaced!';
      lblSearchResult.Visible := TRUE;
    end else
      lblSearchResult.Visible := FALSE;
  end;
end;

end.

   