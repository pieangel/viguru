object FrmVolS: TFrmVolS
  Left = 0
  Top = 0
  Caption = 'VolS'
  ClientHeight = 572
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
    Height = 267
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
      Left = 16
      Top = 31
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label8: TLabel
      Left = 5
      Top = 109
      Width = 3
      Height = 13
    end
    object btnClear: TButton
      Left = 149
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
      Left = 208
      Top = 3
      Width = 42
      Height = 17
      Caption = 'Start'
      TabOrder = 2
      OnClick = cbStartClick
    end
    object edtQty: TEdit
      Left = 55
      Top = 27
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object udQty: TUpDown
      Left = 87
      Top = 27
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 1
      TabOrder = 4
    end
    object gbEntry: TGroupBox
      Left = 11
      Top = 54
      Width = 108
      Height = 102
      Caption = 'Entry('#45800#50948':'#47564#50896')'
      TabOrder = 5
      object Label7: TLabel
        Left = 6
        Top = 23
        Width = 24
        Height = 13
        Caption = 'Start'
      end
      object Label11: TLabel
        Left = 4
        Top = 75
        Width = 29
        Height = 13
        Caption = 'Count'
      end
      object Label12: TLabel
        Left = 6
        Top = 48
        Width = 19
        Height = 13
        Caption = 'Gap'
      end
      object edtStart: TEdit
        Tag = 6
        Left = 45
        Top = 20
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '8'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udStart: TUpDown
        Left = 77
        Top = 20
        Width = 16
        Height = 21
        Associate = edtStart
        Min = 1
        Max = 999
        Position = 8
        TabOrder = 1
      end
      object edtCount: TEdit
        Tag = 8
        Left = 45
        Top = 72
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '3'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udCount: TUpDown
        Left = 77
        Top = 72
        Width = 16
        Height = 21
        Associate = edtCount
        Min = 1
        Position = 3
        TabOrder = 3
      end
      object udGap: TUpDown
        Left = 76
        Top = 46
        Width = 16
        Height = 21
        Associate = edtGap
        Min = 1
        Max = 999
        Position = 6
        TabOrder = 4
      end
      object edtGap: TEdit
        Tag = 7
        Left = 44
        Top = 46
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '6'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
    end
    object GroupBox2: TGroupBox
      Left = 122
      Top = 90
      Width = 138
      Height = 66
      Caption = #44256#51216'('#45800#50948' : '#47564#50896')'
      TabOrder = 6
      object Label17: TLabel
        Left = 4
        Top = 21
        Width = 26
        Height = 13
        AutoSize = False
        Caption = #44256#51216
      end
      object Label3: TLabel
        Left = 64
        Top = 21
        Width = 24
        Height = 13
        Caption = #45824#48708
      end
      object Label19: TLabel
        Left = 5
        Top = 43
        Width = 48
        Height = 13
        Caption = #44032#49345#49552#51061
      end
      object edtHighPL: TEdit
        Left = 30
        Top = 18
        Width = 29
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 0
        Text = '0'
      end
      object edtChange: TEdit
        Tag = 9
        Left = 90
        Top = 16
        Width = 26
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '7'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udChange: TUpDown
        Left = 116
        Top = 16
        Width = 16
        Height = 21
        Associate = edtChange
        Min = 1
        Max = 999
        Position = 7
        TabOrder = 2
      end
      object edtVPL: TEdit
        Left = 66
        Top = 39
        Width = 62
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 3
        Text = '0'
      end
    end
    object GroupBox3: TGroupBox
      Left = 11
      Top = 156
      Width = 149
      Height = 44
      Caption = #49552#51208'('#45800#50948':'#47564#50896')'
      TabOrder = 7
      object Label15: TLabel
        Left = 8
        Top = 21
        Width = 51
        Height = 13
        AutoSize = False
        Caption = #49552#51208#44552#50529
      end
      object Label16: TLabel
        Left = 110
        Top = 21
        Width = 36
        Height = 13
        AutoSize = False
        Caption = '* '#49688#47049
      end
      object edtLossCut: TEdit
        Tag = 10
        Left = 58
        Top = 18
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '10'
        OnChange = edtQtyChange
        OnKeyPress = edtQtyKeyPress
      end
      object udLosscut: TUpDown
        Left = 90
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
      Left = 165
      Top = 179
      Width = 95
      Height = 21
      Date = 41547.617361111110000000
      Time = 41547.617361111110000000
      DateMode = dmUpDown
      ImeName = 'Microsoft Office IME 2007'
      Kind = dtkTime
      TabOrder = 8
      OnChange = dtClearChange
    end
    object cbAutoLiquid: TCheckBox
      Left = 189
      Top = 158
      Width = 71
      Height = 17
      Caption = #51088#46041#52397#49328
      Checked = True
      State = cbChecked
      TabOrder = 9
      OnClick = cbAutoLiquidClick
    end
    object sgBase: TStringGrid
      Left = 1
      Top = 203
      Width = 265
      Height = 63
      Align = alBottom
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 3
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ScrollBars = ssNone
      TabOrder = 10
      OnDrawCell = sgBaseDrawCell
    end
    object GroupBox1: TGroupBox
      Left = 125
      Top = 24
      Width = 135
      Height = 65
      Caption = #44032#44201#48276#50948
      TabOrder = 11
      object Label10: TLabel
        Left = 11
        Top = 20
        Width = 24
        Height = 13
        Caption = #44592#51456
      end
      object Label9: TLabel
        Left = 78
        Top = 20
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label4: TLabel
        Left = 79
        Top = 44
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label18: TLabel
        Left = 11
        Top = 42
        Width = 27
        Height = 13
        AutoSize = False
        Caption = #44368#52404
      end
      object edtLow: TEdit
        Tag = 1
        Left = 42
        Top = 17
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
        Top = 17
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '1.3'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
      object edtChangeUp: TEdit
        Tag = 4
        Left = 91
        Top = 39
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '2.0'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
      object edtChangeDown: TEdit
        Tag = 3
        Left = 42
        Top = 39
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 3
        Text = '0.4'
        OnChange = edtQtyChange
        OnKeyPress = edtLowKeyPress
      end
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 267
    Width = 267
    Height = 305
    Align = alClient
    TabOrder = 1
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 265
      Height = 148
      Align = alClient
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 8
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 285
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
      Top = 149
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
