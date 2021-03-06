unit SignalLinks;

interface

uses
  Classes, SysUtils, Controls,
  //
  CleAccounts, CleFunds, CleSymbols, ClePositions,
  SystemIF, Signals, Dialogs,EnvFile, Forms;

type
  TSignalLinkItem = class;
  
  TSignalLinkEvent = procedure(aLink : TSignalLinkItem) of object;
  TSignalLinkOrderEvent = procedure(aLink : TSignalLinkItem;
     aEvent : TSignalEventItem) of object;

  TSignalLinkItem = class(TCollectionItem)
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FSignal : TSignalItem;
    FMultiplier : Integer;
    FPosition : Integer;

    FOnUpdate : TSignalLinkEvent;
    FOnRemove : TSignalLinkEvent;
    FOnOrder : TSignalLinkOrderEvent;
    FIsFund: boolean;
    FFund: TFund;
  public
    destructor Destroy; override;

    procedure UpdatePosition;
    procedure RemoveLink;
    procedure NewOrder(aEvent : TSignalEventItem);

    property Account : TAccount read FAccount;
    property Fund    : TFund    read FFund;
    property Symbol : TSymbol read FSymbol write FSymbol;
    property Signal : TSignalItem read FSignal;
    property Multiplier : Integer read FMultiplier;
      // 시그널 수량 * 링크 승수
    property Position : Integer read FPosition;
    property IsFund   : boolean read FIsFund;

    property OnUpdate : TSignalLinkEvent read FOnUpdate write FOnUpdate;
    property OnRemove : TSignalLinkEvent read FOnRemove write FOnRemove;
    property OnOrder : TSignalLinkOrderEvent read FOnOrder write FOnOrder;
  end;

  TSignalLinks = class(TCollection)
  private
    FSignals : TSignals; // reference to signal list
    function GetLink(i:Integer) : TSignalLinkItem;
  public
    constructor Create;

    function NewLink : TSignalLinkItem;
    function EditLink(aLink : TSignalLinkItem) : Boolean;
    procedure RemoveLink(aLink : TSignalLinkItem); overload;
    procedure RemoveLink(aSignal : TSignalItem); overload;

    procedure LoadLinks;
    procedure LoadOldLinks( aEnvFile : TEnvFile );
    procedure SaveLinks;
    function GetLinkCode( stData : string) : string;

    function NewOrder(aEvent : TSignalEventItem) : Integer;
    procedure UpdatePosition(aSignal : TSignalItem);

    property Signals : TSignals read FSignals write FSignals;
    property Links[i:Integer] : TSignalLinkItem read GetLink; default;
  end;


implementation

uses
  {LogCentral, TradeCentral, PriceCentral,  }
  DSignalLink, GAppEnv, CleMarkets;{, AppTypes;

//===============================================================//
                     { TSignalLinks }
//===============================================================//

destructor TSignalLinkItem.Destroy;
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self);

  inherited;
end;

procedure TSignalLinkItem.UpdatePosition;
begin
  if FSignal <> nil then
    FPosition := FMultiplier * FSignal.Position;

  if Assigned(FOnUpdate) then
    FOnUpdate(Self);
end;

procedure TSignalLinkItem.NewOrder(aEvent : TSignalEventItem);
begin
  if (aEvent = nil) or (aEvent.Signal = nil) then Exit;

  if Assigned(FOnOrder) then
    FOnOrder(Self, aEvent);
end;

procedure TSignalLinkItem.RemoveLink;
begin
  if Assigned(FOnRemove) then
    FOnRemove(Self );
end;

//===============================================================//
                     { TSignalLinks }
//===============================================================//

constructor TSignalLinks.Create;
begin
  inherited Create(TSignalLinkItem);
end;

//------------------------< Get/Set >---------------------------//

function TSignalLinks.GetLink(i:Integer) : TSignalLinkItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TSignalLinkItem
  else
    Result := nil;
end;

function TSignalLinks.GetLinkCode(stData: string): string;
var
  stResult : string;
  iPos : integer;
begin
  stResult := Copy( stData , 2 , Length(stData) -2);
  iPos := Pos(',', stResult);
  Result := Copy(stResult, 1, iPos-1);
end;

//------------------------< Manage Links >---------------------------//

// (public)
// make a new link with a dialog
//
function TSignalLinks.NewLink : TSignalLinkItem;
var
  aDlg : TSignalLinkDialog;
begin
  Result := nil;

  aDlg := TSignalLinkDialog.Create(nil);
  try
    aDlg.SignalList := FSignals;

    if aDlg.ShowModal <> mrOK then Exit;

    //-- new signal-account connection item
    Result := Add as TSignalLinkItem;
    Result.FIsFund   := adlg.IsFund;
    Result.FFund    := aDlg.Fund;
    Result.FAccount := aDlg.Account;
    Result.FSymbol := aDlg.Symbol;
    Result.FSignal := aDlg.Signal;
    Result.FMultiplier := aDlg.Multiplier;
    Result.FPosition := Result.Signal.Position * Result.Multiplier;
  finally
    aDlg.Free;
  end;
end;

// (public)
// edit a link with a dialog
//
function TSignalLinks.EditLink(aLink : TSignalLinkItem) : Boolean;
var
  aDlg : TSignalLinkDialog;
begin
  Result := False;

  if aLink = nil then Exit;

  aDlg := TSignalLinkDialog.Create(nil);
  try
    aDlg.SignalList := FSignals;

    aDlg.IsFund  := aLink.IsFund;
    aDlg.Account := aLink.Account;
    aDlg.Symbol  := aLink.Symbol;
    aDlg.Signal  := aLink.Signal;
    aDlg.Multiplier := aLink.Multiplier;
    adlg.Fund       := aLink.Fund;

    if aDlg.ShowModal <> mrOK then Exit;

    aLink.FAccount := aDlg.Account;
    aLink.FSymbol := aDlg.Symbol;
    aLink.FSignal := aDlg.Signal;

    aLink.FMultiplier := aDlg.Multiplier;
    aLink.FPosition := aLink.Signal.Position * aLink.Multiplier;

    Result := True;
  finally
    aDlg.Free;
  end;
end;

// (public)
// remove a link
//
procedure TSignalLinks.RemoveLink(aLink : TSignalLinkItem);
begin
  if aLink = nil then Exit;

  aLink.Free;
end;

// (public)
// remove a link with the matched signal
//
procedure TSignalLinks.RemoveLink(aSignal : TSignalItem);
var
  i : Integer;
begin
  if aSignal = nil then Exit;

  for i:=Count-1 downto 0 do
    if Links[i].Signal = aSignal then
      Links[i].Free;
end;

//---------------------< Manage Position Quantity >----------------------//

procedure TSignalLinks.UpdatePosition(aSignal : TSignalItem);
var
  i : Integer;
begin
  if aSignal = nil then Exit;

  for i:=0 to Count-1 do
    if Links[i].Signal = aSignal then
      Links[i].UpdatePosition;
end;

//--------------------------< Manage order >--------------------------//

function TSignalLinks.NewOrder(aEvent : TSignalEventItem) : Integer;
var
  i, iMatchedCount : Integer;
begin
  if (aEvent = nil) or (aEvent.Signal = nil) then Exit;

  iMatchedCount := 0;

  for i:=0 to Count-1 do
  begin
    if Links[i].Signal = aEvent.Signal then
    begin
      Links[i].NewOrder(aEvent);
        //
      Inc(iMatchedCount);
    end;
  end;

  Result := iMatchedCount;
end;


//-------------------------< Load Save >--------------------------------//

const
  Link_FILE = 'signallink.gsu';

// (public)
// Load signal inks
//



procedure TSignalLinks.LoadLinks;
const
  FIELD_COUNT = 5;
var
  i : Integer;
  aEnvFile : TEnvFile;
  aItem : TSignalLinkItem;
  iLinkCount : Integer;
  aAccount : TAccount;
  aSymbol : TSymbol;
  aSignal : TSignalItem;
  FFutureMarket : TFutureMarket;
  isFund : boolean;
  aFund  : TFund;
  stSymbol : String;
  stTmp, stLog, stLinkCode : string;
  iAge : integer;
begin
  aEnvFile := TEnvFile.Create;
  try
    if not aEnvFile.Exists(Link_FILE) then Exit;

    iAge  := StrToInt64( FormatDateTime('yyyymmdd', FileDateToDateTime(FileAge( gEnv.RootDir + Link_FILE ))));

    if iAge < 20171130 then
    begin
      LoadOldLinks( aEnvFile  );
      Exit;
    end;

    aEnvFile.LoadLines(Link_FILE);
    if aEnvFile.Lines.Count mod FIELD_COUNT <> 0 then
    begin
      stLog := Format('%s %s', ['SignalData', '연결표 복구','시스템 신호 연결표가 잘못되었습니다.']);
      gEnv.DoLog( WIN_MC, stLog);
      Exit;
    end;
    iLinkCount := aEnvFile.Lines.Count div FIELD_COUNT;

    for i:=0 to iLinkCount-1 do
    begin
      // 편드인지
      stTmp    := aEnvFile.Lines[i*FIELD_COUNT ];
      if stTmp = 'Y' then begin
        isFund := true;
        aAccount := nil;
        aFund   := gEnv.Engine.TradeCore.Funds.Find(  aEnvFile.Lines[i*FIELD_COUNT +1] );
      end else
      if stTmp = 'N' then begin
        isFund := false;
        aAccount := gEnv.Engine.TradeCore.Accounts.Find(aEnvFile.Lines[i*FIELD_COUNT+1 ]);
        aFund   := nil ;
      end else
        Continue;

      stSymbol := aEnvFile.Lines[i*FIELD_COUNT + 2];
      aSymbol  :=  gEnv.Engine.SymbolCore.Symbols.FindCode(stSymbol);

      aSignal :=
         FSignals.Find(aEnvFile.Lines[i*FIELD_COUNT + 3]);

      if aSymbol = nil then
      begin
        stLinkCode := GetLinkCode( aSignal.Description );

        stLinkCode := UpperCase(stLinkCode);
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindLinkCode(stLinkCode);
      end;

      if aSymbol = nil then
      begin
        gEnv.DoLog(WIN_MC, '종목 찾지 못함 TSignalLinks');
        ShowMessage('종목 찾지 못함 ..!!');
        //Application.Terminate;
      end;

      if (( aAccount <> nil) or ( aFund <> nil ))  and (aSignal <> nil) then
      begin
        aItem := Add as TSignalLinkItem;
        aItem.FIsFund   := IsFund;
        aItem.FFund    := aFund;
        aItem.FAccount := aAccount;
        aItem.FSymbol := aSymbol;
        aItem.FSignal := aSignal;
        aItem.FMultiplier := StrToIntDef(aEnvFile.Lines[i*FIELD_COUNT+4],0);
        aItem.FPosition := aSignal.Position * aItem.Multiplier; // = 0
      end;
    end;
  finally
    aEnvFile.Free;
  end;
end;

procedure TSignalLinks.LoadOldLinks(aEnvFile: TEnvFile);
const
  FIELD_COUNT = 4;
var
  i : Integer;
  aItem : TSignalLinkItem;
  iLinkCount : Integer;
  aAccount : TAccount;
  aSymbol : TSymbol;
  aSignal : TSignalItem;
  FFutureMarket : TFutureMarket;
  isFund : boolean;
  aFund  : TFund;
  stSymbol : String;
  stLog, stLinkCode : string;
begin
   if aEnvFile.Lines.Count mod FIELD_COUNT <> 0 then
    begin
      stLog := Format('%s %s', ['SignalData', '연결표 복구','시스템 신호 연결표가 잘못되었습니다.']);
      gEnv.DoLog( WIN_MC, stLog);
      Exit;
    end;
    iLinkCount := aEnvFile.Lines.Count div FIELD_COUNT;

    for i:=0 to iLinkCount-1 do
    begin
      aAccount := gEnv.Engine.TradeCore.Accounts.Find(aEnvFile.Lines[i*FIELD_COUNT]);

      stSymbol := aEnvFile.Lines[i*FIELD_COUNT + 1];
      aSymbol :=  gEnv.Engine.SymbolCore.Symbols.FindCode(stSymbol);


      aSignal :=
         FSignals.Find(aEnvFile.Lines[i*FIELD_COUNT + 2]);

      if aSymbol = nil then
      begin
        stLinkCode := GetLinkCode( aSignal.Description );

        stLinkCode := UpperCase(stLinkCode);
        aSymbol := gEnv.Engine.SymbolCore.Symbols.FindLinkCode(stLinkCode);
      end;

      if aSymbol = nil then
      begin
        gEnv.DoLog(WIN_MC, '종목 찾지 못함 TSignalLinks');
        ShowMessage('종목 찾지 못함 ..!!');
        //Application.Terminate;
      end;

      if (aAccount <> nil) and (aSignal <> nil) then
      begin
        aItem := Add as TSignalLinkItem;
        aItem.FIsFund  := false;
        aItem.FFund    := nil;
        aItem.FAccount := aAccount;
        aItem.FSymbol := aSymbol;
        aItem.FSignal := aSignal;
        aItem.FMultiplier := StrToIntDef(aEnvFile.Lines[i*FIELD_COUNT+3],0);
        aItem.FPosition := aSignal.Position * aItem.Multiplier; // = 0
      end;
    end;
end;

// (public)
// Save signal inks
//
procedure TSignalLinks.SaveLinks;
var
  i : Integer;
  aEnvFile : TEnvFile;
begin
  aEnvFile := TEnvFile.Create;
  try
    aEnvFile.Lines.Clear;
    for i:=0 to Count-1 do
    begin
      // 펀드 사항 추가.
      if Links[i].IsFund then begin
        aEnvFile.Lines.Add( 'Y');
        if Links[i].Fund <> nil then
          aEnvFile.Lines.Add(Links[i].Fund.Name)
        else
          aEnvFile.Lines.Add('');
      end
      else begin
        aEnvFile.Lines.Add( 'N');
        if Links[i].Account <> nil then
          aEnvFile.Lines.Add(Links[i].Account.Code)
        else
          aEnvFile.Lines.Add('');
      end;

      if Links[i].Symbol <> nil then
        aEnvFile.Lines.Add(Links[i].Symbol.Code)
      else
        aEnvFile.Lines.Add('');
      aEnvFile.Lines.Add(Links[i].Signal.Title);
      aEnvFile.Lines.Add(IntToStr(Links[i].Multiplier));
    end;
    aEnvFile.SaveLines(Link_FILE);
  finally
    aEnvFile.Free;
  end;
end;

end.
