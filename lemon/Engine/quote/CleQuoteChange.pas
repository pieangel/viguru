unit CleQuoteChange;

interface

uses
  Classes, SysUtils, DateUtils, Math,

  GleTypes, GleConsts, CleMarketSpecs,

  CleQuoteChangeData

  ;

const
  CHK_PRICE = 0.0001     ;

type

  TQuoteChangeBase = class( TCollectionItem )
  private
    FMoveSize: integer;
    FSpread: integer;
    FTime: TDateTime;
  public
    property Spread   : integer  read FSpread  write FSpread;
    property Movesize : integer read FMoveSize write FMoveSize;
    property Time     : TDateTime read FTime  write FTime;
  end;


  TQuoteChangeItem = class( TQuoteChangeBase )
  private
    FSide: integer;
    FPrice: double;
    FRctCnt: integer;
    FRctSum: integer;
    FRmvVol: integer;
    FAskPrice: double;
    FPrevBid: double;
    FPrevAsk: double;
    FBidPrice: double;
    FFillVol: integer;
  public
    EndTime  : TDateTime;
    LastTime : TDateTime;
    Sent     : boolean;
    NewData  : boolean;

    LongTermVol : array [0..1] of integer;
    ShortTermVol: array [0..1] of integer;

    LongTermCnt : array [0..1] of integer;
    ShortTermCnt: array [0..1] of integer;

    Constructor Create( aColl : TCollection ); override;
    property Price : double read FPrice write FPrice;
    property Side : integer read FSide write FSide;

    property RctSum : integer read FRctSum;
    property RctCnt  : integer read FRctCnt;
    property RmvVol  : integer read FRmvVol;

    // 로그용 변수들
    property PrevAsk : double read FPrevAsk;
    property PrevBid : double read FPrevBid;
    property AskPrice: double read FAskPrice;
    property BidPrice: double read FBidPrice;

    property FillVol : integer read FFillVol;
    //

    function IaAccumulData( dtTime : TDateTime; var idx : integer ) : boolean;
    procedure init;

  end;

  TQuoteChange  = class( TCollection )
  private
    FQuote: TObject;
    FConfig: TCatchConfig;
    FOnCatchEvent: TNotifyEvent;
    FOnStateEvent: TGetStrProc;
    FLastData: TQuoteChangeItem;
    FStart  : boolean;

    procedure SetConfig(const Value: TCatchConfig);
    function New( dtTime : TDateTime ) :  TQuoteChangeItem;

    procedure SetStart(const Value: boolean);
  public

    constructor Create( aQuote : TObject ); overload;
    destructor  Destroy; override;

    property Quote  : TObject read FQuote;
    property Config : TCatchConfig read FConfig write SetConfig;

    property OnCatchEvent : TNotifyEvent read FOnCatchEvent write FOnCatchEvent;
    property OnStateEvent : TGetStrProc  read FOnStateEvent write FOnStateEvent;
    property LastData     : TQuoteChangeItem read FLastData write FLastData;
    property Start        : boolean read FStart write SetStart;

    procedure CheckChange;
    procedure CheckFillSum;
    procedure CalcChange;
  end;


implementation

uses
  CleQuoteBroker, GAppEnv, GleLib
  ;




{ TQuoteChange }

procedure TQuoteChange.CalcChange;
var
  aQuote : TQuote;
  idx , iSide, iRmvQty   : integer;
  bRes   : boolean;
  stPrice, stLog  : string;
  iRecentCtcFill, iRecentCtcFillCnt : integer;
begin

  if FLastData.Sent then
  begin
    FLastData.NewData := false;
    Exit;
  end;

  aQuote  := FQuote as TQuote;
  bRes := FLastData.IaAccumulData( aQuote.LastQuoteTime, idx );

  if not bRes then
  begin
    FLastData.NewData := false;
    Exit;
  end;

  FLastData.init;



  with FLastData do
  begin

    iRmvQty :=   ifThen( MoveSize < 0,
      aQuote.Bids[0].Volume, aQuote.Asks[0].Volume );

    aQuote.GetTermVolNCnt( LongTermVol, ShortTermVol, LongTermCnt, ShortTermCnt,
      Format('%.2f', [Price]), Side, FConfig.Nms, Time
      );

    iRecentCtcFill  := ifThen( Side < 0, ShortTermVol[0] + ShortTermVol[1], LongTermVol[0] + LongTermVol[1] );
    iRecentCtcFillCnt := ifThen( Side < 0, ShortTermCnt[0], LongTermCnt[0] );

    if ( iRecentCtcFill >= FConfig.FillSum ) and
       ( iRecentCtcFillCnt >= FConfig.FillCnt ) and
       ( iRmvQty < FConfig.MaxQuoteQty )  then
    begin

      FRctSum := iRecentCtcFill;
      FRctCnt := iRecentCtcFillCnt;
      FRmvVol := iRmvQty;
      LastTime:= aQuote.LastQuoteTime;

      if( FConfig.UseRemVol ) and ( iRecentCtcFill > iRmvQty) then
      begin
        if Assigned( FOnCatchEvent ) then
          FOnCatchEvent( FLastData );
      end
      else if not FConfig.UseRemVol then
        if Assigned( FOnCatchEvent ) then
          FOnCatchEvent( FLastData );


      if Sent then
      begin
        stLog := Format('[%s:%s], %s, %.2f, %.2f->%.2f|%.2f->%.2f,  l:%d(%d),%d(%d) s:%d(%d),%d(%d) , vol:%d > %d',
          [
            FormatDateTime('hh:nn:ss.zzz', Time ),
            FormatDateTime('hh:nn:ss.zzz', Endtime ),
            ifThenStr( Side > 0 , 'L', 'S'),
            Price,

            FPrevAsk,
            FAskPrice,
            FPrevBid,
            FBidPrice,

            LongTermVol[0],
            LongTermCnt[0],
            LongTermVol[1],
            LongTermCnt[1],

            ShortTermVol[0],
            ShortTermCnt[0],
            ShortTermVol[1],
            ShortTermCnt[1],
            iRecentCtcFill,
            iRmvQty
          ]);
        gEnv.EnvLog( WIN_CATCH, stLog,false, aQuote.Symbol.ShortCode);
      end;

    end;
  end;

end;

procedure TQuoteChange.CheckChange;
var
  aQuote  : TQuote;
  iMoveSize, iSpread, iRemoveVol: integer;
  stLog : string;
  iRecentCtcFill, iRecentCtcFillCnt : integer;
begin
  if not FStart then Exit;
  if FQuote = nil then Exit;

  aQuote  := FQuote as TQuote;

  if ( aQuote.LastEvent <> qtTimeNSale  ) or (not aQuote.CtcCheckPrice) then
    Exit;

  iSpread := -1;
  iMoveSize := aQuote.CtcGetMoveSize( iSpread );

  // movesize 가 - 이면 다운... 매도 체결인것이지
  if ( abs(iMoveSize) = 2)  and ( iSpread = 1 ) then
  begin
    iRemoveVol    := ifThen( iMoveSize < 0,
      aQuote.Bids[0].Volume, aQuote.Asks[0].Volume );

    //FLastData := New( aQuote.LastQuoteTime );
    with FLastData do
    begin
      Time      := aQuote.LastQuoteTime;
      FMoveSize := iMoveSize;
      FSpread   := iSpread;
      FPrice    := aQuote.Sales.Last.Price;
      FSide     := aQuote.Sales.Last.Side;
      FRmvVol   := iRemoveVol;
      Endtime   := IncMilliSecond( aQuote.LastQuoteTime, FConfig.Nms * 2 );

      FPrevAsk  := aquote.PrevAsks[0].Price;
      FPrevBid  := aQuote.PrevBids[0].Price;
      FAskPrice := aQuote.Asks[0].Price;
      FBidPrice := aQuote.Bids[0].Price;

      FFillVol  := aQuote.Sales.Last.Volume;
      NewData   := true;
      Sent      := false;
    end;
  end;

  if FLastData.NewData then
    CalcChange;
end;



procedure TQuoteChange.CheckFillSum;
begin

end;

constructor TQuoteChange.Create(aQuote: TObject);
begin
  inherited Create( TQuoteChangeItem );
  FQuote  := aQuote;
  FLastData := New( now );
  FLastData.NewData := false;

end;


destructor TQuoteChange.Destroy;
begin

  inherited;
end;


function TQuoteChange.New(dtTime: TDateTime): TQuoteChangeItem;
begin
  Result  := Add as TQuoteChangeItem;
  Result.Time := dtTime;
end;

procedure TQuoteChange.SetConfig(const Value: TCatchConfig);
begin
  FConfig := Value;
end;

procedure TQuoteChange.SetStart(const Value: boolean);
begin
  FStart := Value;
  FLastData.NewData := false;
  if not FStart  then
  begin
    OnCatchEvent  := nil;
    OnStateEvent  := nil;
   // Clear;
  end;

end;


{ TQuoteChangeItem }

constructor TQuoteChangeItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);

  LongTermVol[0]  := 0;
  LongTermVol[1]  := 0;

  ShortTermVol[0] := 0;
  ShortTermVol[1] := 0;

  LongTermCnt[0] := 0;
  LongTermCnt[1] := 0;
  ShortTermCnt[0]:= 0;
  ShortTermCnt[1]:= 0;

  EndTime  := 0;
  Sent     := false;

end;



function TQuoteChangeItem.IaAccumulData(dtTime : TDateTime; var idx: integer): boolean;
var
  iRes : integer;
begin
  Result := false;
  if dtTime > EndTime then
    Exit;

  result := true;
end;

procedure TQuoteChangeItem.init;
begin
  LongTermVol[0]  := 0;
  LongTermVol[1]  := 0;

  ShortTermVol[0] := 0;
  ShortTermVol[1] := 0;

  LongTermCnt[0] := 0;
  LongTermCnt[1] := 0;
  ShortTermCnt[0]:= 0;
  ShortTermCnt[1]:= 0;
end;

end.
