object FrmMiniPosList: TFrmMiniPosList
  Left = 0
  Top = 0
  Caption = #48120#45768#51092#44256
  ClientHeight = 262
  ClientWidth = 192
  Color = clBtnFace
  Constraints.MaxWidth = 208
  Constraints.MinWidth = 208
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
  object p1: TPanel
    Left = 0
    Top = 0
    Width = 192
    Height = 26
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object cbAccount: TComboBox
      Left = 1
      Top = 2
      Width = 124
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object ShowStg: TCheckBox
      Left = 160
      Top = 3
      Width = 29
      Height = 17
      Caption = 'S'
      TabOrder = 1
      Visible = False
      OnClick = Show0NetClick
    end
    object ShowUnit: TCheckBox
      Left = 129
      Top = 3
      Width = 27
      Height = 17
      Hint = #52380#45800#50948' '#49552#51061
      Caption = 'U'
      Checked = True
      State = cbChecked
      TabOrder = 2
      OnClick = ShowUnitClick
    end
    object btnQuery: TButton
      Left = 137
      Top = 26
      Width = 33
      Height = 21
      Caption = #51312#54924
      TabOrder = 3
      Visible = False
      OnClick = btnQueryClick
    end
  end
  object sgTop: TStringGrid
    Left = 0
    Top = 26
    Width = 192
    Height = 77
    Align = alTop
    ColCount = 2
    Ctl3D = False
    DefaultRowHeight = 18
    DefaultDrawing = False
    RowCount = 4
    FixedRows = 0
    ParentCtl3D = False
    TabOrder = 1
    OnDrawCell = sgTopDrawCell
    ColWidths = (
      64
      196)
  end
  object Panel1: TPanel
    Left = 0
    Top = 103
    Width = 192
    Height = 2
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
  end
  object sgBottom: TStringGrid
    Left = 0
    Top = 105
    Width = 192
    Height = 157
    Align = alClient
    ColCount = 4
    Ctl3D = False
    DefaultColWidth = 50
    DefaultRowHeight = 18
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 3
    OnDblClick = sgBottomDblClick
    OnDrawCell = sgBottomDrawCell
    OnMouseDown = sgBottomMouseDown
    ColWidths = (
      50
      23
      55
      59)
  end
  object RefreshTimer: TTimer
    OnTimer = RefreshTimerTimer
    Left = 96
    Top = 200
  end
  object PopupMenu1: TPopupMenu
    Left = 96
    Top = 168
    object mTotal: TMenuItem
      Caption = #52509#49552#51061
      OnClick = mTotalClick
    end
  end
end
