object FrmSynConfig: TFrmSynConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = #54872#44221#49444#51221
  ClientHeight = 160
  ClientWidth = 163
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
  object Panel1: TPanel
    Left = 0
    Top = 132
    Width = 163
    Height = 28
    Align = alBottom
    TabOrder = 0
    object Button1: TButton
      Left = 47
      Top = 1
      Width = 56
      Height = 25
      Caption = #54869#51064
      ModalResult = 1
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Left = 104
      Top = 1
      Width = 54
      Height = 25
      Caption = #52712#49548
      ModalResult = 2
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 163
    Height = 132
    Align = alClient
    TabOrder = 1
    object listFrame: TListView
      Left = 1
      Top = 1
      Width = 161
      Height = 130
      Align = alClient
      Checkboxes = True
      Columns = <
        item
          Width = 30
        end
        item
          Caption = #54868#47732
          Width = 120
        end
        item
          Width = 0
        end>
      DragMode = dmAutomatic
      GridLines = True
      RowSelect = True
      TabOrder = 0
      ViewStyle = vsReport
      OnDragDrop = listFrameDragDrop
      OnDragOver = listFrameDragOver
    end
  end
end
