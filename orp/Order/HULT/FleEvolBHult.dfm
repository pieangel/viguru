object FrmEvolBHult: TFrmEvolBHult
  Left = 0
  Top = 0
  Caption = #48152#54736#53944
  ClientHeight = 259
  ClientWidth = 293
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 293
    Height = 27
    Align = alTop
    TabOrder = 0
    DesignSize = (
      293
      27)
    object cbAccount: TComboBox
      Left = 4
      Top = 2
      Width = 115
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 248
      Top = 5
      Width = 43
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Run'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object cbAccount2: TComboBox
      Left = 125
      Top = 2
      Width = 115
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbAccount2Change
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 240
    Width = 293
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 293
    Height = 131
    Align = alTop
    TabOrder = 2
    object dtStartTime: TDateTimePicker
      Left = 194
      Top = 6
      Width = 91
      Height = 21
      Date = 41717.375694444450000000
      Time = 41717.375694444450000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 0
    end
    object dtEndTime: TDateTimePicker
      Left = 194
      Top = 28
      Width = 91
      Height = 21
      Date = 41717.625000000000000000
      Time = 41717.625000000000000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 1
    end
    object sgCon: TStringGrid
      Left = 4
      Top = 6
      Width = 185
      Height = 121
      ColCount = 4
      Ctl3D = False
      DefaultColWidth = 45
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 6
      ParentCtl3D = False
      TabOrder = 2
    end
    object Button1: TButton
      Left = 194
      Top = 73
      Width = 39
      Height = 20
      Caption = #54200#51665
      TabOrder = 3
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 246
      Top = 73
      Width = 39
      Height = 20
      Caption = #51201#50857
      TabOrder = 4
      OnClick = Button2Click
    end
    object edtRowCnt: TEdit
      Tag = 1
      Left = 244
      Top = 50
      Width = 26
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 5
      Text = '4'
      OnChange = edtRowCntChange
      OnKeyPress = edtRowCntKeyPress
    end
    object udRowCnt: TUpDown
      Left = 270
      Top = 50
      Width = 15
      Height = 21
      Associate = edtRowCnt
      Min = 1
      Max = 5
      Position = 4
      TabOrder = 6
    end
    object edtEntryCnt: TEdit
      Left = 194
      Top = 50
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 7
      Text = '2'
      OnChange = edtRowCntChange
      OnKeyPress = edtRowCntKeyPress
    end
    object udEntryCnt: TUpDown
      Left = 221
      Top = 50
      Width = 15
      Height = 21
      Associate = edtEntryCnt
      Min = 1
      Max = 3
      Position = 2
      TabOrder = 8
    end
    object edtSymbol: TEdit
      Left = 193
      Top = 105
      Width = 67
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 9
    end
    object Button3: TButton
      Left = 263
      Top = 105
      Width = 22
      Height = 21
      Caption = '..'
      TabOrder = 10
      OnClick = Button3Click
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 158
    Width = 293
    Height = 82
    Align = alClient
    Caption = 'Panel3'
    TabOrder = 3
    object sgOrd: TStringGrid
      Left = 1
      Top = 1
      Width = 291
      Height = 80
      Align = alClient
      ColCount = 6
      Ctl3D = False
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 0
      ColWidths = (
        65
        59
        37
        31
        31
        49)
    end
  end
  object Timer1: TTimer
    Interval = 500
    OnTimer = Timer1Timer
    Left = 232
    Top = 192
  end
end
