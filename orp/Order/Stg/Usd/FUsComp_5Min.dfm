object FrmUsComp: TFrmUsComp
  Left = 0
  Top = 0
  Caption = 'Us_Comp(5Min)'
  ClientHeight = 160
  ClientWidth = 258
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
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 258
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      258
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
      Left = 214
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
    object Label1: TLabel
      Left = 138
      Top = 31
      Width = 24
      Height = 13
      Caption = #51333#47308
    end
    object dtEnd: TDateTimePicker
      Left = 168
      Top = 26
      Width = 77
      Height = 21
      Date = 42401.600694444450000000
      Time = 42401.600694444450000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtEntend: TDateTimePicker
      Left = 149
      Top = 5
      Width = 96
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
      Width = 95
      Height = 21
      Date = 42401.437500000000000000
      Time = 42401.437500000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 2
    end
    object dtLiqStart: TDateTimePicker
      Left = 35
      Top = 27
      Width = 78
      Height = 21
      Date = 42401.562500000000000000
      Time = 42401.562500000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 3
    end
  end
  object GroupBox2: TGroupBox
    Left = 3
    Top = 81
    Width = 253
    Height = 56
    TabOrder = 3
    object Label8: TLabel
      Left = 3
      Top = 36
      Width = 24
      Height = 13
      Caption = #49552#51208
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
    object Button2: TButton
      Left = 214
      Top = 7
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 1
      OnClick = Button2Click
    end
    object edtEntPer: TLabeledEdit
      Left = 30
      Top = 32
      Width = 38
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 2
      Text = '0.004'
    end
    object edtE_C: TLabeledEdit
      Left = 123
      Top = 7
      Width = 29
      Height = 21
      EditLabel.Width = 19
      EditLabel.Height = 13
      EditLabel.Caption = 'E_C'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 3
      Text = '0.7'
    end
    object edtE_S: TLabeledEdit
      Left = 181
      Top = 7
      Width = 28
      Height = 21
      EditLabel.Width = 18
      EditLabel.Height = 13
      EditLabel.Caption = 'E_S'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 4
      Text = '1'
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
      TabOrder = 5
      Text = '2'
    end
    object cbStopLiq: TCheckBox
      Left = 158
      Top = 34
      Width = 50
      Height = 17
      Caption = #51333#52397
      Checked = True
      State = cbChecked
      TabOrder = 6
      OnClick = cbStopLiqClick
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 141
    Width = 258
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 35
      end
      item
        Width = 90
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 168
    Top = 128
  end
end
