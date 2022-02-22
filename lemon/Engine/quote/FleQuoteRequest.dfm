object frmQuote: TfrmQuote
  Left = 0
  Top = 0
  Caption = #51333#47785#49884#49464#51312#54924
  ClientHeight = 532
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 505
    Width = 400
    Height = 27
    Align = alBottom
    TabOrder = 0
    object btnRe: TBitBtn
      Left = 310
      Top = 1
      Width = 89
      Height = 23
      Caption = #49884#49464#51312#54924
      TabOrder = 0
      OnClick = btnReClick
    end
    object btnUpdate: TBitBtn
      Left = 221
      Top = 1
      Width = 89
      Height = 23
      Caption = #54868#47732#50629#45936#51060#53944
      TabOrder = 1
      OnClick = btnUpdateClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 505
    Align = alClient
    TabOrder = 1
    object sgData: TStringGrid
      Left = 1
      Top = 1
      Width = 398
      Height = 503
      Align = alClient
      ColCount = 6
      DefaultRowHeight = 19
      FixedCols = 0
      RowCount = 2
      Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goRowSelect]
      TabOrder = 0
      OnDrawCell = sgDataDrawCell
    end
  end
  object refreshTimer: TTimer
    Enabled = False
    Interval = 6000
    OnTimer = refreshTimerTimer
    Left = 24
    Top = 472
  end
end
