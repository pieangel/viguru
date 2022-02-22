unit UOscillatorBase;

interface

uses
  Classes, SysUtils, Math, DateUtils,

  UObjectBase,

  CleSymbols, CleAccounts, CleQuoteBroker, Ticks,

  GleTypes, GleConsts  ,

  UPaveConfig

  ;

Const
  ArrCnt  = 2;
  SignCnt = 3;

  ZERO = 1e-8;
type

  TTermItem = class(TCollectionItem)
  public
    T : TDateTime;
    MMIndex : Integer; // daily
    O, H, L, C : Double;
    FillVol : Double;
    AccVol : Double;
  end;


  TParaItem = class( TTermItem )
  public
    Pos : integer;
    SAR, AF, EP, HighValue, LowValue : double;
    WriteCount : integer;
    procedure init;
    function ParaToString : string;
    procedure Assign( var aItem : TParaItem );

  end;

  TParaItems = class( TCollection )
  private
    FLastItem: TParaItem;
    function GetParaItem(i: integer): TParaItem;
  public
    Constructor Create; overload;
    Destructor  Destroy; override;

    function New( dtTime : TDateTime ) : TParaItem;

    property ParaItems[ i : integer] : TParaItem read GetParaItem;
    property LastItem : TParaItem read FLastItem write FLastItem;
  end;

  TParabolicSignal = class( TTradeBase )
  private
    FAccel: double;
    FAcclFact: double;

    FPeriod: integer;
    FCount: integer;
    FSAREvent: TSAREvent;
    FParas: TParaItems;
    FLastItem: TParaItem;
    FPrevItem: TParaItem;
    FSide: integer;
    FSAR: double;
    FReLoad: boolean;

    procedure SetAcclFact(const Value: double);
    procedure CalcParabolic(aQuote: TQuote; bUpdate : boolean = false); overload;
    procedure CalcParabolic(aPara : TParaItem ; aQuote: TQuote; bUpdate : boolean = false); overload;

    procedure NewTermData(aQuote: TQuote; iMMIndex : integer);
    procedure UpdateData(aQuote: TQuote);  

    function  ParaToStringTitle : string;
  public

    Signal : array [0..SignCnt-1] of integer;
    Signal_idx : integer;
    Signal_pos : integer;
    Added : boolean;

    Destructor Destroy; override;

    procedure OnQuote( aQuote : TQuote; iData : integer ); override;
    procedure init(aAcnt : TAccount; aSymbol : TSymbol; aType : integer); override;
    procedure init2(aSymbol : TSymbol; aType : integer); override;
    procedure Start;
    procedure Stop;
    

    procedure ReMakeData;

    property AcclFact: double read FAcclFact write SetAcclFact;
    property Paras : TParaItems read FParas;
    property LastItem : TParaItem read FLastItem write FLastItem;
    property PrevItem : TParaItem read FPrevItem write FPrevItem;

    property Period : integer read FPeriod write FPeriod;
    property Count  : integer read FCount write FCount;
    property Side   : integer read FSide;
    property SAR    : double read FSAR;

    property SAREvent : TSAREvent read FSAREvent write FSAREvent;

    property ReLoad  : boolean read FReLoad write FReLoad;
  end;

procedure DspLog( stLog : string );


implementation

uses
  GAppEnv, CleQuoteTimers
  ;

{ TParabolicSignal }

procedure DspLog( stLog : string );
begin
//  gEnv.EnvLog( WIN_DSP, stLog );
end;


procedure TParabolicSignal.init(aAcnt: TAccount; aSymbol: TSymbol;
  aType: integer);
  var
    navi : TNavi;
  I: Integer;
begin
  inherited;
  if FParas = nil then
    FParas:= TParaItems.Create;
  FParas.Clear;

  FLastItem := TParaItem.Create( nil );
  FPrevItem := TParaItem.Create( nil );
  Added := false;
  FSide := 0;
  FReLoad := false;
 // if gEnv.RunMode <> rtSimulation then
  ReMakeData;
end;

procedure TParabolicSignal.init2(aSymbol: TSymbol; aType: integer);
begin
  inherited;
  if FParas = nil then
    FParas:= TParaItems.Create;
  FParas.Clear;

  FLastItem := TParaItem.Create( nil );
  FPrevItem := TParaItem.Create( nil );
  Added := false;
  FSide := 0;
  FReLoad := false;
 // if gEnv.RunMode <> rtSimulation then
  ReMakeData;
end;

procedure TParabolicSignal.OnQuote(aQuote: TQuote; iData : integer);
var
  bNew : boolean;
  wHH, wMM, wSS, wCC : Word;
  iMMIndex : integer;
  aTime : TDateTime;
  aTick : TTickItem;
  I: Integer;

begin
  if aQuote.Symbol <> Symbol then Exit;

  if iData = 300 then
  begin
    Exit;
  end;

  if (aQuote.LastEvent <> qtTimeNSale) or ( aQuote.FTicks.Count < 1 ) then Exit;

  if FReLoad then Exit;

  bNew := aQuote.AddTerm;

  if bNew then
    NewTermData( aQuote,iMMIndex )
  else
    UpdateData( aQuote );

  aQuote.SAR  :=  FSAR;
  Added := false;
end;

function TParabolicSignal.ParaToStringTitle: string;
begin
  Result := 'time, SAR , HighValue , LowValue , AF, H, L ,Pos, C';
end;

procedure TParabolicSignal.NewTermData( aQuote : TQuote; iMMIndex : integer );
var
  aPara : TParaItem;
  aItem : TSTermItem;
  dtStart, dtNow : TDateTime;
begin

  ///if FCount = 0 then Exit;
  aItem := aQuote.Terms.XTerms[ aQuote.Terms.Count-2 ];
  if aItem = nil then Exit;

  //aPrevPara := FParas.ParaItems[ FParas.Count-1] ;
  Added  := true;
  aPara  := FParas.New( aQuote.LastQuoteTime );
  FCount := FParas.Count ;

  aPara.T := aItem.LastTime;
  aPara.O := aItem.O;
  aPara.H := aItem.H;
  aPara.L := aItem.L;
  aPara.C := aItem.C;
  aPara.FillVol := aItem.FillVol;

  if FLastItem <> nil then
  begin
    aPara.Pos := FLastItem.Pos;
    aPara.SAR := FLastItem.SAR;
    aPara.AF  := FlastItem.AF;
    apara.EP  := FLastItem.EP;
    aPara.HighValue := FLastItem.HighValue;
    aPara.LowValue  := FLastItem.LowValue;
  end;
    {
  FLastItem := aPara;
  CalcParabolic( aQuote );
    }
  CalcParabolic( aPara, aQuote );
  FLastItem := aPara;
  FPrevItem.Assign( FLastItem );

  dtStart := EncodeTime(9,0,30,0 );
  dtNow   := Frac( GetQuoteTime );

  FSide := FLastItem.Pos;

  //gEnv.EnvLog( WIN_GI, Format(' %d, %.2f, %.3f', [ FSide, FLastItem.SAR, AcclFact ]  )  );

  if ( Assigned( FSAREvent )) and ( dtStart < dtNow ) then
    FSAREvent( Self, FLastItem.Pos );
end;


procedure TParabolicSignal.UpdateData( aQuote : TQuote );
begin

  if (FLastItem <> nil) and ( aQuote.Terms.LastTerm <> nil ) then
  begin

    if FCount -2 < 0 then
      Exit;

    with FPrevItem do
    begin
       if Pos > 0 then
      begin
        if aQuote.Last <= SAR + EPSILON then
          Pos := -1;
      end else
      if Pos < 0 then
      begin
        if aQuote.Last >= SAR - EPSILON then
          Pos := 1
      end;
    end;

    FSide := FPrevITem.Pos;

    if FLastItem.Pos = FPrevItem.Pos then
      FSAR  := FLastItem.SAR
    else begin
      if ( FPrevITem.Pos > 0 ) and ( FLastItem.Pos < 0 )  then
        FSAR  := FLastItem.LowValue
      else if ( FPrevITem.Pos < 0 ) and ( FLastItem.Pos > 0 ) then
        FSAR  := FLastItem.HighValue;
    end;

  end;
end;

procedure TParabolicSignal.CalcParabolic(aPara: TParaItem; aQuote: TQuote;
  bUpdate: boolean);
var
  dHigh, dLow, dTmp : double;
  stLog : string;
  aPrevPara, aTmp : TParaItem;

begin

  try
    aTmp := TParaItem.Create( nil );
    aTmp.init;

    if FCount - 2 < 0 then
      aPrevPara := aTmp
    else
      aPrevPara := FParas.ParaItems[ FCount-2 ];

    With aPara do
    begin

      if FCount = 1 then
      begin
        Pos       := 1;
        HighValue := H;
        LowValue  := L;
        SAR       := C;
        AF        := FAcclFact;
      end
      else if  FCount > 1 then
      begin
        if H > HighValue + EPSILON then
          HighValue := H;
        if L < LowValue - EPSILON then
          LowValue  := L;

        if Pos > 0 then
        begin
          if L <= aPrevPara.SAR + EPSILON then
            Pos := -1;
        end else
        if Pos < 0 then
        begin
          if H >= aPrevPara.SAR - EPSILON then
            Pos := 1
        end;
      end;

      if Pos > 0 then
      begin
        if aPrevPara.Pos < 0 then
        begin
          SAR := LowValue;
          AF  := FAcclFact;
          LowValue  := L;
          HighValue := H;

        end else
        begin
          if FCount = 1 then
            SAR := C
          else begin
            if not bUpdate then
            begin
              SAR := aPrevPara.SAR + AF * ( HighValue - aPrevPara.SAR );
              if ( HighValue > aPrevPara.HighValue ) and ( AF < 0.2 ) then
                AF  := AF + min( FAcclFact, ( 0.2 - AF ));
            end;
          end;
        end;
        if FCount > 1 then
        begin
          if SAR > L + EPSILON then SAR := L;
          if SAR > aPrevPara.L + EPSILON then SAR := aPrevPara.L;
        end;
      end else
      begin
        if aPrevPara.Pos > 0 then
        begin
          SAR := HighValue;
          AF  := FAcclFact;
          LowValue  := L;
          Highvalue := H;
          
        end else
        begin
          if FCount  = 1 then
            SAR := C
          else begin
            if not bUpdate then
            begin
              SAR := aPrevPara.SAR + AF * ( LowValue - aPrevPara.SAR );
              if ( LowValue < aPrevPara.LowValue - EPSILON ) and ( AF < 0.2 ) then
                AF  := AF + Min( FAcclFact, ( 0.2 - AF ));
            end;
          end;
        end;

        if FCount > 1 then
        begin
          if SAR < H - EPSILON then SAR := H;
          if SAR < aPrevPara.H - EPSILON then SAR := aPrevPara.H;
        end;
      end;
    end;

  finally
    aTmp.Free;
    FSAR := LastItem.SAR;
    //FPrevItem.Assign( FLastItem );
  end;

end;

destructor TParabolicSignal.Destroy;
begin
  FLastITem.Free;
  FPrevITem.Free;
  inherited;
end;

procedure TParabolicSignal.CalcParabolic( aQuote : TQuote ; bUpdate : boolean );
var
  dHigh, dLow, dTmp : double;
  stLog : string;
  aPara, aTmp : TParaItem;

begin

  try
    aTmp := TParaItem.Create( nil );
    aTmp.init;

    if FCount - 2 < 0 then
      aPara := aTmp
    else
      if bUpdate then
        aPara := FPrevItem
      else
        aPara := FParas.ParaItems[ FCount-2 ];


    With FLastItem do
    begin

      if FCount = 1 then
      begin
        Pos       := 1;
        HighValue := H;
        LowValue  := L;
        SAR       := C;
        AF        := FAcclFact;
      end
      else if  FCount > 1 then
      begin
        if H > HighValue + EPSILON then
          HighValue := H;
        if L < LowValue - EPSILON then
          LowValue  := L;

        if Pos > 0 then
        begin
          if L <= aPara.SAR + EPSILON then
            Pos := -1;
        end else
        if Pos < 0 then
        begin
          if H >= aPara.SAR - EPSILON then
            Pos := 1
        end;
      end;

      if Pos > 0 then
      begin
        if aPara.Pos < 0 then
        begin
          SAR := LowValue;
          AF  := FAcclFact;
          LowValue  := L;
          HighValue := H;

        end else
        begin
          if FCount = 1 then
            SAR := C
          else begin
            if not bUpdate then
            begin
              SAR := aPara.SAR + AF * ( HighValue - aPara.SAR );
              if ( HighValue > aPara.HighValue ) and ( AF < 0.2 ) then
                AF  := AF + min( FAcclFact, ( 0.2 - AF ));
            end;
          end;
        end;
        if FCount > 1 then
        begin
          if SAR > L + EPSILON then SAR := L;
          if SAR > aPara.L + EPSILON then SAR := aPara.L;
        end;
      end else
      begin
        if aPara.Pos > 0 then
        begin
          SAR := HighValue;
          AF  := FAcclFact;
          LowValue  := L;
          Highvalue := H;
          
        end else
        begin
          if FCount  = 1 then
            SAR := C
          else begin
            if not bUpdate then
            begin
              SAR := aPara.SAR + AF * ( LowValue - aPara.SAR );
              if ( LowValue < aPara.LowValue - EPSILON ) and ( AF < 0.2 ) then
                AF  := AF + Min( FAcclFact, ( 0.2 - AF ));
            end;
          end;
        end;

        if FCount > 1 then
        begin
          if SAR < H - EPSILON then SAR := H;
          if SAR < aPara.H - EPSILON then SAR := aPara.H;
        end;
      end;
    end;     
    
             {
    if aQuote.AddTerm then
      gEnv.EnvLog(WIN_UPDOWN, '+' +FLastItem.ParaToString )
    else
      gEnv.EnvLog(WIN_UPDOWN, ' ' +FLastItem.ParaToString );
               }
  finally
    aTmp.Free;
    //aQuote.SAR := LastItem.SAR;
    FPrevItem.Assign( FLastItem );
  end;
end;

procedure TParabolicSignal.SetAcclFact(const Value: double);
begin
  FAcclFact := Value;
end;

procedure TParabolicSignal.Start;
begin
  Run := true;
end;

procedure TParabolicSignal.Stop;
begin
  Run := false;
end;


procedure TParabolicSignal.ReMakeData;
var
  aQuote : TQuote;
  aPara  : TParaItem;
  aItem : TSTermItem;
  I: Integer;
begin
  try
    if ( Symbol = nil ) or ( Symbol.Quote = nil ) then Exit;

    aQuote  := Symbol.Quote as TQuote;

    if aQuote.Terms.Count <= 0 then Exit;

    FReLoad := true;

    FParas.Clear;

    FLastItem.init;
    FPrevItem.init;

    Added := false;
    FSide := 0;

    for I := 0 to aQuote.Terms.Count - 1 do
    begin
      aItem := aQuote.Terms.XTerms[i];
      aPara := FParas.New( aItem.LastTime );
      FCount  := FParas.Count;

      aPara.T := aItem.LastTime;
      aPara.O := aItem.O;
      aPara.H := aItem.H;
      aPara.L := aItem.L;
      aPara.C := aItem.C;
      aPara.FillVol := aItem.FillVol;

      if FLastItem <> nil then
      begin
        aPara.Pos := FLastItem.Pos;
        aPara.SAR := FLastItem.SAR;
        aPara.AF  := FlastItem.AF;
        apara.EP  := FLastItem.EP;
        aPara.HighValue := FLastItem.HighValue;
        aPara.LowValue  := FLastItem.LowValue;
      end;

      CalcParabolic( aPara, aQuote );
      FLastItem := aPara;
      FPrevItem.Assign( FLastItem );

      FSide := FLastItem.Pos;

      gEnv.EnvLog( WIN_GI, Format(' %d, %.2f , %.3f', [ FSide, FLastItem.SAR, AcclFact ]  )  );

    end;

  finally
    FReLoad := false;
  end;

end;



{ TParaItems }

constructor TParaItems.Create;
begin
  inherited Create( TParaItem );
end;

destructor TParaItems.Destroy;
begin

  inherited;
end;

function TParaItems.GetParaItem(i: integer): TParaItem;
begin
  if ( i < 0 ) or ( i >= Count ) then
    Result := nil
  else
    Result := Items[i] as TParaItem;
end;

function TParaItems.New(dtTime: TDateTime): TParaItem;
begin
  Result := Add As TParaItem;
  Result.T  := dtTime;
  Result.init;
  FLastItem := Result;
end;

{ TParaItem }

procedure TParaItem.Assign(var aItem: TParaItem);
begin
  Pos   := aItem.Pos;
  SAR   := aItem.SAR;
  AF    := aItem.AF;
  EP    := aItem.EP;
  HighValue := aItem.HighValue;
  LowValue  := aItem.LowValue;
  WriteCount := aItem.WriteCount;

  T := aItem.T;
  MMIndex := aItem.MMIndex;
  O := aItem.O;
  H := aItem.H;
  L := aItem.L;
  C := aItem.C;
  FillVol := aItem.FillVol;
  AccVol  := aItem.AccVol;
end;

procedure TParaItem.init;
begin
  Pos := 0;
  SAR := 0; AF := 0; EP := 0;
  HighValue := 0; LowValue:= 100000;
  WriteCount := 0;
end;

function TParaItem.ParaToString: string;
begin
  Result := Format('%s, %.1f, %.1f, %.1f, %.3f ,%.1f, %.1f, %d, %.1f',
    [ FormatDateTime('hh:nn:ss.zzz', T), SAR, HighValue, LowValue, AF, H, L, Pos, C ] );
end;



end.



