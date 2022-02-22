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
    FType : string;             //���� ���� F , ���� Ȯ�� G, �ɼ� ���� O, �ɼ� Ȯ�� P
    FKrxData : string;
    FMarket : string;           //���� F, �ɼ� O
    FAcptTime : string;
    FResCode : string;          //FEP �����ڵ�
    FMsgCode : string;          //KRX �����ڵ�
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
