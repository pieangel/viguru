object ElwIv: TElwIv
  Left = 0
  Top = 0
  Caption = 'Elw IV'
  ClientHeight = 120
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 8
    Top = 75
    Width = 75
    Height = 25
    Caption = 'K200'#52488#44592#54868
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 128
    Top = 75
    Width = 75
    Height = 25
    Caption = #51452#49885#52488#44592#54868
    TabOrder = 1
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 248
    Top = 75
    Width = 75
    Height = 25
    Caption = #51204#52404
    TabOrder = 2
    OnClick = Button3Click
  end
  object plDr: TPanel
    Left = 8
    Top = 8
    Width = 129
    Height = 25
    TabOrder = 3
  end
  object Button4: TButton
    Left = 248
    Top = 24
    Width = 75
    Height = 25
    Caption = 'Button4'
    TabOrder = 4
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 8
    Top = 39
    Width = 49
    Height = 25
    Caption = 'Log'
    TabOrder = 5
    OnClick = Button5Click
  end
end
