unit FleBondTrends;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,

  CleAccounts, CleFunds, CleBondTrends ,

  CleStorage, Grids

  ;

type
  TFrmBondTrends = class(TForm)
    plRun: TPanel;
    cbRun: TCheckBox;
    Button6: TButton;
    edtAccount: TEdit;
    stTxt: TStatusBar;
    cbStgType: TComboBox;
    Panel1: TPanel;
    Label2: TLabel;
    Label4: TLabel;
    Label3: TLabel;
    dtEnd: TDateTimePicker;
    dtEntend: TDateTimePicker;
    dtStart2: TDateTimePicker;
    dtStart: TDateTimePicker;
    GroupBox2: TGroupBox;
    edtOrdQty: TLabeledEdit;
    edtE_C: TLabeledEdit;
    edtE_S: TLabeledEdit;
    edtEC: TLabeledEdit;
    edtE_S2: TLabeledEdit;
    cbLeftCon: TComboBox;
    cbRightCon: TComboBox;
    GroupBox3: TGroupBox;
    cbTrailingStop: TCheckBox;
    edtStopMax: TLabeledEdit;
    edtStopPer: TLabeledEdit;
    edtLiskAmt: TLabeledEdit;
    cbEndLiq: TCheckBox;
    Button2: TButton;
    Timer1: TTimer;
    Panel2: TPanel;
    sg: TStringGrid;
    cbUseFillter: TCheckBox;
    procedure edtE_SKeyPress(Sender: TObject; var Key: Char);
    procedure edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cbStgTypeChange(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbRunClick(Sender: TObject);
    procedure stTxtDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure cbEndLiqClick(Sender: TObject);
    procedure cbTrailingStopClick(Sender: TObject);
    procedure cbUseFillterClick(Sender: TObject);
  private
    { Private declarations }
    FIsFund : boolean;
    FFund   : TFund;
    FAccount: TAccount;
    FParam: TBondTrendParam;
    FBondSg: TBondTrends;
    FAutoStart : boolean;

    procedure initControls;
    procedure GetParam;
    procedure OnTextNotifyEvent(Sender: TObject; Value: String);
    function GetRect(oRect: TRect): TRect;
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure Start;
    procedure Stop;

    property Param  : TBondTrendParam read FParam write FParam;
    property BondSg : TBondTrends read FBondSg;
  end;

var
  FrmBondTrends: TFrmBondTrends;

implementation

uses
  GAppEnv, GleLib,
  CleQuoteTimers
  ;

{$R *.dfm}

procedure TFrmBondTrends.Button1Click(Sender: TObject);
begin
  FBondSg.testorder;
end;

procedure TFrmBondTrends.Button2Click(Sender: TObject);
begin
  if ( FBondSg <> nil ) and ( cbRun.Checked ) then
  begin
    GetParam;
    FBondSg.Param := FParam;
  end;
end;

procedure TFrmBondTrends.Button6Click(Sender: TObject);
begin
  if cbRun.Checked then begin
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

procedure TFrmBondTrends.cbEndLiqClick(Sender: TObject);
begin
  if ( cbRun.Checked ) and ( FBondSg <> nil ) then
  begin
    FParam.UseEndLiq  := cbEndLiq.Checked;
    FBondSg.Param := FParam;
  end;
end;

procedure TFrmBondTrends.cbRunClick(Sender: TObject);
begin
  if cbRun.Checked then
    Start
  else
    Stop;
end;

procedure TFrmBondTrends.cbStgTypeChange(Sender: TObject);
begin
  case cbStgType.ItemIndex of
   0 :
     begin
          dtStart2.Visible  := true;
          label2.Caption    := '????';

          dtStart.Time    := EncodeTime( 09,01,0,0);
          dtEnd.Time      := EncodeTime( 15,32,0,0);

          dtStart2.Time   := EncodeTime( 10,30,0,0);
          dtEntEnd.Time   := EncodeTime( 14,30,0,0);

          edtStopMax.Text := '60';

          edtE_C.Text := '0.8';
          cbLeftCon.ItemIndex := 1;
          cbRightCon.ItemIndex:= 0;
     end;
   1 :
     begin
          label2.Caption    := '????';
          dtStart.Time    := EncodeTime( 09,30,0,0);
          dtEnd.Time      := EncodeTime( 15,32,0,0);
          dtStart2.Visible:= false;
          dtEntEnd.Time   := EncodeTime( 14,30,0,0);

          edtStopMax.Text := '50';

          edtE_C.Text := '0.77';
          cbLeftCon.ItemIndex := 1;
          cbRightCon.ItemIndex:= 1;
     end;
  end; 
end;

procedure TFrmBondTrends.cbTrailingStopClick(Sender: TObject);
begin
  if ( cbRun.Checked ) and ( FBondSg <> nil ) then
  begin
    FParam.UseTrailingStop  := cbTrailingStop.Checked;
    FBondSg.Param := FParam;
  end;
end;

procedure TFrmBondTrends.cbUseFillterClick(Sender: TObject);
begin
  if ( cbRun.Checked ) and ( FBondSg <> nil ) then
  begin
    FParam.UseFillter  := cbUseFillter.Checked;
    FBondSg.Param := FParam;
  end;
end;

procedure TFrmBondTrends.edtE_SKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', '.', #8, #13]) then
    Key := #0;
end;

procedure TFrmBondTrends.edtOrdQtyKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9', #8, #13]) then
    Key := #0;
end;

procedure TFrmBondTrends.FormActivate(Sender: TObject);
begin
  if (gEnv.RunMode = rtSimulation) and ( not FAutoStart ) then
  begin
    if (FAccount <> nil )  then
      if not cbRun.Checked then
       cbRun.Checked := true;
    FAutoStart := true;
  end;
end;

procedure TFrmBondTrends.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  action := caFree;
end;

procedure TFrmBondTrends.FormCreate(Sender: TObject);
begin
  initControls;

  FAccount := nil;
  FFund    := nil;
  FIsFund  := false;

  FBondSg := TBondTrends.Create( Self );
  FBondSg.OnNotify  := OnTextNotifyEvent;
end;

procedure TFrmBondTrends.FormDestroy(Sender: TObject);
begin
  //
  FBondSg.Free;
end;

procedure TFrmBondTrends.GetParam;
begin

  with FParam do
  begin
    OrdQty      := StrToIntDef( edtOrdQty.Text, 1 );
    EntryCnt    := StrtoIntDef( edtEC.Text, 2 );

    E_C := StrToFloatDef( edtE_C.Text, 0.8 );
    E_S := StrToFloatDef( edtE_S.Text, 0.66 );
    E_S2:= StrToFloatDef( edtE_S2.Text, 0.7 );
    LiskAmt := StrToFloatDef( edtLiskAmt.Text, 16 );

    UseFillter      := cbUseFillter.Checked;
    UseTrailingStop  := cbTrailingStop.Checked;
    StopMax := StrToIntDef( edtStopMax.Text, 50);
    StopPer := StrToIntDef( edtStopPer.Text, 30);
    UseEndLiq  := cbEndLiq.Checked;

    StartTime   := Frac( dtStart.Time );
    Start2Time  := Frac( dtStart2.Time );
    Endtime     := Frac( dtEnd.Time );
    EntEndtime  := Frac( dtEntend.Time );

    StgType     := cbStgType.ItemIndex;
    LeftCon     := cbLeftCon.ItemIndex;
    RightCon    := cbRightcon.ItemIndex;
  end;

end;

procedure TFrmBondTrends.initControls;
begin
  with sg do
  begin
    Cells[0,0]  := '????';
    Cells[1,0]  := '????';
  end;

end;

procedure TFrmBondTrends.LoadEnv(aStorage: TStorage);
var
  I: integer;
  stCode : string;
  aFund  : TFund;
  aAcnt  : TAccount;
begin
  if aStorage = nil then Exit;

  with aStorage do
  begin
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

    cbStgType.ItemIndex := FieldByName('StgType').AsInteger;
    if cbStgType.ItemIndex < 0 then
      cbStgType.ItemIndex := 0;

    cbStgTypeChange( cbStgType );

    dtEnd.Time    := FieldByName('EndTime').AsTimeDef( dtEnd.Time );
    dtStart.Time  := FieldByName('StartTime').AsTimeDef( dtStart.Time );

    dtEntEnd.Time  := FieldByName('EntEndTime').AsTimeDef( dtEntEnd.Time );
    dtStart2.Time  := FieldByName('Start2Time').AsTimeDef( dtStart2.Time );

    edtEC.Text      := FieldByName('OrdEc').AsStringDef('2');
    edtOrdQty.Text  := FieldByName('OrdQty').AsStringDef('1');
    edtE_C.Text     := FieldByName('E_C').AsStringDef( edtE_C.Text );
    edtE_S.Text     := FieldByName('E_S').AsStringDef( edtE_S.Text );
    edtE_S2.Text    := FieldByName('E_S2').AsStringDef( edtE_S2.Text );

    cbLeftCon.ItemIndex := FieldByName('LeftCon').AsIntegerDef(0);
    cbRightCon.ItemIndex := FieldByName('RightCon').AsIntegerDef(0);

    edtStopMax.Text := FieldByName('StopMax').AsStringDef( edtStopMax.Text );
    edtStopPer.Text := FieldByName('StopPer').AsStringDef( edtStopPer.Text );

    cbTrailingStop.Checked  := FieldByName('UseTrailingStop').AsBooleanDef( true );
    cbEndLiq.Checked        := FieldByName('UseEndLiq').AsBooleanDef(true) ;
    cbUseFillter.Checked    := FieldByName('UseFillter').AsBooleanDef(true) ;
  end;
end;

procedure TFrmBondTrends.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  with aStorage do
  begin

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

    FieldByName('StgType').AsInteger  := cbStgType.ItemIndex;

    FieldByName('EndTime').AsFloat    := double( dtEnd.Time );
    FieldByName('StartTime').AsFloat  := double( dtStart.Time );

    FieldByName('EntEndTime').AsFloat := double( dtEntEnd.Time );
    FieldByName('Start2Time').AsFloat := double( dtStart2.Time );

    FieldByName('OrdEc').AsString := edtEC.Text;
    FieldByName('OrdQty').AsString:= edtOrdQty.Text;
    FieldByName('E_C').AsString   := edtE_C.Text;
    FieldByName('E_S').AsString   := edtE_S.Text;
    FieldByName('E_S2').AsString  := edtE_S2.Text;

    FieldByName('LeftCon').AsInteger  := cbLeftCon.ItemIndex;
    FieldByName('RightCon').AsInteger := cbRightCon.ItemIndex;

    FieldByName('StopMax').AsString   := edtStopMax.Text ;
    FieldByName('StopPer').AsString   := edtStopPer.Text ;

    FieldByName('UseTrailingStop').AsBoolean  := cbTrailingStop.Checked;
    FieldByName('UseEndLiq').AsBoolean        := cbEndLiq.Checked;
    FieldByName('UseFillter').AsBoolean       := cbUseFillter.Checked;

  end;
end;

procedure TFrmBondTrends.OnTextNotifyEvent(Sender: TObject; Value: String);
begin
  if Sender <> FBondSg then Exit;
  InsertLine( sg, 1 );
  //sg.Cells[0,1] := FormatDateTime('hh:nn:ss.zz', now );
  sg.Cells[0,1] := FormatDateTime('hh:nn:ss.zz', GetQuoteTime );
  sg.Cells[1,1] := Value;
end;

procedure TFrmBondTrends.Start;
begin
  if FIsFund then
  begin
    if ( FFund = nil ) then
    begin
      ShowMessage(' ?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FBondSg.Param := FParam;
    FBondSg.init( FFund, Self );
  end else
  begin
    if ( FAccount = nil ) then
    begin
      ShowMessage('?????? ??????????');
      cbRun.Checked := false;
      Exit;
    end;
    GetParam;
    FBondSg.Param := FParam;
    FBondSg.init( FAccount, Self );
  end;

  if not FBondSg.Start then
  begin
    ShowMessage('???????? ????..');
    cbRun.Checked := false;
    Exit;
  end;
  plRun.Color := clYellow;
end;

procedure TFrmBondTrends.Stop;
begin
  FBondSg.Stop;
  plRun.Color := clBtnFace;
end;

function TFrmBondTrends.GetRect( oRect : TRect ) : TRect ;
begin
  Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
end;
procedure TFrmBondTrends.stTxtDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
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

procedure TFrmBondTrends.Timer1Timer(Sender: TObject);
begin
  //
  try
    if ( FBondSg <> nil ) then
    begin
      stTxt.Panels[2].Text  := Format('%d.th %.0f, %.0f, %.0f', [
        FBondSg.OrderCnt, FBondSg.NowPL, FBondSg.MaxPL, FBondSg.MinPL ]);
      stTxt.Panels[0].Text  := IntToStr( FBondSg.Volume );
      stTxt.Tag := FBondSg.Volume;
    end;

    stTxt.Panels[1].Text  := Format('%.2f, %.2f',  [gEnv.Engine.SymbolCore.Bond10Future.CntRatio,
      gEnv.Engine.SymbolCore.Bond10Future.VolRatio   ]);
  except
  end;
end;

end.
