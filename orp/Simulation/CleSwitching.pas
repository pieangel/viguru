unit CleSwitching;

interface

uses
  Classes, SysUtils, MMSystem
  ;

type
  TBaseCollection = class( TCollection )
  public
    AObject : string;
    Constructor Create( aItemClass: TCollectionItemClass );
  end;

  TSwitchgItem = class( TCollectionItem )
  public
    Step  : integer;
    MaxTerm  : integer;
    MinTerm  : integer;
  
    OnOff : boolean;          // true / false
    DataType  : string;       // tick / hoga
    DelayTime : integer;
    PrcDesc   : string;       // procedure name             

    Constructor Create(aColl: TCollection);  override;
    procedure SetItem( stType : string; stDesc  : string );    
    procedure CalcDelayTime( prevTime : integer );
    //procedure SetTime( prevNodeTime : integer );
  end;     

  TSwitchgItems  = class( TCollection )
  public       
    Node      : integer ;
    PrcName   : string;  
    
    Constructor Create( iNode : integer ); overload;
    Destructor  Destroy; override;
    
    function New( iStep : integer) : TSwitchgItem;     
    function Steps( iStep : integer ) :  TSwitchgItem;     
  end;  

  TSwitchgNode = class( TCollectionItem )
  public
    Node      : integer;    // index 가 더 낳을듯한디....
    SwitchgItems : TSwitchgItems;
    constructor Create(Coll: TCollection); override;    
  end;

  TSwitchNodes  = class( TBaseCollection )
  public
    Constructor Create( stObject : string ) ; 
    Destructor  Destroy; override;

    function New( iNode : integer ) : TSwitchgNode;      
    function Nodes( iNode, iStep : integer ) : TSwitchgItem; overload;   
    function Nodes( iNode : integer ) : TSwitchgNode; overload;

    procedure TurnOnOff( iNode, iStep : integer; Value  : boolean );
  end;      

  TQuoteNodes  = class( TSwitchNodes )
  
  end;
  TTradeNodes  = class( TSwitchNodes )
  
  end;

  TSwitchgMngr  = class
  private
    FQuoteNodes: TQuoteNodes;
    FTradeNodes: TTradeNodes;
    FNodeCount: integer;
    procedure NodeSetting;
  public
    property QuoteNodes : TQuoteNodes read FQuoteNodes;      
    property TradeNodes : TTradeNodes read FTradeNodes;  

    property NodeCount  : integer read FNodeCount; 

    Constructor Create;
    Destructor  Destroy; override;  

    function QuoteNodeSetting : integer;
    procedure TradeNodeSetting;
  end;

implementation

{ TSwitchgNode }

constructor TSwitchgItems.Create( iNode : integer );
begin
  inherited Create( TSwitchgItem );
  Node  := iNode;
end;

destructor TSwitchgItems.Destroy;
begin

  inherited;
end;

function TSwitchgItems.New( iStep : integer): TSwitchgItem;
begin
  Result  := Add as TSwitchgItem;  
  Result.Step := iStep;
  Result.OnOff:= true;  
end;

function TSwitchgItems.Steps(iStep: integer): TSwitchgItem;
begin
  if ( iStep < 0) and ( iStep > Count) then
    Result := nil
  else
    Result := Items[iStep] as TSwitchgItem;
end;

{ TSwitchgItem }

procedure TSwitchgItem.CalcDelayTime( prevTime : integer );
var
  iPrevNode, iMax, iMin, iTmp : integer;
  aStep : TSwitchgItem;
begin 
  DelayTime  := timeGetTime;


  //if (Collection as TSwitchgItems).Node = 0 then
  //  Exit;

  iTmp  := DelayTime - prevTime;

  if MaxTerm < iTmp then MaxTerm := iTmp;
  if MinTerm > iTmp then MinTerm := iTmp            
  
end;

constructor TSwitchgItem.Create(aColl: TCollection);
begin                       
  inherited Create(aColl);
  MaxTerm := -1;
  MinTerm := 200;
end;

procedure TSwitchgItem.SetItem(stType, stDesc: string);
begin
  DataType  := stType;
  PrcDesc   := stDesc;
end;

{ TSwitchgNode }

constructor TSwitchgNode.Create(Coll: TCollection);
begin
  inherited Create( Coll );       
  SwitchgItems := TSwitchgItems.Create( Node );
end;

{ TSwitchgNodes }

constructor TSwitchNodes.Create( stObject : string );
begin
  inherited Create( TSwitchgNode );
  AObject := stObject;  
end;

destructor TSwitchNodes.Destroy;
begin

  inherited;
end;

function TSwitchNodes.New(iNode: integer): TSwitchgNode;
begin
  Result  := Add as  TSwitchgNode;

  // Node = Count
  Result.Node := iNode;
end;

function TSwitchNodes.Nodes(iNode: integer): TSwitchgNode;
begin
  if ( iNode < 0) and ( iNode > Count ) then
    Result := nil
  else begin
    Result := ( Items[iNode] ) as TSwitchgNode;
  end;  
end;

function TSwitchNodes.Nodes(iNode, iStep: integer): TSwitchgItem;
begin
  if ( iNode < 0) and ( iNode > Count ) then
    Result := nil
  else begin
    Result := (( Items[iNode] ) as TSwitchgNode).SwitchgItems.Steps( iStep);    
  end;
end;

procedure TSwitchNodes.TurnOnOff(iNode, iStep: integer; Value: boolean);
var
  aStep : TSwitchgItem;
begin
  aStep := Nodes( iNode, iStep );
  if aStep <> nil then
    aStep.OnOff := Value;
end;

{ TBaseCollection }

constructor TBaseCollection.Create(aItemClass: TCollectionItemClass);
begin
  inherited Create( aItemClass );
end;

{ TSwitchgMngr }

constructor TSwitchgMngr.Create;
begin
  FQuoteNodes:= TQuoteNodes.Create('QUOTE');
  FTradeNodes:= TTradeNodes.Create('TRADE'); 
end;

destructor TSwitchgMngr.Destroy;
begin
  FQuoteNodes.Free;
  FTradeNodes.Free;
  inherited;
end;

procedure TSwitchgMngr.NodeSetting;
begin

end;

function TSwitchgMngr.QuoteNodeSetting : integer ;
var
  aNode : TSwitchgNode;
  aStep   : TSwitchgItem;
  iNode , iStep : integer;
begin
  iNode := 0;  iStep := 0;
  aNode := FQuoteNodes.New(iNode); inc(iNode);
  aNode.SwitchgItems.PrcName  := 'TUdpSocketThread.WMASyncSelect';
    inc(iStep);
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep);
      aStep.SetItem( 'X', '.Start' );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.End' );        
    iStep := 0;
    
  aNode := FQuoteNodes.New(iNode);inc(iNode);  //
  aNode.SwitchgItems.PrcName  := 'TUdpSocketThread.AnalysisDataPacket';
    inc( iStep );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.Start' );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.End' );   
    iStep := 0;
  
  aNode := FQuoteNodes.New(iNode);inc(iNode);  //  
  aNode.SwitchgItems.PrcName  := 'TUdpThread.syncProc';
    inc( iStep );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep);
      aStep.SetItem( 'X', '.Start' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.End' );   
    iStep := 0;  
    
  aNode := FQuoteNodes.New(iNode);inc(iNode);  //  TKRXQuoteParser.Parse
  aNode.SwitchgItems.PrcName  := 'TKRXQuoteParser.Parse';
    inc( iStep );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.Start' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.End' );   
    iStep := 0;  
      
  aNode := FQuoteNodes.New(iNode);inc(iNode);  //  Parse******MarketDepth   or  Parse******TimeNSale
  aNode.SwitchgItems.PrcName  := 'TKRXQuoteParser.Parse********';
    inc( iStep );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'H', '.Start' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'H', '.Parse' );       
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'H', '.End' );   

      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'T', '.Start' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'T', '.Parse' );       
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'T', '.End' );         
    iStep := 0;  
      
  aNode := FQuoteNodes.New(iNode);inc(iNode);  //  
  aNode.SwitchgItems.PrcName  := 'TQuote.Update';
    inc( iStep );
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.Start' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep); 
      aStep.SetItem( 'X', '.Distribute' ); 
      aStep := aNode.SwitchgItems.New(iStep); inc(iStep);       
      aStep.SetItem( 'X', '.End' );   
    iStep := 0;   

  Result := iNode;

  {
  FQuoteNodes.New(6);inc(iNode);
  FQuoteNodes.New(7);inc(iNode);
  FQuoteNodes.New(8);inc(iNode);
  }

end;

procedure TSwitchgMngr.TradeNodeSetting;
begin

end;

end.
