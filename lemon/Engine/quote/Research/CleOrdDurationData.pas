unit CleOrdDurationData;

interface

uses
  Classes, Graphics;

type
  TOrdDurationData = class(TCollectionItem)
  private
    FSendTime : string;
    FDuraTime : string;
    FUserID : string;
    FAccountCode : string;
    FOrderType : string;
    FSymbolCode : string;
    FOrderNo : string;
  public
    property SendTime : string read FSendTime;
    property DuraTime : string read FDuraTime;
    property UserID : string read FUserID;
    property AccountCode : string read FAccountCode;
    property OrderType : string read FOrderType;
    property SymbolCode : string read FSymbolCode;
    property OrderNo : string read FOrderNo;
  end;

  TOrdDurationDatas = class(TCollection)
  private
    FSoundDir : string;
    FSoundCheck : boolean;
    FDuraColor : TColor;
  public
    constructor Create;
    destructor Destroy; override;
    procedure New( stSendTime, stDuraTime, stUserID, stType, stAccCode, stCode, stOrdNo : string);
    procedure InitData;
    property SoundDir : string read FSoundDir write FSoundDir;
    property SoundCheck : boolean read FSoundCheck write FSoundCheck;
    property DuraColor : TColor read FDuraColor write FDuraColor;
  end;

implementation

uses
  FleOrderDuration;

{ TOrdDurationDatas }

constructor TOrdDurationDatas.Create;
begin
  inherited Create(TOrdDurationData);
  FSoundDir := '';
  FSoundCheck := false;
  FDuraColor := clblack;
end;

destructor TOrdDurationDatas.Destroy;
begin

  inherited;
end;

procedure TOrdDurationDatas.InitData;
begin
  FSoundDir := '';
  FSoundCheck := false;
  FDuraColor := clBlack;
end;

procedure TOrdDurationDatas.New(stSendTime, stDuraTime, stUserID,
                           stType, stAccCode, stCode, stOrdNo: string);
var
  aData : TOrdDurationData;
begin
  aData := Add as TOrdDurationData;
  aData.FSendTime := stSendTime;
  aData.FDuraTime := stDuraTime;
  aData.FUserID := stUserID;
  aData.FOrderType := stType;
  aData.FAccountCode := stAccCode;
  aData.FSymbolCode := stCode;
  aData.FOrderNo := stOrdNo;
end;

end.
