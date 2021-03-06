unit FTrendTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,

  CleStorage,  CleAccounts, ClePositions,  CleSymbols, CleORders, CleFunds,

  CleTrendTrade, Menus

  ;

const
  TitleCnt = 7;
  Title : array [0..TitleCnt-1] of string = ( '건수','조건','가격',
                                              '몇종목','건수','청산',
                                              '기타' );
  TitleCnt2 = 7;
  Title2 : array [0..TitleCnt2-1] of string = ( '시각','종목','구분',
                                              'LS','수량','평균가','비고' );

  Order_Col = 0;

type
  TFrmTrendTrade = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    rbF: TRadioButton;
    rbO: TRadioButton;
    stBar: TStatusBar;
    Timer1: TTimer;
    Panel3: TPanel;
    cbTrend2: TCheckBox;
    edtQty2: TEdit;
    UpDown2: TUpDown;
    cbTrend2Stop: TCheckBox;
    Button3: TButton;
    Button1: TButton;
    dtStartTime2: TDateTimePicker;
    dtEndTime2: TDateTimePicker;
    cbInvest: TComboBox;
    sgTrend2: TStringGrid;
    Panel4: TPanel;
    sgOrd: TStringGrid;
    cbUseCnt: TCheckBox;
    Button6: TButton;
    Label2: TLabel;
    cbFut: TComboBox;
    edtAccount: TEdit;
    edtLiskAmt2: TEdit;
    Panel2: TPanel;
    sgTrend1: TStringGrid;
    cbTrend1: TCheckBox;
    edtQty1: TEdit;
    UpDown1: TUpDown;
    dtStartTime: TDateTimePicker;
    Label1: TLabel;
    dtEndTime: TDateTimePicker;
    Button2: TButton;
    btnApply1: TButton;
    cbPlatoon: TCheckBox;
    edtPlatoonPoint: TEdit;
    cbReverse: TCheckBox;
    popCntNVol: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

    procedure btnApply1Click(Sender: TObject);
    procedure rbFClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure stBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);

    procedure FormActivate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure cbTrend1Click(Sender: TObject);
    procedure cbTrend2Click(Sender: TObject);
    procedure cbTrend2StopClick(Sender: TObject);
    procedure sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cbFutChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Panel2DblClick(Sender: TObject);
    procedure Panel3DblClick(Sender: TObject);
    procedure N1Click(Sender: TObject);
  private
    FAutoStart : boolean;
    FIsFund   : boolean;
    FAccount  : TAccount;
    FFund     : TFund;
    FSymbol   : TSymbol;
    TTs       : TTrendTrades;
    FParam    : TTrendParam;

    procedure initControls;
    procedure SetDefaultParam(iDir: integer);
    function GetParam( iDir : integer ) : boolean;

    function GetInvestCode : string;
    procedure SetControls;
    procedure initControls2;
    { Private declarations }
  public
    { Public declarations }

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnTrendNotify( Sender : TObject; stData : string; iDiv : integer );
    procedure OnTrendOrderEvent( aItem : TOrderedItem; iDiv : integer );
    procedure OnTrendResultNotify(Sender: TObject; Value : boolean );
  end;

var
  FrmTrendTrade: TFrmTrendTrade;

implementation

uses
  GAppEnv, GleLib, GleTypes, GleConsts, CleQuoteTimers
  ;

{$R *.dfm}

procedure TFrmTrendTrade.btnApply1Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  //GetParam( iTag );
  if not GetParam(iTag) then
    ShowMessage('추세1 조건이 잘못되었음  !! ');


end;

procedure TFrmTrendTrade.Button2Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  SetDefaultParam( iTag );
end;

procedure TFrmTrendTrade.Button6Click(Sender: TObject);
begin
  if cbStart.Checked then
  begin
    ShowMessage('실행중에는 계좌를 바꿀수 없음');
    Exit;
  end;

  if gAccount = nil then
    gEnv.CreateAccountSelect;

  try
    gAccount.Left := GetMousePoint.X+10;
    gAccount.Top  := GetMousePoint.Y;

    if gAccount.Open then
    begin
      if ( gAccount.Selected <> nil ) then
        if gAccount.Selected is TFund then
        begin
          if FFund <> gAccount.Selected then
          begin
            FIsFund := true;
            FAccount:= nil;
            FFund   := TFund( gAccount.Selected );
            edtAccount.Text := FFund.Name;
          end;
        end else
        begin
            FIsFund := false;
            FFund   := nil;
            FAccount:= TAccount( gAccount.Selected );
            edtAccount.Text := FAccount.Name
        end;
    end;
  finally
    gAccount.Hide;
  end;
end;

procedure TFrmTrendTrade.SetDefaultParam( iDir : integer );
var
  i : integer;
begin
  case iDir of
    // 추세 1
    1 : if rbF.Checked then
        begin
          with sgTrend1 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '0.7';
              Cells[2,i]  := '0';
              Cells[3,i]  := '1';
              Cells[4,i]  := '2';
              Cells[5,i]  := '0.9';
              Cells[6,i]  := '';
            end;
        end
        else begin
          with sgTrend1 do
          begin
              // 매수
              Cells[1,1]  := '0.7';
              Cells[2,1]  := '0.7';
              Cells[3,1]  := '1';
              Cells[4,1]  := '2';
              Cells[5,1]  := '0.9';
              Cells[6,1]  := '1';

              // 매도
              Cells[1,2]  := '0.65';
              Cells[2,2]  := '1';
              Cells[3,2]  := '1';
              Cells[4,2]  := '2';
              Cells[5,2]  := '1';
              Cells[6,2]  := '1';
          end;

        end;
    // 추세 2 투자자
    2 : if rbF.Checked then
        begin
          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';      // 조건
              if i=2 then
                Cells[1,i]  := '-50';      // 조건

              Cells[2,i]  := '0';       // 진입가격조건
              Cells[3,i]  := '1';       // 종목카운트
              Cells[4,i]  := '1';       // 진입카운트
              Cells[5,i]  := '0';       // 청산조건
              Cells[6,i]  := '50';       // 청산조건
            end;
        end
        else begin

          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';
              if i=2 then
                Cells[1,i]  := '-50';      // 조건
              Cells[2,i]  := '1';
              Cells[3,i]  := '1';
              Cells[4,i]  := '1';
              Cells[5,i]  := '0';
              Cells[6,i]  := '50';
            end;

        end;
  end;
end;

procedure TFrmTrendTrade.sgOrdDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgClr, ftClr : TColor;
    wFmt : word;
    rRect : TRect;
begin

  wFmt  := DT_CENTER or DT_VCENTER;
  rRect := Rect;
  bgClr := clWhite;
  ftClr := clBlack;

  with sgOrd do
  begin

    stTxt := Cells[ ACol, ARow ];

    if ARow = 0 then
    begin
      bgClr := clBtnFace;
    end
    else begin
      if ACol = 3 then
        if stTxt = 'L' then
          ftClr := clRed
        else
          ftClr := clBlue;

      if Objects[1,ARow] <> nil then
        bgClr := TColor( Objects[1,ARow] );

      if ACol in [4,5] then
        wFmt  := DT_RIGHT or DT_VCENTER;
    end;

    Canvas.Font.Color   := ftClr;
    Canvas.Brush.Color  := bgClr;

    Canvas.FillRect(Rect);
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, wFmt );
  end;

end;

procedure TFrmTrendTrade.stBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  {
  var
    oRect : TRect;

  function GetRect( oRect : TRect ) : TRect ;
  begin
    Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
  end;
  }
begin
   {
  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stBar.Canvas.Handle, PChar( stBar.Panels[0].Text ),
    Length( stBar.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
    }
end;

procedure TFrmTrendTrade.Timer1Timer(Sender: TObject);
var
  stData, stFile : string;
  dTot, dFut, dOpt, dS, dFee : double;
  I: Integer;
  aAcnt : TAccount;
begin
  // 손익 적기
  if TTs.Count <= 0 then Exit;

  dFut := 0; dOpt := 0; dS := 0;  dTot := 0;   dFee := 0;

  for I := 0 to TTs.Count - 1 do
  begin
    aAcnt := TTs.Trend[i].Account;
    dFut := 0; dOpt := 0; dS := 0;

    dTot := dTot
      + gEnv.Engine.TradeCore.Positions.GetMarketPl( aAcnt, dFut, dOpt, dS  );
    dFee := dFee + ( aAcnt.GetFee / 1000 );
  end;

  stData  := Format('%.0f ', [  (dTot / 1000) - ( dFee / 1000 ) ] );
  stBar.Panels[2].Text := stData;
end;

function TFrmTrendTrade.GetInvestCode: string;
begin
  case cbInvest.ItemIndex of
    0 : Result := INVEST_FINANCE;
    2 : Result := INVEST_GONG;
    1 : REsult := INVEST_FORIN;
  end;
end;

function TFrmTrendTrade.GetParam( iDir : integer ) : boolean;
var
  I: Integer;
  bResult : boolean;
begin

  bResult := false;

  try

    with FParam do
    begin

      StartTime := dtStartTime.Time;
      EndTime   := dtEndTime.Time;

      StartTime2:= dtStartTime2.Time;
      EndTime2  := dtEndTime2.Time;
      UseFut  := rbF.Checked;
      FutIdx  := cbFut.ItemIndex;

      UseTrd1 := cbTrend1.Checked;
      UseTrd2 := cbTrend2.Checked;
      UseTrdStop  := cbTrend2Stop.Checked;

      case iDir of
        1 : begin
          OrdQty1            := StrToIntDef( edtQty1.Text, 2 );
          OrdCon1[ptLong]    := StrToFloat( sgTrend1.Cells[1,1] ) ;
          BasePrice1[ptLong] := StrToFloat( sgTrend1.Cells[2,1] ) ;
          SymbolCnt1[ptLong] := StrToInt( sgTrend1.Cells[3,1] ) ;
          OrdCnt1[ptLong] := StrToInt( sgTrend1.Cells[4,1] ) ;
          LiqCon1[ptLong] := StrToFloat( sgTrend1.Cells[5,1] )  ;
          OtrCon1[ptLong] := StrToFloatdef( sgTrend1.Cells[6,1], 1 ) ;

          OrdCon1[ptShort]    := StrToFloat( sgTrend1.Cells[1,2] ) ;
          BasePrice1[ptShort] := StrToFloat( sgTrend1.Cells[2,2] ) ;
          SymbolCnt1[ptShort] := StrToInt( sgTrend1.Cells[3,2] ) ;
          OrdCnt1[ptShort] := StrToInt( sgTrend1.Cells[4,2] ) ;
          LiqCon1[ptShort] := StrToFloat( sgTrend1.Cells[5,2] )  ;
          OtrCon1[ptShort] := StrToFloatdef( sgTrend1.Cells[6,2], 1 ) ;

          end;
        2 : begin
          OrdQty2            := StrToIntDef( edtQty2.Text, 1 );
          OrdCon2[ptLong]    := StrToFloat( sgTrend2.Cells[1,1] ) ;
          BasePrice2[ptLong] := StrToFloat( sgTrend2.Cells[2,1] ) ;
          SymbolCnt2[ptLong] := StrToInt( sgTrend2.Cells[3,1] ) ;
          OrdCnt2[ptLong] := StrToInt( sgTrend2.Cells[4,1] ) ;
          LiqCon2[ptLong] := StrToFloat( sgTrend2.Cells[5,1] )  ;
          OtrCon2[ptLong] := StrToFloatdef( sgTrend2.Cells[6,1], 50 ) ;

          OrdCon2[ptShort]    := StrToFloat( sgTrend2.Cells[1,2] ) ;
          BasePrice2[ptShort] := StrToFloat( sgTrend2.Cells[2,2] ) ;
          SymbolCnt2[ptShort] := StrToInt( sgTrend2.Cells[3,2] ) ;
          OrdCnt2[ptShort] := StrToInt( sgTrend2.Cells[4,2] ) ;
          LiqCon2[ptShort] := StrToFloat( sgTrend2.Cells[5,2] )  ;
          OtrCon2[ptShort] := StrToFloatdef( sgTrend2.Cells[6,2], 50 ) ;
          // 계약당 얼마로 수정 --> 펀드 승수땜시
          LiskAmt2         := StrToFloatDef( edtLiskAmt2.Text, 8 ) * 10000;
          UseCnt    := cbUseCnt.Checked;

          UsePlatoon      := cbPlatoon.Checked;
          PlatoonPoint    := StrToFloatDef( edtPlatoonPoint.Text, 3 );
          UseReverse      := cbReverse.Checked;

        end;
      end;
    end;

    ///  2020.03.04 추가 조건
    if (iDir = 1) and ( FParam.UseTrd1 ) then
    begin
      if  FParam.Trd1UseCnt then begin
        // 건수 사용인데 1 보다 크면...안됨
        if ( FParam.OrdCon1[ptLong] > 1 ) or ( FParam.OrdCon1[ptShort] > 1 ) then begin
          bResult := false;
          Exit;
        end;
      end else
      begin
        // 잔량 사용인데 1보다 작으면 안됨..
        if ( FParam.OrdCon1[ptLong] <  1.1 ) or ( FParam.OrdCon1[ptShort] < 1.1  ) or
           ( FParam.OtrCon1[ptLong] < 1.1 ) or ( FParam.OtrCon1[ptShort] < 1.1 ) then begin
          bResult := false;
          Exit;
        end;
      end;
    end;

    for I := 0 to TTs.Count - 1 do
      TTs.Trend[i].Param  := FParam;

    bResult := true;
  finally
    result := bResult;
  end;


end;

procedure TFrmTrendTrade.cbFutChange(Sender: TObject);
begin
  //

end;

procedure TFrmTrendTrade.cbStartClick(Sender: TObject);
var
  I: Integer;
  aItem : TFundItem;
  aTrd  : TTrendTrade;
begin
  if (( not FIsFund ) and ( FAccount = nil ) or ( FSymbol = nil ))
    or
    (( FIsFund) and ( FFund = nil ) or (FSymbol = nil ))then

  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  try
    if cbStart.Checked then
    begin

      TTs.Clear;

      if FIsFund then
      begin
        for I := 0 to FFund.FundItems.Count - 1 do
        begin
          aTrd  := TTs.New(GetInvestCode);
          aTrd.init( FFund.FundAccount[i], FSymbol);
          aTrd.Multi  := FFund.FundItems[i].Multiple;
          aTrd.OnTrendNotify  := OnTrendNotify;
          aTrd.OnTrendOrderEvent  := OnTrendOrderEvent;
          aTrd.OnTrendResultNotify:= OnTrendResultNotify;
        end;

        if not GetParam(1) then
        begin
          ShowMessage('추세1 조건이 잘못되었음  !! ');
          cbStart.Checked := false;
          Exit;
        end;
        GetParam(2);

        for I := 0 to TTS.Count - 1 do
          TTs.Trend[i].Start;

      end else
      begin
          aTrd  := TTs.New(GetInvestCode);
          aTrd.init( FAccount, FSymbol);
          aTrd.OnTrendNotify  := OnTrendNotify;
          aTrd.OnTrendOrderEvent  := OnTrendOrderEvent;
          aTrd.OnTrendResultNotify:= OnTrendResultNotify;
          if not GetParam(1) then
          begin
            ShowMessage('추세1 조건이 잘못되었음  !! ');
            cbStart.Checked := false;
            Exit;
          end;
          GetParam(2);
          aTrd.Start;
      end;
    end
    else begin
      for I := 0 to TTS.Count - 1 do
      begin
        TTs.Trend[i].OnTrendNotify  := nil;
        TTs.Trend[i].OnTrendOrderEvent  := nil;
        TTs.Trend[i].OnTrendResultNotify:= nil;
        TTs.Trend[i].Stop;
      end;
    end;

  finally
    SetControls;
  end;

end;

procedure TFrmTrendTrade.SetControls;
var
  bEable : boolean;
begin
  bEable  := not cbStart.Checked;

  Button6.Enabled := bEable;
  rbF.Enabled     := bEable;
  rbO.Enabled     := bEable;
  cbFut.Enabled   := bEable;

  stBar.Panels[1].Text := '';

  if cbStart.Checked then
    Panel1.Color  := clAqua
  else
    Panel1.Color  := clBtnFace;
end;

procedure TFrmTrendTrade.cbTrend1Click(Sender: TObject);
var
  i : integer;
begin
  FParam.UseTrd1  := cbTrend1.Checked;
  for I := 0 to TTs.Count - 1 do
    TTs.Trend[i].Param  := FParam;
end;

procedure TFrmTrendTrade.cbTrend2Click(Sender: TObject);
var
  i : integer;
begin
  FParam.UseTrd2  := cbTrend2.Checked;
  for I := 0 to TTs.Count - 1 do
    TTs.Trend[i].Param  := FParam;
end;

procedure TFrmTrendTrade.cbTrend2StopClick(Sender: TObject);
var
  i : integer;
begin
  FParam.UseTrdStop  := cbTrend2Stop.Checked;
  for I := 0 to TTs.Count - 1 do
    TTs.Trend[i].Param  := FParam
end;

procedure TFrmTrendTrade.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil ) and ( FSymbol <> nil ) then
      if not cbStart.Checked then
       cbStart.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmTrendTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TFrmTrendTrade.FormCreate(Sender: TObject);
begin
  //
  initControls;

  FSymbol := gEnv.Engine.SymbolCore.Future;
  TTs        := TTrendTrades.Create;
  FAutoStart := false;
  FParam.Trd1UseCnt    := true;  // 추세1 에서 건수를 사용  false 는 잔량을 사용


end;

procedure TFrmTrendTrade.FormDestroy(Sender: TObject);
begin
  TTs.Free;
end;

procedure TFrmTrendTrade.initControls;
var
  I: integer;
begin

  for I := 0 to TitleCnt - 1 do begin
    with sgTrend1 do Cells[i,0]  := Title[i];
    with sgTrend2 do Cells[i,0]  := Title[i];
  end;


  with sgOrd do
    for I := 0 to TitleCnt2 - 1 do
      Cells[i,0]  := Title2[i];

  sgTrend1.Cells[0,1] := '매수';
  sgTrend1.Cells[0,2] := '매도';

  sgTrend2.Cells[0,1] := '상승';
  sgTrend2.Cells[0,2] := '하락';

  SetDefaultParam(1);
  SetDefaultParam(2);

end;

procedure TFrmTrendTrade.initControls2;
begin

  if FParam.Trd1UseCnt  then begin
    sgTrend1.Cells[0,0] := '건수';

  end
  else begin
    sgTrend1.Cells[0,0] := '잔량'   ;

  end;

end;

procedure TFrmTrendTrade.LoadEnv(aStorage: TStorage);
var
  j, i : integer;
  aAcnt: TAccount;
  stCode : string;
  aFund  : TFund;
begin
  if aStorage = nil then Exit;

  FIsFund := aStorage.FieldByName('IsFund').AsBooleanDef(false);
  stCode := aStorage.FieldByName('AcntCode').AsString;

  if FIsFund  then
  begin
    aFund := gEnv.Engine.TradeCore.Funds.Find( stCode );
    if aFund <> nil then
    begin
      FIsFund  := true;
      FFund    := aFund;
      FAccount := nil;
      edtAccount.Text := FFund.Name;
    end;
  end else
  begin
    aAcnt := gEnv.Engine.TradeCore.Accounts.Find( stCode );
    if aAcnt <> nil then
    begin
      FIsFund   := false;
      FFund     := nil;
      FAccount  := aAcnt;
      edtAccount.Text := FAccount.Name;
    end;
  end;

  cbTrend1.Checked  := aStorage.FieldByName('Trend1').AsBoolean;
  cbTrend2.Checked  := aStorage.FieldByName('Trend2').AsBoolean;

  rbF.Checked := aStorage.FieldByName('Fut').AsBoolean ;
  rbO.Checked := aStorage.FieldByName('Opt').AsBoolean ;

  cbTrend2Stop.Checked  := aStorage.FieldByName('Trend2Stop').AsBoolean ;

  UpDown1.Position := StrToIntDef( aStorage.FieldByName('Qty1').AsString, 2 );
  UpDown2.Position := StrToIntDef( aStorage.FieldByName('Qty2').AsString, 1 );

  dtStartTime.Time := TDateTime( aStorage.FieldByName('StartTime').AsFloat );
  dtEndTime.Time := TDateTime( aStorage.FieldByName('EndTime').AsFloat );

  dtStartTime2.Time := TDateTime( aStorage.FieldByName('StartTime2').AsFloat );
  dtEndTime2.Time := TDateTime( aStorage.FieldByName('EndTime2').AsFloat );

  cbInvest.ItemIndex  := aStorage.FieldByName('InvestIdx').AsInteger ;
  cbUseCnt.Checked    := aStorage.FieldByName('UseCnt').AsBoolean;

  edtLiskAmt2.Text  := aStorage.FieldByName('LiskAmt2').AsString;
  cbFut.ItemIndex := aStorage.FieldByName('FutIdx').AsInteger;

  cbPlatoon.Checked   := aStorage.FieldByName('UsePlatoon').AsBooleanDef( cbPlatoon.Checked );
  edtPlatoonPoint.Text:= aStorage.FieldByName('PlatoonPoint').AsStringDef( edtPlatoonPoint.Text );
  cbReverse.Checked   := aStorage.FieldByName('UseReverse').AsBooleanDef( cbReverse.Checked );

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName( Format('Trend1[%d,%d]',[j,i] ) ).AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString;

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName( Format('Trend2[%d,%d]', [j,i])  ).AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString;  

  Panel2.Tag  := aStorage.FieldByName('p2').AsIntegerDef(0);
  Panel3.Tag  := aStorage.FieldByName('p3').AsIntegerDef(0);

  with Panel2 do
  begin
    if Tag = 0 then
      Height := 90
    else
      Height := 25;
  end;

  with Panel3 do
  begin
    if Tag = 0 then
      Height := 116
    else
      Height := 25;
  end;

  FParam.Trd1UseCnt :=  aStorage.FieldByName('Trd1UseCnt').AsBooleanDef( true );
  if FParam.Trd1UseCnt then
    N1.Checked := true
  else
    N2.Checked := true;

  initControls2;
end;

procedure TFrmTrendTrade.N1Click(Sender: TObject);
var
  iDiv : integer;
begin
  //
  iDiv := popCntNVol.Items.IndexOf( Sender as TMenuItem );

  case iDiv of
    0 : FParam.Trd1UseCnt := true;
    else FParam.Trd1UseCnt := false;
  end;

  initControls2;

end;

procedure TFrmTrendTrade.OnTrendNotify(Sender: TObject; stData: string;
  iDiv: integer);
begin
  if Sender = nil then Exit;
  stBar.Panels[iDiv-1].Text := stData;
end;

procedure TFrmTrendTrade.OnTrendOrderEvent(aItem: TOrderedItem; iDiv: integer);
var
  iRow : integer;
  stDiv: string;
begin
  iRow := 1;
  InsertLine( sgOrd, iRow );

  if aItem.stType = stTrend then
    stDiv := sgTrend1.Cells[0,0]  
  else
    stDiv := '투자';

  with sgOrd do
  begin
    if iDiv > 0  then
    begin
      Objects[Order_Col, iRow]  := aItem.Order;
    end
    else begin
      Objects[Order_Col, iRow]  := aItem.LiqOrder;
    end;

    if aItem.stType = stTrend then
      Objects[1, iRow]  := Pointer(clWhite)
    else
      Objects[1, iRow]  := Pointer($00EEEEEE);

    Cells[0, iRow]  := FormatDateTime('hh:nn:ss', GetQuoteTime );
    Cells[1, iRow]  := aItem.Symbol.ShortCode;
    Cells[2, iRow]  := stDiv;

    if iDiv = 1 then begin
      if aItem.Order <> nil then
      begin
        Cells[3, iRow] :=  ifThenStr( aItem.Order.Side > 0 ,'L','S' );
        Cells[4, iRow]  := IntToStr( aItem.Order.OrderQty );
        Cells[5, iRow]  := Format('%.2f', [ aItem.Order.FilledPrice ] );
        Cells[6, iRow]  := '신규';
      end else Cells[6, iRow]  := 'nil';
    end
    else if iDiv = -1 then begin
      if aItem.LiqOrder <> nil then
      begin
        Cells[3, iRow] := ifThenStr( aItem.LiqOrder.Side > 0 ,'L','S' );
        Cells[4, iRow]  := IntToStr( aItem.LiqOrder.OrderQty );
        Cells[5, iRow]  := Format('%.2f', [ aItem.Order.FilledPrice ] );
        Cells[6, iRow]  := '청산';
      end else Cells[6, iRow]  := 'nil';
    end else
    if iDiv = 100 then begin
      Cells[3, iRow]  := ifThenStr( aItem.OrdRes.OrdDir > 0 ,'L','S' );
      Cells[4, iRow]  := IntToStr( FParam.OrdQty2 );
      Cells[5, iRow]  := Format('%.2f', [ aItem.Last ] );
      Cells[6, iRow]  := '준비';
    end else
    if iDiv = -100 then begin
      Cells[3, iRow]  := ifThenStr( aItem.OrdRes.OrdDir > 0 ,'L','S' );
      Cells[4, iRow]  := IntToStr( FParam.OrdQty2 );
      Cells[5, iRow]  := Format('%.2f', [ aItem.Last ] );
      Cells[6, iRow]  := '해제';
    end;
  end;
end;

procedure TFrmTrendTrade.OnTrendResultNotify(Sender: TObject; Value: boolean);
var
  iRow : integer;
begin
//
  iRow  := sgOrd.Cols[Order_Col].IndexOfObject( Sender );

  if iRow > 0 then
  begin
    with sgOrd do
      Cells[5, iRow]  := Format('%.2f', [ ( Sender as TOrder).FilledPrice ] );
  end;
end;

procedure TFrmTrendTrade.Panel2DblClick(Sender: TObject);
begin
  //  90
  with Panel2 do
  begin
    if Tag = 0 then begin
      Height := 25;
      Tag    := 1;
    end else
    begin
      Height := 90;
      Tag    := 0;
    end;
  end;
end;

procedure TFrmTrendTrade.Panel3DblClick(Sender: TObject);
begin
  // 116
  with Panel3 do
  begin
    if Tag = 0 then begin
      Height := 25;
      Tag    := 1;
    end else
    begin
      Height := 116;
      Tag    := 0;
    end;
  end;
end;

procedure TFrmTrendTrade.rbFClick(Sender: TObject);
begin
  SetDefaultParam(1);
  SetDefaultParam(2);
    {
  if TT = nil then Exit;

  FParam.UseFut  := rbF.Checked;
  if TT <> nil then
    TT.Param  := FParam;
    }
end;

procedure TFrmTrendTrade.SaveEnv(aStorage: TStorage);
var
  j, i : integer;
begin
  if aStorage = nil then Exit;

  aStorage.FieldByName('IsFund').AsBoolean := FIsFund;

  if FIsFund then begin
    if FFund <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FFund.Name
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end
  else begin
    if FAccount <> nil then
      aStorage.FieldByName('AcntCode').AsString    := FAccount.Code
    else
      aStorage.FieldByName('AcntCode').AsString    := '';
  end;

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString  := Cells[j,i];

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString   := Cells[j,i];

  aStorage.FieldByName('Trend1').AsBoolean  := cbTrend1.Checked;
  aStorage.FieldByName('Trend2').AsBoolean  := cbTrend2.Checked;

  aStorage.FieldByName('Fut').AsBoolean  := rbF.Checked;
  aStorage.FieldByName('Opt').AsBoolean  := rbO.Checked;
  aStorage.FieldByName('Trend2Stop').AsBoolean  := cbTrend2Stop.Checked;

  aStorage.FieldByName('Qty1').AsString := edtQty1.Text;
  aStorage.FieldByName('Qty2').AsString := edtQty2.Text;

  aStorage.FieldByName('StartTime').AsFloat := double( dtStartTime.Time );
  aStorage.FieldByName('StartTime2').AsFloat := double( dtStartTime2.Time );

  aStorage.FieldByName('EndTime').AsFloat := double( dtEndTime.Time );
  aStorage.FieldByName('EndTime2').AsFloat := double( dtEndTime2.Time );

  aStorage.FieldByName('InvestIdx').AsInteger := cbInvest.ItemIndex;
  aStorage.FieldByName('FutIdx').AsInteger := cbFut.ItemIndex;
  aStorage.FieldByName('UseCnt').AsBoolean    := cbUseCnt.Checked;

  aStorage.FieldByName('LiskAmt2').AsString := edtLiskAmt2.Text;

  aStorage.FieldByName('p2').AsInteger := Panel2.Tag;
  aStorage.FieldByName('p3').AsInteger := Panel3.Tag;

  aStorage.FieldByName('UsePlatoon').AsBoolean  := cbPlatoon.Checked;
  aStorage.FieldByName('PlatoonPoint').AsString := edtPlatoonPoint.Text;
  aStorage.FieldByName('UseReverse').AsBoolean  := cbReverse.Checked;

  aStorage.FieldByName('Trd1UseCnt').AsBoolean  := FParam.Trd1UseCnt;
end;

end.
