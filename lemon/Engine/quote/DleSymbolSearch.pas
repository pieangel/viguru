unit DleSymbolSearch;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  CleSymbols,  CleQuoteBroker, GleConsts,
  StdCtrls, ComCtrls, CommCtrl, Buttons, Grids, ExtCtrls
  ;

type
  TSymbolSearch = class(TForm)
    plFillter: TPanel;
    plInfo: TPanel;
    plSelected: TPanel;
    sgInfo: TStringGrid;
    Label2: TLabel;
    Label3: TLabel;
    refreshTimer: TTimer;
    GroupBox1: TGroupBox;
    Label12: TLabel;
    edtWeight: TEdit;
    udWeight: TUpDown;
    Label11: TLabel;
    udRemainDaysTo: TUpDown;
    edtRemainDaysTo: TEdit;
    Label6: TLabel;
    Label4: TLabel;
    edtVolume: TEdit;
    udVolume: TUpDown;
    Label5: TLabel;
    GroupBox2: TGroupBox;
    Label7: TLabel;
    edtTickRatioTo: TEdit;
    udTickRatio: TUpDown;
    Label8: TLabel;
    edtTickRatioFrom: TEdit;
    UpDown1: TUpDown;
    Label9: TLabel;
    edtSpread: TEdit;
    udSpread: TUpDown;
    Label10: TLabel;
    listUnderlying: TListBox;
    listLP: TListBox;
    Button3: TButton;
    Button4: TButton;
    SpeedButton2: TSpeedButton;
    Button2: TButton;
    Panel1: TPanel;
    ckAuto: TCheckBox;
    cbSec: TComboBox;
    cbSymbol: TComboBox;
    Label1: TLabel;
    edtRemainDaysFrom: TEdit;
    udRemainDaysFrom: TUpDown;
    SpeedButtonPrefs: TSpeedButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure udTickRatioClick(Sender: TObject; Button: TUDBtnType);
    procedure edtVolumeKeyPress(Sender: TObject; var Key: Char);
    procedure ckAutoClick(Sender: TObject);
    procedure cbSecChange(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure refreshTimerTimer(Sender: TObject);
    procedure sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure sgInfoDblClick(Sender: TObject);

    procedure UpDown1Click(Sender: TObject; Button: TUDBtnType);
    procedure sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
      State: TGridDrawState);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FSelected : TSymbol;   // 선택한 종목
    FSelectRow: integer;
    FSymbolRow: Integer;

    procedure init;
    function Open: Boolean;
    procedure UpdateSymbol( bFlag : boolean );
    procedure Clear;

    procedure SetFillteringCondition;

    procedure initControl;
    function IsContinue( aQuote : TQuote; index : integer = 0 ) : boolean;
    procedure update;

  end;

var
  SymbolSearch: TSymbolSearch;

implementation

uses GAppEnv, DleSymbolConfig, FOrderBoard, CleFQN;

{$R *.dfm}

procedure TSymbolSearch.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TSymbolSearch.Button3Click(Sender: TObject);
var
  aDlg : TSymbolFillter;
begin
  try
    aDlg := TSymbolFillter.Create( self );
    aDlg.init(1, self);
    aDlg.Show;
  except
  end;

end;

procedure TSymbolSearch.Button4Click(Sender: TObject);
var
  aDlg : TSymbolFillter;
begin
  try
    aDlg := TSymbolFillter.Create( self );
    aDlg.init(0, self);
    aDlg.Show;
  except
  end;

end;

procedure TSymbolSearch.cbSecChange(Sender: TObject);
var iSec : integer;
begin
  iSec := cbSec.ItemIndex + 1;
  refreshTimer.Interval := iSec * 10000;

end;

procedure TSymbolSearch.edtVolumeKeyPress(Sender: TObject; var Key: Char);
begin
  if not (Key in ['0'..'9',#13]) then
    Key := #0;
end;

procedure TSymbolSearch.ckAutoClick(Sender: TObject);
begin
  cbSec.Enabled := ckAuto.Checked;
  if not ckAuto.Checked then
    refreshTimer.Enabled  := false
  else
    refreshTimer.Enabled  := true;
end;

procedure TSymbolSearch.Clear;
var
  i : integer;
begin
  for i := 1 to sgInfo.RowCount - 1 do
    sgInfo.Rows[i].Clear;
end;

procedure TSymbolSearch.cbSymbolChange(Sender: TObject);
var
  aForm : TForm;
  aSymbol : TSymbol;
begin

  if cbSymbol.Items.Count > 0 then
  begin

    aSymbol := cbSymbol.Items.Objects[ cbSymbol.ItemIndex ] as TSymbol;

    if aSymbol <> nil then
    begin
      if Fselected = nil then
        FSelected := aSymbol
      else
        if FSelected = aSymbol then
          Exit
        else
          FSelected := aSymbol;

      aForm := gEnv.Engine.FormBroker.Selected;

      if aForm <> nil then
      begin
        TOrderBoardForm( aForm ).SetExSymbol( FSelected, FSelected.Spec.Market );
        gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(FSelected);
        if cbSymbol.Items.IndexOfObject( FSelected ) < 0then
          cbSymbol.AddItem( FSelected.Name, FSelected );
      end;
    end;  // if aSymbol
  end;

end;

procedure TSymbolSearch.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action  := caFree;
end;

procedure TSymbolSearch.FormCreate(Sender: TObject);
begin
  init;
  UpdateSymbol( true );
end;

procedure TSymbolSearch.init;
begin
  // 기초자산
  FSelectRow  := -1;
  FSymbolRow  := -1;

  initControl;

  with sgInfo do
  begin
    ColCount  := 10;

    Cells[0, 0] := '종목명';
    Cells[1, 0] := 'L P';
    Cells[2, 0] := 'LP비중';
    Cells[3, 0] := '잔존일';
    Cells[4, 0] := '현재가';

    Cells[5, 0] := '매도잔량';
    Cells[6, 0] := '틱델타';
    Cells[7, 0] := '틱비율';
    Cells[8, 0] := 'SP';
    Cells[9, 0] := '거래량';

    ColWidths[0]  := 130;
    ColWidths[1]  := 40;
    ColWidths[2]  := 60;
    ColWidths[3]  := 40;
    ColWidths[4]  := 40;

    ColWidths[5]  := 50;
    ColWidths[6]  := 50;
    ColWidths[7]  := 50;
    Colwidths[8]  := 50;
    Colwidths[9]  := 90;
  end;

  gEnv.Engine.GiFillter.GetLpList( listLp.Items );
  gEnv.Engine.GiFillter.GetUnderlyingList(listUnderlying.Items);

  gEnv.Engine.SymbolCore.SymbolCache.GetList2(cbSymbol.Items, mtElw);

end;


function TSymbolSearch.Open: Boolean;
begin
  Result := (ShowModal = mrOK);
end;

procedure TSymbolSearch.refreshTimerTimer(Sender: TObject);
begin
  UpdateSymbol( true );
end;

procedure TSymbolSearch.SetFillteringCondition;
begin
  with gEnv.Engine.GiFillter do
  begin
    LpWeight  := StrToIntDef( edtWeight.Text, 0 );
    RemainDaysTo:= StrToIntDef( edtRemainDaysTo.Text, 0 );
    RemainDaysFrom:= StrToIntDef( edtRemainDaysFrom.Text, 0 );
    Volume    := StrToFloatDef( edtVolume.Text, 0 );
    TickRatioTo   := StrToFloatDef( edtTickRatioTo.Text, 0.0);
    TickRatioFrom := StrToFloatDef( edtTickRatioFrom.Text, 0.0);
    Spread        := StrToIntDef( edtSpread.Text, 0 );
    AutoQuery     := ckAuto.Checked;
    AutoSecIndex  := cbSec.ItemIndex;
  end;
end;

procedure TSymbolSearch.initControl;

begin
  with gEnv.Engine.GiFillter do
  begin
    udWeight.Position := LpWeight;
    udRemainDaysTo.Position := RemainDaysTo;
    udRemainDaysFrom.Position := RemainDaysFrom;
    udSpread.Position := Spread;

    edtVolume.Text  := FloatToStr( Volume );
    edtTickRatioTo.Text   := Format('%.3f', [TickRatioTo] );
    edtTickRatioFrom.Text := Format('%.3f', [TickRatioFrom] );

    cbSec.ItemIndex := AutoSecIndex;
    ckAuto.Checked  := AutoQuery;
  end;

end;


procedure TSymbolSearch.sgInfoDblClick(Sender: TObject);
var
  aForm : TForm;
begin

  if FSelectRow < 1 then Exit;
  FSelected :=  TSymbol( sgInfo.Objects[0, FSelectRow]);
  if Fselected = nil then Exit;

  aForm := gEnv.Engine.FormBroker.Selected;

  if aForm <> nil then
  begin
    TOrderBoardForm( aForm ).SetExSymbol( FSelected, FSelected.Spec.Market );
    gEnv.Engine.SymbolCore.SymbolCache.AddSymbol(FSelected);
    if cbSymbol.Items.IndexOfObject( FSelected ) < 0then
      cbSymbol.AddItem( FSelected.Name, FSelected );
  end;

end;

procedure TSymbolSearch.sgInfoDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
  var
    stTxt : string;
    clBack, clFont : TColor;
    dtFormat : Word;
    rRect : TRect;
begin
  clBack := clWhite;
  clFont := clBlack;
  dtFormat := DT_LEFT or DT_VCENTER;
  rRect := Rect;

  with sgInfo do
  begin
    stTxt := Cells[ACol, ARow ];

    if ARow > 0 then
    begin
      if ACol in [2..9] then
        dtFormat  :=  DT_RIGHT or DT_VCENTER
      else if ACol = 1 then
        dtFormat  :=  DT_CENTER or DT_VCENTER;
    end
    else if ARow = 0 then begin
      clBack := clBtnFace;
      dtFormat := DT_CENTER or DT_VCENTER;
    end;

    if ( ARow = FSelectRow ) and ( ARow > 0) then begin
      clBack := $00F2BEB9;
    end;

    if ( ARow = FSymbolRow ) and ( FSymbolRow <> FSelectRow ) and ( ARow > 0 ) then
    begin
      clBack := clSilver;
    end;

    Canvas.Font.Color := clFont;
    Canvas.Brush.Color  := clBack;
    Canvas.FillRect( Rect );
    rRect.Right := rRect.Right - 2;

    DrawText( Canvas.Handle,  PChar( stTxt ), Length( stTxt ), rRect, dtFormat );
  end;

end;


procedure TSymbolSearch.sgInfoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
  var
    ARow, ACol : integer;

begin
  sgInfo.MouseToCell(X, Y, ACol, FSelectRow );
  sgInfo.Repaint;
end;

procedure TSymbolSearch.SpeedButton2Click(Sender: TObject);
begin
  SetFillteringCondition;
  UpdateSymbol( true );
end;


procedure TSymbolSearch.udTickRatioClick(Sender: TObject; Button: TUDBtnType);
var
  dRatio : double;
begin
  dRatio  := StrToFloatDef( edtTickRatioTo.Text, 0 );
  if Button = btNext then
    dRatio  := dRatio + 0.1
  else
    dRatio  := dRatio - 0.1;

  edtTickRatioTo.Text := Format( '%.3f', [ dRatio ] );

end;

procedure TSymbolSearch.update;
begin
  listLp.Clear;
  listUnderlying.Clear;
  gEnv.Engine.GiFillter.GetLpList( listLp.Items );
  gEnv.Engine.GiFillter.GetUnderlyingList(listUnderlying.Items);

  initControl;
end;

procedure TSymbolSearch.UpdateSymbol(bFlag: boolean);
var
  i, iCol, iCnt: Integer;
  aSymbol : TSymbol;
  aQuote  : TQuote;
  bCheck : boolean;
  stLog : string;
  aLp : TLp;
begin

  Clear;

  with sgInfo do  begin

  //RowCount :=  gEnv.Engine.QuoteBroker.SortList.Count ;
  iCnt := 0;

  for i := 0 to gEnv.Engine.QuoteBroker.SortList.Count - 1 do
  begin
    iCol := 0;
    aQuote := TQuote(gEnv.Engine.QuoteBroker.SortList.Items[i]);

    if aQuote = nil then
    begin
      Continue;
    end;
    aSymbol := aQuote.Symbol;

    bCheck := IsContinue( aQuote, i );
    if not bCheck then begin
      inc( iCnt );
      Continue;
    end;

    Objects[iCol, i+1-iCnt] := aSymbol;
    Cells[iCol , i+1-iCnt]  := Trim( aSymbol.Name );
    inc(iCol);
    // LP
    aLp := gEnv.Engine.SymbolCore.LPs.Find( (aSymbol as TElw).LPCode);
    if aLp <> nil then
      Cells[iCol , i+1-iCnt]  := Copy(aLp.LpName, 1, 4)
    else
      Cells[iCol , i+1-iCnt]  := '';
    inc(iCol);

    // LP 비중
    Cells[iCol, i+1-iCnt]   := Format('%.2f%s', [ (aSymbol as TElw).LPGravity,'%' ] );
    inc(iCol);
    // 잔존일
    Cells[iCol, i+1-iCnt]   := IntToStr( ( aSymbol as TElw ).DaysToExp );
    inc(iCol);
    // 현재가
    Cells[iCol , i+1-iCnt]  := Format('%.*n', [ aSymbol.Spec.Precision, aSymbol.Last ]);
    inc(iCol);

    // 매도잔량
    Cells[iCol , i+1-iCnt]  := FormatFloat('#,##0',  aQuote.Asks[0].Volume );
    inc(iCol);

    // 틱델타
    Cells[iCol , i+1-iCnt]  := Format('%.3f', [ aSymbol.TickDelta ] );
    inc(iCol);
    // 틱비율
    Cells[iCol , i+1-iCnt]  := Format('%.3f', [ aSymbol.TickRatio ] );
    inc(iCol);
    // SP
    Cells[iCol , i+1-iCnt]  := Format('%s / %d', [ aSymbol.LpHogaSpread, aSymbol.HogaSpread ]);
    inc(iCol);
    // 거래량
    if aQuote.Sales.Last <> nil then
      Cells[iCol , i+1-iCnt] := Format('%.0n',[aQuote.Sales.Last.DayVolume*1.0])
    else
      Cells[iCol , i+1-iCnt] := '0';
    inc(iCol);

    if aSymbol = FSelected then
      FSymbolRow  := i+1-iCnt;
  end;

  RowCount := gEnv.Engine.QuoteBroker.SortList.Count - iCnt + 1;

  if RowCount > 1 then
    FixedRows := 1;

  end; // with
end;

function TSymbolSearch.IsContinue(aQuote: TQuote; index : integer): boolean;
var
  aElw : TElw;
  i, iRes : integer;
  bRes : boolean;
  stLog, stTmp , staa, aa, bb: string;
  aLp : TLp;
begin
  result := false;
  aElw := aQuote.Symbol as TElw;

  aLp := gEnv.Engine.SymbolCore.LPs.Find( aElw.LPCode);
  if aLp <> nil then
    stTmp  := aLp.LpName
  else
    stTmp  := '';

  if aQuote.Sales.Last <> nil then
    staa := Format('%.0n',[aQuote.Sales.Last.DayVolume*1.0])
  else
    staa := '0';


  with gEnv.Engine.GiFillter do
  begin
    {
    aa := '';
    for i := 0 to Underlyings.Count - 1 do
      aa := aa + ',' + TSymbol(Underlyings.Objects[i]).Name;

    bb  := '';
    for i := 0 to Lps.Count - 1 do
      bb := bb + ',' +Lps[i];

    stLog := Format('%d : %s(%s), %s(%s), 비중 : %s>%d, 잔 :%s>%s>%s, 틱 : %s>%s>%s, sp: %d>%d, vol :%s>%s',
        [
        index,
        aElw.Name, aa,
        stTmp,  bb,
        Format('%.2f%s', [ aElw.LPGravity,'%' ] ), lpWeight,
        IntToStr( RemainDaysTo ), IntToStr( aElw.DaysToExp ), IntToStr( RemainDaysFrom ),
        Format('%.3f', [ TickRatioTo ] ), Format('%.3f', [ aElw.TickRatio ] ), Format('%.3f', [ TickRatioFrom ] ),
        aElw.HogaSpread ,  Spread,
        Format('%.0f', [Volume]), staa
        ]);

    //gEnv.DoLog(WIN_ELW, stLog);
     }
    // 1. 수치 비교
    if (aElw.TickRatio > TickRatioTo) or (aElw.TickRatio < TickRatioFrom ) then
      Exit;

    if (aElw.HogaSpread > Spread) or (aElw.HogaSpread < 0)then
      Exit;

    if aQuote.Sales.Count > 0 then begin
      if aQuote.Sales[0].DayVolume < Volume then
        Exit;
    end
    else Exit;

    if aElw.lpGravity > lpWeight then
      Exit;

    if (aElw.DaysToExp > RemainDaysTo) or (aElw.DaysToExp < RemainDaysFrom ) then
      Exit;

    // 2. 종목 비교
    iRes := IsCheckSymbol( aElw );

    if iRes < 0 then
      Exit;

    bRes := IsCheckLp( aElw.LPCode );
    if not bRes then
      Exit;

  end;

  Result := true;

end;


procedure TSymbolSearch.UpDown1Click(Sender: TObject; Button: TUDBtnType);
var
  dRatio : double;
begin
  dRatio  := StrToFloatDef( edtTickRatioFrom.Text, 0 );
  if Button = btNext then
    dRatio  := dRatio + 0.1
  else
    dRatio  := dRatio - 0.1;

  edtTickRatioFrom.Text := Format( '%.3f', [ dRatio ] );
end;

end.
