unit DProtectedStop;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleStorage,
  CleProtectedStop, CleSymbols, ComCtrls, StdCtrls, Buttons, ExtCtrls, Grids
  ;

type
  TProtectStopOrder = class(TForm)
    Panel1: TPanel;
    BtnCohesionSymbol: TSpeedButton;
    cbSymbol: TComboBox;
    ComboAccount: TComboBox;
    ButtonAuto: TSpeedButton;
    GroupBox1: TGroupBox;
    rdExecConDeposit: TRadioButton;
    rdExecConSame: TRadioButton;
    rdExecConCur: TRadioButton;
    edtExecConDeposit: TEdit;
    edtExecConSame: TEdit;
    edtExecConCur: TEdit;
    GroupBox2: TGroupBox;
    rdClear: TRadioButton;
    rdFixClear: TRadioButton;
    edtClear: TEdit;
    edtFixClear: TEdit;
    GroupBox3: TGroupBox;
    rdDeposit: TRadioButton;
    rdSame: TRadioButton;
    udTick: TUpDown;
    edtTick: TEdit;
    udClear: TUpDown;
    GroupBox4: TGroupBox;
    Label1: TLabel;
    edtAutoCnt: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    edtAutoSec: TEdit;
    Label4: TLabel;
    cbAuto: TCheckBox;
    Label5: TLabel;
    sgLog: TStringGrid;
    plSide: TPanel;
    btnShow: TSpeedButton;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure edtExecConDepositChange(Sender: TObject);
    procedure edtExecConDepositKeyPress(Sender: TObject; var Key: Char);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure rdExecConDepositClick(Sender: TObject);
    procedure cbAutoClick(Sender: TObject);
    procedure ButtonAutoClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure rdClearClick(Sender: TObject);
    procedure rdSameClick(Sender: TObject);
    procedure ComboAccountChange(Sender: TObject);
    procedure sgLogDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure btnShowClick(Sender: TObject);
  private

    FAccount  : TAccount;
    FStopOrder: TProtectedStop;
    FHi : integer;
    SaveHi: integer;
    procedure SetEdtAble(btn: array of boolean);
    procedure SetEdtAble2(btn: array of boolean);
    procedure SetEdtAble3(btn: array of boolean);
    procedure initControls;
    { Private declarations }
  public
    { Public declarations }
    Param : TProtectedStopParams;
    property StopOrder  : TProtectedStop read FStopOrder;
    procedure UpdateConfig;
    procedure SetConfig;
    procedure Stop;
    procedure Start;

    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);

  end;

var
  ProtectStopOrder: TProtectStopOrder;

implementation

uses
  GAppEnv, GleLib, CleFQN, GleTypes;

{$R *.dfm}

procedure TProtectStopOrder.BtnCohesionSymbolClick(Sender: TObject);
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

procedure TProtectStopOrder.ButtonAutoClick(Sender: TObject);
begin
  if ButtonAuto.Down then
  begin
    Start;
  end
  else begin
    Stop;
  end;
end;

procedure TProtectStopOrder.cbAutoClick(Sender: TObject);
begin
  edtAutoCnt.Enabled  := cbAuto.Checked;
  edtAutoSec.Enabled  := cbAuto.Checked;
  //udAutoSec.Enabled   := cbAuto.Checked;

  stop;
end;

procedure TProtectStopOrder.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
  bRet : boolean;
begin
  if cbSymbol.ItemIndex = -1 then Exit;
  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;

  bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck
   (aSymbol, FStopOrder.Symbol, FStopOrder.Account, FStopOrder.Account, self, rdtProtected);

  if not bRet then
  begin
    cbSymbol.ItemIndex := -1;
    gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(aSymbol, FStopOrder.Account, rdtProtected);
    aSymbol := nil;
  end;

  FStopOrder.Symbol := aSymbol;
  stop;
end;

procedure TProtectStopOrder.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  bRet : boolean;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;

  if aAccount <> nil then
  begin
    if FStopOrder.Symbol <> nil then
    begin
      bRet := gEnv.Engine.FormBroker.RedundancyChecks.RedundancyCheck
              (FStopOrder.Symbol, FStopOrder.Symbol, aAccount, FStopOrder.Account, self, rdtProtected);

      if not bRet then
      begin
        ComboAccount.ItemIndex := -1;
        gEnv.Engine.FormBroker.RedundancyChecks.AlramBox(FStopOrder.Symbol, aAccount, rdtProtected);
        aAccount := nil;
      end;
    end;

    FStopOrder.Account  := aAccount;
    stop;
  end;

end;

procedure TProtectStopOrder.edtExecConDepositChange(Sender: TObject);
begin
  //
  stop;
end;

procedure TProtectStopOrder.edtExecConDepositKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13, '.', #8]) then
    Key := #0;
end;

procedure TProtectStopOrder.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin    
  Action := caFree;
end;

procedure TProtectStopOrder.FormCreate(Sender: TObject);
var
  aMarkets : TMarketTypes;
begin
  FHi   := GetSystemMetrics( SM_CYCAPTION ) ;
  SaveHi  := Height;
  FStopOrder:= TProtectedStop.Create( self );

  FAccount  := nil;
  gEnv.Engine.TradeCore.Accounts.GetList( ComboAccount.Items );

  aMarkets := [ mtFutures, mtOption ];
  gEnv.Engine.SymbolCore.SymbolCache.GetLists2( cbSymbol.Items, aMarkets );

  rdExecConDepositClick( rdExecConDeposit );
  rdClearClick( rdClear );
  rdSameClick( rdDeposit );
  cbAutoClick( cbAuto );

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;

  initControls;

end;


procedure TProtectStopOrder.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.FormBroker.RedundancyChecks.Del(FStopOrder.Symbol, FStopOrder.Account, self, rdtProtected);
  FStopOrder.Free;
end;


procedure TProtectStopOrder.initControls;
begin
  with sgLog do
  begin
    Cells[0,0]  := 'Time';
    Cells[1,0]  := 'Contents';
    {
    Cells[2,0]  := '단가';
    Cells[3,0]  := '조건';
    Cells[4,0]  := '가격';
    Cells[5,0]  := '수량';
    Cells[6,0]  := '자동정정';
    //
    Cells[0,1]  := 'L상대';
    Cells[0,2]  := 'S상대';
    Cells[0,3]  := 'L당측';
    Cells[0,4]  := 'S당측';
    Cells[0,5]  := 'L현재가';
    Cells[0,6]  := 'S현재가';
    }
    //
    ColWidths[0] := 60;
    ColWidths[1] := Width - ColWidths[0];
    //Colwidths[5] := 72;
  end;


end;

procedure TProtectStopOrder.SetEdtAble( btn : array of boolean );
begin
  edtExecConDeposit.Enabled := btn[0];
  edtExecConSame.Enabled    := btn[1];
  edtExecConCur.Enabled     := btn[2];
end;



procedure TProtectStopOrder.Start;
begin
  UpdateConfig;
  FStopOrder.ProtecteParam  := Param;
  FStopOrder.Run;

  if not FStopOrder.Start then
    Stop
  else begin
    ButtonAuto.Caption  := 'Start';
    Color := clMoneyGreen;
  end;
end;

procedure TProtectStopOrder.Stop;
begin
  if FStopOrder = nil then
    Exit;
  FStopOrder.Stop;
  ButtonAuto.Down := false;
  ButtonAuto.Caption  := 'Stop';
  Color := clbtnFace;

end;

procedure TProtectStopOrder.SetEdtAble2(btn: array of boolean);
begin
  edtTick.Enabled := btn[1];
  udTick.Enabled  := btn[1];
end;

procedure TProtectStopOrder.SetEdtAble3(btn: array of boolean);
begin
  edtClear.Enabled  := btn[0];
  udClear.Enabled   := btn[0];
  edtFixClear.Enabled := btn[1];
end;

procedure TProtectStopOrder.sgLogDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    aBack : TColor;
    bGray : boolean;
    stTxt : string;
begin
  with sgLog do
  begin
    stTxt := Cells[ACol, ARow];
    if ARow = 0 then
      aBack := clBtnFace
    else begin
      if integer( Objects[0, ARow] ) = 100 then
        aBack := clSkyBlue
      else
        aBack := clWhite;
    end;

    Canvas.Font.Color := clBlack;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect );
    Canvas.TextRect( Rect, Rect.Left + 2, Rect.Top + 1, stTxt );
  end;
end;

procedure TProtectStopOrder.rdClearClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..1] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;
  btn[0]  := false;
  btn[1]  := false;
  btn[iTag] := true;
  SetEdtAble3(btn);
  stop;
end;

procedure TProtectStopOrder.rdSameClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..1] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;
  btn[0]  := false;
  btn[1]  := false;
  btn[iTag] := true;
  SetEdtAble2(btn);
  stop;
end;

procedure TProtectStopOrder.rdExecConDepositClick(Sender: TObject);
var
  iTag  : integer;
  btn   : array [0..2] of boolean;
begin
  iTag  := TRadioButton( Sender ).Tag;

  btn[0]  := false;
  btn[1]  := false;
  btn[2]  := false;

  btn[iTag] := true;
  SetEdtAble( btn );
  stop;
end;             

procedure TProtectStopOrder.UpdateConfig;
begin
  //
  with Param do
  begin
    if rdExecConDeposit.Checked then
      ExecCondition := ecDeposit
    else if rdExecConSame.Checked then
      ExecCondition := ecSameSide
    else if rdExecConCur.Checked then
      ExecCondition := ecCurrent;

    ecDepositVal  := StrTofloatDef( edtExecConDeposit.Text, 0 );
    ecSameSideVal := StrTofloatDef( edtExecConSame.Text, 0 );
    ecCurrentVal  := StrTofloatDef( edtExecConCur.Text, 0 );

    if rdClear.Checked then
      OrderQtyCondition := ocClearDivN
    else if rdFixClear.Checked then
      OrderQtyCondition := ocMinFixNClear;

    ClearQtyDivN   := StrToIntDef( edtClear.Text, 1 );
    FixedOrderQTy  := StrToIntDef( edtFixClear.Text, 1 );

    if rdDeposit.Checked then
      OrderPrice  := opDeposit
    else if rdSame.Checked then
      OrderPrice  := opSameSide;
    TickQty := strTointDef( edtTick.Text, 0 );


    OnAutoModify  := cbAuto.Checked;
    AutoModifyCnt := StrToIntDef( edtAutoCnt.Text, 1 );
    AutoModifySec := StrToIntDef( edtAutoSec.Text, 1 );
  end;

end;

procedure TProtectStopOrder.SetConfig;
begin
  with Param do
  begin

    edtExecConDeposit.Text  :=  FloatToStr( ecDepositVal );
    edtExecConSame.Text :=  FloatToStr( ecSameSideVal );
    edtExecConCur.Text  := FloatToStr( ecCurrentVal );
    case ExecCondition of
      ecDeposit:  rdExecConDeposit.Checked := true;
      ecSameSide: rdExecConSame.Checked := true;
      ecCurrent:  rdExecConCur.Checked := true;
    end;

    udClear.Position  := ClearQtyDivN;
    edtFixClear.Text  := IntToStr( FixedOrderQTy );
    case OrderQtyCondition of
      ocMinFixNClear: rdFixClear.Checked := true;
      ocClearDivN:  rdClear.Checked := true;
    end;

    udTick.Position := TickQty;
    case OrderPrice of
      opDeposit:  rdDeposit.Checked := true;
      opSameSide: rdSame.Checked  := true;
    end;

    edtAutoCnt.Text := IntToStr( AutoModifyCnt );
    edtAutoSec.Text := IntToStr( AutoModifySec );
    cbAuto.Checked  := OnAutoModify;
  end;

end;


procedure TProtectStopOrder.LoadEnv(aStorage: TStorage);
var
  bShow : boolean;
begin
  if aStorage = nil then Exit;

  with Param do
  begin

    ExecCondition := TStopExecCondition( aStorage.FieldByName('ExecCondition').AsInteger );
    ecDepositVal  := aStorage.FieldByName('ecDepositVal').AsFloat;
    ecSameSideVal := aStorage.FieldByName('ecSameSideVal').AsFloat;
    ecCurrentVal  := aStorage.FieldByName('ecCurrentVal').AsFloat;

    OrderQtyCondition := TStopQtyCondition( aStorage.FieldByName('OrderQtyCondition').AsInteger );
    ClearQtyDivN  := aStorage.FieldByName('ClearQtyDivN').AsInteger;
    FixedOrderQTy := aStorage.FieldByName('FixedOrderQTy').AsInteger;

    OrderPrice  := TStopOrderPrice( aStorage.FieldByName('OrderPrice').AsInteger );
    TickQty :=  aStorage.FieldByName('TickQty').AsInteger;

    OnAutoModify  := aStorage.FieldByName('OnAutoModify').AsBoolean;
    AutoModifyCnt := aStorage.FieldByName('AutoModifyCnt').AsInteger;
    AutoModifySec := aStorage.FieldByName('AutoModifySec').AsInteger;

    // false 가 보여주는것
    bShow   := aStorage.FieldByName('ShowConfig').AsBoolean;

    // bNow
    if bShow then
    begin
      btnShow.Down := true;
      btnShow.Click;
    end;
    
  end;

  SetConfig;
end;


procedure TProtectStopOrder.SaveEnv(aStorage: TStorage);
begin

  UpdateConfig;

  if aStorage = nil then Exit;

  with Param do
  begin
    aStorage.FieldByName('ExecCondition').AsInteger  := Integer( ExecCondition );
    aStorage.FieldByName('ecDepositVal').AsFloat  := ecDepositVal;
    aStorage.FieldByName('ecSameSideVal').AsFloat  := ecSameSideVal;
    aStorage.FieldByName('ecCurrentVal').AsFloat  := ecCurrentVal;


    aStorage.FieldByName('OrderQtyCondition').AsInteger  := Integer( OrderQtyCondition );
    aStorage.FieldByName('ClearQtyDivN').AsInteger   := ClearQtyDivN;
    aStorage.FieldByName('FixedOrderQTy').AsInteger   := FixedOrderQTy;

    aStorage.FieldByName('OrderPrice').AsInteger  := Integer( OrderPrice );
    aStorage.FieldByName('TickQty').AsInteger  := TickQty ;

    aStorage.FieldByName('OnAutoModify').AsBoolean  := OnAutoModify;
    aStorage.FieldByName('AutoModifyCnt').AsInteger  := AutoModifyCnt ;
    aStorage.FieldByName('AutoModifySec').AsInteger  := AutoModifySec ;
    aStorage.FieldByName('ShowConfig').AsBoolean  := btnShow.Down;
  end;

end;

procedure TProtectStopOrder.btnShowClick(Sender: TObject);
begin

  if btnShow.Down then
  begin
    SaveHi  := Height;
    Height  := FHi + Panel1.Height + 10;
    btnShow.Caption  :=  '▲'
  end
  else begin
    Height  := SaveHi;
    btnShow.Caption  :=  '▼';
  end;
end;

end.
