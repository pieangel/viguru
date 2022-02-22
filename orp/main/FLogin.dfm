object Login: TLogin
  Left = 0
  Top = 0
  ClientHeight = 114
  ClientWidth = 333
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object processCnt: TLabel
    Left = 8
    Top = 72
    Width = 78
    Height = 17
    AutoSize = False
    Caption = 'aaa'
  end
  object processName: TLabel
    Left = 8
    Top = 49
    Width = 78
    Height = 17
    AutoSize = False
    Caption = 'aaa'
  end
  object pBar: TProgressBar
    Left = 3
    Top = 96
    Width = 326
    Height = 16
    TabOrder = 0
  end
  object Button1: TButton
    Left = 284
    Top = 65
    Width = 41
    Height = 25
    Caption = #51333#47308
    TabOrder = 1
    OnClick = Button1Click
  end
end
