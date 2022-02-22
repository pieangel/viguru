object frmBHultOpt: TfrmBHultOpt
  Left = 0
  Top = 0
  Caption = 'BHultOpt'
  ClientHeight = 368
  ClientWidth = 206
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
    Width = 206
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentBackground = False
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      206
      27)
    object cbAccount: TComboBox
      Left = 6
      Top = 2
      Width = 102
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object cbStart: TCheckBox
      Left = 156
      Top = 4
      Width = 46
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object btnColor: TButton
      Left = 117
      Top = 2
      Width = 30
      Height = 20
      Caption = 'C'
      TabOrder = 2
      OnClick = btnColorClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 206
    Height = 322
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object Label3: TLabel
      Left = 11
      Top = 8
      Width = 18
      Height = 13
      Caption = 'Qty'
    end
    object Label11: TLabel
      Left = 4
      Top = 86
      Width = 13
      Height = 13
      Caption = 'PH'
    end
    object Label12: TLabel
      Left = 74
      Top = 86
      Width = 11
      Height = 13
      Caption = 'PL'
    end
    object Label13: TLabel
      Left = 141
      Top = 86
      Width = 8
      Height = 13
      Caption = '='
    end
    object Label14: TLabel
      Left = 7
      Top = 58
      Width = 8
      Height = 13
      Caption = 'O'
    end
    object Label15: TLabel
      Left = 73
      Top = 58
      Width = 10
      Height = 13
      Caption = 'In'
    end
    object Label16: TLabel
      Left = 123
      Top = 58
      Width = 24
      Height = 13
      Caption = 'Term'
    end
    object Price: TLabel
      Left = 95
      Top = 8
      Width = 23
      Height = 13
      Caption = 'Price'
    end
    object edtQty: TEdit
      Left = 33
      Top = 5
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
      Text = '5'
      OnKeyPress = edtQtyKeyPress
    end
    object UpDown1: TUpDown
      Left = 68
      Top = 5
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 5
      TabOrder = 1
    end
    object gbUseHul: TGroupBox
      Left = 5
      Top = 157
      Width = 196
      Height = 67
      Caption = #49552#51208#51312#44148'('#45800#50948' : '#47564#50896')'
      TabOrder = 2
      object Label6: TLabel
        Left = 11
        Top = 21
        Width = 19
        Height = 13
        Caption = 'Risk'
      end
      object Label4: TLabel
        Left = 102
        Top = 21
        Width = 26
        Height = 13
        Caption = 'Profit'
      end
      object cbAllcnlNStop: TCheckBox
        Left = 6
        Top = 40
        Width = 147
        Height = 17
        Caption = #49552#51208#54980' '#47784#46160' '#52712#49548' && '#49828#53457
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbAutoLiquidClick
      end
      object edtRiskAmt: TEdit
        Tag = 3
        Left = 31
        Top = 17
        Width = 46
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '500'
        OnKeyPress = edtQtyKeyPress
      end
      object UpDown5: TUpDown
        Left = 77
        Top = 17
        Width = 16
        Height = 21
        Associate = edtRiskAmt
        Min = 1
        Max = 30000
        Increment = 10
        Position = 500
        TabOrder = 2
      end
      object edtProfitAmt: TEdit
        Tag = 4
        Left = 130
        Top = 17
        Width = 46
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '30,000'
        OnKeyPress = edtQtyKeyPress
      end
      object udProfitAmt: TUpDown
        Left = 176
        Top = 17
        Width = 16
        Height = 21
        Associate = edtProfitAmt
        Min = 1
        Max = 30000
        Increment = 10
        Position = 30000
        TabOrder = 4
      end
    end
    object gbRiquid: TGroupBox
      Left = 5
      Top = 107
      Width = 196
      Height = 44
      Caption = 'Clear'
      TabOrder = 3
      object DateTimePicker: TDateTimePicker
        Left = 89
        Top = 16
        Width = 95
        Height = 21
        Date = 41547.625000000000000000
        Time = 41547.625000000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object cbAutoLiquid: TCheckBox
        Left = 5
        Top = 18
        Width = 71
        Height = 17
        Caption = 'AutoClear'
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbAutoLiquidClick
      end
    end
    object edtPrevHigh: TEdit
      Left = 21
      Top = 82
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 4
    end
    object edtPrevLow: TEdit
      Left = 88
      Top = 82
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 5
    end
    object edtBand: TEdit
      Left = 154
      Top = 82
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 6
    end
    object edtOpen: TEdit
      Left = 21
      Top = 54
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 7
    end
    object edtInput: TEdit
      Left = 88
      Top = 54
      Width = 28
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 8
      Text = '2.0'
    end
    object edtTerm: TEdit
      Tag = 3
      Left = 149
      Top = 54
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '5'
    end
    object udTerm: TUpDown
      Left = 184
      Top = 54
      Width = 16
      Height = 21
      Associate = edtTerm
      Min = 1
      Position = 5
      TabOrder = 10
    end
    object DateTimePicker1: TDateTimePicker
      Left = 8
      Top = 30
      Width = 95
      Height = 21
      Date = 41547.375115740740000000
      Time = 41547.375115740740000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 11
    end
    object GroupBox1: TGroupBox
      Left = 7
      Top = 223
      Width = 194
      Height = 96
      Caption = 'Hult('#45800#50948' :'#47564#50896')'
      TabOrder = 12
      object Label19: TLabel
        Left = 4
        Top = 44
        Width = 43
        Height = 13
        Caption = 'Hult'#44552#50529
      end
      object Label21: TLabel
        Left = 3
        Top = 70
        Width = 19
        Height = 13
        Caption = 'Add'
      end
      object Label22: TLabel
        Left = 71
        Top = 70
        Width = 24
        Height = 13
        Caption = #54943#49688
      end
      object Label2: TLabel
        Left = 136
        Top = 70
        Width = 15
        Height = 13
        Caption = 'Div'
      end
      object Label5: TLabel
        Left = 5
        Top = 18
        Width = 19
        Height = 13
        Caption = 'Gap'
      end
      object edtHult: TEdit
        Tag = 5
        Left = 48
        Top = 40
        Width = 28
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '300'
        OnKeyPress = edtQtyKeyPress
      end
      object udHult: TUpDown
        Left = 76
        Top = 40
        Width = 16
        Height = 21
        Associate = edtHult
        Min = 1
        Max = 10000
        Increment = 10
        Position = 300
        TabOrder = 1
      end
      object edtHultPL: TEdit
        Left = 63
        Top = 15
        Width = 55
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 2
      end
      object edtAddEntry: TEdit
        Tag = 6
        Left = 23
        Top = 67
        Width = 27
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '100'
        OnKeyPress = edtQtyKeyPress
      end
      object udAddEntry: TUpDown
        Left = 50
        Top = 67
        Width = 16
        Height = 21
        Associate = edtAddEntry
        Min = 1
        Max = 10000
        Increment = 10
        Position = 100
        TabOrder = 4
      end
      object edtAddEntryCnt: TEdit
        Tag = 7
        Left = 95
        Top = 67
        Width = 21
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '5'
        OnKeyPress = edtQtyKeyPress
      end
      object UdAddEntryCnt: TUpDown
        Left = 116
        Top = 67
        Width = 16
        Height = 21
        Associate = edtAddEntryCnt
        Max = 10000
        Position = 5
        TabOrder = 6
      end
      object edtPos: TEdit
        Left = 121
        Top = 15
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 7
      end
      object edtHigh: TEdit
        Left = 153
        Top = 15
        Width = 38
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 8
      end
      object edtLow: TEdit
        Left = 153
        Top = 40
        Width = 38
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 9
      end
      object edtQtyDiv: TEdit
        Tag = 8
        Left = 154
        Top = 67
        Width = 21
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 10
        Text = '1'
        OnKeyPress = edtQtyKeyPress
      end
      object udQtyDiv: TUpDown
        Left = 175
        Top = 67
        Width = 16
        Height = 21
        Associate = edtQtyDiv
        Min = 1
        Max = 10000
        Position = 1
        TabOrder = 11
      end
      object Edit1: TEdit
        Tag = 9
        Left = 25
        Top = 15
        Width = 21
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 12
        Text = '5'
        OnKeyPress = edtQtyKeyPress
      end
      object udHultGap: TUpDown
        Left = 46
        Top = 15
        Width = 16
        Height = 21
        Associate = Edit1
        Min = 1
        Max = 10000
        Position = 5
        TabOrder = 13
      end
      object cbCalS: TCheckBox
        Left = 98
        Top = 44
        Width = 43
        Height = 17
        Caption = 'CalS'
        TabOrder = 14
      end
    end
    object edtPrice: TEdit
      Tag = 2
      Left = 128
      Top = 7
      Width = 28
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 13
      Text = '1.5'
    end
    object edtCode: TEdit
      Left = 126
      Top = 29
      Width = 72
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 14
    end
    object btnApply: TButton
      Left = 162
      Top = 6
      Width = 36
      Height = 20
      Caption = #51201#50857
      TabOrder = 15
      OnClick = btnApplyClick
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 349
    Width = 206
    Height = 19
    Panels = <
      item
        Width = 60
      end
      item
        Width = 160
      end>
  end
  object ColorDialog: TColorDialog
    Left = 168
    Top = 224
  end
end
