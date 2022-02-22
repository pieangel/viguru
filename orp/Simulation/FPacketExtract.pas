unit FPacketExtract;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,

  CleAccounts, CleSymbols, CleOrders, CleQuoteBroker, CleQuoteTimers, CleDistributor,

  UMemoryMapIO, NextGenKospiPacket, GleTypes, GleLib, CleFQN,  GAppConsts,

  StdCtrls, Grids, ExtCtrls, Buttons

  ;

const

  DataIdx = 5;

type

  TGridItem = class( TCollectionItem )
  public
    OrderNo : string;
    FillNo  : string;
    LS      : string;
    Price   : double;
    Qty     : integer;
    FillTime: string;
    FillTime2: string;
    Find  : boolean;
  end;


  TFrmPacketExt = class(TForm)
    Panel1: TPanel;
    sgData: TStringGrid;
    ComboAccount: TComboBox;
    BtnCohesionSymbol: TSpeedButton;
    cbSymbol: TComboBox;
    procedure ComboAccountChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure BtnCohesionSymbolClick(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
  private
    { Private declarations }
    FAccountGroup : TAccountGroup;
    FAccount  : TAccount;
    FData : TStringList;
    FSymbol : TSymbol;
    procedure init;
    procedure ReadFile(var index: integer; pData: PChar);
    function Parse(stText: String): Integer;
    procedure AddData;
    function FindGridItem(var i: integer; stTime: string): TGridItem;
  public
    { Public declarations }
    MMap  :TMemoryMapIO;
    GridItems : TCollection;

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  end;

var
  FrmPacketExt: TFrmPacketExt;

implementation

uses GAppEnv;

{$R *.dfm}

procedure TFrmPacketExt.BtnCohesionSymbolClick(Sender: TObject);
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

procedure TFrmPacketExt.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  if cbSymbol.ItemIndex = -1 then Exit;
  aSymbol := cbSymbol.Items.Objects[cbSymbol.ItemIndex] as TSymbol;
  if (aSymbol = nil) then Exit;

  if FSymbol <> nil then
    gEnv.Engine.QuoteBroker.Cancel( Self );

  FSymbol := aSymbol;
  gEnv.Engine.QuoteBroker.Subscribe( Self, FSymbol, QuoteProc );

end;

procedure TFrmPacketExt.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
  aMarkets  : TMarketTypes;
  aGroup  : TAccountGroup;
begin

  aGroup  := GetComboObject( ComboAccount ) as TAccountGroup;
  if aGroup = nil then Exit;
  if aGroup = FAccountGroup then
    Exit;
  FAccountGroup := aGroup;
  // 선,옵 계좌를 구한다.
  aAccount  := FAccountGroup.Accounts.GetMarketAccount( atFO );

  if aAccount <> FAccount then
  begin
    FAccount := aAccount;
  end;

end;

procedure TFrmPacketExt.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmPacketExt.FormCreate(Sender: TObject);
begin
  MMap  :=TMemoryMapIO.Create;
  FData := TStringList.Create;
  FAccount  := nil;

  FAccountGroup := nil;
  FSymbol := nil;

  gEnv.Engine.TradeCore.AccountGroups.GetList( ComboAccount.Items );


  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex  := 0;
    ComboAccountChange( nil );
  end;

  GridItems := TCollection.Create( TGridItem );
  init;
end;

procedure TFrmPacketExt.FormDestroy(Sender: TObject);
begin
  FData.Free;
  MMap.Free;
  GridItems.Free;
end;


procedure TFrmPacketExt.init;
var
  iStep : integer;
  stTxt, stErr: string;
  pFile : PChar;

begin
  sgData.RowCount := 2;
  sgData.ColCount := 11;
  sgData.FixedRows  := 1;

  with sgData do
  begin
    Cells[0,0]  := '체결변호';
    ColWidths[0]:= 80;

    Cells[1,0]  := '주문번호';
    ColWidths[1]:= 80;

    Cells[2,0]  := 'LS';
    ColWidths[2]:= 40;

    Cells[3,0]  := '가격';
    ColWidths[3]:= 60;

    Cells[4,0]  := '수량';
    ColWidths[4]:= 40;

    Cells[5,0]  := '시각';
    ColWidths[5]:= 100;

    Cells[6,0]  := '';
    ColWidths[6]:= 5;

    Cells[7,0]  := '시각';
    ColWidths[7]:= 100;

    Cells[8,0]  := 'LS';
    ColWidths[8]:= 40;

    Cells[9,0]  := '가격';
    ColWidths[9]:= 60;

    Cells[10,0]  := '수량';
    ColWidths[10]:= 40;
  end;


  stTxt :=

  ComposeFilePath([gEnv.RootDir, DIR_FILLFILES]) + '\' + FormatDateTime('yyyymmdd', GetQuoteDate);
  stTxt := stTxt+'_kospider.txt';
  if not FileExists(stTxt) then
  begin
    stErr := 'File Not Exist';
    ShowMessage( stErr );
    Exit;
  end;

  pFile := MMap.CreateMemoryMapIO(iStep , stTxt );

  if pFile = nil then
  begin
    case iStep of
      1 : stErr := 'not find file';
      2 : stErr := 'failed CreateFile';
      3 : stErr := 'failed CreateFileMapping';
      4 : stErr := 'failed MapViewOfFile';
    end;
    ShowMessage( stErr );
    Exit;
  end;

  iStep := 0;
  while pFile[iStep] <> #0 do
  begin
    ReadFile( iStep, pFile );
  end;

end;


procedure TFrmPacketExt.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aQuote : TQuote;
    aItem, oItem  : TGridItem;
    i : integer;
begin
  if DataObj = nil then Exit;
  aQuote := DataObj as TQuote;
  if aQuote.Symbol <> FSymbol then Exit;
  if aQuote.LastEvent = qtTimeNSale then
  begin
    aItem := FindGridItem(i, aQuote.Sales.Last.DistTime);
    if aItem = nil then Exit;
    oItem := TGridItem( sgData.Objects[0,i+1] );
    if aItem <> oItem then
      i := sgData.Cols[0].IndexOfObject( aItem );

    if i < 0 then Exit;

    with sgData do
    begin
      aItem.Find := true;
      Cells[7,i+1]  := aQuote.Sales.Last.DistTime;
      Cells[8,i+1]  := ifThenStr( aQuote.Sales.Last.Side > 0, 'L', 'S');
      Cells[9,i+1]  := Format( '%.2f', [ aQuote.Last ]);
      Cells[10,i+1]  := IntToStr( aQuote.Sales.Last.Volume );
    end;
  end;
end;

function TFrmPacketExt.FindGridItem( var i: integer; stTime : string ) : TGridItem;
var
  aItem : TGridItem;
  j : integer;
begin
  Result := nil;

  if stTime = '10463437' then
    stTime := '10463437';

  for j := 0 to GridItems.Count - 1 do
  begin
    aItem := TGridItem( GridItems.Items[j] );
    if aItem.FillTime2 = '10463437'  then
      aItem.FillTime2 := '10463437';
    if (aItem.FillTime2 = stTime) and ( not aItem.Find) then
    begin
      Result := aItem;
      i := j;
      break;
    end;
  end;
end;


procedure TFrmPacketExt.ReadFile(var index: integer; pData: PChar);
var
  iEnd, iStart, iRes : integer;
  stData : string;

begin
  iStart := index;

  while pData[index] <> #13 do
  begin
    inc( index );
  end;

  iEnd := index - iStart;

  if iEnd > 10 then
  begin
    SetString( stData, pData+iStart, iEnd );
    iRes  := Parse( stData );
    //if iRes = 9 then //접수
    //if iRes = 6 then //체결
     AddData;
  end;

  //inc( FParseCount );
  inc( index, 2 );
end;


function TFrmPacketExt.Parse(stText: String): Integer;
var
  i : Integer;
  stToken : String;
begin
  FData.Clear;

  stToken := '';

  for i:=1 to Length(stText) do
  begin
    if stText[i] = #9 then
    begin
      FData.Add(stToken);
      stToken := '';
    end else
      stToken := stToken + stText[i];
  end;

  if Length(stToken) > 0 then
    FData.Add(stToken);

  Result := FData.Count;

end;

procedure TFrmPacketExt.AddData;
var
  i : integer;
  vHead : PCommonData;
  vData : PFillPacket;
  aAccount  : TAccount;
  stTmp : string;
  aItem : TGridItem;
begin
  for i := 0 to Fdata.Count - 1 do
    gEnv.EnvLog(WIN_TEST, FData[i]);

  vHead := PCommonData( FData[DataIdx] );

  if FAccount = nil then Exit;
  if OrderFill <>  string( vHead.TransacCode ) then
    Exit;

  vData := PFillPacket( FData[DataIdx] );

  stTmp := Trim( string( vData.AccountNo ) );
  if FAccount.Code <> stTmp then Exit;

  aItem := TGridItem( GridItems.Add );
  aItem.FillNo  := Trim( string( vData.FillNo ) );

  if vData.Side = '2' then
    aItem.LS := 'L'
  else
    aItem.LS := 'S';

  aItem.Price   := StrToFloat( string( vData.FillPrice ));
  aItem.Qty     := StrToInt( string( vData.FillQty ));
  aItem.FillTime:= Trim( string( vData.FillTime ));
  aItem.FillTime2 := Copy( aItem.FillTime, 1,Length( aItem.FillTime ) -1  );
  aItem.Find    := false;
  aItem.OrderNo := Trim( string( vData.CommonData.ClOrdID ));


  i := sgData.RowCount -1 ;
  InsertLine( sgData, i);

  with sgData do
  begin
    Objects[0,i]  := aItem;
    Cells[0,i]  := aItem.OrderNo;
    Cells[1,i]  := aItem.FillNo;
    Cells[2,i]  := aItem.LS;
    Cells[3,i]  := Format('%.2f', [aItem.Price]);
    Cells[4,i]  := IntToStr(aItem.Qty);
    Cells[5,i]  := aItem.FillTime;
  end;

end;



initialization
  RegisterClass( TFrmPacketExt );

Finalization
  UnRegisterClass( TFrmPacketExt )
end.
