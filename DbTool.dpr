program DbTool;

uses
  Winapi.Windows,
  SysUtils,
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  uMain in 'uMain.pas' {FrmMain},
  uConf in 'uConf.pas',
  uExec in 'uExec.pas';

{$R *.res}
function FindWindowExtd(partialTitle: string): HWND;
var
  hWndTemp: hWnd;
  iLenText: Integer;
  cTitletemp: array [0..254] of Char;
  sTitleTemp: string;
begin
  hWndTemp := FindWindow(nil, nil);
  while hWndTemp <> 0 do begin
    iLenText := GetWindowText(hWndTemp, cTitletemp, 255);
    sTitleTemp := cTitletemp;
    sTitleTemp := UpperCase(copy( sTitleTemp, 1, iLenText));
    partialTitle := UpperCase(partialTitle);
    if pos( partialTitle, sTitleTemp ) <> 0 then
      Break;
    hWndTemp := GetWindow(hWndTemp, GW_HWNDNEXT);
  end;
  result := hWndTemp;
end;
begin

  var mx := CreateMutex(nil, True, 'Global\{27DDA7A2-EEFA-4131-B244-56CA3C7CDAA2}');
  if mx = 0 then
    RaiseLastOSError;
  if GetLastError = ERROR_ALREADY_EXISTS then
  begin
    var hwnd:=FindWindowExtd(uConf.conf.title);
    SetForegroundWindow(hwnd);
    Application.Terminate;
  end;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Amakrits');
  Application.CreateForm(TFrmMain, FrmMain);
  FrmMain.Init;
  Application.Run;
  ReleaseMutex(mx);
end.
