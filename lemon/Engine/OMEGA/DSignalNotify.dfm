object SignalNotifyDialog: TSignalNotifyDialog
  Left = 471
  Top = 368
  BorderStyle = bsDialog
  Caption = '½ÅÈ£ ¹ß»ý'
  ClientHeight = 175
  ClientWidth = 265
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = '±¼¸²'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 9
    Width = 249
    Height = 128
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 20
    Top = 23
    Width = 42
    Height = 13
    Caption = '½Å È£ : '
  end
  object Label2: TLabel
    Left = 20
    Top = 46
    Width = 38
    Height = 13
    Caption = 'À§ Ä¡ :'
  end
  object Label3: TLabel
    Left = 20
    Top = 68
    Width = 38
    Height = 13
    Caption = 'Àü ·« :'
  end
  object Label5: TLabel
    Left = 20
    Top = 90
    Width = 38
    Height = 13
    Caption = '½Ã °¢ :'
  end
  object Label6: TLabel
    Left = 20
    Top = 113
    Width = 42
    Height = 13
    Caption = 'ÁÖ ¹® : '
  end
  object LabelAlias: TLabel
    Left = 68
    Top = 23
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = '±¼¸²'
    Font.Style = []
    ParentFont = False
  end
  object LabelSource: TLabel
    Left = 68
    Top = 46
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = '±¼¸²'
    Font.Style = []
    ParentFont = False
  end
  object LabelStratety: TLabel
    Left = 68
    Top = 68
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = '±¼¸²'
    Font.Style = []
    ParentFont = False
  end
  object LabelTime: TLabel
    Left = 68
    Top = 90
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = '±¼¸²'
    Font.Style = []
    ParentFont = False
  end
  object LabelOrder: TLabel
    Left = 68
    Top = 113
    Width = 12
    Height = 13
    Caption = '...'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = '±¼¸²'
    Font.Style = []
    ParentFont = False
  end
  object Button1: TButton
    Left = 96
    Top = 144
    Width = 75
    Height = 25
    Caption = 'È® ÀÎ(&O)'
    Default = True
    TabOrder = 0
    OnClick = Button1Click
  end
end
