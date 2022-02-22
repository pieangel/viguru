object FrmPairsTest: TFrmPairsTest
  Left = 0
  Top = 0
  Caption = 'pair test'
  ClientHeight = 409
  ClientWidth = 679
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
  object sgSymbols: TStringGrid
    Left = 0
    Top = 65
    Width = 679
    Height = 96
    Align = alTop
    ColCount = 10
    DefaultRowHeight = 17
    RowCount = 2
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 0
    RowHeights = (
      17
      17)
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 679
    Height = 65
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 460
    object Label1: TLabel
      Left = 137
      Top = 6
      Width = 46
      Height = 13
      Caption = #49345#54620#49440' : '
    end
    object Label2: TLabel
      Left = 226
      Top = 6
      Width = 46
      Height = 13
      Caption = #54616#54620#49440' : '
    end
    object lbvol: TLabel
      Left = 389
      Top = 8
      Width = 3
      Height = 13
    end
    object cbAccount: TComboBox
      Left = 2
      Top = 2
      Width = 111
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 0
      TabOrder = 0
      Text = 'cbAccount'
      OnChange = cbAccountChange
    end
    object edtHigh: TEdit
      Left = 181
      Top = 2
      Width = 36
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 1
      Text = '1.3'
    end
    object edtLow: TEdit
      Left = 270
      Top = 4
      Width = 35
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '1.3'
    end
    object edtQtyR: TEdit
      Left = 331
      Top = 2
      Width = 40
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '1'
    end
    object cbRun: TCheckBox
      Left = 2
      Top = 39
      Width = 41
      Height = 17
      Caption = #49884#51089
      TabOrder = 4
      OnClick = cbRunClick
    end
    object Button5: TButton
      Left = 49
      Top = 31
      Width = 75
      Height = 25
      Caption = #47588#46020
      TabOrder = 5
      OnClick = Button5Click
    end
    object Button4: TButton
      Left = 130
      Top = 31
      Width = 75
      Height = 25
      Caption = #47588#49688
      TabOrder = 6
      OnClick = Button4Click
    end
    object Button3: TButton
      Left = 217
      Top = 31
      Width = 75
      Height = 25
      Caption = #52397#49328
      TabOrder = 7
      OnClick = Button3Click
    end
    object Button2: TButton
      Left = 298
      Top = 31
      Width = 75
      Height = 25
      Caption = 'Button2'
      TabOrder = 8
      OnClick = Button2Click
    end
    object Button1: TButton
      Left = 379
      Top = 31
      Width = 75
      Height = 25
      Caption = #51333#47785#52286#44592
      TabOrder = 9
      OnClick = Button1Click
    end
  end
  object sgRes: TStringGrid
    Left = 0
    Top = 190
    Width = 392
    Height = 120
    DefaultRowHeight = 19
    FixedCols = 0
    RowCount = 2
    TabOrder = 2
    ColWidths = (
      71
      33
      51
      78
      78)
  end
end
