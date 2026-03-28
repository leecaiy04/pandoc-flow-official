#!/bin/bash

# 公文格式转换脚本
# 标题映射：#→文档标题，##→一级标题，###→二级标题，####→三级标题
# 使用方法: ./convert_doc.sh input.md output.docx

if [ $# -ne 2 ]; then
    echo "使用方法: $0 <输入文件.md> <输出文件.docx>"
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
output_file="$2"
template="公文模板.docx"

# 检查文件是否存在
if [ ! -f "$input_file" ]; then
    echo "错误: 输入文件 '$input_file' 不存在"
    exit 1
fi

if [ ! -f "$template" ]; then
    echo "错误: 模板文件 '$template' 不存在"
    exit 1
fi

# 使用pandoc转换
pandoc "$input_file" \
    --reference-doc="$template" \
    --from=markdown \
    --to=docx \
    --output="$output_file" \
    --highlight-style=pygments \
    --metadata title="公文文档" \
    --variable CJKmainfont="方正小标宋简体"

if [ $? -eq 0 ]; then
    echo "转换成功: $output_file"
    echo ""
    echo "标题映射已应用："
    echo "# → 文档标题（请在Word中确认标题1样式：方正小标宋简体二号居中）"
    echo "## → 一级标题（请在Word中确认标题2样式：黑体三号左对齐）"
    echo "### → 二级标题（请在Word中确认标题3样式：楷体三号左对齐）"
    echo "#### → 三级标题（请在Word中确认标题4样式：仿宋三号左对齐）"
else
    echo "转换失败"
    exit 1
fi