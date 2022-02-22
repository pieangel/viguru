object PositionListupForm: TPositionListupForm
  Left = 0
  Top = 0
  Caption = 'Position List'
  ClientHeight = 303
  ClientWidth = 777
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
    Width = 777
    Height = 49
    Align = alTop
    TabOrder = 0
    object cbAcnt: TComboBox
      Tag = 10
      Left = 66
      Top = 0
      Width = 145
      Height = 21
      Style = csDropDownList
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 0
      OnChange = cbAcntChange
    end
    object Panel2: TPanel
      Left = 0
      Top = 0
      Width = 65
      Height = 22
      Caption = #44228'  '#51340
      TabOrder = 1
    end
    object cbIssue: TComboBox
      Tag = 20
      Left = 278
      Top = 0
      Width = 145
      Height = 21
      Style = csDropDownList
      ImeName = #54620#44397#50612' '#51077#47141' '#49884#49828#53596' (IME 2000)'
      ItemHeight = 13
      TabOrder = 2
      OnChange = cbAcntChange
    end
    object Panel3: TPanel
      Left = 212
      Top = 0
      Width = 65
      Height = 21
      Caption = #51333'  '#47785
      TabOrder = 3
    end
    object cbPos: TCheckBox
      Left = 430
      Top = 0
      Width = 65
      Height = 25
      Caption = #54252#51648#49496
      Checked = True
      State = cbChecked
      TabOrder = 4
      OnClick = cbPosClick
    end
    object Panel4: TPanel
      Left = 0
      Top = 22
      Width = 65
      Height = 22
      Caption = #54217#44032#49552#51061
      TabOrder = 5
    end
    object Panel5: TPanel
      Left = 221
      Top = 22
      Width = 65
      Height = 22
      Caption = #49692#49552#51061
      TabOrder = 6
    end
    object Panel6: TPanel
      Left = 442
      Top = 22
      Width = 65
      Height = 22
      Caption = #52509#49552#51061
      TabOrder = 7
    end
    object statOte: TStaticText
      Left = 66
      Top = 22
      Width = 154
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      BevelInner = bvNone
      BevelOuter = bvNone
      BiDiMode = bdLeftToRight
      BorderStyle = sbsSunken
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 8
      Transparent = False
    end
    object statPL: TStaticText
      Left = 287
      Top = 22
      Width = 154
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      BevelInner = bvNone
      BevelOuter = bvNone
      BiDiMode = bdLeftToRight
      BorderStyle = sbsSunken
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 9
      Transparent = False
    end
    object statTotPL: TStaticText
      Left = 508
      Top = 22
      Width = 154
      Height = 22
      Alignment = taRightJustify
      AutoSize = False
      BevelInner = bvNone
      BevelOuter = bvNone
      BiDiMode = bdLeftToRight
      BorderStyle = sbsSunken
      Caption = '0'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentBiDiMode = False
      ParentFont = False
      TabOrder = 10
      Transparent = False
    end
  end
  object Panel7: TPanel
    Left = 0
    Top = 49
    Width = 777
    Height = 254
    Align = alClient
    TabOrder = 1
    object sgPos: TStringGrid
      Left = 1
      Top = 1
      Width = 775
      Height = 252
      Align = alClient
      ColCount = 13
      Ctl3D = False
      DefaultRowHeight = 17
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      ScrollBars = ssVertical
      TabOrder = 0
      OnDragDrop = sgPosDragDrop
      OnDragOver = sgPosDragOver
      OnDrawCell = sgPosDrawCell
      OnMouseDown = sgPosMouseDown
      ColWidths = (
        81
        70
        66
        83
        45
        56
        79
        46
        73
        33
        30
        42
        41)
    end
  end
  object Timer1: TTimer
    OnTimer = Timer1Timer
    Left = 504
  end
end
