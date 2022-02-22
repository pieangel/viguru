object FrmAnalysis: TFrmAnalysis
  Left = 0
  Top = 0
  Caption = #49464#47141' '#48516#49437
  ClientHeight = 472
  ClientWidth = 500
  Color = 15387315
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object plTop: TPanel
    Left = 0
    Top = 0
    Width = 500
    Height = 25
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 8
      Width = 27
      Height = 13
      Caption = #51333#47785' '
    end
    object Label2: TLabel
      Left = 252
      Top = 6
      Width = 24
      Height = 13
      Caption = #49464#47141
    end
    object Label3: TLabel
      Left = 334
      Top = 6
      Width = 24
      Height = 13
      Caption = #51060#49345
    end
    object cbCode: TComboBox
      Left = 45
      Top = 3
      Width = 76
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 0
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbCodeChange
    end
    object Button1: TButton
      Left = 127
      Top = 3
      Width = 25
      Height = 20
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 161
      Top = 4
      Width = 76
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ReadOnly = True
      TabOrder = 2
    end
    object Edit2: TEdit
      Left = 280
      Top = 3
      Width = 31
      Height = 19
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      TabOrder = 3
      Text = '20'
      OnKeyDown = Edit2KeyDown
    end
    object upFilter: TUpDown
      Left = 311
      Top = 3
      Width = 16
      Height = 19
      Associate = Edit2
      Position = 20
      TabOrder = 4
    end
    object rdPrice: TRadioButton
      Left = 376
      Top = 4
      Width = 49
      Height = 17
      Caption = #44032#44201
      Checked = True
      TabOrder = 5
      TabStop = True
    end
    object rdHoga: TRadioButton
      Tag = 1
      Left = 431
      Top = 4
      Width = 49
      Height = 17
      Caption = #54840#44032
      TabOrder = 6
      OnClick = rdHogaClick
    end
  end
  object plInfo: TPanel
    Left = 0
    Top = 25
    Width = 500
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
  end
  object plHoga: TPanel
    Left = 0
    Top = 73
    Width = 500
    Height = 340
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 2
  end
  object plDist: TPanel
    Left = 0
    Top = 413
    Width = 500
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 3
  end
end
