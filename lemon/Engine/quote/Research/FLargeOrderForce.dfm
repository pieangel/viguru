object LargeOrderForce: TLargeOrderForce
  Left = 0
  Top = 0
  Caption = #45824#47049#51452#47928#49464#47141#44160#49353
  ClientHeight = 240
  ClientWidth = 319
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
    Width = 319
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 34
      Height = 13
      Caption = #51333#47785' : '
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
      Left = 320
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
      Text = '50'
      Visible = False
      OnChange = edtCntChange
    end
    object edtCnt: TEdit
      Left = 331
      Top = 7
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
      Visible = False
      OnChange = edtCntChange
    end
    object Button1: TButton
      Left = 201
      Top = 3
      Width = 31
      Height = 20
      Caption = 'clear'
      TabOrder = 4
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 244
      Top = 3
      Width = 31
      Height = 20
      Caption = 'Log'
      TabOrder = 5
      OnClick = Button2Click
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 32
    Width = 319
    Height = 208
    Align = alClient
    ColCount = 6
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
    PopupMenu = PopupMenu1
    TabOrder = 1
    OnDrawCell = sgInfoDrawCell
    ColWidths = (
      56
      40
      37
      72
      52
      64)
  end
  object PopupMenu1: TPopupMenu
    Left = 152
    Top = 120
    object clear1: TMenuItem
      Caption = 'clear'
      OnClick = clear1Click
    end
    object Log1: TMenuItem
      Caption = 'Log'
      OnClick = Log1Click
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 72
    Top = 144
  end
end
