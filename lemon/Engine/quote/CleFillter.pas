unit CleFillter;

interface

uses
  Classes, SysUtils,
  CleSymbols,
  CleStorage
  ;
type



  TFillter = class
  private
    FVolume: double;

    FLPs: TStringList;
    FUnderlyings : TStringList;

    FTickRatioTo: double;
    FSpread: integer;
    FLpWeight: Integer;
    FTickRatioFrom: double;
    FAutoQuery: Boolean;
    FAutoSecIndex: integer;
    FRemainDaysFrom: Integer;
    FRemainDaysTo: Integer;
  {  function GetLP(i: Integer): TLP;
    function GetUnderlying(i: Integer): TSymbol;    }
  public
    constructor Create;
    destructor Destroy; override;

    function AddUnderlying( aSymbol : TSymbol ) : boolean;
    function AddLp( aLp : TLp ) : boolean;

    property Underlyings: TStringList read FUnderlyings write FUnderlyings ;
    property LPs        : TStringList read FLPs        write FLPs;

    property Volume     : double     read FVolume     write FVolume;
    property RemainDaysTo : Integer     read FRemainDaysTo write FRemainDaysTo;
    property RemainDaysFrom : Integer     read FRemainDaysFrom write FRemainDaysFrom;
    property LpWeight   : Integer     read FLpWeight   write FLpWeight;
    property Spread     : integer     read FSpread     write FSpread;
    property TickRatioTo    : double   read FTickRatioTo   write FTickRatioTo;
    property TickRatioFrom  : double   read FTickRatioFrom write FTickRatioFrom;
    //
    property AutoQuery : Boolean  read FAutoQuery write FAutoQuery;
    property AutoSecIndex : integer read FAutoSecIndex write FAutoSecIndex default 0;
   {
    property Underlying[i:Integer]: TSymbol read GetUnderlying;
    property LP[i:Integer]: TLP read GetLP;
   }
    procedure GetLpList(aList: TStrings);
    procedure GetUnderlyingList( aList : TStrings );

    function IsCheckSymbol( aElw : TElw ) : integer;
    function IsCheckLp( stLp  : string ) : boolean;

    procedure SaveEnv(aStorage: TStorage);
    procedure LoadEnv(aStorage: TStorage);
  end;

implementation

uses GAppEnv;

{ TFillter }

function TFillter.AddLp(aLp: TLp): boolean;
begin
  if FLPs.IndexOfObject( aLp ) < 0 then
    FLPs.AddObject( aLp.LpName, aLp );
end;

function TFillter.AddUnderlying(aSymbol: TSymbol): boolean;
begin
  if FUnderlyings.IndexOfObject( aSymbol ) < 0 then
    FUnderlyings.AddObject( aSymbol.Code, aSymbol );
end;

constructor TFillter.Create;
begin
  FUnderlyings:= TStringList.Create;
  FLPs        := TStringList.Create;

  FVolume:= 0;
  FRemainDaysTo:= 30;
  FRemainDaysFrom := 60;

  FTickRatioTo:= 1.5;
  FSpread:=2;
  FLpWeight:= 80;
  FTickRatioFrom:= 0.1
end;

destructor TFillter.Destroy;
begin
  FUnderlyings.Free;
  FLPs.Free;
  inherited;
end;
                        {
function TFillter.GetLP(i: Integer): TLP;
begin
  if (i >= 0) and (i <= FLps.Count-1) then
    Result := TLP(FLps.Objects[i])
  else
    Result := nil;
end;

function TFillter.GetUnderlying(i: Integer): TSymbol;
begin
  if (i >= 0) and (i <= FUnderlyings.Count-1) then
    Result := TSymbol(FUnderlyings.Objects[i])
  else
    Result := nil;
end;
        }
procedure TFillter.GetUnderlyingList(aList: TStrings);
var
  i: Integer;
begin
  if aList = nil then Exit;

  for i := 0 to FUnderlyings.Count - 1 do
    aList.AddObject((FUnderlyings.Objects[i] as TSymbol).Name, FUnderlyings.Objects[i]);

end;

function TFillter.IsCheckLp(stLp: string): boolean;
var 
  i : integer;
  alp : TLp ;
begin
  result := false;
  for i := 0 to FLPs.Count - 1 do
  begin
    aLp := TLp( FLps.Objects[i] );
    if aLp.LpCode = stLp then begin
      result := true;
      break;    
    end;  
  end;
  
end;

function TFillter.IsCheckSymbol(aElw: TElw): integer;
var 
  i : integer;
  aSymbol, aUnder : TSymbol;
begin 
  aSymbol := aElw.Underlying; 
  Result := FUnderlyings.IndexOfObject( aSymbol )  
end;

procedure TFillter.LoadEnv(aStorage: TStorage);
var
  I , iCount: integer;
  aSymbol : TSymbol;  
  stCode, stName  : string;
  aLp : TLp;
begin
  if aStorage = nil then Exit;

  iCount  :=  aStorage.FieldByName('UdCount').AsInteger;  
  for i := 0 to iCount - 1 do
  begin
    stCode  := aStorage.FieldByName('UdCode'+IntToStr(i)).AsString;
    aSymbol := gEnv.Engine.SymbolCore.Symbols.FindCode(stCode);
    if aSymbol <> nil then begin
      AddUnderlying( aSymbol );
    end;
  end;

  iCount  :=  aStorage.FieldByName('LpCount').AsInteger;
  for i := 0 to iCount - 1 do
  begin
    stCode  := aStorage.FieldByName('LpCode'+IntToStr(i)).AsString;
    aLp := gEnv.Engine.SymbolCore.LPs.Find(stCode);
    if aLp <> nil then
      AddLp( aLp );
  end;

  FVolume       := aStorage.FieldByName('Volume').AsFloat;
  FRemainDaysTo   := aStorage.FieldByName('RemainDaysTo').AsInteger;
  FRemainDaysFrom   := aStorage.FieldByName('RemainDaysFrom').AsInteger;
  FLpWeight     := aStorage.FieldByName('LpWeight').AsInteger;
  FSpread       := aStorage.FieldByName('Spread').AsInteger;
  FTickRatioTo  := aStorage.FieldByName('TickRatioTo').AsFloat;
  FTickRatioFrom:= aStorage.FieldByName('TickRatioFrom').AsFloat;

  FAutoQuery    := aStorage.FieldByName('AutoQuery').AsBoolean;
  FAutoSecIndex := aStorage.FieldByName('AutoQueryIndex').AsInteger;
end;

procedure TFillter.SaveEnv(aStorage: TStorage);
var
  I , iCount: integer;
  aSymbol : TSymbol;  
  aLp : TLp;
begin
  if aStorage = nil then Exit;
  
  aStorage.FieldByName('UdCount').AsInteger :=  FUnderlyings.Count;  
  for i := 0 to FUnderlyings.Count - 1 do
  begin
    aSymbol := TSymbol( FUnderlyings.Objects[i] );     
    aStorage.FieldByName('UdCode'+IntTostr(i)).AsString := aSymbol.Code;
  end;            

  aStorage.FieldByName('LpCount').AsInteger :=  FLPs.Count;
  for i := 0 to FLPs.Count - 1 do
  begin
    aLp := TLp( FLPs.Objects[i] );
    aStorage.FieldByName('lpCode'+IntToStr(i)).AsString := aLp.LpCode;
  end;

  aStorage.FieldByName('Volume').AsFloat  := FVolume;
  aStorage.FieldByName('RemainDaysTo').AsInteger  := FRemainDaysTo;
  aStorage.FieldByName('RemainDaysFrom').AsInteger  := FRemainDaysFrom;
  aStorage.FieldByName('LpWeight').AsInteger    := FLpWeight;
  aStorage.FieldByName('Spread').AsInteger      := FSpread;
  aStorage.FieldByName('TickRatioTo').AsFloat   := FTickRatioTo;
  aStorage.FieldByName('TickRatioFrom').AsFloat := FTickRatioFrom;

  aStorage.FieldByName('AutoQuery').AsBoolean   := FAutoQuery;
  aStorage.FieldByName('AutoQueryIndex').AsInteger  := FAutoSecIndex;

end;

procedure TFillter.GetLpList(aList: TStrings);
var
  i: Integer;
begin
  if aList = nil then Exit;

  for i := 0 to FLPs.Count - 1 do
    aList.AddObject((FLPs.Objects[i] as TLp).LpName, FLPs.Objects[i]);
end;


end.
