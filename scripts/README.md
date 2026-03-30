# 脚本目录说明

## 📜 脚本列表

### 核心转换脚本

| 脚本文件 | 描述 | 推荐度 | 使用方法 |
|----------|------|--------|----------|
| `convert_doc.bat` | **主要脚本** - Windows转换，支持自动检测路径 | ⭐⭐⭐⭐⭐ | `scripts\convert_doc.bat <input.md> [output.docx]` |
| `convert_doc.sh` | **主要脚本** - Linux/Mac转换，支持自动检测路径 | ⭐⭐⭐⭐⭐ | `./scripts/convert_doc.sh <input.md> [output.docx]` |

### 配置脚本

| 脚本文件 | 描述 | 推荐度 | 用途 |
|----------|------|--------|----------|
| `install_typora_config.bat` | Typora一键配置脚本 | ⭐⭐⭐⭐⭐ | 自动安装主题、配置自定义导出和检查字体 |

## 🚀 快速使用

### Windows用户

#### 1. 转换文档
```batch
# 将 Markdown 转换为 Word (默认输出同名 docx)
scripts\convert_doc.bat examples\示例文档.md

# 指定输出文件名
scripts\convert_doc.bat examples\示例文档.md output\我的公文.docx
```

#### 2. 配置 Typora (推荐)
```batch
# 运行一键配置脚本
scripts\install_typora_config.bat
```
配置完成后，在 Typora 中按 `Ctrl+Shift+D` 即可一键转换。

### Linux/Mac用户

#### 1. 转换文档
```bash
# 添加执行权限
chmod +x scripts/*.sh

# 执行转换
./scripts/convert_doc.sh examples/示例文档.md
```

## ⚙️ 脚本细节

### convert_doc.bat / .sh
这两个脚本现在更加智能化：
- ✅ **自动路径识别**: 无论在项目根目录还是脚本目录运行，都能正确找到模板和配置文件。
- ✅ **Pandoc Defaults 支持**: 使用 `templates/pandoc-defaults.yaml` 进行统一配置，便于维护。
- ✅ **显式模板绑定**: 脚本会额外传入 `--reference-doc`，避免工作目录变化导致样式丢失。
- ✅ **参数优化**: 输出文件名现在是可选的，如果不指定则自动生成。
- ✅ **增强纠错**: 会检查 Pandoc 是否安装，以及模板文件是否存在。

### install_typora_config.bat
该脚本旨在实现真正的“一键配置”：
- ✅ **动态路径写入**: 自动获取项目当前所在位置，并写入 Typora 配置，彻底解决了路径硬编码问题。
- ✅ **环境健康检查**: 自动检查常用公文字体（仿宋、楷体、黑体、小标宋）是否已在 Windows 系统中安装。
- ✅ **安全备份**: 在修改 Typora 的 `conf.user.json` 之前会自动创建备份。

## 📝 标题映射说明

脚本遵循《党政机关公文格式》(GB/T 9704-2012) 标准：

| Markdown | Word样式 | 字体 | 字号 |
|----------|----------|------|------|
| `# 标题` | 文档标题 | 方正小标宋简体 | 二号(22pt) |
| `## 标题` | 一级标题 | 黑体 | 三号(16pt) |
| `### 标题` | 二级标题 | 楷体_GB2312 | 三号(16pt) |
| `#### 标题` | 三级标题 | 仿宋_GB2312 | 三号(16pt) |

## 🚨 故障排除

### 常见错误

**错误：** `pandoc not found`
**解决：** 请安装 Pandoc (https://pandoc.org) 并将其路径添加到系统环境变量 PATH 中。

**错误：** `模板文件不存在`
**解决：** 请确保 `templates/official-template.docx` 文件存在于项目中。

**错误：** 字体显示不正确
**解决：** 
1. 运行 `install_typora_config.bat` 查看字体检查结果。
2. 缺失字体请参考 `fonts/README.md`。

## 🔄 版本历史

- **v2.0**: 
  - 脚本逻辑大重构，支持动态路径识别。
  - 引入 `pandoc-defaults.yaml`。
  - 删除了所有冗余脚本，保持项目整洁。
  - 优化了 Typora 一键配置脚本，支持自动字体检测。
