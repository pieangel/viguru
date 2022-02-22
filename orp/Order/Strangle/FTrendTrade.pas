unit FTrendTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Grids,

  CleStorage,  CleAccounts, ClePositions,  CleSymbols,

  CleTrendTrade

  ;

const
  TitleCnt = 7;
  Title : array [0..TitleCnt-1] of string = ( '구분','조건','가격',
                                              '몇종목','건수','청산',
                                              '기타' );


type
  TFrmTrendTrade = class(TForm)
    Panel1: TPanel;
    cbAccount: TComboBox;
    cbStart: TCheckBox;
    sgTrend1: TStringGrid;
    rbF: TRadioButton;
    rbO: TRadioButton;
    sgTrend2: TStringGrid;
    stBar: TStatusBar;
    cbTrend1: TCheckBox;
    cbTrend2: TCheckBox;
    btnApply1: TButton;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    edtQty2: TEdit;
    edtQty1: TEdit;
    cbTrend2Stop: TCheckBox;
    UpDown1: TUpDown;
    UpDown2: TUpDown;
    dtStartTime: TDateTimePicker;
    dtEndTime: TDateTimePicker;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure btnApply1Click(Sender: TObject);
    procedure rbFClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure stBarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel;
      const Rect: TRect);
  private
    FAccount  : TAccount;
    FSymbol   : TSymbol;
    TT        : TTrendTrade;
    FParam    : TTrendParam;
    procedure initControls;
    procedure SetDefaultParam(iDir: integer);
    procedure GetParam( iDir : integer );
    { Private declarations }
  public
    { Public declarations }

    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );

    procedure OnTrendNotify( Sender : TObject; stData : string; iDiv : integer );  
  end;

var
  FrmTrendTrade: TFrmTrendTrade;

implementation

uses
  GAppEnv, GleLib, GleTypes
  ;

{$R *.dfm}

procedure TFrmTrendTrade.btnApply1Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  GetParam( iTag );                  
end;

procedure TFrmTrendTrade.Button2Click(Sender: TObject);
var
  iTag : integer;
begin
  iTag  := ( Sender as TButton ).Tag;
  SetDefaultParam( iTag );
end;

procedure TFrmTrendTrade.SetDefaultParam( iDir : integer );
var
  i : integer;
begin
  case iDir of
    // 추세 1
    1 : if rbF.Checked then
        begin
          with sgTrend1 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '0.7';
              Cells[2,i]  := '0';
              Cells[3,i]  := '1';
              Cells[4,i]  := '2';
              Cells[5,i]  := '0.9';
              Cells[6,i]  := '';
            end;
        end
        else begin
          with sgTrend1 do
          begin
              // 매수
              Cells[1,1]  := '0.7';
              Cells[2,1]  := '0.7';
              Cells[3,1]  := '1';
              Cells[4,1]  := '2';
              Cells[5,1]  := '0.9';
              Cells[6,1]  := '3.0';

              // 매도
              Cells[1,2]  := '0.65';
              Cells[2,2]  := '1';
              Cells[3,2]  := '1';
              Cells[4,2]  := '2';
              Cells[5,2]  := '1';
              Cells[6,2]  := '';
          end;

        end;
    // 추세 2 투자자
    2 : if rbF.Checked then
        begin
          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';      // 조건
              if i=2 then
                Cells[1,i]  := '-50';      // 조건

              Cells[2,i]  := '0';       // 진입가격조건
              Cells[3,i]  := '1';       // 종목카운트
              Cells[4,i]  := '1';       // 진입카운트
              Cells[5,i]  := '0';       // 청산조건
              Cells[6,i]  := '50';       // 청산조건
            end;
        end
        else begin

          with sgTrend2 do
            for I := 1 to 2 do
            begin
              Cells[1,i]  := '50';
              if i=2 then
                Cells[1,i]  := '-50';      // 조건
              Cells[2,i]  := '1';
              Cells[3,i]  := '1';
              Cells[4,i]  := '1';
              Cells[5,i]  := '0';
              Cells[6,i]  := '50';
            end;

        end;
  end;
end;

procedure TFrmTrendTrade.stBarDrawPanel(StatusBar: TStatusBar;
  Panel: TStatusPanel; const Rect: TRect);
  {
  var
    oRect : TRect;

  function GetRect( oRect : TRect ) : TRect ;
  begin
    Result := Rect( oRect.Left, oRect.Top, oRect.Right, oRect.Bottom );
  end;
  }
begin
   {
  StatusBar.Canvas.FillRect( Rect );
  oRect := GetRect( Rect );
  DrawText( stBar.Canvas.Handle, PChar( stBar.Panels[0].Text ),
    Length( stBar.Panels[0].Text ),
    oRect, DT_VCENTER or DT_CENTER )    ;
    }
end;

procedure TFrmTrendTrade.GetParam( iDir : integer );
begin
  with FParam do
  begin

    StartTime := dtStartTime.Time;
    EndTime   := dtEndTime.Time;
    UseFut  := rbF.Checked;

    UseTrd1 := cbTrend1.Checked;
    UseTrd2 := cbTrend2.Checked;
    UseTrdStop  := cbTrend2Stop.Checked;

    case iDir of
      1 : begin
        OrdQty1            := StrToIntDef( edtQty1.Text, 2 );
        OrdCon1[ptLong]    := StrToFloat( sgTrend1.Cells[1,1] ) ;
        BasePrice1[ptLong] := StrToFloat( sgTrend1.Cells[2,1] ) ;
        SymbolCnt1[ptLong] := StrToInt( sgTrend1.Cells[3,1] ) ;
        OrdCnt1[ptLong] := StrToInt( sgTrend1.Cells[4,1] ) ;
        LiqCon1[ptLong] := StrToFloat( sgTrend1.Cells[5,1] )  ;
        OtrCon1[ptLong] := StrToFloatdef( sgTrend1.Cells[6,1], 3 ) ;

        OrdCon1[ptShort]    := StrToFloat( sgTrend1.Cells[1,2] ) ;
        BasePrice1[ptShort] := StrToFloat( sgTrend1.Cells[2,2] ) ;
        SymbolCnt1[ptShort] := StrToInt( sgTrend1.Cells[3,2] ) ;
        OrdCnt1[ptShort] := StrToInt( sgTrend1.Cells[4,2] ) ;
        LiqCon1[ptShort] := StrToFloat( sgTrend1.Cells[5,2] )  ;
        OtrCon1[ptShort] := StrToFloatdef( sgTrend1.Cells[6,2], 3 ) ;

        end;
      2 : begin
        OrdQty2            := StrToIntDef( edtQty2.Text, 1 );
        OrdCon2[ptLong]    := StrToFloat( sgTrend2.Cells[1,1] ) ;
        BasePrice2[ptLong] := StrToFloat( sgTrend2.Cells[2,1] ) ;
        SymbolCnt2[ptLong] := StrToInt( sgTrend2.Cells[3,1] ) ;
        OrdCnt2[ptLong] := StrToInt( sgTrend2.Cells[4,1] ) ;
        LiqCon2[ptLong] := StrToFloat( sgTrend2.Cells[5,1] )  ;
        OtrCon2[ptLong] := StrToFloatdef( sgTrend2.Cells[6,1], 50 ) ;

        OrdCon2[ptShort]    := StrToFloat( sgTrend2.Cells[1,2] ) ;
        BasePrice2[ptShort] := StrToFloat( sgTrend2.Cells[2,2] ) ;
        SymbolCnt2[ptShort] := StrToInt( sgTrend2.Cells[3,2] ) ;
        OrdCnt2[ptShort] := StrToInt( sgTrend2.Cells[4,2] ) ;
        LiqCon2[ptShort] := StrToFloat( sgTrend2.Cells[5,2] )  ;
        OtrCon2[ptShort] := StrToFloatdef( sgTrend2.Cells[6,2], 50 ) ;
      end;
    end;
  end;

  if TT <> nil then
    TT.Param  := FParam;

end;


procedure TFrmTrendTrade.cbAccountChange(Sender: TObject);

var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( cbAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FAccount = aAccount) then Exit;

  FAccount := aAccount;

end;

procedure TFrmTrendTrade.cbStartClick(Sender: TObject);
begin
  if ( FAccount = nil ) or ( FSymbol = nil ) then
  begin
    ShowMessage('시작할수 없습니다. ');
    cbStart.Checked := false;
    Exit;
  end;

  if cbStart.Checked then
  begin
    TT.init( FAccount, FSymbol );
    TT.OnTrendNotify  := OnTrendNotify;
    GetParam(1);
    GetParam(2);
    TT.Start;
  end
  else begin
    TT.OnTrendNotify  := nil;
    TT.Stop;
  end;

end;

procedure TFrmTrendTrade.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TFrmTrendTrade.FormCreate(Sender: TObject);
begin
  //
  initControls;

  gEnv.Engine.TradeCore.Accounts.GetList(cbAccount.Items );

  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange(cbAccount);
  end;

  FSymbol := gEnv.Engine.SymbolCore.Future;

  TT        := TTrendTrade.Create;
end;

procedure TFrmTrendTrade.FormDestroy(Sender: TObject);
begin
  TT.Stop;
  TT.Free;
end;

procedure TFrmTrendTrade.initControls;
var
  I: integer;
begin

  for I := 0 to TitleCnt - 1 do begin
    with sgTrend1 do Cells[i,0]  := Title[i];
    with sgTrend2 do Cells[i,0]  := Title[i];
  end;

  sgTrend1.Cells[0,1] := '매수';
  sgTrend1.Cells[0,2] := '매도';

  sgTrend2.Cells[0,1] := '매수';
  sgTrend2.Cells[0,2] := '매도';

  SetDefaultParam(1);
  SetDefaultParam(2);

end;

procedure TFrmTrendTrade.LoadEnv(aStorage: TStorage);
var
  j, i : integer;
  aAcnt: TAccount;
begin
  if aStorage = nil then Exit;      

  aAcnt := gEnv.Engine.TradeCore.Accounts.Find( aStorage.FieldByName('AccountCode').AsString );
  if aAcnt <> nil then
  begin
    SetComboIndex( cbAccount, aAcnt );
    cbAccountChange(cbAccount);
  end;

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName('Trend1[%j,%i]').AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString;

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        if aStorage.FieldByName('Trend2[%j,%i]').AsString <> '' then
          Cells[j,i]  := aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString;

  cbTrend1.Checked  := aStorage.FieldByName('Trend1').AsBoolean;
  cbTrend2.Checked  := aStorage.FieldByName('Trend2').AsBoolean;

  rbF.Checked := aStorage.FieldByName('Fut').AsBoolean ;
  rbO.Checked := aStorage.FieldByName('Opt').AsBoolean ;

  cbTrend2Stop.Checked  := aStorage.FieldByName('Trend2Stop').AsBoolean ;

  UpDown1.Position := StrToIntDef( aStorage.FieldByName('Qty1').AsString, 2 );
  UpDown2.Position := StrToIntDef( aStorage.FieldByName('Qty2').AsString, 1 );

  dtStartTime.Time := TDateTime( aStorage.FieldByName('StartTime').AsFloat );
end;

procedure TFrmTrendTrade.OnTrendNotify(Sender: TObject; stData: string;
  iDiv: integer);
begin
  if Sender <> TT then Exit;
  stBar.Panels[iDiv-1].Text := stData;
end;

procedure TFrmTrendTrade.rbFClick(Sender: TObject);
begin
  SetDefaultParam(1);
  SetDefaultParam(2);
end;

procedure TFrmTrendTrade.SaveEnv(aStorage: TStorage);
var
  j, i : integer;
begin
  if aStorage = nil then Exit;

  if FAccount <> nil then
    aStorage.FieldByName('AccountCode').AsString := FAccount.Code
  else
    aStorage.FieldByName('AccountCode').AsString := '';

  with sgTrend1 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(  Format('Trend1[%d,%d]',[j,i]) ).AsString  := Cells[j,i];

  with sgTrend2 do
    for i := 1 to RowCount - 1 do
      for j := 1 to ColCount - 1 do
        aStorage.FieldByName(Format('Trend2[%d,%d]',[j,i])).AsString   := Cells[j,i];

  aStorage.FieldByName('Trend1').AsBoolean  := cbTrend1.Checked;
  aStorage.FieldByName('Trend2').AsBoolean  := cbTrend2.Checked;

  aStorage.FieldByName('Fut').AsBoolean  := rbF.Checked;
  aStorage.FieldByName('Opt').AsBoolean  := rbO.Checked;
  aStorage.FieldByName('Trend2Stop').AsBoolean  := cbTrend2Stop.Checked;

  aStorage.FieldByName('Qty1').AsString := edtQty1.Text;
  aStorage.FieldByName('Qty2').AsString := edtQty2.Text;

  aStorage.FieldByName('StartTime').AsFloat := double( dtStartTime.Time );

end;

end.
