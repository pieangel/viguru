object SystemOrderForm: TSystemOrderForm
  Left = 1
  Top = 104
  Caption = #49884#49828#53596' '#51452#47928
  ClientHeight = 456
  ClientWidth = 871
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 154
    Width = 871
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object PageSystemOrder: TPageControl
    Left = 0
    Top = 157
    Width = 871
    Height = 280
    ActivePage = TabSheet2
    Align = alClient
    TabOrder = 0
    object TabSheet2: TTabSheet
      Caption = #49888#54840#50672#44208' '#49444#51221
      ImageIndex = 1
      object Splitter2: TSplitter
        Left = 373
        Top = 0
        Height = 252
        Beveled = True
        ResizeStyle = rsLine
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 373
        Height = 252
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 0
        object Panel4: TPanel
          Left = 0
          Top = 0
          Width = 373
          Height = 25
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object ButtonLinkAdd: TSpeedButton
            Tag = 100
            Left = 5
            Top = 0
            Width = 65
            Height = 22
            Caption = #52628#44032'(&A)'
            Flat = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = #44404#47548
            Font.Style = []
            ParentFont = False
            OnClick = ButtonLinkClick
          end
          object ButtonLinkEdit: TSpeedButton
            Tag = 200
            Left = 77
            Top = 0
            Width = 65
            Height = 22
            Caption = #49688#51221'(&E)'
            Enabled = False
            Flat = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = #44404#47548
            Font.Style = []
            ParentFont = False
            OnClick = ButtonLinkClick
          end
          object ButtonLinkDelete: TSpeedButton
            Tag = 300
            Left = 149
            Top = 0
            Width = 65
            Height = 22
            Caption = #49325#51228'(&D)'
            Enabled = False
            Flat = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlue
            Font.Height = -13
            Font.Name = #44404#47548
            Font.Style = []
            ParentFont = False
            OnClick = ButtonLinkClick
          end
        end
        object ListLink: TListView
          Left = 0
          Top = 25
          Width = 373
          Height = 227
          Align = alClient
          Columns = <
            item
              Caption = #44228#51340
              Width = 140
            end
            item
              Caption = #51333#47785
              Width = 80
            end
            item
              Caption = #49888#54840
              Width = 90
            end
            item
              Alignment = taRightJustify
              Caption = #49849#49688
              Width = 40
            end>
          GridLines = True
          OwnerData = True
          OwnerDraw = True
          ReadOnly = True
          PopupMenu = PopLink
          SmallImages = ImageList1
          TabOrder = 1
          ViewStyle = vsReport
          OnData = ListLinkData
          OnDblClick = ListLinkDblClick
          OnDrawItem = ListDrawItem
          OnSelectItem = ListLinkSelectItem
        end
      end
      object Panel6: TPanel
        Left = 376
        Top = 0
        Width = 487
        Height = 252
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel6'
        TabOrder = 1
        object Bevel4: TBevel
          Left = 0
          Top = 0
          Width = 487
          Height = 25
          Align = alTop
          Shape = bsSpacer
        end
        object Label1: TLabel
          Left = 8
          Top = 6
          Width = 61
          Height = 13
          Caption = #49888#54840' '#51221#51032' : '
        end
        object ButtonSignalAdd: TSpeedButton
          Tag = 100
          Left = 131
          Top = 0
          Width = 116
          Height = 22
          Caption = 'MC '#49888#54840' '#52628#44032'(&A)'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -13
          Font.Name = #44404#47548
          Font.Style = []
          ParentFont = False
          OnClick = SignalClick
        end
        object ButtonSignalEdit: TSpeedButton
          Tag = 200
          Left = 253
          Top = 0
          Width = 60
          Height = 22
          Caption = #49688#51221'(&E)'
          Enabled = False
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -13
          Font.Name = #44404#47548
          Font.Style = []
          ParentFont = False
          OnClick = SignalClick
        end
        object ButtonSignalDelete: TSpeedButton
          Tag = 300
          Left = 317
          Top = 0
          Width = 60
          Height = 22
          Caption = #49325#51228'(&D)'
          Enabled = False
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -13
          Font.Name = #44404#47548
          Font.Style = []
          ParentFont = False
          OnClick = SignalClick
        end
        object ListSignal: TListView
          Left = 0
          Top = 25
          Width = 487
          Height = 227
          Align = alClient
          Columns = <
            item
              Caption = #49888#54840
              Width = 90
            end
            item
              Alignment = taRightJustify
              Caption = #54252#51648#49496
              Width = 55
            end
            item
              Caption = #48156#49373#51109#49548
              Width = 90
            end
            item
              Caption = #49444#47749
              Width = 150
            end>
          GridLines = True
          OwnerData = True
          OwnerDraw = True
          ReadOnly = True
          PopupMenu = PopSignal
          SmallImages = ImageList1
          TabOrder = 0
          ViewStyle = vsReport
          OnData = ListSignalData
          OnDblClick = ListSignalDblClick
          OnDrawItem = ListDrawItem
          OnSelectItem = ListSignalSelectItem
        end
      end
    end
    object TabSheet5: TTabSheet
      Caption = #51452#47928' '#44592#47197
      ImageIndex = 4
      object Splitter3: TSplitter
        Left = 283
        Top = 0
        Height = 252
        Beveled = True
        ResizeStyle = rsLine
      end
      object Panel7: TPanel
        Left = 0
        Top = 0
        Width = 283
        Height = 252
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel3'
        TabOrder = 0
        object Bevel3: TBevel
          Left = 0
          Top = 0
          Width = 283
          Height = 23
          Align = alTop
          Shape = bsSpacer
        end
        object Label3: TLabel
          Left = 8
          Top = 5
          Width = 88
          Height = 13
          Caption = #49888#54840' '#48156#49373' '#44592#47197' : '
        end
        object ListEvent: TListView
          Left = 0
          Top = 23
          Width = 283
          Height = 229
          Align = alClient
          Columns = <
            item
              Caption = #48156#49373#49884#44033
              Width = 70
            end
            item
              Caption = #49888#54840#47749
              Width = 70
            end
            item
              Caption = #51452#47928
              Width = 120
            end>
          GridLines = True
          OwnerData = True
          OwnerDraw = True
          ReadOnly = True
          SmallImages = ImageList1
          TabOrder = 0
          ViewStyle = vsReport
          OnData = ListEventData
          OnDrawItem = ListDrawItem
          OnSelectItem = ListLinkSelectItem
        end
      end
      object Panel9: TPanel
        Left = 286
        Top = 0
        Width = 577
        Height = 252
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel6'
        TabOrder = 1
        object Bevel2: TBevel
          Left = 0
          Top = 0
          Width = 577
          Height = 23
          Align = alTop
          Shape = bsSpacer
        end
        object Label2: TLabel
          Left = 8
          Top = 5
          Width = 61
          Height = 13
          Caption = #51452#47928' '#44592#47197' : '
        end
        object ButtonCancelAll: TSpeedButton
          Tag = 100
          Left = 181
          Top = 0
          Width = 132
          Height = 22
          Caption = #51452#47928' '#51204#52404' '#52712#49548'(&X)'
          Flat = True
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlue
          Font.Height = -13
          Font.Name = #44404#47548
          Font.Style = []
          ParentFont = False
          OnClick = ButtonCancelAllClick
        end
        object SpeedButton2: TSpeedButton
          Tag = 10
          Left = 535
          Top = 1
          Width = 23
          Height = 22
          Hint = #51452#47928'/'#52404#44208#45236#50669' '#49688#46041#51312#54924
          Flat = True
          Glyph.Data = {
            36050000424D3605000000000000360400002800000010000000100000000100
            0800000000000001000000000000000000000001000000000000000000000000
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
            FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00070700000000
            000000000000000007070707A4070707070707070707070007070707A4FF07FF
            070207FF07FF070007070707A407FF070202FF07FF07070007070707A4FF0702
            0202020207FF070007070707A407FF070202FF060607070007070707A4FF07FF
            070207FF06FF070007070707A4070607FF07FF070607070007070707A4FF06FF
            070207FF07FF070007070707A4070606FF020207FF07070007070707A4FF0702
            0202020207FF070007070707A4FFFFFFFF020207FF07070007070707A4FFFFFF
            FF0207FF0000000007070707A4FFFFFFFF07FF07A4FF000707070707A4FFFFFF
            FFFFFFFFA400070707070707A4A4A4A4A4A4A4A4A40707070707}
          ParentShowHint = False
          ShowHint = True
          Visible = False
          OnClick = ButtonRecoveryClick
        end
        object ListOrder: TListView
          Left = 0
          Top = 23
          Width = 577
          Height = 229
          Align = alClient
          Columns = <
            item
              Caption = #51452#47928#49884#44033
              Width = 70
            end
            item
              Caption = #49888#54840
              Width = 70
            end
            item
              Caption = #44228#51340
              Width = 70
            end
            item
              Caption = #51333#47785
              Width = 80
            end
            item
              Alignment = taRightJustify
              Caption = #51452#47928
              Width = 40
            end
            item
              Alignment = taRightJustify
              Caption = #51452#47928#44032
              Width = 55
            end
            item
              Alignment = taRightJustify
              Caption = #52404#44208
              Width = 40
            end
            item
              Alignment = taRightJustify
              Caption = #52404#44208#44032
              Width = 55
            end
            item
              Alignment = taRightJustify
              Caption = #49345#53468
              Width = 75
            end>
          GridLines = True
          OwnerData = True
          OwnerDraw = True
          ReadOnly = True
          PopupMenu = PopOrder
          SmallImages = ImageList1
          TabOrder = 0
          ViewStyle = vsReport
          OnData = ListOrderData
          OnDrawItem = ListOrderDrawItem
        end
      end
    end
    object TabSheet1: TTabSheet
      Caption = #47196#44536
      ImageIndex = 3
      object MemoLog: TRichEdit
        Left = 0
        Top = 0
        Width = 863
        Height = 252
        Align = alClient
        Font.Charset = HANGEUL_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
        ParentFont = False
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 437
    Width = 871
    Height = 19
    Panels = <
      item
        Alignment = taCenter
        Text = 'MultiChart'
        Width = 150
      end
      item
        Alignment = taCenter
        Width = 120
      end
      item
        Width = 80
      end
      item
        Width = 200
      end>
  end
  object Panel5: TPanel
    Left = 0
    Top = 0
    Width = 871
    Height = 154
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 871
      Height = 30
      Align = alTop
      BevelInner = bvLowered
      TabOrder = 0
      object ButtonSave: TSpeedButton
        Left = 634
        Top = 4
        Width = 23
        Height = 22
        Hint = #51452#47928#47196#44536' '#51200#51109
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000130B0000130B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333330070
          7700333333337777777733333333008088003333333377F73377333333330088
          88003333333377FFFF7733333333000000003FFFFFFF77777777000000000000
          000077777777777777770FFFFFFF0FFFFFF07F3333337F3333370FFFFFFF0FFF
          FFF07F3FF3FF7FFFFFF70F00F0080CCC9CC07F773773777777770FFFFFFFF039
          99337F3FFFF3F7F777F30F0000F0F09999937F7777373777777F0FFFFFFFF999
          99997F3FF3FFF77777770F00F000003999337F773777773777F30FFFF0FF0339
          99337F3FF7F3733777F30F08F0F0337999337F7737F73F7777330FFFF0039999
          93337FFFF7737777733300000033333333337777773333333333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = ButtonSaveClick
      end
      object ButtonPrint: TSpeedButton
        Left = 659
        Top = 4
        Width = 23
        Height = 22
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000130B0000130B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00300000000000
          00033FFFFFFFFFFFFFFF0888888888888880777777777777777F088888888888
          8880777777777777777F0000000000000000FFFFFFFFFFFFFFFF0F8F8F8F8F8F
          8F80777777777777777F08F8F8F8F8F8F9F0777777777777777F0F8F8F8F8F8F
          8F807777777777777F7F0000000000000000777777777777777F3330FFFFFFFF
          03333337F3FFFF3F7F333330F0000F0F03333337F77773737F333330FFFFFFFF
          03333337F3FF3FFF7F333330F00F000003333337F773777773333330FFFF0FF0
          33333337F3FF7F3733333330F08F0F0333333337F7737F7333333330FFFF0033
          33333337FFFF7733333333300000033333333337777773333333}
        NumGlyphs = 2
        Visible = False
        OnClick = ButtonPrintClick
      end
      object ButtonHelp: TSpeedButton
        Left = 684
        Top = 4
        Width = 23
        Height = 22
        Hint = #46020#50880#47568
        Flat = True
        Glyph.Data = {
          76010000424D7601000000000000760000002800000020000000100000000100
          04000000000000010000120B0000120B00001000000000000000000000000000
          800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF0033333CCCCC33
          33333FFFF77777FFFFFFCCCCCC808CCCCCC3777777F7F777777F008888070888
          8003777777777777777F0F0770F7F0770F0373F33337F333337370FFFFF7FFFF
          F07337F33337F33337F370FFFB99FBFFF07337F33377F33337F330FFBF99BFBF
          F033373F337733333733370BFBF7FBFB0733337F333FF3337F33370FBF98BFBF
          0733337F3377FF337F333B0BFB990BFB03333373FF777FFF73333FB000B99000
          B33333377737777733333BFBFBFB99FBF33333333FF377F333333FBF99BF99BF
          B333333377F377F3333333FB99FB99FB3333333377FF77333333333FB9999FB3
          333333333777733333333333FBFBFB3333333333333333333333}
        NumGlyphs = 2
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = ButtonHelpClick
      end
      object SpeedButton1: TSpeedButton
        Left = 712
        Top = 4
        Width = 23
        Height = 22
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 15908537
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        Visible = False
        OnClick = SpeedButton1Click
      end
      object BtnConfig: TSpeedButton
        Left = 525
        Top = 4
        Width = 63
        Height = 22
        Caption = #49444' '#51221'(&C)'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        OnClick = BtnConfigClick
      end
      object ButtonSync: TSpeedButton
        Left = 429
        Top = 4
        Width = 93
        Height = 22
        Caption = 'MC '#51116#51217#49549'(&R)'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        OnClick = ButtonSyncClick
      end
      object ButtonTarget: TSpeedButton
        Left = 186
        Top = 4
        Width = 115
        Height = 22
        Caption = #49888#54840#54633#44228' '#51201#50857'(&F)'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        OnClick = ButtonTargetClick
      end
      object ButtonClear: TSpeedButton
        Left = 307
        Top = 4
        Width = 97
        Height = 22
        Caption = #54252#51648#49496#52397#49328'(&P)'
        Flat = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
        OnClick = ButtonClearClick
      end
      object ButtonRecovery: TSpeedButton
        Tag = 10
        Left = 606
        Top = 4
        Width = 23
        Height = 22
        Hint = #51452#47928'/'#52404#44208#45236#50669' '#49688#46041#51312#54924
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          0800000000000001000000000000000000000001000000000000000000000000
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
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00070700000000
          000000000000000007070707A4070707070707070707070007070707A4FF07FF
          070207FF07FF070007070707A407FF070202FF07FF07070007070707A4FF0702
          0202020207FF070007070707A407FF070202FF060607070007070707A4FF07FF
          070207FF06FF070007070707A4070607FF07FF070607070007070707A4FF06FF
          070207FF07FF070007070707A4070606FF020207FF07070007070707A4FF0702
          0202020207FF070007070707A4FFFFFFFF020207FF07070007070707A4FFFFFF
          FF0207FF0000000007070707A4FFFFFFFF07FF07A4FF000707070707A4FFFFFF
          FFFFFFFFA400070707070707A4A4A4A4A4A4A4A4A40707070707}
        ParentShowHint = False
        ShowHint = True
        Visible = False
        OnClick = ButtonRecoveryClick
      end
      object CheckOrderConnected: TCheckBox
        Left = 9
        Top = 7
        Width = 78
        Height = 17
        Caption = #51088#46041#51452#47928
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = CheckOrderConnectedClick
      end
      object CheckDetail: TCheckBox
        Left = 93
        Top = 7
        Width = 78
        Height = 17
        Caption = #49345#49464#54364#49884
        TabOrder = 1
        OnClick = CheckDetailClick
      end
    end
    object ListTarget: TListView
      Left = 0
      Top = 30
      Width = 871
      Height = 124
      Align = alClient
      Columns = <
        item
          Caption = #44228#51340
          Width = 150
        end
        item
          Caption = #51333#47785
          Width = 80
        end
        item
          Alignment = taRightJustify
          Caption = #54252#51648#49496
          Width = 55
        end
        item
          Alignment = taRightJustify
          Caption = #54217#44512#45800#44032
          Width = 70
        end
        item
          Alignment = taRightJustify
          Caption = #54788#51116#44032
          Width = 60
        end
        item
          Alignment = taRightJustify
          Caption = #54217#44032#49552#51061
          Width = 90
        end
        item
          Alignment = taRightJustify
          Caption = #47588#46020#51452#47928
          Width = 70
        end
        item
          Alignment = taRightJustify
          Caption = #47588#49688#51452#47928
          Width = 70
        end
        item
          Alignment = taRightJustify
          Caption = #49888#54840#54633#44228
          Width = 70
        end>
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      OwnerData = True
      OwnerDraw = True
      ReadOnly = True
      ParentFont = False
      PopupMenu = PopTarget
      SmallImages = ImageList1
      TabOrder = 1
      ViewStyle = vsReport
      OnData = ListTargetData
      OnDblClick = ListTargetDblClick
      OnDrawItem = ListTargetDrawItem
      OnSelectItem = ListTargetSelectItem
    end
  end
  object PopLink: TPopupMenu
    Left = 220
    Top = 336
    object MenuLinkEdit: TMenuItem
      Tag = 200
      Caption = #49688#51221'(&E)'
      OnClick = PopLinkClick
    end
    object MenuLinkDelete: TMenuItem
      Tag = 300
      Caption = #49325#51228'(&D)'
      OnClick = PopLinkClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object MenuAdd: TMenuItem
      Tag = 100
      Caption = #52628#44032'(&A)'
      OnClick = PopLinkClick
    end
  end
  object PopSignal: TPopupMenu
    Left = 316
    Top = 336
    object MenuSignalEdit: TMenuItem
      Tag = 200
      Caption = #49688#51221'(&E)'
      OnClick = SignalClick
    end
    object MenuSignalDelete: TMenuItem
      Tag = 300
      Caption = #49325#51228'(&D)'
      OnClick = SignalClick
    end
    object MenuItem3: TMenuItem
      Caption = '-'
    end
    object MenuItem4: TMenuItem
      Tag = 100
      Caption = #52628#44032'(&A)'
      OnClick = SignalClick
    end
  end
  object PopTarget: TPopupMenu
    OnPopup = PopTargetPopup
    Left = 260
    Top = 80
    object MenuTargetEdit: TMenuItem
      Tag = 200
      Caption = #49688#51221'(&E)'
      OnClick = PopTargetClick
    end
    object MenuTargetDelete: TMenuItem
      Tag = 300
      Caption = #49325#51228'(&D)'
      OnClick = PopTargetClick
    end
    object MenuItem7: TMenuItem
      Caption = '-'
    end
    object MenuItem8: TMenuItem
      Tag = 100
      Caption = #52628#44032'(&A)'
      OnClick = PopTargetClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object MenuTargetClear: TMenuItem
      Tag = 400
      Caption = #52397#49328'(&C)'
      OnClick = PopTargetClick
    end
  end
  object ClearTimer: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = ClearTimerTimer
    Left = 800
  end
  object PopOrder: TPopupMenu
    OnPopup = PopOrderPopup
    Left = 466
    Top = 245
    object MenuOrder: TMenuItem
      Tag = 100
      Caption = #45800#49692#51452#47928'(&S)'
      OnClick = PopOrderClick
    end
    object MenuEFOrder: TMenuItem
      Tag = 200
      Caption = 'EF'#51452#47928'(&E)'
      OnClick = PopOrderClick
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object MenuAccount: TMenuItem
      Tag = 300
      Caption = #44228#51340#51221#48372'(&A)'
      OnClick = PopOrderClick
    end
    object MenuOrderList: TMenuItem
      Tag = 400
      Caption = #51452#47928#45236#50669'(&L)'
      OnClick = PopOrderClick
    end
    object MenuFillList: TMenuItem
      Tag = 500
      Caption = #52404#44208#45236#50669'(&F)'
      OnClick = PopOrderClick
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object MenuCancel: TMenuItem
      Tag = 600
      Caption = #51452#47928' '#52712#49548'(&X)'
      OnClick = PopOrderClick
    end
  end
  object ImageList1: TImageList
    Height = 14
    Left = 450
    Top = 117
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 800
    Top = 64
  end
end
