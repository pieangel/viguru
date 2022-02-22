object BearSetForm: TBearSetForm
  Left = 0
  Top = 0
  Hint = #44148#49688
  Caption = 'Bear System'
  ClientHeight = 285
  ClientWidth = 641
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonAuto: TSpeedButton
    Left = 65
    Top = 8
    Width = 41
    Height = 21
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'Stop'
    OnClick = ButtonAutoClick
  end
  object Label10: TLabel
    Left = 161
    Top = 36
    Width = 24
    Height = 13
    Caption = 'msec'
  end
  object BtnCohesionSymbol: TSpeedButton
    Left = 345
    Top = 8
    Width = 23
    Height = 19
    Caption = '...'
    OnClick = BtnCohesionSymbolClick
  end
  object BtnOrderSymbol: TSpeedButton
    Left = 345
    Top = 33
    Width = 23
    Height = 19
    Caption = '...'
    OnClick = BtnOrderSymbolClick
  end
  object Bevel3: TBevel
    Left = 4
    Top = 110
    Width = 360
    Height = 3
  end
  object Bevel1: TBevel
    Left = 8
    Top = 146
    Width = 117
    Height = 3
  end
  object PaintLog: TPaintBox
    Left = 376
    Top = 11
    Width = 255
    Height = 249
  end
  object ButtonFix: TSpeedButton
    Left = 8
    Top = 8
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
  object ButtonSync: TSpeedButton
    Left = 31
    Top = 8
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
  object ComboAccount: TComboBox
    Left = 112
    Top = 8
    Width = 124
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboAccountChange
  end
  object ComboCohesionSymbol: TComboBox
    Left = 242
    Top = 8
    Width = 100
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboCohesionSymbolChange
  end
  object CheckLongOrder: TCheckBox
    Left = 8
    Top = 35
    Width = 25
    Height = 17
    Hint = #47588#49688#51452#47928
    Caption = 'L'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 2
    OnClick = CheckLongOrderClick
  end
  object CheckShortOrder: TCheckBox
    Left = 39
    Top = 35
    Width = 36
    Height = 17
    Hint = #47588#46020#51452#47928
    Caption = 'S'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 3
    OnClick = CheckShortOrderClick
  end
  object CheckCancelOrder: TCheckBox
    Left = 70
    Top = 34
    Width = 89
    Height = 20
    Caption = 'Cancel'
    TabOrder = 4
    OnClick = CheckCancelOrderClick
  end
  object editCancelTime: TEdit
    Left = 124
    Top = 33
    Width = 33
    Height = 21
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    TabOrder = 5
    Text = '1000'
    OnChange = OnEditboxChange
  end
  object ComboOrderSymbol: TComboBox
    Left = 242
    Top = 33
    Width = 100
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    ItemHeight = 13
    TabOrder = 6
    OnChange = ComboOrderSymbolChange
  end
  object EditCohesionFilter: TEdit
    Left = 4
    Top = 60
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#49688#47049#54596#53552
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Text = '10'
    OnChange = OnEditboxChange
  end
  object EditCohesionPeriod: TEdit
    Left = 44
    Top = 60
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#50672#49549#49884#44036'(msec)'
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 8
    Text = '500'
    OnChange = OnEditboxChange
  end
  object EditCohesionTotQty: TEdit
    Left = 83
    Top = 60
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#52509#49688#47049
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 9
    Text = '50'
    OnChange = OnEditboxChange
  end
  object EditCohesionCnt: TEdit
    Left = 4
    Top = 85
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#44148#49688
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    Text = '2'
    OnChange = OnEditboxChange
  end
  object EditCohesionQuoteLevel: TEdit
    Left = 44
    Top = 85
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#54840#44032
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    Text = '1'
    OnChange = OnEditboxChange
  end
  object EditCohesionAvgPrice: TEdit
    Left = 83
    Top = 85
    Width = 38
    Height = 21
    Hint = #51025#51665#51333#47785' '#44032#44201#52264
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 12
    Text = '0.04'
    OnChange = OnEditboxChange
  end
  object EditOrderCollectionPeriod: TEdit
    Left = 4
    Top = 119
    Width = 38
    Height = 21
    Hint = #51452#47928#51333#47785' '#49688#51665#49884#44036'(msec)'
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 13
    Text = '2000'
    OnChange = OnEditboxChange
  end
  object EditOrderQuoteLevel: TEdit
    Left = 44
    Top = 119
    Width = 38
    Height = 21
    Hint = #51452#47928#51333#47785' '#54840#44032
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 14
    Text = '1'
    OnChange = OnEditboxChange
  end
  object EditOrderFilter: TEdit
    Left = 83
    Top = 119
    Width = 38
    Height = 21
    Hint = #51452#47928#51333#47785' '#49688#47049#54596#53552
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 15
    Text = '10'
    OnChange = OnEditboxChange
  end
  object EditOrderQty: TEdit
    Left = 129
    Top = 60
    Width = 40
    Height = 21
    Hint = #51452#47928#49688#47049
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 16
    Text = '50'
    OnChange = OnEditboxChange
  end
  object EditMaxPosition: TEdit
    Left = 172
    Top = 60
    Width = 40
    Height = 21
    Hint = #54252#51648#49496#54620#46020
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 17
    Text = '20'
    OnChange = OnEditboxChange
  end
  object CheckSaveCohesion: TCheckBox
    Left = 4
    Top = 154
    Width = 117
    Height = 17
    Caption = #51025#51665' '#45936#51060#53552' '#51200#51109' '
    Checked = True
    State = cbChecked
    TabOrder = 18
    OnClick = CheckSaveCohesionClick
  end
  object GridInfo: TStringGrid
    Left = 147
    Top = 119
    Width = 201
    Height = 105
    ColCount = 3
    FixedCols = 0
    RowCount = 4
    FixedRows = 0
    ScrollBars = ssNone
    TabOrder = 19
  end
  object TabConfig: TTabControl
    Left = 8
    Top = 238
    Width = 319
    Height = 26
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    Style = tsButtons
    TabOrder = 20
    Tabs.Strings = (
      'C1'
      'C2'
      'C3'
      'C4'
      'C5'
      'C6'
      'C7')
    TabIndex = 0
    OnChange = TabConfigChange
  end
  object StatusTrade: TStatusBar
    Left = 0
    Top = 266
    Width = 641
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object EditMaxQuoteQty: TEdit
    Left = 214
    Top = 60
    Width = 40
    Height = 21
    Hint = #52572#45824#54840#44032#51092#47049
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 22
    Text = '1000'
    OnChange = OnEditboxChange
  end
  object CheckSaveOrder: TCheckBox
    Left = 4
    Top = 175
    Width = 117
    Height = 17
    Caption = #50896#52380' '#45936#51060#53552' '#51200#51109' '
    Checked = True
    State = cbChecked
    TabOrder = 23
    OnClick = CheckSaveOrderClick
  end
  object CheckSaveCollection: TCheckBox
    Left = 4
    Top = 198
    Width = 117
    Height = 17
    Caption = #51452#47928' '#45936#51060#53552' '#51200#51109' '
    Checked = True
    State = cbChecked
    TabOrder = 24
    OnClick = CheckSaveCollectionClick
  end
  object EditOrderQuoteTime: TEdit
    Left = 233
    Top = 83
    Width = 40
    Height = 21
    Hint = #51452#47928#49884#44036'(msec)'
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 25
    Text = '100'
    OnChange = OnEditboxChange
  end
  object CheckOrderQuoteTime: TCheckBox
    Left = 129
    Top = 87
    Width = 98
    Height = 17
    Hint = #51452#47928#54840#44032#49884#44036
    Caption = #51452#47928#54840#44032#49884#44036
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 26
    OnClick = CheckLongOrderClick
  end
  object CheckQuoteJamSkip: TCheckBox
    Left = 263
    Top = 60
    Width = 68
    Height = 17
    Hint = #51452#47928#54840#44032#49884#44036
    Caption = #51648#50672'skip'
    Checked = True
    ParentShowHint = False
    ShowHint = True
    State = cbChecked
    TabOrder = 27
    OnClick = CheckQuoteJamSkipClick
  end
  object EditQuoteJamSkipTime: TEdit
    Left = 326
    Top = 58
    Width = 40
    Height = 21
    Hint = #51648#50672#49884#44036'(msec)'
    ImeName = 'Microsoft IME 2003'
    ParentShowHint = False
    ShowHint = True
    TabOrder = 28
    Text = '3000'
    OnChange = OnEditboxChange
  end
end
