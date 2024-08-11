@ECHO OFF
setlocal
title 3DSAESKD

set "aeskeys_url_yetiuard=https://github.com/Yetiuard/misc/raw/main/aeskeys-txt-seeddb-bin/yetiuard/aes_keys.txt"
set "aeskeys_url_jimjam=https://ia600305.us.archive.org/2/items/3DS-AES-Keys/aes_keys.txt"
set "aeskeys_url_pastebin=https://pastebin.com/raw/vRy8c6JP"
set "seeddb_url_jimjam=https://ia600305.us.archive.org/2/items/3DS-AES-Keys/seeddb.bin"
set "seeddb_url_ihaveamac=https://github.com/ihaveamac/3DS-rom-tools/raw/master/seeddb/seeddb.bin"
set "aeskeystxt=aes_keys.txt"
set "seeddbbin=seeddb.bin"
set "lime3ds_aeskeys=%appdata%\Lime3DS\sysdata\aes_keys.txt"
set "mandarine_aeskeys=%appdata%\Mandarine\sysdata\aes_keys.txt"
set "citra_aeskeys=%appdata%\Citra\sysdata\aes_keys.txt"
set "lime3ds_seeddb=%appdata%\Lime3DS\sysdata\seeddb.bin"
set "mandarine_seeddb=%appdata%\Mandarine\sysdata\seeddb.bin"
set "citra_seeddb=%appdata%\Citra\sysdata\seeddb.bin"

if not exist "%aeskeystxt%" (
    ECHO %aeskeystxt% not found in the current directory!
    ECHO:
    ECHO Do you want to:
    ECHO [1] Download the file
    ECHO [2] Use a custom aes_keys.txt file
    ECHO [3] Skip this part
    ECHO:
    CHOICE /N /C:123 /M "Your choice:"
    IF ERRORLEVEL 3 GOTO SEEDDBCHECK
    IF ERRORLEVEL 2 GOTO USE_CUSTOM_PATH_AESKEYS
    IF ERRORLEVEL 1 GOTO CHOOSEAESKEYSDOWNLOAD
    GOTO END
)

:SEEDDBCHECK
if not exist "%seeddbbin%" (
    ECHO %seeddbbin% not found in the current directory!
    ECHO:
    ECHO Do you want to:
    ECHO [1] Download the file
    ECHO [2] Use a custom file
    ECHO [3] Skip this part
    ECHO:
    CHOICE /N /C:123 /M "Youe choice:"
    IF ERRORLEVEL 3 (
            ECHO Setup complete. Press any key to exit!
            PAUSE >nul
            EXIT /B
            )
    IF ERRORLEVEL 2 GOTO USE_CUSTOM_PATH_SEEDDBBIN
    IF ERRORLEVEL 1 GOTO CHOOSESEEDDBBINDOWNLOAD
)


:DOWNLOADAESKEYS
powershell -Command "Invoke-WebRequest -Uri '%aeskeys_url%' -OutFile '%aeskeystxt%'"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Download failed. :( Press any key to exit. 
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES_AESKEYS

:DOWNLOADSEEDDB
powershell -Command "Invoke-WebRequest -Uri '%seeddbbin_url%' -OutFile '%seeddbbin%'"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Download failed. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES_SEEDDB

:USE_CUSTOM_PATH_AESKEYS
FOR /F "delims=" %%I IN ('powershell -noprofile "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.OpenFileDialog; $f.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory(); $f.Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'; $f.ShowHelp = $true; $f.Multiselect = $false; [void]$f.ShowDialog(); $f.FileName"') DO SET "custom_file_path=%%I"
IF NOT EXIST "%custom_file_path%" (
    ECHO Custom file not found. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)

COPY /Y "%custom_file_path%" "%aeskeystxt%"
IF %ERRORLEVEL% NEQ 0 (
    ECHO File copy failed. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES_AESKEYS

:USE_CUSTOM_PATH_SEEDDBBIN
FOR /F "delims=" %%I IN ('powershell -noprofile "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.OpenFileDialog; $f.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory(); $f.Filter = 'Binary Files (*.bin)|*.bin|All Files (*.*)|*.*'; $f.ShowHelp = $true; $f.Multiselect = $false; [void]$f.ShowDialog(); $f.FileName"') DO SET "custom_file_path=%%I"
IF NOT EXIST "%custom_file_path%" (
    ECHO Custom file not found. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)

COPY /Y "%custom_file_path%" "%seeddbbin%"
IF %ERRORLEVEL% NEQ 0 (
    ECHO File copy failed. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES_SEEDDB

:CHOOSESEEDDBBINDOWNLOAD
ECHO Choose a source for the SeedDB file:
ECHO [1] IHaveAMac (recommended)
ECHO [2] JimJam108
CHOICE /N /C:12 /M "Your choice:"
IF ERRORLEVEL 2 SET "seeddbbin_url=%seeddb_url_jimjam%"
IF ERRORLEVEL 1 SET "seeddbbin_url=%seeddb_url_ihaveamac%"
GOTO DOWNLOADSEEDDB

:CHOOSEAESKEYSDOWNLOAD
ECHO Choose a source for the SeedDB file:
ECHO [1] Yetiuard
ECHO [2] PasteBin
Echo [3] JimJam108
CHOICE /N /C:123 /M "Your choice:"
IF ERRORLEVEL 3 SET "aeskeys_url=%aeskeys_url_jimjam%"
IF ERRORLEVEL 2 SET "aeskeys_url=%aeskeys_url_pastebin%"
IF ERRORLEVEL 1 SET "aeskeys_url=%aeskeys_url_yetiuard%"
GOTO DOWNLOADAESKEYS

:CHECK_DIRECTORIES_AESKEYS
CALL :ProcessFile "%citra_aeskeys%" "%aeskeystxt%" "Citra"
CALL :ProcessFile "%lime3ds_aeskeys%" "%aeskeystxt%" "Lime3DS"
CALL :ProcessFile "%mandarine_aeskeys%" "%aeskeystxt%" "Mandarine"
ECHO AES keys setup complete.
GOTO SEEDDBCHECK

:CHECK_DIRECTORIES_SEEDDB
CALL :ProcessFile "%citra_seeddb%" "%seeddbbin%" "Citra"
CALL :ProcessFile "%lime3ds_seeddb%" "%seeddbbin%" "Lime3DS"
CALL :ProcessFile "%mandarine_seeddb%" "%seeddbbin%" "Mandarine"
ECHO SeedDB setup complete. Press any key to exit!
PAUSE >nul
EXIT /B

:ProcessFile
SET "file_path=%~1"
SET "source_file=%~2"
SET "dir_name=%~3"
SET "dir_path=%~dp1"
IF EXIST "%file_path%" (
    ECHO:
    CHOICE /N /C:YN /M "Overwrite the file in %dir_name%? (Y/N)"
    IF ERRORLEVEL 2 GOTO SKIP_FILE
    IF ERRORLEVEL 1 GOTO OVERWRITE
) ELSE (
    ECHO File %file_path% does not exist.
    CHOICE /N /C:CS /M "(C)reate it or (S)kip?"
    IF ERRORLEVEL 2 GOTO SKIP_FILE
    IF ERRORLEVEL 1 GOTO CREATE_AND_COPY
)

:OVERWRITE
COPY /Y "%source_file%" "%file_path%"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Failed to copy to %file_path%. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO END

:SKIP_FILE
ECHO Skipping
GOTO END

:CREATE_AND_COPY
IF NOT EXIST "%dir_path%" (
    MKDIR "%dir_path%"
    IF %ERRORLEVEL% NEQ 0 (
        ECHO Failed to create directory. :( Press any key to exit.
        PAUSE >nul
        EXIT /B
    )
)
COPY /Y "%source_file%" "%file_path%"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Failed to copy to %file_path%. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO END

:END
EXIT /B
