use anyhow::{anyhow, bail, Context, Result};
use std::path::{Path, PathBuf};
use std::process::Command;
use tauri::{path::BaseDirectory, AppHandle, Manager, Runtime};

const DEFAULTS_RESOURCE_PATH: &str = "templates/pandoc-defaults.yaml";
const PRIMARY_REFERENCE_DOC_RESOURCE_PATH: &str = "templates/official-template.docx";
const LEGACY_REFERENCE_DOC_RESOURCE_PATH: &str = "templates/reference.docx";

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
) -> Result<ConversionResult> {
    let input_path = input.as_ref();
    if !input_path.exists() {
        bail!("输入文件不存在：{}", input_path.display());
    }

    let output_path = input_path.with_extension("docx");
    let templates = resolve_builtin_templates(app)?;

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

fn resolve_builtin_templates<R: Runtime>(app: &AppHandle<R>) -> Result<TemplateSelection> {
    let defaults = resolve_builtin_defaults(app)?;
    let reference_doc = resolve_builtin_reference_doc(app)?;
    Ok(TemplateSelection {
        defaults: Some(defaults),
        reference_doc: Some(reference_doc),
    })
}

fn resolve_builtin_defaults<R: Runtime>(app: &AppHandle<R>) -> Result<PathBuf> {
    resolve_required_resource(app, "内置 Pandoc 配置", &[DEFAULTS_RESOURCE_PATH])
}

fn resolve_builtin_reference_doc<R: Runtime>(app: &AppHandle<R>) -> Result<PathBuf> {
    resolve_required_resource(
        app,
        "内置 Word 模板",
        &[
            PRIMARY_REFERENCE_DOC_RESOURCE_PATH,
            LEGACY_REFERENCE_DOC_RESOURCE_PATH,
        ],
    )
}

fn resolve_required_resource<R: Runtime>(
    app: &AppHandle<R>,
    label: &str,
    relative_paths: &[&str],
) -> Result<PathBuf> {
    let mut attempted_paths = Vec::new();

    for relative_path in relative_paths {
        for candidate in collect_resource_candidates(app, relative_path) {
            attempted_paths.push(candidate.display().to_string());
            if candidate.is_file() {
                return Ok(candidate);
            }
        }
    }

    let resource_dir = app.path().resource_dir().unwrap_or_default();
    let attempted_paths = if attempted_paths.is_empty() {
        "无".to_string()
    } else {
        attempted_paths.join(" | ")
    };

    bail!(
        "找不到{}。候选资源：{}。资源目录：{}。尝试路径：{}",
        label,
        relative_paths.join(", "),
        resource_dir.display(),
        attempted_paths
    )
}

fn collect_resource_candidates<R: Runtime>(
    app: &AppHandle<R>,
    relative_path: &str,
) -> Vec<PathBuf> {
    let resolver = app.path();
    let mut candidates = Vec::new();

    if let Ok(resolved) = resolver.resolve(relative_path, BaseDirectory::Resource) {
        push_unique_path(&mut candidates, resolved);
    }

    if let Ok(resource_dir) = resolver.resource_dir() {
        push_unique_path(&mut candidates, resource_dir.join(relative_path));
    }

    #[cfg(debug_assertions)]
    {
        let manifest_dir = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
        push_unique_path(&mut candidates, manifest_dir.join("..").join(relative_path));

        if let Ok(current_dir) = std::env::current_dir() {
            push_unique_path(&mut candidates, current_dir.join(relative_path));

            if let Some(parent) = current_dir.parent() {
                push_unique_path(&mut candidates, parent.join(relative_path));
            }
        }
    }

    candidates
}

fn push_unique_path(paths: &mut Vec<PathBuf>, candidate: PathBuf) {
    if !paths.iter().any(|existing| existing == &candidate) {
        paths.push(candidate);
    }
}

fn build_cli_command(input: &Path, selection: &TemplateSelection, output: &Path) -> String {
    let mut parts = Vec::new();
    parts.push(format!("pandoc \"{}\"", display_cli_path(input)));
    if let Some(defaults) = selection.defaults.as_ref() {
        parts.push(format!("-d \"{}\"", display_cli_path(defaults)));
    }
    if let Some(reference_doc) = selection.reference_doc.as_ref() {
        parts.push(format!(
            "--reference-doc \"{}\"",
            display_cli_path(reference_doc)
        ));
    }
    parts.push(format!("-o \"{}\"", display_cli_path(output)));
    parts.join(" ")
}

fn display_cli_path(path: &Path) -> String {
    normalize_cli_path(path.to_string_lossy().as_ref()).replace('"', "\\\"")
}

fn normalize_cli_path(raw: &str) -> String {
    #[cfg(target_os = "windows")]
    {
        if let Some(rest) = raw.strip_prefix(r"\\?\UNC\") {
            return format!(r"\\{}", rest);
        }

        if let Some(rest) = raw.strip_prefix(r"\\?\") {
            return rest.to_string();
        }
    }

    raw.to_string()
}

#[cfg(test)]
mod tests {
    use super::{build_cli_command, normalize_cli_path, TemplateSelection};
    use std::path::PathBuf;

    #[test]
    fn cli_command_keeps_spaces_between_args() {
        let input = PathBuf::from(r"D:\docs\示例文档.md");
        let output = PathBuf::from(r"D:\docs\示例文档.docx");
        let selection = TemplateSelection {
            defaults: Some(PathBuf::from(r"C:\templates\pandoc-defaults.yaml")),
            reference_doc: Some(PathBuf::from(r"C:\templates\official-template.docx")),
        };

        let command = build_cli_command(&input, &selection, &output);

        assert!(command.contains("\"D:\\docs\\示例文档.md\" -d"));
        assert!(command.contains("pandoc "));
        assert!(command.contains(" --reference-doc "));
        assert!(command.contains(" -o "));
    }

    #[cfg(target_os = "windows")]
    #[test]
    fn normalize_cli_path_strips_windows_verbatim_prefix() {
        assert_eq!(
            normalize_cli_path(
                r"\\?\C:\Users\Administrator\AppData\Local\PandocFlow\templates\pandoc-defaults.yaml"
            ),
            r"C:\Users\Administrator\AppData\Local\PandocFlow\templates\pandoc-defaults.yaml"
        );
        assert_eq!(
            normalize_cli_path(r"\\?\UNC\server\share\demo.md"),
            r"\\server\share\demo.md"
        );
    }
}
