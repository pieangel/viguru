object FrmBondTrends: TFrmBondTrends
  Left = 0
  Top = 0
  Caption = 'Bond Trend'
  ClientHeight = 220
  ClientWidth = 249
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
    Top = 29
    Width = 249
    Height = 134
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object TGroupBox
      Left = 0
      Top = 0
      Width = 249
      Height = 51
      TabOrder = 0
      object Label2: TLabel
        Left = 5
        Top = 28
        Width = 24
        Height = 13
        Caption = #51652#51077
      end
      object Label4: TLabel
        Left = 134
        Top = 7
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label3: TLabel
        Left = 5
        Top = 8
        Width = 24
        Height = 13
        Caption = #49884#51089
      end
      object dtEnd: TDateTimePicker
        Left = 148
        Top = 26
        Width = 97
        Height = 21
        Date = 42401.647222222220000000
        Time = 42401.647222222220000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object dtEntend: TDateTimePicker
        Left = 148
        Top = 4
        Width = 97
        Height = 21
        Date = 42401.604166666660000000
        Time = 42401.604166666660000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 1
      end
      object dtStart2: TDateTimePicker
        Left = 31
        Top = 26
        Width = 97
        Height = 21
        Date = 42401.437500000000000000
        Time = 42401.437500000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 2
      end
      object dtStart: TDateTimePicker
        Left = 31
        Top = 4
        Width = 97
        Height = 21
        Date = 42401.375694444450000000
        Time = 42401.375694444450000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 3
      end
    end
    object GroupBox2: TGroupBox
      Left = 0
      Top = 53
      Width = 249
      Height = 51
      TabOrder = 1
      object edtOrdQty: TLabeledEdit
        Left = 28
        Top = 4
        Width = 23
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = #51452#47928
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        TabOrder = 0
        Text = '1'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtE_C: TLabeledEdit
        Left = 75
        Top = 4
        Width = 30
        Height = 21
        EditLabel.Width = 19
        EditLabel.Height = 13
        EditLabel.Caption = 'E_C'
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '0.8'
        OnKeyPress = edtE_SKeyPress
      end
      object edtE_S: TLabeledEdit
        Left = 129
        Top = 4
        Width = 35
        Height = 21
        EditLabel.Width = 18
        EditLabel.Height = 13
        EditLabel.Caption = 'E_S'
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '0.66'
        OnKeyPress = edtE_SKeyPress
      end
      object edtEC: TLabeledEdit
        Left = 28
        Top = 26
        Width = 23
        Height = 21
        EditLabel.Width = 17
        EditLabel.Height = 13
        EditLabel.Caption = 'E.C'
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '2'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtE_S2: TLabeledEdit
        Left = 94
        Top = 26
        Width = 35
        Height = 21
        EditLabel.Width = 24
        EditLabel.Height = 13
        EditLabel.Caption = 'E_S2'
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 4
        Text = '0.7'
        OnKeyPress = edtE_SKeyPress
      end
      object cbLeftCon: TComboBox
        Left = 146
        Top = 26
        Width = 47
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        ItemIndex = 1
        TabOrder = 5
        Text = #51333#44032
        Items.Strings = (
          #49884#44032
          #51333#44032)
      end
      object cbRightCon: TComboBox
        Left = 197
        Top = 26
        Width = 47
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 6
        Text = #49884#44032
        Items.Strings = (
          #49884#44032
          #51204#51333)
      end
      object cbUseFillter: TCheckBox
        Left = 176
        Top = 6
        Width = 97
        Height = 17
        Caption = #8595#49324#50857
        Checked = True
        State = cbChecked
        TabOrder = 7
        OnClick = cbUseFillterClick
      end
    end
    object GroupBox3: TGroupBox
      Left = 0
      Top = 103
      Width = 249
      Height = 28
      TabOrder = 2
      object cbTrailingStop: TCheckBox
        Left = 5
        Top = 4
        Width = 43
        Height = 17
        Caption = 'T. S.'
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbTrailingStopClick
      end
      object edtStopMax: TLabeledEdit
        Left = 44
        Top = 3
        Width = 30
        Height = 21
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        Text = '60'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object edtStopPer: TLabeledEdit
        Left = 75
        Top = 3
        Width = 26
        Height = 21
        EditLabel.Width = 11
        EditLabel.Height = 13
        EditLabel.Caption = '%'
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpRight
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        Text = '30'
        OnKeyPress = edtE_SKeyPress
      end
      object edtLiskAmt: TLabeledEdit
        Left = 123
        Top = 3
        Width = 28
        Height = 21
        Hint = #54620#46020#49444#51221
        EditLabel.Width = 3
        EditLabel.Height = 13
        EditLabel.Caption = ' '
        ImeName = 'Microsoft Office IME 2007'
        LabelPosition = lpLeft
        ParentShowHint = False
        ShowHint = True
        TabOrder = 3
        Text = '16'
        OnKeyPress = edtOrdQtyKeyPress
      end
      object cbEndLiq: TCheckBox
        Left = 162
        Top = 5
        Width = 44
        Height = 17
        Caption = #51333#52397
        Checked = True
        State = cbChecked
        TabOrder = 4
        OnClick = cbEndLiqClick
      end
      object Button2: TButton
        Left = 213
        Top = 3
        Width = 31
        Height = 21
        Caption = #51201#50857
        TabOrder = 5
        OnClick = Button2Click
      end
    end
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 249
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      249
      29)
    object cbRun: TCheckBox
      Left = 206
      Top = 6
      Width = 39
      Height = 17
      Anchors = [akTop, akRight]
      Caption = 'Run'
      TabOrder = 0
      OnClick = cbRunClick
    end
    object Button6: TButton
      Left = 104
      Top = 4
      Width = 22
      Height = 21
      Caption = #44228
      TabOrder = 1
      OnClick = Button6Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 4
      Width = 100
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 2
    end
    object cbStgType: TComboBox
      Left = 135
      Top = 4
      Width = 47
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 3
      Text = 'TR'
      OnChange = cbStgTypeChange
      Items.Strings = (
        'TR'
        'IN')
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 163
    Width = 249
    Height = 38
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 3
    object sg: TStringGrid
      Left = 0
      Top = 0
      Width = 249
      Height = 38
      Align = alClient
      ColCount = 2
      Ctl3D = False
      DefaultColWidth = 60
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 0
      ColWidths = (
        49
        731)
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 201
    Width = 249
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
        Width = 100
      end>
    OnDrawPanel = stTxtDrawPanel
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 80
    Top = 32
  end
end
