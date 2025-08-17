@echo off
echo ===============================================
echo   Star Citizen Cache Cleaner - Auto Launcher
echo ===============================================
echo.

REM Simple certificate check
powershell -NoProfile -Command "if (Get-ChildItem -Path Cert:\CurrentUser\Root -ErrorAction SilentlyContinue | Where-Object {$_.Subject -eq 'CN=PowerShell Code Signing (10 Year)'}) { exit 0 } else { exit 1 }" >nul 2>&1

if %ERRORLEVEL% EQU 0 (
    echo Certificate is trusted - using RemoteSigned policy
    echo.
    powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "StarCitizenCacheCleaner.ps1"
) else (
    echo Certificate not trusted - checking for certificate file...
    if exist "PowerShellCodeSigning.cer" (
        echo Found certificate file - attempting to install...
        powershell -NoProfile -Command "try { Import-Certificate -FilePath 'PowerShellCodeSigning.cer' -CertStoreLocation Cert:\CurrentUser\Root -ErrorAction Stop; Write-Host 'Certificate installed!' } catch { Write-Host 'Installation failed - using Bypass mode' }" 2>nul
        echo Running script with RemoteSigned policy...
        powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File "StarCitizenCacheCleaner.ps1"
    ) else (
        echo No certificate file found - using Bypass mode
        echo.
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "StarCitizenCacheCleaner.ps1"
    )
)

echo.
echo Script execution completed.
echo.
pause
