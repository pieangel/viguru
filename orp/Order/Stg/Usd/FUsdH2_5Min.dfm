object FrmUsH2: TFrmUsH2
  Left = 0
  Top = 0
  Caption = 'US_H2_5Min'
  ClientHeight = 324
  ClientWidth = 257
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
  object Label8: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 285
    Width = 255
    Height = 13
    AutoSize = False
    Caption = #51092#44256' |'#44148#49688#48708'  | '#51652#51077#54924#49688', '#54217#44032#49552#51061',  '#54788#51116#49552#51061
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 257
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      257
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
      Left = 213
      Top = 6
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
    Left = 0
    Top = 29
    Width = 249
    Height = 97
    TabOrder = 1
    object Label2: TLabel
      Left = 6
      Top = 6
      Width = 24
      Height = 13
      Caption = #49884#44036
    end
    object Label1: TLabel
      Left = 135
      Top = 6
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label4: TLabel
      Left = 135
      Top = 29
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label6: TLabel
      Left = 135
      Top = 51
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label3: TLabel
      Left = 7
      Top = 30
      Width = 24
      Height = 13
      Caption = #51652#51077
    end
    object Label5: TLabel
      Left = 6
      Top = 52
      Width = 24
      Height = 13
      Caption = #52397#49328
    end
    object Label7: TLabel
      Left = 6
      Top = 76
      Width = 36
      Height = 13
      Caption = #51116#51652#51077
    end
    object dtStart: TDateTimePicker
      Left = 36
      Top = 4
      Width = 97
      Height = 21
      Date = 42401.375000000000000000
      Time = 42401.375000000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtEnd: TDateTimePicker
      Left = 149
      Top = 4
      Width = 97
      Height = 21
      Date = 42401.621527777780000000
      Time = 42401.621527777780000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 1
    end
    object dtLiqEnd: TDateTimePicker
      Left = 149
      Top = 48
      Width = 97
      Height = 21
      Date = 42401.611111111110000000
      Time = 42401.611111111110000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 2
    end
    object dtEntend: TDateTimePicker
      Left = 149
      Top = 26
      Width = 97
      Height = 21
      Date = 42401.520833333340000000
      Time = 42401.520833333340000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 3
    end
    object dtEntStart: TDateTimePicker
      Left = 36
      Top = 26
      Width = 97
      Height = 21
      Date = 42401.378125000000000000
      Time = 42401.378125000000000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 4
    end
    object dtLiqStart: TDateTimePicker
      Left = 36
      Top = 48
      Width = 97
      Height = 21
      Date = 42401.541666666660000000
      Time = 42401.541666666660000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 5
    end
    object edtBongStart: TLabeledEdit
      Left = 107
      Top = 72
      Width = 26
      Height = 21
      EditLabel.Width = 52
      EditLabel.Height = 13
      EditLabel.Caption = 'BongIndex'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 6
      Text = '6'
      OnKeyPress = edtBongStartKeyPress
    end
    object edtBongEnd: TLabeledEdit
      Left = 149
      Top = 72
      Width = 26
      Height = 21
      EditLabel.Width = 11
      EditLabel.Height = 13
      EditLabel.Caption = '~ '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 7
      Text = '60'
      OnKeyPress = edtBongStartKeyPress
    end
    object Button3: TButton
      Left = 212
      Top = 70
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 8
      OnClick = Button3Click
    end
  end
  object GroupBox2: TGroupBox
    Left = 0
    Top = 128
    Width = 249
    Height = 56
    TabOrder = 2
    object edtOrdQty: TLabeledEdit
      Left = 35
      Top = 5
      Width = 23
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = #51452#47928
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '1'
      OnKeyPress = edtBongStartKeyPress
    end
    object edtE1: TLabeledEdit
      Left = 76
      Top = 5
      Width = 30
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = 'E1'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 1
      Text = '3.3'
      OnKeyPress = edtE1KeyPress
    end
    object edtE2: TLabeledEdit
      Left = 125
      Top = 5
      Width = 35
      Height = 21
      EditLabel.Width = 12
      EditLabel.Height = 13
      EditLabel.Caption = 'E2'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 2
      Text = '0.7'
      OnKeyPress = edtE1KeyPress
    end
    object edtR1: TLabeledEdit
      Left = 181
      Top = 5
      Width = 29
      Height = 21
      EditLabel.Width = 7
      EditLabel.Height = 13
      EditLabel.Caption = 'R'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 3
      Text = '0.8'
      OnKeyPress = edtE1KeyPress
    end
    object edtL2: TLabeledEdit
      Left = 188
      Top = 32
      Width = 50
      Height = 21
      EditLabel.Width = 11
      EditLabel.Height = 13
      EditLabel.Caption = 'L2'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 4
      Text = '0.0055'
      OnKeyPress = edtE1KeyPress
    end
    object edtL1: TLabeledEdit
      Left = 121
      Top = 32
      Width = 50
      Height = 21
      EditLabel.Width = 11
      EditLabel.Height = 13
      EditLabel.Caption = 'L1'
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 5
      Text = '0.0055'
      OnKeyPress = edtE1KeyPress
    end
    object Button2: TButton
      Left = 215
      Top = 4
      Width = 31
      Height = 21
      Caption = #51201#50857
      TabOrder = 6
      OnClick = Button2Click
    end
    object cbStopLiq: TCheckBox
      Left = 8
      Top = 34
      Width = 45
      Height = 17
      Caption = #51333#52397
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = cbStopLiqClick
    end
    object cbEntFilter: TCheckBox
      Left = 58
      Top = 34
      Width = 45
      Height = 17
      Caption = #54596#53552
      Checked = True
      State = cbChecked
      TabOrder = 8
      OnClick = cbEntFilterClick
    end
  end
  object sgLog: TStringGrid
    Left = 0
    Top = 187
    Width = 263
    Height = 43
    ColCount = 4
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    FixedRows = 0
    TabOrder = 3
  end
  object sg: TStringGrid
    Left = 0
    Top = 236
    Width = 263
    Height = 43
    ColCount = 4
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    FixedRows = 0
    TabOrder = 4
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 305
    Width = 257
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
    ExplicitTop = 302
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 256
    Top = 72
  end
end
