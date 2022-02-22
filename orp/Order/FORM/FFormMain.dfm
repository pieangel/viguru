object FormMain: TFormMain
  Left = 44
  Top = 0
  Caption = #46041#49884#54840#44032' '#51452#47928#52376#47532
  ClientHeight = 603
  ClientWidth = 296
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
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 296
    Height = 29
    Align = alTop
    ParentColor = True
    TabOrder = 0
    object BtnCohesionSymbol: TSpeedButton
      Left = 267
      Top = 5
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = BtnCohesionSymbolClick
    end
    object cbSymbol: TComboBox
      Left = 156
      Top = 5
      Width = 98
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbSymbolChange
    end
    object ComboAccount: TComboBox
      Left = 4
      Top = 5
      Width = 148
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 584
    Width = 296
    Height = 19
    Panels = <
      item
        Width = 90
      end
      item
        Width = 90
      end
      item
        Width = 50
      end>
  end
  object GroupBox3: TGroupBox
    Left = 0
    Top = 30
    Width = 293
    Height = 363
    BiDiMode = bdLeftToRight
    Caption = #46041#49884#54840#44032' '#49884#51089#51204' '#51452#47928#52376#47532
    Color = clBtnFace
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentBiDiMode = False
    ParentColor = False
    ParentCtl3D = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 2
    object GroupBox1: TGroupBox
      Left = 7
      Top = 16
      Width = 278
      Height = 163
      BiDiMode = bdLeftToRight
      Caption = 'K200'
      Color = clBtnFace
      Ctl3D = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentBiDiMode = False
      ParentColor = False
      ParentCtl3D = False
      ParentFont = False
      TabOrder = 0
      object Label11: TLabel
        Left = 30
        Top = 16
        Width = 55
        Height = 13
        Caption = #51204#51068#51333#44032' :'
      end
      object Label12: TLabel
        Left = 6
        Top = 39
        Width = 79
        Height = 13
        Caption = #48288#51060#49884#49828#48276#50948' :'
      end
      object Label16: TLabel
        Left = 195
        Top = 40
        Width = 14
        Height = 13
        Caption = 'A :'
      end
      object Label17: TLabel
        Left = 30
        Top = 88
        Width = 55
        Height = 13
        Caption = #50696#49345#46321#46973' :'
      end
      object Label18: TLabel
        Left = 11
        Top = 111
        Width = 74
        Height = 13
        Caption = #50696#49345#46321#46973'(%) :'
      end
      object Label20: TLabel
        Left = 134
        Top = 39
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label21: TLabel
        Left = 6
        Top = 134
        Width = 79
        Height = 13
        Caption = #45817#51068#50696#49345#51648#49688' :'
      end
      object edtPrevBasisLow: TEdit
        Left = 91
        Top = 36
        Width = 40
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        Text = '0'
        OnChange = edtPrevBasisLowChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtPrevBasisHigh: TEdit
        Left = 148
        Top = 36
        Width = 40
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '0'
        OnChange = edtPrevBasisLowChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtPrevBasisAvg: TEdit
        Left = 215
        Top = 38
        Width = 40
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 2
        OnChange = edtPrevBasisAvgChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtExUpDown: TEdit
        Left = 91
        Top = 85
        Width = 48
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 3
        Text = '0'
        OnChange = edtExUpDownChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtExUpDownPer: TEdit
        Tag = 1
        Left = 91
        Top = 108
        Width = 48
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = '0'
        OnChange = edtExUpDownChange
        OnKeyPress = edtBaseKeyPress
      end
      object stIndex: TStaticText
        Left = 143
        Top = 134
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BiDiMode = bdLeftToRight
        BorderStyle = sbsSunken
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowAccelChar = False
        ShowHint = False
        TabOrder = 5
        Transparent = False
      end
      object stExUpDown: TStaticText
        Left = 143
        Top = 85
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 6
        Transparent = False
      end
      object stExUpDownPer: TStaticText
        Left = 143
        Top = 109
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 7
        Transparent = False
      end
      object stCalcIndex: TStaticText
        Left = 91
        Top = 134
        Width = 48
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 8
      end
      object stPrevClose: TStaticText
        Left = 91
        Top = 12
        Width = 40
        Height = 20
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 9
      end
      object StaticText1: TStaticText
        Left = 189
        Top = 85
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 10
      end
      object StaticText2: TStaticText
        Left = 189
        Top = 109
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 11
      end
      object StaticText3: TStaticText
        Left = 189
        Top = 134
        Width = 43
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 12
      end
      object StaticText4: TStaticText
        Left = 91
        Top = 65
        Width = 48
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = #51077#47141#44050
        TabOrder = 13
      end
      object StaticText5: TStaticText
        Left = 143
        Top = 65
        Width = 43
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = #49688#49888#44050
        TabOrder = 14
      end
      object StaticText6: TStaticText
        Left = 189
        Top = 65
        Width = 43
        Height = 17
        Alignment = taCenter
        AutoSize = False
        Caption = #50724' '#52264
        TabOrder = 15
      end
    end
    object GroupBox2: TGroupBox
      Left = 7
      Top = 183
      Width = 278
      Height = 172
      BiDiMode = bdLeftToRight
      Caption = #49440#47932
      Color = clBtnFace
      Ctl3D = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBackground = False
      ParentBiDiMode = False
      ParentColor = False
      ParentCtl3D = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 1
      object Label1: TLabel
        Left = 42
        Top = 19
        Width = 43
        Height = 13
        Alignment = taRightJustify
        Caption = #44592#51456#44032' :'
      end
      object Label2: TLabel
        Left = 30
        Top = 97
        Width = 55
        Height = 13
        Alignment = taRightJustify
        Caption = #51452#47928#49688#47049' :'
      end
      object Label3: TLabel
        Left = 30
        Top = 144
        Width = 55
        Height = 13
        Alignment = taRightJustify
        Caption = #51452#47928#44036#44201' :'
      end
      object Label4: TLabel
        Left = 30
        Top = 121
        Width = 55
        Height = 13
        Alignment = taRightJustify
        Caption = #51452#47928#44148#49688' :'
      end
      object Label7: TLabel
        Left = 151
        Top = 144
        Width = 23
        Height = 13
        Caption = 'TICK'
      end
      object lbSum: TLabel
        Left = 148
        Top = 120
        Width = 31
        Height = 13
        AutoSize = False
      end
      object Label14: TLabel
        Left = 29
        Top = 43
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Caption = #47588#46020' Shift :'
      end
      object Label15: TLabel
        Left = 29
        Top = 65
        Width = 56
        Height = 13
        Alignment = taRightJustify
        Caption = #47588#49688' Shift :'
      end
      object edtBase: TEdit
        Left = 91
        Top = 14
        Width = 55
        Height = 21
        Hint = #50696#49345#51648#49688' + '#51204#51068#48288#51060#49884#49828#54217#44512
        ImeName = 'Microsoft IME 2003'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtQty: TEdit
        Left = 91
        Top = 91
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '3'
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object udQty: TUpDown
        Left = 127
        Top = 91
        Width = 15
        Height = 21
        Associate = edtQty
        Position = 3
        TabOrder = 2
      end
      object edtGap: TEdit
        Left = 91
        Top = 141
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 3
        Text = '1'
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtCnt: TEdit
        Left = 91
        Top = 114
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = '20'
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object udCnt: TUpDown
        Left = 127
        Top = 114
        Width = 15
        Height = 21
        Associate = edtCnt
        Position = 20
        TabOrder = 5
      end
      object udGap: TUpDown
        Left = 127
        Top = 141
        Width = 15
        Height = 21
        Associate = edtGap
        Position = 1
        TabOrder = 6
      end
      object edtAskShift: TEdit
        Left = 91
        Top = 38
        Width = 51
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 7
        Text = '0.2'
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object edtBidShift: TEdit
        Left = 91
        Top = 62
        Width = 51
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 8
        Text = '0.2'
        OnChange = edtBaseChange
        OnKeyPress = edtBaseKeyPress
      end
      object stAskRange: TStaticText
        Left = 146
        Top = 38
        Width = 95
        Height = 21
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 9
      end
      object stBidRange: TStaticText
        Left = 146
        Top = 62
        Width = 95
        Height = 21
        AutoSize = False
        BorderStyle = sbsSunken
        TabOrder = 10
      end
      object btnFutCalc: TButton
        Left = 150
        Top = 14
        Width = 43
        Height = 21
        Caption = 'Calc'
        TabOrder = 11
        OnClick = btnFutCalcClick
      end
      object Button1: TButton
        Left = 195
        Top = 91
        Width = 75
        Height = 22
        Caption = 'Log File'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 12
        OnClick = Button1Click
      end
    end
    object btnOrder: TButton
      Left = 202
      Top = 325
      Width = 75
      Height = 20
      BiDiMode = bdLeftToRight
      Caption = #51452#47928#51204#49569
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 2
      OnClick = btnOrderClick
    end
    object btnSH: TButton
      Left = 7
      Top = 383
      Width = 75
      Height = 20
      BiDiMode = bdLeftToRight
      Caption = #49704#44592#44592
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 3
      Visible = False
      OnClick = btnSHClick
    end
  end
  object gbJangStart: TGroupBox
    Left = 0
    Top = 502
    Width = 293
    Height = 82
    Caption = #46041#49884#54840#44032' '#47560#44048' '#52376#47532
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 3
    object Label6: TLabel
      Left = 155
      Top = 32
      Width = 56
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #47588#46020' Shift :'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
    end
    object Label5: TLabel
      Left = 155
      Top = 53
      Width = 56
      Height = 13
      Alignment = taRightJustify
      BiDiMode = bdLeftToRight
      Caption = #47588#49688' Shift :'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
    end
    object DateTimePickerTime: TDateTimePicker
      Left = 12
      Top = 47
      Width = 102
      Height = 21
      BiDiMode = bdLeftToRight
      Date = 38303.375011574080000000
      Time = 38303.375011574080000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Korean Input System (IME 2000)'
      Kind = dtkTime
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnChange = edtBidShift2Change
    end
    object edtBidShift2: TEdit
      Left = 215
      Top = 51
      Width = 51
      Height = 21
      BiDiMode = bdLeftToRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 1
      Text = '0.2'
      OnChange = edtBidShift2Change
      OnKeyPress = edtBaseKeyPress
    end
    object edtAskShift2: TEdit
      Left = 215
      Top = 27
      Width = 51
      Height = 21
      BiDiMode = bdLeftToRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 2
      Text = '0.2'
      OnChange = edtBidShift2Change
      OnKeyPress = edtBaseKeyPress
    end
    object CheckBox2: TCheckBox
      Tag = 100
      Left = 13
      Top = 19
      Width = 47
      Height = 17
      BiDiMode = bdLeftToRight
      Caption = #49892#54665
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentColor = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 3
      OnClick = CheckBox2Click
    end
  end
  object gbSimulEnd: TGroupBox
    Left = 0
    Top = 401
    Width = 293
    Height = 97
    Caption = #46041#49884#54840#44032' '#47560#44048' '#51649#51204' '#52376#47532' '
    Color = clBtnFace
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentBackground = False
    ParentColor = False
    ParentFont = False
    TabOrder = 4
    object Label9: TLabel
      Left = 130
      Top = 23
      Width = 36
      Height = 13
      BiDiMode = bdLeftToRight
      Caption = 'Upper :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
    end
    object Label10: TLabel
      Left = 130
      Top = 46
      Width = 36
      Height = 13
      BiDiMode = bdLeftToRight
      Caption = 'Lower :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
    end
    object Label13: TLabel
      Left = 123
      Top = 69
      Width = 43
      Height = 13
      BiDiMode = bdLeftToRight
      Caption = #50668#50976#44050' :'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
    end
    object DateCancelTime: TDateTimePicker
      Left = 12
      Top = 49
      Width = 102
      Height = 21
      BiDiMode = bdLeftToRight
      Date = 38303.374305555550000000
      Time = 38303.374305555550000000
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Korean Input System (IME 2000)'
      Kind = dtkTime
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 0
      OnChange = edtUpperBasisChange
    end
    object edtUpperBasis: TEdit
      Left = 172
      Top = 18
      Width = 39
      Height = 21
      BiDiMode = bdLeftToRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 1
      Text = '0'
      OnChange = edtUpperBasisChange
      OnKeyPress = edtBaseKeyPress
    end
    object edtLowerBasis: TEdit
      Left = 172
      Top = 42
      Width = 39
      Height = 21
      BiDiMode = bdLeftToRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 2
      Text = '0'
      OnChange = edtUpperBasisChange
      OnKeyPress = edtBaseKeyPress
    end
    object edtDelay: TEdit
      Left = 172
      Top = 66
      Width = 39
      Height = 21
      BiDiMode = bdLeftToRight
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ImeName = 'Microsoft IME 2003'
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 3
      Text = '0.2'
      OnChange = edtUpperBasisChange
      OnKeyPress = edtBaseKeyPress
    end
    object btnCalc: TButton
      Left = 215
      Top = 66
      Width = 43
      Height = 21
      BiDiMode = bdLeftToRight
      Caption = 'Calc'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 4
      OnClick = btnCalcClick
    end
    object cbSimulEnd: TCheckBox
      Tag = 200
      Left = 13
      Top = 20
      Width = 47
      Height = 17
      BiDiMode = bdLeftToRight
      Caption = #49892#54665
      Color = clBtnFace
      Ctl3D = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentColor = False
      ParentCtl3D = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = False
      TabOrder = 5
      OnClick = CheckBox2Click
    end
    object StaticText7: TStaticText
      Left = 215
      Top = 42
      Width = 49
      Height = 17
      Hint = #50696#49345#51648#49688'+'#51204#51068#48288#51060#49884#49828#44256#44032'-'#50668#50976#44050
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      BorderStyle = sbsSunken
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
    end
    object StaticText8: TStaticText
      Left = 215
      Top = 18
      Width = 49
      Height = 18
      Hint = #50696#49345#51648#49688'+'#51204#51068#48288#51060#49884#49828#44256#44032'+'#50668#50976#44050
      Alignment = taRightJustify
      AutoSize = False
      BiDiMode = bdLeftToRight
      BorderStyle = sbsSunken
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentBiDiMode = False
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 7
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 184
    Top = 128
  end
end
