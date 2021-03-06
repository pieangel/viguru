object FrmTrendTrade: TFrmTrendTrade
  Left = 0
  Top = 0
  Caption = 'Trend'
  ClientHeight = 310
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 337
    Height = 27
    Align = alTop
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      337
      27)
    object cbStart: TCheckBox
      Left = 292
      Top = 4
      Width = 41
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Run'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object rbF: TRadioButton
      Left = 152
      Top = 4
      Width = 28
      Height = 17
      Caption = 'F'
      Checked = True
      TabOrder = 1
      TabStop = True
      OnClick = rbFClick
    end
    object rbO: TRadioButton
      Left = 178
      Top = 4
      Width = 28
      Height = 17
      Caption = 'O'
      TabOrder = 2
      OnClick = rbFClick
    end
    object Button6: TButton
      Left = 114
      Top = 2
      Width = 22
      Height = 21
      Caption = '..'
      TabOrder = 3
      OnClick = Button6Click
    end
    object cbFut: TComboBox
      Left = 213
      Top = 2
      Width = 58
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 1
      TabOrder = 4
      Text = #48120#45768
      OnChange = cbFutChange
      Items.Strings = (
        #51648#49688
        #48120#45768)
    end
    object edtAccount: TEdit
      Left = 3
      Top = 2
      Width = 107
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 5
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 117
    Width = 337
    Height = 116
    Align = alTop
    TabOrder = 1
    OnDblClick = Panel3DblClick
    object Label2: TLabel
      Left = 105
      Top = 80
      Width = 8
      Height = 13
      Caption = '~'
    end
    object cbTrend2: TCheckBox
      Left = 2
      Top = 6
      Width = 57
      Height = 17
      Caption = #53804#51088#51088
      TabOrder = 0
      OnClick = cbTrend2Click
    end
    object edtQty2: TEdit
      Left = 57
      Top = 4
      Width = 22
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 1
      Text = '1'
    end
    object UpDown2: TUpDown
      Left = 79
      Top = 4
      Width = 15
      Height = 21
      Associate = edtQty2
      Min = 1
      Position = 1
      TabOrder = 2
    end
    object cbTrend2Stop: TCheckBox
      Left = 133
      Top = 7
      Width = 71
      Height = 17
      Caption = #52628#49464'2'#49828#53457
      TabOrder = 3
      OnClick = cbTrend2StopClick
    end
    object Button3: TButton
      Tag = 2
      Left = 266
      Top = 5
      Width = 24
      Height = 22
      Caption = 'def'
      TabOrder = 4
      OnClick = Button2Click
    end
    object Button1: TButton
      Tag = 2
      Left = 294
      Top = 5
      Width = 29
      Height = 22
      Caption = 'apply'
      TabOrder = 5
      OnClick = btnApply1Click
    end
    object dtStartTime2: TDateTimePicker
      Left = 0
      Top = 93
      Width = 95
      Height = 21
      Date = 41717.375694444450000000
      Time = 41717.375694444450000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 6
    end
    object dtEndTime2: TDateTimePicker
      Left = 96
      Top = 93
      Width = 91
      Height = 21
      Date = 41717.583333333340000000
      Time = 41717.583333333340000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 7
    end
    object cbInvest: TComboBox
      Left = 186
      Top = 93
      Width = 49
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 8
      Text = #44552#53804
      Items.Strings = (
        #44552#53804
        #50808#44397
        #44592#44288)
    end
    object sgTrend2: TStringGrid
      Left = 0
      Top = 30
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
      TabOrder = 9
    end
    object cbUseCnt: TCheckBox
      Left = 237
      Top = 95
      Width = 42
      Height = 17
      Caption = #44148#49688
      Checked = True
      State = cbChecked
      TabOrder = 10
    end
    object edtLiskAmt2: TEdit
      Left = 97
      Top = 4
      Width = 33
      Height = 21
      Hint = #54620#46020#44552#50529
      ImeName = 'Microsoft IME 2010'
      TabOrder = 11
      Text = '8'
    end
    object cbPlatoon: TCheckBox
      Left = 208
      Top = 6
      Width = 28
      Height = 17
      Caption = 'P'
      Checked = True
      State = cbChecked
      TabOrder = 12
    end
    object edtPlatoonPoint: TEdit
      Left = 235
      Top = 4
      Width = 28
      Height = 21
      TabOrder = 13
      Text = '3'
    end
    object cbReverse: TCheckBox
      Left = 284
      Top = 95
      Width = 44
      Height = 17
      Caption = #48152#45824
      TabOrder = 14
    end
  end
  object Panel4: TPanel
    Left = 0
    Top = 233
    Width = 337
    Height = 58
    Align = alClient
    TabOrder = 3
    object sgOrd: TStringGrid
      Left = 1
      Top = 1
      Width = 335
      Height = 56
      Align = alClient
      ColCount = 7
      Ctl3D = False
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = sgOrdDrawCell
      ColWidths = (
        65
        59
        37
        31
        31
        49
        42)
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 291
    Width = 337
    Height = 19
    Panels = <
      item
        Width = 150
      end
      item
        Width = 100
      end
      item
        Width = 100
      end>
    OnDrawPanel = stBarDrawPanel
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 337
    Height = 90
    Align = alTop
    TabOrder = 4
    OnDblClick = Panel2DblClick
    object Label1: TLabel
      Left = 170
      Top = 6
      Width = 8
      Height = 13
      Caption = '~'
    end
    object sgTrend1: TStringGrid
      Left = 0
      Top = 27
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
      TabOrder = 0
    end
    object cbTrend1: TCheckBox
      Left = 3
      Top = 6
      Width = 48
      Height = 17
      Caption = #44148#49688
      TabOrder = 1
      OnClick = cbTrend1Click
    end
    object edtQty1: TEdit
      Left = 45
      Top = 3
      Width = 27
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 2
      Text = '1'
    end
    object UpDown1: TUpDown
      Left = 72
      Top = 3
      Width = 16
      Height = 21
      Associate = edtQty1
      Min = 1
      Position = 1
      TabOrder = 3
    end
    object dtStartTime: TDateTimePicker
      Left = 91
      Top = 3
      Width = 76
      Height = 21
      Date = 41717.385416666660000000
      Time = 41717.385416666660000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 4
    end
    object dtEndTime: TDateTimePicker
      Left = 182
      Top = 3
      Width = 77
      Height = 21
      Date = 41717.617361111110000000
      Time = 41717.617361111110000000
      ImeName = 'Microsoft IME 2010'
      Kind = dtkTime
      TabOrder = 5
    end
    object Button2: TButton
      Tag = 1
      Left = 266
      Top = 3
      Width = 24
      Height = 22
      Caption = 'def'
      TabOrder = 6
      OnClick = Button2Click
    end
    object btnApply1: TButton
      Tag = 1
      Left = 294
      Top = 3
      Width = 29
      Height = 22
      Caption = 'apply'
      TabOrder = 7
      OnClick = btnApply1Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 176
    Top = 80
  end
end
