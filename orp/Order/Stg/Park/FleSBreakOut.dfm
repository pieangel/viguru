object FrmSBreakOut: TFrmSBreakOut
  Left = 0
  Top = 0
  Caption = 'Only Short'
  ClientHeight = 161
  ClientWidth = 265
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
    Width = 265
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      265
      29)
    object cbRun: TCheckBox
      Left = 219
      Top = 6
      Width = 39
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 0
      OnClick = cbRunClick
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 22
      Height = 21
      Caption = #44228
      TabOrder = 1
      OnClick = Button6Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 2
    end
    object stSymbol: TStaticText
      Left = 130
      Top = 5
      Width = 61
      Height = 19
      AutoSize = False
      BevelInner = bvSpace
      BevelOuter = bvNone
      BorderStyle = sbsSunken
      TabOrder = 3
    end
    object Button1: TButton
      Left = 195
      Top = 4
      Width = 22
      Height = 21
      Caption = #51333
      TabOrder = 4
      Visible = False
      OnClick = Button1Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 1
    Top = 29
    Width = 261
    Height = 83
    TabOrder = 1
    object Label2: TLabel
      Left = 102
      Top = 11
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label1: TLabel
      Left = 66
      Top = 61
      Width = 11
      Height = 13
      Caption = '%'
    end
    object dtEnd: TDateTimePicker
      Left = 117
      Top = 8
      Width = 93
      Height = 21
      Date = 42401.648611111110000000
      Time = 42401.648611111110000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtStart: TDateTimePicker
      Left = 3
      Top = 8
      Width = 95
      Height = 21
      Date = 42401.375347222220000000
      Time = 42401.375347222220000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 1
    end
    object edtEntryCnt: TLabeledEdit
      Left = 223
      Top = 32
      Width = 23
      Height = 21
      Hint = #51652#51077' '#54924#49688
      EditLabel.Width = 13
      EditLabel.Height = 13
      EditLabel.Caption = 'EC'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '2'
    end
    object edtBelowPrc: TLabeledEdit
      Left = 66
      Top = 32
      Width = 30
      Height = 21
      Hint = #51060#49345
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51060#54616
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '2.0'
    end
    object Button2: TButton
      Left = 216
      Top = 8
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 4
      OnClick = Button2Click
    end
    object edtBasePrc: TLabeledEdit
      Left = 127
      Top = 32
      Width = 28
      Height = 21
      Hint = #50640' '#44032#51109' '#44032#44620#50868
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = #44032#44620#50868
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpRight
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      Text = '1.5'
    end
    object edtOrdQty: TLabeledEdit
      Left = 31
      Top = 32
      Width = 31
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51452#47928
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 6
      Text = '1'
    end
    object edtLCPer: TLabeledEdit
      Left = 31
      Top = 57
      Width = 30
      Height = 21
      Hint = #47588#46020' '#51652#51077' '#44148#49688#48708#50984
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #49552#51208
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
      Text = '40'
    end
    object cbStopLiq: TCheckBox
      Left = 87
      Top = 60
      Width = 86
      Height = 17
      Caption = #51333#47308#49884#52397#49328
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = cbStopLiqClick
    end
    object dtMorning: TDateTimePicker
      Left = 175
      Top = 56
      Width = 77
      Height = 21
      Date = 42401.397222222220000000
      Time = 42401.397222222220000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 9
    end
  end
  object sgLog: TStringGrid
    Left = 1
    Top = 113
    Width = 260
    Height = 154
    ColCount = 2
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 3
    ColWidths = (
      55
      187)
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 142
    Width = 265
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 30
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
    OnTimer = Timer1Timer
    Left = 8
    Top = 6
  end
end
