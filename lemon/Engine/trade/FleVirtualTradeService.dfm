object VirtualTradeServiceForm: TVirtualTradeServiceForm
  Left = 441
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Virtual Trade Service'
  ClientHeight = 157
  ClientWidth = 207
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 8
    Top = 124
    Width = 42
    Height = 13
    Caption = 'Markets:'
  end
  object Label5: TLabel
    Left = 8
    Top = 293
    Width = 21
    Height = 13
    Caption = 'Log:'
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 612
    Height = 110
    Caption = 'Global Options'
    TabOrder = 0
    object SpeedButtonAbortAllOrders: TSpeedButton
      Left = 487
      Top = 17
      Width = 113
      Height = 22
      Caption = 'Abort All Orders...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButtonAbortAllOrdersClick
    end
    object Bevel1: TBevel
      Left = 464
      Top = 28
      Width = 2
      Height = 60
    end
    object SpeedButtonFillAllOrders: TSpeedButton
      Left = 487
      Top = 45
      Width = 113
      Height = 22
      Caption = 'Fill All Orders...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButtonFillAllOrdersClick
    end
    object SpeedButtonSaveLogs: TSpeedButton
      Left = 487
      Top = 73
      Width = 113
      Height = 22
      Caption = 'Save Logs...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 9
      Top = 51
      Width = 67
      Height = 13
      Caption = #53685#49888#46364#47112#51060' :'
    end
    object Label6: TLabel
      Left = 10
      Top = 83
      Width = 67
      Height = 13
      Caption = #51217#49688#46364#47112#51060' :'
    end
    object Label7: TLabel
      Left = 153
      Top = 52
      Width = 67
      Height = 13
      Caption = #52404#44208#46364#47112#51060' :'
    end
    object Label9: TLabel
      Left = 324
      Top = 51
      Width = 60
      Height = 13
      Caption = #48512#48516#52404#44208#47456
    end
    object labelfill: TLabel
      Left = 314
      Top = 82
      Width = 72
      Height = 13
      Caption = #48512#48516#52404#44208'Term'
    end
    object Label8: TLabel
      Left = 150
      Top = 83
      Width = 72
      Height = 13
      Caption = #49345#45824#54840#44032#52404#44208
    end
    object Bevel2: TBevel
      Left = 288
      Top = 28
      Width = 2
      Height = 60
    end
    object edtOrder: TEdit
      Left = 82
      Top = 49
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 0
      Text = '15'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object edtAccept: TEdit
      Tag = 1
      Left = 83
      Top = 76
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 1
      Text = '30'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object edtFill: TEdit
      Tag = 2
      Left = 225
      Top = 48
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 2
      Text = '200'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object udOrder: TUpDown
      Left = 114
      Top = 49
      Width = 15
      Height = 21
      Associate = edtOrder
      Max = 2000
      Position = 15
      TabOrder = 3
      OnClick = udOrderClick
    end
    object udAccept: TUpDown
      Tag = 1
      Left = 115
      Top = 76
      Width = 15
      Height = 21
      Associate = edtAccept
      Max = 2000
      Position = 30
      TabOrder = 4
      OnClick = udOrderClick
    end
    object udFill: TUpDown
      Tag = 2
      Left = 257
      Top = 48
      Width = 15
      Height = 21
      Associate = edtFill
      Max = 2000
      Position = 200
      TabOrder = 5
      OnClick = udOrderClick
    end
    object udPartFillRatio: TUpDown
      Tag = 4
      Left = 422
      Top = 46
      Width = 15
      Height = 21
      Associate = edtPartFillRatio
      Position = 50
      TabOrder = 6
      OnClick = udOrderClick
    end
    object edtPartFillRatio: TEdit
      Tag = 4
      Left = 390
      Top = 46
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 7
      Text = '50'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object edtPartFill: TEdit
      Tag = 5
      Left = 391
      Top = 79
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 8
      Text = '200'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object udPartFill: TUpDown
      Tag = 5
      Left = 423
      Top = 79
      Width = 15
      Height = 21
      Associate = edtPartFill
      Max = 2000
      Position = 200
      TabOrder = 9
      OnClick = udOrderClick
    end
    object edtearchFill: TEdit
      Tag = 3
      Left = 228
      Top = 75
      Width = 32
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 10
      Text = '200'
      OnKeyDown = edtOrderKeyDown
      OnKeyPress = edtOrderKeyPress
    end
    object udEarchFill: TUpDown
      Tag = 3
      Left = 260
      Top = 75
      Width = 15
      Height = 21
      Associate = edtearchFill
      Max = 2000
      Position = 200
      TabOrder = 11
      OnClick = udOrderClick
    end
    object cbPartFill: TCheckBox
      Tag = 100
      Left = 324
      Top = 19
      Width = 105
      Height = 17
      Caption = #48512#48516' '#52404#44208' '#48156#49373
      TabOrder = 12
      OnClick = cbPartFillClick
    end
    object cbTraining: TCheckBox
      Left = 11
      Top = 18
      Width = 103
      Height = 17
      Caption = #49828#53000#54609' '#50672#49845#50857
      TabOrder = 13
      OnClick = cbTrainingClick
    end
  end
  object ListViewMarkets: TListView
    Left = 8
    Top = 143
    Width = 290
    Height = 140
    Columns = <
      item
        Caption = 'Status'
      end
      item
        Caption = 'Code'
        Width = 100
      end
      item
        Alignment = taRightJustify
        Caption = 'Orders'
      end>
    HideSelection = False
    OwnerData = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnData = ListViewMarketsData
    OnSelectItem = ListViewMarketsSelectItem
  end
  object MemoLog: TMemo
    Left = 8
    Top = 312
    Width = 290
    Height = 155
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    TabOrder = 2
  end
  object GroupBoxMarket: TGroupBox
    Left = 304
    Top = 124
    Width = 316
    Height = 343
    Caption = 'Market Details'
    TabOrder = 3
    object Label2: TLabel
      Left = 142
      Top = 23
      Width = 69
      Height = 13
      Caption = 'Market Depth:'
    end
    object Label3: TLabel
      Left = 15
      Top = 185
      Width = 37
      Height = 13
      Caption = 'Orders:'
    end
    object SpeedButtonMarketAbortAllOrders: TSpeedButton
      Left = 15
      Top = 42
      Width = 113
      Height = 22
      Caption = 'Abort All Orders...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButtonMarketAbortAllOrdersClick
    end
    object SpeedButtonMarketFillAllOrders: TSpeedButton
      Left = 15
      Top = 70
      Width = 113
      Height = 22
      Caption = 'Fill All Orders...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButtonMarketFillAllOrdersClick
    end
    object StringGridMarketDepth: TStringGrid
      Left = 142
      Top = 42
      Width = 162
      Height = 149
      ColCount = 3
      DefaultColWidth = 50
      DefaultRowHeight = 13
      FixedCols = 0
      RowCount = 10
      FixedRows = 0
      TabOrder = 0
    end
    object ListViewOrders: TListView
      Left = 15
      Top = 204
      Width = 289
      Height = 125
      Columns = <
        item
          Caption = 'No.'
        end
        item
          Caption = 'Type'
        end
        item
          Caption = 'Account'
          Width = 60
        end
        item
          Alignment = taRightJustify
          Caption = 'Vol'
        end
        item
          Alignment = taRightJustify
          Caption = 'Price'
        end>
      HideSelection = False
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 1
      ViewStyle = vsReport
      OnData = ListViewOrdersData
    end
  end
end
