object FrmPave: TFrmPave
  Left = 0
  Top = 0
  Caption = 'HFT / HULT'
  ClientHeight = 254
  ClientWidth = 204
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
    Width = 204
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      204
      27)
    object Label1: TLabel
      Left = 4
      Top = 5
      Width = 39
      Height = 13
      Caption = 'Account'
    end
    object cbAccount: TComboBox
      Left = 48
      Top = 2
      Width = 100
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 155
      Top = 4
      Width = 45
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 204
    Height = 208
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object Label2: TLabel
      Left = 4
      Top = 6
      Width = 34
      Height = 13
      Caption = 'Symbol'
    end
    object Label3: TLabel
      Left = 4
      Top = 31
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label4: TLabel
      Left = 111
      Top = 33
      Width = 24
      Height = 13
      Caption = #44036#44201
    end
    object Label5: TLabel
      Left = 4
      Top = 58
      Width = 24
      Height = 13
      Caption = #44148#49688
    end
    object Label6: TLabel
      Left = 110
      Top = 58
      Width = 26
      Height = 13
      Caption = 'Profit'
    end
    object Label7: TLabel
      Left = 95
      Top = 108
      Width = 40
      Height = 13
      Caption = 'Max Net'
    end
    object Label8: TLabel
      Left = 96
      Top = 83
      Width = 32
      Height = 13
      Caption = 'LC Net'
    end
    object Label9: TLabel
      Left = 4
      Top = 84
      Width = 20
      Height = 13
      Caption = 'OTE'
    end
    object edtSymbol: TEdit
      Left = 45
      Top = 2
      Width = 102
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 149
      Top = 2
      Width = 29
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object rgAskIdx: TRadioGroup
      Left = 235
      Top = 59
      Width = 89
      Height = 122
      Caption = #47588#46020#49884#51089#54840#44032
      ItemIndex = 1
      Items.Strings = (
        '1'#54840#44032
        '2'#54840#44032
        '3'#54840#44032
        '4'#54840#44032
        '5'#54840#44032)
      TabOrder = 2
      Visible = False
      OnClick = rgAskIdxClick
    end
    object rgBidIdx: TRadioGroup
      Tag = 1
      Left = 330
      Top = 59
      Width = 89
      Height = 122
      Caption = #47588#49688#49884#51089#54840#44032
      ItemIndex = 1
      Items.Strings = (
        '1'#54840#44032
        '2'#54840#44032
        '3'#54840#44032
        '4'#54840#44032
        '5'#54840#44032)
      TabOrder = 3
      Visible = False
      OnClick = rgAskIdxClick
    end
    object edtQty: TEdit
      Left = 34
      Top = 28
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '1'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object edtGap: TEdit
      Tag = 1
      Left = 141
      Top = 29
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '8'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object edtCnt: TEdit
      Tag = 2
      Left = 34
      Top = 55
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      Text = '2'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object UpDown1: TUpDown
      Left = 69
      Top = 28
      Width = 15
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 1
      TabOrder = 7
    end
    object UpDown2: TUpDown
      Left = 176
      Top = 29
      Width = 15
      Height = 21
      Associate = edtGap
      Min = 1
      Max = 50
      Position = 8
      TabOrder = 8
    end
    object UpDown3: TUpDown
      Left = 69
      Top = 55
      Width = 15
      Height = 21
      Associate = edtCnt
      Min = 1
      Position = 2
      TabOrder = 9
    end
    object sgLog: TStringGrid
      Left = 4
      Top = 159
      Width = 196
      Height = 37
      ColCount = 2
      Ctl3D = False
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ParentCtl3D = False
      TabOrder = 10
      ColWidths = (
        57
        136)
    end
    object gbCatch: TGroupBox
      Left = 271
      Top = 6
      Width = 196
      Height = 118
      Caption = 'Catch'
      TabOrder = 11
      object Label10: TLabel
        Left = 6
        Top = 42
        Width = 43
        Height = 13
        Caption = 'Continue'
      end
      object Label13: TLabel
        Left = 11
        Top = 69
        Width = 26
        Height = 13
        Caption = 'FillVol'
      end
      object Label14: TLabel
        Left = 108
        Top = 69
        Width = 28
        Height = 13
        Caption = 'Q_Vol'
      end
      object Label15: TLabel
        Left = 106
        Top = 43
        Width = 30
        Height = 13
        Caption = 'Speed'
      end
      object Label11: TLabel
        Left = 5
        Top = 97
        Width = 43
        Height = 13
        Caption = 'Liquidate'
      end
      object edtContinue: TEdit
        Tag = 8
        Left = 53
        Top = 38
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '3'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object udContinue: TUpDown
        Left = 84
        Top = 38
        Width = 16
        Height = 21
        Associate = edtContinue
        Min = 1
        Position = 3
        TabOrder = 1
      end
      object udFillVol: TUpDown
        Left = 84
        Top = 66
        Width = 16
        Height = 21
        Associate = edtFillVol
        Min = 1
        Max = 999
        Position = 100
        TabOrder = 2
      end
      object edtFillVol: TEdit
        Tag = 10
        Left = 53
        Top = 66
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '100'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object cbUseCatch: TCheckBox
        Left = 7
        Top = 16
        Width = 70
        Height = 17
        Caption = 'Use Catch '
        TabOrder = 4
        OnClick = cbUseCatchClick
      end
      object edtLiquidateTick: TEdit
        Tag = 12
        Left = 53
        Top = 93
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '3'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object edtHoldTick: TEdit
        Tag = 13
        Left = 144
        Top = 93
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 6
        Text = '3'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object udHoldTick: TUpDown
        Left = 175
        Top = 93
        Width = 16
        Height = 21
        Associate = edtHoldTick
        Min = 1
        Max = 10
        Position = 3
        TabOrder = 7
      end
      object udLiquidateTick: TUpDown
        Left = 84
        Top = 93
        Width = 16
        Height = 21
        Associate = edtLiquidateTick
        Min = 1
        Position = 3
        TabOrder = 8
      end
      object edtQVol: TEdit
        Tag = 11
        Left = 144
        Top = 67
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '50'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object udQVol: TUpDown
        Left = 175
        Top = 67
        Width = 16
        Height = 21
        Associate = edtQVol
        Min = 1
        Max = 999
        Position = 50
        TabOrder = 10
      end
      object edtSpeed: TEdit
        Tag = 9
        Left = 144
        Top = 38
        Width = 31
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 11
        Text = '10'
        OnChange = edtGapChange
        OnKeyPress = edtQtyKeyPress
      end
      object udSpeed: TUpDown
        Left = 175
        Top = 38
        Width = 16
        Height = 21
        Associate = edtSpeed
        Min = 1
        Position = 10
        TabOrder = 12
      end
    end
    object cbAutoLiquid: TCheckBox
      Left = 20
      Top = 136
      Width = 71
      Height = 17
      Caption = 'AutoClear'
      Checked = True
      State = cbChecked
      TabOrder = 12
    end
    object DateTimePicker: TDateTimePicker
      Left = 104
      Top = 134
      Width = 95
      Height = 21
      Date = 41547.631944444450000000
      Time = 41547.631944444450000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 13
    end
    object edtProfit: TEdit
      Tag = 3
      Left = 140
      Top = 55
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 14
      Text = '2'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object udProfit: TUpDown
      Left = 175
      Top = 55
      Width = 16
      Height = 21
      Associate = edtProfit
      Min = 1
      Position = 2
      TabOrder = 15
    end
    object edtMaxNet: TEdit
      Tag = 2
      Left = 140
      Top = 105
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 16
      Text = '7'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object udMaxNet: TUpDown
      Left = 175
      Top = 105
      Width = 15
      Height = 21
      Associate = edtMaxNet
      Min = 1
      Position = 7
      TabOrder = 17
    end
    object edtLCNet: TEdit
      Tag = 2
      Left = 141
      Top = 80
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 18
      Text = '3'
      OnChange = edtGapChange
      OnKeyPress = edtQtyKeyPress
    end
    object udLCNet: TUpDown
      Left = 176
      Top = 80
      Width = 15
      Height = 21
      Associate = edtLCNet
      Min = 1
      Position = 3
      TabOrder = 19
    end
    object edtOTE: TEdit
      Left = 34
      Top = 82
      Width = 49
      Height = 21
      ImeName = 'Microsoft IME 2010'
      TabOrder = 20
      Text = '100'
      OnKeyPress = edtQtyKeyPress
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 235
    Width = 204
    Height = 19
    Panels = <
      item
        Width = 100
      end>
  end
end
