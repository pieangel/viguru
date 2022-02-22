object OrderConfirmDialog: TOrderConfirmDialog
  Left = 376
  Top = 276
  BorderStyle = bsDialog
  Caption = 'Send this order?'
  ClientHeight = 169
  ClientWidth = 242
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 226
    Height = 129
    Shape = bsFrame
  end
  object LabelType: TLabel
    Left = 103
    Top = 19
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelAccount: TLabel
    Left = 103
    Top = 38
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelSymbol: TLabel
    Left = 103
    Top = 57
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelQty: TLabel
    Left = 103
    Top = 76
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object LabelPrice: TLabel
    Left = 103
    Top = 95
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object Label2: TLabel
    Left = 66
    Top = 19
    Width = 28
    Height = 13
    Caption = 'Type:'
  end
  object Label3: TLabel
    Left = 51
    Top = 38
    Width = 43
    Height = 13
    Caption = 'Account:'
  end
  object Label4: TLabel
    Left = 56
    Top = 57
    Width = 38
    Height = 13
    Caption = 'Symbol:'
  end
  object Label5: TLabel
    Left = 56
    Top = 76
    Width = 38
    Height = 13
    Caption = 'Volume:'
  end
  object Label6: TLabel
    Left = 67
    Top = 95
    Width = 27
    Height = 13
    Caption = 'Price:'
  end
  object Label7: TLabel
    Left = 17
    Top = 114
    Width = 77
    Height = 13
    Caption = 'Time-to-Market:'
  end
  object LabelTimeToMarket: TLabel
    Left = 103
    Top = 114
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlue
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
  end
  object ButtonYes: TButton
    Left = 43
    Top = 143
    Width = 72
    Height = 20
    Caption = '&Send'
    Default = True
    ModalResult = 6
    TabOrder = 0
  end
  object ButtonNo: TButton
    Left = 123
    Top = 143
    Width = 72
    Height = 20
    Cancel = True
    Caption = '&No'
    ModalResult = 2
    TabOrder = 1
  end
end
