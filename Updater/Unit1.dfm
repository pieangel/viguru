object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = '   Guru Update'
  ClientHeight = 260
  ClientWidth = 267
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object gbDown: TGroupBox
    Left = 271
    Top = 126
    Width = 257
    Height = 126
    TabOrder = 0
    object Label1: TLabel
      Left = 12
      Top = 23
      Width = 58
      Height = 13
      Caption = #51204#49569#54028#51068' : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 12
      Top = 45
      Width = 58
      Height = 13
      Caption = #51204#49569#49549#46020' : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label3: TLabel
      Left = 12
      Top = 95
      Width = 58
      Height = 13
      Caption = #51204#52404#44060#49688' : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label4: TLabel
      Left = 12
      Top = 66
      Width = 58
      Height = 13
      Caption = #51652#54665#49345#54889' : '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label_AvgSpeed: TLabel
      Left = 76
      Top = 45
      Width = 70
      Height = 13
      AutoSize = False
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object Label_Count: TLabel
      Left = 180
      Top = 45
      Width = 68
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object lbFileCnt: TLabel
      Left = 191
      Top = 82
      Width = 57
      Height = 13
      Alignment = taRightJustify
      AutoSize = False
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
    end
    object lbFileName: TLabel
      Left = 76
      Top = 23
      Width = 131
      Height = 13
      AutoSize = False
      Color = clBlue
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
    end
    object ProgressBar2: TProgressBar
      Left = 76
      Top = 97
      Width = 172
      Height = 13
      TabOrder = 0
    end
    object ProgressBar1: TProgressBar
      Left = 76
      Top = 66
      Width = 172
      Height = 13
      TabOrder = 1
    end
    object Button2: TButton
      Left = 204
      Top = 5
      Width = 44
      Height = 25
      Caption = #51473#51648
      TabOrder = 2
      OnClick = Button2Click
    end
  end
  object gb0Lee: TGroupBox
    Left = 4
    Top = 3
    Width = 257
    Height = 128
    TabOrder = 1
    object lbTitle: TLabel
      Left = 2
      Top = 15
      Width = 253
      Height = 21
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = #50689#47532' '#53944#47112#51060#46377' '#51064#51613
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clPurple
      Font.Height = -16
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      ExplicitLeft = 10
      ExplicitTop = 9
      ExplicitWidth = 244
    end
    object edt0LeeID: TLabeledEdit
      Left = 61
      Top = 45
      Width = 106
      Height = 21
      EditLabel.Width = 53
      EditLabel.Height = 13
      EditLabel.Caption = #49324#50857#51088' ID '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
    end
    object edt0LeePW: TLabeledEdit
      Left = 61
      Top = 72
      Width = 106
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Caption = #48708#48128#48264#54840' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      PasswordChar = '*'
      TabOrder = 1
    end
    object Button1: TButton
      Left = 173
      Top = 43
      Width = 68
      Height = 50
      Caption = #51064#51613
      TabOrder = 2
      OnClick = Button1Click
    end
    object stResult: TStaticText
      Left = 2
      Top = 109
      Width = 253
      Height = 17
      Align = alBottom
      AutoSize = False
      BorderStyle = sbsSunken
      TabOrder = 3
    end
  end
  object gbLogin: TGroupBox
    Left = 4
    Top = 129
    Width = 257
    Height = 126
    TabOrder = 2
    object edtID: TLabeledEdit
      Left = 61
      Top = 8
      Width = 106
      Height = 21
      EditLabel.Width = 53
      EditLabel.Height = 13
      EditLabel.Caption = #49324#50857#51088' ID '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      TabOrder = 0
      OnKeyPress = edtIDKeyPress
    end
    object edtPW: TLabeledEdit
      Left = 61
      Top = 35
      Width = 106
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Caption = #48708#48128#48264#54840' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      PasswordChar = '*'
      TabOrder = 1
      OnKeyPress = edtIDKeyPress
    end
    object edtCert: TLabeledEdit
      Left = 61
      Top = 62
      Width = 106
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Caption = #44277#51064#51064#51613' '
      ImeName = 'Microsoft Office IME 2007'
      LabelPosition = lpLeft
      PasswordChar = '#'
      TabOrder = 2
    end
    object btnCon: TButton
      Left = 173
      Top = 10
      Width = 68
      Height = 47
      Caption = #51217#49549
      Enabled = False
      TabOrder = 3
      OnClick = btnConClick
    end
    object btnExit: TButton
      Left = 197
      Top = 62
      Width = 44
      Height = 25
      Caption = #51333#47308
      TabOrder = 4
      OnClick = btnExitClick
    end
    object cbSaveInput: TCheckBox
      Left = 61
      Top = 91
      Width = 82
      Height = 17
      Caption = #51077#47141#44050#51200#51109
      Checked = True
      State = cbChecked
      TabOrder = 5
    end
    object cbMock: TCheckBox
      Left = 149
      Top = 91
      Width = 73
      Height = 17
      Caption = #47784#51032#44144#47000
      TabOrder = 6
      OnClick = cbMockClick
    end
  end
  object Ftp: TIdFTP
    OnWork = FtpWork
    OnWorkBegin = FtpWorkBegin
    OnWorkEnd = FtpWorkEnd
    AutoLogin = True
    ProxySettings.ProxyType = fpcmNone
    ProxySettings.Port = 0
    Left = 344
    Top = 8
  end
  object Timer: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerTimer
    Left = 368
    Top = 8
  end
  object IdAntiFreeze1: TIdAntiFreeze
    Left = 320
    Top = 8
  end
  object idh: TIdHTTP
    AllowCookies = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentType = 'application/x-www-form-urlencoded'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 392
    Top = 8
  end
  object IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL
    MaxLineAction = maException
    Port = 0
    DefaultPort = 0
    SSLOptions.Method = sslvSSLv23
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 424
    Top = 8
  end
end
