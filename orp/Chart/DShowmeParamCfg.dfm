object ShowMeParamCfg: TShowMeParamCfg
  Left = 0
  Top = 0
  Caption = 'ShowMe '#49444#51221
  ClientHeight = 248
  ClientWidth = 259
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonOK: TButton
    Left = 40
    Top = 215
    Width = 75
    Height = 25
    Caption = #54869' '#51064'(&O)'
    Default = True
    TabOrder = 0
    OnClick = ButtonOKClick
  end
  object Button2: TButton
    Left = 145
    Top = 215
    Width = 75
    Height = 25
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 1
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 243
    Height = 185
    Caption = 'gbName'
    TabOrder = 2
    object Label3: TLabel
      Left = 17
      Top = 107
      Width = 47
      Height = 13
      Caption = 'Position : '
    end
    object Label2: TLabel
      Left = 14
      Top = 75
      Width = 49
      Height = 13
      Caption = 'BidColor : '
    end
    object Label1: TLabel
      Left = 14
      Top = 50
      Width = 52
      Height = 13
      Caption = 'AskColor : '
    end
    object AskColor: TShape
      Left = 72
      Top = 50
      Width = 67
      Height = 17
      Brush.Color = clBlue
    end
    object BidColor: TShape
      Left = 72
      Top = 75
      Width = 67
      Height = 17
    end
    object SpeedButton1: TSpeedButton
      Left = 142
      Top = 72
      Width = 23
      Height = 22
      Caption = '...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButton1Click
    end
    object ButtonColor: TSpeedButton
      Left = 142
      Top = 47
      Width = 23
      Height = 22
      Caption = '...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonColorClick
    end
    object Label4: TLabel
      Left = 17
      Top = 131
      Width = 34
      Height = 13
      Caption = #44228#51340' : '
    end
    object SpeedButton2: TSpeedButton
      Left = 165
      Top = 131
      Width = 23
      Height = 22
      Caption = '...'
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = SpeedButton2Click
    end
    object edtPos: TEdit
      Left = 70
      Top = 104
      Width = 42
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
      Text = '1'
    end
    object edtParam: TEdit
      Left = 70
      Top = 131
      Width = 87
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
    end
  end
  object ColorDialog: TColorDialog
    Left = 304
    Top = 112
  end
end
