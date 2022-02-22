object FrmTool: TFrmTool
  Left = 0
  Top = 0
  Caption = #54872#44221#49500#51221
  ClientHeight = 368
  ClientWidth = 342
  Color = clBtnFace
  Constraints.MaxWidth = 358
  Constraints.MinHeight = 240
  Constraints.MinWidth = 350
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
  object GroupBox1: TGroupBox
    Left = 8
    Top = 397
    Width = 329
    Height = 114
    Caption = #49884#49464' '#46364#47112#51060' '#49324#50868#46300
    TabOrder = 0
    Visible = False
    object Label2: TLabel
      Left = 99
      Top = 27
      Width = 24
      Height = 13
      Caption = #51060#49345
    end
    object Label4: TLabel
      Left = 99
      Top = 55
      Width = 24
      Height = 13
      Caption = #51060#49345
    end
    object Label3: TLabel
      Left = 99
      Top = 83
      Width = 24
      Height = 13
      Caption = #51060#49345
    end
    object edtFut: TEdit
      Left = 132
      Top = 23
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 0
    end
    object btnFut: TButton
      Left = 271
      Top = 27
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 1
      OnClick = btnFutClick
    end
    object edtCall: TEdit
      Left = 132
      Top = 50
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 2
    end
    object btnStock: TButton
      Tag = 1
      Left = 271
      Top = 53
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 3
      OnClick = btnFutClick
    end
    object cbFut: TCheckBox
      Left = 16
      Top = 25
      Width = 41
      Height = 17
      Caption = #49440#47932
      TabOrder = 4
      OnClick = cbFutClick
    end
    object cbcall: TCheckBox
      Tag = 1
      Left = 16
      Top = 53
      Width = 41
      Height = 17
      Caption = #53084#50741
      TabOrder = 5
      OnClick = cbFutClick
    end
    object cbput: TCheckBox
      Tag = 2
      Left = 16
      Top = 82
      Width = 41
      Height = 17
      Caption = #54411#50741
      TabOrder = 6
      OnClick = cbFutClick
    end
    object edtPut: TEdit
      Left = 132
      Top = 77
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 7
    end
    object btnElw: TButton
      Tag = 2
      Left = 271
      Top = 78
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 8
      OnClick = btnFutClick
    end
    object edtFutSec: TEdit
      Left = 61
      Top = 25
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
    end
    object edtCallSec: TEdit
      Left = 61
      Top = 52
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 10
    end
    object edtPutSec: TEdit
      Left = 61
      Top = 80
      Width = 32
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 11
    end
    object Button4: TButton
      Left = 299
      Top = 25
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 12
      OnClick = Button3Click
    end
    object Button7: TButton
      Tag = 1
      Left = 299
      Top = 52
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 13
      OnClick = Button3Click
    end
    object Button9: TButton
      Tag = 2
      Left = 299
      Top = 77
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 14
      OnClick = Button3Click
    end
  end
  object Button5: TButton
    Left = 200
    Top = 336
    Width = 58
    Height = 25
    Caption = #54869' '#51064
    TabOrder = 1
    OnClick = Button5Click
  end
  object Button6: TButton
    Left = 276
    Top = 336
    Width = 58
    Height = 25
    Caption = #52712' '#49548
    TabOrder = 2
    OnClick = Button6Click
  end
  object GroupBox2: TGroupBox
    Left = 326
    Top = 173
    Width = 329
    Height = 50
    Caption = #51452#47928#52285' '#49884#49464' '#44081#49888' '#51452#44592
    TabOrder = 3
    Visible = False
    object Label1: TLabel
      Left = 150
      Top = 24
      Width = 16
      Height = 13
      Caption = 'ms '
    end
    object cbMS: TCheckBox
      Left = 16
      Top = 23
      Width = 49
      Height = 17
      Caption = #49324#50857
      TabOrder = 0
      OnClick = cbFutClick
    end
    object edtMS: TEdit
      Left = 96
      Top = 21
      Width = 33
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '8'
    end
    object udMS: TUpDown
      Left = 129
      Top = 21
      Width = 15
      Height = 21
      Associate = edtMS
      Position = 8
      TabOrder = 2
    end
  end
  object GroupBox3: TGroupBox
    Left = 5
    Top = 70
    Width = 329
    Height = 160
    Caption = #50508#46988
    TabOrder = 4
    object lvTimer: TListView
      Left = 2
      Top = 37
      Width = 325
      Height = 121
      Align = alBottom
      Checkboxes = True
      Columns = <
        item
          Width = 20
        end
        item
          Caption = #51060#47492
          Width = 60
        end
        item
          Caption = #49884#44036
          Width = 70
        end
        item
          Caption = #49324#50868#46300
          Width = 170
        end>
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = lvTimerDblClick
      OnMouseDown = lvTimerMouseDown
    end
    object edtAdd: TButton
      Left = 290
      Top = 11
      Width = 25
      Height = 20
      Caption = '+'
      TabOrder = 1
      OnClick = edtAddClick
    end
    object edtDel: TButton
      Left = 187
      Top = 11
      Width = 25
      Height = 20
      Caption = #12641
      TabOrder = 2
      OnClick = edtDelClick
    end
    object cbUseAlram: TCheckBox
      Left = 7
      Top = 17
      Width = 42
      Height = 17
      Caption = 'Use'
      TabOrder = 3
      OnClick = cbUseAlramClick
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 231
    Width = 327
    Height = 99
    Caption = #51088#46041#51452#47928' '#49324#50868#46300
    TabOrder = 5
    object cbVolStop: TCheckBox
      Tag = 1
      Left = 16
      Top = 19
      Width = 65
      Height = 17
      Caption = #51092#47049#49828#53457
      TabOrder = 0
      OnClick = cbFutClick
    end
    object edtVolStop: TEdit
      Left = 130
      Top = 17
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 1
    end
    object Button1: TButton
      Tag = 1
      Left = 269
      Top = 23
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 2
      OnClick = btnFutClick
    end
    object cbFrontQt: TCheckBox
      Tag = 2
      Left = 16
      Top = 45
      Width = 89
      Height = 17
      Hint = 'Front Quoting'
      Caption = 'Front Quoting'
      TabOrder = 3
      OnClick = cbFutClick
    end
    object edtFrontQt: TEdit
      Left = 129
      Top = 44
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 4
    end
    object Button8: TButton
      Tag = 2
      Left = 269
      Top = 49
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 5
      OnClick = btnFutClick
    end
    object Button3: TButton
      Tag = 1
      Left = 296
      Top = 20
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 6
      OnClick = Button3Click
    end
    object Button2: TButton
      Tag = 2
      Left = 296
      Top = 44
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 7
      OnClick = Button3Click
    end
    object cbSCatch: TCheckBox
      Tag = 3
      Left = 15
      Top = 71
      Width = 89
      Height = 17
      Hint = 'cbSCatch'
      Caption = 'SCatch'
      TabOrder = 8
      OnClick = cbFutClick
    end
    object edtSCatch: TEdit
      Left = 128
      Top = 70
      Width = 134
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 9
    end
    object Button10: TButton
      Tag = 3
      Left = 268
      Top = 75
      Width = 25
      Height = 15
      Caption = '....'
      TabOrder = 10
      OnClick = btnFutClick
    end
    object Button11: TButton
      Tag = 3
      Left = 296
      Top = 70
      Width = 27
      Height = 21
      Caption = #9654
      TabOrder = 11
      OnClick = Button3Click
    end
  end
  object GroupBox5: TGroupBox
    Left = 5
    Top = 3
    Width = 329
    Height = 65
    Caption = #54788#51116#49884#44033#49444#51221
    TabOrder = 6
    object Label5: TLabel
      Left = 119
      Top = 17
      Width = 50
      Height = 13
      Caption = 'Font Color'
    end
    object Label6: TLabel
      Left = 120
      Top = 40
      Width = 41
      Height = 13
      Caption = 'BG Color'
    end
    object Label7: TLabel
      Left = 20
      Top = 40
      Width = 44
      Height = 13
      Caption = 'Font Size'
    end
    object plFont: TPanel
      Left = 173
      Top = 15
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 0
    end
    object btnFColor: TButton
      Tag = 10
      Left = 244
      Top = 15
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 1
      OnClick = btnFColorClick
    end
    object plBg: TPanel
      Left = 173
      Top = 38
      Width = 67
      Height = 19
      Alignment = taLeftJustify
      BevelOuter = bvLowered
      ParentBackground = False
      TabOrder = 2
    end
    object btnBGColor: TButton
      Tag = 20
      Left = 244
      Top = 38
      Width = 27
      Height = 19
      Caption = '...'
      TabOrder = 3
      OnClick = btnFColorClick
    end
    object cbSize: TComboBox
      Left = 72
      Top = 36
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      ItemIndex = 0
      TabOrder = 4
      Text = '1'
      Items.Strings = (
        '1'
        '2'
        '3'
        '4'
        '5'
        '6'
        '7'
        '8'
        '9'
        '10'
        '11'
        '12'
        '13'
        '14'
        '15'
        '16'
        '17'
        '18'
        '19'
        '20')
    end
    object btnTime: TButton
      Tag = 10
      Left = 274
      Top = 15
      Width = 52
      Height = 42
      Caption = #54788#51116#49884#44033
      TabOrder = 5
      OnClick = btnTimeClick
    end
    object cbOnTop: TCheckBox
      Tag = 1
      Left = 19
      Top = 17
      Width = 65
      Height = 17
      Caption = #54637#49345' '#50948
      TabOrder = 6
      OnClick = cbFutClick
    end
  end
  object GroupBox6: TGroupBox
    Left = 171
    Top = 379
    Width = 105
    Height = 35
    Caption = #48513#47560#53356
    TabOrder = 7
    Visible = False
    object Label8: TLabel
      Left = 7
      Top = 15
      Width = 38
      Height = 13
      Caption = 'Hot Key'
    end
    object cbHotkey: TComboBox
      Left = 49
      Top = 11
      Width = 49
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      Text = 'F2'
      Items.Strings = (
        'F2'
        'F3'
        'F4'
        'F5'
        'F6'
        'F7'
        'F8'
        'F9'
        'F10'
        'F11'
        'F12')
    end
  end
  object dlgOpen: TOpenDialog
    Filter = '*.wav|*.wav'
    Left = 226
    Top = 78
  end
  object dlgColor: TColorDialog
    Left = 72
    Top = 80
  end
end
