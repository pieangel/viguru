unit CleQuoteResearch;

interface

uses
  Classes, SysUtils, DateUtils,

  CleQuoteBroker, CleSymbols, CleDistributor, ClePriceItems,

  GleTypes, GleLib, GleConsts

  ;

const
  OrdCnt = 6;
  OrdType : array [0..OrdCnt-1] of string
    = ( 'L', 'S', 'Lx', 'Sx', 'Lc', 'Sc' );

type

  TSearchType = ( stNone, stAdd, stUpdate, stDel );

  TFillter = record
    SisSec  : integer;
    SisCnt  : integer;
    OrdQty  : integer;
    TotQty  : integer;
    //

    ConFillQty  : integer;
    ConQty      : integer;
    AfterSec  : integer;
    BeforSec  : integer;
  end;

  TQuoteDesc = class
  public
    Price   : string;
    Qty     : string;
    Side    : string;
    Time    : TDateTime;
    FillQty : string;
    Time2   : TDateTime;
    TimeGap : integer;
    //
    BeforeAcOrd : integer;
    BeforeAcCnl : integer;
    BeforeAcFil : integer;

    AfterAcOrd : integer;
    AfterAcCnl : integer;
    AfterAcFil : integer;

    OrderData : TOrderData;

  end;

  TQuoteResearchItem  = class( TCollectionItem )
  private
    FData: TQuoteDesc;
    FFillter: TFillter;
    FFlash: boolean;
    FTotQty: integer;
    FContinueFill: boolean;
    FSameCnt: integer;
  public
    StartTime : TDateTime;
    LimitTime : TDateTime;
    BeforTime : TDateTime;
    QuoteList : TList;
    constructor Create(aColl: TCollection); override;
    destructor  Destroy; override;

    function GetTimeGap( dtTime : TDateTime ) : integer;
    property Data : TQuoteDesc read FData;
    property Fillter : TFillter read FFillter write FFillter;
    property Flash  : boolean read FFlash write FFlash;
    property TotQty : integer read FTotQty write FTotQty;
    property ContinueFill : boolean read FContinueFill write FContinueFill;
    property SameCnt  : integer read FSameCnt write FSameCnt;
  end;

  TSearchNotify = procedure( aItem : TQuoteResearchItem;  stType : TSearchType ) of object;

  TQuoteResearch = class( TCollection )
  private
    FOrdType: string;
    FFillter: TFillter;
    FQuote: TQuote;
    FSymbol: TSymbol;
    FLastData: TOrderData;
    FOnSearchEvent: TSearchNotify;
    FRecv: Boolean;
    FSFCount: integer;
    FLFCount: integer;
    procedure DoQuote;
    procedure DeleteItem(ii: integer);
    procedure SetSymbol(const Value: TSymbol);
    procedure DoQuoteFill;
    procedure DoQuoteXFill;
    function AddData( bContinue : boolean ) : TQuoteResearchItem;
    function UpdateData : TQuoteResearchItem;
  public
    constructor Create( stType : string ); overload;
    destructor Destroy; override;

    function CheckNNew( aData : TOrderData; var stType : TSearchType;
      var index : integer ) : TQuoteResearchItem;
    function AssignData( aItem : TQuoteResearchItem; aData : TOrderData ) : TQuoteDesc;
    procedure AssginSymbol( aSymbol : TSymbol );

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

    procedure SetFillter( aFillter : TFillter );

    property OrdType : string read FOrdType;
    property Fillter : TFillter read FFillter write FFillter;
    property Quote  : TQuote read FQuote;
    property Symbol : TSymbol read FSymbol write SetSymbol;
    property LastData : TOrderData read FLastData;
    property Recv : Boolean read FRecv write FRecv;

    property LFCount  : integer read FLFCount;
    property SFCount  : integer read FSFCount;

    property OnSearchEvent : TSearchNotify read FOnSearchEvent write FOnSearchEvent;
  end;

implementation

uses
  GAppEnv;

{ TForceItem }

constructor TQuoteResearchItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  QuoteList := TList.Create;
  FFlash  := true;
  FTotQty  := 0;

  FSameCnt  := 1;
end;

destructor TQuoteResearchItem.Destroy;
begin
  QuoteList.Free;
  inherited;
end;

function TQuoteResearchItem.GetTimeGap(dtTime: TDateTime): integer;
var
  aData : TOrderData;
begin
  Result := MilliSecondsBetween( dtTime, FData.Time );
end;

{ TQuoteResearch }

procedure TQuoteResearch.AssginSymbol(aSymbol: TSymbol);
begin
  if aSymbol = nil then Exit;

  if FSymbol = aSymbol then Exit;

  if FSymbol <> nil then
  begin

    gEnv.Engine.QuoteBroker.Cancel( Self, FSymbol );
    if FQuote <> nil then
      FQuote.ExtrateOrder := false;
  end;

  Clear;

  FSymbol := aSymbol;

  FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteProc, spNormal );
  if FQuote <> nil then
    FQuote.ExtrateOrder := true;

end;

function TQuoteResearch.AssignData(aItem: TQuoteResearchItem;
  aData: TOrderData) : TQuoteDesc;
begin
  Result  := TQuoteDesc.Create;

  with Result do
  begin
    Price := aData.GetOrderPrice2;
    Qty   := aData.Qty;
    Side  := aData.Side;
    Time  := aData.Time;
    FillQty := aData.FillQty;
    OrderData := aData;
  end;

  aItem.TotQty  := aItem.TotQty + abs(  StrToIntDef( aData.Qty,0 ));
  aItem.Fillter := FFillter;

  if aItem.QuoteList.Count = 0 then
    aItem.FData := Result;

  aItem.QuoteList.Add( Result );
end;

function TQuoteResearch.CheckNNew(aData: TOrderData;
  var stType : TSearchType; var index : integer): TQuoteResearchItem;
  var
    ii : integer;
begin

  stType := stNone;

  if Count = 0 then
  begin
    Result := Add as TQuoteResearchItem;
    AssignData( Result, aData );
    Result.StartTime:= aData.Time;
    Result.LimitTime:= IncMilliSecond( Result.StartTime, FFillter.SisSec );
    stType := stAdd;
  end
  else begin
    Result := Items[Count-1] as TQuoteResearchItem;
    if (( Result.QuoteList.Count < FFillter.SisCnt ) and  ( Result.LimitTime < aData.Time )) or
      (( Result.TotQty < FFillter.TotQty ) and  ( Result.LimitTime < aData.Time )) or
      (( Result.TotQty < FFillter.TotQty ) and  ( Result.LimitTime < aData.Time ) and ( Result.QuoteList.Count > FFillter.SisCnt ))
      then
    begin
      stType := stDel;
      index  := Count -1;

      Result := Add as TQuoteResearchItem;
      AssignData( Result, aData );
      Result.StartTime:= aData.Time;
      Result.LimitTime:= IncMilliSecond( Result.StartTime, FFillter.SisSec );
    end
    else if ( Result.LimitTime >= aData.Time ) then
    begin
      stType := stUpdate;
      AssignData( Result, aData );
    end
    else if ( Result.QuoteList.Count >= FFillter.SisCnt ) and  ( Result.LimitTime < aData.Time ) then
    begin
      Result := Add as TQuoteResearchItem;
      AssignData( Result, aData );
      Result.StartTime:= aData.Time;
      Result.LimitTime:= IncMilliSecond( Result.StartTime, FFillter.SisSec );
      stType := stAdd;
    end;
  end;

end;

constructor TQuoteResearch.Create( stType : string );
begin
  inherited Create( TQuoteResearchItem );
  FOrdType  := stType;
  FSymbol := nil;
  FQuote  := nil;
  FLastData := nil;
  FRecv := true;

  FSFCount  := 0;
  FLFCount  := 0;
end;

destructor TQuoteResearch.Destroy;
begin
  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );
  if FQuote <> nil then
    FQuote.ExtrateOrder := false;
  inherited;
end;

procedure TQuoteResearch.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
begin
  //
  if not FRecv then Exit;

  if (DataObj = nil) or ( FSymbol = nil)  then Exit;

  aQuote  := DataObj as TQuote;

  if aQuote.Symbol <> FSymbol then Exit;

  if aQuote.LastData = FLastData then Exit;

  if Fquote = nil then FQuote := aQuote;

  DoQuote;

  FLastData := aQuote.LastData;

end;

procedure TQuoteResearch.SetFillter(aFillter: TFillter);
begin
  FFillter.SisSec := aFillter.SisSec;
  FFillter.SisCnt := aFillter.SisCnt;
  FFillter.OrdQty := aFillter.OrdQty;
  FFillter.TotQty := aFillter.TotQty;

  FFillter.ConQty := aFillter.ConQty;
  FFillter.ConFillQty := aFillter.ConFillQty;
  FFillter.AfterSec := aFillter.AfterSec;
  FFillter.BeforSec := aFillter.BeforSec;

end;

procedure TQuoteResearch.SetSymbol(const Value: TSymbol);
begin
  if Value = nil then Exit;

  if FSymbol <> Value then
    AssginSymbol( Value );
end;

procedure TQuoteResearch.DoQuote;
var
  iQty : integer;
  ii : integer;
  stType  : TSearchType;
  aItem : TQuoteResearchItem;
begin

  with FQuote do
  begin

    if LastData = nil then Exit;

    if FOrdType = 'FL' then
    begin
      DoQuoteFill;
      Exit;
    end
    else if FOrdType = 'xFL' then
    begin
      DoQuoteXFill;
      Exit;
    end;

    if FOrdType <> LastData.GetOrderState then
      Exit;

    iQty  := StrToIntDef( LastData.Qty , 0 );
    if iQty < FFillter.OrdQty then Exit;

    aItem := CheckNNew( LastData,  stType, ii );

    case stType of
      stDel:
        begin

          if Assigned( FOnSearchEvent ) then
          begin
            if ii >= 0 then
              FOnSearchEvent( Items[ii] as TQuoteResearchItem, stDel );
            FOnSearchEvent( aItem, stAdd );
          end;

          DeleteItem( ii );

        end;
      else
        if Assigned( FOnSearchEvent ) then
        begin
          if ( aItem.QuoteList.Count >= FFillter.SisCnt) and
            (aItem.TotQty >= FFillter.TotQty) then
          begin
            aItem.FFlash  := true;
            FOnSearchEvent( aItem , stType );
          end;
        end;
    end;
  end;
end;


procedure TQuoteResearch.DoQuoteFill;
var
  iQTy : integer;
  aItem : TQuoteResearchItem;
  aDesc : TQuoteDesc;
begin
  //if FQuote.LastEvent <> qtTimeNSale then Exit;

  with FQuote do
  begin
    iQty  := StrToIntDef( LastData.FillQty , 0 );
    if iQty < 1 then Exit;

    iQty  := StrToIntDef( LastData.Qty , 0 );
    if iQty < FFillter.OrdQty then Exit;

    aItem := Add as TQuoteResearchItem;
    aDesc := AssignData( aItem, LastData );

    aItem.StartTime:= LastData.Time;

    if Count > 1 then
    begin
      aDesc.Time2   := (Items[Count-2] as TQuoteResearchItem).StartTime;
      aDesc.TimeGap := MilliSecondsBetween( aItem.StartTime, aDesc.Time2) ;
    end
    else
      aDesc.TimeGap := 0;

    if LastData.Side = 'L' then
      inc( FLFCount )
    else
      inc( FSFCount );

    if Assigned( FOnSearchEvent ) then
    begin
      aItem.FFlash  := true;
      FOnSearchEvent( aItem, stAdd );
    end;
  end;
end;

procedure TQuoteResearch.DeleteItem( ii :integer );
var
  i : integer;
begin
  if ii < 0 then Exit;
  Delete( ii );
end;

procedure TQuoteResearch.DoQuoteXFill;
var
  aItem : TQuoteResearchItem;
  iQty : integer;
  bOK : boolean;
  dLGap, dSGap : double;
  stLog : string;
begin

  //if FQuote.LastEvent <> qtTimeNSale then Exit;

  with FQuote do
  begin
    iQty  := StrToIntDef( LastData.Qty , 0 );

    bOK := false;
    {
    if LastData.ContinueFill then
      bOK := true
    else begin
    }
    dSGap := abs( PrevAsks[0].Price - Asks[0].Price );
    dLGap := abs( PrevBids[0].Price - Bids[0].Price );

    if ((dSGap > PRICE_EPSILON) or ( dLGap > PRICE_EPSILON)) and
      (LastData.FillQty <> '') then
      bOK := true;
 //   end;

    if bOK then begin
      if iQty < FFillter.OrdQty then Exit;
      aItem := AddData( LastData.ContinueFill );
    end
    else Exit;

    if aItem = nil then Exit;
    

    if (Assigned( FOnSearchEvent )) and ( aItem <> nil) then
    begin
      if bOK then begin
        aItem.FFlash  := true;
        if LastData.Side = 'L' then
          inc( FLFCount )
        else
          inc( FSFCount );
        FOnSearchEvent( aItem, stAdd )
      end
      else
        FOnSearchEvent( aItem, stUpdate );
    end;
  end;

end;

function TQuoteResearch.AddData( bContinue : boolean ) : TQuoteResearchItem;
var
  pItem, aItem : TQuoteResearchItem;
  aDesc : TQuoteDesc;
  BeforTime, prevTime : TDateTime;
  aData : TOrderData;
  iCom, i : integer;

  BeforeAcOrd,    BeforeAcCnl, BeforeAcFil : integer;
begin
  Result := nil;

  with FQuote do
  begin

    // filttering
    BeforTime := IncMilliSecond( LastData.Time, FFillter.BeforSec * -1 );
    pItem := nil;
    if Count > 0 then
    begin
      pItem := Items[Count-1] as TQuoteResearchItem;
      prevTime   := pItem.StartTime;
      if BeforTime < prevTime then
        BeforTime := PrevTime;
    end;

    BeforeAcOrd := 0;    BeforeAcCnl := 0;  BeforeAcFil := 0;

    for i := 0 to PriceAxis.OrderList.Count - 1 do
    begin
      aData := TOrderData( PriceAxis.OrderList.Items[i] );
      if aData = nil then Continue;
      if aData.Time <= BeforTime then
        break;

      if LastData.Side = 'L' then
      begin
        if (aData.QType = LN) and (aData.FillQty = '') then
        begin
            inc(BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
        if (aData.QType in  [SC, SPC]) and (aData.FillQty = '') then
          inc(BeforeAcCnl, StrToIntDef(aData.Qty, 0));
        if (aData.FillQty <> '') and ( aData.Side = 'L') then
        begin
          inc(BeforeAcFil, StrToIntDef(aData.FillQty, 0));
          inc(BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;

      end
      else begin
        if (aData.QType = SN) and (aData.FillQty = '') then
        begin
            inc(BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
        if (aData.QType in  [LC, LPC]) and (aData.FillQty = '') then
          inc(BeforeAcCnl, StrToIntDef(aData.Qty, 0));
        if (aData.FillQty <> '') and ( aData.Side = 'S') then
        begin
          inc(BeforeAcFil, StrToIntDef(aData.FillQty, 0));
          inc(BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
      end;
    end;

    // filttering end

    if (BeforeAcOrd < FFillter.ConQty) or ( BeforeAcFil < FFillter.ConFillQty ) then
      Exit;

    aItem := Add as TQuoteResearchItem;
    aDesc := AssignData( aItem, LastData );
    aItem.FContinueFill := bContinue;

    aItem.StartTime := LastData.Time;
    //aItem.LimitTime := IncMilliSecond( aItem.StartTime, FFillter.AfterSec );
    aItem.BeforTime := BeforTime;//IncMilliSecond( aItem.StartTime, FFillter.BeforSec * -1 );

    if pItem <> nil then
    begin
      aDesc.Time2   := prevTime;
      aDesc.TimeGap := MilliSecondsBetween( aItem.StartTime, aDesc.Time2) ;
      if pItem.FData.Side = aItem.FData.Side then
      begin
        //  pItem.FData.Price 가 크면 양수..
        iCom := CompareStr( aItem.FData.Price, pItem.FData.Price  );

        if aItem.FData.Side = 'L' then
        begin
          if iCom > 0 then
            aItem.SameCnt := aItem.SameCnt + pItem.SameCnt
          else
            aItem.SameCnt := pItem.SameCnt;
        end
        else begin
          if iCom < 0 then
            aItem.SameCnt := aItem.SameCnt + pItem.SameCnt
          else
            aItem.SameCnt := pItem.SameCnt;
        end;
      end;
    end
    else begin
      aDesc.TimeGap := 0;
      aItem.FSameCnt:= 1;
    end;

    aDesc.BeforeAcOrd := BeforeAcOrd;
    aDesc.BeforeAcCnl := BeforeAcCnl;
    aDesc.BeforeAcFil := BeforeAcFil;
    {
    for i := 0 to PriceAxis.OrderList.Count - 1 do
    begin
      aData := TOrderData( PriceAxis.OrderList.Items[i] );
      if aData = nil then Continue;
      if aData.Time <= aItem.BeforTime then
        break;

      if aDesc.Side = 'L' then
      begin
        if (aData.QType = LN) and (aData.FillQty = '') then
        begin
            inc(aDesc.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
        if (aData.QType in  [LC, LPC]) and (aData.FillQty = '') then
          inc(aDesc.BeforeAcCnl, StrToIntDef(aData.Qty, 0));
        if (aData.FillQty <> '') and ( aData.Side = 'L') then
        begin
          inc(aDesc.BeforeAcFil, StrToIntDef(aData.FillQty, 0));
          inc(aDesc.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;

      end
      else begin
        if (aData.QType = SN) and (aData.FillQty = '') then
        begin
            inc(aDesc.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
        if (aData.QType in  [SC, SPC]) and (aData.FillQty = '') then
          inc(aDesc.BeforeAcCnl, StrToIntDef(aData.Qty, 0));
        if (aData.FillQty <> '') and ( aData.Side = 'S') then
        begin
          inc(aDesc.BeforeAcFil, StrToIntDef(aData.FillQty, 0));
          inc(aDesc.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
        end;
      end;
    end;
    }
    Result := aItem;
  end;// with

end;

function TQuoteResearch.UpdateData : TQuoteResearchItem;
var
  aItem : TQuoteResearchItem;
  aDesc : TQuoteDesc;
  aData : TOrderData;
begin
  Result := nil;
  if Count <= 0 then Exit;

  aItem := Items[Count-1] as TQuoteResearchItem;

  with FQuote do
  begin
    if aItem.LimitTime < LastData.Time then
      Exit;

    aData := LastData;

    if aItem.FData.Side = 'L' then
    begin
      if (aData.QType = LN) and (aData.FillQty = '') then
        inc(aItem.FData.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
      if (aData.QType in  [LC, LPC]) and (aData.FillQty = '') then
        inc(aItem.FData.BeforeAcCnl, StrToIntDef(aData.Qty, 0));
      if (aData.FillQty <> '') and ( aData.Side = 'L') then
        inc(aItem.FData.BeforeAcFil, StrToIntDef(aData.FillQty, 0));
    end
    else begin
      if (aData.QType = SN) and (aData.FillQty = '') then
        inc(aItem.FData.BeforeAcOrd, StrToIntDef(aData.Qty, 0));
      if (aData.QType in  [SC, SPC]) and (aData.FillQty = '') then
        inc(aItem.FData.BeforeAcCnl, StrToIntDef(aData.Qty, 0));
      if (aData.FillQty <> '') and ( aData.Side = 'S') then
        inc(aItem.FData.BeforeAcFil, StrToIntDef(aData.FillQty, 0));
    end;
  end;

  Result := aItem;

end;

end.
