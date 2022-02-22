object DoubleOrderDialog: TDoubleOrderDialog
  Left = 306
  Top = 195
  BorderStyle = bsDialog
  Caption = 'DoubleOrderDialog'
  ClientHeight = 137
  ClientWidth = 241
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 16
    Top = 16
    Width = 38
    Height = 13
    Caption = #44228#51340' : '
  end
  object LabelAccount: TLabel
    Left = 56
    Top = 16
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 16
    Top = 35
    Width = 38
    Height = 13
    Caption = #51333#47785' : '
  end
  object LabelSymbol: TLabel
    Left = 56
    Top = 35
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
  end
  object Label7: TLabel
    Left = 16
    Top = 55
    Width = 38
    Height = 13
    Caption = #49688#47049' : '
  end
  object LabelPrice: TLabel
    Left = 83
    Top = 55
    Width = 38
    Height = 13
    Caption = #44032#44201' : '
  end
  object Label3: TLabel
    Left = 152
    Top = 35
    Width = 38
    Height = 13
    Caption = #44396#48516' : '
  end
  object LabelPosition: TLabel
    Left = 200
    Top = 35
    Width = 26
    Height = 13
    Caption = #47588#49688
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = []
    ParentFont = False
  end
  object EditQty: TEdit
    Left = 16
    Top = 73
    Width = 57
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544')'
    TabOrder = 0
    OnChange = EditQtyChange
  end
  object EditPrice: TEdit
    Left = 83
    Top = 73
    Width = 65
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544')'
    TabOrder = 1
    OnChange = EditPriceChange
  end
  object ButtonOK: TButton
    Left = 29
    Top = 104
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    Default = True
    TabOrder = 2
    OnClick = ButtonOKClick
  end
  object ButtonCancel: TButton
    Left = 125
    Top = 104
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 3
  end
end
