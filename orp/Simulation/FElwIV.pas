unit FElwIV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleQuoteBroker, CleDistributor, CalcElwIVGreeks,
  CleExcelLog, GleTypes,  CleKrxSymbols, 
  CleQuoteTimers, StdCtrls, ExtCtrls , math
  ;

Const
  stTitle =  '시간,T-Ask-IV, T-Bid-IV, 매도, 매수, 현재가, 기초매도, 기초매수,기초현재가, 행사가, 금리, 잔존일, aa, bb,전환, 배당';

  stTitle2 = '시간,'+//Ask-IV, Bid-IV, W-C-IV, W-W-IV, M-C-IV, M-W-IV,'+
    //'Ask-Delta, Bid-Delta, ' +
    //'VLM1, VHM1, VLD1,VHD1, VLM2,VHM2,VLD2,VHD2,VLM3,VHM3,VLD3,VHD3,'+//
    //'Ask-Iv, Delta, 차이, 추정값, 매도가, A,' +
    'Lp잔량,잔량,매도, 현재가, 가중치, 평균, 매수, 잔량, Lp잔량,'+
    '잔량,기초매도,기초현재가, 기초가중치 ,5가중치, 매도가중치, 매수가중치, 기초매수,잔량,'+
    '행사가, 잔존일, aa, bb,전환, 배당';

  {
  stTitle2 = '시간,' +
    '-,추정,매도가,기초매도,A,B,'+
    '-,추정,매도가,기초현재,A,B,'+
    '-,추정,매도가,기초가중치,A,B,'+
    '-,추정,매도가,기초5가중치,A,B,'+
    '-,추정,매도가,기초매도가중치,A,B,';

  stTitle3 = '시간,' +
    '-,추정,매도가,기초가중치,A,B,';


  stTitle4 = '시간,' +
    '-,추정,매도가,기초매도가중치,A,B,';

  }
  FirAsk = '1';
  FirBid = '2';

type

  TElwDetailITem  = class( TCollectionItem )
  public
    Time   : TDateTime;
    PreVal : array [0..4] of double;     //

    Differ : array [0..4] of double;     // P-V

    AVal  : array [0..4] of double;
    BVal  : array [0..4] of double;

    A :  array [0..4] of double;
    B :  array [0..4] of double;

    //
    W, E, R, T, Q, F,
    Last,  UnderLast, UnderCur, WAvgPrice, Step5Price, AskWPrice : double;
    UnderType : TElwUnderlyingType;



  end;

  TElwItem = class( TCollection )
  private
    function GetElwItem(i: integer): TElwDetailItem;
  public
    aa  : array [0..4] of double;
    bb  : array [0..4] of double;
    function New( dtTime : TDateTime ) : TElwDetailItem;
    constructor Create;
    destructor Destroy; override;

    property ElwItem[ i : integer ] : TElwDetailItem read GetElwItem;
  end;

  TElwIvItem = class( TCollectionItem )
  private
    function GetValSize(iLen: integer): integer;
  public
    ExcelLog  : TExcelLog;
    Quote     : TQuote;
    //Underlying: TSymbol;
    Index     : integer;
    AVal1      : array of Double;
    AVal2      : array of Double;
    AVal3      : array of Double;
    AVal4      : array of Double;
    AVal5      : array of Double;

    BVal1      : array of Double;
    BVal2      : array of Double;
    BVal3      : array of Double;
    BVal4      : array of Double;
    BVal5      : array of Double;

    ElwItem   : TElwItem;

    dTick, dDan : double;
    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    procedure BInit( aquote : TQuote );
    Function GetTickSize( dPrice: Double ) : integer;
  end;


  TElwIv = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    plDr: TPanel;
    Button4: TButton;
    Button5: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    function FindLog(aQuote: TQuote): TElwIvItem;
    function GetAskWeightPrice(uType: TElwUnderlyingType; dConRatio: double;
      aElwQuote, aUnderQuote: TQuote; dDelta : double = 1): double;
    function GetBidWeightPrice(uType: TElwUnderlyingType; dConRatio: double;
      aElwQuote, aUnderQuote: TQuote; dDelta: double): double;
    { Private declarations }
  public
    { Public declarations }
    Future : TSymbol;
    Logs   : TCollection;
    procedure k200init;
    procedure stockinit;
    procedure allinit;
    procedure Fin;
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure DoQuote( aQuote : TQuote; aLog : TElwIVItem );
    procedure DoQuote2( aQuote : TQuote; aLog : TElwIVItem );

  end;

var
  ElwIv: TElwIv;

implementation

uses
  GAppEnv, GleLib;

{$R *.dfm}



procedure TElwIv.allinit;
begin

end;

procedure TElwIv.Button1Click(Sender: TObject);
begin
  k200init;
end;


procedure TElwIv.Button2Click(Sender: TObject);
begin
  stockinit;
end;

procedure TElwIv.Button3Click(Sender: TObject);
begin
  k200init;
  stockinit;
end;

procedure TElwIv.Button4Click(Sender: TObject);
begin
  //Caption := IntToStr( gEnv.Maxcount );
end;


procedure TElwIv.Button5Click(Sender: TObject);
var
  stLog : string;
  i, j, k : integer;
  aLog : TElwIvItem;
  aItem: TElwDetailItem;
  d1, dTmp: double;

  vv,dLow : array [0..4] of double;
  da   : array [0..4] of double;
  ii   : array [0..4] of integer;

  function GetPrice( a, b, c : double ) : double;
  begin
    Result := a + b * ( c - 209 );
  end;
begin

  for i := 0 to Logs.Count - 1 do
  begin

    aLog  := TElwIvItem( Logs.Items[i] );
    if aLog = nil then
    begin
      gEnv.OnLog(self, 'ㅁㅁㅁ');
      Continue;
    end;   

    // Find 'A' Value
    {
    vv := aLog.ElwItem.ElwItem[ aLog.ElwItem.Count-1].A;
    aLog.ElwItem.aa := vv;

    for j := 0 to aLog.ElwItem.Count-1 do
    begin

      aItem := aLog.ElwItem.ElwItem[j];
      if aItem <> nil then begin
        with aItem do
        begin
         dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderLast, 0,0,0,0, E, R, T, vv, Q, F)/5)*5;

          stLog := '['+FormatDateTime('hh:nn.ss.zzz', aItem.Time)+']'+
            ',' + Format('%.5f', [ AskIV  ]) +
            ',' + Format('%.5f', [ Delta  ]) +
            ',' + Format('%.f',  [ DVal  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ vv ] ) ;

          aLog.ExcelLog.LogData( stLog, aLog.Index );
          inc( aLog.Index );

        end;
      end;
    end;  // for

          aLog.ExcelLog.LogData( '', aLog.Index );
          inc( aLog.Index );
    }
    // Find 'B' Value
    if aLog.ElwItem.Count < 1 then
      Continue;

    for k := 0 to 5 - 1 do
    begin
      vv[k] := aLog.ElwItem.ElwItem[ aLog.ElwItem.Count-1].A[k];
      aLog.ElwItem.aa[k] := vv[k];
    end;

    for j := 0 to aLog.ElwItem.Count-1 do
    begin

      aItem := aLog.ElwItem.ElwItem[j];
      if aItem <> nil then begin
        with aItem do  begin
          ///
          d1  := aLog.dDan * -1;
          for k := 0 to High(aLog.BVal1) do
          begin
            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderLast,
              0,0,0,0, E, R, T, GetPrice(vv[0],d1,UnderLast), Q, F)/5)*5;
            aLog.BVal1[k] := aLog.BVal1[k] + abs( dTmp - Last ) ;

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderCur,
              0,0,0,0, E, R, T, GetPrice(vv[1],d1,UnderCur), Q, F)/5)*5;
            aLog.BVal2[k] := aLog.BVal2[k] + abs( dTmp - Last ) ;

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, WAvgPrice,
              0,0,0,0, E, R, T, GetPrice(vv[2],d1,WAvgPrice), Q, F)/5)*5;
            aLog.BVal3[k] := aLog.BVal3[k] + abs( dTmp - Last ) ;

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, Step5Price,
              0,0,0,0, E, R, T, GetPrice(vv[3],d1,Step5Price), Q, F)/5)*5;
            aLog.BVal4[k] := aLog.BVal4[k] + abs( dTmp - Last ) ;

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, AskWPrice,
              0,0,0,0, E, R, T, GetPrice(vv[4],d1,AskWPrice), Q, F)/5)*5;
            aLog.BVal5[k] := aLog.BVal5[k] + abs( dTmp - Last ) ;

            d1 := d1 + aLog.dTick;
          end;

          ////
          d1 := aLog.dDan * -1;

          for k := 0 to 4 do
          begin
            ii[k] := 0;
            da[k] := d1;
          end;
          dLow[0] := aLog.BVal1[0];
          dLow[1] := aLog.BVal2[0];
          dLow[2] := aLog.BVal3[0];
          dLow[3] := aLog.BVal4[0];
          dLow[4] := aLog.BVal5[0];

          for k := 0 to High( aLog.BVal1 ) do
          begin

            if dLow[0] > aLog.BVal1[k] then
            begin
              dLow[0]  := aLog.BVal1[k];
              da[0]    := d1;
              ii[0] := k;
            end;

            if dLow[1] > aLog.BVal2[k] then
            begin
              dLow[1]  := aLog.BVal2[k];
              da[1]    := d1;
              ii[1] := k;
            end;

            if dLow[2] > aLog.BVal3[k] then
            begin
              dLow[2]  := aLog.BVal3[k];
              da[2]    := d1;
              ii[2] := k;
            end;

            if dLow[3] > aLog.BVal4[k] then
            begin
              dLow[3]  := aLog.BVal4[k];
              da[3]    := d1;
              ii[3] := k;
            end;

            if dLow[4] > aLog.BVal5[k] then
            begin
              dLow[4]  := aLog.BVal5[k];
              da[4]    := d1;
              ii[4] := k;
            end;
            d1 := d1 + aLog.dTick;
          end;

          for k := 0 to 4 do
          begin
            B[k] := da[k];
          end;
          {
          dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderLast, 0,0,0,0,
            E, R, T, GetPrice(vv,da,UnderLast), Q, F)/5)*5;

          stLog := '['+FormatDateTime('hh:nn.ss.zzz', aItem.Time)+']'+
            ',' + Format('%.5f', [ AskIV  ]) +
            ',' + Format('%.5f', [ Delta  ]) +
            ',' + Format('%.f',  [ abs(dTmp-Last)]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.9f', [ da+vv*UnderLast ] ) +
            ',' + Format('%.12f', [ da ] ) +
            ',' + Format('%.9f', [ aLog.dDan ] ) +
            ',' + Format('%.9f', [ aLog.dTick ] ) ;

          aLog.ExcelLog.LogData( stLog, aLog.Index );
          inc( aLog.Index );
          }

        end;
      end;
    end;  // for

    // end Find 'B'

    for k := 0 to 5 - 1 do
    begin
      vv[k] := aLog.ElwItem.ElwItem[ aLog.ElwItem.Count-1].B[k];
      aLog.ElwItem.bb[k] := vv[k];
    end;


    if (aLog.Quote.Symbol as TElw).LPCode = '00030' then
    begin

      for j := 0 to aLog.ElwItem.Count-1 do
      begin
        aItem := aLog.ElwItem.ElwItem[j];
        if aItem <> nil then begin
          with aItem do
          begin
            stLog := '['+FormatDateTime('hh:nn.ss.zzz', aItem.Time)+']';

            k := 0;

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderLast, 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,UnderLast), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ UnderLast] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, UnderCur, 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,UnderCur), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ UnderCur] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            // 잔량 가중치
            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, WAvgPrice, 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,WAvgPrice), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ WAvgPrice] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] );

            inc(k);

            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, Step5Price, 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,Step5Price), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ Step5Price] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            // 매도 가중치
            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, AskWPrice , 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,AskWPrice ), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ AskWPrice] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            aLog.ExcelLog.LogData( stLog, aLog.Index );
            inc( aLog.Index );

          end;
        end;
      end;  // for
    end else
    if (aLog.Quote.Symbol as TElw).LPCode = '00005' then
    begin
      for j := 0 to aLog.ElwItem.Count-1 do
      begin
        aItem := aLog.ElwItem.ElwItem[j];
        if aItem <> nil then begin
          with aItem do
          begin
            stLog := '['+FormatDateTime('hh:nn.ss.zzz', aItem.Time)+']';

            k := 2;

            // 잔량가중치
            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, WAvgPrice , 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,WAvgPrice ), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ WAvgPrice] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            aLog.ExcelLog.LogData( stLog, aLog.Index );
            inc( aLog.Index );

          end;
        end;
      end;  // for

    end else
    if (aLog.Quote.Symbol as TElw).LPCode = '00010' then
    begin

      for j := 0 to aLog.ElwItem.Count-1 do
      begin
        aItem := aLog.ElwItem.ElwItem[j];
        if aItem <> nil then begin
          with aItem do
          begin
            stLog := '['+FormatDateTime('hh:nn.ss.zzz', aItem.Time)+']';

            k := 4;

            // 매도 가중치
            dTmp := ceil(ELW_Greeks_KIS( W, UnderType, gtPrice, AskWPrice , 0,0,0,0,
              E, R, T, GetPrice(aLog.ElwItem.aa[k] ,aLog.ElwItem.bb[k] ,AskWPrice ), Q, F)/5)*5;

            stLog := stLog +
            ',' + Format('%.f',  [ abs( dTmp - Last)  ]) +
            ',' + Format('%.5f', [ dTmp  ]) +
            ',' + Format('%.4f', [ Last] ) +
            ',' + Format('%.4f', [ AskWPrice] ) +
            ',' + Format('%.9f', [ aLog.ElwItem.aa[k] ] ) +
            ',' + Format('%.12f',[ vv[k] ] ) ;

            inc(k);

            aLog.ExcelLog.LogData( stLog, aLog.Index );
            inc( aLog.Index );

          end;
        end;
      end;  // for

    end;





  end;
end;

function TElwIv.GetAskWeightPrice( uType : TElwUnderlyingType;
  dConRatio : double; aElwQuote, aUnderQuote : TQuote; dDelta : double  ) : double;
  var
    dDiv : integer;
    N, dVal, dN : Double;
    K : integer;
    iPSum,iSum,iTmp ,i: Integer;

begin
  Result := 0;
  case uType of
    eutIndex: dDiv := 500000;
    eutStock: dDiv := 1;
  end;

  N := aElwQuote.Bids[0].Volume * dConRatio / dDiv * dDelta;

  iSum := 0;   dVal := 0;    dN := 0;
  for i := 0 to aUnderQuote.Asks.Count - 1 do
  begin
    iSum := iSum + aUnderQuote.Bids[i].Volume;
    //dVal := dVal + (aUnderQuote.Asks[i].Volume * aUnderQuote.Asks[i].Price );
    //iTmp := aUnderQuote.Asks[i].Volume;
    if iSum >= N then begin
      //dVal := dVal + (( N - iSum - aUnderQuote.Asks[i].Volume )+ aUnderQuote.Asks[i].Price );
      //dN := N - ((iSum - iTmp) + 0.0001);
      Break;
    end;
  end;

  K := i;

  if k >= aUnderQuote.Bids.Count then
    k := aUnderQuote.Bids.Count-1
  else if k < 0 then
    K := 0;

  dVal := 0;  iSum := 0;
  try
    for i := 0 to k do
      if i = k then
        dVal := dVal + ((N - iSum) * aUnderQuote.Bids[i].Price )
      else begin
        dVal := dVal + (aUnderQuote.Bids[i].Volume * aUnderQuote.Bids[i].Price );
        iSum := iSum +  aUnderQuote.Bids[i].Volume;
      end;
  except
    gEnv.DoLog( WIN_ERR, IntToStr( i ) + IntToStr( k ));
  end;

  if N <= 0 then
    Result := 0
  else
    Result := dVal  / N;

end;


function TElwIv.GetBidWeightPrice( uType : TElwUnderlyingType;
  dConRatio : double; aElwQuote, aUnderQuote : TQuote; dDelta : double  ) : double;
  var
    dDiv : integer;
    N, dVal, dN : Double;
    K : integer;
    iPSum,iSum,iTmp ,i: Integer;

begin
  Result := 0;
  case uType of
    eutIndex: dDiv := 500000;
    eutStock: dDiv := 1;
  end;

  N := aElwQuote.Asks[0].Volume * dConRatio / dDiv * dDelta;

  iSum := 0;   dVal := 0;    dN := 0;
  for i := 0 to aUnderQuote.Asks.Count - 1 do
  begin
    iSum := iSum + aUnderQuote.Asks[i].Volume;
    //dVal := dVal + (aUnderQuote.Asks[i].Volume * aUnderQuote.Asks[i].Price );
    //iTmp := aUnderQuote.Asks[i].Volume;
    if iSum >= N then begin
      //dVal := dVal + (( N - iSum - aUnderQuote.Asks[i].Volume )+ aUnderQuote.Asks[i].Price );
      //dN := N - ((iSum - iTmp) + 0.0001);
      Break;
    end;
  end;

  K := i;

  if k >= aUnderQuote.Bids.Count then
    k := aUnderQuote.Bids.Count-1
  else if k < 0 then
    K := 0;

  dVal := 0;  iSum := 0;
  try
    for i := 0 to k do
      if i = k then
        dVal := dVal + ((N - iSum) * aUnderQuote.Asks[i].Price )
      else begin
        dVal := dVal + (aUnderQuote.Asks[i].Volume * aUnderQuote.Asks[i].Price );
        iSum := iSum +  aUnderQuote.Asks[i].Volume;
      end;
  except
    gEnv.DoLog( WIN_ERR, IntToStr( i ) + IntToStr( k ));
  end;

  if N <= 0 then
    Result := 0
  else
    Result := dVal  / N;

end;

procedure TElwIv.DoQuote(aQuote: TQuote; aLog : TElwIVItem);
var
  stLog : string;
  bQuote : TQuote;
  aSymbol : TStock;
  aUnderType : TElwUnderlyingType;

  k :integer;

  U, E, R, T, TC, W, I, Q, F, FixT : Double;
  ExpireDateTime : TDateTime;
  dLast, dUnderLast  : double;
  dLast2, dUnderLast2 , dDelta, dGamma, dTheta, dVega, dRho, aAskIV, aBidIV, dWCIV, dWWIV,
  dPrice, d1, dTmp, dLow, dSum, da,
  dDelta2, dGamma2, dTheta2, dVega2, dRho2  : double;
  dDelta3, dGamma3, dTheta3, dVega3, dRho3  : double;
  dDelta4, dGamma4, dTheta4, dVega4, dRho4  : double;
  dWAvgPrice, dWAvgPrice2, d5StepPrice, dBidWeightPRice, dAskWeightPrice : double;
  dAvg, dAvg2 : double;
  aElw : TELW;
  iAskVol, iBidVol, iAskVol2, iBidVol2, iAskLpVol, iBidLpVol, j, ii : integer;

  // add variables
  Asks : array [0..4] of double;
  Bids : array [0..4] of double;
  Askvols : array [0..4] of integer;
  BidVols : array [0..4] of integer;

  VLM1, VHM1, VLD1,VHD1, VLM2,VHM2,VLD2,VHD2 : double;
  VLM3, VHM3, VLD3,VHD3 : double;

  aItem : TElwDetailItem;

  function GetIV( uType : TElwUnderlyingType; _U, _C : double) : Double;
  begin
    REsult := ELW_Bisection_ImpVol( W, uType, _U, 0, 0, 0, 0, E, R, T, _C, Q, F );
    //Result := IV2(_U, E, R, Q, T, TC, _C / aElw.ConvRatio , W);
  end;

  function GetIV2( uType : TElwUnderlyingType; _U, _C : double) : Double;
  begin
    REsult := ELW_Bisection_ImpVol( W, uType, _U, 0, 0, 0, 0, E, R, FixT, _C, Q, F );
    //Result := IV2(_U, E, R, Q, T, TC, _C / aElw.ConvRatio , W);
  end;
begin


  bQuote := Future.Quote as TQuote;

  dLast := aQuote.Asks[0].Price;
  dUnderLast := bQuote.Asks[0].Price;

  dLast2 := aQuote.Bids[0].Price;
  dUnderLast2 := bQuote.Bids[0].Price;

  aElw := aQuote.Symbol as TElw;
  Q := gEnv.Engine.SymbolCore.k200DR;

  F := aElw.ConvRatio;

  aUnderType := eutIndex;

  if aElw.Underlying.Code <> '01' then
  begin
    aSymbol := aElw.Underlying as TStock;
    bQuote  := aSymbol.Quote as TQuote;

    dLast := aQuote.Asks[0].Price;
    dUnderLast := bQuote.Asks[0].Price;

    dLast2 := aQuote.Bids[0].Price;
    dUnderLast2 := bQuote.Bids[0].Price;

    Q := aSymbol.DividendPrice;// .DividendRate;
    aUnderType := eutStock;
  end;

  // Elw
  iAskLpVol := aQuote.Asks[0].LpVolume;
  iBidLpVol := aQuote.Bids[0].LpVolume;
  iAskVol := aQuote.Asks[0].Volume;
  iBidVol := aQuote.Bids[0].Volume;

  // 기초
  iAskVol2 := bQuote.Asks[0].Volume;
  iBidVol2 := bQuote.Bids[0].Volume;

  if ( dLast < EPSILON ) or ( dUnderLast < EPSILON ) or
     ( dLast2 < EPSILON ) or ( dUnderLast2 <  EPSILON ) then
     Exit;


  for k := 0 to 5 - 1 do
  begin
    Asks[k] := bQuote.Asks[k].Price;
    Bids[k] := bQuote.Bids[k].Price;
    AskVols[k]  := bQuote.Asks[k].Volume;
    BidVols[k]  := bQuote.Bids[k].Volume;
  end;

  dWAvgPrice  :=GetWeightAvgPrice2( aQuote.Asks[0].Price, aQuote.Bids[0].Price,
    aQuote.Asks[0].Volume, aQuote.Bids[0].Volume );

  dWAvgPrice2 :=GetWeightAvgPrice2( bQuote.Asks[0].Price, bQuote.Bids[0].Price,
    bQuote.Asks[0].Volume, bQuote.Bids[0].Volume );

  d5StepPrice := Get5StepWeigthPrice( Asks, Bids, AskVols, BidVols );




  E := aElw.StrikePrice;
  R := (Future as TFuture).CDRate;
  ExpireDateTime := GetQuoteDate + aElw.DaysToExp - 1 + EncodeTime(15,0,0,0);
  T := gEnv.Engine.Holidays.CalcTimeToExp(GetQuoteTime, ExpireDateTime);
  FixT := gEnv.Engine.Holidays.CalcTimeToExp(GetQuoteDate + EncodeTime(9,0,0,0), ExpireDateTime);
  //T := gEnv.Engine.Holidays.CalcDaysToExp2(GetQuoteTime, ExpireDateTime );
  TC := aElw.DaysToExp / 365;


  if aElw.CallPut = 'C' then
    W := 1
  else
    W := -1;
  {
  BS_Vanilla_Greeks(gType : TGreeksType;
     U, E, R, Q, V, T, TC, TR, W: Double) : Double;  // TR 전환비율  Q 배당률
  }

  // 기초매도 가중치에 델파값을 인자를 주기 위해
  //
  aAskIV := GetIV( aUnderType, dUnderLast, dLast  );
  dDelta := ELW_Greeks_KIS( W, aUnderType, gtDelta, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
  //dDelta := BS_Vanilla_Greeks( gtDelta, dUnderLast, E, R, Q, aAskIV, T, TC, aElw.ConvRatio, W );
  dLow  := 1000;
  dSum  := 0;
  da    := -1;

  dPrice := ELW_Greeks_KIS( W, aUnderType, gtPrice, dUnderLast, 0,0,0,0, E, R, T, aASkIV, Q, F);
  d1 := 0.2;


  //
  // 기초매수 가중치
  dWCIV  := GetIV( aUnderType, dUnderLast2 , dLast2);
  dBidWeightPRice:= GetAskWeightPrice( aUnderType, aElw.ConvRatio, aQuote,  bQuote, dWCIV );
  // 기초매도 가중치
  dWCIV  := GetIV( aUnderType, dUnderLast , dLast);
  dAskWeightPrice := GetBidWeightPrice( aUnderType, aElw.ConvRatio, aQuote,  bQuote, dWCIV );
  {
{
S  = 종가
X = 행사가
R = 이자율
T = 잔존일 ( 시간 ) 분단위
D = 이산배당금
F = 전환비율

function BS_Vanilla_Greeks_KIS(gType : TGreeksType; S, X, R, T, V, D,F,
    S1,S2,S3,S4, W : Double) : Double ;


  VLM1  := GetIV( aUnderType, dWAvgPrice2, dLast-5);
  VHM1  := GetIV( aUnderType, dWAvgPrice2 , dLast);
  VLD1  := GetIV2( aUnderType, dWAvgPrice2, dLast-5);
  VHD1  := GetIV2( aUnderType, dWAvgPrice2 , dLast);
  VLM2  := GetIV( aUnderType, d5StepPrice, dLast-5);
  VHM2  := GetIV( aUnderType, d5StepPrice , dLast);
  VLD2  := GetIV2( aUnderType, d5StepPrice, dLast-5);
  VHD2  := GetIV2( aUnderType, d5StepPrice , dLast);
  // 기초매도 가중치
  VLM3  := GetIV( aUnderType, dAskWeightPrice, dLast-5);
  VHM3  := GetIV( aUnderType, dAskWeightPrice , dLast);
  VLD3  := GetIV2( aUnderType, dAskWeightPrice, dLast-5);
  VHD3  := GetIV2( aUnderType, dAskWeightPrice , dLast);

{
  aAskIV := GetIV( aUnderType, dUnderLast, dLast  );
  aBidIV := GetIV( aUnderType, dUnderLast2, dLast2  );
  dWCIV  := GetIV( aUnderType, bQuote.Last, dWAvgPrice  );
  dWWIV  := GetIV( aUnderType, dWAvgPrice2, dWAvgPrice );
  dAvg   := GetIV( aUnderType, bQuote.Last, (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2 );
  dAvg2  := GetIV( aUnderType, dWAvgPrice2, (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2 );
  // ask
  dDelta := ELW_Greeks_KIS( W, aUnderType, GtDelta, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
  dGamma  := ELW_Greeks_KIS( W, aUnderType, GtGamma, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
  dTheta  := ELW_Greeks_KIS( W, aUnderType, GtTheta, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
  dVega   := ELW_Greeks_KIS( W, aUnderType, GtVega, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
  dRho    := ELW_Greeks_KIS( W, aUnderType, GtRho, dUnderLast, 0,0,0,0, E, R, T, aAskIV, Q, F );
}
  {
  dDelta := BS_Vanilla_Greeks( gtDelta, dUnderLast, E, R, Q, aAskIV, T, TC, aElw.ConvRatio, W );
  dGamma := BS_Vanilla_Greeks( gtGamma, dUnderLast, E, R, Q, aAskIV, T, TC, aElw.ConvRatio, W );
  dTheta := BS_Vanilla_Greeks( gtTheta, dUnderLast, E, R, Q, aAskIV, T, TC, aElw.ConvRatio, W );
  dVega  := BS_Vanilla_Greeks( gtVega , dUnderLast, E, R, Q, aAskIV, T, TC, aElw.ConvRatio, W );
  }
  // bid
  {
  dDelta2 := ELW_Greeks_KIS( W, aUnderType, GtDelta, dUnderLast2, 0,0,0,0, E, R, T, aBidIV, Q, F );
  dGamma2  := ELW_Greeks_KIS( W, aUnderType, GtGamma, dUnderLast2, 0,0,0,0, E, R, T, aBidIV, Q, F );
  dTheta2  := ELW_Greeks_KIS( W, aUnderType, GtTheta, dUnderLast2, 0,0,0,0, E, R, T, aBidIV, Q, F );
  dVega2   := ELW_Greeks_KIS( W, aUnderType, GtVega, dUnderLast2, 0,0,0,0, E, R, T, aBidIV, Q, F );
  dRho2    := ELW_Greeks_KIS( W, aUnderType, GtRho, dUnderLast2, 0,0,0,0, E, R, T, aBidIV, Q, F );

  {
  dDelta2:= BS_Vanilla_Greeks( gtDelta, dUnderLast2, E, R, Q, aBidIV, T, TC, aElw.ConvRatio, W );
  dGamma2:= BS_Vanilla_Greeks( gtGamma, dUnderLast2, E, R, Q, aBidIV, T, TC, aElw.ConvRatio, W );
  dTheta2:= BS_Vanilla_Greeks( gtTheta, dUnderLast2, E, R, Q, aBidIV, T, TC, aElw.ConvRatio, W );
  dVega2 := BS_Vanilla_Greeks( gtVega , dUnderLast2, E, R, Q, aBidIV, T, TC, aElw.ConvRatio, W );
  }

  //Ask-Delta, Bid-Delta, Ask-Gamma, Bid-Gamma, Ask-Vega, Bid-Vega, Ask-Theta, BidTheta
  stLog := '['+FormatDateTime('hh:nn.ss.zzz', GetQuoteTime)+']'+
  {
    ',' + Format('%.5f', [ aAskIV  ]) +
    ',' + Format('%.5f', [ aBidIV ]) +
    ',' + Format('%.5f', [ dWCIV  ]) +
    ',' + Format('%.5f', [ dWWIV ]) +

    ',' + Format('%.5f', [ dAvg  ]) +
    ',' + Format('%.5f', [ dAvg2 ]) +

    ',' + Format('%.5f', [ dDelta  ]) +
    ',' + Format('%.5f', [ dDelta2 ]) +

    ',' + Format('%.4f', [ dGamma  ]) +
    ',' + Format('%.4f', [ dGamma2 ]) +

    ',' + Format('%.4f', [ dVega  ]) +
    ',' + Format('%.4f', [ dVega2 ]) +
(aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2
    ',' + Format('%.4f', [ dTheta  ]) +
    ',' + Format('%.4f', [ dTheta2 ]) +


    ',' + Format('%.5f', [ VLM1  ]) +
    ',' + Format('%.5f', [ VHM1  ]) +
    ',' + Format('%.5f', [ VLD1  ]) +
    ',' + Format('%.5f', [ VHD1  ]) +
    ',' + Format('%.5f', [ VLM2  ]) +
    ',' + Format('%.5f', [ VHM2  ]) +
    ',' + Format('%.5f', [ VLD2  ]) +
    ',' + Format('%.5f', [ VHD2  ]) +
    ',' + Format('%.5f', [ VLM3  ]) +
    ',' + Format('%.5f', [ VHM3  ]) +
    ',' + Format('%.5f', [ VLD3  ]) +
    ',' + Format('%.5f', [ VHD3  ]) +


    ',' + Format('%.5f', [ aAskIV  ]) +
    ',' + Format('%.5f', [ dDelta  ]) +
    //',' + Format('%.5f', [ aItem.V  ]) +
    ',' + Format('%.5f', [ dTmp  ]) +
    ',' + Format( '%.4f',[ dLast] ) +
    ',' + Format( '%.4f',[ da ] ) +

}
    ',' + IntToStr( iAskLpVol ) +
    ',' + IntToStr( iAskVol ) +
    ',' + Format('%.0f', [ dLast ] ) +
    ',' + Format('%.0f', [ aQuote.Last ]) +
    ',' + Format('%.2f', [ dWAvgPrice ]) +
    ',' + Format('%.2f', [ (aQuote.Asks[0].Price + aQuote.Bids[0].Price)/2 ]) +
    ',' + Format('%.0f', [ dLast2 ] ) +
    ',' + IntToStr( iBidVol ) +
    ',' + IntToStr( iBidLpVol ) +

    ',' + IntToStr( iAskVol2 ) +
    ',' + Format('%.2f', [ dUnderLast ] ) +
    ',' + Format('%.2f', [ bQuote.Last ]) +
    ',' + Format('%.4f', [ dWAvgPrice2 ]) +
    ',' + Format('%.4f', [ d5StepPrice ]) +
    ',' + Format('%.4f', [ dAskWeightPrice ]) +
    ',' + Format('%.4f', [ dBidWeightPrice ]) +
    ',' + Format('%.2f', [ dUnderLast2 ] ) +
    ',' + IntToStr( iBidVol2 ) +


    ',' + Format('%f', [aElw.StrikePrice ]) +

    ',' + Format('%d', [aElw.DaysToExp ]) +
    ',' + Format('%.4f', [T]) +
    ',' + Format('%.4f', [TC]) +
    ',' + Format('%.5f', [ aElw.ConvRatio ]) +
    ',' + Format('%.8f', [ aElw.DiscretDividend ])
    ;

  aLog.ExcelLog.LogData( stLog, aLog.Index );
  inc( aLog.Index );

end;

procedure TElwIv.DoQuote2(aQuote: TQuote; aLog: TElwIVItem);
var
  bQuote  : TQuote;
  dLast, dUnderLast, dUnderLast2, dLast2,
  Q, F, E, R, T, TC, FixT, W,
  dWAvgPrice, dWAvgPrice2, d5StepPrice, dAskWeightPrice,
  dWCIV,

  d1, dTmp :double;
  dLow : array [0..4] of double;
  da   : array [0..4] of double;

  aElw : TElw;
  aSymbol : TStock;

  aUnderType : TElwUnderlyingType;
  ExpireDateTime : TDateTime;

  k, i, j  : integer;
  ii : array [0..4] of integer;

  // add variables
  Asks : array [0..4] of double;
  Bids : array [0..4] of double;
  Askvols : array [0..4] of integer;
  BidVols : array [0..4] of integer;

  aItem : TElwDetailItem;

  function GetIV( uType : TElwUnderlyingType; _U, _C : double) : Double;
  begin
    REsult := ELW_Bisection_ImpVol( W, uType, _U, 0, 0, 0, 0, E, R, T, _C, Q, F );
  end;

begin
  bQuote := Future.Quote as TQuote;

  dLast2 := aQuote.Asks[0].Price;
  dUnderLast2 := bQuote.Asks[0].Price;

  dLast := aQuote.Bids[0].Price;
  dUnderLast := bQuote.Bids[0].Price;

  aElw := aQuote.Symbol as TElw;
  Q := gEnv.Engine.SymbolCore.k200DR;

  F := aElw.ConvRatio;

  aUnderType := eutIndex;

  if aElw.Underlying.Code <> '01' then
  begin
    aSymbol := aElw.Underlying as TStock;
    bQuote  := aSymbol.Quote as TQuote;

    dLast2 := aQuote.Asks[0].Price;
    dUnderLast2 := bQuote.Asks[0].Price;

    dLast := aQuote.Bids[0].Price;
    dUnderLast := bQuote.Bids[0].Price;

    Q := aSymbol.DividendPrice;// .DividendRate;
    aUnderType := eutStock;
  end;


  if ( dLast < EPSILON ) or ( dUnderLast < EPSILON ) or
     ( dLast2 < EPSILON ) or ( dUnderLast2 <  EPSILON ) then
     Exit;


  for k := 0 to 5 - 1 do
  begin
    Asks[k] := bQuote.Asks[k].Price;
    Bids[k] := bQuote.Bids[k].Price;
    AskVols[k]  := bQuote.Asks[k].Volume;
    BidVols[k]  := bQuote.Bids[k].Volume;
  end;

  dWAvgPrice  :=GetWeightAvgPrice2( aQuote.Asks[0].Price, aQuote.Bids[0].Price,
    aQuote.Asks[0].Volume, aQuote.Bids[0].Volume );

  // 기초가중치
  dWAvgPrice2 :=GetWeightAvgPrice2( bQuote.Asks[0].Price, bQuote.Bids[0].Price,
    bQuote.Asks[0].Volume, bQuote.Bids[0].Volume );

  // 5 가중치
  d5StepPrice := Get5StepWeigthPrice( Asks, Bids, AskVols, BidVols );




  E := aElw.StrikePrice;
  R := (Future as TFuture).CDRate;
  ExpireDateTime := GetQuoteDate + aElw.DaysToExp - 1 + EncodeTime(15,0,0,0);
  T := gEnv.Engine.Holidays.CalcTimeToExp(GetQuoteTime, ExpireDateTime);
  FixT := gEnv.Engine.Holidays.CalcTimeToExp(GetQuoteDate + EncodeTime(9,0,0,0), ExpireDateTime);
  TC := aElw.DaysToExp / 365;


  if aElw.CallPut = 'C' then
    W := 1
  else
    W := -1;

  dWCIV  := GetIV( aUnderType, dWAvgPrice2 , dLast);
  // 기초매도 가중치
  dAskWeightPrice := GetBidWeightPrice( aUnderType, aElw.ConvRatio, aQuote,  bQuote, dWCIV );

  d1 := 0.2;

  with aLog do
  begin

    for j := 0 to High(AVal1) do
    begin
      dTmp := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dUnderLast, 0,0,0,0, E, R, T, d1, Q, F)/5)*5;
      AVal1[j] := AVal1[j] + abs( dTmp - dLast ) ;

      dTmp := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, bQuote.Last, 0,0,0,0, E, R, T, d1, Q, F)/5)*5;
      AVal2[j] := AVal2[j] + abs( dTmp - dLast ) ;

      dTmp := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dWAvgPrice2, 0,0,0,0, E, R, T, d1, Q, F)/5)*5;
      AVal3[j] := AVal3[j] + abs( dTmp - dLast ) ;

      dTmp := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, d5StepPrice, 0,0,0,0, E, R, T, d1, Q, F)/5)*5;
      AVal4[j] := AVal4[j] + abs( dTmp - dLast ) ;

      dTmp := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dAskWeightPrice, 0,0,0,0, E, R, T, d1, Q, F)/5)*5;
      AVal5[j] := AVal5[j] + abs( dTmp - dLast ) ;

      d1 := d1 + 0.0001;

    end;

    for i := 0 to 4 do
    begin
      ii[i] := 0;
      da[i] := 0.2;
    end;
    dLow[0] := AVal1[0];
    dLow[1] := AVal2[0];
    dLow[2] := AVal3[0];
    dLow[3] := AVal4[0];
    dLow[4] := AVal5[0];

    d1 := 0.2 ;
    for j := 0 to High( AVal1 ) do
    begin
      if dLow[0] > AVal1[j] then
      begin
        dLow[0]  := AVal1[j];
        da[0]    := d1;
        ii[0] := j;
      end;

      if dLow[1] > AVal2[j] then
      begin
        dLow[1]  := AVal2[j];
        da[1]    := d1;
        ii[1] := j;
      end;

      if dLow[2] > AVal3[j] then
      begin
        dLow[2]  := AVal3[j];
        da[2]    := d1;
        ii[2] := j;
      end;

      if dLow[3] > AVal4[j] then
      begin
        dLow[3]  := AVal4[j];
        da[3]    := d1;
        ii[3] := j;
      end;

      if dLow[4] > AVal5[j] then
      begin
        dLow[4]  := AVal5[j];
        da[4]    := d1;
        ii[4] := j;
      end;
      d1 := d1 + 0.0001;
    end;


    for i := 0 to 4 do
    begin
      if (ii[i] = -1) then
        ii[i] := -1;
      if (da[i] = -1) then
        da[i] := -1;
    end;

    aItem := aLog.ElwItem.New( GetQuoteTime );
   {
    for i := 0 to 5 - 1 do
      da[i] := 0.272;
   }
    aItem.PreVal[0] := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dUnderLast, 0,0,0,0, E, R, T, da[0], Q, F)/5)*5;
    aItem.PreVal[1] := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, bQuote.Last, 0,0,0,0, E, R, T, da[1], Q, F)/5)*5;
    aItem.PreVal[2] := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dWAvgPrice2 , 0,0,0,0, E, R, T, da[2], Q, F)/5)*5;
    aItem.PreVal[3] := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, d5StepPrice , 0,0,0,0, E, R, T, da[3], Q, F)/5)*5;
    aItem.PreVal[4] := ceil(ELW_Greeks_KIS( W, aUnderType, gtPrice, dAskWeightPrice , 0,0,0,0, E, R, T, da[4], Q, F)/5)*5;

    for i := 0 to 4 do
    begin
      aItem.Differ[i] := abs( aItem.PreVal[i] - dLast );
      aItem.A[i] := da[i];
    end;

    aItem.AVal[0]  := AVal1[ii[0]];
    aItem.AVal[1]  := AVal2[ii[1]];
    aItem.AVal[2]  := AVal3[ii[2]];
    aItem.AVal[3]  := AVal4[ii[3]];
    aItem.AVal[4]  := AVal5[ii[4]];

    //
    aItem.W := W;
    aItem.E := E;
    aItem.R := R;
    aItem.T := T;
    aItem.F := F;
    aItem.Q := Q;
    aItem.Last := dLast;
    aItem.UnderLast := dUnderLast;
    aItem.UnderCur  := bQuote.Last;
    aItem.WAvgPrice := dWAvgPrice2 ;
    aItem.Step5Price:= d5StepPrice ;
    aItem.AskWPrice := dAskWeightPrice;
    aItem.UnderType := aUnderType;
  end;

end;

procedure TElwIv.Fin;
begin
  gEnv.Engine.QuoteBroker.Cancel( Self );
end;

procedure TElwIv.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TElwIv.FormCreate(Sender: TObject);

begin
  //
  Logs  := TCollection.Create( TElwIvItem );
  Future  := gEnv.Engine.SymbolCore.Future;

  gEnv.Engine.SymbolCore.CalcTotDividendRate;
  plDr.Caption  := 'DR : ' + Format('%.4f', [gEnv.Engine.SymbolCore.k200DR] );



  //gEnv.testcount := 0;
  //gEnv.MaxCount := -1;
end;

procedure TElwIv.FormDestroy(Sender: TObject);
begin
  Logs.Free;
  Fin;
end;



procedure TElwIv.k200init;
var
  i, j : Integer;
  aSymbol, bSymbol : TSymbol;
  aQuote : TQuote;
  aItem : TElwIvItem;
  stName : string;
begin
  with gEnv.Engine.SymbolCore do
    for i:=0 to Indexes.Count -1 do
    begin
      aSymbol := Indexes[i] as TSymbol;
      if aSymbol.Code <> '01' then Continue;
      for j := 0 to aSymbol.DerivativeList.Count - 1 do
      begin
        bSymbol := TSymbol( aSymbol.DerivativeList.Items[j]);
        // 멜츠 00010   신한 00002   대우 000005   우리 00012  유진 00008 맥쿼리  00035
        // 00037 씨티   00016 하나   00024 동양    00030 삼성  00003 한국증권

        if ((bSymbol as TElw).LPCode = '00010') or
           ((bSymbol as TElw).LPCode = '00005') or
           ((bSymbol as TElw).LPCode = '00030') //or
           {((bSymbol as TElw).LPCode = '00024') or
           ((bSymbol as TElw).LPCode = '00003') }then begin
        {
        if (bSymbol.Name = '삼성9131KOSPI200콜') or
          (bSymbol.Name = '삼성9132KOSPI200콜') or
          (bSymbol.Name = '삼성9133KOSPI200콜') or
          (bSymbol.Name = '삼성9134KOSPI200콜') or
          (bSymbol.Name = '삼성9135KOSPI200콜')
        then begin}
          aQuote := gEnv.Engine.QuoteBroker.SubscribeElw( self, bSymbol, QuoteProc);
          aItem := TElwIvItem( Logs.Add );
          aItem.BInit( aQuote );
          stName  := Format('ElwIV_%s', [ aQuote.Symbol.Name ]);
          aItem.ExcelLog.LogInit( stName, stTitle2);

          {
        if ((bSymbol as TElw).LPCode = '00010') then
          aItem.ExcelLog.LogInit( stName, stTitle4)
        else if ((bSymbol as TElw).LPCode = '00005') then
          aItem.ExcelLog.LogInit( stName, stTitle3)
        else
         aItem.ExcelLog.LogInit( stName, stTitle3);
         }

        end;
      end;
    end;

end;

procedure TElwIv.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aLog : TElwIVITem;
    aQuote : TQuote;
begin
  if (DataObj = nil)  or ( Receiver <> self ) then
    Exit;

  aQuote := DataObj as TQuote;
  aLog := FindLog( aQuote );

  if aLog <> nil then
    DoQuote( aQuote, aLog );

end;


procedure TElwIv.stockinit;
var
  i, j : integer;
  aSymbol , bSymbol : TSymbol;
  aItem : TElwIvItem;
  aQuote : TQuote;
  stName : string;
begin

  with gEnv.Engine.SymbolCore do
    for I := Stocks.Count-1  downto 0 do
    begin
      aSymbol := Stocks[i] as TSymbol;
      if aSymbol.DoSubscribe then
      begin
        gEnv.Engine.QuoteBroker.Subscribe( self, aSymbol, gEnv.Engine.QuoteBroker.DummyEventHandler);
        for j := 0 to aSymbol.DerivativeList.Count - 1 do begin
          bSymbol := TSymbol(aSymbol.DerivativeList.Items[j]);

 //         if bSymbol.Name = '대우9234NC소프트콜' then
 //         begin

        if ((bSymbol as TElw).LPCode = '00010') or
           ((bSymbol as TElw).LPCode = '00005') or
           ((bSymbol as TElw).LPCode = '00030') //or
           {((bSymbol as TElw).LPCode = '00024') or
           ((bSymbol as TElw).LPCode = '00003') }then begin

       // if bSymbol.Name = '메리츠9106KOSPI200콜' then
       // begin
            aQuote := gEnv.Engine.QuoteBroker.SubscribeElw( self, bSymbol,
                  QuoteProc);
            aItem := TElwIvItem( Logs.Add );
            aItem.BInit( aQuote );
            stName  := Format('ElwIV_%s', [ aQuote.Symbol.Name ]);
            aItem.ExcelLog.LogInit( stName, stTitle2);
            {
            if ((bSymbol as TElw).LPCode = '00010') then
              aItem.ExcelLog.LogInit( stName, stTitle4)
            else if ((bSymbol as TElw).LPCode = '00005') then
              aItem.ExcelLog.LogInit( stName, stTitle3)
            else
             aItem.ExcelLog.LogInit( stName, stTitle3);
             }
          end;

        end;
      end;
    end;

end;

function TElwIv.FindLog( aQuote: TQuote ) : TElwIvItem;
var
  i : integer;
begin
  Result := nil;
  for i := 0 to Logs.Count - 1 do
    if TElwIvItem( Logs.Items[i]).Quote = aQuote then
    begin
      Result :=  TElwIvItem( Logs.Items[i]);
      break;
    end;

end;

{ TElwIvItem }

procedure TElwIvItem.BInit(aquote: TQuote);
var
  d : double;
  iTick , i, iDan, iDan2 : integer;
  stLog : string;
  aElw : TElw;
  dLast: double;
begin
  Quote := aQuote;
  aElw  := Quote.Symbol as TElw;
  //Quote.Symbol.
  if aElw.Underlying.Code = '01' then
    dLast := gEnv.Engine.SymbolCore.Future.Last
  else
    dLast := aElw.Underlying.Last;

  iTick := GetTickSize( dLast );
  stLog :=  Format('%.0f', [ dLast ])  ;
  iDan  := 100;//GetValSize( Length( stLog  ));

  if aElw.Underlying.Code = '01' then
    iDan  := 100
  else
    iDan  := GetValSize( Length( stLog  ));

  //dTick := iTick / iDan;
  dDan  := 1  / iDan;
  dTick := dDan / 500 ;

  d := -1*dDan;
  i := 0;
  while d <= dDan do
  begin
    d := d + dTick;
    inc(i);
  end;

  SetLength( BVal1, i );
  SetLength( BVal2, i );
  SetLength( BVal3, i );
  SetLength( BVal4, i );
  SetLength( BVal5, i );

end;

constructor TElwIvItem.Create(aColl: TCollection);
var
  d : double;
  i : integer;
begin
  inherited;
  ExcelLog  := TExcelLog.Create;
  ElwItem   := TElwItem.Create;
  Quote     := nil;
  Index     := 0;

  d := 0.2;
  i := 0;
  while d <= 1 do
  begin
    d := d + 0.0001;
    inc(i);
  end;

  SetLength( AVal1, i );
  SetLength( AVal2, i );
  SetLength( AVal3, i );
  SetLength( AVal4, i );
  SetLength( AVal5, i );



end;

destructor TElwIvItem.Destroy;
begin
  ExcelLog.Free;
  ElwItem.Free;

  inherited;
end;

function TElwIvItem.GetTickSize(dPrice: Double): integer;
begin

  if dPrice > 500000.0 - EPSILON then
    Result := 1000
  else if dPrice > 100000 - EPSILON then
    Result := 500
  else if dPrice > 50000 - EPSILON then
    Result := 100
  else if dPrice > 10000 - EPSILON then
    Result := 50
  else if dPrice > 5000 - EPSILON then
    Result := 10
  else
    Result := 5;
end;

function TElwIvItem.GetValSize(iLen : integer): integer;
var
  i : integer;
begin

  Result := 1;
  for i := 0 to iLen - 1 do
    Result := Result * 10;

end;

{ TElwItem }

constructor TElwItem.Create;
begin
  inherited Create( TElwDetailITem );
end;

destructor TElwItem.Destroy;
begin

  inherited;
end;

function TElwItem.GetElwItem(i: integer): TElwDetailItem;
begin
  if ( i < 0)  or (i >= Count) then
    Result := nil
  else
    Result := Items[i] as TElwDetailItem;
end;

function TElwItem.New(dtTime: TDateTime): TElwDetailItem;
begin
  Result := Add as TElwDetailITem;
  Result.Time := dtTime;
end;

initialization
  RegisterClass( TElwIv );

Finalization
  UnRegisterClass( TElwIv )

end.
