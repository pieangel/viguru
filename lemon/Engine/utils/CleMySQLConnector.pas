unit CleMySQLConnector;

interface

uses
  Classes, DBXpress, SqlExpr,SysUtils,
   ADODB, ActiveX;
type
  TMySQLConnector = class
  private
    FConn2: TADOConnection;
    FDataSet2: TADOQuery;
    FDataSet: TADOQuery;
    FMdb: String;

    function GetConnected: Boolean;

  protected
    FHost: String;
    FConn: TSQLConnection;
    FSqlQuery : TSQLQuery ;
    
    FServer: String;
    FDB: String;
    FUser: String;
    FPassword: String;

  public
    constructor Create;
    destructor Destroy; override;

    function Connect(stHost, stDatabase, stUser, stPwd: String): Boolean; overload;
    function Connect: Boolean; overload;
    procedure SetConString( bSql : boolean );
    procedure SetMdbConString( stTable : string );
    procedure Disconnect( bActive : boolean = false );

    property Connected: Boolean read GetConnected;
    property SQLQuery: TSQLQuery read FSqlQuery;

    //*^^*
    property Conn2 : TADOConnection read FConn2;
    property DataSet : TADOQuery read FDataSet;

    property Server: String read FServer write FServer;
    property DB: String read FDB write FDB;
    property User: String read FUser write FUser;
    property Password: String read FPassword write FPassword;
    property Mdb: String read FMdb write FMdb;

    
  end;

implementation

uses GleTypes,GAppEnv;

{ TMySQLConnector }

constructor TMySQLConnector.Create;
var stCon : string;
begin
  CoInitialize(nil);
  FConn2 := TADOConnection.Create(nil);
  FDataSet := TADOQuery.Create(nil);
  FDataSet.Connection := FConn2;


  //FConn2.ConnectionString := 'DRIVER={MySQL ODBC 3.51 Driver}; SERVER=172.17.104.130; DATABASE=orpdb; User Id=root; Password=admin;';


  {
  FConn := TSQLConnection.Create(nil);

  FSqlQuery := TSQLQuery.Create(nil);
    //
  FConn.DriverName := 'DBxmysql';
  FConn.GetDriverFunc := 'getSQLDriverMYSQL50';
  FConn.LibraryName := 'dbxopenmysql50.dll';
  FConn.VendorLib := 'libmysql.dll';
  FConn.LoginPrompt := false;

    //
  FDataset.SQLConnection := FConn;
  FDataset.SchemaName := 'misfitdb';

  FSqlQuery.SQLConnection := FConn ;
  //FDataset.Active := ;
  }
end;

destructor TMySQLConnector.Destroy;
begin
  FSqlQuery.Free ; 
  FDataSet.Close ;
  FDataSet.Free;
  //FConn.Free;
  FConn2.Close;
  FConn2.Free;
  CoUninitialize;
  inherited;
end;

function TMySQLConnector.Connect(stHost, stDatabase, stUser,
  stPwd : String ): Boolean;
begin
  if FConn2.Connected then
  begin
    Result := true;
    Exit;
  end;

  try
    try
      FConn2.Open();
      {
      FConn.Params.Clear;
      FConn.Params.Add('hostname=' + stHost);
      FConn.Params.Add('database=' + stDatabase);
      FConn.Params.Add('user_name=' + stUser);
      FConn.Params.Add('password=' + stPwd);
      FConn.Params.Add('ServerCharSet=euckr' );

      FConn.Connected := True;
      }
    except
      on E : Exception do
        gLog.Add( lkError, 'SQLConnect', 'Connect', E.Message );
    end;
  finally
    Result := FConn2.Connected;
  end;
end;

function TMySQLConnector.Connect: Boolean;
begin
  Result := Connect(FServer, FDB, FUser, FPassword);
end;

procedure TMySQLConnector.Disconnect( bActive : boolean = false );
begin
  if not bActive then
    FConn2.Connected := bActive;
end;


function TMySQLConnector.GetConnected: Boolean;
begin
  Result := FConn2.Connected;
end;

procedure TMySQLConnector.SetConString( bSql : boolean );
var stCon : string;
begin
  //FConn2.ConnectionString := 'DRIVER={MySQL ODBC 3.51 Driver}; SERVER=172.17.104.130; DATABASE=orpdb; User Id=root; Password=admin;';

  if bSql then
    stCon := Format('Provider=SQLOLEDB.1;Password=%s;Persist Security '+
                  ' Info=True;User ID=%s;Initial Catalog=%s;Data Source=%s',
        [Password,
         User,
         DB,
         Server])

  else
    stCon := Format('Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;' +
                  'Data Source = %s',
        [Mdb]);

  FConn2.ConnectionString := stCon;

end;

procedure TMySQLConnector.SetMdbConString(stTable: string);
var stCon : string;
begin
  stCon := Format('Provider=Microsoft.Jet.OLEDB.4.0;Persist Security Info=False;' +
                  'Data Source = %s',
        [stTable]);

  FConn2.ConnectionString := stCon;
end;

end.
