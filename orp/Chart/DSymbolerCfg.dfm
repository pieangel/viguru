object SymbolerConfig: TSymbolerConfig
  Left = 411
  Top = 193
  BorderStyle = bsDialog
  Caption = #52320#53944' '#51333#47785' '#49444#51221
  ClientHeight = 509
  ClientWidth = 306
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 12
    Width = 38
    Height = 13
    Caption = #51333#47785' : '
  end
  object ButtonSymbol: TSpeedButton
    Left = 265
    Top = 6
    Width = 23
    Height = 22
    Caption = '...'
    Flat = True
    OnClick = ButtonSymbolClick
  end
  object ComboSymbols: TComboBox
    Left = 49
    Top = 7
    Width = 209
    Height = 19
    Style = csOwnerDrawFixed
    ImeName = #54620#44397#50612'('#54620#44544')'
    ItemHeight = 13
    TabOrder = 0
    OnChange = ComboSymbolsChange
  end
  object GroupCompression: TGroupBox
    Left = 10
    Top = 39
    Width = 189
    Height = 153
    Caption = #45800#50948
    TabOrder = 1
    object Label2: TLabel
      Left = 16
      Top = 24
      Width = 4
      Height = 13
    end
    object LabelTerms: TLabel
      Left = 112
      Top = 13
      Width = 57
      Height = 13
      Caption = #45800#50948'('#48516') :'
    end
    object Bevel1: TBevel
      Left = 100
      Top = 23
      Width = 2
      Height = 113
    end
    object RadioTick: TRadioButton
      Left = 16
      Top = 16
      Width = 81
      Height = 17
      Caption = 'Tick Bar'
      TabOrder = 0
      OnClick = RadioTickClick
    end
    object RadioMin: TRadioButton
      Left = 16
      Top = 37
      Width = 81
      Height = 17
      Caption = 'Intra-day'
      TabOrder = 1
    end
    object EditPeriod: TEdit
      Left = 114
      Top = 32
      Width = 63
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544')'
      TabOrder = 2
      Text = '1'
    end
    object RadioDaily: TRadioButton
      Left = 16
      Top = 83
      Width = 81
      Height = 17
      Caption = 'Daily'
      TabOrder = 3
    end
    object RadioWeekly: TRadioButton
      Left = 16
      Top = 107
      Width = 81
      Height = 17
      Caption = 'Weekly'
      TabOrder = 4
    end
    object RadioMonthly: TRadioButton
      Left = 16
      Top = 129
      Width = 81
      Height = 17
      Caption = 'Monthly '
      TabOrder = 5
    end
    object RadioQuote: TRadioButton
      Left = 16
      Top = 60
      Width = 66
      Height = 17
      Caption = 'Quote'
      TabOrder = 6
      OnClick = RadioTickClick
    end
    object GroupBox3: TGroupBox
      Left = 102
      Top = 58
      Width = 85
      Height = 89
      TabOrder = 7
      object Label3: TLabel
        Left = 57
        Top = 67
        Width = 26
        Height = 13
        Caption = #51068#51204
      end
      object rdbData: TRadioButton
        Left = 3
        Top = 3
        Width = 61
        Height = 17
        Caption = #51088#47308#49688
        TabOrder = 0
      end
      object EditCount: TEdit
        Left = 12
        Top = 22
        Width = 63
        Height = 21
        ImeName = #54620#44397#50612'('#54620#44544')'
        MaxLength = 4
        TabOrder = 1
        Text = '300'
      end
      object rdbPast: TRadioButton
        Left = 1
        Top = 44
        Width = 82
        Height = 17
        Caption = #44284#44144#45936#51060#53552
        Checked = True
        TabOrder = 2
        TabStop = True
      end
      object cbPast: TComboBox
        Left = 12
        Top = 64
        Width = 42
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = '0'
        Items.Strings = (
          '0'
          '1'
          '2'
          '3'
          '4'
          '5'
          '6'
          '7'
          '8'
          '9'
          '10'
          '11'
          '12'
          '13'
          '14'
          '15'
          '16'
          '17'
          '18'
          '19'
          '20'
          '21'
          '22'
          '23'
          '24'
          '25'
          '26'
          '27'
          '28'
          '29'
          '30')
      end
    end
  end
  object RadioStyle: TRadioGroup
    Left = 13
    Top = 198
    Width = 117
    Height = 81
    Caption = #52320#53944#54805#53468
    ItemIndex = 1
    Items.Strings = (
      'OHLC Bar'
      'Candlestick'
      'Line ')
    TabOrder = 2
    OnClick = RadioStyleClick
  end
  object GroupBox2: TGroupBox
    Left = 212
    Top = 90
    Width = 77
    Height = 102
    Caption = #49353
    TabOrder = 3
    object Label5: TLabel
      Left = 16
      Top = 24
      Width = 4
      Height = 13
    end
    object PaintColor: TPaintBox
      Left = 13
      Top = 24
      Width = 50
      Height = 33
      OnPaint = PaintColorPaint
    end
    object ButtonChangeColor: TSpeedButton
      Left = 8
      Top = 72
      Width = 65
      Height = 22
      Caption = #48320#44221'(&C)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonChangeColorClick
    end
  end
  object ButtonOK: TButton
    Left = 51
    Top = 475
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    Default = True
    TabOrder = 4
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 132
    Top = 475
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    TabOrder = 5
    OnClick = ButtonCancelClick
  end
  object Button1: TButton
    Left = 213
    Top = 475
    Width = 75
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    TabOrder = 6
  end
  object GroupBox1: TGroupBox
    Left = 136
    Top = 199
    Width = 153
    Height = 82
    Caption = #52629#51201
    TabOrder = 7
    object RadioScaleScreen: TRadioButton
      Left = 8
      Top = 15
      Width = 137
      Height = 17
      Caption = #54868#47732#45800#50948' '#52572#45824'/'#52572#49548
      TabOrder = 0
    end
    object RadioScaleEntire: TRadioButton
      Left = 8
      Top = 37
      Width = 113
      Height = 17
      Caption = #51204#52404' '#52572#45824' '#52572#49548
      TabOrder = 1
    end
    object RadioScaleSymbol: TRadioButton
      Left = 8
      Top = 59
      Width = 137
      Height = 17
      Caption = #51333#47785' '#44536#47000#54532#50752' '#44057#44172
      TabOrder = 2
    end
  end
  object GroupPosition: TGroupBox
    Left = 10
    Top = 334
    Width = 279
    Height = 43
    Caption = #44536#47000#54532' '#50948#52824
    TabOrder = 8
    object RadioMainGraph: TRadioButton
      Left = 8
      Top = 19
      Width = 89
      Height = 17
      Caption = #44592#48376' '#44536#47000#54532
      TabOrder = 0
      OnClick = RadioMainGraphClick
    end
    object RadioSubGraph: TRadioButton
      Left = 132
      Top = 19
      Width = 89
      Height = 17
      Caption = #48512#49549' '#44536#47000#54532
      TabOrder = 1
      OnClick = RadioMainGraphClick
    end
  end
  object CheckFill: TCheckBox
    Left = 214
    Top = 53
    Width = 81
    Height = 17
    Caption = #52404#44208' '#54364#49884
    TabOrder = 9
  end
  object RadioYRateType: TRadioGroup
    Left = 12
    Top = 285
    Width = 279
    Height = 43
    Caption = 'Y'#52629' '#48708#50984
    Columns = 2
    ItemIndex = 0
    Items.Strings = (
      #44592#48376
      #44057#51008#48708#50984)
    TabOrder = 10
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 383
    Width = 280
    Height = 83
    Caption = #48372#44592
    TabOrder = 11
    object ButtonGridColor: TSpeedButton
      Left = 190
      Top = -7
      Width = 77
      Height = 17
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Visible = False
      OnClick = ButtonGridColorClick
    end
    object SpeedButton1: TSpeedButton
      Tag = 1
      Left = 190
      Top = 11
      Width = 77
      Height = 17
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      Visible = False
      OnClick = ButtonGridColorClick
    end
    object SpeedButton2: TSpeedButton
      Tag = 2
      Left = 170
      Top = 20
      Width = 77
      Height = 17
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonGridColorClick
    end
    object SpeedButton3: TSpeedButton
      Tag = 3
      Left = 170
      Top = 39
      Width = 77
      Height = 17
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonGridColorClick
    end
    object SpeedButton4: TSpeedButton
      Tag = 4
      Left = 170
      Top = 59
      Width = 77
      Height = 17
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonGridColorClick
    end
    object ckHighLine: TCheckBox
      Left = 28
      Top = -7
      Width = 57
      Height = 17
      Caption = #44256#44032
      TabOrder = 0
      Visible = False
    end
    object ckLowLine: TCheckBox
      Tag = 1
      Left = 28
      Top = 11
      Width = 76
      Height = 17
      Caption = #51200#44032
      TabOrder = 1
      Visible = False
    end
    object ckRlHighLine: TCheckBox
      Tag = 2
      Left = 8
      Top = 20
      Width = 91
      Height = 17
      Caption = #49345#45824#50900#44256#44032
      TabOrder = 2
    end
    object ckRlLowLine: TCheckBox
      Tag = 3
      Left = 8
      Top = 39
      Width = 91
      Height = 17
      Caption = #49345#45824#50900#51200#44032
      TabOrder = 3
    end
    object ckCustom: TCheckBox
      Left = 8
      Top = 59
      Width = 97
      Height = 17
      Caption = #49324#50857#51088#51648#51221
      TabOrder = 4
    end
    object edtCustom: TEdit
      Left = 96
      Top = 56
      Width = 51
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = 'edtCustom'
    end
  end
  object ColorDialog: TColorDialog
    Left = 264
    Top = 168
  end
end
