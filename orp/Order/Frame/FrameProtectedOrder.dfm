object FraProtectedOrder: TFraProtectedOrder
  Left = 0
  Top = 0
  Width = 367
  Height = 268
  TabOrder = 0
  object plLeft: TPanel
    Left = 0
    Top = 0
    Width = 367
    Height = 111
    Align = alTop
    ParentBackground = False
    TabOrder = 0
    object plSide: TPanel
      Left = 1
      Top = 1
      Width = 365
      Height = 34
      Align = alTop
      ParentBackground = False
      TabOrder = 0
      object ButtonAuto: TSpeedButton
        Left = 1
        Top = 1
        Width = 43
        Height = 28
        AllowAllUp = True
        GroupIndex = 1
        Caption = 'Stop'
        OnClick = ButtonAutoClick
      end
      object GroupBox1: TGroupBox
        Left = 43
        Top = -3
        Width = 320
        Height = 32
        Hint = #49892#54665#51312#44148
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBackground = False
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object btnShow: TSpeedButton
          Left = 284
          Top = 9
          Width = 31
          Height = 18
          AllowAllUp = True
          GroupIndex = 2
          Caption = #9650
          OnClick = btnShowClick
        end
        object rdExecConDeposit: TRadioButton
          Left = 2
          Top = 11
          Width = 67
          Height = 17
          Caption = #49345#45824#54840#44032' '
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rdExecConDepositClick
        end
        object rdExecConSame: TRadioButton
          Tag = 1
          Left = 98
          Top = 10
          Width = 67
          Height = 17
          Caption = #44057#51008#54840#44032'   <'
          TabOrder = 1
          OnClick = rdExecConDepositClick
        end
        object rdExecConCur: TRadioButton
          Tag = 2
          Left = 193
          Top = 10
          Width = 57
          Height = 17
          Caption = #54788#51116#44032'       <'
          TabOrder = 2
          OnClick = rdExecConDepositClick
        end
        object edtExecConDeposit: TEdit
          Left = 68
          Top = 9
          Width = 28
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 3
          OnChange = edtExecConDepositChange
          OnKeyPress = edtExecConDepositKeyPress
        end
        object edtExecConSame: TEdit
          Left = 164
          Top = 9
          Width = 27
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 4
          OnChange = edtExecConDepositChange
        end
        object edtExecConCur: TEdit
          Left = 250
          Top = 9
          Width = 32
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 5
          OnChange = edtExecConDepositChange
        end
      end
    end
    object plCenter: TPanel
      Left = 1
      Top = 35
      Width = 365
      Height = 75
      Align = alClient
      ParentBackground = False
      TabOrder = 1
      object btnExpand: TSpeedButton
        Tag = 3
        Left = 1
        Top = 58
        Width = 363
        Height = 16
        Align = alBottom
        AllowAllUp = True
        GroupIndex = 2
        Caption = #9660
        OnClick = btnExpandClick
        ExplicitTop = 56
      end
      object GroupBox2: TGroupBox
        Left = 4
        Top = -3
        Width = 359
        Height = 32
        Hint = #51452#47928#49688#47049
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object rdClear: TRadioButton
          Left = 5
          Top = 12
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
          Left = 157
          Top = 11
          Width = 149
          Height = 17
          Caption = 'Min( '#44256#51221#49688#47049', '#52397#49328#44032#45733')'
          TabOrder = 1
          OnClick = rdFixClearClick
        end
        object edtClear: TEdit
          Left = 107
          Top = 8
          Width = 28
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 2
          Text = '1'
          OnChange = edtExecConDepositChange
        end
        object edtFixClear: TEdit
          Left = 310
          Top = 8
          Width = 37
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 3
          OnChange = edtExecConDepositChange
        end
        object udClear: TUpDown
          Left = 135
          Top = 8
          Width = 15
          Height = 21
          Associate = edtClear
          Min = 1
          Position = 1
          TabOrder = 4
        end
      end
      object GroupBox3: TGroupBox
        Left = 4
        Top = 28
        Width = 359
        Height = 31
        Hint = #51452#47928#44032#44201
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        object Label5: TLabel
          Left = 200
          Top = 12
          Width = 18
          Height = 13
          Caption = 'Tick'
        end
        object lbTag: TLabel
          Left = 277
          Top = 10
          Width = 76
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
        object rdDeposit: TRadioButton
          Left = 5
          Top = 10
          Width = 69
          Height = 17
          Caption = #49345#45824#54840#44032' '
          Checked = True
          TabOrder = 0
          TabStop = True
          OnClick = rdDepositClick
        end
        object rdSame: TRadioButton
          Tag = 1
          Left = 80
          Top = 10
          Width = 79
          Height = 17
          Caption = #44057#51008#54840#44032'  - '
          TabOrder = 1
          OnClick = rdDepositClick
        end
        object udTick: TUpDown
          Left = 179
          Top = 7
          Width = 15
          Height = 21
          Associate = edtTick
          Position = 1
          TabOrder = 2
        end
        object edtTick: TEdit
          Left = 158
          Top = 7
          Width = 21
          Height = 21
          ImeName = 'Microsoft IME 2003'
          TabOrder = 3
          Text = '1'
          OnChange = edtExecConDepositChange
        end
      end
    end
  end
  object plRight: TPanel
    Left = 0
    Top = 111
    Width = 367
    Height = 157
    Align = alClient
    TabOrder = 1
    object GroupBox4: TGroupBox
      Left = 4
      Top = -4
      Width = 360
      Height = 66
      Hint = #51452#47928#51221#51221
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      object Label1: TLabel
        Left = 4
        Top = 29
        Width = 353
        Height = 13
        Caption = #47588#49688#54252#51648#49496' '#51080#51012#44221#50864' '#52397#49328#51452#47928#44032#44201#51060'('#47588#46020')  '#47588#49688#54840#44032#48372#45796' '#53364' '#44221#50864' '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object Label2: TLabel
        Left = 39
        Top = 49
        Width = 81
        Height = 13
        Caption = #54924' '#51221#51221#54980'  '#52397#49328
      end
      object Label3: TLabel
        Left = 195
        Top = 11
        Width = 161
        Height = 13
        Caption = #52488#54980' '#51088#46041#51221#51221#49884#51089'(1000=1sec)'
      end
      object Label4: TLabel
        Left = 109
        Top = 11
        Width = 55
        Height = 13
        Caption = #45824#44592#49884#44036' :'
      end
      object edtAutoCnt: TEdit
        Left = 7
        Top = 44
        Width = 31
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 0
        OnChange = edtExecConDepositChange
      end
      object edtAutoSec: TEdit
        Left = 167
        Top = 7
        Width = 30
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '1000'
        OnChange = edtExecConDepositChange
      end
      object cbAuto: TCheckBox
        Left = 6
        Top = 9
        Width = 91
        Height = 17
        Caption = #51088#46041#51452#47928#51221#51221
        TabOrder = 2
        OnClick = cbAutoClick
      end
    end
    object sgLog: TStringGrid
      Left = 4
      Top = 63
      Width = 357
      Height = 92
      ColCount = 2
      Ctl3D = False
      DefaultColWidth = 52
      DefaultRowHeight = 17
      RowCount = 8
      ParentCtl3D = False
      TabOrder = 1
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
  end
end
