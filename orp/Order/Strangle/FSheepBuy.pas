unit FSheepBuy;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, Grids, StdCtrls, ExtCtrls, Buttons,

  CleSymbols, CleQuoteBroker, CleAccounts, ClePositions, CleDistributor,

  CleMarkets, CleQuoteTimers, CleSheepBuySystem,  CleStrategyStore,

  CleStorage,

  GleTypes, GleConsts, CleOrderConsts
  ;

type



  TFrmSheepBuy = class(TForm)
    Panel3: TPanel;
    Panel4: TPanel;
    plStart: TPanel;
    Label4: TLabel;
    Bevel1: TBevel;
    cbAccount: TComboBox;
    stUpPrice: TStaticText;
    stDownPrice: TStaticText;
    Panel2: TPanel;
    rdClear: TRadioButton;
    edtClear: TEdit;
    udClear: TUpDown;
    rdFixClear: TRadioButton;
    edtFixClear: TEdit;
    UpDown4: TUpDown;
    StringGridOptions: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtFutMove: TEdit;
    UpDown3: TUpDown;
    UpDown2: TUpDown;
    edtMaxQty: TEdit;
    edtQty: TEdit;
    UpDown1: TUpDown;
    sgSymbols: TStringGrid;
    sgLog: TStringGrid;
    stbar: TStatusBar;
    cbStart: TCheckBox;
    lblAcntName: TLabel;
    rbUp: TRadioButton;
    rbDown: TRadioButton;
    Panel5: TPanel;
    stFutPrice: TStaticText;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    edtSymbolCnt: TEdit;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StringGridOptionsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure StringGridOptionsMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgSymbolsDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure sgLogDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure cbAccountChange(Sender: TObject);
    procedure sgSymbolsSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure cbStartClick(Sender: TObject);
    procedure rbUpClick(Sender: TObject);
    procedure edtFutMoveChange(Sender: TObject);
    procedure edtFutMoveKeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure rdClearClick(Sender: TObject);
    procedure stbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
  private
    FOptionMarket : TOptionMarket;
    FTimer  : TQuoteTimer;
    FRow    : integer;
    FParam  : TSheepBuyParam;
    procedure initControls;
    procedure SetSymbol(aSymbol : TSymbol);
    procedure refreshOptions;
    procedure OnTimer( Sender  :TObject );
    procedure Start;
    procedure Stop;
    procedure GetParam;
    procedure log;
    function GetRect(oRect: TRect): TRect;
    { Private declarations }
  public
    { Public declarations }

    SheepBuy : TSheepBuySystem;
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

    procedure OnPosEvent(Sender: TObject);
    procedure LogEvent( Values : TStrings; index : integer );
  end;

var
  FrmSheepBuy: TFrmSheepBuy;

implementation

uses
  GAppEnv, GleLib
  ;

{$R *.dfm}

{ TFrmSheepBuy }

procedure TFrmSheepBuy.LoadEnv(aStorage: TStorage);
begin

end;


procedure TFrmSheepBuy.SaveEnv(aStorage: TStorage);
begin

end;

procedure TFrmSheepBuy.OnPosEvent(Sender: TObject);
var
  aPos : TPosition;
  iCol, iRow : integer;
begin
  iRow := -1;
  if aPos.Symbol.ShortCode[1] = '2' then
    iCol := 0;
  if aPos.Symbol.ShortCode[1] = '3' then
    iCol := 2;

  iRow := sgSymbols.Cols[iCol].IndexOfObject( aPos.Symbol);
  if iRow > 0 then
  begin
    sgSymbols.Cells[ iCol+1, iRow ] := IntToStr( aPos.Volume );
    if aPos.Volume > 0 then
      sgSymbols.Objects[iCol+1, iRow] := Pointer( integer( clRed ))
    else if aPos.Volume < 0  then
      sgSymbols.Objects[iCol+1, iRow] := Pointer( integer( clBlue ))
    else
      sgSymbols.Objects[iCol+1, iRow] := nil;
  end;
end;

procedure TFrmSheepBuy.OnTimer(Sender: TObject);
begin
  refreshOptions;

end;

procedure TFrmSheepBuy.Button1Click(Sender: TObject);
begin
  SheepBuy.DoLiquid;
end;

procedure TFrmSheepBuy.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  bRet : boolean;
begin

  if ( cbStart.Checked ) then
  begin
    ShowMessage('진행중에는 종목을 바꿀수 없습니다.');
    Exit;
  end;

  aAccount  := GetComboObject( cbAccount ) as TAccount;

  if aAccount <> nil then
  begin
    SheepBuy.SetAccount( aAccount );
    lblAcntName.Caption := aAccount.Name;
  end;

end;

procedure TFrmSheepBuy.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FTimer.Enabled := false;
  Action := caFree;
end;

procedure TFrmSheepBuy.FormDestroy(Sender: TObject);
begin

  gEnv.Engine.QuoteBroker.Timers.DeleteTimer( FTimer );
  gEnv.Engine.QuoteBroker.Cancel( Self );

  SheepBuy.stop;
  SheepBuy.Free;
end;


procedure TFrmSheepBuy.FormCreate(Sender: TObject);
var
  aColl : TStrategys;
begin
  initControls;

  aColl := gEnv.Engine.TradeCore.StrategyGate.GetStrategys;
  SheepBuy := TSheepBuySystem.Create( aColl, opSheepBuy );
  SheepBuy.init;
  SheepBuy.OnPosEvent := OnPosEvent;
  SheepBuy.OnLogEvent := LogEvent;

  gEnv.Engine.TradeCore.Accounts.GetList2( cbAccount.Items );
  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( nil );
  end;

  FTimer  := gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Interval := 300;
  FTimer.Enabled  := true;
  FTimer.OnTimer  := OnTimer;

end;

procedure TFrmSheepBuy.GetParam;
var
  i, iCnt :integer;
begin
  with FParam do
  begin
    IsUp  := rbUp.Checked;
    Qty   := StrToIntDef( edtQty.Text, 1 );
    MaxQty  := StrToIntDef( edtMaxQty.Text, 10 );
    FutTick := StrToIntDef( edtFutMove.Text, 1 );
    // 청산
    if rdFixClear.Checked then begin
      LiqType := lctMinFixNClear;
      LiqQty  := StrToIntDef( edtFixClear.Text, 1 );
    end
    else begin
      LiqType := lctClearDivN;
      LiqQty  := StrToIntDef( edtClear.Text, 1 );
    end;

    SheepBuySymbols := nil;

    iCnt := 0;
    with sgSymbols do
    begin
      for I := 1 to RowCount - 1 do
        if ( Objects[0, i] <> nil ) and ( Objects[2,i] <> nil ) then
          inc( iCnt );

      SetLength( SheepBuySymbols, iCnt );

      for I := 0 to iCnt - 1 do
      begin
        SheepBuySymbols[i].Call := TOption( Objects[0, i+1] );
        SheepBuySymbols[i].Put := TOption( Objects[2, i+1] );
      end;
    end;
  end;
end;

procedure TFrmSheepBuy.edtFutMoveChange(Sender: TObject);
begin
  with FParam do
  case TEdit( Sender ).Tag of
    0 : Qty :=  StrToIntDef( edtQty.Text, 1 );
    1 : MaxQty  := StrToIntDef( edtMaxQty.Text, 10 );
    2 : FutTick := StrToIntDef( edtFutMove.Text, 1 );
    3 : if rdClear.Checked then LiqQty := StrToIntDef( edtClear.Text, 1 );
    4 : if rdFixClear.Checked then LiqQty  := StrToIntDef( edtFixClear.Text, 1 );
  end;

  SheepBuy.SheepBuys.Param.Assign( FParam, false);
end;



procedure TFrmSheepBuy.initControls;
var
  aTree: TOptionTree;
  i: Integer;
  aStrike: TStrike;
begin
  with sgSymbols do
  begin
    Cells[0,0]  := 'Call';
    Cells[1,0]  := 'Net';
    Cells[2,0]  := 'Put';
    Cells[3,0]  := 'Net';
  end;

  with StringGridOptions do
  begin
    Cells[0,0] := 'Call';
    Cells[1,0] := '행사가';
    Cells[2,0] := 'Put';
  end;

  FRow  := 1;

    // get selected option month
  FOptionMarket := gEnv.Engine.SymbolCore.OptionMarkets.OptionMarkets[0];
  aTree := FOptionMarket.Trees.FrontMonth;

  if aTree = nil then
  begin
    StringGridOptions.RowCount := 1;
    Exit;
  end;
    // set option grid
  StringGridOptions.RowCount := aTree.Strikes.Count + 1;

    //
  for i := 0 to aTree.Strikes.Count - 1 do
  begin
    aStrike := aTree.Strikes[i];
      // strike price
    StringGridOptions.Cells[1, i+1]   := Format('%.2f', [aStrike.StrikePrice]);
    StringGridOptions.Objects[1, i+1] := aStrike;
      // call
    StringGridOptions.Cells[0,i+1] := '';
    if aStrike.Call <> nil then
      StringGridOptions.Objects[0,i+1] := aStrike.Call
    else
      StringGridOptions.Objects[0,i+1] := nil;

      // put
    StringGridOptions.Cells[2,i+1] := '';
    if aStrike.Put <> nil then
      StringGridOptions.Objects[2,i+1] := aStrike.Put
    else
      StringGridOptions.Objects[2,i+1] := nil
  end;
end;



procedure TFrmSheepBuy.rbUpClick(Sender: TObject);
begin
  FParam.IsUp := rbUp.Checked;
  SheepBuy.SheepBuys.Param.Assign( FParam, false);
  log;
end;

procedure TFrmSheepBuy.rdClearClick(Sender: TObject);
begin
  if rdClear.Checked then
    Fparam.LiqType := lctClearDivN
  else
    FParam.LiqType  :=  lctMinFixNClear;
  SheepBuy.SheepBuys.Param.Assign( FParam, false);
end;

procedure TFrmSheepBuy.refreshOptions;
var
  aTree: TOptionTree;
  i: Integer;
  aStrike: TStrike;
begin

  if FOptionMarket = nil then Exit;
    //
  for i := 0 to StringGridOptions.RowCount- 1 do
  begin
    aStrike := TStrike( StringGridOptions.Objects[1,i+1]);
    if aStrike = nil then
      Continue;

    if aStrike.Call <> nil then
      StringGridOptions.Cells[0,i+1] := Format('%.2f', [aStrike.Call.Last])
    else
      StringGridOptions.Cells[0,i+1] :='';
    if aStrike.Put <> nil then
      StringGridOptions.Cells[2,i+1] := Format('%.2f', [aStrike.Put.Last])
    else
      StringGridOptions.Cells[2,i+1] :='';
  end;

  if gEnv.Engine.SymbolCore.Future <> nil then

  stFutPrice.Caption := Format('%.2f', [ gEnv.Engine.SymbolCore.Future.Last ] );

  stbar.Panels[0].Text :=  Format('%.0n', [SheepBuy.TotPL]);
end;


procedure TFrmSheepBuy.SetSymbol(aSymbol: TSymbol);
var
  iCol, iCnt : integer;
begin

  if ( cbStart.Checked ) then
  begin
    ShowMessage('진행중에는 종목을 바꿀수 없습니다.');
    Exit;
  end;

  iCnt := StrToIntDef(edtSymbolCnt.Text, 1 );

  if (aSymbol as TOption).CallPut = 'C' then
    iCol := 0
  else
    iCol := 2;

  with sgSymbols do
  begin
    if ( iCnt < 1 ) or ( iCnt >= RowCount ) then Exit;

    Objects[ iCol, iCnt] := asymbol;
    Cells[ iCol, iCnt ]  := aSymbol.ShortCode;
  end;
end;

procedure TFrmSheepBuy.sgLogDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgColor, ftColor : TColor;
begin

  with sgLog do
  begin
    stTxt := Cells[ ACol, ARow];
    ftColor := clBlack;
    if ARow = 0 then
      bgColor := clBtnFace
    else begin
      bgColor := clWhite;
    end;

    Canvas.Brush.Color := bgColor;
    Canvas.Font.Color  := ftColor;
    Canvas.FillRect( Rect );
    DrawText( Canvas.Handle, PChar(stTxt), Length( stTxt ), Rect, DT_CENTER or DT_VCENTER );
  end;

end;

procedure TFrmSheepBuy.sgSymbolsDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    bgColor, ftColor : TColor;
begin

  with sgSymbols do
  begin
    stTxt := Cells[ ACol, ARow];
    ftColor := clBlack;
    if ARow = 0 then
      bgColor := clBtnFace
    else begin
      bgColor := clWhite;
      if Objects[ACol, ARow] <> nil then
        ftColor := TColor(integer( Objects[ACol, ARow]));

      if ARow = FRow then
        bgColor := EVEN_COLOR;
    end;

    Canvas.Brush.Color := bgColor;
    Canvas.Font.Color  := ftColor;
    Canvas.FillRect( Rect );
    DrawText( Canvas.Handle, PChar(stTxt), Length( stTxt ), Rect, DT_CENTER or DT_VCENTER );
  end;
end;

procedure TFrmSheepBuy.sgSymbolsSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);
begin
  if ARow > 0 then begin
    edtSymbolcnt.Text := IntToStr( ARow );
    FRow := ARow;
    sgSymbols.Repaint;
  end;
end;

procedure TFrmSheepBuy.StringGridOptionsDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  iX, iY : Integer;
  aSize : TSize;
  stText : String;
begin
  with StringGridOptions.Canvas do
  begin
    Font.Name := StringGridOptions.Font.Name;
    Font.Size := StringGridOptions.Font.Size;

    //
    if gdFixed in State then
    begin
      Brush.Color := FIXED_COLOR;
      Font.Color := clBlack;
    end else
    if aCol = 1 then
    begin
      Brush.Color := EVEN_COLOR;
      Font.Color := clBlack;
    end else
    if [gdSelected, gdFocused] <= State then
    begin
      Brush.Color := SELECTED_COLOR;
      Font.Color := clWhite;
    end else
    if StringGridOptions.Cells[aCol, aRow] <> '' then
    begin
      Brush.Color := NODATA_COLOR;
      Font.Color := clBlack;
    end else
    begin
      Brush.Color := NODATA_COLOR;
    end;
      // background
    FillRect(Rect);
      // text
    stText := StringGridOptions.Cells[aCol, aRow];
      //
    if stText <> '' then
    begin
        // calc position
      aSize := TextExtent(stText);
      iY := Rect.Top + (Rect.Bottom - Rect.Top - aSize.cy) div 2;
      iX := Rect.Left + (Rect.Right - Rect.Left - aSize.cx) div 2;
        // put text
      TextRect(Rect, iX, iY, stText);
    end;
  end;

end;

procedure TFrmSheepBuy.StringGridOptionsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iCol, iRow: Integer;
  aOption: TOption;
begin
  StringGridOptions.MouseToCell(X,Y, iCol, iRow);
  if (iCol = -1) or (iRow = -1)
     or (iCol = 1) or (iRow = 0)
     or not (StringGridOptions.Objects[iCol,iRow] is TSymbol) then Exit;


  StringGridOptions.Col := iCol;
  StringGridOptions.Row := iRow;

  aOption := StringGridOptions.Objects[iCol,iRow] as TOption;
  if aOption = nil then Exit;

  SetSymbol(aOption);

end;


procedure TFrmSheepBuy.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop
end;


procedure TFrmSheepBuy.edtFutMoveKeyPress(Sender: TObject; var Key: Char);
begin
 if not (Key in ['1'..'9', #13, #8]) then
     Key := #0;
end;

procedure TFrmSheepBuy.Start;
begin
  plStart.Color := clSkyblue;
  GetParam;
  if not SheepBuy.start( FParam ) then
  begin
    showMessage('시작할수 없음');
    cbStart.Checked := false;
    Stop;
    Exit;
  end;
  SheepBuy.start( FParam );
  log;
end;

function TFrmSheepBuy.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;

procedure TFrmSheepBuy.stbarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  var
    oRect : TRect;
begin
  case Panel.Index of
    0 :
      if SheepBuy.TotPL > 0 then
        stbar.Canvas.Font.Color := clRed
      else if SheepBuy.TotPL < 0 then
        stbar.Canvas.Font.Color := clBlue
      else
        stbar.Canvas.Font.Color := clBlack;
  end;
  stbar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  //stbar.Canvas.TextOut( 0, 0, stBar.Panels[0].Text);
  DrawText( stBar.Canvas.Handle, PChar( stBar.Panels[0].Text ),
    Length( stBar.Panels[0].Text ),
    oRect, DT_VCENTER or DT_RIGHT );
end;

procedure TFrmSheepBuy.Stop;
begin
  plStart.Color := clBtnFace;
  SheepBuy.stop;
end;

procedure TFrmSheepBuy.log;
begin
  if rbUp.Checked then begin
    stUpPrice.Caption   := stFutPrice.Caption;
    stUpPrice.Color     := clRed;
    stUpPrice.Font.Color:= clWhite;
    stDownPrice.Color   := clBtnFace;
    stDownPrice.Font.Color  := clBlack;
    stbar.Panels[1].Text  := format('上 : %s', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime)]);
  end
  else begin
    stDownPrice.Caption := stFutPrice.Caption;
    stUpPrice.Color     := clBtnFace;
    stUpPrice.Font.Color:= clBlack;
    stDownPrice.Color   := clBlue;
    stDownPrice.Font.Color  := clWhite;
    stbar.Panels[2].Text  := format('下 : %s', [ FormatDateTime('hh:nn:ss.zzz', GetQuoteTime)]);
  end;
end;

procedure TFrmSheepBuy.LogEvent(Values: TStrings; index: integer);
var
  I: integer;
begin
  InsertLine( sgLog, 1 );
  with sgLog do
    for I := 0 to index - 1 do
      Cells[i,1]  := Values[i];

  if rbUp.Checked then
    stUpPrice.Caption := Values[2]
  else
    stDownPrice.Caption := Values[2];
end;

end.
