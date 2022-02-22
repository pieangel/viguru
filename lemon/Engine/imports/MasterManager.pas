unit MasterManager;

interface

uses
  ADODB, DB, StdCtrls, SysUtils, Classes,  Windows,
    // application
  GleLib, CleParsers, SynthUtil;

type
  TMasterRecord = class(TCollectionItem)
  public
    Date: String;
    FileType: String;
    Code: String;
    ShortDesc: String;
    RemDays: Double;
    ClosingMonth: string;
    DividendRate: Double;
    PrevClose: Double;
    BasePrice: Double;
    HighLimit: Double;
    LowLimit: Double;
    CbHigh: Double;
    CbLow: Double;
    CdRate: Double;
    PrevOpenPositions: Double;
    StrikePrice: Double;
    IsATM: boolean;
    PrevIV: Double;
  end;

  TMasterRecords = class(TCollection)
  private
    function GetRecord(i: Integer): TMasterRecord;
  public
    constructor Create;
    property Records[i:Integer]: TMasterRecord read GetRecord; default;
  end;

  TMasterLogEvent = procedure(aRecord : TMasterRecord ) of Object;

  TMasterManager = class
  private
    FRecords: TMasterRecords;
    
    FOnLog : TStrings ;
    FOnMasterLog : TMasterLogEvent ;
    FADOConnection : TADOConnection ;
    FADOCommand1: TADOCommand;
    FADOCommand2: TADOCommand;
    FADOCommand3: TADOCommand;
    FADOCommand4: TADOCommand;
    FADODataSet1: TADODataSet;
    FADOQuery : TADOQuery ;
    procedure DeleteMaster( stDate : String ; stType : String) ;  overload ;
    procedure DeleteMaster( stDate : String; stType : String ; stCode : String ) ;  overload ;
    procedure SaveMaster(  stType : String ; MasterData : TMasterRecord );

    function LoadDrvmasterFuture( stRecord : String)  : TMasterRecord ;
    function LoadDrvmasterOption( stRecord : String) : TMasterRecord ;
  public
    constructor Create(stConnectionStr : String) ; overload ;
    destructor Destroy; override;

      // Select
    function GetMaster(stDate: String): Integer; overload;
    function GetMaster(stDate, stType: String): Integer; overload;
    function GetMasterLastDate: TDateTime;

      // Import
    function LoadDrvmaster(stFile,stDate : String): Boolean;
    function LoadGosumast(stFile,stDate : String): Boolean;
    function LoadOptmast(stFile,stDate : String): Boolean;
    function LoadHolidays(stFile : String): Boolean;
    function LoadExpdates(stFile : String): Boolean;

      //
    property Records: TMasterRecords read FRecords;
    property OnLog : TStrings read FOnLog write FOnLog ;
    property OnMasterLog : TMasterLogEvent read FOnMasterLog write FOnMasterLog ;
  end;

const
  GOSU_MASTER = '1';
  FTOPT_MASTER = '2';
  DRV_MASTER = '3';

implementation

{ TMasterRecordCollection }

constructor TMasterRecords.Create;
begin
  inherited Create(TMasterRecord);
end;

function TMasterRecords.GetRecord(i: Integer): TMasterRecord;
begin
  if (i >= 0) and (i <= Count-1) then
    Result := Items[i] as TMasterRecord
  else
    Result := nil;
end;


{ TMasterParser }

// ---------- << constructor / destructor >> ---------- //

constructor TMasterManager.Create(stConnectionStr : String) ;
begin
  // 'Provider=MSDASQL.1;Persist Security Info=False;Data Source=QuoteDB'
  // 'Provider=Microsoft.Jet.OLEDB.4.0;Data Source=QuoteDB.mdb;Persist Security Info=False
  FADOConnection := TADOConnection.Create(nil) ;
  FADOConnection.ConnectionString :=
    'Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;Data Source='+stConnectionStr;
  
  FADOCommand1 := TADOCommand.Create(nil);
  FADOCommand2 := TADOCommand.Create(nil);
  FADOCommand3 := TADOCommand.Create(nil);
  FADOCommand4 := TADOCommand.Create(nil);
  FADODataSet1 := TADODataSet.Create(nil);
  FADOQuery :=  TADOQuery.Create(nil);
  FADOCommand1.Connection := FADOConnection ;
  FADOCommand2.Connection := FADOConnection ;
  FADOCommand3.Connection := FADOConnection ;
  FADOCommand4.Connection := FADOConnection ;
  FADODataSet1.Connection := FADOConnection ;
  FADOQuery.Connection := FADOConnection ;

  FRecords := TMasterRecords.Create;
end;

destructor TMasterManager.Destroy;
begin
  FRecords.Free;
  
  FADOCommand1.Free;
  FADOCommand2.Free;
  FADOCommand3.Free;
  FADOCommand4.Free;
  FADODataSet1.Free;
  FADOQuery.Close;
  FADOQuery.Free;
  FADOConnection.Close;
  FADOConnection.Free;
    //  
  inherited;
end;

// ---------- << private >> ---------- //

// --- delete master

procedure TMasterManager.DeleteMaster(stDate, stType: String);
begin
    //
  FADOCommand4.CommandText :=
    'delete from SymbolMaster ' +
    'where MasterDate = :stDate and fileType = :stType' ;
  FADOCommand4.Parameters.ParamByName('stDate').Value :=
            trim(stDate) ;
  FADOCommand4.Parameters.ParamByName('stType').Value := stType ;
  FADOCommand4.Execute ;

  if Assigned(OnLog) then
    OnLog.add('delete Master [date] ' + stDate
      + ' [type] ' + stType   ) ; 
end;

procedure TMasterManager.DeleteMaster(stDate, stType, stCode: String);
begin
  //
  FADOCommand4.CommandText :=
    'delete from SymbolMaster ' +
    'where MasterDate = :stDate and fileType = :stType ' +
    ' and Code = :stCode '  ;
  FADOCommand4.Parameters.ParamByName('stDate').Value :=
            trim(stDate) ;
  FADOCommand4.Parameters.ParamByName('stType').Value := stType ;
  FADOCommand4.Parameters.ParamByName('stCode').Value := stCode ;
  FADOCommand4.Execute ;
  if Assigned(OnLog) then
    OnLog.add('delete Master [date] ' + stDate
      + ' [type] ' + stType + ' [code] ' + stCode   ) ;
end;


// --- insert master

procedure TMasterManager.SaveMaster(stType: String;
  MasterData: TMasterRecord);
begin
  FADOCommand3.CommandText := 'insert into SymbolMaster( '
    + 'MasterDate, FileType, Code, ShortDesc, RemDays, '
    + 'ClosingMonth, DividendRate, PrevClose, BasePrice, HighLimit, '
    + 'LowLimit, CbHigh, CbLow, CdRate, PrevOpenPositions, '
    + 'StrikePrice, IsATM, PrevIV ) values ( '
    + ':MasterDate, :FileType, :Code, :ShortDesc, :RemDays,  '
    + ':ClosingMonth, :DividendRate, :PrevClose, :BasePrice, :HighLimit, '
    + ':LowLimit, :CbHigh, :CbLow, :CdRate, :PrevOpenPositions, '
    + ':StrikePrice, :IsATM, :PrevIV ) ' ;
  //
  with  FADOCommand3.Parameters, MasterData  do
  begin
    ParamByName('MasterDate').Value := Date ;
    ParamByName('FileType').Value := stType   ;
    ParamByName('Code').Value := Code   ;

    ParamByName('ShortDesc').Value := ShortDesc   ;
    ParamByName('RemDays').Value := RemDays   ;
    ParamByName('ClosingMonth').Value := Copy(ClosingMonth, 1, 6); //CA003: modified -- make sure it has 6 characters

    ParamByName('DividendRate').Value := DividendRate   ;
    ParamByName('PrevClose').Value := PrevClose   ;
    ParamByName('BasePrice').Value := BasePrice   ;
    ParamByName('HighLimit').Value := HighLimit   ;

    ParamByName('LowLimit').Value := LowLimit ;
    ParamByName('CbHigh').Value := CbHigh   ;
    ParamByName('CbLow').Value := CbLow   ;
    ParamByName('CdRate').Value := CdRate   ;
    ParamByName('PrevOpenPositions').Value := PrevOpenPositions   ;

    ParamByName('StrikePrice').Value := StrikePrice ;
    ParamByName('IsATM').Value := IsATM   ;
    ParamByName('PrevIV').Value := PrevIV   ;
    
  end;
  FADOCommand3.Execute ;
end;


// --- parsing drvmaster future 

function TMasterManager.LoadDrvmasterFuture(stRecord: String): TMasterRecord;
var
  stToken : String ;
  aRecord : TMasterRecord ;
begin
  //
  aRecord := FRecords.Add as TMasterRecord; 
  with aRecord do
  begin
    // 1 ~ 10 
    stToken := copy( stRecord , 36 , 8 ) ;    // �����ڵ�   8   ( Code)
    if stToken[1] = '1' then // ���� ( stFurues )
      Code := Copy(stToken, 1, 5)
    else
      Code := stToken ;  
    stToken := copy( stRecord , 44 , 4 ) ;    // ����Seq    4
    stToken := copy( stRecord , 48 , 30 ) ;    // �ѱ������ 30
    stToken := copy( stRecord , 78 , 30 ) ;    // ��������� 30
    stToken := copy( stRecord , 108 , 15 ) ;    // �������� 15 ( ShortDesc)
    ShortDesc := stToken ; 

    stToken := copy( stRecord , 123 , 4 ) ;    // �����  4
    stToken := copy( stRecord , 127 , 8 ) ;    // ������  8
    stToken := copy( stRecord , 135 , 3 ) ;    // �����ϼ� 3
    stToken := copy( stRecord , 138 , 3 ) ;    // �����ϼ� 3   ( RemDays)
    RemDays := strToFloat(stToken) ;  
    stToken := copy( stRecord , 141 , 8 ) ;    // ���� �ŷ��� 8  ( ClosingMonth )
    ClosingMonth := stToken ; 

    // 11 ~ 20
    stToken := copy( stRecord , 149 , 1 ) ;    // ���� �ŷ��� ����  1
    stToken := copy( stRecord , 150 , 9 ) ;    // �������� �̷���ġ  9 ( DividendRate )
    DividendRate := strToFloat(stToken)/1000000.0 ;  
    stToken := copy( stRecord , 159 , 1 ) ;    // ���ذ��� ����   1
    stToken := copy( stRecord , 160 , 6 ) ;    // ���ذ�   6    ( BasePrice )
    BasePrice := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 166 , 6 ) ;    // �̷а���(���갡) 6

    stToken := copy( stRecord , 172 , 6 ) ;    // �̷а���(���ذ�) 6
    stToken := copy( stRecord , 178 , 6 ) ;    // CD�ݸ�     6
    CdRate := strToFloat(stToken)/100000.0 ;  
    stToken := copy( stRecord , 184 , 1 ) ;    // SIGN ��ȣ  1
    stToken := copy( stRecord , 185 , 6 ) ;    // ���Ѱ�    6   ( HighLimit )
    HighLimit := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 191 , 1 ) ;    // SIGN ��ȣ   1

    // 21 ~ 30
    stToken := copy( stRecord , 192 , 6 ) ;    // ���Ѱ�  6     ( LowLimit )
    LowLimit :=  strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 198 , 1 ) ;    // ���� ���갡�� ���� 1
    stToken := copy( stRecord , 199 , 6 ) ;    // ���� ���갡��   6
    stToken := copy( stRecord , 205 , 1 ) ;    // ���� ��������  1
    stToken := copy( stRecord , 206 , 1 ) ;    // SIGN ��ȣ   1

    stToken := copy( stRecord , 207 , 6 ) ;    // ���� ����    6  ( PrevClose )
    PrevClose := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 213 , 8 ) ;    // ���� ü�����    8
    stToken := copy( stRecord , 221 , 8 ) ;    //  ���� �ٿ��� ü�����  8
    stToken := copy( stRecord , 229 , 8 ) ;    // ���� ������ ü����� 8
    stToken := copy( stRecord , 237 , 15 ) ;    // ���� ü���� 15

    // 31 ~ 40
    stToken := copy( stRecord , 252 , 15 ) ;    // ���� �ٿ��� ü����  15
    stToken := copy( stRecord , 267 , 15 ) ;    // ���� ������ ü����   15
    stToken := copy( stRecord , 282 , 8 ) ;    // ���Ϲ̰�����������(Ȯ��ġ) 8  ( PrevOpenPositions )
    PrevOpenPositions := strToFloat(stToken) ;
    stToken := copy( stRecord , 290 , 8 ) ;    // ������ �ְ� ����  8
    stToken := copy( stRecord , 298 , 1 ) ;    // SIGN ��ȣ  1

    stToken := copy( stRecord , 299 , 6 ) ;    // ������ �ְ�  6
    stToken := copy( stRecord , 305 , 8 ) ;    // ����������������  8
    stToken := copy( stRecord , 313 , 1 ) ;    // SIGN ��ȣ         1
    stToken := copy( stRecord , 314 , 6 ) ;    // ������ ������     6
    stToken := copy( stRecord , 320 , 12 ) ;    // ����ǥ���ڵ�     12

    // 41 ~ 50
    stToken := copy( stRecord , 332 , 8 ) ;    // ��ȸ����   8 
    stToken := copy( stRecord , 340 , 1 ) ;    // ���尡 ��뱸��   1
    stToken := copy( stRecord , 341 , 1 ) ;    // ���Ǻ������� ��뱸�� 1
    stToken := copy( stRecord , 342 , 1 ) ;    // ������������ ��뱸��  1
    stToken := copy( stRecord , 343 , 6 ) ;    // ������������    6

    stToken := copy( stRecord , 349 , 1 ) ;    // ������������  ����   1
    stToken := copy( stRecord , 350 , 6 ) ;    // CB������Ѱ�  6  ( CbHigh )
    CbHigh := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 356 , 6 ) ;    // CB�������Ѱ�  6  ( CbLow )
    CbLow := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 362 , 8 ) ;    // ���� �����Ÿ�ü��ð�  8
    stToken := copy( stRecord , 370 , 6 ) ;    // ���� �������� �ٿ��� ���� 6

    // 51 ~ 53
    stToken := copy( stRecord , 376 , 6 ) ;    // ���� �������� ������ ���� 6
    stToken := copy( stRecord , 382 , 12 ) ;    // �������� �ٿ��� ǥ���ڵ�  12
    stToken := copy( stRecord , 394 , 12 ) ;    // �������� ������ ǥ���ڵ�  12

    StrikePrice := 0 ;
    IsATM := false ;

    // end of text(1) 
  end ;

  Result := aRecord ;
end;


// --- parsing drvmaster option

function TMasterManager.LoadDrvmasterOption(stRecord: String): TMasterRecord;
var
  stToken : String ;
  aRecord : TMasterRecord ;
begin
  // 
  aRecord := FRecords.Add as TMasterRecord; 
  with aRecord do
  begin
    // 1 ~ 10 
    stToken := copy( stRecord , 37 , 8 ) ;    // ��ȸ����   8
    stToken := copy( stRecord , 45 , 4 ) ;    // ����Seq  4
    stToken := copy( stRecord , 49 , 12 ) ;    // �����ڵ�  12   ( Code )
    Code := Copy(stToken, 4, 8) ; 
    stToken := copy( stRecord , 61 , 1 ) ;    // �ɼ�����  1
    stToken := copy( stRecord , 62 , 2 ) ;    // �ŷ��������  2

    stToken := copy( stRecord , 64 , 6 ) ;    // ������   6     ( ClosingMonth )
    ClosingMonth :=  stToken ; 
    stToken := copy( stRecord , 70 , 6 ) ;    // ��簡��   6    ( StrikePrice )
    StrikePrice :=strToFloat( stToken) / 100.0 ;
    stToken := copy( stRecord , 76 , 4 ) ;    // ��ȸ Seq   4
    stToken := copy( stRecord , 80 , 30 ) ;    // ������ ���� �ѱ۸�   30
    stToken := copy( stRecord , 110 , 30 ) ;    // ������ ���� ������   30

    // 11 ~ 20
    stToken := copy( stRecord , 140 , 14 ) ;    // ������ ���� ����   14   ( ShortDesc )
    ShortDesc := stToken ; 
    stToken := copy( stRecord , 154 , 1 ) ;    // �Ǹ���� ��������    1
    stToken := copy( stRecord , 155 , 3 ) ;    // �����ϼ�             3
    stToken := copy( stRecord , 158 , 3 ) ;    // �����ϼ�             3  ( RemDays )
    RemDays := strToFloat(stToken) ;
    stToken := copy( stRecord , 161 , 1 ) ;    // �ֱٿ��� ����        1

    stToken := copy( stRecord , 162 , 1 ) ;    // ATM ����            1  ( IsATM )
    IsATM := (stToken = '1');   ; 
    stToken := copy( stRecord , 163 , 8 ) ;    // ������  8
    stToken := copy( stRecord , 171 , 8 ) ;    // ���� �ŷ��� 8
    stToken := copy( stRecord , 179 , 8 ) ;    // ���� �ŷ��� 8
    stToken := copy( stRecord , 187 , 1 ) ;    // ���� �ŷ��� ���� 1

    // 21 ~ 30
    stToken := copy( stRecord , 188 , 1 ) ;    // �ű�/�߰�/���� ����  1
    stToken := copy( stRecord , 189 , 8 ) ;    // �ű�/�߰�/������  8
    stToken := copy( stRecord , 197 , 9 ) ;    // �������� ���簡ġ  9 ( DividendRate )
    DividendRate :=  strToFloat(stToken)/1000000.0 ;
    stToken := copy( stRecord , 206 , 10 ) ;    // �̷а�   10 
    stToken := copy( stRecord , 216 , 6 ) ;    // ���� �ð�  6

    stToken := copy( stRecord , 222 , 6 ) ;    // ���� ��  6
    stToken := copy( stRecord , 228 , 6 ) ;    // ���� ����  6
    stToken := copy( stRecord , 234 , 6 ) ;    //  ���� ���� 6   ( PrevClose )
    PrevClose := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 240 , 1 ) ;    // ���� ��������  1
    stToken := copy( stRecord , 241 , 6 ) ;    // �Ÿ� ���ű� ���ذ�  6 

    // 31 ~ 40
    stToken := copy( stRecord , 247 , 1 ) ;    // �Ÿ����ű� ���ذ� ���� 1
    stToken := copy( stRecord , 248 , 6 ) ;    // ����ȣ������ (����ġ) 6   ( HighLimit )
    HighLimit := strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 254 , 6 ) ;    // ����ȣ������ (����ġ) 6   ( LowLimit )
    LowLimit :=  strToFloat(stToken)/100.0 ;
    stToken := copy( stRecord , 260 , 3 ) ;    // ���ݴ��� ���ذ�(3.00)  3
    stToken := copy( stRecord , 263 , 3 ) ;    // ȣ������ (0.01)   3

    stToken := copy( stRecord , 266 , 3 ) ;    // ȣ������ (0.05)  3
    stToken := copy( stRecord , 269 , 6 ) ;    // CD�ݸ�     6            ( CdRate )
    CdRate := strToFloat(stToken)/100000.0 ;
    stToken := copy( stRecord , 275 , 8 ) ;    // ���� �̰�����������  8  ( PrevOpenPositions )
    PrevOpenPositions := strToFloat(stToken) ;
    stToken := copy( stRecord , 283 , 8 ) ;    // ���ϰŷ���           8
    stToken := copy( stRecord , 291 , 15 ) ;    // ���ϰŷ����(��)     15

    // 41 ~ 50
    stToken := copy( stRecord , 306 , 8 ) ;    // ���� �ְ�����      8
    stToken := copy( stRecord , 314 , 6 ) ;    // ���� �ְ���      6
    stToken := copy( stRecord , 320 , 8 ) ;    // ���� ��������      8
    stToken := copy( stRecord , 328 , 6 ) ;    // ���� ��������      6
    stToken := copy( stRecord , 334 , 8 ) ;    // ������ �ְ�����    8 

    stToken := copy( stRecord , 342 , 6 ) ;    // ������ �ְ���    6
    stToken := copy( stRecord , 348 , 8 ) ;    // ������ ��������    8
    stToken := copy( stRecord , 356 , 6 ) ;    // ������ ��������    6
    stToken := copy( stRecord , 362 , 1 ) ;    // ���尡 ��뱸��    1
    stToken := copy( stRecord , 363 , 1 ) ;    // ���Ǻ������� ��뱸��  1

    // 51 ~ 54 
    stToken := copy( stRecord , 364 , 1 ) ;    // ������������ ��뱸��  1
    stToken := copy( stRecord , 365 , 6 ) ;    // ���ذ�  6       ( BasePrice )
    BasePrice := strToFloat(stToken) / 100.0  ;
    stToken := copy( stRecord , 371 , 1 ) ;    // ���ذ�����  1
    stToken := copy( stRecord , 372 , 6 ) ;    // ���纯����  6   ( PrevIV )
    PrevIV := strToFloat(stToken) / 1000.0 ;

    // filler(27) , end of text(1) 
  end ;
  Result := aRecord ;
end;


// ---------- << public >> ---------- //

// --- select master

function TMasterManager.GetMaster(stDate, stType : String): Integer;
var
  aRecord : TMasterRecord;
begin
  FRecords.Clear;

  //
  if Assigned(OnLog) then OnLog.add('[MasterDate] start ' + stDate ) ;

  with FADOQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT MasterDate, FileType, Code, ShortDesc, RemDays, ');
    SQL.Add(' ClosingMonth, DividendRate, PrevClose, BasePrice, HighLimit, ');
    SQL.Add(' LowLimit, CbHigh, CbLow, CdRate, PrevOpenPositions, ');
    SQL.Add(' StrikePrice, IsATM, PrevIV ');
    SQL.Add('FROM SymbolMaster ');
    SQL.Add('WHERE MasterDate = :Date  and FileType = :stType ' ) ;

    Parameters.ParamValues['Date'] := Trim(stDate);
    Parameters.ParamValues['stType'] := Trim(stType);

    Open;

	  First;
    while Not EOF do
    begin
      aRecord := FRecords.Add as TMasterRecord;
      aRecord.Date := FieldByName('MasterDate').AsString;
      // if Assigned(OnLog) then OnLog.add('[MasterDate] ' + FieldByName('MasterDate').AsString ) ;
      Next;
    end;

    Close;
  end;

  if Assigned(OnLog) then OnLog.add('[MasterDate] end ' + stDate ) ;

  Result := FRecords.Count;
end;

function TMasterManager.GetMaster(stDate : String): Integer;
var
  aRecord: TMasterRecord;
begin
  FRecords.Clear;
    //
  if Assigned(OnLog) then OnLog.add('[MasterDate] start ' + stDate ) ;

  with FADOQuery do
  begin
    Close;
    SQL.Clear;
    SQL.Add('SELECT MasterDate, FileType, Code, ShortDesc, RemDays, ');
    SQL.Add(' ClosingMonth, DividendRate, PrevClose, BasePrice, HighLimit, ');
    SQL.Add(' LowLimit, CbHigh, CbLow, CdRate, PrevOpenPositions, ');
    SQL.Add(' StrikePrice, IsATM, PrevIV ');
    SQL.Add('FROM SymbolMaster ');
    SQL.Add('WHERE MasterDate = :Date ' ) ;

    Parameters.ParamValues['Date']  := trim(stDate)   ;

    try
      Open;

	    First;
      while not EOF do
      begin
        aRecord := FRecords.Add as TMasterRecord;

        aRecord.Date := FieldByName('MasterDate').AsString;
        aRecord.FileType := FieldByName('FileType').AsString;
        aRecord.Code := FieldByName('Code').AsString;
        aRecord.ShortDesc := FieldByName('ShortDesc').AsString;
        aRecord.RemDays := FieldByName('RemDays').AsFloat;

        aRecord.ClosingMonth := FieldByName('ClosingMonth').AsString;
        aRecord.DividendRate := FieldByName('DividendRate').AsFloat;
        aRecord.PrevClose := FieldByName('PrevClose').AsFloat;
        aRecord.BasePrice := FieldByName('BasePrice').AsFloat;
        aRecord.HighLimit := FieldByName('HighLimit').AsFloat;

        aRecord.LowLimit := FieldByName('LowLimit').AsFloat;
        aRecord.CbHigh := FieldByName('CbHigh').AsFloat;
        aRecord.CbLow := FieldByName('CbLow').AsFloat;
        aRecord.CdRate := FieldByName('CdRate').AsFloat;
        aRecord.PrevOpenPositions := FieldByName('PrevOpenPositions').AsFloat;

        aRecord.StrikePrice := FieldByName('StrikePrice').AsFloat;
        aRecord.IsATM := FieldByName('IsATM').AsBoolean;
        aRecord.PrevIV := FieldByName('PrevIV').AsFloat;

        // if Assigned(OnLog) then OnLog.add('[MasterDate] ' + FieldByName('MasterDate').AsString ) ;
        Next;
      end;
    finally
      Close;
    end;
  end;

  if Assigned(OnLog) then OnLog.add('[MasterDate] end ' + stDate ) ;

  Result := FRecords.Count;
end;

// --- Load master

function TMasterManager.LoadGosumast(stFile, stDate : String) : Boolean;
var
  i : integer ;
  aParser: TParser;
  aFileBuf : TStringList;
  stRecord, stType : String ;
  //
  aRecord : TMasterRecord ;
begin
  Result := False;
  aFileBuf := nil;
  aParser := nil;
    //
  try
    aFileBuf := TStringList.Create;
    aParser := TParser.Create(['|']);

    stType := GOSU_MASTER ;
    aFileBuf.LoadFromFile(stFile );
    DeleteMaster( stDate, stType );

    for i:=0 to aFileBuf.Count-1 do
        begin

          stRecord := aFileBuf.Strings[i];

          if aParser.Parse(stRecord) <= 0 then Continue;

          // �����ɼ�
          if CompareStr(aParser[0], '01') = 0 then
          begin

            aRecord :=  FRecords.Add as TMasterRecord;

            with aRecord do
            begin
              Date := stDate ;
              Code := Trim(aParser[1]); // �����ڵ�
              //
              if Code[1] = '1' then // ���� ( stFurues )
              begin
                Code := Copy(Code, 1, 5);
              end ;

              ShortDesc := aParser[4] ;       // ��������
              RemDays := StrToInt(aParser[5]);      // �����ϼ�
              ClosingMonth := aParser[6]; // ������(�ŷ� ������)
              DividendRate := StrToFloat(aParser[7]) / 1000000.0;    // ���������̷���ġ
              PrevClose    := StrToFloat(aParser[8] ) / 100.0;      // ��������
              HighLimit    := StrToFloat(aParser[9]) / 100.0;       // ���Ѱ�
              LowLimit     := StrToFloat(aParser[10]) / 100.0;      // ���Ѱ�
              CdRate       := StrToFloat(aParser[11]) / 100000.0;   // CD�ݸ�
              PrevOpenPositions := StrToInt( aParser[12] );         // ���Ϲ̰�����������

              if code[1]  <>  '4' then
                BasePrice := StrToFloat( aParser[16] ) / 100.0 ;     // ���ذ�

              if ( Code[1] = '2' ) or ( Code[1] = '3' )   then
                StrikePrice := StrToFloat( aParser[17] ) / 100.0 ;  // ��簡

              IsATM := (aParser[18][1] = '1');           // ATM����   ATM ���� 1:ATM, 2:ITM, 3 OTM
              PrevIV := StrToFloat(aParser[19]) / 1000.0;    // ���簡ġ������

              if Code[1] = '1'  then // ����
              begin
                CBHigh := StrToFloat(aParser[20]) / 100.0; // CD���� ���Ѱ�
                CBLow  := StrToFloat(aParser[21]) / 100.0; // CB���� ���Ѱ�
              end;
            end ;

            // -- debug
            if Assigned(OnMasterLog) then OnMasterLog(aRecord);
            SaveMaster( stType , aRecord);

            aRecord.Destroy ;
          end ; // .. end if �����ɼ�
        end; // ...end for
  finally
    aParser.Free;
    aFileBuf.Free;
  end;
end;

function TMasterManager.LoadOptmast(stFile, stDate : String) : Boolean;
const
  K200_FO_LEN = 440;
var
  i, iRecCnt : integer ; 
  stRecord, stType, stPacket : String ;
  szBuf : array[0..600] of Char ; 
  iP : Integer;
  stValue : String;
  lValue : LongInt;
  //
  aRecord : TMasterRecord ;
begin
  Result := False;
      //
  try
    stType := FTOPT_MASTER;
    stPacket := FileToStr(stFile);
    if stPacket = '' then Exit;

    DeleteMaster(stDate, stType);
    iRecCnt := Length(stPacket) div K200_FO_LEN ;

    for i:=0 to iRecCnt-1 do
    begin
      stRecord := Copy(stPacket, i*K200_FO_LEN+1, K200_FO_LEN);
      CopyMemory(szBuf+0, @stRecord[1], Length(stRecord));

      aRecord :=  FRecords.Add as TMasterRecord;

      with aRecord do
      begin
        Date := stDate ;
    
        //
        iP := 0;
        DeconvertBytes(szBuf, iP, stValue, 8);
        Code := Trim(stValue); // �����ڵ�  
        if Code[1] = '1' then
          Code := Copy(Code, 1, 5);

        iP := iP + 20;
        DeconvertBytes(szBuf, iP, stValue, 30);  // �ѱ������
        DeconvertBytes(szBuf, iP, stValue, 30);  // ���������
        DeconvertBytes(szBuf, iP, stValue, 15);  // ����� , ��������
        ShortDesc := stValue ; 

        iP := iP + 17;
        DeconvertLong(szBuf, iP, lValue);     // �����ϼ�
        RemDays := lValue;
        DeconvertLong(szBuf, iP, lValue);     // ������
        ClosingMonth := IntToStr(lValue div 100);
        iP := iP + 4;
        DeconvertLong(szBuf, iP, lValue);     // ���������̷���ġ
        DividendRate := lValue / 1000000.0; 
        iP := iP + 20;
        DeconvertLong(szBuf, iP, lValue);  // ��������
        PrevClose := lValue / 100.0; 
        iP := iP + 4;
        DeconvertLong(szBuf, iP, lValue);  // ���Ѱ�
        HighLimit := lValue / 100.0;
        DeconvertLong(szBuf, iP, lValue);  // ���Ѱ�
        LowLimit := lValue / 100.0;
        DeconvertLong(szBuf, iP, lValue);  // CD�ݸ�
        CDRate := lValue / 100000.0;
        DeconvertLong(szBuf, iP, lValue);  // ���Ϲ̰������� ����(����: ���) , �̰�����������
        PrevOpenPositions := lValue; 
        iP := iP + 68;
        DeconvertLong(szBuf, iP, lValue);  // ���尡�ֹ���� ����
        // CanOrderAtMarket := (lValue = 1);
        DeconvertLong(szBuf, iP, lValue);  // ���Ǻν��尡 ��뱸��
        // CanOrderAtCondition := (lValue = 1);
        DeconvertLong(szBuf, iP, lValue);  // ������������ ��뱸��
        // CanOrderAtBestPrice := (lValue = 1);
        DeconvertLong(szBuf, iP, lValue);  // ���ذ�
        BasePrice := lValue / 100.0 ; 
        iP := iP + 40;
        DeconvertLong(szBuf, iP, lValue); // ��簡
        StrikePrice := lValue / 100.0; 
        iP := iP + 12;
        DeconvertLong(szBuf, iP, lValue); // ATM ����
        IsATM := (lValue = 1);
        iP := iP + 32;
        DeconvertLong(szBuf, iP, lValue); // ���簡ġ������
        PrevIV := lValue / 1000.0; 
        iP := iP + 12;
        DeconvertLong(szBuf, iP, lValue); // CB���� ���Ѱ�
        CBHigh := lValue / 100.0;
        DeconvertLong(szBuf, iP, lValue);  // CB���� ���Ѱ�
        CBLow := lValue / 100;

      end; //.. with

       // -- debug
      if Assigned(OnMasterLog) then OnMasterLog(aRecord);
      SaveMaster( stType , aRecord);

      aRecord.Destroy ;
      
    end; //.. for

  except

  end ;
end;

function TMasterManager.LoadDrvmaster(stFile,stDate : String) : Boolean;
var
  i : integer ;
  aFileBuf : TStringList;
  stRecord, stType, stToken : String ;
  //
  aRecord : TMasterRecord ;
begin
  aRecord := nil;
  result := true;
    //
  try
    aFileBuf := TStringList.Create;

    stType := DRV_MASTER  ;
    aFileBuf.LoadFromFile(stFile);
    DeleteMaster( stDate, stType );

    for i:=0 to aFileBuf.Count-1 do
        begin

          stRecord := aFileBuf.Strings[i];

          stToken := copy( stRecord , 1, 12 ) ;     // time & millisec
          stToken := copy( stRecord , 14, 2 ) ;     // PacketType	F2(����), O2(�ɼ�)

          // seqNo 6 (22)  , Date 8 (28) ,   Dummy 6 (36) -- future
          // seqNo 7 (23) , Date 8 (29) , Dummy 6(37)  -- option

          if CompareStr(stToken, 'F2') = 0 then //CA003: modified
          begin
            aRecord := LoadDrvmasterFuture(stRecord) ;
          end
          else if Comparestr(stToken, 'O2') = 0 then //CA003: modified
          begin
            aRecord := LoadDrvmasterOption(stRecord) ;
          end ;

          if (CompareStr(stToken, 'F2') = 0) or   //CA003: modified
             (CompareStr(stToken, 'O2') = 0) then
          begin
            with aRecord do
            begin
              Date := stDate  ;
            end;
            // -- debug
            if Assigned(OnMasterLog) then OnMasterLog(aRecord);

            DeleteMaster(stDate, stType, aRecord.Code);
            SaveMaster(stType, aRecord);

            aRecord.Destroy ;
          end;



        end; // ...end for

  except
    result := false;
  end ;

end;


// --- parsing & insert expdates 

function TMasterManager.LoadExpdates(stFile : String): Boolean;
var
  FH: TextFile;
  stRead: String;
  opt : TLocateOptions ;

  stDate, stFormatDate, stValue : String;
  dK200Index : Double ;
begin
  //
  Result := true ;

  if Assigned(OnLog) then OnLog.add('***** LoadExpdates *****') ;
  try
    FADODataSet1.commandText := 'select Expdate from Expdates'  ;
    FADODataSet1.Open ;
    opt :=  [loCaseInSensitive] ;
    AssignFile(FH, stFile );
    if not FileExists(stFile) then
    begin
      Exit;
    end;
    //
    Reset(FH);
    while not EOF(FH) do
    begin
      Readln(FH, stRead);
      stDate := Copy(stRead, 1, 8);
      stValue := Trim(Copy(stRead, 10, Length(stRead)-9));
      dK200Index := strToFloat(stValue) ;
      stFormatDate :=
            Copy(stDate,1,4) + '-' +
            Copy(stDate,5,2) + '-' +
            Copy(stDate,7,2)  ;

      FADOCommand2.CommandText := 'insert into Expdates( Expdate, K200Index) ' +
        'values( :stDate, :dK200Index) ' ;
      if not FADODataSet1.Locate( 'Expdate' , Variant(stFormatDate) , opt ) then
      begin
        FADOCommand2.Parameters.ParamByName('stDate').Value :=
            stFormatDate ;
        FADOCommand2.Parameters.ParamByName('dK200Index').Value :=
            dK200Index   ;
        FADOCommand2.Execute ;
        if Assigned(OnLog) then OnLog.add('add : ' + stRead ) ;
      end
      else
      begin
        if Assigned(OnLog) then OnLog.add('skip : ' + stRead ) ;
      end ;

    end;

    CloseFile(FH);
    FADODataSet1.Close ;

  except
    Result := false ;
  end ;
end;


// --- parsing & insert  holiday

function TMasterManager.LoadHolidays(stFile : String) : Boolean;
var
  FH: TextFile;
  stRead: String;
  opt : TLocateOptions ;
begin
  //
  Result := true ;

  if Assigned(OnLog) then OnLog.add('***** LoadHolidays *****') ;
  try
    FADODataSet1.commandText := 'select HolidayDate from Holidays'  ;
    FADODataSet1.Open ;
    opt :=  [loCaseInSensitive] ;
    AssignFile(FH, stFile );
    if not FileExists(stFile) then
    begin
      Exit;
    end;
    //
    FADOCommand1.CommandText := 'insert into Holidays(HolidayDate) ' +
      'values(:stDate) ' ;
    Reset(FH);
    while not EOF(FH) do
    begin
      Readln(FH, stRead);
      if not FADODataSet1.Locate( 'HolidayDate' , Variant(stRead) , opt ) then
      begin
        if Assigned(OnLog) then OnLog.add('add : ' + stRead ) ;
        FADOCommand1.Parameters.ParamByName('stDate').Value :=
            stRead ;
        FADOCommand1.Execute ; 
      end
      else
      begin
        if Assigned(OnLog) then OnLog.add('skip : ' + stRead ) ; 
      end ;

    end;

    CloseFile(FH);
    FADODataSet1.Close ;
    
  except
    Result := false ;
  end ; 

end;

//CA003: following
function TMasterManager.GetMasterLastDate : TDateTime;
var
  stResult: String;
begin
  Result := 0;
  
  if Assigned(OnLog) then
    OnLog.add('Get the last date of import of the master db') ;

  with FADOQuery do
  begin
    Close;

    SQL.Clear;
    SQL.Add('SELECT Max(MasterDate) FROM SymbolMaster ');

    OPEN;

    if RecordCount > 0 then
    begin
	    First;
      stResult := Fields[0].AsString;
      if Length(stResult) = 10 then // 'yyyy-mm-dd'
      try
        Result := EncodeDate(StrToIntDef(Copy(stResult,1,4), 0),
                             StrToIntDef(Copy(stResult,6,2), 0),
                             StrToIntDef(Copy(stResult,9,2), 0));
      except
        // ignore
      end;
    end;

    Close;
  end;

  if Assigned(OnLog) then
    OnLog.add('command done') ;
end;

end.
