# 公文格式转换工具使用指南

## 工具概述

本工具旨在将 Markdown 文档快速转换为符合《党政机关公文格式》(GB/T 9704-2012) 国家标准的 Word 文档。它通过 Pandoc 引擎，结合预设的公文模板，实现了格式的精确映射。

## 标题级别映射

| Markdown 语法 | Word 样式 | 字体 | 字号 | 属性 | 说明 |
|---------------|----------|------|------|------|------|
| `# 标题`      | 文档标题 | 方正小标宋简体 | 二号(22pt) | 居中 | 公文正式标题 |
| `## 标题`     | 一级标题 | 黑体 | 三号(16pt) | 左对齐 | 主要章节标题 |
| `### 标题`    | 二级标题 | 楷体_GB2312 | 三号(16pt) | 左对齐 | 次级章节标题 |
| `#### 标题`   | 三级标题 | 仿宋_GB2312 | 三号(16pt) | 左对齐 | 三级章节标题 |
| 普通文本      | 正文     | 仿宋_GB2312 | 三号(16pt) | 首行缩进 | 正文内容 |

## 🚀 快速开始

### 1. 转换文档
在项目根目录下运行：
```batch
# Windows
scripts\convert_doc.bat input.md [output.docx]

# Linux/Mac
./scripts/convert_doc.sh input.md [output.docx]
```

### 2. Typora 一键集成
如果您使用 Typora，直接运行配置脚本：
```batch
scripts\install_typora_config.bat
```
之后在 Typora 中按 `Ctrl+Shift+D` 即可完成导出。

## 📁 核心文件说明

- `scripts/convert_doc.bat`: Windows 主转换程序。
- `scripts/convert_doc.sh`: Linux/Mac 主转换程序。
- `templates/official-template.docx`: 包含所有样式的 Word 模板。
- `templates/pandoc-defaults.yaml`: Pandoc 统一配置参数。
- `docs/Typora详细配置教程.md`: 针对 Typora 用户的深度指南。
- `examples/示例文档.md`: 标注了正确格式的 MD 示例文件。

## 🛠️ 高级技巧

### 1. 批量处理 (Windows)
```batch
for %f in (*.md) do scripts\convert_doc.bat "%f"
```

### 2. 自定义样式
如需调整行间距或页边距，请直接编辑 `templates/official-template.docx`：
1. 打开文件。
2. 在“样式”面板中找到并修改对应样式（如“正文”）。
3. 保存文件后再次运行转换脚本即可生效。

## 🚨 常见问题

- **转换出来的字体不对?** 请确保系统中已安装“方正小标宋简体”、“楷体_GB2312”等字体。
- **手动运行 pandoc 时样式偶尔失效?** 请同时传入 `-d templates/pandoc-defaults.yaml` 和 `--reference-doc templates/official-template.docx`。
- **命令报错 "pandoc not found"?** 请安装 [Pandoc](https://pandoc.org) 并配置 PATH 环境变量。
- **想要修改默认标题字体?** 修改 `templates/pandoc-defaults.yaml` 中的 `variables` 部分。

---
📖 更多详细信息请参考 [项目首页 README](../README.md)。
