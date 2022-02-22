unit FleEvolBHult;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Grids, ExtCtrls,

  CleAccounts, ClePositions, CleSymbols, CleOrders, CleQuoteBroker,

  CleEvolBHult, CleEvolBHultData,

  CleStorage, CleIni
  ;
const
  TitleCnt2 = 6;
  Title2 : array [0..TitleCnt2-1] of string = ( '시각','종목','구분',
                                              'LS','수량','평균가' );


type
  TFrmEvolBHult = class(TForm)
    Panel1      : TPanel;
    cbAccount   : TComboBox;
    cbStart     : TCheckBox;
    stBar       : TStatusBar;
    Panel2      : TPanel;
    dtStartTime : TDateTimePicker;
    dtEndTime   : TDateTimePicker;
    sgCon: TStringGrid;
    Button1: TButton;
    Button2: TButton;
    edtRowCnt: TEdit;
    udRowCnt: TUpDown;
    edtEntryCnt: TEdit;
    udEntryCnt: TUpDown;
    cbAccount2: TComboBox;
    Panel3: TPanel;
    sgOrd: TStringGrid;
    Timer1: TTimer;
    edtSymbol: TEdit;
    Button3: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure cbAccount2Change(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure edtRowCntKeyPress(Sender: TObject; var Key: Char);
    procedure edtRowCntChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FBAccount: TAccount;
    FAccount: TAccount;
    FSymbol: TSymbol;
    FBPosition: TPosition;
    FPosition: TPosition;
    FEvolData: TEvolBHultData;
    FEvolBHult: TEvolBHult;
    procedure LoadConfig;
    procedure GetParam;

    { Private declarations }
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure initControls;

    property Account : TAccount read FAccount;
    property BAccount: TAccount read FBAccount;
    property Symbol  : TSymbol  read FSymbol;
    property BPosition: TPosition read FBPosition;
    property Position: TPosition read FPosition;

    property EvolData : TEvolBHultData read FEvolData write FEvolData;
    property EvolBHult :TEvolBHult read FEvolBHult;
  end;

var
  FrmEvolBHult: TFrmEvolBHult;

implementation

uses
  GAppEnv, GleLib, GleConsts
  ;

{$R *.dfm}

procedure TFrmEvolBHult.Button1Click(Sender: TObject);
var
  stName : string;
begin
  stName := ExtractFilePath( paramstr(0) )+ 'env\' + BHULT_ENV;
  ShowNotePad( Handle, stName );
end;

procedure TFrmEvolBHult.Button2Click(Sender: TObject);
begin
  //
  LoadConfig;
  Getparam;
end;

procedure TFrmEvolBHult.Button3Click(Sender: TObject);
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open then
    begin
      FSymbol := gSymbol.Selected;
      edtSymbol.Text  := FSymbol.ShortCode;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmEvolBHult.cbAccount2Change(Sender: TObject);
var
  aAccount : TAccount;
begin
  aAccount  := GetComboObject( cbAccount2 ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FBAccount = aAccount) then Exit;

  FBAccount := aAccount;
end;

procedure TFrmEvolBHult.cbAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;
end;

procedure TFrmEvolBHult.cbStartClick(Sender: TObject);
begin
  if ( FAccount = nil ) or  ( FBAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin

    FEvolBHult.init( FAccount, FBAccount, FSymbol );
    {
    FEvolBHult.OnTrendNotify  := OnTrendNotify;
    FEvolBHult.OnTrendOrderEvent  := OnTrendOrderEvent;
    FEvolBHult.OnTrendResultNotify:= OnTrendResultNotify;
    }
    GetParam;
    FEvolBHult.Start;

  end
  else begin
     {
    FEvolBHult.OnTrendNotify  := nil;
    FEvolBHult.OnTrendOrderEvent  := nil;
    FEvolBHult.OnTrendResultNotify:= nil;
    }
    FEvolBHult.Stop;

  end;
end;

procedure TFrmEvolBHult.edtRowCntChange(Sender: TObject);
var
  iTag : integer;
begin
  // entry tag is 0
  iTag := (Sender as TEdit ).Tag;
  case iTag of
    0 : FEvolData.EntryCnt  := StrToIntDef( edtEntryCnt.Text, 2 )  ;
    1 : FEvolData.RowCnt    := StrToIntDef( edtRowCnt.Text, 4 )  ;
  end;

  if FEvolBHult <> nil then
    FEVolBHult.EvolData := FEvolData; 

end;

procedure TFrmEvolBHult.edtRowCntKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8]) then
    Key := #0;
end;

procedure TFrmEvolBHult.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmEvolBHult.FormCreate(Sender: TObject);
begin
  //
  initControls;

  FEvolData.DefCnt  := 5;

  FEvolBHult:= TEvolBHult.Create;

  FBAccount := nil;
  FAccount  := nil;
  FSymbol   := nil;
  FBPosition:= nil;
  FPosition := nil;

  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount.Items );
  gEnv.Engine.TradeCore.Accounts.GetList( cbAccount2.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( cbAccount );
  end;

  if cbAccount2.Items.Count > 0 then
  begin
    cbAccount2.ItemIndex := 0;
    cbAccountChange( cbAccount2 );
  end;
end;

procedure TFrmEvolBHult.FormDestroy(Sender: TObject);
begin
  //
  FEvolBHult.stop;
  FEvolBHult.Free;
end;

procedure TFrmEvolBHult.GetParam;
var
  I: integer;
begin
  with FEvolData, sgCon do
  begin
    EntryCnt  := StrToIntDef( edtEntryCnt.Text, 2 );
    RowCnt    := StrToIntDef( edtRowCnt.Text, 4 );

    StartTime := dtStartTime.Time;
    EndTime   := dtEndTime.Time;

    FEvolData.init;

    for I := 0 to RowCnt - 1 do
    begin
      EntryItem[i].Volume   := StrToIntDef( Cells[ 0, i+1] , 3 * (i + 1) ) ;
      EntryItem[i].AvgPrice := StrToFloat( Cells[ 1, i+1] );
      EntryItem[i].Qty      := StrToIntDef( Cells[ 2, i+1], 1 );
      EntryItem[i].Run      := Cells[3,i+1] = 'O';
    end;
  end;

  if FEVolBHult <> nil then  
    FEvolBHult.EvolData := FEvolData;
end;

procedure TFrmEvolBHult.initControls;
var
  i : integer;
begin

  with sgCon do
  begin
    //
    Cells[0,0]  := '잔고';
    Cells[1,0]  := '평균가';
    Cells[2,0]  := '수량';
    Cells[3,0]  := 'Run';
  end;

  with sgOrd do
    for I := 0 to TitleCnt2 - 1 do
      Cells[i,0]  := Title2[i];
end;


procedure TFrmEvolBHult.LoadConfig;
var
  ini : TInitFile;
  iCount, iPos, i : integer;
  stTmp : string;
begin
  ini := nil;
  try
    ini := TInitFile.Create( BHULT_ENV );
    iCount:= ini.GetInteger('CONFIG', 'COUNT');
    with sgCon do
      for i := 0 to iCount - 1 do
      begin
        Cells[0, i+1] := ini.GetString('CONFIG_'+IntToStr(i), 'VOL' );
        Cells[1, i+1] := ini.GetString('CONFIG_'+IntToStr(i), 'AVG' );
        Cells[2, i+1] := ini.GetString('CONFIG_'+IntToStr(i), 'QTY' );
        Cells[3, i+1] := ifThenStr( ini.GetString('CONFIG_'+IntToStr(i), 'RUN' ) = '1' ,
          'O','X');
      end;
  finally
    ini.Free;
  end;
end;


procedure TFrmEvolBHult.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  if FBAccount <> nil then
    aStorage.FieldByName('BAccountCode').AsString := FBAccount.Code
  else
    aStorage.FieldByName('BAccountCode').AsString := '';

  if FSymbol <> nil then
    aStorage.FieldByName('SymbolCode').AsString := FSymbol.Code
  else
    aStorage.FieldByName('SymbolCode').AsString := '';

  aStorage.FieldByName('StartTime').AsFloat := double( dtStartTime.Time );
  aStorage.FieldByName('EndTime').AsFloat := double( dtEndTime.Time );

  aStorage.FieldByName('EntryCnt').AsString := edtEntryCnt.Text;
  aStorage.FieldByName('RowCnt').AsString   := edtRowCnt.Text;


end;

procedure TFrmEvolBHult.LoadEnv(aStorage: TStorage);
var
  aAcnt : TAccount;
  aSymbol : TSymbol;
begin
  if aStorage = nil then Exit;

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('AccountCode').AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    cbAccountChange(cbAccount);
  end;

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('BAccountCode').AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount2, aAcnt );
    cbAccount2Change(cbAccount2);
  end;

  aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode( aStorage.FieldByName('SymbolCode').AsString );
  if aSymbol <> nil then
  begin
    FSymbol := aSymbol;
    edtSymbol.Text  := FSymbol.ShortCode;
  end;

  dtStartTime.Time  := TDateTime( aStorage.FieldByName('StartTime').AsFloat );
  dtEndTime.Time    := TDateTime( aStorage.FieldByName('EndTime').AsFloat );

  udEntryCnt.Position := StrToIntDef( aStorage.FieldByName('EntryCnt').AsString, 2 );
  udRowCnt.Position   := StrToIntDef( aStorage.FieldByName('RowCnt').AsString, 4);

  LoadConfig;

end;

procedure TFrmEvolBHult.Timer1Timer(Sender: TObject);
begin
  //
  if ( FBAccount = nil ) or (FAccount = nil ) or ( FSymbol = nil ) then Exit;

  if FPosition = nil then
    FPosition := gEnv.Engine.TradeCore.Positions.Find( FAccount, FSymbol );

  if FBPosition = nil then
    FBPosition := gEnv.Engine.TradeCore.Positions.Find( FBAccount, FSymbol );

  if (FPosition = nil) or (FBPosition = nil ) then Exit;

  stBar.Panels[0].Text  := Format('Net:%d, %.3f', [ FPosition.Volume, FPosition.AvgPrice ] );
  stBar.Panels[1].Text  := Format('Net:%d, %.3f', [ FBPosition.Volume, FBPosition.AvgPrice ] );
  stBar.Panels[2].Text  := Format('%.3f', [ FPosition.AvgPrice - FBPosition.AvgPrice ] );

end;

end.
