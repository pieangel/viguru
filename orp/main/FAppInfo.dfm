object FrmAppInfo: TFrmAppInfo
  Left = 0
  Top = 0
  Caption = #44228#51340#44288#47532
  ClientHeight = 300
  ClientWidth = 671
  Color = clBtnFace
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #44404#47548#52404
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object AppPage: TPageControl
    Left = 0
    Top = 0
    Width = 671
    Height = 280
    ActivePage = tsAccount
    Align = alClient
    TabOrder = 0
    OnChange = AppPageChange
    object tsLog: TTabSheet
      Caption = 'Log'
      object LogPage: TPageControl
        Left = 0
        Top = 0
        Width = 663
        Height = 21
        Align = alTop
        TabOrder = 0
        OnChange = LogPageChange
      end
      object lvLog: TListView
        Left = 0
        Top = 21
        Width = 663
        Height = 231
        Align = alClient
        Columns = <
          item
            Caption = 'Time'
            Width = 100
          end
          item
            Caption = 'Source'
            Width = 100
          end
          item
            Caption = 'Title'
            Width = 100
          end
          item
            Caption = 'Description'
            Width = 400
          end
          item
            Alignment = taRightJustify
          end>
        OwnerData = True
        OwnerDraw = True
        TabOrder = 1
        ViewStyle = vsReport
        OnData = lvLogData
        OnDrawItem = lvLogDrawItem
      end
    end
    object tsAccount: TTabSheet
      Caption = #49436#48652#44228#51340' '#44288#47532
      ImageIndex = 1
      object lvAcnt: TListView
        Left = 261
        Top = 0
        Width = 402
        Height = 252
        Align = alClient
        Columns = <
          item
            Caption = #49436#48652#44228#51340#53076#46300
            Width = 100
          end
          item
            Caption = #49436#48652#44228#51340#47749
            Width = 100
          end
          item
            Alignment = taCenter
            Caption = #44396#48516
            Tag = 4
            Width = 60
          end>
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        OwnerData = True
        OwnerDraw = True
        ParentFont = False
        PopupMenu = PopupMenu1
        TabOrder = 0
        ViewStyle = vsReport
        OnClick = lvAcntClick
        OnData = lvAcntData
        OnDrawItem = lvLogDrawItem
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 261
        Height = 252
        Align = alLeft
        BevelOuter = bvNone
        Font.Charset = ANSI_CHARSET
        Font.Color = clPurple
        Font.Height = -12
        Font.Name = #44404#47548#52404
        Font.Style = []
        ParentColor = True
        ParentFont = False
        TabOrder = 1
        object lvInvest: TListView
          Left = 0
          Top = 0
          Width = 261
          Height = 161
          Align = alTop
          Columns = <
            item
              Caption = #44228#51340
              Width = 100
            end
            item
              Caption = #44228#51340#47749
              Width = 100
            end
            item
              Alignment = taRightJustify
              Caption = #44396#48516
              Tag = 4
            end>
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #44404#47548#52404
          Font.Style = []
          OwnerData = True
          OwnerDraw = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
          OnClick = lvInvestClick
          OnData = lvInvestData
          OnDrawItem = lvLogDrawItem
        end
        object edtAcntCode: TLabeledEdit
          Left = 88
          Top = 171
          Width = 92
          Height = 20
          EditLabel.Width = 72
          EditLabel.Height = 12
          EditLabel.Caption = #49436#48652#44228#51340#53076#46300
          ImeName = 'Microsoft IME 2010'
          LabelPosition = lpLeft
          TabOrder = 1
        end
        object edtAcntName: TLabeledEdit
          Left = 88
          Top = 197
          Width = 92
          Height = 20
          EditLabel.Width = 60
          EditLabel.Height = 12
          EditLabel.Caption = #49436#48652#44228#51340#47749
          ImeName = 'Microsoft IME 2010'
          LabelPosition = lpLeft
          TabOrder = 2
        end
        object Add: TButton
          Left = 209
          Top = 197
          Width = 46
          Height = 21
          Caption = #49373#49457
          TabOrder = 3
          OnClick = AddClick
        end
        object btnApply: TButton
          Left = 209
          Top = 226
          Width = 46
          Height = 21
          Hint = #54872#44221#54028#51068#50640#51200#51109
          Caption = #51200#51109
          ParentShowHint = False
          ShowHint = True
          TabOrder = 4
          OnClick = btnApplyClick
        end
        object btnCancel: TButton
          Left = 117
          Top = 226
          Width = 46
          Height = 21
          Caption = #45803#44592
          TabOrder = 5
          OnClick = btnCancelClick
        end
        object btnOK: TButton
          Left = 24
          Top = 226
          Width = 46
          Height = 21
          Caption = #54869#51064
          TabOrder = 6
          OnClick = btnOKClick
        end
        object edtUpdate: TButton
          Left = 209
          Top = 171
          Width = 46
          Height = 21
          Caption = #49688#51221
          TabOrder = 7
          OnClick = edtUpdateClick
        end
      end
    end
    object tsFund: TTabSheet
      Caption = #45796#44228#51340' '#44288#47532
      ImageIndex = 2
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 222
        Height = 252
        Align = alLeft
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 0
        object tvFund: TTreeView
          Left = 0
          Top = 32
          Width = 222
          Height = 220
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = #44404#47548#52404
          Font.Style = []
          Indent = 19
          ParentFont = False
          ReadOnly = True
          TabOrder = 0
          OnChange = tvFundChange
        end
        object Panel8: TPanel
          Left = 0
          Top = 0
          Width = 222
          Height = 32
          Align = alTop
          BevelOuter = bvLowered
          TabOrder = 1
          object ButtonFundCfg: TSpeedButton
            Left = 144
            Top = 6
            Width = 71
            Height = 22
            Hint = #54144#46300#49444#51221
            Caption = #45796#44228#51340' '#49444#51221
            Flat = True
            ParentShowHint = False
            ShowHint = True
            OnClick = ButtonFundCfgClick
          end
          object btnNew: TButton
            Left = 6
            Top = 6
            Width = 83
            Height = 20
            Caption = #49352' '#45796#44228#51340
            TabOrder = 0
            OnClick = btnNewClick
          end
        end
      end
      object Panel5: TPanel
        Left = 222
        Top = 0
        Width = 441
        Height = 252
        Align = alClient
        BevelOuter = bvLowered
        Caption = 'Panel5'
        TabOrder = 1
        object ListViewFundList: TListView
          Left = 1
          Top = 32
          Width = 439
          Height = 219
          Align = alClient
          Columns = <
            item
              Caption = #44228#51340#48264#54840
              Width = 100
            end
            item
              Caption = #44228#51340#47749
              Width = 120
            end
            item
              Caption = #49849#49688
            end>
          DragMode = dmAutomatic
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = #44404#47548
          Font.Style = []
          GridLines = True
          OwnerDraw = True
          ReadOnly = True
          RowSelect = True
          ParentFont = False
          TabOrder = 0
          ViewStyle = vsReport
          OnDrawItem = ListViewFundListDrawItem
        end
        object PanelFundTitle: TPanel
          Left = 1
          Top = 1
          Width = 439
          Height = 31
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object btnReName: TButton
            Left = 5
            Top = 5
            Width = 85
            Height = 20
            Caption = #45796#44228#51340#47749' '#48320#44221
            TabOrder = 0
            OnClick = btnReNameClick
          end
          object btnRemove: TButton
            Left = 96
            Top = 5
            Width = 73
            Height = 20
            Caption = #45796#44228#51340' '#49325#51228
            TabOrder = 1
            OnClick = btnRemoveClick
          end
        end
      end
    end
  end
  object sbInfo: TStatusBar
    Left = 0
    Top = 280
    Width = 671
    Height = 20
    Panels = <
      item
        Width = 50
      end>
  end
  object PopupMenu1: TPopupMenu
    Left = 568
    Top = 104
    object delete1: TMenuItem
      Caption = 'delete'
      OnClick = delete1Click
    end
  end
end
