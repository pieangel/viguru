object FrmHLTrade: TFrmHLTrade
  Left = 0
  Top = 0
  Caption = 'HLT'
  ClientHeight = 452
  ClientWidth = 568
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
    Width = 568
    Height = 33
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 8
      Width = 24
      Height = 13
      Caption = #44228#51340
    end
    object Label2: TLabel
      Left = 168
      Top = 8
      Width = 24
      Height = 13
      Caption = #51333#47785
    end
    object cbAccount: TComboBox
      Left = 34
      Top = 5
      Width = 128
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object edtSymbol: TEdit
      Left = 197
      Top = 5
      Width = 102
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 1
    end
    object Button1: TButton
      Left = 300
      Top = 5
      Width = 29
      Height = 21
      Caption = '...'
      TabOrder = 2
      OnClick = Button1Click
    end
    object btnStart: TButton
      Left = 333
      Top = 5
      Width = 45
      Height = 21
      Caption = 'Start'
      TabOrder = 3
      OnClick = btnStartClick
    end
    object btnStop: TButton
      Tag = 1
      Left = 380
      Top = 5
      Width = 45
      Height = 21
      Caption = 'Stop'
      TabOrder = 4
      OnClick = btnStartClick
    end
    object btnClear: TButton
      Left = 425
      Top = 5
      Width = 45
      Height = 21
      Caption = #52397#49328
      TabOrder = 5
      OnClick = btnClearClick
    end
    object btnApply: TButton
      Left = 471
      Top = 6
      Width = 39
      Height = 21
      Caption = #51201#50857
      TabOrder = 6
      OnClick = btnApplyClick
    end
    object cbTrend: TCheckBox
      Left = 515
      Top = 8
      Width = 95
      Height = 17
      Caption = #52628#49464
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = cbTrendClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 33
    Width = 568
    Height = 419
    Align = alClient
    TabOrder = 1
    object Label5: TLabel
      Left = 7
      Top = 11
      Width = 36
      Height = 13
      Caption = #51204#44256#44032
    end
    object Label6: TLabel
      Left = 108
      Top = 11
      Width = 36
      Height = 13
      Caption = #51204#51200#44032
    end
    object Label7: TLabel
      Left = 209
      Top = 11
      Width = 36
      Height = 13
      Caption = #49884'    '#44032
    end
    object Label15: TLabel
      Left = 402
      Top = 11
      Width = 48
      Height = 13
      Caption = #52397#49328#49884#44036
    end
    object Label25: TLabel
      Left = 313
      Top = 11
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object edtPrevHigh: TEdit
      Left = 45
      Top = 7
      Width = 58
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
    end
    object edtPrevLow: TEdit
      Left = 148
      Top = 7
      Width = 58
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
    end
    object gbBand1: TGroupBox
      Left = 3
      Top = 34
      Width = 561
      Height = 50
      Caption = 'Band1'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 2
      object Label4: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label3: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label9: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label26: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label27: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd1: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart1: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.385416666660000000
        Time = 41534.385416666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand1: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput1: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '3.3'
      end
      object edtLossCut1: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL1: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut1
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP1: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit1
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit1: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart1: TCheckBox
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm1: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '5'
      end
      object UpDown14: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm1
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 10
      end
    end
    object edtOpen: TEdit
      Left = 250
      Top = 7
      Width = 58
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 3
    end
    object dtClear: TDateTimePicker
      Left = 456
      Top = 7
      Width = 97
      Height = 21
      Date = 41534.625000000000000000
      Time = 41534.625000000000000000
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 4
    end
    object gbBand2: TGroupBox
      Left = 3
      Top = 86
      Width = 561
      Height = 50
      Caption = 'Band2'
      TabOrder = 5
      object Label8: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label10: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label11: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label28: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label29: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd2: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart2: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.395833333340000000
        Time = 41534.395833333340000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand2: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput2: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '3.0'
      end
      object edtLossCut2: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL2: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut2
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP2: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit2
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit2: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart2: TCheckBox
        Tag = 1
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm2: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '10'
      end
      object UpDown15: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm2
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 10
      end
    end
    object gbBand3: TGroupBox
      Left = 3
      Top = 142
      Width = 561
      Height = 50
      Caption = 'Band3'
      TabOrder = 6
      object Label12: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label13: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label14: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label30: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label31: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd3: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart3: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.395833333340000000
        Time = 41534.395833333340000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand3: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput3: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '2.5'
      end
      object edtLossCut3: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL3: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut3
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP3: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit3
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit3: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart3: TCheckBox
        Tag = 2
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm3: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '15'
      end
      object UpDown16: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm3
        Min = 1
        Max = 500
        Position = 15
        TabOrder = 10
      end
    end
    object gbBand4: TGroupBox
      Left = 3
      Top = 198
      Width = 561
      Height = 50
      Caption = 'Band4'
      TabOrder = 7
      object Label16: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label17: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label18: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label32: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label33: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd4: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart4: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.385416666660000000
        Time = 41534.385416666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand4: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput4: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '3.8'
      end
      object edtLossCut4: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL4: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut4
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP4: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit4
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit4: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart4: TCheckBox
        Tag = 3
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm4: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '5'
      end
      object UpDown17: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm4
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 10
      end
    end
    object gbBand5: TGroupBox
      Left = 3
      Top = 254
      Width = 561
      Height = 50
      Caption = 'Band5'
      TabOrder = 8
      object Label19: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label20: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label21: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label34: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label35: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd5: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart5: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.395833333340000000
        Time = 41534.395833333340000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand5: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput5: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '3.4'
      end
      object edtLossCut5: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL5: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut5
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP5: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit5
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit5: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart5: TCheckBox
        Tag = 4
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm5: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '10'
      end
      object UpDown18: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm5
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 10
      end
    end
    object gbBand6: TGroupBox
      Left = 3
      Top = 310
      Width = 561
      Height = 50
      Caption = 'Band6'
      TabOrder = 9
      object Label22: TLabel
        Left = 225
        Top = 23
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label23: TLabel
        Left = 325
        Top = 22
        Width = 24
        Height = 13
        Caption = #49552#51208
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label24: TLabel
        Left = 395
        Top = 22
        Width = 24
        Height = 13
        Caption = #51060#51061
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label36: TLabel
        Left = 467
        Top = 22
        Width = 27
        Height = 13
        Caption = 'TERM'
      end
      object Label37: TLabel
        Left = 540
        Top = 23
        Width = 16
        Height = 13
        Caption = 'Min'
      end
      object dtEnd6: TDateTimePicker
        Left = 233
        Top = 20
        Width = 92
        Height = 21
        Date = 41534.604166666660000000
        Time = 41534.604166666660000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStart6: TDateTimePicker
        Left = 133
        Top = 19
        Width = 92
        Height = 21
        Date = 41534.395833333340000000
        Time = 41534.395833333340000000
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object edtBand6: TEdit
        Left = 50
        Top = 19
        Width = 50
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
      end
      object edtInput6: TEdit
        Left = 100
        Top = 19
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '2.8'
      end
      object edtLossCut6: TEdit
        Tag = 3
        Left = 350
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '5'
      end
      object udL6: TUpDown
        Left = 375
        Top = 19
        Width = 16
        Height = 21
        Associate = edtLossCut6
        Min = 1
        Max = 500
        Position = 5
        TabOrder = 5
      end
      object udP6: TUpDown
        Left = 445
        Top = 19
        Width = 16
        Height = 21
        Associate = edtProfit6
        Min = 1
        Max = 500
        Position = 10
        TabOrder = 6
      end
      object edtProfit6: TEdit
        Tag = 7
        Left = 420
        Top = 19
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '10'
      end
      object cbStart6: TCheckBox
        Tag = 5
        Left = 5
        Top = 19
        Width = 45
        Height = 21
        Align = alCustom
        Caption = 'Start'
        TabOrder = 8
        OnClick = cbStart1Click
      end
      object edtTerm6: TEdit
        Tag = 7
        Left = 497
        Top = 20
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '15'
      end
      object UpDown19: TUpDown
        Left = 522
        Top = 20
        Width = 16
        Height = 21
        Associate = edtTerm6
        Min = 1
        Max = 500
        Position = 15
        TabOrder = 10
      end
    end
    object sgInfo: TStringGrid
      Left = 1
      Top = 360
      Width = 566
      Height = 39
      Align = alBottom
      ColCount = 7
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 10
      OnDrawCell = sgInfoDrawCell
    end
    object edtQty: TEdit
      Left = 343
      Top = 7
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 11
      Text = '1'
    end
    object UpDown13: TUpDown
      Left = 376
      Top = 7
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 1000
      Position = 1
      TabOrder = 12
    end
    object stTxt: TStatusBar
      Left = 1
      Top = 399
      Width = 566
      Height = 19
      Panels = <
        item
          Width = 60
        end
        item
          Width = 160
        end>
    end
  end
end
