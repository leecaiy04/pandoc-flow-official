@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM 🚀 公文格式一键转换工具 (拖放至此运行)
REM 功能：将 Markdown 拖放到此图标上，在同级目录生成 Word
REM 作者：Pandoc Flow

echo =====================================
echo    🏛️  公文格式一键转换工具
echo =====================================
echo.

REM 检查是否有输入参数 (拖放的文件名)
if "%~1"=="" (
    echo [🛑 错误] 请将 Markdown 文件拖放到此脚本图标上进行转换。
    echo.
    pause
    exit /b 1
)

REM 获取脚本所在的项目根目录
set "SCRIPT_DIR=%~dp0"
set "PROJECT_ROOT=%SCRIPT_DIR%.."
set "CONVERT_SCRIPT=%SCRIPT_DIR%convert_doc.bat"

REM 循环处理所有拖入的文件
:process
if "%~1"=="" goto finish

set "input_file=%~1"
set "output_file=%~dpn1.docx"

echo [🔄 正在处理] "%~nx1" ...
call "%CONVERT_SCRIPT%" "%input_file%" "%output_file%"

shift
goto process

:finish
echo.
echo =====================================
echo ✅ 所有文件转换完成！
echo =====================================
echo.
echo 💡 提示：转换后的 Word 文档已生成在源 Markdown 文件同一目录下。
echo.
pause
