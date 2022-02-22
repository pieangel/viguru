object FrmInvestor: TFrmInvestor
  Left = 0
  Top = 0
  Caption = #53804#51088#51088'('#44060#51064')'
  ClientHeight = 416
  ClientWidth = 314
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
    Width = 314
    Height = 193
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 11
      Top = 29
      Width = 24
      Height = 13
      Caption = #49688#47049
    end
    object Label3: TLabel
      Left = 74
      Top = 29
      Width = 24
      Height = 13
      Caption = #44036#44201
    end
    object Label7: TLabel
      Left = 206
      Top = 62
      Width = 8
      Height = 13
      Caption = '~'
    end
    object Label8: TLabel
      Left = 133
      Top = 62
      Width = 24
      Height = 13
      Caption = #44032#44201
    end
    object Label4: TLabel
      Left = 158
      Top = 29
      Width = 24
      Height = 13
      Caption = #45800#44228
    end
    object Label5: TLabel
      Left = 137
      Top = 29
      Width = 12
      Height = 13
      Caption = #50613
    end
    object Label2: TLabel
      Left = 223
      Top = 29
      Width = 48
      Height = 13
      Caption = #51652#51077#54943#49688
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
      Left = 63
      Top = 2
      Width = 117
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboAccountChange
    end
    object edtQty: TEdit
      Left = 39
      Top = 26
      Width = 30
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '1'
      OnChange = edtQtyChange
    end
    object edtGap: TEdit
      Left = 103
      Top = 26
      Width = 30
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '10'
    end
    object edtLow: TEdit
      Left = 167
      Top = 58
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '0.5'
      OnChange = edtQtyChange
    end
    object edtHigh: TEdit
      Left = 220
      Top = 58
      Width = 33
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 5
      Text = '1.5'
      OnChange = edtQtyChange
    end
    object btnClear: TButton
      Left = 184
      Top = 1
      Width = 52
      Height = 21
      Caption = #52397#49328
      TabOrder = 6
      OnClick = btnClearClick
    end
    object sgInvestor: TStringGrid
      Left = 1
      Top = 85
      Width = 312
      Height = 64
      Align = alBottom
      DefaultColWidth = 60
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 3
      ScrollBars = ssNone
      TabOrder = 7
      OnDrawCell = sgInvestorDrawCell
    end
    object rgType: TRadioGroup
      Left = 11
      Top = 49
      Width = 113
      Height = 32
      Caption = 'OrderType'
      Columns = 2
      ItemIndex = 0
      Items.Strings = (
        #47588#46020
        #47588#49688)
      TabOrder = 8
      OnClick = rgTypeClick
    end
    object edtGrade: TEdit
      Left = 185
      Top = 26
      Width = 30
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '10'
    end
    object sgInfo: TStringGrid
      Left = 1
      Top = 149
      Width = 312
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
      TabOrder = 10
      OnDrawCell = sgInfoDrawCell
    end
    object cbReSet: TCheckBox
      Left = 259
      Top = 62
      Width = 38
      Height = 17
      Caption = '0'#50896' '#44592#51456' '#52397#49328
      TabOrder = 11
      OnClick = cbStartClick
    end
    object edtEntryCnt: TEdit
      Left = 277
      Top = 26
      Width = 30
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 12
      Text = '2'
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 193
    Width = 314
    Height = 223
    Align = alClient
    TabOrder = 1
    object sgOpt: TStringGrid
      Left = 1
      Top = 1
      Width = 312
      Height = 202
      Align = alClient
      DefaultColWidth = 60
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      ScrollBars = ssNone
      TabOrder = 0
      OnDrawCell = sgOptDrawCell
    end
    object StatusBar1: TStatusBar
      Left = 1
      Top = 203
      Width = 312
      Height = 19
      Panels = <
        item
          Alignment = taRightJustify
          Width = 150
        end
        item
          Alignment = taRightJustify
          Width = 50
        end>
    end
  end
end
