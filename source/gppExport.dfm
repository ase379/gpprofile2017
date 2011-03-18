object frmExport: TfrmExport
  Left = 392
  Top = 250
  ActiveControl = inpWhere
  BorderStyle = bsDialog
  Caption = 'GpProfile - Export'
  ClientHeight = 217
  ClientWidth = 292
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
  object grpWhat: TGroupBox
    Left = 8
    Top = 8
    Width = 113
    Height = 97
    Caption = ' What '
    TabOrder = 0
    object cbProcedures: TCheckBox
      Left = 8
      Top = 16
      Width = 97
      Height = 17
      Caption = 'Procedures'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object cbClasses: TCheckBox
      Left = 8
      Top = 32
      Width = 97
      Height = 17
      Caption = 'Classes'
      Checked = True
      State = cbChecked
      TabOrder = 1
    end
    object cbUnits: TCheckBox
      Left = 8
      Top = 48
      Width = 97
      Height = 17
      Caption = 'Units'
      Checked = True
      State = cbChecked
      TabOrder = 2
    end
    object cbThreads: TCheckBox
      Left = 8
      Top = 64
      Width = 65
      Height = 17
      Caption = 'Threads'
      Checked = True
      State = cbChecked
      TabOrder = 3
      OnClick = cbThreadsClick
    end
    object expSelectThreadProc: TComboBox
      Left = 72
      Top = 62
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 4
      Visible = False
    end
  end
  object grpWhere: TGroupBox
    Left = 8
    Top = 112
    Width = 273
    Height = 57
    Caption = ' Where '
    TabOrder = 2
    object inpWhere: TEdit
      Left = 8
      Top = 24
      Width = 233
      Height = 21
      TabOrder = 0
    end
    object btnBrowse: TButton
      Left = 240
      Top = 24
      Width = 21
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = btnBrowseClick
    end
  end
  object grpHow: TGroupBox
    Left = 128
    Top = 8
    Width = 153
    Height = 97
    Caption = ' How '
    TabOrder = 1
    object rbCSV: TRadioButton
      Left = 8
      Top = 16
      Width = 137
      Height = 17
      Caption = 'CSV (comma delimited)'
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rbCSVClick
    end
    object rbTXT: TRadioButton
      Left = 8
      Top = 32
      Width = 121
      Height = 17
      Caption = 'TXT (tab delimited)'
      TabOrder = 1
      OnClick = rbCSVClick
    end
  end
  object btnExport: TButton
    Left = 128
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Export'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 208
    Top = 184
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object SaveDialog1: TSaveDialog
    Filter = 'CSV - comma delimited (*.csv)|*.csv|Any file|*.*'
    Title = 'Export to'
    Left = 8
    Top = 184
  end
end
