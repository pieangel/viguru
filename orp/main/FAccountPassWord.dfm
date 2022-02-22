object FrmAccountPassWord: TFrmAccountPassWord
  Left = 0
  Top = 0
  Caption = #44228#51340' '#48708#48128#48264#54840' '#51077#47141
  ClientHeight = 369
  ClientWidth = 321
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 338
    Width = 321
    Height = 31
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      321
      31)
    object Button1: TButton
      Left = 4
      Top = 6
      Width = 68
      Height = 19
      Anchors = [akBottom]
      Caption = #51200#51109
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 248
      Top = 7
      Width = 73
      Height = 19
      Anchors = [akBottom]
      Caption = #45803#44592
      ModalResult = 2
      TabOrder = 1
      OnClick = Button2Click
    end
    object CheckBox1: TCheckBox
      Left = 112
      Top = 8
      Width = 97
      Height = 17
      Caption = #44228#51340#48708#48264#48372#44592
      TabOrder = 2
      OnClick = CheckBox1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 321
    Height = 338
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    OnResize = Panel2Resize
    object sgAcnt: TStringGrid
      Left = 0
      Top = 0
      Width = 321
      Height = 338
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultRowHeight = 19
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = sgAcntDrawCell
      OnGetEditText = sgAcntGetEditText
      OnMouseDown = sgAcntMouseDown
      OnMouseUp = sgAcntMouseUp
      OnTopLeftChanged = sgAcntTopLeftChanged
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
      TabOrder = 1
      OnClick = cbAllClick
    end
  end
end
