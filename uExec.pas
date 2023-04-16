unit uExec;

interface

uses
  System.Classes,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Forms,
  System.SysUtils,
  TlHelp32,
  System.IOUtils;

type
  TLogging = reference to procedure(Msg: string);
  THandler = reference to procedure();

  TAsyncReader = class(TThread)
  private
    Log: TLogging;
    OnFailure: THandler;
    OnStart: THandler;
    Cmd: string;

  protected
    procedure Execute; override;
    procedure Action;
  public
    Process: TProcessInformation;
    constructor Create(Logger: TLogging; Command: string;
      FnFail, FnStart: THandler; OnEnd: TNotifyEvent);
    destructor Destroy; override;
  end;

function ProcessCount(const ExeName: String): Integer;
function ExecHidden(Cmd, WorkDir: string): PROCESS_INFORMATION;
function SyncOutput(Cmd, WorkDir: string; Logger: TLogging): Cardinal;

implementation

uses System.Threading;

{ 检查进程数量 }
function ProcessCount(const ExeName: String): Integer;
var
  ContinueLoop: bool;
  FSnapshotHandle: THandle;
  FProcessEntry32: TProcessEntry32;
begin
  FSnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  FProcessEntry32.dwSize := SizeOf(FProcessEntry32);
  ContinueLoop := Process32First(FSnapshotHandle, FProcessEntry32);
  Result := 0;
  while Integer(ContinueLoop) <> 0 do
  begin
    if ((UpperCase(ExtractFileName(FProcessEntry32.szExeFile))
      = UpperCase(ExeName)) or (UpperCase(FProcessEntry32.szExeFile)
      = UpperCase(ExeName))) then
      Inc(Result);
    ContinueLoop := Process32Next(FSnapshotHandle, FProcessEntry32);
  end;
  CloseHandle(FSnapshotHandle);
end;

{ 隐藏窗口执行 }
function ExecHidden(Cmd, WorkDir: string): PROCESS_INFORMATION;
var
  si: STARTUPINFO;
  pi: PROCESS_INFORMATION;
begin
  FillChar(si, SizeOf(si), 0);
  FillChar(pi, SizeOf(pi), 0);
  si.wShowWindow := SW_HIDE;
  si.dwFlags := STARTF_USESHOWWINDOW;
  if not CreateProcess(nil, PChar(Cmd), nil, nil, false, 0, nil, PChar(WorkDir),
    si, pi) then
  begin
    Result := pi;
  end;
  Result := pi;
end;

{ 执行并输出 }
function SyncOutput(Cmd, WorkDir: string; Logger: TLogging): Cardinal;
const
  cBufferSize = 2048;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  si: TStartupInfo;
  pi: TProcessInformation;
  pBuffer: array [0 .. cBufferSize] of AnsiChar;
  dRead: DWord;
  dRunning: DWord;
begin
  Result := 500;
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := True;
  saSecurity.lpSecurityDescriptor := nil;
  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
  begin
    SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0);
    FillChar(si, SizeOf(TStartupInfo), #0);
    with si do
    begin
      cb := SizeOf(TStartupInfo);
      hStdOutput := hWrite;
      hStdError := hWrite;
      dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
      wShowWindow := SW_HIDE;
    end;
    if CreateProcess(nil, PChar(Cmd), @saSecurity, @saSecurity, True,
      NORMAL_PRIORITY_CLASS, nil, nil, si, pi) then
    begin
      var
      task := TTask.Run(
        procedure
        begin
          while True do
          begin
            dRunning := WaitForSingleObject(pi.hProcess, INFINITE);
            if dRunning <> WAIT_TIMEOUT then
              break;
            repeat
              dRead := 0;
              ReadFile(hRead, pBuffer[0], cBufferSize, dRead, nil);
              pBuffer[dRead] := #0;
              OemToAnsi(pBuffer, pBuffer);
              Logger(String(pBuffer));
            until (dRead < cBufferSize);
          end;
        end).Start;
      while (task.Status <> TTaskStatus.Completed) do
      begin
        Application.ProcessMessages;
      end;

      GetExitCodeProcess(pi.hProcess, Result);
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
    end;
    CloseHandle(hRead);
    CloseHandle(hWrite);
  end;
end;
{$REGION AsyncReader}

procedure TAsyncReader.Execute;
begin
  Action;
end;

constructor TAsyncReader.Create(Logger: TLogging; Command: string;
FnFail, FnStart: THandler; OnEnd: TNotifyEvent);
begin
  Log := Logger;
  Cmd := Command;
  OnFailure := FnFail;
  OnStart := FnStart;
  TAsyncReader.NameThreadForDebugging(Command);
  FreeOnTerminate := True;
  OnTerminate := OnEnd;
  inherited Create(false);
end;

destructor TAsyncReader.Destroy;
begin
  // TerminateProcess(Process.hProcess, 0);
  // if Process.hProcess <> 0 then
  // CloseHandle(Process.hProcess);
  // if Process.hThread <> 0 then
  // CloseHandle(Process.hThread);

  inherited;
end;

procedure TAsyncReader.Action;
const
  cBufferSize = 2048;
var
  saSecurity: TSecurityAttributes;
  hRead: THandle;
  hWrite: THandle;
  suiStartup: TStartupInfo;
  pBuffer: array [0 .. cBufferSize] of AnsiChar;
  dRead: DWord;
  dRunning: DWord;
  succ: bool;
label 1, 2;
begin
  succ := false;
  saSecurity.nLength := SizeOf(TSecurityAttributes);
  saSecurity.bInheritHandle := True;
  saSecurity.lpSecurityDescriptor := nil;
  if CreatePipe(hRead, hWrite, @saSecurity, 0) then
  begin
    SetHandleInformation(hRead, HANDLE_FLAG_INHERIT, 0);
    FillChar(suiStartup, SizeOf(TStartupInfo), #0);
    FillChar(Process, SizeOf(TProcessInformation), #0);
    suiStartup.cb := SizeOf(TStartupInfo);
    suiStartup.hStdOutput := hWrite;
    suiStartup.hStdError := hWrite;
    suiStartup.dwFlags := STARTF_USESTDHANDLES or STARTF_USESHOWWINDOW;
    suiStartup.wShowWindow := SW_HIDE;

    if CreateProcess(nil, PChar(Cmd), @saSecurity, @saSecurity, True,
      NORMAL_PRIORITY_CLASS, nil, nil, suiStartup, Process) then
    begin
      succ := True;
      Synchronize(
        procedure
        begin
          OnStart;
        end);
      { loop for check terminate and read output }
      while True do
      begin
        if CheckTerminated then
          goto 1;
        while WaitForSingleObject(Process.hProcess, 100) <> WAIT_TIMEOUT do
        begin
          repeat
            dRead := 0;
            ReadFile(hRead, pBuffer[0], cBufferSize, dRead, nil);
            pBuffer[dRead] := #0;
            OemToAnsi(pBuffer, pBuffer);
            Synchronize(
              procedure
              begin
                Log(String(pBuffer));
              end)
          until (dRead < cBufferSize);
        end;
      end;
      goto 2; // defualt jump to close handle
    1:
      TerminateProcess(Process.hProcess, 0);
    2: // close handle
      CloseHandle(Process.hProcess);
      CloseHandle(Process.hThread);
      Process.hProcess := 0;
      Process.hThread := 0;
    end;
    if not succ then
      Synchronize(
        procedure
        begin
          OnFailure;
        end);
    CloseHandle(hRead);
    CloseHandle(hWrite);
  end;
  if not succ then
    Synchronize(
      procedure
      begin
        OnFailure;
      end);
end;
{$ENDREGION}

end.
