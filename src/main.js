const LEGACY_TEMPLATE_STORAGE_KEY = 'custom_template_path';

function waitForTauri(timeout = 7000) {
  if (window.__TAURI__) {
    return Promise.resolve(window.__TAURI__);
  }

  return new Promise((resolve, reject) => {
    const start = Date.now();
    const timer = setInterval(() => {
      if (window.__TAURI__) {
        clearInterval(timer);
        resolve(window.__TAURI__);
      } else if (Date.now() - start > timeout) {
        clearInterval(timer);
        reject(new Error('Tauri API 初始化超时'));
      }
    }, 50);
  });
}

class StatusPanel {
  constructor(element) {
    this.element = element;
    this.invoke = null;
  }

  setInvoker(fn) {
    this.invoke = fn;
  }

  showIdle() {
    if (this.element) {
      this.element.textContent = '输出文件将保存在源文件同级目录';
    }
  }

  showProcessing(targetPath) {
    if (!this.element) return;
    const label = targetPath ? getFileName(targetPath) : '文档';
    const safeLabel = escapeHTML(label);
    this.element.innerHTML = `
      <span class="spinner"></span>
      <span class="status-processing">转换中：${safeLabel}</span>
    `;
  }

  showSuccess(fileName, fullPath, cliCommand) {
    if (!this.element) return;
    const safeName = escapeHTML(fileName || '文档');
    this.element.innerHTML = `
      <div><span class="status-success">✓ 转换完成</span></div>
      <div class="status-note">${safeName}</div>
    `;
    if (fullPath && this.invoke) {
      const button = document.createElement('button');
      button.className = 'btn btn-primary';
      button.textContent = '打开所在目录';
      button.addEventListener('click', async () => {
        try {
          await this.invoke('open_folder', { path: fullPath });
        } catch (error) {
          console.error('open_folder failed', error);
          this.showError(error?.message || '打开所在目录失败');
        }
      });
      this.element.appendChild(button);
    }

    if (cliCommand) {
      const helper = document.createElement('div');
      helper.className = 'cli-helper';
      helper.innerHTML = `
        <div class="cli-helper__header">
          <div class="cli-helper__label">命令行复现</div>
        </div>
        <pre class="cli-helper__code">${escapeHTML(cliCommand)}</pre>
      `;

      const header = helper.querySelector('.cli-helper__header');
      const copyButton = document.createElement('button');
      copyButton.className = 'btn btn-secondary cli-helper__copy';
      copyButton.type = 'button';
      copyButton.textContent = '复制命令';
      copyButton.addEventListener('click', async () => {
        const copied = await copyText(cliCommand);
        copyButton.textContent = copied ? '已复制' : '复制失败';
        window.setTimeout(() => {
          copyButton.textContent = '复制命令';
        }, 1600);
      });
      header?.appendChild(copyButton);

      this.element.appendChild(helper);
    }
  }

  showError(message) {
    if (!this.element) return;
    const safeMessage = escapeHTML(message || '发生未知错误');
    this.element.innerHTML = `<span class="status-error">⚠ ${safeMessage}</span>`;
  }
}

class DropZone {
  constructor(element, { onRequestDialog, onDrop }) {
    this.element = element;
    this.onRequestDialog = onRequestDialog;
    this.onDrop = onDrop;
    this.hoverDepth = 0;
    this.bind();
  }

  bind() {
    if (!this.element) return;

    this.element.addEventListener('click', () => this.onRequestDialog?.());
    this.element.addEventListener('keydown', (event) => {
      if (event.key === 'Enter' || event.key === ' ') {
        event.preventDefault();
        this.onRequestDialog?.();
      }
    });

    this.element.addEventListener('dragenter', (event) => {
      event.preventDefault();
      this.hoverDepth += 1;
      this.setHover(true);
    });

    this.element.addEventListener('dragover', (event) => {
      event.preventDefault();
      this.setHover(true);
    });

    this.element.addEventListener('dragleave', (event) => {
      event.preventDefault();
      this.hoverDepth = Math.max(0, this.hoverDepth - 1);
      if (this.hoverDepth === 0) this.setHover(false);
    });

    this.element.addEventListener('drop', (event) => {
      event.preventDefault();
      this.hoverDepth = 0;
      this.setHover(false);
      const files = Array.from(event.dataTransfer?.files || []);
      const paths = files.map((file) => file.path).filter(Boolean);
      if (paths.length) {
        this.onDrop?.(paths);
      }
    });
  }

  setHover(state) {
    if (!this.element) return;
    this.element.classList.toggle('hover', Boolean(state));
  }
}

class PandocApp {
  constructor(api, statusPanel) {
    this.api = api;
    this.statusPanel = statusPanel;
    this.statusPanel.setInvoker(api.invoke);
    this.dropZone = new DropZone(document.getElementById('drop-zone'), {
      onRequestDialog: () => this.selectMarkdownFiles(),
      onDrop: (paths) => this.handleFiles(paths),
    });
  }

  async init() {
    try {
      await this.api.listen('tauri://drag-drop', (event) => {
        this.dropZone.setHover(false);
        const paths = event.payload?.paths || [];
        this.handleFiles(paths);
      });

      await this.api.listen('initial-files', (event) => {
        this.handleFiles(event.payload || []);
      });

      await this.api.listen('markdown-conversion-response', (event) => {
        const { success, result, full_path, cli_command, error } = event.payload;
        if (success) {
          this.statusPanel.showSuccess(result, full_path, cli_command);
        } else {
          this.statusPanel.showError(error || '转换失败，请检查 Pandoc 配置');
        }
      });
    } catch (error) {
      console.error('Event registration failed:', error);
      this.statusPanel.showError('监听系统事件失败，请重启应用');
    }
  }

  async selectMarkdownFiles() {
    if (!this.api.openDialog) return;
    const selection = await this.api.openDialog({
      multiple: true,
      filters: [{ name: 'Markdown', extensions: ['md'] }],
    }).catch((error) => {
      this.statusPanel.showError(error?.message || '无法打开文件选择器');
      return null;
    });

    if (!selection) return;
    const entries = Array.isArray(selection) ? selection : [selection];
    this.handleFiles(entries);
  }

  async handleFiles(entries) {
    const paths = extractMarkdownPaths(entries);
    if (!paths.length) {
      this.statusPanel.showError('请选择 Markdown (.md) 文件');
      return;
    }

    for (const path of paths) {
      this.statusPanel.showProcessing(path);
      try {
        await this.api.emit('markdown-conversion-request', { path });
      } catch (error) {
        console.error('emit failed', error);
        this.statusPanel.showError(
          `无法发送转换请求：${error?.message || String(error)}`
        );
        break;
      }
    }
  }
}

function extractMarkdownPaths(entries) {
  const payload = Array.isArray(entries) ? entries : [entries];
  return payload
    .map((item) => {
      if (!item) return null;
      if (typeof item === 'string') return item;
      if (typeof item === 'object') {
        if ('path' in item && item.path) return item.path;
        if ('filePath' in item && item.filePath) return item.filePath;
      }
      return null;
    })
    .filter(Boolean)
    .map((path) => path.trim())
    .filter((path) => path.toLowerCase().endsWith('.md'));
}

function getFileName(path) {
  if (!path) return '';
  const segments = path.split(/[\\/]/);
  return segments[segments.length - 1] || path;
}

function escapeHTML(value) {
  return (value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

async function copyText(value) {
  const text = value || '';
  if (!text) return false;

  try {
    if (navigator.clipboard?.writeText) {
      await navigator.clipboard.writeText(text);
      return true;
    }
  } catch (error) {
    console.warn('Clipboard API unavailable:', error);
  }

  const textarea = document.createElement('textarea');
  textarea.value = text;
  textarea.setAttribute('readonly', 'readonly');
  textarea.style.position = 'fixed';
  textarea.style.opacity = '0';
  textarea.style.pointerEvents = 'none';
  document.body.appendChild(textarea);
  textarea.select();

  try {
    return document.execCommand('copy');
  } catch (error) {
    console.warn('execCommand copy failed:', error);
    return false;
  } finally {
    document.body.removeChild(textarea);
  }
}

const statusPanel = new StatusPanel(document.getElementById('status'));
statusPanel.showIdle();
window.localStorage.removeItem(LEGACY_TEMPLATE_STORAGE_KEY);

(async () => {
  try {
    const tauri = await waitForTauri();
    const api = {
      emit: (...args) => tauri.event.emit(...args),
      listen: (...args) => tauri.event.listen(...args),
      openDialog: (...args) => tauri.dialog.open(...args),
      invoke: (...args) => tauri.core.invoke(...args),
    };

    const app = new PandocApp(api, statusPanel);
    await app.init();
  } catch (error) {
    console.error('Failed to bootstrap app:', error);
    statusPanel.showError('Tauri 接口初始化失败，请重启应用');
  }
})();
