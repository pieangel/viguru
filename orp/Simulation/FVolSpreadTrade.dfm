object FrmVolSpread: TFrmVolSpread
  Left = 0
  Top = 0
  Caption = 'FrmVolSpread'
  ClientHeight = 322
  ClientWidth = 568
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
    Width = 568
    Height = 33
    Align = alTop
    TabOrder = 0
    object ComboAccount: TComboBox
      Left = 8
      Top = 6
      Width = 113
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object cbRun: TCheckBox
      Left = 519
      Top = 7
      Width = 49
      Height = 17
      Caption = #49884#51089
      TabOrder = 1
      OnClick = cbRunClick
    end
    object Button1: TButton
      Left = 127
      Top = 7
      Width = 57
      Height = 20
      Caption = #52397#49328
      TabOrder = 2
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 496
      Top = 30
      Width = 57
      Height = 20
      TabOrder = 3
    end
    object edtStdQty: TEdit
      Left = 488
      Top = 6
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 4
      Text = '1'
    end
    object Button3: TButton
      Left = 190
      Top = 6
      Width = 41
      Height = 21
      Caption = 'hedge'
      TabOrder = 5
      OnClick = Button3Click
    end
    object Button4: TButton
      Left = 237
      Top = 6
      Width = 59
      Height = 21
      Caption = 'hedge'#52397#49328
      TabOrder = 6
      OnClick = Button4Click
    end
    object edtLow: TEdit
      Left = 424
      Top = 6
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '-0.10'
    end
    object edtHigh: TEdit
      Left = 377
      Top = 6
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 8
      Text = '0.10'
    end
    object edtHedge: TEdit
      Left = 321
      Top = 6
      Width = 41
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 9
      Text = '0.10'
    end
  end
  object sgSymbols: TStringGrid
    Left = 0
    Top = 33
    Width = 568
    Height = 96
    Align = alTop
    ColCount = 10
    DefaultColWidth = 50
    DefaultRowHeight = 17
    FixedCols = 0
    FixedRows = 0
    TabOrder = 1
  end
  object sgResult: TStringGrid
    Left = 0
    Top = 129
    Width = 568
    Height = 174
    Align = alClient
    ColCount = 2
    DefaultColWidth = 50
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    TabOrder = 2
    ColWidths = (
      62
      447)
  end
  object stBar: TStatusBar
    Left = 0
    Top = 303
    Width = 568
    Height = 19
    Panels = <
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 100
      end
      item
        Width = 50
      end>
  end
end
