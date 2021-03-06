unit FJikJinHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleSymbols, CleAccounts, CleFunds,

  ClePositions, CleQuoteTimers, CleQuoteBroker, CleKrxSymbols,

  CleStorage, UPaveConfig , GleTypes, ComCtrls, StdCtrls, ExtCtrls, Grids  ,

  CleJikJinHult

  ;

type
  TFrmJikJinHult = class(TForm)
    Panel1: TPanel;
    cbStart: TCheckBox;
    edtSymbol: TLabeledEdit;
    Button3: TButton;
    edtAccount: TEdit;
    Button7: TButton;
    stTxt: TStatusBar;
    Panel2: TPanel;
    gbUseHul: TGroupBox;
    Label6: TLabel;
    dtEndTime: TDateTimePicker;
    dtStartTime: TDateTimePicker;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label2: TLabel;
    Label5: TLabel;
    Label1: TLabel;
    edtQty: TEdit;
    edtIntervalTick: TEdit;
    edtNumber: TEdit;
    cbStopLiq: TCheckBox;
    GroupBox2: TGroupBox;
    edtCntRatio: TEdit;
    edtVolRatio: TEdit;
    cbDefTick: TCheckBox;
    cbCntRatio: TCheckBox;
    cbVolRatio: TCheckBox;
    edtDefTick: TEdit;
    GroupBox3: TGroupBox;
    Label3: TLabel;
    Label4: TLabel;
    Label7: TLabel;
    edtLossAmt: TEdit;
    edtPlusAmt: TEdit;
    sgLog: TStringGrid;
    Timer1: TTimer;
    lbCurPL: TLabel;
    cbOpenPrc: TCheckBox;
    Label8: TLabel;
    stTxt2: TStatusBar;
    procedure Button7Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure edtVolRatioKeyPress(Sender: TObject; var Key: Char);
    procedure Timer1Timer(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sgLogDblClick(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
  private
    { Private declarations }
    FIsFund : boolean;
    FFund   : TFund;
    FParam  : TJikJinHultData;

    FAccount    : TAccount;
    FSymbol     : TSymbol;

    FJikJin : TJikJinHult;

    FMax, FMin : double;

    procedure initControls;
    procedure GetParam;

    procedure OnTextNotify( Sender : TObject; stData : string );
    procedure SetControls(bEnable: boolean);
    function GetRect(oRect: TRect): TRect;
  public
    { Public declarations }
    procedure Stop( bCnl : boolean = true );
    procedure Start;
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmJikJinHult: TFrmJikJinHult;

implementation

uses
  GAppEnv, GleLib, math,
  CleFQN;

{$R *.dfm}

{ TFrmJikJinHult }

procedure TFrmJikJinHult.Button2Click(Sender: TObject);
begin
  if ( FJikJin <> nil ) and (  cbStart.Checked ) then
  begin
    GetParam;
    FjikJin.Param := FParam;
  end;
end;

procedure TFrmJikJinHult.Button3Click(Sender: TObject);
begin
  if gSymbol = nil then
    gEnv.CreateSymbolSelect;
  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin

        if cbStart.Checked then
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

procedure TFrmJikJinHult.Button7Click(Sender: TObject);
begin
  if cbStart.Checked then begin
    ShowMessage('?????????? ?????? ????');
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

procedure TFrmJikJinHult.cbStartClick(Sender: TObject);
begin
  if cbStart.Checked then
    Start
  else
    Stop( false );
end;

procedure TFrmJikJinHult.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmJikJinHult.edtVolRatioKeyPress(Sender: TObject; var Key: Char);
begin
  // ????. ??????, ??????????
  if not (Key in ['0'..'9','.',#8]) then
    Key := #0;
end;

procedure TFrmJikJinHult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmJikJinHult.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount := nil;
  FFund    := nil;
  FIsFund  := false;

  FJikJin := TJikJinHult.Create( Self );
  //FJikJin.OnNotify  := OnTextNotify;
end;

procedure TFrmJikJinHult.FormDestroy(Sender: TObject);
begin
  Timer1.Enabled := false;
  FJikJin.Free;
end;

procedure TFrmJikJinHult.GetParam;
begin

  with FParam do
  begin
    StartTime   := dtStartTime.Time;
    EndTime     := dtEndTime.Time;

    OrdQty  := StrToIntDef( edtQty.Text, 1 );
    OrdGap  := StrToIntDef( edtIntervalTick.Text, 5 );
    LiqNum  := StrToIntDef( edtNumber.Text, 5 );

    UseCntRatio := cbCntRatio.Checked;
    UseVolRatio := cbVolRatio.Checked;
    UseDefTick  := cbDefTick.Checked;
    UseOpenPrc := cbOpenPrc.Checked;

    UseStopLiq  := cbStopLiq.Checked;

    CntRatio := StrToFloatDef( edtCntRatio.Text , 0.65 );
    VolRatio := StrToFloatDef( edtVolRatio.Text , 0.65 );
    DefTick  := StrToIntDef( edtDefTick.Text , 5 );

    RiskAmt := StrToFloatDef( edtLossAmt.Text , 100 );
    PlusAmt := StrToFloatDef( edtPlusAmt.Text , 100 );
  end

end;

procedure TFrmJikJinHult.initControls;
begin
  sgLog.Cells[0,0] :='time';
  sgLog.Cells[1,0] :='????';

end;

procedure TFrmJikJinHult.LoadEnv(aStorage: TStorage);
var
  stCode, stTime : string;
  dtTime : TDateTime;
  aSymbol: TSymbol;

  aFund  : TFund;
  aAcnt  : TAccount;
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

  stCode  := aStorage.FieldByName('SymbolCode').AsString ;
  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( stCode );

  if aSymbol <> nil  then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  dtStartTime.Time  := TDateTime(aStorage.FieldByName('StartTime').AsTimeDef(dtStartTime.Time) );
  dtEndTime.Time    := TDateTime(aStorage.FieldByName('EndTime').AsTimeDef( dtEndTime.Time ) );

  cbStopLiq.Checked := aStorage.FieldByName('UseStopLiq').AsBooleanDef( true );

  edtQty.Text         := aStorage.FieldByName('OrderQty').AsStringDef('1');
  edtIntervalTick.Text:= aStorage.FieldByName('IntervalTick').AsStringDef('5');
  edtNumber.Text      := aStorage.FieldByName('Number').AsStringDef('4');

  cbCntRatio.Checked  := aStorage.FieldByName('UseCntRatio').AsBooleanDef(cbCntRatio.Checked);
  cbVolRatio.Checked  := aStorage.FieldByName('UseVolRatio').AsBooleanDef(cbVolRatio.Checked);
  cbDefTick.Checked   := aStorage.FieldByName('UseDefTick').AsBooleanDef(cbDefTick.Checked);
  cbOpenPrc.Checked   := aStorage.FieldByName('UseOpenPrc').AsBooleanDef(true);

  edtCntRatio.Text  := aStorage.FieldByName('CntRatio').AsStringDef('0.65');
  edtVolRatio.Text  := aStorage.FieldByName('VolRatio').AsStringDef('0.65');
  edtDefTick.Text   := aStorage.FieldByName('DefTick').AsStringDef('5');

  edtPlusAmt.Text   := aStorage.FieldByName('PlusAmt').AsStringDef('200');
  edtLossAmt.Text   := aStorage.FieldByName('LossAmt').AsStringDef('200');


end;

procedure TFrmJikJinHult.OnTextNotify(Sender: TObject; stData: string);
begin
  InsertLine( sgLog, 1 );
  sgLog.Cells[0, 1] := FormatDateTime('hh:nn:ss', GetQuoteTime );
  sgLog.Cells[1, 1] := stData;
end;

procedure TFrmJikJinHult.SaveEnv(aStorage: TStorage);
var
  stCode, stTime : string;
begin

  if aStorage = nil then Exit;
  // Main
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

  // ????
  aStorage.FieldByName('StartTime').AsFloat	:= double( dtStartTime.Time );
  aStorage.FieldByName('EndTime').AsFloat	:= double( dtEndTime.Time );

  // ????
  aStorage.FieldByName('OrderQty').AsString := edtQty.Text;
  aStorage.FieldByName('UseStopLiq').AsBoolean := cbStopLiq.Checked;

  aStorage.FieldByName('OrderQty').AsString     := edtQty.Text ;
  aStorage.FieldByName('IntervalTick').AsString := edtIntervalTick.Text;
  aStorage.FieldByName('Number').AsString       := edtNumber.Text;

  aStorage.FieldByName('UseCntRatio').AsBoolean := cbCntRatio.Checked;
  aStorage.FieldByName('UseVolRatio').AsBoolean := cbVolRatio.Checked;
  aStorage.FieldByName('UseDefTick').AsBoolean  := cbDefTick.Checked;
  aStorage.FieldByName('UseOpenPrc').AsBoolean  := cbOpenPrc.Checked;

  aStorage.FieldByName('CntRatio').AsString := edtCntRatio.Text;
  aStorage.FieldByName('VolRatio').AsString := edtVolRatio.Text;
  aStorage.FieldByName('DefTick').AsString  := edtDefTick.Text;

  aStorage.FieldByName('PlusAmt').AsString  := edtPlusAmt.Text;
  aStorage.FieldByName('LossAmt').AsString  := edtLossAmt.Text;

end;

procedure TFrmJikJinHult.Start;
var
  bRes : boolean;
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

  bRes := false;

  if FJikJin <> nil then
  begin
    GetParam;

    FJikJin.Param := FParam;
    FJikJin.OnNotify  := OnTextNotify;

    if FIsFund then
      bRes  := FJikJin.init( FFund, FSymbol )
    else
      bRes := FJikJin.init( FAccount, FSymbol );

    if (not FJikJin.Start) or ( not bRes ) then
    begin
      cbStart.Checked := false;
      Exit;
    end;

    Timer1.Enabled := true;
    // ?????? ???? ??????..???????? false
    SetControls( false );
  end;
end;

procedure TFrmJikJinHult.Stop(bCnl: boolean);
begin
  FJikJin.Stop;
  SetControls( true );
end;

function TFrmJikJinHult.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top+1, oRect.Right, oRect.Bottom );
end;

procedure TFrmJikJinHult.stTxtDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
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

procedure TFrmJikJinHult.SetControls( bEnable : boolean );
begin
  //Timer1.Enabled := not bEnable;
  Button3.Enabled := bEnable;
  Button7.Enabled := bEnable;
  if bEnable then
    Panel1.Color  := clBtnFace
  else
    Panel1.Color  := clYellow;
end;

procedure TFrmJikJinHult.sgLogDblClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 1 to sgLog.RowCount - 1 do
    sgLog.Rows[i].Clear;

  sgLog.RowCount := 2;
end;

procedure TFrmJikJinHult.Timer1Timer(Sender: TObject);
var
  dPL : double;
begin
  //
  if FJikJin <> nil then
  begin

    stTxt.Panels[0].Text  := IntToStr( FJikJin.GetPosition );
    stTxt.Tag := FJikJin.GetPosition;

    if FSymbol <> nil then
      stTxt.Panels[1].Text := Format('%.2f, %.2f', [ FSymbol.CntRatio, FSymbol.VolRatio ] )
    else
      stTxt.Panels[1].Text := '';

    stTxt2.Panels[0].Text :=  Format('%d, B: %.2f,  N: %.2f,  L: %.2f', [ FJikJin.JJItem.Count,
       FJikJin.JJItem.BasePrice, FJikJin.JJItem.HitPrice, FJikJin.JJItem.LossPrice ] );

    //lbCurPL.Caption := Format('%.0f', [ FJikJin.GetPL]);

    {
    sgLog.Cells[1,0] := Format('B:%.2f, %.2f | %.2f', [FJikJin.JJItem.BasePrice,
      FJikJin.JJItem.StartPrice[ptLong],FJikJin.JJItem.StartPrice[ptShort] ] );
    }

    dPL  := FJikJin.GetPL ;

    FMin := Min( FMin, dPL );
    FMax := Max( FMax, dPL );

    stTxt.Panels[2].Text := Format('%.0f, %.0f, %.0f', [ dPL , FMax, FMin]);
  end;

 // if not cbStart.Checked then
 //   Timer1.Enabled := false;
end;

end.
