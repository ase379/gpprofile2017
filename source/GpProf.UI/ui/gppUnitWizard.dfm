object fmUnitWizard: TfmUnitWizard
  Left = 374
  Top = 176
  Caption = 'GpProfile - Unit Selection Wizard'
  ClientHeight = 718
  ClientWidth = 577
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  Position = poDefault
  TextHeight = 17
  object pnlBottom: TPanel
    Left = 0
    Top = 685
    Width = 577
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitTop = 682
    ExplicitWidth = 573
    object oxButton1: TButton
      AlignWithMargins = True
      Left = 408
      Top = 3
      Width = 77
      Height = 25
      Margins.Left = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Caption = 'OK'
      Default = True
      ModalResult = 1
      TabOrder = 0
      ExplicitLeft = 404
    end
    object oxButton2: TButton
      AlignWithMargins = True
      Left = 495
      Top = 5
      Width = 77
      Height = 23
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      ExplicitLeft = 491
    end
  end
  object vstUnitDependencies: TVirtualStringTree
    AlignWithMargins = True
    Left = 3
    Top = 52
    Width = 571
    Height = 630
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.MainColumn = -1
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    OnAddToSelection = vstUnitDependenciesAddToSelection
    OnExpanding = vstUnitDependenciesExpanding
    OnRemoveFromSelection = vstUnitDependenciesRemoveFromSelection
    Touch.InteractiveGestures = [igPan, igPressAndTap]
    Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
    Columns = <>
  end
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 577
    Height = 49
    Align = alTop
    TabOrder = 2
    ExplicitWidth = 573
    object lblLevelsApplied: TLabel
      AlignWithMargins = True
      Left = 405
      Top = 13
      Width = 84
      Height = 23
      Margins.Top = 12
      Margins.Right = 12
      Margins.Bottom = 12
      Align = alLeft
      Alignment = taCenter
      Caption = 'Levels Applied'
      Layout = tlCenter
      ExplicitHeight = 17
    end
    object btnDeselectLevels: TButton
      AlignWithMargins = True
      Left = 177
      Top = 9
      Width = 152
      Height = 31
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      Caption = 'Deselection With Children'
      TabOrder = 0
      OnClick = btnDeselectLevelsClick
    end
    object numberLevelsApplied: TNumberBox
      AlignWithMargins = True
      Left = 340
      Top = 13
      Width = 50
      Height = 23
      Margins.Top = 12
      Margins.Right = 12
      Margins.Bottom = 12
      Align = alLeft
      CurrencyFormat = nbcfPrefixSpace
      MinValue = 1.000000000000000000
      MaxValue = 100.000000000000000000
      TabOrder = 1
      Value = 1.000000000000000000
      ExplicitHeight = 25
    end
    object btnSelectLevels: TButton
      AlignWithMargins = True
      Left = 9
      Top = 9
      Width = 152
      Height = 31
      Margins.Left = 8
      Margins.Top = 8
      Margins.Right = 8
      Margins.Bottom = 8
      Align = alLeft
      Caption = 'Selection With Children'
      TabOrder = 2
      OnClick = btnSelectLevelsClick
    end
  end
end
