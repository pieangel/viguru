object FraMain: TFraMain
  Left = 0
  Top = 0
  Width = 173
  Height = 711
  TabOrder = 0
  object Label1: TLabel
    Left = 11
    Top = 69
    Width = 35
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Qty'
  end
  object Label2: TLabel
    Left = 11
    Top = 99
    Width = 34
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'Slice'
  end
  object Label3: TLabel
    Left = 112
    Top = 531
    Width = 35
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 's_pre'
  end
  object Label4: TLabel
    Left = 24
    Top = 561
    Width = 35
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = 'l_pre'
  end
  object cbAll: TCheckBox
    Left = 33
    Top = 9
    Width = 105
    Height = 17
    Caption = #47784#46160#52712#49548'N'#52397#49328
    TabOrder = 0
    OnClick = cbAllClick
  end
  object btnSymbol: TButton
    Left = 6
    Top = 32
    Width = 61
    Height = 25
    Caption = #51333#47785#48320#44221
    TabOrder = 1
    OnClick = btnSymbolClick
  end
  object plCode: TPanel
    Left = 71
    Top = 32
    Width = 88
    Height = 25
    BevelInner = bvLowered
    TabOrder = 2
  end
  object edtQty: TEdit
    Left = 47
    Top = 65
    Width = 41
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 3
    Text = '0'
    OnKeyPress = edtQtyKeyPress
  end
  object udQty: TUpDown
    Left = 88
    Top = 65
    Width = 15
    Height = 21
    Associate = edtQty
    Max = 5000
    TabOrder = 4
  end
  object btnQty: TButton
    Left = 107
    Top = 65
    Width = 46
    Height = 24
    Caption = 'apply'
    TabOrder = 5
    OnClick = btnQtyClick
  end
  object edtSlice: TEdit
    Left = 47
    Top = 95
    Width = 41
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 6
    Text = '0'
    OnKeyPress = edtQtyKeyPress
  end
  object udSlice: TUpDown
    Left = 88
    Top = 95
    Width = 15
    Height = 21
    Associate = edtSlice
    Max = 99
    TabOrder = 7
  end
  object btnSlice: TButton
    Tag = 1
    Left = 108
    Top = 95
    Width = 46
    Height = 24
    Caption = 'apply'
    TabOrder = 8
    OnClick = btnQtyClick
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 122
    Width = 165
    Height = 210
    TabOrder = 9
    object Panel1: TPanel
      Left = 30
      Top = 10
      Width = 105
      Height = 25
      BevelInner = bvLowered
      Caption = 'RESTRICT'
      TabOrder = 0
    end
    object cbBid1limit: TCheckBox
      Left = 85
      Top = 122
      Width = 31
      Height = 17
      Caption = '1'
      TabOrder = 1
      OnClick = cbBid1limitClick
    end
    object cbBid2limit: TCheckBox
      Tag = 1
      Left = 95
      Top = 139
      Width = 31
      Height = 17
      Caption = '2'
      TabOrder = 2
      OnClick = cbBid1limitClick
    end
    object cbBid3limit: TCheckBox
      Tag = 2
      Left = 106
      Top = 155
      Width = 31
      Height = 17
      Caption = '3'
      TabOrder = 3
      OnClick = cbBid1limitClick
    end
    object cbBid4limit: TCheckBox
      Tag = 3
      Left = 116
      Top = 172
      Width = 31
      Height = 17
      Caption = '4'
      TabOrder = 4
      OnClick = cbBid1limitClick
    end
    object cbBid5limit: TCheckBox
      Tag = 4
      Left = 125
      Top = 188
      Width = 31
      Height = 17
      Caption = '5'
      TabOrder = 5
      OnClick = cbBid1limitClick
    end
    object cbAsk1limit: TCheckBox
      Left = 52
      Top = 104
      Width = 31
      Height = 17
      Alignment = taLeftJustify
      Caption = '1'
      TabOrder = 6
      OnClick = cbAsk1limitClick
    end
    object cbAsk2limit: TCheckBox
      Tag = 1
      Left = 43
      Top = 87
      Width = 31
      Height = 17
      Alignment = taLeftJustify
      Caption = '2'
      TabOrder = 7
      OnClick = cbAsk1limitClick
    end
    object cbAsk3limit: TCheckBox
      Tag = 2
      Left = 33
      Top = 71
      Width = 31
      Height = 17
      Alignment = taLeftJustify
      Caption = '3'
      TabOrder = 8
      OnClick = cbAsk1limitClick
    end
    object cbAsk4limit: TCheckBox
      Tag = 3
      Left = 22
      Top = 57
      Width = 31
      Height = 14
      Alignment = taLeftJustify
      Caption = '4'
      TabOrder = 9
      OnClick = cbAsk1limitClick
    end
    object cbAsk5limit: TCheckBox
      Tag = 4
      Left = 12
      Top = 39
      Width = 31
      Height = 17
      Alignment = taLeftJustify
      Caption = '5'
      TabOrder = 10
      OnClick = cbAsk1limitClick
    end
    object btnBidCnl: TButton
      Tag = 1
      Left = 129
      Top = 122
      Width = 27
      Height = 17
      Caption = '->'
      TabOrder = 11
      OnClick = btnAskCnlClick
    end
    object btnAskCnl: TButton
      Left = 7
      Top = 104
      Width = 27
      Height = 17
      Caption = '<-'
      TabOrder = 12
      OnClick = btnAskCnlClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 4
    Top = 332
    Width = 165
    Height = 189
    TabOrder = 10
    object Panel2: TPanel
      Left = 30
      Top = 10
      Width = 105
      Height = 25
      BevelInner = bvLowered
      Caption = 'ADJUST'
      TabOrder = 0
    end
    object btnAsk345: TButton
      Tag = 2
      Left = 7
      Top = 39
      Width = 57
      Height = 25
      Caption = '3  4  5'
      TabOrder = 1
      OnClick = btnAsk1Click
    end
    object btnAsk2: TButton
      Tag = 1
      Left = 22
      Top = 69
      Width = 41
      Height = 25
      Caption = '2'
      TabOrder = 2
      OnClick = btnAsk1Click
    end
    object btnAsk1: TButton
      Left = 37
      Top = 99
      Width = 26
      Height = 25
      Caption = '1'
      TabOrder = 3
      OnClick = btnAsk1Click
    end
    object btnBid345: TButton
      Tag = 2
      Left = 100
      Top = 156
      Width = 57
      Height = 25
      Caption = '3  4  5'
      TabOrder = 4
      OnClick = btnBid1Click
    end
    object btnBid2: TButton
      Tag = 1
      Left = 100
      Top = 128
      Width = 41
      Height = 25
      Caption = '2'
      TabOrder = 5
      OnClick = btnBid1Click
    end
    object btnBid1: TButton
      Left = 100
      Top = 99
      Width = 26
      Height = 25
      Caption = '1'
      TabOrder = 6
      OnClick = btnBid1Click
    end
  end
  object edtAskPre: TEdit
    Left = 50
    Top = 527
    Width = 41
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 11
    Text = '0'
    OnKeyPress = edtQtyKeyPress
  end
  object upAskPre: TUpDown
    Left = 91
    Top = 527
    Width = 15
    Height = 21
    Associate = edtAskPre
    Max = 5000
    TabOrder = 12
  end
  object btnAskPre: TButton
    Tag = 2
    Left = 4
    Top = 527
    Width = 46
    Height = 24
    Caption = 'apply'
    TabOrder = 13
    OnClick = btnQtyClick
  end
  object btnBidPre: TButton
    Tag = 3
    Left = 123
    Top = 557
    Width = 46
    Height = 24
    Caption = 'apply'
    TabOrder = 14
    OnClick = btnQtyClick
  end
  object edtBidPre: TEdit
    Left = 65
    Top = 557
    Width = 41
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 15
    Text = '0'
    OnKeyPress = edtQtyKeyPress
  end
  object udBidPre: TUpDown
    Left = 106
    Top = 557
    Width = 15
    Height = 21
    Associate = edtBidPre
    Max = 5000
    TabOrder = 16
  end
  object GroupBox3: TGroupBox
    Left = 4
    Top = 581
    Width = 165
    Height = 39
    TabOrder = 17
    object Label5: TLabel
      Left = 8
      Top = 15
      Width = 60
      Height = 17
      Alignment = taCenter
      AutoSize = False
      Caption = 'delayAfford'
    end
    object edtDelay: TEdit
      Left = 69
      Top = 10
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
      Text = '300'
      OnKeyPress = edtQtyKeyPress
    end
    object btnDelay: TButton
      Tag = 4
      Left = 112
      Top = 10
      Width = 46
      Height = 24
      Caption = 'apply'
      TabOrder = 1
      OnClick = btnQtyClick
    end
  end
  object plWinRate2: TPanel
    Left = 4
    Top = 650
    Width = 165
    Height = 25
    BevelInner = bvLowered
    TabOrder = 18
  end
  object plWinRate1: TPanel
    Left = 4
    Top = 623
    Width = 165
    Height = 25
    BevelInner = bvLowered
    TabOrder = 19
  end
  object btnStop: TButton
    Left = 4
    Top = 680
    Width = 46
    Height = 24
    Caption = #49884#51089
    TabOrder = 20
    OnClick = btnStopClick
  end
  object plSymbol1: TPanel
    Left = 51
    Top = 680
    Width = 55
    Height = 24
    BevelInner = bvLowered
    TabOrder = 21
  end
  object plSymbol2: TPanel
    Left = 107
    Top = 680
    Width = 62
    Height = 24
    BevelInner = bvLowered
    TabOrder = 22
  end
end
