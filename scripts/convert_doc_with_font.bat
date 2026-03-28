@echo off
chcp 65001 >nul

REM 公文格式转换脚本 - 带字体规范 (Windows版本)
REM 使用方法: convert_doc_with_font.bat input.md output.docx

if "%~1"=="" (
    echo 使用方法: %0 ^<输入文件.md^> ^<输出文件.docx^>
    echo 示例: %0 document.md document.docx
    exit /b 1
)

if "%~2"=="" (
    echo 使用方法: %0 ^<输入文件.md^> ^<输出文件.docx^>
    echo 示例: %0 document.md document.docx
    exit /b 1
)

set "input_file=%~1"
set "output_file=%~2"
set "template=公文模板.docx"

REM 检查文件是否存在
if not exist "%input_file%" (
    echo 错误: 输入文件 '%input_file%' 不存在
    exit /b 1
)

if not exist "%template%" (
    echo 错误: 模板文件 '%template%' 不存在
    exit /b 1
)

REM 使用pandoc转换，应用自定义字体样式
pandoc "%input_file%" ^
    --reference-doc="%template%" ^
    --from=markdown ^
    --to=docx ^
    --output="%output_file%" ^
    --highlight-style=pygments ^
    --metadata title="公文文档" ^
    --variable fontsize=22pt ^
    --variable mainfont="方正小标宋简体" ^
    --variable CJKmainfont="方正小标宋简体"

if %errorlevel% equ 0 (
    echo 转换成功: %output_file%
    echo 注意：请在Word中检查字体设置是否正确应用
) else (
    echo 转换失败
    exit /b 1
)