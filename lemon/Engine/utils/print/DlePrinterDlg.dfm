object PrintDialogLe: TPrintDialogLe
  Left = 389
  Top = 225
  BorderStyle = bsDialog
  Caption = 'Print'
  ClientHeight = 275
  ClientWidth = 429
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 414
    Height = 53
    Caption = 'Printer'
    TabOrder = 0
    object Label1: TLabel
      Left = 16
      Top = 23
      Width = 31
      Height = 13
      Caption = 'Name:'
    end
    object ComboPrinter: TComboBox
      Left = 51
      Top = 20
      Width = 350
      Height = 22
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      ItemHeight = 16
      TabOrder = 0
      OnClick = ComboPrinterClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 122
    Top = 72
    Width = 136
    Height = 53
    Caption = 'Copies'
    TabOrder = 1
    object SpinCopies: TSpinEdit
      Left = 13
      Top = 20
      Width = 85
      Height = 22
      MaxValue = 100
      MinValue = 1
      TabOrder = 0
      Value = 1
      OnChange = SpinCopiesChange
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 72
    Width = 108
    Height = 73
    Caption = 'Orientation'
    TabOrder = 2
    object RadioLandscape: TRadioButton
      Left = 13
      Top = 20
      Width = 76
      Height = 17
      Caption = 'Landscape'
      TabOrder = 0
      OnClick = RadioOrientationClick
    end
    object RadioPortrait: TRadioButton
      Left = 13
      Top = 43
      Width = 71
      Height = 17
      Caption = 'Portrait'
      TabOrder = 1
      OnClick = RadioOrientationClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 122
    Top = 131
    Width = 136
    Height = 106
    Caption = 'Margins(cm)'
    TabOrder = 3
    object EditTop: TEdit
      Tag = 100
      Left = 46
      Top = 20
      Width = 45
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 0
      OnChange = EditMarginChange
      OnExit = EditMarginExit
    end
    object EditBottom: TEdit
      Tag = 200
      Left = 46
      Top = 74
      Width = 45
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 1
      OnChange = EditMarginChange
      OnExit = EditMarginExit
    end
    object EditLeft: TEdit
      Tag = 300
      Left = 11
      Top = 47
      Width = 45
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 2
      OnChange = EditMarginChange
      OnExit = EditMarginExit
    end
    object EditRight: TEdit
      Tag = 400
      Left = 81
      Top = 47
      Width = 45
      Height = 21
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 3
      OnChange = EditMarginChange
      OnExit = EditMarginExit
    end
  end
  object CheckFitInPage: TCheckBox
    Left = 8
    Top = 183
    Width = 101
    Height = 17
    Caption = 'Fit to page'
    TabOrder = 4
    OnClick = CheckFitInPageClick
  end
  object GroupBox5: TGroupBox
    Left = 264
    Top = 72
    Width = 158
    Height = 165
    Cursor = crHandPoint
    Caption = 'Preview'
    TabOrder = 5
    object PaintPreview: TPaintBox
      Left = 2
      Top = 15
      Width = 154
      Height = 148
      Align = alClient
      OnClick = PreviewClick
      OnPaint = PaintPreviewPaint
      ExplicitWidth = 194
      ExplicitHeight = 184
    end
    object Image: TImage
      Left = 24
      Top = 32
      Width = 105
      Height = 105
      Stretch = True
      OnClick = PreviewClick
    end
  end
  object ButtonOK: TButton
    Left = 220
    Top = 243
    Width = 97
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object Button3: TButton
    Left = 323
    Top = 243
    Width = 97
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object CheckBoxGrayScale: TCheckBox
    Left = 8
    Top = 160
    Width = 108
    Height = 17
    Caption = 'Print In Grayscale'
    TabOrder = 8
    OnClick = RadioColorClick
  end
end
