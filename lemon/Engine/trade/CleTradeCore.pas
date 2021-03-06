unit CleTradeCore;

// Copyright(C) Eight Pines Technologies, Inc. All Rights Reserved.

// Core Data Object for trades

interface

uses
  Classes, Windows,
    // lemon: data
  CleFunds, CleAccounts, CleOrders, CleFills, ClePositions, CleTrades,

  CleStopOrders,  ClePrograms,  CleFrontOrder,  CleStrategyGate,

  CleStorage, EnvFile,  EnvUtil

  ;

type
  TTradeCore = class
  private
    FFunds: TFunds;
    FAccounts: TAccountList;
      //
    FOrderTickets: TOrderTickets;
    FOrderResults: TOrderResults;
    FOrders: TOrders;
    FFills: TFills;
    FPositions: TPositions;
      // optional used only in US
    FTrades: TTrades;
    FPrograms: TPrograms;

    FStrategyGate : TStrategyGate;
    FFrontOrders: TOrderItems;
    FInvestors: TInvestors;
    FInvestorPositions: TPositions;
    FStopOrders: TStopOrders;
    FStorage: TStorage;
    FFundPositions: TFundPositions;
    function FindNextUserBlock(aEnvFile: TEnvFile; var iP,
      iEndP: Integer): Boolean;
    function LoadGroup(aEnvFile: TEnvFile; var iP: Integer): Boolean;
    function SaveGroup(aEnvFile: TEnvFile; aGroup : TFund): Boolean;

  public
    constructor Create;
    destructor Destroy; override;

    property Funds: TFunds read FFunds;
    property Accounts: TAccountList read FAccounts;

    property OrderTickets: TOrderTickets read FOrderTickets;
    property Orders: TOrders read FOrders;
    property OrderResults: TOrderResults read FOrderResults;
    property Fills: TFills read FFills;
    property Positions: TPositions read FPositions;
    property Investors: TInvestors read FInvestors;
    property InvestorPositions: TPositions read FInvestorPositions;
    property FundPositions  : TFundPositions read FFundPositions;

    property Trades: TTrades read FTrades;
    property Programs: TPrograms read FPrograms;
    //property TopsQuery : TTopsQuery read FTopsQuery;

    property StrategyGate : TStrategyGate read FStrategyGate;
    property FrontOrders : TOrderItems read FFrontOrders;
    property StopOrders  : TStopOrders read FStopOrders;
    property Storage  : TStorage read FStorage;

    procedure CheckVirAccount;
    procedure Reset( iPos : integer; bBack : boolean );
    procedure Clear;
    procedure AccountPrint( stTitle : string = '' );

    procedure SaveVirAccount;

    procedure SaveFunds;            // ????????
    procedure LoadFunds;            // ????????
  end;

implementation

uses GAppEnv, SysUtils,  CleFQN,  GAppConsts, GleTypes,
  GleLib
  ;

{ TTradeCore }

const
  BEGIN_OF_USER = 'begin_of_user';
  END_OF_USER = 'end_of_user';

procedure TTradeCore.AccountPrint;
begin

end;

procedure TTradeCore.CheckVirAccount;
var
  aAcnt : TAccount;
  i : integer;
  aInvestor: TInvestor;
  stCode, stName : string;
begin
  //  ?????? investor ?? ?????? ???? ?????? ?????????? ?????? ????.

  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];

    if aInvestor.Accounts.Count = 0 then
    begin
      stCode  := Copy( aInvestor.Code, 7, Length( aInvestor.Code ) - 7 + 1 ) + '_1';
      stName  := aInvestor.Name +'_1' ;
      aAcnt := aInvestor.Accounts.New( stCode, stName, mtFutures, gEnv.ConConfig.Password );
      aAcnt.DefAcnt := true;
      aAcnt.InvestCode  := aInvestor.Code;
      aAcnt.LogIdx  := 0;
      aInvestor.RceAccount  := aAcnt;
    end;
  end;
end;

procedure TTradeCore.Clear;
begin
  FOrderTickets.Clear;
  FOrderResults.Clear;
  FOrders.Clear;
  FFills.Clear;
  FPositions.Clear;

  FFrontOrders.Clear;
  FInvestorPositions.Clear;
  FInvestors.Reset;
  FStopOrders.Clear;
end;

constructor TTradeCore.Create;
begin
    // group 1
  FFunds := TFunds.Create;

  FInvestors  := TInvestors.Create;
  FAccounts:= TAccountList.Create;

  FInvestorPositions:= TPositions.Create;
    // group 2
  FOrderTickets := TOrderTickets.Create;
  FOrderResults := TOrderResults.Create;
  FOrders := TOrders.Create;

    // group 3
  FFills := TFills.Create;
  FPositions := TPositions.Create;
  FFundPositions:= TFundPositions.Create;

    // group 4, optional used only in US
  FTrades := TTrades.Create;
  FPrograms := TPrograms.Create;

    //
  FStrategyGate := TStrategyGate.Create;
  FFrontOrders:= TOrderItems.Create;
  FStopOrders := TStopOrders.Create;

  FStorage  := TStorage.Create;

end;

destructor TTradeCore.Destroy;
begin

  FStorage.New;
  SaveVirAccount;
  FStorage.Free;

    // group 4
  FPrograms.Free;
  FTrades.Free;
  FStopOrders.Free;

    // group 3
  FOrders.Free;
  FOrderResults.Free;
  FOrderTickets.Free;

    // group 2
  FFills.Free;
  FPositions.Free;
  FInvestorPositions.Free;
  FFundPositions.Free;

    // group 1
  FInvestors.Free;
  FAccounts.Free;
  FFunds.Free;
  FFrontOrders.Free;
  FStrategyGate.Free;

  inherited;
end;




procedure TTradeCore.Reset(iPos: integer; bBack : boolean);
begin

end;

function TTradeCore.FindNextUserBlock(aEnvFile: TEnvFile; var iP, iEndP: Integer) : Boolean;
var
  i : Integer;
  bStart, bEnd : Boolean;
begin
  i := iP;
  bStart := False;
  bEnd := False;
  Result := False;

  while i <= aEnvFile.Lines.Count-1 do
  begin
    if CompareStr(aEnvFile.Lines[i], BEGIN_OF_USER) = 0 then
    begin
      iP := i;
      bStart := True;
    end else
    if CompareStr(aEnvFile.Lines[i], END_OF_USER) = 0 then
    begin
      iEndP := i;
      bEnd := True;
    end;

    Inc(i);

    if bStart and bEnd and (iEndP > iP) then
      Break;
  end;

  Result := (bStart and bEnd and (iEndP > iP));
end;

procedure TTradeCore.SaveFunds;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt, iUserSaveCount : Integer;
  iLong : Integer;
  iVersion : Word;
  stUserID : String;
  aEnvOld, aEnvNew : TEnvFile;
begin
  aEnvOld := TEnvFile.Create;
  aEnvNew := TEnvFile.Create;

  try
      // load group information to a string list
    if aEnvOld.Exists(FILE_KR_FUND) then
      aEnvOld.LoadLines(FILE_KR_FUND);

    iP := 0;

      // get version & user count
    if aEnvOld.Lines.Count = 0 then
    begin
      iVersion := 0;
      iUserCnt := 0;
    end else
    begin
      iLong := StrToInt(aEnvOld.Lines[iP]); Inc(iP); // version(2) + Count(2)
      iVersion := HiWord(iLong);
      iUserCnt := LoWord(iLong);    // the number of saved HTS IDs
    end;

      // copy the old information except the one under the current ID
    iUserSaveCount := 0;
    
    if (iVersion = GURU_VERSION) and (iUserCnt > 0) then
    begin
      for i:=0 to iUserCnt-1 do
      begin
          // find user block
        if not FindNextUserBlock(aEnvOld, iP, iEndP) then Break;

          // get ID for the user block
        stUserID := aEnvOld.Lines[iP+1];

          // save if the ID is not the current HTS ID
        if CompareStr(stUserID, gEnv.ConConfig.UserID) <> 0 then
        begin
            // copy a USER block
          while iP <= iEndP do
          begin
            aEnvNew.Lines.Add(aEnvOld.Lines[iP]);
            Inc(iP);
          end;

            // increase user count
          Inc(iUserSaveCount);
        end;
          // next
        iP := iEndP + 1;
      end;
    end;

      // save groups under the current HTS ID
    aEnvNew.Lines.Add(BEGIN_OF_USER);
    aEnvNew.Lines.Add(gEnv.ConConfig.UserID);
    aEnvNew.Lines.Add(IntToStr(FFunds.Count));
    for i:=0 to FFunds.Count-1 do
      SaveGroup(aEnvNew, FFunds.Funds[i] as TFund);
    aEnvNew.Lines.Add(END_OF_USER);

    Inc(iUserSaveCount);

      // insert version & count
    iLong := MakeLong(iUserSaveCount, GURU_VERSION);
    aEnvNew.Lines.Insert(0, IntToStr(iLong));

      // save to file
    aEnvNew.SaveLines(FILE_KR_FUND);
  finally
    aEnvOld.Free;
    aEnvNew.Free;
  end;

end;

function TTradeCore.SaveGroup(aEnvFile: TEnvFile; aGroup: TFund): Boolean;
var
  i : Integer;
begin
  Result := False;

  if (aEnvFile = nil) or (aGroup = nil) then Exit;

  aEnvFile.Lines.Add(aGroup.Name);
  aEnvFile.Lines.Add(IntToStr(aGroup.FundItems.Count )); // ?????????? ?????? ??????

  for i:=0 to aGroup.FundItems.Count-1 do
  begin
    aEnvFile.Lines.Add(aGroup.FundItems[i].Account.Code);
    aEnvFile.Lines.Add(IntToStr(aGroup.FundItems[i].Multiple));
  end;

  Result := True;

end;

procedure TTradeCore.LoadFunds;
var
  i, j, iP, iEndP, iUserCnt, iGroupCnt : Integer;
  iLong : Integer;
  iVersion : Word;
  stUserID : String;
  aEnvFile : TEnvFile;
begin
  aEnvFile := TEnvFile.Create;
  try
    if (not aEnvFile.Exists(FILE_KR_FUND)) or
       (not aEnvFile.LoadLines(FILE_KR_FUND)) or
       (aEnvFile.Lines.Count = 0)
    then
      Exit;

    iP := 0;

      // version + count
    iLong := StrToInt(aEnvFile.Lines[iP]); Inc(iP);
      // get version
    iVersion := HiWord(iLong);

      // load by version
    if iVersion = 0 then
    begin // conversion from the old version
      iGroupCnt := LoWord(iLong);

      for i:=0 to iGroupCnt - 1 do
        if not LoadGroup(aEnvFile, iP) then
          Break;

        // make sure version change
      SaveFunds;
    end else
      // new version
    if iVersion = GURU_VERSION then
    begin
      iUserCnt := LoWord(iLong);    // User ID Number

      for i:=0 to iUserCnt-1 do
      begin
        if not FindNextUserBlock(aEnvFile, iP, iEndP) then Break;

        Inc(iP);
        stUserID := aEnvFile.Lines[iP];
        Inc(iP);

          // ?????? ID?? ???? ???????? ID ?? ???? ????
        if CompareStr(stUserID, gEnv.ConConfig.UserID ) = 0 then
        begin
          FFunds.Clear;
          iGroupCnt := StrToInt(aEnvFile.Lines[iP]); Inc(iP);

          for j:=0 to iGroupCnt - 1 do
            if not LoadGroup(aEnvFile, iP) then
              Break;

          Break;
        end;

        iP := iEndP + 1;
      end;  //... for i
    end;  //... if iVersion = 0 then
  finally
    aEnvFile.Free;
  end;

end;

function TTradeCore.LoadGroup(aEnvFile: TEnvFile; var iP: Integer): Boolean;
var
  i, iAccCnt: Integer;
  iMultiple : integer;
  stAccount : String;
  aGroup : TFund;
  aAccount : TAccount;
begin
  Result := False;

  try
    aGroup := FFunds.New(aEnvFile.Lines[iP]);
    Inc(iP);      //--1. ??????
    iAccCnt := StrToInt(aEnvFile.Lines[iP]); Inc(iP); //--2. ??????

    for i:=0 to iAccCnt-1 do
    begin
      stAccount := aEnvFile.Lines[iP]; Inc(iP);          //--3. ????????
      iMultiple := StrToIntDef(aEnvFile.Lines[iP],1); Inc(iP);//--4. ????
      aAccount  := FAccounts.Find(stAccount); // by FullCode

      if aAccount <> nil then
        with aGroup.FundItems.AddFundItem(aAccount) do
          Multiple := iMultiple;

      Result := True;
    end;
  except
    gLog.Add(lkDebug, 'Account Storage', 'Load Groups', 'Group loading failure');
  end;

end;


procedure TTradeCore.SaveVirAccount;
var
  i , j : integer;
  aInvest : TInvestor;
  aAcnt : TAccount;
begin

  for i := 0 to Investors.Count - 1 do
  begin
    aInvest := Investors.Investor[i];
    if aInvest = nil then Continue;

    FStorage.New;

    FStorage.FieldByName('code').AsString := aInvest.Code;
    FStorage.FieldByName('name').AsString := aInvest.Name;
    FStorage.FieldByName('count').AsInteger := aInvest.Accounts.Count;

    for j := 0 to aInvest.Accounts.Count - 1 do
    begin
      aAcnt := aInvest.Accounts.Accounts[j];
      if aACnt = nil then Continue;

      FStorage.FieldByName('code_'+IntToStr(j)).AsString := aAcnt.Code;
      FStorage.FieldByName('name_'+IntToStr(j)).AsString := aAcnt.Name;
    end;
  end;

  FStorage.Save( ComposeFilePath([gEnv.DataDir, 'account.lsg']) );

end;

end.
