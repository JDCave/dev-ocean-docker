# OpenClaw Docker 配置更新说明

## 🎯 目标

重新构建 OpenClaw Docker 镜像，满足以下需求：

1. ✅ **容器启动自动启动 gateway**
2. ✅ **端口可配置**
3. ✅ **所有 API Keys 通过环境变量配置**（不硬编码）
4. ✅ **支持配置**:
   - OpenRouter API Key
   - 飞书 App ID 和 App Secret
   - 飞书群组 ID
   - Notion API Key 和 Database ID
   - Tavily Search API Key
5. ✅ **Gateway 自动启动**（Docker 环境无需 systemd）

---

## 📁 修改的文件

### 1. `docker-compose.yaml`

**变化**:
- 使用环境变量替换硬编码值
- 添加 `OPENCLAW_GATEWAY_PORT`, `OPENCLAW_GATEWAY_BIND`
- 添加所有 API Keys 的环境变量
- 配置 `entrypoint` 和 `command`
- 添加健康检查
- 添加数据持久化 volume

**新增配置项**:
```yaml
environment:
  - OPENROUTER_API_KEY
  - TAVILY_API_KEY
  - FEISHU_APP_ID
  - FEISHU_APP_SECRET
  - FEISHU_GROUP_IDS  # 逗号分隔
  - NOTION_API_KEY
  - NOTION_DATABASE_ID
  - OPENCLAW_GATEWAY_PORT
  - OPENCLAW_GATEWAY_BIND
  - OPENCLAW_MODEL
  - OPENCLAW_WORKSPACE
```

---

### 2. `Dockerfile`

**变化**:
- 添加 `COPY entrypoint.sh /entrypoint.sh`
- 修改 `CMD ["openclaw", "gateway"]` 为 `ENTRYPOINT ["/entrypoint.sh"]` + `CMD ["gateway"]`
- 移除了不必要的 "Set default shell to bash"

**作用**: 使用 entrypoint 脚本在启动前自动生成配置文件

---

### 3. `entrypoint.sh` (新建)

**功能**:
- 检查是否已有 `openclaw.json`
- 如果没有，从环境变量生成
- 支持占位符替换，避免特殊字符问题
- 生成后设置权限（600）
- 最后 `exec openclaw "$@"` 启动 gateway

**配置模板**: 使用 `__PLACEHOLDER__` 方式，通过 `sed` 替换

**输出**: `/root/.openclaw/openclaw.json`

---

### 4. `.env.example` (新建)

**用途**: 环境变量配置模板

**包含所有必需配置**:
- OpenRouter
- Tavily
- Feishu (App ID, Secret, Group IDs)
- Notion (可选)
- Gateway 端口和绑定
- 其他 OpenClaw 配置

**使用**: `cp .env.example .env` 然后编辑填入真实值

---

### 5. `README.md` (新建)

**完整使用文档**:
- 快速开始步骤
- 各服务的配置方法（Feishu、Notion、Tavily）
- 常用命令
- 开发调试指南
- 常见问题排查
- 安全建议
- 生产部署建议

---

### 6. `.gitignore` (新建)

**保护敏感信息**:
- `.env` 文件（包含所有 API Keys）
- Docker 数据
- IDE 配置
- 日志文件

---

### 7. `quick-start.sh` (新建)

**一键启动脚本**:
- 检查 `.env` 是否存在，不存在则复制模板
- 提示用户填写配置
- 自动构建镜像（如果需要）
- 启动容器
- 显示状态和日志

**用法**: `./quick-start.sh`

---

## 🚀 **使用流程**

### 首次使用

```bash
cd /workspace/code/dev-ocean-docker/openclaw-dev-container

# 1. 复制并配置环境变量
cp .env.example .env
vim .env   # 填入所有 API Keys

# 2. 一键启动
./quick-start.sh

# 3. 验证
curl http://localhost:18789/health
docker-compose logs -f openclaw
```

### 后续重启

```bash
cd /workspace/code/dev-ocean-docker/openclaw-dev-container
docker-compose restart
```

### 修改配置

1. 编辑 `.env`
2. 重启容器: `docker-compose down && docker-compose up -d`

---

## 🔐 **安全性设计**

### 1. **Key 不硬编码**
- 所有敏感信息通过 `.env` 管理
- `.env` 在 `.gitignore` 中，不会被提交
- 镜像本身不包含任何真实 API Key

### 2. **运行时注入**
- entrypoint 在容器启动时生成配置
- 配置仅在容器内部 `/root/.openclaw/openclaw.json`
- 宿主机看不到（除非挂载了该目录）

### 3. **权限控制**
- `openclaw.json` 设置为 600（仅所有者可读写）
- 容器以 root 运行（开发环境可接受，生产建议用非 root）

---

## 📊 **配置项映射表**

| 环境变量 | 对应 openclaw.json 路径 | 必需 | 说明 |
|---------|----------------------|------|------|
| `OPENROUTER_API_KEY` | `auth.profiles.openrouter:default.apiKey` | ✅ | OpenRouter API Key |
| `TAVILY_API_KEY` | `tools.web.search.apiKey` | ✅ | Tavily Search API Key |
| `FEISHU_APP_ID` | `channels.feishu.appId` | ✅ | 飞书应用 ID |
| `FEISHU_APP_SECRET` | `channels.feishu.appSecret` | ✅ | 飞书应用 Secret |
| `FEISHU_GROUP_IDS` | `channels.feishu.groupAllowFrom[]` | ✅ | 允许的群组（逗号分隔） |
| `NOTION_API_KEY` | `skills.entries.notion.apiKey` | ❌ | Notion Integration Token |
| `NOTION_DATABASE_ID` | (Not used directly) | ❌ | 由应用代码读取环境变量 |
| `OPENCLAW_GATEWAY_PORT` | `gateway.port` | ❌ (默认 18789) | Gateway 端口 |
| `OPENCLAW_GATEWAY_BIND` | `gateway.bind` | ❌ (默认 lan) | 绑定地址 |
| `OPENCLAW_MODEL` | `agents.defaults.model.primary` | ❌ (默认 step-3.5-flash) | 默认模型 |
| `OPENCLAW_WORKSPACE` | `agents.defaults.workspace` | ❌ (默认 /root/.openclaw/workspace) | 工作空间路径 |

---

## 🐛 **自动配置原理**

```
容器启动流程:

1. Docker 启动容器
   ↓
2. ENTRYPOINT /entrypoint.sh 执行
   ↓
3. 检查 /root/.openclaw/openclaw.json 是否存在？
   ├─ 存在 → 跳过配置生成
   └─ 不存在 → 从环境变量生成
         ↓
   a. 读取所有环境变量
   b. 替换 openclaw.json.template 中的占位符
   c. 写入 /root/.openclaw/openclaw.json
   d. 设置权限 600
   ↓
4. exec openclaw gateway
   ↓
5. Gateway 启动，读取配置文件
```

---

## 🧪 **验证配置**

启动后运行：

```bash
# 查看生成的配置文件（敏感信息已隐藏）
docker-compose exec openclaw cat /root/.openclaw/openclaw.json | grep -E '"appId"|\"apiKey\"|\"port\"'

# 验证 JSON 格式
docker-compose exec openclaw python3 -c "import json; json.load(open('/root/.openclaw/openclaw.json')); print('✅ JSON valid')"

# 查看 gateway 状态
docker-compose exec openclaw openclaw gateway status

# 健康检查
curl http://localhost:18789/health
```

---

## ⚠️ **注意事项**

1. **环境变量名必须一致**：
   - 使用 `.env` 中的变量名
   - `docker-compose.yaml` 中的 `environment` 引用 `${VAR_NAME}`
   - `entrypoint.sh` 中使用 `$VAR_NAME`

2. **Feishu Group IDs 格式**：
   ```bash
   # 正确
   FEISHU_GROUP_IDS="oc_aaa,oc_bbb,oc_ccc"
   
   # 错误（带空格）
   FEISHU_GROUP_IDS="oc_aaa, oc_bbb"
   ```

3. **Notion 配置**（可选）：
   - 如果不需要 Notion，`NOTION_API_KEY` 留空即可
   - 但环境变量必须存在（值为空字符串）

4. **Gateway 端口冲突**：
   - 如果 18789 被占用，修改 `.env` 中的 `OPENCLAW_GATEWAY_PORT`
   - 例如: `OPENCLAW_GATEWAY_PORT=18889`

5. **Docker in Docker**：
   - 如果容器内需要运行 Docker，需要 `privileged: true`
   - 当前配置不需要

---

## 📦 **文件清单**

```
openclaw-dev-container/
├── Dockerfile                   # 已修改
├── docker-compose.yaml          # 已修改（新增 env 配置）
├── entrypoint.sh                # 新建（自动配置）
├── .env.example                 # 新建（配置模板）
├── .gitignore                   # 新建
├── README.md                    # 新建（完整文档）
├── quick-start.sh               # 新建（一键启动）
└── (原有文件保留)
    ├── docker_run.sh
    ├── docker_setup.sh
    └── settings.xml
```

---

## 🔄 **与原配置的兼容性**

- ✅ **向后兼容**: 如果已有 `openclaw.json`，entrypoint 会跳过生成
- ✅ **数据保留**: 挂载的 `~/.openclaw` 目录保留所有配置和数据
- ✅ **迁移简单**: 只需将原有配置中的 key 填入 `.env`，删除 `openclaw.json` 重新生成

---

## 🎉 **完成状态**

- [x] Dockerfile 修改
- [x] docker-compose.yaml 配置
- [x] entrypoint.sh 脚本
- [x] .env.example 模板
- [x] README.md 文档
- [x] .gitignore
- [x] quick-start.sh 启动脚本
- [x] 权限设置（chmod +x）
- [x] 配置文件生成逻辑（支持特殊字符转义）
- [x] 健康检查配置
- [x] 数据持久化 volume

---

## 🚦 **下一步**

1. **测试构建和启动**:
   ```bash
   cd /workspace/code/dev-ocean-docker/openclaw-dev-container
   ./quick-start.sh
   ```

2. **验证功能**:
   - Gateway 是否自动启动
   - 端口是否监听
   - 飞书消息是否能收到
   - 其他服务（Notion、Tavily）是否正常

3. **问题反馈**:
   - 查看日志: `docker-compose logs openclaw`
   - 检查配置: `docker-compose exec openclaw cat /root/.openclaw/openclaw.json`

---

**更新日期**: 2025-03-25  
**维护者**: OpenClaw Assistant
