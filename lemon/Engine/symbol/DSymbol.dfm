object SymbolDialog: TSymbolDialog
  Left = 430
  Top = 136
  BorderStyle = bsDialog
  Caption = #51333#47785#49440#53469
  ClientHeight = 412
  ClientWidth = 568
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label4: TLabel
    Left = 292
    Top = 11
    Width = 64
    Height = 13
    Caption = #49440#53469#51333#47785' : '
  end
  object ButtonSelect: TSpeedButton
    Tag = 100
    Left = 257
    Top = 128
    Width = 27
    Height = 25
    Caption = '>'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonMoveClick
  end
  object ButtonUnselect: TSpeedButton
    Tag = 200
    Left = 257
    Top = 161
    Width = 27
    Height = 25
    Caption = '<'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonMoveClick
  end
  object SpeedButton3: TSpeedButton
    Tag = 300
    Left = 257
    Top = 194
    Width = 28
    Height = 26
    Caption = '<<'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -13
    Font.Name = #44404#47548
    Font.Style = [fsBold]
    ParentFont = False
    OnClick = ButtonMoveClick
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 250
    Height = 412
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 0
    object PageTypes: TPageControl
      Tag = 300
      Left = 0
      Top = 32
      Width = 250
      Height = 343
      ActivePage = TabOptions
      Align = alClient
      TabOrder = 0
      TabWidth = 61
      OnChange = PageTypesChange
      object TabFutures: TTabSheet
        Caption = #49440#47932
        object Bevel1: TBevel
          Left = 0
          Top = 0
          Width = 242
          Height = 33
          Align = alTop
          Shape = bsSpacer
        end
        object Label8: TLabel
          Left = 7
          Top = 12
          Width = 64
          Height = 13
          Caption = #44592#52488#51088#49328' : '
        end
        object ComboFutUnders: TComboBox
          Tag = 100
          Left = 71
          Top = 8
          Width = 106
          Height = 19
          Style = csOwnerDrawFixed
          Enabled = False
          ImeName = #54620#44397#50612'('#54620#44544')'
          ItemHeight = 13
          TabOrder = 0
          OnChange = ComboBoxMarketsChange
        end
        object ListFutures: TListView
          Left = 0
          Top = 33
          Width = 242
          Height = 282
          Align = alClient
          Columns = <
            item
              Caption = #53076#46300
              Width = 80
            end
            item
              Caption = #51333#47785#47749
              Width = 140
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
      end
      object TabOptions: TTabSheet
        Caption = #50741#49496
        ImageIndex = 1
        object Label2: TLabel
          Left = 7
          Top = 12
          Width = 64
          Height = 13
          Caption = #44592#52488#51088#49328' : '
        end
        object Bevel2: TBevel
          Left = 0
          Top = 0
          Width = 242
          Height = 33
          Align = alTop
          Shape = bsSpacer
        end
        object GridOptions: TStringGrid
          Left = 0
          Top = 50
          Width = 242
          Height = 265
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
          OnDrawCell = GridOptionsDrawCell
          OnSelectCell = GridOptionsSelectCell
          ExplicitLeft = 5
          ExplicitTop = 48
          ColWidths = (
            69
            81
            65)
        end
        object HeaderControl2: THeaderControl
          Left = 0
          Top = 33
          Width = 242
          Height = 17
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
              Text = #54665#49324#44032
              Width = 82
            end
            item
              Alignment = taCenter
              ImageIndex = -1
              Text = 'Put'
              Width = 66
            end>
        end
        object ComboOptUnders: TComboBox
          Left = 71
          Top = 8
          Width = 96
          Height = 19
          Style = csOwnerDrawFixed
          ImeName = #54620#44397#50612'('#54620#44544')'
          ItemHeight = 13
          TabOrder = 2
          OnChange = ComboBoxMarketsChange
        end
        object ComboOptMonths: TComboBox
          Left = 169
          Top = 8
          Width = 62
          Height = 19
          Style = csOwnerDrawFixed
          ImeName = #54620#44397#50612'('#54620#44544')'
          ItemHeight = 13
          TabOrder = 3
          OnChange = ComboBoxMonthsChange
        end
      end
      object TabCombi: TTabSheet
        Caption = #49828#54532#47112#46300
        ImageIndex = 2
        object Label3: TLabel
          Left = 8
          Top = 157
          Width = 64
          Height = 13
          Caption = #44396#49457#51333#47785' : '
          Visible = False
        end
        object Bevel3: TBevel
          Left = 0
          Top = 0
          Width = 242
          Height = 33
          Align = alTop
          Shape = bsSpacer
        end
        object Label5: TLabel
          Left = 7
          Top = 12
          Width = 64
          Height = 13
          Caption = #44592#52488#51088#49328' : '
        end
        object ListCombiSymbols: TListView
          Left = 8
          Top = 208
          Width = 224
          Height = 56
          Columns = <
            item
              Caption = #53076#46300
              Width = 80
            end
            item
              Caption = #51333#47785#47749
              Width = 115
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
        object ListCombi: TListView
          Left = 0
          Top = 33
          Width = 242
          Height = 282
          Align = alClient
          Columns = <
            item
              Caption = #53076#46300
              Width = 80
            end
            item
              Caption = #51333#47785#47749
              Width = 140
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
        object ComboSpreadUnders: TComboBox
          Left = 71
          Top = 8
          Width = 106
          Height = 19
          Style = csOwnerDrawFixed
          Enabled = False
          ImeName = #54620#44397#50612'('#54620#44544')'
          ItemHeight = 13
          TabOrder = 2
          OnChange = ComboBoxMarketsChange
        end
      end
      object TabIndex: TTabSheet
        Caption = #51648#49688'/'#51452#49885
        ImageIndex = 3
        object ListIndex: TListView
          Left = 0
          Top = 0
          Width = 242
          Height = 315
          Align = alClient
          Columns = <
            item
              Caption = #53076#46300
              Width = 80
            end
            item
              Caption = #51333#47785#47749
              Width = 140
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
      end
    end
    object Panel1: TPanel
      Left = 0
      Top = 0
      Width = 250
      Height = 32
      Align = alTop
      TabOrder = 1
      object Label1: TLabel
        Left = 9
        Top = 9
        Width = 38
        Height = 13
        Caption = #49440#53469' : '
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ParentFont = False
      end
      object EditSelected: TEdit
        Left = 48
        Top = 5
        Width = 195
        Height = 21
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -13
        Font.Name = #44404#47548
        Font.Style = []
        ImeName = #54620#44397#50612'('#54620#44544')'
        ParentFont = False
        ReadOnly = True
        TabOrder = 0
      end
    end
    object Panel3: TPanel
      Left = 0
      Top = 375
      Width = 250
      Height = 37
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object ButtonOK: TButton
        Left = 10
        Top = 7
        Width = 70
        Height = 25
        Caption = #54869#51064'(&O)'
        Default = True
        TabOrder = 0
        OnClick = ButtonOKClick
      end
      object ButtonCancel: TButton
        Left = 90
        Top = 7
        Width = 70
        Height = 25
        Caption = #52712#49548'(&C)'
        TabOrder = 1
        OnClick = ButtonCancelClick
      end
      object ButtonHelp: TButton
        Left = 170
        Top = 7
        Width = 70
        Height = 25
        Caption = #46020#50880#47568'(&H)'
        TabOrder = 2
        OnClick = ButtonHelpClick
      end
    end
  end
  object ListSelected: TListView
    Left = 291
    Top = 32
    Width = 265
    Height = 343
    Columns = <
      item
        Caption = #53076#46300
        Width = 80
      end
      item
        Caption = #51333#47785#47749
        Width = 165
      end>
    ColumnClick = False
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
    OnDblClick = ListSelectedDblClick
    OnDrawItem = ListDrawItem
    OnSelectItem = ListSelectedSelectItem
  end
  object BtnUp: TButton
    Tag = 700
    Left = 322
    Top = 382
    Width = 95
    Height = 25
    Caption = #50948#47196' '#51060#46041'(&U)'
    TabOrder = 2
    OnClick = SymbolMove
  end
  object BtnDown: TButton
    Tag = 800
    Left = 426
    Top = 382
    Width = 95
    Height = 25
    Caption = #50500#47000#47196' '#51060#46041'(&D)'
    TabOrder = 3
    OnClick = SymbolMove
  end
end
