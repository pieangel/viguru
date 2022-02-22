object FrmUsI2: TFrmUsI2
  Left = 0
  Top = 0
  Caption = 'Us_I2'
  ClientHeight = 183
  ClientWidth = 264
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 108
    Top = 148
    Width = 75
    Height = 13
    Caption = #44592#48376#49444#51221' '#49440#53469
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 264
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      264
      29)
    object Button1: TButton
      Left = 190
      Top = 4
      Width = 20
      Height = 21
      Caption = #51333
      TabOrder = 0
      OnClick = Button1Click
    end
    object edtSymbol: TLabeledEdit
      Left = 128
      Top = 4
      Width = 58
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object cbRun: TCheckBox
      Left = 220
      Top = 6
      Width = 42
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 2
      OnClick = cbRunClick
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 3
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 22
      Height = 21
      Caption = #44228
      TabOrder = 4
      OnClick = Button6Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 3
    Top = 30
    Width = 253
    Height = 51
    TabOrder = 1
    object Label2: TLabel
      Left = 6
      Top = 31
      Width = 24
      Height = 13
      Caption = #52397#49328
    end
    object Label4: TLabel
      Left = 134
      Top = 8
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label3: TLabel
      Left = 6
      Top = 8
      Width = 24
      Height = 13
      Caption = #51652#51077
    end
    object dtEnd: TDateTimePicker
      Left = 35
      Top = 28
      Width = 97
      Height = 21
      Date = 42401.621527777780000000
      Time = 42401.621527777780000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtEntend: TDateTimePicker
      Left = 148
      Top = 5
      Width = 97
      Height = 21
      Date = 42401.583333333340000000
      Time = 42401.583333333340000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 1
    end
    object dtEntStart: TDateTimePicker
      Left = 35
      Top = 5
      Width = 97
      Height = 21
      Date = 42401.437500000000000000
      Time = 42401.437500000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 2
    end
    object dtMkStart: TDateTimePicker
      Left = 167
      Top = 28
      Width = 78
      Height = 21
      Date = 42401.375000000000000000
      Time = 42401.375000000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 3
    end
  end
  object cbDefault: TComboBox
    Left = 190
    Top = 144
    Width = 58
    Height = 21
    Style = csDropDownList
    ImeName = 'Microsoft IME 2010'
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 2
    Text = 'US_I2'
    OnChange = cbDefaultChange
    Items.Strings = (
      'US_I2'
      'US_I3')
  end
  object cbStopLiq: TCheckBox
    Left = 8
    Top = 147
    Width = 86
    Height = 17
    Caption = #51333#47308#49884' '#52397#49328
    Checked = True
    State = cbChecked
    TabOrder = 3
    OnClick = cbStopLiqClick
  end
  object GroupBox2: TGroupBox
    Left = 3
    Top = 84
    Width = 253
    Height = 59
    TabOrder = 5
    object Label8: TLabel
      Left = 7
      Top = 36
      Width = 20
      Height = 13
      Caption = 'ATR'
    end
    object edtOrdQty: TLabeledEdit
      Left = 30
      Top = 7
      Width = 23
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51452#47928
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '1'
    end
    object edtChanelIdx: TLabeledEdit
      Left = 115
      Top = 7
      Width = 24
      Height = 21
      Hint = #47588#49688' '#51652#51077' '#44148#49688#48708#50984
      EditLabel.Width = 14
      EditLabel.Height = 13
      EditLabel.Caption = 'CH'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '12'
    end
    object Button2: TButton
      Left = 214
      Top = 32
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 2
      OnClick = Button2Click
    end
    object dtATRLiqStart: TDateTimePicker
      Left = 29
      Top = 32
      Width = 76
      Height = 21
      Date = 42401.590277777780000000
      Time = 42401.590277777780000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 3
    end
    object edtATRPeriod: TLabeledEdit
      Left = 106
      Top = 32
      Width = 21
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 4
      Text = '30'
    end
    object edtATRMulti: TLabeledEdit
      Left = 138
      Top = 32
      Width = 19
      Height = 21
      EditLabel.Width = 6
      EditLabel.Height = 13
      EditLabel.Caption = '*'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 5
      Text = '4'
    end
    object edtTermCnt: TLabeledEdit
      Left = 162
      Top = 32
      Width = 24
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 6
      Text = '36'
    end
    object edtEntryCnt: TLabeledEdit
      Left = 74
      Top = 7
      Width = 22
      Height = 21
      Hint = #52572#45824' '#51652#51077' '#52852#50868#53944
      EditLabel.Width = 17
      EditLabel.Height = 13
      EditLabel.Caption = 'E.C'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = '2'
    end
    object UpDown1: TUpDown
      Left = 139
      Top = 7
      Width = 16
      Height = 21
      Associate = edtChanelIdx
      Min = 1
      Position = 12
      TabOrder = 8
    end
    object edtH: TEdit
      Left = 160
      Top = 7
      Width = 42
      Height = 21
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft Office IME 2007'
      ParentFont = False
      ReadOnly = True
      TabOrder = 9
    end
    object edtL: TEdit
      Left = 205
      Top = 7
      Width = 42
      Height = 21
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft Office IME 2007'
      ParentFont = False
      ReadOnly = True
      TabOrder = 10
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 164
    Width = 264
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 35
      end
      item
        Width = 60
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
    ExplicitTop = 171
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 168
    Top = 128
  end
end
