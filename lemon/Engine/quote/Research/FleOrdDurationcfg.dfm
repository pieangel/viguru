object FrmOrdDuarCfg: TFrmOrdDuarCfg
  Left = 0
  Top = 0
  Caption = 'Order Duration Cfg'
  ClientHeight = 262
  ClientWidth = 396
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
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 329
    Top = 231
    Width = 59
    Height = 25
    Caption = #51333' '#47308
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object btnApply: TButton
    Left = 264
    Top = 231
    Width = 59
    Height = 25
    Caption = #51201' '#50857
    TabOrder = 1
    OnClick = btnApplyClick
  end
  object GroupBox1: TGroupBox
    Left = 167
    Top = 8
    Width = 223
    Height = 97
    Caption = #49324#50868#46300#49444#51221
    TabOrder = 2
    object cbFut: TCheckBox
      Left = 11
      Top = 21
      Width = 32
      Height = 17
      Caption = 'F'
      TabOrder = 0
      OnClick = cbFutClick
    end
    object cbCall: TCheckBox
      Tag = 1
      Left = 12
      Top = 44
      Width = 29
      Height = 17
      Caption = 'C'
      TabOrder = 1
      OnClick = cbFutClick
    end
    object cbPut: TCheckBox
      Tag = 2
      Left = 12
      Top = 67
      Width = 26
      Height = 17
      Caption = 'P'
      TabOrder = 2
      OnClick = cbFutClick
    end
    object edtPut: TEdit
      Tag = 2
      Left = 52
      Top = 67
      Width = 94
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 3
    end
    object edtCall: TEdit
      Tag = 1
      Left = 52
      Top = 42
      Width = 94
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 4
    end
    object edtFut: TEdit
      Left = 52
      Top = 20
      Width = 94
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 5
    end
    object btnFut: TButton
      Left = 153
      Top = 19
      Width = 29
      Height = 21
      Caption = '....'
      TabOrder = 6
      OnClick = btnFutClick
    end
    object btnCall: TButton
      Tag = 1
      Left = 153
      Top = 43
      Width = 29
      Height = 21
      Caption = '....'
      TabOrder = 7
      OnClick = btnFutClick
    end
    object btnPut: TButton
      Tag = 2
      Left = 153
      Top = 68
      Width = 29
      Height = 21
      Caption = '....'
      TabOrder = 8
      OnClick = btnFutClick
    end
    object spPut: TButton
      Tag = 2
      Left = 184
      Top = 68
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 9
      OnClick = spFutClick
    end
    object spCall: TButton
      Tag = 1
      Left = 184
      Top = 43
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 10
      OnClick = spFutClick
    end
    object spFut: TButton
      Left = 184
      Top = 19
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 11
      OnClick = spFutClick
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 8
    Width = 153
    Height = 97
    Caption = #49353#49345' '#49444#51221
    TabOrder = 3
    object Label5: TLabel
      Left = 20
      Top = 22
      Width = 13
      Height = 13
      Caption = 'F :'
    end
    object Label6: TLabel
      Left = 20
      Top = 47
      Width = 14
      Height = 13
      Caption = 'C :'
    end
    object Label7: TLabel
      Left = 20
      Top = 73
      Width = 13
      Height = 13
      Caption = 'P :'
    end
    object plPut: TPanel
      Left = 42
      Top = 70
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 0
    end
    object plCall: TPanel
      Left = 42
      Top = 45
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 1
    end
    object plFut: TPanel
      Left = 42
      Top = 20
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 2
    end
    object btnFColor: TButton
      Left = 113
      Top = 20
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 3
      OnClick = btnFColorClick
    end
    object btnCColor: TButton
      Tag = 10
      Left = 113
      Top = 45
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 4
      OnClick = btnFColorClick
    end
    object btnPColor: TButton
      Tag = 20
      Left = 113
      Top = 70
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 5
      OnClick = btnFColorClick
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 111
    Width = 169
    Height = 114
    Caption = #51333#47785#49444#51221
    TabOrder = 4
    object btnIColor: TButton
      Tag = 30
      Left = 139
      Top = 55
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 0
      OnClick = btnFColorClick
    end
    object plIssue: TPanel
      Left = 9
      Top = 55
      Width = 127
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 1
    end
    object edtIssue: TEdit
      Left = 20
      Top = 83
      Width = 84
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 2
    end
    object cbIssue: TCheckBox
      Tag = 3
      Left = 4
      Top = 86
      Width = 16
      Height = 17
      TabOrder = 3
      OnClick = cbFutClick
    end
    object btnIssue: TButton
      Tag = 3
      Left = 107
      Top = 84
      Width = 29
      Height = 21
      Caption = '....'
      TabOrder = 4
      OnClick = btnFutClick
    end
    object spIssue: TButton
      Tag = 3
      Left = 138
      Top = 84
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 5
      OnClick = spFutClick
    end
    object cbCode: TComboBox
      Left = 7
      Top = 21
      Width = 159
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 6
      OnChange = cbCodeChange
    end
  end
  object GroupBox4: TGroupBox
    Left = 183
    Top = 111
    Width = 205
    Height = 114
    Caption = #51312#44148#49444#51221
    TabOrder = 5
    object Label1: TLabel
      Left = 152
      Top = 12
      Width = 46
      Height = 13
      Caption = #45800#50948'(MS)'
    end
    object Label2: TLabel
      Left = 10
      Top = 36
      Width = 37
      Height = 13
      Caption = '1'#45800#44228' :'
    end
    object Label3: TLabel
      Left = 118
      Top = 36
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label4: TLabel
      Left = 10
      Top = 63
      Width = 37
      Height = 13
      Caption = '2'#45800#44228' :'
    end
    object Label8: TLabel
      Left = 118
      Top = 63
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label9: TLabel
      Left = 10
      Top = 90
      Width = 37
      Height = 13
      Caption = '3'#45800#44228' :'
    end
    object Label10: TLabel
      Left = 118
      Top = 90
      Width = 8
      Height = 13
      Caption = '~'
    end
    object edtOneS: TEdit
      Left = 59
      Top = 33
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 0
      Text = '0'
      OnKeyPress = edtOneSKeyPress
    end
    object edtOneE: TEdit
      Left = 132
      Top = 33
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 1
      Text = '40'
      OnKeyPress = edtOneSKeyPress
    end
    object edtTwoS: TEdit
      Left = 59
      Top = 60
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 2
      Text = '41'
      OnKeyPress = edtOneSKeyPress
    end
    object edtTwoE: TEdit
      Left = 132
      Top = 60
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 3
      Text = '80'
      OnKeyPress = edtOneSKeyPress
    end
    object edtThreeS: TEdit
      Left = 59
      Top = 87
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 4
      Text = '81'
      OnKeyPress = edtOneSKeyPress
    end
    object edtThreeE: TEdit
      Left = 132
      Top = 87
      Width = 53
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 5
      OnKeyPress = edtOneSKeyPress
    end
  end
  object dlgColor: TColorDialog
    Left = 192
    Top = 232
  end
  object dlgOpen: TOpenDialog
    Filter = '*.wav|*.wav'
    InitialDir = 'c:\WINDOWS\Media'
    Left = 226
    Top = 232
  end
end
