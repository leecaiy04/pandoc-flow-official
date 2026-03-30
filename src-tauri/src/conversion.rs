use anyhow::{anyhow, bail, Context, Result};
use std::path::{Path, PathBuf};
use std::process::Command;
use tauri::{path::BaseDirectory, AppHandle, Manager, Runtime};

#[derive(Debug, Default)]
struct TemplateSelection {
    defaults: Option<PathBuf>,
    reference_doc: Option<PathBuf>,
}

#[derive(Debug)]
pub struct ConversionResult {
    pub output_path: PathBuf,
    pub cli_command: String,
}

pub fn convert_markdown<R: Runtime>(
    app: &AppHandle<R>,
    input: impl AsRef<Path>,
    custom_template: Option<String>,
) -> Result<ConversionResult> {
    let input_path = input.as_ref();
    if !input_path.exists() {
        bail!("输入文件不存在：{}", input_path.display());
    }

    let output_path = input_path.with_extension("docx");
    let templates = resolve_templates(app, custom_template)?;

    let mut cmd = Command::new("pandoc");
    cmd.arg(input_path);

    if let Some(defaults) = templates.defaults.as_ref() {
        cmd.arg("-d").arg(defaults);
    }

    if let Some(reference_doc) = templates.reference_doc.as_ref() {
        cmd.arg("--reference-doc").arg(reference_doc);
    }

    cmd.arg("-o").arg(&output_path);

    let output = cmd
        .output()
        .with_context(|| "系统未安装 Pandoc 或执行失败")?;

    if output.status.success() {
        let cli_command = build_cli_command(input_path, &templates, &output_path);
        Ok(ConversionResult {
            output_path,
            cli_command,
        })
    } else {
        let stderr = String::from_utf8_lossy(&output.stderr).trim().to_string();
        if stderr.is_empty() {
            Err(anyhow!("Pandoc 转换失败，但未返回具体错误信息。"))
        } else {
            Err(anyhow!("Pandoc 转换失败: {}", stderr))
        }
    }
}

fn resolve_templates<R: Runtime>(
    app: &AppHandle<R>,
    custom_template: Option<String>,
) -> Result<TemplateSelection> {
    if let Some(custom) = custom_template {
        let path = PathBuf::from(&custom);
        if !path.exists() {
            bail!("自定义模板不存在：{}", custom);
        }

        let is_yaml = path
            .extension()
            .and_then(|ext| ext.to_str())
            .map(|ext| matches!(ext.to_lowercase().as_str(), "yaml" | "yml"))
            .unwrap_or(false);

        if is_yaml {
            return Ok(TemplateSelection {
                defaults: Some(path),
                reference_doc: None,
            });
        } else {
            return Ok(TemplateSelection {
                defaults: None,
                reference_doc: Some(path),
            });
        }
    }

    let resolver = app.path();
    let defaults = resolver
        .resolve("templates/pandoc-defaults.yaml", BaseDirectory::Resource)
        .ok();
    let reference_doc = resolver
        .resolve("templates/official-template.docx", BaseDirectory::Resource)
        .ok();

    if defaults.is_none() && reference_doc.is_none() {
        let resource_dir = resolver.resource_dir().unwrap_or_default();
        bail!(
            "找不到任何可用模板文件。资源目录：{}",
            resource_dir.display()
        );
    }

    Ok(TemplateSelection {
        defaults,
        reference_doc,
    })
}

fn build_cli_command(input: &Path, selection: &TemplateSelection, output: &Path) -> String {
    let mut parts = Vec::new();
    parts.push(format!("pandoc \"{}\"", escape_path(input)));
    if let Some(defaults) = selection.defaults.as_ref() {
        parts.push(format!("-d \"{}\"", escape_path(defaults)));
    }
    if let Some(reference_doc) = selection.reference_doc.as_ref() {
        parts.push(format!(
            "--reference-doc \"{}\"",
            escape_path(reference_doc)
        ));
    }
    parts.push(format!("-o \"{}\"", escape_path(output)));
    parts.join(" ")
}

fn escape_path(path: &Path) -> String {
    path.to_string_lossy().replace('"', "\\\"")
}
