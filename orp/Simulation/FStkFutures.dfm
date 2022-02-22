object StkFutures: TStkFutures
  Left = 0
  Top = 0
  Caption = #51452#49885#49440#47932#54840#44032#48708#44368
  ClientHeight = 163
  ClientWidth = 343
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
    Left = 8
    Top = 8
    Width = 121
    Height = 25
    Caption = #51452#49885#49440#47932
    TabOrder = 0
  end
  object lbstkf: TListBox
    Left = 8
    Top = 39
    Width = 121
    Height = 82
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    TabOrder = 1
    OnDblClick = lbstkfDblClick
  end
  object Panel2: TPanel
    Left = 215
    Top = 8
    Width = 121
    Height = 25
    Caption = #44592#52488#51088#49328
    TabOrder = 2
  end
  object lbUnder: TListBox
    Left = 215
    Top = 39
    Width = 121
    Height = 82
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    TabOrder = 3
  end
  object btnAdd: TButton
    Left = 134
    Top = 39
    Width = 54
    Height = 25
    Caption = '<< Add'
    TabOrder = 4
    OnClick = btnAddClick
  end
  object btnAllDel: TButton
    Left = 134
    Top = 96
    Width = 54
    Height = 24
    Caption = #47532#49483
    TabOrder = 5
    OnClick = btnAllDelClick
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 136
    Width = 49
    Height = 17
    Caption = #47196#44536
    Checked = True
    State = cbChecked
    TabOrder = 6
  end
end
