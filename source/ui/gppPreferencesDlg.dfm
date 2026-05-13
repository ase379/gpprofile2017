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
  TextHeight = 15
  object Panel1: TPanel
    Left = 0
    Top = 361
    Width = 483
    Height = 29
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
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
    end
  end
  object PagePreferences: TPageControl
    Left = 0
    Top = 0
    Width = 483
    Height = 361
    ActivePage = tabInstrumentation
    Align = alClient
    HotTrack = True
    TabOrder = 1
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
          Top = 17
          Width = 465
          Height = 29
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 0
          object Label1: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 6
            Width = 157
            Height = 20
            Margins.Left = 8
            Margins.Top = 6
            Align = alLeft
            Caption = 'Template for instrumentation:'
            FocusControl = cbxMarker
          end
          object cbxMarker: TComboBox
            AlignWithMargins = True
            Left = 168
            Top = 3
            Width = 281
            Height = 23
            Margins.Right = 16
            Align = alRight
            Style = csDropDownList
            TabOrder = 0
            Items.Strings = (
              '{>>GpProfile}'
              '{$IFDEF GpProfile}')
          end
        end
        object pnlCompilerVersion: TPanel
          Left = 2
          Top = 46
          Width = 465
          Height = 29
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          TabOrder = 1
          object Label2: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 6
            Width = 93
            Height = 20
            Margins.Left = 8
            Margins.Top = 6
            Align = alLeft
            Caption = '&Compiler version:'
            FocusControl = cbxCompilerVersion
          end
          object cbxCompilerVersion: TComboBox
            AlignWithMargins = True
            Left = 168
            Top = 3
            Width = 281
            Height = 23
            Margins.Right = 16
            Align = alRight
            Style = csDropDownList
            TabOrder = 0
            OnChange = cbxCompilerVersionChange
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
        object cbProfilingAutostart: TCheckBox
          Left = 8
          Top = 44
          Width = 257
          Height = 17
          Hint = 'Start profiling upon init of the target module.'
          Caption = 'Start &profiling on target startup'
          Checked = True
          State = cbChecked
          TabOrder = 2
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
          TabOrder = 4
        end
        object cbMakeBackupOfInstrumentedFile: TCheckBox
          Left = 231
          Top = 44
          Width = 220
          Height = 17
          Caption = 'Backup Instrumented Files'
          TabOrder = 3
        end
        object cbShowDirStructure: TCheckBox
          Left = 231
          Top = 21
          Width = 220
          Height = 17
          Caption = 'Show Directory Structure'
          TabOrder = 1
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
        object Label3: TLabel
          AlignWithMargins = True
          Left = 10
          Top = 20
          Width = 454
          Height = 15
          Margins.Left = 8
          Align = alTop
          Caption = 
            'Choose the compression level here to get a faster target executi' +
            'on or a smaller prf.'
        end
        object Panel3: TPanel
          Left = 2
          Top = 38
          Width = 465
          Height = 65
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 0
          object Label4: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 3
            Width = 60
            Height = 59
            Margins.Left = 8
            Align = alLeft
            Caption = '&Speed/Size:'
            FocusControl = tbSpeedSize
          end
          object tbSpeedSize: TTrackBar
            Left = 71
            Top = 0
            Width = 25
            Height = 65
            Align = alLeft
            Max = 4
            Min = 1
            Orientation = trVertical
            PageSize = 1
            Position = 1
            TabOrder = 0
            ThumbLength = 15
          end
          object pnSpeedSizeLabels: TPanel
            Left = 96
            Top = 0
            Width = 369
            Height = 65
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 1
            object lblFasterTarget: TLabel
              AlignWithMargins = True
              Left = 3
              Top = 3
              Width = 363
              Height = 15
              Align = alTop
              Caption = 'faster target'
              OnClick = lblFasterTargetClick
              OnDblClick = lblFasterTargetClick
            end
            object lblSmallerFile: TLabel
              AlignWithMargins = True
              Left = 3
              Top = 47
              Width = 363
              Height = 15
              Align = alBottom
              Caption = 'smaller profiling file'
              OnClick = lblSmallerFileClick
              OnDblClick = lblSmallerFileClick
            end
            object lblPrfBufSizeKB: TLabel
              Left = 152
              Top = 38
              Width = 93
              Height = 15
              Align = alCustom
              Anchors = [akTop, akRight]
              Caption = 'Write Bufffer Size:'
            end
            object cbMemWorkingSetEnabled: TCheckBox
              Left = 152
              Top = 3
              Width = 177
              Height = 17
              Align = alCustom
              Anchors = [akTop, akRight]
              Caption = 'Analyse Memory Working Set'
              Checked = True
              State = cbChecked
              TabOrder = 0
            end
            object cbbPrfBufSizeKB: TComboBox
              Left = 251
              Top = 35
              Width = 102
              Height = 23
              Align = alCustom
              Anchors = [akTop, akRight]
              CharCase = ecUpperCase
              ItemIndex = 0
              TabOrder = 1
              Text = '64 KB'
              Items.Strings = (
                '64 KB'
                '256 KB'
                '512 KB'
                '1 MB'
                '10 MB'
                '100 MB'
                '256 MB'
                '512 MB')
            end
          end
        end
      end
      object btnInstrumentationDefaults: TButton
        AlignWithMargins = True
        Left = 395
        Top = 302
        Width = 77
        Height = 23
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 23
        Constraints.MaxWidth = 77
        Constraints.MinHeight = 17
        Constraints.MinWidth = 77
        TabOrder = 3
        OnClick = btnInstrumentationDefaultsClick
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
        Height = 50
        Align = alTop
        Caption = ' Options '
        TabOrder = 0
        object cbHideNotExecuted: TCheckBox
          Left = 10
          Top = 20
          Width = 241
          Height = 17
          Caption = ' &Hide procedures that were never executed'
          Checked = True
          State = cbChecked
          TabOrder = 0
        end
      end
      object GroupBox7: TGroupBox
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 469
        Height = 70
        Align = alTop
        Caption = ' Settings '
        TabOrder = 1
        object Label6: TLabel
          AlignWithMargins = True
          Left = 10
          Top = 25
          Width = 449
          Height = 15
          Margins.Left = 8
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alTop
          Caption = 'Performance output file name: (without extension)'
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
      object btnAnalysisDefaults: TButton
        AlignWithMargins = True
        Left = 395
        Top = 135
        Width = 77
        Height = 23
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 23
        Constraints.MaxWidth = 77
        Constraints.MinHeight = 17
        Constraints.MinWidth = 77
        TabOrder = 2
        OnClick = btnAnalysisDefaultsClick
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
        object memoExclUnits: TMemo
          AlignWithMargins = True
          Left = 10
          Top = 25
          Width = 311
          Height = 198
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
          Top = 25
          Width = 130
          Height = 198
          Margins.Left = 0
          Margins.Top = 8
          Margins.Right = 8
          Margins.Bottom = 8
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object btnAddFromFolder: TButton
            Left = 0
            Top = 164
            Width = 130
            Height = 17
            Align = alBottom
            Caption = '&Add from folder'
            Constraints.MaxHeight = 25
            Constraints.MaxWidth = 130
            TabOrder = 0
            OnClick = btnAddFromFolderClick
          end
          object btnClear: TButton
            Left = 0
            Top = 181
            Width = 130
            Height = 17
            Align = alBottom
            Caption = 'C&lear all'
            Constraints.MaxHeight = 25
            Constraints.MaxWidth = 130
            TabOrder = 1
            OnClick = btnClearClick
          end
        end
      end
      object btnUnitsDefaults: TButton
        AlignWithMargins = True
        Left = 395
        Top = 242
        Width = 77
        Height = 23
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 23
        Constraints.MaxWidth = 77
        Constraints.MinHeight = 17
        Constraints.MinWidth = 77
        TabOrder = 1
        OnClick = btnExcludedUnitsDefaultsClick
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
          Top = 17
          Width = 203
          Height = 275
          Margins.Bottom = 8
          Align = alRight
          BevelOuter = bvNone
          TabOrder = 0
          object btnAddDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 170
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actAddDefine
            Align = alBottom
            TabOrder = 0
          end
          object btnClearAllDefines: TButton
            AlignWithMargins = True
            Left = 3
            Top = 250
            Width = 197
            Height = 17
            Margins.Bottom = 8
            Action = actClearAllDefines
            Align = alBottom
            TabOrder = 1
          end
          object btnClearUserDefines: TButton
            AlignWithMargins = True
            Left = 3
            Top = 230
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actClearAllDefines
            Align = alBottom
            Caption = 'Clear u&ser'
            TabOrder = 2
          end
          object btnDeleteDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 210
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actDeleteDefine
            Align = alBottom
            TabOrder = 3
          end
          object btnRenameDefine: TButton
            AlignWithMargins = True
            Left = 3
            Top = 190
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Action = actRenameDefine
            Align = alBottom
            TabOrder = 4
          end
          object cbConsoleDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 52
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add c&onsole application defines'
            TabOrder = 5
            OnClick = cbConsoleDefinesClick
          end
          object cbDisableUserDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 92
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Disable &user defines'
            TabOrder = 6
            OnClick = cbDisableUserDefinesClick
          end
          object cbProjectDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 72
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add &project defines'
            TabOrder = 7
            OnClick = cbProjectDefinesClick
          end
          object cbStandardDefines: TCheckBox
            AlignWithMargins = True
            Left = 3
            Top = 32
            Width = 197
            Height = 17
            Margins.Bottom = 0
            Align = alTop
            Caption = 'Add selected &compiler defines'
            TabOrder = 8
            OnClick = cbStandardDefinesClick
          end
          object cbxDelphiDefines: TComboBox
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 197
            Height = 23
            Align = alTop
            Style = csDropDownList
            TabOrder = 9
            OnChange = cbxDelphiDefinesChange
          end
        end
        object pnlSymbolsDefine: TPanel
          AlignWithMargins = True
          Left = 5
          Top = 17
          Width = 256
          Height = 275
          Margins.Top = 0
          Margins.Bottom = 0
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          object inpDefine: TEdit
            AlignWithMargins = True
            Left = 3
            Top = 244
            Width = 250
            Height = 23
            Margins.Bottom = 8
            Align = alBottom
            TabOrder = 0
          end
          object lvDefines: TListView
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 250
            Height = 235
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
          end
        end
      end
      object btnDefinesDefaults: TButton
        AlignWithMargins = True
        Left = 395
        Top = 303
        Width = 77
        Height = 23
        Align = alRight
        Caption = 'D&efaults'
        Constraints.MaxHeight = 23
        Constraints.MaxWidth = 77
        Constraints.MinHeight = 17
        Constraints.MinWidth = 77
        TabOrder = 1
        OnClick = btnDefinesDefaultsClick
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
