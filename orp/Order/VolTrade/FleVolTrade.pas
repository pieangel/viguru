unit FleVolTrade;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Grids, ExtCtrls, CleVolTrade,  CleQuoteTimers,
  CleSymbols, CleAccounts, GleLib
  ;

const
  FIXED = 6;

type
  TFrmVolTarde = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    sgVKospi: TStringGrid;
    cbStart: TCheckBox;
    ComboAccount: TComboBox;
    btnSymbol: TButton;
    sgCall: TStringGrid;
    sgTitle: TStringGrid;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnSymbolClick(Sender: TObject);
    procedure sgVKospiDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure ComboAccountChange(Sender: TObject);
    procedure cbStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
    FVols : TVolSymbols;
    FTimer: TQuoteTimer;
    procedure InitGrid;
    procedure OnDisplay(Sender: TObject; Value : boolean );
    procedure OnDoLog( Sender : TObject );
  public
    { Public declarations }
  end;

var
  FrmVolTarde: TFrmVolTarde;

implementation

uses
  CleFQN, GleConsts, GAppEnv;

{$R *.dfm}

procedure TFrmVolTarde.btnSymbolClick(Sender: TObject);
begin
  FVols.SetSymbol;
end;

procedure TFrmVolTarde.cbStartClick(Sender: TObject);
begin
  FVols.StartStop(cbStart.Checked);
end;

procedure TFrmVolTarde.ComboAccountChange(Sender: TObject);
var
  aAccount : TAccount;
begin

  aAccount  := GetComboObject( ComboAccount ) as TAccount;
  if aAccount = nil then Exit;
    // 선택계좌를 구함
  if (aAccount = nil) or (FVols.Account = aAccount) then Exit;

  cbStart.Checked := false;
  cbStartClick(cbStart);
  FVols.SetAccount(aAccount);
end;

procedure TFrmVolTarde.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmVolTarde.FormCreate(Sender: TObject);
begin
  FVols := TVolSymbols.Create;
  FVols.OnResult := OnDisplay;
  FVols.OnDoLog  := OnDoLog;
  InitGrid;
  gEnv.Engine.TradeCore.Accounts.GetList(ComboAccount.Items );

  FTimer:=gEnv.Engine.QuoteBroker.Timers.New;
  FTimer.Enabled := true;
  FTimer.Interval := 1000;
  FTimer.OnTimer  := Timer1Timer;

  if ComboAccount.Items.Count > 0 then
  begin
    ComboAccount.ItemIndex := 0;
    ComboAccountChange(ComboAccount);
  end;

end;

procedure TFrmVolTarde.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.QuoteBroker.Cancel( self );
  FVols.Free;
end;

procedure TFrmVolTarde.InitGrid;
begin
  sgVKospi.Cells[0,0] := 'VKOSPI';
  sgVKospi.Cells[0,1] := 'Fut';

  with sgTitle do
  begin
    Cells[0,0]  := 'code';
    Cells[1,0]  := 'last';
    Cells[2,0]  := '3s';
    Cells[3,0]  := '2s';
    Cells[4,0]  := '1s';
    Cells[5,0]  := 'sum';
  end;
end;

procedure TFrmVolTarde.OnDisplay(Sender: TObject; Value: boolean);
var
  i, j, iCall, iPut : integer;
  aItem : TVolSymbol;
begin
  iCall := 0;
  iPut := 6;
  for i := 0 to FVols.Count-1 do
  begin
    aItem := FVols.Items[i] as TVolSymbol;

    case aItem.Symbol.Spec.Market of
      mtIndex:
      begin
        for j := 0 to 4 do
          sgVKospi.Cells[ j + 1 , 0 ] := Format('%.3f', [aItem.GetData(j)]);
      end;
      mtFutures:
      begin
        for j := 0 to 4 do
          sgVKospi.Cells[ j + 1 , 1 ] := Format('%.2f', [aItem.GetData(j)]);
      end;
      mtOption:
      begin
        if (aItem.Symbol as TOption).CallPut = 'C' then
        begin
          sgCall.Cells[ 0 , iCall ] := aItem.Symbol.ShortCode;
          for j := 0 to 4 do
            sgCall.Cells[ j + 1 , iCall ] := Format('%.2f', [aItem.GetData(j)]);
          inc(iCall);
        end else
        begin
          sgCall.Cells[ 0, iPut ] := aItem.Symbol.ShortCode;
          for j := 0 to 4 do
            sgCall.Cells[ j + 1 , iPut ] := Format('%.2f', [aItem.GetData(j)]);
          inc(iPut);
        end;
      end;
    end;
  end;
end;

procedure TFrmVolTarde.OnDoLog(Sender: TObject);
var
  stLog : string;
  i, j : integer;
begin

  for I := 0 to sgVKospi.RowCount - 1 do
  begin
    stLog := '';
    for j:=0 to sgVKospi.Rows[i].Count-1 do
      stLog := stLog + Format('%8.8s', [sgVKospi.Rows[i].Strings[j]]) + ',';
    gEnv.EnvLog( WIN_GI, stLog);
  end;

  for I := 0 to sgCall.RowCount - 1 do
  begin
    stLog := '';
    for j:=0 to sgCall.Rows[i].Count-1 do
      stLog := stLog + Format('%8.8s', [sgCall.Rows[i].Strings[j]]) + ',';
    gEnv.EnvLog( WIN_GI, stLog);
  end;

  gEnv.EnvLog( WIN_GI, '');
    
end;

procedure TFrmVolTarde.sgVKospiDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
var
  aFont, aBack : TColor;
  stTxt : string;
  dFormat, iTag : Word;
  dCmp  : double;
  sgGrid : TStringGrid;
  dData : double;
begin

  aFont := clBlack;
  aBack := clWhite;
  dFormat := DT_VCENTER or DT_RIGHT;

  sgGrid := Sender as TStringGrid;
  iTag   := sgGrid.Tag;

  with sgGrid do
  begin

    stTxt := Cells[ ACol, ARow];
    aBack   := clBtnFace;
    dFormat := DT_VCENTER or DT_CENTER;

    if (ACol = 0) or (ACol = FIXED) then
      aBack := FIXED_COLOR
    else if ACol = 7 then
      aBack   := clBtnFace     
    else if ACol >= 2 then
    begin
      dData := StrToFloatDef(stTxt,0);   

      case iTag of
        2 :
          begin
            case ARow  of
              0 :  // vkospi
                begin
                  case ACol of
                    5 : dCmp := 0.012;
                    else dCmp := 0.01;
                  end;
                end;
              1 :  // 선물
                begin
                  case ACol of
                    5 : dCmp := 0.09;
                    else dCmp := 0.00;
                  end;
                end;
            end;
          end;
        3 :
          begin
            dCmp := 0.009;
          end;
      end;

      if dData > dCmp then
      begin
        aBack := LONG_COLOR;
      end else if dData < -dCmp then
      begin
        aBack := SHORT_COLOR;
      end;
    end;

    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), Rect, dFormat );
  end;

end;

procedure TFrmVolTarde.Timer1Timer(Sender: TObject);
var
  startTime : TDateTime;
begin
  startTime := EncodeTime(9,4,0,0);

  if gEnv.Engine.SymbolCore.ConsumerIndex.VIX.f0 <= 0 then
    Exit;

  if Frac(Now) > startTime then
  begin
    btnSymbolClick(nil);
    FTimer.Enabled  := false;
    btnSymbol.Enabled := false;
  end;

end;

end.
