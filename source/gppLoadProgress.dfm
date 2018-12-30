object frmLoadProgress: TfrmLoadProgress
  Left = 324
  Top = 187
  BorderIcons = [biHelp]
  BorderStyle = bsNone
  Caption = 'frmLoadProgress'
  ClientHeight = 62
  ClientWidth = 438
  Color = clBtnFace
  ParentFont = True
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object pnlLoadResults: TPanel
    Left = 0
    Top = 0
    Width = 438
    Height = 59
    Align = alTop
    BevelInner = bvLowered
    BevelWidth = 2
    TabOrder = 0
    object Label1: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 7
      Width = 424
      Height = 21
      Align = alTop
      AutoSize = False
      Caption = 'Label1'
      Layout = tlCenter
    end
    object ProgressBar1: TProgressBar
      AlignWithMargins = True
      Left = 7
      Top = 34
      Width = 361
      Height = 18
      Align = alClient
      TabOrder = 0
    end
    object btnCancelLoad: TButton
      AlignWithMargins = True
      Left = 374
      Top = 34
      Width = 57
      Height = 18
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelLoadClick
    end
  end
end
