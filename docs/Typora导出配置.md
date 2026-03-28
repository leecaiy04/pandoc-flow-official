# Typora 公文格式导出配置

## 方法一：使用自定义导出命令

### 1. 安装 Pandoc
确保系统已安装 pandoc：
- Windows: `choco install pandoc` 或从 https://pandoc.org/installing.html 下载
- macOS: `brew install pandoc`

### 2. 配置 Typora 自定义导出

#### 步骤 1: 打开偏好设置
1. 在 Typora 中点击 **文件** → **偏好设置** (或按 `Ctrl+,`)
2. 或点击菜单栏的 **Typora** → **偏好设置**

#### 步骤 2: 配置导出
1. 选择 **导出** 标签页
2. 在 **自定义导出** 部分，点击 **添加自定义导出格式**

#### 步骤 3: 填写配置信息

**格式名称：** `公文格式 Word`
**命令：**
```
convert_doc.bat
```
**参数：**
```
"${currentFilePath}" "${currentFilePath}.docx"
```
**工作目录：**
```
D:\Code\Template\pandoc
```

**说明：** 标题映射：#→文档标题，##→一级标题，###→二级标题，####→三级标题

#### 步骤 4: 设置快捷键
1. 在 **快捷键** 标签页中找到新添加的导出命令
2. 设置喜欢的快捷键，如 `Ctrl+Shift+D`

## 方法二：使用 Pandoc 插件

### 1. 安装 Pandoc 插件
Typora 原生支持 Pandoc，只需确保 Pandoc 已安装并添加到系统 PATH。

### 2. 配置 Pandoc 导出

#### 创建自定义模板文件
在 `D:\Code\Template\pandoc\` 目录下创建 `typora-custom.lua`：

```lua
function Header (header)
  local level = header.level
  
  if level == 1 then
    -- 公文标题
    return pandoc.Div(
      pandoc.Para{pandoc.Strong(header.content)},
      pandoc.Attr("", {"official-title"}, {})
    )
  elseif level == 2 then
    -- 一级标题
    return pandoc.Div(
      pandoc.Para(header.content),
      pandoc.Attr("", {"level-1-heading"}, {})
    )
  elseif level == 3 then
    -- 二级标题
    return pandoc.Div(
      pandoc.Para(header.content),
      pandoc.Attr("", {"level-2-heading"}, {})
    )
  elseif level == 4 then
    -- 三级标题
    return pandoc.Div(
      pandoc.Para(header.content),
      pandoc.Attr("", {"level-3-heading"}, {})
    )
  end
  
  return header
end
```

### 3. 修改导出命令

在 Typora 的自定义导出配置中使用：
```
pandoc "${currentFilePath}" --lua-filter=typora-custom.lua --reference-doc=公文模板.docx -o "${currentFilePath}.docx"
```

## 使用方法

### Markdown 文档格式规范

在 Typora 中按照以下格式编写文档：

```markdown
# 这是文档标题（方正小标宋简体二号，居中）

## 这是一级标题（黑体三号，左对齐）

### 这是二级标题（楷体三号，左对齐）

#### 这是三级标题（仿宋三号，左对齐）

这是正文内容（仿宋三号，首行缩进2字符）。

正文段落之间的空行会被保留。

**加粗文本** 和 *斜体文本* 会保持原有格式。

- 无序列表项目
- 无序列表项目

1. 有序列表项目
2. 有序列表项目

| 表格 | 示例 |
|------|------|
| 单元格1 | 单元格2 |
```

### 标题级别对应关系

| Markdown | Word样式 | 字体 | 说明 |
|----------|----------|------|------|
| `# 标题` | 文档标题 | 方正小标宋简体二号 | 公文正式标题 |
| `## 标题` | 一级标题 | 黑体三号 | 主要章节 |
| `### 标题` | 二级标题 | 楷体三号 | 次级章节 |
| `#### 标题` | 三级标题 | 仿宋三号 | 三级章节 |

### 导出步骤

1. 在 Typora 中编写 Markdown 文档
2. 点击 **文件** → **导出** → **公文格式 Word**
3. 或使用设置的快捷键
4. 在当前目录下会生成对应的 `.docx` 文件

## 高级配置

### 批量导出脚本

创建批量处理脚本 `batch_convert.bat`：

```batch
@echo off
chcp 65001 >nul

for %%f in (*.md) do (
    echo 正在处理: %%f
    pandoc "%%f" --reference-doc="公文模板.docx" -o "%%~nf.docx"
    echo 完成生成: %%~nf.docx
)

echo 批量转换完成
pause
```

### 自动监听文件夹变化

使用 Python 监听文件夹并自动转换：

```python
# auto_convert.py
import os
import time
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

class DocConvertHandler(FileSystemEventHandler):
    def on_modified(self, event):
        if event.src_path.endswith('.md'):
            os.system(f'convert_doc.bat "{event.src_path}" "{event.src_path}.docx"')
            print(f"已转换: {event.src_path}")

if __name__ == "__main__":
    path = "."  # 监听当前目录
    event_handler = DocConvertHandler()
    observer = Observer()
    observer.schedule(event_handler, path, recursive=False)
    observer.start()
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
```

## 故障排除

### 常见问题及解决方案

1. **"pandoc 不是内部或外部命令"**
   - 重新安装 pandoc 并确保添加到系统 PATH
   - 重启 Typora

2. **"找不到模板文件"**
   - 检查 `公文模板.docx` 是否在 `D:\Code\Template\pandoc\` 目录
   - 检查文件路径是否正确

3. **导出后中文乱码**
   - 确保 Markdown 文件使用 UTF-8 编码
   - 在 Typora 设置中确认编码格式

4. **样式不正确**
   - 检查模板文件中的样式定义
   - 确认标题级别映射正确

### 验证配置

1. 创建测试文件 `test.md`
2. 导出为 Word 文档
3. 检查生成的 `test.docx` 文件格式是否正确

### 备份重要文件
在进行配置更改前，建议备份：
- 原始的 `公文模板.docx`
- 重要的 Markdown 文档