object FraSCatchOrder: TFraSCatchOrder
  Left = 0
  Top = 0
  Width = 363
  Height = 144
  TabOrder = 0
  object plLeft: TPanel
    Left = 0
    Top = 0
    Width = 363
    Height = 66
    Align = alTop
    ParentBackground = False
    ParentShowHint = False
    ShowHint = True
    TabOrder = 0
    object Label1: TLabel
      Left = 5
      Top = 35
      Width = 43
      Height = 13
      Caption = #52404#44208#54633' :'
    end
    object Label2: TLabel
      Left = 105
      Top = 32
      Width = 31
      Height = 13
      Caption = #44148#49688' :'
    end
    object Label4: TLabel
      Left = 77
      Top = 8
      Width = 13
      Height = 13
      Caption = 'ms'
    end
    object Label5: TLabel
      Left = 95
      Top = 8
      Width = 46
      Height = 13
      Caption = 'Ord Qty :'
    end
    object Label3: TLabel
      Left = 175
      Top = 8
      Width = 60
      Height = 13
      Caption = 'Max Quote :'
    end
    object ButtonAuto: TSpeedButton
      Left = 5
      Top = 4
      Width = 41
      Height = 21
      AllowAllUp = True
      GroupIndex = 1
      Caption = 'Stop'
      OnClick = ButtonAutoClick
    end
    object btnExpand: TSpeedButton
      Tag = 4
      Left = 1
      Top = 50
      Width = 361
      Height = 15
      Align = alBottom
      AllowAllUp = True
      GroupIndex = 2
      Caption = #9660
      OnClick = btnExpandClick
      ExplicitTop = 105
      ExplicitWidth = 416
    end
    object lbTag: TLabel
      Left = 299
      Top = 32
      Width = 59
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
    object edtFillcnt: TEdit
      Left = 140
      Top = 29
      Width = 47
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 0
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object edtFillSum: TEdit
      Left = 52
      Top = 29
      Width = 46
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object edtNms: TEdit
      Left = 47
      Top = 4
      Width = 30
      Height = 21
      Hint = #52404#44208#44148#49688' '#44396#54616#45716' '#49884#44036#48276#50948
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '100'
      OnChange = edtFillSumChange
    end
    object edtOrderQty: TEdit
      Left = 143
      Top = 4
      Width = 31
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
    object cbUseVol: TCheckBox
      Left = 200
      Top = 31
      Width = 97
      Height = 17
      Caption = #48533#44340#54840#44032#51092#47049
      TabOrder = 4
      OnClick = cbUseVolClick
    end
    object UseMoth: TCheckBox
      Left = 310
      Top = 8
      Width = 46
      Height = 17
      Caption = 'Moth'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clMaroon
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 5
      OnClick = UseMothClick
    end
    object edtMaxQuoteQty: TEdit
      Left = 235
      Top = 4
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 6
      OnChange = edtFillSumChange
      OnKeyPress = edtOrderQtyKeyPress
    end
  end
  object plRight: TPanel
    Left = 0
    Top = 66
    Width = 363
    Height = 78
    Align = alClient
    TabOrder = 1
    object sgInfo: TStringGrid
      Left = 1
      Top = 1
      Width = 361
      Height = 76
      Align = alClient
      ColCount = 3
      Ctl3D = True
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 4
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      ParentCtl3D = False
      TabOrder = 0
      OnDrawCell = sgInfoDrawCell
      ColWidths = (
        56
        64
        92)
    end
  end
end
