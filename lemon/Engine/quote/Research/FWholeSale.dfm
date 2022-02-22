object FrmWholeSale: TFrmWholeSale
  Left = 0
  Top = 0
  Caption = #46244#51665#44592' '#51452#47928' '#44160#49353
  ClientHeight = 291
  ClientWidth = 677
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
    Width = 677
    Height = 32
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 649
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 34
      Height = 13
      Caption = #51333#47785' : '
    end
    object Label2: TLabel
      Left = 190
      Top = 6
      Width = 36
      Height = 13
      Caption = #51452#47928#54633
    end
    object Label3: TLabel
      Left = 341
      Top = 6
      Width = 24
      Height = 13
      Caption = #51452#47928
    end
    object Label4: TLabel
      Left = 404
      Top = 6
      Width = 24
      Height = 13
      Caption = #51060#51204
    end
    object Label6: TLabel
      Left = 266
      Top = 6
      Width = 36
      Height = 13
      Caption = #52404#44208#54633
    end
    object Label5: TLabel
      Left = 481
      Top = 6
      Width = 19
      Height = 13
      Caption = 'Gap'
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
    object edtConQty: TEdit
      Left = 230
      Top = 2
      Width = 29
      Height = 19
      Hint = #51452#47928#54633
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '10'
      OnChange = edtAfterChange
      OnKeyPress = edtAfterKeyPress
    end
    object edtBefore: TEdit
      Left = 434
      Top = 2
      Width = 35
      Height = 19
      Hint = #51452#47928#44148#49688
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '1000'
      OnChange = edtAfterChange
      OnKeyPress = edtAfterKeyPress
    end
    object edtQty: TEdit
      Left = 369
      Top = 2
      Width = 29
      Height = 19
      Hint = #51452#47928
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '1'
      OnChange = edtAfterChange
      OnKeyPress = edtAfterKeyPress
    end
    object Button1: TButton
      Left = 598
      Top = 2
      Width = 47
      Height = 21
      Caption = 'Clear'
      TabOrder = 5
      OnClick = Button1Click
    end
    object edtConFill: TEdit
      Left = 306
      Top = 2
      Width = 29
      Height = 19
      Hint = #52404#44208#54633
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '10'
      OnChange = edtAfterChange
      OnKeyPress = edtAfterKeyPress
    end
    object Button2: TButton
      Left = 546
      Top = 2
      Width = 45
      Height = 21
      Caption = 'Log'
      TabOrder = 7
      OnClick = Button2Click
    end
    object edtGap: TEdit
      Left = 501
      Top = 3
      Width = 31
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 8
      Text = '1000'
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 32
    Width = 677
    Height = 259
    Align = alClient
    ColCount = 14
    Ctl3D = False
    DefaultRowHeight = 15
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
    ExplicitWidth = 649
    ColWidths = (
      56
      40
      37
      72
      52
      64
      64
      64
      64
      64
      64
      64
      64
      64)
  end
  object tmflash: TTimer
    OnTimer = tmflashTimer
    Left = 104
    Top = 208
  end
end
