unit DataMenu;

interface

uses
  SysUtils, Classes, Menus, Controls, Forms, 

  GAppForms, Dialogs,

  CleStorage
  ;

type
  TDataModule1 = class(TDataModule)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Exit1: TMenuItem;
    Research1: TMenuItem;
    Skew1: TMenuItem;
    Order1: TMenuItem;
    OrderBoard1: TMenuItem;
    N3: TMenuItem;
    N20: TMenuItem;
    Orders1: TMenuItem;
    StopOrderList1: TMenuItem;
    OpenDialog: TOpenDialog;
    N1: TMenuItem;
    N2: TMenuItem;
    Multi: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    stg: TMenuItem;
    USIN123: TMenuItem;
    USH11Min: TMenuItem;
    N5: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    VolTrade1: TMenuItem;
    N9: TMenuItem;
    USH25Min1: TMenuItem;
    N10: TMenuItem;
    N11: TMenuItem;
    ShortVol1: TMenuItem;
    USIN1: TMenuItem;
    N12: TMenuItem;
    SBO1: TMenuItem;
    MultiChart1: TMenuItem;
    N13: TMenuItem;
    procedure concernClick(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure Help1Click(Sender: TObject);
    procedure N7Click(Sender: TObject);
  private

    procedure FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
    procedure FormOpen(iFormID, iVar: Integer; var aForm: TForm);
    procedure FormReLoad(iFormID: integer; aForm: TForm);
    procedure FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
    { Private declarations }
  public
    { Public declarations }
    procedure init;
    procedure OpenWins;
  end;

var
  DataModule1: TDataModule1;

implementation

uses
  GAppEnv  ,
  CleFormBroker,  GleConsts, FOrpMain, FleStopOrderList,  FAccountPassWord,
  FOrderBoard, FAppInfo, DBoardEnv, FleOrderList2, FleMiniPositionList , FAccountDeposit,
  FFundOrderBoard, FleFundMiniPositionList,

  ///
  FHulTrade  ,FUsdH2_5Min , FUs_In_123 , FUsdH1_1Min, FTrendTrade, FleStrangle, FShortHult,
  FUsI2_5Min , FSystemOrder,
  FleSBreakOut
  ;

{$R *.dfm}

procedure TDataModule1.concernClick(Sender: TObject);
begin
  if (Sender = nil) or not (Sender is TComponent) then Exit;

  if not gEnv.RecoveryEnd then Exit;  

  case (Sender as TComponent).Tag of
      // file
    100: OpenWins;
    999: Application.Terminate;
      // skew
    201: gEnv.Engine.FormBroker.Open(ID_SKEW, 0); // skew chart
    202: gEnv.Engine.FormBroker.Open(ID_ACNT_DEPOSIT, 0); // skew chart
    203: gEnv.Engine.FormBroker.Open(ID_ACNT_PASSWORD, 0); //
    //250: gEnv.Engine.FormBroker.Open(ID_POS_MNGR, 0 ) ;


      // trade
    302: gEnv.Engine.FormBroker.Open(ID_ORDER_LIST, 0); // order list
    303: gEnv.Engine.FormBroker.Open(ID_POSITION_LIST, 0); // position list
    304: gEnv.Engine.FormBroker.Open(ID_ORDER, 0); // simple order form
    305: gEnv.Engine.FormBroker.Open(ID_ORDERBOARD, 0); // order board
    306: gEnv.Engine.FormBroker.Open(ID_SYSTEM_ORDER, 0); // system order
    330: gEnv.Engine.FormBroker.Open(ID_MINI_POSITION_LIST, 0); // position list
    350: gEnv.Engine.FormBroker.Open(ID_STOP_LIST, 0); // stop order list
      // ????
    411: gEnv.Engine.FormBroker.Open(ID_MULTI_ACNT, 0);
    401: gEnv.Engine.FormBroker.Open(ID_FUND_ORDERBOARD, 0);
    410: gEnv.Engine.FormBroker.Open(ID_FUND_MINI_POS, 0);

    402: gEnv.Engine.FormBroker.Open(ID_US_IN_123, 0);
    403: gEnv.Engine.FormBroker.Open(ID_USD_H1, 0);
    404: gEnv.Engine.FormBroker.Open(ID_USD_H2, 0);
    409: gEnv.Engine.FormBroker.Open(ID_US_I2, 0);

    405: gEnv.Engine.FormBroker.Open(ID_HULT, 0);
    406: gEnv.Engine.FormBroker.Open(ID_TREND_CNT_INVEST, 0);
    407: gEnv.Engine.FormBroker.Open(ID_STRANGLE, 0);
    408: gEnv.Engine.FormBroker.Open(ID_SHORT_HULT, 0);
      //
    412: gEnv.Engine.FormBroker.Open(ID_SBO, 0);



  end;
end;


procedure TDataModule1.DataModuleCreate(Sender: TObject);
begin
  OpenDialog.InitialDir := gEnv.RootDir;

  gEnv.Engine.FormBroker.OnOpen := FormOpen;
  gEnv.Engine.FormBroker.OnLoad := FormLoad;
  gEnv.Engine.FormBroker.OnSave := FormSave;
  gEnv.Engine.FormBroker.OnReLoad := FormReLoad;
end;

procedure TDataModule1.OpenWins;
var
  stName, stFile, stDir : string;

begin
  stDir := ExtractFilePath( paramstr(0) )+'back';

  if not DirectoryExists( stDir ) then
    stDir := ExtractFilePath( paramstr(0) ) ;

  OpenDialog.InitialDir := stDir;

  if OpenDialog.Execute then
    stFile := OpenDialog.FileName;


  if stFile <> '' then
  begin
    stName := ExtractFileName( stFile );
    if MessageDlg(stName + ' ?????? ???????? ?????????????',
          mtConfirmation, [mbOK, mbCancel], 0) = mrCancel then Exit;

    gEnv.Engine.FormBroker.CloseWindow;
    gEnv.Engine.FormBroker.Load(stFile);
  end;
end;

procedure TDataModule1.FormOpen(iFormID, iVar: Integer; var aForm: TForm);
var
  bForm : TForm;
begin
  aForm := nil;

  case iFormID of
    //ID_SKEW: aForm := TSkewForm.Create(Self);
    ID_SKEW:
      aForm :=TFrmAppInfo.Create( OrpMainForm );
    ID_MULTI_ACNT:
      begin
        aForm :=TFrmAppInfo.Create( OrpMainForm );
        TFrmAppInfo(aForm).AppPage.ActivePageIndex := 2;
        TFrmAppInfo(aForm).AppPageChange( TFrmAppInfo(aForm).AppPage  );
      end;

    ID_ACNT_DEPOSIT:
      aForm := TFrmAccountDeposit.Create( OrpMainForm);


    ID_ORDERBOARD: aForm := TOrderBoardForm.Create(OrpMainForm);
    ID_ORDER:;
    ID_SYSTEM_ORDER : aForm := TSystemOrderForm.Create( OrpMainForm );

    ID_ORDER_LIST:
      begin
        aForm := TFrmOrderList2.Create(OrpMainForm);

      end;

    ID_ACNT_PASSWORD:
      aForm := TFrmAccountPassWord.Create( OrpMainForm );

    ID_MINI_POSITION_LIST:
        aForm := TFrmMiniPosList.Create(OrpMainForm);

    ID_STOP_LIST:
        aForm := TFrmStopOrderList.Create( OrpMainForm );

    ID_FUND_ORDERBOARD:
        aForm := TFundBoardForm.Create( OrpMainform );
    ID_FUND_MINI_POS :
        aForm := TFrmFundMiniPosList.Create( OrpMainForm);

    ID_HULT :
       aForm := TFrmHulTrade.Create( OrpMainForm);

    ID_SHORT_HULT :
       aForm := TFrmShortHult.Create( OrpMainForm);

    ID_USD_H2     : aForm := TFrmUsH2.Create(OrpMainForm );
    ID_US_IN_123  : aForm := TFrmUsIn123.Create( OrpMainForm );
    ID_USD_H1     : aForm := TFrmUsH1.Create(OrpMainForm );
    ID_US_I2      : aForm := TFrmUsI2.Create(OrpMainForm);

    ID_TREND_CNT_INVEST : aForm := TFrmTrendTrade.Create( OrpMainForm );
    ID_STRANGLE   : aForm  := TFrmStrangle.Create( OrpMainForm );

    ID_SBO  : aForm  := TFrmSBreakOut.Create( OrpMainForm );

  end;
end;

procedure TDataModule1.FormReLoad(iFormID: integer; aForm: TForm);
begin

end;

procedure TDataModule1.FormLoad(iFormID: Integer; aStorage: TStorage; var aForm: TForm);
var
  aItem : TForm;
begin
    // create/get form


   if (iFormID = ID_VIRTUAL_TRADE) and ( not gEnv.Simul ) then
    Exit;

  if (( iFormID = ID_SKEW ) or ( iFormID = ID_MULTI_ACNT ) or ( iFormID = ID_SYSTEM_ORDER) ) then
    Exit;

  if ( iFormID = ID_QUOTE_SIMULATION ) and ( gEnv.RunMode = rtSimulation ) then
    Exit;

  if iFormID = ID_GURU_MAIN then
  begin
    if OrpMainForm <> nil then
      OrpMainForm.LoadEnv( aStorage );
    Exit;
  end;

  if gEnv.UserType = utNormal then
    if (iFormID = ID_US_IN_123 ) or
       (iFormID = ID_USD_H1 ) or
       (iFormID = ID_USD_H2 ) or
       (iFormID = ID_HULT ) or
       (iFormID = ID_SBO )
        then
      Exit;

  FormOpen(iFormID, 0, aForm);
    //
  if aForm = nil then Exit;
    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).LoadEnv(aStorage);
        {
    ID_SYSTEM_ORDER :
      if aForm is TSystemOrderForm then
        (aForm as TSystemOrderForm).LoadEnv(aStorage);
        }
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).LoadEnv(aStorage);

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).LoadEnv( aStorage );


    ID_FUND_ORDERBOARD:
        if aForm is TFundBoardForm  then
        ( aForm as TFundBoardForm).LoadEnv( aStorage );

    ID_FUND_MINI_POS :
        if aForm is TFrmFundMiniPosList  then
        ( aForm as TFrmFundMiniPosList).LoadEnv( aStorage );

    ID_HULT :
        if aForm is TFrmHulTrade  then
        ( aForm as TFrmHulTrade).LoadEnv( aStorage );

    ID_USD_H2     :
      if aForm is TFrmUsH2 then
        ( aForm as TFrmUsH2 ).LoadEnv( aStorage );

    ID_USD_H1     :
      if aForm is TFrmUsH1 then
        ( aForm as TFrmUsH1 ).LoadEnv( aStorage );

    ID_US_IN_123 :
      if aForm is TFrmUsIn123 then
        ( aForm as TFrmUsIn123 ).LoadEnv( aStorage );

    ID_US_I2     :
      if aForm is TFrmUsI2 then
        (aForm as TFrmUsI2).LoadEnv( aStorage );

    ID_TREND_CNT_INVEST :
      if aForm is TFrmTrendTrade then
        ( aForm as TFrmTrendTrade ).LoadEnv( aStorage );

    ID_STRANGLE   :
      if aForm  is TFrmStrangle then
        (aForm as TFrmStrangle).LoadEnv( aStorage );

    ID_SHORT_HULT :
      if aForm  is TFrmShortHult then
        (aForm as TFrmShortHult).LoadEnv( aStorage );

    ID_SBO :
      if aForm  is TFrmSBreakOut then
        (aForm as TFrmSBreakOut).LoadEnv( aStorage );
  end;
end;

procedure TDataModule1.FormSave(iFormID: Integer; aStorage: TStorage; aForm: TForm);
begin
    //
  if aForm = nil then Exit;

    //
  case iFormID of
    ID_SKEW: ;
    ID_ORDERBOARD:
      if aForm is TOrderBoardForm then
        (aForm as TOrderBoardForm).SaveEnv(aStorage);
    ID_ORDER: ;
    ID_ORDER_LIST:
      if aForm is TFrmOrderList2 then
        (aForm as TFrmOrderList2).SaveEnv(aStorage);

    ID_GURU_MAIN  :
      if OrpMainForm <> nil then
        OrpMainForm.SaveEnv( aStorage );

    ID_MINI_POSITION_LIST :
        if aForm is TFrmMiniPosList  then
        ( aForm as TFrmMiniPosList).SaveEnv( aStorage );

    ID_FUND_ORDERBOARD:
        if aForm is TFundBoardForm  then
        ( aForm as TFundBoardForm).SaveEnv( aStorage );

    ID_FUND_MINI_POS :
        if aForm is TFrmFundMiniPosList  then
        ( aForm as TFrmFundMiniPosList).SaveEnv( aStorage );

    ID_HULT :
        if aForm is TFrmHulTrade  then
        ( aForm as TFrmHulTrade).SaveEnv( aStorage );

    ID_USD_H2     :
      if aForm is TFrmUsH2 then
        ( aForm as TFrmUsH2 ).SaveEnv( aStorage );

    ID_USD_H1     :
      if aForm is TFrmUsH1 then
        ( aForm as TFrmUsH1 ).SaveEnv( aStorage );

    ID_US_IN_123 :
      if aForm is TFrmUsIn123 then
        ( aForm as TFrmUsIn123 ).SaveEnv( aStorage );

    ID_US_I2     :
      if aForm is TFrmUsI2 then
        (aForm as TFrmUsI2).SaveEnv( aStorage );

    ID_TREND_CNT_INVEST :
      if aForm is TFrmTrendTrade then
        ( aForm as TFrmTrendTrade ).SaveEnv( aStorage );

    ID_STRANGLE   :
      if aForm  is TFrmStrangle then
        (aForm as TFrmStrangle).SaveEnv( aStorage );

    ID_SHORT_HULT :
      if aForm  is TFrmShortHult then
        (aForm as TFrmShortHult).SaveEnv( aStorage );

    ID_SBO :
      if aForm  is TFrmSBreakOut then
        (aForm as TFrmSBreakOut).SaveEnv( aStorage );


  end;
end;

procedure TDataModule1.Help1Click(Sender: TObject);
var
  iTag : integer;
  aItem : TMenuItem;
  aForm : TForm;
begin
  iTag  := TMenuItem( Sender ).Tag;
  aItem := TMenuItem( Sender );
  aForm := gEnv.Engine.FormBroker.FindFormMenu(aItem) as TForm;
  if aForm = nil then exit;
  aForm.WindowState := wsNormal;
  aForm.Show;
end;

procedure TDataModule1.init;
begin

end;

procedure TDataModule1.N7Click(Sender: TObject);
begin
  if gEnv.Info <> nil then  
    gEnv.Info.Show;
end;

end.
