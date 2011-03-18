object frmComCtl: TfrmComCtl
  Left = 401
  Top = 293
  Caption = 'GpProfile'
  ClientHeight = 320
  ClientWidth = 549
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 517
    Height = 57
    AutoSize = False
    Caption = 
      'COMCTL32.DLL library installed on your computer is too old. GpPr' +
      'ofile will continue to work but you may experience some problems' +
      ' with images not displaying correctly.'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label2: TLabel
    Left = 16
    Top = 88
    Width = 517
    Height = 17
    AutoSize = False
    Caption = 'You should get newer COMCTL32.DLL from'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label3: TLabel
    Left = 16
    Top = 216
    Width = 517
    Height = 41
    AutoSize = False
    Caption = 
      'This information will not be displayed again. This information i' +
      's also displayed in the help file under topic "Known problems".'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Label4: TLabel
    Left = 16
    Top = 144
    Width = 517
    Height = 57
    AutoSize = False
    Caption = 
      'For your convenience this address was copied to the clipboard so' +
      ' you can paste it into the browser. You can also open it by clic' +
      'king the address above.'
    Font.Charset = EASTEUROPE_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = 'Arial'
    Font.Style = [fsBold]
    ParentFont = False
    WordWrap = True
  end
  object Edit1: TEdit
    Left = 416
    Top = 80
    Width = 121
    Height = 21
    TabOrder = 0
    Text = 'http://www.microsoft.com/msdownload/ieplatform/ie/comctrlx86.asp'
    Visible = False
  end
  object Button1: TButton
    Left = 237
    Top = 280
    Width = 75
    Height = 25
    Caption = 'Close'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
