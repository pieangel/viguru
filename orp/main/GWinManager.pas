unit GWinManager;

interface

uses
  Windows, SysUtils, Classes, Forms,
  GAppForms
  ;

type

  TWinItem = class(TCollectionItem)
  private
    FWindow: TForm;
    FFormID: integer;
  public
    property Window : TForm read FWindow;
    property FormID : integer read FFormID;
  end;

  TWindowManager  = class( TCollection )
  private
    FSelected: TForm;
    function GetWindow(i: Integer): TWinItem;
  public
    constructor Create;
    destructor Destroy; override;

    function New( aItem : TForm; FormID : integer  ) : TWinItem;
    function FindWindow( FormID : integer ) : TWinItem;
    procedure WinOnActivate(Sender: TObject);

    property Selected : TForm read FSelected;
    property WinItem[i:Integer]:TWinItem read GetWindow; default;
  end;


implementation

uses GAppEnv;

{ TWindowManager }

function TWindowManager.New(aItem: TForm; FormID : integer ): TWinItem;
begin
  Result := Add as TWinItem;

  Result.FWindow  := aItem;
  Result.FFormID  := FormID;

  if FormID = ID_ORDERBOARD then
    aItem.OnActivate  := WinOnActivate;
end;

procedure TWindowManager.WinOnActivate(Sender: TObject);
begin
  if Sender <> nil then begin
    FSelected := TForm( Sender );
    gEnv.OnLog( self, 'select : ' + Sender.ClassName );
  end;
end;

constructor TWindowManager.Create;
begin
  inherited Create( TWinItem );
end;

destructor TWindowManager.Destroy;
begin

  inherited;
end;

function TWindowManager.FindWindow(FormID: integer): TWinItem;
begin

end;

function TWindowManager.GetWindow(i: Integer): TWinItem;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TWinItem
  else
    Result := nil;
end;

end.
