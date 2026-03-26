# dev-ocean-docker

Docker 开发环境集合，包括 OpenClaw AI 助手部署和全栈开发工具。

## 📋 概述

本仓库包含多个基于 Docker 的开发环境：

1. **openclaw-dev-container** - OpenClaw 官方开发容器，支持自动配置
2. **fullstack-dev-ubuntu** - 通用全栈开发环境，提供现代化工具链

---

## 🚀 快速开始

### openclaw-dev-container (OpenClaw AI 助手)

OpenClaw 开发容器提供一站式环境，用于部署支持飞书、Notion 等集成的 AI 助手服务。

#### 前置要求

- Docker (20.10+)
- Docker Compose (2.0+)

#### 1. 配置环境变量

```bash
cd /workspace/code/dev-ocean-docker/openclaw-dev-container

# 复制模板
cp .env.example .env

# 编辑 .env 并填入你的 API Keys
vim .env
```

**必需配置**:
- `OPENROUTER_API_KEY` - OpenRouter API key
- `TAVILY_API_KEY` - Tavily Search API key
- `FEISHU_APP_ID` - 飞书应用 ID
- `FEISHU_APP_SECRET` - 飞书应用 Secret
- `FEISHU_GROUP_IDS` - 允许的群组 ID（多个用逗号分隔）

**可选配置**:
- `NOTION_API_KEY` - Notion Integration token
- `NOTION_DATABASE_ID` - Notion Database ID（用于笔记存储）
- `OPENCLAW_GATEWAY_PORT` - 网关端口（默认: 18789）
- `OPENCLAW_MODEL` - 默认模型（默认: step-3.5-flash）
- `OPENCLAW_WORKSPACE` - 工作空间路径（默认: /root/.openclaw/workspace）

#### 2. 启动容器

```bash
# 使用 quick-start 脚本（推荐）
./quick-start.sh

# 使用特定版本
./quick-start.sh --version 1.0.1

# 强制重建镜像
./quick-start.sh --build --version 1.0.1

# 查看帮助
./quick-start.sh --help
```

#### 3. 验证启动

```bash
# 查看日志
docker-compose logs -f openclaw

# 健康检查
curl http://localhost:18789/health

# 查看状态
docker-compose exec openclaw openclaw gateway status
```

---

### fullstack-dev-ubuntu (通用开发环境)

完整的全栈开发环境，提供现代化工具链支持多语言开发。

#### 核心特性

- **多语言支持**: Java 25, Python 3, Node 24, Rust
- **完整工具链**: Maven 3.9.12, npm/yarn, cargo
- **镜像源优化**: 阿里云镜像源，国内下载更快
- **开箱即用**: 所有工具预装完成，无需额外配置

#### 已安装工具

| 语言/工具 | 版本 | 用途 |
|-----------|------|------|
| Java (OpenJDK Zulu) | 25 | 企业级后端开发 |
| Maven | 3.9.12 | 构建和依赖管理 |
| Python | 3.x | 数据科学 / Web 后端 |
| Node.js | 24.x | 前端 / 全栈开发 |
| Rust | latest | 系统编程 / WASM |
| 其他 | git, curl, vim... | 日常开发工具 |

#### 快速开始

1. **构建镜像**
   ```bash
   cd /workspace/code/dev-ocean-docker/fullstack-dev-ubuntu

   # 使用 run 脚本
   ./run.sh  # 构建并保存为 tar（可选上传）

   # 或直接使用 Docker
   docker build -t fullstack-dev-env:v1.0.1 .
   ```

2. **运行容器**
   ```bash
   # 交互式模式（推荐开发使用）
   docker run -it \
     --name fullstack-dev-container \
     -v "$HOME/code:/workspace/code" \
     -v "$HOME/.ssh:/root/.ssh" \
     -p 3000:3000 \
     fullstack-dev-env:v1.0.1

   # 后台运行
   docker run -d \
     --name fullstack-dev \
     -v "$HOME/code:/workspace/code" \
     fullstack-dev-env:v1.0.1
   ```

3. **验证安装**
   ```bash
   java -version
   mvn -version
   python --version
   node -v
   rustc --version
   ```

#### 典型使用场景

**Java/Spring 项目**
```bash
cd /workspace/code/spring-app
mvn clean install
mvn spring-boot:run
```

**Python 项目**
```bash
cd /workspace/code/python-api
pip install -r requirements.txt
python app.py
```

**Node.js 项目**
```bash
cd /workspace/code/react-app
npm install
npm start
```

**多语言混合**
```
/workspace/code/
├── backend-spring/   # Java
├── frontend-vue/     # Node.js
├── service-python/   # Python
└── tool-rust/        # Rust
```

#### 卷挂载建议

```bash
# 代码目录
-v "/path/to/code:/workspace/code"

# SSH 密钥（Git 操作）
-v "$HOME/.ssh:/root/.ssh"

# Maven 本地仓库（缓存加速）
-v "$HOME/.m2:/root/.m2"
```

---

## 📁 项目结构

```
dev-ocean-docker/
├── README.md                    # 主文档（中文）
├── README_en.md                 # 英文文档
├── CHANGES.md                   # 更新日志
├── LEGACY_SCRIPTS.md            # 废弃脚本说明
├── openclaw-dev-container/      # OpenClaw Docker 镜像目录
│   ├── Dockerfile               # 镜像定义
│   ├── docker-compose.yaml      # 服务编排
│   ├── entrypoint.sh            # 容器启动脚本
│   ├── .env.example             # 环境变量模板
│   ├── quick-start.sh           # 一键启动脚本
│   ├── docker_run.sh            # 遗留脚本（废弃）
│   ├── docker_setup.sh          # 遗留脚本（废弃）
│   ├── settings.xml             # Maven 配置
│   └── data/                    # 持久化数据目录（自动创建）
├── fullstack-dev-ubuntu/        # 全栈开发环境
│   ├── Dockerfile               # 镜像定义
│   ├── run.sh                   # 构建脚本
│   └── settings.xml             # Maven 配置（阿里云镜像）
├── local_test/                  # 本地测试脚本和数据
│   └── (测试脚本、日志、镜像备份)
├── .gitignore
└── docker-registry.json
```

---

## 🔧 配置参考

### 环境变量 (openclaw-dev-container)

| 变量名 | 必需 | 默认值 | 说明 |
|--------|------|--------|------|
| `OPENROUTER_API_KEY` | ✅ | - | OpenRouter API key，用于 LLM 访问 |
| `TAVILY_API_KEY` | ✅ | - | Tavily Search API key，用于网络搜索 |
| `FEISHU_APP_ID` | ✅ | - | 飞书应用 ID |
| `FEISHU_APP_SECRET` | ✅ | - | 飞书应用 Secret |
| `FEISHU_GROUP_IDS` | ✅ | - | 允许的群组 ID，逗号分隔 |
| `NOTION_API_KEY` | ❌ | - | Notion Integration token（可选） |
| `NOTION_DATABASE_ID` | ❌ | - | Notion Database ID（可选） |
| `OPENCLAW_GATEWAY_PORT` | ❌ | 18789 | Gateway 监听端口 |
| `OPENCLAW_GATEWAY_BIND` | ❌ | lan | 绑定地址（lan/localhost/all） |
| `OPENCLAW_MODEL` | ❌ | step-3.5-flash | 默认模型 ID |
| `OPENCLAW_WORKSPACE` | ❌ | /root/.openclaw/workspace | 工作空间路径 |

---

## 📖 模块说明

### openclaw-dev-container

**用途**: 快速部署 OpenClaw 网关服务，适用于开发、测试和生产。

**核心特性**:
- 环境变量自动生成配置文件
- Gateway 自动前台启动（Docker 友好）
- 数据持久化（配置、工作空间、日志）
- 版本管理（支持多标签镜像）
- 健康检查自动监控

**端口与服务**:
- Gateway API: `http://localhost:18789`
- Web UI: `http://localhost:18789` (需要 token)
- SSE Events: `http://localhost:18789/events`

**数据持久化**:
- 宿主机 `~/.openclaw/` → 容器 `/root/.openclaw/`
- 包含配置、工作空间、日志等

**常见问题**:
- 修改配置后不生效: 容器内已有 `openclaw.json` 不会被覆盖，删除它或重启容器
- 端口占用: 修改 `.env` 中的 `OPENCLAW_GATEWAY_PORT`
- 飞书消息收不到: 检查应用是否安装到群组，`FEISHU_GROUP_IDS` 是否正确，查看日志

---

### fullstack-dev-ubuntu

**用途**: 统一开发环境，支持多语言全栈开发。

**基础镜像**: Ubuntu 24.04 LTS

**已安装语言和工具**:
- Java 25 (OpenJDK Zulu) + Maven 3.9.12
- Python 3 + pip
- Node.js 24.x + npm
- Rust (rustc + cargo)
- 开发工具: git, curl, wget, unzip, tar, vim, build-essential 等

**优化**:
- 阿里云镜像源加速下载
- 预配置 Maven settings.xml 使用阿里云镜像
- 默认工作空间: `/workspace`

**适用场景**:
- Java/Spring 后端开发
- Python/Django/FastAPI 服务
- Node.js/React/Vue 前端
- Rust 应用开发
- 多语言混合项目

**镜像大小**:
- 基础: ~2GB
- 构建后: ~2.5GB（含缓存）
- 运行容器: 取决于项目依赖

---

## 🔄 版本管理 (openclaw-dev-container)

```bash
# 查看当前版本
cat .current-version

# 启动特定版本
./quick-start.sh --version 1.0.1

# 构建新版本
./quick-start.sh --build --version 1.0.1
```

---

## 🛠️ 开发与调试

### 查看 Gateway 状态

```bash
# 进入容器
docker-compose exec openclaw bash

# 查看网关状态
openclaw gateway status

# 查看日志（容器内）
cat /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 或从宿主机查看（如果挂载了日志）
tail -f ~/.openclaw/openclaw-$(date +%Y-%m-%d).log
```

### 调试配置

```bash
# 检查生成的配置文件
docker-compose exec openclaw cat /root/.openclaw/openclaw.json

# 验证 JSON 格式
docker-compose exec openclaw python3 -c "import json; json.load(open('/root/.openclaw/openclaw.json')); print('✅ JSON valid')"
```

---

## 🌐 访问地址

- **Gateway API**: http://localhost:18789
- **Control UI**: http://localhost:18789 (如果启用)
- **SSE Events**: http://localhost:18789/events

---

## 🐛 故障排除

### 1. 容器启动失败，提示端口占用
**解决**: 修改 `.env` 中的 `OPENCLAW_GATEWAY_PORT`，或停止占用端口的进程

### 2. "API key invalid" 错误
检查 `.env` 中的 API Key 是否正确复制，没有多余空格

### 3. 飞书消息收不到
- 确认 App ID 和 Secret 正确
- 确认应用已安装到群组
- 确认 `FEISHU_GROUP_IDS` 包含正确的群组 ID
- 查看日志：`docker-compose logs openclaw | grep -i feishu`

### 4. Notion 无法写入
- 确认 Notion API Key 是 Integration 的（不是用户 token）
- 确认 Database 已分享给 Integration（Can edit）
- 确认 `NOTION_DATABASE_ID` 正确

### 5. gateway 无法启动（Docker 环境 systemd 问题）
本容器已针对 Docker 优化，gateway 会直接前台运行。如果看到：
```
Runtime: unknown (systemctl not available)
```
这是正常的，Inside Docker 不支持 systemd。gateway 依然会正常启动。

---

## 🔒 安全建议

1. **保护 .env 文件**：
   ```bash
   chmod 600 .env
   # 确保不提交到 Git
   echo ".env" >> .gitignore
   ```

2. **定期轮换 API Keys**：
   - OpenRouter：每 90 天
   - Tavily：按提供商政策
   - Feishu：应用凭证长期有效，注意安全

3. **限制容器权限**：
   - 生产环境考虑使用非 root 用户
   - 限制网络访问（仅允许出站）

---

## 📊 性能调优

### 调整资源限制

在 `docker-compose.yaml` 中添加：

```yaml
services:
  openclaw:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

### 调整 Gateway 端口映射

```yaml
ports:
  - "18789:18789"  # 宿主机:容器
```

---

## 🚢 生产部署建议

1. **使用 production 镜像**：基于 `ghcr.io/openclaw/openclaw:stable`
2. **配置反向代理**：Nginx/Traefik 处理 HTTPS
3. **持久化存储**: 使用 Docker volume 或 external storage
4. **监控告警**: 设置 healthcheck 和日志收集
5. **密钥管理**: 使用 Docker secrets 或 vault

---

## 📚 相关资源

- [OpenClaw 文档](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Feishu 开发者文档](https://open.feishu.cn/document)
- [Notion API 文档](https://developers.notion.com)
- [Tavily API 文档](https://docs.tavily.com)

---

**版本**: 1.0.0+  
**更新**: 2025-03-25  
**维护**: dev-ocean-docker team
