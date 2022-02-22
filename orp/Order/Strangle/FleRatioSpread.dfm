object FrmRatioSpread: TFrmRatioSpread
  Left = 0
  Top = 0
  Caption = 'Ratio Spread'
  ClientHeight = 442
  ClientWidth = 392
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
    Width = 392
    Height = 225
    Align = alTop
    TabOrder = 0
    ExplicitWidth = 351
    object Label1: TLabel
      Left = 14
      Top = 29
      Width = 51
      Height = 13
      Caption = #49688'         '#47049
    end
    object Label2: TLabel
      Left = 120
      Top = 29
      Width = 51
      Height = 13
      Caption = #44036'         '#44201
    end
    object Label7: TLabel
      Left = 209
      Top = 83
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label3: TLabel
      Left = 120
      Top = 83
      Width = 48
      Height = 13
      Caption = #50741#49496#44032#44201
    end
    object Label4: TLabel
      Left = 14
      Top = 55
      Width = 51
      Height = 13
      Caption = #45800'         '#44228
    end
    object Label5: TLabel
      Left = 14
      Top = 82
      Width = 51
      Height = 13
      Caption = #49345'       '#48169'2'
    end
    object Label6: TLabel
      Left = 14
      Top = 109
      Width = 51
      Height = 13
      Caption = #54616'       '#48169'2'
    end
    object Label8: TLabel
      Left = 120
      Top = 55
      Width = 48
      Height = 13
      Caption = #48708'        '#50984
    end
    object Label11: TLabel
      Left = 120
      Top = 109
      Width = 45
      Height = 13
      Caption = #49552'       '#51061
    end
    object Label9: TLabel
      Left = 238
      Top = 55
      Width = 36
      Height = 13
      Caption = #54788#51116#44032
    end
    object Label10: TLabel
      Left = 124
      Top = 134
      Width = 36
      Height = 13
      Caption = 'UpBase'
    end
    object Label12: TLabel
      Left = 120
      Top = 159
      Width = 50
      Height = 13
      Caption = 'DownBase'
    end
    object ComboAccount: TComboBox
      Left = 72
      Top = 2
      Width = 153
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object cbStart: TCheckBox
      Left = 14
      Top = 3
      Width = 47
      Height = 17
      Caption = 'Start'
      TabOrder = 1
      OnClick = cbStartClick
    end
    object btnSymbol: TButton
      Left = 235
      Top = 1
      Width = 52
      Height = 21
      Caption = #51333#47785
      TabOrder = 2
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 72
      Top = 26
      Width = 39
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '2'
    end
    object edtGap: TEdit
      Left = 175
      Top = 26
      Width = 50
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '0.3'
    end
    object edtLow: TEdit
      Left = 174
      Top = 79
      Width = 28
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '0.1'
    end
    object edtHigh: TEdit
      Left = 223
      Top = 79
      Width = 30
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      Text = '2.0'
    end
    object edtGrade: TEdit
      Left = 72
      Top = 52
      Width = 39
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '8'
    end
    object btnClear: TButton
      Left = 293
      Top = 1
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 8
      OnClick = btnClearClick
    end
    object sgInfo: TStringGrid
      Left = 1
      Top = 181
      Width = 390
      Height = 43
      Align = alBottom
      ColCount = 4
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      FixedRows = 0
      ScrollBars = ssNone
      TabOrder = 9
      OnDrawCell = sgInfoDrawCell
      ExplicitWidth = 349
    end
    object edtUpBid2: TEdit
      Left = 72
      Top = 79
      Width = 38
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 10
      Text = '0.65'
    end
    object edtDownBid2: TEdit
      Left = 72
      Top = 106
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 11
      Text = '0.65'
    end
    object edtRatio: TEdit
      Left = 175
      Top = 52
      Width = 50
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 12
      Text = '20'
    end
    object edtPL: TEdit
      Left = 174
      Top = 106
      Width = 78
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 13
    end
    object cbHdege: TCheckBox
      Left = 248
      Top = 28
      Width = 50
      Height = 17
      Caption = 'Hedge'
      TabOrder = 14
      OnClick = cbStartClick
    end
    object edtFut: TEdit
      Left = 280
      Top = 52
      Width = 54
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 15
    end
    object rgEntry: TRadioGroup
      Left = 14
      Top = 127
      Width = 73
      Height = 52
      Caption = 'Entry'
      ItemIndex = 0
      Items.Strings = (
        'Hedge'
        'User')
      TabOrder = 16
      OnClick = rgEntryClick
    end
    object edtUpBase: TEdit
      Left = 175
      Top = 131
      Width = 54
      Height = 21
      Enabled = False
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 17
      Text = '0'
    end
    object edtDownBase: TEdit
      Left = 175
      Top = 156
      Width = 54
      Height = 21
      Enabled = False
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 18
      Text = '0'
    end
    object udUp: TUpDown
      Left = 229
      Top = 131
      Width = 17
      Height = 21
      Enabled = False
      Min = -1000
      Max = 1000
      TabOrder = 19
      OnClick = udUpClick
    end
    object udDown: TUpDown
      Tag = 1
      Left = 229
      Top = 155
      Width = 17
      Height = 21
      Enabled = False
      Min = -1000
      Max = 1000
      TabOrder = 20
      OnClick = udUpClick
    end
    object btnDownApply: TButton
      Tag = 1
      Left = 250
      Top = 155
      Width = 35
      Height = 21
      Caption = #51201#50857
      Enabled = False
      TabOrder = 21
      OnClick = btnDownApplyClick
    end
    object btnUpApply: TButton
      Left = 250
      Top = 131
      Width = 35
      Height = 21
      Caption = #51201#50857
      Enabled = False
      TabOrder = 22
      OnClick = btnDownApplyClick
    end
    object btnDownInit: TButton
      Tag = 1
      Left = 291
      Top = 155
      Width = 45
      Height = 21
      Caption = #52488#44592#54868
      Enabled = False
      TabOrder = 23
      OnClick = btnDownInitClick
    end
    object btnUpInit: TButton
      Left = 291
      Top = 131
      Width = 45
      Height = 21
      Caption = #52488#44592#54868
      Enabled = False
      TabOrder = 24
      OnClick = btnDownInitClick
    end
    object cbTwoSymbol: TCheckBox
      Left = 304
      Top = 28
      Width = 97
      Height = 17
      Caption = '2'#51333#47785
      Checked = True
      State = cbChecked
      TabOrder = 25
      OnClick = cbStartClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 225
    Width = 392
    Height = 217
    Align = alClient
    TabOrder = 1
    ExplicitWidth = 351
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 390
      Height = 196
      Align = alClient
      DefaultColWidth = 75
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
      ExplicitWidth = 349
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 197
      Width = 390
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 50
        end>
      ExplicitWidth = 349
    end
  end
end
