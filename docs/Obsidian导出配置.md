# Obsidian 公文格式导出配置

## 方法一：使用自定义命令

### 1. 安装 Pandoc
确保系统已安装 pandoc：
- Windows: `choco install pandoc` 或从官网下载
- macOS: `brew install pandoc`

### 2. 配置 Obsidian 自定义命令

在 Obsidian 设置中：

1. 打开 **设置** → **命令**
2. 点击 **添加新命令**
3. 配置如下：

**命令名称：** `导出为公文格式`
**命令类型：** `Shell command`
**命令：**
```
cd /d "D:\Code\Template\pandoc" && convert_doc.bat "{{filepath}}" "{{filepath}}.docx"
```

**快捷键（可选）：** `Ctrl+Shift+E`

**说明：** 标题映射：#→文档标题，##→一级标题，###→二级标题，####→三级标题

## 方法二：使用 QuickAdd 插件

### 1. 安装 QuickAdd 插件
1. 在 Obsidian 中安装 QuickAdd 插件
2. 启用插件

### 2. 配置 QuickAdd

1. 打开 QuickAdd 设置
2. 选择 **Macro**
3. 添加新的 Macro，命名为 "导出公文格式"
4. 添加以下步骤：
   - **User Script**: 运行转换脚本
   - 或者使用 **Shell Command**: 调用 pandoc

### 3. 脚本内容
```javascript
module.exports = async (params) => {
    const { app, quickAddApi } = params;
    const activeFile = app.workspace.getActiveFile();
    const filePath = activeFile.path;
    
    const result = await quickAddApi.utility.systemShell([
        "convert_doc.bat", 
        filePath, 
        filePath.replace('.md', '.docx')
    ]);
    
    new Notice("导出成功: " + result);
};
```

## 使用方法

### Markdown 文档格式规范

```markdown
# 这是文档标题（方正小标宋简体二号，居中）
## 这是一级标题（黑体三号，左对齐）
### 这是二级标题（楷体三号，左对齐）
#### 这是三级标题（仿宋三号，左对齐）

这是正文内容（仿宋三号，首行缩进2字符）。

- 列表项目
- 列表项目

1. 有序列表
2. 有序列表
```

### 标题级别对应关系

| Markdown | Word样式 | 字体 | 说明 |
|----------|----------|------|------|
| `# 标题` | 文档标题 | 方正小标宋简体二号 | 公文正式标题 |
| `## 标题` | 一级标题 | 黑体三号 | 主要章节 |
| `### 标题` | 二级标题 | 楷体三号 | 次级章节 |
| `#### 标题` | 三级标题 | 仿宋三号 | 三级章节 |

### 导出步骤

1. 在 Obsidian 中编写 Markdown 文档
2. 使用配置的快捷键或命令
3. 系统会自动调用 pandoc 和公文模板
4. 在相同目录下生成对应的 `.docx` 文件

## 注意事项

1. 确保脚本路径正确：`D:\Code\Template\pandoc\convert_doc.bat`
2. 确保模板文件 `official-template.docx` 存在
3. 生成的文件名会在原文件名后添加 `.docx` 扩展名
4. 如果遇到中文编码问题，请确保使用 UTF-8 编码

## 故障排除

### 常见错误
1. **pandoc not found**: 需要安装 pandoc 并添加到 PATH
2. **模板文件不存在**: 检查 `official-template.docx` 是否在正确位置
3. **权限错误**: 确保有写入目录的权限

### 验证安装
在命令行中运行：
```bash
pandoc --version
```
应显示 pandoc 版本信息。
