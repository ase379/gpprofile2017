object frmMainProfiling: TfrmMainProfiling
  Left = 0
  Top = 0
  Width = 897
  Height = 694
  TabOrder = 0
  object PageControl2: TPageControl
    Left = 0
    Top = 0
    Width = 897
    Height = 694
    ActivePage = tabProcedures
    Align = alClient
    HotTrack = True
    PopupMenu = popAnalysisListview
    TabOrder = 0
    OnChange = PageControl2Change
    ExplicitLeft = 3
    ExplicitTop = 3
    object tabProcedures: TTabSheet
      Caption = 'Procedures'
      ImageIndex = -1
      object splitCallees: TSplitter
        Left = 0
        Top = 511
        Width = 889
        Height = 3
        Cursor = crVSplit
        Align = alBottom
        AutoSnap = False
        Color = clBtnFace
        ParentColor = False
        Visible = False
        ExplicitTop = 250
      end
      object pnThreadProcs: TPanel
        Left = 0
        Top = 0
        Width = 889
        Height = 31
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        DesignSize = (
          889
          31)
        object lblSelectThreadProc: TLabel
          Left = 0
          Top = 10
          Width = 71
          Height = 15
          Caption = '&Select thread:'
          FocusControl = cbxSelectThreadProc
        end
        object pnlBrowser: TPanel
          Left = 789
          Top = 4
          Width = 95
          Height = 26
          Anchors = [akTop, akRight]
          BevelOuter = bvNone
          TabOrder = 0
          object ToolBar3: TToolBar
            Left = -1
            Top = 0
            Width = 96
            Height = 26
            Align = alRight
            AutoSize = True
            Caption = 'ToolBar3'
            EdgeInner = esNone
            EdgeOuter = esNone
            Images = imglButtons
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            object ToolButton18: TToolButton
              Left = 0
              Top = 0
              Action = actBrowsePrevious
              DropdownMenu = popBrowsePrevious
              ParentShowHint = False
              ShowHint = True
              Style = tbsDropDown
            end
            object ToolButton19: TToolButton
              Left = 48
              Top = 0
              Action = actBrowseNext
              DropdownMenu = popBrowseNext
              ParentShowHint = False
              ShowHint = True
              Style = tbsDropDown
            end
          end
        end
        object cbxSelectThreadProc: TComboBox
          Left = 72
          Top = 6
          Width = 191
          Height = 23
          Style = csDropDownList
          TabOrder = 1
          OnChange = cbxSelectThreadProcChange
        end
      end
      object pnlTopTwo: TPanel
        Left = 0
        Top = 31
        Width = 889
        Height = 480
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 2
        ExplicitHeight = 536
        object splitCallers: TSplitter
          Left = 0
          Top = 150
          Width = 889
          Height = 3
          Cursor = crVSplit
          Align = alTop
          AutoSnap = False
          Color = clBtnFace
          ParentColor = False
          Visible = False
          OnMoved = splitCallersMoved
        end
        object pnlCallers: TPanel
          Left = 0
          Top = 0
          Width = 889
          Height = 150
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          Visible = False
          object vstCallers: TVirtualStringTree
            Left = 0
            Top = 23
            Width = 889
            Height = 127
            Align = alClient
            Header.AutoSizeIndex = 0
            Header.Height = 20
            Header.MinHeight = 20
            Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
            PopupMenu = popAnalysisListview
            TabOrder = 0
            TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
            OnChange = vstCallersChange
            OnNodeDblClick = vstCalleesNodeDblClick
            Touch.InteractiveGestures = [igPan, igPressAndTap]
            Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
            ExplicitHeight = 150
            Columns = <
              item
                MinWidth = 200
                Position = 0
                Text = 'Procedure (Callers)'
                Width = 200
              end
              item
                MinWidth = 75
                Position = 1
                Text = '% Time'
                Width = 75
              end
              item
                MinWidth = 100
                Position = 2
                Text = '% Time w/Child'
                Width = 100
              end
              item
                MinWidth = 75
                Position = 3
                Text = 'Time'
                Width = 75
              end
              item
                MinWidth = 75
                Position = 4
                Text = 'Time w/Child'
                Width = 75
              end
              item
                MinWidth = 75
                Position = 5
                Text = 'Calls'
                Width = 75
              end
              item
                MinWidth = 75
                Position = 6
                Text = 'Min/Call'
                Width = 75
              end
              item
                MinWidth = 75
                Position = 7
                Text = 'Max/Call'
                Width = 75
              end
              item
                MinWidth = 75
                Position = 8
                Text = 'Avg/Call'
                Width = 75
              end>
          end
          object sbFilterCallers: TSearchBox
            Left = 0
            Top = 0
            Width = 889
            Height = 23
            Align = alTop
            TabOrder = 1
            TextHint = 'Filter the procedure callers...'
            OnChange = sbFilterCallersChange
          end
        end
        object pnlCurrent: TPanel
          Left = 0
          Top = 153
          Width = 889
          Height = 327
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
          ExplicitTop = 85
          ExplicitHeight = 451
          object vstProcs: TVirtualStringTree
            Left = 0
            Top = 23
            Width = 889
            Height = 304
            Align = alClient
            Header.AutoSizeIndex = 0
            Header.Height = 20
            Header.MinHeight = 20
            Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
            PopupMenu = popAnalysisListview
            TabOrder = 0
            TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
            OnChange = vstProcsChange
            Touch.InteractiveGestures = [igPan, igPressAndTap]
            Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
            ExplicitTop = 20
            ExplicitHeight = 428
            Columns = <
              item
                MinWidth = 50
                Position = 0
                Text = 'Procedure'
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 1
                Text = '% Time'
                Width = 75
              end
              item
                MinWidth = 100
                Position = 2
                Text = '% Time w/Child'
                Width = 100
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 3
                Text = 'Time'
                Width = 75
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 4
                Text = 'Time w/Child'
                Width = 75
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 5
                Text = 'Calls'
                Width = 75
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 6
                Text = 'Min/Call'
                Width = 75
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 7
                Text = 'Max/Call'
                Width = 75
              end
              item
                MinWidth = 75
                Options = [coAllowClick, coDraggable, coEnabled, coParentBidiMode, coParentColor, coResizable, coShowDropMark, coVisible, coSmartResize, coAllowFocus, coEditable]
                Position = 8
                Text = 'Avg/Call'
                Width = 75
              end>
          end
          object sbFilterProcs: TSearchBox
            Left = 0
            Top = 0
            Width = 889
            Height = 23
            Align = alTop
            TabOrder = 1
            TextHint = 'Filter the procedure...'
            OnInvokeSearch = sbFilterProcsInvokeSearch
          end
        end
      end
      object pnlCallees: TPanel
        Left = 0
        Top = 514
        Width = 889
        Height = 150
        Align = alBottom
        BevelOuter = bvNone
        TabOrder = 1
        Visible = False
        object vstCallees: TVirtualStringTree
          Left = 0
          Top = 23
          Width = 889
          Height = 127
          Align = alClient
          Header.AutoSizeIndex = 0
          Header.Height = 20
          Header.MinHeight = 20
          Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
          PopupMenu = popAnalysisListview
          TabOrder = 0
          TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
          OnChange = vstCalleesChange
          OnNodeDblClick = vstCalleesNodeDblClick
          Touch.InteractiveGestures = [igPan, igPressAndTap]
          Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
          ExplicitHeight = 68
          Columns = <
            item
              MinWidth = 200
              Position = 0
              Text = 'Procedure (Callees)'
              Width = 200
            end
            item
              MinWidth = 75
              Position = 1
              Text = '% Time'
              Width = 75
            end
            item
              MinWidth = 100
              Position = 2
              Text = '% Time w/Child'
              Width = 100
            end
            item
              MinWidth = 75
              Position = 3
              Text = 'Time'
              Width = 75
            end
            item
              MinWidth = 75
              Position = 4
              Text = 'Time w/Child'
              Width = 75
            end
            item
              MinWidth = 75
              Position = 5
              Text = 'Calls'
              Width = 75
            end
            item
              MinWidth = 75
              Position = 6
              Text = 'Min/Call'
              Width = 75
            end
            item
              MinWidth = 75
              Position = 7
              Text = 'Max/Call'
              Width = 75
            end
            item
              MinWidth = 75
              Position = 8
              Text = 'Avg/Call'
              Width = 75
            end>
        end
        object sbFilterCallees: TSearchBox
          Left = 0
          Top = 0
          Width = 889
          Height = 23
          Align = alTop
          TabOrder = 1
          TextHint = 'Filter the procedure callees...'
          OnInvokeSearch = sbFilterCalleesInvokeSearch
        end
      end
    end
    object tabClasses: TTabSheet
      Caption = 'Classes'
      ImageIndex = -1
      object vstClasses: TVirtualStringTree
        Left = 0
        Top = 56
        Width = 889
        Height = 608
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Height = 20
        Header.MinHeight = 20
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        PopupMenu = popAnalysisListview
        TabOrder = 0
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            MinWidth = 200
            Position = 0
            Text = 'Class'
            Width = 200
          end
          item
            MinWidth = 150
            Position = 1
            Text = '% Time'
            Width = 150
          end
          item
            MinWidth = 150
            Position = 2
            Text = 'Time'
            Width = 150
          end
          item
            MinWidth = 150
            Position = 3
            Text = 'Calls'
            Width = 150
          end>
      end
      object pnThreadClass: TPanel
        Left = 0
        Top = 0
        Width = 889
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label1: TLabel
          Left = 0
          Top = 10
          Width = 71
          Height = 15
          Caption = '&Select thread:'
          FocusControl = cbxSelectThreadClass
        end
        object cbxSelectThreadClass: TComboBox
          Left = 72
          Top = 6
          Width = 199
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbxSelectThreadClassChange
        end
      end
      object sbFilterClasses: TSearchBox
        Left = 0
        Top = 33
        Width = 889
        Height = 23
        Align = alTop
        TabOrder = 2
        TextHint = 'Filter the classes...'
        OnInvokeSearch = sbFilterClassesInvokeSearch
      end
    end
    object tabUnits: TTabSheet
      Caption = 'Units'
      ImageIndex = -1
      object pnThreadUnits: TPanel
        Left = 0
        Top = 0
        Width = 889
        Height = 33
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object Label2: TLabel
          Left = 8
          Top = 10
          Width = 71
          Height = 15
          Caption = '&Select thread:'
          FocusControl = cbxSelectThreadUnit
        end
        object cbxSelectThreadUnit: TComboBox
          Left = 80
          Top = 6
          Width = 199
          Height = 23
          Style = csDropDownList
          TabOrder = 0
          OnChange = cbxSelectThreadUnitChange
        end
      end
      object vstUnits: TVirtualStringTree
        Left = 0
        Top = 56
        Width = 889
        Height = 608
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Height = 20
        Header.MinHeight = 20
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        PopupMenu = popAnalysisListview
        TabOrder = 1
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            MinWidth = 200
            Position = 0
            Text = 'Unit'
            Width = 200
          end
          item
            MinWidth = 150
            Position = 1
            Text = '% Time'
            Width = 150
          end
          item
            MinWidth = 150
            Position = 2
            Text = 'Time'
            Width = 150
          end
          item
            MinWidth = 150
            Position = 3
            Text = 'Calls'
            Width = 150
          end>
      end
      object sbFilterUnits: TSearchBox
        Left = 0
        Top = 33
        Width = 889
        Height = 23
        Align = alTop
        TabOrder = 2
        TextHint = 'Filter the units...'
        OnInvokeSearch = sbFilterUnitsInvokeSearch
      end
    end
    object tabThreads: TTabSheet
      Caption = 'Threads'
      ImageIndex = -1
      object vstThreads: TVirtualStringTree
        Left = 0
        Top = 23
        Width = 889
        Height = 641
        Align = alClient
        Header.AutoSizeIndex = 0
        Header.Height = 20
        Header.MinHeight = 20
        Header.Options = [hoColumnResize, hoDrag, hoShowSortGlyphs, hoVisible]
        PopupMenu = popAnalysisListview
        TabOrder = 0
        TreeOptions.PaintOptions = [toShowButtons, toShowDropmark, toThemeAware, toUseBlendedImages]
        Touch.InteractiveGestures = [igPan, igPressAndTap]
        Touch.InteractiveGestureOptions = [igoPanSingleFingerHorizontal, igoPanSingleFingerVertical, igoPanInertia, igoPanGutter, igoParentPassthrough]
        Columns = <
          item
            MinWidth = 90
            Position = 0
            Text = 'ThreadID'
            Width = 90
          end
          item
            MinWidth = 275
            Position = 1
            Text = 'Thread'
            Width = 275
          end
          item
            MinWidth = 75
            Position = 2
            Text = '% Time'
            Width = 75
          end
          item
            MinWidth = 75
            Position = 3
            Text = 'Time'
            Width = 75
          end
          item
            MinWidth = 75
            Position = 4
            Text = 'Calls'
            Width = 75
          end>
      end
      object sbFilterThreads: TSearchBox
        Left = 0
        Top = 0
        Width = 889
        Height = 23
        Align = alTop
        TabOrder = 1
        TextHint = 'Filter the threads...'
        OnInvokeSearch = sbFilterThreadsInvokeSearch
      end
    end
  end
  object popBrowseNext: TPopupMenu
    Left = 197
    Top = 314
  end
  object popBrowsePrevious: TPopupMenu
    Left = 213
    Top = 357
  end
  object ActionList1: TActionList
    Images = imglButtons
    Left = 77
    Top = 134
    object actBrowsePrevious: TAction
      Category = 'Browser'
      Caption = 'Previous'
      Enabled = False
      ImageIndex = 0
      OnExecute = actBrowsePreviousExecute
      OnUpdate = actBrowsePreviousUpdate
    end
    object actBrowseNext: TAction
      Category = 'Browser'
      Caption = 'Next'
      Enabled = False
      ImageIndex = 1
      OnExecute = actBrowseNextExecute
      OnUpdate = actBrowseNextUpdate
    end
  end
  object imglButtons: TImageList
    Left = 47
    Top = 134
    Bitmap = {
      494C010102002100040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF0000000000000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF
      0000FFFF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFF0000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF0000FFFF
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFF00000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFFFFF00000000
      FFFFFFFF00000000FDFFFFBF00000000F9FFFF9F00000000F1FFFF8F00000000
      E003C00700000000C003C00300000000C003C00300000000E003C00700000000
      F1FFFF8F00000000F9FFFF9F00000000FDFFFFBF00000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
  object popAnalysisListview: TPopupMenu
    Left = 197
    Top = 224
    object mnuHideNotExecuted: TMenuItem
    end
    object mnuExportProfile: TMenuItem
      Caption = 'E&xport...'
      Enabled = False
      Hint = 'Export profile'
      ImageIndex = 11
    end
  end
end
