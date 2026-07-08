# Repository Guidelines

## 项目结构与模块组织
`src/` 存放 Tauri 前端界面，主要是 `index.html`、`main.js`、`styles.css`。`src-tauri/` 是 Rust 后端，`src/conversion.rs` 负责 Pandoc 调用与命令拼装，`src/events.rs` 处理事件模型。`scripts/` 提供命令行与编辑器集成脚本，`templates/`、`fonts/` 是转换所依赖的模板和字体资源，`docs/` 与 `examples/` 分别放说明文档和示例输入，`output/` 用于默认导出结果。

## 构建、测试与开发命令
先运行 `npm install` 安装前端开发依赖。使用 `npm run tauri dev` 启动桌面端调试，`npm run tauri build` 构建安装包。Rust 单元测试可用 `cargo test --manifest-path src-tauri/Cargo.toml` 运行。脚本链路验证建议执行 `scripts\convert_doc.bat examples\示例文档.md output\测试输出.docx`，确认 Pandoc、模板和输出目录均正常。

## 代码风格与命名约定
前端保持现有简单原生结构，不引入额外框架；修改 `src/` 时沿用现有文件职责划分，避免把 UI、状态和平台调用混在一起。Rust 代码遵循默认 `rustfmt` 风格，批处理与 Shell 脚本继续使用清晰的动词式文件名，例如 `convert_doc.bat`、`install_typora_config.bat`。新增资源文件时，名称应直观反映用途。

## 测试指南
当前没有独立 `tests/` 目录，核心自动化测试主要位于 `src-tauri/src/conversion.rs`。涉及 Pandoc 命令拼装、资源路径或模板解析的改动，至少运行一次 `cargo test`。涉及脚本、模板、字体或打包资源的改动，还应做一次手工转换验证，并优先使用 `examples/示例文档.md` 复现。

## 提交与 Pull Request 规范
提交信息保持简短、聚焦单一变更。仓库历史同时存在中文摘要和约定式前缀，建议优先使用 `fix:`、`chore:`、`docs:` 开头，例如 `fix: stabilize bundled template resolution`，或使用等价的简短中文说明。PR 需说明改动范围、验证方式和影响模块；若涉及界面、打包或导出效果，请附截图或输出结果说明。

## 资源与配置提示
不要随意重命名 `templates/official-template.docx` 或 `templates/pandoc-defaults.yaml`；若必须调整，同步更新 `src-tauri/tauri.conf.json`、`src-tauri/src/conversion.rs` 以及相关脚本。提交前确认系统已安装 Pandoc，且文档中引用的命令仍与仓库当前目录结构一致。
