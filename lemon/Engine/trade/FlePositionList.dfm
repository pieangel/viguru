object PositionListForm: TPositionListForm
  Left = 0
  Top = 0
  Caption = 'Position List'
  ClientHeight = 292
  ClientWidth = 593
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
  object ListViewPositions: TListView
    Left = 0
    Top = 0
    Width = 593
    Height = 292
    Align = alClient
    Columns = <
      item
        Caption = 'Account'
        Width = 90
      end
      item
        Caption = 'Symbol'
        Width = 90
      end
      item
        Alignment = taRightJustify
        Caption = 'Volume'
      end
      item
        Alignment = taRightJustify
        Caption = 'Avg Price'
        Width = 90
      end
      item
        Alignment = taRightJustify
        Caption = 'Prev'
        Width = 60
      end
      item
        Alignment = taRightJustify
        Caption = 'Prev Avg Price'
        Width = 90
      end
      item
        Alignment = taRightJustify
        Caption = 'P&L'
        Width = 100
      end>
    OwnerData = True
    TabOrder = 0
    ViewStyle = vsReport
    OnData = ListViewPositionsData
    OnDblClick = ListViewPositionsDblClick
  end
end
