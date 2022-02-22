object FrmArbPLMonitor: TFrmArbPLMonitor
  Left = 0
  Top = 0
  Caption = #52264#51061#49552#51061#47784#45768#53552
  ClientHeight = 576
  ClientWidth = 635
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
  object Splitter1: TSplitter
    Left = 0
    Top = 438
    Width = 635
    Height = 4
    Cursor = crVSplit
    Align = alBottom
    ExplicitTop = 336
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 635
    Height = 49
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 40
      Top = 16
      Width = 3
      Height = 13
    end
    object lblFixedPL: TLabel
      Left = 152
      Top = 8
      Width = 135
      Height = 13
      Caption = #54869#51221#49552#51061':  000,000,000 '#50896
    end
    object lblOpenPL: TLabel
      Left = 152
      Top = 27
      Width = 135
      Height = 13
      Caption = #54217#44032#49552#51061':  000,000,000 '#50896
    end
    object lblTotGroup: TLabel
      Left = 320
      Top = 8
      Width = 88
      Height = 13
      Caption = #52509#44536#47353#49688':  120    '
    end
    object lblWinRate: TLabel
      Left = 320
      Top = 27
      Width = 99
      Height = 13
      Caption = #49849#47456': 90% ( 9 / 10 )'
    end
    object lbAcntName: TLabel
      Left = 7
      Top = 30
      Width = 123
      Height = 13
      AutoSize = False
      Caption = #44228#51340#47749
    end
    object Button1: TButton
      Left = 425
      Top = 2
      Width = 75
      Height = 41
      Caption = #49552#51061#44081#49888
      TabOrder = 0
      OnClick = Button1Click
    end
    object cbAccount: TComboBox
      Left = 4
      Top = 3
      Width = 126
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft IME 2010'
      ItemHeight = 13
      TabOrder = 1
      OnChange = cbAccountChange
    end
  end
  object sgSet: TStringGrid
    Left = 0
    Top = 49
    Width = 635
    Height = 389
    Align = alClient
    DefaultRowHeight = 17
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 1
    OnDrawCell = sgSetDrawCell
    OnMouseDown = sgSetMouseDown
    OnSelectCell = sgSetSelectCell
  end
  object sgDetail: TStringGrid
    Tag = 10
    Left = 0
    Top = 442
    Width = 635
    Height = 134
    Align = alBottom
    DefaultRowHeight = 17
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    TabOrder = 2
    OnDrawCell = sgSetDrawCell
  end
end
