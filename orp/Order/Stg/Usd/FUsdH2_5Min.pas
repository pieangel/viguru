unit FUsdH2_5Min;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, ComCtrls, ExtCtrls, StdCtrls, CleFunds,

  CleSymbols, CleAccounts ,  CleStorage ,CleUsdH2_5Min, CleUsdH2_5Min_Fund, CleUsdParam
  ;

type
  TFrmUsH2 = class(TForm)
    plRun: TPanel;
    Button1: TButton;
    edtSymbol: TLabeledEdit;
    cbRun: TCheckBox;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    dtStart: TDateTimePicker;
    dtEnd: TDateTimePicker;
    Label1: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    dtLiqEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    dtEntStart: TDateTimePicker;
    Label3: TLabel;
    Label5: TLabel;
    dtLiqStart: TDateTimePicker;
    Label7: TLabel;
    edtBongStart: TLabeledEdit;
    edtBongEnd: TLabeledEdit;
    GroupBox2: TGroupBox;
    edtOrdQty: TLabeledEdit;
    edtE1: TLabeledEdit;
    edtE2: TLabeledEdit;
    edtR1: TLabeledEdit;
    edtL2: TLabeledEdit;
    edtL1: TLabeledEdit;
    Button2: TButton;
    Timer1: TTimer;
    Button3: TButton;
    sgLog: TStringGrid;
    sg: TStringGrid;
    stTxt: TStatusBar;
    Label8: TLabel;
    Button6: TButton;
    edtAccount: TEdit;
    cbStopLiq: TCheckBox;
    cbEntFilter: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    
    procedure Button1Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure edtBongStartKeyPress(Sender: TObject; var Key: Char);
    procedure edtE1KeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure Button6Click(Sender: TObject);
    procedure cbStopLiqClick(Sender: TObject);
    procedure cbEntFilterClick(Sender: TObject);
  private
    { Private declarations }
    FFuture, FSymbol : TSymbol;
    FAccount: TAccount;
    FFund   : TFund;
    FParam  : TUsdH2_5Min_Param;
    FUsdH2  : TUsdH2_5Min_Trend;
    FUsdH2_F  : TUsdH2_5Min_Trend_Fund;
    FIsFund   : boolean;
    procedure Start;
    procedure Stop;
    procedure GetParam;
    procedure SetControls(bEnable: boolean);
    function GetRect(oRect: TRect): TRect;
    procedure SetParamData( bCalc : boolean = false );
  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmUsH2: TFrmUsH2;

implementation

uses
  GAppEnv , GleLib , Math,

  CleQuoteBroker , ClePositions
  ;

{$R *.dfm}

procedure TFrmUsH2.Button1Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbRun.Checked then
        begin
          ShowMessage('?????????? ?????? ?????? ????');
        end
        else begin
          FSymbol := gSymbol.Selected;
          edtSymbol.Text  := FSymbol.ShortCode;
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmUsH2.SetParamData( bCalc : boolean );
begin
  if ( cbRun.Checked ) then
    if ( FIsFund ) and ( FUsdH2_F <> nil ) then begin
      FUsdH2_F.Param := FParam;
      if bCalc then
        FUsdH2_F.CalcRange;
    end
    else if ( not FIsFund ) and ( FUsdH2 <> nil ) then begin
      FUsdH2.Param := FParam;
      if bCalc then
        FUsdH2.CalcRange;
    end;
end;

procedure TFrmUsH2.Button2Click(Sender: TObject);
begin
  with FParam do
  begin
    OrdQty    := StrToIntDef( edtOrdQty.Text, 1 );
    E_1       := StrToFloatDef( edtE1.Text, 3.3);
    E_2       := StrToFloatDef( edtE2.Text, 0.7);
    R_1       := StrToFloatDef( edtR1.Text, 0.8);
    L_1       := StrToFloatDef( edtL1.Text, 0.0055);
    L_2       := StrToFloatDef( edtL2.Text, 0.0055);
    UseStopLiq:= cbStopLiq.Checked;
    UseEntFillter := cbEntFilter.Checked;
  end;
  SetParamData( true );
end;

procedure TFrmUsH2.Button3Click(Sender: TObject);
begin

  with FParam do
  begin
    StartTime   := Frac( dtStart.Time );
    Endtime     := Frac( dtEnd.Time );
    EntTime     := Frac( dtEntStart.Time );
    EntEndtime  := Frac( dtEntEnd.Time );
    LiqStTime   := Frac( dtLiqStart.Time );
    LiqEndTime  := Frac( dtLiqEnd.Time );
    BongStart := StrToIntDef( edtBongStart.Text, 6 );
    BongEnd   := StrToIntDef( edtBongEnd.Text, 60 );
  end;
  SetParamData;

end;

procedure TFrmUsH2.Button6Click(Sender: TObject);
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

procedure TFrmUsH2.cbEntFilterClick(Sender: TObject);
begin
  FParam.UseEntFillter  := cbEntFilter.Checked;

  if ( cbRun.Checked ) and ( FUsdH2 <> nil ) then
    FUsdH2.Param := FParam;
  if ( cbRun.Checked ) and ( FUsdH2_F <> nil ) then
    FUsdH2_F.Param := FParam;
end;

procedure TFrmUsH2.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    start
  else
    stop;
end;

procedure TFrmUsH2.cbStopLiqClick(Sender: TObject);
begin
  FParam.UseStopLiq := cbStopLiq.Checked;

  if ( cbRun.Checked ) and ( FUsdH2 <> nil ) then
    FUsdH2.Param := FParam;
  if ( cbRun.Checked ) and ( FUsdH2_F <> nil ) then
    FUsdH2_F.Param := FParam;
end;

procedure TFrmUsH2.edtBongStartKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0
end;

procedure TFrmUsH2.edtE1KeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0
end;

procedure TFrmUsH2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmUsH2.FormCreate(Sender: TObject);
begin
  //
  FAccount := nil;
  FSymbol  := nil;
  FFuture  := nil;
  FFund    := nil;
  FIsFund  := false;
  FUsdH2  := TUsdH2_5Min_Trend.Create( Self );
  FUsdH2_F  := TUsdH2_5Min_Trend_Fund.Create( Self );

  FFuture := gEnv.Engine.SymbolCore.Future;

  with sg do
  begin
    Cells[0,0] := '????????';
    Cells[1,0] := '????????';
    Cells[2,0] := '??????';
    Cells[3,0] := '??????,??Cnt';

    Cells[0,1] := '??????';
    Cells[1,1] := '?? ??-??';
    Cells[2,1] := '??????*L1';
    Cells[3,1] := '?? ??-??';
  end;
end;

procedure TFrmUsH2.FormDestroy(Sender: TObject);
begin
  FUsdH2.Free;
  FUsdH2_F.Free;
end;

procedure TFrmUsH2.GetParam;
begin
  Button2Click(nil);
  Button3Click(nil)
end;

procedure TFrmUsH2.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aAcnt  : TAccount;
  aFund  : TFund;
  aSymbol: TSymbol;
begin

  if aStorage = nil then Exit;

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

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

  dtStart.Time      := TDateTime(aStorage.FieldByName('StartTime').AsTimeDef( dtStart.Time )  );
  dtEnd.Time        := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEnd.Time ) );
  dtEntStart.Time   := TDateTime(aStorage.FieldByName('EntStartTime').AsTimeDef( dtEntStart.Time ));
  dtEntEnd.Time     := TDateTime(aStorage.FieldByName('EntEndTime').AsTimeDef( dtEntend.Time ));
  dtLiqStart.Time := TDateTime(aStorage.FieldByName('LiqStartTime').AsTimeDef( dtLiqStart.Time));
  dtLiqEnd.Time   := TDateTime(aStorage.FieldByName('LiqEndTime').AsTimeDef( dtLiqEnd.Time ));
  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBoolean;
  cbEntFilter.Checked := aStorage.FieldByName('UseEntFilter').AsBooleanDef( true );

  edtOrdQty.Text    := aStorage.FieldByName('OrdQty').AsStringDef('1')  ;
  edtE1.Text        := aStorage.FieldByName('E1').AsStringDef('3.3') ;
  edtE2.Text        := aStorage.FieldByName('E2').AsStringDef('0.7') ;
  edtR1.Text        := aStorage.FieldByName('R1').AsStringDef('0.8') ;
  edtL1.Text        := aStorage.FieldByName('L1').AsStringDef('0.0015') ;
  edtL2.Text        := aStorage.FieldByName('L2').AsStringDef('0.0015') ;
end;

procedure TFrmUsH2.SaveEnv(aStorage: TStorage);
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

  if FSymbol <> nil then
    aStorage.FieldByName('Symbolcode').AsString     := FSymbol.Code
  else
    aStorage.FieldByName('Symbolcode').AsString    := '';

  aStorage.FieldByName('StartTime').AsFloat       := double( dtStart.Time );
  aStorage.FieldByName('EndTime').AsFloat         := double( dtEnd.Time );
  aStorage.FieldByName('EntStartTime').AsFloat    := double( dtEntStart.Time );
  aStorage.FieldByName('EntEndTime').AsFloat      := double( dtEntEnd.Time );
  aStorage.FieldByName('LiqStartTime').AsFloat  := double( dtLiqStart.Time );
  aStorage.FieldByName('LiqEndTime').AsFloat    := double( dtLiqEnd.Time );
  aStorage.FieldByName('UseStopLiq').AsBoolean  := cbStopLiq.Checked;
  aStorage.FieldByName('UseEntFilter').AsBoolean:= cbEntFilter.Checked;

  aStorage.FieldByName('OrdQty').AsString    := edtOrdQty.Text;
  aStorage.FieldByName('E1').AsString := edtE1.Text;
  aStorage.FieldByName('E2').AsString := edtE2.Text;
  aStorage.FieldByName('R1').AsString := edtR1.Text;
  aStorage.FieldByName('L1').AsString := edtL1.Text;
  aStorage.FieldByName('L2').AsString := edtL2.Text;
end;

procedure TFrmUsH2.Start;
begin

  if FIsFund  then
  begin
    if ( FSymbol = nil ) or ( FFund = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    if FUsdH2_F <> nil then
    begin
      GetParam;
      FUsdH2_F.init( FFund, FFuture, FSymbol );
      FUsdH2_F.Start;
      plRun.Color := clLime;
      Timer1.Enabled  := true;
      SetControls( false );
    end;
  end else
  begin
    if ( FSymbol = nil ) or ( FAccount = nil ) then
    begin
      ShowMessage('???????? ????????. ');
      cbRun.Checked := false;
      Exit;
    end;

    if FUsdH2 <> nil then
    begin
      GetParam;
      FUsdH2.init( FAccount, FFuture, FSymbol );
      FUsdH2.Start;
      plRun.Color := clLime;
      Timer1.Enabled  := true;
      SetControls( false );
    end;
  end;
end;

procedure TFrmUsH2.SetControls( bEnable : boolean );
begin
  Button6.Enabled := bEnable;
  Button1.Enabled   := bEnable;
end;

procedure TFrmUsH2.Stop;
begin

  if FIsFund then
  begin
    if FUsdH2_F <> nil then
    begin
      FUsdH2_F.Stop;
      plRun.Color := clBtnFace;
      SetControls( true );
    end;
  end else
  begin
    if FUsdH2 <> nil then
    begin
      FUsdH2.Stop;
      plRun.Color := clBtnFace;
      SetControls( true );
    end;
  end;
end;

procedure TFrmUsH2.stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
  const Rect: TRect);
  var
    oRect : TRect;
begin
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
  oRect := GetRect( Rect );
  DrawText( stTxt.Canvas.Handle, PChar( stTxt.Panels[0].Text ),
    Length( stTxt.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
end;

function TFrmUsH2.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmUsH2.Timer1Timer(Sender: TObject);
var
  aQuote : TQuote;
  iAskCnt, iBidCnt : integer;
  dVal, d1, d2 : double;
  aPos : TPosition;
begin

  if FIsFund then
  begin

    if (FUsdH2_F <> nil) and ( FSymbol <> nil ) and ( FFuture <> nil ) then
      with sgLog do
      begin
        Cells[0,0] := Format('%.2f', [ FUsdH2_F.EntryBuy ]);
        Cells[1,0] := Format('%.2f', [ FUsdH2_F.EntrySell]);
        Cells[2,0] := Format('%.2f', [ FUsdH2_F.EntryPrice]);
        Cells[3,0] := Format('%d(%d)', [ FUsdH2_F.EntBongIdx,  FUsdH2_F.BongCnt]);

        if FFuture.Quote = nil then Exit;
        aQuote  := FFuture.Quote as TQuote;

        iAskCnt := aQuote.Asks.CntTotal;
        iBidCnt := aQuote.Bids.CntTotal;

        if ( iAskCnt = 0 ) or ( iBidCnt = 0 ) then
          dVal := 0.0
        else begin
          d1  := iAskCnt / iBidCnt;
          d2  := iBidCnt / iAskCnt;
          dVal:= min( d1, d2 );
        end;

        if iAskCnt > iBidCnt then
          Cells[0,1]   := Format( '%.2f', [ -dVal ] )
        else
          Cells[0,1]   := Format( '%.2f', [ dVal ] );

        Cells[1,1]   := Format( '%.2f', [ FFuture.Last - FFuture.DayOpen ] );
        Cells[2,1] := Format('%.2f', [ FUsdH2_F.EntryPrice * FParam.L_1 ]);
        Cells[3,1]   := Format( '%.2f', [ FSymbol.Last - FSymbol.DayOpen ] );

        if ( FUsdH2_F.Position <> nil ) then
        begin
          stTxt.Panels[0].Text  := IntToStr( FUsdH2_F.Position.Volume );
          stTxt.Tag := FUsdH2_F.Position.Volume;
          if FFuture <> nil then
            stTxt.Panels[1].Text := Format('%.2f', [ FFuture.CntRatio ] );

          stTxt.Panels[2].Text  := Format('(%d th.) %.0f,  %.0f', [ FUsdH2_F.OrderCnt,
            FUsdH2_F.Position.EntryOTE/1000,
            FUsdH2_F.Position.LastPL / 1000 ]);
        end;
      end;

  end
  else begin
    if (FUsdH2 <> nil) and ( FSymbol <> nil ) and ( FFuture <> nil ) then
      with sgLog do
      begin
        Cells[0,0] := Format('%.2f', [ FUsdH2.EntryBuy ]);
        Cells[1,0] := Format('%.2f', [ FUsdH2.EntrySell]);
        Cells[2,0] := Format('%.2f', [ FUsdH2.EntryPrice]);
        Cells[3,0] := Format('%d(%d)', [ FUsdH2.EntBongIdx,  FUsdH2.BongCnt]);

        if FFuture.Quote = nil then Exit;
        aQuote  := FFuture.Quote as TQuote;

        iAskCnt := aQuote.Asks.CntTotal;
        iBidCnt := aQuote.Bids.CntTotal;

        if ( iAskCnt = 0 ) or ( iBidCnt = 0 ) then
          dVal := 0.0
        else begin
          d1  := iAskCnt / iBidCnt;
          d2  := iBidCnt / iAskCnt;
          dVal:= min( d1, d2 );
        end;

        if iAskCnt > iBidCnt then
          Cells[0,1]   := Format( '%.2f', [ -dVal ] )
        else
          Cells[0,1]   := Format( '%.2f', [ dVal ] );

        Cells[1,1]   := Format( '%.2f', [ FFuture.Last - FFuture.DayOpen ] );
        Cells[2,1] := Format('%.2f', [ FUsdH2.EntryPrice * FParam.L_1 ]);
        Cells[3,1]   := Format( '%.2f', [ FSymbol.Last - FSymbol.DayOpen ] );

        if ( FUsdH2.Position <> nil ) then
        begin
          stTxt.Panels[0].Text  := IntToStr( FUsdH2.Position.Volume );
          stTxt.Tag := FUsdH2.Position.Volume;
          if FFuture <> nil then
            stTxt.Panels[1].Text := Format('%.2f', [ FFuture.CntRatio ] );

          stTxt.Panels[2].Text  := Format('(%d th.) %.0f,  %.0f', [ FUsdH2.OrderCnt,
            FUsdH2.Position.EntryOTE/1000,
            FUsdH2.Position.LastPL / 1000 ]);
        end;
      end;

  end;
end;

end.
