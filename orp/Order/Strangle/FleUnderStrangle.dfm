object FrmUnderStrangle: TFrmUnderStrangle
  Left = 0
  Top = 0
  Caption = #49440#50577
  ClientHeight = 223
  ClientWidth = 205
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
    Left = 98
    Top = 35
    Width = 8
    Height = 13
    Caption = '~'
  end
  object Label1: TLabel
    Left = 130
    Top = 186
    Width = 12
    Height = 13
    Caption = #47564
  end
  object sg: TStringGrid
    Left = 3
    Top = 208
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
    TabOrder = 14
    ColWidths = (
      49
      126)
  end
  object plRun: TPanel
    Left = 0
    Top = 0
    Width = 205
    Height = 29
    Align = alTop
    BevelInner = bvLowered
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      205
      29)
    object cbRun: TCheckBox
      Left = 162
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
  object sgInput: TStringGrid
    Left = 3
    Top = 55
    Width = 96
    Height = 123
    ColCount = 3
    DefaultColWidth = 30
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 6
    FixedRows = 0
    TabOrder = 1
    OnDrawCell = sgInputDrawCell
    OnMouseDown = sgInputMouseDown
    OnMouseUp = sgInputMouseUp
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
    TabOrder = 2
  end
  object dtEnd: TDateTimePicker
    Left = 108
    Top = 32
    Width = 93
    Height = 21
    Date = 42401.437500000000000000
    Time = 42401.437500000000000000
    DateMode = dmUpDown
    ImeName = 'Microsoft Office IME 2007'
    Kind = dtkTime
    TabOrder = 3
  end
  object edtOrdQty: TLabeledEdit
    Left = 29
    Top = 181
    Width = 32
    Height = 21
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #49688#47049
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    TabOrder = 4
    Text = '1'
    OnKeyPress = edtLiskAmtKeyPress
  end
  object edtLiskAmt: TLabeledEdit
    Left = 92
    Top = 181
    Width = 32
    Height = 21
    Hint = #45800#50948':'#47564#50896
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #49552#51208
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 5
    Text = '20'
    OnKeyPress = edtLiskAmtKeyPress
  end
  object cbUseLiq: TCheckBox
    Left = 155
    Top = 58
    Width = 46
    Height = 17
    Caption = #52397#49328
    TabOrder = 6
  end
  object sgSymbol: TStringGrid
    Tag = 1
    Left = 106
    Top = 121
    Width = 95
    Height = 57
    ColCount = 2
    DefaultColWidth = 45
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 3
    FixedRows = 0
    PopupMenu = PopupMenu1
    TabOrder = 7
    OnDrawCell = sgInputDrawCell
    OnMouseDown = sgSymbolMouseDown
  end
  object rbBuy: TRadioButton
    Left = 155
    Top = 81
    Width = 41
    Height = 17
    Caption = #47588#49688
    TabOrder = 8
  end
  object rbSell: TRadioButton
    Left = 155
    Top = 101
    Width = 41
    Height = 17
    Caption = #47588#46020
    Checked = True
    TabOrder = 9
    TabStop = True
  end
  object Button2: TButton
    Left = 106
    Top = 57
    Width = 31
    Height = 21
    Caption = #51201#50857
    TabOrder = 10
    OnClick = Button2Click
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 204
    Width = 205
    Height = 19
    Panels = <
      item
        Width = 80
      end
      item
        Width = 50
      end>
  end
  object edtEC: TLabeledEdit
    Left = 175
    Top = 181
    Width = 26
    Height = 21
    Hint = #54943#49688
    EditLabel.Width = 24
    EditLabel.Height = 13
    EditLabel.Caption = #54924#49688
    ImeName = 'Microsoft Office IME 2007'
    LabelPosition = lpLeft
    ParentShowHint = False
    ShowHint = True
    TabOrder = 11
    Text = '5'
  end
  object Button1: TButton
    Left = 106
    Top = 94
    Width = 31
    Height = 21
    Caption = #51333#47785
    TabOrder = 12
    OnClick = Button1Click
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 64
    Top = 128
  end
  object PopupMenu1: TPopupMenu
    Left = 144
    Top = 152
    object N1: TMenuItem
      Caption = #51333#47785#49325#51228
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = #51333#47785#51201#50857
      OnClick = N2Click
    end
  end
end
