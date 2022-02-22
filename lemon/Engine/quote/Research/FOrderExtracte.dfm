object FrmOrderExtracte: TFrmOrderExtracte
  Left = 0
  Top = 0
  Caption = #51452#47928' '#52628#52636
  ClientHeight = 293
  ClientWidth = 486
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548#52404
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
    Width = 486
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 49
      Height = 13
      Caption = #51333#47785' : '
    end
    object spEx: TSpeedButton
      Left = 392
      Top = 1
      Width = 65
      Height = 22
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Expansion'
      OnClick = spExClick
    end
    object cbSymbol: TComboBox
      Left = 40
      Top = 2
      Width = 109
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbSymbolChange
    end
    object btnSymbol: TButton
      Left = 154
      Top = 2
      Width = 31
      Height = 20
      Caption = '...'
      TabOrder = 1
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 198
      Top = 2
      Width = 34
      Height = 19
      Hint = #51452#47928#49688#47049
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '10'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object edtCnt: TEdit
      Left = 238
      Top = 2
      Width = 23
      Height = 19
      Hint = #54840#44032
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '3'
      OnChange = edtQtyChange
      OnKeyPress = edtQtyKeyPress
    end
    object edtClear: TButton
      Left = 287
      Top = 1
      Width = 41
      Height = 21
      Caption = 'Clear'
      TabOrder = 4
      OnClick = edtClearClick
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 32
    Width = 486
    Height = 261
    Align = alClient
    ColCount = 8
    Ctl3D = False
    DefaultRowHeight = 16
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = []
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
    ColWidths = (
      56
      40
      37
      72
      52
      64
      64
      64)
  end
end
