object BoardConfig: TBoardConfig
  Left = 0
  Top = 0
  Caption = 'Board Config'
  ClientHeight = 200
  ClientWidth = 282
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object StringGridVolumes: TStringGrid
    Left = 8
    Top = 37
    Width = 175
    Height = 89
    BorderStyle = bsNone
    ColCount = 3
    DefaultColWidth = 55
    DefaultRowHeight = 16
    FixedCols = 0
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goEditing]
    ScrollBars = ssNone
    TabOrder = 0
    OnKeyPress = StringGridVolumesKeyPress
    OnMouseWheelDown = StringGridVolumesMouseWheelDown
    OnMouseWheelUp = StringGridVolumesMouseWheelUp
  end
  object ComboBoxItem: TComboBox
    Left = 8
    Top = 8
    Width = 129
    Height = 21
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    TabOrder = 1
    OnChange = ComboBoxItemChange
  end
  object cbDefault: TCheckBox
    Left = 10
    Top = 136
    Width = 97
    Height = 17
    Caption = 'Default Set'
    TabOrder = 2
    OnClick = cbDefaultClick
  end
  object ButtonOK: TButton
    Left = 8
    Top = 163
    Width = 75
    Height = 25
    Caption = #54869#51064
    TabOrder = 3
    OnClick = ButtonOKClick
  end
  object edtAdd: TButton
    Left = 232
    Top = 37
    Width = 42
    Height = 25
    Caption = 'Add'
    TabOrder = 4
    OnClick = edtAddClick
  end
  object edtDel: TButton
    Left = 232
    Top = 115
    Width = 42
    Height = 25
    Caption = 'Delete'
    TabOrder = 5
    OnClick = edtDelClick
  end
  object edtName: TEdit
    Left = 197
    Top = 10
    Width = 75
    Height = 21
    ImeName = 'Microsoft IME 2003'
    TabOrder = 6
  end
  object Button3: TButton
    Left = 197
    Top = 163
    Width = 75
    Height = 25
    Caption = #52712#49548
    TabOrder = 7
    OnClick = Button3Click
  end
  object Button2: TButton
    Left = 232
    Top = 78
    Width = 42
    Height = 25
    Caption = 'Clear'
    TabOrder = 8
    OnClick = Button2Click
  end
  object Button1: TButton
    Left = 108
    Top = 163
    Width = 75
    Height = 25
    Caption = #51201#50857
    TabOrder = 9
    OnClick = Button1Click
  end
end
