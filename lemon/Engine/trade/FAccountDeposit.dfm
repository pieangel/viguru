object FrmAccountDeposit: TFrmAccountDeposit
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #50696#53441#51092#44256' '#48143' '#51613#44144#44552
  ClientHeight = 169
  ClientWidth = 379
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
  object PageControl1: TPageControl
    Left = 0
    Top = 0
    Width = 379
    Height = 169
    ActivePage = tsDeposit
    Align = alClient
    TabOrder = 0
    OnChange = PageControl1Change
    object tsDeposit: TTabSheet
      Caption = #50696#53441#51092#44256' '#48143' '#51613#44144#44552
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 371
        Height = 27
        Align = alTop
        BevelInner = bvLowered
        TabOrder = 0
        object Botton2: TSpeedButton
          Left = 325
          Top = 2
          Width = 34
          Height = 22
          Caption = #51312#54924
          OnClick = Botton2Click
        end
        object cbAccount: TComboBox
          Left = 6
          Top = 3
          Width = 187
          Height = 21
          Style = csDropDownList
          ImeName = 'Microsoft IME 2010'
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbAccountChange
        end
        object Button1: TButton
          Left = 267
          Top = 2
          Width = 52
          Height = 21
          Caption = '+'#51613#44144#44552
          TabOrder = 1
          OnClick = Button1Click
        end
      end
      object Panel2: TPanel
        Left = 0
        Top = 27
        Width = 371
        Height = 65
        Align = alTop
        BevelInner = bvLowered
        TabOrder = 1
        object sgPL: TStringGrid
          Left = 2
          Top = 2
          Width = 367
          Height = 61
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultColWidth = 90
          DefaultRowHeight = 19
          DefaultDrawing = False
          FixedCols = 0
          RowCount = 3
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          OnDrawCell = sgPLDrawCell
        end
      end
      object Panel3: TPanel
        Left = 0
        Top = 92
        Width = 371
        Height = 46
        Align = alTop
        BevelInner = bvLowered
        TabOrder = 2
        Visible = False
        object sgMargin: TStringGrid
          Tag = 1
          Left = 2
          Top = 2
          Width = 367
          Height = 42
          Align = alClient
          ColCount = 4
          Ctl3D = False
          DefaultColWidth = 90
          DefaultRowHeight = 19
          DefaultDrawing = False
          FixedCols = 0
          RowCount = 2
          FixedRows = 0
          ParentCtl3D = False
          TabOrder = 0
          OnDrawCell = sgPLDrawCell
        end
      end
    end
    object tsAbleQty: TTabSheet
      Caption = #51452#47928#44032#45733#49688#47049
      ImageIndex = 1
      object Label1: TLabel
        Left = 6
        Top = 33
        Width = 48
        Height = 13
        Caption = #44144#47000#44396#48516
      end
      object Label2: TLabel
        Left = 6
        Top = 55
        Width = 48
        Height = 13
        Caption = #51333#47785#53076#46300
      end
      object Label3: TLabel
        Left = 9
        Top = 82
        Width = 48
        Height = 13
        Caption = #55148#47581#44032#44201
      end
      object Label4: TLabel
        Left = 9
        Top = 108
        Width = 48
        Height = 13
        Caption = #51452#47928#50976#54805
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 371
        Height = 27
        Align = alTop
        BevelInner = bvLowered
        TabOrder = 0
        object cbAccount2: TComboBox
          Left = 6
          Top = 4
          Width = 187
          Height = 21
          Style = csDropDownList
          ImeName = 'Microsoft IME 2010'
          ItemHeight = 13
          TabOrder = 0
          OnChange = cbAccount2Change
        end
        object Button4: TButton
          Left = 325
          Top = 3
          Width = 41
          Height = 21
          Caption = #51312#54924
          TabOrder = 1
          OnClick = Button4Click
        end
      end
      object rbS: TRadioButton
        Left = 65
        Top = 31
        Width = 48
        Height = 17
        Caption = #47588#46020
        TabOrder = 1
      end
      object rbL: TRadioButton
        Left = 114
        Top = 31
        Width = 48
        Height = 17
        Caption = #47588#49688
        Checked = True
        TabOrder = 2
        TabStop = True
      end
      object cbSymbol: TComboBox
        Left = 65
        Top = 52
        Width = 95
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        TabOrder = 3
        OnChange = cbSymbolChange
      end
      object Button3: TButton
        Left = 164
        Top = 52
        Width = 25
        Height = 19
        Caption = '...'
        TabOrder = 4
        OnClick = Button3Click
      end
      object Edit1: TEdit
        Left = 65
        Top = 79
        Width = 81
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
      end
      object sgResult: TStringGrid
        Tag = 1
        Left = 165
        Top = 86
        Width = 203
        Height = 41
        ColCount = 2
        Ctl3D = False
        DefaultColWidth = 100
        DefaultRowHeight = 19
        DefaultDrawing = False
        RowCount = 2
        FixedRows = 0
        ParentCtl3D = False
        TabOrder = 6
        OnDrawCell = sgPLDrawCell
        RowHeights = (
          19
          19)
      end
      object cbPriceControl: TComboBox
        Left = 65
        Top = 106
        Width = 81
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 13
        ItemIndex = 0
        TabOrder = 7
        Text = #51648#51221#44032' '
        Items.Strings = (
          #51648#51221#44032' '
          #49884#51109#44032' '
          #51312#44148#48512#51648#51221#44032' '
          #52572#50976#47532#51648#51221#44032
          #51648#51221#44032'(IOC)'
          #51648#51221#44032'(FOK)')
      end
    end
  end
end
