object SingleOrderBoardForm: TSingleOrderBoardForm
  Left = 0
  Top = 0
  Caption = 'Single Order Board'
  ClientHeight = 527
  ClientWidth = 624
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
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
    Width = 170
    Height = 527
    Align = alLeft
    BevelInner = bvLowered
    TabOrder = 0
    ExplicitTop = -234
    object PanelUnders: TPanel
      Left = 2
      Top = 2
      Width = 166
      Height = 39
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 0
      object Bevel1: TBevel
        Left = 16
        Top = 32
        Width = 142
        Height = 4
        Shape = bsTopLine
      end
      object ComboBoxUnderlyings: TComboBox
        Left = 2
        Top = 5
        Width = 108
        Height = 21
        Style = csDropDownList
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 13
        TabOrder = 0
        OnChange = ComboBoxUnderlyingsChange
      end
      object StaticTextUnderlying: TStaticText
        Left = 118
        Top = 10
        Width = 46
        Height = 16
        Alignment = taCenter
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
        OnMouseDown = StaticTextUnderlyingMouseDown
      end
    end
    object PageControl1: TPageControl
      Left = 2
      Top = 91
      Width = 166
      Height = 434
      ActivePage = TabSheetOptions
      Align = alClient
      TabOrder = 1
      object TabSheetOptions: TTabSheet
        Caption = #50741#49496
        object StringGridOptions: TStringGrid
          Left = 0
          Top = 23
          Width = 158
          Height = 383
          Align = alClient
          Color = clBtnFace
          ColCount = 3
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          ScrollBars = ssVertical
          TabOrder = 0
          OnDrawCell = StringGridOptionsDrawCell
          OnMouseDown = StringGridOptionsMouseDown
          OnMouseWheelDown = StringGridOptionsMouseWheelDown
          OnMouseWheelUp = StringGridOptionsMouseWheelUp
          ExplicitTop = 25
          ColWidths = (
            36
            49
            35)
        end
        object Panel1: TPanel
          Left = 0
          Top = 0
          Width = 158
          Height = 23
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object ComboBoxOptions: TComboBox
            Left = 2
            Top = 2
            Width = 103
            Height = 18
            Style = csOwnerDrawFixed
            ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
            ItemHeight = 12
            TabOrder = 0
            OnChange = ComboBoxOptionsChange
          end
          object edDeliveryTime: TEdit
            Left = 108
            Top = 2
            Width = 47
            Height = 17
            AutoSize = False
            Color = 16509691
            ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
            ReadOnly = True
            TabOrder = 1
          end
        end
      end
      object TabSheetELWs: TTabSheet
        Caption = 'ELW'
        ImageIndex = 1
        object Panel2: TPanel
          Left = 0
          Top = 0
          Width = 158
          Height = 25
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object Label7: TLabel
            Left = 5
            Top = 7
            Width = 47
            Height = 13
            Caption = #51092#51316#51068': '
          end
          object ComboBoxELWs: TComboBox
            Left = 52
            Top = 4
            Width = 103
            Height = 18
            Style = csOwnerDrawFixed
            ImeName = #54620#44397#50612'('#54620#44544') (MS-IME95)'
            ItemHeight = 12
            TabOrder = 0
            OnChange = ComboBoxELWsChange
          end
        end
        object StringGridELWTrees: TStringGrid
          Left = 0
          Top = 25
          Width = 158
          Height = 247
          Align = alClient
          Color = clBtnFace
          ColCount = 3
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          ScrollBars = ssVertical
          TabOrder = 1
          ColWidths = (
            38
            56
            38)
        end
        object StringGridELWs: TStringGrid
          Left = 0
          Top = 272
          Width = 158
          Height = 134
          Align = alBottom
          Color = clBtnFace
          ColCount = 4
          DefaultRowHeight = 16
          FixedCols = 0
          RowCount = 2
          Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
          ScrollBars = ssVertical
          TabOrder = 2
          ColWidths = (
            45
            31
            30
            32)
        end
      end
      object TabSheet1: TTabSheet
        Caption = '...'
        ImageIndex = 2
        object lvSymbolList: TListView
          Left = 0
          Top = 0
          Width = 158
          Height = 406
          Align = alClient
          Columns = <
            item
              Caption = #51333#47785#47749
              Width = 100
            end
            item
              Caption = #53076#46300
              Width = 65
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #44404#47548
          Font.Style = []
          GridLines = True
          ReadOnly = True
          RowSelect = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
        end
      end
    end
    object PanelFutures: TPanel
      Left = 2
      Top = 41
      Width = 166
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 2
      object LabelFut: TLabel
        Left = 6
        Top = 3
        Width = 21
        Height = 13
        Caption = #49440': '
      end
      object ComboBoxFutures: TComboBox
        Left = 24
        Top = 0
        Width = 90
        Height = 19
        Style = csOwnerDrawFixed
        ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
        ItemHeight = 13
        TabOrder = 0
        OnChange = ComboBoxFuturesChange
      end
      object StaticTextFutures: TStaticText
        Left = 116
        Top = 1
        Width = 46
        Height = 16
        Alignment = taCenter
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
        OnMouseDown = StaticTextFuturesMouseDown
      end
    end
    object PanelSpread: TPanel
      Left = 2
      Top = 66
      Width = 166
      Height = 25
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 3
      object Label3: TLabel
        Left = 6
        Top = 3
        Width = 21
        Height = 13
        Caption = #49828': '
      end
      object ComboBoxSpreads: TComboBox
        Left = 24
        Top = 0
        Width = 90
        Height = 19
        Style = csOwnerDrawFixed
        ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
        ItemHeight = 13
        TabOrder = 0
        OnChange = ComboBoxSpreadsChange
      end
      object StaticTextSpread: TStaticText
        Left = 116
        Top = 1
        Width = 46
        Height = 16
        Alignment = taCenter
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
        OnMouseDown = StaticTextSpreadMouseDown
      end
    end
  end
  object PanelMain: TPanel
    Left = 170
    Top = 0
    Width = 300
    Height = 527
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitWidth = 350
    object PanelTop: TPanel
      Left = 0
      Top = 0
      Width = 300
      Height = 33
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 0
      ExplicitWidth = 508
      object SpeedButtonLeftPanel: TSpeedButton
        Left = 2
        Top = 2
        Width = 31
        Height = 29
        Align = alLeft
        AllowAllUp = True
        GroupIndex = 1
        Down = True
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000000000000000000000010000000100004A004A006200
          6200780178009F019F00BC01BC00D301D300E200E200EF00EF00F700F700FB00
          FB00FD00FD00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FD00FD00FC00FC00FA00FA00F701F700F202F200EC03
          EC00E305E300D708D700C60BC600AF11AF008F188F007E1D7E006C226C006125
          6100572857004C2C4C0040304000353535003636360037373700383838003939
          39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
          4100424242004343430044444400454545004646460047474700484848004949
          49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
          5100525252005353530054545400555555005656560057575700585858005959
          59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
          6100626262006363630064646400656565006666660067676700686868006969
          69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
          7100727272007373730074747400757575007676760077777700787878007979
          79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
          8100828282008383830084848400858585008686860087878700888888008989
          89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
          9100929292009393930094949400959595009696960097979700989898009999
          99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
          A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
          A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00AFAFAF00B0B0B000B1B1
          B100B2B2B200B3B3B300B4B4B400B5B5B500B6B6B600B7B7B700BABEBC00BEC5
          C100C1CCC500C8D6CD00CDDED400D2E4D900D7EADF00DCEEE300E0F2E700E7F6
          EC00EEF9F100F2FBF500F5FBF700F7FCF800F9FDFA00FAFDFB00FBFDFB00FBFD
          FC00F9FDFA00F6FCF800F3FBF600ECFAF100E7F8ED00E4F7EB00DFF6E800DAF5
          E400D6F4E100D2F2DD00CEF1DA00CBF0D700C7EFD500C3EED100BEECCC00B9EA
          C900B1E8C400A9E6BE009FE3B70095E0B0008CDDA7007FD99F0073D596006BD3
          8F0063D089005DCE820058CD7F0051CB7B004AC9770044C872003DC66D0037C4
          68002FBF61002DBD5D002CBA59002AB9560028B7510026B74C0024B6480022B4
          410020B23B001DB2360017B22E0011B127000DB120000BB11C000AB01B0009AB
          190009A518000A8F1700097C1300086F100007680E00076A0E001515151515FE
          FEFFFFFEFE1515151515151515FEFEFBF8F8F8F8FBFEFE1515151515FFFCF7F8
          F8F8F8F8F8F8FCFE151515FFFBF4F5F7F8F8F8F8F8F8F8FCFE1515FFF0F1F4F7
          E3C2D1F3F8F8F8F8FE15FDF2EBF0F5E4C5C9DDF6F8F8F8F8FBFEFDEDEAEFE4CB
          C9DEF8F8F8F8F8F8F9FEFCE9E9DECCC9CAD6D8D8D8D8D8F8F8FEFBE4E6D5C9C9
          C9C9C9C9C9C9C9F8F8FFFBE1E2E6D9C9C9DCE4E3E4E4E4F5F8FEFBE3DCE8E9DB
          C9CEE1EFF0F0F1F5FAFE15F2D8DFEAE9DBC9C5E7F0F1F3F4FB1515F2E1D2DFE9
          E9DBD8E9EDEFF0F4FB151515F2DFD0DAE1E5E6E6E6E9F0FC1515151515F2F2DA
          D3D8DBDDE1EDED1515151515151515EEF2F2F2F2F11515151515}
        OnClick = SpeedButtonLeftPanelClick
      end
      object SpeedButtonRightPanel: TSpeedButton
        Left = 267
        Top = 2
        Width = 31
        Height = 29
        Align = alRight
        AllowAllUp = True
        GroupIndex = 3
        Down = True
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          08000000000000010000000000000000000000010000000100004A004A006200
          6200780178009F019F00BC01BC00D301D300E200E200EF00EF00F700F700FB00
          FB00FD00FD00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FD00FD00FC00FC00FA00FA00F701F700F202F200EC03
          EC00E305E300D708D700C60BC600AF11AF008F188F007E1D7E006C226C006125
          6100572857004C2C4C0040304000353535003636360037373700383838003939
          39003A3A3A003B3B3B003C3C3C003D3D3D003E3E3E003F3F3F00404040004141
          4100424242004343430044444400454545004646460047474700484848004949
          49004A4A4A004B4B4B004C4C4C004D4D4D004E4E4E004F4F4F00505050005151
          5100525252005353530054545400555555005656560057575700585858005959
          59005A5A5A005B5B5B005C5C5C005D5D5D005E5E5E005F5F5F00606060006161
          6100626262006363630064646400656565006666660067676700686868006969
          69006A6A6A006B6B6B006C6C6C006D6D6D006E6E6E006F6F6F00707070007171
          7100727272007373730074747400757575007676760077777700787878007979
          79007A7A7A007B7B7B007C7C7C007D7D7D007E7E7E007F7F7F00808080008181
          8100828282008383830084848400858585008686860087878700888888008989
          89008A8A8A008B8B8B008C8C8C008D8D8D008E8E8E008F8F8F00909090009191
          9100929292009393930094949400959595009696960097979700989898009999
          99009A9A9A009B9B9B009C9C9C009D9D9D009E9E9E009F9F9F00A0A0A000A1A1
          A100A2A2A200A3A3A300A4A4A400A5A5A500A6A6A600A7A7A700A8A8A800A9A9
          A900AAAAAA00ABABAB00ACACAC00ADADAD00AEAEAE00B3B3B300BFC1BF00C8CC
          C900D0D5D200D7DDD900DEE6E100E6EDE800ECF3EE00F1F7F300F5FAF600F7FB
          F900F9FCFA00FBFDFB00FBFDFC00FBFDFC00F9FDFA00F6FCF800F4FBF600F0FA
          F300ECFAF100E9F9EF00E6F8ED00E2F7EA00DDF6E700D7F4E300D3F3E000D0F2
          DD00CEF1DB00CCF1D900C9EFD600C0EDCF00B9EBC900ADE7C000A3E4B80098E0
          AF008DDDA50085DAA0007DD89A0075D694006DD38F0067D18B0060CF84005BCE
          800055CC7B004DCA780047C8750042C672003DC46E0039C36B0036C2680033C0
          640030BE61002EBC5C002CBA590029B9550027B8510027B74E0025B5490023B5
          440023B3420022B13D0020B03B001EB1360019B2310016B32D0012B327000EB4
          21000BB41D000AB41B0009B31A0009B0190009AD19000AA318000A9717000A8C
          1700097D14000872120007680E0006640D0006650D0007690F001515151515FD
          FDFFFFFDFD1515151515151515FDFDF9F5F4F4F5F8FCFC1515151515FFFAF2F4
          F4F5F4F4F4F4FAFD151515FFF9EFF0F2F5F5F5F5F5F4F4FAFE1515FFE8E9EFF2
          EDC6C2D9F5F5F4F4FE15FBECE3E9F1F3F1D1BCBFDAF5F5F4F8FDFBE4E1E7F1F4
          F2F5D2BCBFDAF5F4F6FDFADFDFCACCCCCCCDCDBEBCC1D6F4F4FEF9D9DCBCBCBC
          BCBCBCBCBCBCCEF3F4FFF9D6D7D6D5D5D5D7D2BBBCD0E7F0F5FDF9D8D0DEE0DE
          DED5C4BCD1E8EBF0F7FD15ECCDD3E1E0DAB9BCD1E8E9EEEFF91515ECD6C8D3DF
          DECDCFE1E5E7E9EEF9151515ECD3C6CFD6DADCDBDBDFE8FA1515151515ECECCF
          C9CDCFD1D6E4E41515151515151515E7ECECECECEA1515151515}
        OnClick = SpeedButtonRightPanelClick
        ExplicitLeft = 483
      end
      object SpeedButtonPrefs: TSpeedButton
        Left = 39
        Top = 6
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
        OnClick = SpeedButtonPrefsClick
      end
      object ComboBoAccount: TComboBox
        Left = 69
        Top = 6
        Width = 124
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2003'
        ItemHeight = 13
        TabOrder = 0
      end
    end
  end
  object PanelRight: TPanel
    Left = 470
    Top = 0
    Width = 154
    Height = 527
    Align = alRight
    BevelInner = bvLowered
    TabOrder = 2
    ExplicitLeft = 272
    ExplicitTop = -234
    object PanelOrderList: TPanel
      Left = 2
      Top = 2
      Width = 150
      Height = 523
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      object GridInfo: TStringGrid
        Left = 0
        Top = 239
        Width = 150
        Height = 284
        Align = alBottom
        ColCount = 2
        DefaultRowHeight = 16
        FixedCols = 0
        RowCount = 16
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
          16
          16
          16)
      end
      object pcTab: TPageControl
        Left = 0
        Top = 0
        Width = 150
        Height = 239
        ActivePage = tabCancel
        Align = alClient
        TabOrder = 1
        object tabReady: TTabSheet
          Caption = #45824#44592
          object Panel3: TPanel
            Left = 0
            Top = 0
            Width = 142
            Height = 33
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object SpeedButton1: TSpeedButton
              Left = 68
              Top = 3
              Width = 64
              Height = 24
              Caption = #47784#46160#52712#49548
            end
          end
          object sgReady: TStringGrid
            Left = 0
            Top = 33
            Width = 142
            Height = 178
            Align = alClient
            ColCount = 3
            DefaultColWidth = 50
            DefaultRowHeight = 16
            FixedCols = 0
            RowCount = 10
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = #44404#47548
            Font.Style = []
            ParentFont = False
            TabOrder = 1
            ColWidths = (
              24
              50
              54)
          end
        end
        object tabCancel: TTabSheet
          Caption = #52712#49548
          ImageIndex = 1
          object Panel5: TPanel
            Left = 0
            Top = 0
            Width = 142
            Height = 57
            Align = alTop
            BevelOuter = bvNone
            TabOrder = 0
            object LabelSymbol: TLabel
              Left = 6
              Top = 6
              Width = 46
              Height = 13
              Caption = 'Symbol'
            end
            object LabelPrice: TLabel
              Left = 98
              Top = 6
              Width = 33
              Height = 13
              Caption = 'Price'
            end
            object LabelTotalQty: TLabel
              Left = 63
              Top = 38
              Width = 21
              Height = 13
              Caption = '/ 0 '
            end
            object ButtonCancel: TButton
              Left = 100
              Top = 25
              Width = 45
              Height = 25
              Caption = #52712#49548
              TabOrder = 0
            end
            object EditCancelQty: TEdit
              Left = 6
              Top = 27
              Width = 51
              Height = 21
              ImeName = 'Microsoft IME 2003'
              TabOrder = 1
              Text = '0'
            end
          end
          object ListViewOrders: TListView
            Left = 0
            Top = 57
            Width = 142
            Height = 154
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
            TabOrder = 1
            ViewStyle = vsReport
          end
        end
      end
    end
  end
  object PopupMenuOrders: TPopupMenu
    Left = 200
    Top = 136
    object N6000X11: TMenuItem
      Tag = 100
      Caption = #47588#49688' 60.00 X 1'
    end
    object N1: TMenuItem
      Tag = 200
      Caption = #47588#49688#51452#47928
    end
    object N2: TMenuItem
      Tag = 300
      Caption = #51221#51221
    end
    object N3: TMenuItem
      Tag = 400
      Caption = #51068#48512' '#52712#49548
    end
    object N4: TMenuItem
      Tag = 500
      Caption = #51204#48512#52712#49548
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N6: TMenuItem
      Tag = 900
      Caption = #47588#49688#51452#47928' '#51204#48512#52712#49548
    end
    object N7: TMenuItem
      Tag = 1000
      Caption = #51452#47928#51204#48512#52712#49548
    end
    object N9: TMenuItem
      Caption = '-'
    end
    object FlipDirection1: TMenuItem
      Caption = 'Flip Direction'
    end
    object FlipSide1: TMenuItem
      Caption = 'Flip Side'
    end
    object FlipSideDirection1: TMenuItem
      Caption = 'Flip Side && Direction'
    end
  end
  object PopQuote: TPopupMenu
    Left = 224
    Top = 123
    object N8: TMenuItem
      Tag = 110
      Caption = #54788#51116#44032'(&P)'
    end
    object C1: TMenuItem
      Tag = 120
      Caption = #52264#53944'(&C)'
    end
  end
end
