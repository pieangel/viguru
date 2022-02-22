object CatchForm: TCatchForm
  Left = 0
  Top = 0
  Caption = 'SCatch Form'
  ClientHeight = 149
  ClientWidth = 344
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
    Width = 344
    Height = 31
    Align = alTop
    BiDiMode = bdLeftToRight
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    object ButtonAuto: TSpeedButton
      Left = 6
      Top = 5
      Width = 41
      Height = 21
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Stop'
      OnClick = ButtonAutoClick
    end
    object ButtonSymbol: TSpeedButton
      Left = 311
      Top = 6
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = ButtonSymbolClick
    end
    object ComboAccount: TComboBox
      Left = 54
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
      Left = 197
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
  object pnlBack: TPanel
    Left = 0
    Top = 31
    Width = 344
    Height = 118
    Align = alClient
    BiDiMode = bdLeftToRight
    Ctl3D = True
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentBiDiMode = False
    ParentBackground = False
    ParentCtl3D = False
    ParentFont = False
    TabOrder = 1
    object Label1: TLabel
      Left = 18
      Top = 42
      Width = 43
      Height = 13
      Caption = #52404#44208#54633' :'
    end
    object Label2: TLabel
      Left = 30
      Top = 64
      Width = 31
      Height = 13
      Caption = #44148#49688' :'
    end
    object Label4: TLabel
      Left = 38
      Top = 9
      Width = 13
      Height = 13
      Caption = 'ms'
    end
    object Bevel1: TBevel
      Left = -23
      Top = 27
      Width = 362
      Height = 3
      Shape = bsTopLine
    end
    object Label5: TLabel
      Left = 56
      Top = 7
      Width = 46
      Height = 13
      Caption = 'Ord Qty :'
    end
    object Label3: TLabel
      Left = 153
      Top = 7
      Width = 60
      Height = 13
      Caption = 'Max Quote :'
    end
    object edtFillcnt: TEdit
      Left = 65
      Top = 61
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object edtFillSum: TEdit
      Left = 65
      Top = 36
      Width = 46
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object edtNms: TEdit
      Left = 8
      Top = 3
      Width = 30
      Height = 21
      Hint = #52404#44208#44148#49688' '#44396#54616#45716' '#49884#44036#48276#50948
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '100'
      OnChange = edtFillSumChange
    end
    object sgInfo: TStringGrid
      Left = 116
      Top = 35
      Width = 219
      Height = 75
      ColCount = 3
      Ctl3D = True
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 4
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      ParentCtl3D = False
      TabOrder = 3
      OnDrawCell = sgInfoDrawCell
      ColWidths = (
        56
        64
        92)
    end
    object edtOrderQty: TEdit
      Left = 103
      Top = 3
      Width = 38
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object cbUseVol: TCheckBox
      Left = 13
      Top = 89
      Width = 97
      Height = 17
      Caption = #48533#44340#54840#44032#51092#47049
      TabOrder = 5
      OnClick = cbUseVolClick
    end
    object UseMoth: TCheckBox
      Left = 288
      Top = 5
      Width = 46
      Height = 17
      Caption = 'Moth'
      Color = clBtnFace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      TabOrder = 6
      OnClick = UseMothClick
    end
    object edtMaxQuoteQty: TEdit
      Left = 213
      Top = 3
      Width = 48
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
  end
end
