object FrmPositionMngr: TFrmPositionMngr
  Left = 0
  Top = 0
  Caption = #49436#48652#44228#51340' '#54252#51648#49496#44288#47532
  ClientHeight = 579
  ClientWidth = 483
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
    Width = 483
    Height = 28
    Align = alTop
    BevelInner = bvLowered
    TabOrder = 0
    ExplicitWidth = 478
    object lbAcntName: TLabel
      Left = 158
      Top = 8
      Width = 3
      Height = 13
    end
    object ComboBoAccount: TComboBox
      Left = 4
      Top = 4
      Width = 149
      Height = 21
      Style = csDropDownList
      ImeName = 'Microsoft Office IME 2007'
      ItemHeight = 13
      TabOrder = 0
      OnChange = ComboBoAccountChange
    end
    object Button1: TButton
      Left = 418
      Top = 3
      Width = 57
      Height = 22
      Caption = #51312' '#54924
      TabOrder = 1
      OnClick = Button1Click
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 28
    Width = 202
    Height = 516
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 480
    object lvAcnt: TListView
      Left = 1
      Top = 22
      Width = 200
      Height = 194
      Align = alTop
      Columns = <
        item
          Caption = #49436#48652#44228#51340#53076#46300
          Width = 90
        end
        item
          Caption = #49436#48652#44228#51340#47749
          Width = 100
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
      OnClick = lvAcntClick
      OnData = lvAcntData
      OnDrawItem = lvAcnt2DrawItem
      ExplicitLeft = 2
      ExplicitTop = 81
    end
    object sg1: TStringGrid
      Left = 1
      Top = 216
      Width = 200
      Height = 299
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 1
      OnDrawCell = sg1DrawCell
      OnMouseDown = sg1MouseDown
      OnMouseUp = sg1MouseUp
      ExplicitTop = 195
      ExplicitHeight = 284
      ColWidths = (
        22
        78
        40
        38)
    end
    object CheckBox1: TCheckBox
      Left = 5
      Top = 217
      Width = 16
      Height = 17
      TabOrder = 2
      OnClick = CheckBox2Click
    end
    object Panel4: TPanel
      Left = 1
      Top = 1
      Width = 200
      Height = 21
      Align = alTop
      BevelOuter = bvNone
      Caption = #48320#44221#51204
      TabOrder = 3
    end
  end
  object Panel3: TPanel
    Left = 281
    Top = 28
    Width = 202
    Height = 516
    Align = alRight
    TabOrder = 2
    ExplicitLeft = 276
    ExplicitHeight = 480
    object lvAcnt2: TListView
      Tag = 1
      Left = 1
      Top = 22
      Width = 200
      Height = 194
      Align = alTop
      Columns = <
        item
          Caption = #49436#48652#44228#51340#53076#46300
          Width = 90
        end
        item
          Caption = #49436#48652#44228#51340#47749
          Width = 100
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
      OnClick = lvAcntClick
      OnData = lvAcntData
      OnDrawItem = lvAcnt2DrawItem
      ExplicitTop = 3
    end
    object sg2: TStringGrid
      Left = 1
      Top = 216
      Width = 200
      Height = 299
      Align = alClient
      ColCount = 4
      Ctl3D = False
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 1
      OnDrawCell = sg1DrawCell
      OnMouseDown = sg1MouseDown
      OnMouseUp = sg1MouseUp
      ExplicitTop = 195
      ExplicitHeight = 284
      ColWidths = (
        22
        78
        40
        38)
    end
    object CheckBox2: TCheckBox
      Tag = 1
      Left = 5
      Top = 217
      Width = 16
      Height = 17
      TabOrder = 2
      OnClick = CheckBox2Click
    end
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 200
      Height = 21
      Align = alTop
      BevelOuter = bvNone
      Caption = #48320#44221#54980
      TabOrder = 3
    end
  end
  object Button2: TButton
    Left = 208
    Top = 282
    Width = 63
    Height = 24
    Caption = '===> '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 3
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 207
    Top = 394
    Width = 63
    Height = 24
    Caption = '<==='
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Tahoma'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 4
    OnClick = Button3Click
  end
  object Panel6: TPanel
    Left = 0
    Top = 544
    Width = 483
    Height = 35
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 5
    object Button4: TButton
      Left = 238
      Top = 6
      Width = 75
      Height = 25
      Caption = #54869#51064
      TabOrder = 0
      OnClick = Button4Click
    end
    object Button5: TButton
      Left = 319
      Top = 6
      Width = 75
      Height = 25
      Caption = #52712#49548
      TabOrder = 1
      OnClick = Button5Click
    end
    object Button6: TButton
      Left = 400
      Top = 6
      Width = 75
      Height = 25
      Caption = #51201#50857
      TabOrder = 2
      OnClick = Button6Click
    end
  end
end
