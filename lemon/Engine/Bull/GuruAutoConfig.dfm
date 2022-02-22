object GuruAuto: TGuruAuto
  Left = 0
  Top = 0
  Caption = 'Guru Auto '#49444#51221
  ClientHeight = 98
  ClientWidth = 291
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object StatusBar1: TStatusBar
    Left = 0
    Top = 79
    Width = 291
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitTop = 73
    ExplicitWidth = 289
  end
  object btOFF: TButton
    Left = 136
    Top = 24
    Width = 97
    Height = 33
    Caption = 'OFF'
    TabOrder = 1
    OnClick = btOFFClick
  end
  object btON: TButton
    Left = 8
    Top = 24
    Width = 97
    Height = 33
    Caption = 'ON'
    TabOrder = 2
    OnClick = btONClick
  end
end
