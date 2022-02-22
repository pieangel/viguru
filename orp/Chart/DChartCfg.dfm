object ChartConfig: TChartConfig
  Left = 317
  Top = 138
  BorderStyle = bsDialog
  Caption = #54868#47732' '#49444#51221
  ClientHeight = 372
  ClientWidth = 304
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox2: TGroupBox
    Left = 8
    Top = 171
    Width = 97
    Height = 81
    Caption = #44201#51088
    TabOrder = 0
    object ButtonGridColor: TSpeedButton
      Left = 8
      Top = 54
      Width = 65
      Height = 21
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonGridColorClick
    end
    object CheckHLine: TCheckBox
      Left = 8
      Top = 16
      Width = 57
      Height = 17
      Caption = #49688#54217#49440
      TabOrder = 0
      OnClick = CheckClick
    end
    object CheckVLine: TCheckBox
      Left = 8
      Top = 34
      Width = 65
      Height = 17
      Caption = #49688#51649#49440
      TabOrder = 1
      OnClick = CheckClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 112
    Top = 171
    Width = 185
    Height = 81
    Caption = #49464#47196#52629
    TabOrder = 1
    object Label5: TLabel
      Left = 82
      Top = 36
      Width = 51
      Height = 13
      Caption = #44544#51088#49688' : '
    end
    object Bevel1: TBevel
      Left = 76
      Top = 16
      Width = 2
      Height = 50
    end
    object ButtonAxisColor: TSpeedButton
      Left = 8
      Top = 54
      Width = 60
      Height = 21
      Caption = #49353'(&G)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonAxisColorClick
    end
    object CheckLeft: TCheckBox
      Left = 8
      Top = 16
      Width = 57
      Height = 17
      Caption = #50812#51901
      TabOrder = 0
      OnClick = CheckClick
    end
    object CheckRight: TCheckBox
      Left = 8
      Top = 34
      Width = 61
      Height = 17
      Caption = #50724#47480#51901
      TabOrder = 1
      OnClick = CheckClick
    end
    object SpinCharCount: TSpinEdit
      Left = 130
      Top = 32
      Width = 47
      Height = 22
      MaxValue = 15
      MinValue = 4
      TabOrder = 2
      Value = 8
      OnChange = SpinCharCountChange
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 112
    Width = 289
    Height = 50
    Caption = #44592#48376
    TabOrder = 2
    object ButtonBkColor: TSpeedButton
      Left = 11
      Top = 19
      Width = 81
      Height = 22
      Caption = #48176#44221#49353'(&B)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonBkColorClick
    end
    object ButtonFont: TSpeedButton
      Left = 99
      Top = 19
      Width = 81
      Height = 22
      Caption = #54256#53944'(&F)...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonFontClick
    end
  end
  object ButtonOK: TButton
    Left = 17
    Top = 340
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    TabOrder = 3
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 113
    Top = 340
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    TabOrder = 4
    OnClick = ButtonCancelClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 289
    Height = 89
    Caption = #48120#47532#48372#44592
    TabOrder = 5
    object PaintPreview: TPaintBox
      Left = 8
      Top = 16
      Width = 273
      Height = 65
      OnPaint = PaintPreviewPaint
    end
  end
  object Button1: TButton
    Left = 209
    Top = 340
    Width = 75
    Height = 25
    Caption = #46020#50880#47568'(&H)'
    TabOrder = 6
  end
  object GroupBox5: TGroupBox
    Left = 8
    Top = 255
    Width = 139
    Height = 78
    Caption = #49828#53356#47204
    TabOrder = 7
    object Label2: TLabel
      Left = 5
      Top = 51
      Width = 73
      Height = 13
      Caption = #50724#47480#51901#50668#48177' :'
    end
    object EditMargin: TEdit
      Left = 78
      Top = 48
      Width = 41
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 0
      Text = '0'
    end
    object UpDownMargin: TUpDown
      Left = 119
      Top = 48
      Width = 15
      Height = 21
      Associate = EditMargin
      Max = 30
      TabOrder = 1
    end
    object CheckProgressMargin: TCheckBox
      Left = 6
      Top = 24
      Width = 119
      Height = 17
      Caption = #50724#47480#51901' '#50668#48177#51652#54665
      TabOrder = 2
      OnClick = CheckProgressMarginClick
    end
  end
  object GroupBox6: TGroupBox
    Left = 151
    Top = 255
    Width = 146
    Height = 78
    Caption = #44592#53440
    TabOrder = 8
    object Label1: TLabel
      Left = 7
      Top = 52
      Width = 51
      Height = 13
      Caption = #48393' '#44036#44201' :'
    end
    object CheckDrawSeparator: TCheckBox
      Left = 8
      Top = 24
      Width = 136
      Height = 17
      Caption = #52320#53944#44036' '#44396#48516#49440' '#45347#44592
      TabOrder = 0
      OnClick = CheckDrawSeparatorClick
    end
    object EditBarWidth: TEdit
      Left = 64
      Top = 48
      Width = 41
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 1
      Text = '1'
    end
    object UpDownBarWidth: TUpDown
      Left = 105
      Top = 48
      Width = 15
      Height = 21
      Associate = EditBarWidth
      Min = 1
      Max = 21
      Position = 1
      TabOrder = 2
    end
  end
  object FontDialog: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 232
    Top = 144
  end
  object ColorDialog: TColorDialog
    Left = 264
    Top = 144
  end
end
