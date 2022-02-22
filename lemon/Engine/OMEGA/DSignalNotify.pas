unit DSignalNotify;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls,

  SystemIF;

type
  TSignalNotifyDialog = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Button1: TButton;
    Bevel1: TBevel;
    LabelAlias: TLabel;
    LabelSource: TLabel;
    LabelStratety: TLabel;
    LabelTime: TLabel;
    LabelOrder: TLabel;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
  private
    FEvent : TSignalEventItem;

    procedure SetEvent(aEvent : TSignalEventItem);
  public
    property Event : TSignalEventItem read FEvent write SetEvent;
  end;


implementation

{$R *.DFM}

procedure TSignalNotifyDialog.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSignalNotifyDialog.SetEvent(aEvent: TSignalEventItem);
begin
  if aEvent = nil then Exit;

  FEvent := aEvent;

  if FEvent.Signal <> nil then
  begin
    LabelAlias.Caption := aEvent.Signal.Title;
    LabelSource.Caption := aEvent.Signal.Source;
    LabelStratety.Caption := aEvent.Signal.Description;
  end;
  LabelTime.Caption := FormatDateTime('hh:nn:ss', aEvent.EventTime);
  LabelOrder.Caption := aEvent.Remark;
end;

procedure TSignalNotifyDialog.Button1Click(Sender: TObject);
begin
  Close;
end;

end.
