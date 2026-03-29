#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use std::process::Command;
use std::path::{Path, PathBuf};
use tauri::{Manager, AppHandle, Runtime, Emitter, Listener};
use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize, Clone)]
struct ConvertRequest {
    path: String,
    custom_template: Option<String>, // 用户选取的自定义模板路径
}

#[derive(Serialize, Deserialize, Clone)]
struct ConvertResponse {
    success: bool,
    result: String,
    error: Option<String>,
}

fn do_convert(app: &AppHandle, path: String, custom_template: Option<String>) -> Result<String, String> {
    let input_path = Path::new(&path);
    if !input_path.exists() {
        return Err(format!("输入文件不存在: {}", path));
    }

    let output_path = input_path.with_extension("docx");
    
    // 确定资源目录
    let resource_dir = app.path().resource_dir().map_err(|e| format!("无法定位资源目录: {}", e))?;
    
    // 默认内置路径 (Tauri v2 资源打包后通常在资源根目录的相应文件夹下)
    let default_defaults = resource_dir.join("templates/pandoc-defaults.yaml");
    let default_template = resource_dir.join("templates/official-template.docx");

    // 确定使用的模板/配置
    let (use_defaults, use_template) = if let Some(custom) = custom_template {
        // 如果是自定义模板，优先尝试作为 defaults yaml，否则作为 reference-doc
        let p = PathBuf::from(custom);
        if p.extension().map_or(false, |ext| ext == "yaml" || ext == "yml") {
            (Some(p), None)
        } else {
            (None, Some(p))
        }
    } else {
        // 使用内置默认值
        (
            if default_defaults.exists() { Some(default_defaults) } else { None },
            if default_template.exists() { Some(default_template) } else { None }
        )
    };

    // 检查是否至少有一个模板可用
    if use_defaults.is_none() && use_template.is_none() {
        return Err(format!("找不到任何可用的模板文件。资源目录：{:?}", resource_dir));
    }

    let mut cmd = Command::new("pandoc");
    cmd.arg(input_path);
    
    if let Some(d) = use_defaults {
        cmd.arg("-d").arg(d);
    } else if let Some(t) = use_template {
        cmd.arg("--reference-doc").arg(t);
    }

    cmd.arg("-o").arg(&output_path);

    let output = cmd.output().map_err(|e| format!("系统未安装 Pandoc 或执行失败: {}", e))?;

    if output.status.success() {
        Ok(output_path.file_name().unwrap_or_default().to_string_lossy().to_string())
    } else {
        let err_msg = String::from_utf8_lossy(&output.stderr);
        Err(format!("Pandoc 转换失败: {}", err_msg))
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .setup(|app| {
            let handle = app.handle().clone();
            
            // 监听转换请求
            app.listen("markdown-conversion-request", move |event| {
                if let Ok(req) = serde_json::from_str::<ConvertRequest>(event.payload()) {
                    let app_handle = handle.clone();
                    let path = req.path;
                    let custom_template = req.custom_template;
                    
                    tauri::async_runtime::spawn(async move {
                        match do_convert(&app_handle, path, custom_template) {
                            Ok(res) => {
                                app_handle.emit("markdown-conversion-response", ConvertResponse {
                                    success: true,
                                    result: res,
                                    error: None,
                                }).unwrap();
                            }
                            Err(e) => {
                                app_handle.emit("markdown-conversion-response", ConvertResponse {
                                    success: false,
                                    result: String::new(),
                                    error: Some(e),
                                }).unwrap();
                            }
                        }
                    });
                }
            });

            // 处理启动参数
            let args: Vec<String> = std::env::args().collect();
            if args.len() > 1 {
                let paths: Vec<String> = args[1..].iter().cloned().collect();
                let app_handle = app.handle().clone();
                tauri::async_runtime::spawn(async move {
                    tokio::time::sleep(tokio::time::Duration::from_millis(1500)).await;
                    app_handle.emit("initial-files", paths).unwrap();
                });
            }
            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
