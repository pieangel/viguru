object SymbolDialog: TSymbolDialog
  Left = 430
  Top = 136
  BorderStyle = bsDialog
  Caption = 'Select symbol'
  ClientHeight = 512
  ClientWidth = 341
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 14
  object PageTypes: TPageControl
    Left = 0
    Top = 0
    Width = 341
    Height = 329
    ActivePage = TabFutures
    Align = alTop
    TabOrder = 0
    TabWidth = 50
    OnChange = PageTypesChange
    object TabFutures: TTabSheet
      Caption = 'Futures'
      object Bevel1: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label8: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object Label10: TLabel
        Left = 174
        Top = 8
        Width = 44
        Height = 14
        Caption = #51452#49885#49440#47932
      end
      object ComboBoxFuturesMarkets: TComboBox
        Tag = 100
        Left = 49
        Top = 5
        Width = 118
        Height = 22
        Style = csDropDownList
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 14
        TabOrder = 0
        OnChange = ComboBoxMarketsChange
      end
      object ListViewFutures: TListView
        Left = 0
        Top = 30
        Width = 333
        Height = 270
        Align = alClient
        Columns = <
          item
            Caption = 'Code'
            Width = 98
          end
          item
            Caption = 'Description'
            Width = 172
          end>
        ColumnClick = False
        GridLines = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        OnDblClick = SymbolDblClick
        OnDrawItem = ListDrawItem
        OnSelectItem = ListSelectItem
      end
      object ComboBoxStockFutures: TComboBox
        Tag = 100
        Left = 226
        Top = 5
        Width = 103
        Height = 22
        Style = csDropDownList
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 14
        Sorted = True
        TabOrder = 2
        OnChange = ComboBoxMarketsChange
      end
    end
    object TabOptions: TTabSheet
      Caption = 'Option'
      ImageIndex = 1
      object Bevel2: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label2: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object Label7: TLabel
        Left = 189
        Top = 8
        Width = 32
        Height = 14
        Caption = 'Month:'
      end
      object StringGridOptions: TStringGrid
        Tag = 700
        Left = 0
        Top = 51
        Width = 333
        Height = 249
        Align = alClient
        ColCount = 3
        DefaultRowHeight = 15
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 15
        FixedRows = 0
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = SymbolDblClick
        OnDrawCell = StringGridOptionsDrawCell
        OnSelectCell = StringGridOptionsSelectCell
        ColWidths = (
          69
          81
          65)
      end
      object HeaderControl2: THeaderControl
        Left = 0
        Top = 30
        Width = 333
        Height = 21
        Sections = <
          item
            Alignment = taCenter
            ImageIndex = -1
            Text = 'Call'
            Width = 72
          end
          item
            Alignment = taCenter
            ImageIndex = -1
            Text = 'Strike'
            Width = 82
          end
          item
            Alignment = taCenter
            ImageIndex = -1
            Text = 'Put'
            Width = 66
          end>
      end
      object ComboBoxOptionMarkets: TComboBox
        Tag = 200
        Left = 49
        Top = 5
        Width = 131
        Height = 19
        Style = csOwnerDrawFixed
        ImeName = '???(??)'
        ItemHeight = 13
        TabOrder = 2
        OnChange = ComboBoxMarketsChange
      end
      object ComboBoxOptionMonths: TComboBox
        Tag = 700
        Left = 223
        Top = 5
        Width = 76
        Height = 19
        Style = csOwnerDrawFixed
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 13
        TabOrder = 3
        OnChange = ComboBoxMonthsChange
      end
    end
    object TabCombi: TTabSheet
      Caption = 'Spread'
      ImageIndex = 2
      TabVisible = False
      object Label3: TLabel
        Left = 10
        Top = 193
        Width = 33
        Height = 14
        Caption = '???? : '
        Visible = False
      end
      object Bevel3: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label5: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object ListCombiSymbols: TListView
        Left = 10
        Top = 256
        Width = 276
        Height = 69
        Columns = <
          item
            Caption = '??'
            Width = 98
          end
          item
            Caption = '???'
            Width = 142
          end>
        GridLines = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        Visible = False
        OnDblClick = SymbolDblClick
        OnDrawItem = ListDrawItem
        OnSelectItem = ListSelectItem
      end
      object ListViewSpread: TListView
        Left = 0
        Top = 30
        Width = 333
        Height = 270
        Align = alClient
        Columns = <
          item
            Caption = 'Code'
            Width = 98
          end
          item
            Caption = 'Description'
            Width = 172
          end>
        GridLines = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = SymbolDblClick
        OnDrawItem = ListDrawItem
        OnSelectItem = ListSelectItem
      end
      object ComboBoxSpreadMarkets: TComboBox
        Tag = 300
        Left = 49
        Top = 5
        Width = 131
        Height = 19
        Style = csOwnerDrawFixed
        Enabled = False
        ImeName = '???(??)'
        ItemHeight = 13
        TabOrder = 2
        OnChange = ComboBoxMarketsChange
      end
    end
    object TabIndex: TTabSheet
      Caption = 'Index'
      ImageIndex = 3
      TabVisible = False
      object Bevel6: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label4: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object ListViewIndex: TListView
        Left = 0
        Top = 30
        Width = 333
        Height = 270
        Align = alClient
        Columns = <
          item
            Caption = 'Code'
            Width = 98
          end
          item
            Caption = 'Description'
            Width = 172
          end>
        GridLines = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = SymbolDblClick
        OnDrawItem = ListDrawItem
        OnSelectItem = ListSelectItem
      end
      object ComboBoxIndexMarkets: TComboBox
        Tag = 400
        Left = 49
        Top = 5
        Width = 131
        Height = 19
        Style = csOwnerDrawFixed
        Enabled = False
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 13
        TabOrder = 1
        OnChange = ComboBoxMarketsChange
      end
    end
    object TabSheet1: TTabSheet
      Caption = 'Stock'
      ImageIndex = 4
      TabVisible = False
      object Bevel5: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label11: TLabel
        Left = 193
        Top = 8
        Width = 23
        Height = 14
        Caption = 'Find:'
      end
      object Label6: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object ListViewStock: TListView
        Left = 0
        Top = 30
        Width = 333
        Height = 270
        Align = alClient
        Columns = <
          item
            Caption = 'Code'
            Width = 98
          end
          item
            Caption = 'Description'
            Width = 172
          end>
        GridLines = True
        OwnerDraw = True
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = SymbolDblClick
        OnDrawItem = ListDrawItem
        OnSelectItem = ListSelectItem
      end
      object Edit1: TEdit
        Left = 221
        Top = 5
        Width = 104
        Height = 22
        ImeName = 'Korean Input System (IME 2000)'
        TabOrder = 1
      end
      object ComboBoxStockMarkets: TComboBox
        Tag = 500
        Left = 49
        Top = 5
        Width = 131
        Height = 19
        Style = csOwnerDrawFixed
        Enabled = False
        ImeName = '???(??)'
        ItemHeight = 13
        TabOrder = 2
        OnChange = ComboBoxMarketsChange
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'ELW'
      ImageIndex = 5
      TabVisible = False
      object Bevel4: TBevel
        Left = 0
        Top = 0
        Width = 333
        Height = 30
        Align = alTop
        Shape = bsSpacer
        ExplicitWidth = 369
      end
      object Label9: TLabel
        Left = 8
        Top = 8
        Width = 35
        Height = 14
        Caption = 'Market:'
      end
      object StringGridELWTrees: TStringGrid
        Tag = 800
        Left = 0
        Top = 30
        Width = 333
        Height = 170
        Align = alClient
        DefaultRowHeight = 15
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 15
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        ScrollBars = ssVertical
        TabOrder = 0
        OnDblClick = SymbolDblClick
        OnDrawCell = StringGridELWTreesDrawCell
        OnSelectCell = StringGridELWTreesSelectCell
        ColWidths = (
          94
          54
          52
          51
          51)
      end
      object ComboBoxELWMarkets: TComboBox
        Tag = 600
        Left = 49
        Top = 5
        Width = 131
        Height = 19
        Style = csOwnerDrawFixed
        ImeName = 'Korean Input System (IME 2000)'
        ItemHeight = 13
        TabOrder = 1
        OnChange = ComboBoxMarketsChange
      end
      object StringGridELWs: TStringGrid
        Tag = 800
        Left = 0
        Top = 200
        Width = 333
        Height = 100
        Align = alBottom
        ColCount = 4
        DefaultRowHeight = 15
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 15
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
        ScrollBars = ssVertical
        TabOrder = 2
        OnDblClick = SymbolDblClick
        OnDrawCell = StringGridELWsDrawCell
        OnSelectCell = StringGridELWsSelectCell
        ColWidths = (
          102
          116
          45
          40)
      end
      object RadioButtonCall: TRadioButton
        Left = 196
        Top = 7
        Width = 49
        Height = 17
        Caption = 'Call'
        Checked = True
        TabOrder = 3
        TabStop = True
        OnClick = RadioButtonCallPutClick
      end
      object RadioButtonPut: TRadioButton
        Left = 249
        Top = 7
        Width = 46
        Height = 17
        Caption = 'Put'
        TabOrder = 4
        OnClick = RadioButtonCallPutClick
      end
    end
  end
  object plSelected: TPanel
    Left = 0
    Top = 331
    Width = 345
    Height = 145
    BevelOuter = bvNone
    Caption = 'plSelected'
    TabOrder = 1
    object SpeedButtonRemove: TSpeedButton
      Tag = 200
      Left = 282
      Top = 71
      Width = 55
      Height = 22
      Caption = 'Del'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Glyph.Data = {
        36030000424D3603000000000000360000002800000010000000100000000100
        18000000000000030000120B0000120B00000000000000000000FF00FFFF00FF
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FF0732DE0732DEFF00FF0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE0732DEFF00FFFF00FF0732DE
        0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732
        DE0732DEFF00FFFF00FFFF00FF0732DE0732DD0732DE0732DEFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FF0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FF
        0534ED0732DF0732DE0732DEFF00FFFF00FFFF00FFFF00FF0732DE0732DEFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0732DE0732DE0732DDFF
        00FF0732DD0732DE0732DEFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FF0732DD0633E60633E60633E90732DCFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0633E307
        32E30534EFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FFFF00FFFF00FF0732DD0534ED0533E90434EF0434F5FF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0434F40534EF0533EBFF
        00FFFF00FF0434F40335F8FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF
        FF00FF0335FC0534EF0434F8FF00FFFF00FFFF00FFFF00FF0335FC0335FBFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FF0335FB0335FB0335FCFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FF0335FB0335FBFF00FFFF00FFFF00FFFF00FF0335FB
        0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FF0335FBFF00FFFF00FF0335FB0335FB0335FBFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF0335FB0335FB
        FF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00
        FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF
        00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FFFF00FF}
      ParentFont = False
      OnClick = ButtonMoveClick
    end
    object SpeedButton1: TSpeedButton
      Tag = 700
      Left = 282
      Top = 15
      Width = 55
      Height = 22
      Caption = 'Up'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333000333
        3333333333777F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333FF7F7FFFF333333000090000
        3333333777737777F333333099999990333333373F3333373333333309999903
        333333337F33337F33333333099999033333333373F333733333333330999033
        3333333337F337F3333333333099903333333333373F37333333333333090333
        33333333337F7F33333333333309033333333333337373333333333333303333
        333333333337F333333333333330333333333333333733333333}
      NumGlyphs = 2
      ParentFont = False
      OnClick = SymbolMove
    end
    object SpeedButton4: TSpeedButton
      Tag = 800
      Left = 282
      Top = 43
      Width = 55
      Height = 22
      Caption = 'Dn'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000120B0000120B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333303333
        333333333337F33333333333333033333333333333373F333333333333090333
        33333333337F7F33333333333309033333333333337373F33333333330999033
        3333333337F337F33333333330999033333333333733373F3333333309999903
        333333337F33337F33333333099999033333333373333373F333333099999990
        33333337FFFF3FF7F33333300009000033333337777F77773333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333309033333333333337F7F333333333333090333
        33333333337F7F33333333333300033333333333337773333333}
      NumGlyphs = 2
      ParentFont = False
      OnClick = SymbolMove
    end
    object SpeedButton3: TSpeedButton
      Tag = 300
      Left = 282
      Top = 99
      Width = 55
      Height = 22
      Caption = 'Clear'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = [fsBold]
      ParentFont = False
      OnClick = ButtonMoveClick
    end
    object Label1: TLabel
      Left = 8
      Top = 123
      Width = 45
      Height = 14
      Caption = 'Selected:'
    end
    object ListSelected: TListView
      Left = 3
      Top = 16
      Width = 260
      Height = 121
      Columns = <
        item
          Caption = 'Code'
          Width = 98
        end
        item
          Caption = 'Description'
          Width = 139
        end>
      ColumnClick = False
      GridLines = True
      OwnerDraw = True
      ReadOnly = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDblClick = ListSelectedDblClick
      OnDrawItem = ListDrawItem
      OnSelectItem = ListSelectedSelectItem
    end
  end
  object Panel1: TPanel
    Left = 0
    Top = 471
    Width = 341
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 2
    object ButtonHelp: TButton
      Left = 222
      Top = 11
      Width = 80
      Height = 24
      Caption = '&Help'
      TabOrder = 0
      OnClick = ButtonHelpClick
    end
    object ButtonCancel: TButton
      Left = 136
      Top = 11
      Width = 80
      Height = 24
      Caption = '&Cancel'
      TabOrder = 1
      OnClick = ButtonCancelClick
    end
    object ButtonOK: TButton
      Left = 50
      Top = 11
      Width = 80
      Height = 24
      Caption = '&OK'
      Default = True
      TabOrder = 2
      OnClick = ButtonOKClick
    end
  end
end
