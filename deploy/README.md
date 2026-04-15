# ☁️ Cloudflare + NPM + SunPanel 部署指南

## 一、前置条件

| 项目 | 要求 |
|:---|:---|
| 服务器 | Linux (推荐 Debian/Ubuntu) 或任何支持 Docker 的系统 |
| Docker | ≥ 20.10 |
| Docker Compose | ≥ 2.0 (V2 插件) |
| 域名 | 已添加到 Cloudflare 并完成 NS 切换 |
| 端口开放 | 80, 443, 81 (NPM 管理), 3002 (SunPanel) |

---

## 二、获取 Cloudflare API Token

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com)
2. 右上角 **头像** → **My Profile** → 左侧 **API Tokens**
3. 点击 **Create Token** → 选择模板 **Edit zone DNS**
4. 配置权限：

   | 权限 | 值 |
   |:---|:---|
   | Zone - DNS | Edit |
   | Zone - Zone | Read |
   | Zone Resources | Include → 选择你的域名 |

5. 点击 **Continue to summary** → **Create Token**
6. **立即复制** Token（仅展示一次！）
7. 设置环境变量：

```bash
# Linux 永久设置
echo 'export CF_API_TOKEN="你的Token"' >> ~/.bashrc
source ~/.bashrc
```

```powershell
# Windows 永久设置
[System.Environment]::SetEnvironmentVariable("CF_API_TOKEN", "你的Token", "User")
```

---

## 三、快速部署

```bash
# 1. 进入部署目录
cd deploy/

# 2. 复制环境变量模板并填写
cp .env.example .env
nano .env   # 填入你的域名、Token 等

# 3. 启动服务
docker compose up -d

# 4. 查看运行状态
docker compose ps
```

---

## 四、配置 NPM 反向代理

### 4.1 首次登录 NPM

- 浏览器访问 `http://你的服务器IP:81`
- 默认账号：`admin@example.com`
- 默认密码：`changeme`
- **首次登录后务必修改邮箱和密码**

### 4.2 添加 Proxy Host

在 NPM 管理面板中，点击 **Proxy Hosts** → **Add Proxy Host**，按以下规则逐一添加：

#### 主服务 (端口 50000 → HTTPS)

| 字段 | 值 |
|:---|:---|
| Domain Names | `app.你的域名.com` |
| Scheme | http |
| Forward Hostname / IP | 主机 IP 或 Docker 宿主机 IP |
| Forward Port | 50000 |
| Block Common Exploits | ✅ |
| Websockets Support | ✅ (按需) |
| SSL → Force SSL | ✅ |
| SSL → HTTP/2 Support | ✅ |

#### SunPanel 面板

| 字段 | 值 |
|:---|:---|
| Domain Names | `home.你的域名.com` |
| Scheme | http |
| Forward Hostname / IP | `sun-panel` (容器名) |
| Forward Port | 3002 |
| SSL → Force SSL | ✅ |

#### NPM 管理面板 (可选)

| 字段 | 值 |
|:---|:---|
| Domain Names | `npm.你的域名.com` |
| Scheme | http |
| Forward Hostname / IP | `nginx-proxy-manager` |
| Forward Port | 81 |
| SSL → Force SSL | ✅ |

> **SSL 证书**：在每个 Proxy Host 的 **SSL** 标签页，可选择：
> - **Request a new SSL Certificate** (Let's Encrypt，需 80 端口可达)
> - **Custom** → 上传 Cloudflare Origin Certificate

---

## 五、配置 Cloudflare DNS

在 [Cloudflare Dashboard](https://dash.cloudflare.com) → 你的域名 → **DNS** → **Records**，添加：

| 类型 | 名称 | 内容 | 代理 | TTL |
|:---|:---|:---|:---|:---|
| A | `app` | `服务器公网IP` | 🟠 Proxied | Auto |
| A | `home` | `服务器公网IP` | 🟠 Proxied | Auto |
| A | `npm` | `服务器公网IP` | 🟠 Proxied | Auto |

### SSL/TLS 设置

**Dashboard → 你的域名 → SSL/TLS → Overview**
- 设置为 **Full** 或 **Full (Strict)**
- 这确保 Cloudflare ↔ NPM 之间也使用 HTTPS

---

## 六、配置 SunPanel

1. 访问 `http://你的服务器IP:3002`（首次）或 `https://home.你的域名.com`（配置完 NPM 后）
2. 注册管理员账号
3. 添加服务书签：

| 名称 | URL |
|:---|:---|
| 🏛️ 主应用 | `https://app.你的域名.com` |
| 🔧 NPM 管理 | `https://npm.你的域名.com` |
| 其他服务 | `https://xxx.你的域名.com` |

---

## 七、常见问题

**Q: 502 Bad Gateway？**
> 检查目标服务是否运行中，以及 NPM 中 Forward Hostname 和端口是否正确。

**Q: SSL 握手失败？**
> 确认 Cloudflare SSL/TLS 模式为 Full，而非 Flexible。

**Q: 无法访问 NPM 管理面板？**
> 检查防火墙是否开放了 81 端口，或改用 `npm.域名` 通过反向代理访问。

---

## 八、常用运维命令

```bash
# 查看日志
docker compose logs -f npm
docker compose logs -f sunpanel

# 重启服务
docker compose restart npm

# 更新镜像
docker compose pull
docker compose up -d

# 停止所有服务
docker compose down

# 停止并删除数据 (⚠️ 慎用)
docker compose down -v
```
