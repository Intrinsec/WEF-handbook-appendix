@echo off
REM
REM sysmon-setup script v20180312
REM Place this script, the sysmon-configuration file and a Sysmon executable into a publicly accessible shared folder.
REM Replace the "<FIXME_path_to_shared_folder>" occurences by a valid UNC path.
REM Deploy the script through GPO and run it at boot time or as a scheduled task to keep your Sysmon configuration updated.
REM Requires local Administrator privileges.
REM

REM Checks if remote files are available.
if not exist "\\<FIXME_path_to_shared_folder>\sysmon\Sysmon.exe" goto :eof
if not exist "\\<FIXME_path_to_shared_folder>\sysmon\sysmon-config.xml" goto :eof

REM Retrieves remote configuration file if it is more recent than the local copy.
robocopy "\\<FIXME_path_to_shared_folder>\sysmon" "C:\Windows" sysmon-config.xml /XO /R:2 /W:5 /Z > nul
if %ERRORLEVEL% EQU 1 sysmon -c C:\Windows\sysmon-config.xml

if not exist "C:\Windows\Sysmon.exe" goto install

REM Simple version check. If the remote and local versions differ, then assume the remote copy is more recent.
for /F "tokens=* usebackq" %%a in (`"\\<FIXME_path_to_shared_folder>\sysmon\Sysmon.exe" -? ^2^>^&^1 ^| findstr Monitor`) do set srv_ver=%%a
for /F "tokens=* usebackq" %%a in (`C:\Windows\Sysmon.exe -? ^2^>^&^1 ^| findstr Monitor`) do set local_ver=%%a
if "%srv_ver%" NEQ "%local_ver%" (
	sysmon -u > nul 2>&1
	goto install
)

sc query Sysmon
if %ERRORLEVEL% EQU 1060 goto install

sc query Sysmon | findstr STATE | findstr RUNNING
if %ERRORLEVEL% EQU 1 net start Sysmon

goto :eof

:install
"\\<FIXME_path_to_shared_folder>\sysmon\Sysmon.exe" /accepteula -i C:\Windows\sysmon-config.xml
