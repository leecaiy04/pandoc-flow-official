# 🏛️ 公文格式转换工具 (Pandoc Flow)

> **让 Markdown 文档转换符合《党政机关公文格式》(GB/T 9704-2012) 标准。**

本项目提供了一套完整的自动化转换方案，支持 Typora、Obsidian 等编辑器，实现一键导出符合国家标准的 Word 公文。

---

## 🎯 快速导航

### 🔥 核心功能
- 🚀 [快速开始](#-快速开始) - 环境准备与基本使用
- 🎨 [编辑器集成](#-编辑器集成) - Typora 与 Obsidian 配置
- 🔧 [脚本说明](scripts/README.md) - 自动化转换脚本细节
- 📄 [模板配置](templates/README.md) - Pandoc 与 Word 模板规范

### 📚 文档与资料
- 📋 [详细文档索引](docs/INDEX.md) - 深度使用指南
- 🎭 [字体规范清单](docs/公文字体规范.md) - 国家标准字体对照
- 📝 [正确格式示例](examples/示例文档.md) - 标注正确的 MD 源码

---

## 📁 项目结构

```
pandoc-flow/
├── 🏠 README.md                    # 项目入口说明 (本文件)
├── 📂 scripts/                     # 自动化工具脚本
│   ├── convert_doc.bat            # Windows 智能转换脚本 ⭐
│   ├── convert_doc.sh             # Linux/Mac 智能转换脚本 ⭐
│   └── install_typora_config.bat # Typora 一键部署工具 ⭐
├── 📂 templates/                   # 核心格式模板
│   ├── official-template.docx      # Word 核心样式母版 ⭐
│   ├── pandoc-defaults.yaml       # Pandoc 统一配置参数 ⭐
│   └── reference.docx              # 备用参考文档
├── 📂 docs/                        # 深度文档库
│   ├── Typora详细配置教程.md       # Typora 完备集成指南
│   ├── Obsidian导出配置.md         # Obsidian 插件集成方案
│   └── ☆公文格式GB_T 9704—2012.pdf # 国家标准原件
├── 📂 examples/                    # 标准用例
│   └── 示例文档.md                # 格式演示 MD 文件
└── 📂 output/                      # 默认转换输出目录
```

---

## 📋 功能特性

- ✅ **标准合规**: 严格遵循 GB/T 9704-2012 公文格式要求。
- ✅ **智能映射**: 自动处理 `#` 标题到“方正小标宋简体二号”等映射关系。
- ✅ **一键集成**: 提供 Windows 一键配置脚本，自动处理路径与字体检查。
- ✅ **跨平台**: 完美支持 Windows、Linux 及 macOS 系统。
- ✅ **深度支持**: 专为 Typora 和 Obsidian 优化，支持快捷键导出。

## 🎯 标题映射规则

| Markdown 语法 | Word 样式 | 字体 (标准) | 字号 | 说明 |
|:---|:---|:---|:---|:---|
| `# 标题` | 文档标题 | 方正小标宋简体 | 二号 (22pt) | 居中，公文正式标题 |
| `## 标题` | 一级标题 | 黑体 | 三号 (16pt) | 主要章节标题 |
| `### 标题` | 二级标题 | 楷体_GB2312 | 三号 (16pt) | 次级章节标题 |
| `#### 标题` | 三级标题 | 仿宋_GB2312 | 三号 (16pt) | 三级章节标题 |
| 普通文本 | 正文 | 仿宋_GB2312 | 三号 (16pt) | 默认正文，首行缩进 |

---

## 🚀 快速开始

### 1. 环境准备
- **安装 Pandoc**: [官方下载页面](https://pandoc.org/installing.html)
- **安装字体**: 确保系统中已安装“方正小标宋简体”、“黑体”、“楷体”、“仿宋”等字体。

### 2. 基本使用 (命令行)
```bash
# Windows
scripts\convert_doc.bat input.md [output.docx]

# Linux/Mac
./scripts/convert_doc.sh input.md [output.docx]
```

### 3. 测试转换
```bash
# 使用自带示例进行测试
scripts\convert_doc.bat examples/示例文档.md output/测试输出.docx
```

---

## 🔧 编辑器集成

### Typora 用户 🎨
建议运行自动配置脚本，实现一键集成：
1. 双击运行 `scripts\install_typora_config.bat`。
2. 重启 Typora，在主题菜单中选择 `official-document`。
3. 编写文档后，按 `Ctrl+Shift+D` 即可秒转公文 Word。

### Obsidian 用户 🔍
1. 参考 [Obsidian导出配置.md](docs/Obsidian导出配置.md) 安装 QuickAdd 插件。
2. 将 `convert_doc.bat` 或 `.sh` 配置为外部命令。

---

## ⚠️ 故障排除与 FAQ

- **Q: 转换后标题字体不对？**
  - A: 检查是否安装了“方正小标宋简体”，并确认 `pandoc-defaults.yaml` 中的 CJKmainfont 设置。
- **Q: 脚本运行报错 "pandoc not found"？**
  - A: 请将 Pandoc 的安装路径添加到系统的环境变量 PATH 中。
- **Q: 如何修改页边距？**
  - A: 直接在 Word 中打开 `templates/official-template.docx`，修改“页面设置”后保存即可。

---

## 🔄 更新日志

- **v2.0 (2024-03)**:
  - 🚀 引入 `install_typora_config.bat` 实现一键无损配置集成。
  - 🧹 清理冗余脚本，统一路径识别逻辑。
  - 📖 整合说明文档，优化目录结构。
  - 🔧 强化 `convert_doc` 脚本，支持 Pandoc Defaults 模式。

---

## 📄 许可证
本项目遵循 [MIT License](LICENSE)。

---

**🎉 立即开始，让您的 Markdown 写作拥有公文般的专业质感！**