object FrmSyncthesize: TFrmSyncthesize
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = #51333#54633#51452#47928
  ClientHeight = 1036
  ClientWidth = 382
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object plSymbolAcnt: TPanel
    Left = 0
    Top = 0
    Width = 382
    Height = 28
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 0
    object ButtonSymbol: TSpeedButton
      Left = 256
      Top = 2
      Width = 23
      Height = 19
      Caption = '...'
      OnClick = ButtonSymbolClick
    end
    object ComboAccount: TComboBox
      Left = 1
      Top = 2
      Width = 137
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboAccountChange
    end
    object ComboSymbol: TComboBox
      Left = 145
      Top = 2
      Width = 105
      Height = 19
      Style = csOwnerDrawFixed
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 1
      OnChange = ComboSymbolChange
    end
    object btnConfig: TButton
      Left = 281
      Top = 2
      Width = 53
      Height = 19
      Caption = #49444#51221
      TabOrder = 2
      OnClick = btnConfigClick
    end
  end
  object plProtectedOrder: TPanel
    Left = 0
    Top = 759
    Width = 382
    Height = 279
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 1
    inline FraProtectedOrder: TFraProtectedOrder
      Left = 2
      Top = 2
      Width = 374
      Height = 271
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 374
      ExplicitHeight = 271
      inherited plLeft: TPanel
        Width = 374
        ExplicitWidth = 374
        inherited plSide: TPanel
          Width = 372
          ExplicitWidth = 372
          inherited GroupBox1: TGroupBox
            inherited btnShow: TSpeedButton
              OnClick = FraProtectedOrderbtnShowClick
            end
          end
        end
        inherited plCenter: TPanel
          Width = 372
          ExplicitWidth = 372
          inherited btnExpand: TSpeedButton
            Width = 370
            OnClick = FraBullbtnExpandClick
            ExplicitWidth = 370
          end
        end
      end
      inherited plRight: TPanel
        Width = 374
        Height = 160
        ExplicitWidth = 374
        ExplicitHeight = 160
      end
    end
  end
  object plSCatch: TPanel
    Left = 0
    Top = 600
    Width = 382
    Height = 159
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 2
    inline FraSCatchOrder: TFraSCatchOrder
      Left = 2
      Top = 2
      Width = 374
      Height = 151
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 374
      ExplicitHeight = 151
      inherited plLeft: TPanel
        Width = 374
        ExplicitWidth = 374
        inherited btnExpand: TSpeedButton
          Width = 372
          OnClick = FraBullbtnExpandClick
          ExplicitWidth = 420
        end
      end
      inherited plRight: TPanel
        Width = 374
        Height = 85
        ExplicitWidth = 374
        ExplicitHeight = 85
        inherited sgInfo: TStringGrid
          Width = 372
          Height = 83
          ExplicitWidth = 372
          ExplicitHeight = 83
        end
      end
    end
  end
  object plFrontQuoting: TPanel
    Left = 0
    Top = 343
    Width = 382
    Height = 257
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 3
    inline FraFrontQuoting: TFraFrontQuoting
      Left = 2
      Top = 2
      Width = 374
      Height = 249
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      OnClick = FraBullbtnExpandClick
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 374
      ExplicitHeight = 249
      inherited Panel1: TPanel
        Width = 374
        Height = 249
        ExplicitWidth = 374
        ExplicitHeight = 249
        inherited plLeft: TPanel
          Width = 372
          ExplicitWidth = 372
          inherited btnExpand: TSpeedButton
            Width = 370
            OnClick = FraBullbtnExpandClick
            ExplicitWidth = 370
          end
        end
        inherited plRight: TPanel
          Width = 372
          Height = 122
          ExplicitWidth = 372
          ExplicitHeight = 122
          inherited Panel6: TPanel
            Width = 370
            ExplicitWidth = 370
          end
          inherited Panel7: TPanel
            Width = 370
            Height = 96
            ExplicitWidth = 370
            ExplicitHeight = 96
            inherited listOrder: TListView
              Width = 368
              Height = 94
              ExplicitWidth = 368
              ExplicitHeight = 94
            end
          end
        end
      end
    end
  end
  object plOrderManager: TPanel
    Left = 0
    Top = 238
    Width = 382
    Height = 105
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    TabOrder = 4
    inline FraOrderManage: TFraOrderManage
      Left = 2
      Top = 2
      Width = 374
      Height = 97
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 374
      ExplicitHeight = 97
      inherited plLeft: TPanel
        Width = 374
        ExplicitWidth = 374
        inherited gbOrder: TGroupBox
          ParentFont = False
        end
        inherited gbPos: TGroupBox
          ParentFont = False
        end
        inherited stBar: TStatusBar
          Width = 372
          ExplicitWidth = 372
        end
      end
      inherited plRight: TPanel
        Width = 374
        Height = 4
        ExplicitWidth = 374
        ExplicitHeight = 4
        inherited GroupBox1: TGroupBox
          Width = 372
          ExplicitWidth = 372
        end
      end
    end
  end
  object plBull: TPanel
    Left = 0
    Top = 28
    Width = 382
    Height = 210
    Align = alTop
    BevelInner = bvLowered
    BevelKind = bkSoft
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    TabOrder = 5
    inline FraBull: TFraBull
      Left = 2
      Top = 2
      Width = 374
      Height = 202
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 2
      ExplicitTop = 2
      ExplicitWidth = 374
      ExplicitHeight = 202
      inherited Panel1: TPanel
        Width = 374
        Height = 202
        ExplicitWidth = 374
        ExplicitHeight = 202
        inherited plLeft: TPanel
          Width = 372
          ExplicitWidth = 372
          inherited Panel2: TPanel
            Width = 370
            ExplicitWidth = 370
            inherited btnExpand: TSpeedButton
              Width = 368
              OnClick = FraBullbtnExpandClick
              ExplicitWidth = 416
            end
            inherited TabConfig: TTabControl
              Width = 368
              ExplicitWidth = 368
            end
            inherited StatusTrade: TStatusBar
              Width = 368
              ExplicitWidth = 368
            end
          end
        end
        inherited plRight: TPanel
          Width = 372
          Height = 70
          ExplicitWidth = 372
          ExplicitHeight = 70
          inherited GridInfo: TStringGrid
            Width = 370
            Height = 68
            ExplicitWidth = 370
            ExplicitHeight = 68
          end
        end
      end
    end
  end
end
