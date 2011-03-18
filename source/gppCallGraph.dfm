object frmCallGraph: TfrmCallGraph
  Left = 311
  Top = 196
  Caption = 'GpProfile Call Graph Analyzer'
  ClientHeight = 516
  ClientWidth = 734
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lblInfo: TLabel
    Left = 208
    Top = 224
    Width = 378
    Height = 29
    Caption = 'This unit is under construction....'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -24
    Font.Name = 'MS Sans Serif'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 734
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object pnlGraph: TPanel
      Left = 0
      Top = 0
      Width = 35
      Height = 26
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object tbrGraph: TToolBar
        Left = 0
        Top = 0
        Width = 27
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'tbrGraph'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Caption = 'ToolButton1'
          ImageIndex = 0
        end
      end
    end
    object pnlItem: TPanel
      Left = 35
      Top = 0
      Width = 35
      Height = 26
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 1
      object tbrItem: TToolBar
        Left = 0
        Top = 0
        Width = 27
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'tbrGraph'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton2: TToolButton
          Left = 0
          Top = 0
          Caption = 'ToolButton1'
          ImageIndex = 0
        end
      end
    end
    object tbrHelp: TPanel
      Left = 70
      Top = 0
      Width = 664
      Height = 26
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 27
        Height = 26
        Align = alLeft
        AutoSize = True
        Caption = 'tbrGraph'
        EdgeBorders = [ebLeft, ebTop, ebRight, ebBottom]
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton3: TToolButton
          Left = 0
          Top = 0
          Caption = 'ToolButton1'
          ImageIndex = 0
        end
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 26
    Width = 734
    Height = 31
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    DesignSize = (
      734
      31)
    object lblSelectThreadProc: TLabel
      Left = 6
      Top = 8
      Width = 66
      Height = 13
      Caption = '&Select thread:'
      FocusControl = cbxSelectThreadCG
    end
    object cbxSelectThreadCG: TComboBox
      Left = 78
      Top = 4
      Width = 145
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbxSelectThreadCGChange
    end
    object pnlBrowser: TPanel
      Left = 622
      Top = 4
      Width = 115
      Height = 26
      Anchors = [akTop, akRight]
      BevelOuter = bvNone
      TabOrder = 1
      object ToolBar3: TToolBar
        Left = 43
        Top = 0
        Width = 72
        Height = 26
        Align = alRight
        AutoSize = True
        Caption = 'ToolBar3'
        EdgeInner = esNone
        EdgeOuter = esNone
        Images = frmMain.imglButtons
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton18: TToolButton
          Left = 0
          Top = 0
          Caption = 'ToolButton18'
          Enabled = False
          ImageIndex = 26
          ParentShowHint = False
          ShowHint = True
          Style = tbsDropDown
        end
        object ToolButton19: TToolButton
          Left = 36
          Top = 0
          Caption = 'ToolButton19'
          Enabled = False
          ImageIndex = 27
          ParentShowHint = False
          ShowHint = True
          Style = tbsDropDown
        end
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 492
    Width = 734
    Height = 24
    Panels = <
      item
        Width = 650
      end>
  end
  object MainMenu1: TMainMenu
    Left = 232
    Top = 32
    object CallGraph1: TMenuItem
      Caption = '&Analyzer'
      object Close1: TMenuItem
        Caption = 'Close'
        ShortCut = 16471
        OnClick = Close1Click
      end
    end
    object Graph1: TMenuItem
      Caption = '&Graph'
      object Zoomingetc1: TMenuItem
        Caption = 'Zooming etc'
        Enabled = False
      end
    end
    object Item1: TMenuItem
      Caption = '&Item'
      object Expandcollapsemovewhatever1: TMenuItem
        Caption = 'Expand, collapse, whatever'
        Enabled = False
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object Jumpto1: TMenuItem
        Caption = 'Jump to &View'
        OnClick = Jumpto1Click
      end
    end
    object Help1: TMenuItem
      Caption = '&Help'
      Enabled = False
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 264
    Top = 32
    object JumptoView1: TMenuItem
      Caption = 'Jump to &View'
      OnClick = Jumpto1Click
    end
  end
end
