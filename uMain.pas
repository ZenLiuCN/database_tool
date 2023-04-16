unit uMain;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.FileCtrl,
  uExec,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.ComCtrls,
  Vcl.StdCtrls,
  Vcl.Mask,
  Vcl.ExtCtrls,
  Vcl.ButtonGroup,
  Vcl.AppEvnts;

type
  TFrmMain = class(TForm)
    Tab: TTabControl;
    PnlMain: TPanel;
    EdtStore: TLabeledEdit;
    PnlAct: TPanel;
    btnOpen: TButton;
    DlgOpen: TOpenDialog;
    Tray: TTrayIcon;
    AppEvents: TApplicationEvents;
    Log: TMemo;
    Tmr: TTimer;
    btnStart: TButton;
    btnStop: TButton;
    btnBackup: TButton;
    btnRestore: TButton;
    btnReload: TButton;
    DlgSave: TSaveDialog;
    PnlBtns: TPanel;
    PnlClient: TPanel;
    btnClear: TButton;

    procedure TrayDblClick(Sender: TObject);
    procedure AppEventsMinimize(Sender: TObject);
    procedure TabChange(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure TmrTimer(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure btnClearClick(Sender: TObject);
  private
    { Private declarations }
    Running: bool;
    Proc: uExec.TAsyncReader;
    procedure Reload(Sender: TObject);
    procedure Start(Sender: TObject);
    procedure Stop(Sender: TObject);
    procedure Backup(Sender: TObject);
    procedure Restore(Sender: TObject);

    procedure Logging(Msg: string);
    procedure LogOut(Msg: string);
    procedure LogTab(Msg: string);
    procedure Dbg(Msg: string);

    procedure Alert(Msg: string);
    procedure Prepare;
    procedure InitDatabase;
    function CloseServer(): bool;
    procedure StartServer();
    procedure capNotify(pre: string);
    function Arc(folder, archive: string): Cardinal;
    function Unarc(archive, folder: string): Cardinal;
    function doBackup(output: string): Cardinal;
    function doRestore(input: string): Cardinal;
    procedure doArcRestore;
    procedure doFileRestore;
    procedure doFolderRestore;
    procedure doArcBackup;
    procedure doFileBackup;
    procedure doFolderBackup;
    procedure OnServiceTerminate(Sender: TObject);
    procedure ModeRunning;
    procedure ModeDefault;
  public
    { Public declarations }
    procedure Init;
  end;

var
  FrmMain: TFrmMain;

implementation

{$R *.dfm}

uses
  uConf,
  TlHelp32,
  System.IOUtils;

procedure TFrmMain.ModeRunning;
begin
  Tmr.Interval := conf.ProcInterval;
  Tmr.Enabled := True;
  btnBackup.Enabled := (conf.CmdBackupol <> '');
  btnRestore.Enabled := (conf.CmdRestoreOl <> '');
  btnStart.Enabled := false;
  btnStop.Enabled := True;
  btnReload.Enabled := false;
  btnOpen.Enabled := false;
  Tab.Enabled := false;
end;

procedure TFrmMain.ModeDefault;
begin
  btnBackup.Enabled := (conf.CmdBackup <> '');
  btnRestore.Enabled := (conf.CmdRestore <> '');
  btnStart.Enabled := True;
  btnStop.Enabled := false;
  btnReload.Enabled := True;
  btnOpen.Enabled := True;
  Tab.Enabled := True;
  capNotify('');
end;

{ 压缩文件夹 }
function TFrmMain.Arc(folder, archive: string): Cardinal;
begin
  Result := 0;
  var Cmd: string;
  if conf.CmdArchive <> '' then
    Cmd := conf.CmdArchive;
  if Cmd = '' then
    Exit
  else begin
    Cmd := Format(Cmd, [archive, folder]);
    Dbg(conf.ArchiveStart + ' ' + Cmd);
    Result := uExec.SyncOutput(Cmd, '', LogOut);
  end;
end;

{ Alert }
procedure TFrmMain.Alert(Msg: string);
begin
  MessageBox(Handle, PChar(Msg), PChar(conf.MsgBoxErr), MB_OK);
end;

{ 解压文件夹 }
function TFrmMain.Unarc(archive, folder: string): Cardinal;
begin
  Result := 0;
  var Cmd: string;
  if conf.CmdUnArchive <> '' then
    Cmd := conf.CmdUnArchive;
  if Cmd = '' then
    Exit
  else begin
    Cmd := Format(Cmd, [archive, folder]);
    Dbg(conf.UnarchiveStart + ' ' + Cmd);
    Result := uExec.SyncOutput(Cmd, '', LogOut);
  end;
end;

{ 备份 }
function TFrmMain.doBackup(output: string): Cardinal;
begin
  Result := 0;
  var Cmd: string;
  if conf.CmdBackupol <> '' then
    Cmd := conf.CmdBackupol
  else
    Cmd := conf.CmdBackup;
  if Cmd = '' then
    Exit
  else begin
    Cmd := Format(Cmd, [output]);
    Dbg(conf.BackupStart + ' ' + Cmd);
    Result := uExec.SyncOutput(Cmd, '', LogOut);
  end;
end;

{ 还原 }
function TFrmMain.doRestore(input: string): Cardinal;
begin
  Result := 0;
  var Cmd: string;
  if conf.CmdRestoreOl <> '' then
    Cmd := conf.CmdRestoreOl
  else
    Cmd := conf.CmdRestore;
  if Cmd = '' then
    Exit
  else begin
    Cmd := Format(Cmd, [input]);
    Dbg(conf.RestoreStart + ' ' + Cmd);
    Result := uExec.SyncOutput(Cmd, '', LogOut);
  end;
end;

{ 标签提示 }
procedure TFrmMain.capNotify(pre: string);
begin
  if not string(EdtStore.EditLabel.Caption).Contains('>') then
    EdtStore.EditLabel.Caption := '>' + EdtStore.EditLabel.Caption;
  EdtStore.EditLabel.Caption := pre + string(EdtStore.EditLabel.Caption).Split(['>'])[1];
end;

{ 停止服务 }
function TFrmMain.CloseServer: bool;
begin
  Result := false;
  if Proc = nil then
    Exit;
  if conf.CmdStop <> '' then begin
    var Cmd := conf.CmdStop;
    if Cmd.Contains('%0:s') then
      Cmd := Format(Cmd, [EdtStore.Text]);
    Dbg(conf.ServiceStop + '  ' + Cmd);
    Logging(conf.ServiceWaitClose);
    var extCode := uExec.SyncOutput(Cmd, '', LogOut);
    Result := extCode = 0;

  end;
  Tmr.Enabled := false;
  Proc.Terminate;
  Proc := nil;
  if conf.CmdStop = '' then
    Result := True;
  if not btnStart.Enabled then
    OnServiceTerminate(nil);
end;

{ 关闭停止服务 }
procedure TFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CloseServer;
  CanClose := True;
end;

{ 初始化数据库 }
procedure TFrmMain.InitDatabase;
begin
  var folder := EdtStore.Text;
  if TDirectory.IsEmpty(folder) then
    if conf.CmdInit <> '' then begin
      var Cmd := Format(conf.CmdInit, [folder]);
      Dbg(conf.InitDatabaseStart + ' ' + Cmd);
      var extCode := uExec.SyncOutput(Cmd, '', LogOut);
      if extCode <> 0 then
        Logging(Format(conf.InitDatabaseFail + ' : %d', [extCode]))
      else
        Logging(conf.InitDatabaseDone);
    end;
end;

{ 启动服务 }
procedure TFrmMain.StartServer;
begin
  if EdtStore.Text = '' then begin
    Alert(conf.ErrNoData);
    Exit;
  end;
  if conf.CmdLaunch = '' then begin
    Alert(conf.ErrMissingCmd);
    Exit;
  end;
  InitDatabase;
  var Cmd := Format(conf.CmdLaunch, [EdtStore.Text]);
  Dbg(conf.ServiceStart + ' ' + Cmd);
  LogTab(conf.ServiceStart);
  Proc := uExec.TAsyncReader.Create(LogOut, Cmd,
    { failed }
    procedure
    begin
      var Err := Format(conf.ServiceStartFail + ' : %d', [GetLastError]);
      Alert(Err);
      Logging(Err);
    end,
  { success }
    procedure
    begin
      ModeRunning;
      capNotify('?>');
      LogTab(conf.ServiceStarted);
    end, OnServiceTerminate);
end;

{ 完成服务停止,重置界面 }
procedure TFrmMain.OnServiceTerminate(Sender: TObject);
begin
  ModeDefault;
end;

{ 输出日志 }
procedure TFrmMain.Logging(Msg: string);
begin
  Log.Lines.Add(FormatDateTime('hh:nn:ss', Now()) + #9 + Msg);
end;

procedure TFrmMain.LogOut(Msg: string);
begin
  Log.Lines.Add(Msg);
end;

procedure TFrmMain.LogTab(Msg: string);
begin
  Log.Lines.Add(FormatDateTime('hh:nn:ss', Now()) + #9 + Tab.Tabs[Tab.TabIndex] + #9 + Msg);
end;

{ 输出Debug日志 }
procedure TFrmMain.Dbg(Msg: string);
begin
  if conf.Debug then
    Log.Lines.Add(FormatDateTime('hh:nn:ss', Now()) + #9 + Msg);
end;

{ 初始化配置 }
procedure TFrmMain.Init;
begin
  Proc := nil;
  Caption := conf.Title;
  Tray.Hint := conf.Title;
  Tray.BalloonHint := conf.HintTray;
  Tab.Tabs.Clear;
  Tab.Tabs.AddStrings(conf.Tabs);
  EdtStore.EditLabel.Caption := conf.LblStore;

  btnOpen.Caption := conf.btnOpen;

  btnStart.Caption := conf.btnStart;
  btnStop.Caption := conf.btnStop;
  btnBackup.Caption := conf.btnBackup;
  btnRestore.Caption := conf.btnRestore;
  btnReload.Caption := conf.btnReload;

  btnStart.Hint := conf.HintStart;
  btnStop.Hint := conf.HintStop;
  btnBackup.Hint := conf.HintBackup;
  btnRestore.Hint := conf.HintRestore;
  btnReload.Hint := conf.HintReload;

  btnStart.OnClick := Start;
  btnStop.OnClick := Stop;
  btnBackup.OnClick := Backup;
  btnRestore.OnClick := Restore;
  btnReload.OnClick := Reload;
  Prepare;

end;

{ 备份动作 }
{$REGION 备份动作 }

procedure TFrmMain.Backup(Sender: TObject);
begin
  var ol := conf.CmdRestoreOl <> '';
  var run := not (Proc = nil);
  if not ((ol and run) or (not ol and not run)) then begin
    Exit;
  end;
  if conf.CmdArchive <> '' then
    doArcBackup
  else if conf.BackupExt <> '' then
    doFileBackup
  else
    doFolderBackup;
end;

procedure TFrmMain.doArcBackup;
begin
  var a7 := '';
  DlgSave.Title := conf.DlgOpenBackup;
  DlgSave.Filter := '7zip|*.7z';
  if not DlgSave.Execute(Handle) then
    Exit;
  a7 := DlgSave.FileName;
  var folder := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName.Replace('.', ''));
  // temp folder
  TDirectory.CreateDirectory(folder);
  Logging(Format(conf.BackupStart + '  %s', [folder]));
  var code := doBackup(folder);
  if code <> 0 then begin
    Logging(Format(conf.BackupFail + '  %d', [code]));
    Exit;
  end;
  Logging(Format(conf.ArchiveStart + '  %s => %s', [folder, a7]));
  code := Arc(folder, a7);
  if code <> 0 then
    Logging(Format(conf.ArchiveFail + '  %d', [code]))
  else
    Logging(conf.BackupDone);

end;

procedure TFrmMain.doFileBackup;
begin
  var a7 := '';
  DlgSave.Title := conf.DlgOpenBackup;
  DlgSave.Filter := conf.BackupExt;
  if not DlgSave.Execute(Handle) then
    Exit;
  a7 := DlgSave.FileName;
  Dbg(Format(conf.BackupStart + '  %s', [a7]));
  var code := doBackup(a7);
  if code <> 0 then
    Logging(Format(conf.BackupFail + '  %d', [code]))
  else
    Logging(conf.BackupDone);
end;

procedure TFrmMain.doFolderBackup;
begin
  var path := '';
  if not SelectDirectory(conf.DlgOpenBackup, '', path, [sdNewFolder, sdShowEdit, sdShowShares, sdNewUI, sdValidateDir]) then
    Exit;

  Dbg(Format(conf.BackupStart + '  %s', [path]));
  var code := doBackup(path);
  if code <> 0 then
    Logging(Format(conf.BackupFail + '  %d', [code]))
  else
    Logging(conf.BackupDone);
end;
{$ENDREGION}
{ 还原动作 }
{$REGION 还原动作 }

procedure TFrmMain.Restore(Sender: TObject);
begin
  var ol := conf.CmdBackupol <> '';
  var run := not (Proc = nil);
  if not ((ol and run) or (not ol and not run)) then
    Exit;
  if conf.CmdUnArchive <> '' then
    doArcRestore
  else if conf.BackupExt <> '' then
    doFileRestore
  else
    doFolderRestore;
end;

procedure TFrmMain.doArcRestore;
begin
  var a7 := '';
  DlgOpen.Title := conf.DlgOpenRestore;
  DlgOpen.Filter := '7zip|*.7z';
  if not DlgOpen.Execute(Handle) then
    Exit;
  a7 := DlgOpen.FileName;
  var folder := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName.Replace('.', ''));
  // temp folder
  TDirectory.CreateDirectory(folder);
  Dbg(Format(conf.UnarchiveStart + '  %s =>', [a7, folder]));
  var code := Unarc(a7, folder);
  if code <> 0 then begin
    Logging(Format(conf.UnarchiveFail + '  %d', [code]));
    Exit;
  end;
  Dbg(Format(conf.RestoreStart + '  %s', [folder]));
  code := doRestore(folder);
  if code <> 0 then
    Logging(Format(conf.RestoreFail + '  %d', [code]))
  else
    Logging(conf.RestoreDone);
end;

procedure TFrmMain.doFileRestore;
begin
  var a7 := '';
  DlgOpen.Title := conf.DlgOpenRestore;
  DlgOpen.Filter := conf.BackupExt;
  if not DlgOpen.Execute(Handle) then
    Exit;
  a7 := DlgOpen.FileName;
  Dbg(Format(conf.RestoreStart + '  %s', [a7]));
  var code := doRestore(a7);
  if code <> 0 then
    Logging(Format(conf.RestoreFail + '  %d', [code]))
  else
    Logging(conf.RestoreDone);
end;

procedure TFrmMain.doFolderRestore;
begin
  var path := '';
  if not SelectDirectory(conf.DlgOpenRestore, '', path, [sdShowEdit, sdShowShares, sdNewUI, sdValidateDir]) then
    Exit;
  Dbg(Format(conf.RestoreStart + '  %s', [path]));
  var code := doRestore(path);
  if code <> 0 then
    Logging(Format(conf.RestoreFail + '  %d', [code]))
  else
    Logging(conf.RestoreDone);
end;
{$ENDREGION}
{ Buttons }
{$REGION Buttons}

procedure TFrmMain.btnClearClick(Sender: TObject);
begin
  Log.Lines.Clear;
end;
{ 选择数据库目录 }

procedure TFrmMain.btnOpenClick(Sender: TObject);
var
  path: string;
begin
  path := EdtStore.Text;
  if SelectDirectory(conf.DlgOpenData, '', path, [sdNewFolder, sdShowEdit, sdShowShares, sdNewUI, sdValidateDir]) then begin
    EdtStore.Text := path;
  end;
  btnStart.Enabled := EdtStore.Text <> '';
end;

{ 数据库类型切换 }
procedure TFrmMain.TabChange(Sender: TObject);
begin
  Prepare;
  LogTab(conf.ModeChanged)
end;

{ 重新加载配置 }
procedure TFrmMain.Reload(Sender: TObject);
begin
  conf.Init;
  Init;
  Logging(conf.ConfReloaded);
end;

{ 启动按钮 }
procedure TFrmMain.Start(Sender: TObject);
begin
  StartServer;
end;

{ 停止按钮 }
procedure TFrmMain.Stop(Sender: TObject);
begin
  if CloseServer then
    LogTab(conf.ServiceStopped);
end;
{$ENDREGION}

{ 监控 }

procedure TFrmMain.TmrTimer(Sender: TObject);
begin
  if ProcessCount(conf.ProcExec) > 0 then
    capNotify('*>')
  else begin
    capNotify('!>');
    LogTab(conf.ErrServiceQuit);
    Tmr.Enabled := false;
    Proc.Terminate;
    Proc := nil;
    Tray.BalloonHint:=conf.ErrServiceQuit;
    Tray.ShowBalloonHint;
    Tray.BalloonHint:=conf.HintTray;
    ModeDefault;
  end;
end;

{ 准备配置信息 }
procedure TFrmMain.Prepare;
begin
  conf.Load(Tab.Tabs[Tab.TabIndex]);
  if conf.ParamDb <> '' then
    EdtStore.Text := conf.ParamDb
  else
    EdtStore.Text := '';
  btnStart.Enabled := EdtStore.Text <> '';
  btnBackup.Enabled := (conf.CmdBackup <> '') and btnStart.Enabled;
  btnRestore.Enabled := (conf.CmdRestore <> '') and btnStart.Enabled;
  btnOpen.Enabled := True;
  btnStop.Enabled := false;
  btnReload.Enabled := True;
end;

{ 托盘还原 }
procedure TFrmMain.TrayDblClick(Sender: TObject);
begin
  Tray.Visible := false;
  Show;
  WindowState := wsNormal;
  Application.BringToFront();
end;

{ 最小化到托盘 }
procedure TFrmMain.AppEventsMinimize(Sender: TObject);
begin
  { Hide the window and set its state variable to wsMinimized. }
  Hide();
  WindowState := wsMinimized;

  { Show the animated tray icon and also a hint balloon. }
  Tray.Visible := True;
  Tray.Animate := True;
  Tray.ShowBalloonHint;
end;

end.

