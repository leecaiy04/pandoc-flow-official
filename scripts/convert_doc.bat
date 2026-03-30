@echo off
chcp 65001 >nul

REM 公文格式转换脚本 (Windows版本)
REM 使用方法: scripts\convert_doc.bat <输入文件.md> [输出文件.docx]

set "PROJECT_ROOT=%~dp0.."
set "DEFAULTS_FILE=%PROJECT_ROOT%\templates\pandoc-defaults.yaml"
set "TEMPLATE=%PROJECT_ROOT%\templates\official-template.docx"

if "%~1"=="" (
    echo 使用方法: %0 ^<输入文件.md^> [输出文件.docx]
    echo 示例: %0 document.md document.docx
    echo.
    echo 标题映射：
    echo # → 文档标题（方正小标宋简体二号）
    echo ## → 一级标题（黑体三号）
    echo ### → 二级标题（楷体三号）
    echo #### → 三级标题（仿宋三号）
    exit /b 1
)

if "%~2"=="" (
    set "input_file=%~1"
    set "output_file=%~n1.docx"
) else (
    set "input_file=%~1"
    set "output_file=%~2"
)

REM 检查文件是否存在
if not exist "%input_file%" (
    echo 错误: 输入文件 '%input_file%' 不存在
    exit /b 1
)

if not exist "%TEMPLATE%" (
    echo 错误: 模板文件 '%TEMPLATE%' 不存在
    exit /b 1
)

REM 检查Pandoc是否安装
where pandoc >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 pandoc 命令，请确保已安装 Pandoc 并将其添加到环境变量 PATH 中。
    exit /b 1
)

echo 正在转换: "%input_file%" 到 "%output_file%"...

if exist "%DEFAULTS_FILE%" (
    pandoc "%input_file%" -d "%DEFAULTS_FILE%" --reference-doc="%TEMPLATE%" -o "%output_file%"
) else (
    pandoc "%input_file%" --reference-doc="%TEMPLATE%" -o "%output_file%"
)

if %errorlevel% equ 0 (
    echo.
    echo 转换成功: "%output_file%"
    echo ------------------------------------------
    echo 提示: 请在Word中检查标题和样式。
    echo ------------------------------------------
) else (
    echo.
    echo 错误: 转换失败
    exit /b 1
)
