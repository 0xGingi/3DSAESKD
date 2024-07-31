@ECHO OFF
setlocal
title 3DSAESKD

set "download_url=https://github.com/Yetiuard/misc/raw/main/aes_keys.txt"
set "source_file=aes_keys.txt"
set "lime3ds_file=%appdata%\Lime3DS\sysdata\aes_keys.txt"
set "mandarine_file=%appdata%\Mandarine\sysdata\aes_keys.txt"
set "citra_file=%appdata%\Citra\sysdata\aes_keys.txt"

if not exist "%source_file%" (
    ECHO %source_file% not found in the current directory.
    CHOICE /N /C:DC /M "Do you want to (D)ownload the file or use a (C)ustom File?"
    IF ERRORLEVEL 2 GOTO USE_CUSTOM_PATH
    IF ERRORLEVEL 1 GOTO DOWNLOAD
    GOTO END
)

:DOWNLOAD
powershell -Command "Invoke-WebRequest -Uri '%download_url%' -OutFile '%source_file%'"
IF %ERRORLEVEL% NEQ 0 (
    ECHO Download failed. :( Press any key to exit. Are you connected to the internet?
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES

:USE_CUSTOM_PATH
FOR /F "delims=" %%I IN ('powershell -noprofile "Add-Type -AssemblyName System.Windows.Forms; $f = New-Object Windows.Forms.OpenFileDialog; $f.InitialDirectory = [System.IO.Directory]::GetCurrentDirectory(); $f.Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'; $f.ShowHelp = $true; $f.Multiselect = $false; [void]$f.ShowDialog(); $f.FileName"') DO SET "custom_file_path=%%I"
IF NOT EXIST "%custom_file_path%" (
    ECHO Custom file not found. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)

COPY /Y "%custom_file_path%" "%source_file%"
IF %ERRORLEVEL% NEQ 0 (
    ECHO File copy failed. :( Press any key to exit.
    PAUSE >nul
    EXIT /B
)
GOTO CHECK_DIRECTORIES

:CHECK_DIRECTORIES
CALL :ProcessFile "%citra_file%" "Citra"
CALL :ProcessFile "%lime3ds_file%" "Lime3DS"
CALL :ProcessFile "%mandarine_file%" "Mandarine"

ECHO Success! Press any key to exit! :3
PAUSE >nul
EXIT /B

:ProcessFile
SET "file_path=%~1"
SET "dir_name=%~2"
SET "dir_path=%~dp1"
IF EXIST "%file_path%" (
    ECHO File %file_path% exists.
    CHOICE /N /C:YN /M "Do you want to overwrite the file in %dir_name%? (Y/N)"
    IF ERRORLEVEL 2 GOTO SKIP_FILE
    IF ERRORLEVEL 1 GOTO OVERWRITE
    GOTO END
) ELSE (
    ECHO File %file_path% does not exist.
    CHOICE /N /C:CS /M "Do you want to: (C)reate it or (S)kip?"
    IF ERRORLEVEL 2 GOTO SKIP_FILE
    IF ERRORLEVEL 1 GOTO CREATE_AND_COPY
    GOTO END
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
ECHO Skipping %file_path%. !
GOTO END

:CREATE_AND_COPY
IF NOT EXIST "%dir_path%" (
    MKDIR "%dir_path%"
    IF %ERRORLEVEL% NEQ 0 (
        GOTO OVERWRITE
        ECHO success?
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
