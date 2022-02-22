unit DBoardOrder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
    // lemon
  GleTypes, CleAccounts, CleSymbols, CleKrxSymbols, CleOrders;
  
type
  TBoardOrderDialog = class(TForm)
    Label1: TLabel;
    LabelAccount: TLabel;
    Label2: TLabel;
    LabelSymbol: TLabel;
    Label7: TLabel;
    EditQty: TEdit;
    EditPrice: TEdit;
    LabelPrice: TLabel;
    ButtonOK: TButton;
    ButtonCancel: TButton;
    Label3: TLabel;
    LabelPosition: TLabel;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure EditQtyChange(Sender: TObject);
    procedure EditPriceChange(Sender: TObject);
  private
    FAccount : TAccount;
    FSymbol : TSymbol;
    FOrderType : TOrderType;
    FPositionType : TPositionType;
    
    function GetQty : Integer;
    function GetPrice : Single;
  public
    function Open(aAccount: TAccount; aSymbol: TSymbol;
      aPositionType: TPositionType; aOrderType : TOrderType;
      iMaxQty: Integer; dPrice: Double) : Boolean;
    property Qty : Integer read GetQty;
    property Price : Single read GetPrice;
  end;

var
  BoardOrderDialog: TBoardOrderDialog;

implementation

{$R *.dfm}

function TBoardOrderDialog.GetPrice: Single;
begin
  Result := StrToFloat(EditPrice.Text);
end;

function TBoardOrderDialog.GetQty: Integer;
begin
  Result := StrToInt(EditQty.Text);
end;

procedure TBoardOrderDialog.EditQtyChange(Sender: TObject);
var
  iQty : Integer;
begin
  if EditQty.Text = '' then Exit;
  //
  try
    iQty := StrToInt(EditQty.Text);
    if (iQty > 0) then
      EditQty.Font.Color := clBlue
    else
      EditQty.Font.Color := clRed;
  except
    Abort;
  end;
end;

procedure TBoardOrderDialog.EditPriceChange(Sender: TObject);
var
  sPrice : Single;
  aEdit : TEdit;
begin
  aEdit := Sender as TEdit;
  if aEdit.Text = '' then Exit;
  //
  try
    sPrice := StrToFloat(aEdit.Text);
    if FSymbol <> nil then
      if (sPrice >= FSymbol.LimitLow) and (sPrice <= FSymbol.LimitHigh) then
      begin
        EditPrice.Font.Color := clBlue;
        if FOrderType = otNormal then
        begin
          EditQtyChange(EditQty);
        end;
      end else
      begin
        EditPrice.Font.Color := clRed;
        if FOrderType = otNormal then
        begin
          EditQtyChange(EditQty);
        end;
      end;
  except
    Abort;
  end;
end;

procedure TBoardOrderDialog.ButtonOKClick(Sender: TObject);
var
  stError : String;
begin
  // 수량
  if (StrToIntDef(EditQty.Text,0) = 0) then
  begin
    ShowMessage('수량이 부적절합니다.');
    EditQty.SetFocus;
    Exit;
  end else
  // 가격
  if (FOrderType <> otCancel) and
     not CheckPrice(FSymbol, EditPrice.Text, stError) then
  begin
    ShowMessage(stError);
    EditPrice.SetFocus;
  end else
    ModalResult := mrOK;
end;

procedure TBoardOrderDialog.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_RETURN then
    SelectNext(ActiveControl as TWinControl, true, true);
end;

function TBoardOrderDialog.Open(aAccount: TAccount;
  aSymbol: TSymbol; aPositionType: TPositionType;
  aOrderType: TOrderType; iMaxQty: Integer; dPrice: Double ): Boolean;
begin
  Result := False;
  if (aAccount = nil) or (aSymbol = nil) then Exit;
  //-- save value 
  FAccount := aAccount;
  FSymbol := aSymbol;
  FOrderType := aOrderType;
  FPositionType := aPositionType;
  // FMaxQty := iMaxQty;
  //-- title
  case aOrderType of
    otChange : Caption := '정정';
    otCancel : Caption := '취소';
    else
      Caption := '주문';
  end;

  ButtonOK.Caption := '전 송(&S)';
  //--
  //-- account
  LabelAccount.Caption := aAccount.Name;
  //-- Symbol
  LabelSymbol.Caption := FSymbol.Name;
  //-- L/S
  LabelPosition.Caption := POSITIONTYPE_DESCS[aPositionType];
  //-- visibility of Price
  LabelPrice.Visible := (aOrderType <> otCancel);
  EditPrice.Visible := LabelPrice.Visible;
  //-- initial Value
  EditQty.Text := IntToStr(iMaxQty);
  EditPrice.Text := Format('%.2f', [dPrice]);
  //--
  Result := (ShowModal = mrOK);
end;

end.
