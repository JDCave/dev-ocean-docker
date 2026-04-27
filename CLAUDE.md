# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A collection of Docker-based development environments targeting Chinese-optimized infrastructure. Two containers:

1. **openclaw-dev-container** — OpenClaw AI assistant gateway with Feishu, Notion, and Tavily integrations. Based on `ghcr.io/openclaw/openclaw:latest`, adds Java 25, Maven, Python, Node 24, Rust, and Go tooling.
2. **fullstack-dev-ubuntu** — Universal multi-language dev environment on Ubuntu 24.04 with Java 25, Python, Node 24, Rust (no Go).

Both use Aliyun mirrors for apt, Maven, and npm where applicable.

## Common Commands

### OpenClaw Dev Container

```bash
cd openclaw-dev-container

# Initial setup
cp .env.example .env    # then fill in API keys

# Start (recommended)
./quick-start.sh                        # latest version
./quick-start.sh --version 1.0.1        # specific version
./quick-start.sh --build                # force rebuild

# Runtime management
docker-compose up -d                    # start in background
docker-compose down                     # stop and remove
docker-compose logs -f openclaw         # follow logs
docker-compose exec openclaw bash       # shell into container
docker-compose exec openclaw openclaw gateway status

# Health check
curl http://localhost:18789/health
```

### Fullstack Dev Container

```bash
cd fullstack-dev-ubuntu
docker build -t fullstack-dev-env:v1.0.1 .
docker run -it -v "$HOME/code:/workspace/code" fullstack-dev-env:v1.0.1
```

## Architecture

### Configuration Pipeline (openclaw-dev-container)

```
.env (user-edited, gitignored)
  → docker-compose.yaml (injects env vars into container)
    → entrypoint.sh (generates openclaw.json from env vars on first run)
      → openclaw gateway (reads generated config)
```

- `entrypoint.sh` only generates `openclaw.json` if it doesn't already exist. To force regeneration, delete the config or wipe the volume.
- `quick-start.sh` manages version tagging (`DOCKER_IMAGE_TAG`), path mapping env vars (`OPENCLAW_CONFIG_PATH`, `CODE_PATH`, `SSH_PATH`), port conflict detection, and container cleanup before start.
- `docker-compose.yaml` uses variable substitution (`${VAR:-default}`) for all configurable values.

### Volume Mappings (openclaw-dev-container)

| Host path (env var) | Container path | Purpose |
|---|---|---|
| `${OPENCLAW_CONFIG_PATH:-D:/OpenClaw}` | `/root/.openclaw` | Config, workspace, logs |
| `${CODE_PATH:-D:/Code}` | `/root/.openclaw/workspace/code` | Source code |
| `${SSH_PATH:-$HOME/.ssh}` | `/root/.ssh` | SSH keys for git |

### Version Management

- `.current-version` tracks the active image tag
- Image name: `openclaw-dev-container:<version>`
- Override via `--version` flag or `IMAGE_VERSION` env var

## Key Conventions

- **Windows host paths**: The project is developed on Windows with WSL/Docker. Volume mount paths use Windows-style (e.g., `D:/OpenClaw`). `quick-start.sh` handles path mapping via env vars.
- **CRLF handling**: `entrypoint.sh` has a `sed -i 's/\r$//'` step in the Dockerfile to convert Windows line endings.
- **Bilingual content**: Comments and user-facing output mix Chinese and English. Maintain both languages when editing documentation (README.md / README_zh.md).
- **Deprecated scripts**: `docker_run.sh` and `docker_setup.sh` are legacy — always use `quick-start.sh`.
- **No tests**: This is an infrastructure/containers repo. There are no test suites. Validation is done via health checks and manual `curl` commands.
- **Package mirrors**: All Dockerfiles use Aliyun mirrors. Preserve these when modifying package installation steps.

## Environment Variables Reference

Required in `.env` for openclaw-dev-container: `OPENROUTER_API_KEY`, `TAVILY_API_KEY`, `FEISHU_APP_ID`, `FEISHU_APP_SECRET`, `FEISHU_GROUP_IDS` (comma-separated, no spaces).

Optional: `NOTION_API_KEY`, `NOTION_DATABASE_ID`, `OPENCLAW_GATEWAY_PORT` (default 18789), `OPENCLAW_GATEWAY_BIND`, `OPENCLAW_MODEL`, `OPENCLAW_WORKSPACE`.

## Build Args (openclaw-dev-container Dockerfile)

`BUILD_DATE`, `VERSION`, `REVISION` — passed via `docker-compose build` or `docker build --build-arg`.
