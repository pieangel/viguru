unit EtcTypes;

interface

type
  TMessageNotifyEvent = procedure(stMsg : String) of object;
  
implementation

end.


                          {

TSystemOrderForm.FormCreate

  TOmegaIF.Create;
    FStccBroker.OnOpenEvent := OpenEvent;
    FStccBroker.OnFilledEvent := FillEvent;

	FSignals.AddIF(FOmegaIF);
		aSystemIF.OnOrder := NewOrder;
	FSignals.OnOrder := NewOrder;




TOmegaIF.FillEvent
	FOnOrder(Self, aEvent)

TOmegaIF.FOnOrder(Self, aEvent)


TSignals.NewOrder


TSignals.FOnOrder


TSystemOrderForm.NewOrder
	FLinks.NewOrder(aEvent);



TSignalLinks.NewOrder
	Links[i].NewOrder(aEvent);


TSignalLinkItem.NewOrder
	FOnOrder(Self, aEvent);



TSignalTargetItem.NewOrder
	PutOrder(aEvent.Signal, aEvent.Qty * aLink.Multiplier);


TSignalTargetItem.PutOrder


  }
