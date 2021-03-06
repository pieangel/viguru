object FrmOrderList2: TFrmOrderList2
  Left = 0
  Top = 0
  Caption = #51452#47928#45236#50669
  ClientHeight = 270
  ClientWidth = 775
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 775
    Height = 33
    Align = alTop
    BevelKind = bkTile
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 10
      Top = 10
      Width = 58
      Height = 13
      Caption = #44228#51340#48264#54840' : '
    end
    object Label2: TLabel
      Left = 427
      Top = 10
      Width = 58
      Height = 13
      Caption = #51333#47785#54596#53552' : '
    end
    object cbAccount: TComboBox
      Left = 67
      Top = 5
      Width = 145
      Height = 21
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbAccountChange
    end
    object edtAccount: TEdit
      Left = 215
      Top = 5
      Width = 74
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 1
    end
    object cbMarketFilter: TComboBox
      Left = 488
      Top = 5
      Width = 100
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbMarketFilterChange
    end
    object btnState: TButton
      Left = 347
      Top = 5
      Width = 75
      Height = 22
      Caption = #49345#53468' '#54596#53552
      TabOrder = 3
      OnMouseDown = btnStateMouseDown
    end
    object cbCancel: TCheckBox
      Left = 594
      Top = 7
      Width = 73
      Height = 17
      Caption = #52712#49548#51452#47928
      TabOrder = 4
      OnClick = cbCancelClick
    end
    object cbRealAcnt: TCheckBox
      Left = 673
      Top = 7
      Width = 88
      Height = 17
      Caption = 'Real '#44228#51340
      TabOrder = 5
      Visible = False
      OnClick = cbRealAcntClick
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 251
    Width = 775
    Height = 19
    Panels = <>
  end
  object sgList: TStringGrid
    Left = 0
    Top = 33
    Width = 775
    Height = 218
    Align = alClient
    ColCount = 12
    Ctl3D = False
    DefaultRowHeight = 17
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 3
    FixedRows = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 2
    OnDrawCell = sgListDrawCell
    OnMouseDown = sgListMouseDown
    ColWidths = (
      76
      67
      51
      48
      47
      44
      58
      73
      74
      70
      65
      65)
  end
  object sttOrder: TStaticText
    Left = 148
    Top = 34
    Width = 140
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = #51452'   '#47928
    TabOrder = 3
  end
  object sttFill: TStaticText
    Left = 296
    Top = 34
    Width = 102
    Height = 17
    Alignment = taCenter
    AutoSize = False
    Caption = #52404'  '#44208
    TabOrder = 4
  end
  object sttCode: TStaticText
    Left = 1
    Top = 44
    Width = 76
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #51333' '#47785' '#53076#46300
    TabOrder = 5
  end
  object sttDiv: TStaticText
    Left = 78
    Top = 44
    Width = 67
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #51452#47928' '#51333#47448
    TabOrder = 6
  end
  object sttState: TStaticText
    Left = 399
    Top = 44
    Width = 73
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #49345' '#53468
    TabOrder = 7
  end
  object sttAcptTime: TStaticText
    Left = 473
    Top = 44
    Width = 74
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #51217#49688#49884#44033
    TabOrder = 8
  end
  object sttNo: TStaticText
    Left = 548
    Top = 44
    Width = 70
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #51452#47928' '#48264#54840
    TabOrder = 9
  end
  object sttOrgNo: TStaticText
    Left = 619
    Top = 44
    Width = 65
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #50896#51452#47928#48264#54840
    TabOrder = 10
  end
  object StaticText1: TStaticText
    Left = 685
    Top = 44
    Width = 65
    Height = 19
    Alignment = taCenter
    AutoSize = False
    Caption = #51452#47928#53440#51077
    TabOrder = 11
  end
  object mPop: TPopupMenu
    OnPopup = mPopPopup
    Left = 472
    Top = 152
    object N1: TMenuItem
      Caption = #51613#51204#51217#49688
      Checked = True
      OnClick = N1Click
    end
    object N2: TMenuItem
      Tag = 1
      Caption = #51204#47049#52404#44208
      Checked = True
      OnClick = N1Click
    end
    object N3: TMenuItem
      Tag = 2
      Caption = #54869#51064#51452#47928
      OnClick = N1Click
    end
    object N4: TMenuItem
      Tag = 3
      Caption = #51453#51008#51452#47928
      OnClick = N1Click
    end
  end
end
