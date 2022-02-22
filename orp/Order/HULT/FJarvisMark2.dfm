object FrmJarvisMark2: TFrmJarvisMark2
  Left = 0
  Top = 0
  Caption = 'JM2'
  ClientHeight = 378
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 253
    Height = 29
    Align = alTop
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      253
      29)
    object cbStart: TCheckBox
      Left = 204
      Top = 7
      Width = 42
      Height = 14
      Anchors = [akRight, akBottom]
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object edtSymbol: TLabeledEdit
      Left = 117
      Top = 4
      Width = 56
      Height = 21
      EditLabel.Width = 3
      EditLabel.Height = 13
      EditLabel.Caption = ' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 1
    end
    object Button3: TButton
      Left = 175
      Top = 4
      Width = 20
      Height = 21
      Caption = #51333
      TabOrder = 2
      OnClick = Button3Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 89
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 3
    end
    object Button7: TButton
      Left = 94
      Top = 4
      Width = 22
      Height = 21
      Caption = #44228
      TabOrder = 4
      OnClick = Button7Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 29
    Width = 253
    Height = 198
    Align = alTop
    BevelOuter = bvLowered
    TabOrder = 1
    object gbUseHul: TGroupBox
      Left = 3
      Top = 1
      Width = 239
      Height = 36
      TabOrder = 0
      object Label6: TLabel
        Left = 96
        Top = 12
        Width = 8
        Height = 13
        Caption = '~'
      end
      object dtEndTime: TDateTimePicker
        Left = 106
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
        Date = 41547.385416666660000000
        Time = 41547.385416666660000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object Button2: TButton
        Left = 203
        Top = 9
        Width = 30
        Height = 21
        Caption = #51201#50857
        TabOrder = 2
        OnClick = Button2Click
      end
    end
    object GroupBox3: TGroupBox
      Left = 3
      Top = 69
      Width = 246
      Height = 130
      TabOrder = 1
      object Label3: TLabel
        Left = 3
        Top = 82
        Width = 6
        Height = 13
        Caption = 'P'
      end
      object Label4: TLabel
        Left = 3
        Top = 108
        Width = 5
        Height = 13
        Caption = 'L'
      end
      object Label8: TLabel
        Left = 190
        Top = 64
        Width = 45
        Height = 13
        Caption = #44148'  '#51092'  '#54028
      end
      object edtPrfPoint: TLabeledEdit
        Left = 11
        Top = 80
        Width = 26
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 0
        OnKeyPress = edtEntryCntKeyPress
      end
      object edtPrfPoint2: TLabeledEdit
        Left = 39
        Top = 80
        Width = 25
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 1
        Text = '0'
        OnKeyPress = edtEntryCntKeyPress
      end
      object GroupBox4: TGroupBox
        Left = 187
        Top = 75
        Width = 55
        Height = 53
        TabOrder = 2
        object cbProfPara: TCheckBox
          Left = 38
          Top = 10
          Width = 15
          Height = 17
          Hint = #54028#46972
          Caption = 'CheckBox1'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 0
        end
        object cbProfVol: TCheckBox
          Left = 20
          Top = 10
          Width = 15
          Height = 17
          Hint = #51092#47049
          Caption = 'cbProfCnt'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 1
        end
        object cbProfCnt: TCheckBox
          Left = 3
          Top = 10
          Width = 15
          Height = 17
          Hint = #44148#49688
          Caption = 'cbProfCnt'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 2
        end
        object cbLossCnt: TCheckBox
          Left = 3
          Top = 33
          Width = 15
          Height = 17
          Hint = #44148#49688
          Caption = 'CheckBox1'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 3
        end
        object cbLossVol: TCheckBox
          Left = 20
          Top = 33
          Width = 15
          Height = 17
          Hint = #51092#47049
          Caption = 'CheckBox1'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 4
        end
        object cbLossPara: TCheckBox
          Left = 38
          Top = 33
          Width = 15
          Height = 17
          Hint = #54028#46972
          Caption = 'CheckBox1'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 5
        end
      end
      object edtLimitAmt: TLabeledEdit
        Left = 39
        Top = 105
        Width = 25
        Height = 21
        Hint = #49552#51208#44552#50529
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '200'
        OnKeyPress = edtQtyKeyPress
      end
      object edtLimitPlus: TLabeledEdit
        Left = 11
        Top = 105
        Width = 26
        Height = 21
        Hint = #51060#51061#51228#54620
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = '200'
        OnKeyPress = edtQtyKeyPress
      end
    end
    object GroupBox1: TGroupBox
      Left = 4
      Top = 36
      Width = 237
      Height = 36
      TabOrder = 2
      object Label2: TLabel
        Left = 3
        Top = 14
        Width = 22
        Height = 13
        Caption = #49688#47049
      end
      object Label5: TLabel
        Left = 74
        Top = 14
        Width = 22
        Height = 13
        Caption = #54924#49688
      end
      object edtQty: TEdit
        Left = 29
        Top = 10
        Width = 22
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '2'
        OnKeyPress = edtQtyKeyPress
      end
      object udQty: TUpDown
        Left = 51
        Top = 10
        Width = 15
        Height = 21
        Associate = edtQty
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 1
      end
      object edtNum: TEdit
        Left = 101
        Top = 10
        Width = 22
        Height = 21
        Hint = #49688#47049
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '2'
        OnKeyPress = edtQtyKeyPress
      end
      object udNum: TUpDown
        Left = 123
        Top = 10
        Width = 15
        Height = 21
        Associate = edtNum
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 3
      end
      object cbPlusOne: TCheckBox
        Left = 144
        Top = 10
        Width = 38
        Height = 21
        Caption = '+1'
        TabOrder = 4
      end
      object cbPause: TCheckBox
        Left = 184
        Top = 13
        Width = 48
        Height = 17
        Caption = 'Pause'
        TabOrder = 5
        Visible = False
        OnClick = cbPauseClick
      end
    end
    object GroupBox2: TGroupBox
      Left = 4
      Top = 75
      Width = 238
      Height = 54
      TabOrder = 3
      object cbCntRatio: TCheckBox
        Left = 3
        Top = 11
        Width = 33
        Height = 17
        Caption = #44148
        Checked = True
        State = cbChecked
        TabOrder = 0
      end
      object edtEntryCnt: TLabeledEdit
        Left = 34
        Top = 8
        Width = 31
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 1
        Text = '0.65'
        OnKeyPress = edtEntryCntKeyPress
      end
      object edtEntryVol: TLabeledEdit
        Left = 104
        Top = 8
        Width = 31
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 2
        Text = '0.65'
        OnKeyPress = edtEntryCntKeyPress
      end
      object cbVolRatio: TCheckBox
        Left = 72
        Top = 11
        Width = 32
        Height = 17
        Caption = #51092
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object edtPara: TLabeledEdit
        Left = 175
        Top = 8
        Width = 31
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 4
        Text = '0.01'
        OnKeyPress = edtEntryCntKeyPress
      end
      object cbPara: TCheckBox
        Left = 139
        Top = 11
        Width = 32
        Height = 17
        Caption = #54028
        Checked = True
        State = cbChecked
        TabOrder = 5
      end
      object stCur: TStaticText
        Left = 4
        Top = 33
        Width = 30
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 6
        Transparent = False
      end
      object stCalcCnt: TStaticText
        Left = 71
        Top = 33
        Width = 30
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 7
        Transparent = False
      end
      object stParaSide: TStaticText
        Left = 142
        Top = 33
        Width = 24
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 8
        Transparent = False
      end
      object Button1: TButton
        Tag = 1
        Left = 173
        Top = 32
        Width = 30
        Height = 19
        Caption = #51201#50857
        TabOrder = 9
        OnClick = Button2Click
      end
      object stVol: TStaticText
        Left = 38
        Top = 33
        Width = 30
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 10
        Transparent = False
      end
      object stCalcVol: TStaticText
        Left = 104
        Top = 33
        Width = 30
        Height = 17
        Alignment = taRightJustify
        AutoSize = False
        BorderStyle = sbsSunken
        Caption = '             '
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 11
        Transparent = False
      end
    end
    object Button4: TButton
      Left = 311
      Top = 139
      Width = 47
      Height = 25
      Caption = 'Test1'
      Enabled = False
      TabOrder = 4
      Visible = False
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 311
      Top = 170
      Width = 47
      Height = 25
      Caption = 'Test2'
      Enabled = False
      TabOrder = 5
      Visible = False
      OnClick = Button5Click
    end
    object Panel3: TPanel
      Left = 67
      Top = 130
      Width = 62
      Height = 68
      BevelOuter = bvNone
      Color = clSilver
      ParentBackground = False
      TabOrder = 6
      object Label1: TLabel
        Left = 20
        Top = 3
        Width = 22
        Height = 13
        Caption = #44148#49688
      end
      object edtPrfCnt: TLabeledEdit
        Left = 3
        Top = 18
        Width = 30
        Height = 21
        EditLabel.Width = 47
        EditLabel.Height = 13
        EditLabel.Caption = 'edtPrfCnt'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 0
        Text = '0.25'
        OnKeyPress = edtEntryCntKeyPress
      end
      object edtPrfCntRate: TLabeledEdit
        Left = 35
        Top = 18
        Width = 26
        Height = 21
        EditLabel.Width = 70
        EditLabel.Height = 13
        EditLabel.Caption = 'edtPrfCntRate'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 1
        Text = '60'
        OnKeyPress = edtQtyKeyPress
      end
      object edtLosCntRate: TLabeledEdit
        Left = 35
        Top = 45
        Width = 25
        Height = 21
        EditLabel.Width = 72
        EditLabel.Height = 13
        EditLabel.Caption = 'edtLosCntRate'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 2
        Text = '60'
        OnKeyPress = edtQtyKeyPress
      end
      object edtLosCnt: TLabeledEdit
        Left = 3
        Top = 45
        Width = 30
        Height = 21
        EditLabel.Width = 49
        EditLabel.Height = 13
        EditLabel.Caption = 'edtLosCnt'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 3
        Text = '0.8'
        OnKeyPress = edtEntryCntKeyPress
      end
    end
    object Panel4: TPanel
      Left = 130
      Top = 130
      Width = 60
      Height = 73
      BevelOuter = bvNone
      Color = clCream
      ParentBackground = False
      TabOrder = 7
      object Label7: TLabel
        Left = 20
        Top = 3
        Width = 22
        Height = 13
        Caption = #51092#47049
      end
      object edtPrfVol: TLabeledEdit
        Left = 1
        Top = 19
        Width = 30
        Height = 21
        EditLabel.Width = 44
        EditLabel.Height = 13
        EditLabel.Caption = 'edtPrfVol'
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 0
        Text = '0.25'
        OnKeyPress = edtEntryCntKeyPress
      end
      object edtPrfVolRate: TLabeledEdit
        Left = 33
        Top = 19
        Width = 26
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 1
        Text = '60'
        OnKeyPress = edtQtyKeyPress
      end
      object edtLosVolRate: TLabeledEdit
        Left = 33
        Top = 44
        Width = 25
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpRight
        TabOrder = 2
        Text = '60'
        OnKeyPress = edtQtyKeyPress
      end
      object edtLosVol: TLabeledEdit
        Left = 1
        Top = 44
        Width = 30
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft IME 2010'
        LabelPosition = lpLeft
        TabOrder = 3
        Text = '0.8'
        OnKeyPress = edtEntryCntKeyPress
      end
    end
    object Button8: TButton
      Left = 364
      Top = 169
      Width = 47
      Height = 25
      Caption = 'Test4'
      Enabled = False
      TabOrder = 8
      Visible = False
      OnClick = Button8Click
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 359
    Width = 253
    Height = 19
    Panels = <
      item
        Style = psOwnerDraw
        Width = 30
      end
      item
        Width = 80
      end
      item
        Width = 50
      end>
    OnDrawPanel = stTxtDrawPanel
  end
  object sgLog: TStringGrid
    Left = 0
    Top = 227
    Width = 253
    Height = 132
    Align = alClient
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 50
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 3
    ColWidths = (
      50
      682)
  end
  object Button6: TButton
    Left = 364
    Top = 167
    Width = 47
    Height = 25
    Caption = 'Test3'
    Enabled = False
    TabOrder = 4
    Visible = False
    OnClick = Button6Click
  end
end
