object FrmInvestStrangle: TFrmInvestStrangle
  Left = 0
  Top = 0
  Caption = #53804#50577
  ClientHeight = 348
  ClientWidth = 209
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
  object Label2: TLabel
    Left = 100
    Top = 35
    Width = 8
    Height = 13
    Caption = '~'
  end
  object rgOrdMethod: TRadioGroup
    Left = 4
    Top = 192
    Width = 131
    Height = 52
    Columns = 2
    ItemIndex = 1
    Items.Strings = (
      #47588#49688
      #47588#46020
      #47588#49688' SP'
      #47588#46020' SP')
    TabOrder = 12
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 209
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      209
      29)
    object cbRun: TCheckBox
      Left = 166
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
  end
  object cbInvest: TComboBox
    Left = 3
    Top = 56
    Width = 45
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    ItemHeight = 13
    ItemIndex = 0
    TabOrder = 1
    Text = #50808#44060
    Items.Strings = (
      #50808#44060
      #44552#44060)
  end
  object cbInvest2: TComboBox
    Left = 156
    Top = 56
    Width = 45
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    ItemHeight = 13
    ItemIndex = 1
    TabOrder = 3
    Text = #44552#50997
    Items.Strings = (
      #50808#51064
      #44552#50997
      #44060#51064)
  end
  object cbUseCnt: TCheckBox
    Tag = 2
    Left = 143
    Top = 221
    Width = 48
    Height = 17
    Caption = #44148#49688
    Checked = True
    State = cbChecked
    TabOrder = 5
    OnClick = cbUseCntClick
  end
  object edtOrdQty: TLabeledEdit
    Left = 13
    Top = 246
    Width = 27
    Height = 21
    Hint = #51452#47928#49688#47049
    EditLabel.Width = 8
    EditLabel.Height = 13
    EditLabel.Caption = 'O'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 6
    Text = '1'
    OnKeyPress = edtECKeyPress
  end
  object edtEC: TLabeledEdit
    Left = 175
    Top = 246
    Width = 26
    Height = 21
    Hint = #54943#49688
    EditLabel.Width = 7
    EditLabel.Height = 13
    EditLabel.Caption = 'C'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 7
    Text = '5'
    OnKeyPress = edtECKeyPress
  end
  object dtStart: TDateTimePicker
    Left = 3
    Top = 32
    Width = 95
    Height = 21
    Date = 42401.375347222220000000
    Time = 42401.375347222220000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 8
  end
  object dtEnd: TDateTimePicker
    Left = 112
    Top = 32
    Width = 93
    Height = 21
    Date = 42401.437500000000000000
    Time = 42401.437500000000000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 9
  end
  object edtLiskAmt: TLabeledEdit
    Left = 125
    Top = 246
    Width = 27
    Height = 21
    Hint = #49552#51208#44552#50529'('#47564#45800#50948')'
    EditLabel.Width = 5
    EditLabel.Height = 13
    EditLabel.Caption = 'L'
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 10
    Text = '10'
    OnKeyPress = edtECKeyPress
  end
  object cbUseLiq: TCheckBox
    Left = 105
    Top = 57
    Width = 46
    Height = 17
    Caption = #52397#49328
    TabOrder = 11
    OnClick = cbUseCntClick
  end
  object sgInvest: TStringGrid
    Left = 3
    Top = 78
    Width = 96
    Height = 123
    ColCount = 3
    DefaultColWidth = 30
    DefaultRowHeight = 19
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    TabOrder = 2
    OnDrawCell = sgInvestDrawCell
    OnMouseDown = sgInvestMouseDown
    OnMouseUp = sgInvestMouseUp
  end
  object sgInvest2: TStringGrid
    Tag = 1
    Left = 105
    Top = 78
    Width = 96
    Height = 123
    ColCount = 3
    DefaultColWidth = 30
    DefaultRowHeight = 19
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    TabOrder = 4
    OnDrawCell = sgInvestDrawCell
    OnMouseDown = sgInvestMouseDown
    OnMouseUp = sgInvestMouseUp
  end
  object Button2: TButton
    Left = 59
    Top = 56
    Width = 31
    Height = 21
    Caption = #51201#50857
    TabOrder = 13
    OnClick = Button2Click
  end
  object cbUseInvest: TCheckBox
    Tag = 1
    Left = 143
    Top = 203
    Width = 48
    Height = 17
    Hint = #53804#51088#51088'1 '#44284' '#44057#51008' '#48169#54693
    Caption = #53804#51088
    ParentShowHint = False
    ShowHint = True
    TabOrder = 14
    OnClick = cbUseCntClick
  end
  object sg: TStringGrid
    Left = 3
    Top = 273
    Width = 198
    Height = 152
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 60
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    TabOrder = 16
    ColWidths = (
      49
      126)
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 329
    Width = 209
    Height = 19
    Panels = <
      item
        Width = 110
      end
      item
        Width = 50
      end>
  end
  object edtRvsAmt: TLabeledEdit
    Left = 80
    Top = 246
    Width = 27
    Height = 21
    Hint = #48152#45824#51452#47928'( '#47564#45800#50948')'
    EditLabel.Width = 3
    EditLabel.Height = 13
    EditLabel.Caption = ' '
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 17
    Text = '5'
    OnKeyPress = edtECKeyPress
  end
  object cbUseHedge: TCheckBox
    Tag = 3
    Left = 49
    Top = 247
    Width = 25
    Height = 17
    Caption = 'H'
    Checked = True
    ParentShowHint = False
    ShowHint = False
    State = cbChecked
    TabOrder = 18
    OnClick = cbUseCntClick
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 144
    Top = 120
  end
end
