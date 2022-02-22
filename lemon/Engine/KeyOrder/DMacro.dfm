object MacroDlg: TMacroDlg
  Left = 306
  Top = 198
  BorderStyle = bsDialog
  Caption = #47588#53356#47196' '#49444#51221
  ClientHeight = 299
  ClientWidth = 269
  Color = clBtnFace
  Font.Charset = HANGEUL_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 249
    Height = 249
    Shape = bsFrame
  end
  object BtnDelay: TSpeedButton
    Left = 192
    Top = 96
    Width = 23
    Height = 22
    Caption = '<-'
    OnClick = BtnDelayClick
  end
  object Label1: TLabel
    Left = 193
    Top = 68
    Width = 11
    Height = 13
    Caption = '0.'
  end
  object ButtonF2: TSpeedButton
    Left = 22
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F2'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF3: TSpeedButton
    Left = 56
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F3'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF4: TSpeedButton
    Left = 89
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F4'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF5: TSpeedButton
    Left = 123
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F5'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF6: TSpeedButton
    Left = 157
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F6'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF7: TSpeedButton
    Left = 191
    Top = 13
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F7'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF8: TSpeedButton
    Left = 31
    Top = 35
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F8'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF9: TSpeedButton
    Left = 65
    Top = 35
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F9'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF10: TSpeedButton
    Left = 99
    Top = 35
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F10'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF11: TSpeedButton
    Left = 133
    Top = 35
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F11'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object ButtonF12: TSpeedButton
    Left = 166
    Top = 35
    Width = 33
    Height = 22
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'F12'
    Flat = True
    NumGlyphs = 4
    OnClick = ButtonFunctionKeyClick
  end
  object OKBtn: TButton
    Left = 60
    Top = 264
    Width = 75
    Height = 25
    Caption = #54869#51064'(&O)'
    TabOrder = 0
    OnClick = OKBtnClick
  end
  object CancelBtn: TButton
    Left = 140
    Top = 264
    Width = 75
    Height = 25
    Cancel = True
    Caption = #52712#49548'(&C)'
    ModalResult = 2
    TabOrder = 1
  end
  object SpinEditTime: TSpinEdit
    Left = 208
    Top = 64
    Width = 33
    Height = 22
    MaxLength = 1
    MaxValue = 9
    MinValue = 1
    TabOrder = 2
    Value = 9
  end
  object ListKey: TListView
    Left = 16
    Top = 62
    Width = 169
    Height = 187
    Columns = <
      item
        Caption = 'Key'
        Width = 45
      end
      item
        Caption = 'Action'
        Width = 90
      end>
    GridLines = True
    OwnerDraw = True
    ReadOnly = True
    RowSelect = True
    SmallImages = ImageList1
    TabOrder = 3
    ViewStyle = vsReport
    OnDrawItem = ListKeyDrawItem
    OnKeyDown = ListKeyKeyDown
    OnSelectItem = ListKeySelectItem
  end
  object ImageList1: TImageList
    Left = 80
    Top = 152
  end
end
