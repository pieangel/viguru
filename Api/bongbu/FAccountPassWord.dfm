object FrmAccountPassWord: TFrmAccountPassWord
  Left = 0
  Top = 0
  Caption = #44228#51340' '#48708#48128#48264#54840' '#51077#47141
  ClientHeight = 409
  ClientWidth = 313
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 14
    Top = 380
    Width = 73
    Height = 19
    Caption = #51200#51109
    TabOrder = 0
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 234
    Top = 380
    Width = 73
    Height = 19
    Caption = #45803#44592
    ModalResult = 2
    TabOrder = 1
    OnClick = Button2Click
  end
  object sgAcnt: TStringGrid
    Left = 0
    Top = 0
    Width = 313
    Height = 369
    Align = alTop
    ColCount = 4
    Ctl3D = False
    DefaultRowHeight = 19
    DefaultDrawing = False
    FixedCols = 0
    RowCount = 2
    ParentCtl3D = False
    ScrollBars = ssVertical
    TabOrder = 2
    OnDrawCell = sgAcntDrawCell
    OnGetEditText = sgAcntGetEditText
    OnMouseDown = sgAcntMouseDown
    OnMouseUp = sgAcntMouseUp
    ColWidths = (
      22
      137
      97
      40)
  end
  object cbAll: TCheckBox
    Left = 5
    Top = 1
    Width = 16
    Height = 17
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 3
    OnClick = cbAllClick
  end
end
