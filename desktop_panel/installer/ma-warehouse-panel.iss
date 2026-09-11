; ─── نصاب پنل انبار MA Warehouse (Inno Setup 6) ───
; ساخت:
;   1) flutter build windows --release
;   2) ISCC.exe installer\ma-warehouse-panel.iss
; خروجی: installer\output\Setup-MA-Warehouse-Panel-v1.0.1.exe
;
; قرارداد نسخه: هنگام انتشار جدید، AppVersion و OutputBaseFilename را
; با pubspec.yaml هم‌خوان کنید.

#define MyAppName "MA Warehouse Panel"
#define MyAppVersion "1.0.1"
#define MyAppPublisher "MA Warehouse"
#define MyAppExeName "ma_warehouse_panel.exe"
#define SrcDir "..\build\windows\x64\runner\Release"

[Setup]
AppId={{9A3B434C-BA1E-4B3D-8029-457562B3D5DE}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\MA Warehouse Panel
OutputBaseFilename=Setup-MA-Warehouse-Panel-v1.0.1
OutputDir=output
Compression=lzma2/max
SolidCompression=yes
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
WizardStyle=modern
InfoBeforeFile=readme-fa.txt
UninstallDisplayIcon={app}\{#MyAppExeName}
; با هر نصب جدید، نسخه قبلی تمیز جایگزین می‌شود
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
Name: "{autoprograms}\MA Warehouse Panel"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\MA Warehouse Panel"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/install /quiet /norestart"; StatusMsg: "Installing Microsoft VC++ runtime..."; Check: VCRedistNeedsInstall
Filename: "{app}\{#MyAppExeName}"; Description: "Launch MA Warehouse Panel"; Flags: nowait postinstall skipifsilent

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
