unit GAppConsts;

interface

{$INCLUDE define.txt}

const
  DIR_DATA = 'database';
  DIR_OUTPUT = 'output';
  DIR_QUOTEFILES = 'quotefiles';
  DIR_FILLFILES = 'fillfiles';
  DIR_TEMPLATE  = 'Template';
  DIR_LOG = 'log';
  DIR_SIMUL = 'simulation';
  GI_COMPONET = 'giexpertmain.exe';

  DIR_ENV = 'env';

  FILE_UPDATER = 'grLauncher.exe';   //  실제 이름..
  FILE_NEW_UPDATE ='grLauncher_new.exe';   //  ftp 에서 받은..  --> FILE_UPDATER 로  이름을 바꿔준다.
  FILE_ENV = 'env.lsg';
  WIN_ENV= 'quoting.lsg';
  FILE_INI = 'config.ini';
  TIMER_ITEM = 'timer.lsg';
  FILE_HOLIDAYS = 'env/holidays.txt';
  FILE_LPCODE = 'elwlp.ini';
{$IFDEF KR_FUT}
  FILE_ENV2  = 'kr_env.ini';
{$ELSE}
  FILE_ENV2  = 'nh_env.ini';
{$ENDIF}
  FILE_ACNT  = 'VirAcnt.xml';

  FILE_PMITEM = 'krx_spec.inc';// 'PMItem.lsg';
  FILE_KR_FUND  = '\kr_fund.lsc';
  GURU_VERSION = 1;

  FILE_ACNT_INFO = 'acnt_info.lsg';

implementation

end.
