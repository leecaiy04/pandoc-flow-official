# Typora 公文格式配置详细教程

## 📋 准备工作

### 1. 安装必要软件
- **Typora**：从 https://typora.io 下载安装
- **Pandoc**：从 https://pandoc.org/installing.html 下载安装
- **字体**：确保安装了方正小标宋简体字体

### 2. 验证安装
打开命令行，输入：
```bash
pandoc --version
```
应显示pandoc版本信息。

## 🔧 方法一：使用自动配置脚本（推荐）

这是最简单、最可靠的方法，脚本会自动处理路径和配置。

1. **运行脚本**：
   - 打开项目文件夹中的 `scripts` 目录。
   - 双击运行 `install_typora_config.bat`。
2. **检查输出**：
   - 脚本会检查 Typora、Pandoc 和字体安装情况。
   - 脚本会自动为您配置自定义导出格式 "公文格式Word"。
3. **完成配置**：
   - 重启 Typora。
   - 现在您可以在 **文件** -> **导出** 中看到 "公文格式Word"，或者直接按 `Ctrl+Shift+D` 使用。

## 🔧 方法二：手动配置导出功能

如果您想手动配置，请按照以下步骤操作：

### 步骤1：打开偏好设置

1. 打开Typora
2. 点击菜单栏 **文件** → **偏好设置**（或按 `Ctrl+,`）
3. 在左侧菜单中选择 **导出**

### 步骤2：配置自定义导出

1. 在 **导出** 页面，找到 **自定义导出** 部分
2. 点击 **添加自定义导出格式**

### 步骤3：填写配置信息

#### 推荐方案（使用脚本）
```
格式名称：公文格式 Word
命令：{项目根目录}\scripts\convert_doc.bat
参数："${currentFilePath}" "${currentFilePath}.docx"
工作目录：{项目根目录}
```

#### 进阶方案（直接使用 Pandoc）
```
格式名称：公文格式 Word (Pandoc)
命令：pandoc
参数：-d "{项目根目录}\templates\pandoc-defaults.yaml" "${currentFilePath}" -o "${currentFilePath}.docx"
工作目录：{项目根目录}
```

> [!IMPORTANT]
> 请务必将 `{项目根目录}` 替换为您本地克隆该仓库的实际绝对路径（例如 `C:\Users\Admin\pandoc-flow`）。

## 🔧 方法三：使用Typora主题文件

### 创建自定义主题

1. 在Typora中打开 **偏好设置**
2. 选择 **外观** → **打开主题文件夹**
3. 创建新文件夹 `official-document`
4. 在文件夹中创建 `official.css` 文件

### CSS样式内容

```css
/* 公文格式样式 - official.css */

/* 文档标题 (对应 # ) */
h1 {
    font-family: "方正小标宋简体", "FZXiaoZhongSongS-R-GB", "Microsoft YaHei", sans-serif;
    font-size: 22pt;
    font-weight: bold;
    text-align: center;
    margin: 24pt 0;
    line-height: 1.2;
}

/* 一级标题 (对应 ## ) */
h2 {
    font-family: "黑体", "SimHei", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    font-weight: bold;
    text-align: left;
    margin: 16pt 0 12pt 0;
    line-height: 1.5;
}

/* 二级标题 (对应 ### ) */
h3 {
    font-family: "楷体_GB2312", "KaiTi", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    font-weight: bold;
    text-align: left;
    margin: 14pt 0 10pt 0;
    line-height: 1.5;
}

/* 三级标题 (对应 #### ) */
h4 {
    font-family: "仿宋_GB2312", "FangSong", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    font-weight: bold;
    text-align: left;
    margin: 12pt 0 8pt 0;
    line-height: 1.5;
}

/* 四级标题 (对应 ##### ) */
h5 {
    font-family: "仿宋_GB2312", "FangSong", "Microsoft YaHei", sans-serif;
    font-size: 14pt;
    font-weight: bold;
    text-align: left;
    margin: 12pt 0 8pt 0;
    line-height: 1.5;
}

/* 正文 */
p {
    font-family: "仿宋_GB2312", "FangSong", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    line-height: 1.5;
    text-indent: 2em;
    margin: 8pt 0;
}

/* 列表 */
ul, ol {
    font-family: "仿宋_GB2312", "FangSong", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    line-height: 1.5;
    margin-left: 2em;
}

li {
    margin: 4pt 0;
}

/* 表格 */
table {
    font-family: "仿宋_GB2312", "FangSong", "Microsoft YaHei", sans-serif;
    font-size: 16pt;
    border-collapse: collapse;
    margin: 12pt 0;
}

th, td {
    border: 1px solid #000;
    padding: 8pt;
    text-align: center;
}

th {
    font-weight: bold;
    background-color: #f0f0f0;
}

/* 代码 */
code {
    font-family: "Consolas", "Courier New", monospace;
    background-color: #f5f5f5;
    padding: 2px 4px;
    border-radius: 3px;
}

pre {
    font-family: "Consolas", "Courier New", monospace;
    background-color: #f5f5f5;
    padding: 12pt;
    border-radius: 5px;
    overflow-x: auto;
}

/* 引用 */
blockquote {
    border-left: 4px solid #ccc;
    margin-left: 0;
    padding-left: 16pt;
    color: #666;
    font-style: italic;
}

/* 链接 */
a {
    color: #0066cc;
    text-decoration: underline;
}

a:hover {
    color: #004499;
}

/* 页面设置 */
@media print {
    @page {
        margin: 3.7cm 2.6cm 3.5cm 2.8cm;
        size: A4;
    }
    
    /* 打印时优化 */
    body {
        font-size: 16pt;
        line-height: 1.5;
    }
}
```

### 主题配置文件
在 `official-document` 文件夹中创建 `theme.css`：

```css
@import "official.css";

/* 主题元数据 */
:root {
    --side-bar-bg-color: #fafafa;
    --window-border: 1px solid #eee;
}
```

## 🔧 方法三：使用Typora插件

### 安装方法

1. 下载Typora插件包
2. 在Typora中 **偏好设置** → **通用** → **打开高级设置**
3. 在 `conf.user.json` 中添加插件配置

### 插件配置示例

```json
{
  "defaultFontFamily": "仿宋_GB2312",
  "fontSize": 16,
  "lineHeight": 1.5,
  "customExport": {
    "official-doc": {
      "name": "公文格式Word",
      "command": "C:\\path\\to\\project\\scripts\\convert_doc.bat",
      "args": ["${currentFilePath}", "${currentFilePath}.docx"],
      "workingDir": "C:\\path\\to\\project"
    }
  }
}
```

## 📝 使用方法

### 方法一：导出菜单
1. 在Typora中编写Markdown文档
2. 点击 **文件** → **导出** → **公文格式Word**
3. 选择保存位置
4. 等待转换完成

### 方法二：快捷键
1. 按设置的快捷键（如 `Ctrl+Shift+D`）
2. 自动生成Word文档

### 方法三：预览然后导出
1. 在Typora中切换到预览模式
2. 应用自定义主题
3. 点击导出按钮

## 📋 验证配置

### 测试文档内容
```markdown
# 关于召开2024年度工作会议的通知

## 一、会议背景

为全面总结2023年工作成果，部署2024年重点任务。

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

### 验证步骤
1. 在Typora中创建测试文档
2. 使用配置的导出功能
3. 检查生成的Word文档：
   - ✅ 标题为方正小标宋简体
   - ✅ 一级标题为黑体
   - ✅ 二级标题为楷体
   - ✅ 正文为仿宋
   - ✅ 正确的字号和对齐

## 🚨 常见问题及解决

### 问题1：找不到pandoc命令
**症状：** 导出时报错 "pandoc not found"

**解决：**
1. 重新安装pandoc
2. 确保添加到系统PATH
3. 重启Typora

### 问题2：字体显示不正确
**症状：** 标题显示为宋体而非指定字体

**解决：**
1. 检查字体是否安装
2. 在Word模板中设置样式
3. 使用正确的pandoc参数

### 问题3：导出失败
**症状：** 点击导出无反应

**解决：**
1. 检查脚本路径是否正确
2. 确认工作目录设置
3. 查看Typora控制台错误信息

### 问题4：中文乱码
**症状：** 导出后中文显示为乱码

**解决：**
1. 确保Markdown文件为UTF-8编码
2. 检查pandoc编码设置
3. 使用正确的字体参数

## 📱 移动端配置

### Typora移动版
移动版Typora不支持自定义导出，需要：
1. 在桌面端完成导出
2. 或使用在线pandoc服务
3. 或同步文件到桌面端处理

## 🔄 定期维护

### 更新配置
1. 定期检查字体安装状态
2. 更新pandoc到最新版本
3. 备份配置文件

### 测试验证
每月进行一次完整的导出测试，确保功能正常。