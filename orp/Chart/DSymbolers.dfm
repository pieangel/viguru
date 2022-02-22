object SymbolersDlg: TSymbolersDlg
  Left = 219
  Top = 149
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #52320#53944' '#45796#51333#47785' '#49444#51221#52285
  ClientHeight = 228
  ClientWidth = 386
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object ListViewSymbols: TListView
    Left = 8
    Top = 21
    Width = 369
    Height = 177
    Columns = <
      item
        Width = 1
      end
      item
        Alignment = taCenter
        Caption = #48516#47448
        Width = 40
      end
      item
        Caption = #51333#47785#53076#46300
        Width = 70
      end
      item
        Alignment = taCenter
        Caption = #54805#53468
      end
      item
        Alignment = taCenter
        Caption = #50948#52824
      end
      item
        Alignment = taCenter
        Caption = #52629#51201
      end
      item
        Alignment = taCenter
        Caption = #52404#44208
        Width = 40
      end
      item
        Alignment = taCenter
        Caption = #49353#49345
        Width = 40
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
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListViewSymbolsDblClick
    OnDrawItem = ListViewSymbolsDrawItem
  end
  object ButtonConfig: TButton
    Left = 22
    Top = 201
    Width = 75
    Height = 25
    Caption = #49444#51221'(&S)'
    TabOrder = 1
    OnClick = ButtonConfigClick
  end
  object Button2: TButton
    Left = 110
    Top = 201
    Width = 75
    Height = 25
    Caption = #45803#44592'(&C)'
    ModalResult = 1
    TabOrder = 2
  end
  object ButtonDelete: TButton
    Left = 198
    Top = 201
    Width = 75
    Height = 25
    Caption = #49325#51228'(&D)'
    TabOrder = 3
    OnClick = ButtonDeleteClick
  end
  object ButtonHelp: TButton
    Left = 289
    Top = 201
    Width = 75
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    TabOrder = 4
  end
  object PanelBase: TPanel
    Left = 152
    Top = 0
    Width = 89
    Height = 21
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = ' '#45800#50948' :'
    TabOrder = 5
  end
  object PanelPeriod: TPanel
    Left = 248
    Top = 0
    Width = 105
    Height = 21
    Alignment = taLeftJustify
    BevelOuter = bvNone
    Caption = ' '#54364#49884' '#45800#50948' :'
    TabOrder = 6
  end
  object ImageList1: TImageList
    Left = 56
    Top = 65528
  end
end
