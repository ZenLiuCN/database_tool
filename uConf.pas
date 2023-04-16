unit uConf;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Variants,
  Vcl.Forms,
  System.IniFiles,
  Vcl.Controls;

type
  TConf = class
    Inf: TIniFile;
    Root: string; { exe root }
    { conf }
    Debug: BOOL;
    ProcInterval: Integer;

    Title: string; { window title }
    { ui }

    LblStore: string;
    BtnOpen: string;

    BtnStart: string;
    BtnStop: string;

    BtnBackup: string;
    BtnRestore: string;
    BtnReload: string;

    DlgOpenData: string;
    DlgOpenBackup: string;
    DlgOpenRestore: string;

    HintStore: string;
    HintOpen: string;

    HintStart: string;
    HintStop: string;

    HintBackup: string;
    HintRestore: string;
    HintReload: string;
    HintClear: string;
    HintTray: string;
    MsgBoxErr: string;
    { errors }
    ErrReloadWhenRun: string;
    ErrSwitchWhenRun: string;
    ErrNoData: string;
    ErrMissingCmd: string;
    ErrServiceQuit: string;
    { infos }
    ConfReloaded: string;
    ModeChanged: string;

    ServiceStart: string;
    ServiceStop: string;
    ServiceStarted: string;
    ServiceStopped: string;
    ServiceStopFail: string;
    ServiceStartFail: string;
    ServiceWaitClose: string;

    BackupStart: string;
    BackupDone: string;
    BackupFail: string;

    RestoreStart: string;
    RestoreDone: string;
    RestoreFail: string;

    ArchiveStart: string;
    ArchiveDone: string;
    ArchiveFail: string;

    UnarchiveStart: string;
    UnarchiveDone: string;
    UnarchiveFail: string;

    InitDatabaseStart: string;
    InitDatabaseDone: string;
    InitDatabaseFail: string;

    Tabs: TStrings;

    ParamDb: string;

    ProcExec: string;
    CmdLaunch: string;
    CmdInit: string;
    CmdStop: string;
    CmdBackupOl: string;
    CmdBackup: string;
    CmdRestoreOl: string;
    CmdRestore: string;
    CmdArchive: string;
    CmdUnArchive: string;
    BackupExt: string;
    ArcExt: string;
  private
  public
    function Fix(Section, Name, Def: string): string;
    procedure Init();
    procedure Load(sec: string);

  end;

var
  conf: TConf;

implementation

uses
  System.DateUtils,
  System.IOUtils;

function TConf.Fix(Section, Name, Def: string): string;
begin
  Result := Inf.ReadString(Section, Name, Def);
  if Result.Contains('@') then
    Result := Result.Replace('@', Root);

end;

procedure TConf.Init();
begin
  Root := ExtractFilePath(Application.ExeName);
  Title := '���ݿ⹤��';
  Tabs := TStringList.Create;
  var ini := ChangeFileExt(Application.ExeName, '.ini');
  if System.SysUtils.FileExists(ini) then begin
    Inf := TIniFile.Create(ini); // create inf

    Debug := Inf.ReadBool('conf', 'debug', False);
    ProcInterval := Inf.ReadInteger('conf', 'proc_interval', 1000);

    Title := Inf.ReadString('lang', 'win_title', '���ݿ⹤��');
    LblStore := Inf.ReadString('lang', 'lbl_store', '����Ŀ¼');
    BtnOpen := Inf.ReadString('lang', 'btn_open', 'ѡ��');
    BtnStart := Inf.ReadString('lang', 'btn_start', '����');
    BtnStop := Inf.ReadString('lang', 'btn_stop', 'ֹͣ');
    BtnBackup := Inf.ReadString('lang', 'btn_backup', '����');
    BtnRestore := Inf.ReadString('lang', 'btn_restore', '��ԭ');
    BtnReload := Inf.ReadString('lang', 'btn_reload', '����');

    DlgOpenData := Inf.ReadString('lang', 'dlg_open_data', 'ѡ�����ݿ��ļ���');
    DlgOpenBackup := Inf.ReadString('lang', 'dlg_open_backup', '���汸������');
    DlgOpenRestore := Inf.ReadString('lang', 'dlg_open_restore', 'ѡ�񱸷�����');

    HintOpen := Inf.ReadString('lang', 'hint_open', '�����ݿ�Ŀ¼');
    HintStart := Inf.ReadString('lang', 'hint_start', '�������ݿ�');
    HintStop := Inf.ReadString('lang', 'hint_stop', 'ֹͣ���ݿ�');
    HintBackup := Inf.ReadString('lang', 'hint_backup', '�������ݿ�');
    HintRestore := Inf.ReadString('lang', 'hint_restore', '��ԭ���ݿ�');
    HintReload := Inf.ReadString('lang', 'hint_reload', '�ؼ�������');
    HintClear := Inf.ReadString('lang', 'hint_clear', '�����־');
    HintTray := Inf.ReadString('lang', 'hint_tray', '˫����ʾ����');
    MsgBoxErr := Inf.ReadString('lang', 'msgbox_err', '����');

    ErrReloadWhenRun := Inf.ReadString('lang', 'err_reload', '����ʱ���ܼ�������');
    ErrNoData := Inf.ReadString('lang', 'err_data', 'δѡ�����ݿ�Ŀ¼');
    ErrMissingCmd := Inf.ReadString('lang', 'err_missing_cmd', 'δ��������');
    ErrSwitchWhenRun := Inf.ReadString('lang', 'err_change', '��������ʱ�����л����ݿ�');
    ErrServiceQuit := Inf.ReadString('lang', 'err_quit', '�����쳣�˳�');

    ConfReloaded := Inf.ReadString('lang', 'conf_reload', '�����������');
    ModeChanged := Inf.ReadString('lang', 'tab_change', '�л�');

    ServiceStart := Inf.ReadString('lang', 'service_start', '��������');
    ServiceStarted := Inf.ReadString('lang', 'service_started', '�����������');
    ServiceStartFail := Inf.ReadString('lang', 'service_start_fail', '��������ʧ��');
    ServiceStop := Inf.ReadString('lang', 'service_stop', 'ֹͣ����');
    ServiceStopped := Inf.ReadString('lang', 'service_stopped', '����ֹͣ���');
    ServiceStopFail := Inf.ReadString('lang', 'service_stop_fail', 'ֹͣ����ʧ��');
    ServiceWaitClose := Inf.ReadString('lang', 'service_await', '�ȴ�����ر�');

    BackupStart := Inf.ReadString('lang', 'backup_start', '��ʼ����:');
    BackupFail := Inf.ReadString('lang', 'backup_fail', '����ʧ��');
    BackupDone := Inf.ReadString('lang', 'backup_done', '�������:');

    RestoreStart := Inf.ReadString('lang', 'restore_start', '��ʼ��ԭ:');
    RestoreDone := Inf.ReadString('lang', 'restore_done', '��ԭ���:');
    RestoreFail := Inf.ReadString('lang', 'restore_fail', '��ԭʧ��');

    ArchiveStart := Inf.ReadString('lang', 'arc_start', 'ѹ������');
    ArchiveDone := Inf.ReadString('lang', 'arc_done', 'ѹ���������');
    ArchiveFail := Inf.ReadString('lang', 'arc_fail', 'ѹ������ʧ��');

    UnarchiveStart := Inf.ReadString('lang', 'unarc_start', '��ѹ����');
    UnarchiveDone := Inf.ReadString('lang', 'unarc_done', '��ѹ�������');
    UnarchiveFail := Inf.ReadString('lang', 'unarc_fail', '��ѹ����ʧ��');

    InitDatabaseStart := Inf.ReadString('lang', 'db_init_start', '��ʼ�����ݿ�');
    InitDatabaseDone := Inf.ReadString('lang', 'db_init_done', '��ʼ�����ݿ����');
    InitDatabaseFail := Inf.ReadString('lang', 'db_init_fail', '��ʼ�����ݿ�ʧ��');

    Inf.ReadSections(Tabs);
    Tabs.Delete(Tabs.IndexOf('conf'));
    Tabs.Delete(Tabs.IndexOf('lang'));
  end
  else begin
    MessageBox(0, PChar(Format('�����ļ�������:%s' + #13#10 + ' Config File not found: %s', [ini, ini])), 'ERROR', MB_OK);
    Application.Terminate;
  end;

end;

procedure TConf.Load(sec: string);
begin
  ParamDb := Fix(sec, 'param_db', '');
  BackupExt := Inf.ReadString(sec, 'backup_ext', '');
  ArcExt := Inf.ReadString(sec, 'arc_ext', '');
  ProcExec := Inf.ReadString(sec, 'proc_exec', '');
  CmdLaunch := Fix(sec, 'cmd_launch', '');
  CmdInit := Fix(sec, 'cmd_init', '');
  CmdStop := Fix(sec, 'cmd_stop', '');
  CmdBackupOl := Fix(sec, 'cmd_backup_ol', '');
  CmdBackup := Fix(sec, 'cmd_backup', '');
  CmdRestoreOl := Fix(sec, 'cmd_restore_ol', '');
  CmdRestore := Fix(sec, 'cmd_restore', '');
  CmdArchive := Fix(sec, 'cmd_arc', '');
  CmdUnArchive := Fix(sec, 'cmd_unarc', '');
end;

initialization
  conf := TConf.Create;
  conf.Init();


finalization
  conf.Inf.Destroy;
  conf.Destroy;

end.

