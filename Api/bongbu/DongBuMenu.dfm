object DongBuData: TDongBuData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 152
  Width = 361
  object MainMenu1: TMainMenu
    Left = 48
    Top = 64
    object File1: TMenuItem
      Caption = #54028#51068
      object N7: TMenuItem
        Caption = #49436#48260#47700#49464#51648' '
        OnClick = N7Click
      end
      object N5: TMenuItem
        Caption = '-'
      end
      object Open1: TMenuItem
        Tag = 100
        Caption = #51200#51109#54868#47732' '#50676#44592
        OnClick = concernClick
      end
      object Exit1: TMenuItem
        Tag = 999
        Caption = #51333#47308
        OnClick = concernClick
      end
    end
    object Research1: TMenuItem
      Caption = #44228#51340
      object Skew1: TMenuItem
        Tag = 201
        Caption = #49436#48652#44228#51340#44288#47532
        OnClick = concernClick
      end
      object N1: TMenuItem
        Tag = 202
        Caption = #50696#53441#51092#44256' '#48143' '#51613#44144#44552
        OnClick = concernClick
      end
      object N2: TMenuItem
        Tag = 203
        Caption = #44228#51340#48708#48128#48264#54840#44288#47532
        OnClick = concernClick
      end
    end
    object Order1: TMenuItem
      Caption = #51452#47928
      object OrderBoard1: TMenuItem
        Tag = 305
        Caption = #51452#47928#52285
        OnClick = concernClick
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object N20: TMenuItem
        Tag = 330
        Caption = #48120#45768' '#51092#44256#45236#50669
        OnClick = concernClick
      end
      object Orders1: TMenuItem
        Tag = 302
        Caption = #51452#47928#47532#49828#53944
        OnClick = concernClick
      end
      object StopOrderList1: TMenuItem
        Tag = 350
        Caption = #49828#53457#51452#47928#47532#49828#53944
        OnClick = concernClick
      end
    end
    object MultiChart1: TMenuItem
      Caption = #47680#54000#52264#53944
      Visible = False
      OnClick = concernClick
      object N13: TMenuItem
        Tag = 306
        Caption = #49884#49828#53596#51452#47928
        OnClick = concernClick
      end
    end
    object Multi: TMenuItem
      Caption = #45796#44228#51340
      object N8: TMenuItem
        Tag = 411
        Caption = #45796#44228#51340#44288#47532
        OnClick = concernClick
      end
      object N4: TMenuItem
        Tag = 401
        Caption = #45796#44228#51340#51452#47928#52285
        OnClick = concernClick
      end
      object N6: TMenuItem
        Tag = 410
        Caption = #45796#44228#51340#48120#45768#51092#44256
        OnClick = concernClick
      end
    end
    object stg: TMenuItem
      Caption = #51204#47029
      Visible = False
      object USIN123: TMenuItem
        Tag = 402
        Caption = 'US_IN_123'
        OnClick = concernClick
      end
      object USH11Min: TMenuItem
        Tag = 403
        Caption = 'US_H1_1Min'
        OnClick = concernClick
      end
      object USH25Min1: TMenuItem
        Tag = 404
        Caption = 'US_H2_5Min'
        OnClick = concernClick
      end
      object USIN1: TMenuItem
        Tag = 409
        Caption = 'US_I2'
        OnClick = concernClick
      end
      object N9: TMenuItem
        Caption = '-'
      end
      object VolTrade1: TMenuItem
        Tag = 405
        Caption = 'VolTrade'
        OnClick = concernClick
      end
      object ShortVol1: TMenuItem
        Tag = 408
        Caption = 'Short_Vol'
        OnClick = concernClick
      end
      object N10: TMenuItem
        Tag = 406
        Caption = #52628#49464'('#44148#49688'&&'#53804#51088#51088')'
        OnClick = concernClick
      end
      object N11: TMenuItem
        Tag = 407
        Caption = #50577#47588#46020
        OnClick = concernClick
      end
      object N12: TMenuItem
        Caption = '-'
      end
      object SBO1: TMenuItem
        Tag = 412
        Caption = 'SBO'
        OnClick = concernClick
      end
    end
  end
  object OpenDialog: TOpenDialog
    DefaultExt = '.lsg'
    Filter = '(*.lsg)|*.lsg'
    Left = 208
  end
end
