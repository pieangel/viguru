object FrmSelect: TFrmSelect
  Left = 0
  Top = 0
  Caption = 'Account Select'
  ClientHeight = 233
  ClientWidth = 299
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
  object lvAcnt: TListView
    Left = 0
    Top = 0
    Width = 299
    Height = 233
    Align = alClient
    Columns = <
      item
        Caption = 'Account'
        Width = 80
      end
      item
        Alignment = taRightJustify
        Caption = 'Market'
        Tag = 1
      end
      item
        Alignment = taRightJustify
        Caption = 'BusinessCode'
        Tag = 3
        Width = 60
      end
      item
        Alignment = taRightJustify
        Caption = 'Country'
        Tag = 4
        Width = 60
      end>
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvAcntDblClick
    ExplicitWidth = 279
  end
end
