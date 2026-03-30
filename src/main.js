const { emit, listen } = window.__TAURI__.event;
const { open } = window.__TAURI__.dialog;
const { invoke } = window.__TAURI__.core;

const STORAGE_KEY = 'custom_template_path';

class TemplateManager {
  constructor({ storageKey, displayEl, resetButton }) {
    this.storageKey = storageKey;
    this.displayEl = displayEl;
    this.resetButton = resetButton;
    this.current = window.localStorage.getItem(storageKey);
    this.render();
  }

  get value() {
    return this.current || null;
  }

  async pickTemplate() {
    const selection = await open({
      multiple: false,
      filters: [{ name: 'Word/Config', extensions: ['docx', 'yaml', 'yml'] }],
    });
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
  }

  showIdle() {
    if (this.element) {
      this.element.textContent = '输出文件将保存在源文件同级目录';
    }
  }

  showProcessing(targetPath) {
    if (!this.element) return;
    const label = targetPath ? getFileName(targetPath) : '文档';
    this.element.innerHTML = <span class="spinner"></span><span class="status-processing">转换中：</span>;
  }

  showSuccess(fileName, fullPath) {
    if (!this.element) return;
    const safeName = fileName || '文档';
    this.element.innerHTML = 
      <div><span class="status-success">✓ 转换完成</span></div>
      <div class="status-note"></div>
    ;
    if (fullPath) {
      const button = document.createElement('button');
      button.className = 'btn btn-primary';
      button.textContent = '打开所在目录';
      button.addEventListener('click', () => {
        invoke('open_folder', { path: fullPath });
      });
      this.element.appendChild(button);
    }
  }

  showError(message) {
    if (!this.element) return;
    this.element.innerHTML = <span class="status-error">⚠ </span>;
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

const statusPanel = new StatusPanel(document.getElementById('status'));
statusPanel.showIdle();

const templateManager = new TemplateManager({
  storageKey: STORAGE_KEY,
  displayEl: document.getElementById('template-name'),
  resetButton: document.getElementById('reset-template'),
});

document
  .getElementById('select-template')
  .addEventListener('click', () => templateManager.pickTemplate());

document
  .getElementById('reset-template')
  .addEventListener('click', () => templateManager.clear());

const dropZone = new DropZone(document.getElementById('drop-zone'), {
  onRequestDialog: () => selectMarkdownFiles(),
  onDrop: (paths) => handleFiles(paths),
});

listen('tauri://drag-drop', (event) => {
  dropZone.setHover(false);
  const paths = event.payload?.paths || [];
  handleFiles(paths);
});

listen('initial-files', (event) => {
  handleFiles(event.payload || []);
});

listen('markdown-conversion-response', (event) => {
  const { success, result, full_path, error } = event.payload;
  if (success) {
    statusPanel.showSuccess(result, full_path);
  } else {
    statusPanel.showError(error || '转换失败，请检查 Pandoc 配置');
  }
});

async function selectMarkdownFiles() {
  const selection = await open({
    multiple: true,
    filters: [{ name: 'Markdown', extensions: ['md'] }],
  });

  if (!selection) return;
  const entries = Array.isArray(selection) ? selection : [selection];
  handleFiles(entries);
}

async function handleFiles(entries) {
  const paths = extractMarkdownPaths(entries);
  if (!paths.length) {
    statusPanel.showError('请选择 Markdown (.md) 文件');
    return;
  }

  for (const path of paths) {
    statusPanel.showProcessing(path);
    try {
      await emit('markdown-conversion-request', {
        path,
        custom_template: templateManager.value,
      });
    } catch (error) {
      statusPanel.showError(
        `无法发送转换请求：${error?.message || String(error)}`
      );
      break;
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
