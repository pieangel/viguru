object FrmSetTimer: TFrmSetTimer
  Left = 0
  Top = 0
  Caption = #53440#51060#47672#49444#51221
  ClientHeight = 145
  ClientWidth = 275
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 8
    Top = 8
    Width = 46
    Height = 13
    Caption = #53440#51060#53952' : '
  end
  object Label1: TLabel
    Left = 17
    Top = 41
    Width = 37
    Height = 13
    Caption = #49884' '#44036' : '
  end
  object Label2: TLabel
    Left = 8
    Top = 71
    Width = 46
    Height = 13
    Caption = #49324#50868#46300' : '
  end
  object Button2: TButton
    Left = 192
    Top = 114
    Width = 75
    Height = 22
    Caption = #45803#44592
    TabOrder = 0
    OnClick = Button2Click
  end
  object edtSound: TEdit
    Left = 60
    Top = 70
    Width = 135
    Height = 21
    ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
    TabOrder = 1
  end
  object btnElw: TButton
    Tag = 2
    Left = 201
    Top = 71
    Width = 29
    Height = 20
    Caption = '....'
    TabOrder = 2
    OnClick = btnElwClick
  end
  object Button3: TButton
    Left = 236
    Top = 70
    Width = 27
    Height = 21
    Caption = #9654
    TabOrder = 3
    OnClick = Button3Click
  end
  object Button1: TButton
    Left = 60
    Top = 114
    Width = 75
    Height = 22
    Caption = 'Add'
    TabOrder = 4
    OnClick = Button1Click
  end
  object edtTitle: TEdit
    Left = 60
    Top = 5
    Width = 112
    Height = 21
    ImeName = 'Microsoft Office IME 2007'
    TabOrder = 5
  end
  object dtTimer: TDateTimePicker
    Left = 60
    Top = 37
    Width = 98
    Height = 21
    Date = 38303.375000000000000000
    Time = 38303.375000000000000000
    ImeName = 'Korean Input System (IME 2000)'
    Kind = dtkTime
    TabOrder = 6
  end
  object dlgOpen: TOpenDialog
    Filter = '*.wav|*.wav'
    InitialDir = 'C:\WINDOWS\Media'
    Left = 98
    Top = 128
  end
end
