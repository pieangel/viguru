object FrmDuration: TFrmDuration
  Left = 0
  Top = 0
  Caption = 'Order Duration'
  ClientHeight = 303
  ClientWidth = 612
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
    Top = 36
    Width = 105
    Height = 267
    Align = alLeft
    TabOrder = 0
    object lvDura: TListView
      Left = 1
      Top = 1
      Width = 103
      Height = 265
      Align = alClient
      Columns = <
        item
          Caption = #51333#47785
          Width = 90
        end>
      GridLines = True
      PopupMenu = pmList
      TabOrder = 0
      ViewStyle = vsReport
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 612
    Height = 36
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 477
      Top = 11
      Width = 62
      Height = 13
      Caption = #45236#51452#47928'Avg :'
    end
    object lbAvg: TLabel
      Left = 542
      Top = 11
      Width = 49
      Height = 13
      AutoSize = False
    end
    object cbReceive: TCheckBox
      Left = 418
      Top = 5
      Width = 55
      Height = 25
      Caption = #49688'  '#49888
      TabOrder = 0
      OnClick = cbReceiveClick
    end
    object btnSymbol: TButton
      Left = 275
      Top = 6
      Width = 25
      Height = 23
      Caption = '...'
      TabOrder = 1
      OnClick = btnSymbolClick
    end
    object btnCfg: TButton
      Left = 301
      Top = 5
      Width = 43
      Height = 25
      Caption = #49444' '#51221
      TabOrder = 2
      OnClick = btnCfgClick
    end
    object rbMarket: TRadioButton
      Left = 5
      Top = 10
      Width = 57
      Height = 17
      Caption = #49884#51109#48324
      Checked = True
      TabOrder = 3
      TabStop = True
      OnClick = rbMarketClick
    end
    object gbMarket: TGroupBox
      Left = 63
      Top = 3
      Width = 150
      Height = 29
      TabOrder = 4
      object cbfut: TCheckBox
        Left = 9
        Top = 7
        Width = 45
        Height = 17
        Caption = #49440#47932
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbfutClick
      end
      object cbCall: TCheckBox
        Tag = 1
        Left = 65
        Top = 7
        Width = 34
        Height = 17
        Caption = #53084
        TabOrder = 1
        OnClick = cbfutClick
      end
      object cbPut: TCheckBox
        Tag = 2
        Left = 111
        Top = 7
        Width = 34
        Height = 17
        Caption = #54411
        TabOrder = 2
        OnClick = cbfutClick
      end
    end
    object rbIssue: TRadioButton
      Left = 219
      Top = 10
      Width = 57
      Height = 17
      Caption = #51333#47785#48324
      TabOrder = 5
      OnClick = rbMarketClick
    end
    object btnClear: TButton
      Left = 346
      Top = 5
      Width = 36
      Height = 25
      Caption = 'Clear'
      TabOrder = 6
      OnClick = btnClearClick
    end
    object btnLog: TButton
      Left = 382
      Top = 5
      Width = 33
      Height = 25
      Caption = 'Log'
      TabOrder = 7
      OnClick = btnLogClick
    end
  end
  object Panel3: TPanel
    Left = 105
    Top = 36
    Width = 507
    Height = 267
    Align = alClient
    TabOrder = 2
    object sgDura: TStringGrid
      Left = 1
      Top = 1
      Width = 505
      Height = 265
      Align = alClient
      ColCount = 8
      DefaultRowHeight = 16
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
      TabOrder = 0
      OnDrawCell = sgDuraDrawCell
    end
  end
  object pmList: TPopupMenu
    Left = 40
    Top = 176
    object nDelete: TMenuItem
      Caption = #49325#51228
      OnClick = nDeleteClick
    end
  end
end
