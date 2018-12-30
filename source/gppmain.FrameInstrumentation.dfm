object frmMainInstrumentation: TfrmMainInstrumentation
  Left = 0
  Top = 0
  Width = 991
  Height = 589
  TabOrder = 0
  object Splitter1: TSplitter
    Left = 129
    Top = 25
    Height = 564
    ExplicitTop = -172
    ExplicitHeight = 412
  end
  object Splitter2: TSplitter
    Left = 269
    Top = 25
    Height = 564
    ExplicitTop = -172
    ExplicitHeight = 412
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 991
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = -781
    ExplicitWidth = 1101
    object chkShowAll: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 99
      Height = 19
      Align = alLeft
      Caption = '&Show all folders'
      TabOrder = 0
    end
    object btnLoadInstrumentationSelection: TButton
      AlignWithMargins = True
      Left = 108
      Top = 3
      Width = 99
      Height = 19
      Align = alLeft
      Caption = 'Load Selection...'
      TabOrder = 1
    end
    object btnSaveInstrumentationSelection: TButton
      AlignWithMargins = True
      Left = 213
      Top = 3
      Width = 99
      Height = 19
      Align = alLeft
      Caption = 'Save Selection...'
      TabOrder = 2
    end
  end
  object pnlUnits: TPanel
    Left = 0
    Top = 25
    Width = 129
    Height = 564
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = -172
    ExplicitHeight = 412
    object lblUnits: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 123
      Height = 17
      Align = alTop
      Caption = '&Units:'
      TabOrder = 0
      ExplicitWidth = 39
    end
    object vstSelectUnits: TVirtualStringTree
      Left = 0
      Top = 23
      Width = 129
      Height = 541
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.Height = 20
      Header.MainColumn = -1
      Header.MinHeight = 20
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      OnAddToSelection = vstSelectUnitsAddToSelection
      OnChecked = vstSelectUnitsChecked
      ExplicitHeight = 389
      Columns = <>
    end
  end
  object pnlClasses: TPanel
    Left = 132
    Top = 25
    Width = 137
    Height = 564
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 2
    ExplicitTop = -172
    ExplicitHeight = 412
    object lblClasses: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 131
      Height = 17
      Align = alTop
      Caption = '&Classes:'
      TabOrder = 0
      ExplicitWidth = 51
    end
    object vstSelectClasses: TVirtualStringTree
      Left = 0
      Top = 23
      Width = 137
      Height = 541
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.Height = 20
      Header.MainColumn = -1
      Header.MinHeight = 20
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      OnAddToSelection = vstSelectClassesAddToSelection
      OnChecked = vstSelectClassesChecked
      ExplicitHeight = 389
      Columns = <>
    end
  end
  object pnlProcs: TPanel
    Left = 272
    Top = 25
    Width = 719
    Height = 564
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    ExplicitLeft = -509
    ExplicitTop = -172
    ExplicitWidth = 829
    ExplicitHeight = 412
    object lblProcs: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 713
      Height = 17
      Align = alTop
      Caption = 'P&rocedures:'
      TabOrder = 0
      ExplicitWidth = 69
    end
    object vstSelectProcs: TVirtualStringTree
      Left = 0
      Top = 23
      Width = 719
      Height = 541
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.Height = 20
      Header.MainColumn = -1
      Header.MinHeight = 20
      TabOrder = 1
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      OnAddToSelection = vstSelectProcsAddToSelection
      OnChecked = vstSelectProcsChecked
      ExplicitWidth = 829
      ExplicitHeight = 389
      Columns = <>
    end
  end
end
