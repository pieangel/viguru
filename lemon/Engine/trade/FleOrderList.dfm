object OrderListForm: TOrderListForm
  Left = 0
  Top = 0
  Caption = 'OrderList'
  ClientHeight = 280
  ClientWidth = 939
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548#52404
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 939
    Height = 24
    Align = alTop
    TabOrder = 0
    object cbAcnt: TComboBox
      Left = 2
      Top = 1
      Width = 145
      Height = 20
      Style = csDropDownList
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 0
      TabOrder = 0
      OnSelect = cbAcntSelect
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 24
    Width = 939
    Height = 256
    Align = alClient
    TabOrder = 1
    object sgOrder: TStringGrid
      Left = 1
      Top = 1
      Width = 937
      Height = 254
      Align = alClient
      ColCount = 14
      DefaultColWidth = 60
      DefaultRowHeight = 18
      FixedCols = 0
      RowCount = 2
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = #44404#47548#52404
      Font.Style = []
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
      ParentFont = False
      PopupMenu = popFilter
      ScrollBars = ssVertical
      TabOrder = 0
      OnDblClick = sgOrderDblClick
      OnDrawCell = sgOrderDrawCell
      OnMouseDown = sgOrderMouseDown
    end
  end
  object popFilter: TPopupMenu
    Left = 320
    Top = 152
    object N1: TMenuItem
      Caption = #51217#49688
      Checked = True
      ImageIndex = 0
      OnClick = N1Click
    end
    object n2: TMenuItem
      Tag = 10
      Caption = #52404#44208
      ImageIndex = 0
      OnClick = N1Click
    end
    object N3: TMenuItem
      Tag = 20
      Caption = #51453#51008#51452#47928
      ImageIndex = 0
      OnClick = N1Click
    end
    object N4: TMenuItem
      Tag = 30
      Caption = #51204#52404
      OnClick = N1Click
    end
  end
  object refreshTimer: TTimer
    Interval = 500
    OnTimer = refreshTimerTimer
    Left = 328
    Top = 192
  end
end
