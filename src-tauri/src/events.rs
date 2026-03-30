use serde::{Deserialize, Serialize};

pub const EVENT_CONVERT_REQUEST: &str = "markdown-conversion-request";
pub const EVENT_CONVERT_RESPONSE: &str = "markdown-conversion-response";
pub const EVENT_INITIAL_FILES: &str = "initial-files";

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ConvertRequest {
    pub path: String,
    pub custom_template: Option<String>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ConvertResponse {
    pub success: bool,
    pub result: String,
    pub full_path: Option<String>,
    pub error: Option<String>,
    pub cli_command: Option<String>,
}
