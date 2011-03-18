object frmLoadProgress: TfrmLoadProgress
  Left = 324
  Top = 187
  AutoSize = True
  BorderIcons = [biHelp]
  BorderStyle = bsNone
  Caption = 'frmLoadProgress'
  ClientHeight = 49
  ClientWidth = 441
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  OnKeyPress = FormKeyPress
  PixelsPerInch = 96
  TextHeight = 13
  object pnlLoadResults: TPanel
    Left = 0
    Top = 0
    Width = 441
    Height = 49
    BevelInner = bvLowered
    BevelWidth = 2
    Caption = 'pnlLoadResults'
    TabOrder = 0
    object ProgressBar1: TProgressBar
      Left = 16
      Top = 15
      Width = 337
      Height = 20
      TabOrder = 0
    end
    object btnCancelLoad: TButton
      Left = 368
      Top = 15
      Width = 57
      Height = 20
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelLoadClick
    end
  end
end
