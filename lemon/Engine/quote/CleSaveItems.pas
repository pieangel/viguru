unit CleSaveItems;

interface

uses
  Classes, SysUtils
  ;

type
  TSaveItemIF = class( TCollectionItem )
  public
    SaveTime  : TDateTime;
  end;


  TQuoteDelayItem = class( TSaveItemIF )
  public
    FutDelay  : double;
    CalDelay  : double;
    PutDelay  : double;
    procedure GetStrings( var aList :TStrings );
  end;

  TIODataItem = class(TSaveItemIF)
  public
    FDateTime1 : string;        //yyyy-mm-dd hh:nn:ss.ssss
    FSeq : string;
    FDateTime2 : string;
    FUserID : string;
    FType : string;             //선물 접수 F , 선물 확인 G, 옵션 접수 O, 옵션 확인 P
    FKrxData : string;
    FMarket : string;           //선물 F, 옵션 O
    FAcptTime : string;
    FResCode : string;          //FEP 에러코드
    FMsgCode : string;          //KRX 에러코드
  end;

implementation

{ TQuoteDelayItem }

procedure TQuoteDelayItem.GetStrings( var aList :TStrings );
begin
  aList.Add( FormatDateTime('hh:nn:ss.zzz', SaveTime)   );
  aList.Add( Format('%.1f', [ FutDelay]) );
  aList.Add( Format('%.1f', [ CalDelay]) );
  aList.Add( Format('%.1f', [ PutDelay]) );
end;

end.
