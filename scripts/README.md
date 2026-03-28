# 脚本目录说明

## 📜 脚本列表

### 主要转换脚本

| 脚本文件 | 描述 | 推荐度 | 使用方法 |
|----------|------|--------|----------|
| `convert_doc.bat` | **主要脚本** - Windows转换 | ⭐⭐⭐⭐⭐ | `convert_doc.bat input.md output.docx` |
| `convert_doc.sh` | **主要脚本** - Linux/Mac转换 | ⭐⭐⭐⭐⭐ | `./convert_doc.sh input.md output.docx` |

### 特殊用途脚本

| 脚本文件 | 描述 | 推荐度 | 备注 |
|----------|------|--------|------|
| `convert_doc_updated.bat` | 更新版转换脚本 | ⭐⭐⭐ | 已合并到主脚本 |
| `convert_doc_with_font.bat` | 带字体规范脚本 | ⭐⭐ | 包含更多字体参数 |

### 配置脚本

| 脚本文件 | 描述 | 推荐度 | 用途 |
|----------|------|--------|------|
| `setup_typora.bat` | Typora自动配置（英文版） | ⭐⭐⭐ | 自动安装Typora配置 |
| `install_typora_config.bat` | Typora配置脚本（原版） | ⭐⭐ | 可能存在编码问题 |
| `install_typora_simple.bat` | Typora简化配置 | ⭐⭐ | 简化版安装脚本 |

## 🚀 快速使用

### Windows用户
```batch
# 主要转换脚本
scripts\convert_doc.bat document.md document.docx

# 配置Typora (推荐使用英文版)
scripts\setup_typora.bat

# 或手动配置，参考：../docs/Typora手动配置指南.md
```

### Linux/Mac用户
```bash
# 主要转换脚本
./scripts/convert_doc.sh document.md document.docx

# 添加执行权限
chmod +x scripts/*.sh
```

## ⚙️ 脚本配置

### 环境要求
- **Windows**: Windows 10/11
- **Linux**: 任意发行版
- **Mac**: macOS 10.14+

### 依赖软件
- **Pandoc**: 必需 (https://pandoc.org)
- **字体**: 见 ../fonts/README.md

### 脚本参数
所有脚本都遵循相同的参数格式：
```
<脚本文件> <输入文件.md> <输出文件.docx>
```

## 🔧 脚本详解

### convert_doc.bat (Windows主脚本)
```batch
@echo off
chcp 65001 >nul
pandoc "%input_file%" --reference-doc="%template%" --variable CJKmainfont="方正小标宋简体" -o "%output_file%"
```

**功能特点：**
- ✅ 支持中文UTF-8
- ✅ 自动设置中文字体
- ✅ 详细的错误提示
- ✅ 参数验证

### convert_doc.sh (Linux/Mac主脚本)
```bash
pandoc "$input_file" --reference-doc="$template" --variable CJKmainfont="方正小标宋简体" -o "$output_file"
```

**功能特点：**
- ✅ 支持Linux/Mac路径
- ✅ 参数检查
- ✅ 错误处理

## 📝 标题映射说明

所有脚本都使用统一的标题映射：

| Markdown | Word样式 | 字体 | 字号 |
|----------|----------|------|------|
| `# 标题` | 文档标题 | 方正小标宋简体 | 二号(22pt) |
| `## 标题` | 一级标题 | 黑体 | 三号(16pt) |
| `### 标题` | 二级标题 | 楷体_GB2312 | 三号(16pt) |
| `#### 标题` | 三级标题 | 仿宋_GB2312 | 三号(16pt) |

## 🛠️ 脚本维护

### 添加新脚本
1. 创建新的 `.bat` 或 `.sh` 文件
2. 添加到本说明文档
3. 更新索引文件

### 修改现有脚本
1. 备份原文件
2. 测试修改效果
3. 更新文档

## 🚨 故障排除

### 常见错误

**错误：** `pandoc not found`
**解决：** 安装pandoc并添加到PATH

**错误：** `模板文件不存在`
**解决：** 确保 `../templates/公文模板.docx` 存在

**错误：** `字体未找到`
**解决：** 参考字体安装指南

**错误：** Typora配置脚本乱码
**解决：** 
1. 使用英文版脚本：`setup_typora.bat`
2. 或手动配置：参考 `../docs/Typora手动配置指南.md`
3. 检查系统编码设置

### 调试模式
在脚本中添加调试输出：
```batch
echo 正在处理: %input_file%
echo 输出文件: %output_file%
echo 模板文件: %template%
```

## 📊 脚本状态

- ✅ convert_doc.bat - 正常工作
- ✅ convert_doc.sh - 正常工作  
- ✅ install_typora_config.bat - 正常工作
- ⚠️ convert_doc_updated.bat - 已废弃
- ⚠️ convert_doc_with_font.bat - 可选使用

## 🔄 版本历史

- **v1.0**: 基础转换功能
- **v1.1**: 添加字体参数
- **v1.2**: 统一标题映射
- **v1.3**: 添加错误处理
- **v2.0**: 脚本重组和优化