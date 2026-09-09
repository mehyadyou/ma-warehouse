; ─── نصاب پنل CRM مالک — MA Warehouse (Inno Setup 6) ───
; ساخت:
;   1) flutter build windows --release
;   2) ISCC.exe installer\ma-crm-panel.iss
; خروجی: installer\output\Setup-MA-CRM-Panel-v1.0.0.exe
;
; قرارداد نسخه: هنگام انتشار جدید، AppVersion و OutputBaseFilename را
; با pubspec.yaml هم‌خوان کنید.

#define MyAppName "MA Warehouse CRM Panel"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "MA Warehouse"
#define MyAppExeName "ma_crm_panel.exe"
#define SrcDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{3E3892E1-BDE7-4397-9BD7-A0E2E1691B21}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\MA Warehouse CRM Panel
OutputBaseFilename=Setup-MA-CRM-Panel-v1.0.0
OutputDir=output
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
WizardStyle=modern
InfoBeforeFile=readme-fa.txt
UninstallDisplayIcon={app}\{#MyAppExeName}
UsePreviousAppDir=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; پیش‌نیاز مایکروسافت — فقط اگر نصب نباشد اجرا می‌شود، بعد پاک می‌شود
Source: "vendor\vc_redist.x64.exe"; DestDir: {tmp}; Flags: deleteafterinstall; Check: VCRedistNeedsInstall
; کل خروجی بیلد release فلاتر
Source: "{#SrcDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\MA Warehouse CRM Panel"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\MA Warehouse CRM Panel"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft VC++ runtime..."; Check: VCRedistNeedsInstall
Filename: "{app}\{#MyAppExeName}"; Description: "Launch MA Warehouse CRM Panel"; Flags: nowait postinstall skipifsilent

[Code]
{ بررسی نصب بودن VC++ 2015+ نسخه x64 — هر دو محل رجیستری قدیمی و جدید }
function VCRedistNeedsInstall: Boolean;
var
  Version: String;
begin
  Result := True;
  if RegQueryStringValue(HKLM,
    'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Version', Version) then
  begin
    Result := False;
    Exit;
  end;
  if RegQueryStringValue(HKLM,
    'SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64',
    'Version', Version) then
  begin
    Result := False;
    Exit;
  end;
end;
