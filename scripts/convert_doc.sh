#!/bin/bash

# 公文格式转换脚本 (Linux/Mac)
# 使用方法: ./scripts/convert_doc.sh <输入文件.md> [输出文件.docx]

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( dirname "$SCRIPT_DIR" )"
DEFAULTS_FILE="$PROJECT_ROOT/templates/pandoc-defaults.yaml"
TEMPLATE="$PROJECT_ROOT/templates/official-template.docx"

if [ $# -lt 1 ]; then
    echo "使用方法: $0 <输入文件.md> [输出文件.docx]"
    echo "示例: $0 document.md document.docx"
    echo ""
    echo "标题映射："
    echo "# → 文档标题（方正小标宋简体二号）"
    echo "## → 一级标题（黑体三号）"
    echo "### → 二级标题（楷体三号）"
    echo "#### → 三级标题（仿宋三号）"
    exit 1
fi

input_file="$1"
if [ -z "$2" ]; then
    output_file="${input_file%.*}.docx"
else
    output_file="$2"
fi

# 检查文件是否存在
if [ ! -f "$input_file" ]; then
    echo "错误: 输入文件 '$input_file' 不存在"
    exit 1
fi

if [ ! -f "$DEFAULTS_FILE" ]; then
    echo "警告: 默认配置文件 '$DEFAULTS_FILE' 不存在"
    echo "将尝试使用命令行参数进行转换..."
fi

if [ ! -f "$TEMPLATE" ]; then
    echo "错误: 模板文件 '$TEMPLATE' 不存在"
    exit 1
fi

# 检查Pandoc是否安装
if ! command -v pandoc &> /dev/null; then
    echo "错误: 未找到 pandoc 命令，请确保已安装 Pandoc。"
    exit 1
fi

echo "正在转换: '$input_file' -> '$output_file'..."

if [ -f "$DEFAULTS_FILE" ]; then
    pandoc "$input_file" \
        -d "$DEFAULTS_FILE" \
        --reference-doc="$TEMPLATE" \
        --output="$output_file"
else
    pandoc "$input_file" \
        --reference-doc="$TEMPLATE" \
        --from=markdown \
        --to=docx \
        --output="$output_file" \
        --highlight-style=pygments \
        --metadata title="公文文档" \
        --variable mainfont="仿宋_GB2312" \
        --variable CJKmainfont="方正小标宋简体"
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "转换成功: $output_file"
    echo "------------------------------------------"
    echo "提示: 请在Word中确认以下样式是否正确应用："
    echo "1. 文档标题 (#) -> 方正小标宋简体二号居中"
    echo "2. 一级标题 (##) -> 黑体三号"
    echo "3. 二级标题 (###) -> 楷体三号"
    echo "4. 三级标题 (####) -> 仿宋三号"
    echo "5. 正文 -> 仿宋三号 (首行缩进2字符)"
    echo "------------------------------------------"
else
    echo ""
    echo "错误: 转换失败"
    exit 1
fi
