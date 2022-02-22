unit TleOrderIF;

//
// This is not an usuable class. It is rather to show how you write a class
// to send orders to servers and to process the replies from the servers.
//
interface

uses
  Classes, SysUtils,
    // lemon: trade
  CleOrders;

type
  TOrderIF_Template = class
  private
      // (assigned) The order collection in the Lemon Engine
    FOrders: TOrders;
      // (assigned) Any object to handle client-server communication
    // FTCP: T...TCP;

      // The parameters for ResultProc() can be varied depending on
      // the communication method between the client and the server
    procedure ResultProc;
  public
    function SendOrder(aTicket: TOrderTicket): Integer;

    property Orders: TOrders read FOrders write FOrders;
    //property TCP: T...TCP read FTCP write FTCP;
  end;

implementation

// ** NOTICE **
// In the application's main, you have to add the follwing line.
//  > aOrderIF.Orders := gEnv.Engine.TradeCore.Orders;
//  > gEnv.Engine.TradeBroker.OnSendOrder = aOrderIF.SendOrder;

{ TOrderIF_Template }

function TOrderIF_Template.SendOrder(aTicket: TOrderTicket): Integer;
var
  i: Integer;
  aOrder: TOrder;
begin
  Result := 0;

  if FOrders = nil then Exit;

  for i := 0 to FOrders.NewOrders.Count - 1 do
  begin
    aOrder := FOrders.NewOrders[i];

    if (aOrder.State = osReady) and (aOrder.Ticket = aTicket) then
    begin
      {
         // make packet for the order depending on the type of the order
       stPacket := ....
       if FTCP.SendPacket(stPacket, ...) then
       begin
         aOrder.Sent;  // this doesn't generate an event
         Inc(Result);
       end;
      }
    end;
  end;
end;

procedure TOrderIF_Template.ResultProc;
{
var
  aOrder: TOrder;
  iRjectCode: Integer;
  bAccepted: Boolean;
}
begin
{
  // Depending on the client-server communication methd, you know
  // the way to parse the server response and recognize the order to which
  // the reply came.

  aOrder := ... // identify the order
  bAccepted := ...

  if bAccepted then
  begin
    aOrder.LocalNo := ...
    aOrder.SrvAcpt;  // this doesn't generate an event
    // Instead, you could call
    //   aOrder.Accept(...) // this will generate an event
    // here, if the step 'SrvAcpt' is not necessary
  end else
  begin
    iRejectCode := ...
    aOrder.Reject(iRejectCode, Now); // this generates an event
  end;
}
end;

end.
