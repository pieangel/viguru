object ProtectStopOrder: TProtectStopOrder
  Left = 0
  Top = 0
  Caption = 'Protected Stop'
  ClientHeight = 518
  ClientWidth = 394
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
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 394
    Height = 29
    Align = alTop
    ParentColor = True
    TabOrder = 0
    object BtnCohesionSymbol: TSpeedButton
      Left = 291
      Top = 5
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = BtnCohesionSymbolClick
    end
    object ButtonAuto: TSpeedButton
      Left = 8
      Top = 5
      Width = 41
      Height = 21
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Stop'
      OnClick = ButtonAutoClick
    end
    object btnShow: TSpeedButton
      Left = 320
      Top = 5
      Width = 41
      Height = 21
      AllowAllUp = True
      GroupIndex = 2
      Caption = #9660
      OnClick = btnShowClick
    end
    object cbSymbol: TComboBox
      Left = 185
      Top = 5
      Width = 100
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbSymbolChange
    end
    object ComboAccount: TComboBox
      Left = 55
      Top = 5
      Width = 124
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 35
    Width = 185
    Height = 102
    Caption = #49892#54665#51312#44148
    TabOrder = 1
    object rdExecConDeposit: TRadioButton
      Left = 16
      Top = 24
      Width = 73
      Height = 17
      Caption = #49345#45824#54840#44032' '
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rdExecConDepositClick
    end
    object rdExecConSame: TRadioButton
      Tag = 1
      Left = 15
      Top = 47
      Width = 74
      Height = 17
      Caption = #44057#51008#54840#44032'   <'
      TabOrder = 1
      OnClick = rdExecConDepositClick
    end
    object rdExecConCur: TRadioButton
      Tag = 2
      Left = 16
      Top = 70
      Width = 73
      Height = 17
      Caption = #54788#51116#44032'       <'
      TabOrder = 2
      OnClick = rdExecConDepositClick
    end
    object edtExecConDeposit: TEdit
      Left = 113
      Top = 20
      Width = 48
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      OnChange = edtExecConDepositChange
      OnKeyPress = edtExecConDepositKeyPress
    end
    object edtExecConSame: TEdit
      Left = 113
      Top = 44
      Width = 48
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 4
      OnChange = edtExecConDepositChange
    end
    object edtExecConCur: TEdit
      Left = 113
      Top = 66
      Width = 48
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 5
      OnChange = edtExecConDepositChange
    end
  end
  object GroupBox2: TGroupBox
    Left = 199
    Top = 35
    Width = 185
    Height = 102
    Caption = #51452#47928#49688#47049
    TabOrder = 2
    object rdClear: TRadioButton
      Left = 16
      Top = 24
      Width = 113
      Height = 17
      Caption = #52397#49328#44032#45733#49688#47049'   / '
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rdClearClick
    end
    object rdFixClear: TRadioButton
      Tag = 1
      Left = 15
      Top = 47
      Width = 153
      Height = 17
      Caption = 'Min( '#44256#51221#49688#47049', '#52397#49328#44032#45733')'
      TabOrder = 1
      OnClick = rdClearClick
    end
    object edtClear: TEdit
      Left = 125
      Top = 20
      Width = 38
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 2
      Text = '1'
      OnChange = edtExecConDepositChange
    end
    object edtFixClear: TEdit
      Left = 55
      Top = 70
      Width = 44
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      OnChange = edtExecConDepositChange
    end
    object udClear: TUpDown
      Left = 163
      Top = 20
      Width = 15
      Height = 21
      Associate = edtClear
      Min = 1
      Position = 1
      TabOrder = 4
    end
  end
  object GroupBox3: TGroupBox
    Left = 8
    Top = 143
    Width = 185
    Height = 74
    Caption = #51452#47928#44032#44201
    TabOrder = 3
    object Label5: TLabel
      Left = 155
      Top = 48
      Width = 18
      Height = 13
      Caption = 'Tick'
    end
    object rdDeposit: TRadioButton
      Left = 16
      Top = 24
      Width = 73
      Height = 17
      Caption = #49345#45824#54840#44032' '
      Checked = True
      TabOrder = 0
      TabStop = True
      OnClick = rdSameClick
    end
    object rdSame: TRadioButton
      Tag = 1
      Left = 16
      Top = 47
      Width = 83
      Height = 17
      Caption = #44057#51008#54840#44032'  - '
      TabOrder = 1
      OnClick = rdSameClick
    end
    object udTick: TUpDown
      Left = 133
      Top = 43
      Width = 15
      Height = 21
      Associate = edtTick
      Position = 1
      TabOrder = 2
    end
    object edtTick: TEdit
      Left = 98
      Top = 43
      Width = 35
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 3
      Text = '1'
      OnChange = edtExecConDepositChange
    end
  end
  object GroupBox4: TGroupBox
    Left = 8
    Top = 223
    Width = 376
    Height = 114
    Caption = #51452#47928#51221#51221
    TabOrder = 4
    object Label1: TLabel
      Left = 9
      Top = 40
      Width = 362
      Height = 13
      Caption = '* '#47588#49688#54252#51648#49496' '#51080#51012#44221#50864' '#52397#49328#51452#47928#44032#44201#51060'('#47588#46020')  '#47588#49688#54840#44032#48372#45796' '#53364' '#44221#50864' '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 52
      Top = 61
      Width = 81
      Height = 13
      Caption = #54924' '#51221#51221#54980'  '#52397#49328
    end
    object Label3: TLabel
      Left = 136
      Top = 84
      Width = 179
      Height = 13
      Caption = #52488#54980' '#51088#46041#51221#51221#49884#51089'   ( 1000 = 1sec)'
    end
    object Label4: TLabel
      Left = 12
      Top = 86
      Width = 79
      Height = 13
      Caption = #49892#54665#45824#44592#49884#44036' :'
    end
    object edtAutoCnt: TEdit
      Left = 12
      Top = 56
      Width = 33
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 0
      OnChange = edtExecConDepositChange
    end
    object edtAutoSec: TEdit
      Left = 97
      Top = 80
      Width = 33
      Height = 21
      ImeName = 'Microsoft IME 2003'
      TabOrder = 1
      Text = '1000'
      OnChange = edtExecConDepositChange
    end
    object cbAuto: TCheckBox
      Left = 10
      Top = 17
      Width = 97
      Height = 17
      Caption = #51088#46041#51452#47928#51221#51221
      TabOrder = 2
      OnClick = cbAutoClick
    end
  end
  object sgLog: TStringGrid
    Left = 8
    Top = 366
    Width = 376
    Height = 147
    ColCount = 2
    Ctl3D = False
    DefaultColWidth = 52
    DefaultRowHeight = 17
    RowCount = 8
    ParentCtl3D = False
    TabOrder = 5
    OnDrawCell = sgLogDrawCell
    RowHeights = (
      17
      17
      17
      17
      17
      17
      17
      17)
  end
  object plSide: TPanel
    Left = 8
    Top = 344
    Width = 377
    Height = 15
    ParentColor = True
    TabOrder = 6
  end
end
