object SymbolFillter: TSymbolFillter
  Left = 0
  Top = 0
  Caption = 'Symbol Filltering'
  ClientHeight = 373
  ClientWidth = 459
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lbTitle: TLabel
    Left = 9
    Top = 11
    Width = 60
    Height = 13
    AutoSize = False
    Caption = #44592' '#52488' '#51088' '#49328' '
    Layout = tlCenter
  end
  object lbSrc: TListBox
    Left = 8
    Top = 40
    Width = 185
    Height = 281
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    MultiSelect = True
    Sorted = True
    TabOrder = 0
    OnDblClick = lbSrcDblClick
    OnKeyDown = lbSrcKeyDown
  end
  object lbDest: TListBox
    Left = 261
    Top = 40
    Width = 190
    Height = 281
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    MultiSelect = True
    TabOrder = 1
    OnDblClick = lbDestDblClick
    OnKeyDown = lbDestKeyDown
  end
  object btnMove: TButton
    Left = 199
    Top = 112
    Width = 56
    Height = 25
    Caption = '>>>'
    TabOrder = 2
    OnClick = btnMoveClick
  end
  object btnDel: TButton
    Left = 199
    Top = 193
    Width = 56
    Height = 25
    Caption = 'Del'
    TabOrder = 3
    OnClick = btnDelClick
  end
  object btnClear: TButton
    Left = 199
    Top = 224
    Width = 56
    Height = 25
    Caption = 'Clear'
    TabOrder = 4
    OnClick = btnClearClick
  end
  object Button4: TButton
    Left = 261
    Top = 343
    Width = 75
    Height = 25
    Caption = #54869#51064
    TabOrder = 5
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 376
    Top = 343
    Width = 75
    Height = 25
    Caption = #52712#49548
    TabOrder = 6
    OnClick = Button5Click
  end
end
