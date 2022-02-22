object FrmRatioS: TFrmRatioS
  Left = 0
  Top = 0
  Caption = 'RatioS'
  ClientHeight = 638
  ClientWidth = 267
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
    Width = 267
    Height = 218
    Align = alTop
    TabOrder = 0
    object Label2: TLabel
      Left = 5
      Top = 4
      Width = 24
      Height = 13
      Caption = #44228#51340
    end
    object Label1: TLabel
      Left = 10
      Top = 27
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label3: TLabel
      Left = 11
      Top = 195
      Width = 24
      Height = 13
      Caption = #50577#54633
    end
    object Label4: TLabel
      Left = 97
      Top = 195
      Width = 15
      Height = 13
      AutoSize = False
      Caption = '/'
    end
    object Label5: TLabel
      Left = 160
      Top = 195
      Width = 15
      Height = 13
      AutoSize = False
      Caption = '='
    end
    object Label6: TLabel
      Left = 231
      Top = 195
      Width = 15
      Height = 13
      AutoSize = False
      Caption = '%'
    end
    object Label8: TLabel
      Left = 5
      Top = 109
      Width = 3
      Height = 13
    end
    object Label19: TLabel
      Left = 155
      Top = 27
      Width = 18
      Height = 13
      Caption = 'Tick'
    end
    object btnClear: TButton
      Left = 146
      Top = 1
      Width = 38
      Height = 21
      Caption = #52397#49328
      TabOrder = 0
      OnClick = btnClearClick
    end
    object ComboAccount: TComboBox
      Left = 33
      Top = 1
      Width = 107
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object cbStart: TCheckBox
      Left = 193
      Top = 3
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 2
      OnClick = cbStartClick
    end
    object edtQty: TEdit
      Left = 40
      Top = 23
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object udQty: TUpDown
      Left = 72
      Top = 23
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 1
      TabOrder = 4
    end
    object edtCSum: TEdit
      Left = 41
      Top = 191
      Width = 54
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ReadOnly = True
      TabOrder = 5
    end
    object edtBase: TEdit
      Left = 102
      Top = 191
      Width = 54
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ReadOnly = True
      TabOrder = 6
    end
    object edtPercent: TEdit
      Left = 171
      Top = 191
      Width = 54
      Height = 21
      ImeName = 'Microsoft IME 2010'
      ReadOnly = True
      TabOrder = 7
    end
    object gbEntry: TGroupBox
      Left = 5
      Top = 47
      Width = 108
      Height = 89
      Caption = 'Entry'
      TabOrder = 8
      object Label7: TLabel
        Left = 6
        Top = 20
        Width = 24
        Height = 13
        Caption = 'Start'
      end
      object Label13: TLabel
        Left = 89
        Top = 23
        Width = 15
        Height = 13
        AutoSize = False
        Caption = '%'
      end
      object Label11: TLabel
        Left = 4
        Top = 66
        Width = 29
        Height = 13
        Caption = 'Count'
      end
      object Label12: TLabel
        Left = 6
        Top = 42
        Width = 19
        Height = 13
        Caption = 'Gap'
      end
      object Label14: TLabel
        Left = 89
        Top = 46
        Width = 15
        Height = 13
        AutoSize = False
        Caption = '%'
      end
      object edtStart: TEdit
        Tag = 3
        Left = 35
        Top = 17
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '110'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udStart: TUpDown
        Left = 67
        Top = 17
        Width = 16
        Height = 21
        Associate = edtStart
        Min = 100
        Max = 999
        Position = 110
        TabOrder = 1
      end
      object edtCount: TEdit
        Tag = 5
        Left = 35
        Top = 63
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '3'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udCount: TUpDown
        Left = 67
        Top = 63
        Width = 16
        Height = 21
        Associate = edtCount
        Min = 1
        Position = 3
        TabOrder = 3
      end
      object udGap: TUpDown
        Left = 67
        Top = 40
        Width = 16
        Height = 21
        Associate = edtGap
        Min = 1
        Max = 999
        Position = 10
        TabOrder = 4
      end
      object edtGap: TEdit
        Tag = 4
        Left = 35
        Top = 40
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '10'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
    end
    object GroupBox3: TGroupBox
      Left = 9
      Top = 140
      Width = 138
      Height = 44
      Caption = #49552#51208'('#45800#50948':'#47564#50896')'
      TabOrder = 9
      object Label15: TLabel
        Left = 4
        Top = 21
        Width = 50
        Height = 13
        AutoSize = False
        Caption = #49552#51208#44552#50529
      end
      object Label16: TLabel
        Left = 100
        Top = 21
        Width = 36
        Height = 13
        AutoSize = False
        Caption = '* '#49688#47049
      end
      object edtLossCut: TEdit
        Tag = 8
        Left = 54
        Top = 18
        Width = 24
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '10'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udLosscut: TUpDown
        Left = 78
        Top = 18
        Width = 16
        Height = 21
        Associate = edtLossCut
        Min = 1
        Max = 999
        Position = 10
        TabOrder = 1
      end
    end
    object dtClear: TDateTimePicker
      Left = 153
      Top = 160
      Width = 95
      Height = 21
      Date = 41547.617361111110000000
      Time = 41547.617361111110000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 10
      OnChange = dtClearChange
    end
    object cbAutoLiquid: TCheckBox
      Left = 177
      Top = 142
      Width = 71
      Height = 17
      Caption = #51088#46041#52397#49328
      Checked = True
      State = cbChecked
      TabOrder = 11
      OnClick = cbAutoLiquidClick
    end
    object GroupBox1: TGroupBox
      Left = 115
      Top = 47
      Width = 138
      Height = 89
      Caption = #44032#44201#48276#50948
      TabOrder = 12
      object Label10: TLabel
        Left = 11
        Top = 32
        Width = 24
        Height = 13
        Caption = #44592#51456
      end
      object Label9: TLabel
        Left = 78
        Top = 32
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label17: TLabel
        Left = 79
        Top = 61
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label18: TLabel
        Left = 11
        Top = 59
        Width = 27
        Height = 13
        AutoSize = False
        Caption = #44368#52404
      end
      object edtLow: TEdit
        Tag = 1
        Left = 42
        Top = 29
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '0.4'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
      object edtHigh: TEdit
        Tag = 2
        Left = 91
        Top = 29
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '1.3'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
      object edtChangeUp: TEdit
        Tag = 6
        Left = 91
        Top = 56
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '2.0'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
      object edtChangeDown: TEdit
        Tag = 7
        Left = 42
        Top = 56
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '0.4'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
    end
    object edtTick: TEdit
      Tag = 10
      Left = 177
      Top = 24
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 13
      Text = '10'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object udTick: TUpDown
      Left = 209
      Top = 24
      Width = 16
      Height = 21
      Associate = edtTick
      Min = 1
      Position = 10
      TabOrder = 14
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 218
    Width = 267
    Height = 420
    Align = alClient
    TabOrder = 1
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 265
      Height = 263
      Align = alClient
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 400
      Width = 265
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 75
        end
        item
          Width = 50
        end>
    end
    object sgPos: TStringGrid
      Left = 1
      Top = 264
      Width = 265
      Height = 136
      Align = alBottom
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 2
      OnDrawCell = sgPosDrawCell
    end
  end
end
