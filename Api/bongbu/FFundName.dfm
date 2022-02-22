object FrmFundName: TFrmFundName
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FrmFundName'
  ClientHeight = 88
  ClientWidth = 216
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  PixelsPerInch = 96
  TextHeight = 13
  object edtFundName: TLabeledEdit
    Left = 24
    Top = 24
    Width = 161
    Height = 21
    EditLabel.Width = 48
    EditLabel.Height = 13
    EditLabel.Caption = #54144#46300#51060#47492
    ImeName = 'Microsoft IME 2010'
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 24
    Top = 51
    Width = 75
    Height = 21
    Caption = #54869#51064
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 110
    Top = 51
    Width = 75
    Height = 21
    Caption = #52712#49548
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
