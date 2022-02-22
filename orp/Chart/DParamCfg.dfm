object ParamConfig: TParamConfig
  Left = 340
  Top = 215
  BorderStyle = bsDialog
  Caption = #51077#47141#44050' '#48320#44221
  ClientHeight = 88
  ClientWidth = 267
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
  object LabelTitle: TLabel
    Left = 9
    Top = 9
    Width = 38
    Height = 13
    Caption = #51228#47785' : '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
  end
  object ComboValue: TComboBox
    Left = 8
    Top = 28
    Width = 249
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
    ItemHeight = 13
    TabOrder = 0
    OnKeyDown = ComboValueKeyDown
  end
  object ButtonOK: TButton
    Left = 50
    Top = 56
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 133
    Top = 56
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 2
  end
end
