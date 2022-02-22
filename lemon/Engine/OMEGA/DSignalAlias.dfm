object SignalAliasDialog: TSignalAliasDialog
  Left = 468
  Top = 239
  BorderStyle = bsDialog
  Caption = #49888#54840' '#49444#51221
  ClientHeight = 178
  ClientWidth = 270
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = #44404#47548
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  DesignSize = (
    270
    178)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 8
    Top = 8
    Width = 253
    Height = 126
    Shape = bsFrame
  end
  object Label1: TLabel
    Left = 42
    Top = 22
    Width = 38
    Height = 13
    Caption = #49888#54840' : '
  end
  object Label2: TLabel
    Left = 42
    Top = 51
    Width = 38
    Height = 13
    Caption = #51333#47785' : '
  end
  object Label3: TLabel
    Left = 17
    Top = 78
    Width = 63
    Height = 13
    Caption = 'Strategy : '
  end
  object Label5: TLabel
    Left = 42
    Top = 108
    Width = 38
    Height = 13
    Caption = #49444#47749' : '
    Enabled = False
  end
  object gEx: TGroupBox
    Left = 8
    Top = 138
    Width = 253
    Height = 65
    TabOrder = 6
    Visible = False
    object ButtonSymbol: TSpeedButton
      Left = 223
      Top = 35
      Width = 23
      Height = 22
      Caption = '...'
      Enabled = False
      Flat = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clBlue
      Font.Height = -13
      Font.Name = #44404#47548
      Font.Style = []
      ParentFont = False
      OnClick = ButtonSymbolClick
    end
    object Label4: TLabel
      Left = 34
      Top = 37
      Width = 38
      Height = 13
      Caption = #51333#47785' : '
      Enabled = False
    end
    object cbLinkSymbolUpdate: TCheckBox
      Left = 9
      Top = 13
      Width = 168
      Height = 17
      Caption = #49888#54840#50672#44208' '#51333#47785' '#51068#44292' '#49688#51221
      TabOrder = 0
      OnClick = cbLinkSymbolUpdateClick
    end
    object edtSymbol: TEdit
      Left = 72
      Top = 36
      Width = 147
      Height = 21
      Enabled = False
      ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
      TabOrder = 1
      OnChange = EditChange
    end
  end
  object EditAlias: TEdit
    Left = 80
    Top = 18
    Width = 170
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
    TabOrder = 0
  end
  object ButtonOK: TButton
    Left = 55
    Top = 145
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #54869' '#51064'(&O)'
    Default = True
    TabOrder = 4
    OnClick = ButtonOKClick
    ExplicitTop = 210
  end
  object Button2: TButton
    Left = 135
    Top = 145
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = #52712' '#49548'(&C)'
    ModalResult = 2
    TabOrder = 5
    ExplicitTop = 210
  end
  object EditStrategy: TEdit
    Left = 80
    Top = 74
    Width = 170
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
    TabOrder = 2
    OnChange = EditChange
  end
  object EditDescription: TEdit
    Left = 80
    Top = 103
    Width = 170
    Height = 21
    Enabled = False
    ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
    TabOrder = 3
  end
  object EditSymbol: TEdit
    Left = 80
    Top = 46
    Width = 170
    Height = 21
    ImeName = #54620#44397#50612'('#54620#44544') (MS-IME98)'
    TabOrder = 1
    OnChange = EditChange
  end
end
