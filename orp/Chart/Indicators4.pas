unit Indicators4;

interface

uses
  Classes, Graphics, Forms, Math,
  //
  Charters, Indicator, Symbolers, XTerms, GleTypes, GleConsts;

type
  { William's OverBought/Oversold Index }

  TAccountFill = class(TIndicator)
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TUpDownVolume = class( TIndicator )
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TVKospiSpread = class( TIndicator )
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

  TSymbolTotalCount = class( TIndicator )
  protected
    procedure DoInit; override;
    procedure DoPlot; override;
  end;

implementation

{ TAccountFill }

procedure TAccountFill.DoInit;
begin

  Title := 'AccountFill';
  //
  AddParam('Account', '');
  //
  AddPlot('LongFill', psLine, clWhite, 3);
  AddPlot('ShortFill', psLine, clBlue, 3);

end;

procedure TAccountFill.DoPlot;
begin
  Plot(0, LongFill[0]);
  Plot(1, ShortFill[0])
end;

{ TUpDownVolume }

procedure TUpDownVolume.DoInit;
begin
  Title := 'UpDown Vol';

  AddPlot('UVol', psHistogram, clWhite, 2);
  AddPlot('DVol', psHistogram, clWhite, 2);
  AddPlot('NetVol', psHistogram, clBlue, 2 );
end;

procedure TUpDownVolume.DoPlot;
begin
  Plot(0, UVol[0]);
  Plot(1, DVol[0]);
  Plot(2, NetVol[0]);
end;

{ TVKospiPairs }

procedure TVKospiSpread.DoInit;
begin
  Title := 'VKospi Spread';
  AddPlot('vSpread', psLine, clGreen, 1 );
  AddPlot('vStandLine', psLine, clRed, 1 );
  AddPlot('vMASpread', psLine, clRed, 1 );
end;

procedure TVKospiSpread.DoPlot;
begin
  Plot(0, vSpread[0]);
  Plot(1, vStandLine[0]);
  Plot(2, vMASpread[0]);
end;

{ TSymbolTotalCount }

procedure TSymbolTotalCount.DoInit;
begin
  Title := 'Future ToTal Count';
  AddPlot('AskCnt', psLine, clBlue, 1 );
  AddPlot('BidCnt', psLine, clRed,  1 );
end;

procedure TSymbolTotalCount.DoPlot;
begin
  Plot(0, AskCnt[0]);
  Plot(1, BidCnt[0]);
end;

end.
