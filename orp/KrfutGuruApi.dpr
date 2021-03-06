program KrfutGuruApi;

uses
  Forms,
  ComObj,
  SysUtils,
  Dialogs,
  windows,
  GleConsts in '..\lemon\Engine\Common\GleConsts.pas',
  LemonEngine in '..\lemon\Engine\main\LemonEngine.pas',
  CleSymbolCore in '..\lemon\Engine\symbol\CleSymbolCore.pas',
  CleMarkets in '..\lemon\Engine\symbol\CleMarkets.pas',
  CleSymbolParser in '..\lemon\Engine\symbol\CleSymbolParser.pas',
  CleSymbols in '..\lemon\Engine\symbol\CleSymbols.pas',
  CleMarketSpecs in '..\lemon\Engine\symbol\CleMarketSpecs.pas',
  CleFQN in '..\lemon\Engine\symbol\CleFQN.pas',
  GAppEnv in 'Main\GAppEnv.pas',
  GAppConsts in 'Main\GAppConsts.pas',
  CleAssocControls in '..\lemon\Engine\utils\CleAssocControls.pas',
  CleCollections in '..\lemon\Engine\utils\CleCollections.pas',
  CleContour in '..\lemon\Engine\utils\CleContour.pas',
  CleDistributor in '..\lemon\Engine\utils\CleDistributor.pas',
  CleFTPConnector in '..\lemon\Engine\utils\CleFTPConnector.pas',
  CleKeyGen in '..\lemon\Engine\utils\CleKeyGen.pas',
  CleLists in '..\lemon\Engine\utils\CleLists.pas',
  CleListViewPeer in '..\lemon\Engine\utils\CleListViewPeer.pas',
  CleMySQLConnector in '..\lemon\Engine\utils\CleMySQLConnector.pas',
  ClePainter in '..\lemon\Engine\utils\ClePainter.pas',
  CleParsers in '..\lemon\Engine\utils\CleParsers.pas',
  CleStringTree in '..\lemon\Engine\utils\CleStringTree.pas',
  CleQuoteBroker in '..\lemon\Engine\quote\CleQuoteBroker.pas',
  CleQuoteTimers in '..\lemon\Engine\quote\CleQuoteTimers.pas',
  StreamIO in '..\lemon\Engine\imports\StreamIO.pas',
  CleKrxQuoteParser in '..\lemon\Engine\quote\CleKrxQuoteParser.pas',
  CleAccounts in '..\lemon\Engine\trade\CleAccounts.pas',
  CleFunds in '..\lemon\Engine\trade\CleFunds.pas',
  CleOrders in '..\lemon\Engine\trade\CleOrders.pas',
  ClePositions in '..\lemon\Engine\trade\ClePositions.pas',
  CleTradeCore in '..\lemon\Engine\trade\CleTradeCore.pas',
  CleTrades in '..\lemon\Engine\trade\CleTrades.pas',
  CleTradingSystems in '..\lemon\Engine\trade\CleTradingSystems.pas',
  CleFills in '..\lemon\Engine\trade\CleFills.pas',
  CleKrxSymbols in '..\lemon\Engine\symbol\CleKrxSymbols.pas',
  GleLib in '..\lemon\Engine\common\GleLib.pas',
  SynthUtil in '..\lemon\Engine\imports\SynthUtil.pas',
  CleFormTracker in '..\lemon\Engine\utils\CleFormTracker.pas',
  CalcGreeks in '..\lemon\Engine\imports\CalcGreeks.pas',
  CleHolidays in '..\lemon\Engine\symbol\CleHolidays.pas',
  CleTradeBroker in '..\lemon\Engine\trade\CleTradeBroker.pas',
  GleEnv in '..\lemon\Engine\common\GleEnv.pas',
  GleTypes in '..\lemon\Engine\common\GleTypes.pas',
  ClePrograms in '..\lemon\Engine\trade\ClePrograms.pas',
  DleSymbolSelect in '..\lemon\Engine\symbol\DleSymbolSelect.pas' {SymbolDialog},
  TleOrderIF in '..\lemon\Engine\trade\TleOrderIF.pas',
  CleFormBroker in '..\lemon\Engine\env\CleFormBroker.pas',
  CleStorage in '..\lemon\Engine\utils\CleStorage.pas',
  GAppForms in 'Main\GAppForms.pas',
  FOrderBoard in 'Order\OrderBoard\FOrderBoard.pas' {OrderBoardForm},
  COrderTablet in 'Order\OrderBoard\COrderTablet.pas',
  CTickPainter in 'Order\OrderBoard\CTickPainter.pas',
  COrderBoard in 'Order\OrderBoard\COrderBoard.pas',
  DBoardParams in 'Order\OrderBoard\DBoardParams.pas' {BoardParamDialog},
  COBTypes in 'Order\OrderBoard\COBTypes.pas',
  DBoardOrder in 'Order\OrderBoard\DBoardOrder.pas' {BoardOrderDialog},
  CleIni in '..\lemon\Engine\env\CleIni.pas',
  CleLog in '..\lemon\Engine\imports\CleLog.pas',
  FFPopupMsg in 'main\FFPopupMsg.pas' {FPopupMsg},
  EnvFile in '..\lemon\Engine\utils\EnvFile.pas',
  EnvUtil in '..\lemon\Engine\utils\EnvUtil.pas',
  CryptInt in '..\lemon\Engine\utils\CryptInt.pas',
  UMemoryMapIO in '..\lemon\Engine\utils\UMemoryMapIO.pas',
  uCpuUsage in '..\lemon\Engine\utils\uCpuUsage.pas',
  CleAccountLoader in '..\lemon\Engine\trade\CleAccountLoader.pas',
  CleImportCode in '..\lemon\Engine\env\CleImportCode.pas',
  FleOrderList2 in '..\lemon\Engine\trade\FleOrderList2.pas' {FrmOrderList2},
  CleFilltering in '..\lemon\Engine\trade\CleFilltering.pas',
  TimeSpeeds in '..\lemon\Engine\imports\TimeSpeeds.pas',
  CHogaPainter in 'Order\OrderBoard\CHogaPainter.pas',
  CBoardDistributor in 'Order\OrderBoard\CBoardDistributor.pas',
  CBoardEnv in 'Order\OrderBoard\CBoardEnv.pas',
  DBoardEnv in 'Order\OrderBoard\DBoardEnv.pas' {BoardConfig},
  ListSave in '..\lemon\Engine\utils\ListSave.pas',
  Ticks in 'Chart\Common\Ticks.pas',
  CleQuoteParserIf in '..\lemon\Engine\quote\CleQuoteParserIf.pas',
  ClePriceItems in '..\lemon\Engine\quote\ClePriceItems.pas',
  CleFormManager in 'Order\FORM\CleFormManager.pas',
  CleExcelLog in '..\lemon\Engine\utils\CleExcelLog.pas',
  CalcElwIVGreeks in '..\lemon\Engine\imports\CalcElwIVGreeks.pas',
  CleCircularQueue in '..\lemon\Engine\utils\CleCircularQueue.pas',
  CleFORMOrderItems in 'Order\FORM\CleFORMOrderItems.pas',
  CleOtherData in '..\lemon\Engine\quote\CleOtherData.pas',
  CleTimers in '..\lemon\Engine\utils\CleTimers.pas',
  CleQuoteChangeData in '..\lemon\Engine\quote\CleQuoteChangeData.pas',
  CleInvestorData in '..\lemon\Engine\quote\CleInvestorData.pas',
  CleOrderBeHaivors in 'Order\CleOrderBeHaivors.pas',
  CleOrderConsts in 'Order\CleOrderConsts.pas',
  CleFrontOrder in '..\lemon\Engine\trade\CleFrontOrder.pas',
  FleMiniPositionList in '..\lemon\Engine\trade\FleMiniPositionList.pas' {FrmMiniPosList},
  CleStopOrders in 'Order\OrderBoard\CleStopOrders.pas',
  FAppInfo in 'main\FAppInfo.pas' {FrmAppInfo},
  FleStopOrderList in '..\lemon\Engine\trade\FleStopOrderList.pas' {FrmStopOrderList},
  DataMenu in '..\Api\Kr\DataMenu.pas' {DataModule1: TDataModule},
  FOrpMain in '..\Api\Kr\FOrpMain.pas' {OrpMainForm},
  CleApiManager in '..\Api\Kr\CleApiManager.pas',
  ApiPacket in '..\Api\Kr\ApiPacket.pas',
  CleApiReceiver in '..\Api\Kr\CleApiReceiver.pas',
  ApiConsts in '..\Api\Kr\ApiConsts.pas',
  FAccountDeposit in '..\lemon\Engine\trade\FAccountDeposit.pas' {FrmAccountDeposit},
  FAccountPassWord in '..\Api\Kr\FAccountPassWord.pas' {FrmAccountPassWord},
  FFundConfig in 'main\FFundConfig.pas' {FrmFundConfig},
  FleFundMiniPositionList in 'Order\Stg\FleFundMiniPositionList.pas' {FrmFundMiniPosList},
  CleKRXOrderBroker in '..\Api\Kr\CleKRXOrderBroker.pas',
  FServerMessage in '..\Api\Kr\FServerMessage.pas' {FrmServerMessage},
  CleKrxSymbolMySQLLoader in '..\Api\Kr\CleKrxSymbolMySQLLoader.pas',
  FLogIn in '..\Api\Kr\FLogIn.pas' {FrmLogin},
  CleAutoStopOrders in 'Order\OrderBoard\CleAutoStopOrders.pas',
  FConfirmLiqMode in 'Order\Stg\FundBoard\FConfirmLiqMode.pas' {FrmLiqMode},
  ESINApiExpLib_TLB in '..\ocx\kr\ESINApiExpLib_TLB.pas',
  CleHultAxis in 'Order\HULT\CleHultAxis.pas',
  FHulTrade in 'Order\HULT\FHulTrade.pas' {FrmHulTrade},
  UFillList in 'Order\HULT\UFillList.pas',
  UObjectBase in 'Order\HULT\UObjectBase.pas',
  UPaveConfig in 'Order\HULT\UPaveConfig.pas',
  UPriceItem in 'Order\HULT\UPriceItem.pas',
  CleStrategyGate in '..\lemon\Engine\trade\CleStrategyGate.pas',
  CleStrategyStore in '..\lemon\Engine\trade\CleStrategyStore.pas',
  CleLogPL in '..\lemon\Engine\utils\CleLogPL.pas',
  CleUs_In_123 in 'Order\Stg\Usd\CleUs_In_123.pas',
  CleUsdH1_1Min_Fund in 'Order\Stg\Usd\CleUsdH1_1Min_Fund.pas',
  CleUsdH2_5Min in 'Order\Stg\Usd\CleUsdH2_5Min.pas',
  FUs_In_123 in 'Order\Stg\Usd\FUs_In_123.pas' {FrmUsIn123},
  FUsdH1_1Min in 'Order\Stg\Usd\FUsdH1_1Min.pas' {FrmUsH1},
  FUsdH2_5Min in 'Order\Stg\Usd\FUsdH2_5Min.pas' {FrmUsH2},
  CleUsdH1_1Min in 'Order\Stg\Usd\CleUsdH1_1Min.pas',
  CleUsdParam in 'Order\Stg\Usd\CleUsdParam.pas',
  CleUs_In_123_Fund in 'Order\Stg\Usd\CleUs_In_123_Fund.pas',
  CleUsdH2_5Min_Fund in 'Order\Stg\Usd\CleUsdH2_5Min_Fund.pas',
  DleAccountSelect in '..\lemon\Engine\trade\DleAccountSelect.pas' {FrmAcntSelect},
  FTrendTrade in 'Order\Troika\FTrendTrade.pas' {FrmTrendTrade},
  CleTrendTrade in 'Order\Troika\CleTrendTrade.pas',
  CleConsumerIndex in '..\lemon\Engine\symbol\CleConsumerIndex.pas',
  FleStrangle in 'Order\Troika\FleStrangle.pas' {FrmStrangle},
  CleStrangle in 'Order\Troika\CleStrangle.pas',
  CleShortHultAxis in 'Order\HULT\CleShortHultAxis.pas',
  FShortHult in 'Order\HULT\FShortHult.pas' {FrmShortHult},
  FUsI2_5Min in 'Order\Stg\Usd\FUsI2_5Min.pas' {FrmUsI2},
  CleUsIn_5min in 'Order\Stg\Usd\CleUsIn_5min.pas',
  FmQtySet in 'Order\OrderBoard\FmQtySet.pas' {FrmQtySet: TFrame},
  FmLiqSet in 'Order\OrderBoard\FmLiqSet.pas' {FrmLiqSet: TFrame},
  FFundOrderBoard in 'Order\Stg\FundBoard\FFundOrderBoard.pas' {FundBoardForm},
  FleSBreakOut in 'Order\Stg\Park\FleSBreakOut.pas' {FrmSBreakOut},
  CleParkParam in 'Order\Stg\Park\CleParkParam.pas',
  DSignalAlias in '..\lemon\Engine\OMEGA\DSignalAlias.pas' {SignalAliasDialog},
  DSignalConfig in '..\lemon\Engine\OMEGA\DSignalConfig.pas' {SignalConfigDialog},
  DSignalLink in '..\lemon\Engine\OMEGA\DSignalLink.pas' {SignalLinkDialog},
  DSignalNotify in '..\lemon\Engine\OMEGA\DSignalNotify.pas' {SignalNotifyDialog},
  EtcTypes in '..\lemon\Engine\OMEGA\EtcTypes.pas',
  FSystemOrder in '..\lemon\Engine\OMEGA\FSystemOrder.pas' {SystemOrderForm},
  OmegaIF in '..\lemon\Engine\OMEGA\OmegaIF.pas',
  ORTCLib_TLB in '..\lemon\Engine\OMEGA\ORTCLib_TLB.pas',
  SignalData in '..\lemon\Engine\OMEGA\SignalData.pas',
  SignalLinks in '..\lemon\Engine\OMEGA\SignalLinks.pas',
  Signals in '..\lemon\Engine\OMEGA\Signals.pas',
  SignalTargets in '..\lemon\Engine\OMEGA\SignalTargets.pas',
  StccDef in '..\lemon\Engine\OMEGA\StccDef.pas',
  SystemIF in '..\lemon\Engine\OMEGA\SystemIF.pas',
  FleOrder in '..\lemon\Engine\trade\FleOrder.pas' {OrderForm},
  DleOrderConfirm in '..\lemon\Engine\trade\DleOrderConfirm.pas' {OrderConfirmDialog},
  CleSBreakOut in 'Order\Stg\Park\CleSBreakOut.pas',
  CleOrderSender in '..\lemon\Engine\trade\CleOrderSender.pas',
  FBHult in 'Order\HULT\FBHult.pas' {FrmBHult},
  CleBHultEx in 'Order\HULT\CleBHultEx.pas',
  FleInvestStrangle in 'Order\Strangle\FleInvestStrangle.pas' {FrmInvestStrangle},
  FleUnderStrangle in 'Order\Strangle\FleUnderStrangle.pas' {FrmUnderStrangle},
  CleStrangleConfig in 'Order\Strangle\CleStrangleConfig.pas',
  CleInvestStrangle in 'Order\Strangle\CleInvestStrangle.pas',
  CleUnderStrangle in 'Order\Strangle\CleUnderStrangle.pas',
  CleStrategyAccounts in 'Order\Strangle\CleStrategyAccounts.pas',
  CleBondTrends in 'Order\Stg\Usd\CleBondTrends.pas',
  FleBondTrends in 'Order\Stg\Usd\FleBondTrends.pas' {FrmBondTrends},
  FUsComp_5Min in 'Order\Stg\Usd\FUsComp_5Min.pas' {FrmUsComp},
  CleUsComp in 'Order\Stg\Usd\CleUsComp.pas';

{$R *.res}
{$R guru.RES}


var
  stClass : string;
  FApp    : Variant;
  bNeedReg: boolean ;

begin

  

  Application.Initialize;
//  bNeedReg  := true;

  bNeedReg  := false;
  FApp      := 0;
  try
    stClass := ComObj.ClassIDToProgID(CLASS_ESINApiExp);
   // FApp := CreateOleObject(stClass);
  except
    bNeedReg  := true;
  end;

  try
    if bNeedReg then
    begin
      if SysUtils.FileExists(  ExtractFilePath( paramstr(0) )+'ESINApiExp.ocx' ) then
      begin
        // ?????? ??????????  multicid.ocx ?? ????????
        ComObj.RegisterComServer( ExtractFilePath( paramstr(0) )+'ESINApiExp.ocx' );
      end;
    end else
      FApp := 0;

  except
    ShowMessage('ESINApiExp.ocx ???? ???? ');
    Application.Terminate;
  end;

  Application.Title := 'KrfutGuruApi';
  Application.CreateForm(TOrpMainForm, OrpMainForm);
  Application.CreateForm(TDataModule1, DataModule1);
  Application.CreateForm(TFPopupMsg, FPopupMsg);
  Application.CreateForm(TFrmServerMessage, FrmServerMessage);
  Application.ShowMainForm  := true;

  Application.Run;
end.
