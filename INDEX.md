# 📂 项目总览索引

## 🎯 快速导航

### 🔥 核心功能
- 📖 [主要使用指南](README.md)
- 🚀 [快速开始](README.md#-快速开始)
- 🔧 [脚本使用](scripts/README.md)
- 📄 [模板说明](templates/README.md)

### 📚 完整文档
- 📋 [文档索引](docs/INDEX.md)
- 🎨 [Typora配置](docs/Typora详细配置教程.md)
- 🔍 [Obsidian配置](docs/Obsidian导出配置.md)
- 📖 [Pandoc指南](docs/Pandoc命令指南.md)

### 🛠️ 技术资料
- 🎭 [字体要求](fonts/README.md)
- 🎨 [Typora配置文件](typora-config/README.md)
- 📝 [示例文档](examples/示例文档.md)

## 📁 目录结构图

```
pandoc/
├── 🏠 README.md                    # 🏛️ 主要使用指南
├── 📂 scripts/                     # 🔧 脚本工具
│   ├── convert_doc.bat            # Windows转换脚本 ⭐
│   ├── convert_doc.sh             # Linux/Mac转换脚本 ⭐
│   ├── install_typora_config.bat # Typora一键配置 ⭐
│   └── README.md                  # 脚本使用说明
├── 📂 docs/                        # 📚 文档库
│   ├── README.md                  # 主要使用指南 ⭐
│   ├── Pandoc命令指南.md           # Pandoc详细说明
│   ├── Typora详细配置教程.md       # Typora完整教程 ⭐
│   ├── Typora导出配置.md           # Typora快速配置
│   ├── Obsidian导出配置.md         # Obsidian配置
│   ├── 公文字体规范.md             # 字体规范 ⭐
│   ├── 更新标题映射.md             # 标题映射规则
│   ├── INDEX.md                   # 文档索引
│   └── 公文格式GB_T_9704—2012.pdf # 国家标准
├── 📂 templates/                   # 📄 模板库
│   ├── 公文模板.docx               # 主要模板 ⭐
│   ├── reference.docx              # 参考文档
│   └── README.md                  # 模板说明
├── 📂 fonts/                       # 🎭 字体库
│   └── README.md                  # 字体要求 ⭐
├── 📂 typora-config/               # 🎨 Typora配置
│   ├── typora-config.json         # 配置文件
│   ├── typora-theme/              # 主题文件夹
│   │   └── official-document/     # 公文格式主题
│   └── README.md                  # 配置说明
├── 📂 examples/                    # 📝 示例库
│   └── 示例文档.md                # 示例文档 ⭐
└── 📂 output/                      # 📤 输出目录
    └── (转换输出文件)
```

## 🎯 用户路径

### 🔰 新手用户 (推荐路径)
```
🏠 README.md → 📖 docs/README.md → 🎨 docs/Typora详细配置教程.md → 🎭 fonts/README.md
```

### 📝 Typora专用路径
```
🎨 docs/Typora详细配置教程.md → 🚀 scripts/install_typora_config.bat → 🏠 README.md
```

### 🔍 Obsidian专用路径
```
🔍 docs/Obsidian导出配置.md → 🚀 scripts/README.md → 🏠 README.md
```

### ⚙️ 高级用户路径
```
🚀 scripts/README.md → 📖 docs/Pandoc命令指南.md → 📄 templates/README.md
```

## 🔍 快速查找

### 按问题类型
| 问题类型 | 解决方案文档 |
|----------|-------------|
| 🚫 **转换失败** | 📖 docs/Pandoc命令指南.md |
| 🎭 **字体错误** | 🎭 fonts/README.md |
| 🎨 **Typora配置** | 🎨 docs/Typora详细配置教程.md |
| 🔍 **Obsidian配置** | 🔍 docs/Obsidian导出配置.md |
| 📄 **模板问题** | 📄 templates/README.md |
| 🚀 **脚本问题** | 🚀 scripts/README.md |

### 按需求类型
| 需求 | 推荐文档 |
|------|----------|
| 🔰 **快速上手** | 🏠 README.md |
| 🎨 **Typora用户** | 🎨 docs/Typora详细配置教程.md |
| 🔍 **Obsidian用户** | 🔍 docs/Obsidian导出配置.md |
| ⚙️ **技术用户** | 🚀 scripts/README.md |
| 📖 **完整了解** | 📚 docs/INDEX.md |

## 📊 文档重要度评级

### ⭐⭐⭐⭐⭐ 必读
- 🏠 [README.md](README.md) - 主要指南
- 🎨 [docs/Typora详细配置教程.md](docs/Typora详细配置教程.md) - Typora教程
- 🎭 [fonts/README.md](fonts/README.md) - 字体要求
- 🚀 [scripts/install_typora_config.bat](scripts/install_typora_config.bat) - 一键配置

### ⭐⭐⭐⭐ 推荐
- 📖 [docs/README.md](docs/README.md) - 使用指南
- 🚀 [scripts/README.md](scripts/README.md) - 脚本说明
- 📖 [docs/Pandoc命令指南.md](docs/Pandoc命令指南.md) - Pandoc指南
- 📄 [templates/README.md](templates/README.md) - 模板说明

### ⭐⭐⭐ 可选
- 🔍 [docs/Obsidian导出配置.md](docs/Obsidian导出配置.md) - Obsidian配置
- 🎨 [docs/Typora导出配置.md](docs/Typora导出配置.md) - Typora快速配置
- 🎨 [typora-config/README.md](typora-config/README.md) - Typora配置详情
- 📝 [examples/示例文档.md](examples/示例文档.md) - 示例文档

### ⭐⭐ 参考
- 📋 [docs/更新标题映射.md](docs/更新标题映射.md) - 标题映射
- 📋 [docs/公文字体规范.md](docs/公文字体规范.md) - 详细字体规范

## 🔄 文档更新状态

### 最新更新 (2024-01-21)
- ✅ 重组目录结构
- ✅ 完善文档体系
- ✅ 添加一键配置脚本
- ✅ 统一标题映射规则

### 稳定文档
- 🏠 README.md - 随项目更新
- 🎭 fonts/README.md - 字体要求稳定
- 📄 templates/README.md - 模板规范稳定

### 频繁更新
- 🎨 docs/Typora详细配置教程.md - 随Typora版本更新
- 📖 docs/Pandoc命令指南.md - 随功能更新
- 🚀 scripts/README.md - 随脚本更新

## 📞 获取帮助

### 🚨 紧急问题
1. 查看相应文档的"故障排除"部分
2. 检查 [docs/Pandoc命令指南.md](docs/Pandoc命令指南.md)
3. 尝试重新配置

### 📝 反馈问题
- 描述问题现象
- 提供错误信息
- 说明操作系统和软件版本
- 列出使用的命令

### 💡 功能建议
欢迎提出改进建议和功能需求！

---

**💡 提示**: 建议收藏本页面作为项目导航中心，快速定位所需文档。