#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

mod conversion;
mod events;

use conversion::convert_markdown;
use events::{
    ConvertRequest, ConvertResponse, EVENT_CONVERT_REQUEST, EVENT_CONVERT_RESPONSE,
    EVENT_INITIAL_FILES,
};
use std::path::{Path, PathBuf};
use std::process::Command;
use tauri::{AppHandle, Emitter, Event, Listener, Runtime};
use tokio::time::{sleep, Duration};

#[tauri::command]
fn open_folder(path: String) -> Result<(), String> {
    let path = PathBuf::from(path);
    if !path.exists() {
        return Err(format!("路径不存在：{}", path.display()));
    }

    #[cfg(target_os = "windows")]
    {
        let result = if path.is_dir() {
            Command::new("explorer")
                .arg(normalize_windows_path(&path))
                .spawn()
        } else {
            Command::new("explorer")
                .arg(format!(r#"/select,"{}""#, normalize_windows_path(&path)))
                .spawn()
        };

        result
            .map(|_| ())
            .map_err(|err| format!("打开目录失败：{}", err))?;
    }

    #[cfg(target_os = "macos")]
    {
        Command::new("open")
            .arg("-R")
            .arg(&path)
            .spawn()
            .map(|_| ())
            .map_err(|err| format!("打开目录失败：{}", err))?;
    }

    #[cfg(target_os = "linux")]
    {
        if let Some(parent) = path.parent() {
            Command::new("xdg-open")
                .arg(parent)
                .spawn()
                .map(|_| ())
                .map_err(|err| format!("打开目录失败：{}", err))?;
        }
    }

    Ok(())
}

#[cfg(target_os = "windows")]
fn normalize_windows_path(path: &Path) -> String {
    let raw = path.to_string_lossy();
    if let Some(rest) = raw.strip_prefix(r"\\?\UNC\") {
        format!(r"\\{}", rest)
    } else if let Some(rest) = raw.strip_prefix(r"\\?\") {
        rest.to_string()
    } else {
        raw.into_owned()
    }
}

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_dialog::init())
        .setup(|app| {
            let handle = app.handle().clone();
            register_conversion_listener(handle.clone());
            bootstrap_initial_files(handle);
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![open_folder])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

fn register_conversion_listener<R: Runtime>(handle: AppHandle<R>) {
    let conversion_handle = handle.clone();
    handle.listen(EVENT_CONVERT_REQUEST, move |event: Event| {
        let payload = event.payload().to_string();
        let request: ConvertRequest = match serde_json::from_str(&payload) {
            Ok(req) => req,
            Err(err) => {
                eprintln!("无法解析转换请求: {}", err);
                return;
            }
        };

        let app_handle = conversion_handle.clone();
        tauri::async_runtime::spawn(async move {
            let response = build_convert_response(&app_handle, request);
            if let Err(err) = app_handle.emit(EVENT_CONVERT_RESPONSE, response) {
                eprintln!("发送转换结果失败: {}", err);
            }
        });
    });
}

fn build_convert_response<R: Runtime>(
    app: &AppHandle<R>,
    request: ConvertRequest,
) -> ConvertResponse {
    let ConvertRequest { path } = request;

    match convert_markdown(app, &path) {
        Ok(result) => {
            let file_name = result
                .output_path
                .file_name()
                .map(|name| name.to_string_lossy().to_string())
                .unwrap_or_default();
            let full_path = result.output_path.to_string_lossy().to_string();
            ConvertResponse {
                success: true,
                result: file_name,
                full_path: Some(full_path),
                error: None,
                cli_command: Some(result.cli_command),
            }
        }
        Err(err) => ConvertResponse {
            success: false,
            result: String::new(),
            full_path: None,
            error: Some(err.to_string()),
            cli_command: None,
        },
    }
}

fn bootstrap_initial_files<R: Runtime>(handle: AppHandle<R>) {
    let args: Vec<String> = std::env::args().collect();
    if args.len() <= 1 {
        return;
    }

    let payload = args[1..].to_vec();
    tauri::async_runtime::spawn(async move {
        sleep(Duration::from_millis(1500)).await;
        if let Err(err) = handle.emit(EVENT_INITIAL_FILES, payload) {
            eprintln!("发送启动文件事件失败: {}", err);
        }
    });
}
