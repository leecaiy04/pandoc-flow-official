@echo off
setlocal enabledelayedexpansion

REM Typora Official Document Configuration Script
REM Simple version without Chinese characters

echo =====================================
echo Typora Official Document Setup
echo =====================================
echo.

REM Set variables
set "TYPORA_CONFIG=%APPDATA%\Typora"
set "THEME_DIR=%APPDATA%\Typora\themes\official-document"
set "CONFIG_FILE=%APPDATA%\Typora\conf.user.json"
set "PROJECT_ROOT=%~dp0.."

echo [1/4] Checking Typora installation...
if not exist "%TYPORA_CONFIG%" (
    echo ERROR: Typora not found
    echo Please install Typora from: https://typora.io
    pause
    exit /b 1
)
echo SUCCESS: Typora installed

echo [2/4] Installing theme...
if not exist "%THEME_DIR%" (
    mkdir "%THEME_DIR%"
)

REM Copy theme files
copy /Y "%PROJECT_ROOT%\typora-config\typora-theme\official-document\*.css" "%THEME_DIR%\" >nul 2>&1
copy /Y "%PROJECT_ROOT%\typora-config\typora-theme\official-document\README.md" "%THEME_DIR%\" >nul 2>&1

if exist "%THEME_DIR%\official.css" (
    echo SUCCESS: Theme files installed
) else (
    echo ERROR: Theme installation failed
    pause
    exit /b 1
)

echo [3/4] Configuring export...
REM Backup existing config
if exist "%CONFIG_FILE%" (
    copy "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul 2>&1
)

REM Create config file using echo
echo { > "%CONFIG_FILE%"
echo   "defaultFontFamily": "FangSong_GB2312", >> "%CONFIG_FILE%"
echo   "defaultFontSize": 16, >> "%CONFIG_FILE%"
echo   "lineHeight": 1.5, >> "%CONFIG_FILE%"
echo   "theme": "official-document", >> "%CONFIG_FILE%"
echo   "customExport": { >> "%CONFIG_FILE%"
echo     "official-doc": { >> "%CONFIG_FILE%"
echo       "name": "Official Document Word", >> "%CONFIG_FILE%"
echo       "description": "Export to official document format", >> "%CONFIG_FILE%"
echo       "command": "convert_doc.bat", >> "%CONFIG_FILE%"
echo       "args": ["${currentFilePath}", "${currentFilePath}.docx"], >> "%CONFIG_FILE%"
echo       "workingDir": "D:\\Code\\Template\\pandoc", >> "%CONFIG_FILE%"
echo       "shortcut": "ctrl+shift+d", >> "%CONFIG_FILE%"
echo       "icon": "file-word" >> "%CONFIG_FILE%"
echo     } >> "%CONFIG_FILE%"
echo   }, >> "%CONFIG_FILE%"
echo   "editor": { >> "%CONFIG_FILE%"
echo     "fontSize": 16, >> "%CONFIG_FILE%"
echo     "fontFamily": "FangSong_GB2312", >> "%CONFIG_FILE%"
echo     "lineHeight": 1.5, >> "%CONFIG_FILE%"
echo     "paragraphSpacing": 8 >> "%CONFIG_FILE%"
echo   } >> "%CONFIG_FILE%"
echo } >> "%CONFIG_FILE%"

if exist "%CONFIG_FILE%" (
    echo SUCCESS: Export configuration completed
) else (
    echo ERROR: Export configuration failed
    pause
    exit /b 1
)

echo [4/4] Checking dependencies...
where pandoc >nul 2>&1
if %errorlevel% equ 0 (
    echo SUCCESS: Pandoc installed
) else (
    echo WARNING: Pandoc not found, please install from: https://pandoc.org/installing.html
)

echo.
echo =====================================
echo Configuration Complete!
echo =====================================
echo.
echo Next steps:
echo 1. Restart Typora
echo 2. Select Theme: official-document
echo 3. Create a new document
echo 4. Use Ctrl+Shift+D to export
echo.
echo Theme directory: %THEME_DIR%
echo Config file: %CONFIG_FILE%
echo Project root: %PROJECT_ROOT%
echo.
echo For manual setup instructions, see:
echo docs/Typora详细配置教程.md
echo.
pause