unit CleCodes;

interface

uses
  Classes;

type
  TCode = record
     Key: Integer;
     Desc: String;
  end;

  TCodeItem = class(TCollectionItem)
  private
    FCode: TCode;
  public
    property Code: Integer read FCode.Key write FCode.Key;
    property Desc: String read FCode.Desc write FCOde.Desc;
  end;

  TCodes = class(TCollection)
  private
    function GetCode(iKey: Integer): TCode;
  public
    constructor Create;

    property Codes[iKey: Integer]: TCode read GetCode;
  end;

implementation

{ TCodes }

constructor TCodes.Create;
begin
  inherited Create(TCodeItem);
end;

function TCodes.GetCode(iKey: Integer): TCode;
begin

end;

end.
