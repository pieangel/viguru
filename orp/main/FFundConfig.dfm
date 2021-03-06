object FrmFundConfig: TFrmFundConfig
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = #45796#44228#51340' '#49444#51221
  ClientHeight = 430
  ClientWidth = 563
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonToRight: TSpeedButton
    Left = 233
    Top = 112
    Width = 24
    Height = 24
    Caption = '>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonToRightClick
  end
  object ButtonToRightAll: TSpeedButton
    Left = 233
    Top = 152
    Width = 24
    Height = 24
    Caption = '>>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonToRightAllClick
  end
  object ButtonToLeft: TSpeedButton
    Left = 233
    Top = 192
    Width = 24
    Height = 24
    Caption = '<'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonToLeftClick
  end
  object ButtonToLeftAll: TSpeedButton
    Left = 233
    Top = 232
    Width = 24
    Height = 24
    Caption = '<<'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonToLeftAllClick
  end
  object ButtonUpper: TSpeedButton
    Tag = 100
    Left = 529
    Top = 144
    Width = 28
    Height = 33
    Caption = #8593
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonUpperClick
  end
  object ButtonLower: TSpeedButton
    Tag = 200
    Left = 529
    Top = 192
    Width = 28
    Height = 33
    Caption = #8595
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -15
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonUpperClick
  end
  object Label5: TLabel
    Left = 8
    Top = 46
    Width = 81
    Height = 13
    AutoSize = False
    Caption = #48708#46321#47197' '#44228#51340' :'
    Color = clBtnFace
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentColor = False
    ParentFont = False
  end
  object Label6: TLabel
    Left = 272
    Top = 46
    Width = 65
    Height = 13
    AutoSize = False
    Caption = #46321#47197' '#44228#51340' :'
    Color = clBtnFace
    ParentColor = False
  end
  object ListViewUnRegDetails: TListView
    Left = 3
    Top = 65
    Width = 224
    Height = 249
    Columns = <
      item
        Caption = #44228#51340#48264#54840
        Width = 100
      end
      item
        Caption = #44228#51340#47749
        Width = 115
      end>
    ColumnClick = False
    DragMode = dmAutomatic
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    ParentFont = False
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListViewUnRegDetailsDblClick
    OnDrawItem = ListViewUnRegDetailsDrawItem
  end
  object ListViewRegDetails: TListView
    Left = 261
    Top = 64
    Width = 266
    Height = 249
    Columns = <
      item
        Caption = #44228#51340#48264#54840
        Width = 90
      end
      item
        Caption = #44228#51340#47749
        Width = 90
      end
      item
        Alignment = taRightJustify
        Caption = #49849#49688
        Width = 40
      end
      item
        Alignment = taRightJustify
        Caption = #48708#50984
        Width = 40
      end>
    ColumnClick = False
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    ParentFont = False
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListViewRegDetailsDblClick
    OnDrawItem = ListViewRegDetailsDrawItem
    OnKeyPress = ListViewRegDetailsKeyPress
    OnSelectItem = ListViewRegDetailsSelectItem
  end
  object ButtonConfirm: TButton
    Left = 344
    Top = 395
    Width = 75
    Height = 25
    Caption = #54869#51064'(&O)'
    TabOrder = 2
    OnClick = ButtonConfirmClick
  end
  object ButtonCancel: TButton
    Left = 454
    Top = 395
    Width = 75
    Height = 25
    Caption = #52712#49548'(&C)'
    ModalResult = 2
    TabOrder = 3
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 563
    Height = 33
    Align = alTop
    BevelInner = bvRaised
    BevelOuter = bvLowered
    TabOrder = 4
    ExplicitWidth = 525
    object Label7: TLabel
      Left = 12
      Top = 10
      Width = 47
      Height = 13
      AutoSize = False
      Caption = #45796#44228#51340#47749' :'
    end
    object EditFundName: TEdit
      Left = 64
      Top = 6
      Width = 121
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 0
    end
  end
  object PanelSummary: TPanel
    Left = 263
    Top = 316
    Width = 265
    Height = 25
    BevelInner = bvLowered
    TabOrder = 5
    object Label8: TLabel
      Left = 6
      Top = 4
      Width = 109
      Height = 13
      Caption = #54788#51116' '#46321#47197#44228#51340' '#54633#44228' :'
    end
    object PanelSumMultiple: TPanel
      Left = 159
      Top = 4
      Width = 43
      Height = 17
      Alignment = taRightJustify
      BevelInner = bvLowered
      BevelOuter = bvNone
      Color = 16777183
      TabOrder = 0
    end
    object PanelSumRatio: TPanel
      Left = 209
      Top = 4
      Width = 43
      Height = 17
      Alignment = taRightJustify
      BevelInner = bvLowered
      BevelOuter = bvNone
      Color = 16777183
      TabOrder = 1
    end
  end
  object GroupBox1: TGroupBox
    Left = 103
    Top = 343
    Width = 425
    Height = 46
    Caption = #54788#51116' '#49440#53469' '#44228#51340' '#51221#48372
    TabOrder = 6
    object Label9: TLabel
      Left = 15
      Top = 21
      Width = 34
      Height = 13
      Caption = #44228#51340' : '
    end
    object Label15: TLabel
      Left = 218
      Top = 21
      Width = 31
      Height = 13
      Caption = #49849#49688' :'
    end
    object Label1: TLabel
      Left = 318
      Top = 21
      Width = 31
      Height = 13
      Caption = #48708#50984' :'
    end
    object EditMultiple: TEdit
      Left = 254
      Top = 18
      Width = 54
      Height = 21
      BiDiMode = bdRightToLeftNoAlign
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      ParentBiDiMode = False
      TabOrder = 0
      OnChange = EditMultipleChange
      OnClick = EditMultipleClick
    end
    object PanelAccountNo: TPanel
      Left = 54
      Top = 20
      Width = 150
      Height = 17
      Alignment = taRightJustify
      BevelInner = bvLowered
      BevelOuter = bvNone
      Color = 16777183
      TabOrder = 1
    end
    object PanelEachRatio: TPanel
      Left = 355
      Top = 20
      Width = 49
      Height = 17
      Alignment = taRightJustify
      BevelInner = bvLowered
      BevelOuter = bvNone
      Color = 16777183
      TabOrder = 2
    end
  end
end
