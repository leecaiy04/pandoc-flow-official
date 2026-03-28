@echo off
chcp 65001 >nul

REM Typora 公文格式快速配置脚本
REM 自动安装主题和导出配置

echo =====================================
echo Typora 公文格式配置工具
echo =====================================
echo.

REM 检查Typora是否安装
echo [1/5] 检查Typora安装状态...
set "typora_path=%APPDATA%\Typora"
if not exist "%typora_path%" (
    echo ❌ 未找到Typora安装目录
    echo 请先安装Typora: https://typora.io
    pause
    exit /b 1
)
echo ✅ Typora已安装

REM 创建主题目录
echo [2/5] 安装公文主题...
set "theme_dir=%APPDATA%\Typora\themes\official-document"
if not exist "%theme_dir%" (
    mkdir "%theme_dir%"
)

REM 复制主题文件
copy /Y "..\typora-config\typora-theme\official-document\*.css" "%theme_dir%\" >nul 2>&1
copy /Y "..\typora-config\typora-theme\official-document\README.md" "%theme_dir%\" >nul 2>&1
if exist "%theme_dir%\official.css" (
    echo ✅ 主题文件已安装到: %theme_dir%
) else (
    echo ❌ 主题文件安装失败
    pause
    exit /b 1
)

REM 配置导出设置
echo [3/5] 配置导出功能...
set "config_dir=%APPDATA%\Typora"
set "config_file=%config_dir%\conf.user.json"

REM 备份现有配置
if exist "%config_file%" (
    copy "%config_file%" "%config_file%.backup" >nul 2>&1
    echo ✅ 已备份现有配置
)

REM 创建或更新配置
echo { > "%config_file%"
echo   "defaultFontFamily": "仿宋_GB2312", >> "%config_file%"
echo   "defaultFontSize": 16, >> "%config_file%"
echo   "lineHeight": 1.5, >> "%config_file%"
echo   "theme": "official-document", >> "%config_file%"
echo   "customExport": { >> "%config_file%"
echo     "official-doc": { >> "%config_file%"
echo       "name": "公文格式Word", >> "%config_file%"
echo       "description": "导出为符合国家标准的公文格式Word文档", >> "%config_file%"
echo       "command": "convert_doc.bat", >> "%config_file%"
echo       "args": ["${currentFilePath}", "${currentFilePath}.docx"], >> "%config_file%"
echo       "workingDir": "D:\\Code\\Template\\pandoc", >> "%config_file%"
echo       "shortcut": "ctrl+shift+d", >> "%config_file%"
echo       "icon": "file-word" >> "%config_file%"
echo     } >> "%config_file%"
echo   }, >> "%config_file%"
echo   "editor": { >> "%config_file%"
echo     "fontSize": 16, >> "%config_file%"
echo     "fontFamily": "仿宋_GB2312", >> "%config_file%"
echo     "lineHeight": 1.5, >> "%config_file%"
echo     "paragraphSpacing": 8 >> "%config_file%"
echo   } >> "%config_file%"
echo } >> "%config_file%"

if exist "%config_file%" (
    echo ✅ 导出配置已完成
) else (
    echo ❌ 导出配置失败
    pause
    exit /b 1
)

REM 检查pandoc安装
echo [4/5] 检查Pandoc安装状态...
where pandoc >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ Pandoc已安装
) else (
    echo ⚠️  Pandoc未安装，请手动安装: https://pandoc.org/installing.html
    echo 安装后需要重启Typora
)

REM 检查字体
echo [5/5] 检查必需字体...
echo 正在检查字体安装状态...

REM 检查方正小标宋简体
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "方正小标宋" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 方正小标宋简体已安装
) else (
    echo ⚠️  方正小标宋简体未安装，标题可能显示为默认字体
)

REM 检查其他字体
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "黑体" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 黑体已安装
) else (
    echo ⚠️  黑体未安装
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "楷体" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 楷体已安装
) else (
    echo ⚠️  楷体未安装
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "仿宋" >nul 2>&1
if %errorlevel% equ 0 (
    echo ✅ 仿宋已安装
) else (
    echo ⚠️  仿宋未安装
)

echo.
echo =====================================
echo 配置完成！
echo =====================================
echo.
echo 📋 后续步骤：
echo 1. 重启Typora使配置生效
echo 2. 在Typora中选择: 主题 → official-document
echo 3. 创建或打开Markdown文档
echo 4. 使用快捷键 Ctrl+Shift+D 导出公文格式Word
echo.
echo 📁 配置文件位置:
echo 主题目录: %theme_dir%
echo 配置文件: %config_file%
echo.
echo 💡 使用说明:
echo # 文档标题 (方正小标宋简体)
echo ## 一级标题 (黑体)
echo ### 二级标题 (楷体)
echo #### 三级标题 (仿宋)
echo.
echo 📖 详细教程请查看: Typora详细配置教程.md
echo.
pause