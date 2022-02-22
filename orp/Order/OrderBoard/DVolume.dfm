object FrmVolume: TFrmVolume
  Left = 0
  Top = 0
  BorderIcons = [biMinimize, biMaximize]
  BorderStyle = bsDialog
  Caption = 'Volume'
  ClientHeight = 71
  ClientWidth = 145
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
  object edtVolume: TEdit
    Left = 8
    Top = 8
    Width = 121
    Height = 21
    ImeName = 'Microsoft IME 2003'
    TabOrder = 0
    OnKeyPress = edtVolumeKeyPress
  end
  object Button1: TButton
    Left = 62
    Top = 38
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
end
