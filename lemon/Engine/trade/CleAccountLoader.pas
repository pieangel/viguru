unit CleAccountLoader;

interface

uses
  Classes, SysUtils,
    // lemon: common
  LemonEngine, GleTypes,  GleConsts,
    // lemon: utils
  XMLDoc,  XMLIntf,
    // lemon: data
  CleAccounts
  ;

type
  TAccountLoader = Class
  private
    FEngine: TLemonEngine;
    FOnLog: TTextNotifyEvent;
    Accounts  : TAccounts;
    FXmlAcnt  : TXMLDocument;

    procedure DoLog(stLog: String);
    procedure CheckVirAccount;


  public
    constructor Create(aEngine: TLemonEngine);
    destructor Destroy; override;

    procedure SaveVirAccount;

    function Load : boolean;
    function LoadVirtualAccount : boolean;
  End;


implementation

uses
  CleFQN, GAppEnv, GAppConsts, GleLib,

  FOrpMain ;

{ TAccountLoader }

constructor TAccountLoader.Create(aEngine: TLemonEngine  );
begin
  FEngine := aEngine;
  Accounts  :=  TAccounts.Create
end;

destructor TAccountLoader.Destroy;
begin
  inherited;
end;

procedure TAccountLoader.DoLog(stLog: String);
begin

end;

function TAccountLoader.Load: boolean;
begin
  try
    FXmlAcnt := TXMLDocument.Create( OrpMainForm );

    if ( not gEnv.Beta ) and ( not gEnv.YoungLee ) then
      Result :=  LoadVirtualAccount;
    //if not Result  then
      CheckVirAccount;

  finally
    FXmlAcnt.Free;
  end;
end;

function TAccountLoader.LoadVirtualAccount: boolean;
var
  aAcnt : TAccount;
  aInvest : TInvestor;
  stInvest,stTmp, stAcnt, stName: string;
  aType : TAccountType;
  stFileName : string;
  ival, I, j: Integer;
  xnAcnt : IXMLNode;
  xnVirAcnt : IXMLNode;

begin
  Result := false;

  stFileName := ExtractFilePath( paramstr(0) )+'env\'+gEnv.ConConfig.UserID +'_'+ FILE_ACNT ;

  if not FileExists(stFileName) then
    Exit;

  try
    FXmlAcnt.LoadFromFile( stFileName );
    FXmlAcnt.Active := true;

    if FXmlAcnt.ChildNodes.First = nil then Exit;

    // ???? ????
    for I := 0 to FXmlAcnt.DocumentElement.ChildNodes.Count - 1 do
    begin
      xnAcnt  := FXmlAcnt.DocumentElement.ChildNodes[i];
      stInvest := xnAcnt.Attributes['code'];
      aInvest := gEnv.Engine.TradeCore.Investors.Find( stInvest );

      if aInvest <> nil then
      begin
        for j := 0 to xnAcnt.ChildNodes.Count - 1 do
        begin
          xnVirAcnt := xnAcnt.ChildNodes[j];

          stAcnt := xnVirAcnt.Attributes['code'];
          stName := xnVirAcnt.Attributes['name'];
          ival   := xnVirAcnt.Attributes['def'];

          aAcnt :=  aInvest.Accounts.New( stAcnt, stName, mtFutures );
          aAcnt.InvestCode  := stInvest;
          if ival = 1 then
          begin
            aAcnt.DefAcnt := true;
            aInvest.RceAccount  := aAcnt;
          end;

          stTmp := Format('%s ?? ???????? ?ε? -> %s, %s, %s', [
            stInvest, stAcnt, stName, ifThenStr( ival = 1, '?⺻','')]);
          gLog.Add( lkApplication, '','', stTmp );

          Result := true;

        end;
      end;
    end;

    FXmlAcnt.Active := false

  except
    gLog.Add( lkError, '','', Format('%s ?? ???????? ?ε? ????', [stFileName]));
  end;

end;



procedure TAccountLoader.CheckVirAccount;
var
  aAcnt : TAccount;
  i : integer;
  aInvestor: TInvestor;
  stCode, stName : string;
begin
  //  ?ϳ??? investor ?? ??? ?ϳ? ?̻??? ???????¸? ?????? ?Ѵ?.
  for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
  begin
    aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];

    if aInvestor.Accounts.Count = 0 then
    begin

      //stCode  := Copy( aInvestor.Code, 7, Length( aInvestor.Code ) - 7 + 1 );// + '_1';
      stCode  := aInvestor.Code+'_1';
      stName  := aInvestor.Name;// +'_1' ;
      aAcnt := aInvestor.Accounts.New( stCode, stName, mtFutures, gEnv.ConConfig.Password );
      aAcnt.DefAcnt := true;
      aAcnt.InvestCode  := aInvestor.Code;
      aAcnt.LogIdx  := 0;
      aInvestor.RceAccount  := aAcnt;

    end;
  end;

end;

procedure TAccountLoader.SaveVirAccount;
var
  aAcnt : TAccount;
  stFileName : string;
  i, j : integer;
  aInvestor : TInvestor;

  xnRoot  , xnAcnt,
  xnVirAcnt : IXMLNode;
begin

  try
    FXmlAcnt := TXMLDocument.Create( OrpMainForm );
    FXmlAcnt.Active := True;
    FXmlAcnt.Encoding:= 'euc-kr';

    // ??Ʈ ???? ??????
    xnRoot := FXmlAcnt.AddChild('AccountList');
    xnRoot.Attributes['LatestUpdate'] := FormatDateTime('YYYY/MM/DD', Now);



    for I := 0 to gEnv.Engine.TradeCore.Investors.Count - 1 do
    begin
      aInvestor := gEnv.Engine.TradeCore.Investors.Investor[i];

      xnAcnt  := xnRoot.AddChild('Account');
      xnAcnt.Attributes['code'] := aInvestor.Code;
      xnAcnt.Attributes['name'] := aInvestor.Name;

      for j := 0 to aInvestor.Accounts.Count - 1 do
      begin
        aAcnt := aInvestor.Accounts.Accounts[j];

        xnVirAcnt := xnAcnt.AddChild('VirAcnt');
        xnVirAcnt.Attributes['code']  := aAcnt.Code;
        xnVirAcnt.Attributes['name']  := aAcnt.Name;
        if aAcnt.DefAcnt then        
          xnVirAcnt.Attributes['def'] := 1
        else
          xnVirAcnt.Attributes['def'] := 0;
      end;
    end;

  finally
    stFileName := ExtractFilePath( paramstr(0) )+'env\'+ gEnv.ConConfig.UserID +'_'+ FILE_ACNT ;
    FXmlAcnt.SaveToFile(stFileName);
    FXmlAcnt.Free;
  end;

end;


end.
