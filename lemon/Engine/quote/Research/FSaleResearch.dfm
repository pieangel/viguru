object FrmResearchMuch: TFrmResearchMuch
  Left = 0
  Top = 0
  Caption = #45824#47049#51452#47928' '#44160#49353
  ClientHeight = 524
  ClientWidth = 428
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
    Width = 428
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label3: TLabel
      Left = 124
      Top = 5
      Width = 34
      Height = 13
      Caption = #49688#47049' : '
    end
    object Label2: TLabel
      Left = 297
      Top = 5
      Width = 14
      Height = 13
      Caption = 'G :'
    end
    object Label1: TLabel
      Left = 237
      Top = 7
      Width = 17
      Height = 13
      Caption = 'Sec'
      Visible = False
    end
    object cbSymbol: TComboBox
      Left = 1
      Top = 2
      Width = 92
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
      Left = 97
      Top = 2
      Width = 23
      Height = 20
      Caption = '...'
      TabOrder = 1
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 157
      Top = 2
      Width = 27
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 2
      Text = '70'
      OnChange = edtQtyChange
    end
    object cbAsc: TCheckBox
      Left = 405
      Top = 13
      Width = 43
      Height = 17
      Hint = #49884#44036#50724#47492#52264#49692
      Caption = #50724#47492
      Enabled = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Visible = False
      OnClick = cbAscClick
    end
    object Button1: TButton
      Left = 347
      Top = 2
      Width = 31
      Height = 20
      Caption = 'Log'
      TabOrder = 4
      OnClick = Button1Click
    end
    object edtGap: TEdit
      Left = 314
      Top = 2
      Width = 31
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 5
      Text = '1000'
    end
    object edtSecond: TEdit
      Left = 206
      Top = 2
      Width = 27
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 6
      Text = '60'
      Visible = False
    end
    object cbSecond: TComboBox
      Left = 243
      Top = 2
      Width = 46
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 7
      Text = '1'#48516
      Items.Strings = (
        '1'#48516
        '1/2'
        '1/3'
        '1/6')
    end
    object cbNow: TCheckBox
      Left = 190
      Top = 3
      Width = 45
      Height = 17
      Caption = #54788#51116
      TabOrder = 8
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 27
    Width = 428
    Height = 497
    Align = alClient
    ColCount = 9
    Ctl3D = False
    DefaultRowHeight = 16
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 2
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    TabOrder = 1
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
    ColWidths = (
      68
      31
      39
      47
      37
      58
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
