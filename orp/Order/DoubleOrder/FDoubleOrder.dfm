object DoubleOrderForm: TDoubleOrderForm
  Left = 227
  Top = 162
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = '+'
  ClientHeight = 633
  ClientWidth = 888
  Color = clBtnFace
  Constraints.MaxWidth = 904
  Constraints.MinHeight = 565
  Constraints.MinWidth = 896
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object PanelLeft: TPanel
    Left = 0
    Top = 0
    Width = 154
    Height = 633
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object PanelDerivative: TPanel
      Left = 0
      Top = 273
      Width = 154
      Height = 360
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 154
        Height = 360
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object PanelSymbols: TPanel
          Left = 0
          Top = 0
          Width = 154
          Height = 73
          Align = alTop
          BevelInner = bvLowered
          TabOrder = 0
          object Panel3: TPanel
            Left = 2
            Top = 27
            Width = 150
            Height = 44
            Align = alClient
            BevelInner = bvRaised
            BevelOuter = bvLowered
            TabOrder = 0
            object LabelFut: TLabel
              Left = 6
              Top = 6
              Width = 38
              Height = 13
              Caption = #49440#47932' : '
            end
            object Label9: TLabel
              Left = 6
              Top = 27
              Width = 34
              Height = 13
              Caption = #50741#49496' :'
            end
            object ComboFutures: TComboBox
              Left = 42
              Top = 3
              Width = 52
              Height = 19
              Style = csOwnerDrawFixed
              ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
              ItemHeight = 13
              TabOrder = 0
              OnChange = ComboFuturesChange
            end
            object EditFutures: TStaticText
              Left = 96
              Top = 3
              Width = 45
              Height = 19
              Alignment = taRightJustify
              AutoSize = False
              BorderStyle = sbsSingle
              Color = 15658734
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -13
              Font.Name = #44404#47548
              Font.Style = []
              ParentColor = False
              ParentFont = False
              TabOrder = 1
              OnMouseDown = EditFuturesMouseDown
            end
            object ComboOptions: TComboBox
              Left = 42
              Top = 24
              Width = 54
              Height = 18
              Style = csOwnerDrawFixed
              ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
              ItemHeight = 12
              TabOrder = 2
              OnChange = ComboOptionsChange
            end
            object edDeliveryTime: TEdit
              Left = 95
              Top = 20
              Width = 46
              Height = 21
              Color = 16509691
              ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
              ReadOnly = True
              TabOrder = 3
            end
          end
          object PanelUnders: TPanel
            Left = 2
            Top = 2
            Width = 150
            Height = 25
            Align = alTop
            BevelInner = bvSpace
            BevelOuter = bvLowered
            TabOrder = 1
            object Label3: TLabel
              Left = 6
              Top = 6
              Width = 38
              Height = 13
              Caption = #44592#52488' : '
            end
            object ComboUnders: TComboBox
              Left = 42
              Top = 3
              Width = 100
              Height = 18
              Style = csOwnerDrawFixed
              ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
              ItemHeight = 12
              TabOrder = 0
              OnChange = ComboUndersChange
            end
          end
        end
        object GridOptions: TStringGrid
          Left = 0
          Top = 73
          Width = 154
          Height = 287
          Align = alClient
          Color = clBtnFace
          ColCount = 3
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          ScrollBars = ssVertical
          TabOrder = 1
          OnDrawCell = GridOptionsDrawCell
          OnMouseDown = GridOptionsMouseDown
          OnMouseWheelDown = GridOptionsMouseWheelDown
          OnMouseWheelUp = GridOptionsMouseWheelUp
          OnSelectCell = GridOptionsSelectCell
          ColWidths = (
            36
            49
            35)
        end
      end
    end
    object PageTick: TPageControl
      Left = 0
      Top = 0
      Width = 154
      Height = 273
      ActivePage = TickSheetLeft
      Align = alTop
      Style = tsFlatButtons
      TabOrder = 1
      object TickSheetLeft: TTabSheet
        Caption = 'L'
        object PaintTicksLeft: TPaintBox
          Left = 0
          Top = 0
          Width = 146
          Height = 242
          Align = alClient
        end
      end
      object TickSheetRight: TTabSheet
        Caption = 'R'
        ImageIndex = 1
        object PaintTicksRight: TPaintBox
          Left = 0
          Top = 0
          Width = 146
          Height = 242
          Align = alClient
        end
      end
    end
  end
  object PanelMain: TPanel
    Left = 154
    Top = 0
    Width = 580
    Height = 633
    Align = alClient
    BevelOuter = bvNone
    Caption = 'PanelMain'
    TabOrder = 1
    object Label1: TLabel
      Left = 504
      Top = 16
      Width = 41
      Height = 13
      Caption = 'Label1'
    end
    object PanelTop: TPanel
      Left = 0
      Top = 0
      Width = 580
      Height = 33
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 0
      object ButtonSync: TSpeedButton
        Left = 52
        Top = 5
        Width = 23
        Height = 22
        AllowAllUp = True
        GroupIndex = 2
        Flat = True
        Glyph.Data = {
          36080000424D3608000000000000360400002800000040000000100000000100
          08000000000000040000C40E0000C40E00000001000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
          A6000020400000206000002080000020A0000020C0000020E000004000000040
          20000040400000406000004080000040A0000040C0000040E000006000000060
          20000060400000606000006080000060A0000060C0000060E000008000000080
          20000080400000806000008080000080A0000080C0000080E00000A0000000A0
          200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
          200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
          200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
          20004000400040006000400080004000A0004000C0004000E000402000004020
          20004020400040206000402080004020A0004020C0004020E000404000004040
          20004040400040406000404080004040A0004040C0004040E000406000004060
          20004060400040606000406080004060A0004060C0004060E000408000004080
          20004080400040806000408080004080A0004080C0004080E00040A0000040A0
          200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
          200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
          200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
          20008000400080006000800080008000A0008000C0008000E000802000008020
          20008020400080206000802080008020A0008020C0008020E000804000008040
          20008040400080406000804080008040A0008040C0008040E000806000008060
          20008060400080606000806080008060A0008060C0008060E000808000008080
          20008080400080806000808080008080A0008080C0008080E00080A0000080A0
          200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
          200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
          200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
          2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
          2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
          2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
          2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
          2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
          2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
          2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00FFF7F7F7F7F7
          F7F7F7F7FFFFFFFFFFFFFF43948B8B9495438C83FFFFFFFFFFFFFF43948B8B94
          95438C83FFFFFFFFFFFFFF43948B8B9495438C83FFFFFFFFFFFFFFF7F7F7F7F7
          F7F7F7FFFFFFFFFFFFFFFF448BDD9D8B944242FFFFFFFFFFFFFFFF448BDD9D8B
          944242FFFFFFFFFFFFFFFF448BDD9D8B944242FFFFFFFFFFFFFFFFFFF7F7F7F7
          F7F7F7F7F7F7F7F7FFFFFFFF9B9CA4A493410A52A3ACE49BFFFFFFFF9B9CA4A4
          93410A52A3ACE49BFFFFFFFF9B9CA4A493410A52A3ACE49BFFFFFFFFF7F7F7F7
          F7F70707080809EDF7FFFFFF9B525192938A0707080809ED4AFFFFFF9B525192
          938A0707080809ED4AFFFFFF9B525192938A0707080809ED4AFFFFFFFFF7F7F7
          070808F6B4F7F7F7F7FFFFFFFFE34848070808F6B4625A9A49FFFFFFFFE34848
          070808F6B4625A9A49FFFFFFFFE34848070808F6B4625A9A49FFFFFFFFFFF7EC
          F6F608F7F7F7F7F7F7FFFFFFFFFF48ECF6F608A41062F5F78AFFFFFFFFFF48EC
          F6F608A41062F5F78AFFFFFFFFFF48ECF6F608A41062F5F78AFFFFFFFFF7F7FF
          F607F7F7F7F7F7F7F7FFFFFFFFC1A4FFF607939B5107075281FFFFFFFFC1A4FF
          F607939B5107075281FFFFFFFFC1A4FFF607939B5107075281FFFFFFFFF7FF09
          07F7F7F7F7F7F7F7FFFFFFFFFFC1FF0907A4A4EE5AF7A349FFFFFFFFFFC1FF09
          07A4A4EE5AF7A349FFFFFFFFFFC1FF0907A4A4EE5AF7A349FFFFFFFFF7E5F6F6
          F7F7F7F7F7F7F7FFFFFFFFFF41E5F6F69BF7ADAE52ED81FFFFFFFFFF41E5F6F6
          9BF7ADAE52ED81FFFFFFFFFF41E5F6F69BF7ADAE52ED81FFFFFFFFFFF709FFF7
          F7F7F7F7F7F7FFFFFFFFFFFF8A09FFA49BA507AD9B52FFFFFFFFFFFF8A09FFA4
          9BA507AD9B52FFFFFFFFFFFF8A09FFA49BA507AD9B52FFFFFFFFFFFFF7FF08F7
          F7F7F7F7F7F7F7FFFFFFFFFF9AFF0811525B9252929A92FFFFFFFFFF9AFF0811
          525B9252929A92FFFFFFFFFF9AFF0811525B9252929A92FFFFFFFFFFF7FFF7F7
          F7F7F7F7F7F7F7F7FFFFFFFF51FF6263F7F7ED52E39AE340FFFFFFFF51FF6263
          F7F7ED52E39AE340FFFFFFFF51FF6263F7F7ED52E39AE3F9FFFFFFFFF7F6F7F7
          F7F7F7F7FFF7E4F7F7FFFFFF89F69AF5EDE4C9C0FFE4E49A81FFFFFF89F69AF5
          EDE4C9C0FFE4E49A81FFFFFF89F69AF5EDE4C9C0FFE4F9F9F9FFFFFFF709F7F7
          F7F7FFFFFFFFF7F7F7FFFFFF89099AA39240FFFFFFFF928981FFFFFF89099AA3
          9240FFFFFFFF928981FFFFFF89099AA39240FFFFFFFFF9F9F9FFFFFFFFF7F7F7
          FFFFFFFFFFFFFFFFFFFFFFFFFF818181FFFFFFFFFFFFFFFFFFFFFFFFFF818181
          FFFFFFFFFFFFFFFFFFFFFFFFFF818181FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
          FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF}
        NumGlyphs = 4
        OnClick = ButtonSyncClick
      end
      object BtnLeftPanel: TSpeedButton
        Left = 6
        Top = 5
        Width = 23
        Height = 22
        AllowAllUp = True
        GroupIndex = 1
        Caption = '>>'
        Flat = True
        NumGlyphs = 4
        OnClick = BtnLeftPanelClick
      end
      object ButtonFix: TSpeedButton
        Left = 29
        Top = 5
        Width = 23
        Height = 22
        AllowAllUp = True
        BiDiMode = bdLeftToRight
        GroupIndex = 1
        Flat = True
        Glyph.Data = {
          FE020000424DFE02000000000000760000002800000048000000120000000100
          0400000000008802000000000000000000001000000000000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888880088888888888807700077888888888888888
          0088888888888807700077888888888888800088880088888800000007888888
          8888888800088880088888800000007888888888888070000000888888077700
          0078888888888888070000000888888077700007888888888880700000708888
          8077777000088888888888880700000708888807777700008888800000008707
          7080888880787000000888888800000008707708088888078700000088888777
          777088788780888880F807887700888888777777088788780888880F80788770
          0888888888808F7FF7F0888880FF0F88870088888888888808F7FF7F0888880F
          F0F888700888888888808F0000F08888880F0F88887088888888888808F0000F
          08888880F0F88887088888888880F0888800888888000FF88870888888888888
          0F0888800888888000FF8887088888888880088888888888888800FFFF088888
          888888880088888888888888800FFFF088888888888888888888888888888800
          0088888888888888888888888888888888800008888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888888888888888888888888888888888888888888888888888888888888888
          8888}
        NumGlyphs = 4
        ParentBiDiMode = False
      end
      object BtnRightPanel: TSpeedButton
        Left = 383
        Top = 5
        Width = 23
        Height = 22
        AllowAllUp = True
        GroupIndex = 3
        Caption = '<<'
        Flat = True
        NumGlyphs = 4
        OnClick = BtnRightPanelClick
      end
      object ButtonConfig: TSpeedButton
        Left = 354
        Top = 5
        Width = 23
        Height = 22
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          F6000000424DF600000000000000760000002800000010000000100000000100
          04000000000080000000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00555555777555
          5555555555000757755555575500005007555570058880000075570870088078
          007555787887087777755550880FF0800007708080888F7088077088F0708F78
          88077000F0778080005555508F0008800755557878FF88777075570870080088
          0755557075888070755555575500075555555555557775555555}
        OnClick = ButtonConfigClick
      end
      object ComboAccount: TComboBox
        Left = 79
        Top = 5
        Width = 269
        Height = 21
        Style = csDropDownList
        ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
        ItemHeight = 13
        TabOrder = 0
        OnChange = ComboAccountChange
      end
    end
    object PanelLeftSymbol: TPanel
      Left = 0
      Top = 33
      Width = 290
      Height = 581
      Align = alLeft
      BevelOuter = bvNone
      Caption = 'PanelLeftSymbol'
      TabOrder = 1
      object PanelQtyLeft: TPanel
        Left = 0
        Top = 515
        Width = 290
        Height = 66
        Align = alBottom
        BevelOuter = bvNone
        Color = 16312544
        TabOrder = 0
        object GridQtyLeft: TStringGrid
          Left = 51
          Top = 6
          Width = 177
          Height = 54
          ColCount = 4
          DefaultColWidth = 42
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 3
          FixedRows = 0
          ScrollBars = ssNone
          TabOrder = 0
          OnClick = GridQtyLeftClick
          OnDrawCell = GridQtyDrawCell
          OnExit = GridQtyExit
          OnKeyPress = GridQtyKeyPress
          OnMouseDown = GridQtyLeftMouseDown
          OnMouseWheelDown = GridQtyMouseWheelDown
          OnMouseWheelUp = GridQtyMouseWheelUp
          OnSelectCell = GridQtyLeftSelectCell
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 45
          Height = 66
          Align = alLeft
          BevelOuter = bvNone
          Color = 16312544
          TabOrder = 1
          object ShapeLeft: TShape
            Left = 4
            Top = 6
            Width = 37
            Height = 19
            Pen.Color = clBlue
          end
          object GridOrderQtyLeft: TStringGrid
            Left = 5
            Top = 7
            Width = 35
            Height = 17
            BorderStyle = bsNone
            ColCount = 1
            DefaultColWidth = 35
            DefaultRowHeight = 17
            FixedCols = 0
            RowCount = 1
            FixedRows = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
            ScrollBars = ssNone
            TabOrder = 0
            OnClick = GridOrderQtyLeftClick
            OnDrawCell = GridOrderQtyLeftDrawCell
            OnExit = GridOrderQtyExit
            OnKeyPress = GridOrderQtyKeyPress
            OnMouseWheelDown = GridOrderQtyMouseWheelDown
            OnMouseWheelUp = GridOrderQtyMouseWheelUp
            OnSelectCell = GridOrderQtyLeftSelectCell
            OnSetEditText = GridOrderQtyLeftSetEditText
          end
          object StaticExitLeft: TStaticText
            Left = 5
            Top = 39
            Width = 35
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BiDiMode = bdRightToLeftReadingOnly
            Caption = '0'
            ParentBiDiMode = False
            TabOrder = 1
            OnClick = StaticExitLeftClick
          end
        end
      end
      object PanelTabletLeft: TPanel
        Left = 0
        Top = 0
        Width = 290
        Height = 515
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object PaintTabletLeft: TPaintBox
          Left = 0
          Top = 0
          Width = 290
          Height = 515
          Align = alClient
          Color = clBtnFace
          ParentColor = False
          ExplicitLeft = -2
          ExplicitTop = -1
          ExplicitHeight = 504
        end
        object ComboSymbol: TComboBox
          Tag = 300
          Left = 29
          Top = 47
          Width = 85
          Height = 18
          Style = csOwnerDrawFixed
          Font.Charset = HANGEUL_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #44404#47548
          Font.Style = []
          ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
          ItemHeight = 12
          ParentFont = False
          TabOrder = 0
          Visible = False
        end
      end
    end
    object PanelRightSymbol: TPanel
      Left = 290
      Top = 33
      Width = 290
      Height = 581
      Align = alClient
      BevelOuter = bvNone
      Caption = 'PanelRightSymbol'
      TabOrder = 2
      object PanelQtyRight: TPanel
        Left = 0
        Top = 515
        Width = 290
        Height = 66
        Align = alBottom
        BevelOuter = bvNone
        Color = 16047349
        TabOrder = 0
        object GridQtyRight: TStringGrid
          Left = 55
          Top = 6
          Width = 177
          Height = 54
          ColCount = 4
          DefaultColWidth = 42
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 3
          FixedRows = 0
          ScrollBars = ssNone
          TabOrder = 0
          OnClick = GridQtyRightClick
          OnDrawCell = GridQtyDrawCell
          OnExit = GridQtyExit
          OnKeyPress = GridQtyKeyPress
          OnMouseDown = GridQtyRightMouseDown
          OnMouseWheelDown = GridQtyMouseWheelDown
          OnMouseWheelUp = GridQtyMouseWheelUp
          OnSelectCell = GridQtyRightSelectCell
        end
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 45
          Height = 66
          Align = alLeft
          BevelOuter = bvNone
          Color = 16047349
          TabOrder = 1
          object ShapeRight: TShape
            Left = 4
            Top = 5
            Width = 37
            Height = 19
            Pen.Color = clBlue
          end
          object GridOrderQtyRight: TStringGrid
            Left = 5
            Top = 6
            Width = 35
            Height = 17
            BorderStyle = bsNone
            ColCount = 1
            DefaultColWidth = 35
            DefaultRowHeight = 17
            FixedCols = 0
            RowCount = 1
            FixedRows = 0
            Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
            ScrollBars = ssNone
            TabOrder = 0
            OnClick = GridOrderQtyRightClick
            OnDrawCell = GridOrderQtyRightDrawCell
            OnExit = GridOrderQtyExit
            OnKeyPress = GridOrderQtyKeyPress
            OnMouseWheelDown = GridOrderQtyMouseWheelDown
            OnMouseWheelUp = GridOrderQtyMouseWheelUp
            OnSelectCell = GridOrderQtyRightSelectCell
            OnSetEditText = GridOrderQtyRightSetEditText
          end
          object StaticExitRight: TStaticText
            Left = 5
            Top = 39
            Width = 35
            Height = 17
            Alignment = taCenter
            AutoSize = False
            BiDiMode = bdRightToLeftReadingOnly
            Caption = '0'
            ParentBiDiMode = False
            TabOrder = 1
            OnClick = StaticExitRightClick
          end
        end
      end
      object PanelTabletRight: TPanel
        Left = 0
        Top = 0
        Width = 290
        Height = 515
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 1
        object PaintTabletRight: TPaintBox
          Left = 0
          Top = 0
          Width = 290
          Height = 515
          Align = alClient
          Color = clBtnFace
          ParentColor = False
          ExplicitLeft = -2
          ExplicitTop = -1
        end
      end
    end
    object StatusInfo: TStatusBar
      Left = 0
      Top = 614
      Width = 580
      Height = 19
      Panels = <
        item
          Alignment = taCenter
          Bevel = pbNone
          Text = #45824#44592#49688
          Width = 40
        end
        item
          Alignment = taCenter
          Width = 20
        end
        item
          Alignment = taCenter
          Bevel = pbNone
          Text = #49552#51061
          Width = 30
        end
        item
          Alignment = taRightJustify
          Width = 50
        end
        item
          Alignment = taCenter
          Bevel = pbNone
          Text = #49688#49688#47308
          Width = 40
        end
        item
          Alignment = taRightJustify
          Width = 34
        end
        item
          Bevel = pbNone
          Text = #49692#49552#51061
          Width = 40
        end
        item
          Alignment = taRightJustify
          Width = 50
        end
        item
          Bevel = pbNone
          Text = '('#52380#50896')'
          Width = 50
        end>
    end
  end
  object PanelRight: TPanel
    Left = 734
    Top = 0
    Width = 154
    Height = 633
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 2
    object Splitter1: TSplitter
      Left = 0
      Top = 297
      Width = 154
      Height = 3
      Cursor = crVSplit
      Align = alTop
    end
    object PageDummy: TPageControl
      Left = 0
      Top = 0
      Width = 154
      Height = 297
      ActivePage = TabSheet1Left
      Align = alTop
      MultiLine = True
      Style = tsFlatButtons
      TabOrder = 0
      object TabSheet1Left: TTabSheet
        Caption = 'L'
        object PaintTicksLeft2: TPaintBox
          Left = 0
          Top = 0
          Width = 146
          Height = 266
          Align = alClient
        end
      end
      object TabSheet2Right: TTabSheet
        Caption = 'R'
        ImageIndex = 1
        object PaintTicksRight2: TPaintBox
          Left = 0
          Top = 0
          Width = 146
          Height = 266
          Align = alClient
        end
      end
    end
    object Panel7: TPanel
      Left = 0
      Top = 300
      Width = 154
      Height = 41
      Align = alTop
      TabOrder = 1
      object BtnLeftInfo: TSpeedButton
        Left = 6
        Top = 8
        Width = 38
        Height = 22
        AllowAllUp = True
        GroupIndex = 3
        Caption = 'L'
        Flat = True
        NumGlyphs = 4
        OnClick = BtnLeftInfoClick
      end
      object BtnRightInfo: TSpeedButton
        Left = 52
        Top = 8
        Width = 38
        Height = 22
        AllowAllUp = True
        GroupIndex = 3
        Caption = 'R'
        Flat = True
        NumGlyphs = 4
        OnClick = BtnRightInfoClick
      end
      object BtnOrderList: TSpeedButton
        Left = 96
        Top = 8
        Width = 38
        Height = 22
        AllowAllUp = True
        GroupIndex = 3
        Caption = #51452#47928
        Flat = True
        NumGlyphs = 4
        OnClick = BtnOrderListClick
      end
    end
    object PanelOrderList: TPanel
      Left = 0
      Top = 341
      Width = 154
      Height = 292
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 2
      object ListOrders: TListView
        Left = 0
        Top = 57
        Width = 154
        Height = 235
        Align = alClient
        Checkboxes = True
        Columns = <
          item
            Caption = #49440#53469
            Width = 40
          end
          item
            Alignment = taRightJustify
            Caption = #44060#49688
            Width = 55
          end
          item
            Caption = #48264#54840
            Width = 55
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnMouseUp = ListOrdersMouseUp
      end
      object Panel5: TPanel
        Left = 0
        Top = 0
        Width = 154
        Height = 57
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object lblSymbol: TLabel
          Left = 6
          Top = 6
          Width = 46
          Height = 13
          Caption = 'Symbol'
        end
        object lblPrice: TLabel
          Left = 98
          Top = 6
          Width = 33
          Height = 13
          Caption = 'Price'
        end
        object lblQty: TLabel
          Left = 63
          Top = 30
          Width = 21
          Height = 13
          Caption = '/ 0 '
        end
        object BtnCancel: TButton
          Left = 100
          Top = 25
          Width = 45
          Height = 25
          Caption = #52712#49548
          TabOrder = 0
          OnClick = BtnCancelClick
        end
        object EditOrderQty: TEdit
          Left = 6
          Top = 27
          Width = 51
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 1
          Text = '0'
          OnExit = editOrderQtyExit
          OnKeyPress = editOrderQtyKeyPress
        end
      end
    end
    object PanelInfo: TPanel
      Left = 0
      Top = 341
      Width = 154
      Height = 292
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 3
      object GridInfo: TStringGrid
        Left = 0
        Top = 0
        Width = 154
        Height = 292
        Align = alClient
        ColCount = 2
        DefaultRowHeight = 16
        FixedCols = 0
        RowCount = 14
        FixedRows = 0
        ScrollBars = ssNone
        TabOrder = 0
        OnDrawCell = GridInfoDrawCell
        RowHeights = (
          16
          16
          16
          16
          16
          16
          16
          16
          16
          16
          16
          16
          16
          16)
      end
    end
  end
  object PopOrdersLeft: TPopupMenu
    OnPopup = PopOrdersLeftPopup
    Left = 224
    Top = 176
    object N6000X11: TMenuItem
      Tag = 100
      Caption = #47588#49688' 60.00 X 1'
      OnClick = PopOrdersLeftClick
    end
    object N1: TMenuItem
      Tag = 200
      Caption = #47588#49688#51452#47928
      OnClick = PopOrdersLeftClick
    end
    object N2: TMenuItem
      Tag = 300
      Caption = #51221#51221
      OnClick = PopOrdersLeftClick
    end
    object N3: TMenuItem
      Tag = 400
      Caption = #51068#48512' '#52712#49548
      OnClick = PopOrdersLeftClick
    end
    object N4: TMenuItem
      Tag = 500
      Caption = #51204#48512#52712#49548
      OnClick = PopOrdersLeftClick
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Tag = 900
      Caption = #47588#49688#51452#47928' '#51204#48512#52712#49548
      OnClick = PopOrdersLeftClick
    end
    object N7: TMenuItem
      Tag = 1000
      Caption = #51452#47928#51204#48512#52712#49548
      OnClick = PopOrdersLeftClick
    end
  end
  object PopQuote: TPopupMenu
    OnPopup = PopQuotePopup
    Left = 208
    Top = 139
    object N8: TMenuItem
      Tag = 110
      Caption = #54788#51116#44032'(&P)'
      OnClick = PopQuoteClick
    end
    object C1: TMenuItem
      Tag = 120
      Caption = #52264#53944'(&C)'
      OnClick = PopQuoteClick
    end
  end
  object PopOrdersRight: TPopupMenu
    OnPopup = PopOrdersRightPopup
    Left = 168
    Top = 176
    object MenuItem1: TMenuItem
      Tag = 100
      Caption = #47588#49688' 60.00 X 1'
      OnClick = PopOrdersRightClick
    end
    object MenuItem2: TMenuItem
      Tag = 200
      Caption = #47588#49688#51452#47928
      OnClick = PopOrdersRightClick
    end
    object MenuItem3: TMenuItem
      Tag = 300
      Caption = #51221#51221
      OnClick = PopOrdersRightClick
    end
    object MenuItem4: TMenuItem
      Tag = 400
      Caption = #51068#48512' '#52712#49548
      OnClick = PopOrdersRightClick
    end
    object MenuItem5: TMenuItem
      Tag = 500
      Caption = #51204#48512#52712#49548
      OnClick = PopOrdersRightClick
    end
    object MenuItem6: TMenuItem
      Caption = '-'
    end
    object MenuItem7: TMenuItem
      Tag = 900
      Caption = #47588#49688#51452#47928' '#51204#48512#52712#49548
      OnClick = PopOrdersRightClick
    end
    object MenuItem8: TMenuItem
      Tag = 1000
      Caption = #51452#47928#51204#48512#52712#49548
      OnClick = PopOrdersRightClick
    end
  end
end
