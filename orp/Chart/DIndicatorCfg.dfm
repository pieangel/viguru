object IndicatorConfig: TIndicatorConfig
  Left = 341
  Top = 120
  BorderStyle = bsDialog
  Caption = #51648#54364' '#49444#51221
  ClientHeight = 394
  ClientWidth = 379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 12
    Top = 12
    Width = 51
    Height = 13
    Caption = #51077#47141#44050' : '
  end
  object ListParams: TListView
    Left = 12
    Top = 30
    Width = 237
    Height = 87
    Columns = <
      item
        Caption = #47749#52845
        Width = 150
      end
      item
        Alignment = taRightJustify
        Caption = #44050
        Width = 65
      end>
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = ListParamsDblClick
  end
  object ButtonEdit: TButton
    Left = 264
    Top = 52
    Width = 97
    Height = 25
    Caption = #54200#51665'(&E)'
    TabOrder = 1
    OnClick = ButtonEditClick
  end
  object ButtonDef: TButton
    Left = 263
    Top = 84
    Width = 98
    Height = 25
    Caption = #52488#44592#44050'(&D)'
    TabOrder = 2
    OnClick = ButtonDefClick
  end
  object RadioPosition: TRadioGroup
    Left = 12
    Top = 269
    Width = 141
    Height = 77
    Caption = #44536#47000#54532' '#50948#52824
    Items.Strings = (
      #44592#48376' '#44536#47000#54532
      #48512#49549' '#44536#47000#54532)
    TabOrder = 3
  end
  object RadioScale: TRadioGroup
    Left = 164
    Top = 269
    Width = 205
    Height = 77
    Caption = #52629#51201
    Items.Strings = (
      #54868#47732#45800#50948' '#52572#45824'/'#52572#49548
      #51204#52404' '#52572#45824'/'#52572#49548
      #51333#47785' '#44536#47000#54532#50752' '#44057#44172)
    TabOrder = 4
  end
  object GroupBox1: TGroupBox
    Left = 12
    Top = 126
    Width = 355
    Height = 134
    Caption = #44536#47000#54532' '#50836#49548
    TabOrder = 5
    object Label4: TLabel
      Left = 131
      Top = 60
      Width = 25
      Height = 13
      Caption = #49353' : '
    end
    object Label5: TLabel
      Left = 118
      Top = 87
      Width = 38
      Height = 13
      Caption = #44405#44592' : '
    end
    object ShapeColor: TShape
      Left = 157
      Top = 58
      Width = 67
      Height = 17
    end
    object ButtonColor: TSpeedButton
      Left = 227
      Top = 55
      Width = 23
      Height = 22
      Caption = '...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonColorClick
    end
    object PaintPreview: TPaintBox
      Left = 256
      Top = 21
      Width = 89
      Height = 102
      OnPaint = PaintPreviewPaint
    end
    object Label2: TLabel
      Left = 118
      Top = 31
      Width = 38
      Height = 13
      Caption = #54805#53468' : '
    end
    object ListPlots: TListBox
      Left = 10
      Top = 19
      Width = 103
      Height = 105
      Columns = 1
      ImeName = #54620#44397#50612'('#54620#44544')'
      ItemHeight = 13
      TabOrder = 0
      OnClick = ListPlotsClick
    end
    object ComboWeight: TComboBox
      Left = 157
      Top = 84
      Width = 91
      Height = 19
      Style = csOwnerDrawFixed
      DropDownCount = 5
      ImeName = #54620#44397#50612'('#54620#44544')'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboWeightChange
      OnDrawItem = ComboWeightDrawItem
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5')
    end
    object ComboStyle: TComboBox
      Left = 157
      Top = 27
      Width = 91
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      ItemHeight = 13
      TabOrder = 2
      OnClick = ComboStyleClick
      Items.Strings = (
        #49440
        #47561#45824
        #51216
        #50672#44208' '#44256#51216
        #50672#44208' '#51200#51216)
    end
    object CheckAutoWeight: TCheckBox
      Left = 160
      Top = 110
      Width = 81
      Height = 17
      Caption = #44405#44592' '#51088#46041
      TabOrder = 3
      OnClick = CheckAutoWeightClick
    end
  end
  object ButtonOK: TButton
    Left = 72
    Top = 358
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    Default = True
    TabOrder = 6
    OnClick = ButtonOKClick
  end
  object Button2: TButton
    Left = 160
    Top = 358
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 7
  end
  object Button1: TButton
    Left = 248
    Top = 358
    Width = 75
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    ModalResult = 2
    TabOrder = 8
  end
  object ColorDialog: TColorDialog
    Left = 304
    Top = 112
  end
end
