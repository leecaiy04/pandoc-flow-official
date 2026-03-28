# 公文格式转换工具

> 🏛️ 将Markdown文档转换为符合《党政机关公文格式》(GB/T 9704-2012)标准的Word文档

## 📋 功能概述

- ✅ **标准公文格式**: 符合国家标准公文格式要求
- ✅ **多编辑器支持**: Typora、Obsidian等主流Markdown编辑器
- ✅ **字体规范**: 方正小标宋简体、黑体、楷体、仿宋等标准字体
- ✅ **一键配置**: 提供自动安装和配置脚本
- ✅ **跨平台**: 支持Windows、Linux、macOS

## 🎯 标题映射

| Markdown语法 | Word样式 | 字体 | 字号 | 说明 |
|--------------|----------|------|------|------|
| `# 标题` | 文档标题 | 方正小标宋简体 | 二号(22pt) | 公文正式标题 |
| `## 标题` | 一级标题 | 黑体 | 三号(16pt) | 主要章节 |
| `### 标题` | 二级标题 | 楷体_GB2312 | 三号(16pt) | 次级章节 |
| `#### 标题` | 三级标题 | 仿宋_GB2312 | 三号(16pt) | 三级章节 |
| 普通文本 | 正文 | 仿宋_GB2312 | 三号(16pt) | 正文内容 |

## 🚀 快速开始

### 1. 环境准备

#### 安装Pandoc
```bash
# Windows (使用Chocolatey)
choco install pandoc

# 或从官网下载
# https://pandoc.org/installing.html
```

#### 检查字体
```bash
# 检查必需字体是否安装
# 参考: fonts/README.md
```

### 2. 基本使用

#### 使用转换脚本
```bash
# Windows
scripts\convert_doc.bat input.md output.docx

# Linux/Mac
./scripts/convert_doc.sh input.md output.docx
```

#### 直接使用Pandoc
```bash
pandoc input.md \
    --reference-doc=templates/公文模板.docx \
    --variable CJKmainfont="方正小标宋简体" \
    -o output.docx
```

### 3. 测试转换
```bash
# 使用示例文件测试
scripts\convert_doc.bat examples/示例文档.md output/测试输出.docx
```

## 📁 目录结构

```
pandoc/
├── 📄 README.md                    # 本说明文件
├── 📁 scripts/                     # 脚本目录
│   ├── convert_doc.bat            # Windows主转换脚本
│   ├── convert_doc.sh             # Linux/Mac主转换脚本
│   └── install_typora_config.bat # Typora一键配置
├── 📁 docs/                        # 文档目录
│   ├── README.md                  # 主要使用指南
│   ├── Pandoc命令指南.md           # Pandoc详细说明
│   ├── Typora详细配置教程.md       # Typora配置教程
│   ├── INDEX.md                   # 文档索引
│   └── ...                        # 其他文档
├── 📁 templates/                   # 模板目录
│   ├── 公文模板.docx               # 公文格式模板
│   ├── reference.docx              # Pandoc参考文档
│   └── README.md                  # 模板说明
├── 📁 fonts/                       # 字体目录
│   └── README.md                  # 字体要求说明
├── 📁 typora-config/               # Typora配置
│   ├── typora-config.json         # Typora配置文件
│   ├── typora-theme/              # Typora主题
│   └── README.md                  # 配置说明
├── 📁 examples/                    # 示例文件
│   └── 示例文档.md                # 示例文档
└── 📁 output/                      # 输出目录
    └── ...                        # 转换输出文件
```

## 🔧 编辑器集成

### Typora用户 🎨

#### 一键配置（推荐）
```bash
# 运行自动配置脚本
scripts\install_typora_config.bat
```

#### 手动配置
1. 参考 [Typora详细配置教程.md](docs/Typora详细配置教程.md)
2. 安装公文格式主题
3. 配置导出快捷键 `Ctrl+Shift+D`

#### 快速开始
1. 在Typora中创建新文档
2. 选择主题 "official-document"
3. 编写Markdown内容
4. 按 `Ctrl+Shift+D` 导出Word

### Obsidian用户 🔍

参考 [Obsidian导出配置.md](docs/Obsidian导出配置.md)

#### 配置步骤
1. 安装QuickAdd插件
2. 配置自定义命令
3. 设置导出快捷键

## 📖 详细文档

| 文档 | 描述 | 适合用户 |
|------|------|----------|
| [docs/README.md](docs/README.md) | **主要使用指南** | 所有用户 |
| [docs/Pandoc命令指南.md](docs/Pandoc命令指南.md) | Pandoc命令详细说明 | 技术用户 |
| [docs/Typora详细配置教程.md](docs/Typora详细配置教程.md) | Typora配置教程 | Typora用户 |
| [docs/Obsidian导出配置.md](docs/Obsidian导出配置.md) | Obsidian配置指南 | Obsidian用户 |
| [fonts/README.md](fonts/README.md) | 字体要求说明 | 所有用户 |
| [templates/README.md](templates/README.md) | 模板使用说明 | 高级用户 |
| [scripts/README.md](scripts/README.md) | 脚本使用说明 | 技术用户 |

## 🧪 示例文档

查看 [examples/示例文档.md](examples/示例文档.md) 了解正确的Markdown格式：

```markdown
# 关于召开2024年度工作会议的通知

## 一、会议背景

为全面总结2023年工作成果。

## 二、会议安排

### （一）时间地点
- 时间：2024年1月15日
- 地点：公司总部

### （二）参会人员
1. 公司领导班子
2. 各部门负责人

## 三、会议议程

### （一）工作总结

#### 1. 上午议程
签到入场

#### 2. 下午议程
分组讨论

## 四、工作要求

各部门需按时完成相关工作。
```

## ⚠️ 故障排除

### 常见问题

**Q: 转换后标题显示为黑体而非方正小标宋？**
A: 检查是否添加了 `--variable CJKmainfont="方正小标宋简体"` 参数

**Q: 字体显示不正确？**
A: 参考 [fonts/README.md](fonts/README.md) 检查字体安装

**Q: 找不到pandoc命令？**
A: 重新安装pandoc并确保添加到系统PATH

**Q: Typora配置失败？**
A: 运行 `scripts\install_typora_config.bat` 一键配置

### 调试模式
```bash
# 查看详细转换过程
pandoc input.md --reference-doc=templates/公文模板.docx -o output.docx --verbose
```

## 🔄 更新日志

### v2.0 (2024-01-21)
- ✅ 统一标题映射规则
- ✅ 重组目录结构
- ✅ 完善文档体系
- ✅ 添加一键配置脚本

### v1.0
- ✅ 基础转换功能
- ✅ Typora集成
- ✅ Obsidian集成

## 📞 技术支持

如遇到问题，请提供：
1. 错误信息截图
2. 输入的Markdown文件
3. 使用的命令和参数
4. 操作系统版本

## 📄 许可证

本项目遵循 MIT 许可证，可自由使用和修改。

---

**🎉 开始使用公文格式转换工具，让您的文档更专业！**