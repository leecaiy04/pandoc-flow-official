# Pandoc 命令使用指南

## 正确的转换命令格式

### 基础命令（确保字体正确应用）
```bash
# Windows
pandoc "input.md" --reference-doc="official-template.docx" --metadata title="公文文档" --variable CJKmainfont="方正小标宋简体" -o "output.docx"

# Linux/Mac
pandoc "input.md" --reference-doc="official-template.docx" --metadata title="公文文档" --variable CJKmainfont="方正小标宋简体" -o "output.docx"
```

### 推荐使用的完整命令
```bash
pandoc "input.md" \
    --reference-doc="official-template.docx" \
    --metadata title="公文文档" \
    --variable CJKmainfont="方正小标宋简体" \
    --variable mainfont="方正小标宋简体" \
    --variable fontsize=22pt \
    --highlight-style=pygments \
    --from=markdown \
    --to=docx \
    --output="output.docx"
```

### 推荐的稳定写法（适用于任意工作目录）
```bash
pandoc "input.md" \
    -d "templates/pandoc-defaults.yaml" \
    --reference-doc="templates/official-template.docx" \
    -o "output.docx"
```

> `pandoc-defaults.yaml` 只负责通用参数；`reference-doc` 建议始终显式传入，避免当前工作目录变化时模板未应用。

## 关键参数说明

### 必要参数
- `--reference-doc="official-template.docx"` - 指定公文模板文件
- `--metadata title="公文文档"` - 设置文档标题元数据
- `--variable CJKmainfont="方正小标宋简体"` - 设置中文字体

### 推荐参数
- `--variable mainfont="方正小标宋简体"` - 设置主要字体
- `--variable fontsize=22pt` - 设置标题字号
- `--highlight-style=pygments` - 代码高亮样式
- `--from=markdown` - 明确输入格式
- `--to=docx` - 明确输出格式

## 常见错误及解决方案

### 问题1：标题显示为黑体而非方正小标宋
**原因：** 缺少字体变量参数
**解决：** 必须添加 `--variable CJKmainfont="方正小标宋简体"`

### 问题2：字体不生效
**原因：** 
1. 系统未安装方正小标宋简体字体
2. 模板文件中的样式未正确设置

**解决：**
1. 安装字体到系统
2. 在Word中手动修改模板的标题1样式

### 问题3：生成的文档格式混乱
**原因：** 模板文件损坏或样式设置错误
**解决：** 重新创建模板文件并正确设置样式

### 问题4：本地命令正常，打包后字体格式不对
**原因：**
1. 仅使用 `-d pandoc-defaults.yaml`，但没有显式传入 `--reference-doc`
2. 打包后资源目录与项目工作目录不同，不能依赖相对路径碰巧生效

**解决：**
1. 始终使用 `-d "templates/pandoc-defaults.yaml" --reference-doc="templates/official-template.docx"`
2. Tauri 图形界面固定使用内置资源，不再允许只替换其中一半模板参数

## 转换脚本使用

### 使用批处理脚本（推荐）
```bash
# Windows
convert_doc.bat input.md output.docx

# 脚本已包含正确的字体参数
```

### 手动执行pandoc
如果手动执行pandoc，请确保使用正确的参数格式：

```bash
# ❌ 错误示例（模板可能未完整生效）
pandoc input.md -d templates/pandoc-defaults.yaml -o output.docx

# ✅ 正确示例（模板和字体稳定生效）
pandoc input.md -d templates/pandoc-defaults.yaml --reference-doc=templates/official-template.docx -o output.docx
```

## 测试验证

### 创建测试文档
```markdown
# 测试文档标题
## 一级标题测试
### 二级标题测试
#### 三级标题测试

这是正文内容，应该显示为仿宋字体。
```

### 验证步骤
1. 使用正确命令转换
2. 在Word中检查标题1样式是否为方正小标宋简体
3. 检查标题2样式是否为黑体
4. 检查正文样式是否为仿宋

## 最佳实践

1. **始终使用完整的字体参数**
2. **在Word模板中预设正确的样式**
3. **使用转换脚本而非手动pandoc命令**
4. **定期验证转换效果**

## 故障排除流程

1. 检查字体是否安装
2. 验证命令参数是否完整
3. 检查模板文件样式设置
4. 测试转换结果
5. 如有问题，优先检查Word模板
