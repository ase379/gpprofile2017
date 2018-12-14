object frmLoadProgress: TfrmLoadProgress
  Left = 324
  Top = 187
  BorderIcons = [biHelp]
  BorderStyle = bsNone
  Caption = 'frmLoadProgress'
  ClientHeight = 38
  ClientWidth = 446
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
    Height = 35
    BevelInner = bvLowered
    BevelWidth = 2
    Caption = 'pnlLoadResults'
    TabOrder = 0
    object ProgressBar1: TProgressBar
      AlignWithMargins = True
      Left = 7
      Top = 7
      Width = 364
      Height = 21
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 16
      ExplicitTop = 15
      ExplicitWidth = 337
      ExplicitHeight = 20
    end
    object btnCancelLoad: TButton
      AlignWithMargins = True
      Left = 377
      Top = 7
      Width = 57
      Height = 21
      Align = alRight
      Caption = 'Cancel'
      TabOrder = 1
      OnClick = btnCancelLoadClick
    end
  end
end
