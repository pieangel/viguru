object FrmQuoteResearch: TFrmQuoteResearch
  Left = 0
  Top = 0
  Caption = #46041#49884' '#52712#49548#51452#47928' '#44160#49353#52285
  ClientHeight = 441
  ClientWidth = 341
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
    Width = 341
    Height = 51
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 34
      Height = 13
      Caption = #51333#47785' : '
    end
    object Label2: TLabel
      Left = 241
      Top = 28
      Width = 48
      Height = 13
      Caption = #45572#51201#49688#47049
    end
    object Label3: TLabel
      Left = 253
      Top = 6
      Width = 12
      Height = 13
      Caption = #52488
    end
    object cbSymbol: TComboBox
      Left = 40
      Top = 2
      Width = 109
      Height = 21
      BevelInner = bvNone
      BevelOuter = bvNone
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbSymbolChange
    end
    object btnSymbol: TButton
      Left = 154
      Top = 2
      Width = 31
      Height = 20
      Caption = '...'
      TabOrder = 1
      OnClick = btnSymbolClick
    end
    object edtQty: TEdit
      Left = 172
      Top = 26
      Width = 34
      Height = 19
      Hint = #51452#47928#49688#47049
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 2
      Text = '10'
      OnChange = edtQtyChange
      OnKeyPress = edtSecKeyPress
    end
    object edtCnt: TEdit
      Left = 209
      Top = 26
      Width = 23
      Height = 19
      Hint = #51452#47928#44148#49688
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 3
      Text = '3'
      OnChange = edtQtyChange
      OnKeyPress = edtSecKeyPress
    end
    object edtSec: TEdit
      Left = 212
      Top = 3
      Width = 35
      Height = 19
      Hint = 'TimeOut'
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 4
      Text = '1000'
      OnChange = edtQtyChange
      OnKeyPress = edtSecKeyPress
    end
    object cbAsc: TCheckBox
      Left = 284
      Top = 3
      Width = 43
      Height = 17
      Hint = #49884#44036#50724#47492#52264#49692
      Caption = #50724#47492
      ParentShowHint = False
      ShowHint = True
      TabOrder = 5
      OnClick = cbAscClick
    end
    object edtTotQty: TEdit
      Left = 292
      Top = 25
      Width = 35
      Height = 19
      Hint = #52509#44148#49688
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ParentCtl3D = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 6
      Text = '100'
      OnChange = edtQtyChange
      OnKeyPress = edtSecKeyPress
    end
    object Button1: TButton
      Left = 6
      Top = 25
      Width = 43
      Height = 25
      Caption = 'Log'
      TabOrder = 7
      OnClick = Button1Click
    end
  end
  object sgInfo: TStringGrid
    Left = 0
    Top = 51
    Width = 341
    Height = 390
    Align = alClient
    ColCount = 4
    Ctl3D = False
    DefaultRowHeight = 16
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 1
    FixedRows = 0
    Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing]
    ParentCtl3D = False
    TabOrder = 1
    OnDblClick = sgInfoDblClick
    OnDrawCell = sgInfoDrawCell
    OnMouseDown = sgInfoMouseDown
    ColWidths = (
      68
      51
      46
      162)
  end
  object tmflash: TTimer
    OnTimer = tmflashTimer
    Left = 104
    Top = 208
  end
end
