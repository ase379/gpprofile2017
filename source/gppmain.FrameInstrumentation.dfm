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
  end
  object Splitter2: TSplitter
    Left = 269
    Top = 25
    Height = 564
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 991
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
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
  end
  object pnlUnits: TPanel
    Left = 0
    Top = 25
    Width = 129
    Height = 564
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object lblUnits: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 123
      Height = 17
      Align = alTop
      Caption = '&Units:'
      TabOrder = 0
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
      PopupMenu = PopupMenu1
      TabOrder = 1
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      OnAddToSelection = vstSelectUnitsAddToSelection
      OnChecked = vstSelectUnitsChecked
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
    object lblClasses: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 131
      Height = 17
      Align = alTop
      Caption = '&Classes:'
      TabOrder = 0
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
    object lblProcs: TStaticText
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 713
      Height = 17
      Align = alTop
      Caption = 'P&rocedures:'
      TabOrder = 0
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
      Columns = <>
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 392
    Top = 313
    object mnuUnitWizard: TMenuItem
      Caption = 'Unit Selection Wizard...'
      OnClick = mnuUnitWizardClick
    end
  end
end
