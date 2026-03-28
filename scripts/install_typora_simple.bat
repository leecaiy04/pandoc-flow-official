@echo off
chcp 65001 >nul

REM Typora 公文格式配置脚本 (简化版)
REM 自动安装主题和导出配置

echo =====================================
echo Typora 公文格式配置工具
echo =====================================
echo.

REM 设置变量
set "TYPORA_CONFIG=%APPDATA%\Typora"
set "THEME_DIR=%APPDATA%\Typora\themes\official-document"
set "CONFIG_FILE=%APPDATA%\Typora\conf.user.json"
set "PROJECT_ROOT=%~dp0.."

echo [1/4] 检查Typora安装状态...
if not exist "%TYPORA_CONFIG%" (
    echo Error: Typora not found
    echo Please install Typora from: https://typora.io
    pause
    exit /b 1
)
echo OK: Typora installed

echo [2/4] Installing theme...
if not exist "%THEME_DIR%" (
    mkdir "%THEME_DIR%"
)

REM 复制主题文件
copy /Y "%PROJECT_ROOT%\typora-config\typora-theme\official-document\*.css" "%THEME_DIR%\" >nul 2>&1
copy /Y "%PROJECT_ROOT%\typora-config\typora-theme\official-document\README.md" "%THEME_DIR%\" >nul 2>&1

if exist "%THEME_DIR%\official.css" (
    echo OK: Theme files installed
) else (
    echo Error: Theme installation failed
    pause
    exit /b 1
)

echo [3/4] Configuring export...
REM 备份现有配置
if exist "%CONFIG_FILE%" (
    copy "%CONFIG_FILE%" "%CONFIG_FILE%.backup" >nul 2>&1
)

REM 创建配置文件
(
echo {
echo   "defaultFontFamily": "FangSong_GB2312",
echo   "defaultFontSize": 16,
echo   "lineHeight": 1.5,
echo   "theme": "official-document",
echo   "customExport": {
echo     "official-doc": {
echo       "name": "Official Document Word",
echo       "description": "Export to official document format",
echo       "command": "convert_doc.bat",
echo       "args": ["${currentFilePath}", "${currentFilePath}.docx"],
echo       "workingDir": "D:\\Code\\Template\\pandoc",
echo       "shortcut": "ctrl+shift+d",
echo       "icon": "file-word"
echo     }
echo   },
echo   "editor": {
echo     "fontSize": 16,
echo     "fontFamily": "FangSong_GB2312",
echo     "lineHeight": 1.5,
echo     "paragraphSpacing": 8
echo   }
echo }
) > "%CONFIG_FILE%"

if exist "%CONFIG_FILE%" (
    echo OK: Export configuration completed
) else (
    echo Error: Export configuration failed
    pause
    exit /b 1
)

echo [4/4] Checking dependencies...
where pandoc >nul 2>&1
if %errorlevel% equ 0 (
    echo OK: Pandoc installed
) else (
    echo Warning: Pandoc not found, please install from: https://pandoc.org/installing.html
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
pause