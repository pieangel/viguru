object FrmUsH1: TFrmUsH1
  Left = 0
  Top = 0
  Caption = 'TR_US_123'
  ClientHeight = 230
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
    Top = 188
    Width = 47
    Height = 13
    Caption = #49444#51221' '#49440#53469
  end
  object Label6: TLabel
    AlignWithMargins = True
    Left = 8
    Top = 211
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
      Left = 215
      Top = 7
      Width = 42
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 2
      OnClick = cbRunClick
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 22
      Height = 21
      Caption = #44228
      TabOrder = 3
      OnClick = Button6Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 4
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
      Date = 42401.621527777780000000
      Time = 42401.621527777780000000
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
      Date = 42401.611111111110000000
      Time = 42401.611111111110000000
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
      Date = 42401.451388888890000000
      Time = 42401.451388888890000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 2
    end
    object Button2: TButton
      Left = 213
      Top = 27
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 3
      OnClick = Button2Click
    end
  end
  object GroupBox3: TGroupBox
    Left = 3
    Top = 151
    Width = 253
    Height = 31
    TabOrder = 2
    object cbTrailingStop: TCheckBox
      Left = 5
      Top = 7
      Width = 76
      Height = 17
      Caption = 'trailing stop'
      Checked = True
      State = cbChecked
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
    end
    object edtStopPer: TLabeledEdit
      Left = 156
      Top = 5
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
    end
    object edtEntPer: TLabeledEdit
      Left = 210
      Top = 5
      Width = 39
      Height = 21
      Hint = #51652#51077#44032' '#45824#48708
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '0.003'
    end
  end
  object GroupBox2: TGroupBox
    Left = 3
    Top = 82
    Width = 253
    Height = 71
    TabOrder = 3
    object Label9: TLabel
      Left = 44
      Top = 29
      Width = 22
      Height = 13
      Caption = #51652#51077
    end
    object Label10: TLabel
      Left = 43
      Top = 49
      Width = 22
      Height = 13
      Caption = #49552#51208
    end
    object edtOrdQty: TLabeledEdit
      Left = 5
      Top = 23
      Width = 21
      Height = 21
      Hint = #51452#47928#49688#47049
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = '1'
    end
    object edtEntryCnt: TLabeledEdit
      Left = 5
      Top = 45
      Width = 21
      Height = 21
      Hint = #52572#45824' '#51652#51077' '#52852#50868#53944
      EditLabel.Width = 6
      EditLabel.Height = 13
      EditLabel.Caption = '  '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '2'
    end
    object Panel1: TPanel
      Left = 68
      Top = 8
      Width = 92
      Height = 60
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      TabOrder = 2
      object Label7: TLabel
        Left = 30
        Top = 2
        Width = 45
        Height = 13
        Caption = 'L  '#44148#49688'  S'
      end
      object edtE_L: TLabeledEdit
        Left = 21
        Top = 16
        Width = 30
        Height = 21
        Hint = #47588#49688' '#51652#51077' '#44148#49688#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '0.65'
        OnKeyPress = edtE_LKeyPress
      end
      object edtL1_L: TLabeledEdit
        Left = 21
        Top = 38
        Width = 30
        Height = 21
        Hint = #47588#49688' '#49552#51208' '#44148#49688' '#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '1'
        OnKeyPress = edtE_LKeyPress
      end
      object edtE_S: TLabeledEdit
        Left = 52
        Top = 16
        Width = 35
        Height = 21
        Hint = #47588#46020' '#51652#51077' '#44148#49688#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '0.65'
        OnKeyPress = edtE_LKeyPress
      end
      object edtL1_S: TLabeledEdit
        Left = 52
        Top = 38
        Width = 35
        Height = 21
        Hint = #47588#46020' '#49552#51208' '#44148#49688#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '1'
        OnKeyPress = edtE_LKeyPress
      end
      object cbEntCnt: TCheckBox
        Left = 3
        Top = 19
        Width = 16
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object cbLossCnt: TCheckBox
        Left = 3
        Top = 40
        Width = 16
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
    end
    object Panel2: TPanel
      Left = 163
      Top = 8
      Width = 88
      Height = 60
      BevelOuter = bvNone
      Color = clCream
      ParentBackground = False
      TabOrder = 3
      object Label8: TLabel
        Left = 27
        Top = 2
        Width = 45
        Height = 13
        Caption = 'L  '#51092#47049'  S'
      end
      object edtE_L2: TLabeledEdit
        Left = 19
        Top = 16
        Width = 30
        Height = 21
        Hint = #47588#49688' '#51652#51077' '#51092#47049#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '0.9'
        OnKeyPress = edtE_LKeyPress
      end
      object edtL_L2: TLabeledEdit
        Left = 19
        Top = 38
        Width = 30
        Height = 21
        Hint = #47588#49688' '#49552#51208' '#51092#47049' '#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '1'
        OnKeyPress = edtE_LKeyPress
      end
      object edtE_S2: TLabeledEdit
        Left = 51
        Top = 16
        Width = 35
        Height = 21
        Hint = #47588#46020' '#51652#51077' '#51092#47049#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '0.9'
        OnKeyPress = edtE_LKeyPress
      end
      object edtL_S2: TLabeledEdit
        Left = 51
        Top = 38
        Width = 35
        Height = 21
        Hint = #47588#46020' '#49552#51208' '#51092#47049#48708#50984
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '1'
        OnKeyPress = edtE_LKeyPress
      end
      object cbEntVol: TCheckBox
        Left = 3
        Top = 19
        Width = 16
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 4
      end
      object cbLossVol: TCheckBox
        Left = 3
        Top = 40
        Width = 16
        Height = 17
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
    end
  end
  object cbDefault: TComboBox
    Left = 163
    Top = 184
    Width = 93
    Height = 21
    Style = csDropDownList
    ImeName = 'Microsoft IME 2010'
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 4
    Text = 'TR_US1'
    OnChange = cbDefaultChange
    Items.Strings = (
      'TR_US1'
      'TR_US2'
      'TR_US3')
  end
  object cbStopLiq: TCheckBox
    Left = 8
    Top = 186
    Width = 86
    Height = 17
    Caption = #51333#47308#49884' '#52397#49328
    Checked = True
    State = cbChecked
    TabOrder = 6
    OnClick = cbStopLiqClick
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 211
    Width = 261
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 40
      end
      item
        Width = 80
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 160
    Top = 228
  end
end
