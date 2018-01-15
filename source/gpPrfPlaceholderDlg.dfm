object frmPreferenceMacros: TfrmPreferenceMacros
  Left = 374
  Top = 176
  BorderStyle = bsDialog
  Caption = 'GpProfile - Macros'
  ClientHeight = 110
  ClientWidth = 483
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = True
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 69
    Width = 483
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object oxButton1: TButton
      Left = 312
      Top = 8
      Width = 77
      Height = 27
      Caption = 'OK'
      Default = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
    object oxButton2: TButton
      Left = 400
      Top = 8
      Width = 77
      Height = 27
      Caption = 'Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 477
    Height = 63
    Align = alClient
    AutoSize = True
    BevelOuter = bvNone
    TabOrder = 1
    object lbAvailableMacros: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 5
      Width = 471
      Height = 13
      Margins.Top = 5
      Align = alTop
      Caption = 'Please select the macro to be added....'
    end
    object cbAvailableMacros: TComboBox
      AlignWithMargins = True
      Left = 3
      Top = 21
      Width = 471
      Height = 21
      Align = alClient
      TabOrder = 0
    end
  end
end
