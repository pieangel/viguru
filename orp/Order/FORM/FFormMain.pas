unit FFormMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleStorage,  CleSymbols , CleOrders, CleDistributor,

  CleFORMConst, CleFrontOrderIF,  CleKrxSymbols,  CleQuoteBroker,

  CleJangBeforeManager, CleJangStartManager, CleJangJungManager,

  CleFormManager , CleSimultaneousEnd,

  GleLib, CleFQN, GleTypes, GleConsts, ComCtrls, StdCtrls, Buttons, ExtCtrls,
  Grids

  ;

const
  SHeight = 704;
  HHeight = 172 + 185 + 5;


type

  TFormMain = class(TForm)
    Panel2: TPanel;
    BtnCohesionSymbol: TSpeedButton;
    cbSymbol: TComboBox;
    ComboAccount: TComboBox;
    stBar: TStatusBar;
    GroupBox3: TGroupBox;
    GroupBox1: TGroupBox;
    Label11: TLabel;
    Label12: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label20: TLabel;
    Label21: TLabel;
    edtPrevBasisLow: TEdit;
    edtPrevBasisHigh: TEdit;
    edtPrevBasisAvg: TEdit;
    edtExUpDown: TEdit;
    edtExUpDownPer: TEdit;
    stIndex: TStaticText;
    stExUpDown: TStaticText;
    stExUpDownPer: TStaticText;
    stCalcIndex: TStaticText;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    lbSum: TLabel;
    edtBase: TEdit;
    edtQty: TEdit;
    udQty: TUpDown;
    edtGap: TEdit;
    edtCnt: TEdit;
    udCnt: TUpDown;
    udGap: TUpDown;
    edtAskShift: TEdit;
    edtBidShift: TEdit;
    stAskRange: TStaticText;
    stBidRange: TStaticText;
    btnOrder: TButton;
    gbJangStart: TGroupBox;
    DateTimePickerTime: TDateTimePicker;
    edtBidShift2: TEdit;
    edtAskShift2: TEdit;
    Label6: TLabel;
    Label5: TLabel;
    CheckBox2: TCheckBox;
    gbSimulEnd: TGroupBox;
    DateCancelTime: TDateTimePicker;
    btnFutCalc: TButton;
    Label9: TLabel;
    Label10: TLabel;
    edtUpperBasis: TEdit;
    edtLowerBasis: TEdit;
    Label13: TLabel;
    edtDelay: TEdit;
    btnCalc: TButton;
    cbSimulEnd: TCheckBox;
    stPrevClose: TStaticText;
    Label14: TLabel;
    Label15: TLabel;
    StaticText1: TStaticText;
    StaticText2: TStaticText;
    StaticText3: TStaticText;
    StaticText4: TStaticText;
    StaticText5: TStaticText;
    StaticText6: TStaticText;
    StaticText7: TStaticText;
    StaticText8: TStaticText;
    btnSH: TButton;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure edtBaseKeyPress(Sender: TObject; var Key: Char);
    procedure CheckBox2Click(Sender: TObject);
    procedure edtBaseChange(Sender: TObject);
    procedure btnOrderClick(Sender: TObject);
    procedure edtExUpDownChange(Sender: TObject);
    procedure edtPrevBasisLowChange(Sender: TObject);
    procedure btnFutCalcClick(Sender: TObject);
    procedure edtPrevBasisAvgChange(Sender: TObject);
    procedure btnCalcClick(Sender: TObject);
    procedure edtUpperBasisChange(Sender: TObject);
    procedure edtBidShift2Change(Sender: TObject);
    procedure btnSHClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

  private
    { Private declarations }
    FAccount  : TAccount;
    FormManager :  TFrontManager;
    FParam  : TFORMParam;
    FRow  : integer;
    FSymbol : TSymbol;
    FQuote  : TQuote;

    FExIndex, FUdRatio, FChange : double;
    FStorage  : TStorage;


    procedure ParamChange(aIF: TFrontOrderIF);
    procedure ShowState(index: integer; value: string);
    procedure CalcErrVal;

  public
    { Public declarations }
    IfList  : TList;
    BLog : boolean;
    SaveHeight : integer;
    procedure LoadEnv(aStorage: TStorage; bSelf : boolean = false);
    procedure SaveEnv(aStorage: TStorage; bSelf : boolean = false);
    procedure SetDefaultParam;
    procedure DoLog(Sender: TObject; Value: String);
    procedure SelfLog( Value : string );
    procedure Notify( Sender: TObject; value : boolean );

    procedure OrderProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);

  end;

var
  FormMain: TFormMain;

implementation

uses
  GAppEnv, GAppConsts, CleQuoteTimers;

{$R *.dfm}

procedure TFormMain.btnCalcClick(Sender: TObject);
var
  dVal : double;
  aIF  : TFrontOrderIF;
begin

  with FParam do
  begin
    Delay  := StrToFloatDef( edtDelay.Text, 0 );
    Upper  := BasisH + Delay;
    Lower  := abs(BasisL - Delay);

    edtUpperBasis.OnChange  := nil;
    edtLowerBasis.OnChange  := nil;

    edtUpperBasis.Text  := Format('%.2f', [ Upper ] );
    edtLowerBasis.Text  := Format('%.2f', [ Lower ] );

    edtUpperBasis.OnChange  := edtUpperBasisChange;
    edtLowerBasis.OnChange  := edtUpperBasisChange;

    StaticText8.Caption := Format('%.2f', [ IndexPrice + Upper ] );
    StaticText7.Caption := Format('%.2f', [ IndexPrice - Lower ] );
  end;

  aIF := FormManager.Find(ottJangBefore );
  if aIF = nil then Exit;
  ParamChange( aIF );
end;

procedure TFormMain.BtnCohesionSymbolClick(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, cbSymbol);
        // apply
      cbSymbolChange(cbSymbol);
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFormMain.btnFutCalcClick(Sender: TObject);
begin
  //if FQuote = nil then Exit;
  edtBase.Text  := Format('%.2f', [ FParam.ExIndex + Fparam.BasisA ]);
end;

procedure TFormMain.btnOrderClick(Sender: TObject);
var
  aIF : TFrontOrderIF;
  stValue : string;
begin

  aIF := FormManager.Find(ottJangBefore);
  if aIF = nil then Exit;
  ParamChange( aIF );

  TJangBeforeManager( aIF ).Start;
  ShowState( 0, '장전주문');

end;

procedure TFormMain.btnSHClick(Sender: TObject);
begin
  //
    {
  BHide := not BHide;

  if BHide  then
  begin
    GroupBox1.Visible := false;
    GroupBox2.Visible := false;
    Height := HHeight;
    //GroupBox3.Height  :=
  end
  else begin
    GroupBox1.Visible := true;
    GroupBox2.Visible := true;
    Height := SHeight;
  end;
    }
end;

procedure TFormMain.Button1Click(Sender: TObject);
var
  stName : string;
begin
  // 로그 보기
  stName := Format( '%s/%s.log', [ WIN_SIMUBAO,
    FormatDateTime( 'yyyymmdd', GetQuoteDate)
    ]);
  ShowNotePad( Handle, stName );
end;


procedure TFormMain.CalcErrVal;
begin
  StaticText1.Caption := Format('%.2f',[ FChange - FParam.ExUpDown]);
  StaticText2.Caption := Format('%.2f',[ FUdRatio - FParam.ExUpDownP]);
  if FQuote <> nil then
    StaticText3.Caption := Format('%.2f',[ FQuote.Last - FParam.ExIndex ])
  else
    StaticText3.Caption := '';

end;


procedure TFormMain.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  aIF : TFrontOrderIF;
  I: Integer;
begin
  if cbSymbol.ItemIndex = -1 then Exit;
  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;

  for I := 0 to IfList.Count - 1 do
  begin
    aIF := TFrontOrderIF( IfList.Items[i] );
    aIF.Symbol  := aSymbol;
  end;

  //FormManager.SetSymbol( aSymbol );

  SelfLog( '종목변경 : ' + aSymbol.ShortCode );

  edtBaseChange( nil );
  edtUpperBasisChange(nil);
  edtBidShift2Change( nil );

end;

procedure TFormMain.CheckBox2Click(Sender: TObject);
var
  aIF : TFrontOrderIF;
  bCheck : boolean;
  stValue : string;
  iTag  : integer;
begin
  if Sender = nil then Exit;

  bCheck := TCheckBox( Sender ).Checked;
  iTag   := TCheckBox( Sender ).Tag;

  case iTag of
    100 : aIF := FormManager.Find( ottJangStart );
    200 : aIF := FormManager.Find( otSimulEndJust );
    else Exit;
  end;

  if aIF = nil then Exit;
  ParamChange( aIF );

  if bCheck then
  begin
    case iTag of
      100 :
        begin
          bCheck  := TJangStartManager( aIF ).Start;
          ShowState( 2 , '마감처리');
          if bCheck then begin
            gbJangStart.Color := $00C8C8FF ;
            SelfLog(  '마감처리 Check On' );
          end
          else
            CheckBox2.Checked := false;
        end;
      200 :
        begin
          bCheck  := TSimultaneousEnd( aIF ).Start;
          ShowState( 1 , '마감직전');
          if bCheck then begin
            gbSimulEnd.Color := $00C8C8FF ;
            SelfLog(  '마감직전처리 Check On' );
          end
          else
            cbSimulEnd.Checked := false;
        end;
    end;
  end
  else begin

    case iTag of
      100 :
        begin
          TJangStartManager( aIF ).Stop;
          gbJangStart.Color := clBtnFace;
          ShowState( 2 , '');
          SelfLog(  '마감처리 Check Off' );
        end;
      200 :
        begin
          TSimultaneousEnd( aIF ).Stop;
          gbSimulEnd.Color := clBtnFace;
          ShowState( 1 , '');
          SelfLog(  '마감찍전처리 Check Off' );
        end;
    end;
  end;

end;

procedure TFormMain.ParamChange(aIF : TFrontOrderIF);
begin
  SetDefaultParam;
  aIF.Param := FParam;
end;

procedure TFormMain.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
var
  aQuote : TQuote;
  dGap  : double;
  aFColor:TColor;
  stQuote, stParam : string;
  iRes : integer;
  aIF : TFrontOrderIF;
begin
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  aQuote := DataObj as TQuote;

  if aQuote.Symbol <> FSymbol then Exit;

  stIndex.Caption := Format('%.2f', [aQuote.Last]);
  stIndex.Color := clWhite;
  stPrevClose.Caption := Format('%.2f', [ aQuote.Symbol.PrevClose ] );


  if aQuote.Symbol.PrevClose < 1 then
    dGap := 0
  else
    dGap  :=  aQuote.Last - aQuote.Symbol.PrevClose;

  FParam.IndexPrice := aQuote.Last;
  FChange := dGap;
  stExUpDown.Caption  := Format('%.2f', [ dGap ] );

  aFColor := clBlack;
  if dGap > 0 then
    aFColor  := clRed
  else if dGap < 0 then
    aFColor  := clBlue  ;

  if aQuote.Symbol.PrevClose < 1 then
    dGap := 0
  else
    dGap  := ((aQuote.Last/aQuote.Symbol.PrevClose) * 100) - 100;

  stExUpDownPer.Caption := Format('%.2f', [ dGap]);
  FUdRatio := dGap;

  stExUpDown.Font.Color := aFColor;
  stExUpDownPer.Font.Color  := aFColor;

  CalcErrVal;

  StaticText8.Caption := Format('%.2f', [ FParam.IndexPrice + FParam.Upper ] );
  StaticText7.Caption := Format('%.2f', [ FParam.IndexPrice - FParam.Lower ] );

  aIF := FormManager.Find(ottJangBefore );
  if aIF <> nil then
    ParamChange( aIF );


  stQuote := FormatDateTime('hhnnsszzz', GetQuoteTime );
  stParam := FormatDateTime('hhnnsszzz', FParam.CancelTime );

  iRes  := CompareStr( stQuote, stParam  );

  if (iRes >= 0) then
  begin
    //stParam := '090000';
    //iRes  := CompareStr( stQuote, stParam  );
    //if (iRes < 0) then
    if cbSimulEnd.Checked then
    begin
      aIF := FormManager.Find(otSimulEndJust );
      if aIF <> nil then
        TSimultaneousEnd( aIF ).FRun := false;
    end;
  end;

end;

procedure TFormMain.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  aIF : TFrontOrderIF;
  I: Integer;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;

  if aAccount <> nil then
  begin
    //FormManager.SetAccount( aAccount );

    for I := 0 to IfList.Count - 1 do
    begin
      aIF := TFrontOrderIF( IfList.Items[i] );
      aIF.Account := aAccount;
    end;

    SelfLog( '계좌변경 : ' + aAccount.Code );
  end;

  edtBaseChange( nil );
  edtUpperBasisChange(nil);
  edtBidShift2Change( nil );  

end;

procedure TFormMain.DoLog(Sender: TObject; Value: String);
begin
  if Sender = nil then Exit;

  case TFrontOrderIF( Sender ).ManagerType of
    ottJangBefore : Value := '시작  전 : ' + Value ;
    ottJangStart  : Value := '마감처리 : ' + Value ;
    otSimulEndJust: Value := '마감직전 : ' + Value ;
    ottJangJung   : ;
  end;

  gEnv.EnvLog( WIN_SIMUBAO, Value );
end;


procedure TFormMain.SelfLog( Value : string );
var
  stLog : string;
begin  {
  case aType of
    ottJangBefore : Value := '시작  전 : ' + Value ;
    ottJangStart  : Value := '마감처리 : ' + Value ;
    otSimulEndJust: Value := '마감직전 : ' + Value ;
    ottJangJung   : ;

    BasisH  : double;
    BasisL  : double;
    BasisA  : double;

    ExUpDown  : double;
    ExUpDownP : double;
    ExIndex   : double;

    BasePrice : double;
    IndexPrice: double;

    AskPrice  : double;
    BidPrice  : double;

    OrderQty  : integer;
    OrderGap  : integer;
    OrderCnt  : integer;
    BidShift  : double;
    AskShift  : double;

    Upper : double;
    Lower : double;
    Delay : double;

    AskShift2 : double;
    BidShift2 : double;

    CancelTime  : TDateTime;
    StartTime   : TDateTime;
  end;    }
  with FParam do
  begin
    {
    stLog := Format('K200 : %.2f, %.2f, %.2f, %.2f, %.2f%s ' +
                    '선물 : %.2f, %.2f, %.2f, %d, %d, %d' +
                    '직전 : %s, %.2f, %.2f, %.2f' +
                    '마감 : %s, %.2f, %.2f',
      [
        BasisL, BasisH, BasisA, ExUpDown, ExUpDown, '%',
        BasePrice, AskShift, BidShift, OrderQty, OrderCnt, OrderGap,
        FormatDateTime( 'hh:nn:ss.zzz', CancelTime ), Upper, Lower, Delay,
        FormatDateTime( 'hh:nn:ss.zzz', StartTime ), AskShift2, BidShift2

      ]);  }
  end;
  if BLog then
    gEnv.EnvLog( WIN_SIMUBAO, Value );
end;

procedure TFormMain.Notify(Sender: TObject; value: boolean);
begin
  if Sender = nil then Exit;

  case TFrontOrderIF( Sender ).ManagerType of
    ottJangBefore : ;
    ottJangStart  : CheckBox2.Checked := Value;
    otSimulEndJust: cbSimulEnd.Checked := Value;
    ottJangJung   : ;
  end;

end;


procedure TFormMain.ShowState( index : integer; value : string );
begin

  stBar.Panels[0].Text  := '';
  if not cbSimulEnd.Checked then
    stBar.Panels[1].Text  := '';

  if not CheckBox2.Checked then  
    stBar.Panels[2].Text  := '';

  stBar.Panels[index].Text  := value

end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  if stIndex.Color = clWhite then
    stIndex.Color := clBtnFace;
end;

procedure TFormMain.edtBaseChange(Sender: TObject);
var
   aIF, bIF : TFrontOrderIF;
   askPrice, bidPrice : double;
   i : integer;

begin
  aIF := FormManager.Find(ottJangBefore );
  if aIF = nil then Exit;
  if aIF.Symbol = nil then Exit;

  ParamChange( aIF );

  if edtBase.Text <> '' then
  begin
    FParam.AskPrice := GetOrderPriceRound( FParam.BasePrice + FParam.AskShift , true);
    FParam.BidPrice := GetOrderPriceRound( FParam.BasePrice - FParam.BidShift , false);

    for i := 0 to FParam.OrderCnt - 1 do
    begin
      if i = 0 then begin
        AskPrice  := FParam.AskPrice;
        BidPrice  := FParam.BidPrice;
      end
      else begin
        AskPrice := TicksFromPrice( aIF.Symbol, AskPrice, FParam.OrderGap );
        BidPrice := TicksFromPrice( aIF.Symbol, BidPrice, FParam.OrderGap * -1 );
      end;
    end;

    stAskRange.Caption  := Format('%.2f ~ %.2f',
      [FParam.AskPrice, AskPrice ]) ;
    stBidRange.Caption  := Format('%.2f ~ %.2f',
      [FParam.BidPrice, BidPrice]);
  end;

  lbSum.Caption :=
    IntToStr( 2 *  StrToIntDef( edtCnt.Text, 0 ));

  ShowState( 0 , '조건설정중');

  with FParam do
  begin
    SelfLog( Format('기준가 : %.2f, %.2f(%s), %.2f(%s), (%d, %d %d) ',
    [
      BasePrice, AskShift, stAskRange.Caption,
      BidShift, stBidRange.Caption,
      OrderQty, OrderCnt, OrderGap
    ]
    )
    );
  end;

end;

procedure TFormMain.edtBaseKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13,'-', '.', #8]) then
    Key := #0;
end;

procedure TFormMain.edtBidShift2Change(Sender: TObject);
begin

  SelfLog( Format('동시호가마감처리 : %s, %.2f, %.2f',
  [
    FormatDateTime('hh:nn:ss.zzz', DateTimePickerTime.Time ),
    Fparam.AskShift2,
    FParam.BidShift2
  ])
  );

  ShowState( 2 , '조건설정중');

  if not CheckBox2.Checked then Exit;
  CheckBox2.Checked := false;

end;

procedure TFormMain.edtExUpDownChange(Sender: TObject);
var
  iTag : integer;
  dVal, dTmp : double;
begin
  if Sender = nil then Exit;
  if FQuote = nil then Exit;

  iTag := TEdit( Sender ).Tag;

  dVal := 0;

  case iTag of
    0 :
      begin
        FParam.ExUpDown := StrToFloatDef( edtExUpDown.Text, 0 );
        dTmp := FQuote.Symbol.PrevClose + FParam.ExUpDown;
        if FQuote.Symbol.PrevClose <> 0 then
          dVal := ((dTmp/FQuote.Symbol.PrevClose) * 100) - 100
        else
          dVal := 0;

        FParam.ExUpDownP := dVal;
        edtExUpDownPer.OnChange := nil;
        edtExUpDownPer.Text := Format('%.2f', [ dVal, '%']);
        edtExUpDownPer.OnChange := edtExUpDownChange;

      end;
    1 :
      begin
        FParam.ExUpDownP := StrToFloatDef( edtExUpDownPer.Text, 0 );
        dTmp := (( FParam.ExUpDownP + 100 ) / 100 ) * FQuote.Symbol.PrevClose;
        dVal := dTmp - FQuote.Symbol.PrevClose;
        FParam.ExUpDown := dVal;
        edtExUpDown.OnChange := nil;
        edtExUpDown.Text:= Format('%.2f', [ FParam.ExUpDown ]);
        edtExUpDown.OnChange := edtExUpDownChange;

      end;
  end;

  FParam.ExIndex  :=  FQuote.Symbol.PrevClose + FParam.ExUpDown;
  stCalcIndex.Caption := Format('%.2f', [ FQuote.Symbol.PrevClose + FParam.ExUpDown] );

  CalcErrVal;

  btnFutCalcClick( nil );

  SelfLog( Format('예상등락 : %.2f, %.2f%s, Index : %.2f, Base : %.2f',
    [
      FParam.ExUpDown,
      Fparam.ExUpDownP,
      '%',
      FParam.ExIndex,
      FParam.BasePrice
    ]
    )

  );


end;

procedure TFormMain.edtPrevBasisAvgChange(Sender: TObject);
begin
  Fparam.BasisA := StrToFloatDef( edtPrevBasisAvg.Text, FParam.BasisA );
  btnFutCalcClick( nil );

  SelfLog( Format('베이시스평균 : %.2f, Base : %.2f',
    [
      FParam.BasisA,
      FParam.BasePrice
    ] )
    );
end;

procedure TFormMain.edtPrevBasisLowChange(Sender: TObject);
begin
  FParam.BasisH := StrToFloatDef( edtPrevBasisHigh.Text, 0 );
  FParam.BasisL := StrToFloatDef( edtPrevBasisLow.Text, 0 );
  FParam.BasisA := ( FParam.BasisH + FParam.BasisL ) / 2;

  SelfLog( Format('전일베이시스고저 : %.2f,  %.2f',
    [
      FParam.BasisL,
      Fparam.BasisH
    ] )
    );

  edtPrevBasisAvg.Text  :=  Format( '%.2f', [ Fparam.BasisA ] );
  btnCalcClick( nil );

end;

// 마감직전처리 값 변경시..
procedure TFormMain.edtUpperBasisChange(Sender: TObject);
begin
  //if not cbSimulEnd.Checked then Exit;
  cbSimulEnd.Checked  := false;
  ShowState( 1 , '조건설정중');
  with FParam do
  begin
    Delay  := StrToFloatDef( edtDelay.Text, 0 );
    Upper  := StrToFloatDef( edtUpperBasis.Text, 0 );
    Lower  := StrToFloatDef( edtLowerBasis.Text, 0 );

    //edtUpperBasis.Text  := Format('%.2f', [ Upper ] );
    //edtLowerBasis.Text  := Format('%.2f', [ Lower ] );

    StaticText8.Caption := Format('%.2f', [ IndexPrice + Upper ] );
    StaticText7.Caption := Format('%.2f', [ IndexPrice - Lower ] );
  end;

  SelfLog( Format('Upper, Lower : %s, %.2f(%s), %.2f(%s)',
  [
    FormatDateTime('hh:nn:ss.zzz', DateCancelTime.Time ),
    Fparam.Upper, StaticText8.Caption,
    FParam.Lower, StaticText7.Caption
  ])
  );
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFormMain.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
  aIF : TFrontOrderIF;
begin

  BLog := false;
  FormManager :=  gEnv.Engine.FormManager;
  FStorage  := TStorage.Create;
  IfList  := TList.Create;

  aIF := FormManager.New(ottJangBefore);
  aIF.OnLog := DoLog;
  aIF.OnEvent := Notify;
  IfList.Add(aIF);
  aIF := FormManager.New(ottJangStart);
  aIF.OnLog := DoLog;
  aIF.OnEvent := Notify;
  IfList.Add(aIF);
  aIF := FormManager.New(otSimulEndJust);
  aIF.OnLog := DoLog;
  aIF.OnEvent := Notify;
  IfList.Add(aIF);

  //
  Label5.Color  := LONG_COLOR;
  Label15.Color  := LONG_COLOR;

  Label6.Color  := SHORT_COLOR;
  Label14.Color  := SHORT_COLOR;
  //


  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( cbSymbol.Items, aMarkets );


  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;

  SetDefaultParam;

  //gEnv.Engine.TradeBroker.Subscribe( Self, OrderProc );


  FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( KOSPI200_CODE );
  if FSymbol <> nil then
  begin
    FQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteProc );
    if FQuote <> nil then begin
      if FQuote.EventCount < 1 then
        FQuote.Last := FSymbol.PrevClose;
      QuoteProc( FQuote, Self, 0, FQuote, 0 );
    end;
    //stPrevClose.Caption := Format('%.2f', [ FSymbol.PrevClose ] );
  end;


  LoadEnv( FStorage, true );

  BLog := true;

end;

procedure TFormMain.FormDestroy(Sender: TObject);
begin
  FStorage.New;
  SaveEnv( FStorage, true );
  gEnv.Engine.FormManager.FormMain  := nil;
  FStorage.Free;

  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );

  gEnv.Engine.FormManager.Del( ottJangBefore );
  gEnv.Engine.FormManager.Del( ottJangStart );
  gEnv.Engine.FormManager.Del( otSimulEndJust );

  IfList.Free;
end;

procedure TFormMain.OrderProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
begin
  if (Receiver <> Self) or (DataID <> TRD_DATA) then Exit;

  case Integer(EventID) of
      // order events
    ORDER_NEW,
    ORDER_ACCEPTED,
    ORDER_REJECTED,
    ORDER_CHANGED,
    ORDER_CONFIRMED,
    ORDER_CONFIRMFAILED,
    ORDER_CANCELED,
    ORDER_FILLED: FormManager.DoOrder(DataObj as TOrder);
  end;
end;

procedure TFormMain.LoadEnv(aStorage: TStorage; bSelf : boolean);
var
  i : integer;
  aIF : TFrontOrderIF;
  stCode  : string;
  aSymbol : TSymbol;
  bRs : boolean;
begin
  if aStorage = nil then Exit;

  if bSelf then
  begin
    bRs := aStorage.Load(ComposeFilePath([gEnv.DataDir, WIN_ENV]));
    if not bRs then Exit;
    aStorage.First;
  end;

  stCode  :=  aStorage.FieldByName('SymbolCode').AsString;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );
  if aSymbol <> nil then
  begin
    gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aSymbol);
    AddSymbolCombo(aSymbol, cbSymbol);
    cbSymbolChange(cbSymbol);
  end;

  edtPrevBasisHigh.Text := aStorage.FieldByName('BasisH').AsString;
  edtPrevBasisLow.Text  := aStorage.FieldByName('BasisL').AsString;

  edtExUpDown.Text  :=  aStorage.FieldByName('ExUpDown').AsString;
  edtExUpDownPer.Text :=  aStorage.FieldByName('ExUpDownP').AsString;

  udQty.Position :=  StrToIntDef( aStorage.FieldByName('OrderQty' ).AsString, 0) ;
  udGap.Position :=  StrToIntDef( aStorage.FieldByName('OrderGap' ).AsString, 0) ;
  udCnt.Position :=  StrToIntDef( aStorage.FieldByName('OrderCnt' ).AsString, 0) ;
  edtBidShift.Text :=   aStorage.FieldByName('BidShift' ).AsString ;
  edtAskShift.Text :=   aStorage.FieldByName('AskShift' ).AsString ;

  edtBidShift2.Text :=  aStorage.FieldByName('BidShift2' ).AsString ;
  edtAskShift2.Text :=  aStorage.FieldByName('AskShift2' ).AsString ;

  edtUpperBasis.Text  :=  aStorage.FieldByName('Upper').AsString;
  edtLowerBasis.Text  :=  aStorage.FieldByName('Lower').AsString;
  edtDelay.Text :=  aStorage.FieldByName('Delay').AsString;

  DateCancelTime.Time :=  aStorage.FieldByName('CancelTime').AsFloat;
  DateTimePickerTime.Time :=  aStorage.FieldByName('StartTime').AsFloat;

  //cbAuto.Checked  := aStorage.FieldByName('Auto').AsBoolean;

  for i := 0 to FormManager.Count - 1 do
  begin
    aIf := FormManager.FrontManager[i];
    if aIF <> nil then
      if aIF.ManagerType in [ ottJangBefore, ottJangStart, otSimulEndJust ] then
        ParamChange( aIF );
  end;

end;


procedure TFormMain.SaveEnv(aStorage: TStorage; bSelf : boolean);
var
  i : integer;
  aIF : TFrontOrderIF;
begin
  if aStorage = nil then Exit;

  if bSelf then
  begin
    aStorage.Clear;
    aStorage.New;
  end;

  if IfList.Count > 0 then
    aIF := TFrontORderIF( IfList.Items[0] )
  else
    aIF := nil;;

  if aIF <> nil then
    if aIF.Symbol <> nil then
      aStorage.FieldByName('SymbolCode').AsString := aIF.Symbol.Code
    else
      aStorage.FieldByName('SymbolCode').AsString := '';

  aStorage.FieldByName('BasisH').AsString := edtPrevBasisHigh.Text;
  aStorage.FieldByName('BasisL').AsString := edtPrevBasisLow.Text;

  aStorage.FieldByName('ExUpDown').AsString := edtExUpDown.Text;
  aStorage.FieldByName('ExUpDownP').AsString  := edtExUpDownPer.Text;

  aStorage.FieldByName('OrderQty' ).AsString := edtQty.Text;
  aStorage.FieldByName('OrderGap' ).AsString := edtGap.Text;
  aStorage.FieldByName('OrderCnt' ).AsString := edtCnt.Text;
  aStorage.FieldByName('BidShift' ).AsString := edtBidShift.Text;
  aStorage.FieldByName('AskShift' ).AsString := edtAskShift.Text;

  aStorage.FieldByName('Upper').AsString  := edtUpperBasis.Text;
  aStorage.FieldByName('Lower').AsString  := edtLowerBasis.Text;
  aStorage.FieldByName('Delay').AsString  := edtDelay.Text;

  aStorage.FieldByName('BidShift2' ).AsString := edtBidShift2.Text;
  aStorage.FieldByName('AskShift2' ).AsString := edtAskShift2.Text;

  aStorage.FieldByName('CancelTime').AsFloat := DateCancelTime.Time;
  aStorage.FieldByName('StartTime').AsFloat := DateTimePickerTime.Time;

  if bSelf then
    aStorage.Save( ComposeFilePath([gEnv.DataDir, WIN_ENV]) );

end;




procedure TFormMain.SetDefaultParam;
begin

  with FParam do
  begin
    BasisH    := StrToFloatDef( edtPrevBasisHigh.Text, 0.0 );
    BasisL    := StrToFloatDef( edtPrevBasisLow.Text, 0.0 );
    BasisA    := ( BasisH + BasisL ) / 2;

    ExUpDown  := StrToFloatDef( edtExUpDown.Text, 0.0 );
    ExUpDownP := StrToFloatDef( edtExUpDownPer.Text, 0.0 );

    BasePrice  := StrToFloatDef( edtBase.Text, 0);
    OrderQty   := StrToIntDef( edtQty.Text, 0 );
    OrderGap   := StrToIntDef( edtGap.Text, 0 );
    OrderCnt   := StrToIntDef( edtCnt.Text, 0 );

    BidShift   := StrToFloatDef( edtBidShift.Text, 1);
    AskShift   := StrToFloatDef( edtAskShift.Text, 1);

    Upper := StrToFloatDef( edtUpperBasis.Text, 0.0);
    Lower := StrToFloatDef( edtLowerBasis.Text, 0.0 );
    Delay := StrToFloatDef( edtDelay.Text, 0.0 );

    BidShift2   := StrToFloatDef( edtBidShift2.Text, 1);
    AskShift2   := StrToFloatDef( edtAskShift2.Text, 1);

    CancelTime  := DateCancelTime.Time;
    StartTime  := DateTimePickerTime.Time;

    if FQuote <> nil then
      IndexPrice := FQuote.Last;
  end;


  //FormManager.SetParam( FParam );

  lbSum.Caption :=  IntToStr( 2 * FParam.OrderCnt ) ;

end;



end.
