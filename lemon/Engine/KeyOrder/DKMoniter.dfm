object KMoniterDlg: TKMoniterDlg
  Left = 237
  Top = 304
  Caption = '['#53412#48372#46300#47784#45768#53552']'
  ClientHeight = 272
  ClientWidth = 434
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548#52404
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object ListLog: TListView
    Left = 0
    Top = 124
    Width = 434
    Height = 129
    Align = alBottom
    Columns = <
      item
        Caption = #54868#47732#47749
        Width = 120
      end
      item
        Caption = #47196#44536
        Width = 300
      end>
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = []
    GridLines = True
    ParentFont = False
    SmallImages = ImageList1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object ListOpens: TListView
    Left = 0
    Top = 0
    Width = 434
    Height = 81
    Align = alTop
    Columns = <
      item
        Caption = #54868#47732#47749' '
        Width = 120
      end
      item
        Caption = #51333#47785
        Width = 300
      end>
    Font.Charset = HANGEUL_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548#52404
    Font.Style = []
    GridLines = True
    OwnerDraw = True
    ParentFont = False
    SmallImages = ImageList1
    TabOrder = 1
    ViewStyle = vsReport
    OnDrawItem = ListOpensDrawItem
    OnSelectItem = ListOpensSelectItem
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 253
    Width = 434
    Height = 19
    Panels = <>
  end
  object Panel1: TPanel
    Left = 0
    Top = 81
    Width = 434
    Height = 43
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 3
    object Label1: TLabel
      Left = 13
      Top = 14
      Width = 70
      Height = 13
      Caption = #51333#47785' A'#49688#47049
    end
    object Label2: TLabel
      Left = 166
      Top = 15
      Width = 70
      Height = 13
      Caption = #51333#47785' B'#49688#47049
    end
    object EditSymbolA: TEdit
      Left = 94
      Top = 10
      Width = 62
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
    end
    object EditSymbolB: TEdit
      Left = 247
      Top = 11
      Width = 62
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
    end
  end
  object ImageList1: TImageList
    Left = 112
    Top = 209
  end
end
