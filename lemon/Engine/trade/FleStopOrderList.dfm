object FrmStopOrderList: TFrmStopOrderList
  Left = 0
  Top = 0
  Caption = #49828#53457#51452#47928#45236#50669
  ClientHeight = 214
  ClientWidth = 405
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
    Width = 405
    Height = 26
    Align = alTop
    TabOrder = 0
    object Label1: TLabel
      Left = 8
      Top = 7
      Width = 27
      Height = 13
      Caption = #44228#51340' '
    end
    object cbAccount: TComboBox
      Left = 38
      Top = 2
      Width = 145
      Height = 21
      Style = csDropDownList
      Ctl3D = False
      ImeName = 'Microsoft IME 2003'
      ItemHeight = 13
      ParentCtl3D = False
      TabOrder = 0
      OnChange = cbAccountChange
    end
  end
  object sgStop: TStringGrid
    Left = 0
    Top = 26
    Width = 405
    Height = 188
    Align = alClient
    ColCount = 7
    Ctl3D = False
    DefaultRowHeight = 17
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    TabOrder = 1
    OnDrawCell = sgStopDrawCell
    OnMouseDown = sgStopMouseDown
    ColWidths = (
      67
      35
      64
      41
      66
      42
      64)
  end
end
