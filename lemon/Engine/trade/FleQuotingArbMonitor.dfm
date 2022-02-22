object FrmQuotingArb: TFrmQuotingArb
  Left = 0
  Top = 0
  Caption = 'QuotingArbMonitor'
  ClientHeight = 625
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object Panel4: TPanel
    Left = 146
    Top = 0
    Width = 486
    Height = 625
    Align = alClient
    TabOrder = 0
    object Splitter1: TSplitter
      Left = 1
      Top = 499
      Width = 484
      Height = 4
      Cursor = crVSplit
      Align = alBottom
      ExplicitTop = 498
      ExplicitWidth = 573
    end
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 484
      Height = 70
      Align = alTop
      TabOrder = 0
      object lbAcntName: TLabel
        Left = 7
        Top = 30
        Width = 123
        Height = 13
        AutoSize = False
        Caption = #44228#51340#47749
      end
      object lblTotGroup: TLabel
        Left = 121
        Top = 30
        Width = 78
        Height = 12
        Caption = #52509#44536#47353#49688':  0   '
      end
      object lblWinRate: TLabel
        Left = 121
        Top = 52
        Width = 96
        Height = 12
        Caption = #49849#47456': 0% ( 0 / 0 )'
      end
      object lblFixedPL: TLabel
        Left = 121
        Top = 8
        Width = 138
        Height = 12
        Caption = #54869#51221#49552#51061':  000,000,000 '#50896
      end
      object lbFCLR: TLabel
        Left = 277
        Top = 8
        Width = 127
        Height = 13
        AutoSize = False
        Caption = 'CLR: 000,000,000 '#50896
      end
      object lbBox: TLabel
        Left = 276
        Top = 30
        Width = 128
        Height = 13
        AutoSize = False
        Caption = 'BOX: 000,000,000 '#50896
      end
      object lbFCP: TLabel
        Left = 277
        Top = 52
        Width = 127
        Height = 13
        AutoSize = False
        Caption = 'FCP: 000,000,000 '#50896
      end
      object lbFCLRcnt: TLabel
        Left = 417
        Top = 8
        Width = 47
        Height = 13
        AutoSize = False
        Caption = '0'
      end
      object lbBOXcnt: TLabel
        Left = 417
        Top = 30
        Width = 47
        Height = 13
        AutoSize = False
        Caption = '0'
      end
      object lbFPCcnt: TLabel
        Left = 417
        Top = 52
        Width = 47
        Height = 13
        AutoSize = False
        Caption = '0'
      end
      object cbAccount: TComboBox
        Left = 4
        Top = 3
        Width = 111
        Height = 20
        Style = csDropDownList
        ImeName = 'Microsoft IME 2010'
        ItemHeight = 12
        TabOrder = 0
        OnChange = cbAccountChange
      end
      object btnFill: TButton
        Left = 7
        Top = 47
        Width = 34
        Height = 22
        Caption = '<<'
        TabOrder = 1
        OnClick = btnFillClick
      end
    end
    object Panel3: TPanel
      Left = 1
      Top = 503
      Width = 484
      Height = 121
      Align = alBottom
      TabOrder = 1
      object sgData: TStringGrid
        Left = 1
        Top = 1
        Width = 482
        Height = 119
        Align = alClient
        ColCount = 7
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 30
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = sgDataDblClick
        OnDrawCell = sgDataDrawCell
        OnSelectCell = sgDataSelectCell
      end
    end
    object Panel2: TPanel
      Left = 1
      Top = 71
      Width = 484
      Height = 428
      Align = alClient
      TabOrder = 2
      object sgBasket: TStringGrid
        Left = 1
        Top = 1
        Width = 482
        Height = 426
        Align = alClient
        ColCount = 7
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDrawCell = sgBasketDrawCell
        OnSelectCell = sgBasketSelectCell
      end
    end
  end
  object plFill: TPanel
    Left = 0
    Top = 0
    Width = 146
    Height = 625
    Align = alLeft
    TabOrder = 1
    Visible = False
    object sgOption: TStringGrid
      Left = 1
      Top = 22
      Width = 144
      Height = 602
      Align = alClient
      ColCount = 3
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 20
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = sgOptionDrawCell
      ColWidths = (
        43
        52
        50)
    end
    object sgFut: TStringGrid
      Left = 1
      Top = 1
      Width = 144
      Height = 21
      Align = alTop
      ColCount = 2
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 1
      FixedRows = 0
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect]
      ScrollBars = ssVertical
      TabOrder = 1
      OnDrawCell = sgFutDrawCell
      ColWidths = (
        59
        62)
    end
  end
end
