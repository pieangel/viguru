object OrderForm: TOrderForm
  Left = 586
  Top = 275
  BorderStyle = bsDialog
  Caption = 'Order'
  ClientHeight = 268
  ClientWidth = 321
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDesigned
  Visible = True
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 42
    Top = 41
    Width = 43
    Height = 13
    Caption = 'Account:'
  end
  object Label2: TLabel
    Left = 47
    Top = 66
    Width = 38
    Height = 13
    Caption = 'Symbol:'
  end
  object ButtonSymbol: TSpeedButton
    Left = 285
    Top = 61
    Width = 23
    Height = 22
    Hint = 'A'#190#184'n'#188#177'AA'
    Caption = '...'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -16
    Font.Name = #177#188#184#178
    Font.Style = []
    ParentFont = False
    ParentShowHint = False
    ShowHint = True
    OnClick = ButtonSymbolClick
  end
  object Label3: TLabel
    Left = 47
    Top = 115
    Width = 38
    Height = 13
    Caption = 'Volume:'
  end
  object LabelPrice: TLabel
    Left = 58
    Top = 167
    Width = 27
    Height = 13
    Caption = 'Price:'
  end
  object LabelPriceType: TLabel
    Left = 20
    Top = 142
    Width = 65
    Height = 13
    Caption = 'Price Control:'
  end
  object LabelFillType: TLabel
    Left = 8
    Top = 194
    Width = 77
    Height = 13
    Caption = 'Time-to-Market:'
    Enabled = False
  end
  object LabelOrgOrder: TLabel
    Left = 49
    Top = 90
    Width = 36
    Height = 13
    Caption = 'Target:'
  end
  object LabelPriceRange: TLabel
    Left = 178
    Top = 167
    Width = 26
    Height = 13
    Caption = '.. - ..'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelFillTypeDesc: TLabel
    Left = 506
    Top = 318
    Width = 12
    Height = 13
    Caption = '...'
    Visible = False
  end
  object ButtonUpdate: TSpeedButton
    Left = 252
    Top = 85
    Width = 56
    Height = 22
    Caption = '&Update'
    Flat = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    OnClick = ButtonUpdateClick
  end
  object SpeedReset: TSpeedButton
    Left = 245
    Top = 5
    Width = 28
    Height = 27
    AllowAllUp = True
    GroupIndex = 1
    Glyph.Data = {
      360C0000424D360C000000000000360000002800000040000000100000000100
      180000000000000C0000120B0000120B00000000000000000000008080008080
      0080800080800080800080800000000000000000000000000000000080800080
      8000808000808000808039B05E39B05E39B05E39B05E39B05EFFFFFF7F7F7F7F
      7F7F7F7F7F7F7F7F7F7F7F39B05EFFFFFFFFFFFF39B05E39B05E008080008080
      008080008080008080FFFFFF7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F008080FFFF
      FFFFFFFF00808000808039B05E39B05E39B05E39B05E39B05E39B05E00000000
      000000000000000000000039B05E39B05E39B05E39B05E39B05E008080008080
      008080008080000000000000BFBFBFBFBFBFBFBFBFBFBFBFBFBFBF0000000000
      0000808000808000808039B05E39B05E39B05E39B05E7F7F7F7F7F7F39B05E39
      B05E39B05EFFFFFF39B05E7F7F7F7F7F7F39B05EFFFFFF39B05E008080008080
      0080800080807F7F7F7F7F7F008080008080008080FFFFFF0080807F7F7F7F7F
      7F008080FFFFFF00808039B05E39B05E39B05E39B05E000000000000BFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBF00000000000039B05E39B05E39B05E008080008080
      0080800000007F7F7F7F7F7FBFBFBF7F7F7F0000007F7F7FBFBFBF7F7F7F7F7F
      7F00000000808000808039B05E39B05E39B05E7F7F7F39B05E39B05E39B05E39
      B05E7F7F7FFFFFFF39B05E39B05E39B05E7F7F7F39B05EFFFFFF008080008080
      0080807F7F7F0080800080800080800080807F7F7FFFFFFF0080800080800080
      807F7F7F008080FFFFFF39B05E39B05E39B05E0000007F7F7F7F7F7FBFBFBF7F
      7F7F0000007F7F7FBFBFBF7F7F7F7F7F7F00000039B05E39B05E008080008080
      000000BFBFBFBFBFBFBFBFBFBFBFBF7F7F7F0000007F7F7FBFBFBFBFBFBFBFBF
      BFBFBFBF00000000808039B05E39B05E7F7F7FFFFFFF39B05E39B05E39B05E39
      B05E7F7F7FFFFFFF39B05E39B05E39B05E39B05E7F7F7FFFFFFF008080008080
      7F7F7FFFFFFF0080800080800080800080807F7F7FFFFFFF0080800080800080
      800080807F7F7FFFFFFF39B05E39B05E000000BFBFBFBFBFBFBFBFBFBFBFBF7F
      7F7F0000007F7F7FBFBFBFBFBFBFBFBFBFBFBFBF00000039B05E008080008080
      0000007F7F7F7F7F7F7F7F7FBFBFBFBFBFBF000000BFBFBFBFBFBF7F7F7F7F7F
      7F7F7F7F00000000808039B05E39B05E7F7F7FFFFFFF39B05E39B05E39B05E39
      B05E7F7F7FFFFFFFFFFFFF39B05E39B05E39B05E7F7F7FFFFFFF008080008080
      7F7F7FFFFFFF0080800080800080800080807F7F7FFFFFFFFFFFFF0080800080
      800080807F7F7FFFFFFF39B05E39B05E0000007F7F7F7F7F7F7F7F7FBFBFBFBF
      BFBF000000BFBFBFBFBFBF7F7F7F7F7F7F7F7F7F00000039B05E008080008080
      000000BFBFBFBFBFBFBFBFBFBFBFBF000000000000000000BFBFBFBFBFBFBFBF
      BFBFBFBF00000000808039B05E39B05E7F7F7FFFFFFF39B05E39B05E39B05E7F
      7F7F7F7F7F7F7F7FFFFFFF39B05E39B05E39B05E7F7F7FFFFFFF008080008080
      7F7F7FFFFFFF0080800080800080807F7F7F7F7F7F7F7F7FFFFFFF0080800080
      800080807F7F7FFFFFFF39B05E39B05E000000BFBFBFBFBFBFBFBFBFBFBFBF00
      0000000000000000BFBFBFBFBFBFBFBFBFBFBFBF00000039B05E008080008080
      0000007F7F7F7F7F7F7F7F7F7F7F7F0000000000000000007F7F7F7F7F7F7F7F
      7F7F7F7F00000000808039B05E39B05E7F7F7FFFFFFF39B05E39B05E39B05E7F
      7F7F7F7F7F7F7F7F39B05E39B05E39B05E39B05E7F7F7FFFFFFF008080008080
      7F7F7FFFFFFF0080800080800080807F7F7F7F7F7F7F7F7F0080800080800080
      800080807F7F7FFFFFFF39B05E39B05E0000007F7F7F7F7F7F7F7F7F7F7F7F00
      00000000000000007F7F7F7F7F7F7F7F7F7F7F7F00000039B05E00FFFF008080
      000000BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBF00000000808039B05E39B05E7F7F7F39B05EFFFFFFFFFFFFFFFFFFFF
      FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF7F7F7F39B05E008080008080
      7F7F7F008080FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
      FFFFFFFF7F7F7F00808039B05E39B05E000000BFBFBFBFBFBFBFBFBFBFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBFBF00000039B05E00808000FFFF
      0080800000000000000000000000000000000000000000000000000000000000
      0000000000808000808039B05E39B05E39B05E7F7F7F7F7F7F7F7F7F7F7F7F7F
      7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F39B05E39B05E008080008080
      0080807F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F7F
      7F7F7F7F00808000808039B05E39B05E39B05E00000000000000000000000000
      000000000000000000000000000000000000000039B05E39B05E008080008080
      00FFFF00FFFF00FFFF00FFFF008080008080008080008080000000BFBFBF0000
      0000808000808000808039B05E39B05E39B05E39B05E7F7F7FFFFFFF7F7F7FFF
      FFFF39B05E39B05E7F7F7FFFFFFF7F7F7FFFFFFF39B05E39B05E008080008080
      008080008080008080008080FFFFFF0080800080800080807F7F7FFFFFFF7F7F
      7FFFFFFF00808000808039B05E39B05E39B05E39B05E000000BFBFBF00000039
      B05E39B05E39B05E000000BFBFBF00000039B05E39B05E39B05E00FFFF00FFFF
      00FFFF00FFFF7F7F7F0000007F7F7F00FFFF00FFFF008080000000BFBFBF0000
      0000808000808000808039B05E39B05E39B05E39B05E7F7F7FFFFFFF7F7F7FFF
      FFFF39B05E39B05E7F7F7FFFFFFF7F7F7FFFFFFF39B05E39B05E008080008080
      0080800080800080807F7F7F008080FFFFFF0080800080807F7F7FFFFFFF7F7F
      7FFFFFFF00808000808039B05E39B05E39B05E39B05E000000BFBFBF00000039
      B05E39B05E39B05E000000BFBFBF00000039B05E39B05E39B05E008080008080
      00FFFF00FFFF000000BFBFBF000000008080008080008080000000BFBFBF0000
      0000808000808000808039B05E39B05E39B05E39B05E7F7F7FFFFFFF7F7F7F39
      B05EFFFFFFFFFFFF7F7F7F39B05E7F7F7FFFFFFF39B05E39B05E008080008080
      0080800080807F7F7FFFFFFF7F7F7FFFFFFF0080800080807F7F7FFFFFFF7F7F
      7FFFFFFF00808000808039B05E39B05E39B05E39B05E000000BFBFBF00000039
      B05E39B05E39B05E000000BFBFBF00000039B05E39B05E39B05E00808000FFFF
      00808000FFFF000000BFBFBF000000008080008080008080000000BFBFBF0000
      0000808000808000808039B05E39B05E39B05E39B05E7F7F7F39B05EFFFFFF7F
      7F7F7F7F7F7F7F7F39B05E39B05E7F7F7F39B05E39B05E39B05E008080008080
      0080800080807F7F7FFFFFFF7F7F7F008080FFFFFFFFFFFF7F7F7F0080807F7F
      7FFFFFFF00808000808039B05E39B05E39B05E39B05E7F7F7F7F7F7FBFBFBF00
      0000000000000000BFBFBF7F7F7F7F7F7F39B05E39B05E39B05E00FFFF008080
      00808000FFFF7F7F7F7F7F7FBFBFBF000000000000000000BFBFBF7F7F7F7F7F
      7F00808000808000808039B05E39B05E39B05E39B05E39B05E7F7F7F39B05EFF
      FFFFFFFFFFFFFFFFFFFFFF7F7F7F39B05E39B05E39B05E39B05E008080008080
      0080800080807F7F7F008080FFFFFF7F7F7F7F7F7F7F7F7F0080800080807F7F
      7F00808000808000808039B05E39B05E39B05E39B05E39B05E000000BFBFBFBF
      BFBFBFBFBFBFBFBFBFBFBF00000039B05E39B05E39B05E39B05E008080008080
      00808000FFFF008080000000BFBFBFBFBFBFBFBFBFBFBFBFBFBFBF0000000080
      8000808000808000808039B05E39B05E39B05E39B05E39B05E39B05E7F7F7F7F
      7F7F7F7F7F7F7F7F7F7F7F39B05E39B05E39B05E39B05E39B05E008080008080
      0080800080800080807F7F7F008080FFFFFFFFFFFFFFFFFFFFFFFF7F7F7F0080
      8000808000808000808039B05E39B05E39B05E39B05E39B05E39B05E00000000
      000000000000000000000039B05E39B05E39B05E39B05E39B05E008080008080
      00808000FFFF0080800080800000000000000000000000000000000080800080
      8000808000808000808039B05E39B05E39B05E39B05E39B05E39B05E39B05E39
      B05E39B05E39B05E39B05E39B05E39B05E39B05E39B05E39B05E008080008080
      0080800080800080800080807F7F7F7F7F7F7F7F7F7F7F7F7F7F7F0080800080
      8000808000808000808039B05E39B05E39B05E39B05E39B05E39B05E39B05E39
      B05E39B05E39B05E39B05E39B05E39B05E39B05E39B05E39B05E}
    NumGlyphs = 4
    ParentShowHint = False
    ShowHint = True
  end
  object ButtonHelp: TSpeedButton
    Left = 279
    Top = 5
    Width = 29
    Height = 27
    AllowAllUp = True
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
  end
  object TabOrderType: TTabControl
    Left = 8
    Top = 8
    Width = 224
    Height = 24
    Style = tsFlatButtons
    TabOrder = 0
    Tabs.Strings = (
      'Buy'
      'Sell'
      'Change'
      'Cancel')
    TabIndex = 0
    TabWidth = 40
    OnChange = TabOrderTypeChange
  end
  object ComboAccount: TComboBox
    Left = 91
    Top = 38
    Width = 219
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = 'CN'#177#185#190'i(CN'#177'U)'
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboAccountChange
  end
  object StatusMsg: TStatusBar
    Left = 0
    Top = 249
    Width = 321
    Height = 19
    Panels = <>
    SimplePanel = True
  end
  object ComboSymbol: TComboBox
    Left = 91
    Top = 63
    Width = 192
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = 'CN'#177#185#190'i(CN'#177'U)'
    ItemHeight = 13
    TabOrder = 2
    OnChange = ComboSymbolChange
  end
  object EditVolume: TEdit
    Left = 91
    Top = 112
    Width = 78
    Height = 21
    ImeName = 'Korean Input System (IME 2000)'
    TabOrder = 4
    Text = '0'
  end
  object ButtonSend: TButton
    Left = 104
    Top = 220
    Width = 85
    Height = 22
    Hint = 'Send an order'
    Caption = '&Send'
    Default = True
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    OnClick = ButtonSendClick
  end
  object ButtonCancel: TButton
    Left = 195
    Top = 220
    Width = 75
    Height = 22
    Hint = 'Cancel'
    Caption = '&Cancel'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    OnClick = ButtonCancelClick
  end
  object EditPrice: TEdit
    Left = 91
    Top = 164
    Width = 78
    Height = 21
    ImeName = 'CN'#177#185#190'i(CN'#177'U)'
    TabOrder = 5
    Text = '0.0'
  end
  object ComboPriceControl: TComboBox
    Left = 91
    Top = 139
    Width = 217
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = 'Korean Input System (IME 2000)'
    ItemHeight = 13
    TabOrder = 6
    OnChange = ComboPriceControlChange
    Items.Strings = (
      'Limit'
      'Market'
      'Limit to Market'
      'Limit at the best price')
  end
  object ComboTimeToMarket: TComboBox
    Left = 91
    Top = 191
    Width = 217
    Height = 19
    Style = csOwnerDrawFixed
    Enabled = False
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ItemHeight = 13
    TabOrder = 7
    Items.Strings = (
      'Good till canceled'
      'Fill or Kill'
      'Immediate or Canceled'
      'All or None')
  end
  object ComboTargetOrder: TComboBox
    Left = 91
    Top = 87
    Width = 162
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = 'Korean Input System (IME 2000)'
    ItemHeight = 13
    TabOrder = 3
    OnChange = ComboTargetOrderChange
  end
end