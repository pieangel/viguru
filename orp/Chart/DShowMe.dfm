object ShowMeCfg: TShowMeCfg
  Left = 0
  Top = 0
  Caption = 'ShowMe '#49444#51221
  ClientHeight = 231
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListViewCharters: TListView
    Left = 8
    Top = 8
    Width = 295
    Height = 217
    Columns = <
      item
        Caption = 'ShowMe'
        Width = 120
      end
      item
        Caption = #51077#47141#44050
        Width = 150
      end>
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnClick = ListViewChartersClick
    OnDblClick = ListViewChartersDblClick
    OnDrawItem = ListViewChartersDrawItem
  end
  object ButtonConfig: TButton
    Left = 321
    Top = 32
    Width = 65
    Height = 25
    Caption = #49444' '#51221'(&F)'
    Default = True
    Enabled = False
    TabOrder = 1
    OnClick = ButtonConfigClick
  end
  object Button2: TButton
    Left = 321
    Top = 80
    Width = 64
    Height = 25
    Caption = #45803' '#44592'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
  object ButtonDel: TButton
    Left = 321
    Top = 128
    Width = 64
    Height = 25
    Caption = #49325' '#51228'(&D)'
    Enabled = False
    TabOrder = 3
    OnClick = ButtonDelClick
  end
  object Button1: TButton
    Left = 321
    Top = 176
    Width = 65
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    ModalResult = 2
    TabOrder = 4
  end
end
