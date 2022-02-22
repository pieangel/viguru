unit FFutInOut;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, DateUtils,

  CleQuoteBroker, CleSymbols, GleTypes, StdCtrls  ,
  CleDistributor, CleStorage, ClePriceItems,
  ExtCtrls,
  Buttons, FQuoteTrace, ComCtrls , CleSimuationForm, Grids
  ;

const
  OrdCnt = 6;
  OrdType : array [0..OrdCnt-1] of string
    = ( 'L', 'S', 'Lx', 'Sx', 'Lc', 'Sc' );

type

  TGridType = ( gtAdd, gtUpdate, gtDel );

  TFillter = record
    SisSec  : integer;
    SisCnt  : integer;
    OrdQty  : integer;
    OrdSec  : integer;
    //
    SalePrev: integer;
    SaleQty : integer;
    SaleAfter: integer;
  end;

  TForceItem  = class( TCollectionItem )
  private
    FData : TOrderData;
  public

    IsForce : Boolean;
    OrderData : TList;
    AfterData : TList;
    Fillter   : TFillter;

    StartTime : TDateTime;
    LastTime  : TDateTime;

    LimitTime : TDateTime;
    AFterTime : TDateTime;
    OrdIdx    : integer;

    constructor Create(aColl: TCollection); override;
    destructor Destroy; override;

    function IsSameForce( aData : TOrderData ) : boolean;
    function GetTimeGap( dtTime : TDateTime ) : integer;
    procedure Add( aData : TOrderData; bAfter : boolean = false );
    procedure AddSort( aData : TOrderData );
    property Data : TOrderData read FData write FData;

  end;

  TForceItems = class( TCollection )
  private
    function CheckForced(aData: TOrderData): TForceItem;
  public
    Fillter  : TFillter;
    constructor Create;
    destructor Destroy; override;

    function New( aData : TOrderData; idx : integer ) : TForceItem; overload;
    function New( aData : TOrderData; idx : integer; var iAct : integer; var ii : integer ): TForceItem; overload;
    procedure Fills( aData : TOrderData ) ;
    procedure CheckDelete( aData : TOrderData ) ;
    function Find( aData : TOrderData ) : TForceItem;
  end;


  TFutInOut = class(TForm)
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Label1: TLabel;
    ComboSymbol: TComboBox;
    GroupBox1: TGroupBox;
    edtSec: TLabeledEdit;
    edtCount: TLabeledEdit;
    edtOrdSec: TLabeledEdit;
    Bevel2: TBevel;
    Label2: TLabel;
    Label3: TLabel;
    edtQty: TLabeledEdit;
    spStart: TSpeedButton;
    Button1: TButton;
    Bevel1: TBevel;
    Label4: TLabel;
    edtPrev: TLabeledEdit;
    edtSale: TLabeledEdit;
    edtafter: TLabeledEdit;
    Button5: TButton;
    stbar: TStatusBar;
    Panel1: TPanel;
    sgForce: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboSymbolChange(Sender: TObject);
    procedure edtSecKeyPress(Sender: TObject; var Key: Char);
    procedure edtSecChange(Sender: TObject);
    procedure edtSecExit(Sender: TObject);
    procedure spStartClick(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure edtPrevExit(Sender: TObject);
    procedure sgForceDblClick(Sender: TObject);
    procedure sgForceMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
  private

    FRow : integer;
    FSymbol : TSymbol;
    FQuote  : TQuote;
    Fillter : TFillter;
    FIndex  : integer;

    procedure initControls;
    procedure GetFillter;
    procedure initLogFile( bForce : boolean = false );
    function MakeFileName( bForce : boolean = false): string;
    function MakeLog(aData: TOrderData; bDist: boolean ; bForce : boolean = false): string;
    function GetOrdIndex(stDiv: string): integer;
    procedure initLogFile2;
    procedure DisData( aItem : TForceItem; gtType : TGridType );


    { Private declarations }

  public
    { Public declarations }

    SelfDir : string;
    SelfFile : string;
    BStart, BStop : Boolean;
    BOrdStart, BOrdStop : boolean;

    StartTime : TDateTime;
    StartOrdTime : TDateTime;

    LastData    : TOrderData;
    SaveData    : TOrderData;

    LogCount    : integer;
    LogIndex    : integer;
    LogFile     : string;

    QuoteList   : TList;
    OrderData   : TList;

    ForceItems  : array [0..OrdCnt-1] of TForceItems;
    WholeSaleItems  : TForceItems;
    SortItems   : TList;

    Storage : TStorage;

    procedure QuoteProc(Sender, Receiver: TObject;
      DataID: Integer; DataObj: TObject; EventID: TDistributorID);
    procedure SetFillter;
    procedure LogData( stLog : string ; bForce : boolean = false); overload;
    procedure LogData( bOrderLog : boolean; aData : TOrderData ); overload;
    procedure LogData2(stLog: string);

    procedure Start;
    procedure Stop;

    procedure SaveEnv(aStorage: TStorage; idx : integer);
    procedure LoadEnv(aStorage: TStorage; stFile : string);
  end;

  function GetString( aData : TOrderData ) : string;
var
  FutInOut: TFutInOut;

implementation

uses
  GleLib, GAppEnv, DleSymbolSelect, CleSimulationConst, CleQuoteTimers, FForce;

{$R *.dfm}


// 분석
function TFutInOut.GetOrdIndex( stDiv : string ) : integer;
var
  i: Integer;
begin
  Result := -1;
  for i := 0 to OrdCnt - 1 do
    if OrdType[i] = stDiv then
    begin
      Result := i;
      break;
    end;
end;

procedure TFutInOut.Button1Click(Sender: TObject);
var
  iQty, i , j, k, iCnt, ii, iAct : integer;
  aItem, dItem, oItem  : TForceItem;
  aData  : TOrderData;
  stTmp  : string;
  bDel   : boolean;
begin
  if FSymbol = nil then exit;

  FQuote := FSymbol.Quote as TQuote;
  if FQuote = nil then Exit;

  for i := 0 to OrdCnt - 1 do
    ForceItems[i].Clear;
  SortItems.Clear;

  stbar.Panels[0].Text := '세력로그...';

  for i := FQuote.PriceAxis.OrderList.Count-1 downto 0 do
  begin

    aData := TOrderData( FQuote.PriceAxis.OrderList.Items[i] );

    iQty  := StrToIntDef( aData.Qty, 0);
    if iQty < Fillter.OrdQty then
      Continue;

    if aData.FillQty <> '' then
      Continue;

    k := GetOrdIndex( aData.GetOrderState );
    if k < 0 then Exit;

    iAct  := 0;
    aItem := ForceItems[k].New( aData, i, iAct, ii );

    if iAct < 0 then
    begin
      dItem := TForceItem(ForceItems[k].Items[ii]);
      for j := 0 to SortItems.Count - 1 do
        if TForceItem( SortItems.Items[j]) = dItem  then
        begin
          SortItems.Delete( j );
          break;
        end;
      ForceItems[k].Delete(ii);
      SortItems.Add( aItem );
    end
    else if iAct = 1 then
    begin
      SortItems.Add( aItem );
    end;
  end;

  LogCount := 0;
  LogIndex := 0;
  initLogFile( true );

  // 디버그용
  for i := 0 to SortItems.Count - 1 do
  begin
    aItem := TforceItem( SortItems.Items[i] );
    if aItem = nil then Continue;

    for j := 0 to aItem.OrderData.Count - 1 do
    begin
      aData := TOrderData( aItem.OrderData.Items[j]);
      stTmp := MakeLog( aData, true, true );
      LogData( stTmp, true );
    end;

    if (aItem.OrdIdx-1) >= 0 then
      for j := (aItem.OrdIdx-1) downto 0 do
      begin
        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[j] );
        if aItem.AFterTime < aData.Time then
          break;

        if (StrToIntDef(aData.Qty,0) < Fillter.OrdQty ) then
          Continue;

        stTmp := MakeLog( aData, false, true );
        LogData( stTmp, true );
      end;

    LogData( '', true );
  end;

  stbar.Panels[0].Text := '세력로그 Finished';

end;

procedure TFutInOut.Button2Click(Sender: TObject);
var
  aDlg : TQuoteTrace;
begin
  if FSymbol = nil then
  begin
    ShowMessage('선택된 종목이 없음');
    Exit;
  end;
  aDlg := TQuoteTrace.Create(self);
  aDlg.cbSymbol.AddItem( FSymbol.Code, FSymbol );
  aDlg.cbSymbol.ItemIndex := 0;
  aDlg.cbSymbolChange( aDlg.cbSymbol );
  aDlg.Show;       
end;

procedure TFutInOut.Button3Click(Sender: TObject);
begin
  Button2Click( nil ); 
  Close;
end;

procedure TFutInOut.Button4Click(Sender: TObject);
var
  aSymbol : TSymbol;
  i : integer;
begin

  if gSymbol = nil then
  begin
    gSymbol := TSymbolDialog.Create(Self);
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try   {
    if gSymbol.Open( true ) then
    begin
        // add to the cache
      //gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      ComboSymbol.Items.Clear;
      //gEnv.Engine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);

      for i:= 0 to gSymbol.ListSelected.Items.Count-1 do
      begin
        aSymbol := TSymbol( gSymbol.ListSelected.Items[i].Data );
        if aSymbol <> nil then
        begin
          gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(aSymbol);
          ComboSymbol.AddItem( aSymbol.Code, aSymbol);
          //AddSymbolCombo(aSymbol, ComboSymbol );
        end;
      end;

      if ComboSymbol.Items.Count > 0 then
      begin
        ComboSymbol.ItemIndex := 0;
        ComboSymbolChange(ComboSymbol);
      end;
    end;  }
    if gSymbol.Open then
    begin
      ComboSymbol.Items.Clear;
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);
        //
      AddSymbolCombo(gSymbol.Selected, ComboSymbol);
        // apply
      ComboSymbolChange(ComboSymbol);

    end;
  finally
    gSymbol.Hide;
  end;

end;

procedure TFutInOut.Button5Click(Sender: TObject);
var
  iQty, i , j, iCnt, ii, iAct : integer;
  aItem : TForceItem;
  aData  : TOrderData;
  stTmp  : string;
  wH, wM : word;
begin

  if FSymbol = nil then exit;

  FQuote := FSymbol.Quote as TQuote;
  if FQuote = nil then Exit;

  stbar.Panels[0].Text := '패대기 로그....';

  WholeSaleItems.Clear;

  for i := FQuote.PriceAxis.OrderList.Count-1 downto 0 do
  begin

    aData := TOrderData( FQuote.PriceAxis.OrderList.Items[i] );

    iQty  := StrToIntDef( aData.Qty, 0);
    if iQty < Fillter.SaleQty then
      Continue;

    WholeSaleItems.New( aData, i );
  end;

  LogCount := 0;
  LogIndex := 0;
  initLogFile2;

  for i := 0 to WholeSaleItems.Count- 1 do
  begin
    aItem := TforceItem( WholeSaleItems.Items[i] );
    if aItem = nil then Continue;

    wH := HourOf(aItem.FData.Time);
    wM := MinuteOf( aItem.FData.Time );

    if (wH = 15) and ( wM > 5 ) then
      break;

    // 직전로그
    if (aItem.OrdIdx + 1) <= ( FQuote.PriceAxis.OrderList.Count-1)  then
      for j := (aItem.OrdIdx + 1) to FQuote.PriceAxis.OrderList.Count-1 do
      begin
        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[j] );
        if aItem.StartTime > aData.Time then
          break;

        if (StrToIntDef(aData.Qty,0) < Fillter.OrdQty ) then
          Continue;

        aItem.OrderData.Add( aData );
      end;

    for j := aItem.OrderData.Count - 1 downto 0 do
    begin
      aData := TOrderData( aItem.OrderData.Items[j]);
      stTmp := MakeLog( aData, false, true );
      LogData2( stTmp );
    end;
    // 실제주문로그
    stTmp := MakeLog( aItem.FData, true, true );
    LogData2( stTmp );

    // afterlog                    1
    if (aItem.OrdIdx-1) >= 0 then
      for j := (aItem.OrdIdx-1) downto 0 do
      begin
        aData := TOrderData( FQuote.PriceAxis.OrderList.Items[j] );
        if aItem.AFterTime < aData.Time then
          break;

        if (StrToIntDef(aData.Qty,0) < Fillter.OrdQty ) then
          Continue;

        stTmp := MakeLog( aData, false, true );
        LogData2( stTmp );
      end;

    LogData2( '' );
  end;

  stbar.Panels[0].Text := '패대기로그 Finished';
end;

procedure TFutInOut.ComboSymbolChange(Sender: TObject);
begin
    // get symbol
  FSymbol := GetComboObject(ComboSymbol) as TSymbol;
  if FSymbol = nil then Exit;

  {
  gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(FSymbol);
  ComboSymbol.Items.Clear;
  gEnv.Engine.SymbolCore.SymbolCache.GetList(ComboSymbol.Items);
  SetComboIndex(ComboSymbol, FSymbol);
  }

end;

procedure TFutInOut.edtSecChange(Sender: TObject);
begin
  //
end;

procedure TFutInOut.edtSecExit(Sender: TObject);
begin
  SetFillter;
end;

procedure TFutInOut.edtSecKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#8, #13]) then
    Key := #0;
end;

procedure TFutInOut.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFutInOut.FormCreate(Sender: TObject);
var
  i : integer;
begin
  FSymbol := nil;
  LastData  := nil;
  SaveData  := nil;
  LogCount  := 0;
  LogIndex  := 0;

  BOrdStart := false;
  BStart := false;
  BStop  := false;

  OrderData := TList.Create;
  QuoteList := TList.Create;

  for i := 0 to OrdCnt - 1 do
    ForceItems[i]  := TForceItems.Create;
  SortItems := TList.Create;


  // 싸잡는 주문..
  WholeSaleItems  := TForceItems.Create;

  SetFillter;
  initControls;

  Storage := TStorage.Create;

  if not DirectoryExists(gEnv.SimulDir + '\FutInOut' ) then
    CreateDir(gEnv.SimulDir + '\FutInOut');
  SelfDir := gEnv.SimulDir + '\FutInOut';
  SelfFile :=  SelfDir+ '\FutInOut' ;

  initLogFile;

  LoadEnv( Storage, SelfFile);

end;

procedure TFutInOut.FormDestroy(Sender: TObject);
var
  idx, i : integer;
begin
  Stop;

  for i := 0 to gSimulEnv.TotCount - 1 do
    if Self.ClassName = ('T'+gSimulEnv.SimulWins[i].Name) then
    begin
      SaveEnv( Storage, i );
    end;


  Button2Click( nil );
  for i := 0 to OrdCnt - 1 do
    ForceItems[i].Free;
  WholeSaleItems.Free;
  SortItems.Free;
  OrderData.Free;
  QuoteList.Free;
  Storage.Free;
end;

procedure TFutInOut.initLogFile( bForce : boolean );
var
  TF : TextFile ;
  stTmp, stFile, stHeader : string;
begin
  if bForce then
    stHeader := '시간,세력,LS,호가,가격,주문,체결'
  else
    stHeader := '시간,LS,호가,가격,주문,체결';
  LogFile  := gEnv.SimulDir + '\FutInOut\'+ MakeFileName( bForce );
  try
    AssignFile(TF, LogFile );
    Rewrite(TF);
    Writeln(TF, stHeader);
  finally
    CloseFile(TF);
  end;
end;


procedure TFutInOut.initLogFile2;
var
  TF : TextFile ;
  stTmp, stFile, stHeader : string;
begin
  stHeader := '시간,패대기,LS,호가,가격,주문,체결';

  LogFile  := gEnv.SimulDir + '\FutInOut\'+ 'WholeSale_'+MakeFileName ;
  try
    AssignFile(TF, LogFile );
    Rewrite(TF);
    Writeln(TF, stHeader);
  finally
    CloseFile(TF);
  end;
end;


function TFutInOut.MakeFileName( bForce : boolean ) : string;
var
 sttmp : string;
begin
  stTmp := ifThenStr( bForce , 'Force_', '');
  Result := Format( '%sFutInOut_%s_%d.csv', [ stTmp, FormatDateTime( 'yyyymmdd', GetQuoteTime ),
    LogIndex]);
end;

procedure TFutInOut.GetFillter;
begin
  edtSec.Text := IntToStr( Fillter.SisSec);
  edtCount.Text := IntToStr( Fillter.SisCnt);
  edtOrdSec.Text  := IntToStr( Fillter.OrdSec);
  edtQty.Text := IntToStr( Fillter.OrdQty);
end;

procedure TFutInOut.SaveEnv(aStorage: TStorage; idx : integer);
var
  i : integer;
  aSymbol : TSymbol;
  stTmp : string;
begin
  if aStorage = nil then Exit;

  aStorage.Clear;

  aStorage.New;

  aStorage.FieldByName('SymbolCount').AsInteger := ComboSymbol.Items.Count;
  for i := 0 to ComboSymbol.Items.Count - 1 do
  begin
    aSymbol := TSymbol( ComboSymbol.Items.Objects[i] );
    if aSymbol <> nil then
      aStorage.FieldByName('Code'+IntTostr(i)).AsString := aSymbol.Code;
  end;

  aStorage.FieldByName('Left').AsInteger := Left;
  aStorage.FieldByName('Top').AsInteger := Top;
  aStorage.FieldByName('width').AsInteger := Width;
  aStorage.FieldByName('Height').AsInteger := Height;
  case WindowState of
    wsNormal: aStorage.FieldByName('WindowState').AsInteger := 0;
    wsMinimized: aStorage.FieldByName('WindowState').AsInteger := 1;
    wsMaximized: aStorage.FieldByName('WindowState').AsInteger := 2;
  end;

  aStorage.FieldByName('Fillter.SisSec').AsInteger := Fillter.SisSec;
  aStorage.FieldByName('Fillter.SisCnt').AsInteger := Fillter.SisCnt;
  aStorage.FieldByName('Fillter.OrdSec').AsInteger := Fillter.OrdSec;
  aStorage.FieldByName('Fillter.OrdQty').AsInteger := Fillter.OrdQty;
  aStorage.FieldByName('Fillter.SalePrev').AsInteger := Fillter.SalePrev;
  aStorage.FieldByName('Fillter.SaleQty').AsInteger := Fillter.SaleQty;
  aStorage.FieldByName('Fillter.SaleAfter').AsInteger := Fillter.SaleAfter;

  aStorage.Save( SelfFile );

end;

procedure TFutInOut.SetFillter;
var
  i : integer;
begin
  Fillter.SisSec  := StrToIntDef( edtSec.Text, 1 );
  Fillter.SisCnt  := StrToIntDef( edtCount.Text, 3 );
  Fillter.OrdSec  := StrToIntDef( edtOrdSec.Text, 1 );
  Fillter.OrdQty  := StrToIntDef( edtQty.Text, 20 );

  Fillter.SalePrev  := StrToIntDef( edtPrev.Text, 5);
  Fillter.SaleQty   := StrToIntDef( edtSale.Text, 100);
  Fillter.SaleAfter := StrToIntDef( edtAfter.Text, 2);

  for i := 0 to OrdCnt - 1 do
    ForceItems[i].Fillter  := Fillter;
  WholeSaleItems.Fillter   := Fillter;
end;



procedure TFutInOut.sgForceDblClick(Sender: TObject);
var
  //aDlg : TForm2;
  aItem : TForceItem;
begin
  if FRow <= 0 then Exit;
  aItem := TForceItem( sgForce.Objects[0, FRow]);

  if aItem = nil then Exit;

  //aDlg  := TForm2.Create( self );

  try
 //   aDlg.init(aItem);
 //   aDlg.Show;
  finally

  end;

end;

procedure TFutInOut.sgForceMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    ACol : integer;
begin
  sgForce.MouseToCell( X, Y, ACol, FRow );
  sgForce.Repaint;

end;

procedure TFutInOut.spStartClick(Sender: TObject);

begin

  if spStart.Down then
  begin
    Start;
    stbar.Panels[0].Text  := '시세구독';
    SaveEnv( Storage , 0);
  end
  else begin
    stop;
    stbar.Panels[0].Text  := '시세구독취소';
  end;
end;

procedure TFutInOut.Start;
var
  i : integer;
  aQuote : TQuote;
  aSymbol : TSymbol;
begin
  //stop;

  for i := 0 to ComboSymbol.Items.Count - 1 do
  begin
    aSymbol := TSymbol( ComboSymbol.Items.Objects[i] );
    if aSymbol <> nil then
    begin
      aQuote := gEnv.Engine.QuoteBroker.Subscribe( Self, aSymbol, QuoteProc );
      aQuote.ExtrateOrder := true;
      QuoteList.Add( aQuote );
    end;
  end;

  if QuoteList.Count > 0 then
  begin
    spStart.Caption := 'start';
    spStart.Down := true;
  end
  else  begin
    spStart.Caption := 'stop';
    spStart.Down := false;
    ShowMessage('종목선택하세요');
  end;

end;

procedure TFutInOut.Stop;
var
  i : integer;
  aQuote : TQuote;
begin

  spStart.Caption := 'stop';
  spStart.Down := false;
  for i := 0 to QuoteList.Count - 1 do
  begin
    aQuote := TQuote( QuoteList.Items[i] );
    if aQuote <> nil then
      aQuote.ExtrateOrder := false;
  end;
  gEnv.Engine.QuoteBroker.Cancel( self );
end;

procedure TFutInOut.initControls;
begin
  stop;
end;



procedure TFutInOut.QuoteProc(Sender, Receiver: TObject; DataID: Integer;
  DataObj: TObject; EventID: TDistributorID);
  var
    aData : TOrderData;
    aQuote : TQuote;
    iPos : integer;
    iQty, k, iAct, j, ii,i : integer;
    aItem, dItem, oItem  : TForceItem;
begin

  if DataObj = nil then Exit;
  aQuote := DataObj as TQuote;

  iPos := QuoteList.IndexOf(aQuote);

  if iPos < 0 then
    Exit;

  if aQuote.PriceAxis.OrderList.Count = 0 then Exit;

  aData := TOrderData( aQuote.PriceAxis.OrderList.Items[0]);
  if aData = LastData then Exit;
  {

  //if aData.QType <> LN then Exit;

  LogData( false, aData );
  }

    iQty  := StrToIntDef( aData.Qty, 0);
    if iQty < Fillter.OrdQty then
      Exit;

    if aData.FillQty <> '' then
      Exit;

    k := GetOrdIndex( aData.GetOrderState );
    if k < 0 then Exit;

    iAct  := 0;
    aItem := ForceItems[k].New( aData, i, iAct, ii );

    if iAct < 0 then
    begin
      dItem := TForceItem(ForceItems[k].Items[ii]);
      DisData( dItem, gtDel );
      for j := 0 to SortItems.Count - 1 do
        if TForceItem( SortItems.Items[j]) = dItem  then
        begin
          SortItems.Delete( j );
          break;
        end;

      ForceItems[k].Delete(ii);
      DisData( aItem, gtAdd );
      SortItems.Add( aItem );
    end
    else if iAct = 1 then
    begin
      SortItems.Add( aItem );
      DisData( aItem, gtAdd );
    end
    else
      DisData( aItem, gtUpdate );



  LastData := aData;
end;


procedure TFutInOut.DisData( aItem : TForceItem; gtType : TGridType );
var
  iRow : integer;

  function Find : integer;
  var
    i : integer;
    oItem : TForceItem;
  begin
    for i := 1 to sgForce.RowCount - 1 do
    begin
      Result := -1 ;
      oItem := TForceItem( sgForce.Objects[0,i]);
      if oItem = aItem  then
      begin
        Result := i;
        break;
      end;

    end;
  end;
begin
  if SortItems.Count <= 0 then Exit;
  if aItem = nil then Exit;
  //sgForce.Objects.i

  case gtType of
    gtAdd:
      begin
        InsertLine( sgForce, 1 );
        sgForce.Objects[0, 1] := aItem;
        sgForce.Cells[0,1]  := FormatDateTime('hh:nn:ss.zzz', aItem.StartTime );
        sgForce.Cells[1,1]  := aItem.FData.GetOrderState;
        sgForce.Cells[2,1]  := intToStr( aItem.OrderData.Count );
      end;
    gtUpdate:
      begin
        iRow := Find ;
        if iRow < 0 then
          Exit;
        sgForce.Cells[2,iRow]  := intToStr( aItem.OrderData.Count );
      end;
    gtDel:
      begin
        iRow := Find ;
        if iRow < 0 then
          Exit;
        DeleteLine( sgForce, iRow );
        Exit;
      end;
  end;

end;


procedure TFutInOut.LoadEnv(aStorage: TStorage; stFile : string);
var
  i , iCnt: integer;
  aSymbol : TSymbol;
  stTmp : string;
begin
  if aStorage = nil then Exit;

  aStorage.Load(stFile);

    // move to the start of the storage
  aStorage.First;

  iCnt  := aStorage.FieldByName('SymbolCount').AsInteger;
  for i := 0 to iCnt - 1 do
  begin
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(
                          aStorage.FieldByName('Code'+IntTostr(i)).AsString);
    if aSymbol <> nil then
      ComboSymbol.AddItem( aSymbol.Code, aSymbol);
  end;


  if ComboSymbol.Items.Count > 0then
  begin
    ComboSymbol.ItemIndex := 0;
    ComboSymbolChange( ComboSymbol );
  end;

  Left  := aStorage.FieldByName('Left').AsInteger;
  Top   := aStorage.FieldByName('Top').AsInteger;
  Width := aStorage.FieldByName('width').AsInteger;
  Height:= aStorage.FieldByName('Height').AsInteger;


  edtSec.Text     := IntToStr(aStorage.FieldByName('Fillter.SisSec').AsInteger );
  edtCount.Text   := IntToStr(aStorage.FieldByName('Fillter.SisCnt').AsInteger);
  edtOrdSec.Text  := IntToStr(aStorage.FieldByName('Fillter.OrdSec').AsInteger);
  edtQty.Text     := IntToStr(aStorage.FieldByName('Fillter.OrdQty').AsInteger);
  edtPrev.Text    := IntToStr(aStorage.FieldByName('Fillter.SalePrev').AsInteger);
  edtSale.Text    := IntToStr(aStorage.FieldByName('Fillter.SaleQty').AsInteger);
  edtAfter.Text   := IntToStr(aStorage.FieldByName('Fillter.SaleAfter').AsInteger);

  SetFillter;

end;

procedure TFutInOut.LogData(bOrderLog: boolean; aData: TOrderData);
var
  i : integer;
  oData  : TOrderData;
  stLog  : string;
begin
  if bOrderLog then
  begin
    for i := 0 to OrderData.Count - 1 do
    begin
      oData := TOrderData( OrderData.Items[i] );
      stLog := MakeLog( oData, true );
      LogData( stLog );
    end;
    OrderData.Clear;
  end;

  i := SecondsBetween( aData.Time, StartOrdTime );
  stLog := MakeLog( aData, false );
  //stLog := stLog + ', ' + FormatDateTime( 'hh:mm:ss.zzz', StartOrdTime ) + ' , ' + FormatDateTime( 'hh:mm:ss.zzz', aData.Time ) + ',' + IntTosTr( i);;
  LogData( stLog );

end;

procedure TFutInOut.edtPrevExit(Sender: TObject);
begin
  SetFillter;
end;

procedure TFutInOut.LogData2( stLog : string );
begin
  inc( LogCount );
  if LogCount > LogMaxCount then
  begin
    LogCount  := 1;
    inc(LogIndex );
    initLogFile2;
  end;

  gEnv.DoLog( '', stLog, true, LogFile );
end;


procedure TFutInOut.LogData( stLog : string; bForce : boolean );
begin
  inc( LogCount );
  if LogCount > LogMaxCount then
  begin
    LogCount  := 1;
    inc(LogIndex );
    initLogFile( bForce );
  end;

  gEnv.DoLog( '', stLog, true, LogFile );
end;

function TFutInOut.MakeLog( aData : TOrderData; bDist : boolean ; bForce : boolean ): string;
var
  stTmp, stTmp2 : string;
  iHoga : integer;

  function GetHoga( dPrice : double ) : integer;
  var
    i : integer;
    stSrc, stDesc : string;
  begin
    Result := -1;
    stSrc := Format('%.*n', [ FQuote.Symbol.Spec.Precision, dPrice] );
    for i := 0 to FQuote.Asks.Size - 1 do
    begin

      stDesc := Format('%.*n', [FQuote.Symbol.Spec.Precision, FQuote.Asks[i].Price] );
      if (CompareStr( stDesc, stSrc ) = 0) then
        Result := i;
      stDesc := Format('%.*n', [FQuote.Symbol.Spec.Precision, FQuote.Bids[i].Price] );
      if (CompareStr( stDesc, stSrc ) = 0) then
        Result := i;

      if Result > -1 then
        break;
    end;
  end;

begin
  {
  iHoga := GetHoga( aData.dPrice );

  if iHoga = -1 then
    iHoga := 0;
   }
  if aData.QType in [ SN,SC,LN,LC,LPC,SPC] then
    stTmp2  := IntToStr( aData.No + 1 )
  else if aData.QType = FL then
  begin
    if aData.Name[1] = 'N' then
      stTmp2 := IntToStr( aData.No2 + 1 )
    else
      stTmp2 := Format('%d->%d', [ aData.No+1, aData.No2+1 ]);
  end
  else
    stTmp2 := Format('%d->%d', [ aData.No+1, aData.No2+1 ]);

  stTmp := aData.Qty;
  if aData.QType in [SC, SPC, LC, LPC] then
    stTmp := '-'+aData.Qty;

  if bForce then
    Result := FormatDateTime('hh:nn:ss.zzz', aData.Time )
      + ',' + ifThenStr( bDist, '세력', '    ')
      + ',' + aData.GetOrderState
      + ',' + stTmp2
      + ',' + aData.Price
      + ',' + stTmp
      + ',' + aData.FillQty
  else
    Result := FormatDateTime('hh:nn:ss.zzz', aData.Time )
      + ',' + aData.GetOrderState
      + ',' + stTmp2
      + ',' + aData.Price
      + ',' + stTmp
      + ',' + aData.FillQty;

end;


{ TForceItems }

procedure TForceItem.Add(aData: TOrderData; bAfter : boolean );
begin
  if bAfter then
  begin
    if IsForce then
     AfterData.Add( aData );
  end
  else begin
    OrderData.Add( aData );
    if OrderData.Count >= 3 then
      IsForce := true;
  end;
end;


procedure TForceItem.AddSort(aData: TOrderData);
var
  i : Integer;
  oData : TOrderData;
  bFind : boolean;
begin
  bFind := false;
  for i := 0 to AfterData.Count - 1 do
  begin
    oData := TOrderData( AfterData.Items[i] );
    if oData.Time >= aData.Time then
    begin
      bFind := true;
      break;
    end;
  end;

  if not bFind then
    AfterData.Add( aData )
  else
    AfterData.Insert(i, aData);

end;

constructor TForceItem.Create(aColl: TCollection);
begin
  inherited Create(aColl);
  FData     := nil;
  IsForce   := false;
  OrderData := TList.Create;
  AfterData := TList.Create;
  OrdIdx    := -1;

end;

destructor TForceItem.Destroy;
begin
  OrderData.Free;
  AfterData.Free;
  inherited;
end;

function TForceItem.GetTimeGap(dtTime: TDateTime): integer;
var
  aData : TOrderData;
begin
  Result := -1;
  if FData = nil then
    Exit;

  Result := SecondsBetween( dtTime, FData.Time );
end;

function TForceItem.IsSameForce(aData: TOrderData): boolean;
var
  oData : TOrderData;
  iSec : integer;
  stTmp : string;
begin
  if OrderData.Count > 0 then
  begin
    if ( FData.GetOrderState = aData.GetOrderState ) and
       ( (GetTimeGap( aData.Time ) >-1) and ( (GetTimeGap( aData.Time ) < Fillter.SisSec )))
       then
    begin
      LastTime := aData.Time;
      Add( aData );
    end
    else begin
      iSec := SecondsBetween( LastTime, aData.Time );
      if iSec < 1 then
        Add( aData, true );
    end;
  end
  else begin
    if (StrToIntDef( aData.Qty, 0 )) >= Fillter.OrdQty  then
    begin
       StartTime := aData.Time;
       FData  := aData;
       Add( aData );
    end;
  end;
end;

{ TForceItems }

procedure TForceItems.CheckDelete(aData: TOrderData);
var
  iSec, i,j : integer;
  oItem, aItem : TForceItem;
  sData : TOrderData;
  stTmp : string;
begin
  for i := Count - 1 downto 0 do
  begin
    aItem := TForceItem( Items[i] );
    if aItem = nil then Continue;
    if aItem.OrderData.Count = 0 then
    begin
      Delete( i );
      Continue;
    end;

    if not aItem.IsForce then
    begin
      iSec := SecondsBetween( aItem.StartTime, aData.Time );
      // 지워져야 할 넘들...
      if iSec > 5 {Fillter.SisSec} then
      begin

        for j := 0 to aItem.OrderData.Count - 1 do
        begin
          sData := TOrderData( aItem.OrderData.Items[j] );
          oItem := CheckForced( sData );
          if oItem <> nil then
          begin
            oItem.AddSort( sData );
          end;
        end;

        Delete( i );
      end;
    end;
  end;

end;

constructor TForceItems.Create;
begin
  inherited CReate( TForceItem );
end;

destructor TForceItems.Destroy;
begin

  inherited;
end;

procedure TForceItems.Fills(aData: TOrderData);
var
  i : integer;
  aItem : TForceItem;
begin
  // 가장 가까운 세력을 찾는다.
  aItem :=  CheckForced( aData );
  if aItem = nil then Exit;

  aItem.AddSort( aData );

end;

function TForceItems.Find(aData: TOrderData): TForceItem;
var
  iSec, i : integer;
  oItem, aItem : TForceItem;
  sData : TOrderData;
  stTmp : string;
  j: Integer;
begin
  Result := nil;

  for i := 0 to Count - 1 do
  begin
    aItem := TForceItem( Items[i] );
    if aItem = nil then Continue;
    if aItem.FData = nil then Continue;
    sData := aItem.FData;

    iSec := SecondsBetween( aItem.StartTime, aData.Time );

    if ( sData.GetOrderState = aData.GetOrderState ) and
      ( iSec < Fillter.SisSec ) then
    begin
      Result := aItem;
      Break;
    end;
  end;
end;

function TForceItems.New(aData: TOrderData; idx: integer; var iAct : integer; var ii : integer): TForceItem;
begin
  if Count = 0 then
  begin
    Result := Add as TForceItem;
    Result.Fillter  := Fillter;
    Result.FData    := aData;
    Result.StartTime:= aData.Time;
    Result.LimitTime:= IncSecond( Result.StartTime, Fillter.SisSec );
    Result.OrderData.Add( aData );
    iAct := 1
    //Result.LimitTime  :=
  end
  else begin
    Result := Items[Count-1] as TForceItem;
    if (not Result.IsForce) and ( Result.LimitTime < aData.Time ) then
    begin
      //Delete( Count-1 );
      iAct := -1;
      ii := Count -1;
      Result := Add as TForceItem;
      Result.Fillter  := Fillter;
      Result.FData    := aData;
      Result.StartTime:= aData.Time;
      Result.LimitTime:= IncSecond( Result.StartTime, Fillter.SisSec );
      Result.OrderData.Add( aData );
    end
    else if (not Result.IsForce) and ( Result.LimitTime >= aData.Time ) then
    begin
      Result.OrderData.Add( aData );
      if Result.OrderData.Count >= Fillter.SisCnt then
      begin
        Result.IsForce := true;
        Result.OrdIdx  := idx;
        Result.AFterTime  := IncSecond( aData.Time, Fillter.OrdSec );
      end;
    end
    else if (Result.IsForce) and ( Result.LimitTime >= aData.Time ) then
    begin
      Result.OrderData.Add( aData );
      Result.OrdIdx  := idx;
      Result.AFterTime  := IncSecond( aData.Time, Fillter.OrdSec );
    end
    else if (Result.IsForce) and ( Result.LimitTime < aData.Time ) then
    begin
      Result := Add as TForceItem;
      Result.Fillter  := Fillter;
      Result.FData    := aData;
      Result.StartTime:= aData.Time;
      Result.LimitTime:= IncSecond( Result.StartTime, Fillter.SisSec );
      Result.OrderData.Add( aData );
      iAct := 1
    end;

  end;

end;

function TForceItems.CheckForced( aData : TOrderData ) : TForceItem;
var
  iSec,i: Integer;
  aItem : TForceItem;
  stTmp : string;
  sData : TOrderData;
begin
  Result := nil;
  if Count = 0 then Exit;

  for i := Count-1 downto 0 do
  begin
    aItem := TForceItem( Items[i] );
    if aItem.IsForce then
    begin
      if aItem.LastTime > aData.Time then
        Continue;

      iSec  := SecondsBetween( aItem.LastTime, aData.Time );
      if (iSec < Fillter.OrdSec) then
      begin
        Result := aItem;
        sData := TOrderData( aItem.OrderData.Items[ aItem.OrderData.Count-1 ] );
        break;
      end;
    end;
  end;

end;


function TForceItems.New(aData: TOrderData; idx : integer): TForceItem;
var
  stTmp : string;
begin

  Result := Add as TForceItem;
  Result.Fillter  := Fillter;
  Result.FData    := aData;
  Result.StartTime:= IncSecond( aData.Time, Fillter.SalePrev * -1 );
  Result.AfterTime:= IncSecond( aData.Time, Fillter.SaleAfter );
  Result.OrdIdx   := idx;

end;


function GetString( aData : TOrderData ) : string;
begin
  Result := Format( '%s,%s,%s', [FormatDateTime('hh:nn:ss.zzz', aData.Time),
    aData.GetOrderState, aData.Qty ]);
end;



initialization
  RegisterClass( TFutInOut );

Finalization
  UnRegisterClass( TFutInOut )

end.
