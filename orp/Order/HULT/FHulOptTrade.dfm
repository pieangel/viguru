object FrmHultOpt: TFrmHultOpt
  Left = 0
  Top = 0
  Caption = 'OptHult'
  ClientHeight = 285
  ClientWidth = 207
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
    Width = 207
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 0
    DesignSize = (
      207
      27)
    object Label1: TLabel
      Left = 4
      Top = 5
      Width = 24
      Height = 13
      Caption = #44228#51340
    end
    object cbAccount: TComboBox
      Left = 34
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
      Left = 152
      Top = 6
      Width = 53
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
    Width = 207
    Height = 239
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object Label2: TLabel
      Left = 5
      Top = 8
      Width = 24
      Height = 13
      Caption = #51333#47785
    end
    object Label3: TLabel
      Left = 19
      Top = 32
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label4: TLabel
      Left = 119
      Top = 33
      Width = 24
      Height = 13
      Caption = #44036#44201
    end
    object Label5: TLabel
      Left = 7
      Top = 59
      Width = 48
      Height = 13
      Caption = #53244#54021#49688#47049
    end
    object Label8: TLabel
      Left = 119
      Top = 59
      Width = 24
      Height = 13
      Caption = #44032#44201
    end
    object edtSymbol: TEdit
      Left = 35
      Top = 4
      Width = 102
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 0
    end
    object edtQty: TEdit
      Left = 62
      Top = 28
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
      Text = '1'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object edtGap: TEdit
      Tag = 1
      Left = 149
      Top = 29
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '3'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object udQty: TUpDown
      Left = 97
      Top = 28
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 1
      TabOrder = 3
    end
    object udGap: TUpDown
      Left = 184
      Top = 29
      Width = 16
      Height = 21
      Associate = edtGap
      Min = 1
      Position = 3
      TabOrder = 4
    end
    object gbUseHul: TGroupBox
      Left = 5
      Top = 168
      Width = 196
      Height = 69
      Caption = #49552#51208#51312#44148
      TabOrder = 5
      object Label6: TLabel
        Left = 11
        Top = 21
        Width = 46
        Height = 13
        Caption = 'Risk '#44552#50529
      end
      object Label7: TLabel
        Left = 132
        Top = 21
        Width = 63
        Height = 13
        Caption = #50896' ('#45800#50948':'#52380')'
      end
      object cbAllcnlNStop: TCheckBox
        Tag = 1
        Left = 6
        Top = 44
        Width = 157
        Height = 17
        Caption = #49552#51208#54980' '#47784#46160' '#52712#49548' && '#49828#53457
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbAutoLiquidClick
      end
      object edtRiskAmt: TEdit
        Tag = 4
        Left = 63
        Top = 17
        Width = 47
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '10,000'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udRiskAmt: TUpDown
        Left = 110
        Top = 17
        Width = 16
        Height = 21
        Associate = edtRiskAmt
        Min = 1
        Max = 32700
        Increment = 10
        Position = 10000
        TabOrder = 2
      end
    end
    object gbRiquid: TGroupBox
      Left = 5
      Top = 117
      Width = 196
      Height = 44
      Caption = #52397#49328' '
      TabOrder = 6
      object dtClear: TDateTimePicker
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
        OnChange = dtClearChange
      end
      object cbAutoLiquid: TCheckBox
        Left = 5
        Top = 18
        Width = 71
        Height = 17
        Caption = #51088#46041#52397#49328
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbAutoLiquidClick
      end
    end
    object edtQuoting: TEdit
      Tag = 2
      Left = 62
      Top = 55
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '2'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object udQuoting: TUpDown
      Left = 97
      Top = 55
      Width = 16
      Height = 21
      Associate = edtQuoting
      Min = 1
      Position = 2
      TabOrder = 8
    end
    object edtPrice: TEdit
      Tag = 3
      Left = 149
      Top = 56
      Width = 40
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '1.0'
      OnChange = edtQtyChange
    end
    object edtLast: TEdit
      Left = 143
      Top = 4
      Width = 56
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 10
    end
    object rgCallPut: TRadioGroup
      Left = 7
      Top = 80
      Width = 185
      Height = 35
      Caption = 'Call_PUt'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        'Call'
        'Put')
      TabOrder = 11
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 266
    Width = 207
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
