object FrmUsIn123: TFrmUsIn123
  Left = 0
  Top = 0
  Caption = 'US_IN_123'
  ClientHeight = 255
  ClientWidth = 261
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label5: TLabel
    Left = 108
    Top = 214
    Width = 69
    Height = 13
    Caption = #44592#48376#49444#51221' '#49440#53469
  end
  object Label6: TLabel
    AlignWithMargins = True
    Left = 8
    Top = 235
    Width = 255
    Height = 13
    AutoSize = False
    Caption = #51092#44256'|'#44148#49688#48708'|'#51652#51077#54924#49688', MaxOpePL,NowOpenPL,PL'
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 261
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      261
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
      Left = 217
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
      Width = 22
      Height = 13
      Caption = #52397#49328
    end
    object Label1: TLabel
      Left = 134
      Top = 31
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label4: TLabel
      Left = 134
      Top = 7
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label3: TLabel
      Left = 6
      Top = 8
      Width = 22
      Height = 13
      Caption = #51652#51077
    end
    object dtEnd: TDateTimePicker
      Left = 35
      Top = 27
      Width = 97
      Height = 21
      Date = 42401.626388888900000000
      Time = 42401.626388888900000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtEntend: TDateTimePicker
      Left = 148
      Top = 4
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
      Top = 4
      Width = 97
      Height = 21
      Date = 42401.377083333330000000
      Time = 42401.377083333330000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 2
    end
    object Button2: TButton
      Left = 212
      Top = 27
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 3
    Top = 80
    Width = 253
    Height = 99
    TabOrder = 2
    object Bevel1: TBevel
      Left = 5
      Top = 48
      Width = 243
      Height = 2
    end
    object edtOrdQty: TLabeledEdit
      Left = 35
      Top = 4
      Width = 23
      Height = 21
      EditLabel.Width = 22
      EditLabel.Height = 13
      EditLabel.Caption = #51452#47928
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '1'
      OnKeyPress = edtEntryCntKeyPress
    end
    object edtE_L: TLabeledEdit
      Left = 95
      Top = 4
      Width = 30
      Height = 21
      Hint = #47588#49688' '#51652#51077' '#44148#49688#48708#50984
      EditLabel.Width = 17
      EditLabel.Height = 13
      EditLabel.Caption = 'E_L'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '0.7'
      OnKeyPress = edtE_LKeyPress
    end
    object edtE_S: TLabeledEdit
      Left = 153
      Top = 4
      Width = 35
      Height = 21
      Hint = #47588#46020' '#51652#51077' '#44148#49688#48708#50984
      EditLabel.Width = 18
      EditLabel.Height = 13
      EditLabel.Caption = 'E_S'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '0.7'
      OnKeyPress = edtE_LKeyPress
    end
    object edtL1_S: TLabeledEdit
      Left = 180
      Top = 53
      Width = 35
      Height = 21
      Hint = #47588#46020' '#49552#51208' '#44148#49688#48708#50984
      EditLabel.Width = 17
      EditLabel.Height = 13
      EditLabel.Caption = 'L_S'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '0.9'
      OnKeyPress = edtE_LKeyPress
    end
    object edtL1_L: TLabeledEdit
      Left = 122
      Top = 53
      Width = 30
      Height = 21
      Hint = #47588#49688' '#49552#51208' '#44148#49688' '#48708#50984
      EditLabel.Width = 16
      EditLabel.Height = 13
      EditLabel.Caption = 'L_L'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '0.9'
      OnKeyPress = edtE_LKeyPress
    end
    object edtL2_L: TLabeledEdit
      Left = 122
      Top = 76
      Width = 30
      Height = 21
      Hint = #47588#49688' '#49552#51208' '#44148#49688' '#48708#50984
      EditLabel.Width = 22
      EditLabel.Height = 13
      EditLabel.Caption = 'L2_L'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Text = '0.8'
      OnKeyPress = edtE_LKeyPress
    end
    object edtL2_S: TLabeledEdit
      Left = 180
      Top = 75
      Width = 35
      Height = 21
      Hint = #47588#46020' '#49552#51208' '#44148#49688#48708#50984
      EditLabel.Width = 23
      EditLabel.Height = 13
      EditLabel.Caption = 'L2_S'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '0.8'
      OnKeyPress = edtE_LKeyPress
    end
    object cbSecondLiqCon: TCheckBox
      Left = 12
      Top = 79
      Width = 69
      Height = 17
      Hint = #51652#51077'2'#54924#51060#49345#48512#53552#51032' '#49552#51208#51312#44148
      Caption = '2'#54924#48512#53552
      Checked = True
      ParentShowHint = False
      ShowHint = True
      State = cbChecked
      TabOrder = 7
      OnClick = cbSecondLiqConClick
    end
    object cbEntFilter: TCheckBox
      Left = 12
      Top = 28
      Width = 45
      Height = 17
      Hint = #50896#45804#47084#44148#49688#54596#53552
      Caption = #44148#54596
      ParentShowHint = False
      ShowHint = True
      TabOrder = 8
      OnClick = cbEntFilterClick
    end
    object cbEntFilter2: TCheckBox
      Left = 196
      Top = 28
      Width = 52
      Height = 17
      Hint = #49884#44032#50752' '#51333#44032' '#48708#44368
      Caption = #54596#53552'2'
      ParentShowHint = False
      ShowHint = True
      TabOrder = 9
      OnClick = cbEntFilter2Click
    end
    object edtCntFilter: TLabeledEdit
      Left = 57
      Top = 26
      Width = 30
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 10
      Text = '0.85'
      OnKeyPress = edtE_LKeyPress
    end
    object cbEntVolFilter: TCheckBox
      Left = 106
      Top = 28
      Width = 45
      Height = 17
      Hint = #50896#45804#47084#51092#47049#54596#53552
      Caption = #51092#54596
      ParentShowHint = False
      ShowHint = True
      TabOrder = 11
      OnClick = cbEntVolFilterClick
    end
    object edtVolFilter: TLabeledEdit
      Left = 153
      Top = 26
      Width = 30
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 12
      Text = '0.85'
      OnKeyPress = edtE_LKeyPress
    end
    object edtEntryCnt: TLabeledEdit
      Left = 220
      Top = 4
      Width = 23
      Height = 21
      Hint = #52572#45824' '#51652#51077' '#52852#50868#53944
      EditLabel.Width = 17
      EditLabel.Height = 13
      EditLabel.Caption = 'E.C'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 13
      Text = '4'
      OnKeyPress = edtEntryCntKeyPress
    end
    object cbLossVolFillter: TCheckBox
      Left = 12
      Top = 55
      Width = 43
      Height = 17
      Hint = #49552#51208#49884' '#50896#45804#47084#51092#47049#54596#53552
      Caption = #51092#54596
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 14
      Visible = False
      OnClick = cbLossVolFillterClick
    end
    object edtLossVolFillter: TLabeledEdit
      Left = 57
      Top = 53
      Width = 30
      Height = 21
      Hint = #49552#51208#49884' '#50896#45804#47084#51092#47049#48708#50984
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      Enabled = False
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 15
      Text = '0.9'
      Visible = False
      OnKeyPress = edtE_LKeyPress
    end
  end
  object GroupBox3: TGroupBox
    Left = 3
    Top = 179
    Width = 253
    Height = 31
    TabOrder = 3
    object cbTrailingStop: TCheckBox
      Left = 5
      Top = 7
      Width = 76
      Height = 17
      Caption = 'trailing stop'
      TabOrder = 0
      OnClick = cbTrailingStopClick
    end
    object edtStopMax: TLabeledEdit
      Left = 110
      Top = 5
      Width = 44
      Height = 21
      EditLabel.Width = 22
      EditLabel.Height = 13
      EditLabel.Caption = #49552#51061
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '50000'
      OnKeyPress = edtEntryCntKeyPress
    end
    object edtStopPer: TLabeledEdit
      Left = 156
      Top = 4
      Width = 29
      Height = 21
      EditLabel.Width = 11
      EditLabel.Height = 13
      EditLabel.Caption = '%'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '30'
      OnKeyPress = edtEntryCntKeyPress
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 236
    Width = 261
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 40
      end
      item
        Width = 40
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
  end
  object cbDefault: TComboBox
    Left = 190
    Top = 210
    Width = 66
    Height = 21
    Style = csDropDownList
    ImeName = 'Microsoft IME 2010'
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 5
    Text = 'US_IN1'
    OnChange = cbDefaultChange
    Items.Strings = (
      'US_IN1'
      'US_IN2'
      'US_IN3')
  end
  object cbStopLiq: TCheckBox
    Left = 8
    Top = 212
    Width = 86
    Height = 17
    Caption = #51333#47308#49884' '#52397#49328
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = cbStopLiqClick
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 256
    Top = 72
  end
end
