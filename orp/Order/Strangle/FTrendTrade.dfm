object FrmTrendTrade: TFrmTrendTrade
  Left = 0
  Top = 0
  Caption = 'Trend'
  ClientHeight = 227
  ClientWidth = 325
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
    Width = 325
    Height = 27
    Align = alTop
    TabOrder = 0
    DesignSize = (
      325
      27)
    object cbAccount: TComboBox
      Left = 4
      Top = 2
      Width = 108
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 277
      Top = 4
      Width = 43
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Run'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object rbF: TRadioButton
      Left = 212
      Top = 4
      Width = 28
      Height = 17
      Caption = 'F'
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = rbFClick
    end
    object rbO: TRadioButton
      Left = 238
      Top = 4
      Width = 28
      Height = 17
      Caption = 'O'
      TabOrder = 3
      OnClick = rbFClick
    end
    object dtStartTime: TDateTimePicker
      Left = 114
      Top = 2
      Width = 95
      Height = 21
      Date = 41717.376388888890000000
      Time = 41717.376388888890000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 4
    end
  end
  object sgTrend1: TStringGrid
    Left = 1
    Top = 53
    Width = 323
    Height = 61
    ColCount = 7
    Ctl3D = False
    DefaultColWidth = 45
    DefaultRowHeight = 19
    RowCount = 3
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 1
  end
  object sgTrend2: TStringGrid
    Left = 1
    Top = 144
    Width = 323
    Height = 61
    ColCount = 7
    Ctl3D = False
    DefaultColWidth = 45
    DefaultRowHeight = 19
    RowCount = 3
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goEditing]
    ParentCtl3D = False
    ScrollBars = ssNone
    TabOrder = 2
  end
  object stBar: TStatusBar
    Left = 0
    Top = 208
    Width = 325
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
    OnDrawPanel = stBarDrawPanel
  end
  object cbTrend1: TCheckBox
    Left = 3
    Top = 32
    Width = 55
    Height = 17
    Caption = #52628#49464'1'
    TabOrder = 4
  end
  object cbTrend2: TCheckBox
    Left = 3
    Top = 121
    Width = 111
    Height = 17
    Caption = #52628#49464'2 ( '#53804#51088#51088' )'
    TabOrder = 5
  end
  object btnApply1: TButton
    Tag = 1
    Left = 283
    Top = 29
    Width = 41
    Height = 22
    Caption = 'apply'
    TabOrder = 6
    OnClick = btnApply1Click
  end
  object Button1: TButton
    Tag = 2
    Left = 283
    Top = 119
    Width = 41
    Height = 22
    Caption = 'apply'
    TabOrder = 7
    OnClick = btnApply1Click
  end
  object Button2: TButton
    Tag = 1
    Left = 237
    Top = 29
    Width = 41
    Height = 22
    Caption = 'default'
    TabOrder = 8
    OnClick = Button2Click
  end
  object Button3: TButton
    Tag = 2
    Left = 237
    Top = 119
    Width = 41
    Height = 22
    Caption = 'default'
    TabOrder = 9
    OnClick = Button2Click
  end
  object edtQty2: TEdit
    Left = 111
    Top = 118
    Width = 27
    Height = 21
    ImeName = 'Microsoft IME 2010'
    TabOrder = 10
    Text = '1'
  end
  object edtQty1: TEdit
    Left = 69
    Top = 29
    Width = 27
    Height = 21
    ImeName = 'Microsoft IME 2010'
    TabOrder = 11
    Text = '2'
  end
  object cbTrend2Stop: TCheckBox
    Left = 160
    Top = 121
    Width = 75
    Height = 17
    Caption = #52628#49464'2'#49828#53457
    TabOrder = 12
  end
  object UpDown1: TUpDown
    Left = 96
    Top = 29
    Width = 16
    Height = 21
    Associate = edtQty1
    Min = 1
    Position = 2
    TabOrder = 13
  end
  object UpDown2: TUpDown
    Left = 138
    Top = 118
    Width = 15
    Height = 21
    Associate = edtQty2
    Min = 1
    Position = 1
    TabOrder = 14
  end
  object dtEndTime: TDateTimePicker
    Left = 114
    Top = 29
    Width = 95
    Height = 21
    Date = 41717.617361111110000000
    Time = 41717.617361111110000000
    ImeName = 'Microsoft IME 2010'
    Kind = dtkTime
    TabOrder = 15
  end
end
