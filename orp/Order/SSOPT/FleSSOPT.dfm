object FrmSsopt: TFrmSsopt
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'SSOPT'
  ClientHeight = 799
  ClientWidth = 879
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
    Width = 180
    Height = 709
    Align = alLeft
    TabOrder = 0
    object ListView1: TListView
      Left = 1
      Top = 0
      Width = 177
      Height = 328
      Columns = <>
      TabOrder = 0
      ViewStyle = vsReport
    end
    object Button1: TButton
      Left = 4
      Top = 339
      Width = 85
      Height = 25
      Caption = #46041#49884#54840#44032'basket'
      TabOrder = 1
    end
    object Button2: TButton
      Left = 92
      Top = 339
      Width = 84
      Height = 25
      Caption = #51109#51473'basket'
      TabOrder = 2
    end
    object ListView2: TListView
      Left = 2
      Top = 372
      Width = 177
      Height = 333
      Columns = <>
      TabOrder = 3
      ViewStyle = vsReport
    end
  end
  object panel20: TPanel
    Left = 0
    Top = 709
    Width = 879
    Height = 90
    Align = alBottom
    Caption = 'panel20'
    TabOrder = 1
    object btnClose: TButton
      Left = 800
      Top = 62
      Width = 75
      Height = 25
      Caption = #51333#47308
      TabOrder = 0
      OnClick = btnCloseClick
    end
    object plOrder: TPanel
      Left = 265
      Top = 4
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 1
    end
    object plAcpt: TPanel
      Left = 265
      Top = 33
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 2
    end
    object plFill: TPanel
      Left = 265
      Top = 62
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 3
    end
    object plMaster: TPanel
      Left = 491
      Top = 4
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 4
    end
    object plQuoteTime: TPanel
      Left = 491
      Top = 33
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 5
    end
    object plDelay: TPanel
      Left = 491
      Top = 62
      Width = 205
      Height = 25
      BevelInner = bvLowered
      TabOrder = 6
    end
    object btnLast: TButton
      Left = 719
      Top = 62
      Width = 75
      Height = 25
      Caption = #46041#44592#54868
      TabOrder = 7
      OnClick = btnLastClick
    end
    object plConn: TPanel
      Left = 2
      Top = 4
      Width = 177
      Height = 83
      Alignment = taLeftJustify
      BevelInner = bvLowered
      TabOrder = 8
    end
  end
  object Panel2: TPanel
    Left = 180
    Top = 0
    Width = 175
    Height = 709
    Align = alLeft
    TabOrder = 2
    inline FraMain1: TFraMain
      Left = 1
      Top = 1
      Width = 173
      Height = 707
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 707
    end
  end
  object Panel3: TPanel
    Left = 355
    Top = 0
    Width = 175
    Height = 709
    Align = alLeft
    TabOrder = 3
    inline FraMain2: TFraMain
      Left = 1
      Top = 1
      Width = 173
      Height = 707
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 707
    end
  end
  object Panel4: TPanel
    Left = 530
    Top = 0
    Width = 175
    Height = 709
    Align = alLeft
    TabOrder = 4
    inline FraMain3: TFraMain
      Left = 1
      Top = 1
      Width = 173
      Height = 707
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 707
    end
  end
  object Panel5: TPanel
    Left = 705
    Top = 0
    Width = 175
    Height = 709
    Align = alLeft
    TabOrder = 5
    inline FraMain4: TFraMain
      Left = 1
      Top = 1
      Width = 173
      Height = 707
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 1
      ExplicitTop = 1
      ExplicitHeight = 707
    end
  end
end
