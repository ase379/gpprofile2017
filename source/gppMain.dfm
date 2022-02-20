object frmMain: TfrmMain
  Left = 312
  Top = 179
  Caption = 'GpProfile'
  ClientHeight = 640
  ClientWidth = 1484
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar: TStatusBar
    Left = 0
    Top = 616
    Width = 1484
    Height = 24
    Panels = <
      item
        Width = 650
      end
      item
        Width = 0
      end>
    ParentFont = True
    UseSystemFont = False
    OnResize = StatusBarResize
  end
  object Panel0: TPanel
    Left = 0
    Top = 0
    Width = 1484
    Height = 616
    Align = alClient
    BevelEdges = []
    BevelOuter = bvNone
    TabOrder = 1
    object splitSourcePreview: TSplitter
      Left = 0
      Top = 492
      Width = 1484
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      OnMoved = splitCallersMoved
      ExplicitTop = 340
      ExplicitWidth = 612
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 1484
      Height = 492
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 1484
        Height = 492
        ActivePage = tabPerformanceAnalysis
        Align = alClient
        HotTrack = True
        TabOrder = 0
        OnChange = PageControl1Change
        ExplicitTop = -3
        object tabInstrumentation: TTabSheet
          Caption = 'Source Code Instrumentation'
          ImageIndex = 16
          object tbrInstrument: TToolBar
            Left = 0
            Top = 0
            Width = 1476
            Height = 52
            AutoSize = True
            ButtonHeight = 52
            ButtonWidth = 132
            Caption = 'ToolBar1'
            EdgeInner = esNone
            EdgeOuter = esNone
            Images = imgListInstrumentationSmall
            ParentShowHint = False
            ShowCaptions = True
            ShowHint = True
            TabOrder = 0
            object btnOpenProject: TToolButton
              Left = 0
              Top = 0
              Action = actOpen
              DropdownMenu = popRecent
              Style = tbsDropDown
            end
            object btnRescanProject: TToolButton
              Left = 147
              Top = 0
              Action = actRescanProject
              ImageIndex = 1
              Style = tbsTextButton
            end
            object btnInstrumentDelimiter1: TToolButton
              Left = 279
              Top = 0
              Width = 5
              Caption = 'btnInstrumentDelimiter1'
              ImageIndex = 9
              Style = tbsSeparator
            end
            object btnInstrument: TToolButton
              Left = 284
              Top = 0
              Action = actInstrument
              ImageIndex = 3
              Style = tbsTextButton
            end
            object btnRemoveInstrumentation: TToolButton
              Left = 416
              Top = 0
              Action = actRemoveInstrumentation
              ImageIndex = 4
              Style = tbsTextButton
            end
            object btnInstrumentDelimiter2: TToolButton
              Left = 548
              Top = 0
              Width = 5
              Caption = 'btnInstrumentDelimiter2'
              ImageIndex = 9
              Style = tbsSeparator
            end
            object btnLoadSelection: TToolButton
              Left = 553
              Top = 0
              Action = actLoadInstrumentationSelection
              DropdownMenu = popRecentGis
              ImageIndex = 6
              Style = tbsDropDown
            end
            object btnSaveSelection: TToolButton
              Left = 700
              Top = 0
              Action = actSaveInstrumentationSelection
              ImageIndex = 7
            end
            object btnInstrumentDelimiter3: TToolButton
              Left = 832
              Top = 0
              Width = 8
              Caption = 'btnInstrumentDelimiter3'
              ImageIndex = 9
              Style = tbsSeparator
            end
            object btnProjectOptions: TToolButton
              Left = 840
              Top = 0
              Action = actProjectOptions
              ParentShowHint = False
              ShowHint = True
              Style = tbsTextButton
            end
          end
        end
        object tabPerformanceAnalysis: TTabSheet
          Caption = 'Performance Analysis'
          ImageIndex = 17
          object tbrAnalysis: TToolBar
            Left = 0
            Top = 0
            Width = 1476
            Height = 52
            AutoSize = True
            ButtonHeight = 52
            ButtonWidth = 94
            Caption = 'ToolBar1'
            EdgeInner = esNone
            EdgeOuter = esNone
            Images = imgListAnalysisSmall
            ParentShowHint = False
            ShowCaptions = True
            ShowHint = True
            TabOrder = 0
            object btnOpenProfile: TToolButton
              Left = 0
              Top = 0
              Action = actOpenProfile
              DropdownMenu = popRecentPrf
              ImageIndex = 0
              Style = tbsDropDown
            end
            object btnRescanProfile: TToolButton
              Left = 109
              Top = 0
              Action = actRescanProfile
              ImageIndex = 1
            end
            object btnAnalysisDelimiter1: TToolButton
              Left = 203
              Top = 0
              Width = 5
              Caption = 'btnAnalysisDelimiter1'
              ImageIndex = 10
              Style = tbsSeparator
            end
            object btnRenameMoveProfile: TToolButton
              Left = 208
              Top = 0
              Action = actRenameMoveProfile
              ImageIndex = 2
            end
            object btnMakeCopyProfile: TToolButton
              Left = 302
              Top = 0
              Action = actMakeCopyProfile
              ImageIndex = 3
            end
            object btnDelUndelProfile: TToolButton
              Left = 396
              Top = 0
              Action = actDelUndelProfile
              ImageIndex = 4
            end
            object btnExportProfile: TToolButton
              Left = 490
              Top = 0
              Action = actExportProfile
              ImageIndex = 5
            end
          end
        end
      end
    end
    object pnlSourcePreview: TPanel
      Left = 0
      Top = 495
      Width = 1484
      Height = 121
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object sourceCodeEdit: TSynEdit
        Left = 0
        Top = 0
        Width = 1484
        Height = 121
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        CodeFolding.GutterShapeSize = 11
        CodeFolding.CollapsedLineColor = clGrayText
        CodeFolding.FolderBarLinesColor = clGrayText
        CodeFolding.IndentGuidesColor = clGray
        CodeFolding.IndentGuides = True
        CodeFolding.ShowCollapsedLine = False
        CodeFolding.ShowHintMark = True
        UseCodeFolding = False
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Courier New'
        Gutter.Font.Style = []
        Gutter.ShowLineNumbers = True
        Highlighter = SynPasSyn
        Lines.Strings = (
          'sourceCodeEdit')
        FontSmoothing = fsmNone
      end
    end
  end
  object pnlLayout: TPanel
    Left = 947
    Top = 224
    Width = 162
    Height = 100
    Hint = 'Layout Manager'
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 2
    Visible = False
    object SpeedButton1: TSpeedButton
      Left = 146
      Top = 3
      Width = 13
      Height = 12
      Hint = 'Close Layout Manager'
      Glyph.Data = {
        16010000424D1601000000000000360000002800000009000000080000000100
        180000000000E000000000000000000000000000000000000000C6C6C6C6C6C6
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C600C6C6C6C6C6C6C6C6C6C6
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C600C6C6C6000000000000C6C6C6C6C6
        C6000000000000C6C6C6C6C6C600C6C6C6C6C6C6000000000000000000000000
        C6C6C6C6C6C6C6C6C600C6C6C6C6C6C6C6C6C6000000000000C6C6C6C6C6C6C6
        C6C6C6C6C600C6C6C6C6C6C6000000000000000000000000C6C6C6C6C6C6C6C6
        C600C6C6C6000000000000C6C6C6C6C6C6000000000000C6C6C6C6C6C600C6C6
        C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6C6B4}
      OnClick = SpeedButton1Click
    end
    object inpLayoutName: TEdit
      Left = 3
      Top = 3
      Width = 89
      Height = 21
      Hint = 'Layout Name'
      TabOrder = 0
      OnKeyPress = inpLayoutNameKeyPress
    end
    object BtnDeleteLayout: TButton
      Left = 94
      Top = 80
      Width = 65
      Height = 17
      Action = actDelLayout
      TabOrder = 1
    end
    object btnActivateLayout: TButton
      Left = 94
      Top = 63
      Width = 65
      Height = 17
      Action = actChangeLayout
      TabOrder = 2
    end
    object btnRenameLayout: TButton
      Left = 94
      Top = 46
      Width = 65
      Height = 17
      Action = actRenameLayout
      TabOrder = 3
    end
    object btnAddLayout: TButton
      Left = 94
      Top = 29
      Width = 65
      Height = 17
      Action = actAddLayout
      TabOrder = 5
    end
    object lvLayouts: TListView
      Left = 3
      Top = 24
      Width = 89
      Height = 73
      Hint = 'Layouts'
      Columns = <
        item
          Caption = 'Name'
          MaxWidth = 69
          MinWidth = 69
          Width = 69
        end>
      ReadOnly = True
      RowSelect = True
      ShowColumnHeaders = False
      SmallImages = imglListViews
      SortType = stText
      TabOrder = 4
      ViewStyle = vsReport
      OnClick = lbLayoutsClick
      OnDblClick = lbLayoutsDblClick
      OnSelectItem = lvLayoutsSelectItem
    end
  end
  object ActionList1: TActionList
    Left = 413
    Top = 118
    object actInstrument: TAction
      Category = 'Project'
      Caption = '&Instrument'
      Enabled = False
      Hint = 'Instrument'
      ImageIndex = 2
      ShortCut = 16457
      OnExecute = actInstrumentExecute
    end
    object actOpen: TAction
      Category = 'Project'
      Caption = '&Open...'
      Hint = 'Open project'
      ImageIndex = 0
      ShortCut = 16463
      OnExecute = actOpenExecute
    end
    object actExit: TAction
      Category = 'GpProfile'
      Caption = 'E&xit'
      Hint = 'Exit'
      ShortCut = 32856
      OnExecute = actExitExecute
    end
    object actPreferences: TAction
      Category = 'GpProfile'
      Caption = 'P&references...'
      Hint = 'Preferences'
      ImageIndex = 1
      OnExecute = actPreferencesExecute
    end
    object actRemoveInstrumentation: TAction
      Category = 'Project'
      Caption = '&Remove Instrumentation'
      Enabled = False
      Hint = 'Remove instrumentation'
      ImageIndex = 3
      ShortCut = 16497
      OnExecute = actRemoveInstrumentationExecute
    end
    object actRescanProject: TAction
      Category = 'Project'
      Caption = '&Rescan'
      Enabled = False
      Hint = 'Rescan project'
      ImageIndex = 5
      ShortCut = 116
      OnExecute = actRescanProjectExecute
    end
    object actOpenProfile: TAction
      Category = 'Profile'
      Caption = '&Open...'
      Hint = 'Open profile'
      ImageIndex = 6
      ShortCut = 16506
      OnExecute = actOpenProfileExecute
    end
    object actHideNotExecuted: TAction
      Category = 'Analysis'
      Caption = '&Hide not executed'
      Checked = True
      Enabled = False
      OnExecute = actHideNotExecutedExecute
    end
    object actProjectOptions: TAction
      Category = 'Project'
      Caption = 'Op&tions...'
      Enabled = False
      Hint = 'Project options'
      ImageIndex = 8
      OnExecute = actProjectOptionsExecute
    end
    object actProfileOptions: TAction
      Category = 'Profile'
      Caption = 'Op&tions...'
      Enabled = False
      Hint = 'Profile options'
      ImageIndex = 9
    end
    object actRescanProfile: TAction
      Category = 'Profile'
      Caption = '&Rescan'
      Enabled = False
      Hint = 'Rescan profile'
      ImageIndex = 10
      OnExecute = actRescanProfileExecute
    end
    object actExportProfile: TAction
      Category = 'Profile'
      Caption = 'E&xport...'
      Enabled = False
      Hint = 'Export profile'
      ImageIndex = 11
      OnExecute = actExportProfileExecute
    end
    object actMakeCopyProfile: TAction
      Category = 'Profile'
      Caption = 'Make a &Copy...'
      Enabled = False
      Hint = 'Make a copy of profile'
      ImageIndex = 12
      OnExecute = actMakeCopyProfileExecute
    end
    object actRenameMoveProfile: TAction
      Category = 'Profile'
      Caption = 'Rename/&Move...'
      Enabled = False
      Hint = 'Rename or move profile'
      ImageIndex = 13
      OnExecute = actRenameMoveProfileExecute
    end
    object actDelUndelProfile: TAction
      Category = 'Profile'
      Caption = '&Delete'
      Enabled = False
      Hint = 'Delete profile'
      ImageIndex = 14
      OnExecute = actDelUndelProfileExecute
    end
    object actRescanChanged: TAction
      Category = 'Project'
      Caption = 'actRescanChanged'
      Enabled = False
      ImageIndex = 26
      OnExecute = actRescanChangedExecute
    end
    object actChangeLayout: TAction
      Category = 'Layout'
      Caption = 'Activate'
      Hint = 'Activate layout'
      OnExecute = actChangeLayoutExecute
      OnUpdate = actChangeLayoutUpdate
    end
    object actAddLayout: TAction
      Category = 'Layout'
      Caption = 'Add'
      Hint = 'Add layout'
      OnExecute = actAddLayoutExecute
      OnUpdate = actAddLayoutUpdate
    end
    object actDelLayout: TAction
      Category = 'Layout'
      Caption = 'Delete'
      Hint = 'Delete layout'
      OnExecute = actDelLayoutExecute
      OnUpdate = actDelLayoutUpdate
    end
    object actRenameLayout: TAction
      Category = 'Layout'
      Caption = 'Rename'
      Hint = 'Rename layout'
      OnExecute = actRenameLayoutExecute
      OnUpdate = actRenameLayoutUpdate
    end
    object actLayoutManager: TAction
      Category = 'GpProfile'
      Caption = '&Layout Manager...'
      Hint = 'Layout Manager'
      ImageIndex = 18
      OnExecute = actLayoutManagerExecute
    end
    object actHelpContents: TAction
      Category = 'Help'
      Caption = '&Contents'
      Hint = 'Help contents'
      ImageIndex = 19
      OnExecute = actHelpContentsExecute
    end
    object actHelpShortcutKeys: TAction
      Category = 'Help'
      Caption = '&Shortcuts'
      Hint = 'Help on shortcut keys'
      OnExecute = actHelpShortcutKeysExecute
    end
    object actHelpAbout: TAction
      Category = 'Help'
      Caption = '&About'
      Hint = 'About GpProfile'
      OnExecute = actHelpAboutExecute
    end
    object actHelpQuickStart: TAction
      Category = 'Help'
      Caption = '&Quick Start'
      Hint = 'Quick start'
      OnExecute = actHelpQuickStartExecute
    end
    object actShowHideSourcePreview: TAction
      Category = 'Layout'
      Caption = 'Hide &Source Preview'
      Hint = 'Hide source preview'
      ImageIndex = 20
      OnExecute = actShowHideSourcePreviewExecute
    end
    object actShowHideCallers: TAction
      Tag = 1
      Category = 'Layout'
      Caption = 'Show &Callers'
      Hint = 'Show callers'
      ImageIndex = 23
      OnExecute = actShowHideCallersExecute
      OnUpdate = actShowHideCallersUpdate
    end
    object actShowHideCallees: TAction
      Tag = 1
      Category = 'Layout'
      Caption = 'Show Calle&d'
      Hint = 'Show called'
      ImageIndex = 25
      OnExecute = actShowHideCalleesExecute
      OnUpdate = actShowHideCalleesUpdate
    end
    object actHelpOpenHome: TAction
      Category = 'Help'
      Caption = '&Home Page'
    end
    object actHelpWriteMail: TAction
      Category = 'Help'
      Caption = '&E-Mail Author'
    end
    object actHelpVisitForum: TAction
      Category = 'Help'
      Caption = 'Forum'
    end
    object actHelpJoinMailingList: TAction
      Category = 'Help'
      Caption = 'Mailing List'
    end
    object actLoadInstrumentationSelection: TAction
      Category = 'Project'
      Caption = 'Load Selection...'
      Enabled = False
      OnExecute = actLoadInstrumentationSelectionExecute
    end
    object actSaveInstrumentationSelection: TAction
      Category = 'Project'
      Caption = 'Save Selection...'
      Enabled = False
      OnExecute = actSaveInstrumentationSelectionExecute
    end
    object Action1: TAction
      Caption = 'Action1'
    end
    object Action2: TAction
      Caption = 'Action2'
    end
    object actShowPerformanceData: TAction
      Category = 'Profile'
      AutoCheck = True
      Caption = 'Performance'
      Checked = True
      Enabled = False
      ImageIndex = 7
    end
    object actShowMemoryData: TAction
      Category = 'Profile'
      Caption = 'Memory'
      Enabled = False
      ImageIndex = 8
    end
  end
  object popRecent: TPopupMenu
    Left = 197
    Top = 294
  end
  object MRU: TGPMRUFiles
    PopupMenu = popRecent
    MaxFiles = 9
    StandAloneMenu = True
    DeleteEntry = False
    OnClick = MRUClick
    Left = 107
    Top = 134
  end
  object MainMenu1: TMainMenu
    Left = 609
    Top = 206
    object GpProfile1: TMenuItem
      Caption = '&GpProfile'
      object Preferences1: TMenuItem
        Action = actPreferences
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Exit1: TMenuItem
        Action = actExit
      end
    end
    object Layout1: TMenuItem
      Caption = '&Layout'
      object ShowSourcePreview1: TMenuItem
        Action = actShowHideSourcePreview
      end
      object HideCallers1: TMenuItem
        Action = actShowHideCallers
      end
      object HideCalled1: TMenuItem
        Action = actShowHideCallees
      end
      object N7: TMenuItem
        Caption = '-'
      end
      object LayoutManager1: TMenuItem
        Action = actLayoutManager
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      object Contents1: TMenuItem
        Action = actHelpContents
      end
      object QuickStart1: TMenuItem
        Action = actHelpQuickStart
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object GpProfileHomePage1: TMenuItem
        Action = actHelpOpenHome
      end
      object WriteMailtoAuthor1: TMenuItem
        Action = actHelpWriteMail
      end
      object Mailinglist1: TMenuItem
        Action = actHelpJoinMailingList
      end
      object Forum1: TMenuItem
        Action = actHelpVisitForum
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object About1: TMenuItem
        Action = actHelpAbout
      end
    end
  end
  object popDelphiVer: TPopupMenu
    Left = 189
    Top = 180
  end
  object popRecentPrf: TPopupMenu
    Left = 197
    Top = 234
  end
  object MRUPrf: TGPMRUFiles
    PopupMenu = popRecentPrf
    MaxFiles = 9
    StandAloneMenu = True
    DeleteEntry = False
    OnClick = MRUPrfClick
    Left = 107
    Top = 164
  end
  object popLayout: TPopupMenu
    Left = 293
    Top = 270
  end
  object imglListViews: TImageList
    Left = 983
    Top = 124
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600C6C6C600C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FF000000000000000000000000000000000000000000000000
      0000000000000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600FFFFFF00FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000FFFF0000FF000000FF000000FF
      000000FF000000FF000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000FFFF0000FF0000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600FFFFFF00FFFFFF0000000000FFFFFF000000
      0000FFFFFF0000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600000000000000
      000000000000C6C6C600000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000
      00000000000000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      000000FF000000FF000000FF000000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00C6C6C6000000
      00000000000000000000000000000000000000FFFF0000FF000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      000000FFFF0000FFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      00000000000000000000000000000000000000FFFF0000FF0000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FF000000FF000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFF8010000FFFFFFFFF0000000
      FC03FC0380000000FC03FC0300000000C003C00300000000C003C00300000000
      C003C00300000000C003C00100000000C003C00100000000C003C00100000000
      C003C00300000000C01FC01F00000000C01FC01F00010000C01FC01F00070000
      FFFFFFFF00070000FFFFFFFF800F000000000000000000000000000000000000
      000000000000}
  end
  object SynPasSyn: TSynPasSyn
    DefaultFilter = 'Pascal files (*.pas,*.inc)|*.PAS;*.INC'
    Options.AutoDetectEnabled = False
    Options.AutoDetectLineLimit = 0
    Options.Visible = False
    AsmAttri.Background = clWindow
    AsmAttri.Foreground = clWindowText
    CommentAttri.Background = clWindow
    CommentAttri.Foreground = clWindowText
    IdentifierAttri.Background = clWindow
    IdentifierAttri.Foreground = clWindowText
    KeyAttri.Background = clWindow
    KeyAttri.Foreground = clWindowText
    NumberAttri.Background = clWindow
    NumberAttri.Foreground = clWindowText
    SpaceAttri.Background = clWindow
    SpaceAttri.Foreground = clWindowText
    StringAttri.Background = clWindow
    StringAttri.Foreground = clWindowText
    SymbolAttri.Background = clWindow
    SymbolAttri.Foreground = clWindowText
    Left = 235
    Top = 134
  end
  object ImageListMedium: TImageList
    Height = 32
    Width = 32
    Left = 95
    Top = 246
    Bitmap = {
      494C010102000800040020002000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000800000002000000001002000000000000040
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F5F0EA40EBE1D680EBE1D680EBE1D680EBE1D680EBE1D680EBE1
      D680EBE1D680EBE1D680EBE1D680EBE1D680EBE1D680EBE1D680EBE1D680EBE1
      D680EBE1D680EBE1D680EBE1D680F5F0EA400000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F1E7DF2DF9F5F213000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EBE1D6805C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E1C9B866D9AB89C8F4EBE4260000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EBE1D6805C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F1E6DD32DBB395B0D8A075F7D89F
      73FFD89F73FFD89F73FFEFB68AFFDBA67EE9ECDCD04400000000CA9064FFD89F
      73FCDAAC8AC8ECDBCE4900000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EBE1D6805C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FAF7F40FD8A47DE2EEB589FFDEA679FCD89F
      73FFD89F73FFD89F73FFEFB68AFFDBA67EE9ECDCD04400000000CA9064FFD9A0
      75FDEAB185FEDEA77DF2EFE3D936000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EBE1D6805C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF706C5AFF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E5D0C15AECB387FFD9A57FE1F3EAE3280000
      000000000000E1C9B866D9AB89C8F4EBE426000000000000000000000000FBF9
      F80ADBB89D9AEBB286FEDBB598A9000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000EBE1D6805C4E42FF5C4E42FF5C4E42FF5C4E42FF5E5245FF7979
      65FF5C4E42FF909C82FF5C4E42FF5C4E42FF5C4E42FF797965FF5E5245FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E1C9B866F0B78BFFDDBA9E9D000000000000
      000000000000F1E7DF2DF9F5F213000000000000000000000000000000000000
      0000EEE2D838E5AB7FFEDBAD89CB000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007DA2B5B1497E99F7497E99F7497E
      99F7497E99F7497E99F7497E99F7497E99F7497E99F7497E99F7497E99F7497E
      99F7497E99F790A1A4FB5C4E42FF5C4E42FF5C4E42FF625749FF94A186FF685F
      50FF5C4E42FF7B7D69FF706D5BFF5C4E42FF5C4E42FF685F50FF94A186FF6257
      49FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E1C9B866F0B78BFFDEBBA099000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F0E4DB33E4AB7FFFDBAD8ACC000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007FA3B6AF6CADD0FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF675E4FFF94A287FF62584AFF5C4E
      42FF5C4E42FF5F5245FF8D987FFF5C4E42FF5C4E42FF5C4E42FF62584AFF94A2
      87FF675E4FFF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E1C9B866F0B78BFFDEBBA099000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F0E4DB33E4AB7FFFDBAD8ACC000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF609EBEFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF675E4FFF94A287FF62584AFF5C4E
      42FF5C4E42FF5C4E42FF8D987FFF5F5245FF5C4E42FF5C4E42FF63594BFF95A3
      88FF675E4FFF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E1C9B866F0B78BFFDEBBA099000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000F0E4DB33E4AB7FFFDBAD8ACC000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF5690AFFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF5C4E42FF625749FF94A186FF685F
      50FF5C4E42FF5C4E42FF706D5BFF7B7D69FF5C4E42FF6A6353FF95A489FF6257
      49FF5C4E42FF5C4E42FF5C4E42FFEBE1D6800000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E1C9B866F0B78BFFDDBAA09A000000000000
      000000000000000000000000000000000000F7F1ED1900000000000000000000
      0000EFE3DA34E4AB7FFFDBAC89CC000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF4C86A4FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5E5245FF7979
      65FF5C4E42FF5C4E42FF5C4E42FF909C82FF5C4E42FF797A66FF5E5245FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D68000000000BFB3A7B18D7E71EB8D7E
      71EB8D7E71EB8D7E71EB8D7E71EB8D7E71EB8D7E71EB8D7E71EB8D7E71EB8D7E
      71EB8D7E71EB8D7E71EB8D7E71EB977A63F3E9AF84FFCC9972F8958272EB8D7E
      71EB8D7E71EBD5CCC383FDFCFC04E7D2C25CCFA380C30000000000000000FDFC
      FB05E0C5AF7CE9B084FEDCB293B4000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF4D88A9FF7EC5EAFF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF706C5AFF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF605043FFC49068FFEBB286FFC6926AFFBB8A
      64FF785C46FFC7BDB390DFBFA888E3AB81F7DDA67CF5DBAD8ACCDBAD8ACCDBAC
      88CFE3AC81F8E5AC80FDE9D6C852000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF5290B3FF73B7DAFF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF6D5745FFB58560FFDFA67BFFE4AB
      7FFF806047FFBEAE9FADD6A681D5EDB488FFE9B084FFE4AB7FFFE4AB7FFFE4AA
      7EFEDEAA83E2E3C9B57100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF589BC0FF65A4C6FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5F5042FF6C5645FF6E57
      44FF635243FFC7BEB48EF7F0EB1CD9AF90B7D3A37ED5F0E4DB33F0E4DB33F0E5
      DC32F8F2EE190000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF5EA5CCFF5B97B7FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A
      79FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A79FF9A8A
      79FF9A8A79FF9A8A79FF9A8A79FFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5F5245FF625749FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000FDFCFC04E2CBBA6300000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF61AAD4FF518BAAFF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5F5245FF5D5044FF655C4DFF89927AFF5C4E
      42FF5C4E42FF5C4E42FF5F5246FF5E5144FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF4C87A7FF82CB
      F1FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FFAFCAD2FFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFEBE1D68000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF655B4DFF92A085FF685F50FF5C4E42FF929F85FF6155
      48FF5C4E42FF5C4E42FF726F5EFF8D987FFF605447FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF5291B3FF79BE
      E2FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF9ACCE4FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCA
      D2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCAD2FFAFCA
      D2FFAFCAD2FF9EB4B9FFD1CFC8A3F5F0EA4000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF64594BFF95A488FF6E6958FF5C4E42FF5C4E42FF80846FFF7370
      5EFF5C4E42FF5C4E42FF5C4F43FF747260FF919E83FF615548FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF589BC0FF6CAD
      D0FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF6DAED1FEB3C9D4680000000000000000A79B8FC05C4E42FF5C4E
      42FF675E4FFF9AAB8FFF655C4EFF5C4E42FF5C4E42FF5C4E42FF675F50FF8B95
      7CFF5C4E42FF5C4E42FF5C4E42FF5C4E42FF706B5AFF97A88BFF5F5346FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF5EA5CDFF609E
      BEFF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF78BDE2FF94B3C3910000000000000000A79B8FC05C4E42FF5C4E
      42FF625649FF919E84FF73715FFF5C4E42FF5C4E42FF5C4E42FF5E5044FF93A0
      85FF5E5245FF5C4E42FF5C4E42FF5C4E42FF818670FF878F78FF5D5044FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF64AED8FF5590
      AEFF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF82CAF0FF749CB1BD0000000000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5E5144FF8C977EFF7C7E6AFF5C4E42FF5C4E42FF5C4E42FF7A7C
      67FF787865FF5C4E42FF5F5245FF858D75FF818670FF5D4F43FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF4D88
      A7FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF5E90ACE60000000000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5F5346FF868E76FF696152FF5C4E42FF5C4E42FF6155
      48FF919E84FF5C4E42FF73715FFF7D816BFF5D4F43FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF4F8C
      ADFF7EC5EBFF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF5893B2FFF1F5F71200000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF858C75FF615649FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF589B
      C1FF4D89A9FF4D89A9FF4D89A9FF4D89A9FF4D89A9FF4D89A9FF4D89A9FF4D89
      A9FF4C87A6FF69A9CBFF84CDF4FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF61A0C0FFD2DFE53D00000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5E5145FF5C4F43FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65AFDAFF5698BCFF548FAEFF65A4C6FF65A4C6FF65A4C6FF65A4C6FF65A4
      C6FF65A4C6FF65A4C6FF65A4C6FF65A4C6FF65A4C6FF65A4C6FF65A4C6FF65A4
      C6FF65A4C6FF65A4C6FF5692B1FEB3C9D46800000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF60A8D1FF5A9DC3FF5A9DC3FF5A9DC3FF5A9DC3FF5A9D
      C3FF5A9DC3FF5A9DC3FF5A9DC3FF5A9DC3FF5A9DC3FF5A9DC3FF5A9DC3FF4F8C
      ADFF94B3C391B9CDD75FB9CDD75FDBE5EB3000000000A79B8FC05C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E42FF5C4E
      42FF5C4E42FFC7BEB48E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF5595
      B9FFC5D5DE4F00000000000000000000000000000000C4B6A8C0998978FF9989
      78FF998978FF998978FF998978FF998978FF998978FF998978FF998978FF9989
      78FF998978FF998978FF998978FF998978FF998978FF998978FF998978FF9989
      78FF998978FFD8CEC38E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF5595
      B9FFC5D5DE4F00000000000000000000000000000000E1D3C2C0D8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFE9DED28E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF64AFD9FF5697
      BBFF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595
      B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF5595B9FF4C88
      A7FFC5D5DE4F00000000000000000000000000000000E1D3C2C0D8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFE9DED28E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF64AFD9FF508BABFCA1BC
      CA7FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CD
      D75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CDD75FB9CD
      D75FE9EFF21E00000000000000000000000000000000E1D3C2C0D8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5AFFFD8C5
      AFFFD8C5AFFFE9DED28E00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000007EA3B6AF62ABD4FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65B0DBFF64AFD9FF508BABFCB7CBD6620000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FEFDFD05FDFDFC07FDFD
      FC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFD
      FC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFDFC07FDFD
      FC07FDFDFC07FEFEFD0400000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000009EBAC883729BB0BF729BB0BF729B
      B0BF729BB0BF729BB0BF729BB0BF729BB0BF729BB0BFB8CCD760000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000080000000200000000100010000000000000200000000000000000000
      000000000000000000000000FFFFFF00FFF80000FFFFF9FF0000000000000000
      FFF80000FFFFF8FF0000000000000000FFF80000FFFF00430000000000000000
      FFF80000FFFE00410000000000000000FFF80000FFFE18E10000000000000000
      FFF80000FFFE39F1000000000000000000000000FFFE3FF10000000000000000
      00000000FFFE3FF1000000000000000000000000FFFE3FF10000000000000000
      00000000FFFE3F71000000000000000000000000800000610000000000000000
      0000000080000001000000000000000000000000800000030000000000000000
      00000000800000070000000000000000000000008000027F0000000000000000
      00000000800003FF000000000000000000000000800003FF0000000000000000
      00000000800003FF000000000000000000000001800003FF0000000000000000
      00000001800003FF000000000000000000000001800003FF0000000000000000
      00000001800003FF000000000000000000000000800003FF0000000000000000
      00000000800003FF000000000000000000000000800003FF0000000000000000
      00000000800003FF000000000000000000000007800003FF0000000000000000
      00000007800003FF000000000000000000000007800003FF0000000000000000
      00000007800003FF0000000000000000001FFFFF800003FF0000000000000000
      003FFFFFFFFFFFFF000000000000000000000000000000000000000000000000
      000000000000}
  end
  object imgListInstrumentationSmall: TImageList
    Height = 24
    Width = 24
    Left = 223
    Top = 374
    Bitmap = {
      494C010109001800040018001800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      000000000000360000002800000060000000480000000100200000000000006C
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000DAC6CF6FB892A4E8C7AA
      B8A9000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DFDA
      D459B9ADA0D5BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2
      A5D2BDB2A5D2BDB2A5D2BBB0A4D3BDB2A5D2B8A69FDCAF8A98F8EDCFD7FFB28D
      9BFACCBBBE9000000000FEFDFE03000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFAF7F9FFB794A5FFC1A1AFFFCAA8B6FFEDCFD7FFF2D5DCFFF0D3
      DAFFCFADBAF7BD9DADCBB692A3E0EEE7EA2F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE2D3DAFFC8A5B4FFF1D4DBFFEDCFD7FFC29EAEFFBF9FAEFFBC99
      A8FFE5C7D0FDF1D4DBFFD7B4C2F6CFB6C2910000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC8ABB9FFE9C9D2FFC8A7B6FFF4EEF1FFFFFFFFFFE9E4
      E1FFBB98A5E8F2D5DCFFBB9AA9D1FFFEFF010000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDDDDFFFFFF
      FFFFFFFFFFFFFFFFFFFFC9ACB9FFEFD2D9FFC4A3B1FFFFFFFFFFFFFFFFFFEBE8
      E4FFB99AA7DCF2D5DCFFC4A4B2C8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF919191FFEBEB
      EBFFFFFFFFFFFEFDFEFFC1A2B0FFE9CBD4FFCCACB9FFE7DBE0FFFFFFFFFFE2D9
      D8FFBD9AA8EDF2D5DCFFBB97A7D8FAF8F80D0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFD8D8D8FFA5A5
      A5FFFFFFFFFFDFCFD7FFCEABB9FFE5C6CFFFF0D3DAFFCBABB8FFBF9CACFFC4A1
      AFFFEDCFD7FFE5C6CFFFDDBCC6FECCB2BE990000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFE5E5E5FF959595FFFFFFFFFFFFFFFFFF7D7D
      7DFFFFFFFFFFFEFDFDFFC0A1B0FFA38B96FFBD9AAAFFE0BFCAFFF2D5DCFFE6C6
      D0FFBF9BAAF1CCB1BE9CBB9BABCAF5F0F4190000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF818181FFEDEDEDFFFFFFFFFFFFFFFFFF9E9E
      9EFFDFDFDFFFFFFFFFFFFFFFFFFFEDEDEDFF848183FFC0A0AFFFEBCDD5FFB995
      A5FFCFC5C1870000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF8E8E8EFFE4E4E4FFFFFFFFFFFFFFFFFFE5E5
      E5FF979797FFFFFFFFFFFFFFFFFFE3E3E3FF8F8F8FFFE0D2D9FFBB98A7FFC7AF
      B9FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFEDEDEDFF8D8D8DFFFFFFFFFFFFFFFFFFFFFF
      FFFF7E7E7EFFFEFEFEFFFFFFFFFF8C8C8CFFEDEDEDFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFF
      FFFFADADADFFD0D0D0FFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF0F0F0FF8C8C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFEDEDEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF7F6F4FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFE1DC
      D6FFD4CDC47E0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFD7D1C9FFD7D1C9FFD7D1C9FFD7D0C8FFA99B
      8AFED6D2C96F0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFFFFFFFFFC9BFB6FEC8BF
      B3A8000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFC9C0B6FEC8BDB3A80000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFCAC1B6FDC7BDB2AA000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFC7BDB3FEC8BFB6A600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DDD7
      CF61B9ADA0DCBDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2
      A4D7BDB2A4D7BDB2A4D7AFA092F0C8BEB49F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CEA383BAD09D78D6D0A789B20000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DFDA
      D459B9ADA0D5BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2
      A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2B9AD
      A0D5DFDAD4590000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000009AB7C7889AB7C7889AB7C7889AB7
      C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7
      C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7C7889AB7
      C7889AB7C788BA9275E3F0B78BFFB89275E100000000E6DBE140CCB4C088CCB4
      C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4
      C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4C088CCB4
      C088CCB4C088CCB4C088E3D7DD4800000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF447A96FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FF457A95FF5B7A87FF447A96FF447A
      96FF447A96FFA68469FFF0B78BFFA28369FF00000000D2BDC778A1758BFFA175
      8BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA175
      8BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA1758BFFA175
      8BFFA1758BFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF88C9EBFFAF9880FFB1957BFF85CEF5FF85CE
      F5FF85CEF5FFB5977FFFF0B78BFFA28369FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FF8B8B8BFF8B8B8BFF8B8B8BFF8B8B8BFF8B8B8BFF8B8B
      8BFF8B8B8BFF8B8B8BFF8B8B8BFF8B8B8BFF8B8B8BFF8B8B8BFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFEFEFFFF8383DCFF8080DCFF8080DCFF8080DCFF8080DCFF8080DCFF7A7A
      D5FF7574CCD98080DCB98080DCB99D9DE28D0000000000000000000000000000
      0000000000000000000000000000F0F1FD140000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FF497186FF497186FF497186FF497186FF497186FF497186FF497186FF4971
      86FF497186FF6D8D9EFF7F8A8DFFB68865FFE7AF83FFB7967BFFA0CBE0FFA0CB
      E0FFA1C9DCFFBD9474FFEFB68AFFA1866CFF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDDDDFFFFFF
      FFFFFCFCFEFF6F6FDCFF8F8FF7FF8F8FF7FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8F8FF7FF8F8FF7FF7777DBCB0000000000000000000000000000
      00000000000000000000000000004F5EE9E58D95F095F5F5FD0D000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFDEC1AAFFD29D76FFEEB68AFFF0B78BFFD3A07AFFCE9F7BFFCE9F
      7BFFD1A07AFFE7AE82FFDAA47CFF858A86FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFD7B7A0FFD7B293FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF919191FFEBEB
      EBFFFDFDFEFF6E6ED6FF7777DBFF7777DBFF7777DBFF7777DBFF7777DBFF7372
      D6FF6F6DCFE47777DBCC7777DBCC8484DCAF0000000000000000000000000000
      00000000000000000000000000005462EADF4250E7F75663EBDDB9BEF75CFEFE
      FF01000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FF9FA19CFF9FA19CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFDAB89FFFD49F76FFEFB68AFFF0B78BFFDEA478FFDCA377FFDCA3
      77FFDAA277FFC69976FF9F9082FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFB57A4EFFB57A4EFFFFFFFFFFFFFFFFFFAD9D8FFFAD9D
      8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFD8D8D8FFA5A5
      A5FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF4555E8F25F6C
      EAD0D1D6F93A0000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFB57A4EFFB57A4EFFFFFFFFFFFFFFFFFF8C908CFF8C908CFF8C908CFF8C90
      8CFF8C908CFF8C908CFF9B8C7CFFBF8C64FFEAB185FFB39277FF91B8C9FF91B8
      C9FF91B9CCFF89C6E6FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFC99D7CFFC99B78FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFE5E5E5FF959595FFFFFFFFFFFFFFFFFF7D7D
      7DFFFFFFFFFFFFFFFFFFFFFFFFFF959595FFE5E5E5FFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF4B59E8EC6F7AEDBDE2E5FB25000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFA8907AFFA8907AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFF8F2EEFFA98263FFB2967BFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF818181FFEDEDEDFFFFFFFFFFFFFFFFFF9E9E
      9EFFDFDFDFFFFFFFFFFFFFFFFFFFEDEDEDFF828282FFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF3C4CE7FF3C4CE7FF4F5CEAE68992EF9BF2F3FD1100000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF4A7185FF92B9CAFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFC99D7CFFC99D7CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF8E8E8EFFE4E4E4FFFFFFFFFFFFFFFFFFE5E5
      E5FF979797FFFFFFFFFFFFFFFFFFE3E3E3FF8F8F8FFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF3C4CE7FF3C4CE7FF3C4CE7FF3C4CE7FE505EEAE4969EF389F8F9FE090000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFA8907AFFA8907AFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF497186FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFB57A4EFFB57A4EFFFFFFFFFFFFFFFFFFAD9D8FFFAD9D
      8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFFAD9D8FFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFEDEDEDFF8D8D8DFFFFFFFFFFFFFFFFFFFFFF
      FFFF7E7E7EFFFEFEFEFFFFFFFFFF8C8C8CFFEDEDEDFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF3C4CE7FF3C4CE7FF3C4CE7FF3C4CE7FE4353E8F58F97F192F9F9FD080000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFB57A4EFFB57A4EFFFFFFFFFFFFFFFFFF8C908CFF8C908CFF8C908CFF8C90
      8CFF8C908CFF8C908CFF8C908CFF8C908CFF497186FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFDCC1ACFFDCC1ACFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFF
      FFFFADADADFFD0D0D0FFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF3C4CE7FF3C4CE7FF3C4DE7FF4453E7F5818DF0A3F4F5FE0E000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FF9AA7A7FF9AA7A7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF497186FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF0F0F0FF8C8C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3C4C
      E7FF3B4BE6FF3F4EE6FB6672ECC8E7E9FB200000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF497186FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFF847478FF847478FF847478FF847478FF847478FF847478FF8474
      78FF847478FF847478FF847478FF847478FF847478FF847478FF847478FFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFEDEDEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23C4CE7FF3C4CE7FF3C4CE7FF3D4D
      E7FD5563E9DED0D3F93E00000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF4971
      86FF497186FF497186FF497186FF497186FF497186FF497186FF497186FF4971
      86FF497186FF497186FF497186FF497186FF497186FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5
      DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5DCFFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000000000000000000000000000000000
      00000000000000000000000000005261E9E23D4DE7FE3B4CE7FE4B5AE9EBB1B7
      F665FEFEFF010000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF63A2C2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFECC7D0FFDAB2B8FF9C8374FF8F7966FF8F7966FF8F79
      66FF8F7966FF8F7966FF8F7966FF8F7966FF927B69FFBFA69FFFF2D5DCFFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF7F6F4FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFE1DC
      D6FFD4CDC47E0000000000000000000000000000000000000000000000000000
      00000000000000000000000000004C5BE9E94453E7F59DA4F280FCFCFF040000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF528CABFF62A1C2FF62A1
      C2FF62A1C2FF62A1C2FF62A1C2FF63A2C3FF79BFE4FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFE7BBC6FFBE9D9AFF8F7966FFC4B5A8FFC4B5A8FFC4B5
      A8FFC4B5A8FFBAAB9CFFAE9E8EFFC4B5A8FFAB9989FF927B69FFF2D5DCFFF2D5
      DCFFF2D5DCFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFD7D1C9FFD7D1C9FFD7D1C9FFD7D0C8FFA99B
      8AFED6D2C96F0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000E5E7FB22F4F4FE0F00000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF447A96FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FF447B96FF5995B5FF79BFE4FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF66A6C9FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFE6BAC6FFBD9B99FF8F7966FFF2EBE1FFF2EBE1FFF2EB
      E1FFF2EBE1FFC9BDAFFF9C8B78FFF2EBE1FFC3B5A7FF8F7966FFF2D5DCFFF2D5
      DCFFE2C2CDFFA1758BFFCCB5C18700000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFFFFFFFFFC9BFB6FEC8BF
      B3A8000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF5494B6FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF63ADD6FF5595B9FF467C99FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FF00000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFE6BAC6FFBD9B99FF8F7966FFF2EBE1FFF2EBE1FFF2EB
      E1FFF2EBE1FFC9BDAFFF9C8B78FFF2EBE1FFC3B5A7FF8F7966FFF2D5DCFFE2C2
      CDFFA67C90FCAC8599E2F2EDEF2000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFC9C0B6FEC8BDB3A80000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF5494B6FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF65AFDBFF518FB0FF447A96FF6E97ADC5799F
      B3B6799FB3B6799FB3B6799FB3B6799FB3B6799FB3B6799FB3B6799FB3B6799F
      B3B6799FB3B6799FB3B6799FB3B6799FB3B600000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFE6BAC6FFBD9B99FF8F7966FFF2EBE1FFF2EBE1FFF2EB
      E1FFF2EBE1FFDFD6CAFFCABEB0FFF2EBE1FFC3B5A7FF8F7966FFE2C2CDFFA67C
      90FCAC8599E2F2EDEF200000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFCAC1B6FDC7BDB2AA000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF5494B6FF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65AFDBFF518FB0FF447A96FFA1BCCA7F000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D2BDC778A1758BFFF2D5
      DCFFF2D5DCFFF2D5DCFFE6BAC6FFBD9B99FF8F7966FFF2EBE1FFF2EBE1FFF2EB
      E1FFF2EBE1FFF2EBE1FFF2EBE1FFF2EBE1FFC3B5A7FF8F7966FFA67C90FCAC85
      99E2F2EDEF20000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFC7BDB3FEC8BFB6A600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000447A96FF447A96FF447A96FF447A
      96FF447A96FF447A96FF447A96FF447A96FFA1BCCA7F00000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000D2BDC778A1758BFFA175
      8BFFA1758BFFA1758BFFA1758BFF9B777EFF8F7966FF8F7966FF8F7966FF8F79
      66FF8F7966FF8F7966FF8F7966FF8F7966FF8F7966FF92796CFFAC8599E2F2ED
      EF2000000000000000000000000000000000000000000000000000000000DDD7
      CF61B9ADA0DCBDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2
      A4D7BDB2A4D7BDB2A4D7AFA092F0C8BEB49F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000A7C0CD77A7C0CD77A7C0CD77A7C0
      CD77A7C0CD77A7C0CD77A7C0CD77BBCFD95B0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E9E0E538D2BEC877D2BE
      C877D2BEC877D2BEC877D2BEC877D2BDC778B9A4A4A8B39D9BB6B39D9BB6B39D
      9BB6B39D9BB6B39D9BB6B39D9BB6B39D9BB6B39E9AB5C8B4BA8BF2EDEF200000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E0C5B077CFA07DCBCDA07FC00000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000F8F2ED18D7B096A1CE9D78D2CA9770E2CD9A
      74D7D2A787B5F5EEE72100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E2C9B46EE2C9B66EFEFEFE020000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000A5C198AF9ABA8BE195B5
      84D1000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000D8B4989BEAB185FFD09E7AD5000000000000000000000000DFDA
      D459B9ADA0D5BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2
      A5D2BDB2A5D2BDB2A5D2BBA792DCC38D64F9E8AF83FFEFB78BFFE9AF84FFEBB2
      86FFEAB185FFCC9871E5E9D6C85200000000000000000000000000000000DFDA
      D459B9ADA0D5BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2
      A5D2BDB2A5D2BD9577EDD79E74FDC08D67F7BBA089E1BDB2A5D2BDB2A5D2B9AD
      A0D5DFDAD459000000000000000000000000000000000000000000000000DFDA
      D459B9ADA0D5BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2
      A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D2BDB2A5D292AA7CF3BDE0BAFF90AB
      7DF7DFDAD459000000000000000000000000ACC6D4735C90AAE95C90AAE95C90
      AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90
      AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE9678D9EEC5C90AAE95C90
      AAE95C90AAE9988878F7EAB185FFC29471E8000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFCF9F7FFCA9973FFEEB589FFD6A076FFD0A483FFDEC0A9FFCCA2
      83FFCC966FEFEEB488FFD09B74E2F4EDE623000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD9B59BFFEAB085FFEEB589FFD59E74FFCD9E7BFFEFE2D8FFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA4BF96FFBDE0BAFF9BB8
      8BFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF9DACADFFB38765FF85CEF5FF85CE
      F5FF85CEF5FFA9A195FFEAB185FFBB8E6FF3000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFDEC0AAFFE2AA7EFFD9A379FFE2C9B7FFFFFFFFFFFFFFFFFFEBE8
      E4FFD1C0AF92CC9970E4D79F75F5CFA687B4000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD9B59BFFEAB085FFF0B78BFFF0B78BFFEEB589FFD6A077FFCCA0
      7EFFD1C2B48D000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA4BF96FFBDE0BAFF9BB8
      8BFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CCF1FF88C6E4FF88C6E4FF88C6E4FF88C6
      E4FF88C6E4FF88C6E4FF8BC3DDFFAE9781FFD4A27BFFBB9678FF85CEF5FF85CE
      F5FF85CDF4FFAE9883FFEDB487FFB78F6EF2000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD0A381FFF0B78BFFCE9F7CFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876F4EBE624F0E4DC33F3E9E02B000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD9B59BFFEAB085FFF0B78BFFF0B78BFFF0B78BFFF0B78BFFECB4
      87FFCE9970F3D2AC8DADF7EFEA1D00000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFA5C097FF9FBD90FF9FBD90FF9FBD90FF90B27EFFBDE0BAFF96B8
      87FF97B386E49FBC90CD9FBC90CD95B584D17FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFB6B1A8FFCDCDC8FFCDCDC8FFCDCD
      C8FFCDCDC8FFCABFB3FFC3926CFFE6AD81FFF0B78BFFCF9F7AFFBF9575FFBF95
      75FFBF9575FFD5A37BFFEAB185FFAD9078E8000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDDDDFFFFFF
      FFFFFFFFFFFFD0A17FFFF0B78BFFD0A584FFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDDDDDDFFFFFF
      FFFFFFFFFFFFD9B59BFFEAB085FFF0B78BFFF0B78BFFF0B78BFFF0B78BFFF0B7
      8BFFF0B78BFFE7AE82FFBB845AF2ECDDD143000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4E0DDFFFFFF
      FFFFFFFFFFFF9FBD90FFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0
      BAFFBDE0BAFFBDE0BAFFBDE0BAFF9ABA8BE17FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFDDC0AAFFD19C73FFEFB68AFFF0B78BFFE8AE82FFE4AA7FFFE4AA
      7FFFE4AA7EFFD6A279FFB39073FF83A2B2BC000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF919191FFEBEB
      EBFFFFFFFFFFD0A584FFEFB68AFFCD9D78FFFEFDFDFFFFFFFFFFFFFFFFFFDBC7
      B7FFB87E54FAC9956EE3C9956EE3BD875FED000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF919191FFEBEB
      EBFFFFFFFFFFD9B59BFFEAB085FFF0B78BFFF0B78BFFF0B78BFFF0B78BFFEEB6
      8AFFD5A076F5CC9F7CC8F1E5DD3300000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA89D92FFEFED
      EBFFFFFFFFFFB8CCACFFA4BF96FFA4BF96FFA4BF96FF86A972FFBDE0BAFF8EB0
      7CFF98B387D9A4C095B8A4C095B8A5C198AF7FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFEDDDD2FFC5926CFFEAB184FFBC9271FFA0ABAAFFA0AB
      AAFFA0ABABFF93B8C8FF7ABBDDFF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFD8D8D8FFA5A5
      A5FFFFFFFFFFE4CDBCFFDFA87DFFDFA67BFFD5B095FFFEFDFDFFFFFFFFFFEBE8
      E4FFC59C7DCFDCA478FCF0B78BFFCE9A75E0000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFBFBFBFFFFFFFFFFFD8D8D8FFA5A5
      A5FFFFFFFFFFD9B59BFFEAB085FFF0B78BFFF0B78BFFEFB78BFFDDA87FFFC999
      75FFCEB9A99B000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFCCC6BFFFFFFFFFFFE0DCD8FFB8AE
      A5FFFFFFFFFFFFFFFFFFFFFFFFFFCCC6BFFFFFFFFFFFA4BF96FFBDE0BAFF9BB8
      8BFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFCEC8BEFFB59375FFB88B67FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFE5E5E5FF959595FFFFFFFFFFFFFFFFFF7D7D
      7DFFFFFFFFFFFEFDFDFFCC9C79FFEAB085FFE1A97EFFCF9E7AFFD1A584FFCC9D
      78FFD9A176F8EEB589FFDAA276F6CE9B74E0000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFE5E5E5FF959595FFFFFFFFFFFFFFFFFF7D7D
      7DFFFFFFFFFFD9B59BFFEAB085FFF0B68AFFDBA57BFFCB9A76FFE5D1C1FFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFEBE8E6FFACA196FFFFFFFFFFFFFFFFFF988B
      7DFFFFFFFFFFFFFFFFFFFFFFFFFFABA095FFEBE8E6FFA4BF96FFBDE0BAFF9BB8
      8BFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFD0CEC8FF89C0DBFF99ADB3FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF818181FFEDEDEDFFFFFFFFFFFFFFFFFF9E9E
      9EFFDFDFDFFFFFFFFFFFF8F2EEFFC89773FFDAA278FFEFB68AFFF0B78BFFF0B7
      8BFFE2A77DFDC89771DBDBBCA584BA8157F5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF818181FFEDEDEDFFFFFFFFFFFFFFFFFF9E9E
      9EFFDFDFDFFFD9B59BFFD9A075FFC99772FF978272FFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF9C8F82FFF1EFEDFFFFFFFFFFFFFFFFFFB3A9
      9FFFE6E2DFFFFFFFFFFFFFFFFFFFF0EFEDFF9D9083FFA4BF96FFBDE0BAFF9BB8
      8BFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFD0CEC8FF89C1DCFF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF8E8E8EFFE4E4E4FFFFFFFFFFFFFFFFFFE5E5
      E5FF979797FFFFFFFFFFFFFFFFFFE2E1E1FFA18A78FFD0A584FFCC9C78FFCA9C
      78FFCAAC90B9FBF9F70B00000000E5D0C159000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFF8E8E8EFFE4E4E4FFFFFFFFFFFFFFFFFFE5E5
      E5FF979797FFE2C9B7FFE3CBBAFFE2E2E2FF8F8F8FFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFA69A8FFFEAE7E4FFFFFFFFFFFFFFFFFFEAE7
      E5FFADA298FFFFFFFFFFFFFFFFFFE9E6E3FFA79B90FFB8CCACFF9FBD90FF9FB9
      8FFFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFC4B9AEFFC4B9AEFFC4B9AEFFB5A99CFF8BBAD0FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFEDEDEDFF8D8D8DFFFFFFFFFFFFFFFFFFFFFF
      FFFF7E7E7EFFFEFEFEFFFFFFFFFF8C8C8CFFEDEDEDFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFEDEDEDFF8D8D8DFFFFFFFFFFFFFFFFFFFFFF
      FFFF7E7E7EFFFEFEFEFFFFFFFFFF8C8C8CFFEDEDEDFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFF0EFEDFFA5998DFFFFFFFFFFFFFFFFFFFFFF
      FFFF998C7FFFFEFEFEFFFFFFFFFFA4988CFFF0EFEDFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFC4B9AEFFFFFFFFFFECE9E6FFAAA194FF85CAEDFF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFF
      FFFFADADADFFD0D0D0FFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFF
      FFFFADADADFFD0D0D0FFFFFFFFFFD9D9D9FFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFE1DDDAFFFFFFFFFFFFFFFFFFFFFF
      FFFFBEB5ADFFDAD5D0FFFFFFFFFFE1DDDAFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFC4B9AEFFEDEAE6FFAAA194FF85CAEDFF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF0F0F0FF8C8C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF0F0F0FF8C8C8CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFF3F1F0FFA4988CFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89C1DCFFD0CEC8FFFFFFFFFFFFFFFFFFFFFF
      FFFFB0A394FFABA195FF85CCEFFF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFEDEDEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFEDEDEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFF1EFEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF88C6E4FFA0A7A3FFA2A7A3FFA2A7A3FFA2A7
      A3FFA09D93FF87CAEFFF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C876000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBE8
      E4FFD7D1C8760000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF7F6F4FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFE1DC
      D6FFD4CDC47E000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF7F6F4FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFE1DC
      D6FFD4CDC47E000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFF7F6F4FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFE1DC
      D6FFD4CDC47E0000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFD7D1C9FFD7D1C9FFD7D1C9FFD7D0C8FFA99B
      8AFED6D2C96F000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFD7D1C9FFD7D1C9FFD7D1C9FFD7D0C8FFA99B
      8AFED6D2C96F000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFD7D1C9FFD7D1C9FFD7D1C9FFD7D0C8FFA99B
      8AFED6D2C96F0000000000000000000000008EB2C29E518DADFF528FB0FF528F
      B0FF528FB0FF528FB0FF528FB0FF528EADFF73B6DAFF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB5000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFFFFFFFFFC9BFB6FEC8BF
      B3A800000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFFFFFFFFFC9BFB6FEC8BF
      B3A800000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFFFFFFFFFC9BFB6FEC8BF
      B3A800000000000000000000000000000000A9C5D2765FA5CDFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF64AEDAFF558EADF5548BAAF9548CABF9548C
      ABF9548CABF9548CABF9548CABF9548CABF9548CABF9548CABF9548CABF9548C
      ABF9548CABF9548CABF9538BA8FA8EB0C39D000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFC9C0B6FEC8BDB3A80000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFC9C0B6FEC8BDB3A80000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFFFFFFFFFC9C0B6FEC8BDB3A80000
      000000000000000000000000000000000000A9C5D2765FA5CDFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65AFDBFF5E97B8EDB5CCD96800000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFCAC1B6FDC7BDB2AA000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFCAC1B6FDC7BDB2AA000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFFFFFFFFFCAC1B6FDC7BDB2AA000000000000
      000000000000000000000000000000000000C8D9E14B709DB5C6709DB5C6709D
      B5C6709DB5C6709DB5C6709DB5C6BACFDA610000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFC7BDB3FEC8BFB6A600000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFC7BDB3FEC8BFB6A600000000000000000000
      000000000000000000000000000000000000000000000000000000000000D7D1
      C876EBE8E4FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFC4B9AEFFC7BDB3FEC8BFB6A600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DDD7
      CF61B9ADA0DCBDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2
      A4D7BDB2A4D7BDB2A4D7AFA092F0C8BEB49F0000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DDD7
      CF61B9ADA0DCBDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2
      A4D7BDB2A4D7BDB2A4D7AFA092F0C8BEB49F0000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DDD7
      CF61B9ADA0DCBDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2A4D7BDB2
      A4D7BDB2A4D7BDB2A4D7AFA092F0C8BEB49F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000060000000480000000100010000000000600300000000000000000000
      000000000000000000000000FFFFFF00FFFF8F000000000000000000E0000500
      0000000000000000E00000000000000000000000E00000000000000000000000
      E00000000000000000000000E00001000000000000000000E000000000000000
      00000000E00000000000000000000000E00000000000000000000000E0000700
      0000000000000000E00007000000000000000000E00007000000000000000000
      E00007000000000000000000E00007000000000000000000E000070000000000
      00000000E00007000000000000000000E00007000000000000000000E0000700
      0000000000000000E0000F000000000000000000E0001F000000000000000000
      E0003F000000000000000000E0007F000000000000000000E000FF0000000000
      00000000FFFFFF000000000000000000FFFFFFFFFFFFFFFFF8FFFFFFE00007FF
      FFFF000000800001E00007FFFFFF000000800001E00007FFFFFF000000800001
      E00000FEFFFF000000800001E00000FE3FFF000000800001E00000FE0FFF0000
      00800001E00007FE07FF000000800001E00007FE01FF000000800001E00007FE
      007F000000800001E00007FE001F000000800001E00007FE001F000000800001
      E00007FE003F000000800001E00007FE00FF000000800001E00007FE03FF0000
      00800001E00007FE07FF000000800001E00007FE1FFF000000800001E00007FE
      7FFF000000800001E0000FFFFFFF000000800001E0001FFFFFFF000000800003
      E0003FFFFFFF003FFF800007E0007FFFFFFF007FFF80000FE000FFFFFFFF00FF
      FF80001FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF8FFFE03FFF8FFFFFF8FFFFFF8E0
      0001E00007E00007000000E00000E00007E00007000000E00000E00007E00007
      000000E00000E00001E00000000000E00007E00000E00000000000E00000E000
      01E00000000000E00000E00007E00007000000E00000E00007E00007000000E0
      0000E00007E00007000000E00002E00007E00007000000E00007E00007E00007
      000000E00007E00007E00007000000E00007E00007E00007000000E00007E000
      07E00007000000E00007E00007E00007000000E00007E00007E00007000000E0
      0007E00007E00007000000E0000FE0000FE0000F000000E0001FE0001FE0001F
      007FFFE0003FE0003FE0003F00FFFFE0007FE0007FE0007FFFFFFFE000FFE000
      FFE000FFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object imgListAnalysisSmall: TImageList
    Height = 24
    Width = 24
    Left = 343
    Top = 374
    Bitmap = {
      494C010107001800040018001800FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000600000003000000001002000000000000048
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F1F1F116DDDDDD39CBCBCB5BC9C9
      C960C9C9C960CCCCCC5ADCDCDC38E0E0ED2C8F8FDFA27373D9D26969D8E27272
      DAD68484DDB4DFDFF62B00000000000000000000000000000000000000000000
      000000000000000000000000000000000000F1F1F116DDDDDD39CBCBCB5BC9C9
      C960C9C9C960CCCCCC5ADCDCDC38F1F1F1150000000000000000D7D3D13D948B
      84A5000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000F1F1F116DDDDDD39CBCBCB5BC9C9
      C960C9C9C960D5D5D546E0E0E034F5F5F51100000000DBBFA980C59068E9D6B2
      989E000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000E5E5E52DA7A7A7A7979797D49B9B9BE7A6A6A6F6AFAFAFFFB7B7
      B7FFB7B7B7FFAFAFAFFF9191AEF75C5CCAFC8585F1FF8F8FF7FF8F8FF7FF8F8F
      F7FF8989F4FF6C6CDAE7B9B9EB64000000000000000000000000000000000000
      000000000000E5E5E52DA7A7A7A7979797D49B9B9BE7A6A6A6F6AFAFAFFFB7B7
      B7FFB7B7B7FFAFAFAFFFA6A6A6F59A9A9AE7B2B2B2EAB4B2B2CF786B62E29182
      76EEBAB4AF6D0000000000000000000000000000000000000000000000000000
      000000000000E5E5E52DA9A9A9A6999999D39B9B9BE7A6A6A6F6AFAFAFFFB7B7
      B7FFB7B7B7FFB1B1B1FFA7A6A5F59C9C9CE0A09389DAB9855FF3EAB185FFC996
      6EDFE9D7C95000000000FDFDFC04000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000F7F7
      F70C9F9F9FB49C9C9CEBC1C1C1FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC5C5CBFF6565D0FF8D8DF5FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8F8FF7FF6F6FDCE4E2E2F529000000000000000000000000F7F7
      F70C9F9F9FB49C9C9CEBC1C1C1FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF89817BFFB1A191FFBDAC
      9CFF83776BE5D7D3D13C0000000000000000000000000000000000000000F7F7
      F70C9F9F9FB49D9D9DEAC2C2C2FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCBC7C4FFBE8B64FFBF8F6BFFCB956DFFEBB287FFF0B78BFFECB4
      87FFD0996EF5C5936ED9C08A62E9F6EEE91F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009E9E
      9EB7BCBCBCFECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFF8C8CCDFF7F7FEBFF8F8FF7FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8F8FF7FF8989F4FF8282DCB50000000000000000000000009E9E
      9EB7BCBCBCFECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9F9A95FFA69688FFBDAC9CFFBDAC
      9CFFBAA999FF7B6F63DDEDEDEB18000000000000000000000000000000009E9E
      9EB7BDBDBDFECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC5B0A0FFD39E75FFEFB58AFFECB487FFC5916CEEC99C79CBC796
      6FDFE7AE81FDEDB487FFE3AD83F3DEC2AB7E0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94DECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFF6E6ED0FF8F8FF7FF9999F8FFA5A5F9FFA5A5F9FFA5A5F9FFA5A5
      F9FFA5A5F9FF9F9FF8FF8F8FF7FF7171DAD70000000000000000000000009494
      94DECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFB9B6B5FF928477FFBDAC9CFFBDAC9CFFBDAC
      9CFFBDAC9CFFB1A191FF80756DC9FCFBFB050000000000000000000000009494
      94DECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFC19A7CFFEEB589FFCA976FF1F7EFEA1D00000000FCFB
      F908CD9D79D4F0B78BFFD8AF91B1000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFF6E6ED1FF8F8FF7FFC3C3FBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE0E0FDFF8F8FF7FF7070DADD0000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFC5C4C3FF5B4F45FF7B6E63FF7A6D62FFBDAC9CFFBDAC
      9CFF928375FE807268E46C5F55EE8D847DAA0000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFC39B7EFFEEB68AFFC99774DD00000000000000000000
      0000D1A584BDF0B78BFFE0B99CA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFBDBDBDFF9F9F9FFF8B8B8BFF898989FF878787FF8787
      87FF878787FF5F5FBEFF8E8EF6FF8F8FF7FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8F8FF7FF8F8FF7FF7373D9D40000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFBDBDBDFF9F9F9FFF8B8B8BFF898989FF878787FF8787
      87FFAEAEAEFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9B9590FFBDAC9CFFBDAC
      9CFF75685DFB0000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFBDBDBDFF9F9F9FFF8B8B8BFF898989FF878787FF8787
      87FF898989FF8E8E8EFFB18766FFE9AF84FFCD9770F8EDDDD14400000000F5EE
      E920CE9A74DEF0B78BFFD3A786C1FCFAFA070000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0B7B7B7FF898989FF979797FFB3B3B3FFCACACAFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFF9999CCFF7979E5FF8F8FF7FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8F8FF7FF8484F0FE8F8FE0A10000000000000000000000009494
      94E0B7B7B7FF898989FF979797FFB3B3B3FFCACACAFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCACACAFFC8C8C8FF958F8AFFBDAC9CFFBDAC
      9CFF75685DFB0000000000000000000000000000000000000000000000009494
      94E0B7B7B7FF898989FF979797FFB3B3B3FFCACACAFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC5B2A3FFD19A70FFE7AE82FFEDB487FFC8936DFBBF8F69EAC894
      6CEFECB487FFE8AF83FFE4AB80FDDBBCA4880000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008888
      88E9919191FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCBCBCCFF6868CEFF8787F2FF8F8FF7FF8F8FF7FF8F8FF7FF8F8F
      F7FF8F8FF7FF8C8CF5FF6B6BD7DEEFEFF9160000000000000000000000008888
      88E9919191FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9E9893FFBDAC9CFFBDAC
      9CFF72665BFC0000000000000000000000000000000000000000000000008888
      88E9919191FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCBCBFFC09372FFC4A186FFC08B62FFDFA57AFFEFB78BFFEAB0
      84FFC48E67FDD6B3989DCB9C79C8F9F6F3120000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007777
      77F4CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFBFBFCCFF6666CFFF7A7AE7FF8E8EF6FF8F8FF7FF8F8F
      F7FF7E7EEAFF6969D6DDD8D8F336000000000000000000000000000000007777
      77F4CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9E9893FFBDAC9CFFBDAC
      9CFF706359FE0000000000000000000000000000000000000000000000007777
      77F4CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCAC6C2FFBF9371FFE4AB7FFFC190
      6CFF7F7671F50000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008F8F
      8FE3CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCACACCFF9999CCFF7171CEFF6767D0FF6D6D
      CFFF6F6FADF1F7F7FD0B00000000000000000000000000000000000000008F8F
      8FE3CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFA9A5A2FF80766DFF8076
      6DFF6C615BFC0000000000000000000000000000000000000000000000008F8F
      8FE3CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC6B1A1FFC08E67FFC4A2
      89FF8F8F8FE30000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCBCBCBFFBFBFBFFFADADADFFA3A3A3FF999999FF9191
      91FF919191FF999999FFA3A3A3FFAEAEAEFFBFBFBFFFCBCBCBFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCBCBCBFFBFBFBFFFADADADFFA3A3A3FF999999FF9191
      91FF919191FF999999FFA3A3A3FFAEAEAEFFC0C0C0FFCBCBCBFFCCCCCCFFCCCC
      CCFFCCCCCCFF0000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCBCBCBFFBFBFBFFFADADADFFA3A3A3FF999999FF9191
      91FF919191FF999999FFA3A3A3FFAEAEAEFFBFBFBFFFCBCBCBFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0C5C5C5FF9B9B9BFF8B8B8BFF999999FFB1B1B1FFBBBBBBFFC3C3C3FFCBCB
      CBFFCBCBCBFFC3C3C3FFBBBBBBFFB1B1B1FF999999FF8C8C8CFF9B9B9BFFC5C5
      C5FF949494E00000000000000000000000000000000000000000000000009494
      94E0C5C5C5FF9B9B9BFF8B8B8BFF999999FFB1B1B1FFBBBBBBFFC3C3C3FFCBCB
      CBFFCBCBCBFFC3C3C3FFBBBBBBFFB1B1B1FF999999FF8C8C8CFF9B9B9BFFC5C5
      C5FF949494E00000000000000000000000000000000000000000000000009494
      94E0C5C5C5FF9B9B9BFF8B8B8BFF999999FFB1B1B1FFBBBBBBFFC3C3C3FFCBCB
      CBFFCBCBCBFFC3C3C3FFBBBBBBFFB1B1B1FF999999FF8C8C8CFF9B9B9BFFC5C5
      C5FF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008888
      88E9919191FFC0C0C0FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC0C0C0FF9191
      91FF888888E90000000000000000000000000000000000000000000000008888
      88E9919191FFC0C0C0FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC0C0C0FF9191
      91FF888888E90000000000000000000000000000000000000000000000008888
      88E9919191FFC0C0C0FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC0C0C0FF9191
      91FF888888E90000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007777
      77F3CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF787878F30000000000000000000000000000000000000000000000007777
      77F3CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF787878F30000000000000000000000000000000000000000000000007777
      77F3CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF787878F30000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC9C9C9FFC4C4C4FFBFBF
      BFFFBFBFBFFFC4C4C4FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC9C9C9FFC4C4C4FFBFBF
      BFFFBFBFBFFFC4C4C4FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC9C9C9FFC4C4C4FFBFBF
      BFFFBFBFBFFFC4C4C4FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFBBBBBBFF9D9D9DFF8F8F8FFF8F8F8FFF939393FF9B9B9BFFA3A3
      A3FFA3A3A3FF9B9B9BFF939393FF8F8F8FFF8F8F8FFF9D9D9DFFBCBCBCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFBBBBBBFF9D9D9DFF8F8F8FFF8F8F8FFF939393FF9B9B9BFFA3A3
      A3FFA3A3A3FF9B9B9BFF939393FF8F8F8FFF8F8F8FFF9D9D9DFFBCBCBCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000009494
      94E0CCCCCCFFBBBBBBFF9D9D9DFF8F8F8FFF8F8F8FFF939393FF9B9B9BFFA3A3
      A3FFA3A3A3FF9B9B9BFF939393FF8F8F8FFF8F8F8FFF9D9D9DFFBCBCBCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008F8F
      8FE38F8F8FFF9D9D9DFFBFBFBFFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFBEBEBEFF9D9D9DFF9090
      90FF909090E30000000000000000000000000000000000000000000000008F8F
      8FE38F8F8FFF9D9D9DFFBFBFBFFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFBEBEBEFF9D9D9DFF9090
      90FF909090E30000000000000000000000000000000000000000000000008F8F
      8FE38F8F8FFF9D9D9DFFBFBFBFFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFBEBEBEFF9D9D9DFF9090
      90FF909090E30000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007B7B
      7BFBC3C3C3FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC2C2
      C2FF7A7A7AFB0000000000000000000000000000000000000000000000007B7B
      7BFBC3C3C3FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC2C2
      C2FF7A7A7AFB0000000000000000000000000000000000000000000000007B7B
      7BFBC3C3C3FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC2C2
      C2FF7A7A7AFB0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008F8F
      8FDBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF8F8F8FDB0000000000000000000000000000000000000000000000008F8F
      8FDBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF8F8F8FDB0000000000000000000000000000000000000000000000008F8F
      8FDBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF8F8F8FDB0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DFDF
      DF398D8D8DDBB0B0B0FBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCBCBFFB0B0B0FB8F8F
      8FDAE0E0E036000000000000000000000000000000000000000000000000DFDF
      DF398D8D8DDBB0B0B0FBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCBCBFFB0B0B0FB8F8F
      8FDAE0E0E036000000000000000000000000000000000000000000000000DFDF
      DF398D8D8DDBB0B0B0FBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCBCBFFB0B0B0FB8F8F
      8FDAE0E0E0360000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FAFAFA08C4C4C46D9D9D9DBC979797D6A2A2A2E7ABABABF0AFAFAFFCB7B7
      B7FFB7B7B7FFAFAFAFFCABABABF0A2A2A2E7969696D69E9E9EBBC2C2C26CFAFA
      FA08000000000000000000000000000000000000000000000000000000000000
      0000FAFAFA08C4C4C46D9D9D9DBC979797D6A2A2A2E7ABABABF0AFAFAFFCB7B7
      B7FFB7B7B7FFAFAFAFFCABABABF0A2A2A2E7969696D69E9E9EBBC2C2C26CFAFA
      FA08000000000000000000000000000000000000000000000000000000000000
      0000FAFAFA08C4C4C46D9D9D9DBC979797D6A2A2A2E7ABABABF0AFAFAFFCB7B7
      B7FFB7B7B7FFAFAFAFFCABABABF0A2A2A2E7969696D69E9E9EBBC2C2C26CFAFA
      FA08000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FEFEFE01E8E8E827DDDDDD39D4D4D447CACA
      CA5FCACACA5FD4D4D447DDDDDD39E8E8E8270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FEFEFE01E8E8E827DDDDDD39D4D4D447CACA
      CA5FCACACA5FD4D4D447DDDDDD39E8E8E8270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FEFEFE01E8E8E827DDDDDD39D4D4D447CACA
      CA5FCACACA5FD4D4D447DDDDDD39E8E8E8270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C79670D7C3895DFCBE8257FB0000000000000000000000000000
      000000000000000000000000000000000000F1F1F116DDDDDD39CBCBCB5BC9C9
      C960C9C9C960CCCCCC5ADCDCDC38EBE6E12BD7B096A1CE9D78D2CA9770E2CD9A
      74D7D2A787B5F5EEE72100000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000F6F6F60FCACACA6BB5B5B595B0B0B0A2B0B0B0A2B5B5
      B595C8C8C86BF6F6F60F00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C38C61EFEAB185FFC78B61FD0000000000000000000000000000
      000000000000E5E5E52DA7A7A7A7979797D49B9B9BE7A6A6A6F6AFAFAFFFB7B7
      B7FFB7B7B7FFAFAFAFFFAA9E94F7BD8B63FCE8AF83FFEFB78BFFE9AF84FFEBB2
      86FFEAB185FFCC9871E5E9D6C852000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000EEEEEE1EAEAEAEB0ADADADE9C2C2C2FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFC2C2C2FFACACACE9AEAEAEAFEEEEEE1C0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000ACC6D4735C90AAE95C90AAE95C90
      AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90AAE95C90
      AAE95C90AAE94E86A3FD4E86A3FD4E86A3FD4D86A3FE5B8497FE4D86A3FE4D86
      A3FE4D86A3FE958574FEEAB185FFBC8A64FE000000000000000000000000F7F7
      F70C9F9F9FB49C9C9CEBC1C1C1FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCBC8C6FFC3926BFFEEB589FFD39C73FFC09574FFAD8E77F5B58B
      6EE8D09B75E2EEB488FFD09B74E2F4EDE6230000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000A5A5A5CBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCBCBCBFFA6A6A6CA0000000000000000000000000000
      00000000000000000000F6F6F60FCACACA6BB5B5B595B0B0B0A2B0B0B0A2B5B5
      B595C8C8C86BF6F6F60F00000000000000000000000000000000000000000000
      0000000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF9DACADFFB38765FF85CEF5FF85CE
      F5FF85CEF5FFA9A195FFEAB185FFB88968FE0000000000000000000000009E9E
      9EB7BCBCBCFECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC4A791FFE2A97EFFD6A076FFC5AC99FFCCCCCCFFCCCCCCFFBBBB
      BBFDA5988EC4CC9970E4D79F75F5CFA687B40000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000A9A9A9E0C2C3CDFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFA9A9A9E00000000000000000000000000000
      0000EEEEEE1EAEAEAEB0ADADADE9C2C2C2FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFC2C2C2FFACACACE9AEAEAEAFEEEEEE1C0000000000000000000000000000
      0000000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CCF1FF87C2DEFF86ABBEFF8CA6B3FF91A8
      B3FF91A8B3FF88C6E4FF8BC3DDFFAE9781FFD4A27BFFBB9678FF85CEF5FF85CE
      F5FF85CDF4FFAE9883FFEDB487FFB48A67FE0000000000000000000000009494
      94DECCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC49775FFF0B78BFFC49572FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF939393DEF4EBE624F0E4DC33F3E9E02B0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000A9A9A9E06A77D8FF7E87BBFFA5A5A5FFA7A7A7FFA4A4A4FFA4A4A4FFA7A7
      A7FFA5A5A5FFA4A4A4FFC1C1C1FFA9A9A9E00000000000000000000000000000
      0000A5A5A5CBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCBCBCBFFA6A6A6CA0000000000000000000000000000
      0000000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF89A4B2FFABAAA9FFC7C7C7FFCCCCCCFFCCCC
      CCFFCCCCCCFFCABFB3FFC3926CFFE6AD81FFF0B78BFFCF9F7AFFBF9575FFBF95
      75FFBF9575FFD5A37BFFEAB185FFA5856BFE0000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC59774FFF0B78BFFC39877FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E00000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000939393EA5E6DCDFF3F57E5FF99A1D6FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC9C9C9FFA5A5A5FF969696E90000000000000000000000000000
      0000A9A9A9E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFA9A9A9E00000000000000000000000000000
      0000000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF80B8D6FFB8B9BAFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFDDC0AAFFD19C73FFEFB68AFFF0B78BFFE8AE82FFE4AA7FFFE4AA
      7FFFE4AA7EFFD6A279FFB39073FF5B8499FA0000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFBDBDBDFF9F9F9FFF8B8B8BFF898989FF878787FF8787
      87FF878787FFB28665FFEFB68AFFB98965FF9F9E9EFFBDBDBDFFCCCCCCFFC5B3
      A6FFB57B51FEC9956EE3C9956EE3BD875FED0000000000000000000000000000
      00000000000000000000A2ACF3755268EBD64D63EADD4D63EADD4D63EADD4D63
      EADD3F56DCFC3F58E5FF304CE7FF3C54E4FF959DD5FFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFF949494EA0000000000000000000000000000
      0000A9A9A9E0BFBFBFFFA4A4A4FFA5A5A5FFA7A7A7FFA4A4A4FFA4A4A4FFA7A7
      A7FFA5A5A5FFA4A4A4FFC1C1C1FFA1A1A1F2C8C8C86BF6F6F60F000000000000
      0000000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFC1C1C1FFCCCCCCFFB9B9B9FFA9A9A9FFA9A9
      A9FFA9A9A9FFA9A9A9FFBABABAFFC5926CFFEAB184FFBC9271FFA0ABAAFFA0AB
      AAFFA0ABABFF93B8C8FF7ABBDDFF5A8EAAE90000000000000000000000009494
      94E0B7B7B7FF898989FF979797FFB3B3B3FFCACACAFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC6AE9DFFDDA67BFFDFA67BFFB89378FF979696FF898989FFB7B7
      B7FFAC886AF4DCA478FCF0B78BFFCE9A75E00000000000000000000000000000
      000000000000D0D6F8393955E8F3455CE9E65F74EDC65F74EDC65F74EDC65F74
      EDC64D60DAF8465DE3FF304CE7FF455BE1FF9499BBFFAAAAAAFFAAAAAAFFAFAF
      AFFFB9B9B9FFCBCBCBFFCCCCCCFFA9A9A9E00000000000000000000000000000
      0000939393EAA2A2A2FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC9C9C9FFA5A5A5FF929292FFC2C2C2FFACACACE9AEAEAEAFEEEE
      EE1C000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFAAAAAAFFA5A5A5FFB9B9B9FFCBCBCBFFCCCC
      CCFFCCCCCCFFCBCBCBFFB9B9B9FFA5A5A5FFB59375FFB88B67FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF5A8EAAE90000000000000000000000008888
      88E9919191FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCBCBFFC2926FFFEAB085FFE0A87DFFC69571FFC39776FFBA8C
      68FFD49D73FEEEB589FFDAA276F6CE9B74E00000000000000000F6F6F60FCACA
      CA6BB5B5B5957783CACC304CE7FF7581CEC9C8C8C86BF6F6F60F000000000000
      0000A6A6A6E25E6DCEFF4259DEFF999FBFFFC2C2C2FFCBCBCBFFCBCBCBFFC2C2
      C2FFB5B5B5FFA3A3A3FFA3A3A3FFA4A4A4E20000000000000000000000000000
      0000939393EACCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFF909090FFCCCCCCFFCCCCCCFFCBCBCBFFA6A6
      A6CA000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF7EAAC1FFAAAAAAFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFABABABFF8A969AFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000007777
      77F4CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCAC4C0FFC2916DFFDDA57BFFEFB68AFFF0B78BFFF0B7
      8BFFE0A77CFFC89771DBDBBCA584BA8157F5EEEEEE1EAEAEAEB0ADADADE9C2C2
      C2FFCCCCCCFF8490D9FF304CE7FF8490D9FFC2C2C2FFACACACE9AEAEAEAFEEEE
      EE1C8B8B8BEE7583DAFFADB2D3FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCBCBCBFF8C8C8CEE0000000000000000000000000000
      0000A9A9A9E0CCCCCCFFCBCBCBFFB9B9B9FFAFAFAFFFAAAAAAFFAAAAAAFFAFAF
      AFFFB9B9B9FFCBCBCBFFCCCCCCFFA4A4A4FFCCCCCCFFCCCCCCFFCCCCCCFFA9A9
      A9E0000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFC1C1C1FFCCCCCCFFC5C5C5FFB5B5B5FFACAC
      ACFFACACACFFB5B5B5FFC5C5C5FFCCCCCCFFC1C1C1FF81B4CFFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000008F8F
      8FE3CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCBCBFFC6AF9DFFC39776FFC3936FFFC496
      73FFA68873F1FBF9F70B00000000E5D0C159A5A5A5CBCBCBCBFFCCCCCCFFCCCC
      CCFFCCCCCCFF8490D9FF304CE7FF8490D9FFCCCCCCFFCCCCCCFFCBCBCBFFA6A6
      A6CAA9A9A9E0CBCBCDFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFA9A9A9E00000000000000000000000000000
      0000A6A6A6E2A3A3A3FFA3A3A3FFB5B5B5FFC2C2C2FFCBCBCBFFCBCBCBFFC2C2
      C2FFB5B5B5FFA3A3A3FFA3A3A3FF9B9B9BFFA5A5A5FFA4A4A4FFC1C1C1FFA9A9
      A9E0000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFA9A9A9FFA5A5A5FFAFAFAFFFC1C1C1FFC9C9
      C9FFC9C9C9FFC1C1C1FFAFAFAFFFA4A4A4FFA9A9A9FF81B4CFFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCBCBCBFFBFBFBFFFADADADFFA3A3A3FF999999FF9191
      91FF919191FF999999FFA3A3A3FFAEAEAEFFBFBFBFFFCBCBCBFFCCCCCCFFCCCC
      CCFF949494E0000000000000000000000000A9A9A9E0CCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFF8490D9FF304CE7FF8490D9FFCCCCCCFFCCCCCCFFCCCCCCFFA9A9
      A9E0A9A9A9E0C5C5C5FFA9A9A9FFA3A3A3FFA1A1A1FF9E9E9EFF9E9E9EFFA1A1
      A1FFA3A3A3FFA9A9A9FFC5C5C5FFA9A9A9E00000000000000000000000000000
      00008B8B8BEECBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCBCBCBFF898989FFCCCCCCFFC9C9C9FFA5A5A5FF9696
      96E9000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF7EACC4FFB0B0B0FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFB0B0B0FF7EACC5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000009494
      94E0C5C5C5FF9B9B9BFF8B8B8BFF999999FFB1B1B1FFBBBBBBFFC3C3C3FFCBCB
      CBFFCBCBCBFFC3C3C3FFBBBBBBFFB1B1B1FF999999FF8C8C8CFF9B9B9BFFC5C5
      C5FF949494E0000000000000000000000000A9A9A9E0BFBFBFFFA4A4A4FFA5A5
      A5FFA7A7A7FF6F7AC4FF304CE7FF707CC6FFA5A5A5FFA4A4A4FFC1C1C1FFA9A9
      A9E0999999EEA5A5A5FFC4C4C4FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC3C3C3FFA5A5A5FF999999EE0000000000000000000000000000
      0000A9A9A9E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFA4A4A4FFCCCCCCFFCCCCCCFFCCCCCCFF9494
      94EA000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFC1C1C1FFCCCCCCFFCBCBCBFFC5C5C5FFBFBF
      BFFFBFBFBFFFC5C5C5FFCBCBCBFFCCCCCCFFC1C1C1FF81B4CFFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000008888
      88E9919191FFC0C0C0FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC0C0C0FF9191
      91FF888888E9000000000000000000000000939393EAA2A2A2FFC9C9C9FFCCCC
      CCFFCCCCCCFF8490D9FF304CE7FF8490D9FFCCCCCCFFC9C9C9FFA5A5A5FF9696
      96E99D9D9DEACCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFF9E9E9EE90000000000000000000000000000
      0000A9A9A9E0C5C5C5FFA9A9A9FFA3A3A3FFA1A1A1FF9E9E9EFF9E9E9EFFA1A1
      A1FFA3A3A3FFA9A9A9FFC5C5C5FFA0A0A0FFB9B9B9FFCBCBCBFFCCCCCCFFA9A9
      A9E0000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF81B4CFFFAEAEAEFFA6A6A6FFA9A9A9FFB1B1B1FFB7B7
      B7FFB7B7B7FFB1B1B1FFA9A9A9FFA6A6A6FFAFAFAFFF81B4CFFF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000007777
      77F3CBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF787878F3000000000000000000000000939393EACCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFAEB2D1FF8791D8FFAEB2D1FFCCCCCCFFCCCCCCFFCCCCCCFF9494
      94EADBDBDB47ABABABC4B2B2B2F3C9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFC8C8C8FFB2B2B2F3ABABABC4DBDBDB460000000000000000000000000000
      0000999999EEA5A5A5FFC4C4C4FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFC3C3C3FFA5A5A5FF959595FFB5B5B5FFA3A3A3FFA3A3A3FFA4A4
      A4E2000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF7FAFC9FFA8A9AAFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFA7A9A9FF7FAFC8FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E0000000000000000000000000A9A9A9E0CCCCCCFFCBCBCBFFB9B9
      B9FFAFAFAFFFAAAAAAFFAAAAAAFFAFAFAFFFB9B9B9FFCBCBCBFFCCCCCCFFA9A9
      A9E00000000000000000E6E6E62ABFBFBF7DB6B6B696B0B0B0A2B0B0B0A2B6B6
      B696C1C1C17CE7E7E72900000000000000000000000000000000000000000000
      00009D9D9DEACCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFF9A9A9AFFCCCCCCFFCCCCCCFFCBCBCBFF8C8C
      8CEE000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF84CBF0FF89A0ACFFB1B6B8FFCBCBCBFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCBCBCBFFB0B5B7FF889FABFF84CBF1FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000009494
      94E0CCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC9C9C9FFC4C4C4FFBFBF
      BFFFBFBFBFFFC4C4C4FFC9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFF949494E0000000000000000000000000A6A6A6E2A3A3A3FFA3A3A3FFB5B5
      B5FFC2C2C2FFCBCBCBFFCBCBCBFFC2C2C2FFB5B5B5FFA3A3A3FFA3A3A3FFA4A4
      A4E2000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000DBDBDB47ABABABC4B2B2B2F3C9C9C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFC8C8C8FFB0B0B0FF9F9F9FFFB6B6B6FFCCCCCCFFCCCCCCFFCCCCCCFFA9A9
      A9E0000000000000000000000000000000007FA7BCB578BDE2FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF81BFE0FF85ACC1FF8CABBCFF90AB
      B9FF90ABB9FF8CABBCFF84ACC1FF81BFE1FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000009494
      94E0CCCCCCFFBBBBBBFF9D9D9DFF8F8F8FFF8F8F8FFF939393FF9B9B9BFFA3A3
      A3FFA3A3A3FF9B9B9BFF939393FF8F8F8FFF8F8F8FFF9D9D9DFFBCBCBCFFCCCC
      CCFF949494E00000000000000000000000008B8B8BEECBCBCBFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCBCBFF8C8C
      8CEE000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000E6E6E62ABFBFBF7D929292F29B9B9BFF919191FF9090
      90FF919191FF969696FF9E9E9EFFA1A1A1FFA3A3A3FFA9A9A9FFC5C5C5FFA9A9
      A9E0000000000000000000000000000000008EB2C29E518DADFF528FB0FF528F
      B0FF528FB0FF528FB0FF528FB0FF528EADFF73B6DAFF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CEF5FF85CE
      F5FF85CEF5FF85CEF5FF78BDE2FF7FA7BCB50000000000000000000000008F8F
      8FE38F8F8FFF9D9D9DFFBFBFBFFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFBEBEBEFF9D9D9DFF9090
      90FF909090E3000000000000000000000000A9A9A9E0CCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFA9A9
      A9E0000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000999999EEA5A5A5FFC4C4C4FFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC3C3C3FFA5A5A5FF9999
      99EE00000000000000000000000000000000A9C5D2765FA5CDFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65B0DBFF64AEDAFF558EADF5548BAAF9548CABF9548C
      ABF9548CABF9548CABF9548CABF9548CABF9548CABF9548CABF9548CABF9548C
      ABF9548CABF9548CABF9538BA8FA8EB0C39D0000000000000000000000007B7B
      7BFBC3C3C3FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC2C2
      C2FF7A7A7AFB000000000000000000000000A9A9A9E0C5C5C5FFA9A9A9FFA3A3
      A3FFA1A1A1FF9E9E9EFF9E9E9EFFA1A1A1FFA3A3A3FFA9A9A9FFC5C5C5FFA9A9
      A9E0000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000009D9D9DEACCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9E9E
      9EE900000000000000000000000000000000A9C5D2765FA5CDFF65B0DBFF65B0
      DBFF65B0DBFF65B0DBFF65AFDBFF5E97B8EDB5CCD96800000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008F8F
      8FDBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCB
      CBFF8F8F8FDB000000000000000000000000999999EEA5A5A5FFC4C4C4FFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC3C3C3FFA5A5A5FF9999
      99EE000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000DBDBDB47ABABABC4B2B2B2F3C9C9
      C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC8C8C8FFB2B2B2F3ABABABC4DBDB
      DB4600000000000000000000000000000000C8D9E14B709DB5C6709DB5C6709D
      B5C6709DB5C6709DB5C6709DB5C6BACFDA610000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000DFDF
      DF398D8D8DDBB0B0B0FBCBCBCBFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCBCBCBFFB0B0B0FB8F8F
      8FDAE0E0E0360000000000000000000000009D9D9DEACCCCCCFFCCCCCCFFCCCC
      CCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFF9E9E
      9EE9000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E6E6E62ABFBF
      BF7DB6B6B696B0B0B0A2B0B0B0A2B6B6B696C1C1C17CE7E7E729000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FAFAFA08C4C4C46D9D9D9DBC979797D6A2A2A2E7ABABABF0AFAFAFFCB7B7
      B7FFB7B7B7FFAFAFAFFCABABABF0A2A2A2E7969696D69E9E9EBBC2C2C26CFAFA
      FA0800000000000000000000000000000000DBDBDB47ABABABC4B2B2B2F3C9C9
      C9FFCCCCCCFFCCCCCCFFCCCCCCFFCCCCCCFFC8C8C8FFB2B2B2F3ABABABC4DBDB
      DB46000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FEFEFE01E8E8E827DDDDDD39D4D4D447CACA
      CA5FCACACA5FD4D4D447DDDDDD39E8E8E8270000000000000000000000000000
      0000000000000000000000000000000000000000000000000000E6E6E62ABFBF
      BF7DB6B6B696B0B0B0A2B0B0B0A2B6B6B696C1C1C17CE7E7E729000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000060000000300000000100010000000000400200000000000000000000
      000000000000000000000000FFFFFF00FF0003FF00CFFF008F000000F80001F8
      0007F80005000000E00000E00003E00000000000E00000E00001E00000000000
      E00000E00000E00021000000E00000E00000E00071000000E00000E00007E000
      20000000E00000E00007E00000000000E00000E00007E00000000000E00001E0
      0007E00007000000E00003E00007E00007000000E00007E00007E00007000000
      E00007E00007E00007000000E00007E00007E00007000000E00007E00007E000
      07000000E00007E00007E00007000000E00007E00007E00007000000E00007E0
      0007E00007000000E00007E00007E00007000000E00007E00007E00007000000
      E00007E00007E00007000000E00007E00007E00007000000F0000FF0000FF000
      0F000000FE00FFFE00FFFE00FF000000FFFFF8FF0003FFFC03FFFFFFFFFFF8F8
      0001FFF000FFFFFF000000E00000FFF000FC03FF000000E00000FFF000F000FF
      000000E00000FFF000F000FF000000E00007FFF000F000FF000000E00000FC00
      00F0003F000000E00000F80000F0000F000000E00000C03000F0000F000000E0
      0000000000F0000F000000E00002000000F0000F000000E00007000000F0000F
      000000E00007000000F0000F000000E00007000000F0000F000000E000070000
      00F0000F000000E00007000C03F0000F000000E00007000FFFF0000F000000E0
      0007000FFFFC000F000000E00007000FFFFF000F000000E00007000FFFFF000F
      007FFFE00007000FFFFF000F00FFFFE00007000FFFFFC03FFFFFFFF0000F000F
      FFFFFFFFFFFFFFFE00FFC03FFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object imgListInstrumentationMedium: TImageList
    Height = 36
    Width = 36
    Left = 223
    Top = 422
    Bitmap = {
      494C010101000800040024002400FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000900000002400000001002000000000000051
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000082A56CEC7EA4
      69F47DA367F69DB98CBD00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F7F5F414F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0
      ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0
      ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED22F2F0ED2280A46AF3BDE0
      BAFFAFD2A8FF96B385CEF7F5F414000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B8ADA4AFA190F2B5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA
      9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA
      9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BEDB5AA9BED7BA065FEBDE0
      BAFFAFD2A8FF88A370FCC3B8ADA4000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFECF1
      E9FF9BB88AFF9AB889FF9AB889FF9AB889FF9AB889FF9AB889FF799F61FFBDE0
      BAFFAFD2A8FF7EA268FF8CA776EC9AB888C69AB888C69AB888C69AB888C69DB9
      8CBD000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE4EB
      DFFF8BAE79FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FFBDE0
      BAFFBBDDB7FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FFAFD2A8FF7DA3
      67F6000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFD8D8D8FFE8E8E8FFFFFFFFFFFFFFFFFFE4EB
      DFFF90B37EFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0
      BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFFBDE0BAFF7EA4
      69F4000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFC3C3C3FFABABABFFFFFFFFFFFFFFFFFFE7EE
      E3FF81A56CFF80A56BFF80A56BFF80A56BFF80A56BFF80A56BFF779D5FFFBDE0
      BAFFAFD2A8FF799E60FF7CA067FA80A56AF180A56AF180A56AF180A56AF182A5
      6CEC000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFF4F4F4FF7A7A7AFFFEFEFEFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFB7B7B7FFE1E1E1FFFFFFFFFFFFFFFFFF979797FFD6D6D6FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFE1E1E1FFB8B8B8FFFFFFFFFFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3
      F3FF7F7F7FFFFBFBFBFFFFFFFFFFFFFFFFFFCDCDCDFFA0A0A0FFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFBFBFBFF7F7F7FFFF3F3F3FFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA9A9
      A9FFBCBCBCFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFAFF777777FFFAFAFAFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFBBBBBBFFA9A9A9FFFFFFFFFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFECECECFF7575
      75FFFAFAFAFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFA1A1A1FFCBCBCBFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFAFAFF757575FFEDEDEDFF80A56BFFBDE0
      BAFFAFD2A8FF93B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7FF7676
      76FFEFEFEFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFD7D7D7FF949494FFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFEFEFEFFF767676FFF7F7F7FF81A56CFF90B3
      7EFF8BAE79FF94B080FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFBCBC
      BCFFABABABFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFDFDFDFF797979FFF4F4
      F4FFFFFFFFFFFFFFFFFFFFFFFFFFAAAAAAFFBCBCBCFFFFFFFFFFE7EEE3FFE4EB
      DFFFE4EBDFFFD2D3C6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFAFA
      FAFF7D7D7DFFF5F5F5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFACACACFFBFBF
      BFFFFFFFFFFFFFFFFFFFF4F4F4FF7D7D7DFFFAFAFAFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFD4D4D4FFE9E9E9FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE2E2E2FF8989
      89FFFFFFFFFFFFFFFFFFE9E9E9FFD5D5D5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F
      7FFFECECECFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFB6B6
      B6FFB5B5B5FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F3
      F3FFEDEDEDFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE1DCD6FFC3B9ADA8000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFE0DAD4FFB0A293FFB0A293FFB0A293FFB0A293FFB0A293FFB0A2
      93FFB0A293FFAC9D8DFFB1A496D4000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFC7BDB2FFF2F0EDFFF2F0EDFFF2F0EDFFF2F0EDFFF2F0
      EDFFE2DDD8FFA29381FED5CDC76D000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFCDC5BBFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF3F1
      EFFFA79887FED2C9C07700000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFCDC5BBFFFFFFFFFFFFFFFFFFFFFFFFFFF3F1EFFFA798
      87FED3C9C1770000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFCDC5BBFFFFFFFFFFFFFFFFFFF3F1EFFFA89988FED2CB
      C276000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFCDC5BBFFFFFFFFFFF3F1EFFFA89988FED2CBC2760000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFCDC5BBFFF3F1EFFFA89988FED2CCC274000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C3B9ADA8E1DCD6FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFD7D1C9FFBFB4A8FFA79887FED3CDC56F00000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C4B9AEA5B2A697F3BCB2A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2
      A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2A5EEBCB2
      A5EEBCB2A5EEAFA293F59E8E7AFFD3CCC56E0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000F2F1EE1FEBE8E433EBE8E433EBE8E433EBE8E433EBE8E433EBE8
      E433EBE8E433EBE8E433EBE8E433EBE8E433EBE8E433EBE8E433EBE8E433EBE8
      E433EBE8E433E4E1DB43EAE5E237000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000090000000240000000100010000000000D00200000000000000000000
      000000000000000000000000FFFFFF00FFFFFFC3F00000000000000000000000
      00000000F8000001F0000000000000000000000000000000F8000001F0000000
      000000000000000000000000F8000001F0000000000000000000000000000000
      F8000001F0000000000000000000000000000000F8000001F000000000000000
      0000000000000000F800000000000000000000000000000000000000F8000000
      00000000000000000000000000000000F8000000000000000000000000000000
      00000000F800000000000000000000000000000000000000F8000001F0000000
      000000000000000000000000F8000001F0000000000000000000000000000000
      F8000001F0000000000000000000000000000000F8000001F000000000000000
      0000000000000000F8000001F0000000000000000000000000000000F8000001
      F0000000000000000000000000000000F8000001F00000000000000000000000
      00000000F8000001F0000000000000000000000000000000F8000001F0000000
      000000000000000000000000F8000001F0000000000000000000000000000000
      F8000001F0000000000000000000000000000000F8000001F000000000000000
      0000000000000000F8000001F0000000000000000000000000000000F8000001
      F0000000000000000000000000000000F8000001F00000000000000000000000
      00000000F8000001F0000000000000000000000000000000F8000001F0000000
      000000000000000000000000F8000003F0000000000000000000000000000000
      F8000007F0000000000000000000000000000000F800000FF000000000000000
      0000000000000000F800001FF0000000000000000000000000000000F800003F
      F0000000000000000000000000000000F800007FF00000000000000000000000
      00000000F80000FFF0000000000000000000000000000000F80001FFF0000000
      000000000000000000000000FFFFFFFFF0000000000000000000000000000000
      00000000000000000000000000000000000000000000}
  end
  object ApplicationTaskbar: TTaskbar
    TaskBarButtons = <>
    TabProperties = []
    Left = 736
    Top = 336
  end
  object JumpList1: TJumpList
    AutoRefresh = True
    Enabled = True
    CustomCategories = <>
    ShowRecent = True
    TaskList = <>
    Left = 672
    Top = 336
  end
  object popRecentGis: TPopupMenu
    Left = 317
    Top = 210
  end
  object MRUGis: TGPMRUFiles
    PopupMenu = popRecentGis
    MaxFiles = 9
    StandAloneMenu = True
    DeleteEntry = False
    OnClick = MRUGisClick
    Left = 107
    Top = 204
  end
end
