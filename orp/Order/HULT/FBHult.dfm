object FrmBHult: TFrmBHult
  Left = 0
  Top = 0
  Caption = 'Bamboo'
  ClientHeight = 274
  ClientWidth = 253
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
    Width = 253
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      253
      27)
    object cbStart: TCheckBox
      Left = 201
      Top = 6
      Width = 46
      Height = 18
      Anchors = [akRight, akBottom]
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 1
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 34
      Height = 21
      Caption = #44228#51340
      TabOrder = 2
      OnClick = Button6Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 253
    Height = 181
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object gbUseHul: TGroupBox
      Left = 4
      Top = 143
      Width = 242
      Height = 36
      TabOrder = 0
      object Label6: TLabel
        Left = 99
        Top = 12
        Width = 8
        Height = 13
        Caption = '~'
      end
      object dtEndTime: TDateTimePicker
        Left = 112
        Top = 8
        Width = 93
        Height = 21
        Date = 41547.645833333340000000
        Time = 41547.645833333340000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtStartTime: TDateTimePicker
        Left = 3
        Top = 8
        Width = 92
        Height = 21
        Date = 41547.378472222220000000
        Time = 41547.378472222220000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object Button2: TButton
        Left = 209
        Top = 8
        Width = 30
        Height = 21
        Caption = #51201#50857
        TabOrder = 2
        OnClick = Button2Click
      end
    end
    object GroupBox3: TGroupBox
      Left = 4
      Top = 2
      Width = 83
      Height = 56
      TabOrder = 1
      object Label2: TLabel
        Left = 7
        Top = 13
        Width = 22
        Height = 13
        Caption = #49688#47049
      end
      object Label9: TLabel
        Left = 12
        Top = 35
        Width = 19
        Height = 13
        Caption = 'E_C'
      end
      object edtOrdQty: TEdit
        Left = 36
        Top = 8
        Width = 25
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '1'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object udQty: TUpDown
        Left = 61
        Top = 8
        Width = 15
        Height = 21
        Associate = edtOrdQty
        Min = 1
        Max = 500
        Position = 1
        TabOrder = 1
      end
      object edtOrdCnt: TEdit
        Tag = 2
        Left = 36
        Top = 32
        Width = 25
        Height = 21
        Hint = #49345#49849#54616#46973' N'#48264#50473
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '1'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object udOrdCnt: TUpDown
        Left = 61
        Top = 32
        Width = 15
        Height = 21
        Associate = edtOrdCnt
        Min = 1
        Max = 5
        Position = 1
        TabOrder = 3
      end
    end
    object GroupBox5: TGroupBox
      Left = 4
      Top = 58
      Width = 110
      Height = 88
      Caption = #51652#51077' (And)'
      TabOrder = 2
      OnClick = GroupBox5Click
      object cbEntCntRate: TCheckBox
        Left = 5
        Top = 18
        Width = 48
        Height = 17
        Caption = #44148#49688
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEntCntRateClick
      end
      object cbEntForeign: TCheckBox
        Tag = 1
        Left = 5
        Top = 42
        Width = 50
        Height = 17
        Caption = #50808#51064
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbEntCntRateClick
      end
      object cbEntPoint: TCheckBox
        Tag = 2
        Left = 5
        Top = 65
        Width = 48
        Height = 17
        Caption = 'Point'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = cbEntCntRateClick
      end
      object edtEntCntRate: TLabeledEdit
        Left = 52
        Top = 16
        Width = 30
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 3
        Text = '0.65'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object edtEntForeignQty: TLabeledEdit
        Tag = 1
        Left = 52
        Top = 39
        Width = 30
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 4
        Text = '2000'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtEntPoint1: TLabeledEdit
        Tag = 2
        Left = 52
        Top = 62
        Width = 25
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 5
        Text = '1.5'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object edtEntPoint2: TLabeledEdit
        Tag = 3
        Left = 80
        Top = 62
        Width = 25
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 6
        Text = '2.0'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
    end
    object GroupBox2: TGroupBox
      Left = 117
      Top = 58
      Width = 129
      Height = 88
      Caption = #52397#49328' (And)'
      TabOrder = 3
      OnClick = GroupBox2Click
      object cbLiqCntRate: TCheckBox
        Tag = 4
        Left = 4
        Top = 18
        Width = 47
        Height = 17
        Caption = #44148#49688
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbEntCntRateClick
      end
      object cbLiqForeign: TCheckBox
        Tag = 5
        Left = 4
        Top = 42
        Width = 49
        Height = 17
        Caption = #50808#51064
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbEntCntRateClick
      end
      object cbLiqPoint: TCheckBox
        Tag = 6
        Left = 4
        Top = 65
        Width = 47
        Height = 17
        Caption = 'Point'
        Checked = True
        State = cbChecked
        TabOrder = 2
        OnClick = cbEntCntRateClick
      end
      object edtLiqCntRate: TLabeledEdit
        Tag = 4
        Left = 52
        Top = 16
        Width = 30
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 3
        Text = '0.8'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object edtLiqForeignRate: TLabeledEdit
        Tag = 5
        Left = 52
        Top = 39
        Width = 30
        Height = 21
        Hint = #51652#51077#50808#51064#44228#50557#49688#51032' N%'#51060#54616#51068#46412
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = '0.5'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object edtLiqPoint: TLabeledEdit
        Tag = 6
        Left = 52
        Top = 62
        Width = 30
        Height = 21
        Hint = #49440#47932#51652#51077#44032' '#45824#48708
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Text = '0.75'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object stPoint: TStaticText
        Left = 84
        Top = 62
        Width = 39
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        ParentColor = False
        TabOrder = 6
        Transparent = False
      end
      object stForFutQty: TStaticText
        Left = 84
        Top = 39
        Width = 39
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        ParentColor = False
        TabOrder = 7
        Transparent = False
      end
      object stCntRate: TStaticText
        Left = 84
        Top = 16
        Width = 39
        Height = 21
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        ParentColor = False
        TabOrder = 8
        Transparent = False
      end
    end
    object gbOptCon: TGroupBox
      Left = 90
      Top = 2
      Width = 156
      Height = 58
      Ctl3D = True
      ParentCtl3D = False
      TabOrder = 4
      object edtBelow: TLabeledEdit
        Left = 53
        Top = 9
        Width = 33
        Height = 21
        EditLabel.Width = 22
        EditLabel.Height = 13
        EditLabel.Caption = #51060#54616
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 0
        Text = '1.0'
        OnChange = edtEntCntRateChange
        OnKeyPress = edtBelowKeyPress
      end
      object cbBuy: TCheckBox
        Left = 54
        Top = 35
        Width = 45
        Height = 17
        Hint = #50741#49496' '#51068#46412#47564
        Caption = #47588#49688
        ParentShowHint = False
        ShowHint = False
        TabOrder = 1
      end
      object cbSub: TComboBox
        Left = 3
        Top = 32
        Width = 47
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 2
        Text = #51648#49688
        Items.Strings = (
          #51648#49688
          #48120#45768)
      end
      object cbMarket: TComboBox
        Left = 3
        Top = 9
        Width = 47
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2010'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 3
        Text = #49440#47932
        Items.Strings = (
          #49440#47932
          #50741#49496)
      end
      object cbStopLiq: TCheckBox
        Tag = 100
        Left = 109
        Top = 35
        Width = 43
        Height = 17
        Hint = #51333#47308#49884#52397#49328
        Caption = #51333#52397
        Checked = True
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 4
        OnClick = cbEntCntRateClick
      end
      object edtListAmt: TLabeledEdit
        Left = 118
        Top = 9
        Width = 33
        Height = 21
        Hint = #49552#51208'( '#45800#50948' : '#47564' )'
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        EditLabel.ParentShowHint = False
        EditLabel.ShowHint = True
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Text = '75'
        OnKeyPress = edtOrdQtyKeyPress
      end
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 255
    Width = 253
    Height = 19
    Hint = #51092#44256', '#49440#47932#51652#51077#44032' ,  ('#49345#49849','#54616#46973') '#54788#51116' , '#52572#44256', '#52572#51200' '#49552#51061' '
    Panels = <
      item
        Style = psOwnerDraw
        Width = 30
      end
      item
        Width = 70
      end
      item
        Width = 60
      end>
    ParentShowHint = False
    ShowHint = True
    OnDrawPanel = stTxtDrawPanel
  end
  object Panel3: TPanel
    Left = 0
    Top = 208
    Width = 253
    Height = 47
    Align = alClient
    BevelOuter = bvLowered
    Caption = 'Panel3'
    TabOrder = 3
    object sgLog: TStringGrid
      Left = 1
      Top = 1
      Width = 251
      Height = 45
      Align = alClient
      BorderStyle = bsNone
      ColCount = 2
      Ctl3D = False
      DefaultColWidth = 50
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      ParentCtl3D = False
      TabOrder = 0
      ColWidths = (
        50
        192)
    end
  end
  object refreshTimer: TTimer
    Enabled = False
    OnTimer = refreshTimerTimer
    Left = 88
    Top = 200
  end
end
