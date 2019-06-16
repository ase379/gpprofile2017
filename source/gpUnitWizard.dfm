object fmUnitWizard: TfmUnitWizard
  Left = 374
  Top = 176
  Caption = 'GpProfile - Unit Selection Wizard'
  ClientHeight = 358
  ClientWidth = 473
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = True
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  object lblUnitDependencies: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 467
    Height = 13
    Align = alTop
    Caption = 'Please select the dependent units to be instrumented:'
    ExplicitWidth = 260
  end
  object pnlBottom: TPanel
    Left = 0
    Top = 325
    Width = 473
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object oxButton1: TButton
      AlignWithMargins = True
      Left = 304
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
    end
    object oxButton2: TButton
      AlignWithMargins = True
      Left = 391
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
    end
  end
  object vstUnitDependencies: TVirtualStringTree
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 467
    Height = 300
    Align = alClient
    Header.AutoSizeIndex = 0
    Header.MainColumn = -1
    TabOrder = 1
    TreeOptions.AutoOptions = [toAutoDropExpand, toAutoExpand, toAutoScrollOnExpand, toAutoSort, toAutoTristateTracking, toAutoDeleteMovedNodes, toAutoChangeScale]
    Columns = <>
  end
end
