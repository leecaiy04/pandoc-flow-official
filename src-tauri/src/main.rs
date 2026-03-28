#![cfg_attr(
    all(not(debug_assertions), target_os = "windows"),
    windows_subsystem = "windows"
)]

use std::process::Command;
use std::path::{Path, PathBuf};
use tauri::{Manager, AppHandle, Runtime};

#[tauri::command]
async fn convert_markdown<R: Runtime>(
    app: AppHandle<R>,
    path: String
) -> Result<String, String> {
    let input_path = Path::new(&path);
    if !input_path.exists() {
        return Err("输入文件不存在".into());
    }

    // 默认输出为同目录下 .docx
    let output_path = input_path.with_extension("docx");
    
    // 获取资源目录中的模版和 defaults 文件
    let resource_dir = app.path_resolver().resource_dir().ok_or("找不到资源目录")?;
    
    // 我们将 templates 文件夹放在资源目录下
    let defaults_file = resource_dir.join("templates/pandoc-defaults.yaml");
    let template_file = resource_dir.join("templates/公文模板.docx");

    if !defaults_file.exists() && !template_file.exists() {
         return Err("找不到模板文件".into());
    }

    println!("正在转换: {} -> {}", input_path.display(), output_path.display());

    // 构建 Pandoc 命令
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
        .setup(|app| {
            // 获取拖拽到图标打开的文件
            let args: Vec<String> = std::env::args().collect();
            // 在 Windows 上，第一个参数是程序本身，后续是传入的文件路径
            if args.len() > 1 {
                let paths: Vec<String> = args[1..].iter().cloned().collect();
                // 将初始拖入的文件列表发送给前端
                let app_handle = app.handle();
                tauri::async_runtime::spawn(async move {
                    // 等待前端加载完成
                    tokio::time::sleep(tokio::time::Duration::from_millis(1500)).await;
                    app_handle.emit_all("initial-files", paths).unwrap();
                });
            }
            Ok(())
        })
        .invoke_handler(tauri::generate_handler![convert_markdown])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
