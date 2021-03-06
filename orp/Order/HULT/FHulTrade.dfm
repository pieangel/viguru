object FrmHulTrade: TFrmHulTrade
  Left = 0
  Top = 0
  Caption = 'HULT'
  ClientHeight = 306
  ClientWidth = 184
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
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
    Width = 184
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      184
      27)
    object cbStart: TCheckBox
      Left = 133
      Top = 5
      Width = 44
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object Button6: TButton
      Left = 109
      Top = 4
      Width = 22
      Height = 21
      Caption = '..'
      TabOrder = 1
      OnClick = Button6Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 2
      Width = 106
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 2
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 184
    Height = 260
    Align = alClient
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentBackground = False
    TabOrder = 1
    object Label2: TLabel
      Left = 9
      Top = 6
      Width = 22
      Height = 13
      Caption = #51333#47785
    end
    object edtSymbol: TEdit
      Left = 39
      Top = 2
      Width = 82
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 123
      Top = 2
      Width = 25
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object gbUseHul: TGroupBox
      Left = 8
      Top = 196
      Width = 171
      Height = 58
      Caption = #49552#51208#51312#44148'('#45800#50948' : '#47564')'
      TabOrder = 2
      object Label6: TLabel
        Left = 11
        Top = 20
        Width = 44
        Height = 13
        Caption = 'Risk '#44552#50529
      end
      object cbAllcnlNStop: TCheckBox
        Tag = 1
        Left = 6
        Top = 38
        Width = 157
        Height = 17
        Caption = #49552#51208#54980' '#47784#46160' '#52712#49548' && '#49828#53457
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbAutoLiquidClick
      end
      object edtRiskAmt: TEdit
        Tag = 5
        Left = 63
        Top = 16
        Width = 47
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '10,000'
        OnKeyPress = edtGapKeyPress
      end
      object UpDown5: TUpDown
        Left = 110
        Top = 16
        Width = 15
        Height = 21
        Associate = edtRiskAmt
        Min = 1
        Max = 32700
        Increment = 10
        Position = 10000
        TabOrder = 2
      end
      object btnColor: TButton
        Left = 131
        Top = 18
        Width = 30
        Height = 20
        Caption = 'C'
        TabOrder = 3
        OnClick = btnColorClick
      end
    end
    object gbRiquid: TGroupBox
      Left = 9
      Top = 135
      Width = 170
      Height = 58
      Caption = #52397#49328' '
      TabOrder = 3
      object DateTimePicker: TDateTimePicker
        Left = 75
        Top = 33
        Width = 92
        Height = 21
        Date = 41547.645833333340000000
        Time = 41547.645833333340000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 0
      end
      object cbAutoLiquid: TCheckBox
        Left = 6
        Top = 16
        Width = 71
        Height = 17
        Caption = #51088#46041#52397#49328
        Checked = True
        State = cbChecked
        TabOrder = 1
        OnClick = cbAutoLiquidClick
      end
      object DateTimePicker1: TDateTimePicker
        Left = 75
        Top = 11
        Width = 92
        Height = 21
        Date = 41547.375000000000000000
        Time = 41547.375000000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 2
      end
    end
    object GroupBox1: TGroupBox
      Left = 8
      Top = 25
      Width = 174
      Height = 57
      TabOrder = 4
      object Label3: TLabel
        Left = 9
        Top = 9
        Width = 22
        Height = 13
        Caption = #49688#47049
      end
      object Label4: TLabel
        Left = 99
        Top = 11
        Width = 22
        Height = 13
        Caption = #44036#44201
      end
      object Label5: TLabel
        Left = 9
        Top = 36
        Width = 22
        Height = 13
        Caption = #53244#54021
      end
      object Label9: TLabel
        Left = 93
        Top = 36
        Width = 30
        Height = 13
        Caption = 'S_Tick'
      end
      object edtQty: TEdit
        Left = 39
        Top = 6
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '1'
        OnKeyPress = edtGapKeyPress
      end
      object UpDown1: TUpDown
        Left = 64
        Top = 6
        Width = 16
        Height = 21
        Associate = edtQty
        Min = 1
        Max = 500
        Position = 1
        TabOrder = 1
      end
      object edtGap: TEdit
        Tag = 1
        Left = 125
        Top = 7
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '3'
        OnKeyPress = edtGapKeyPress
      end
      object UpDown2: TUpDown
        Left = 150
        Top = 7
        Width = 16
        Height = 21
        Associate = edtGap
        Min = 1
        Position = 3
        TabOrder = 3
      end
      object edtQuoting: TEdit
        Tag = 2
        Left = 39
        Top = 32
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 4
        Text = '2'
        OnKeyPress = edtGapKeyPress
      end
      object udQuoting: TUpDown
        Left = 64
        Top = 32
        Width = 16
        Height = 21
        Associate = edtQuoting
        Min = 1
        Position = 2
        TabOrder = 5
      end
      object edtSTick: TEdit
        Tag = 6
        Left = 125
        Top = 32
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 6
        Text = '0'
        OnKeyPress = edtGapKeyPress
      end
      object udSTick: TUpDown
        Left = 150
        Top = 32
        Width = 16
        Height = 21
        Associate = edtSTick
        TabOrder = 7
      end
    end
    object GroupBox2: TGroupBox
      Left = 8
      Top = 100
      Width = 175
      Height = 32
      TabOrder = 5
      object Label1: TLabel
        Left = 9
        Top = 9
        Width = 29
        Height = 13
        Caption = 'S_Pos'
      end
      object Label8: TLabel
        Left = 93
        Top = 10
        Width = 29
        Height = 13
        Caption = 'E_Pos'
      end
      object edtSPos: TEdit
        Tag = 3
        Left = 41
        Top = 6
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '2'
        OnKeyPress = edtGapKeyPress
      end
      object udSPos: TUpDown
        Left = 66
        Top = 6
        Width = 16
        Height = 21
        Associate = edtSPos
        Min = 1
        Max = 10000
        Position = 2
        TabOrder = 1
      end
      object edtEPos: TEdit
        Tag = 4
        Left = 128
        Top = 6
        Width = 25
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '2'
        OnKeyPress = edtGapKeyPress
      end
      object udEPos: TUpDown
        Left = 153
        Top = 6
        Width = 16
        Height = 21
        Associate = edtEPos
        Max = 10000
        Position = 2
        TabOrder = 3
      end
    end
    object cbUseBetween: TCheckBox
      Tag = 2
      Left = 10
      Top = 83
      Width = 49
      Height = 17
      Caption = #49324#51060
      TabOrder = 6
      OnClick = cbAutoLiquidClick
    end
    object btnApply: TButton
      Left = 149
      Top = 3
      Width = 36
      Height = 20
      Caption = #51201#50857
      TabOrder = 7
      OnClick = btnApplyClick
    end
    object cbPause: TCheckBox
      Tag = 3
      Left = 121
      Top = 83
      Width = 50
      Height = 17
      Hint = #51452#47928#47564' '#52712#49548
      Caption = 'Pause'
      ParentShowHint = False
      ShowHint = False
      TabOrder = 8
      OnClick = cbPauseClick
    end
    object cbPlatoon: TCheckBox
      Tag = 3
      Left = 63
      Top = 83
      Width = 50
      Height = 17
      Caption = #54540#47000#53808
      Checked = True
      ParentShowHint = False
      ShowHint = False
      State = cbChecked
      TabOrder = 9
      OnClick = cbPlatoonClick
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 287
    Width = 184
    Height = 19
    Panels = <
      item
        Width = 60
      end
      item
        Width = 160
      end>
  end
  object ColorDialog: TColorDialog
    Left = 144
    Top = 208
  end
end
