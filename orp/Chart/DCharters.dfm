object CharterDialog: TCharterDialog
  Left = 268
  Top = 213
  BorderStyle = bsDialog
  Caption = #51648#54364#49444#51221
  ClientHeight = 227
  ClientWidth = 389
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonConfig: TButton
    Left = 321
    Top = 32
    Width = 65
    Height = 25
    Caption = #49444' '#51221'(&F)'
    Default = True
    Enabled = False
    TabOrder = 0
    OnClick = ButtonConfigClick
  end
  object Button2: TButton
    Left = 321
    Top = 80
    Width = 64
    Height = 25
    Caption = #45803' '#44592'(&C)'
    ModalResult = 2
    TabOrder = 1
  end
  object Button1: TButton
    Left = 321
    Top = 176
    Width = 65
    Height = 25
    Caption = #46020#50880#47568'(&H)'
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
  object ListViewCharters: TListView
    Left = 8
    Top = 8
    Width = 295
    Height = 217
    Columns = <
      item
        Caption = #51648#54364#47749
        Width = 120
      end
      item
        Caption = #51077#47141#44050
        Width = 150
      end>
    DragMode = dmAutomatic
    GridLines = True
    OwnerDraw = True
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 4
    ViewStyle = vsReport
    OnClick = ListViewChartersClick
    OnData = ListViewChartersData
    OnDblClick = ListViewChartersDblClick
    OnDrawItem = ListViewChartersDrawItem
    OnDragDrop = ListViewChartersDragDrop
    OnDragOver = ListViewChartersDragOver
  end
  object ImageList1: TImageList
    Left = 376
  end
end
