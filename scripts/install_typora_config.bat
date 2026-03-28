@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM Typora 公文格式快速配置脚本
REM 自动安装主题和导出配置

echo =====================================
echo Typora 公文格式配置工具
echo =====================================
echo.

REM 获取项目根目录 (绝对路径)
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%.."
set "PROJECT_ROOT=%cd%"
set "CONVERT_SCRIPT=%PROJECT_ROOT%\scripts\convert_doc.bat"
set "THEME_SRC=%PROJECT_ROOT%\typora-config\typora-theme\official-document"

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
set "theme_dest=%APPDATA%\Typora\themes\official-document"
if not exist "%theme_dest%" (
    mkdir "%theme_dest%"
)

REM 复制主题文件
if exist "%THEME_SRC%" (
    copy /Y "%THEME_SRC%\*.css" "%theme_dest%\" >nul 2>&1
    copy /Y "%THEME_SRC%\README.md" "%theme_dest%\" >nul 2>&1
    echo ✅ 主题文件已安装到: %theme_dest%
) else (
    echo ❌ 找不到主题源文件: %THEME_SRC%
    pause
    exit /b 1
)

REM 配置导出设置
echo [3/5] 配置导出功能...
set "config_file=%typora_path%\conf.user.json"

REM 备份现有配置
if exist "%config_file%" (
    copy "%config_file%" "%config_file%.backup" >nul 2>&1
    echo ✅ 已备份现有配置 (conf.user.json.backup)
)

REM 转义路径中的反斜杠用于 JSON
set "ESC_PROJECT_ROOT=%PROJECT_ROOT:\=\\%"
set "ESC_CONVERT_SCRIPT=%CONVERT_SCRIPT:\=\\%"

echo 正在更新 Typora 配置文件...

REM 使用 PowerShell 安全地合并 JSON 配置
powershell -Command ^
    "$path = '%config_file%';" ^
    "$newConfig = @{" ^
    "  'defaultFontFamily' = '仿宋_GB2312';" ^
    "  'defaultFontSize' = 16;" ^
    "  'lineHeight' = 1.5;" ^
    "  'theme' = 'official-document';" ^
    "  'customExport' = @{" ^
    "    'official-doc' = @{" ^
    "      'name' = '公文格式Word';" ^
    "      'description' = '导出为符合国家标准的公文格式Word文档';" ^
    "      'command' = '!ESC_CONVERT_SCRIPT!';" ^
    "      'args' = @('${currentFilePath}', '${currentFilePath}.docx');" ^
    "      'workingDir' = '!ESC_PROJECT_ROOT!';" ^
    "      'shortcut' = 'ctrl+shift+d';" ^
    "      'icon' = 'file-word'" ^
    "    }" ^
    "  };" ^
    "  'editor' = @{" ^
    "    'fontSize' = 16;" ^
    "    'fontFamily' = '仿宋_GB2312';" ^
    "    'lineHeight' = 1.5;" ^
    "    'paragraphSpacing' = 8" ^
    "  }" ^
    "};" ^
    "if (Test-Path $path) {" ^
    "  $existing = Get-Content $path | ConvertFrom-Json;" ^
    "  if ($existing.customExport) {" ^
    "    $existing.customExport | Add-Member -NotePropertyName 'official-doc' -NotePropertyValue $newConfig.customExport.'official-doc' -Force;" ^
    "  } else {" ^
    "    $existing | Add-Member -NotePropertyName 'customExport' -NotePropertyValue $newConfig.customExport -Force;" ^
    "  }" ^
    "  $existing.theme = $newConfig.theme;" ^
    "  $existing | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8;" ^
    "} else {" ^
    "  $newConfig | ConvertTo-Json -Depth 10 | Set-Content $path -Encoding UTF8;" ^
    "}"

if !errorlevel! equ 0 (
    echo ✅ 导出配置已完成 (动态路径: %PROJECT_ROOT%)
) else (
    echo ❌ 导出配置失败
    pause
    exit /b 1
)

REM 检查pandoc安装
echo [4/5] 检查Pandoc安装状态...
where pandoc >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ Pandoc已安装
) else (
    echo ⚠️  Pandoc未安装，请手动安装: https://pandoc.org/installing.html
    echo 安装后需要重启Typora
)

REM 检查字体
echo [5/5] 检查必需字体...
echo 正在检查字体安装状态...

set "font_missing=0"
reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "方正小标宋" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ 方正小标宋简体已安装
) else (
    echo ⚠️  方正小标宋简体未安装
    set "font_missing=1"
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "黑体" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ 黑体已安装
) else (
    echo ⚠️  黑体未安装
    set "font_missing=1"
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "楷体" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ 楷体已安装
) else (
    echo ⚠️  楷体未安装
    set "font_missing=1"
)

reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /f "仿宋" >nul 2>&1
if !errorlevel! equ 0 (
    echo ✅ 仿宋已安装
) else (
    echo ⚠️  仿宋未安装
    set "font_missing=1"
)

if !font_missing! equ 1 (
    echo.
    echo 💡 提示: 部分公文字体缺失，请参考 fonts\README.md 安装。
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
echo 主题目录: %theme_dest%
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