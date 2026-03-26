# OpenClaw Development Container

基于 Docker 的 OpenClaw 开`发环境，支持自动配置和启动。

## ✨ 特性

- ✅ **一键启动**: 自动配置 all-in-one 环境
- ✅ **环境变量配置**: 所有敏感信息通过 env 注入，不硬编码
- ✅ **自动生成配置**: 容器启动时自动创建 `openclaw.json`
- ✅ **Gateway 自动启动**: 容器运行即服务
- ✅ **数据持久化**: 配置和数据保存在宿主机
- ✅ **健康检查**: 自动监控服务状态
- ✅ **版本管理**: 支持多版本镜像切换

## 📋 前置要求

- Docker (20.10+)
- Docker Compose (2.0+)

## 🚀 快速开始

### 1. 配置环境变量

```bash
cd /workspace/code/dev-ocean-docker

# 复制模板（从 openclaw-dev-container 目录）
cp openclaw-dev-container/.env.example .env

# 编辑 .env，填入你的 API Keys
vim .env
```

**必需配置项**:
- `OPENROUTER_API_KEY` - OpenRouter API key
- `TAVILY_API_KEY` - Tavily Search API key
- `FEISHU_APP_ID` - 飞书应用 ID
- `FEISHU_APP_SECRET` - 飞书应用 Secret
- `FEISHU_GROUP_IDS` - 允许的群组 ID（多个用逗号分隔）

**可选配置**:
- `NOTION_API_KEY` - Notion Integration token
- `NOTION_DATABASE_ID` - Notion Database ID（用于笔记存储）
- `OPENCLAW_GATEWAY_PORT` - 网关端口（默认 18789）
- `OPENCLAW_MODEL` - 默认模型（默认 step-3.5-flash）
- `OPENCLAW_WORKSPACE` - 工作空间路径（默认 /root/.openclaw/workspace）

### 2. 启动容器

```bash
# 进入容器目录
cd /workspace/code/dev-ocean-docker/openclaw-dev-container

# 使用 quick-start 脚本（推荐）
./quick-start.sh

# 使用特定版本
./quick-start.sh --version 1.0.1

# 强制重建镜像
./quick-start.sh --build --version 1.0.1

# 查看帮助
./quick-start.sh --help
```

### 3. 验证启动

```bash
# 查看日志
docker-compose logs -f openclaw

# 健康检查
curl http://localhost:18789/health

# 查看状态
docker-compose exec openclaw openclaw gateway status
```

## 🔧 配置说明

### 环境变量详解

| 变量名 | 必需 | 默认值 | 说明 |
|--------|------|--------|------|
| `OPENROUTER_API_KEY` | ✅ | - | OpenRouter API key，用于 LLM 访问 |
| `TAVILY_API_KEY` | ✅ | - | Tavily Search API key，用于网络搜索 |
| `FEISHU_APP_ID` | ✅ | - | 飞书应用 ID |
| `FEISHU_APP_SECRET` | ✅ | - | 飞书应用 Secret |
| `FEISHU_GROUP_IDS` | ✅ | - | 允许的群组 ID，逗号分隔 |
| `NOTION_API_KEY` | ❌ | - | Notion Integration token（如不需要可留空） |
| `NOTION_DATABASE_ID` | ❌ | - | Notion Database ID（如不需要可留空） |
| `OPENCLAW_GATEWAY_PORT` | ❌ | 18789 | Gateway 监听端口 |
| `OPENCLAW_GATEWAY_BIND` | ❌ | lan | 绑定地址（lan/localhost/all） |
| `OPENCLAW_MODEL` | ❌ | step-3.5-flash | 默认模型 ID |
| `OPENCLAW_WORKSPACE` | ❌ | /root/.openclaw/workspace | 工作空间路径 |

**版本控制变量**:
- `DOCKER_IMAGE_TAG` - 指定镜像标签（如 `openclaw-dev-container:1.0.1`），quick-start.sh 会自动设置

### Feishu 配置步骤

1. 访问 [飞书开放平台](https://open.feishu.cn/)
2. 创建「企业内部应用」
3. 在「凭证与基础信息」获取：
   - App ID
   - App Secret
4. 在「权限管理」添加以下权限：
   - 接收消息 (im.message)
   - 发送消息 (im.message)
5. 在「订阅事件」添加：
   - `im.message.message_read`
   - `im.message.message_created`
6. 在「机器人」页面安装应用到指定群组
7. 复制群组 ID（从群组设置页 URL 中获取）

### Notion 配置步骤（可选）

1. 访问 [Notion Integrations](https://www.notion.so/my-integrations)
2. 创建新 Integration，记录 API Key
3. 在 Notion 中创建 Database，记录 Database ID
4. 在 Database 页面：`...` → `Add connections` → 选择你的 Integration
5. 赋予 `Can edit` 权限

### Tavily 配置步骤

1. 访问 [Tavily](https://tavily.com) 并注册
2. 在 Dashboard 获取 API Key
3. 添加到 `.env` 文件

## 📁 文件结构

```
dev-ocean-docker/
├── README.md                    # 主文档（使用说明）
├── CHANGES.md                   # 更新日志
├── LEGACY_SCRIPTS.md            # 废弃脚本说明
├── openclaw-dev-container/      # Docker 镜像目录
│   ├── Dockerfile               # 镜像定义
│   ├── docker-compose.yaml      # 服务编排
│   ├── entrypoint.sh            # 容器启动脚本
│   ├── .env.example             # 环境变量模板
│   ├── quick-start.sh           # 一键启动脚本
│   ├── docker_run.sh            # 遗留脚本（废弃）
│   ├── docker_setup.sh          # 遗留脚本（废弃）
│   ├── settings.xml             # Maven 设置
│   └── data/                    # 持久化数据目录（自动创建）
├── fullstack-dev-ubuntu/        # 其他 Docker 配置（备用）
├── local_test/                  # 本地测试脚本和数据
│   └── (包含测试脚本、日志和镜像备份)
├── .gitignore
└── docker-registry.json
```

## 🔄 版本管理

### 查看当前版本

```bash
cat .current-version
```

### 启动特定版本

```bash
# 使用 1.0.1 版本
./quick-start.sh --version 1.0.1

# 或通过环境变量
IMAGE_VERSION=1.0.1 ./quick-start.sh
```

### 构建新版本

1. 修改 `Dockerfile` 或其他文件
2. 构建并打标签：
```bash
./quick-start.sh --build --version 1.0.1
```
这会：
- 构建镜像（latest）
- 自动标记为 `openclaw-dev-container:1.0.1`
- 启动容器

### 版本切换流程

```bash
# 1. 停止当前容器
docker-compose down

# 2. 启动新版本
./quick-start.sh --version 1.0.1

# 3. 验证
cat .current-version  # 应显示 1.0.1
```

### 镜像管理命令

```bash
# 列出所有本地镜像
docker images openclaw-dev-container

# 删除旧版本
docker rmi openclaw-dev-container:1.0.0

# 推送版本到远程仓库（可选）
docker tag openclaw-dev-container:1.0.1 your-registry/openclaw-dev-container:1.0.1
docker push your-registry/openclaw-dev-container:1.0.1
```

## 🛠️ 开发调试

### 查看 Gateway 状态

```bash
# 进入容器
docker-compose exec openclaw bash

# 查看状态
openclaw gateway status

# 查看详细日志（容器内）
cat /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# 或从宿主机查看（如果挂载了日志）
tail -f ~/.openclaw/openclaw-$(date +%Y-%m-%d).log
```

### 调试配置文件

```bash
# 检查生成的配置文件
docker-compose exec openclaw cat /root/.openclaw/openclaw.json

# 验证 JSON 格式
docker-compose exec openclaw python3 -c "import json; json.load(open('/root/.openclaw/openclaw.json')); print('✅ JSON valid')"
```

### 重新配置

如果修改了 `.env` 文件，需要重启容器：

```bash
docker-compose down
./quick-start.sh  # 或 docker-compose up -d
```

注意：已存在的 `openclaw.json` 不会被覆盖（除非删除）。

## 🌐 访问地址

- **Gateway API**: http://localhost:18789
- **Control UI**: http://localhost:18789 (如果启用)
- **SSE Events**: http://localhost:18789/events

## 🐛 常见问题

### 1. 容器启动失败，提示端口占用

解决：修改 `.env` 中的 `OPENCLAW_GATEWAY_PORT`，或停止占用端口的进程

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

## 🚢 生产部署建议

1. **使用 production 镜像**：基于 `ghcr.io/openclaw/openclaw:stable`
2. **配置反向代理**：Nginx/Traefik 处理 HTTPS
3. **持久化存储**: 使用 Docker volume 或 external storage
4. **监控告警**: 设置 healthcheck 和日志收集
5. **密钥管理**: 使用 Docker secrets 或 vault

## 📦 项目模块说明

### 1. openclaw-dev-container

OpenClaw 的官方开发容器镜像，提供一键配置和自动启动的集成环境。

- **用途**: 快速部署 OpenClaw 网关服务，适合开发、测试和生产
- **核心特性**:
  - 环境变量自动生成配置文件
  - Gateway 自动启动
  - 数据持久化
  - 版本管理支持
  - 健康检查
- **技术栈**: 基于 OpenClaw 官方镜像，预装所有依赖
- **使用场景**: AI 助手服务部署、Feishu 集成等
- **文档**: 见本 README 快速开始章节

### 2. fullstack-dev-ubuntu

通用全栈开发环境，提供完整的现代化开发工具链。

- **用途**: 统一的开发环境，支持多语言全栈开发
- **已安装工具**:
  - **Java**: OpenJDK 25 (Zulu) + Maven 3.9.12
  - **Python**: Python3 + pip
  - **Node.js**: Node 24.x + npm
  - **Rust**: rustc + cargo
  - **开发工具**: git, curl, wget, unzip, tar, vim, build-essential 等
- **基础镜像**: Ubuntu 24.04 LTS
- **优化**: 使用阿里云镜像源加速，包含 Maven settings.xml 配置
- **使用场景**:
  - Java/Spring 后端开发
  - Python/Django/FastAPI 服务
  - Node.js/React/Vue 前端
  - Rust 应用开发
  - 多语言混合项目
- **快速启动**:
  ```bash
  # 构建镜像
  cd fullstack-dev-ubuntu
  ./run.sh
  ```
- **工作目录**: `/workspace` (默认)
- **卷挂载**: 建议挂载代码目录到 `/workspace/code`
- **端口**: 可根据需要映射（如 3000 用于前端开发服务器）

## 📚 相关资源

- OpenClaw 文档: https://docs.openclaw.ai
- OpenClaw GitHub: https://github.com/openclaw/openclaw
- Feishu 开发者文档: https://open.feishu.cn/document
- Notion API 文档: https://developers.notion.com
- Tavily API 文档: https://docs.tavily.com

## 🧪 测试与验证

### 基本检查

```bash
# 检查容器是否在运行
docker ps | grep openclaw-dev-container

# 进入容器（bash）
docker exec -it openclaw-dev-container bash

# 执行 OpenClaw 初始化（首次）
openclaw onboard --install-daemon

# 查看 Gateway 状态
openclaw gateway status

# 查看应用状态
openclaw status
```

### Web UI 访问

Gateway 启动后，可通过浏览器访问：

```
http://localhost:18789/#token=YOUR_TOKEN
```

Token 可在 `~/.openclaw/workspace/.auth token` 或通过 `openclaw gateway token` 获取。

---

**版本**: 1.0.0+  
**更新**: 2025-03-25  
**维护**: OpenClaw Team
