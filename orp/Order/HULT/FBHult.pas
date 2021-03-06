unit FBHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Math,
  Dialogs, DateUtils,

  CleSymbols, CleAccounts, CleFunds,  ClePositions,

  CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,

  CleStorage, UPaveConfig , GleTypes , CleBHultEx,

  ComCtrls, StdCtrls, ExtCtrls , Grids;

type
  TFrmBHult = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    Panel2: TPanel;
    gbUseHul: TGroupBox;
    stTxt: TStatusBar;
    dtEndTime: TDateTimePicker;
    GroupBox3: TGroupBox;
    Label2: TLabel;
    edtOrdQty: TEdit;
    udQty: TUpDown;
    Label9: TLabel;
    edtOrdCnt: TEdit;
    udOrdCnt: TUpDown;
    GroupBox5: TGroupBox;
    cbEntCntRate: TCheckBox;
    cbEntForeign: TCheckBox;
    cbEntPoint: TCheckBox;
    edtEntCntRate: TLabeledEdit;
    edtEntForeignQty: TLabeledEdit;
    dtStartTime: TDateTimePicker;
    Label6: TLabel;
    Button2: TButton;
    edtAccount: TEdit;
    Button6: TButton;
    edtEntPoint1: TLabeledEdit;
    GroupBox2: TGroupBox;
    cbLiqCntRate: TCheckBox;
    cbLiqForeign: TCheckBox;
    cbLiqPoint: TCheckBox;
    edtLiqCntRate: TLabeledEdit;
    edtLiqForeignRate: TLabeledEdit;
    edtLiqPoint: TLabeledEdit;
    stPoint: TStaticText;
    stForFutQty: TStaticText;
    stCntRate: TStaticText;
    Panel3: TPanel;
    sgLog: TStringGrid;
    edtEntPoint2: TLabeledEdit;
    gbOptCon: TGroupBox;
    edtBelow: TLabeledEdit;
    cbBuy: TCheckBox;
    cbSub: TComboBox;
    cbMarket: TComboBox;
    cbStopLiq: TCheckBox;
    edtListAmt: TLabeledEdit;
    refreshTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);

    procedure cbStartClick(Sender: TObject);
    procedure edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
    procedure Button2Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure refreshTimerTimer(Sender: TObject);


    procedure edtEntCntRateChange(Sender: TObject);
    procedure cbEntCntRateClick(Sender: TObject);

    procedure edtTargetPosChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure edtBelowKeyPress(Sender: TObject; var Key: Char);
    procedure GroupBox5Click(Sender: TObject);
    procedure GroupBox2Click(Sender: TObject);

  private
    { Private declarations }
    FAccount    : TAccount;
    FSymbol     : TSymbol;

    FIsFund : boolean;
    FFund   : TFund;

    FJarvisData : TJarvisData;
    FBHultAxis  : TBHultEx;

    procedure initControls;
    procedure GetParam;

    function GetRect(oRect: TRect): TRect;

    procedure SetControls(bEnable: boolean);

    procedure DoLog( stLog : string );
    procedure OnDisplay(Sender: TObject; Value : boolean );
    procedure OnJarvisNotify( Sender : TObject; jetType : TjarvisEventType; stData : string );

  public
    { Public declarations }
    procedure Stop( bCnl : boolean = true );
    procedure Start;

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

  end;

var
  FrmBHult: TFrmBHult;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

{ TFrmBHult }

procedure TFrmBHult.Button2Click(Sender: TObject);
begin
  if ( FBHultAxis <> nil ) and ( cbStart.Checked ) then
  begin
    GetParam;
    FBHultAxis.JarvisData := FJarvisData;
  end;
end;

procedure TFrmBHult.Button6Click(Sender: TObject);
begin
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

procedure TFrmBHult.cbEntCntRateClick(Sender: TObject);
var
  iTag : integer;
begin

  if ( FBHultAxis = nil ) or ( not cbStart.Checked ) then Exit;

  iTag  := (Sender as TCheckBox).Tag;

  with FJarvisData do
  case (Sender as TCheckBox).Tag of
    // ????
    0 :
      begin
        UseEntCntRate := cbEntCntRate.Checked;
        CntRate := StrTofloatDef( edtEntCntRate.Text, 0.65 );
        FBHultAxis.UpdateParam( iTag, UseEntCntRate, CntRate, 0 );
      end;
    1 :
      begin
        UseEntForeignQty  := cbEntForeign.Checked;
        ForeignQty := StrToIntDef( edtEntForeignQty.Text, 2000 );
        FBHultAxis.UpdateParam( iTag, UseEntForeignQty, ForeignQty, 0 );
      end;
    2 :
      begin
        UseEntPoint  := cbEntPoint.Checked;
        Point1      := StrToFloatDef( edtEntPoint1.Text, 1.5 );
        Point2      := StrToFloatDef( edtEntPoint2.Text, 2.0 );
        FBHultAxis.UpdateParam( iTag, UseEntPoint, Point1, Point2 );
      end;
     // ????
    4 :
      begin
        UseLiqCntRate    := cbLiqCntRate.Checked;
        LIqCntRate       := StrToFloatDef( edtLiqCntRate.Text, 0.8 );
        FBHultAxis.UpdateParam( iTag, UseLiqCntRate, LIqCntRate, 0 );
      end ;
    5 :
      begin
        UseLiqForeignQty := cbLiqForeign.Checked;
        LiqForeignPer    := StrToFloatDef( edtLiqForeignRate.Text, 50 );
        FBHultAxis.UpdateParam( iTag, UseLiqForeignQty, LiqForeignPer, 0 );
      end;
    6 :
      begin
        UseLiqPoint      := cbLiqPoint.Checked;
        LiqPoint         := StrToFloatDef( edtLiqPoint.Text, 0.75 );
        FBHultAxis.UpdateParam( iTag, UseLiqPoint, LiqPoint, 0 );
      end;
    100 :
      begin
        UseStopLiq       := cbStopLiq.Checked;
        FBHultAxis.UpdateParam( iTag, UseStopLiq, 0, 0 );
      end;
  end;



end;

procedure TFrmBHult.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop( false );
end;


procedure TFrmBHult.DoLog(stLog: string);
begin
  InsertLine( sgLog, 1 );
  sgLog.Cells[0, 1] := FormatDateTime('hh:nn:ss', GetQuoteTime );
  sgLog.Cells[1, 1] := stLog;
end;

procedure TFrmBHult.edtBelowKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0;
end;

procedure TFrmBHult.edtEntCntRateChange(Sender: TObject);
begin
  case ( Sender as TControl).Tag of
    // Entry Condition
    0 : cbEntCntRate.Checked := false;
    1 : cbEntForeign.Checked := false ;
    2, 3 : cbEntPoint.Checked:= false ;
    // Liquide Condition
    4 : cbLiqCntRate.Checked := false;
    5 : cbLiqForeign.Checked := false ;
    6 : cbLiqPoint.Checked   := false ;
  end;
end;



procedure TFrmBHult.edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmBHult.edtTargetPosChange(Sender: TObject);
begin
   {
  FJarvisData.TargetPos := StrToIntDef( edtTargetPos.Text, 5 );
  if FBHultAxis <> nil then
    FBHultAxis.JarvisData := FJarvisData;
    }
end;

procedure TFrmBHult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmBHult.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount    := nil;
  FFund       := nil;
  FBHultAxis  := TBHultEx.Create( nil );

  FSymbol := gEnv.Engine.SymbolCore.Future;
end;

procedure TFrmBHult.FormDestroy(Sender: TObject);
begin
  if FBHultAxis <> nil then
    FBHultAxis.Free;
end;

procedure TFrmBHult.GetParam;
begin
  with FJarvisData do
  begin
    StartTime   := Frac( dtStartTime.Time );
    EndTime     := Frac( dtEndTime.Time );
    UseStopLiq  := cbStopLiq.Checked;
    LiskAmt     := StrToFloatDef( edtListAmt.Text, 60 ) * 10000;

    OrdQty  := StrToIntDef( edtOrdQty.Text, 1 );
    OrdCnt  := StrToIntDef( edtOrdCnt.Text, 1 );

    Marketdiv := cbMarket.ItemIndex;
    SubMaKDiv := cbSub.ItemIndex;
    UseBuy    := cbBuy.Checked;
    BelowPrc  := StrToFloatDef( edtBelow.Text, 1.0 );

    UseEntCntRate    := cbEntCntRate.Checked;
    UseEntForeignQty := cbEntForeign.Checked;
    UseEntPoint      := cbEntPoint.Checked;
    CntRate := StrToFloatDef( edtEntCntRate.Text, 0.65 );
    ForeignQty  := StrTointDef( edtEntForeignQty.Text, 2000 );
    Point1      := StrToFloatDef( edtEntPoint1.Text, 1.5 );
    Point2      := StrToFloatDef( edtEntPoint2.Text, 2.0 );


    UseLiqCntRate    := cbLiqCntRate.Checked;
    UseLiqForeignQty := cbLiqForeign.Checked;
    UseLiqPoint      := cbLiqPoint.Checked;
    LIqCntRate       := StrToFloatDef( edtLiqCntRate.Text, 0.8 );
    LiqForeignPer    := StrToFloatDef( edtLiqForeignRate.Text, 50 );
    LiqPoint         := StrToFloatDef( edtLiqPoint.Text, 0.75 );
    LiqUseAnd        := GroupBox2.Tag = 0;
  end;
                           
end;

procedure TFrmBHult.initControls;
begin
  sgLog.Cells[0,0]  := '????';
  sgLog.Cells[1,0]  := '????';
end;

procedure TFrmBHult.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
  aFund : TFund;
  aAcnt : TAccount;
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
  // Main
  // ????
  udQty.Position    := StrToIntDef(aStorage.FieldByName('OrderQty').AsString, 1 );
  udOrdCnt.Position := StrToIntDef(aStorage.FieldByName('Ordercnt').AsString, 1 );
  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBooleanDef( true );
  edtListAmt.Text   := aStorage.FieldByName('LiskAmt').AsStringDef( edtListAmt.Text );

  // ????
  cbMarket.ItemIndex  := aStorage.FieldByName('MarketDiv').AsIntegerDef(0);
  cbSub.ItemIndex     := aStorage.FieldByName('SubMakDiv').AsIntegerDef(0);
  cbBuy.Checked       := aStorage.FieldByName('UseBuy').AsBooleanDef( false );
  edtBelow.Text       := aStorage.FieldByName('BelowPrc').AsStringDef(edtBelow.Text);

  // ????
  edtEntCntRate.Text    := aStorage.FieldByName('EntCntRate').AsStringDef( edtEntCntRate.Text );
  edtEntForeignQty.Text := aStorage.FieldByName('EntForeignQty').AsStringDef( edtEntForeignQty.Text );
  edtEntPoint1.Text     := aStorage.FieldByName('EntPoint1').AsStringDef( edtEntPoint1.Text );
  edtEntPoint2.Text     := aStorage.FieldByName('EntPoint2').AsStringDef( edtEntPoint2.Text );

  cbEntCntRate.Checked  := aStorage.FieldByName('UseEntCntRate').AsBoolean;
  cbEntForeign.Checked  := aStorage.FieldByName('UseEntForeign').AsBoolean;
  cbEntPoint.Checked    := aStorage.FieldByName('UseEntPoint').AsBoolean ;

  // ????
  edtLiqCntRate.Text    := aStorage.FieldByName('LiqCntRate').AsStringDef( edtLiqCntRate.Text ) ;
  edtLiqForeignRate.Text:= aStorage.FieldByName('LiqForeignRate').AsStringDef( edtLiqForeignRate.Text) ;
  edtLiqPoint.Text      := aStorage.FieldByName('LiqPoint').AsStringDef( edtLiqPoint.Text ) ;

  cbLiqCntRate.Checked  := aStorage.FieldByName('UseLiqCntRate').AsBoolean;
  cbLiqForeign.Checked  := aStorage.FieldByName('UseLiqForeign').AsBoolean;
  cbLiqPoint.Checked    := aStorage.FieldByName('UseLiqPoint').AsBoolean;
  if aStorage.FieldByName('UseLiqAnd').AsBooleandef(true) then
  begin
    GroupBox2.Tag := 0;
    GroupBox2.Caption := '???? (And)';
  end else
  begin
    GroupBox2.Tag := 1;
    GroupBox2.Caption := '???? (Or)';
  end;

  // ????
  dtStartTime.Time  := TDateTime( aStorage.FieldByName('StartTime').AsTimeDef( dtStartTime.Time ) 	);
  dtEndTime.Time    := TDateTime( aStorage.FieldByName('EndTime').AsTimeDef( dtEndTime.Time )	);

end;

procedure TFrmBHult.OnDisplay(Sender: TObject; Value: boolean);
var
  i : integer;

begin
  if FBHultAxis = nil then exit;
end;

procedure TFrmBHult.OnJarvisNotify(Sender: TObject; jetType: TjarvisEventType;
  stData: string);
begin
  if Sender <> FBHultAxis then Exit;

  case jetType of
    jetLog : DoLog( stData ) ;
  //  jetStop: PostMessage( Handle, WM_ENDMESSAGE, 0, 0 );
  end;

end;

procedure TFrmBHult.SaveEnv(aStorage: TStorage);
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

  // ????
  aStorage.FieldByName('OrderQty').AsString     := edtOrdQty.Text;
  aStorage.FieldByName('Ordercnt').AsString     := edtOrdCnt.Text;
  aStorage.FieldByName('UseStopLiq').AsBoolean  := cbStopLiq.Checked;
  aStorage.FieldByName('LiskAmt').AsString      := edtListAmt.Text;

  // ????
  aStorage.FieldByName('MarketDiv').AsInteger    := cbMarket.ItemIndex;
  aStorage.FieldByName('SubMakDiv').AsInteger    := cbSub.ItemIndex;
  aStorage.FieldByName('UseBuy').AsBoolean       := cbBuy.Checked;
  aStorage.FieldByName('BelowPrc').AsString      := edtBelow.Text;

  // ????
  aStorage.FieldByName('UseEntCntRate').AsBoolean   := cbEntCntRate.Checked  ;
  aStorage.FieldByName('UseEntForeign').AsBoolean   := cbEntForeign.Checked;
  aStorage.FieldByName('UseEntPoint').AsBoolean     := cbEntPoint.Checked;
  

  aStorage.FieldByName('EntCntRate').AsString       := edtEntCntRate.Text;
  aStorage.FieldByName('EntForeignQty').AsString    := edtEntForeignQty.Text ;
  aStorage.FieldByName('EntPoint1').AsString        := edtEntPoint1.Text;
  aStorage.FieldByName('EntPoint2').AsString        := edtEntPoint2.Text;

  // ????
  aStorage.FieldByName('UseLiqCntRate').AsBoolean   := cbLiqCntRate.Checked  ;
  aStorage.FieldByName('UseLiqForeign').AsBoolean   := cbLiqForeign.Checked;
  aStorage.FieldByName('UseLiqPoint').AsBoolean     := cbLiqPoint.Checked;
  aStorage.FieldByName('UseLiqAnd').AsBoolean       := FJarvisData.LiqUseAnd;

  aStorage.FieldByName('LiqCntRate').AsString       := edtLiqCntRate.Text;
  aStorage.FieldByName('LiqForeignRate').AsString   := edtLiqForeignRate.Text ;
  aStorage.FieldByName('LiqPoint').AsString         := edtLiqPoint.Text;

  // ????
  aStorage.FieldByName('StartTime').AsFloat	:= double( dtStartTime.Time );
  aStorage.FieldByName('EndTime').AsFloat	:= double( dtEndTime.Time );

end;

procedure TFrmBHult.SetControls( bEnable : boolean );
begin
  Button6.Enabled   := bEnable;

  if bEnable then
    Panel1.Color  := clBtnFAce
  else begin
    Panel1.Color  := clSkyBlue;
  end;
end;

procedure TFrmBHult.Start;
begin

  if (( FIsFund ) and ( FFund = nil ))  or
     (( not FIsFund ) and ( FAccount = nil )) then
  begin
    ShowMessage('???????? ????????. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FSymbol = nil then
  begin
    ShowMessage('???????? ????????. ');
    cbStart.Checked := false;
    Exit;
  end;

  if FBHultAxis <> nil then
  begin
    GetParam;
    FBHultAxis.JarvisData := FJarvisData;
    FBHultAxis.OnJarvisEvent  := OnJarvisNotify;

    if FIsFund then
      FBHultAxis.init( FFund, FSymbol, Self )
    else
      FBHultAxis.init( FAccount, FSymbol, Self );

    if not FBHultAxis.Start then
    begin
      cbStart.Checked := false;
      Exit;
    end;

    reFreshTimer.Enabled := true;
    SetControls( false );
  end;
end;

procedure TFrmBHult.Stop( bCnl : boolean = true );
begin
  SetControls( true );

  if FBHultAxis <> nil then
  begin
    FBHultAxis.Stop;
    FBHultAxis.OnJarvisEvent  := nil;
  end;
end;

procedure TFrmBHult.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
  //
  if stTxt.Tag = 0 then begin
    StatusBar.Canvas.Brush.Color := clBtnFace;
    StatusBar.Canvas.Font.Color := clBlack;
  end
  else if stTxt.Tag < 0 then begin
    StatusBar.Canvas.Brush.Color := clBlue;
    StatusBar.Canvas.Font.Color := clWhite;
  end
  else if stTxt.Tag > 0 then begin
    StatusBar.Canvas.Brush.Color := clRed;
    StatusBar.Canvas.Font.Color := clWhite;
  end;

  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect(Rect);
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

function TFrmBHult.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top+1, oRect.Right, oRect.Bottom );
end;


procedure TFrmBHult.GroupBox2Click(Sender: TObject);
var
  stCap: string;
begin

  if ( not cbStart.Checked ) and ( FBHultAxis = nil ) then Exit;

  stCap := '????';

  with GroupBox2 do
    case Tag of
      0 :   // and --> or
        begin
          Tag := 1;
          Caption := stCap + ' (Or)';
          FJarvisData.LiqUseAnd := false;
        end;
      1 :  // or --> and
        begin
          Caption := stCap + ' (And)';
          Tag := 0;
          FJarvisData.LiqUseAnd := true;
        end;
    end;

  FBHultAxis.JarvisData := FjarvisData;

end;

procedure TFrmBHult.GroupBox5Click(Sender: TObject);
begin
  {
  if ( not cbStart.Checked ) and ( FBHultAxis = nil ) then Exit;
  stCap := '????';

  with GroupBox5 do
    case Tag of
      0 :   // and --> or
        begin
          Tag := 1;
          Caption := stCap + ' (Or)';
          FJarvisData.EntUseAnd := false;
        end;
      1 :  // or --> and
        begin
          Caption := stCap + ' (And)';
          Tag := 0;
          FJarvisData.EntUseAnd := true;
        end;
    end;

  FBHultAxis.JarvisData := FjarvisData;
  }
end;

procedure TFrmBHult.refreshTimerTimer(Sender: TObject);
var
  dBase, dCur, dNext, dLoss, dGap : double;
  iIdx, iGap  : integer;
  aType : TPositionType;
  ftColor : TColor;
  aQuote  : TQuote;
begin

  if FBHultAxis <> nil then
  begin
    // ?????? ????
    if ( FSymbol <> nil ) and ( FSymbol.Quote <> nil ) then
    begin
      aQuote  := FSymbol.Quote as TQuote;
      stCntRate.Font.Color  := ifThenColor( aQuote.CntRatio > 0 , clRed, clBlue );
      stCntRate.Caption     := Format('%.2f', [ aQuote.CntRatio ] );

      if FBHultAxis.OrdSide <> 0 then
      begin
        if FBHultAxis.OrdSide > 0 then
          dGap  := FBHultAxis.EnterPrice - FSymbol.Last
        else
          dGap  := FSymbol.Last - FBHultAxis.EnterPrice;

        stPoint.Caption := Format('%.2f', [ dGap ] );
      end else
      begin
        stPoint.Font.Color  := clBlack;
        stPoint.Caption := '0';
      end;
    end;

    sgLog.Cells[0,0]  := IntToStr( FBHultAxis.Count );

    stForFutQty.Caption    := Format('%.0f' , [
      FBHultAxis.EnterForFut - ( FBHultAxis.EnterForFut * FBHultAxis.JarvisData.LiqForeignPer )]);
    stForFutQty.Font.Color := ifThenColor( FBHultAxis.ForeignerFut > 0 , clRed, clBlue );

    stTxt.Panels[0].Text  := IntToStr( abs(FBHultAxis.Volume ));
    stTxt.Tag := FBHultAxis.Volume;
    stTxt.Panels[1].Text := Format('%.2f', [ FBHultAxis.EnterPrice ] );
    stTxt.Panels[2].Text := Format('(%d|%d) %.0f, %.0f, %.0f', [ FBHultAxis.OrderCnt[ptLong], FBHultAxis.OrderCnt[ptShort],
           FBHultAxis.NowPL / 1000 ,
           FBHultAxis.MaxPL / 1000,
           FBHultAxis.MinPL / 1000]);

  end;

end;

end.

