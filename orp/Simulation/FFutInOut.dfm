object FutInOut: TFutInOut
  Left = 0
  Top = 0
  Caption = #49464#47141#52286#44592
  ClientHeight = 635
  ClientWidth = 391
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
  object Label1: TLabel
    Left = 8
    Top = 8
    Width = 34
    Height = 13
    Caption = #51333#47785' : '
  end
  object spStart: TSpeedButton
    Left = 8
    Top = 162
    Width = 67
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'START'
    OnClick = spStartClick
  end
  object Button2: TButton
    Left = 290
    Top = 5
    Width = 90
    Height = 21
    Caption = #51452#47928#52628#52636' '#48372#44592
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 305
    Top = 187
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 1
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 150
    Top = 5
    Width = 32
    Height = 20
    Caption = '...'
    TabOrder = 2
    OnClick = Button4Click
  end
  object ComboSymbol: TComboBox
    Left = 48
    Top = 5
    Width = 96
    Height = 21
    Style = csDropDownList
    ImeName = 'Microsoft IME 2003'
    ItemHeight = 13
    TabOrder = 3
    OnChange = ComboSymbolChange
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 32
    Width = 372
    Height = 121
    Caption = #54596#53552#47553
    TabOrder = 4
    object Bevel2: TBevel
      Left = 102
      Top = 38
      Width = 2
      Height = 60
    end
    object Label2: TLabel
      Left = 11
      Top = 19
      Width = 48
      Height = 13
      Caption = #51452#47928#48772#46412
    end
    object Label3: TLabel
      Left = 127
      Top = 19
      Width = 63
      Height = 13
      Caption = #48736#51652#54980' '#51452#47928
    end
    object Bevel1: TBevel
      Left = 228
      Top = 38
      Width = 2
      Height = 60
    end
    object Label4: TLabel
      Left = 243
      Top = 19
      Width = 39
      Height = 13
      Caption = #54056#45824#44592' '
    end
    object edtSec: TLabeledEdit
      Left = 52
      Top = 39
      Width = 31
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = 'Sec :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 0
      Text = '1'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtCount: TLabeledEdit
      Left = 52
      Top = 66
      Width = 31
      Height = 21
      EditLabel.Width = 36
      EditLabel.Height = 13
      EditLabel.Caption = 'Count :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 1
      Text = '3'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtOrdSec: TLabeledEdit
      Left = 159
      Top = 38
      Width = 31
      Height = 21
      EditLabel.Width = 24
      EditLabel.Height = 13
      EditLabel.Caption = 'Sec :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 2
      Text = '1'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtQty: TLabeledEdit
      Left = 52
      Top = 91
      Width = 31
      Height = 21
      EditLabel.Width = 28
      EditLabel.Height = 13
      EditLabel.Caption = 'Qty  :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 3
      Text = '2'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtPrev: TLabeledEdit
      Left = 299
      Top = 39
      Width = 31
      Height = 21
      EditLabel.Width = 51
      EditLabel.Height = 13
      EditLabel.Caption = #51649#51204' Sec :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 4
      Text = '5'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtSale: TLabeledEdit
      Left = 299
      Top = 66
      Width = 31
      Height = 21
      EditLabel.Width = 25
      EditLabel.Height = 13
      EditLabel.Caption = 'Qty :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 5
      Text = '100'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
    object edtafter: TLabeledEdit
      Left = 299
      Top = 91
      Width = 31
      Height = 21
      EditLabel.Width = 54
      EditLabel.Height = 13
      EditLabel.Caption = #51060#54980' Sec  :'
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      LabelPosition = lpLeft
      TabOrder = 6
      Text = '2'
      OnChange = edtSecChange
      OnExit = edtSecExit
      OnKeyPress = edtSecKeyPress
    end
  end
  object Button1: TButton
    Left = 8
    Top = 189
    Width = 67
    Height = 22
    Caption = #49464#47141#47196#44536
    TabOrder = 5
    OnClick = Button1Click
  end
  object Button5: TButton
    Left = 88
    Top = 190
    Width = 67
    Height = 22
    Caption = #54056#45824#44592#47196#44536
    TabOrder = 6
    OnClick = Button5Click
  end
  object stbar: TStatusBar
    Left = 0
    Top = 616
    Width = 391
    Height = 19
    Panels = <
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object Panel1: TPanel
    Left = 0
    Top = 232
    Width = 391
    Height = 384
    Align = alBottom
    Caption = 'Panel1'
    TabOrder = 8
    object sgForce: TStringGrid
      Left = 1
      Top = 1
      Width = 389
      Height = 382
      Align = alClient
      DefaultRowHeight = 17
      FixedCols = 0
      TabOrder = 0
      OnDblClick = sgForceDblClick
      OnMouseDown = sgForceMouseDown
    end
  end
end
