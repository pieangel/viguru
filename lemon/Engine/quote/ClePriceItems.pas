unit ClePriceItems;

interface

uses
  Classes, SysUtils, DateUtils,

  GleTypes, GleConsts,

  CleOrders, CleSymbols, CleFills

  ;

Const
  NewAdd  = 0;
  Modify  = 1;

  Cancel  = 2;
  Fill    = 3;

  Modify2  = 4;
  Modify3  = 5;

type

  TQuoteOrdertype = ( NONE,SN,SC,SPC,SPM,LN,LC,LPC,LPM,All,FL);
  // 잔량 기준으로
  TFillOrderType  = ( ftMore, ftLittle, ftSame, ftLittleC );

  TOrderData = class( TCollectionItem )
  private
    FName: string;
    FOwn: boolean;
    FPrice: string;
    FQty: string;
    FSide: string;
    FTime: TDateTime;
    FCondition: integer;
    FQType: TQuoteOrdertype;
    FNo: integer;
    FNo2: integer;
    FFType: TFillOrdertype;
    FBGone: boolean;
    FFillQty: string;
    FContinueFill: boolean;
  public
    //  dprice -> dprice2   정정시
    dPrice, dPrice2 : double;

    function GetText : string;
    function GetOrderDiv : string;
    function GetOrderPrice : string;
    function GetOrderPrice2 : string;
    function GetOrderState: string;
    function GetOrderState2: string;
    function GetHoga: string;

    property Name : string read FName write FName;
    property Side : string read FSide write FSide;
    property Qty  : string read FQty write FQty;
    property FillQty  : string read FFillQty write FFillQty;
    property Price : string read FPrice write FPrice;
    property Own  : boolean read FOwn write FOwn;
    property Time : TDateTime read FTime write FTime;
    property Condition  : integer read FCondition write FCondition;
    property No   : integer read FNo write FNo;
    property No2   : integer read FNo2 write FNo2;

    property QType  : TQuoteOrdertype read FQType write FQType;
    property FType  : TFillOrdertype read FFType write FFType;
    property BGone  : boolean read FBGone write FBGone;

    property ContinueFill : boolean read FContinueFill write FContinueFill;
  end;

  TForceDist = class
  private
    FQty: integer;
    FOwn: boolean;
    FMax: boolean;
    //FDonNo: boolean;
    FTime: TDateTime;
    FOrder: TOrder;
    FOrdFill: boolean;
    FCorrCnt: integer;
    FDistTime: string;
    FContinueDist: Boolean;
    FContinueSTime: TDateTime;
    FContinueDepth: integer;
    //FAccount: TAccount;
    //procedure SetAccount(const Value: TAccount);              // self order qty
  public
    Constructor Create;
    property Qty   : integer read FQty write FQty;
    property Own   : boolean read FOwn write FOwn;
    property Max   : boolean read FMax write FMax;
    //property DonNo : boolean read FDonNo write FDonNo;
    property Time  : TDateTime  read FTime write FTime;
    property Order : TOrder read FOrder write FOrder;
    property OrdFill  : boolean read FOrdFill write FOrdFill;
    property CorrCnt  : integer read FCorrCnt write FCorrCnt;
    property DistTime  : string read FDistTime write FDistTime;

    property ContinueDist : Boolean read FContinueDist write FContinueDist;
    property ContinueSTime: TDateTime read FContinueSTime write FContinueSTime;
    property ContinueDepth: integer read FContinueDepth write FContinueDepth;

    function SetQuotePosition( aOrder : TOrder ) : boolean;
  end;

  TNFindOrder = class( TCollectionItem )
  public
    OrderExist  : boolean;
    OwnOrder    : TOrder;
  end;

  TQuoteList = class
  public
    Time  : TDateTime;
  end;

  TPriceItem = class( TCollectionItem )
  private
    procedure Filled;
    procedure CorrectVolume(iDiff: integer);

    function GetOwnText : string;
    function GetText : string; overload;
    function GetText(var bOwn : boolean ) : string; overload;
    function CheckOwnOder : boolean; overload;
    function CheckOwnOder(aDist: TForceDist; idx : integer): boolean; overload;
    procedure FindOwnOrder(aOrder: TOrder; idx : integer);

    // add 02.25
    function CalcNotDistQty( iQty : integer; isFill : boolean = true ) : integer;
    function CheckFill( stTime : string ) : integer;
    function CheckFillQty(aSum : integer): integer;
    function CheckCancelOrder(aDist: TForceDist) : boolean;

    procedure CheckNearTime(aDist: TForceDist);
    procedure CheckMaxQty( aDist : TForceDist; bFirst : boolean = false);

  public

    Price : Double;
    PriceDesc : string;
    Volume  : array [TNavi] of Integer;
    Cnt     : array [TNavi] of integer;
    Side    : array [TNavi] of TSideType;
    Index   : array [TNavi] of Integer;


    CntDiff : integer;
    VolDiff : integer;
    FillVol : integer;

    ForceList : TList;
    DelList   : TList;
    //IsFill    : Boolean;
    IsQuoteNow     : boolean;
    IsFillNow      : boolean;
    IsFirst        : boolean;

    CalcVol : integer;
    EventCount : integer;
    PrevEventCount : integer;

    // add
    OrderExists : boolean;
    NFindOrders : TCollection;
    DelOrdres   : TCollection;
    OwnCount    : integer;
    DelayMs     : integer;
    DistTime    : string;

    Changed : boolean;

    //
    DelQty  : integer;
    FillQty : integer;

    FullLog, SaveOwnOrder : string;
    NotDistQty : integer;
    NotDistQty2: integer;

    // 누적 체결
    StartTime : TDateTime;
    AccumulVol: integer;

    ContinueDepth: integer;
    FirstSis  : boolean;
    LastData  : TOrderData;

    //
    Constructor Create(aColl: TCollection); override;
    Destructor  Destroy ; override;
    procedure SetItemValue( idx, iSide , iVol, iCnt : integer; stTime : string );
    procedure GetNumberOfCases;
    procedure Add( bFirst : boolean = false);
    procedure Delete( bAll : boolean = false);
    procedure DeleteOrder( aDist : TForceDist );
    procedure DeleteOrder2( aOrder : TOrder );
    procedure Clear;
    procedure Log( s : string );

    procedure AddOrder( aOrder : TOrder );
    procedure AddOrder2( aOrder : TOrder );


    procedure DecOwnCount;
    procedure IncOwnCount;
    procedure ReSetNotDistQty;

    // 누적 체결량
    procedure SetFillVol( aVol : integer  );
    procedure AddFill( dPrice : double; iSide, iVol : integer; stTime : string );


  end;

  TPriceAxis = class( TCollection )
  private

    function GetPrice(i: integer): TPriceItem;

  public
    OrderList: TCollection;
    Prec     : integer;
    TickSize : double;
    //Count    : integer;
    Symbol   : TSymbol;

    DelaySec  : integer;
    UseSumShow : boolean;


    //  dispaly 용도
    ShowMaxQty : boolean;
    MaxQty  : integer;


    Constructor Create;
    Destructor Destroy; override;

    function New( dPrice : Double ) : TPriceItem;
    function Find( Price: double; var iPos: integer): TPriceItem; overload;
    function Find( dPrice : Double ) : TPriceItem; overload;
    function Find( stPrice : string ) : TPriceItem; overload;
    function FindIndex( dPrice : Double ) : integer;

    property Prices[i : integer] : TPriceItem read GetPrice;

  end;

implementation

uses
  GAppEnv, CleQuoteBroker, ClePositions;

{ TOrderData }

function TOrderData.GetHoga: string;
begin

  if ( QType in [ SPM, LPM, All, FL] ) then
    Result := Format( '%d', [ No2 + 1 ])
  else
    Result := Format( '%d', [ No + 1 ]);
end;

function TOrderData.GetOrderState2: string;
begin
  // No2 in hoga
  // No out hoga

  if (FQtype = LPM) or (( FQtype = All ) and  ( Side = 'L' ))  or
    (( FQtype = FL ) and  (Side = 'L'))
  then  begin

    if ( FQtype = FL ) then begin
      if Name[1] = 'N' then
        Result := 'L'
      else
        Result  := 'Lc';
    end
    else begin
      if dPrice2 < PRICE_EPSILON then
        Result := 'Sc'
      else if dPrice < PRICE_EPSILON then
        Result := 'Lc'
      else begin
        if dPrice2 > dPrice then
          Result := 'Lc'
        else if dPrice2 < dPrice then
          Result := 'Sc'
        else
          Result := 'xx';
      end;

      {
      if (No2 > 0) and ( No = 0) then
        Result := 'Lc'
      else if ( No2 = 0) and ( No > 0) then
        Result := 'Sc'
      else if No2 > No then
        Result := 'Sc'
      else if No2 < No then
        Result := 'Lc'
      else
        Result := 'xx';
      }
    end;
  end else
  if (FQtype = SPM) or (( FQtype = All ) and ( Side = 'S')) or
  (( FQtype = FL ) and ( Side = 'S'))  then
  begin
    if ( FQtype = FL )  then  begin
      if Name[1] = 'N' then
        Result := 'S'
      else
        Result := 'Sc';
    end
    else begin

      if dPrice2 < PRICE_EPSILON then
        Result := 'Lc'
      else if dPrice < PRICE_EPSILON then
        Result := 'Sc'
      else begin
        if dPrice2 > dPrice then
          Result := 'Lc'
        else if dPrice2 < dPrice then
          Result := 'Sc'
        else
          Result := 'xx';
      end;
      {
      if (No2 > 0) and ( No = 0) then
        Result := 'Sc'
      else if ( No2 = 0) and ( No > 0) then
        Result := 'Lc'
      else if (No2 > No) and ( No > 0) then
        Result := 'Lc'
      else if (No2 < No) and ( No2 > 0) then
        Result := 'Sc'
      else
        Result := 'xx';
        }
    end;
  end;

end;




function TOrderData.GetOrderState: string;
begin
  case FQtype of

    SN: Result := 'S';
    SC,
    SPC: Result := 'Sx';
    SPM: Result := 'Sc';
    LN: Result := 'L';
    LC,
    LPC: Result := 'Lx';
    LPM: Result := 'Lc';
    All:
      begin
        if Side = 'L' then
          Result := 'Lc'
        else
          Result := 'Sc';
      end;
    FL:
      begin
        case Side[1] of
          'L' :
            begin
              if Name[1] = 'N' then
                Result := 'L'
              else
                Result := 'Lc';
            end;
          'S' :
            begin
              if Name[1] = 'N' then
                Result := 'S'
              else
                Result := 'Sc';
            end;
        end;
      end
  end;  // case

end;

function TOrderData.GetOrderDiv: string;
var
  s1, s2 : string;
  d1, d2 : double;
begin

  d1 := dPrice;
  d2 := dPrice2;

  if d1 > 100 then
    d1 := d1 - 100;
  if d2 > 100 then
    d2 := d2 - 100;

  if dPrice = 0 then
    s1 := Format('%6s', [''])
  else
    s1 := Format('%.2f', [d1]);

  if dPrice2 = 0 then
    s2 := Format('%6s', [''])
  else
    s2 := Format('%.2f', [d2]);

  //Result := Format('%s->%s', [ s1, s2]);
  case FQtype of
    NONE: Result := '' ;
    SN, LN:           Result := Format('%s->%s', [ s2, s1]);
    SC, SPC, LC, LPC: Result := Format('%s->%s', [ s1, s2]);
    SPM,LPM,All :     Result := Format('%s->%s', [ s1, s2]);
    FL  : Result := Format('%s->%s', [ s1, s2]);
  end;

end;

function TOrderData.GetOrderPrice: string;
var
  iPos : integer;
  stTmp : string;
  bC : boolean;
begin
  bc := false;
  case FQtype of
    NONE: stTmp := '' ;
    SPM, LPM, ALL, FL  : stTmp := Format('%.2f', [ dPrice2 ]);
    SC, SPC, LC, LPC  :
      begin
        bc := true;
        stTmp := Format('%.2f', [ dPrice ]);
      end

    else
      stTmp := Format('%.2f', [ dPrice ]);
  end;

  iPos := Pos( '.', stTmp );

  Result := Copy( stTmp, iPos+1, Length( stTmp ));
end;

function TOrderData.GetOrderPrice2: string;
var
  iPos : integer;
  stTmp : string;
  bC : boolean;
begin
  bc := false;
  case FQtype of
    NONE: stTmp := '' ;
    FL  : stTmp := Format('%.2f', [ dPrice2 ]);
    SC, SPC, LC, LPC  :
      begin
        bc := true;
        stTmp := Format('%.2f', [ dPrice ]);
      end

    else
      stTmp := Format('%.2f', [ dPrice ]);
  end;

  Result := stTmp;

end;

function TOrderData.GetText: string;
begin
  Result := Format('%s,%s,%s,%s',[ Name, Price, Side, Qty ]);
end;

{ TForceDist }

constructor TForceDist.Create;
begin
  //FDonNo := false;
  FQty:= 0;
  FCorrCnt  := 0;
  FOwn:= false;
  FMax:= false;
  FTime := gEnv.Engine.QuoteBroker.Timers.Now;
  FOrder  := nil;
  FOrdFill:= false;
  FContinueDist := false;
end;

{
procedure TForceDist.SetAccount(const Value: TAccount);
begin
  if Value = nil then Exit;

  if FAccount = nil then
    FAccount := Value
  else begin
    if FAccount <> Value then
      Exit;
  end;
end;
}

function TForceDist.SetQuotePosition(aOrder: TOrder): boolean;
begin
  FOwn  := true;
  FOrder  := aOrder;

end;

{ TPriceAxis }

constructor TPriceAxis.Create;
begin
  inherited Create( TPriceItem );
  OrderList := TCollection.Create( TOrderData );

  Symbol := nil;

  DelaySec  := 1000;

  UseSumShow:= false;

  ShowMaxQty := false;
  MaxQty  := 100;
end;

destructor TPriceAxis.Destroy;
begin
  OrderList.Free;
  inherited;
end;

function TPriceAxis.Find(stPrice: string): TPriceItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  aItem : TPriceItem;
  stFindKey, stDesKey: String;
begin

  Result := nil;
  stFindkey := stPrice;
  iLow := 0;
  iHigh:= Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    aItem := GetPrice(iMid);
    if aItem = nil then
      break;
    iCom     := CompareStr( aItem.PriceDesc, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := aItem;
        break;;
      end;
    end;
  end;

end;

function TPriceAxis.FindIndex(dPrice: Double): integer;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  aItem : TPriceItem;
  stFindKey, stDesKey: String;
begin

  Result := -1;
  stFindkey := Format('%*n', [ Prec, dPrice ] );
  iLow := 0;
  iHigh:= Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    aItem := GetPrice(iMid);
    if aItem = nil then
      break;
    iCom     := CompareStr( aItem.PriceDesc, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := iMid;
        break;;
      end;
    end;
  end;

end;

function TPriceAxis.Find(dPrice: Double): TPriceItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  aItem : TPriceItem;
  stFindKey, stDesKey: String;
begin

  Result := nil;
  stFindkey := Format('%*n', [ Prec, dPrice ] );
  iLow := 0;
  iHigh:= Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    aItem := GetPrice(iMid);
    if aItem = nil then
      break;
    iCom     := CompareStr( aItem.PriceDesc, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := aItem;
        break;;
      end;
    end;
  end;

end;

function TPriceAxis.Find(Price: double; var iPos : integer ): TPriceItem;
var
  iLow, iHigh, iMid, iCom, idx, i, iTmp : integer;
  aItem : TPriceItem;
  stFindKey, stDesKey: String;
begin

  Result := nil;
  stFindkey := Format('%*n', [ Prec, Price ] );
  iLow := 0;
  iHigh:= Count-1;

  while iLow <= iHigh do begin
    iMid  := (iLow + iHigh) shr 1;
    aItem := GetPrice(iMid);
    if aItem = nil then
      break;

    stDesKey := Format( '%*n', [Prec, aItem.Price ]);
    iCom     := CompareStr( stDesKey, stFindKey );

    if iCom < 0 then iLow := iMid +  1
    else begin
      iHigh := iMid -1;
      if iCom = 0 then begin
        Result := aItem;
        break;;
      end;
    end;
  end;
  iPos := iLow;
end;

function TPriceAxis.GetPrice(i: integer): TPriceItem;
begin
  if (i < 0) and (i >= Count) then
    Result := nil
  else
    Result := Items[i] as TPriceItem;

end;


function TPriceAxis.New(dPrice: Double): TPriceItem;
begin
  Result := Add as TPriceItem;
  Result.Price := dPrice;
  Result.PriceDesc  := Format('%*n', [Prec, dPrice]);

end;

{ TPriceItem }



constructor TPriceItem.Create(aColl: TCollection);
var
  i : TNavi;
begin
  inherited Create( aColl );
  for i := Last to Prev do
  begin
    Volume[i]  := 0;
    Cnt[i]     := 0;
    Side[i]    := stNone;
    Index[i]   := -1;
  end;
  CntDiff := 0;
  VolDiff := 0;
  CalcVol := 0;
  EventCount  := 0;
  PrevEventCount  := 0;
  DelQty  := 0;
  FillQty := 0;
  IsFirst  := false;
  IsQuoteNow := false;
  IsFillNow  := false;
  ForceList := TList.Create;
  DelList   := TList.Create;

  NFindOrders := TCollection.Create( TNFindOrder );
  DelOrdres   := TCollection.Create( TNFindOrder );
  OrderExists := false;
  Changed := false;

  SaveOwnOrder  := '';

  NotDistQty := 0;
  NotDistQty2:= 0;

  ContinueDepth := 1;
  FirstSis  := false;

  StartTime := gEnv.Engine.QuoteBroker.Timers.Now;
end;

procedure TPriceItem.AddFill(dPrice: double; iSide, iVol: integer;
  stTime: string);
begin
  FillVol := iVol;
  IsFillNow := true;

  Fillvol := CheckFill( stTime );
end;

procedure TPriceItem.AddOrder(aOrder: TOrder);
var
  pN : TNFindOrder;
begin
  pN  := NFindOrders.Insert(0) as TNFindOrder;
  //pN  := TNFindOrder( NFindOrders.Add );
  pN.OrderExist := true;
  pN.OwnOrder   := aOrder;
  OrderExists   := true;
  {
  gEnv.EnvLog( WIN_TEST, Format('added (%s) %s, %d : %d ',
     [ PriceDesc, aOrder.TradeTime, aOrder.OrderNo, NFindOrders.Count ]) );
  }
end;

procedure TPriceItem.AddOrder2(aOrder: TOrder);
var
  pN : TNFindOrder;
begin
  pN  := TNFindOrder( DelOrdres.Add );
  pN.OrderExist := true;
  pN.OwnOrder   := aOrder;
  OrderExists   := true;
  //gEnv.DoLog( WIN_TEST, Format('adddelorder (%s) %d : %d ', [ PriceDesc, aOrder.OrderNo, DelOrdres.Count ]) );
end;

procedure TPriceItem.Clear;
begin
  OrderExists := false;
  //NFindOrders.Clear;

  ForceList.Clear;
  CalcVol := 0;
  Volume[Prev]  := Volume[Last];
  Cnt[Prev]  := Cnt[Last];
  Side[Prev]  := Side[Last];
  Index[Prev] := Index[Last];

  Volume[Last]  := 0;
  Cnt[Last] := 0;
  Index[Last] := -1;

  Side[Last] := stNone;

  FillVol := 0;

  IsFillNow := false;
  IsQuoteNow := false;

  VolDiff := 0;
  CntDiff := 0;
  OwnCount := 0;

  NotDistQty:= 0;
  NotDistQty2:=0;

  ContinueDepth := 1;
  FirstSis  := false;

  DelList.Clear;
  //DelOrders.

end;


procedure TPriceItem.CorrectVolume( iDiff : integer );
var
  aDist, aDist2 : TForceDist;
  iTmp, aQty, i, iOwn : integer;
  stLog,stTmp : string;
  bFind : boolean;
begin

  if iDiff < 0 then
  begin
    if ForceList.Count = 0 then begin
      //NotDistQty  := abs( iDiff );
      inc( NotDistQty, abs( iDiff ));
      inc( CalcVol, NotDistQty );
    end
    else begin
    {
      if OwnCount > 0 then
        NotDistQty2 := abs( iDiff )
      else
        NotDistQty  := abs( iDiff );
     }
      if OwnCount > 0 then
        inc(NotDistQty2 , abs( iDiff ))
      else
        inc(NotDistQty  , abs( iDiff ));

      inc( CalcVol, abs( iDiff ) );
      //**
      {
      stLog := Format('CorrectVolume - c : %d, v : %d, d : %d', [ CalcVol, Volume[Last], iDiff]);
      inc( CalcVol, abs( iDiff ) );
      gEnv.DoLog(WIN_TEST, stLog );
      }
    end;

  end
  else if iDiff > 0 then
  begin
    if ForceList.Count = 0 then Exit;

    aQty := CalcNotDistQty( iDiff, false );

    try

    for i := ForceList.Count-1  downto 0 do
    begin

      aDist := TForceDist( ForceList.Items[i] );
      if aQty <= 0 then break;

      if (aDist.Own) and ( aDist.Order <> nil ) then
        if aDist.FQty = aDist.Order.ActiveQty then
          Continue ;

      if aDist.FQty < aQty then begin
        aQty := aQty - aDist.FQty;
        dec( CalcVol, aDist.FQty );
        aDist.FQty := 0;
      end else
      if aDist.FQty = aQty then begin
        aDist.FQty := 0;
        dec( CalcVol, aQty );
        aQty := -1;
      end else
      if aDist.FQty > aQty then begin
        aDist.FQty := aDist.FQty - aQty;
        dec( CalcVol, aQty );
        aQty := -1;
      end;

      if aDist.Qty = 0 then
      begin
        aDist.Free;
        ForceList.Delete(i);
      end;
    end;

    if aQty > 0 then
      CalcNotDistQty( aQty, true );

    except
      stLog := Format('c : %d, v : %d, d : %d %s', [ i, Volume[Last], iDiff, DistTime]);
    end;
  end;


end;

procedure TPriceItem.Add( bFirst : boolean );
var
  aDist : TForceDist;
  iDiff, i, aQty : integer;
begin
   if bFirst then begin
    ForceList.Clear;
    OwnCount  := 0;
    NotDistQty:= 0;
    NotDistQty2 := 0;
    aDist := TForceDist.Create;
    aDist.FQty  := Volume[Last];
    CalcVol := Volume[Last];
    aDist.DistTime := DistTime;
  end
  else begin

    if CntDiff <> 1 then
    begin

      if OwnCount > 0 then
        inc(NotDistQty2, volDiff)
      else
        inc( NotDistQty, VolDiff );

      inc( CalcVol, VolDiff );

      iDiff := CalcVol - Volume[Last];
      if iDiff <> 0 then
        CorrectVolume( iDiff );
      Exit;
    end  ;

    aDist := TForceDist.Create;
    aDist.FQty  := VolDiff;
    aDist.DistTime := DistTime;
    inc(CalcVol, VolDiff );
  end;
  ForceList.Add( aDist );

  if not bFirst then
  begin
    CheckOwnOder( aDist, ForceList.Count-1 );
    CheckNearTime( aDist );
    CheckMaxQty( aDist );

    iDiff := CalcVol - Volume[Last];
    if iDiff <> 0 then
      CorrectVolume( iDiff );
  end
  else
    CheckMaxQty( aDist, true );
end;

procedure TPriceItem.DecOwnCount;
begin
  Dec( OwnCount );
  {
  gEnv.EnvLog( WIN_TEST,  Format('DecOwnCount : %s , %d', [ PriceDesc, OwnCount ])
  );
  }
  if OwnCount < 0 then
    OwnCount := 0;


end;

procedure TPriceItem.Delete( bAll : boolean );
var
  iOwn,i, iDiff, aQty : integer;
  aDist : TForceDist;
  bFind : boolean;
  stTmp : string;
  bRes  : boolean;
begin
  bFind := false;
  aQty := abs( VolDiff );

  if abs(CntDiff) <= 1 then
  begin

    aDist := TForceDist.Create;
    aDist.Qty := aQty;
    aDist.DistTime  :=  DistTime;

    bRes := CheckCancelOrder( aDist );

    if bRes then
      aDist.Free
    else begin
      DelList.Add( aDist );
      for i := ForceList.Count-1 downto 0 do
      begin
        aDist := TForceDist( ForceList.Items[i] );
        if aDist.FQty = aQty then
        begin
          if aDist.Own then
            Continue;
          {
          begin
            if aDist.Order <> nil then
              if aDist.Order.ActiveQty > 0 then
                Continue;
          end;
          }
          aDist.Free;
          ForceList.Delete(i);
          dec( CalcVol, aQty );
          bFind := true;
          break;
        end;
      end;

    end;
  end;

  iDiff := CalcVol - Volume[Last];
  if iDiff <> 0 then
    CorrectVolume( iDiff );

end;

procedure TPriceItem.DeleteOrder(aDist: TForceDist);
var
  iGap : integer;
begin
  if aDist.Order = nil then Exit;

  iGap  := aDist.FQty - aDist.Order.ActiveQty;

  if iGap > 0 then
  begin
    dec(  CalcVol, iGap );
    aDist.FQty  := aDist.Order.ActiveQty;
  end;
  //ForceList.Delete(i);
end;

procedure TPriceItem.DeleteOrder2(aOrder: TOrder);
var
  i : integer;
  nOrd  : TNFindOrder;
begin

  for i := DelOrdres.Count-1 downto 0 do
  begin
    nOrd  := TNFindOrder( DelOrdres.Items[i] );
    if nOrd.OwnOrder = aOrder then
    begin
      DelOrdres.Delete(i);
      break;
    end;
  end;

end;

function TPriceItem.CalcNotDistQty(iQty: integer; isFill: boolean): integer;
var
  iNotDistQty : integer;
begin
  if isFill then
    iNotDistQty := NotDistQty
  else
    iNotDistQty := NotDistQty2;

  if iNotDistQty <= 0 then
    Result := iQty
  else if iNotDistQty > iQty then begin
    Dec( iNotDistQty, iQty );
    Dec( CalcVol, iQty );
    Result := 0;
  end
  else if iNotDistQty = iQty then begin
    iNotDistQty := 0;
    Dec( CalcVol, iQty );
    Result := 0;
  end
  else if iNotDistQty < iQty then begin
    Result := iQty - iNotDistQty;
    Dec( CalcVol, iNotDistQty );
    iNotDistQty := 0;
  end;

  if isFill then
    NotDistQty  := iNotDistQty
  else
    NotDistQty2 := iNotDistQty;
end;

function TPriceItem.CheckCancelOrder(aDist: TForceDist): boolean;
var
  i, iRes : integer;
  nOrd : TNFindOrder;
  stLog : string;
begin
  Result := false;

  for i := DelOrdres.Count-1 downto 0 do
  begin
    nOrd  := TNFindOrder( DelOrdres.Items[i] );
    if nOrd = nil then Continue;
    iRes := CompareStr( nOrd.OwnOrder.TradeTime, aDist.DistTime);

    if iRes < 0 then begin
      DelOrdres.Delete(i);
      Continue;
    end;

    if iRes = 0 then
    begin
      //**
      {
      stLog := Format( 'First Cnl Ord(%s) : ord:%s ( Dist:%s ) ,%d,  %d  ',
      [ PriceDesc,
        nOrd.OwnOrder.TradeTime,
        aDist.DistTime,
        nOrd.OwnOrder.OrderNo,
        aDist.FQty
        ]);
      gEnv.DoLog( WIN_TEST, stLog);
      }
      DelOrdres.Delete(i);
      Result := true;
    end;
  end;


end;

function TPriceItem.CheckFill(stTime: string): integer;
var
  j, i : Integer;
  aOrder : TOrder;
  bFind  : boolean;
  stLog : string;
  iDist : TForceDist;

  aPosition : TPosition;
  aFill     : TFill;
  aFillSum  : integer;
begin

  Result := FillVol;

  aPosition := gEnv.Engine.TradeCore.Positions.Find(
     TPriceAxis( Collection ).Symbol );

  if aPosition = nil then Exit;

  try

    aFillSum  := 0;

    //gEnv.EnvLog( WIN_TEST, 'CheckFill : ' + stTime);

    for i := gEnv.Engine.TradeCore.Fills.Count-1 downto 0 do
    begin
      aFill := TFill(gEnv.Engine.TradeCore.Fills.Items[i] );
      if aFill = nil then Continue;
      if aFill.Symbol <> TPriceAxis( Collection ).Symbol then Continue;
      
      if aFill.IsCheck then
        break;

      j := CompareStr( stTime , aFill.FillTime2 );
      //**
      {
      stLog := Format('Find Fill : %s,%d | %s,%d | %d, %d (%s)', [
        stTime, FillVol, aFill.FillTime2, aFill.Volume,
        aPosition.Fills.Count, i , aFill.Account.Code
        ]);
      gEnv.EnvLog( WIN_TEST, stLog);
      }

      if j > 0 then
        break
      else if j < 0 then   //  stTime 이 작다..
        continue
      else if j = 0 then begin
        inc(aFillSum, abs(aFill.Volume) );
        //**
        {
        stLog := Format('Fill Sum : %s,%d | %s,%d | %d, %d ', [
          stTime, FillVol, aFill.FillTime2, aFill.Volume,
          aPosition.Fills.Count, i
          ]);
        gEnv.EnvLog( WIN_TEST, stLog);
        }
        aFill.IsCheck := true;
      end;
        //aList.Add( aFill );
    end;

  finally

    if aFillSum > 0 then
    begin
      FirstSis  := true;
      Result := CheckFillQty( aFillSum );
      //**
      //gEnv.EnvLog( WIN_TEST, Format('CheckFill : %d, %d, %d', [FillVol, aFillSum, Result ]));
    end;

  end;


end;

function TPriceItem.CheckFillQty(aSum: integer): integer;
begin
  Result := FillVol - aSum;
  if Result < 0 then
    Result := 0;
end;

procedure TPriceItem.CheckMaxQty(aDist: TForceDist; bFirst : boolean);
var
  iQty : integer;
  aQuote : TQuote;
  aData  : TOrderData;
  bFill : boolean;
begin
  aQuote := nil;
  bFill  := false;

  if not bFirst then
  begin
    if CntDiff <> 1 then
      Exit;

    iQty :=  TPriceAxis( Collection ).MaxQty;
    if iQty <= 0 then
      Exit;

    if aDist.Qty >= iQty then
      aDist.Max := true;
  end
  else begin
    // 치는 주문으로 잔량이 남았을경우..
    // 오리지널 주문수량이 Max 보다 큰지 체크한다.
    if TPriceAxis( Collection ).Symbol <> nil then
      aQuote  := TPriceAxis( Collection ).Symbol.Quote as TQuote;

    if aQuote = nil then Exit;

    aData := aQuote.LastData;
    if aData = nil then
      Exit;

    if aData.FType = ftMore then
    begin
      iQty :=  TPriceAxis( Collection ).MaxQty;
      if StrToIntDef(aData.Qty, 0) >= iQty then
      begin
        bFill := true;
        aDist.Max := true;
      end;
    end;
  end;

  if (aDist.Max) and ( not bFill ) then
  begin
    if aQuote = nil then
      aQuote  := TPriceAxis( Collection ).Symbol.Quote as TQuote;

    if aQuote = nil then Exit;

  end;
end;

procedure TPriceItem.CheckNearTime(aDist: TForceDist);
var
  pDist : TForceDist;
  i, j, iDelaySec : integer;
  iDelay : int64;
  bGo : boolean;
  stLog : string;
begin

  iDelaySec :=  TPriceAxis( Collection ).DelaySec;

  if aDist.FOwn then
  begin
    inc(ContinueDepth);
    Exit;
  end;

  if ForceList.Count < 2 then
    Exit;

  try
    //
    for i := ForceList.Count-2 downto 0 do
    begin
      pDist := TForceDist( ForceList.Items[ i ]);
      if pDist = nil then Continue;
      if (pDist.Qty <> aDist.Qty) or ( pDist.FOwn ) then
      begin
        inc(ContinueDepth);
        break;
      end;

      iDelay := MilliSecondsBetween( aDist.Time , pDist.Time );
      if iDelay > iDelaySec then
      begin
        inc(ContinueDepth);
        break;
      end;

      if not pDist.ContinueDist then
      begin
        pDist.ContinueDist  := true;
        pDist.ContinueSTime := pDist.Time;
        pDist.ContinueDepth := ContinueDepth;

        aDist.ContinueDist  := true;
        aDist.ContinueSTime := pDist.Time;
        aDist.ContinueDepth := ContinueDepth;

      end
      else begin
        iDelay := MilliSecondsBetween( aDist.Time , pDist.ContinueSTime );
        if iDelay <= iDelaySec then
        begin
          aDist.ContinueDist  := true;
          aDist.ContinueSTime := pDist.ContinueSTime;
          aDist.ContinueDepth := pDist.ContinueDepth;
        end
        else begin
          inc(ContinueDepth);
          break;
        end;

      end;
    end;    

  except

  end;

end;


function TPriceItem.CheckOwnOder: boolean;
var
  i, iRes, iDelay : integer;
  nOrd : TNFindOrder;
  stLog : string;
  dQuote: TDateTime;
  aQuote: TQuote;
  aDist : TForceDist;
begin
  Result := false;

  if NFindOrders.Count > 0 then
    ReSetNotDistQty;

  for i := NFindOrders.Count-1 downto 0 do
  begin
    iDelay := 0;
    nOrd  := TNFindOrder( NFindOrders.Items[i] );
    if nOrd = nil then Continue;

    aDist := TForceDist.Create;
    aDist.FQty    := nOrd.OwnOrder.ActiveQty;

    aDist.DistTime:= nOrd.OwnOrder.TradeTime;
    aDist.Order   := nOrd.OwnOrder;
    aDist.Own     := true;
    incOwnCount;

    Dec(NotDistQty, aDist.FQty );
    ForceList.Add( aDist );

    NFindOrders.Delete(i);
  end;

end;

function TPriceItem.CheckOwnOder( aDist : TForceDist; idx : integer ) : boolean;
var
  i, iRes, iDelay : integer;
  nOrd : TNFindOrder;
  stLog : string;
  dQuote: TDateTime;
  aQuote: TQuote;
begin
  Result := false;

  for i := NFindOrders.Count-1 downto 0 do
  begin
    iDelay := 0;
    nOrd  := TNFindOrder( NFindOrders.Items[i] );
    if nOrd = nil then Continue;
    iRes := CompareStr( nOrd.OwnOrder.TradeTime, aDist.DistTime );
    //**
    {
    stLog := Format( 'Compare(%s) : order : %s ( dist : %s ) ,%d,  %d   ',
      [
        PriceDesc,
        nOrd.OwnOrder.TradeTime,
        aDist.DistTime,
        aDist.FQty,
        nOrd.OwnOrder.OrderNo
      ]);
    gEnv.EnvLog( WIN_TEST, stLog);
    }

    if iRes < 0 then // TradeTime < DistTime
    begin
      //**
      {
      stLog := Format( 'OverTime(%s) : Order : %s ( dist: %s ) ,%d,  %d  delay(%d) , ForceCnt : %d ',
        [
        PriceDesc,
        nOrd.OwnOrder.TradeTime,
        aDist.DistTime,
        aDist.FQty,
        nOrd.OwnOrder.OrderNo,
        iDelay,
        ForceList.Count
        ]);
      gEnv.EnvLog( WIN_TEST, stLog );
      }

      FindOwnOrder( nOrd.OwnOrder, idx );
      //KRXQuoteEmulationForm.ButtonPauseClick( nil );
      NFindOrders.Delete(i);
      Result := true;
      Continue;
    end;

    if ( iRes = 0 ) and (aDist.Qty  = nOrd.OwnOrder.OrderQty) and ( not aDist.FOwn ) then
    begin
      //**
      {
      stLog := Format( 'find(%s) : ord:%s ( Dist:%s ) ,%d,  %d delay(%d) ',
      [ PriceDesc,
        nOrd.OwnOrder.TradeTime,
        aDist.DistTime,
        nOrd.OwnOrder.OrderNo,
        aDist.FQty,
        DelayMs
        ]);
      gEnv.EnvLog( WIN_TEST, stLog);
      }

      ReSetNotDistQty;

      aDist.Own := true;
      aDist.Order := nOrd.OwnOrder;
      IncOwnCount;
      NFindOrders.Delete(i);
      Result := true;

    end;
  end;
end;

procedure TPriceItem.FindOwnOrder( aOrder : TOrder; idx : integer );
var
  i, iRes : integer;
  aDist, iDist : TForceDist;
  stLog : string;
  bFind : boolean;
begin
 { bFind := false;

  if (idx < ForceList.Count) and ( idx > -1) then
  begin
    //**
  }
    {
    stLog := Format( 'InsertIdxOrder(%s)%d,%d : ord:%s, %d  ,%d  (%d, %d %d ) ',
    [ PriceDesc,
      ForceList.Count,
      idx,
      aOrder.TradeTime,
      aOrder.OrderNo,
      aOrder.ActiveQty,

      Volume[Last],
      NotDistQty,
      NotDistQty2
      ]);
    gEnv.EnvLog( WIN_TEST, stLog);
    }
    {
    if (ForceList.Count = 0) and ( Volume[Last] > 0) then
    begin
      iDist := TForceDist.Create;
      iDist.DistTime  := aOrder.TradeTime;
      iDist.FQty  := Volume[Last];
      NotDistQty := 0;
      NotDistQty2:= 0;
      ForceList.Add( iDist );
      stLog := Format( 'Add Dist : %d ', [ Volume[Last]]);
      gEnv.EnvLog( WIN_TEST, stLog);
    end;
    }
    ReSetNotDistQty;
    iDist := TForceDist.Create;
    //iDist.FDonNo:= false;
    iDist.DistTime  := aOrder.TradeTime;
    iDist.FQty  := aOrder.ActiveQty;
    iDist.Own   := true;
    iDist.Order := aOrder;
    ForceList.Insert(ForceList.Count, iDist);
    IncOwnCount;
    inc( CalcVol, aOrder.ActiveQty );

    Exit;

 // end;

 for i := ForceList.Count - 1  downto 0 do
  begin
    aDist := TForceDist( ForceList.Items[i] );
    if aDist = nil then Continue;

    iRes := CompareStr( aOrder.TradeTime, aDist.DistTime );

    if ( iRes = 0 ) and (aDist.Qty  = aOrder.ActiveQty) and ( not aDist.FOwn ) then
    begin
      //**
      {
      stLog := Format( 'FindOwnOrder(%s) : ord:%s ( Dist:%s ) ,%d,  %d delay(%d) ',
      [ PriceDesc,
        aOrder.TradeTime,
        aDist.DistTime,
        aOrder.OrderNo,
        aDist.FQty,
        DelayMs
        ]);
      gEnv.EnvLog( WIN_TEST, stLog);
      }

      aDist.Own := true;
      aDist.Order := aOrder;
      inc(OwnCount);
      bFind := true;

      break;
    end
    else if ( iRes > 0 ) then  begin
      iDist := TForceDist.Create;
      //iDist.FDonNo:= false;
      iDist.DistTime  := aOrder.TradeTime;
      iDist.FQty  := aOrder.ActiveQty;
      iDist.Own   := true;
      iDist.Order := aOrder;
      ForceList.Insert(i, iDist);
      inc( CalcVol, aOrder.ActiveQty );
      //**
      {
      stLog := Format( 'InsertOrder2(%s)%d : ord:%s ( Dist:%s ) ,%d  %d  ',
      [ PriceDesc,
        i,
        aOrder.TradeTime,
        aDist.DistTime,
        aOrder.OrderNo,
        aOrder.ActiveQty
        ]);
      gEnv.EnvLog( WIN_TEST, stLog);
      }
      bFind := true;
      break;
    end;
  end;

  if not bFind then
  begin
    iDist.DistTime  := aOrder.TradeTime;
    iDist.FQty  := aOrder.ActiveQty;
    iDist.Own   := true;
    iDist.Order := aOrder;
    inc(OwnCount);
    ForceList.Add( iDist );

    inc( CalcVol, aOrder.ActiveQty );
    //**
    {
    stLog := Format( 'InsertNotOrder(%s)0 : ord:%s ( Dist:%s ) ,%d  %d(%d)  ',
    [ PriceDesc,
      aOrder.TradeTime,
      aDist.DistTime,
      aOrder.OrderNo,
      aOrder.ActiveQty,
      aDist.FQty
      ]);
    gEnv.EnvLog( WIN_TEST, stLog);
    }
  end;


end;


destructor TPriceItem.Destroy;
begin
  NFindOrders.Free;
  DelOrdres.Free;
  ForceList.Free;
  DelList.Free;
  inherited;
end;

procedure TPriceItem.Filled;
var
  iOwn, aQty, i, j  : integer;
  nDist, aDist : TForceDist;
  stLog : string;
begin

  {
  gEnv.EnvLog( WIN_TEST, Format('체결  : %s',
  [
    DistTime
  ]));
  }
  if FillVol <= 0 then
  begin

    Exit;
  end;

  aQty := CalcNotDistQty( FillVol );

  if aQty <= 0 then Exit;

  for i := 0 to ForceList.Count-1 do begin
    if aQty < 0 then break;

    aDist := TForceDist( ForceList.Items[i] );
    if aDist = nil then
      Continue;
    {
    if ( i = 0 ) and ( aDist.Own ) and  ( aDist.Order <> nil ) and
     ( aDist.Order.FilledQty > 0 ) and ( not FirstSis ) then
     {
     gEnv.EnvLog( WIN_TEST, Format('부분체결 시세먼저 : %d, %d, %d | %d ',
      [
        aDist.Order.OrderNo,
        aDist.Order.ActiveQty,
        aDist.Order.FilledQty,
        aQty
      ]))

    else
    }
    if aDist.Own then
      Continue;

    if aDist.FQty < aQty then begin
      aQty := aQty - aDist.FQty;
      dec( CalcVol, aDist.FQty );
      aDist.FQty := 0;
    end else
    if aDist.FQty = aQty then begin
      aDist.FQty := 0;
      dec( CalcVol, aQty );
      aQty := -1;
    end else
    if aDist.FQty > aQty then begin
      aDist.FQty := aDist.FQty - aQty;
      dec( CalcVol, aQty );
      aQty := -1;
    end;
  end;

  j := i;

  if (ForceList.Count-1) < j then
    j := ForceList.Count-1;

  for i := j downto 0 do
  begin
    aDist := TForceDist( ForceList.Items[i] );
    if aDist.Qty = 0 then
    begin
      aDist.Free;
      ForceList.Delete(i);
    end;
  end;
end;

procedure TPriceItem.GetNumberOfCases;
var
  aDist : TForceDist;
  stTmp, s : string;
  iDiff, i : integer;
begin

  if EventCount = 1 then
  begin

    NotDistQty := Volume[Last];
    inc( CalcVol, NotDistQty );

    IsQuoteNow   := false;
    IsFillNow    := false;
    VolDiff      := 0;
    CntDiff      := 0;

    CheckOwnOder;
    Exit;
  end;

  if IsFillNow then
  begin
    if not IsQuoteNow then
    begin
      Clear;
      s := 'clear';
    end
    else begin
      if ( Side[Prev] <> stNone ) and ( Side[Prev] <> Side[Last]) then
      begin
        // 체결로 매도/수가 바뀐 호가...
        Add( true );
        s := 'add';
      end
      else begin
        Filled;
        FirstSis := false;
        s := 'filled';
      end;
    end;
  end
  else begin

    if VolDiff > 0 then begin
      Add;
      s := 'add2';
    end
    else if VolDiff < 0 then begin
      Delete;
      s := 'delete';
    end;
  end;


  IsQuoteNow   := false;
  IsFillNow    := false;
  VolDiff      := 0;
  CntDiff      := 0;
  FillVol      := 0;

end;

function TPriceItem.GetOwnText: string;
var
  iT,iFr, iBa, iOwn,i : integer;
  aDist : TForceDist;
  st : string;
begin
  Result := '';

  if OwnCount <= 0 then Exit;
  iOwn  := OwnCount;

  iFr := 0;
  iBa := 0;
  iT  := 0;

  if NotDistQty > 0 then
    Result := IntToStr( NotDistQty )+',';

  for i := 0 to ForceList.Count - 1 do
  begin
    aDist := TForceDist( ForceList.Items[i] );
    if aDist = nil then Continue;
    inc( iT, aDist.Qty );

    if aDist.Own then
    begin
      Dec( iOwn );
      iFr := (NotDistQty + iT) - aDist.Qty;
      iBa := Volume[Last] - iFr - aDist.Qty ;
    end;

    if aDist.Own then
    begin

      st := '';
      if iFr <> 0 then
        st := Format('%d-',[iFr]);
      if aDist.Qty <> 0 then
        st := st + Format('%d',[aDist.Qty]);
      if iBa > 0 then
        st := st + Format('-%d', [iBa]) ;

      Result := Result + st+',';

      Result := Result + '[' + IntToStr( aDist.Order.OrderNo ) +'],';
    end
    else
      Result := Result + IntToStr(aDist.Qty)+',';

    if iOwn <= 0 then
      break;
  end;
end;

function TPriceItem.GetText(var bOwn: boolean): string;
var
  i : integer;
  stTmp : string;
  aDist : TForceDist;
begin
  bOwn := false;
  for i := 0 to ForceList.Count - 1 do
  begin
    aDist := TForceDist( ForceList.Items[i] );
    if aDist = nil then Continue;
    if (aDist.FOwn) then begin
      Result := Result + '나|';
      bOwn := true;
    end
    else
      Result := Result + '  |';

    Result := Result + Format('%d(%s)', [ aDist.FQty, aDist.DistTime] );
    Result := Result + '|';
  end;

  Result := PriceDesc + ':'+Result;

end;

procedure TPriceItem.ReSetNotDistQty;
begin
  if OwnCount > 0 then
    Exit;

  if NotDistQty2 > 0 then
    inc(NotDistQty, NotDistQty2 );
  NotDistQty2 := 0;

end;



procedure TPriceItem.IncOwnCount;
begin
  {
  gEnv.EnvLog( WIN_TEST,  Format('IncOwnCount : %s , %d', [ PriceDesc, OwnCount ])
  );
  }
  if OwnCount < 0 then
    OwnCount := 0;
  inc(OwnCount);
end;

function TPriceItem.GetText : string;
var
  i : integer;
  stTmp : string;
  aDist : TForceDist;
begin

  for i := 0 to ForceList.Count - 1 do
  begin
    aDist := TForceDist( ForceList.Items[i] );
    if aDist = nil then Continue;

    if (aDist.FOwn) then
      Result := Result + '나|'
    else
      Result := Result + '  |';

    Result := Result + Format('%d(%s)', [ aDist.FQty, aDist.DistTime] );
    Result := Result + '|';
  end;
end;

procedure TPriceItem.Log( s : string );
begin
  gEnv.DoLog( WIN_SIS, GetText + ','+s, false, PriceDesc);
end;

procedure TPriceItem.SetFillVol(aVol: integer);
begin
  FillVol := aVol;
end;

procedure TPriceItem.SetItemValue(idx, iSide, iVol, iCnt: integer; stTime : string);
var
  stLog : string;
  bLog  : boolean;
  iV,iC : integer;
begin

  Volume[Prev]  := Volume[Last];
  Cnt[Prev]  := Cnt[Last];
  Side[Prev]  := Side[Last];
  Index[Prev] := Index[Last];

  Volume[Last]  := iVol;
  Cnt[Last] := iCnt;
  Index[Last] := Idx;

  if iSide = 1 then
    Side[Last] := stLong
  else
    Side[Last] := stShort;

  if Side[Prev] <> Side[Last] then begin
    VolDiff := iVol;
    CntDiff := iCnt;
  end
  else begin
    VolDiff := Volume[Last] - Volume[Prev];
    CntDiff := Cnt[Last] - Cnt[Prev];
  end;

  IsQuoteNow   := true;
  inc(EventCount);

  Changed := false;

  {
  if ( PriceDesc = '211.70') and  (VolDiff = 200) then
    gEnv.EnvLog( WIN_GI, Format('%d, %d, %d, %d', [iVol, iCnt,
      VolDiff, CntDiff])   , false, PriceDesc );
  }

  if ( VolDiff <> 0) or ( CntDiff <> 0) then
  begin
    iV  := VolDiff;
    iC  := CntDiff;
    DistTime := stTime;
    GetNumberOfCases;
            {
    if (OwnCount > 0) and ( PrevEventCount <> EventCount ) then
    begin
      stLog := Format( '%s:%s|%d,%d|%d,%d|%s',
        [
          TPriceAxis( Collection ).Symbol.ShortCode,
          PriceDesc,
          iV, iC,
          Volume[Last],Cnt[Last],
          GetOwnText
        ]);
      gEnv.EnvLog( WIN_GI, stLog );
    end;
    }
  end;

  PrevEventCount  := EventCount;

  {
  gEnv.DoLog( WIN_GI, Format('%d, %d, %d, %d', [iVol, iCnt,
    VolDiff, CntDiff])   , false, PriceDesc );
  }
end;



end.
