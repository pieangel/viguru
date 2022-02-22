unit CJackpotOrder;

interface

uses
  Classes, SysUtils,
  CleSymbols, CleQuoteBroker, CleOrders, CleQuoteTimers ,  GleTypes,
  GleConsts
  ;

const
  CondVol = 'V';
  CondFil = 'F';
  CondAll = 'A';
  CondNot = 'N';

type
  TJackPotOrderType = ( jtNew, jtCancel );

  TJackPotDelItem = class( TCollectionItem )
  public
    Time    : TDateTime;
    Symbol  : TSymbol;
    JackType: TJackPotOrderType;
    Price   : double;
    Qty     : integer;
    PriceDesc: string;
  end;

  TJackPotItem = Class( TCollectionItem )
  public
    Symbol  : TSymbol;
    Quote   : TQuote;
    Side    : integer;
    Volume  : integer;
    Index   : integer;
    OrdQty  : integer;
    JackType: TJackPotOrderType;
    Price   : double;
    JackPotSeq  : integer;

    AclFilVol : integer;
    AclFilVol2: integer;
    Condition : char;
    UseOrCond : boolean;
  End;

  TOrderNotify = procedure ( aPot : TJackPotItem ) of object;
  TCheckNotify = function( aPot : TJackPotItem ) : integer of object;
  TAccumulCheckNotify = function( var iFill : integer; aPot : TJackPotItem ) : boolean of object;
  TStandbyNotify = procedure( Sender : TObject ) of object;
  TGetStandByState = function( aPot : TJackPotItem ) : char of object;

  TJackPots = Class( TCollection )
  private
    FOnJackPotOrder: TOrderNotify;
    FOnDelJackPotOrder: TOrderNotify;
    FJackPotSeq: integer;

    FOnCheckJackPotOrder: TCheckNotify;
    FOnStandByEvent: TStandbyNotify;
    FSymbol: TSymbol;
    FOnAccumulCheck: TAccumulCheckNotify;
    FOnGetStandByState: TGetStandByState;
    FBidDelJackPot: TCollection;
    FAskDelJackPot: TCollection;
    FStopCoolTime: integer;
    FUseStopCoolTime: boolean;
    FBidVolStops: TList;
    FAskVolStops: TList;
    FManage: boolean;
    FManageParam: TManageParam;
    FLastItem: TJackPotItem;
    FPartPrice: double;
    FPositionType: TPositionType;
    FAccumulCmpSec: integer;
    FUseMoth: boolean;

    function GetJackPot(i: integer): TJackPotItem;
    function ISOrder(aPot: TJackPotItem; aDepths: TMarketDepths; iRes : integer): boolean;
    procedure SetSymbol(const Value: TSymbol);
    function CheckJackPot(dPrice: double; iSide: integer): boolean;
    procedure AskAdd(aItem : TJackPotItem );
    procedure BidAdd(aItem : TJackPotItem);
    procedure ClearPotList;
    procedure DoManageVolStop(aQuote: TQuote);
    procedure SetManage(const Value: boolean);
    procedure SetManageParam(const Value: TManageParam);
    function GetPrice(aQuote : TQuote; bAsk: boolean): string;
    procedure SetUseMoth(const Value: boolean);
  public
    Constructor Create;
    Destructor  Destroy; override;

    function New( aSymbol : TSymbol; iSide : integer; dPrice : double  ) : TJackPotItem;

    function Find( aSymbol : TSymbol; iSide : integer; dPrice : double  ) : TJackPotItem;
    function FindAsk( aSymbol : TSymbol; dPrice : double; var iPos : integer ) : TJackPotItem;
    function FindBid( aSymbol : TSymbol; dPrice : double; var iPos : integer ) : TJackPotItem;

    procedure Cancel( aSymbol : TSymbol; iSide : integer ); overload;
    procedure Cancel( aItem : TJackPotItem ); overload;
    procedure Cancel; overload;
    procedure PartCancel( iSide : integer; dPrice : double );

    procedure AllCancel( iSide : integer ) ;
    procedure OnQuote( aQuote : TQuote );
    procedure ClearPot;
    procedure DeleteLog( aPot : TjackPotItem );

    property Symbol : TSymbol read FSymbol write SetSymbol;
    property JackPots[ i : integer] : TJackPotItem read GetJackPot;
    property OnJackPotOrder : TOrderNotify read  FOnJackPotOrder write FOnJackPotOrder;
    property OnDelJackPotOrder : TOrderNotify read  FOnDelJackPotOrder write FOnDelJackPotOrder;
    property OnCheckJackPotOrder : TCheckNotify read FOnCheckJackPotOrder write FOnCheckJackPotOrder;
    property OnStandByEvent : TStandbyNotify read FOnStandByEvent write FOnStandByEvent;
    property OnAccumulCheck : TAccumulCheckNotify read FOnAccumulCheck write FOnAccumulCheck;
    property OnGetStandByState : TGetStandByState read FOnGetStandByState write FOnGetStandByState;
    property JackPotSeq : integer read FJackPotSeq  write FJackPotSeq;

    //
    property AskVolStops : TList read FAskVolStops write FAskVolStops;
    property BidVolStops : TList read FBidVolStops write FBidVolStops;

    property AskDelJackPot : TCollection read FAskDelJackPot write FAskDelJackPot;
    property BidDelJackPot : TCollection read FBidDelJackPot write FBidDelJackPot;

    property UseStopCoolTime : boolean read FUseStopCoolTime write FUseStopCoolTime;
    property StopCoolTime    : integer read FStopCoolTime write FStopCoolTime;

    property Manage   : boolean read FManage write SetManage;
    property ManageParam : TManageParam read FManageParam write SetManageParam;

    // Moth 전송을 위함
    property LastItem        : TJackPotItem read FLastItem write FLastItem;
    property PartPrice       : double read FPartPrice write FPartPrice;
    property PositionType    : TPositionType read FPositionType write FPositionType;
    property AccumulCmpSec   : integer read FAccumulCmpSec write FAccumulCmpSec;

  End;



implementation

uses
  GAppEnv, GleLib, CleKrxSymbols;

{ TJackPots }

procedure TJackPots.Cancel(aSymbol : TSymbol; iSide: integer);
var
  i , iCnt : integer;
  aItem : TJackPotItem;
begin
  iCnt  := 0;

  if iSide = 1 then
  begin

    for i := FAskVolStops.Count- 1 downto 0 do
    begin
      aItem := TJackPotItem( FAskVolStops.Items[i] );
      if aItem = nil then Continue;

      aItem.JackType  := jtCancel;
      if Assigned( FOnDelJackPotOrder ) then
        FOnDelJackPotOrder( aItem );
        {
        gLog.Add( lkKeyOrder, 'TJackPots', 'Cancel',
          Format('%s : %.2f, %d : 취소', [ ifThenStr( iSide = 1, '매도', '매수'),
          aItem.Price, aItem.Side
           ]) );
        }

      aItem.Free;
      FAskVolStops.Delete(i);
    end;
  end
  else begin
    for i := FBidVolStops.Count- 1 downto 0 do
    begin
      aItem := TJackPotItem( FBidVolStops.Items[i] );
      if aItem = nil then Continue;

      aItem.JackType  := jtCancel;
      if Assigned( FOnDelJackPotOrder ) then
        FOnDelJackPotOrder( aItem );
        {
        gLog.Add( lkKeyOrder, 'TJackPots', 'Cancel',
          Format('%s : %.2f, %d : 취소', [ ifThenStr( iSide = 1, '매도', '매수'),
          aItem.Price, aItem.Side
           ]) );
        }

      aItem.Free;
      FBidVolStops.Delete(i);
    end;
  end;

 // gLog.Add( lkKeyOrder, ' ', ' ', 'Count : ' + IntToStr( Count ));

end;

procedure TJackPots.AllCancel(iSide: integer);
var
  i  : integer;
  aPot : TJackPotItem;
begin
  if iSide = 1 then
    for i := FAskVolStops.Count- 1 downto 0 do
    begin
      aPot := TJackPotItem( FAskVolStops.Items[i] );
      if aPot = nil then Continue;
      if Assigned( FOnDelJackPotOrder ) then
      begin
        aPot.JackType  := jtCancel;
        FOnDelJackPotOrder( aPot );
        DeleteLog( aPot );
        aPot.Free;
        FAskVolStops.Delete(i);
      end;
    end;

  if iSide = 1 then
    FAskVolStops.Clear;

  if iSide = 2 then
    for i := FBidVolStops.Count- 1 downto 0 do
    begin
      aPot := TJackPotItem( FBidVolStops.Items[i] );
      if aPot = nil then Continue;
      if Assigned( FOnDelJackPotOrder ) then
      begin
        aPot.JackType  := jtCancel;
        FOnDelJackPotOrder( aPot );
        DeleteLog( aPot );
        aPot.Free;
        FBidVolStops.Delete(i);
      end;
    end;

  if iSide = 2 then
    FBidVolStops.Clear;

end;

procedure TJackPots.Cancel;
var
  i , iCnt : integer;
  aItem : TJackPotItem;
begin

  AllCancel( 1 );
  AllCancel( 2 );
end;

procedure TJackPots.Cancel(aItem: TJackPotItem);
var
  iSide, iPos  : integer;
begin

  if aITem = nil then Exit;
  iPos := -1;
  iSide := aItem.Side;

  if iSide = 1 then
    FindAsk( aItem.Symbol, aItem.Price, iPos )
  else
    FindBid( aItem.Symbol, aItem.Price, iPos );

  if iPos >= 0 then
  begin
    if Assigned( FOnDelJackPotOrder ) then
    begin
      aItem.JackType  := jtCancel;
      FOnDelJackPotOrder( aItem );
      DeleteLog( aItem );
      aItem.Free;
      if iSide = 1 then
        FAskVolStops.Delete( iPos )
      else
        FBidVolStops.Delete( iPos );
    end;
  end;

  if Assigned( FOnStandByEvent ) then
    FOnStandByEvent( Self );

  //gLog.Add( lkKeyOrder, ' ', ' ', 'Count : ' + IntToStr( Count ));
end;


procedure TJackPots.PartCancel(iSide: integer; dPrice: double);
var
  i , iCnt : integer;
  aItem : TJackPotItem;
begin
  iCnt  := 0;

  if iSide = 1 then
  begin

    for i := FAskVolStops.Count- 1 downto 0 do
    begin
      aItem := TJackPotItem( FAskVolStops.Items[i] );
      if aItem = nil then Continue;
      if ( aItem.JackType = jtNew ) and
         ( aItem.Price + PRICE_EPSILON >= dPrice  ) then
         begin
            aItem.JackType  := jtCancel;
            if Assigned( FOnDelJackPotOrder ) then
              FOnDelJackPotOrder( aItem );
              {
              gLog.Add( lkKeyOrder, 'TJackPots', 'Cancel',
                Format('%s : %.2f, %d : 취소', [ ifThenStr( iSide = 1, '매도', '매수'),
                aItem.Price, aItem.Side
                 ]) );
              }

            aItem.Free;
            FAskVolStops.Delete(i);
         end;
    end;
  end
  else begin
    for i := FBidVolStops.Count- 1 downto 0 do
    begin
      aItem := TJackPotItem( FBidVolStops.Items[i] );
      if aItem = nil then Continue;

      if ( aItem.JackType = jtNew ) and
         ( aItem.Price <= dPrice + PRICE_EPSILON ) then
         begin
            aItem.JackType  := jtCancel;
            if Assigned( FOnDelJackPotOrder ) then
              FOnDelJackPotOrder( aItem );
              {
              gLog.Add( lkKeyOrder, 'TJackPots', 'Cancel',
                Format('%s : %.2f, %d : 취소', [ ifThenStr( iSide = 1, '매도', '매수'),
                aItem.Price, aItem.Side
                 ]) );
              }

            aItem.Free;
            FBidVolStops.Delete(i);
         end;
    end;
  end;


end;

procedure TJackPots.ClearPot;
begin

  ClearPotList;
  //FJackPotSeq := 0;
  FBidDelJackPot.Clear;
  FAskDelJackPot.Clear;

  if Assigned( FOnStandByEvent ) then
    FOnStandByEvent( Self );
  gLog.Add( lkKeyOrder,'TOrderBoard','DoStandBy', 'Clear' );
  //FTablet.DrawStandBy;
end;


procedure TJackPots.ClearPotList;
var
  i :integer;
  aPot: TjackPotItem;
begin

    for I := FAskVolStops.Count - 1 downto 0 do
    begin
      aPot := TjackPotItem( FAskVolStops.Items[i] );
      if aPot <> nil then
        aPot.Free;
      FAskVolStops.Delete(i);
    end;


    for I := FBidVolStops.Count - 1 downto 0 do
    begin
      aPot := TjackPotItem( FBidVolStops.Items[i] );
      if aPot <> nil then
        aPot.Free;
      FBidVolStops.Delete(i);
    end;

end;

constructor TJackPots.Create;
begin
  inherited Create( TJackPotItem );
  FJackPotSeq := 0;

  FBidDelJackPot:= TCollection.Create( TJackPotDelItem );
  FAskDelJackPot:= TCollection.Create( TJackPotDelItem );

  FBidVolStops:= TList.Create;
  FAskVolStops:= TList.Create;

  FManage := false;
  PartPrice := 0;
  FAccumulCmpSec := 200;
  FUseMoth  := false;
end;

procedure TJackPots.DeleteLog(aPot: TjackPotItem);
var
  stLog : string;
begin
  stLog :=
  Format( 'Delete : %d, %s, %s, %.2f, %d, %d, (%s)',
  [
    aPot.JackPotSeq,
    aPot.Symbol.ShortCode,
    ifThenStr(  aPot.Side = 1, '매도', '매수' ),
    aPot.Price,
    aPot.OrdQty,
    aPot.Volume,
    ifThenStr( aPot.Side = 1,  IntToStr(FAskVolStops.Count-1)
      , IntToStr( FBidVolStops.Count-1) )

  ]);
  gLog.Add( lkKeyOrder,'TOrderBoard','DoStandBy', stLog );

end;

destructor TJackPots.Destroy;
begin
  FBidVolStops.Free;
  FAskVolStops.Free;
  FBidDelJackPot.Free;
  FAskDelJackPot.Free;
  inherited;
end;

function TJackPots.Find(aSymbol: TSymbol; iSide : integer; dPrice : double ): TJackPotItem;
var
  iPos : integer;
begin

  Result := nil;
  if iSide = 1 then
    Result := FindAsk( aSymbol, dPrice, iPos )
  else
    REsult := FindBid( aSymbol, dPrice, iPos );

end;

function TJackPots.FindAsk(aSymbol: TSymbol; dPrice: double; var iPos : integer ): TJackPotItem;
var

  pItem : TJackPotItem;
  stFindKey, stDesKey: String;
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;

begin
  Result := nil;
  iPos := -1;

  if aSymbol = nil then
    Exit;

  stFindkey := Format('%*n',
    [ aSymbol.Spec.Precision,
      dPrice
    ] );

  iLow := 0;
  iHigh:= FAskVolStops.Count-1;



  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TJackPotItem( FAskVolStops.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%*n',
     [ pItem.Symbol.Spec.Precision,
       pItem.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := TJackPotItem( FAskVolStops.Items[iMid] );
        iPos := iMid;
        break;;
      end;
    end;

  end;

end;

function TJackPots.FindBid(aSymbol: TSymbol; dPrice: double; var iPos : integer): TJackPotItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  pItem : TJackPotItem;
  stFindKey, stDesKey: String;
begin

  Result := nil;
  iPos := -1;

  if aSymbol = nil then
    Exit;

  stFindkey := Format('%*n',
    [ aSymbol.Spec.Precision,
      dPrice
    ] );

  iLow := 0;
  iHigh:= FBidVolStops.Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TJackPotItem( FBidVolStops.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%*n',
     [ pItem.Symbol.Spec.Precision,
       pItem.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result  := TJackPotItem( FBidVolStops.Items[iMid] );
        iPos := iMid;
        break;;
      end;
    end;

  end;

end;

function TJackPots.GetJackPot(i: integer): TJackPotItem;
begin
  if ( i < 0) and ( i >= Count) then
    Result := nil
  else
    Result := Items[i] as TJackPotItem;
end;

function TJackPots.New(aSymbol: TSymbol; iSide : integer; dPrice : double  ): TJackPotItem;
var
  bNew : boolean;
begin
  Result := Find( aSymbol, iSide, dPrice );
  bNew   := false;

  if Result = nil then
  begin
    bNew   := CheckJackPot( dPrice, iSide );
    if Not bNew then Exit;
    Result := TJackPotItem.Create( nil );
    inc(FJackPotSeq);
    Result.JackPotSeq := FJackPotSeq;
  end;

  Result.Price  := dPrice;
  Result.Symbol := aSymbol;
  Result.Side   := iSide;

  if bNew then
    if Result.Side = 1 then
      AskAdd( Result )
    else
      BidAdd( Result );

  if aSymbol.Quote <> nil then
  begin
    Result.Quote  := aSymbol.Quote as TQuote;
  end;

  FLastItem := Result;
  Result.JackType := jtNew;
  {
  if Assigned( FOnStandByEvent ) then
    FOnStandByEvent( Self );
  }
end;

function TJackPots.CheckJackPot( dPrice : double; iSide : integer ) : boolean;
var
  stLog, stDsc : string;
  aItem : TJackPotDelItem;
  iGap, i, iRes : integer;
  aNow : TDateTime;
begin
  Result := true;

  if not FUseStopCoolTime then Exit;

  aNow   := GetQuoteTime;

  // 매도
  if iSide = 1 then begin
    for i := FAskDelJackPot.Count - 1 downto 0 do
    begin
      aItem :=  TJackPotDelItem( FAskDelJackPot.Items[i] );
      if aItem = nil then
        Continue;

      stDsc := Format('%.2f', [ dPrice ]);
      iGap  := GetMSBetween( aNow, aItem.Time );
      if iGap > FStopCoolTime  then
        break;

      iRes  := CompareStr( aItem.PriceDesc, stDsc );
      if (iRes = 0) then
      begin
        stLog  := Format('CoolTimeCheck(%d|%d) : %s 매도 Last : %s, %d  Now : %s',
          [
            iGap , FStopCoolTime,
            stDsc,
            FormatDateTime('hh:nn:ss.zzz', aItem.Time),
            aItem.Qty,
            FormatDateTime('hh:nn:ss.zzz', aNow)
          ]);

        gLog.Add( lkKeyOrder, 'TJackPots', 'CheckJackPot', stLog );
        Result := false;
        break;
      end;
    end;
  end
  else begin
    for i := FBidDelJackPot.Count - 1 downto 0 do
    begin
      aItem :=  TJackPotDelItem( FBidDelJackPot.Items[i] );
      if aItem = nil then
        Continue;

      stDsc := Format('%.2f', [ dPrice ]);
      iGap  := GetMSBetween( aNow, aItem.Time );
      if iGap > FStopCoolTime  then
        break;

      iRes  := CompareStr( aItem.PriceDesc, stDsc );
      if (iRes = 0) then
      begin
        stLog  := Format('CoolTimeCheck(%d|%d) : %s 매수 Last : %s, %d  Now : %s',
          [
            iGap , FStopCoolTime,
            stDsc,
            FormatDateTime('hh:nn:ss.zzz', aItem.Time),
            aItem.Qty,
            FormatDateTime('hh:nn:ss.zzz', aNow)
          ]);

        gLog.Add( lkKeyOrder, 'TJackPots', 'CheckJackPot', stLog );
        Result := false;
        break;
      end;
    end;
  end;
end;

function TJackPots.GetPrice( aQuote : TQuote;  bAsk : boolean ) : string;
var
  dPrice : Double;
begin
  if bAsk then begin
    if FManageParam.UseShift then
      dPrice := aQuote.Bids[0].Price - FManageParam.AskShift
    else begin
      if (FManageParam.BidHoga >=1) and (FManageParam.BidHoga <= 5) then
        dPrice  := aQuote.Bids[FManageParam.BidHoga-1].Price
      else if FManageParam.BidHoga <= 0 then
        Exit
      else
        dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Bids[0].Price, -( FManageParam.BidHoga-1) );
    end;
  end else
  begin
    if FManageParam.UseShift then
      dPrice := aQuote.Asks[0].Price + FManageParam.BidShift
    else begin

      if (FManageParam.AskHoga >=1) and (FManageParam.AskHoga <= 5) then
        dPrice  := aQuote.Asks[FManageParam.AskHoga-1].Price
      else if FManageParam.AskHoga <= 0 then
        Exit
      else
        dPrice  := TicksFromPrice( aQuote.Symbol, aQuote.Asks[0].Price, FManageParam.AskHoga -1 );
    end;

  end;

  Result := Format( '%.*n', [ 2, dPrice ]);

end;

procedure TJackPots.DoManageVolStop( aQuote : TQuote );
var
  i, iRes : integer;
  aPot : TJackPotItem;
  stSrc, stDes,  stLog : string;

begin
  //if FUseMoth then
  //  Exit;

  try
    for i :=AskVolStops.Count - 1 downto 0 do
    begin

      aPot    := TJackPotItem( AskVolStops.Items[i] );
      if aPot = nil then Continue;

      if ( aPot.Symbol = aQuote.Symbol) and  ( aPot.JackType = jtNew ) then
      begin

        if aQuote.Bids[0].Price < PRICE_EPSILON then
          break;

        stSrc := Format( '%.*n', [ 2, aPot.Price ]);
        stDes := GetPrice( aQuote, true );
        iRes  := CompareStr( stSrc, stDes );

        if iRes < 0 then
          break;

        Cancel( aPot );
      end;
    end;

    //
    aPot := nil;

    for i := BidVolStops.Count-1 downto 0 do
    begin
      aPot    := TJackPotItem( BidVolStops.Items[i] );
      if aPot = nil then Continue;

      if ( aPot.Symbol = aQuote.Symbol) and  ( aPot.JackType = jtNew ) then
      begin

        if aQuote.Asks[0].Price < PRICE_EPSILON then
          break;

        stSrc := Format( '%.*n', [ 2, aPot.Price ]);
        stDes := GetPrice( aQuote, false );
        iRes  := CompareStr( stSrc, stDes );

        if iRes > 0 then
          break;

        Cancel( aPot );
      end;
    end;



  except
  end;

end;

procedure TJackPots.OnQuote(aQuote: TQuote);
var
  i, iRes : integer;
  aPot : TJackPotItem;
  aDepths : TMarketDepths;
  bOrder : boolean;
  stSrc, stDes, stTmp, stLog : string;
  aItem : TJackPotDelItem;
begin
  if FManage then
  begin
    DoManageVolStop( aQuote );
    Exit;
  end;

  try
    for i :=AskVolStops.Count - 1 downto 0 do
    begin
      bOrder  := false;
      aPot    := TJackPotItem( AskVolStops.Items[i] );
      if aPot = nil then Continue;

      if ( aPot.Symbol = aQuote.Symbol) and  ( aPot.JackType = jtNew ) then
      begin

        if aQuote.Bids[0].Price < PRICE_EPSILON then
          break;

        stSrc := Format( '%.*n', [ 2, aPot.Price ]);
        stDes := Format( '%.*n', [ 2, aQuote.Bids[0].Price ]);
        iRes  := CompareStr( stSrc, stDes );

        if iRes < 0 then
          break;
        bOrder  := IsOrder( aPot, aQuote.Bids, iRes );

        //
        if Assigned( FOnJackPotOrder ) and bOrder then
        begin
          aPot.JackType := jtCancel;
          FOnJackPotOrder( aPot );

          stLog :=
          Format( 'Delete : %d, %s, %s, %.2f, %d, %d, (%d)',
          [
            aPot.JackPotSeq,
            aPot.Symbol.ShortCode,
            '매도',
            aPot.Price,
            aPot.OrdQty,
            aPot.Volume,
            AskVolStops.Count-1
          ]);
          gLog.Add( lkKeyOrder,'TOrderBoard','DoStandBy', stLog );
          aItem := TJackPotDelItem( FAskDelJackPot.Add );
          aItem.Time := GetQuoteTime;
          aItem.Price:= aPot.Price;
          aItem.Symbol  := aPot.Symbol;
          aItem.Qty     := aPot.OrdQty;
          aItem.JackType:= jtCancel;
          aItem.PriceDesc := Format('%.2f', [ aItem.Price ]);

          aPot.Free;
          AskVolStops.Delete( i );
        end;
        //

      end;
    end;

    ////////////////////////////////////////////////////////////////////////////

    for i :=BidVolStops.Count - 1 downto 0 do
    begin
      bOrder  := false;
      aPot    := TJackPotItem( BidVolStops.Items[i] );
      if aPot = nil then Continue;

      if ( aPot.Symbol = aQuote.Symbol) and  ( aPot.JackType = jtNew ) then
      begin

        if aQuote.Asks[0].Price < PRICE_EPSILON then
          break;

        stSrc := Format( '%.*n', [ 2, aPot.Price ]);
        stDes := Format( '%.*n', [ 2, aQuote.Asks[0].Price ]);
        iRes  := CompareStr( stSrc, stDes );

        if iRes > 0 then
          break;
        bOrder  := IsOrder( aPot, aQuote.Asks, iRes );
        //
        if Assigned( FOnJackPotOrder ) and bOrder then
        begin
          aPot.JackType := jtCancel;
          FOnJackPotOrder( aPot );

          stLog :=
          Format( 'Delete : %d, %s, %s, %.2f, %d, %d, (%d)',
          [
            aPot.JackPotSeq,
            aPot.Symbol.ShortCode,
            '매수',
            aPot.Price,
            aPot.OrdQty,
            aPot.Volume,
            BidVolStops.Count-1
          ]);
          gLog.Add( lkKeyOrder,'TOrderBoard','DoStandBy', stLog );
          aItem := TJackPotDelItem( FBidDelJackPot.Add );
          aItem.Time := GetQuoteTime;
          aItem.Price:= aPot.Price;
          aItem.Symbol  := aPot.Symbol;
          aItem.Qty     := aPot.OrdQty;
          aItem.JackType:= jtCancel;
          aItem.PriceDesc := Format('%.2f', [ aItem.Price ]);

          aPot.Free;
          BidVolStops.Delete( i );
        end;
        //
      end;
    end;

  except

  end;

end;



procedure TJackPots.AskAdd(aItem : TJackPotItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TJackPotItem;
  stFindKey, stDesKey: String;
begin

  stFindkey := Format('%*n',
    [ aItem.Symbol.Spec.Precision,
      aItem.Price
    ] );

  iLow := 0;
  iHigh:= FAskVolStops.Count-1;

  iPos := -1;

  if FAskVolStops.Count = 0 then
  begin
    FAskVolStops.Add( aItem);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TJackPotItem( FAskVolStops.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%*n',
     [ pItem.Symbol.Spec.Precision,
       pItem.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;
    iPos := iLow;
  end;

  if iPos >=0 then
    FAskVolStops.Insert(iPos, aItem);

  for i := FAskVolStops.Count-1 downto 0 do
  begin
    pItem := TJackPotItem( FAskVolStops.Items[i] );
    stDesKey  := Format('Ask : %.2f, %d, %d',
      [
        pItem.Price,
        pItem.OrdQty,
        pItem.Volume
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );

end;

procedure TJackPots.BidAdd(aItem : TJackPotItem);
var
  iLow, iHigh, iMid, iCom, idx, i, iPos, iTmp : integer;
  pItem : TJackPotItem;
  stFindKey, stDesKey: String;
begin


  stFindkey := Format('%*n',
    [ aItem.Symbol.Spec.Precision,
      aItem.Price
    ] );

  iLow := 0;
  iHigh:= FBidVolStops.Count-1;

  iPos := -1;

  if FBidVolStops.Count = 0 then
  begin
    FBidVolStops.Add( aItem);
    Exit;
  end;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    pItem := TJackPotItem( FBidVolStops.Items[iMid] );
    if pItem = nil then
      break;

    stDesKey := Format( '%*n',
     [ pItem.Symbol.Spec.Precision,
       pItem.Price
     ] );
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom > 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        iPos := iMid;
        break;;
      end;
    end;

    iPos := iLow;
  end;

  if iPos >=0 then
    FBidVolStops.Insert( iPos, aItem );

  for i := FBidVolStops.Count-1 downto 0 do
  begin
    pItem := TJackPotItem( FBidVolStops.Items[i] );
    stDesKey  := Format('Bid : %.2f, %d, %d',
      [
        pItem.Price,
        pItem.OrdQty,
        pItem.Volume
      ]);
    gEnv.EnvLog( WIN_TEST, stDesKey );
  end;
  gEnv.EnvLog( WIN_TEST, '' );

end;



procedure TJackPots.SetManage(const Value: boolean);
var
  stLog : string;
begin
  FManage := Value;
  if FSymbol <> nil then
  stLog := Format('Manage %s : %s, (%s,%s)',
    [
      ifthenStr( Value , 'On', 'Off'),
      Symbol.ShortCode,

      ifthenStr( FManageParam.UseShift, Format('%.2f', [ FManageParam.AskShift]), IntToStr( FManageParam.AskHoga )),
      ifthenStr( FManageParam.UseShift, Format('%.2f', [ FManageParam.BidShift]), IntToStr( FManageParam.BidHoga ))
    ])
  else
    stLog := 'symbol is nil';
  gLog.Add( lkKeyOrder,'TOrderBoard','SetManage', stLog );
end;

procedure TJackPots.SetManageParam(const Value: TManageParam);
begin
  FManageParam := Value;
end;

procedure TJackPots.SetSymbol(const Value: TSymbol);
begin
  FSymbol := Value;
end;

procedure TJackPots.SetUseMoth(const Value: boolean);
var
  stLog : string;
begin
  FUseMoth := Value;

  if FSymbol = nil then Exit;

  stLog := Format('잔량스탑 관리  (%s ) ', [ FSymbol.ShortCode ] );

  if Value then
    stLog := stLog + ' Use Moth '
  else
    stLog := stLog + ' Not Use Moth';

  gEnv.EnvLog( WIN_TEST, stLog);
end;

function TJackPots.ISOrder( aPot : TJackPotItem; aDepths : TMarketDepths; iRes : integer ) : boolean;
var
  stSrc , stDes, stSam : string;
  iP, iFil  : integer;
  stLog : string;
  dPrice : double;
  bRes, bGo1, bGo2 : boolean;
  cRes : char;
begin

  Result := false;

  if aPot.Symbol = nil then Exit;

  iFil := 0;
  bRes := true;

  if iRes = 0 then
  begin
    case aPot.Condition of

      CondAll :
        begin
          if aPot.UseOrCond then
          begin
              stLog := 'A , Or : ';
              if aPot.Volume < aDepths[0].Volume then
                bGo1 := false
              else begin
                stLog := Format('%s 잔량 OK (%d >= %d)', [stLog , aPot.Volume, aDepths[0].Volume ]);
                bGo1 := true;
              end;

              if Assigned( FOnAccumulCheck ) then
                bRes := FOnAccumulCheck( iFil, aPot );

              if bRes then
                stLog := Format('%s 누적체결 OK (%d <= %d)', [stLog , aPot.AclFilVol, iFil]);


              if (not bRes) and (not bGo1) then
                Exit;

          end
          else begin
              stLog := 'A , And : ';
              if aPot.Volume < aDepths[0].Volume then
                Exit;

              stLog := Format('%s 잔량 OK (%d >= %d)', [stLog , aPot.Volume,aDepths[0].Volume]);
              if Assigned( FOnAccumulCheck ) then
                bRes := FOnAccumulCheck( iFil, aPot );

              if iFil <= 0 then
                Exit;

              if not bRes then
                Exit;

              stLog := Format('%s 누적체결 OK (%d <= %d)', [stLog , aPot.AclFilVol, iFil]);
          end;
        end;
      CondFil :
        begin
          stLog := 'F : ';
          bRes := false;
          if Assigned( FOnAccumulCheck ) then
            bRes := FOnAccumulCheck( iFil, aPot );
          {
          if iFil <= 0 then
            Exit;
          }
          if not bRes then
            Exit;
          stLog := Format('%s 누적체결 OK (%d <= %d)', [stLog , aPot.AclFilVol, iFil]);
        end;
      CondVol :
        begin
          stLog := 'V : ';
          if aPot.Volume < aDepths[0].Volume then
            Exit;
          stLog := Format('%s 잔량 OK (%d >= %d)', [stLog , aPot.Volume, aDepths[0].Volume]);
        end;
    end;
  end
  else begin
    stLog := Format( '호가변화 - Stop:%s  상대호가:%s', [ stSrc, stDes ]);
  end;

  iRes := 0;
  if Assigned( FOnCheckJackPotOrder ) then
    iRes := FOnCheckJackPotOrder( aPot );

  aPot.AclFilVol2 := iFil;

  if iRes <> aPot.OrdQty then
  begin
    stLog := Format('%s, %s|%s ,(%d|%d) %d|%d',
    [ ifThenStr( aPot.Side = 1 , '매도', '매수'),
    stSrc, stDes,
    aPot.Volume , aPot.AclFilVol,
    aPot.OrdQty, iRes
    ]);
    gLog.Add(lkKeyOrder, 'TJackPots', 'ISOrder', stLog);
    Result := false;
    Exit;
  end;

  stLog := Format('%.2f, %d, %d, %d : %s',
    [
      aPot.Price,
      aPot.OrdQty,
      aPot.Volume,
      aPot.AclFilVol,
      stLog
    ]);
  gLog.Add(lkKeyOrder, 'TJackPots', 'ISOrder', stLog);
  Result := true;

  {
  stLog := Format('%s, %s|%s ,(%d|%d) %d',
    [ ifThenStr( aPot.Side = 1 , '매도', '매수'),
    stSrc, stDes,
    aPot.Volume , aDepths[0].Volume,
    iRes
    ]);

  gLog.Add(lkKeyOrder, 'TJackPots', 'ISOrder', stLog);
  }

end;

end.
