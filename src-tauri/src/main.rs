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
}

#[derive(Serialize, Deserialize, Clone)]
struct ConvertResponse {
    success: bool,
    result: String,
    error: Option<String>,
}

fn do_convert(app: &AppHandle, path: String) -> Result<String, String> {
    let input_path = Path::new(&path);
    if !input_path.exists() {
        return Err("输入文件不存在".into());
    }

    let output_path = input_path.with_extension("docx");
    let resource_dir = app.path().resource_dir().map_err(|e| format!("找不到资源目录: {}", e))?;
    
    let defaults_file = resource_dir.join("templates/pandoc-defaults.yaml");
    let template_file = resource_dir.join("templates/official-template.docx");

    if !defaults_file.exists() && !template_file.exists() {
         return Err("找不到模板文件".into());
    }

    let mut cmd = Command::new("pandoc");
    cmd.arg(input_path);
    
    if defaults_file.exists() {
        cmd.arg("-d").arg(defaults_file);
    } else {
        cmd.arg("--reference-doc").arg(template_file);
    }

    cmd.arg("-o").arg(&output_path);

    let output = cmd.output().map_err(|e| format!("执行 Pandoc 失败: {}", e))?;

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
            
            // 监听前端发来的转换请求 (绕过 Command ACL)
            app.listen("markdown-conversion-request", move |event| {
                if let Ok(req) = serde_json::from_str::<ConvertRequest>(event.payload()) {
                    let app_handle = handle.clone();
                    let path = req.path;
                    
                    // 在异步线程中执行，避免阻塞主线程
                    tauri::async_runtime::spawn(async move {
                        match do_convert(&app_handle, path) {
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

            // 处理启动参数（拖入图标的文件）
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
