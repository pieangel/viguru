unit FleOrderDuration;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, Grids,
  CleStorage, CleSymbols, CleOrdDurationData, Menus;

const
  DURA_COUNT = 8;
  DURA_TITLE : array[0..DURA_COUNT-1] of string =(
                '종  목','I  D','계좌번호', '소요시간', '주문시간', '주문종류', '주문번호', '단 계');
  DURA_WIDTH : array[0..DURA_COUNT-1] of integer = (
               90, 40, 60, 60, 80, 60, 70, 50);
  InsertRow = 1;

  DuraCol = 3;
  GradeCol = 7;


type
  TMyGrid = class( TStringGrid );
  TDuraConfig = class
  public
    FColor : array [0..2] of TColor;      // 0 : 선물, 1 : 콜, 2 : 풋
    FSoundDir : array [0..2] of string;
    FSoundCheck : array [0..2] of boolean;
    FOneGrade : array[0..1] of string;    // 0 : start, 1 : end
    FTwoGrade : array[0..1] of string;
    FThreeGrade : array[0..1] of string;
    FSymbolList : TList;
    constructor Create;
    destructor Destroy; override;
  end;

  TDataType = ( dtAdd, dtClear );
  TFrmDuration = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    cbReceive: TCheckBox;
    lvDura: TListView;
    sgDura: TStringGrid;
    btnSymbol: TButton;
    btnCfg: TButton;
    rbMarket: TRadioButton;
    gbMarket: TGroupBox;
    cbfut: TCheckBox;
    cbCall: TCheckBox;
    cbPut: TCheckBox;
    rbIssue: TRadioButton;
    pmList: TPopupMenu;
    nDelete: TMenuItem;
    btnClear: TButton;
    Label1: TLabel;
    lbAvg: TLabel;
    btnLog: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure cbReceiveClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure btnCfgClick(Sender: TObject);
    procedure rbMarketClick(Sender: TObject);
    procedure sgDuraDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure nDeleteClick(Sender: TObject);
    procedure btnClearClick(Sender: TObject);
    procedure cbfutClick(Sender: TObject);
    procedure btnLogClick(Sender: TObject);
  private
    { Private declarations }

    FDuraConfig : TDuraConfig;
    FFillerDataList : TList;
    procedure OnDuraDataReceive ( aSymbol : TSymbol );
    procedure InitGridColumn;
    procedure DrawListViewData( aType : TDataType;  aSymbol : TSymbol = nil );
    procedure AddDuraGridData ( aSymbol : TSymbol );
    procedure PlaySound( aSymbol : TSymbol; iDura : integer );
    procedure TotDuraGridData;
    procedure TotIssueData;
    function GetGradeColor( iGrade : integer; clBack : TColor )  : TColor;
    function FillterMarketSymbol( aSymbol : TSymbol ) : boolean;
    function GetTimeFormat( stTime : string ) : string;
    function GetGradeText(iDura : integer) : string;

  public
    { Public declarations }
    procedure LoadEnv(aStorage: TStorage);
    procedure SaveEnv(aStorage: TStorage);
  end;

var
  FrmDuration: TFrmDuration;

implementation

uses
  GAppEnv, GleLib, FleOrdDurationcfg, CleFQN, CleExcelLog;
{$R *.dfm}

{ TFrmDuration }
// 오름차 정렬 함수
function compareBySendTime(Item1 : Pointer; Item2 : Pointer) : Integer;
var
  aData1, aData2 : TOrdDurationData;
begin
  aData1 := TOrdDurationData(Item1);
  aData2 := TOrdDurationData(Item2);
  if aData1.SendTime > aData2.SendTime then
    Result := 1
  else if aData1.SendTime = aData2.SendTime then
    Result := 0
  else
    Result := -1;
end;
procedure TFrmDuration.btnCfgClick(Sender: TObject);
var
  aDlg : TFrmOrdDuarCfg;
begin
  aDlg  := TFrmOrdDuarCfg.Create( Self );
  aDlg.SetDuraConfig(FDuraConfig);
  aDlg.ShowModal;
end;

procedure TFrmDuration.btnSymbolClick(Sender: TObject);
var
  aItem : TListItem;
  aSymbol : TSymbol;
  i, iRet : integer;
begin
  if gSymbol = nil then
  begin
    gEnv.CreateSymbolSelect;
    gSymbol.SymbolCore  := gEnv.Engine.SymbolCore;
  end;

  try
    if gSymbol.Open(true) then
    begin
        // add to the cache
      gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(gSymbol.Selected);

      for i := 0 to gSymbol.ListSelected.Items.Count-1 do
      begin
        aSymbol := TSymbol( gSymbol.ListSelected.Items[i].Data );
        if aSymbol = nil then continue;

        iRet := FDuraConfig.FSymbolList.IndexOf(aSymbol);
        if iRet = -1 then
        begin
          FDuraConfig.FSymbolList.Add(aSymbol);
          DrawListViewData( dtAdd, aSymbol );
        end;
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmDuration.cbfutClick(Sender: TObject);
var
  i, j : integer;
  aMarket : TMarketType;
  aList : TStringList;
  aSymbol : TSymbol;
  aData : TOrdDurationData;
begin
  try
    btnClearClick(btnClear);
    aList := TStringList.Create;
    if cbFut.Checked then
    begin
      aMarket := mtFutures;
      gEnv.Engine.SymbolCore.Symbols.GetList2( aList, aMarket );
    end;

    if cbCall.Checked then
    begin
      aMarket := mtOption;
      gEnv.Engine.SymbolCore.Symbols.GetListCallPut( aList, aMarket, 'C' );
    end;

    if cbPut.Checked then
    begin
      aMarket := mtOption;
      gEnv.Engine.SymbolCore.Symbols.GetListCallPut( aList, aMarket, 'P' );
    end;

    for i := 0 to aList.Count - 1 do
    begin
      aSymbol := TSymbol(aList.Objects[i]);
      if aSymbol = nil then continue;

      for j := 0 to  aSymbol.OrdDurationDatas.Count - 1 do
      begin
        aData := aSymbol.OrdDurationDatas.Items[j] as TOrdDurationData;
        if aData = nil then continue;
        FFillerDataList.Add(aData);
      end;
    end;
  finally
    FFillerDataList.Sort(CompareBySendTime);
    TotDuraGridData;
  end;
end;

procedure TFrmDuration.cbReceiveClick(Sender: TObject);
begin
  if cbReceive.Checked then
    gEnv.Engine.SymbolCore.OnDuraReceive := OnDuraDataReceive
  else
    gEnv.Engine.SymbolCore.OnDuraReceive := nil;
end;

procedure TFrmDuration.AddDuraGridData(aSymbol : TSymbol);
var
  iCol, iLast, iDura : integer;
  aData : TOrdDurationData;
  stTime : string;
begin
  iLast := aSymbol.OrdDurationDatas.Count - 1;
  aData := aSymbol.OrdDurationDatas.Items[iLast] as TOrdDurationData;
  if aData = nil then exit;
  if StrToIntDef(aData.DuraTime,0) < StrToIntDef(FDuraConfig.FOneGrade[0],0) then exit;

  InsertLine( sgDura, InsertRow );
  iCol := 0;
  sgDura.Objects[ GradeCol , InsertRow ] := aSymbol;

  sgDura.Cells[ iCol, InsertRow ] := aSymbol.Name; Inc(iCol);      //종목코드
  sgDura.Cells[ iCol, InsertRow ] := aData.UserID; Inc(iCol);      //ID
  sgDura.Cells[ iCol, InsertRow ] := aData.AccountCode; Inc(iCol); //계좌번호
  iDura := StrToIntDef(aData.DuraTime, 0);
  sgDura.Cells[ iCol, InsertRow ] := IntToStr(iDura); Inc(iCol);   //소요시간
  stTime :=  GetTimeFormat( string(aData.SendTime ));
  sgDura.Cells[ iCol, InsertRow ] := stTime; Inc(iCol);            //주문생성시간
  sgDura.Cells[ iCol, InsertRow ] := aData.OrderType; Inc(iCol);   //주문타입
  sgDura.Cells[ iCol, InsertRow ] := aData.OrderNo; Inc(iCol);     //주문번호
  sgDura.Cells[ iCol, InsertRow ] := GetGradeText(iDura);          //단계

  PlaySound( aSymbol , StrToIntDef(aData.DuraTime,0));
end;

procedure TFrmDuration.DrawListViewData(aType: TDataType; aSymbol : TSymbol);
var
  aItem : TListItem;
begin
  case aType of
    dtAdd:
    begin
      aItem := lvDura.Items.Add;
      aItem.Caption := aSymbol.Name;
      aItem.Data := aSymbol;
    end;
    dtClear: lvDura.Clear;
  end;
end;

procedure TFrmDuration.btnClearClick(Sender: TObject);
var
  i : integer;
begin
  for i := 1 to sgDura.RowCount - 1 do
    sgDura.Rows[i].Clear;

  sgDura.RowCount := 2;
end;

procedure TFrmDuration.btnLogClick(Sender: TObject);
var
  ExcelLog  : TExcelLog;
  i : integer;
begin
  try
    ExcelLog  := TExcelLog.Create;
    ExcelLog.LogInit( Caption, sgDura.Rows[0] );

    for I := 1 to sgDura.RowCount - 1 do
      ExcelLog.LogData( sgDura.Rows[i], i );
  finally
    ExcelLog.Free;
  end;
end;

function TFrmDuration.FillterMarketSymbol(aSymbol: TSymbol) : boolean;
var
  iRet : integer;
begin
  Result := false;
  if rbMarket.Checked then              //Market
  begin
    if (aSymbol.Spec.Market = mtFutures) and (cbFut.Checked) then
      Result := true;

    if (aSymbol.Spec.Market = mtOption) then
    begin
      if ((aSymbol as TOption).CallPut = 'C') and ( cbCall.Checked ) then
        Result := true;

      if ((aSymbol as TOption).CallPut = 'P') and ( cbPut.Checked ) then
        Result := true;
    end;
  end else                              //Issue
  begin
    iRet := FDuraConfig.FSymbolList.IndexOf(aSymbol);
    if iRet >= 0 then Result := true;
  end;
end;

procedure TFrmDuration.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := cafree;
end;

procedure TFrmDuration.FormCreate(Sender: TObject);
begin
  FDuraConfig := TDuraConfig.Create;
  FFillerDataList := TList.Create;
  if cbReceive.Checked then
    gEnv.Engine.SymbolCore.OnDuraReceive := OnDuraDataReceive;

  InitGridColumn;
end;

procedure TFrmDuration.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.SymbolCore.OnDuraReceive := nil;
  FDuraConfig.Free;
  FFillerDataList.Free;
end;

function TFrmDuration.GetGradeColor(iGrade: integer; clBack : TColor): TColor;
var
  iDiv, iPrec : array[0..2] of integer;
begin
  iDiv[0]  := 255 - ( clBack and $FF );
  iDiv[1]  := 255 - ( (clBack and $FF00)shr 8 );
  iDiv[2]  := 255 - ( (clBack and $FF0000)shr 16 );

  iPrec[0]  := iDiv[0] div 3;
  iPrec[1]  := iDiv[1] div 3;
  iPrec[2]  := iDiv[2] div 3;

  Result  :=  RGB(  255 - ( iGrade*iPrec[0] ),
        255 - ( iGrade * iPrec[1] ),
        255 - ( iGrade * iPrec[2] ));
end;

function TFrmDuration.GetGradeText(iDura: integer): string;
begin
  Result := '';
  
  if (iDura >= StrToIntDef(FDuraConfig.FOneGrade[0],0))
      and (iDura <= StrToIntDef(FDuraConfig.FOneGrade[1],0)) then
    Result := '1단계'
  else if (iDura >= StrToIntDef(FDuraConfig.FTwoGrade[0],0))
      and (iDura <= StrToIntDef(FDuraConfig.FTwoGrade[1],0)) then
    Result := '2단계'
  else if iDura >= StrToIntDef(FDuraConfig.FThreeGrade[0],0) then
    Result := '3단계';
end;

function TFrmDuration.GetTimeFormat(stTime : string ): string;
var
  stH, stM, stS, stSS : string;
begin
  Result := '';
  if Length(stTime) = 9 then
  begin
    stH := Copy(stTime,1,2);
    stM := Copy(stTime,3,2);
    stS := Copy(stTime,5,2);
    stSS := Copy(stTime,7,3);
    Result := Format(' %s:%s:%s.%s',[stH,stM,stS,stSS]);
  end;
end;

procedure TFrmDuration.InitGridColumn;
var
  i : integer;
begin
  for i := 0 to  DURA_COUNT - 1 do
  begin
    sgDura.Cells[i, 0] := DURA_TITLE[i];
    sgDura.ColWidths[i] := DURA_WIDTH[i];
  end;
end;

procedure TFrmDuration.OnDuraDataReceive(aSymbol: TSymbol);
var
  bRet : boolean;
  iAvg : integer;
begin
  if aSymbol = nil then exit;
  bRet := FillterMarketSymbol( aSymbol );
  if not bRet then exit;
  AddDuraGridData( aSymbol );
  iAvg := gEnv.Engine.TradeCore.Orders.GetTotDuraTime;
  lbAvg.Caption := Format('%d ms', [iAvg]);
end;

procedure TFrmDuration.PlaySound(aSymbol: TSymbol; iDura : integer);
var
  stText : string;
  iCnt : integer;
  i : integer;
  bSound : boolean;
begin
  iCnt := 0;
  bSound := false;
  if rbMarket.Checked then
  begin
    if aSymbol.Spec.Market = mtFutures then
    begin
      stText := FDuraConfig.FSoundDir[0];
      bSound := FDuraConfig.FSoundCheck[0];
    end;

    if aSymbol.Spec.Market = mtOption then
    begin
      if (aSymbol as TOption).CallPut = 'C' then
      begin
        stText := FDuraConfig.FSoundDir[1];
        bSound := FDuraConfig.FSoundCheck[1];
      end;
      if (aSymbol as TOption).CallPut = 'P' then
      begin
        stText := FDuraConfig.FSoundDir[2];
        bSound := FDuraConfig.FSoundCheck[2];
      end;
    end;
  end else
  begin
    stText := aSymbol.OrdDurationDatas.SoundDir;
    bSound := aSymbol.OrdDurationDatas.SoundCheck;
  end;

  if (iDura >= StrToIntDef(FDuraConfig.FOneGrade[0],0))
      and (iDura <= StrToIntDef(FDuraConfig.FOneGrade[1],0)) then
    iCnt := 0
  else if (iDura >= StrToIntDef(FDuraConfig.FTwoGrade[0],0))
      and (iDura <= StrToIntDef(FDuraConfig.FTwoGrade[1],0)) then
    iCnt := 1
  else if iDura >= StrToIntDef(FDuraConfig.FThreeGrade[0],0) then
    iCnt := 2;

  for i := 0 to iCnt do
  begin
    if bSound then
      FillSoundPlay( stText );
  end;
end;

procedure TFrmDuration.rbMarketClick(Sender: TObject);
begin
  if rbMarket.Checked then
  begin
    cbFut.Enabled := true;
    cbCall.Enabled := true;
    cbPut.Enabled := true;
    cbfutClick(cbFut);
  end else
  begin
    cbFut.Enabled := false;
    cbCall.Enabled := false;
    cbPut.Enabled := false;
    TotIssueData;
  end;
end;

procedure TFrmDuration.LoadEnv(aStorage: TStorage);
var
  i, iCnt : integer;
  aSymbol : TSymbol;
  stCode, stTmp : string;
begin
  if aStorage = nil then Exit;
  iCnt := aStorage.FieldByName('SymbolCnt').AsInteger;

  for i := 0 to iCnt - 1 do
  begin
    stTmp := Format('Symbol%d',[i]);
    stCode :=  aStorage.FieldByName(stTmp).AsString;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);

    if aSymbol <> nil then
    begin
      stTmp := Format('Symbol%d_Sound',[i]);
      aSymbol.OrdDurationDatas.SoundDir := aStorage.FieldByName(stTmp).AsString;
      stTmp := Format('Symbol%d_Check',[i]);
      aSymbol.OrdDurationDatas.SoundCheck := aStorage.FieldByName(stTmp).AsBoolean;
      stTmp := Format('Symbol%d_Color',[i]);
      aSymbol.OrdDurationDatas.DuraColor := aStorage.FieldByName(stTmp).AsInteger;
      FDuraConfig.FSymbolList.Add(aSymbol);
      DrawListViewData( dtAdd, aSymbol );
    end;
  end;
  cbFut.Checked := aStorage.FieldByName('cbFut').AsBoolean;
  cbCall.Checked := aStorage.FieldByName('cbCall').AsBoolean;
  cbPut.Checked := aStorage.FieldByName('cbPut').AsBoolean;
  rbMarket.Checked := aStorage.FieldByName('rbMarket').AsBoolean;
  rbIssue.Checked := aStorage.FieldByName('rbIssue').AsBoolean;
  cbReceive.Checked := aStorage.FieldByName('Receive').AsBoolean;

  if (not rbMarket.Checked) and (not rbIssue.Checked) then
    rbMarket.Checked := true;
  rbMarketClick(rbMarket);

  // 선물, 콜, 풋 사운드/ 색상 Load
  with FDuraConfig do
  begin
    FColor[0] := aStorage.FieldByName('FColor').AsInteger;
    FColor[1] := aStorage.FieldByName('CColor').AsInteger;
    FColor[2] := aStorage.FieldByName('PColor').AsInteger;

    FSoundDir[0] := aStorage.FieldByName('FSound').AsString;
    FSoundDir[1] := aStorage.FieldByName('CSound').AsString;
    FSoundDir[2] := aStorage.FieldByName('PSound').AsString;

    FSoundCheck[0] := aStorage.FieldByName('FSoundCheck').AsBoolean;
    FSoundCheck[1] := aStorage.FieldByName('CSoundCheck').AsBoolean;
    FSoundCheck[2] := aStorage.FieldByName('PSoundCheck').AsBoolean;

    FOneGrade[0] := aStorage.FieldByName('OneGradeS').AsString;
    FOneGrade[1] := aStorage.FieldByName('OneGradeE').AsString;
    FTwoGrade[0] := aStorage.FieldByName('TwoGradeS').AsString;
    FTwoGrade[1] := aStorage.FieldByName('TwoGradeE').AsString;
    FThreeGrade[0] := aStorage.FieldByName('ThreeGradeS').AsString;
    FThreeGrade[1] := aStorage.FieldByName('ThreeGradeE').AsString;
  end;
end;

procedure TFrmDuration.nDeleteClick(Sender: TObject);
var
  aSymbol : TSymbol;
  iIndex : integer;
begin
  if lvDura.Selected = nil then exit;
  aSymbol := TSymbol(lvDura.Selected.Data);
  if aSymbol = nil then exit;
  
  iIndex := FDuraConfig.FSymbolList.IndexOf(aSymbol);
  FDuraConfig.FSymbolList.Delete(iIndex);
  lvDura.Selected.Delete;
  aSymbol.OrdDurationDatas.InitData;
end;

procedure TFrmDuration.SaveEnv(aStorage: TStorage);
var
  aSymbol : TSymbol;
  i : integer;
  stTmp : string;
begin
  if aStorage = nil then Exit;
  aStorage.FieldByName('SymbolCnt').AsInteger := FDuraConfig.FSymbolList.Count;
  for i := 0 to FDuraConfig.FSymbolList.Count - 1 do
  begin
    aSymbol := FDuraConfig.FSymbolList.Items[i];
    stTmp := Format('Symbol%d',[i]);
    aStorage.FieldByName(stTmp).AsString := aSymbol.Code;
    stTmp := Format('Symbol%d_Sound',[i]);
    aStorage.FieldByName(stTmp).AsString := aSymbol.OrdDurationDatas.SoundDir;
    stTmp := Format('Symbol%d_Check',[i]);
    aStorage.FieldByName(stTmp).AsBoolean := aSymbol.OrdDurationDatas.SoundCheck;
    stTmp := Format('Symbol%d_Color',[i]);
    aStorage.FieldByName(stTmp).AsInteger := Integer(aSymbol.OrdDurationDatas.DuraColor);
  end;
  aStorage.FieldByName('cbFut').AsBoolean := cbFut.Checked;
  aStorage.FieldByName('cbCall').AsBoolean := cbCall.Checked;
  aStorage.FieldByName('cbPut').AsBoolean := cbPut.Checked;
  aStorage.FieldByName('rbMarket').AsBoolean := rbMarket.Checked;
  aStorage.FieldByName('rbIssue').AsBoolean := rbIssue.Checked;
  aStorage.FieldByName('Receive').AsBoolean := cbReceive.Checked;

  // 선물, 콜, 풋 사운드/ 색상 Save
  with FDuraConfig do
  begin
    aStorage.FieldByName('FColor').AsInteger := Integer(FColor[0]);
    aStorage.FieldByName('CColor').AsInteger := Integer(FColor[1]);
    aStorage.FieldByName('PColor').AsInteger := Integer(FColor[2]);

    aStorage.FieldByName('FSound').AsString := FSoundDir[0];
    aStorage.FieldByName('CSound').AsString := FSoundDir[1];
    aStorage.FieldByName('PSound').AsString := FSoundDir[2];

    aStorage.FieldByName('FSoundCheck').AsBoolean := FSoundCheck[0];
    aStorage.FieldByName('CSoundCheck').AsBoolean := FSoundCheck[1];
    aStorage.FieldByName('PSoundCheck').AsBoolean := FSoundCheck[2];

    aStorage.FieldByName('OneGradeS').AsString := FOneGrade[0];
    aStorage.FieldByName('OneGradeE').AsString := FOneGrade[1];
    aStorage.FieldByName('TwoGradeS').AsString := FTwoGrade[0];
    aStorage.FieldByName('TwoGradeE').AsString := FTwoGrade[1];
    aStorage.FieldByName('ThreeGradeS').AsString := FThreeGrade[0];
    aStorage.FieldByName('ThreeGradeE').AsString := FThreeGrade[1];
  end;
end;

procedure TFrmDuration.sgDuraDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  stTxt, stType : string;
  dtFormat : Word;
  clFont, clBack : TColor;
  rRect : TRect;
  aSymbol : TSymbol;
  iIndex : integer;
begin
  clFont := clBlack;
  clBack := clWindow;

  dtFormat := DT_CENTER or DT_VCENTER;
  rRect := Rect;

  with Sender as TStringGrid do
  begin
    stTxt := Cells[ ACol, ARow ];
    if ARow = 0 then
      clBack := clBtnFace;

    if GradeCol = ACol then
    begin
      aSymbol := TSymbol(Objects[ ACol, ARow]);
      if aSymbol <> nil then
      begin
        if rbMarket.Checked then
        begin
          if aSymbol.Spec.Market = mtFutures then
            clBack := FDuraConfig.FColor[0];

          if aSymbol.Spec.Market = mtOption then
          begin
            if (aSymbol as TOption).CallPut = 'C' then
              clBack := FDuraConfig.FColor[1];
            if (aSymbol as TOption).CallPut = 'P' then
              clBack := FDuraConfig.FColor[2];
          end;
        end else
          clBack := aSymbol.OrdDurationDatas.DuraColor;

        iIndex := 1;
        if stTxt = '1단계' then
          iIndex := 1
        else if stTxt = '2단계' then
          iIndex := 2
        else if stTxt = '3단계' then
          iIndex := 3;

        clBack := GetGradeColor( iIndex, clBack);
        clFont := clWindow;
      end;
    end;

    Canvas.Font.Color := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect );
    rRect.Top := rRect.Top + 2;
    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, dtFormat );
  end;
end;


procedure TFrmDuration.TotDuraGridData;
var
  iCol, iDura, i, iRow : integer;
  aSymbol : TSymbol;
  aData: TOrdDurationData;
  stTime : string;
begin
  iRow := 1;
  sgDura.RowCount := FFillerDataList.Count + 2;
  for i := FFillerDataList.Count - 1 downto 0 do
  begin
    aData := FFillerDataList.Items[i];
    if aData = nil then continue;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(string(aData.SymbolCode));
    if aSymbol = nil then continue;

    if StrToIntDef(aData.DuraTime,0) < StrToIntDef(FDuraConfig.FOneGrade[0],0) then continue;
    iCol := 0;
    sgDura.Objects[ GradeCol , iRow ] := aSymbol;

    sgDura.Cells[ iCol, iRow ] := aSymbol.Name; Inc(iCol);      //종목코드
    sgDura.Cells[ iCol, iRow ] := aData.UserID; Inc(iCol);      //ID
    sgDura.Cells[ iCol, iRow ] := aData.AccountCode; Inc(iCol); //계좌번호
    iDura := StrToIntDef(aData.DuraTime, 0);
    sgDura.Cells[ iCol, iRow ] := IntToStr(iDura); Inc(iCol);   //소요시간
    stTime := GetTimeFormat( string(aData.SendTime) );
    sgDura.Cells[ iCol, iRow ] := stTime; Inc(iCol);            //주문생성시간
    sgDura.Cells[ iCol, iRow ] := aData.OrderType; Inc(iCol);   //주문타입
    sgDura.Cells[ iCol, iRow ] := aData.OrderNo; Inc(iCol);     //주문번호
    sgDura.Cells[ iCol, iRow ] := GetGradeText(iDura);          //단계
    inc(iRow);
  end;
  FFillerDataList.Clear;
end;

procedure TFrmDuration.TotIssueData;
var
  i,j : integer;
  aSymbol : TSymbol;
  aData : TOrdDurationData;
begin
  try
    for i := 0 to FDuraConfig.FSymbolList.Count - 1 do
    begin
      aSymbol := FDuraConfig.FSymbolList.Items[i];
      if aSymbol = nil then continue;

      for j := 0 to  aSymbol.OrdDurationDatas.Count - 1 do
      begin
        aData := aSymbol.OrdDurationDatas.Items[j] as TOrdDurationData;
        if aData = nil then continue;
        FFillerDataList.Add(aData);
      end;
    end;
  finally
    FFillerDataList.Sort(CompareBySendTime);
    TotDuraGridData;
  end;
end;

{ TConfig }

constructor TDuraConfig.Create;
begin
  FSymbolList := TList.Create;
  FOneGrade[0] := '20';
  FOneGrade[1] := '40';
  FTwoGrade[0] := '41';
  FTwoGrade[1] := '80';
  FThreeGrade[0] := '81';
end;

destructor TDuraConfig.Destroy;
begin
  FSymbolList.Free;
  inherited;
end;

end.
