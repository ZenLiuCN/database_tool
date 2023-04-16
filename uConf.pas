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
    Debug: bool;
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
  Title := '数据库工具';
  Tabs := TStringList.Create;
  var
  ini := ChangeFileExt(Application.ExeName, '.ini');
  if System.SysUtils.FileExists(ini) then
  begin
    Inf := TIniFile.Create(ini); // create inf

    Debug := Inf.ReadBool('conf', 'debug', false);
    ProcInterval := Inf.ReadInteger('conf', 'proc_interval', 1000);

    Title := Inf.ReadString('lang', 'win_title', '数据库工具');
    LblStore := Inf.ReadString('lang', 'lbl_store', '数据库');
    BtnOpen := Inf.ReadString('lang', 'btn_open', '打开');
    BtnStart := Inf.ReadString('lang', 'btn_start', '启');
    BtnStop := Inf.ReadString('lang', 'btn_stop', '停');
    BtnBackup := Inf.ReadString('lang', 'btn_backup', '备');
    BtnRestore := Inf.ReadString('lang', 'btn_restore', '还');
    BtnReload := Inf.ReadString('lang', 'btn_reload', '载');

    DlgOpenData := Inf.ReadString('lang', 'dlg_open_data', '选择数据库文件夹');
    DlgOpenBackup := Inf.ReadString('lang', 'dlg_open_backup', '保存备份数据');
    DlgOpenRestore := Inf.ReadString('lang', 'dlg_open_restore', '选择备份数据');

    HintOpen := Inf.ReadString('lang', 'hint_open', '打开数据库目录');
    HintStart := Inf.ReadString('lang', 'hint_start', '启动数据库');
    HintStop := Inf.ReadString('lang', 'hint_stop', '停止数据库');
    HintBackup := Inf.ReadString('lang', 'hint_backup', '备份数据库');
    HintRestore := Inf.ReadString('lang', 'hint_restore', '还原数据库');
    HintReload := Inf.ReadString('lang', 'hint_reload', '重加载配置');
    HintTray := Inf.ReadString('lang', 'hint_tray', '双击显示窗口');
    MsgBoxErr := Inf.ReadString('lang', 'msgbox_err', '错误');

    ErrReloadWhenRun := Inf.ReadString('lang', 'err_reload', '运行时不能加载配置');
    ErrNoData := Inf.ReadString('lang', 'err_data', '未选择数据库目录');
    ErrMissingCmd := Inf.ReadString('lang', 'err_missing_cmd', '未配置命令');
    ErrSwitchWhenRun := Inf.ReadString('lang', 'err_change', '服务启动时不能切换数据库');
    ErrServiceQuit := Inf.ReadString('lang', 'err_quit', '服务异常退出');

    ConfReloaded := Inf.ReadString('lang', 'conf_reload', '加载配置完成');
    ModeChanged := Inf.ReadString('lang', 'tab_change', '切换');

    ServiceStart := Inf.ReadString('lang', 'service_start', '启动服务');
    ServiceStarted := Inf.ReadString('lang', 'service_started', '服务启动完毕');
    ServiceStartFail := Inf.ReadString('lang', 'service_start_fail', '服务启动失败');
    ServiceStop := Inf.ReadString('lang', 'service_stop', '停止服务');
    ServiceStopped := Inf.ReadString('lang', 'service_stopped', '服务停止完毕');
    ServiceStopFail := Inf.ReadString('lang', 'service_stop_fail', '停止服务失败');
    ServiceWaitClose := Inf.ReadString('lang', 'service_await', '等待服务关闭');

    BackupStart := Inf.ReadString('lang', 'backup_start', '开始备份:');
    BackupFail := Inf.ReadString('lang', 'backup_fail', '备份失败');
    BackupDone := Inf.ReadString('lang', 'backup_done', '备份完成:');

    RestoreStart := Inf.ReadString('lang', 'restore_start', '开始还原:');
    RestoreDone := Inf.ReadString('lang', 'restore_done', '还原完成:');
    RestoreFail := Inf.ReadString('lang', 'restore_fail', '还原失败');

    ArchiveStart := Inf.ReadString('lang', 'arc_start', '压缩备份');
    ArchiveDone := Inf.ReadString('lang', 'arc_done', '压缩备份完成');
    ArchiveFail := Inf.ReadString('lang', 'arc_fail', '压缩备份失败');

    UnarchiveStart := Inf.ReadString('lang', 'unarc_start', '解压备份');
    UnarchiveDone := Inf.ReadString('lang', 'unarc_done', '解压备份完成');
    UnarchiveFail := Inf.ReadString('lang', 'unarc_fail', '解压备份失败');

    InitDatabaseStart := Inf.ReadString('lang', 'db_init_start', '初始化数据库');
    InitDatabaseDone := Inf.ReadString('lang', 'db_init_done', '初始化数据库完成');
    InitDatabaseFail := Inf.ReadString('lang', 'db_init_fail', '初始化数据库失败');

    Inf.ReadSections(Tabs);
    Tabs.Delete(Tabs.IndexOf('conf'));
    Tabs.Delete(Tabs.IndexOf('lang'));
  end
  else
  begin
    MessageBox(0, PChar(Format('配置文件不存在:%s' + #13#10 +
      ' Config File not found: %s', [ini, ini])), 'ERROR', MB_OK);
    Application.Terminate;
  end;

end;

procedure TConf.Load(sec: string);
begin
  ParamDb := Fix(sec, 'param_db', '');
  BackupExt := Inf.ReadString(sec, 'backup_ext', '');
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
