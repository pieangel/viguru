unit FraSSOPT;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, StdCtrls, ExtCtrls, ComCtrls,
  CleSsoptData, CleSymbols, GleTypes;

type
  TFraMain = class(TFrame)
    cbAll: TCheckBox;
    btnSymbol: TButton;
    plCode: TPanel;
    Label1: TLabel;
    edtQty: TEdit;
    udQty: TUpDown;
    btnQty: TButton;
    Label2: TLabel;
    edtSlice: TEdit;
    udSlice: TUpDown;
    btnSlice: TButton;
    GroupBox1: TGroupBox;
    Panel1: TPanel;
    cbBid1limit: TCheckBox;
    cbBid2limit: TCheckBox;
    cbBid3limit: TCheckBox;
    cbBid4limit: TCheckBox;
    cbBid5limit: TCheckBox;
    cbAsk1limit: TCheckBox;
    cbAsk2limit: TCheckBox;
    cbAsk3limit: TCheckBox;
    cbAsk4limit: TCheckBox;
    cbAsk5limit: TCheckBox;
    btnBidCnl: TButton;
    btnAskCnl: TButton;
    GroupBox2: TGroupBox;
    Panel2: TPanel;
    btnAsk345: TButton;
    btnAsk2: TButton;
    btnAsk1: TButton;
    btnBid345: TButton;
    btnBid2: TButton;
    btnBid1: TButton;
    edtAskPre: TEdit;
    upAskPre: TUpDown;
    btnAskPre: TButton;
    btnBidPre: TButton;
    edtBidPre: TEdit;
    udBidPre: TUpDown;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox3: TGroupBox;
    Label5: TLabel;
    edtDelay: TEdit;
    btnDelay: TButton;
    plWinRate2: TPanel;
    plWinRate1: TPanel;
    btnStop: TButton;
    plSymbol1: TPanel;
    plSymbol2: TPanel;
    procedure cbAsk1limitClick(Sender: TObject);
    procedure cbBid1limitClick(Sender: TObject);
    procedure btnQtyClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure edtQtyKeyPress(Sender: TObject; var Key: Char);
    procedure cbAllClick(Sender: TObject);
    procedure btnAsk1Click(Sender: TObject);
    procedure btnBid1Click(Sender: TObject);
    procedure btnAskCnlClick(Sender: TObject);
  private
    { Private declarations }
    FParams : TSsoptParams;
    FSymbol : TSymbol;
    FBidCheck : array[0..4] of TCheckBox;
    FAskCheck : array[0..4] of TCheckBox;
    FOnSymbolCheck : TObjectCheckEvent;
    procedure SetParams;
    function CheckBoxCheck(iIndex : integer; bBid : boolean) : boolean;
  public
    { Public declarations }

    procedure InitParams( iIndex : integer );
    procedure SendPacket(aType : TSSoptType);
    procedure SymbolState(aState : TSymbolState);
    procedure LastState( aState : TLastState );
    property Params : TSsoptParams read FParams;
    property Symbol : TSymbol read FSymbol;
    property OnSymbolCheck : TObjectCheckEvent read FOnSymbolCheck write FOnSymbolCheck;
  end;

implementation

uses
  GAppEnv;

{$R *.dfm}

procedure TFraMain.btnAsk1Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;
  FParams.AdjustLS := 'S';
  FParams.AdjustIndex := iTag;
  SendPacket(sotAdjust);
end;

procedure TFraMain.btnAskCnlClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;

  if iTag = 0 then
    FParams.CnlLS := 'S'
  else
    FParams.CnlLS := 'L';

  SendPacket(sotHogacnl);
end;

procedure TFraMain.btnBid1Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;
  FParams.AdjustLS := 'L';
  FParams.AdjustIndex := iTag;
  SendPacket(sotAdjust);
end;

procedure TFraMain.btnQtyClick(Sender: TObject);
var
  iTag : integer;
  aType : TSSoptType;
begin
  iTag := (Sender as TButton).Tag;
  with FParams do
  begin
    OrderQty := StrToIntDef(edtQty.Text, 10);
    Slice := StrToIntDef(edtSlice.Text, 1);
    AskPre := StrToIntDef(edtAskPre.Text, 10);
    BidPre := StrToIntDef(edtBidPre.Text, 10);
    DelayAfford := StrToIntDef(edtDelay.Text, 300);
  end;

  case iTag of
    0 : aType := sotQty;    // qty
    1 : aType := sotSlice;  //Slice
    2 :
    begin
      aType := sotPre;
      FParams.PreLS := 'S';
    end;                    //AskPre
    3 :
    begin
      aType := sotPre;
      FParams.PreLS := 'L';
    end;                    //BidPre
    4 : aType := sotDelay;  //Delay
  end;

  SendPacket( aType );
end;

procedure TFraMain.btnStopClick(Sender: TObject);
var
  iTag : integer;
begin
  iTag := (Sender as TButton).Tag;

  if iTag = 0 then                //정지상태
  begin
    (Sender as TButton).Tag := 1;
    (Sender as TButton).Caption := '정지';
    btnSymbol.Enabled := false;
    FParams.OnOff := true;
  end else
  begin
    (Sender as TButton).Tag := 0;
    (Sender as TButton).Caption := '시작';
    btnSymbol.Enabled := true;
    FParams.OnOff := false;
  end;

  SendPacket(sotOnOff);
end;

procedure TFraMain.btnSymbolClick(Sender: TObject);
var
  bRet : boolean;
  stLog : string;
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
      if Assigned(OnSymbolCheck) then
        bRet := OnSymbolCheck( gSymbol.Selected );

      if bRet then
      begin
        stLog := Format('Code = %s 동일종목존재', [gSymbol.Selected.ShortCode]);
        ShowMessage(stLog);
        exit;
      end;

      FSymbol := gSymbol.Selected;
      if FSymbol <> nil then
      begin
        FParams.SymbolCode := FSymbol.ShortCode;
        plCode.Caption := FParams.SymbolCode;
        SetParams;
        SendPacket( sotSymbol );
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFraMain.cbAllClick(Sender: TObject);
begin
  FParams.AllCancelClear := cbAll.Checked;
  SendPacket(sotClear);
end;

procedure TFraMain.cbAsk1limitClick(Sender: TObject);
var
  i, iTag : integer;
  aCheck : TCheckBox;
  bRet : boolean;
begin
  aCheck := Sender as TCheckBox;
  iTag := aCheck.Tag;
  FParams.Asklimit[iTag] := aCheck.Checked;

  if FParams.Asklimit[iTag] then
  begin
    for i := iTag-1 downto 0 do
    begin
      FParams.Asklimit[iTag] := true;
      FAskCheck[i].OnClick := nil;
      FAskCheck[i].Checked := true;
      FAskCheck[i].OnClick := cbAsk1limitClick;
    end;
  end else
  begin
    bRet := CheckBoxCheck(iTag, false);
    if not bRet then
    begin
      FParams.Asklimit[iTag] := true;
      FAskCheck[iTag].Checked := true;
      exit;
    end;
  end;

  FParams.LimitLS := 'S';
  FParams.LimitIndex := iTag;
  SendPacket(sotStrict);
end;

procedure TFraMain.cbBid1limitClick(Sender: TObject);
var
  i, iTag : integer;
  aCheck : TCheckBox;
  bRet : boolean;
begin
  aCheck := Sender as TCheckBox;
  iTag := aCheck.Tag;
  FParams.Bidlimit[iTag] := aCheck.Checked;

  if FParams.Bidlimit[iTag] then
  begin
    for i := iTag-1 downto 0 do
    begin
      FParams.Bidlimit[iTag] := true;

      FBidCheck[i].OnClick := nil;
      FBidCheck[i].Checked := true;
      FBidCheck[i].OnClick := cbBid1limitClick;

    end;
  end else
  begin
    bRet := CheckBoxCheck(iTag, true);
    if not bRet then
    begin
      FParams.Bidlimit[iTag] := true;
      FBidCheck[iTag].Checked := true;
      exit;
    end;
  end;
  FParams.LimitLS := 'L';
  FParams.LimitIndex := iTag;
  SendPacket(sotStrict);
end;

function TFraMain.CheckBoxCheck(iIndex: integer; bBid : boolean): boolean;
var
  i : integer;
begin
  Result := true;

  if bBid then
  begin
    for i := iIndex + 1 to 4 do
    begin
      if FParams.Bidlimit[i] then
      begin
        Result := false;
        break;
      end;
    end;
  end else
  begin
    for i := iIndex + 1 to 4 do
    begin
      if FParams.Asklimit[i] then
      begin
        Result := false;
        break;
      end;
    end;
  end;
end;

procedure TFraMain.edtQtyKeyPress(Sender: TObject; var Key: Char);
begin
if not (Key in ['0'..'9',#13, #8]) then
     Key := #0;
end;

procedure TFraMain.InitParams(iIndex: integer);
var
  i : integer;
begin
  with FParams do
  begin
    Index := iIndex;
    AllCancelClear := false;
    SymbolCode := '';
    OrderQty := 10;
    Slice := 1;
    LimitLS := 'L';
    CnlLS   := 'L';
    LimitIndex := 0;
    for i := 0 to 4 do
    begin
      Bidlimit[i] := false;
      Asklimit[i] := false;
    end;
    AdjustLS := 'L';
    AdjustIndex := 0;
    PreLS := 'L';
    AskPre := 10;
    BidPre := 10;
    DelayAfford := 300;
    OnOff := false;
  end;

  FBidCheck[0] := cbBid1limit;
  FBidCheck[1] := cbBid2limit;
  FBidCheck[2] := cbBid3limit;
  FBidCheck[3] := cbBid4limit;
  FBidCheck[4] := cbBid5limit;

  FAskCheck[0] := cbAsk1limit;
  FAskCheck[1] := cbAsk2limit;
  FAskCheck[2] := cbAsk3limit;
  FAskCheck[3] := cbAsk4limit;
  FAskCheck[4] := cbAsk5limit;

  FSymbol := nil;
end;

procedure TFraMain.SendPacket( aType : TSSoptType );
begin
  gEnv.Engine.SsoptBroker.Send(aType, FParams);
end;

procedure TFraMain.SetParams;
begin
  with FParams do
  begin
    edtQty.Text := IntToStr(OrderQty);
    edtSlice.Text := IntToStr(Slice);
    edtAskPre.Text := IntToStr(AskPre);
    edtBidPre.Text := IntToStr(BidPre);
    edtDelay.Text := IntToStr(DelayAfford);
  end;
end;

procedure TFraMain.SymbolState(aState: TSymbolState);
begin
  plWinRate1.Caption := aState.Winrate1[FParams.Index];
  plWinRate2.Caption := aState.Winrate2[FParams.Index];
  plSymbol1.Caption := aState.SymbolState1[FParams.Index];
  plSymbol2.Caption := aState.SymbolState2[FParams.Index];
end;


procedure TFraMain.LastState(aState: TLastState);
var
  aSymbol : TSymbol;
  i : integer;
  stAskCheck, stBidCheck : string;
begin
  with FParams do
  begin
    AllCancelClear := aState.IsAllClear[Index];
    cbAll.OnClick := nil;
    cbAll.Checked := AllCancelClear;
    cbAll.OnClick := cbAllClick;

    SymbolCode := aState.SymbolCode[Index];
    FSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode2(SymbolCode);
    if FSymbol <> nil then
    begin
      plCode.Caption := FSymbol.ShortCode;
      btnSymbol.Enabled := false;
    end;


    OrderQty := StrToIntDef(aState.OrderQty[Index], 10);
    edtQty.Text := IntToStr(OrderQty);

    Slice := StrToIntDef(aState.Slice[Index],1);
    edtSlice.Text := IntToStr(Slice);

    stAskCheck := aState.IsAskHoga[Index];
    stBidCheck := aState.IsBidHoga[Index];

    for i := 0 to 4 do
    begin
      if stBidCheck[i+1] = '1' then
        Bidlimit[i] := true
      else
        Bidlimit[i] := false;

      FBidCheck[i].OnClick := nil;
      FBidCheck[i].Checked := Bidlimit[i];
      FBidCheck[i].OnClick := cbBid1limitClick;

      if stAskCheck[i+1] = '1' then
        Asklimit[i] := true
      else
        Asklimit[i] := false;

      FAskCheck[i].OnClick := nil;
      FAskCheck[i].Checked := Asklimit[i];
      FAskCheck[i].OnClick := cbAsk1limitClick;
    end;


    AskPre := StrToIntDef(aState.AskPre[Index], 10);
    edtAskPre.Text := IntToStr(AskPre);
    BidPre := StrToIntDef(aState.BidPre[Index], 10);
    edtBidPre.Text := IntToStr(BidPre);
    DelayAfford := StrToIntDef(aState.DelayAfford[Index], 300);
    edtDelay.Text := IntToStr(DelayAfford);

    if aState.OnOff[Index] = 0 then
    begin
      btnStop.Tag := 0;
      btnStop.Caption := '시작';
      btnSymbol.Enabled := true;
      OnOff := false
    end else
    begin
      btnStop.Tag := 1;
      btnStop.Caption := '정지';
      btnSymbol.Enabled := false;
      OnOff := true;
    end;
  end;
end;

end.
