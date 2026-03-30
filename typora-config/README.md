# Typora配置目录说明

## 📝 配置文件列表

### 🔧 配置文件
| 文件名 | 描述 | 用途 |
|--------|------|------|
| `typora-config.json` | Typora主配置文件 | 包含导出设置和主题配置 |
| `install_typora_config.bat` | **一键安装脚本** | 自动安装Typora配置 |

### 🎨 主题文件
| 文件名 | 描述 | 用途 |
|--------|------|------|
| `typora-theme/` | 主题文件夹 | 包含公文格式主题 |

## 🎯 使用方法

### 一键安装（推荐）
```bash
# 运行自动配置脚本
scripts\install_typora_config.bat
```

### 手动配置
1. **复制主题文件**:
   ```bash
   cp -r typora-config/typora-theme/official-document %APPDATA%/Typora/themes/
   ```

2. **导入配置**:
   ```bash
   cp typora-config/typora-config.json %APPDATA%/Typora/conf.user.json
   ```

## 📁 目录结构

```
typora-config/
├── typora-config.json          # 主配置文件
├── typora-theme/               # 主题文件夹
│   └── official-document/      # 公文格式主题
│       ├── official.css        # 主样式文件
│       ├── theme.css           # 主题元数据
│       └── README.md           # 主题说明
└── README.md                   # 本说明文档
```

## ⚙️ 配置说明

### typora-config.json
**主要配置项**:
- `defaultFontFamily`: 默认字体（仿宋_GB2312）
- `theme`: 主题名称（official-document）
- `customExport`: 自定义导出设置
- `editor`: 编辑器设置
- `preview`: 预览设置

### 自定义导出
配置文件中默认定义了一个导出选项：
1. **公文格式Word**: 使用 `convert_doc.bat` 脚本

如需手动改为直接调用 `pandoc`，请确保同时传入：
`-d "{项目根目录}\templates\pandoc-defaults.yaml" --reference-doc "{项目根目录}\templates\official-template.docx"`

## 🎨 主题详情

### official-document主题
**特性**:
- 符合公文标准的字体设置
- 正确的标题映射
- 打印优化
- 深色模式支持

**样式对应**:
- `h1` → 文档标题 (#)
- `h2` → 一级标题 (##)
- `h3` → 二级标题 (###)
- `h4` → 三级标题 (####)
- `p` → 正文

## 🔧 配置步骤

### 1. 安装主题
```bash
# 复制主题到Typora目录
cp -r typora-config/typora-theme/official-document "${APPDATA}/Typora/themes/"
```

### 2. 应用主题
1. 打开Typora
2. 点击"主题" → "official-document"
3. 重启Typora生效

### 3. 配置导出
1. 复制配置文件
2. 重启Typora
3. 使用快捷键 `Ctrl+Shift+D` 导出

## 🚨 故障排除

### 主题不生效
**原因**: 主题路径错误
**解决**: 检查 `%APPDATA%/Typora/themes/` 目录

### 导出失败
**原因**: 脚本路径错误
**解决**: 检查配置中的工作目录路径

### 字体显示错误
**原因**: 字体未安装
**解决**: 参考 `../fonts/README.md`

## 🔄 配置维护

### 备份配置
```bash
# 备份现有配置
cp %APPDATA%/Typora/conf.user.json conf.user.json.backup
```

### 更新配置
1. 修改配置文件
2. 重启Typora
3. 测试功能

## 📞 技术支持

如遇到配置问题：
1. 检查文件权限
2. 验证路径正确性
3. 查看Typora日志
4. 重新安装配置

---

**注意**: 配置修改后需要重启Typora才能生效。
