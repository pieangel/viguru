object BullSystemForm: TBullSystemForm
  Left = 97
  Top = 176
  Caption = 'Bull Set'
  ClientHeight = 308
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 382
    Height = 33
    Align = alTop
    TabOrder = 0
    object ButtonAuto: TSpeedButton
      Left = 32
      Top = 5
      Width = 41
      Height = 21
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Stop'
      OnClick = ButtonAutoClick
    end
    object ButtonSymbol: TSpeedButton
      Left = 335
      Top = 6
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = ButtonSymbolClick
    end
    object ButtonFix: TSpeedButton
      Left = 2
      Top = 5
      Width = 23
      Height = 21
      AllowAllUp = True
      BiDiMode = bdLeftToRight
      GroupIndex = 1
      Flat = True
      Glyph.Data = {
        FE020000424DFE02000000000000760000002800000048000000120000000100
        0400000000008802000000000000000000001000000000000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888880088888888888807700077888888888888888
        0088888888888807700077888888888888800088880088888800000007888888
        8888888800088880088888800000007888888888888070000000888888077700
        0078888888888888070000000888888077700007888888888880700000708888
        8077777000088888888888880700000708888807777700008888800000008707
        7080888880787000000888888800000008707708088888078700000088888777
        777088788780888880F807887700888888777777088788780888880F80788770
        0888888888808F7FF7F0888880FF0F88870088888888888808F7FF7F0888880F
        F0F888700888888888808F0000F08888880F0F88887088888888888808F0000F
        08888880F0F88887088888888880F0888800888888000FF88870888888888888
        0F0888800888888000FF8887088888888880088888888888888800FFFF088888
        888888880088888888888888800FFFF088888888888888888888888888888800
        0088888888888888888888888888888888800008888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888888888888888888888888888888888888888888888888888888888888888
        8888}
      NumGlyphs = 4
      ParentBiDiMode = False
    end
    object ComboAccount: TComboBox
      Left = 80
      Top = 6
      Width = 137
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object ComboSymbol: TComboBox
      Left = 224
      Top = 6
      Width = 105
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboSymbolChange
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 270
    Width = 382
    Height = 38
    Align = alBottom
    TabOrder = 1
    object TabConfig: TTabControl
      Left = 1
      Top = 1
      Width = 380
      Height = 17
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      Style = tsButtons
      TabOrder = 0
      Tabs.Strings = (
        'C1'
        'C2'
        'C3'
        'C4'
        'C5'
        'C6'
        'C7'
        'C8')
      TabIndex = 0
      OnChange = TabConfigChange
    end
    object StatusTrade: TStatusBar
      Left = 1
      Top = 18
      Width = 380
      Height = 19
      Panels = <
        item
          Width = 150
        end
        item
          Width = 200
        end>
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 33
    Width = 382
    Height = 237
    Align = alClient
    TabOrder = 2
    object Bevel2: TBevel
      Left = 9
      Top = 113
      Width = 409
      Height = 3
      Shape = bsTopLine
    end
    object Label7: TLabel
      Left = 2
      Top = 2
      Width = 13
      Height = 13
      Caption = 'E :'
    end
    object Label10: TLabel
      Left = 184
      Top = 6
      Width = 17
      Height = 13
      Caption = 'sec'
    end
    object Label1: TLabel
      Left = 3
      Top = 122
      Width = 13
      Height = 13
      Caption = 'X :'
    end
    object Label26: TLabel
      Left = 203
      Top = 40
      Width = 57
      Height = 13
      Caption = 'New Order :'
    end
    object Label2: TLabel
      Left = 203
      Top = 66
      Width = 66
      Height = 13
      Caption = 'Max Position :'
    end
    object Label3: TLabel
      Left = 203
      Top = 90
      Width = 74
      Height = 13
      Caption = 'Max QuoteQty :'
    end
    object Bevel1: TBevel
      Left = 38
      Top = 27
      Width = 362
      Height = 3
      Shape = bsTopLine
    end
    object ckE1: TCheckBox
      Left = 18
      Top = 38
      Width = 41
      Height = 17
      Caption = 'E1'
      TabOrder = 0
      OnClick = OnChkboxClick
    end
    object ckLE_Enabled: TCheckBox
      Left = 19
      Top = 4
      Width = 30
      Height = 17
      Caption = 'L'
      TabOrder = 1
      OnClick = OnChkboxClick
    end
    object ckSE_Enabled: TCheckBox
      Left = 55
      Top = 4
      Width = 30
      Height = 17
      Caption = 'S'
      TabOrder = 2
      OnClick = OnChkboxClick
    end
    object ckTimeCancel: TCheckBox
      Left = 91
      Top = 3
      Width = 62
      Height = 20
      Caption = 'Time Cx'
      TabOrder = 3
      OnClick = OnChkboxClick
    end
    object edCancelTime: TEdit
      Left = 150
      Top = 1
      Width = 33
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 4
      Text = '1.0'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P1: TEdit
      Left = 60
      Top = 36
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 5
      Text = '1.1'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P2: TEdit
      Left = 92
      Top = 36
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 6
      Text = '1.0'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object ckE2: TCheckBox
      Left = 18
      Top = 88
      Width = 41
      Height = 17
      Caption = 'E2'
      TabOrder = 7
      OnClick = OnChkboxClick
    end
    object edE2P1: TEdit
      Left = 68
      Top = 86
      Width = 33
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 8
      Text = '50'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object GridInfo: TStringGrid
      Left = 148
      Top = 122
      Width = 229
      Height = 105
      ColCount = 3
      FixedCols = 0
      RowCount = 4
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 9
      OnClick = GridInfoClick
    end
    object edNewOrderQty: TEdit
      Left = 280
      Top = 36
      Width = 65
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 10
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edMaxPosition: TEdit
      Left = 280
      Top = 61
      Width = 65
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 11
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edMaxQuoteQty: TEdit
      Left = 280
      Top = 86
      Width = 65
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 12
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P3: TEdit
      Left = 132
      Top = 36
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 13
      Text = '2.0'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P4: TEdit
      Left = 164
      Top = 36
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 14
      Text = '0.7'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P5: TEdit
      Left = 60
      Top = 60
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 15
      Text = '0.3'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edE1P6: TEdit
      Left = 92
      Top = 60
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 16
      Text = '0.2'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edX1P1: TEdit
      Left = 59
      Top = 124
      Width = 29
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 17
      Text = '0.5'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edX1P2: TEdit
      Left = 95
      Top = 124
      Width = 33
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 18
      Text = '0.7'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edX2P1: TEdit
      Left = 58
      Top = 148
      Width = 33
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 19
      Text = '2.5'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object edX2P2: TEdit
      Left = 95
      Top = 148
      Width = 33
      Height = 21
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      TabOrder = 20
      Text = '1.0'
      OnChange = OnEditboxChange
      OnExit = OnChkboxClick
    end
    object cbRun: TCheckBox
      Left = 318
      Top = 4
      Width = 97
      Height = 17
      Caption = 'Run'
      TabOrder = 21
      Visible = False
      OnClick = cbRunClick
    end
    object Button1: TButton
      Left = 243
      Top = 2
      Width = 49
      Height = 20
      Caption = ' Clear'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -9
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      TabOrder = 22
      OnClick = Button1Click
    end
    object cbActive: TCheckBox
      Left = 316
      Top = 4
      Width = 62
      Height = 17
      Hint = #47560#51648#47561#51004#47196' '#49440#53469#54620' '#51452#47928#52285#51012' '#54876#49457#54868
      Caption = ' Activate'
      TabOrder = 23
    end
  end
  object ckX1: TCheckBox
    Left = 19
    Top = 158
    Width = 41
    Height = 20
    Caption = 'X1 :'
    TabOrder = 3
    OnClick = OnChkboxClick
  end
  object ckX2: TCheckBox
    Left = 19
    Top = 182
    Width = 41
    Height = 20
    Caption = 'X2 :'
    TabOrder = 4
    OnClick = OnChkboxClick
  end
  object ckX3: TCheckBox
    Left = 19
    Top = 206
    Width = 49
    Height = 20
    Caption = 'X3 : '
    TabOrder = 5
    OnClick = OnChkboxClick
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'txt'
    Left = 669
    Top = 54
  end
  object Timer2: TTimer
    Interval = 100
    OnTimer = Timer2Timer
    Left = 336
    Top = 72
  end
end
