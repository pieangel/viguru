object FrmShortHult: TFrmShortHult
  Left = 0
  Top = 0
  Caption = 'DHult'
  ClientHeight = 244
  ClientWidth = 210
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 210
    Height = 27
    Align = alTop
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentBackground = False
    TabOrder = 0
    DesignSize = (
      210
      27)
    object cbStart: TCheckBox
      Left = 160
      Top = 4
      Width = 46
      Height = 17
      Anchors = [akTop, akRight, akBottom]
      Caption = 'Start'
      TabOrder = 0
      OnClick = cbStartClick
    end
    object btnColor: TButton
      Left = 135
      Top = 3
      Width = 21
      Height = 20
      Caption = 'C'
      TabOrder = 1
      OnClick = btnColorClick
    end
    object Button6: TButton
      Left = 109
      Top = 4
      Width = 22
      Height = 21
      Caption = '..'
      TabOrder = 2
      OnClick = Button6Click
    end
    object edtAccount: TEdit
      Left = 3
      Top = 2
      Width = 106
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 3
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 27
    Width = 210
    Height = 198
    Align = alClient
    BevelOuter = bvLowered
    BiDiMode = bdLeftToRight
    ParentBiDiMode = False
    ParentBackground = False
    TabOrder = 1
    object Label2: TLabel
      Left = 7
      Top = 6
      Width = 34
      Height = 13
      Caption = 'Symbol'
    end
    object Label3: TLabel
      Left = 6
      Top = 31
      Width = 18
      Height = 13
      Caption = 'Qty'
    end
    object Label4: TLabel
      Left = 73
      Top = 33
      Width = 19
      Height = 13
      Caption = 'Gap'
    end
    object Label17: TLabel
      Left = 139
      Top = 34
      Width = 17
      Height = 13
      Caption = 'Pos'
    end
    object Label10: TLabel
      Left = 7
      Top = 144
      Width = 48
      Height = 13
      Caption = 'StartPoint'
    end
    object edtSymbol: TEdit
      Left = 46
      Top = 2
      Width = 94
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      ReadOnly = True
      TabOrder = 0
    end
    object Button1: TButton
      Left = 141
      Top = 2
      Width = 24
      Height = 21
      Caption = '...'
      TabOrder = 1
      OnClick = Button1Click
    end
    object edtQty: TEdit
      Left = 27
      Top = 28
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 2
      Text = '1'
      OnKeyPress = edtQtyKeyPress
    end
    object edtGap: TEdit
      Tag = 1
      Left = 94
      Top = 29
      Width = 24
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 3
      Text = '5'
      OnKeyPress = edtQtyKeyPress
    end
    object UpDown1: TUpDown
      Left = 52
      Top = 28
      Width = 16
      Height = 21
      Associate = edtQty
      Min = 1
      Max = 500
      Position = 1
      TabOrder = 4
    end
    object UpDown2: TUpDown
      Left = 118
      Top = 29
      Width = 16
      Height = 21
      Associate = edtGap
      Min = 1
      Max = 1000
      Position = 5
      TabOrder = 5
    end
    object gbUseHul: TGroupBox
      Left = 5
      Top = 50
      Width = 200
      Height = 89
      Caption = #52397#49328'('#45800#50948' : '#47564')'
      TabOrder = 6
      object Label6: TLabel
        Left = 8
        Top = 21
        Width = 19
        Height = 13
        Caption = 'Risk'
      end
      object Label8: TLabel
        Left = 67
        Top = 19
        Width = 26
        Height = 13
        Caption = 'Profit'
      end
      object Label1: TLabel
        Left = 136
        Top = 21
        Width = 17
        Height = 13
        Caption = 'Cnt'
      end
      object cbAllcnlNStop: TCheckBox
        Left = 8
        Top = 44
        Width = 157
        Height = 17
        Caption = #49552#51208#54980' '#47784#46160' '#52712#49548' && '#49828#53457
        Checked = True
        State = cbChecked
        TabOrder = 0
        OnClick = cbAllcnlNStopClick
      end
      object edtRiskAmt: TEdit
        Tag = 3
        Left = 30
        Top = 17
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 1
        Text = '999'
        OnKeyPress = edtQtyKeyPress
      end
      object edtProfitAmt: TEdit
        Tag = 4
        Left = 96
        Top = 17
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 2
        Text = '999'
        OnKeyPress = edtQtyKeyPress
      end
      object cbAutoLiquid: TCheckBox
        Left = 8
        Top = 67
        Width = 71
        Height = 17
        Caption = 'AutoClear'
        Checked = True
        State = cbChecked
        TabOrder = 3
      end
      object DateTimePicker: TDateTimePicker
        Left = 82
        Top = 63
        Width = 95
        Height = 21
        Date = 41547.625000000000000000
        Time = 41547.625000000000000000
        DateMode = dmUpDown
        ImeName = 'Microsoft Office IME 2007'
        Kind = dtkTime
        TabOrder = 4
      end
      object edtQtyLimit: TEdit
        Tag = 3
        Left = 158
        Top = 17
        Width = 35
        Height = 21
        ImeName = 'Microsoft Office IME 2007'
        TabOrder = 5
        Text = '999'
        OnKeyPress = edtQtyKeyPress
      end
    end
    object edtClearPos: TEdit
      Tag = 2
      Left = 161
      Top = 29
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 7
      Text = '3'
      OnKeyPress = edtQtyKeyPress
    end
    object udClearPos: TUpDown
      Left = 186
      Top = 29
      Width = 16
      Height = 21
      Associate = edtClearPos
      Min = 1
      Max = 1000
      Position = 3
      TabOrder = 8
    end
    object Panel3: TPanel
      Left = 1
      Top = 170
      Width = 208
      Height = 27
      Align = alBottom
      TabOrder = 9
    end
    object cbAPI: TCheckBox
      Left = 139
      Top = 145
      Width = 63
      Height = 17
      Caption = 'No Prop.'
      Checked = True
      State = cbChecked
      TabOrder = 10
      Visible = False
      OnClick = cbAllcnlNStopClick
    end
    object Button2: TButton
      Left = 168
      Top = 3
      Width = 38
      Height = 20
      Caption = #51201#50857
      TabOrder = 11
      OnClick = Button2Click
    end
    object edtSPoint: TEdit
      Tag = 2
      Left = 59
      Top = 142
      Width = 25
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 12
      Text = '0.5'
    end
    object edtOpen: TEdit
      Tag = 2
      Left = 87
      Top = 142
      Width = 46
      Height = 21
      ImeName = 'Microsoft Office IME 2007'
      TabOrder = 13
    end
  end
  object stTxt: TStatusBar
    Left = 0
    Top = 225
    Width = 210
    Height = 19
    Panels = <
      item
        Width = 60
      end
      item
        Width = 160
      end>
  end
  object ColorDialog: TColorDialog
    Top = 168
  end
end
