object FrmJikJinHult: TFrmJikJinHult
  Left = 0
  Top = 0
  Caption = #51649#54736
  ClientHeight = 259
  ClientWidth = 245
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
    Width = 245
    Height = 29
    Align = alTop
    BevelOuter = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      245
      29)
    object cbStart: TCheckBox
      Left = 196
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
  object stTxt: TStatusBar
    Left = 0
    Top = 240
    Width = 245
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
  object Panel2: TPanel
    Left = 0
    Top = 29
    Width = 245
    Height = 140
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object gbUseHul: TGroupBox
      Left = 2
      Top = 1
      Width = 237
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
    object GroupBox1: TGroupBox
      Left = 2
      Top = 36
      Width = 237
      Height = 36
      TabOrder = 1
      object Label2: TLabel
        Left = 3
        Top = 14
        Width = 22
        Height = 13
        Caption = #49688#47049
      end
      object Label5: TLabel
        Left = 57
        Top = 14
        Width = 22
        Height = 13
        Caption = #44036#44201
      end
      object Label1: TLabel
        Left = 113
        Top = 14
        Width = 22
        Height = 13
        Caption = #54943#49688
      end
      object edtQty: TEdit
        Left = 29
        Top = 10
        Width = 22
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '1'
        OnKeyPress = edtQtyKeyPress
      end
      object edtIntervalTick: TEdit
        Left = 84
        Top = 10
        Width = 22
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '5'
        OnKeyPress = edtQtyKeyPress
      end
      object edtNumber: TEdit
        Left = 141
        Top = 10
        Width = 22
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '5'
        OnKeyPress = edtQtyKeyPress
      end
      object cbStopLiq: TCheckBox
        Tag = 100
        Left = 188
        Top = 12
        Width = 43
        Height = 17
        Hint = #51333#47308#49884#52397#49328
        Caption = #51333#52397
        Checked = True
        ParentShowHint = False
        ShowHint = True
        State = cbChecked
        TabOrder = 3
      end
    end
    object GroupBox2: TGroupBox
      Left = 2
      Top = 71
      Width = 237
      Height = 36
      TabOrder = 2
      object edtCntRatio: TEdit
        Left = 34
        Top = 8
        Width = 29
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '0.65'
        OnKeyPress = edtVolRatioKeyPress
      end
      object edtVolRatio: TEdit
        Left = 101
        Top = 8
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '0.65'
        OnKeyPress = edtVolRatioKeyPress
      end
      object cbDefTick: TCheckBox
        Left = 138
        Top = 11
        Width = 34
        Height = 17
        Caption = #54001
        Checked = True
        State = cbChecked
        TabOrder = 2
      end
      object cbCntRatio: TCheckBox
        Left = 4
        Top = 11
        Width = 30
        Height = 17
        Caption = #44148
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object cbVolRatio: TCheckBox
        Left = 71
        Top = 11
        Width = 30
        Height = 17
        Caption = #51092
        TabOrder = 4
      end
      object edtDefTick: TEdit
        Left = 168
        Top = 8
        Width = 21
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 5
        Text = '5'
        OnKeyPress = edtQtyKeyPress
      end
      object cbOpenPrc: TCheckBox
        Left = 194
        Top = 11
        Width = 41
        Height = 17
        Caption = #49884#44032
        Checked = True
        State = cbChecked
        TabOrder = 6
      end
    end
    object GroupBox3: TGroupBox
      Left = 3
      Top = 106
      Width = 237
      Height = 34
      TabOrder = 3
      object Label3: TLabel
        Left = 129
        Top = 13
        Width = 22
        Height = 13
        Caption = #49552#51208
      end
      object Label4: TLabel
        Left = 3
        Top = 13
        Width = 22
        Height = 13
        Caption = #51060#51061
      end
      object Label7: TLabel
        Left = 64
        Top = 13
        Width = 14
        Height = 13
        Caption = '>1'
      end
      object lbCurPL: TLabel
        Left = 91
        Top = 13
        Width = 3
        Height = 13
      end
      object Label8: TLabel
        Left = 195
        Top = 14
        Width = 37
        Height = 13
        Caption = #45800#50948':'#47564
      end
      object edtLossAmt: TEdit
        Left = 157
        Top = 10
        Width = 36
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        Text = '200'
        OnKeyPress = edtQtyKeyPress
      end
      object edtPlusAmt: TEdit
        Left = 28
        Top = 9
        Width = 32
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '200'
        OnKeyPress = edtQtyKeyPress
      end
    end
  end
  object sgLog: TStringGrid
    Left = 0
    Top = 169
    Width = 245
    Height = 52
    Align = alClient
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 50
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    TabOrder = 3
    OnDblClick = sgLogDblClick
    ExplicitHeight = 71
    ColWidths = (
      50
      175)
  end
  object stTxt2: TStatusBar
    Left = 0
    Top = 221
    Width = 245
    Height = 19
    Panels = <
      item
        Width = 300
      end
      item
        Width = 50
      end>
    ExplicitLeft = 88
    ExplicitTop = 216
    ExplicitWidth = 0
  end
  object Timer1: TTimer
    Enabled = False
    OnTimer = Timer1Timer
    Left = 104
    Top = 24
  end
end
