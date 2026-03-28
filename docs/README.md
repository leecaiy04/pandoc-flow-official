# 公文格式转换工具使用指南

## 工具概述

本工具提供将 Markdown 文档转换为符合国家标准公文格式的 Word 文档功能。支持从 Obsidian、Typora 等编辑器直接导出。

## 标题级别映射

| Markdown 语法 | Word样式 | 字体 | 字号 | 样式 | 对齐方式 | 说明 |
|---------------|----------|------|------|------|----------|------|
| `# 标题`      | 文档标题 | 方正小标宋简体 | 二号(22pt) | 加粗 | 居中 | 公文正式标题 |
| `## 标题`     | 一级标题 | 黑体 | 三号(16pt) | 加粗 | 左对齐 | 主要章节标题 |
| `### 标题`    | 二级标题 | 楷体_GB2312 | 三号(16pt) | 加粗 | 左对齐 | 次级章节标题 |
| `#### 标题`   | 三级标题 | 仿宋_GB2312 | 三号(16pt) | 加粗 | 左对齐 | 三级章节标题 |
| 普通文本      | 正文     | 仿宋_GB2312 | 三号(16pt) | 常规 | 首行缩进2字符 | 正文内容 |

## 快速开始

### 1. 环境准备
```bash
# 安装 pandoc (Windows)
choco install pandoc

# 或从官网下载安装
# https://pandoc.org/installing.html
```

### 2. 转换命令
```bash
# Windows
convert_doc.bat input.md output.docx

# Linux/Mac
./convert_doc.sh input.md output.docx

# 直接使用 pandoc
pandoc input.md --reference-doc=公文模板.docx -o output.docx
```

### 3. 测试转换
```bash
# 使用提供的示例
convert_doc.bat 示例文档.md 测试输出.docx
```

## 编辑器集成

### Obsidian 用户
参考：[Obsidian导出配置.md](Obsidian导出配置.md)

- 支持自定义命令导出
- 支持快捷键操作
- 支持批量处理

### Typora 用户
参考：[Typora导出配置.md](Typora导出配置.md)

- 内置导出菜单
- 支持自定义模板
- 支持实时预览

## 文件说明

```
pandoc/
├── 公文模板.docx          # 基础模板文件
├── reference.docx         # pandoc 参考文档
├── convert_doc.bat        # Windows 转换脚本（已更新）
├── convert_doc.sh         # Linux/Mac 转换脚本（已更新）
├── convert_doc_updated.bat # 更新版转换脚本
├── convert_doc_with_font.bat # 带字体规范脚本
├── 示例文档.md            # 测试用例（已更新）
├── Obsidian导出配置.md     # Obsidian 配置说明
├── Typora导出配置.md       # Typora 配置说明
├── 公文字体规范.md         # 详细的字体配置指南
├── 更新标题映射.md         # 标题映射更新说明
└── README.md              # 本说明文档
```

## 高级功能

### 1. 批量转换
```batch
# Windows 批量转换脚本
for %%f in (*.md) do (
    convert_doc.bat "%%f" "%%~nf_正式.docx"
)
```

### 2. 自定义样式
可以通过修改 `公文模板.docx` 中的样式来自定义：
- 字体设置
- 段落间距
- 页面布局
- 页眉页脚

### 3. 元数据支持
在 Markdown 文件开头添加 YAML front matter：

```markdown
---
title: 文档标题
author: 作者姓名
date: 2024-01-15
---

# 正文内容
```

## 故障排除

### 常见问题

**Q: 转换后格式不正确？**
A: 检查 `公文模板.docx` 中的样式设置，确保标题样式已正确定义。

**Q: 中文显示乱码？**
A: 确保 Markdown 文件使用 UTF-8 编码保存。

**Q: 找不到 pandoc 命令？**
A: 重新安装 pandoc 并确保已添加到系统 PATH。

**Q: 模板文件损坏？**
A: 使用原始模板文件重新创建 `reference.docx`。

### 日志查看
转换过程中的详细信息可以通过以下方式查看：

```bash
# 详细输出
pandoc input.md --reference-doc=公文模板.docx -o output.docx --verbose

# 调试模式
pandoc input.md --reference-doc=公文模板.docx -o output.docx --debug
```

## 技术支持

如遇到问题，请提供：
1. 错误信息截图
2. 输入的 Markdown 文件
3. 使用的命令和参数
4. 操作系统版本

## 更新日志

- v1.0.0: 初始版本，支持基本转换功能
- 支持标题级别映射
- 支持主要编辑器集成

## 许可证

本工具遵循 MIT 许可证，可自由使用和修改。