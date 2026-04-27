# dev-ocean-docker

A collection of Docker development environments including OpenClaw AI assistant deployment and fullstack development tools.

## 📋 Overview

This repository contains multiple Docker-based development environments:

1. **openclaw-dev-container** — OpenClaw AI assistant gateway with Feishu, Notion, and Tavily integrations
2. **hermes-dev-container** — Hermes AI agent development environment with full toolchain
3. **fullstack-dev-ubuntu** — Universal fullstack development environment with modern toolchains

---

## 🚀 Quick Start

### openclaw-dev-container (OpenClaw AI Assistant)

The OpenClaw development container provides an all-in-one environment for deploying AI assistant services with Feishu, Notion, and more integrations.

#### Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)

#### 1. Configure Environment Variables

```bash
cd /workspace/code/dev-ocean-docker/openclaw-dev-container

# Copy template
cp .env.example .env

# Edit .env and fill in your API Keys
vim .env
```

**Required configuration**:
- `OPENROUTER_API_KEY` - OpenRouter API key
- `TAVILY_API_KEY` - Tavily Search API key
- `FEISHU_APP_ID` - Feishu App ID
- `FEISHU_APP_SECRET` - Feishu App Secret
- `FEISHU_GROUP_IDS` - Allowed group IDs (comma-separated)

**Optional configuration**:
- `NOTION_API_KEY` - Notion Integration token
- `NOTION_DATABASE_ID` - Notion Database ID (for notes storage)
- `OPENCLAW_GATEWAY_PORT` - Gateway port (default: 18789)
- `OPENCLAW_MODEL` - Default model (default: step-3.5-flash)
- `OPENCLAW_WORKSPACE` - Workspace path (default: /root/.openclaw/workspace)

#### 2. Start Container

```bash
# Using quick-start script (recommended)
./quick-start.sh

# Use specific version
./quick-start.sh --version 1.0.1

# Force rebuild image
./quick-start.sh --build --version 1.0.1

# Show help
./quick-start.sh --help
```

#### 3. Verify Startup

```bash
# View logs
docker-compose logs -f openclaw

# Health check
curl http://localhost:18789/health

# Check status
docker-compose exec openclaw openclaw gateway status
```

---

### hermes-dev-container (Hermes AI Agent)

A development environment for [Hermes Agent](https://github.com/NousResearch/hermes-agent) with a complete multi-language toolchain.

#### Prerequisites

- Docker (20.10+)
- Docker Compose (2.0+)
- Hermes Agent source code cloned locally

#### 1. Get Source Code

```bash
git clone --depth 1 https://github.com/NousResearch/hermes-agent.git D:/Code/opensource/NousResearch/hermes-agent
```

#### 2. Configure Environment Variables

```bash
cd hermes-dev-container

# Copy template
cp .env.example .env

# Edit .env and adjust paths
vim .env
```

**Configuration**:

| Variable | Default | Description |
|----------|---------|-------------|
| `HERMES_SOURCE_PATH` | `D:/Code/opensource/NousResearch/hermes-agent` | Hermes source code path |
| `HERMES_DATA_PATH` | `D:/Hermes` | Data directory (config, logs, sessions) |
| `HERMES_GATEWAY_PORT` | `8301` | Gateway port |
| `HERMES_DASHBOARD_PORT` | `9119` | Dashboard port |
| `CODE_PATH` | `D:/Code` | Source code directory |
| `SSH_PATH` | `$HOME/.ssh` | SSH keys directory |

#### 3. Start Container

```bash
# Build and start
./quick-start.sh --build

# Start with specific version
./quick-start.sh --version 2026.04.26

# Force rebuild
./quick-start.sh --build --version 2026.04.26

# Show help
./quick-start.sh --help
```

#### 4. Verify Startup

```bash
# View logs
docker-compose logs -f hermes

# Check status
docker-compose ps

# Enter container
docker exec -it hermes-dev-container bash

# Run hermes command (inside container)
hermes --version
```

#### Volume Mappings

| Host path | Container path | Purpose |
|---|---|---|
| `D:/Hermes` | `/opt/data` | Config, logs, sessions |
| `D:/Code` | `/opt/data/workspace/code` | Source code |
| `$HOME/.ssh` | `/root/.ssh` | SSH keys |

#### Installed Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Java (Azul Zulu JDK) | 25 | Enterprise backend |
| Maven | 3.9.15 | Build management |
| Python + uv | 3.13 | Runtime + package manager |
| Node.js | 24.x | Frontend / Full-stack |
| Rust | latest | Systems programming |
| Go | 1.26.1 | Cloud-native tools |

---

### fullstack-dev-ubuntu (Universal Development Environment)

A complete fullstack development environment with modern toolchains for multi-language development.

#### Key Features

- **Multi-language support**: Java 25, Python 3, Node 24, Rust
- **Complete toolchain**: Maven 3.9.12, npm/yarn, cargo
- **Optimized mirrors**: Aliyun mirrors for faster downloads in China
- **Ready-to-use**: All tools pre-installed, no additional setup needed

#### Included Tools

| Language/Tool | Version | Purpose |
|--------------|---------|---------|
| Java (OpenJDK Zulu) | 25 | Enterprise backend development |
| Maven | 3.9.12 | Build and dependency management |
| Python | 3.x | Data science / Web backend |
| Node.js | 24.x | Frontend / Full-stack development |
| Rust | latest | Systems programming / WASM |
| Others | git, curl, vim... | Daily development tools |

#### Quick Start

1. **Build Image**
   ```bash
   cd /workspace/code/dev-ocean-docker/fullstack-dev-ubuntu

   # Using run script
   ./run.sh  # builds and saves to tar (optional upload)

   # Or using Docker directly
   docker build -t fullstack-dev-env:v1.0.1 .
   ```

2. **Run Container**
   ```bash
   # Interactive mode (recommended for development)
   docker run -it \
     --name fullstack-dev-container \
     -v "$HOME/code:/workspace/code" \
     -v "$HOME/.ssh:/root/.ssh" \
     -p 3000:3000 \
     fullstack-dev-env:v1.0.1

   # Background mode
   docker run -d \
     --name fullstack-dev \
     -v "$HOME/code:/workspace/code" \
     fullstack-dev-env:v1.0.1
   ```

3. **Verify Installation**
   ```bash
   java -version
   mvn -version
   python --version
   node -v
   rustc --version
   ```

#### Typical Use Cases

**Java/Spring Project**
```bash
cd /workspace/code/spring-app
mvn clean install
mvn spring-boot:run
```

**Python Project**
```bash
cd /workspace/code/python-api
pip install -r requirements.txt
python app.py
```

**Node.js Project**
```bash
cd /workspace/code/react-app
npm install
npm start
```

**Multi-language Projects**
```
/workspace/code/
├── backend-spring/   # Java
├── frontend-vue/     # Node.js
├── service-python/   # Python
└── tool-rust/        # Rust
```

#### Volume Mount Recommendations

```bash
# Code directory
-v "/path/to/code:/workspace/code"

# SSH keys (for Git operations)
-v "$HOME/.ssh:/root/.ssh"

# Maven local repository (cache acceleration)
-v "$HOME/.m2:/root/.m2"
```

---

## 📁 Project Structure

```
dev-ocean-docker/
├── README.md                    # Main documentation (English)
├── README_zh.md                 # Chinese documentation
├── CHANGES.md                   # Changelog
├── CLAUDE.md                    # Claude Code project instructions
├── openclaw-dev-container/      # OpenClaw Docker image
│   ├── Dockerfile               # Image definition
│   ├── docker-compose.yaml      # Service orchestration
│   ├── entrypoint.sh            # Container startup script
│   ├── .env.example             # Environment variables template
│   └── quick-start.sh           # One-click startup script
├── hermes-dev-container/        # Hermes Agent Docker image
│   ├── Dockerfile               # Image definition (extends Hermes source)
│   ├── docker-compose.yaml      # Service orchestration
│   ├── .env.example             # Environment variables template
│   └── quick-start.sh           # One-click startup script
├── fullstack-dev-ubuntu/        # Fullstack development environment
│   ├── Dockerfile               # Image definition
│   └── run.sh                   # Build script
├── .gitignore
└── .claude/                     # Claude Code config
```

---

## 🔧 Configuration Reference

### Environment Variables (openclaw-dev-container)

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `OPENROUTER_API_KEY` | ✅ | - | OpenRouter API key for LLM access |
| `TAVILY_API_KEY` | ✅ | - | Tavily Search API key for web search |
| `FEISHU_APP_ID` | ✅ | - | Feishu application ID |
| `FEISHU_APP_SECRET` | ✅ | - | Feishu application secret |
| `FEISHU_GROUP_IDS` | ✅ | - | Allowed group IDs (comma-separated) |
| `NOTION_API_KEY` | ❌ | - | Notion Integration token (optional) |
| `NOTION_DATABASE_ID` | ❌ | - | Notion Database ID (optional) |
| `OPENCLAW_GATEWAY_PORT` | ❌ | 18789 | Gateway listening port |
| `OPENCLAW_GATEWAY_BIND` | ❌ | lan | Bind address (lan/localhost/all) |
| `OPENCLAW_MODEL` | ❌ | step-3.5-flash | Default model ID |
| `OPENCLAW_WORKSPACE` | ❌ | /root/.openclaw/workspace | Workspace path |

---

## 📖 Module Documentation

### openclaw-dev-container

**Purpose**: Quickly deploy OpenClaw gateway service for development, testing, and production.

**Key Features**:
- Automatic config generation from environment variables
- Gateway auto-start (foreground mode for Docker)
- Data persistence (config, workspace, logs)
- Version management (multi-tag images)
- Health check monitoring

**Ports & Services**:
- Gateway API: `http://localhost:18789`
- Web UI: `http://localhost:18789` (requires token)
- SSE Events: `http://localhost:18789/events`

**Data Persistence**:
- Host `~/.openclaw/` → Container `/root/.openclaw/`
- Includes configs, workspace data, logs, etc.

**Common Issues**:
- Config changes not applying: Container's existing `openclaw.json` won't be overwritten; delete it or restart container
- Port already in use: Change `OPENCLAW_GATEWAY_PORT` in `.env`
- Not receiving Feishu messages: Check if app is installed in group, verify `FEISHU_GROUP_IDS`, check logs

---

### fullstack-dev-ubuntu

**Purpose**: Unified development environment supporting multi-language fullstack development.

**Base Image**: Ubuntu 24.04 LTS

**Installed Languages & Tools**:
- Java 25 (OpenJDK Zulu) + Maven 3.9.12
- Python 3 + pip
- Node.js 24.x + npm
- Rust (rustc + cargo)
- Development tools: git, curl, wget, unzip, tar, vim, build-essential, etc.

**Optimizations**:
- Aliyun mirror sources for faster package downloads
- Pre-configured Maven settings.xml with Aliyun mirrors
- Default workspace: `/workspace`

**Use Cases**:
- Java/Spring backend development
- Python/Django/FastAPI services
- Node.js/React/Vue frontend
- Rust application development
- Multi-language hybrid projects

**Image Size**:
- Base: ~2GB
- Built: ~2.5GB (including cache)
- Running container: varies by project dependencies

---

## 🔄 Version Management (openclaw-dev-container)

```bash
# Check current version
cat .current-version

# Start specific version
./quick-start.sh --version 1.0.1

# Build new version
./quick-start.sh --build --version 1.0.1
```

---

## 🛠️ Development & Debugging

### View Gateway Status

```bash
# Enter container
docker-compose exec openclaw bash

# Check gateway status
openclaw gateway status

# View logs (inside container)
cat /tmp/openclaw/openclaw-$(date +%Y-%m-%d).log

# Or from host (if logs are mounted)
tail -f ~/.openclaw/openclaw-$(date +%Y-%m-%d).log
```

### Debug Configuration

```bash
# Check generated config
docker-compose exec openclaw cat /root/.openclaw/openclaw.json

# Validate JSON format
docker-compose exec openclaw python3 -c "import json; json.load(open('/root/.openclaw/openclaw.json')); print('✅ JSON valid')"
```

---

## 🌐 Access URLs

- **Gateway API**: http://localhost:18789
- **Control UI**: http://localhost:18789 (if enabled)
- **SSE Events**: http://localhost:18789/events

---

## 🐛 Troubleshooting

### 1. Container fails to start due to port in use
**Solution**: Change `OPENCLAW_GATEWAY_PORT` in `.env` or stop the process using the port.

### 2. "API key invalid" error
Check that API keys in `.env` are copied correctly without extra whitespace.

### 3. Not receiving Feishu messages
- Verify App ID and Secret are correct
- Confirm app is installed in the group
- Ensure `FEISHU_GROUP_IDS` contains correct group IDs
- Check logs: `docker-compose logs openclaw | grep -i feishu`

### 4. Notion write fails
- Ensure Notion API Key is from Integration (not user token)
- Confirm Database is shared with Integration (`Can edit`)
- Verify `NOTION_DATABASE_ID` is correct

### 5. Gateway won't start (systemd issue in Docker)
This container is optimized for Docker; gateway runs in foreground. If you see:
```
Runtime: unknown (systemctl not available)
```
This is normal—systemd is not supported inside Docker, but gateway still starts normally.

---

## 🔒 Security Recommendations

1. **Protect .env file**:
   ```bash
   chmod 600 .env
   echo ".env" >> .gitignore  # Ensure not committed
   ```

2. **Rotate API Keys regularly**:
   - OpenRouter: every 90 days
   - Tavily: per provider policy
   - Feishu: long-lived credentials, handle with care

3. **Restrict container permissions**:
   - Consider non-root user for production
   - Limit network access (outbound only if possible)

---

## 📊 Performance Tuning

### Adjust Resource Limits

In `docker-compose.yaml`:

```yaml
services:
  openclaw:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

### Adjust Gateway Port Mapping

```yaml
ports:
  - "18789:18789"  # host:container
```

---

## 🚢 Production Deployment Recommendations

1. **Use production image**: Based on `ghcr.io/openclaw/openclaw:stable`
2. **Configure reverse proxy**: Nginx/Traefik for HTTPS
3. **Persistent storage**: Use Docker volumes or external storage
4. **Monitoring & alerts**: Set up healthchecks and log collection
5. **Secrets management**: Use Docker secrets or vault

---

## 📚 Related Resources

- [OpenClaw Documentation](https://docs.openclaw.ai)
- [OpenClaw GitHub](https://github.com/openclaw/openclaw)
- [Feishu Developer Docs](https://open.feishu.cn/document)
- [Notion API Docs](https://developers.notion.com)
- [Tavily API Docs](https://docs.tavily.com)

---

**Version**: 1.0.0+  
**Last Updated**: 2025-03-25  
**Maintainer**: dev-ocean-docker team
