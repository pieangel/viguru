unit DleOrderConfirm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,
    // lemon: symbol
  CleSymbols,
    // lemon: trade
  CleAccounts, CleOrders;

type
  TOrderConfirmDialog = class(TForm)
    Bevel1: TBevel;
    ButtonYes: TButton;
    ButtonNo: TButton;
    LabelType: TLabel;
    LabelAccount: TLabel;
    LabelSymbol: TLabel;
    LabelQty: TLabel;
    LabelPrice: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    LabelTimeToMarket: TLabel;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function ConfirmOrder(aParent : TForm; aOrderType : TOrderType;
  aAccount : TAccount; aSymbol : TSymbol; iSide, iVolume: Integer;
  pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
  iTargetOrderNo: Integer): Boolean;

implementation

{$R *.DFM}

function ConfirmOrder(aParent : TForm; aOrderType : TOrderType;
  aAccount : TAccount; aSymbol : TSymbol; iSide, iVolume: Integer;
  pcValue: TPriceControl; dPrice: Double; tmValue: TTimeToMarket;
  iTargetOrderNo: Integer): Boolean;
var
  aDlg : TOrderConfirmDialog;
begin
  aDlg := TOrderConfirmDialog.Create(aParent);
  try
      // order type
    case aOrderType of
      otNormal: if iSide > 0 then
                  aDlg.LabelType.Caption := 'Buy'
                else
                  aDlg.LabelType.Caption := 'Sell';
      otChange: aDlg.LabelType.Caption := 'Change(' + IntToStr(iTargetOrderNo) + ')'; 
      otCancel: aDlg.LabelType.Caption := 'Cancel(' + IntToStr(iTargetOrderNo) + ')';
    end;
      // account
    if aAccount <> nil then
      aDlg.LabelAccount.Caption := aAccount.Name;
      // symbol
    if aSymbol <> nil then
      aDlg.LabelSymbol.Caption := aSymbol.Name;
      // volume
    aDlg.LabelQty.Caption := IntToStr(iVolume);
      // price
    if aOrderType in [otNormal, otChange] then
      case pcValue of
        pcLimit        : aDlg.LabelPrice.Caption := Format('%.2f Limit', [dPrice]);
        pcMarket       : aDlg.LabelPrice.Caption := 'Market';
        pcLimitToMarket: aDlg.LabelPrice.Caption := Format('%.2f Limit-to-Market', [dPrice]);
        pcBestLimit    : aDlg.LabelPrice.Caption := 'Best Limit';
      end
    else
      aDlg.LabelPrice.Caption := '';
      // Time to market
    case tmValue of
      tmGTC: aDlg.LabelTimeToMarket.Caption := 'Good-till-Canceled';
      tmFOK: aDlg.LabelTimeToMarket.Caption := 'Fill-or-Kill';
      tmIOC: aDlg.LabelTimeToMarket.Caption := 'Immediate-or-Canceled';
      tmFAS: aDlg.LabelTimeToMarket.Caption := 'Fill-and-Store';
    end;

      //
    Result := (aDlg.ShowModal = mrYes);
  finally
    aDlg.Free;
  end;
end;


end.
