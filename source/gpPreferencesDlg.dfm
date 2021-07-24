object frmPreferences: TfrmPreferences
  Left = 374
  Top = 176
  BorderStyle = bsDialog
  Caption = 'GpProfile - Preferences'
  ClientHeight = 390
  ClientWidth = 483
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poDefault
  OnCreate = FormCreate
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 361
    Width = 483
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 366
    object oxButton1: TButton
      AlignWithMargins = True
      Left = 320
      Top = 3
      Width = 77
      Height = 23
      Align = alRight
      Caption = 'OK'
      Constraints.MaxHeight = 25
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitHeight = 25
    end
    object oxButton2: TButton
      AlignWithMargins = True
      Left = 403
      Top = 3
      Width = 77
      Height = 23
      Align = alRight
      Caption = 'Cancel'
      Constraints.MaxHeight = 25
      ModalResult = 2
      TabOrder = 1
      ExplicitHeight = 25
    end
  end
  object PagePreferences: TPageControl
    Left = 0
    Top = 0
    Width = 483
    Height = 361
    ActivePage = tabDefines
    Align = alClient
    HotTrack = True
    TabOrder = 1
    ExplicitHeight = 327
    object tabInstrumentation: TTabSheet
      Caption = 'Instrumentation'
      ImageIndex = -1
      object GroupBox1: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 469
        Height = 78
        Align = alTop
        Caption = ' Settings '
        TabOrder = 0
        object pnlMarkerStyle: TPanel
          Left = 2
          Top = 15
          Width = 465
          Height = 27
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitLeft = 1
          ExplicitTop = 12
          object Label1: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 6
            Width = 143
            Height = 18
            Margins.Left = 8
            Margins.Top = 6
            Align = alLeft
            Caption = 'Template for instrumentation:'
            FocusControl = cbxMarker
            ExplicitLeft = 3
            ExplicitTop = 3
            ExplicitHeight = 13
          end
          object cbxMarker: TComboBox
            AlignWithMargins = True
            Left = 168
            Top = 3
            Width = 281
            Height = 21
            Margins.Right = 16
            Align = alRight
            Style = csDropDownList
            TabOrder = 0
            Items.Strings = (
              '{>>GpProfile}'
              '{$IFDEF GpProfile}')
            ExplicitLeft = 184
            ExplicitTop = 0
          end
        end
        object pnlCompilerVersion: TPanel
          Left = 2
          Top = 42
          Width = 465
          Height = 27
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 1
          object Label2: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 6
            Width = 83
            Height = 18
            Margins.Left = 8
            Margins.Top = 6
            Align = alLeft
            Caption = '&Compiler version:'
            FocusControl = cbxCompilerVersion
            ExplicitLeft = 3
            ExplicitHeight = 17
          end
          object cbxCompilerVersion: TComboBox
            AlignWithMargins = True
            Left = 168
            Top = 3
            Width = 281
            Height = 21
            Margins.Right = 16
            Align = alRight
            Style = csDropDownList
            TabOrder = 0
            OnChange = cbxCompilerVersionChange
            ExplicitLeft = 184
            ExplicitTop = 0
          end
        end
      end
      object GroupBox4: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 198
        Width = 469
        Height = 98
        Hint = 'Detects changed units by using the timestamp of the unit file.'
        Align = alTop
        Caption = 'Options '
        TabOrder = 1
        ExplicitTop = 201
        object cbProfilingAutostart: TCheckBox
          Left = 8
          Top = 44
          Width = 257
          Height = 17
          Hint = 'Start profiling upon init of the target module.'
          Caption = 'Start &profiling on target startup'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object cbShowAllFolders: TCheckBox
          Left = 8
          Top = 21
          Width = 257
          Height = 17
          Hint = 'Show all units. If disabled: show only units of the dpr/dpk.'
          Caption = 'Show &all folders'
          TabOrder = 0
        end
        object cbInstrumentAssembler: TCheckBox
          Left = 8
          Top = 68
          Width = 257
          Height = 17
          Hint = 'Instrument pure asm functions.'
          Caption = '&Instrument pure assembler procedures'
          TabOrder = 2
        end
        object cbMakeBackupOfInstrumentedFile: TCheckBox
          Left = 234
          Top = 20
          Width = 220
          Height = 17
          Caption = 'Backup Instrumented Files'
          TabOrder = 3
        end
      end
      object GroupBox3: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 87
        Width = 469
        Height = 105
        Align = alTop
        Caption = 'PRF (Profiling Result File) Settings'
        TabOrder = 2
        ExplicitTop = 90
        object Label3: TLabel
          AlignWithMargins = True
          Left = 10
          Top = 18
          Width = 454
          Height = 13
          Margins.Left = 8
          Align = alTop
          Caption = 
            'Choose the compression level here to get a faster target executi' +
            'on or a smaller prf.'
          ExplicitLeft = 5
          ExplicitWidth = 402
        end
        object Panel3: TPanel
          Left = 2
          Top = 34
          Width = 465
          Height = 69
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitLeft = 5
          ExplicitTop = 37
          ExplicitWidth = 459
          ExplicitHeight = 63
          object Label4: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 3
            Width = 57
            Height = 63
            Margins.Left = 8
            Align = alLeft
            Caption = '&Speed/Size:'
            FocusControl = tbSpeedSize
            ExplicitLeft = 5
            ExplicitTop = 0
            ExplicitHeight = 57
          end
          object tbSpeedSize: TTrackBar
            Left = 68
            Top = 0
            Width = 25
            Height = 69
            Align = alLeft
            Max = 3
            Min = 1
            Orientation = trVertical
            PageSize = 1
            Position = 1
            TabOrder = 0
            ThumbLength = 15
            ExplicitLeft = 57
            ExplicitHeight = 63
          end
          object pnSpeedSizeLabels: TPanel
            Left = 93
            Top = 0
            Width = 372
            Height = 69
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            ExplicitLeft = 82
            ExplicitWidth = 377
            ExplicitHeight = 63
            object lblFasterTarget: TLabel
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 366
              Height = 13
              Align = alTop
              Caption = 'faster target'
              OnClick = lblFasterTargetClick
              OnDblClick = lblFasterTargetClick
              ExplicitWidth = 62
            end
            object lblSmallerFile: TLabel
              AlignWithMargins = True
              Left = 3
              Top = 53
              Width = 366
              Height = 13
              Align = alBottom
              Caption = 'smaller profiling file'
              OnClick = lblSmallerFileClick
              OnDblClick = lblSmallerFileClick
              ExplicitTop = 47
              ExplicitWidth = 91
            end
          end
        end
      end
      object btnInstrumentationDefaults: TButton
        AlignWithMargins = True
        Left = 397
        Top = 302
        Width = 75
        Height = 25
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 25
        TabOrder = 3
        OnClick = btnInstrumentationDefaultsClick
        ExplicitLeft = 362
      end
    end
    object tabAnalysis: TTabSheet
      Caption = 'Analysis'
      ImageIndex = -1
      object grpAnalysisSettings: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 79
        Width = 469
        Height = 49
        Align = alTop
        Caption = ' Options '
        TabOrder = 0
        object cbHideNotExecuted: TCheckBox
          Left = 8
          Top = 20
          Width = 241
          Height = 17
          Caption = ' &Hide procedures that were never executed'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
      end
      object btnAnalysisDefaults: TButton
        Left = 400
        Top = 131
        Width = 75
        Height = 25
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 25
        TabOrder = 1
        OnClick = btnAnalysisDefaultsClick
        ExplicitLeft = 399
        ExplicitTop = 134
      end
      object GroupBox7: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 469
        Height = 70
        Align = alTop
        Caption = ' Settings '
        TabOrder = 2
        object Label6: TLabel
          AlignWithMargins = True
          Left = 10
          Top = 23
          Width = 449
          Height = 13
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alTop
          Caption = 'Performance output file name: (without extension)'
          ExplicitWidth = 243
        end
        object Panel2: TPanel
          AlignWithMargins = True
          Left = 10
          Top = 39
          Width = 449
          Height = 21
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alBottom
          BevelOuter = bvNone
          Caption = 'Panel2'
          TabOrder = 0
          ExplicitLeft = 8
          object edtPerformanceOutputFilename: TEdit
            AlignWithMargins = True
            Left = 0
            Top = 0
            Width = 415
            Height = 21
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 8
            Margins.Bottom = 0
            Align = alClient
            TabOrder = 0
          end
          object btnPrfPlaceholderSelection: TButton
            Left = 423
            Top = 0
            Width = 26
            Height = 21
            Align = alRight
            Caption = '...'
            TabOrder = 1
            OnClick = btnPrfPlaceholderSelectionClick
          end
        end
      end
    end
    object tabExcluded: TTabSheet
      Caption = 'Excluded units'
      ImageIndex = -1
      object GroupBox2: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 469
        Height = 233
        Align = alTop
        Caption = ' Units '
        TabOrder = 0
        ExplicitLeft = 8
        ExplicitTop = 8
        ExplicitWidth = 457
        object memoExclUnits: TMemo
          AlignWithMargins = True
          Left = 10
          Top = 23
          Width = 311
          Height = 200
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alLeft
          ScrollBars = ssVertical
          TabOrder = 0
        end
        object pnlUnitCommands: TPanel
          AlignWithMargins = True
          Left = 329
          Top = 23
          Width = 130
          Height = 200
          Margins.Left = 0
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = 230
          ExplicitWidth = 228
          ExplicitHeight = 216
          object btnAddFromFolder: TButton
            Left = 0
            Top = 166
            Width = 125
            Height = 17
            Align = alBottom
            Caption = '&Add from folder'
            Constraints.MaxHeight = 25
            Constraints.MaxWidth = 125
            TabOrder = 0
            OnClick = btnAddFromFolderClick
            ExplicitTop = 182
            ExplicitWidth = 75
          end
          object btnClear: TButton
            Left = 0
            Top = 183
            Width = 125
            Height = 17
            Align = alBottom
            Caption = 'C&lear all'
            Constraints.MaxHeight = 25
            Constraints.MaxWidth = 125
            TabOrder = 1
            OnClick = btnClearClick
            ExplicitTop = 199
          end
        end
      end
      object btnUnitsDefaults: TButton
        AlignWithMargins = True
        Left = 397
        Top = 242
        Width = 75
        Height = 25
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 25
        TabOrder = 1
        OnClick = btnExcludedUnitsDefaultsClick
        ExplicitLeft = 392
        ExplicitTop = 259
      end
    end
    object tabDefines: TTabSheet
      Caption = 'Conditional defines'
      ImageIndex = 3
      object GroupBox5: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 469
        Height = 294
        Align = alTop
        Caption = ' Symbols '
        TabOrder = 0
        object pnlSymbolCommands: TPanel
          Left = 264
          Top = 15
          Width = 203
          Height = 277
          Margins.Bottom = 8
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 0
          ExplicitTop = 12
          object btnAddDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 172
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actAddDefine
            Align = alBottom
            TabOrder = 0
            ExplicitLeft = 151
            ExplicitTop = 135
            ExplicitWidth = 65
          end
          object btnClearAllDefines: TButton
            AlignWithMargins = True
            Left = 3
            Top = 252
            Width = 197
            Height = 17
            Margins.Bottom = 8
            Action = actClearAllDefines
            Align = alBottom
            TabOrder = 1
            ExplicitLeft = 151
            ExplicitTop = 199
            ExplicitWidth = 65
          end
          object btnClearUserDefines: TButton
            AlignWithMargins = True
            Left = 3
            Top = 232
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actClearAllDefines
            Align = alBottom
            Caption = 'Clear u&ser'
            TabOrder = 2
            ExplicitLeft = 151
            ExplicitTop = 186
            ExplicitWidth = 65
          end
          object btnDeleteDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 212
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actDeleteDefine
            Align = alBottom
            TabOrder = 3
            ExplicitLeft = 151
            ExplicitTop = 169
            ExplicitWidth = 65
          end
          object btnRenameDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 192
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actRenameDefine
            Align = alBottom
            TabOrder = 4
            ExplicitLeft = 151
            ExplicitTop = 152
            ExplicitWidth = 65
          end
          object cbConsoleDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 50
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add c&onsole application defines'
            TabOrder = 5
            OnClick = cbConsoleDefinesClick
            ExplicitLeft = 95
            ExplicitTop = 63
            ExplicitWidth = 121
          end
          object cbDisableUserDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 90
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Disable &user defines'
            TabOrder = 6
            OnClick = cbDisableUserDefinesClick
            ExplicitLeft = 95
            ExplicitTop = 95
            ExplicitWidth = 121
          end
          object cbProjectDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 70
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add &project defines'
            TabOrder = 7
            OnClick = cbProjectDefinesClick
            ExplicitLeft = 95
            ExplicitTop = 79
            ExplicitWidth = 121
          end
          object cbStandardDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 30
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add selected &compiler defines'
            TabOrder = 8
            OnClick = cbStandardDefinesClick
            ExplicitLeft = 111
            ExplicitTop = 47
            ExplicitWidth = 105
          end
          object cbxDelphiDefines: TComboBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 197
            Height = 21
            Align = alTop
            Style = csDropDownList
            TabOrder = 9
            OnChange = cbxDelphiDefinesChange
            ExplicitLeft = 90
            ExplicitTop = 20
            ExplicitWidth = 146
          end
        end
        object pnlSymbolsDefine: TPanel
          AlignWithMargins = True
          Left = 5
          Top = 15
          Width = 256
          Height = 277
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitLeft = -1
          ExplicitTop = 11
          ExplicitWidth = 262
          ExplicitHeight = 216
          object inpDefine: TEdit
            AlignWithMargins = True
            Left = 3
            Top = 248
            Width = 250
            Height = 21
            Margins.Bottom = 8
            Align = alBottom
            TabOrder = 0
            ExplicitLeft = -24
            ExplicitTop = 100
            ExplicitWidth = 209
          end
          object lvDefines: TListView
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 250
            Height = 239
            Align = alClient
            Columns = <
              item
                Caption = 'Define'
                Width = 192
              end>
            HideSelection = False
            ReadOnly = True
            RowSelect = True
            ShowColumnHeaders = False
            SmallImages = imgDefines
            SortType = stText
            TabOrder = 1
            ViewStyle = vsReport
            OnClick = lvDefinesClick
            ExplicitLeft = 0
            ExplicitTop = -3
            ExplicitWidth = 256
            ExplicitHeight = 183
          end
        end
      end
      object btnDefinesDefaults: TButton
        AlignWithMargins = True
        Left = 397
        Top = 303
        Width = 75
        Height = 25
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 25
        Constraints.MaxWidth = 75
        TabOrder = 1
        OnClick = btnDefinesDefaultsClick
        ExplicitLeft = 399
        ExplicitTop = 242
      end
    end
  end
  object imgDefines: TImageList
    Left = 228
    Top = 272
    Bitmap = {
      494C010106000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000848484000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000848484000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000848484000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000848484000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF0000000000FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      0000848484000000000084848400000000008484840000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF0000000000FFFFFF0000000000FFFFFF0000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FF
      FF0000FFFF0000FFFF0000FFFF00000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C6000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C60000000000FFFFFF00FFFFFF00C6C6C6008484840084848400C6C6
      C600C6C6C6008484840084848400000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF0000000000FFFFFF00FFFFFF00C6C6C600C6C6C60084848400FFFF
      FF00C6C6C600C6C6C60084848400000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C60000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF000000000084848400848484008484840084848400848484008484
      8400848484008484840084848400000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000FFFF0000000000000000000000
      00000000000000FFFF0000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C60000000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400848484008484
      8400FFFFFF00FFFFFF000000000000000000000000000000000000FFFF0000FF
      FF0000FFFF00000000000000000000FFFF0000FFFF0000FFFF00000000000000
      000000FFFF0000FFFF0000FFFF00000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000C6C6C600FFFFFF00C6C6
      C600FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00C6C6C600FFFF
      FF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600FFFF
      FF00C6C6C6000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF0000FFFF000084840000848400008484000084840000848400008484000084
      840000FFFF0000FFFF0000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000FFFF0000000000000000000000000000FFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00848484008484840084848400848484008484840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
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
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF00D555800100000000AAAB800100000000
      D555800100000000AAAB800100000000D555800100000000AAAB800100000000
      D555800100000000AAAB800100000000D555800100000000AAAB800100000000
      D555800100000000AABB801900000000D557801300000000AAAF800700000000
      D55F800F00000000FFFFFFFF0000000080008000FFFF80018000800000038001
      C631800000038001C631800000008001C631800000008001C631800000008001
      C631800000008001C631800000008001C6318000000080018000800000008001
      8000800000038001C001800000038019F007800000038013FC1F800000038007
      FE3F8000FFFF800FFFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object ActionList1: TActionList
    Left = 124
    Top = 288
    object actAddDefine: TAction
      Category = 'Defines'
      Caption = '&Add'
      Hint = 'Add conditional symbol'
      OnExecute = actAddDefineExecute
      OnUpdate = actAddDefineUpdate
    end
    object actRenameDefine: TAction
      Category = 'Defines'
      Caption = '&Rename'
      Hint = 'Rename conditional symbol'
      OnExecute = actRenameDefineExecute
      OnUpdate = actRenameDefineUpdate
    end
    object actDeleteDefine: TAction
      Category = 'Defines'
      Caption = '&Delete'
      Hint = 'Delete conditional symbol'
      OnExecute = actDeleteDefineExecute
      OnUpdate = actDeleteDefineUpdate
    end
    object actClearAllDefines: TAction
      Category = 'Defines'
      Caption = 'C&lear all'
      Hint = 'Clear all conditional symbols'
      OnExecute = actClearAllDefinesExecute
      OnUpdate = actClearAllDefinesUpdate
    end
  end
end
