const STORAGE_KEY = 'custom_template_path';

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

class TemplateManager {
  constructor({ storageKey, displayEl, resetButton, openDialog }) {
    this.storageKey = storageKey;
    this.displayEl = displayEl;
    this.resetButton = resetButton;
    this.openDialog = openDialog;
    this.current = window.localStorage.getItem(storageKey);
    this.render();
  }

  get value() {
    return this.current || null;
  }

  async pickTemplate() {
    if (!this.openDialog) return;
    const selection = await this.openDialog({
      multiple: false,
      filters: [{ name: 'Word/Config', extensions: ['docx', 'yaml', 'yml'] }],
    }).catch(() => null);

    if (!selection) return;
    const path = typeof selection === 'string' ? selection : selection?.path;
    if (!path) return;

    this.setTemplate(path);
  }

  setTemplate(path) {
    this.current = path;
    window.localStorage.setItem(this.storageKey, path);
    this.render();
  }

  clear() {
    this.current = null;
    window.localStorage.removeItem(this.storageKey);
    this.render();
  }

  render() {
    if (!this.displayEl) return;
    if (this.current) {
      const fileName = getFileName(this.current);
      this.displayEl.textContent = fileName;
      this.displayEl.title = this.current;
      if (this.resetButton) this.resetButton.style.display = 'inline-block';
    } else {
      this.displayEl.textContent = '内置默认模板';
      this.displayEl.title = '内置默认模板';
      if (this.resetButton) this.resetButton.style.display = 'none';
    }
  }
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

  showSuccess(fileName, fullPath) {
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
      button.addEventListener('click', () => {
        this.invoke('open_folder', { path: fullPath });
      });
      this.element.appendChild(button);
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
    this.templateManager = new TemplateManager({
      storageKey: STORAGE_KEY,
      displayEl: document.getElementById('template-name'),
      resetButton: document.getElementById('reset-template'),
      openDialog: api.openDialog,
    });
    this.dropZone = new DropZone(document.getElementById('drop-zone'), {
      onRequestDialog: () => this.selectMarkdownFiles(),
      onDrop: (paths) => this.handleFiles(paths),
    });
  }

  async init() {
    document
      .getElementById('select-template')
      ?.addEventListener('click', () => this.templateManager.pickTemplate());

    document
      .getElementById('reset-template')
      ?.addEventListener('click', () => this.templateManager.clear());

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
        const { success, result, full_path, error } = event.payload;
        if (success) {
          this.statusPanel.showSuccess(result, full_path);
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
        await this.api.emit('markdown-conversion-request', {
          path,
          custom_template: this.templateManager.value,
        });
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

const statusPanel = new StatusPanel(document.getElementById('status'));
statusPanel.showIdle();

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