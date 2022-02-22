object SymbolSearch: TSymbolSearch
  Left = 132
  Top = 279
  Caption = 'Symbol Search'
  ClientHeight = 560
  ClientWidth = 781
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object plFillter: TPanel
    Left = 633
    Top = 0
    Width = 148
    Height = 560
    Align = alRight
    BevelOuter = bvLowered
    TabOrder = 0
    object Label2: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 10
      Width = 55
      Height = 13
      AutoSize = False
      Caption = #44592#52488#51088#49328
      Layout = tlCenter
    end
    object Label3: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 180
      Width = 35
      Height = 13
      AutoSize = False
      Caption = 'LP'
      Layout = tlCenter
    end
    object GroupBox1: TGroupBox
      AlignWithMargins = True
      Left = 5
      Top = 333
      Width = 141
      Height = 123
      TabOrder = 0
      object Label12: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 18
        Width = 36
        Height = 13
        AutoSize = False
        Caption = 'LP'#48708#51473
        Layout = tlCenter
      end
      object Label11: TLabel
        Left = 108
        Top = 23
        Width = 24
        Height = 13
        Caption = #51060#54616
      end
      object Label6: TLabel
        AlignWithMargins = True
        Left = 4
        Top = 75
        Width = 36
        Height = 13
        AutoSize = False
        Caption = #51092#51316#51068
        Layout = tlCenter
      end
      object Label4: TLabel
        Left = 2
        Top = 47
        Width = 36
        Height = 13
        Caption = #44144#47000#47049
      end
      object Label5: TLabel
        Left = 106
        Top = 47
        Width = 24
        Height = 13
        Caption = #51060#49345
      end
      object Label1: TLabel
        Left = 59
        Top = 98
        Width = 8
        Height = 13
        Caption = '~'
      end
      object edtWeight: TEdit
        Left = 43
        Top = 15
        Width = 46
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        Text = '0'
        OnKeyPress = edtVolumeKeyPress
      end
      object udWeight: TUpDown
        Left = 89
        Top = 15
        Width = 15
        Height = 21
        Associate = edtWeight
        TabOrder = 1
      end
      object udRemainDaysTo: TUpDown
        Left = 39
        Top = 94
        Width = 15
        Height = 21
        Associate = edtRemainDaysTo
        Max = 32678
        TabOrder = 2
      end
      object edtRemainDaysTo: TEdit
        Left = 3
        Top = 94
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 3
        Text = '0'
        OnKeyPress = edtVolumeKeyPress
      end
      object edtVolume: TEdit
        Left = 43
        Top = 42
        Width = 46
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = '0'
        OnKeyPress = edtVolumeKeyPress
      end
      object udVolume: TUpDown
        Left = 89
        Top = 42
        Width = 15
        Height = 21
        Associate = edtVolume
        Max = 32678
        TabOrder = 5
      end
      object edtRemainDaysFrom: TEdit
        Left = 73
        Top = 95
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 6
        Text = '0'
        OnKeyPress = edtVolumeKeyPress
      end
      object udRemainDaysFrom: TUpDown
        Left = 109
        Top = 95
        Width = 15
        Height = 21
        Associate = edtRemainDaysFrom
        Max = 32678
        TabOrder = 7
      end
    end
    object GroupBox2: TGroupBox
      Left = 5
      Top = 455
      Width = 141
      Height = 103
      TabOrder = 1
      object Label7: TLabel
        Left = 3
        Top = 12
        Width = 36
        Height = 13
        Caption = #54001#48708#50984
      end
      object Label8: TLabel
        Left = 59
        Top = 36
        Width = 8
        Height = 13
        Caption = '~'
      end
      object Label9: TLabel
        Left = 3
        Top = 57
        Width = 48
        Height = 13
        Caption = #49828#54532#47112#46300
      end
      object Label10: TLabel
        Left = 57
        Top = 82
        Width = 24
        Height = 13
        Caption = #51060#54616
      end
      object edtTickRatioTo: TEdit
        Left = 3
        Top = 30
        Width = 36
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        Text = '2.000'
      end
      object udTickRatio: TUpDown
        Left = 38
        Top = 30
        Width = 16
        Height = 21
        Min = -20
        Max = 20
        TabOrder = 1
        OnClick = udTickRatioClick
      end
      object edtTickRatioFrom: TEdit
        Left = 73
        Top = 30
        Width = 40
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 2
        Text = '1.000'
      end
      object UpDown1: TUpDown
        Left = 113
        Top = 30
        Width = 16
        Height = 21
        Min = -20
        Max = 20
        TabOrder = 3
        OnClick = UpDown1Click
      end
      object edtSpread: TEdit
        Left = 3
        Top = 76
        Width = 35
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = '2'
      end
      object udSpread: TUpDown
        Left = 38
        Top = 76
        Width = 15
        Height = 21
        Associate = edtSpread
        Max = 10
        Position = 2
        TabOrder = 5
      end
    end
    object listUnderlying: TListBox
      Left = 6
      Top = 29
      Width = 140
      Height = 135
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      TabOrder = 2
    end
    object listLP: TListBox
      Left = 5
      Top = 199
      Width = 141
      Height = 132
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      TabOrder = 3
    end
    object Button3: TButton
      Left = 72
      Top = 8
      Width = 49
      Height = 17
      Caption = #49444#51221
      TabOrder = 4
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 72
      Top = 176
      Width = 49
      Height = 17
      Caption = #49444#51221
      TabOrder = 5
      OnClick = Button4Click
    end
  end
  object plInfo: TPanel
    Left = 0
    Top = 0
    Width = 633
    Height = 560
    Align = alClient
    BevelOuter = bvLowered
    TabOrder = 1
    object plSelected: TPanel
      Left = 1
      Top = 523
      Width = 631
      Height = 36
      Align = alBottom
      BevelOuter = bvLowered
      TabOrder = 0
      object SpeedButton2: TSpeedButton
        Tag = 300
        Left = 502
        Top = 6
        Width = 108
        Height = 22
        Caption = #51312'  '#54924
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -11
        Font.Name = 'Arial'
        Font.Style = [fsBold]
        ParentFont = False
        OnClick = SpeedButton2Click
      end
      object Button2: TButton
        Left = 4
        Top = 6
        Width = 75
        Height = 25
        Caption = #45803' '#44592
        ModalResult = 2
        TabOrder = 0
        OnClick = Button2Click
      end
    end
    object sgInfo: TStringGrid
      Left = 1
      Top = 27
      Width = 631
      Height = 496
      Align = alClient
      BevelInner = bvNone
      BevelOuter = bvNone
      ColCount = 6
      Ctl3D = False
      DefaultRowHeight = 15
      FixedCols = 0
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 1
      OnDblClick = sgInfoDblClick
      OnDrawCell = sgInfoDrawCell
      OnMouseDown = sgInfoMouseDown
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 631
      Height = 26
      Align = alTop
      BevelOuter = bvLowered
      TabOrder = 2
      object SpeedButtonPrefs: TSpeedButton
        Left = 161
        Top = -1
        Width = 22
        Height = 23
        AllowAllUp = True
        Flat = True
        Glyph.Data = {
          36050000424D3605000000000000360400002800000010000000100000000100
          0800000000000001000000000000000000000001000000010000000000000101
          0100020202000303030004040400050505000606060007070700080808000909
          09000A0A0A000B0B0B000C0C0C000D0D0D000E0E0E000F0F0F00101010001111
          1100121212001313130014141400151515001616160017171700181818001919
          19001A1A1A001B1B1B001C1C1C00241E1B002C201A00342219003B2418004426
          1B0050291D005A2B1F00622D21006A2F210071302100763120007C311E008232
          1A00883215008C3211008F330E0091330B009333080095330500963303009733
          0100983301009833000098330000983300009833000098330100983301009833
          0100973301009733020097330200963303009533040094330600923308009033
          0A008E340C008B340F0088351200833714007F381500793A1B00723D22006D3F
          270067412E00604435005D463A005A483F00564A4400534D4A00505050005151
          5100565353005B5555005F585700675B5900705E5C0077615E007D6360008465
          6200886763008D68640090696500926A6600956B6700966C6700986C6700996D
          68009B6F6A009D716C009F726D00A0736F00A1747000A2757100A3767200A477
          7300A5787300A77A7500AA7D7800AF827B00B68A7F00BF948400C9A08A00D3AB
          9100DBB59500E3BF9A00E9C69E00EBC9A000ECCBA100EDCCA100EFCFA400F0D1
          A600EECDA200ECC79C00E9C29A00E6BD9700E2B69200DFB08C00DBA98400D8A6
          8500D2A08400CC9A8100C5927E00BF8C7B00BA887900B4837800B2837800B182
          7800AF817800AD807800AA817D00A6838500A2858F009E8797009C8A9E009A8C
          A400988DAA00978FAF009790B3009692B7009693BA009694BC009696BF009698
          C4009699C600969AC600969AC300969BC400979CC400989EC40098A0C40099A2
          C3009BA2C1009CA3BE009EA4BB009FA4B800A1A5B500A4A6B100A6A7AD00A3A5
          AE009FA3B4009BA1B900969FC200929DC9008F9CCF008C9BD4008C95DA008D90
          DF008889E4008082EA00767CEF006D76F2006673F5006070F6005C6DF800576C
          F9005468F9004F64F9004A5EF9004357F900394DF9002C42F900203BFA001938
          FA001334FA000E34FA000B34FA000934FA000835FA000735FA000936FB000C36
          FB000F37FB001137FB001C35F8002832FB00352FFB00442BFB006C22FC008E1A
          FD00B111FD00D508FE00E705FE00F103FE00F701FE00FB00FE00FD00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00FE00
          FE00FD0BFE00FA1BFD00F72EFC00F445FA00EE66F900E88AF400E4A9F000E1C6
          EE00E4D7EA00E6E0EC00E7E4F100ECEAF400F2F1F700F8F5F500FAF6F300FBF6
          F100FCF7F100FCF9F500FDFBF800FEFCFA00FEFDFC00FEFDFB00E0E0E0E0E0E0
          E0E0E0E0E0E0E0E0E0E0E06E6A6A6A6A6A6A6A6A6A6A6A60E0E0E06EF9F37979
          7979787777777960E0E0E087F93535353535353535777960E0E0E087FA35FEFE
          FEB1F1FE357A7960E0E0E06FFD35FEFEB3C7B9FE35787960E0E0E06FFE35F3BB
          C7BBC8F335797960E0E0E083FE35B9CBF1F6C1B93B797960E0E0E083FE35F5F3
          FEFEA1C755797960E0E0E080FE35FEFEFEFEFEB9C7797960E0E0E080FE353535
          3535352CCCC77360E0E0E07FFEFEFEFEFEFBF9F387C7C7C7E0E0E07FFEFEFEFE
          FEFEFFF2877F80C7E0E0E07DFEFEFEFEFEFEFEF2877B84E0E0E0E07DFAFAF8F8
          F8F8F8F28783E0E0E0E0E07D818181818181818187E0E0E0E0E0}
      end
      object ckAuto: TCheckBox
        Left = 473
        Top = 6
        Width = 83
        Height = 17
        Caption = #51088#46041#51116#51312#54924
        TabOrder = 0
        OnClick = ckAutoClick
      end
      object cbSec: TComboBox
        Left = 555
        Top = 4
        Width = 50
        Height = 21
        Style = csDropDownList
        Enabled = False
        ImeName = 'Microsoft IME 2003'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 1
        Text = '10'#52488
        OnChange = cbSecChange
        Items.Strings = (
          '10'#52488
          '20'#52488
          '30'#52488
          '40'#52488
          '50'#52488
          '60'#52488)
      end
      object cbSymbol: TComboBox
        Left = 2
        Top = 1
        Width = 145
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft IME 2003'
        ItemHeight = 13
        TabOrder = 2
        OnChange = cbSymbolChange
      end
    end
  end
  object refreshTimer: TTimer
    Enabled = False
    Interval = 10000
    OnTimer = refreshTimerTimer
    Left = 104
    Top = 336
  end
end
