object FrmSheepBuy: TFrmSheepBuy
  Left = 0
  Top = 0
  Caption = #50577' '#47588#49688
  ClientHeight = 302
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
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 156
    Height = 302
    Align = alLeft
    TabOrder = 0
    object StringGridOptions: TStringGrid
      Left = 1
      Top = 28
      Width = 154
      Height = 273
      Align = alClient
      Color = clBtnFace
      ColCount = 3
      DefaultRowHeight = 16
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine]
      ScrollBars = ssVertical
      TabOrder = 0
      OnDrawCell = StringGridOptionsDrawCell
      OnMouseDown = StringGridOptionsMouseDown
      ColWidths = (
        39
        49
        40)
    end
    object Panel5: TPanel
      Left = 1
      Top = 1
      Width = 154
      Height = 27
      Align = alTop
      BevelOuter = bvNone
      TabOrder = 1
      object Label5: TLabel
        Left = 8
        Top = 6
        Width = 27
        Height = 13
        Caption = #49440' '#47932
      end
      object stFutPrice: TStaticText
        Left = 45
        Top = 3
        Width = 66
        Height = 20
        Alignment = taRightJustify
        AutoSize = False
        BevelInner = bvLowered
        BevelOuter = bvNone
        BorderStyle = sbsSunken
        TabOrder = 0
      end
    end
  end
  object Panel4: TPanel
    Left = 156
    Top = 0
    Width = 327
    Height = 302
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object plStart: TPanel
      Left = 0
      Top = 0
      Width = 327
      Height = 86
      Align = alTop
      BiDiMode = bdLeftToRight
      ParentBiDiMode = False
      ParentBackground = False
      TabOrder = 0
      object Label4: TLabel
        Left = 66
        Top = 5
        Width = 27
        Height = 13
        Caption = #44228' '#51340
      end
      object Bevel1: TBevel
        Left = 5
        Top = 55
        Width = 93
        Height = 2
      end
      object lblAcntName: TLabel
        Left = 210
        Top = 5
        Width = 48
        Height = 13
        Caption = #51452#47928#49688#47049
      end
      object sgSymbols: TStringGrid
        Left = 133
        Top = 28
        Width = 189
        Height = 56
        BevelOuter = bvRaised
        ColCount = 4
        Ctl3D = False
        DefaultRowHeight = 17
        DefaultDrawing = False
        FixedCols = 0
        RowCount = 3
        ParentCtl3D = False
        ScrollBars = ssNone
        TabOrder = 5
        OnDrawCell = sgSymbolsDrawCell
        OnSelectCell = sgSymbolsSelectCell
        ColWidths = (
          62
          30
          59
          33)
      end
      object cbAccount: TComboBox
        Left = 103
        Top = 2
        Width = 102
        Height = 21
        Style = csDropDownList
        ImeName = 'Microsoft Office IME 2007'
        ItemHeight = 0
        TabOrder = 0
        OnChange = cbAccountChange
      end
      object rbUp: TRadioButton
        Left = 7
        Top = 33
        Width = 40
        Height = 17
        Caption = #19978
        Checked = True
        TabOrder = 1
        TabStop = True
        OnClick = rbUpClick
      end
      object stUpPrice: TStaticText
        Left = 46
        Top = 31
        Width = 47
        Height = 20
        AutoSize = False
        BevelInner = bvLowered
        BevelOuter = bvNone
        BiDiMode = bdLeftToRight
        BorderStyle = sbsSunken
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWhite
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 2
      end
      object stDownPrice: TStaticText
        Left = 46
        Top = 60
        Width = 47
        Height = 20
        AutoSize = False
        BevelInner = bvLowered
        BevelOuter = bvNone
        BiDiMode = bdLeftToRight
        BorderStyle = sbsSunken
        Color = clBtnFace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindow
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentBiDiMode = False
        ParentColor = False
        ParentFont = False
        ParentShowHint = False
        ShowHint = False
        TabOrder = 3
      end
      object rbDown: TRadioButton
        Left = 6
        Top = 63
        Width = 37
        Height = 17
        Caption = #19979
        TabOrder = 4
        OnClick = rbUpClick
      end
      object cbStart: TCheckBox
        Left = 6
        Top = 3
        Width = 49
        Height = 17
        Caption = 'Start'
        TabOrder = 6
        OnClick = cbStartClick
      end
      object edtSymbolCnt: TEdit
        Left = 286
        Top = 4
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        ReadOnly = True
        TabOrder = 7
        Text = '1'
      end
    end
    object Panel2: TPanel
      Left = 0
      Top = 86
      Width = 327
      Height = 89
      Align = alTop
      TabOrder = 1
      object Label1: TLabel
        Left = 18
        Top = 10
        Width = 48
        Height = 13
        Caption = #51452#47928#49688#47049
      end
      object Label2: TLabel
        Left = 18
        Top = 37
        Width = 48
        Height = 13
        Caption = #52572#45824#49688#47049
      end
      object Label3: TLabel
        Left = 6
        Top = 63
        Width = 60
        Height = 13
        Caption = #49440#47932#50880#51649#51076
      end
      object Label6: TLabel
        Left = 249
        Top = 37
        Width = 59
        Height = 13
        Caption = ', '#52397#49328#44032#45733')'
      end
      object rdClear: TRadioButton
        Left = 147
        Top = 10
        Width = 113
        Height = 17
        Caption = #52397#49328#44032#45733#49688#47049'   / '
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = rdClearClick
      end
      object edtClear: TEdit
        Tag = 3
        Left = 255
        Top = 7
        Width = 38
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 1
        Text = '3'
        OnChange = edtFutMoveChange
        OnKeyPress = edtFutMoveKeyPress
      end
      object udClear: TUpDown
        Left = 293
        Top = 7
        Width = 15
        Height = 21
        Associate = edtClear
        Min = 1
        Position = 3
        TabOrder = 2
      end
      object rdFixClear: TRadioButton
        Tag = 1
        Left = 146
        Top = 37
        Width = 47
        Height = 17
        Caption = 'Min('
        TabOrder = 3
        OnClick = rdClearClick
      end
      object edtFixClear: TEdit
        Tag = 4
        Left = 188
        Top = 34
        Width = 38
        Height = 21
        ImeName = 'Microsoft IME 2003'
        TabOrder = 4
        Text = '3'
        OnChange = edtFutMoveChange
        OnKeyPress = edtFutMoveKeyPress
      end
      object UpDown4: TUpDown
        Left = 226
        Top = 34
        Width = 15
        Height = 21
        Associate = edtFixClear
        Min = 1
        Position = 3
        TabOrder = 5
      end
      object edtFutMove: TEdit
        Tag = 2
        Left = 72
        Top = 61
        Width = 41
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 6
        Text = '1'
        OnChange = edtFutMoveChange
        OnKeyPress = edtFutMoveKeyPress
      end
      object UpDown3: TUpDown
        Left = 113
        Top = 61
        Width = 15
        Height = 21
        Associate = edtFutMove
        Min = 1
        Max = 10
        Position = 1
        TabOrder = 7
      end
      object UpDown2: TUpDown
        Left = 113
        Top = 34
        Width = 15
        Height = 21
        Associate = edtMaxQty
        Min = 1
        Position = 10
        TabOrder = 8
      end
      object edtMaxQty: TEdit
        Tag = 1
        Left = 72
        Top = 34
        Width = 41
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 9
        Text = '10'
        OnChange = edtFutMoveChange
        OnKeyPress = edtFutMoveKeyPress
      end
      object edtQty: TEdit
        Left = 72
        Top = 7
        Width = 41
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 10
        Text = '1'
        OnChange = edtFutMoveChange
        OnKeyPress = edtFutMoveKeyPress
      end
      object UpDown1: TUpDown
        Left = 113
        Top = 7
        Width = 15
        Height = 21
        Associate = edtQty
        Min = 1
        Max = 5
        Position = 1
        TabOrder = 11
      end
      object Button1: TButton
        Left = 269
        Top = 62
        Width = 47
        Height = 22
        Caption = #52397#49328
        TabOrder = 12
        OnClick = Button1Click
      end
    end
    object sgLog: TStringGrid
      Left = 0
      Top = 175
      Width = 327
      Height = 108
      Align = alClient
      BevelOuter = bvRaised
      Ctl3D = False
      DefaultRowHeight = 17
      DefaultDrawing = False
      FixedCols = 0
      RowCount = 2
      ParentCtl3D = False
      TabOrder = 2
      OnDrawCell = sgLogDrawCell
    end
    object stbar: TStatusBar
      Left = 0
      Top = 283
      Width = 327
      Height = 19
      BiDiMode = bdLeftToRight
      Panels = <
        item
          Alignment = taRightJustify
          Style = psOwnerDraw
          Width = 100
        end
        item
          Width = 100
        end
        item
          Width = 50
        end>
      ParentBiDiMode = False
      OnDrawPanel = stbarDrawPanel
    end
  end
end
