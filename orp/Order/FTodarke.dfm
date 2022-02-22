object FrmTodarke: TFrmTodarke
  Left = 0
  Top = 0
  Caption = #53664#45797#53664#45797
  ClientHeight = 336
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
  object plbg: TPanel
    Left = 0
    Top = 0
    Width = 394
    Height = 209
    Align = alTop
    BiDiMode = bdLeftToRight
    Ctl3D = True
    ParentBiDiMode = False
    ParentBackground = False
    ParentCtl3D = False
    TabOrder = 0
    object Label4: TLabel
      Left = 252
      Top = 6
      Width = 8
      Height = 13
      Caption = '~'
    end
    object cbStart: TCheckBox
      Left = 9
      Top = 3
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object ComboAccount: TComboBox
      Left = 55
      Top = 2
      Width = 124
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object btnSymbol: TButton
      Left = 333
      Top = 1
      Width = 52
      Height = 21
      Caption = #51333#47785
      TabOrder = 2
      Visible = False
    end
    object btnClear: TButton
      Left = 317
      Top = 1
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 3
    end
    object GroupBox1: TGroupBox
      Left = 9
      Top = 28
      Width = 235
      Height = 175
      Caption = #53664#45797#51060
      TabOrder = 4
      object Label2: TLabel
        Left = 10
        Top = 18
        Width = 23
        Height = 13
        Caption = 'start'
      end
      object Label6: TLabel
        Left = 15
        Top = 37
        Width = 18
        Height = 13
        Caption = 'end'
      end
      object Label7: TLabel
        Left = 135
        Top = 94
        Width = 24
        Height = 13
        Caption = #51652#51077
      end
      object Label8: TLabel
        Left = 135
        Top = 121
        Width = 24
        Height = 13
        Caption = #52397#49328
      end
      object Label9: TLabel
        Left = 135
        Top = 148
        Width = 24
        Height = 13
        Caption = #49552#51208
      end
      object Label10: TLabel
        Left = 214
        Top = 96
        Width = 12
        Height = 13
        Caption = #52488
      end
      object Label11: TLabel
        Left = 214
        Top = 123
        Width = 12
        Height = 13
        Caption = #52488
      end
      object Label12: TLabel
        Left = 214
        Top = 150
        Width = 12
        Height = 13
        Caption = #54001
      end
      object Label1: TLabel
        Left = 134
        Top = 69
        Width = 24
        Height = 13
        Caption = #49688#47049
      end
      object Label5: TLabel
        Left = 34
        Top = 91
        Width = 21
        Height = 13
        Caption = '1'#52264' '
        Color = clBtnFace
        ParentColor = False
      end
      object Label21: TLabel
        Left = 34
        Top = 119
        Width = 21
        Height = 13
        Caption = '2'#52264' '
        Color = clBtnFace
        ParentColor = False
      end
      object Label22: TLabel
        Left = 34
        Top = 145
        Width = 21
        Height = 13
        Caption = '3'#52264' '
        Color = clBtnFace
        ParentColor = False
      end
      object Label23: TLabel
        Left = 135
        Top = 43
        Width = 21
        Height = 13
        Caption = 'MAX'
      end
      object edt1th: TEdit
        Left = 95
        Top = 91
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 0
        Text = '0.7'
      end
      object edt2th: TEdit
        Left = 95
        Top = 115
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '0.65'
      end
      object edt3th: TEdit
        Left = 95
        Top = 142
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '0.6'
      end
      object dpstartTime1: TDateTimePicker
        Left = 38
        Top = 14
        Width = 92
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 38303.375000000000000000
        Time = 38303.375000000000000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImeName = 'Korean Input System (IME 2000)'
        Kind = dtkTime
        ParentBiDiMode = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 3
      end
      object dpEndTime1: TDateTimePicker
        Left = 38
        Top = 37
        Width = 92
        Height = 21
        BiDiMode = bdLeftToRight
        Date = 38303.416840277780000000
        Time = 38303.416840277780000000
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ImeName = 'Korean Input System (IME 2000)'
        Kind = dtkTime
        ParentBiDiMode = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 4
      end
      object edtEntrySec: TEdit
        Left = 164
        Top = 91
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '52'
      end
      object edtLiqSec: TEdit
        Left = 164
        Top = 118
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 6
        Text = '2'
        OnChange = edtLiqSecChange
      end
      object edtLossTick1: TEdit
        Left = 164
        Top = 145
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 7
        Text = '2'
        OnChange = edtLossTick1Change
      end
      object UpDown1: TUpDown
        Left = 194
        Top = 118
        Width = 15
        Height = 21
        Associate = edtLiqSec
        Min = 1
        Max = 59
        Position = 2
        TabOrder = 8
      end
      object UpDown3: TUpDown
        Left = 194
        Top = 91
        Width = 15
        Height = 21
        Associate = edtEntrySec
        Min = 1
        Max = 59
        Position = 52
        TabOrder = 9
      end
      object UpDown4: TUpDown
        Left = 194
        Top = 145
        Width = 15
        Height = 21
        Associate = edtLossTick1
        Min = 1
        Max = 10
        Position = 2
        TabOrder = 10
      end
      object edtQty: TEdit
        Left = 164
        Top = 65
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 11
        Text = '1'
        OnChange = edtQtyChange
      end
      object UpDown2: TUpDown
        Left = 194
        Top = 65
        Width = 15
        Height = 21
        Associate = edtQty
        Min = 1
        Position = 1
        TabOrder = 12
      end
      object cbL1th: TCheckBox
        Left = 5
        Top = 89
        Width = 26
        Height = 21
        Caption = 'L'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 13
        OnClick = cbL1thClick
      end
      object cbL2th: TCheckBox
        Tag = 1
        Left = 4
        Top = 118
        Width = 26
        Height = 17
        Caption = 'L'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 14
        OnClick = cbL1thClick
      end
      object cbL3th: TCheckBox
        Tag = 2
        Left = 4
        Top = 143
        Width = 26
        Height = 17
        Caption = 'L'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 15
        OnClick = cbL1thClick
      end
      object cbS1th: TCheckBox
        Left = 61
        Top = 91
        Width = 26
        Height = 17
        Caption = 'S'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 16
        OnClick = cbS1thClick
      end
      object cbS2th: TCheckBox
        Tag = 1
        Left = 61
        Top = 118
        Width = 26
        Height = 17
        Caption = 'S'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 17
        OnClick = cbS1thClick
      end
      object cbS3th: TCheckBox
        Tag = 2
        Left = 61
        Top = 143
        Width = 26
        Height = 17
        Caption = 'S'
        Checked = True
        Color = clBtnFace
        ParentColor = False
        State = cbChecked
        TabOrder = 18
        OnClick = cbS1thClick
      end
      object cbIncQty: TCheckBox
        Left = 159
        Top = 9
        Width = 71
        Height = 17
        Caption = #49688#47049#51613#44032
        TabOrder = 19
        OnClick = cbIncQtyClick
      end
      object edtMaxOrder: TEdit
        Left = 164
        Top = 39
        Width = 30
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 20
        Text = '3'
        OnChange = edtMaxOrderChange
      end
      object UpDown9: TUpDown
        Left = 194
        Top = 39
        Width = 15
        Height = 21
        Associate = edtMaxOrder
        Min = 1
        Max = 50
        Position = 3
        TabOrder = 21
      end
    end
    object cbwithOpt: TCheckBox
      Left = 200
      Top = 3
      Width = 35
      Height = 17
      Caption = 'opt'
      TabOrder = 5
    end
    object edtMin: TEdit
      Left = 241
      Top = 1
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      Text = '1.0'
    end
    object edtMax: TEdit
      Left = 281
      Top = 2
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '1.5'
    end
  end
  object stBar: TStatusBar
    Left = 0
    Top = 316
    Width = 394
    Height = 20
    Panels = <
      item
        Alignment = taRightJustify
        Style = psOwnerDraw
        Width = 50
      end
      item
        Style = psOwnerDraw
        Width = 50
      end
      item
        Style = psOwnerDraw
        Width = 50
      end
      item
        Width = 50
      end>
    OnDrawPanel = stBarDrawPanel
  end
  object Panel1: TPanel
    Left = 0
    Top = 209
    Width = 394
    Height = 107
    Align = alClient
    Caption = 'Panel1'
    TabOrder = 2
    object sgResult: TStringGrid
      Left = 1
      Top = 1
      Width = 392
      Height = 105
      Align = alClient
      Ctl3D = False
      DefaultColWidth = 55
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 0
      ColWidths = (
        74
        36
        43
        43
        170)
    end
  end
end
