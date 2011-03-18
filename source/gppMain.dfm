object frmMain: TfrmMain
  Left = 312
  Top = 179
  Caption = 'GpProfile 2011'
  ClientHeight = 514
  ClientWidth = 612
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
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
    Top = 490
    Width = 612
    Height = 24
    Panels = <
      item
        Width = 650
      end
      item
        Width = 0
      end>
    OnResize = StatusBarResize
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 612
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Panel5: TPanel
      Left = 214
      Top = 0
      Width = 201
      Height = 26
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object ToolBar2: TToolBar
        Left = 0
        Top = 0
        Width = 194
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Images = imglButtons
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton22: TToolButton
          Left = 0
          Top = 0
          Action = actOpenProfile
          DropdownMenu = popRecentPrf
          Style = tbsDropDown
        end
        object ToolButton23: TToolButton
          Left = 36
          Top = 0
          Action = actRescanProfile
        end
        object ToolButton11: TToolButton
          Left = 59
          Top = 0
          Width = 8
          Caption = 'ToolButton11'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object ToolButton2: TToolButton
          Left = 67
          Top = 0
          Action = actRenameMoveProfile
        end
        object ToolButton5: TToolButton
          Left = 90
          Top = 0
          Action = actMakeCopyProfile
        end
        object ToolButton13: TToolButton
          Left = 113
          Top = 0
          Action = actDelUndelProfile
        end
        object ToolButton24: TToolButton
          Left = 136
          Top = 0
          Action = actExportProfile
        end
        object ToolButton21: TToolButton
          Left = 159
          Top = 0
          Width = 8
          Caption = 'ToolButton21'
          ImageIndex = 10
          Style = tbsSeparator
        end
        object ToolButton25: TToolButton
          Left = 167
          Top = 0
          Action = actProfileOptions
          ParentShowHint = False
          ShowHint = True
        end
      end
    end
    object pnlToolbarMain: TPanel
      Left = 415
      Top = 0
      Width = 56
      Height = 26
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 2
      object tbrMain: TToolBar
        Left = 0
        Top = 0
        Width = 50
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Images = imglButtons
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton41: TToolButton
          Left = 0
          Top = 0
          Action = actPreferences
          AllowAllUp = True
          ParentShowHint = False
          ShowHint = True
        end
        object ToolButton14: TToolButton
          Left = 23
          Top = 0
          Action = actHelpContents
        end
      end
    end
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 214
      Height = 26
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object tbrProject: TToolBar
        Left = 0
        Top = 0
        Width = 207
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'tbrProject'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Images = imglButtons
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Action = actOpen
          AllowAllUp = True
          DropdownMenu = popRecent
          Style = tbsDropDown
        end
        object ToolButton8: TToolButton
          Left = 36
          Top = 0
          Action = actRescanProject
        end
        object ToolButton6: TToolButton
          Left = 59
          Top = 0
          Width = 8
          Caption = 'ToolButton6'
          ImageIndex = 9
          Style = tbsSeparator
        end
        object ToolButton9: TToolButton
          Left = 67
          Top = 0
          Action = actInstrumentRun
        end
        object ToolButton3: TToolButton
          Left = 90
          Top = 0
          Action = actInstrument
          AllowAllUp = True
        end
        object ToolButton4: TToolButton
          Left = 113
          Top = 0
          Action = actRemoveInstrumentation
          AllowAllUp = True
        end
        object tbtnRun: TToolButton
          Left = 136
          Top = 0
          Action = actRun
          AllowAllUp = True
          DropdownMenu = popDelphiVer
          Style = tbsDropDown
        end
        object ToolButton7: TToolButton
          Left = 172
          Top = 0
          Width = 8
          Caption = 'ToolButton7'
          ImageIndex = 9
          Style = tbsSeparator
        end
        object ToolButton10: TToolButton
          Left = 180
          Top = 0
          Action = actProjectOptions
          ParentShowHint = False
          ShowHint = True
        end
      end
    end
    object pnlToolbarLayout: TPanel
      Left = 471
      Top = 0
      Width = 141
      Height = 26
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 3
      object tbrLayout: TToolBar
        Left = 0
        Top = 0
        Width = 109
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'ToolBar1'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        Images = imglButtons
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton15: TToolButton
          Left = 0
          Top = 0
          Action = actShowHideSourcePreview
        end
        object ToolButton16: TToolButton
          Left = 23
          Top = 0
          Action = actShowHideCallers
        end
        object ToolButton17: TToolButton
          Left = 46
          Top = 0
          Action = actShowHideCallees
        end
        object tBtnLayout: TToolButton
          Left = 69
          Top = 0
          Action = actLayoutManager
          DropdownMenu = popLayout
          Style = tbsDropDown
        end
      end
    end
  end
  object Panel0: TPanel
    Left = 0
    Top = 26
    Width = 612
    Height = 464
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object splitSourcePreview: TSplitter
      Left = 0
      Top = 340
      Width = 612
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      OnMoved = splitCallersMoved
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 612
      Height = 340
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object PageControl1: TPageControl
        Left = 0
        Top = 0
        Width = 612
        Height = 340
        ActivePage = tabAnalysis
        Align = alClient
        HotTrack = True
        Images = imglButtons
        TabOrder = 0
        OnChange = PageControl1Change
        object tabInstrumentation: TTabSheet
          Caption = 'Instrumentation'
          ImageIndex = 16
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object Splitter1: TSplitter
            Left = 129
            Top = 25
            Height = 286
          end
          object Splitter2: TSplitter
            Left = 269
            Top = 25
            Height = 286
          end
          object pnlTop: TPanel
            Left = 0
            Top = 0
            Width = 604
            Height = 25
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object chkShowAll: TCheckBox
              Left = 6
              Top = 4
              Width = 99
              Height = 17
              Caption = '&Show all folders'
              TabOrder = 0
              OnClick = cbProfileChange
            end
          end
          object pnlUnits: TPanel
            Left = 0
            Top = 25
            Width = 129
            Height = 286
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 1
            DesignSize = (
              129
              286)
            object clbUnits: TGpCheckListBox
              Tag = 258
              Left = 4
              Top = 24
              Width = 123
              Height = 258
              OnClickCheck = clbUnitsClickCheck
              AllowGrayed = True
              Anchors = [akLeft, akTop, akRight, akBottom]
              ItemHeight = 13
              TabOrder = 0
              OnClick = clbUnitsClick
            end
            object lblUnits: TStaticText
              Left = 4
              Top = 4
              Width = 37
              Height = 17
              Caption = '&Units:'
              TabOrder = 1
            end
          end
          object pnlClasses: TPanel
            Left = 132
            Top = 25
            Width = 137
            Height = 286
            Align = alLeft
            BevelOuter = bvNone
            TabOrder = 2
            DesignSize = (
              137
              286)
            object clbClasses: TGpCheckListBox
              Left = 2
              Top = 24
              Width = 133
              Height = 258
              OnClickCheck = clbClassesClickCheck
              AllowGrayed = True
              Anchors = [akLeft, akTop, akRight, akBottom]
              ItemHeight = 13
              TabOrder = 0
              OnClick = clbClassesClick
            end
            object lblClasses: TStaticText
              Left = 3
              Top = 4
              Width = 49
              Height = 17
              Caption = '&Classes:'
              TabOrder = 1
            end
          end
          object pnlProcs: TPanel
            Left = 272
            Top = 25
            Width = 332
            Height = 286
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 3
            DesignSize = (
              332
              286)
            object clbProcs: TGpCheckListBox
              Left = 2
              Top = 24
              Width = 326
              Height = 258
              OnClickCheck = clbProcsClickCheck
              Anchors = [akLeft, akTop, akRight, akBottom]
              ItemHeight = 13
              TabOrder = 0
              OnClick = clbProcsClick
            end
            object lblProcs: TStaticText
              Left = 2
              Top = 4
              Width = 67
              Height = 17
              Caption = 'P&rocedures:'
              TabOrder = 1
            end
          end
        end
        object tabAnalysis: TTabSheet
          Caption = 'Analysis'
          ImageIndex = 17
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitWidth = 0
          ExplicitHeight = 0
          object PageControl2: TPageControl
            Left = 0
            Top = 0
            Width = 604
            Height = 311
            ActivePage = tabProcedures
            Align = alClient
            HotTrack = True
            TabOrder = 0
            OnChange = PageControl2Change
            object tabProcedures: TTabSheet
              Caption = 'Procedures'
              ImageIndex = -1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              object splitCallees: TSplitter
                Left = 0
                Top = 186
                Width = 596
                Height = 3
                Cursor = crVSplit
                Align = alBottom
                Color = clBtnFace
                ParentColor = False
                Visible = False
                OnMoved = splitCallersMoved
              end
              object Panel2: TPanel
                Left = 0
                Top = 0
                Width = 596
                Height = 31
                Align = alTop
                BevelOuter = bvNone
                TabOrder = 0
                DesignSize = (
                  596
                  31)
                object lblSelectThreadProc: TLabel
                  Left = 6
                  Top = 8
                  Width = 66
                  Height = 13
                  Caption = '&Select thread:'
                  FocusControl = cbxSelectThreadProc
                end
                object cbxSelectThreadProc: TComboBox
                  Left = 78
                  Top = 4
                  Width = 145
                  Height = 21
                  Style = csDropDownList
                  ItemHeight = 0
                  TabOrder = 0
                  OnChange = cbxSelectThreadProcChange
                end
                object pnlBrowser: TPanel
                  Left = 496
                  Top = 4
                  Width = 95
                  Height = 26
                  Anchors = [akTop, akRight]
                  BevelOuter = bvNone
                  TabOrder = 1
                  object ToolBar3: TToolBar
                    Left = 23
                    Top = 0
                    Width = 72
                    Height = 26
                    Align = alRight
                    AutoSize = True
                    Caption = 'ToolBar3'
                    EdgeInner = esNone
                    EdgeOuter = esNone
                    Images = imglButtons
                    ParentShowHint = False
                    ShowHint = True
                    TabOrder = 0
                    object ToolButton18: TToolButton
                      Left = 0
                      Top = 0
                      Action = actBrowsePrevious
                      DropdownMenu = popBrowsePrevious
                      ParentShowHint = False
                      PopupMenu = popBrowsePrevious
                      ShowHint = True
                      Style = tbsDropDown
                    end
                    object ToolButton19: TToolButton
                      Left = 36
                      Top = 0
                      Action = actBrowseNext
                      DropdownMenu = popBrowseNext
                      ParentShowHint = False
                      ShowHint = True
                      Style = tbsDropDown
                    end
                  end
                end
              end
              object pnlTopTwo: TPanel
                Left = 0
                Top = 31
                Width = 596
                Height = 155
                Align = alClient
                BevelOuter = bvNone
                TabOrder = 3
                object splitCallers: TSplitter
                  Left = 0
                  Top = 82
                  Width = 596
                  Height = 3
                  Cursor = crVSplit
                  Align = alTop
                  Color = clBtnFace
                  ParentColor = False
                  Visible = False
                  OnMoved = splitCallersMoved
                end
                object pnlCallers: TPanel
                  Left = 0
                  Top = 0
                  Width = 596
                  Height = 82
                  Align = alTop
                  BevelOuter = bvNone
                  TabOrder = 0
                  Visible = False
                  DesignSize = (
                    596
                    82)
                  object lvCallers: TGpArrowListView
                    Tag = 79
                    Left = 18
                    Top = 1
                    Width = 574
                    Height = 79
                    Anchors = [akLeft, akTop, akRight, akBottom]
                    Columns = <
                      item
                        Caption = 'Procedure'
                        Width = 150
                      end
                      item
                        Alignment = taRightJustify
                        Caption = '% Time'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Time'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'w/Child'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Calls'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Min/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Max/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Avg/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end>
                    ReadOnly = True
                    RowSelect = True
                    TabOrder = 0
                    ViewStyle = vsReport
                    OnClick = lvCalleesClick
                    OnCompare = lvCallersCompare
                    OnDblClick = lvCallersDblClick
                    OnColumnResize = lvProcsColumnResize
                    OnColumnTrack = lvCalleesColumnTrack
                  end
                end
                object pnlCurrent: TPanel
                  Left = 0
                  Top = 85
                  Width = 596
                  Height = 70
                  Align = alClient
                  BevelOuter = bvNone
                  TabOrder = 1
                  DesignSize = (
                    596
                    70)
                  object lvProcs: TGpArrowListView
                    Tag = 68
                    Left = 17
                    Top = 1
                    Width = 575
                    Height = 65
                    Anchors = [akLeft, akTop, akRight, akBottom]
                    Columns = <
                      item
                        Caption = 'Procedure'
                        Width = 150
                      end
                      item
                        Alignment = taRightJustify
                        Caption = '% Time'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Time'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'w/Child'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Calls'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Min/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Max/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end
                      item
                        Alignment = taRightJustify
                        Caption = 'Avg/Call'
                        MaxWidth = 80
                        MinWidth = 80
                        Width = 80
                      end>
                    ReadOnly = True
                    RowSelect = True
                    PopupMenu = popAnalysisListview
                    TabOrder = 0
                    ViewStyle = vsReport
                    OnClick = lvProcsClick
                    OnCompare = lvProcsCompare
                    OnSelectItem = lvProcsSelectItem
                    OnColumnResize = lvProcsColumnResize
                    OnColumnTrack = lvCalleesColumnTrack
                  end
                end
              end
              object pnlCallees: TPanel
                Left = 0
                Top = 189
                Width = 596
                Height = 91
                Align = alBottom
                BevelOuter = bvNone
                TabOrder = 2
                Visible = False
                DesignSize = (
                  596
                  91)
                object lvCallees: TGpArrowListView
                  Tag = 89
                  Left = 17
                  Top = 1
                  Width = 575
                  Height = 89
                  Anchors = [akLeft, akTop, akRight, akBottom]
                  Columns = <
                    item
                      Caption = 'Procedure'
                      Width = 150
                    end
                    item
                      Alignment = taRightJustify
                      Caption = '% Time'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'Time'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'w/Child'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'Calls'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'Min/Call'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'Max/Call'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end
                    item
                      Alignment = taRightJustify
                      Caption = 'Avg/Call'
                      MaxWidth = 80
                      MinWidth = 80
                      Width = 80
                    end>
                  ReadOnly = True
                  RowSelect = True
                  TabOrder = 0
                  ViewStyle = vsReport
                  OnClick = lvCalleesClick
                  OnCompare = lvCalleesCompare
                  OnDblClick = lvCallersDblClick
                  OnColumnResize = lvProcsColumnResize
                  OnColumnTrack = lvCalleesColumnTrack
                end
              end
              object pnlBottom: TPanel
                Left = 0
                Top = 280
                Width = 596
                Height = 3
                Align = alBottom
                BevelOuter = bvNone
                TabOrder = 1
              end
            end
            object tabClasses: TTabSheet
              Caption = 'Classes'
              ImageIndex = -1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              DesignSize = (
                596
                283)
              object Label1: TLabel
                Left = 6
                Top = 8
                Width = 66
                Height = 13
                Caption = '&Select thread:'
                FocusControl = cbxSelectThreadClass
              end
              object cbxSelectThreadClass: TComboBox
                Left = 78
                Top = 4
                Width = 145
                Height = 21
                Style = csDropDownList
                ItemHeight = 0
                TabOrder = 0
                OnChange = cbxSelectThreadClassChange
              end
              object lvClasses: TGpArrowListView
                Tag = 248
                Left = 4
                Top = 32
                Width = 587
                Height = 204
                Anchors = [akLeft, akTop, akRight, akBottom]
                Columns = <
                  item
                    Caption = 'Class'
                    Width = 275
                  end
                  item
                    Alignment = taRightJustify
                    Caption = '% Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Calls'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end>
                ReadOnly = True
                RowSelect = True
                PopupMenu = popAnalysisListview
                TabOrder = 1
                ViewStyle = vsReport
                OnClick = lvProcsClick
                OnCompare = lvClassesCompare
                OnSelectItem = lvProcsSelectItem
                ExplicitHeight = 207
              end
            end
            object tabUnits: TTabSheet
              Caption = 'Units'
              ImageIndex = -1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              DesignSize = (
                596
                283)
              object Label2: TLabel
                Left = 6
                Top = 8
                Width = 66
                Height = 13
                Caption = '&Select thread:'
                FocusControl = cbxSelectThreadUnit
              end
              object cbxSelectThreadUnit: TComboBox
                Left = 78
                Top = 4
                Width = 145
                Height = 21
                Style = csDropDownList
                ItemHeight = 0
                TabOrder = 0
                OnChange = cbxSelectThreadUnitChange
              end
              object lvUnits: TGpArrowListView
                Left = 4
                Top = 32
                Width = 588
                Height = 204
                Anchors = [akLeft, akTop, akRight, akBottom]
                Columns = <
                  item
                    Caption = 'Unit'
                    Width = 275
                  end
                  item
                    Alignment = taRightJustify
                    Caption = '% Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Calls'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end>
                HotTrack = True
                ReadOnly = True
                RowSelect = True
                PopupMenu = popAnalysisListview
                TabOrder = 1
                ViewStyle = vsReport
                OnClick = lvProcsClick
                OnCompare = lvUnitsCompare
                OnSelectItem = lvProcsSelectItem
                ExplicitHeight = 207
              end
            end
            object tabThreads: TTabSheet
              Caption = 'Threads'
              ImageIndex = -1
              ExplicitLeft = 0
              ExplicitTop = 0
              ExplicitWidth = 0
              ExplicitHeight = 0
              DesignSize = (
                596
                283)
              object lvThreads: TGpArrowListView
                Left = 4
                Top = 32
                Width = 589
                Height = 207
                Anchors = [akLeft, akTop, akRight, akBottom]
                Columns = <
                  item
                    Caption = 'Thread'
                    Width = 275
                  end
                  item
                    Alignment = taRightJustify
                    Caption = '% Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Time'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end
                  item
                    Alignment = taRightJustify
                    Caption = 'Calls'
                    MaxWidth = 75
                    MinWidth = 75
                    Width = 75
                  end>
                HotTrack = True
                ReadOnly = True
                RowSelect = True
                PopupMenu = popAnalysisListview
                TabOrder = 0
                ViewStyle = vsReport
                OnCompare = lvThreadsCompare
                ExplicitHeight = 210
              end
            end
          end
        end
      end
    end
    object pnlSourcePreview: TPanel
      Left = 0
      Top = 343
      Width = 612
      Height = 121
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      object mwSource: TmwCustomEdit
        Left = 0
        Top = 0
        Width = 612
        Height = 121
        Cursor = crIBeam
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        Gutter.Width = 0
        HighLighter = mwPasSyn1
        Keystrokes = <
          item
            ShortCut = 38
            Command = ecUp
          end
          item
            ShortCut = 8230
            Command = ecSelUp
          end
          item
            ShortCut = 16422
            Command = ecScrollUp
          end
          item
            ShortCut = 40
            Command = ecDown
          end
          item
            ShortCut = 8232
            Command = ecSelDown
          end
          item
            ShortCut = 16424
            Command = ecScrollDown
          end
          item
            ShortCut = 37
            Command = ecLeft
          end
          item
            ShortCut = 8229
            Command = ecSelLeft
          end
          item
            ShortCut = 16421
            Command = ecWordLeft
          end
          item
            ShortCut = 24613
            Command = ecSelWordLeft
          end
          item
            ShortCut = 39
            Command = ecRight
          end
          item
            ShortCut = 8231
            Command = ecSelRight
          end
          item
            ShortCut = 16423
            Command = ecWordRight
          end
          item
            ShortCut = 24615
            Command = ecSelWordRight
          end
          item
            ShortCut = 34
            Command = ecPageDown
          end
          item
            ShortCut = 8226
            Command = ecSelPageDown
          end
          item
            ShortCut = 16418
            Command = ecPageBottom
          end
          item
            ShortCut = 24610
            Command = ecSelPageBottom
          end
          item
            ShortCut = 33
            Command = ecPageUp
          end
          item
            ShortCut = 8225
            Command = ecSelPageUp
          end
          item
            ShortCut = 16417
            Command = ecPageTop
          end
          item
            ShortCut = 24609
            Command = ecSelPageTop
          end
          item
            ShortCut = 36
            Command = ecLineStart
          end
          item
            ShortCut = 8228
            Command = ecSelLineStart
          end
          item
            ShortCut = 16420
            Command = ecEditorTop
          end
          item
            ShortCut = 24612
            Command = ecSelEditorTop
          end
          item
            ShortCut = 35
            Command = ecLineEnd
          end
          item
            ShortCut = 8227
            Command = ecSelLineEnd
          end
          item
            ShortCut = 16419
            Command = ecEditorBottom
          end
          item
            ShortCut = 24611
            Command = ecSelEditorBottom
          end
          item
            ShortCut = 45
            Command = ecToggleMode
          end
          item
            ShortCut = 16429
            Command = ecCopy
          end
          item
            ShortCut = 8237
            Command = ecPaste
          end
          item
            ShortCut = 46
            Command = ecDeleteChar
          end
          item
            ShortCut = 8238
            Command = ecCut
          end
          item
            ShortCut = 8
            Command = ecDeleteLastChar
          end
          item
            ShortCut = 16392
            Command = ecDeleteLastWord
          end
          item
            ShortCut = 32776
            Command = ecUndo
          end
          item
            ShortCut = 40968
            Command = ecRedo
          end
          item
            ShortCut = 13
            Command = ecLineBreak
          end
          item
            ShortCut = 16449
            Command = ecSelectAll
          end
          item
            ShortCut = 16451
            Command = ecCopy
          end
          item
            ShortCut = 24649
            Command = ecBlockIndent
          end
          item
            ShortCut = 16461
            Command = ecLineBreak
          end
          item
            ShortCut = 16462
            Command = ecInsertLine
          end
          item
            ShortCut = 16468
            Command = ecDeleteWord
          end
          item
            ShortCut = 24661
            Command = ecBlockUnindent
          end
          item
            ShortCut = 16470
            Command = ecPaste
          end
          item
            ShortCut = 16472
            Command = ecCut
          end
          item
            ShortCut = 16473
            Command = ecDeleteLine
          end
          item
            ShortCut = 24665
            Command = ecDeleteEOL
          end
          item
            ShortCut = 16474
            Command = ecUndo
          end
          item
            ShortCut = 24666
            Command = ecRedo
          end
          item
            ShortCut = 16432
            Command = ecGotoMarker0
          end
          item
            ShortCut = 16433
            Command = ecGotoMarker1
          end
          item
            ShortCut = 16434
            Command = ecGotoMarker2
          end
          item
            ShortCut = 16435
            Command = ecGotoMarker3
          end
          item
            ShortCut = 16436
            Command = ecGotoMarker4
          end
          item
            ShortCut = 16437
            Command = ecGotoMarker5
          end
          item
            ShortCut = 16438
            Command = ecGotoMarker6
          end
          item
            ShortCut = 16439
            Command = ecGotoMarker7
          end
          item
            ShortCut = 16440
            Command = ecGotoMarker8
          end
          item
            ShortCut = 16441
            Command = ecGotoMarker9
          end
          item
            ShortCut = 24624
            Command = ecSetMarker0
          end
          item
            ShortCut = 24625
            Command = ecSetMarker1
          end
          item
            ShortCut = 24626
            Command = ecSetMarker2
          end
          item
            ShortCut = 24627
            Command = ecSetMarker3
          end
          item
            ShortCut = 24628
            Command = ecSetMarker4
          end
          item
            ShortCut = 24629
            Command = ecSetMarker5
          end
          item
            ShortCut = 24630
            Command = ecSetMarker6
          end
          item
            ShortCut = 24631
            Command = ecSetMarker7
          end
          item
            ShortCut = 24632
            Command = ecSetMarker8
          end
          item
            ShortCut = 24633
            Command = ecSetMarker9
          end>
        LeftChar = 1
        MaxUndo = 10
        ParentColor = False
        ParentFont = False
        ReadOnly = True
        RightEdge = 0
        ScrollPastEOL = False
        TabOrder = 0
        TabIndent = 4
        TopLine = 1
        WantTabs = False
      end
    end
  end
  object pnlLayout: TPanel
    Left = 358
    Top = 24
    Width = 162
    Height = 100
    Hint = 'Layout Manager'
    BevelInner = bvRaised
    BevelOuter = bvLowered
    ParentShowHint = False
    ShowHint = True
    TabOrder = 3
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
    object Button1: TButton
      Left = 94
      Top = 80
      Width = 65
      Height = 17
      Action = actDelLayout
      TabOrder = 1
    end
    object Button2: TButton
      Left = 94
      Top = 63
      Width = 65
      Height = 17
      Action = actChangeLayout
      TabOrder = 2
    end
    object Button3: TButton
      Left = 94
      Top = 46
      Width = 65
      Height = 17
      Action = actRenameLayout
      TabOrder = 3
    end
    object Button4: TButton
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
  object OpenDialog: TOpenDialog
    Left = 167
    Top = 134
  end
  object ActionList1: TActionList
    Images = imglButtons
    Left = 77
    Top = 134
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
    object actRun: TAction
      Category = 'Project'
      Caption = 'Run'
      Enabled = False
      Hint = 'Run'
      ImageIndex = 4
      ShortCut = 120
      OnExecute = actRunExecute
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
    object actInstrumentRun: TAction
      Category = 'Project'
      Caption = 'Instrument and Run'
      Enabled = False
      Hint = 'Instrument and run'
      ImageIndex = 7
      ShortCut = 16504
      OnExecute = actInstrumentRunExecute
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
      OnExecute = actProfileOptionsExecute
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
    object actBrowsePrevious: TAction
      Category = 'Browser'
      Caption = 'Previous'
      Enabled = False
      ImageIndex = 26
      OnExecute = actBrowsePreviousExecute
      OnUpdate = actBrowsePreviousUpdate
    end
    object actBrowseNext: TAction
      Category = 'Browser'
      Caption = 'Next'
      Enabled = False
      ImageIndex = 27
      OnExecute = actBrowseNextExecute
      OnUpdate = actBrowseNextUpdate
    end
    object actOpenCallGraph: TAction
      Category = 'Profile'
      Caption = 'Open Call &Graph Analyzer'
      Enabled = False
      Hint = 'Open Call Graph Analyzer'
      ImageIndex = 28
      OnExecute = actOpenCallGraphExecute
      OnUpdate = actOpenCallGraphUpdate
    end
    object actJumpToCallGraph: TAction
      Category = 'Analysis'
      Caption = 'Jump to Call &Graph'
      Enabled = False
      Hint = 'Jump to Call Graph'
      OnExecute = actJumpToCallGraphExecute
      OnUpdate = actJumpToCallGraphUpdate
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
  end
  object imglButtons: TImageList
    Left = 47
    Top = 134
    Bitmap = {
      494C01011D001F00380010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000008000000001002000000000000080
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
      00000000000000000000000000000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF0000000000000000000000FF00000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000000000000000000000000000FF0000000000000000000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FF000000FF00000000000000FF0000000000000000000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C6000000000000000000000000000000FF00000000000000
      00000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000FF00000000000000FF000000
      00000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000FF0000000000000000000000
      FF000000FF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
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
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6
      C60000000000C6C6C600000000000000000000000000000000000000000000FF
      00000000000000FF000000FF000000FF00000000000000FF000000FF000000FF
      00000000000000FF000000000000000000000000000000000000000000000000
      000000000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF00000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF00000000000000FF000000FF00000000000000FF000000FF00000000
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484000000000084848400848484000000000084848400848484000000
      0000848484008484840000000000000000000000000000000000000000008484
      8400848484000000000084848400848484000000000084848400848484000000
      000084848400848484000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000000000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF00000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
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
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      840084848400848484000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008484
      8400848484000000000084848400848484000000000084848400848484000000
      0000848484008484840000000000000000000000000000000000000000008484
      8400848484000000000084848400848484000000000084848400848484000000
      000084848400848484000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C6C6
      C600C6C6C60000000000C6C6C600C6C6C60000000000C6C6C600C6C6C6000000
      0000C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF00000000000000FF000000FF00000000000000FF000000FF00000000
      000000FF000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C6C6
      C60000000000C6C6C600C6C6C600C6C6C60000000000C6C6C600C6C6C600C6C6
      C60000000000C6C6C600000000000000000000000000000000000000000000FF
      00000000000000FF000000FF000000FF00000000000000FF000000FF000000FF
      00000000000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000000000000000000000FF
      000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF
      000000FF000000FF00000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484008484840000000000000000000000000000000000000000008484
      8400848484008484840084848400848484008484840084848400848484008484
      840084848400848484000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
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
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840084008400840084848400000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600FFFFFF00FFFFFF00C6C6C600848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000008400840084008400FFFFFF00FFFFFF00C6C6C600848484000000
      0000000000000000000000000000000000000000000000000000FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000008400
      840084008400FFFFFF00FFFFFF000000000000000000C6C6C600C6C6C6008484
      8400000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C60084848400C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF000000000000000000848484008400840084008400FFFF
      FF00FFFFFF000000000000000000840084008400840000000000C6C6C600C6C6
      C600848484000000000000000000000000000000000000000000FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000008484840084008400FFFFFF000000
      000000000000840084008400840084008400840084008400840000000000C6C6
      C600C6C6C6008484840000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C60084848400C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000008484840000000000000000008400
      840084008400840084000084840000FFFF008400840084008400840084000000
      0000C6C6C600C6C6C60084848400000000000000000000000000FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000008484840084008400840084008400
      8400840084008400840084008400008484008400840084008400840084008400
      840000000000C6C6C60000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C60084848400C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000084008400FFFFFF008400
      84008400840084008400840084008400840000FFFF0000FFFF00840084008400
      8400840084000000000000000000000000000000000000000000FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000084008400FFFF
      FF0084008400840084008400840084008400840084000084840000FFFF0000FF
      FF00840084008400840000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      000000000000000000000000000000000000C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      8400FFFFFF00840084008400840084008400008484008400840000FFFF0000FF
      FF00840084008400840084008400000000000000000000000000FFFFFF00C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084008400FFFFFF00840084008400840000FFFF0000FFFF0000FFFF008400
      8400840084008400840000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000084008400FFFFFF00840084008400840084008400840084008400
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084008400FFFFFF008400840084008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840084008400840000000000000000000000
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
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000840000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      00008400000084000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000000000000000000000000
      00008400000084000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000084000000840000008400
      00008400000084000000840000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000084000000840000008400
      0000840000008400000084000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000084000000840000008400
      0000840000008400000084000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000084000000840000008400
      0000840000008400000084000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000008400000000000000000000000000
      0000840000008400000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000008400000000000000000000000000
      00008400000084000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000008400000000000000000000000000
      00008400000084000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000008400000000000000000000000000
      0000840000008400000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000008400000000000000000000000000
      00008400000000000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000008400000000000000000000000000
      0000840000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000008400000000000000000000000000
      0000840000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000008400000000000000000000000000
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000084848400848484008484
      8400848484008484840000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000848484008484
      8400848484000000000084848400000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840084848400000000000000
      0000000000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008484840000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484000000000000000000000000000000000000000000000000000000
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
      00008400000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00000000000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000C6C6
      C600FFFFFF00FFFFFF00C6C6C600848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00008400000084000000000000000000000000000000FFFFFF00848484008484
      84008484840084848400FFFFFF000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600000000000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C60000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      00008400000084000000840000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00000000000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C60084848400C6C6C60000000000000000000000
      0000000000000000000000000000000000008400000000000000000000000000
      00008400000084000000000000000000000000000000FFFFFF00848484008484
      84008484840084848400FFFFFF000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600000000000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C60000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C6C6C6008484840000000000000000000000
      0000000000000000000000000000000000008400000000000000000000000000
      00008400000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00000000000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF00C6C6C60084848400C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00848484008484
      84008484840084848400FFFFFF000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600000000000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00000000000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C6000000000084848400C6C6
      C600FFFFFF0084848400C6C6C60000000000000000000000000084848400C6C6
      C600FFFFFF00FFFFFF000000000000FFFF00000000000000000000FFFF000000
      00000000000000FFFF0000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C600FFFFFF0000000000C6C6C6008484
      8400FFFFFF00C6C6C60084848400000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000FFFF000000000000FFFF000000
      000000FFFF0000000000000000000000000000000000C6C6C60084848400FFFF
      FF00C6C6C6008484840000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF0000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000C6C6C6000000000084848400C6C6
      C600FFFFFF0084848400C6C6C600000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000084848400C6C6C600FFFF
      FF0084848400C6C6C60000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C60000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF0000000000C6C6C6000000
      000000000000000000008484840000000000000000000000000000000000FFFF
      0000FFFF0000FFFF00000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF00000000000000000000000000C6C6C600000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF00000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF000000000000000000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF000000FF00000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF00000000000000FFFF000000000000FFFF000000
      000000FFFF0000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00000000000000000000FFFF000000
      00000000000000FFFF0000000000000000000000000000000000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
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
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      840000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      840000848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF00000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000084840000848400008484000084840000848400008484000084
      840000848400008484000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000FF0000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000000000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF000000000084848400C6C6C600FFFFFF008484
      8400C6C6C600000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000FF
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000FF0000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF00000000000000000000FFFF000000
      00000000000000FFFF00000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF0000000000C6C6C60084848400FFFFFF00C6C6
      C60084848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF000000FF000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF000000000000FFFF000000000000FFFF000000
      000000FFFF000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF000000000000000000000000000000000084848400C6C6C600FFFFFF008484
      8400C6C6C600000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      00000000000000FF000000FF000000FF00000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C6C6C60000000000000000000000
      000084848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      00000000000000FF000000FF0000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C6000000000000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      00000000000000FF000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000FFFF0000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      000000FF000000FF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF000000000000FFFF000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFF0000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF00000000000000000000FFFF000000
      00000000000000FFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
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
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FFFF00000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      84000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C6000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      84000084840000000000000000000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000084840000848400008484000084840000848400008484000084
      84000084840000848400000000000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C6000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      00000000000000000000000000000000000000000000C6C6C600FFFFFF00C6C6
      C60000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C6000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C6000000
      00000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C6C6C600FFFFFF000000
      0000FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C6000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF000000000000FF
      000000FF0000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000000000FF
      000000FF0000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6
      C600FFFFFF00C6C6C6000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C6000000000000FF000000FF000000FF
      000000FF000000FF000000FF000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C60000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600C6C6C600C6C6C600FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF000000FF000000FF
      000000FF000000FF000000FF000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FFFF
      FF00FF000000FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
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
      2800000040000000800000000100010000000000000400000000000000000000
      000000000000000000000000FFFFFF00FFFF000000000000F9FF000000000000
      F87F000000000000F687000000000000CEE7000000000000C76F000000000000
      F96F000000000000826F00000000000000370000000000000157000000000000
      016700000000000001670000000000000167000000000000017F000000000000
      833F000000000000C73F000000000000FFFFFFFFFFFFFFFFC001C001FFFFFFFF
      C001C001FFFFFFFFC001C001FDFFFFBFC001C001F9FFFF9FC001C001F1FFFF8F
      C001C001E003C007C001C001C003C003C001C001C003C003C001C001E003C007
      C001C001F1FFFF8FC001C001F9FFFF9FC001C001FDFFFFBFC001C001FFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC001C001C001C001
      C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001
      C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001
      C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001C001
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFE3F801FE0FFF801F81F
      801FC07FF801E00F801F803F80018007801F803F80010003801F803F80010001
      801F803F80010000801F803F80010001801F803F80018001801F803F8001C001
      801F803F801FE000801F803F801FF000801F803F801FF803801FC07F801FFC0F
      FFFFE0FFFFFFFE3FFFFFFFFFFFFFFFFFFF83FF83FF83F783F701F701F783F301
      F301F301F383810181018101818373017301730173837701770177017701FF01
      FF01FF01FF01FF01838383838301838301C77DC701C783C701FF7DFF01FF83FF
      01FF7DFF01FF83FF01FF45FF01FF83FF01FF39FF01FF01FF01FF7DFF01FF01FF
      83FFBBFF83FF01FFC7FFC7FFC7FFC7FFFFFFFFFFFFFFFF0000010001E0FFF700
      00010001C07FF30000010001803F810000010001803F730000010001803F7700
      00010001803FFF0000010001801B8300000100008001010000000000800301FF
      00000000800301FF00000000800101FF00000000800301FF00000000C00301FF
      00000001E00183FFFF00FFE3FEDBC7FFFFFFFFFFFFFFFFFFF7FF003F001FC00F
      F3FF003F000FC00FF1FF003F0007C00FF0FF003F0003C00FF07F003F0001C00F
      F03F003F0000C00FF01F001B0003C007F01F00010003C003F03F00030003C001
      F07F00038E03C000F0FF0001FE03C000F1FF0003FE03C001F3FF0003FF07C003
      F7FFFC01FF8FFFC7FFFFFEDBFFFFFFCFFFFFFFFFFFFFFFFF001F0001C00FC00F
      000F0001C00FC00F00070001C00FC00F00030001C00FC00F00010001C00FC00F
      00000001C00FC00F001F0001C00FC00F00000001C007C00F00000001C003C00F
      8F000001C001C00FFF000001C000C001FF000001C000C000FF000001C001C000
      FF000001FFC3FF81FFFFFFFFFFE7FFFF00000000000000000000000000000000
      000000000000}
  end
  object popRecent: TPopupMenu
    Left = 197
    Top = 134
  end
  object MRU: TGPMRUFiles
    Menu = Reopen1
    PopupMenu = popRecent
    MaxFiles = 9
    StandAloneMenu = True
    DeleteEntry = False
    OnClick = MRUClick
    Left = 107
    Top = 134
  end
  object MainMenu1: TMainMenu
    Images = imglButtons
    Left = 137
    Top = 134
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
    object Project1: TMenuItem
      Caption = '&Project'
      object Open2: TMenuItem
        Action = actOpen
      end
      object Reopen1: TMenuItem
        Caption = 'R&eopen'
        Enabled = False
      end
      object Rescan1: TMenuItem
        Action = actRescanProject
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object InstrumentandRun1: TMenuItem
        Action = actInstrumentRun
      end
      object Instrument1: TMenuItem
        Action = actInstrument
      end
      object RemoveInstrumentation1: TMenuItem
        Action = actRemoveInstrumentation
      end
      object Run1: TMenuItem
        Action = actRun
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Options1: TMenuItem
        Action = actProjectOptions
      end
    end
    object Profile1: TMenuItem
      Caption = 'P&rofile'
      object OpenProfilingData1: TMenuItem
        Action = actOpenProfile
      end
      object ReopenProfilingData1: TMenuItem
        Caption = 'R&eopen'
      end
      object Rescan2: TMenuItem
        Action = actRescanProfile
      end
      object N2: TMenuItem
        Caption = '-'
      end
      object RenameMove1: TMenuItem
        Action = actRenameMoveProfile
      end
      object SaveAs1: TMenuItem
        Action = actMakeCopyProfile
      end
      object Delete1: TMenuItem
        Action = actDelUndelProfile
      end
      object Export1: TMenuItem
        Action = actExportProfile
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object ProfileOptions1: TMenuItem
        Action = actProfileOptions
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
      object Shortcutkeys1: TMenuItem
        Action = actHelpShortcutKeys
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
    Left = 197
    Top = 164
  end
  object popRecentPrf: TPopupMenu
    Left = 197
    Top = 194
  end
  object MRUPrf: TGPMRUFiles
    Menu = ReopenProfilingData1
    PopupMenu = popRecentPrf
    MaxFiles = 9
    StandAloneMenu = True
    DeleteEntry = False
    OnClick = MRUPrfClick
    Left = 107
    Top = 164
  end
  object popAnalysisListview: TPopupMenu
    Left = 197
    Top = 224
    object mnuHideNotExecuted: TMenuItem
      Action = actHideNotExecuted
    end
    object mnuExportProfile: TMenuItem
      Caption = 'E&xport...'
      Enabled = False
      Hint = 'Export profile'
      ImageIndex = 11
      OnClick = mnuExportProfileClick
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = 'Profiling results|*.prf|Any file|*.*'
    Left = 167
    Top = 164
  end
  object popLayout: TPopupMenu
    Left = 197
    Top = 254
  end
  object imglListViews: TImageList
    Left = 47
    Top = 164
    Bitmap = {
      494C010103000500380010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
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
  object mwPasSyn1: TmwPasSyn
    DefaultFilter = 'Pascal files (*.pas,*.inc)|*.PAS;*.INC'
    AsmAttri.Background = clWindow
    AsmAttri.Foreground = clWindowText
    AsmAttri.Style = []
    AsmAttri.IntegerStyle = 0
    CommentAttri.Background = clWindow
    CommentAttri.Foreground = clWindowText
    CommentAttri.Style = [fsItalic]
    CommentAttri.IntegerStyle = 2
    IdentifierAttri.Background = clWindow
    IdentifierAttri.Foreground = clWindowText
    IdentifierAttri.Style = []
    IdentifierAttri.IntegerStyle = 0
    KeyAttri.Background = clWindow
    KeyAttri.Foreground = clWindowText
    KeyAttri.Style = [fsBold]
    KeyAttri.IntegerStyle = 1
    NumberAttri.Background = clWindow
    NumberAttri.Foreground = clWindowText
    NumberAttri.Style = []
    NumberAttri.IntegerStyle = 0
    SpaceAttri.Background = clWindow
    SpaceAttri.Foreground = clWindowText
    SpaceAttri.Style = []
    SpaceAttri.IntegerStyle = 0
    StringAttri.Background = clWindow
    StringAttri.Foreground = clWindowText
    StringAttri.Style = []
    StringAttri.IntegerStyle = 0
    SymbolAttri.Background = clWindow
    SymbolAttri.Foreground = clWindowText
    SymbolAttri.Style = []
    SymbolAttri.IntegerStyle = 0
    Left = 235
    Top = 134
  end
  object popBrowsePrevious: TPopupMenu
    Left = 197
    Top = 285
  end
  object popBrowseNext: TPopupMenu
    Left = 197
    Top = 314
  end
  object OpenDialog1: TOpenDialog
    Filter = #1060#1072#1081#1083#1099' '#1087#1088#1086#1092#1080#1083#1103' (*.prf)|*.prf'
    Options = [ofHideReadOnly, ofNoChangeDir, ofFileMustExist, ofEnableSizing]
    Left = 168
    Top = 208
  end
end
