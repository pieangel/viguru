object DateDialog: TDateDialog
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Date'
  ClientHeight = 85
  ClientWidth = 170
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 155
    Height = 38
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 19
    Top = 19
    Width = 30
    Height = 13
    Caption = 'Date: '
  end
  object DateTimePicker: TDateTimePicker
    Left = 56
    Top = 17
    Width = 97
    Height = 21
    Date = 39497.943875462970000000
    Time = 39497.943875462970000000
    TabOrder = 0
  end
  object ButtonOK: TButton
    Left = 17
    Top = 52
    Width = 65
    Height = 25
    Caption = '&OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object Button2: TButton
    Left = 90
    Top = 52
    Width = 65
    Height = 25
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
