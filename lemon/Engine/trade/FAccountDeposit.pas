unit FAccountDeposit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GleTypes,
  CleSymbols,
  CleAccounts, ClePositions, CleDistributor, Grids, StdCtrls, ExtCtrls, ComCtrls,

  CleStorage, Buttons

  ;

type
  TFrmAccountDeposit = class(TForm)
    PageControl1: TPageControl;
    tsDeposit: TTabSheet;
    tsAbleQty: TTabSheet;
    Panel1: TPanel;
    cbAccount: TComboBox;
    Button1: TButton;
    Panel2: TPanel;
    sgPL: TStringGrid;
    Panel3: TPanel;
    sgMargin: TStringGrid;
    Panel4: TPanel;
    cbAccount2: TComboBox;
    Button4: TButton;
    Label1: TLabel;
    rbS: TRadioButton;
    rbL: TRadioButton;
    Label2: TLabel;
    cbSymbol: TComboBox;
    Button3: TButton;
    Label3: TLabel;
    Edit1: TEdit;
    sgResult: TStringGrid;
    Label4: TLabel;
    cbPriceControl: TComboBox;
    Botton2: TSpeedButton;
    procedure sgPLDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure cbAccountChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure cbSymbolChange(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure cbAccount2Change(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure Botton2Click(Sender: TObject);

  private
    { Private declarations }
    FH, FTop, FLeft : integer;
    FInvest : TInvestor;
    FInvest2: TInvestor;
    FSymbol : TSymbol;

    procedure UpdateData;
    procedure UpdateData2( aPos : TPosition );
    procedure OrderEventHandler(Sender, Receiver: TObject; DataID: Integer;
      DataObj: TObject; EventID: TDistributorID);
    procedure InPutData(sgGrid: TStringGrid; dVal : double;ACol, ARow: integer;
               bBlack : boolean = false);
  public
    { Public declarations }
    procedure LoadEnv( aStorage : TStorage );
    procedure SaveEnv( aStorage : TStorage );
  end;

var
  FrmAccountDeposit: TFrmAccountDeposit;

implementation

uses
  GAppEnv, GleLib , GleConsts, GAppForms  ,
  Math
  ;

{$R *.dfm}

procedure TFrmAccountDeposit.Botton2Click(Sender: TObject);
var
  stLog : string;
begin
  if FInvest <> nil then
    if FInvest.PassWord = '' then
    begin
      stLog  := '???? ???????? ?? ????';
      stLog  := stLog + #13+#10+#13+#10;
      stLog  := stLog + '???????? ???????????? ?????????????????';
      if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      begin
        gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0);
        Exit;
      end else
        Exit
    end else
      gEnv.Engine.SendBroker.RequestAccountAdjustMent( FInvest );

end;

procedure TFrmAccountDeposit.Button1Click(Sender: TObject);
begin
  if Panel3.Visible then
  begin
    //FTop:= Top;
    //FLeft:= Left;
    Height := Height - Panel3.Height;
    Panel3.Visible :=  false;
    button1.Caption := '+??????';
  end
  else begin
    Height := FH;
    //Top := FTop;
    //Left:= FLeft;
    Panel3.Visible :=  true;
    button1.Caption := '-??????';
  end;
end;


procedure TFrmAccountDeposit.Button3Click(Sender: TObject);
begin

  if gSymbol = nil then
    gEnv.CreateSymbolSelect;

  try
    if gSymbol.Open then
    begin
      if ( gSymbol.Selected <> nil ) and ( FSymbol <> gSymbol.Selected ) then
      begin
        FSymbol := gSymbol.Selected;
        AddSymbolCombo( FSymbol, cbSymbol );
        Edit1.Text  := Format('%.*f', [ FSymbol.Spec.Precision, FSymbol.Last ]);
      end;
    end;
  finally
    gSymbol.Hide;
  end;
end;

procedure TFrmAccountDeposit.Button4Click(Sender: TObject);
var
  stLog : string;
  dTmp  : double;
begin

  if FInvest2 <> nil then
    if FInvest2.PassWord = '' then
    begin
      stLog  := '???? ???????? ?? ????';
      stLog  := stLog + #13+#10+#13+#10;
      stLog  := stLog + '???????? ???????????? ?????????????????';
      if (MessageDlg( stLog, mtInformation, [mbYes, mbNo], 0) = mrYes ) then
      begin
        gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0);
        Exit;
      end else
        Exit
    end else begin

      if cbPriceControl.ItemIndex = 1 then
        stLog := '0'
      else begin
        dTmp  := StrToFloatDef( edit1.Text, 0 );
        if  dTmp < PRICE_EPSILON then
          if FSymbol = nil then
            Exit
          else dTmp := FSymbol.Last;

        stLog := IntToStr( Round( dTmp * 100  ));
      end;

      gEnv.Engine.SendBroker.RequestAccountAbleQty( FInvest2, FSymbol, ifThen( rbS.Checked, -1, 1 ),
        cbPriceControl.ItemIndex + 1 , stLog );
    end;

end;

procedure TFrmAccountDeposit.cbAccount2Change(Sender: TObject);
var
  aInvest : TInvestor;
begin

  aInvest := TInvestor( cbAccount2.Items.Objects[ cbAccount2.ItemIndex]);
  if FInvest2 <> aInvest then
    FInvest2 := aInvest;
end;

procedure TFrmAccountDeposit.cbAccountChange(Sender: TObject);
var
  aInvest : TInvestor;
begin

  aInvest := TInvestor( cbAccount.Items.Objects[ cbAccount.ItemIndex]);
  if FInvest <> aInvest then
  begin
    FInvest := aInvest;
    UpdateData;
  end;

end;

procedure TFrmAccountDeposit.cbSymbolChange(Sender: TObject);
var
  aSymbol : TSymbol;
begin
  aSymbol := TSymbol( cbSymbol.Items.Objects[ cbSymbol.ItemIndex ] );
  if FSymbol <> aSymbol then
  begin
    FSymbol := aSymbol;
    Edit1.Text  := FSymbol.PriceToStr( FSymbol.Last);
  end;
end;

procedure TFrmAccountDeposit.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TFrmAccountDeposit.FormCreate(Sender: TObject);
begin

  with sgPL do
  begin
    Cells[0,0]  := '????????';
    Cells[0,1]  := '????????';
    Cells[0,2]  := '????????';
    Cells[2,0]  := '????????????';
    Cells[2,1]  := '??????';
    Cells[2,2]  := '??????';

    ColWidths[0]  := ColWidths[0] - 10;
    ColWidths[1]  := ColWidths[1] + 10;
    ColWidths[2]  := ColWidths[0];
    ColWidths[3]  := ColWidths[1];
  end;

  with sgMargin do
  begin
    Cells[0,0]  := '??????????';
    Cells[0,1]  := '??????????';

    Cells[2,0]  := '????????????';
    Cells[2,1]  := '??????????';

    ColWidths[0]  := ColWidths[0] - 10;
    ColWidths[1]  := ColWidths[1] + 10;
    ColWidths[2]  := ColWidths[0];
    ColWidths[3]  := ColWidths[1];
  end;

  with sgResult do
  begin
    Cells[0,0]  := '????????????????';
    Cells[0,1]  := '????????????????';
  end;  

  gEnv.Engine.TradeCore.Investors.GetList2( cbAccount.Items );
  if cbAccount.Items.Count > 0 then
  begin
    cbAccount.ItemIndex := 0;
    cbAccountChange( nil );
  end;

  gEnv.Engine.TradeCore.Investors.GetList2( cbAccount2.Items );
  if cbAccount2.Items.Count > 0 then
  begin
    cbAccount2.ItemIndex := 0;
    cbAccount2Change( nil );
  end;

  gEnv.Engine.TradeBroker.Subscribe( Self, OrderEventHandler );

  FH  := Height;
  FTop:= Top;
  FLeft:= Left;
  
  Height := Height - Panel3.Height;
end;

procedure TFrmAccountDeposit.FormDestroy(Sender: TObject);
begin
  gEnv.Engine.TradeBroker.Unsubscribe( Self );
end;

procedure TFrmAccountDeposit.OrderEventHandler(Sender, Receiver: TObject;
  DataID: Integer; DataObj: TObject; EventID: TDistributorID);
  var
    aInvest : TInvestor;
    aPos : TPosition;
begin
  if (Receiver <> Self) or (DataObj = nil) then Exit;

  case Integer(EventID) of
    ACCOUNT_DEPOSIT :
      begin
        aInvest := DataObj as Tinvestor;
        if aInvest = FInvest then UpdateData;
      end;
    POSITION_ABLEQTY :
      begin
        aPos := DataObj as TPosition;
        //if aPos.Account.InvestCode = FInvest2.Code then UpdateData2( aPos );
        if aPos.Account = FInvest2 then UpdateData2( aPos );
      end
    else
      Exit;
  end;
end;

procedure TFrmAccountDeposit.PageControl1Change(Sender: TObject);
begin
  if PageControl1.ActivePageIndex = 1 then
    Height := FH
  else
    if Panel3.Visible then
      Height := FH
    else
      Height := Height - Panel3.Height;
end;



procedure TFrmAccountDeposit.InPutData( sgGrid : TStringGrid; dVal : double;
  ACol, ARow : integer; bBlack : boolean );
begin
  with sgGrid do
  begin
    Cells[ ACol, ARow ] := FormatFloat('#,##0', dVal );
    if not bBlack then
      Objects[ACol,ARow ] := Pointer( ifThenColor( dVal > 0 , clRed,
                                    ifThenColor( dVal < 0,  clBlue, clBlack )));
  end;
end;



procedure TFrmAccountDeposit.UpdateData;
begin

  if FInvest = nil then Exit;

  InPutData( sgPL, FInvest.Deposit, 1, 0, true );
  InPutData( sgPL, FInvest.OpenPL , 1, 1 );
  InPutData( sgPL, FInvest.LiquidPL , 1, 2 );

  InPutData( sgPL, FInvest.DepositOTE , 3, 0 , true);
  InPutData( sgPL, abs(FInvest.RecoverFees), 3, 1, true );
  InPutData( sgPL, FInvest.OpenPL + FInvest.LiquidPL - abs(FInvest.RecoverFees) , 3, 2 );

  InPutData( sgMargin, FInvest.TrustMargin, 1, 0, true );
  InPutData( sgMargin, FInvest.HoldMargin , 1, 1, true );

  InPutData( sgMargin, FInvest.EAbleAmt , 3, 0, true );
  InPutData( sgMargin, FInvest.AddMargin, 3, 1, true );


end;

procedure TFrmAccountDeposit.UpdateData2( aPos : TPosition );
var
  iQty : integer;
begin
  if rbS.Checked then
    iQty := aPos.AbleQty[ptShort]
  else
    iQty := aPos.AbleQty[ptLong];

  InPutData( sgResult, iQty , 1, 0 , true);
  InPutData( sgResult, aPos.LiqQty  , 1, 1, true );
end;

procedure TFrmAccountDeposit.sgPLDrawCell(Sender: TObject; ACol,
  ARow: Integer; Rect: TRect; State: TGridDrawState);
  var
    aGrid : TStringGrid;
    aBack, aFont : TColor;
    dFormat : Word;
    stTxt : string;
    aRect : TRect;
    aPos : TPosition;
begin
  aGrid := Sender as TStringGrid;

  aFont   := clBlack;
  dFormat := DT_CENTER or DT_VCENTER;
  aRect   := Rect;
  aBack   := clWhite;

  with aGrid do
  begin
    stTxt := Cells[ ACol, ARow];

    case ACol of
      0, 2 :
        begin
          aBack := clBtnFace
        end
      else begin
        if Objects[ACol, ARow] <> nil then
          aFont :=  TColor( Objects[ACol, ARow]);
        dFormat := DT_RIGHT or DT_VCENTER;
        aRect.Right := aRect.Right -2;

        if ( aGrid.Tag = 0 ) and ( ACol = 3 ) and ( ARow = 1 ) then
          aBack  :=  clMoneyGreen;

      end;
    end;


    Canvas.Font.Color   := aFont;
    Canvas.Brush.Color  := aBack;
    Canvas.FillRect( Rect);

    aRect.Top := aRect.Top + 4;

    Canvas.Font.Name :='??????';
    Canvas.Font.Size := 9;

    DrawText( Canvas.Handle, PChar( stTxt ), Length( stTxt ), aRect, dFormat );

    if (ACol = 0) or ( ACol = 2) then begin
      Canvas.Pen.Color := clBlack;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Right, Rect.Bottom),
                       Point(Rect.Right, Rect.Top)]);
      Canvas.Pen.Color := clWhite;
      Canvas.PolyLine([Point(Rect.Left,  Rect.Bottom),
                       Point(Rect.Left,  Rect.Top),
                       Point(Rect.Right, Rect.Top)]);
    end;

  end;

end;


procedure TFrmAccountDeposit.LoadEnv(aStorage: TStorage);
var
  stCode : string;
  aInvest : TInvestor;
begin
  if aStorage = nil then Exit;

  stCode := aStorage.FieldByName('invest').AsString;
  aInvest := gEnv.Engine.TradeCore.Investors.Find( stCode );
  if aInvest <> nil then
  begin
    SetComboIndex( cbAccount, aInvest );
    cbAccountChange( cbAccount );
  end;
end;

procedure TFrmAccountDeposit.SaveEnv(aStorage: TStorage);
begin
  if aStorage = nil then Exit;

  if FInvest <> nil then
    aStorage.FieldByName('invest').AsString := FInvest.Code
  else
    aStorage.FieldByName('invest').AsString := '';
end;

end.
