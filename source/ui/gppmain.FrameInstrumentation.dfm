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
  object splitter2: TSplitter
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
    object chkShowDirStructure: TCheckBox
      AlignWithMargins = True
      Left = 108
      Top = 3
      Width = 155
      Height = 19
      Align = alLeft
      Caption = 'Show Directory Structure'
      TabOrder = 0
      OnClick = chkShowDirStructureClick
    end
    object chkShowAll: TCheckBox
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 99
      Height = 19
      Align = alLeft
      Caption = '&Show all folders'
      TabOrder = 1
    end
    object btnUnitSelectionWizard: TButton
      Left = 266
      Top = 0
      Width = 151
      Height = 25
      Align = alLeft
      Caption = 'Unit Selection Wizard...'
      Enabled = False
      TabOrder = 2
      OnClick = btnUnitSelectionWizardClick
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
      Height = 19
      Align = alTop
      Caption = '&Units:'
      TabOrder = 0
    end
    object vstSelectUnits: TVirtualStringTree
      Left = 0
      Top = 48
      Width = 129
      Height = 516
      Align = alClient
      Header.AutoSizeIndex = -1
      Header.Height = 20
      Header.MainColumn = -1
      Header.MinHeight = 20
      TabOrder = 1
      TreeOptions.AutoOptions = [toAutoDropExpand, toAutoExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
      TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
      TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
      OnAddToSelection = vstSelectUnitsAddToSelection
      OnChecked = vstSelectUnitsChecked
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <>
    end
    object sbUnits: TSearchBox
      Left = 0
      Top = 25
      Width = 129
      Height = 23
      Align = alTop
      TabOrder = 2
      TextHint = 'Filter units...'
      OnInvokeSearch = sbUnitsInvokeSearch
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
      Height = 19
      Align = alTop
      Caption = '&Classes:'
      TabOrder = 0
    end
    object vstSelectClasses: TVirtualStringTree
      Left = 0
      Top = 48
      Width = 137
      Height = 516
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
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <>
    end
    object sbClasses: TSearchBox
      Left = 0
      Top = 25
      Width = 137
      Height = 23
      Align = alTop
      TabOrder = 2
      TextHint = 'Filter classes...'
      OnInvokeSearch = sbClassesInvokeSearch
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
      Height = 19
      Align = alTop
      Caption = 'P&rocedures:'
      TabOrder = 0
    end
    object vstSelectProcs: TVirtualStringTree
      Left = 0
      Top = 48
      Width = 719
      Height = 516
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
      Touch.InteractiveGestures = [igPan, igPressAndTap]
      Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
      Columns = <>
    end
    object sbProcedures: TSearchBox
      Left = 0
      Top = 25
      Width = 719
      Height = 23
      Align = alTop
      TabOrder = 2
      TextHint = 'Filter procedures...'
      OnInvokeSearch = sbProceduresInvokeSearch
    end
  end
end
