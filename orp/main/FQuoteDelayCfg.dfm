object FrmQuoteDelayCfg: TFrmQuoteDelayCfg
  Left = 0
  Top = 0
  Caption = #49884#49464#46364#47112#51060#49444#51221
  ClientHeight = 243
  ClientWidth = 482
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
  object cbUse: TCheckBox
    Left = 8
    Top = 8
    Width = 153
    Height = 17
    Caption = #49884#49464#46364#47112#51060#44536#47000#54532' '#54364#49884
    TabOrder = 0
    OnClick = cbUseClick
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 31
    Width = 457
    Height = 170
    Caption = #49884#49464#46364#47112#51060
    TabOrder = 1
    object Label1: TLabel
      Left = 12
      Top = 23
      Width = 55
      Height = 13
      Caption = #44081#49888#51452#44592' :'
    end
    object Label2: TLabel
      Left = 24
      Top = 45
      Width = 43
      Height = 13
      Caption = 'Min Sec :'
    end
    object Label3: TLabel
      Left = 20
      Top = 67
      Width = 47
      Height = 13
      Caption = 'Max Sec :'
    end
    object Label4: TLabel
      Left = 12
      Top = 92
      Width = 55
      Height = 13
      Caption = #49353#49345#49440#53469' :'
    end
    object Label5: TLabel
      Left = 76
      Top = 93
      Width = 13
      Height = 13
      Caption = 'F :'
    end
    object Label6: TLabel
      Left = 76
      Top = 118
      Width = 14
      Height = 13
      Caption = 'C :'
    end
    object Label7: TLabel
      Left = 76
      Top = 144
      Width = 13
      Height = 13
      Caption = 'P :'
    end
    object edtTimer: TEdit
      Left = 73
      Top = 16
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
      Text = '300'
    end
    object edtMaxSec: TEdit
      Left = 73
      Top = 65
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '3'
    end
    object plFut: TPanel
      Left = 98
      Top = 91
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 2
    end
    object Button1: TButton
      Left = 169
      Top = 91
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 3
      OnClick = Button1Click
    end
    object plCall: TPanel
      Left = 98
      Top = 116
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 4
    end
    object Button2: TButton
      Tag = 10
      Left = 169
      Top = 116
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 5
      OnClick = Button1Click
    end
    object plPut: TPanel
      Left = 98
      Top = 141
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 6
    end
    object Button3: TButton
      Tag = 20
      Left = 169
      Top = 141
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 7
      OnClick = Button1Click
    end
    object edtMinSec: TEdit
      Left = 73
      Top = 43
      Width = 37
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 8
      Text = '0.2'
    end
    object GroupBox2: TGroupBox
      Left = 212
      Top = 14
      Width = 229
      Height = 146
      Caption = #46364#47112#51060#49324#50868#46300' '#49324#50857
      TabOrder = 9
      object Label11: TLabel
        Left = 11
        Top = 100
        Width = 89
        Height = 13
        Caption = #46364#47112#51060' '#52572#49548#44050' + '
      end
      object Label12: TLabel
        Left = 141
        Top = 102
        Width = 48
        Height = 13
        Caption = #52488#44284#51068#46412
      end
      object edtFut: TEdit
        Left = 52
        Top = 20
        Width = 94
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 0
      end
      object btnFut: TButton
        Left = 152
        Top = 19
        Width = 29
        Height = 21
        Caption = '....'
        TabOrder = 1
        OnClick = btnFutClick
      end
      object spFut: TButton
        Left = 188
        Top = 19
        Width = 27
        Height = 21
        Caption = #9654
        TabOrder = 2
        OnClick = spFutClick
      end
      object spCall: TButton
        Tag = 1
        Left = 188
        Top = 45
        Width = 27
        Height = 21
        Caption = #9654
        TabOrder = 3
        OnClick = spFutClick
      end
      object spPut: TButton
        Tag = 2
        Left = 189
        Top = 68
        Width = 27
        Height = 21
        Caption = #9654
        TabOrder = 4
        OnClick = spFutClick
      end
      object btnCall: TButton
        Tag = 1
        Left = 153
        Top = 43
        Width = 29
        Height = 21
        Caption = '....'
        TabOrder = 5
        OnClick = btnFutClick
      end
      object btnPut: TButton
        Tag = 2
        Left = 154
        Top = 68
        Width = 29
        Height = 21
        Caption = '....'
        TabOrder = 6
        OnClick = btnFutClick
      end
      object edtPut: TEdit
        Tag = 2
        Left = 52
        Top = 67
        Width = 94
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 7
      end
      object edtCall: TEdit
        Tag = 1
        Left = 52
        Top = 42
        Width = 94
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 8
      end
      object edtShift: TEdit
        Left = 103
        Top = 97
        Width = 28
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 9
        Text = '0'
      end
      object cbFut: TCheckBox
        Left = 11
        Top = 21
        Width = 32
        Height = 17
        Caption = 'F'
        TabOrder = 10
        OnClick = cbPutClick
      end
      object cbCall: TCheckBox
        Tag = 1
        Left = 12
        Top = 44
        Width = 29
        Height = 17
        Caption = 'C'
        TabOrder = 11
        OnClick = cbPutClick
      end
      object cbPut: TCheckBox
        Tag = 2
        Left = 12
        Top = 67
        Width = 26
        Height = 17
        Caption = 'P'
        TabOrder = 12
        OnClick = cbPutClick
      end
    end
  end
  object Button4: TButton
    Left = 59
    Top = 207
    Width = 59
    Height = 25
    Caption = #54869' '#51064
    TabOrder = 2
    OnClick = Button4Click
  end
  object Button5: TButton
    Left = 149
    Top = 207
    Width = 59
    Height = 25
    Caption = #51201' '#50857
    TabOrder = 3
    OnClick = Button5Click
  end
  object dlgColor: TColorDialog
    Left = 144
    Top = 64
  end
  object dlgOpen: TOpenDialog
    Filter = '*.wav|*.wav'
    InitialDir = '/env'
    Left = 42
    Top = 144
  end
end
