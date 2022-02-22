object FraBull: TFraBull
  Left = 0
  Top = 0
  Width = 367
  Height = 210
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 210
    Align = alClient
    TabOrder = 0
    object plLeft: TPanel
      Left = 1
      Top = 1
      Width = 365
      Height = 130
      Align = alTop
      BiDiMode = bdLeftToRight
      Ctl3D = True
      ParentBiDiMode = False
      ParentBackground = False
      ParentCtl3D = False
      TabOrder = 0
      object Label7: TLabel
        Left = 38
        Top = 8
        Width = 13
        Height = 13
        Caption = 'E :'
      end
      object Label10: TLabel
        Left = 192
        Top = 9
        Width = 16
        Height = 13
        Caption = 'sec'
      end
      object Label26: TLabel
        Left = 162
        Top = 31
        Width = 59
        Height = 13
        Caption = 'New Order :'
      end
      object Label2: TLabel
        Left = 268
        Top = 31
        Width = 67
        Height = 13
        Caption = 'Max Position :'
      end
      object Label3: TLabel
        Left = 162
        Top = 54
        Width = 78
        Height = 13
        Caption = 'Max QuoteQty :'
      end
      object ButtonAuto: TSpeedButton
        Left = 3
        Top = 4
        Width = 34
        Height = 21
        AllowAllUp = True
        GroupIndex = 1
        Caption = 'Stop'
        OnClick = ButtonAutoClick
      end
      object Bevel2: TBevel
        Left = 9
        Top = 113
        Width = 409
        Height = 3
        Shape = bsTopLine
      end
      object lbTag: TLabel
        Left = 298
        Top = 54
        Width = 61
        Height = 16
        Alignment = taRightJustify
        AutoSize = False
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object ckE1: TCheckBox
        Left = 5
        Top = 29
        Width = 32
        Height = 17
        Caption = 'E1'
        TabOrder = 0
        OnClick = OnChkboxClick
      end
      object ckLE_Enabled: TCheckBox
        Left = 55
        Top = 6
        Width = 26
        Height = 17
        Caption = 'L'
        TabOrder = 1
        OnClick = OnChkboxClick
      end
      object ckSE_Enabled: TCheckBox
        Left = 82
        Top = 6
        Width = 26
        Height = 17
        Caption = 'S'
        TabOrder = 2
        OnClick = OnChkboxClick
      end
      object ckTimeCancel: TCheckBox
        Left = 109
        Top = 5
        Width = 54
        Height = 20
        Caption = 'TimeCx'
        TabOrder = 3
        OnClick = OnChkboxClick
      end
      object edCancelTime: TEdit
        Left = 165
        Top = 4
        Width = 25
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 4
        Text = '1.0'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P1: TEdit
        Left = 35
        Top = 27
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 5
        Text = '1.1'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P2: TEdit
        Left = 67
        Top = 27
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 6
        Text = '1.0'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object ckE2: TCheckBox
        Left = 102
        Top = 54
        Width = 32
        Height = 17
        Caption = 'E2'
        TabOrder = 7
        OnClick = OnChkboxClick
      end
      object edE2P1: TEdit
        Left = 134
        Top = 52
        Width = 23
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 8
        Text = '50'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edNewOrderQty: TEdit
        Left = 223
        Top = 27
        Width = 41
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 9
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edMaxPosition: TEdit
        Left = 336
        Top = 26
        Width = 24
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 10
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edMaxQuoteQty: TEdit
        Left = 242
        Top = 50
        Width = 38
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 11
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P3: TEdit
        Left = 96
        Top = 27
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 12
        Text = '2.0'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P4: TEdit
        Left = 128
        Top = 27
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 13
        Text = '0.7'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P5: TEdit
        Left = 35
        Top = 51
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 14
        Text = '0.3'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edE1P6: TEdit
        Left = 67
        Top = 51
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 15
        Text = '0.2'
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object Button1: TButton
        Left = 213
        Top = 5
        Width = 39
        Height = 20
        Caption = ' Clear'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -9
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 16
        OnClick = Button1Click
      end
      object Panel2: TPanel
        Left = 1
        Top = 74
        Width = 363
        Height = 55
        Align = alBottom
        TabOrder = 17
        object btnExpand: TSpeedButton
          Left = 1
          Top = 39
          Width = 361
          Height = 15
          Align = alBottom
          AllowAllUp = True
          GroupIndex = 2
          Caption = #9660
          OnClick = btnExpandClick
          ExplicitTop = 24
          ExplicitWidth = 414
        end
        object TabConfig: TTabControl
          Left = 1
          Top = 1
          Width = 361
          Height = 19
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
          Top = 20
          Width = 361
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
      object UseMoth: TCheckBox
        Left = 314
        Top = 7
        Width = 48
        Height = 17
        Caption = 'Moth'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -12
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 18
        OnClick = UseMothClick
      end
      object cbRun: TCheckBox
        Left = 273
        Top = 7
        Width = 34
        Height = 17
        Caption = 'Run'
        TabOrder = 19
        Visible = False
      end
      object cbActive: TCheckBox
        Left = 253
        Top = 7
        Width = 59
        Height = 17
        Hint = #47560#51648#47561#51004#47196' '#49440#53469#54620' '#51452#47928#52285#51012' '#54876#49457#54868
        Caption = 'Activate'
        TabOrder = 20
      end
    end
    object plRight: TPanel
      Left = 1
      Top = 131
      Width = 365
      Height = 78
      Align = alClient
      TabOrder = 1
      object Label1: TLabel
        Left = 13
        Top = 150
        Width = 13
        Height = 13
        Caption = 'X :'
        Visible = False
      end
      object edX1P1: TEdit
        Left = 83
        Top = 147
        Width = 29
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 0
        Text = '0.5'
        Visible = False
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edX1P2: TEdit
        Left = 119
        Top = 147
        Width = 33
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 1
        Text = '0.7'
        Visible = False
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object GridInfo: TStringGrid
        Left = 1
        Top = 1
        Width = 363
        Height = 76
        Align = alClient
        ColCount = 3
        DefaultRowHeight = 17
        FixedCols = 0
        RowCount = 4
        FixedRows = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssNone
        TabOrder = 2
      end
      object ckX1: TCheckBox
        Left = 43
        Top = 146
        Width = 41
        Height = 20
        Caption = 'X1 :'
        TabOrder = 3
        Visible = False
        OnClick = OnChkboxClick
      end
      object ckX3: TCheckBox
        Left = 268
        Top = 148
        Width = 49
        Height = 20
        Caption = 'X3 : '
        TabOrder = 4
        Visible = False
        OnClick = OnChkboxClick
      end
      object ckX2: TCheckBox
        Left = 157
        Top = 148
        Width = 41
        Height = 20
        Caption = 'X2 :'
        TabOrder = 5
        Visible = False
        OnClick = OnChkboxClick
      end
      object edX2P1: TEdit
        Left = 191
        Top = 147
        Width = 33
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 6
        Text = '2.5'
        Visible = False
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
      object edX2P2: TEdit
        Left = 228
        Top = 147
        Width = 33
        Height = 21
        ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
        TabOrder = 7
        Text = '1.0'
        Visible = False
        OnChange = OnEditboxChange
        OnExit = OnChkboxClick
      end
    end
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 100
    OnTimer = Timer2Timer
    Left = 332
    Top = 100
  end
end
