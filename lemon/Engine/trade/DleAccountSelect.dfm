object FrmAcntSelect: TFrmAcntSelect
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'FrmAcntSelect'
  ClientHeight = 315
  ClientWidth = 216
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDefault
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 216
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    Caption = '  '#44228#51340#51312#54924
    TabOrder = 0
  end
  object Panel2: TPanel
    Left = 0
    Top = 25
    Width = 216
    Height = 25
    Align = alTop
    Alignment = taLeftJustify
    TabOrder = 1
    object rbAccount: TRadioButton
      Left = 80
      Top = 4
      Width = 49
      Height = 17
      Caption = #44228#51340
      TabOrder = 0
      OnClick = rbTotalClick
    end
    object rbFund: TRadioButton
      Left = 157
      Top = 4
      Width = 57
      Height = 17
      Caption = #54144#46300
      TabOrder = 1
      OnClick = rbTotalClick
    end
    object rbTotal: TRadioButton
      Left = 7
      Top = 3
      Width = 49
      Height = 17
      Caption = #51204#52404
      Checked = True
      TabOrder = 2
      TabStop = True
      OnClick = rbTotalClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 50
    Width = 216
    Height = 240
    Align = alClient
    TabOrder = 2
    object lstAcnt: TListView
      Left = 1
      Top = 1
      Width = 214
      Height = 238
      Align = alClient
      Columns = <
        item
          Width = 1
        end
        item
          Caption = #44228#51340#47749
          Width = 100
        end
        item
          Caption = #53076#46300
          Width = 90
        end>
      ColumnClick = False
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
      OnDrawItem = lstAcntDrawItem
      OnSelectItem = lstAcntSelectItem
      ExplicitLeft = 6
      ExplicitTop = -9
      ExplicitWidth = 179
      ExplicitHeight = 249
    end
  end
  object TPanel
    Left = 0
    Top = 290
    Width = 216
    Height = 25
    Align = alBottom
    TabOrder = 3
    object cbStay: TCheckBox
      Left = 7
      Top = 4
      Width = 66
      Height = 17
      Caption = #54868#47732#50976#51648
      TabOrder = 0
      Visible = False
    end
    object Button1: TButton
      Left = 167
      Top = 2
      Width = 53
      Height = 21
      Caption = #45803'  '#44592
      TabOrder = 1
      OnClick = Button1Click
    end
  end
end
