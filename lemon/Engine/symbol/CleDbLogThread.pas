unit CleDbLogThread;

interface

uses
  Classes, Windows, SyncObjs,

  CleDbLogConsts, CleQuoteBroker
  ;

type

  TDBLogThread = class(TThread)
  private
    { Private declarations }
    FEvent  : TEvent;
    FList   : TList;
    FMutex  : HWND;
    FData   : TDBLogItem;
    procedure WriteDB;
    procedure writeTerm(aOne: TOneMin);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor  Destroy; override;
    procedure Fin;

    procedure PushData( aType : TDbLogType; aQuote : TQuote );
    function  PopData : TDBLogItem;
  end;

implementation

uses
  GAppEnv , Forms, Ticks
  ;

{ Important: Methods and properties of objects in visual components can only be
  used in a method called using Synchronize, for example,

      Synchronize(UpdateCaption);

  and UpdateCaption could look like,

    procedure TDBLogThread.UpdateCaption;
    begin
      Form1.Caption := 'Updated in a thread';
    end; }

{ TDBLogThread }

constructor TDBLogThread.Create;
begin
  FreeOnTerminate := True;
  FEvent := TEvent.Create(nil, False, False, '');
  FMutex := CreateMutex(nil, False, PChar('DBMutex_1235'));
  FList  := TList.Create;

  inherited Create(false);
  Priority := tpNormal;

end;

destructor TDBLogThread.Destroy;
begin
  FEvent.Free;
  CloseHandle( FMutex );
  FList.Free;

  inherited;
end;

procedure TDBLogThread.Execute;
begin
  { Place thread code here }
  while not Terminated do
  begin
    if not( FEvent.WaitFor( INFINITE ) in [wrSignaled] ) then Continue;

    while FList.Count > 0 do
    begin
      FData := PopData;
      if FData <> nil then begin
        WriteDB;
        FData.Free;
        FData := nil;
      end;
      Application.ProcessMessages;
    end;
  end;
end;

procedure TDBLogThread.Fin;
begin
  Terminate;
  FEvent.SetEvent;

end;

procedure TDBLogThread.WriteDB;
begin
  case FData.LogType of
    dblOneMin: writeTerm( TOneMin(FData)) ;
  end;
end;

function TDBLogThread.PopData: TDBLogItem;
begin
  Result := nil;
  WaitForSingleObject( FMutex, INFINITE );
  Result  := TDBLogItem( FList.Items[0] );
  FList.Delete(0);
  ReleaseMutex( FMutex );
end;

procedure TDBLogThread.PushData(aType: TDbLogType; aQuote: TQuote);
var
  aOne  : TOneMin;
  aItm  : TSTermItem;
begin
  case aType of
    dblOneMin:
      begin
        aOne  := TOneMin.Create;
        aOne.LogType  := aType;
        aOne.Time     := aQuote.LastQuoteTime;
        aOne.Code     := aQuote.Symbol.Code;

        aItm  := aQuote.Terms.XTerms[ aQuote.Terms.Count-2];
        if aItm = nil then
        begin
          aOne.Free;
          Exit;
        end;

        with aItm do begin
          aOne.O        := O;
          aOne.H        := H;
          aOne.L        := L;
          aOne.C        := C;
          aOne.Qty      := FillVol;
          aOne.Ask      := AskPrice;
          aOne.Bid      := BidPrice;
        end;
      end;
  end;

  WaitForSingleObject( FMutex, INFINITE );
  FList.Add( aOne );
  ReleaseMutex( FMutex );
  FEvent.SetEvent;
end;


procedure TDBLogThread.writeTerm( aOne : TOneMin );
begin
  gEnv.Loader.InsertOneMin( aOne);
end;

end.
