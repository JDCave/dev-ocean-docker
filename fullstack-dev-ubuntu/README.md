# Fullstack Dev Ubuntu

统一的现代化全栈开发环境，提供完整的开发工具链。

## 📋 概述

这是一个基于 Ubuntu 24.04 LTS 的 Docker 开发镜像，预装了 Java、Python、Node.js、Rust 等主流开发语言和工具，适合多语言全栈开发。

---

## ✨ 特性

- ✅ **多语言支持**: Java 25, Python 3, Node 24, Rust
- ✅ **现代工具链**: Maven 3.9.12, 最新版 npm/yarn
- ✅ **镜像源优化**: 阿里云镜像加速，国内下载更快
- ✅ **开箱即用**: 所有工具预装完成，无需手动配置
- ✅ **统一环境**: 团队开发环境一致，避免 "works on my machine"
- ✅ **轻量镜像**: 基础 Ubuntu + 仅安装必要工具

---

## 📦 包含的工具

### Java / JVM
- **OpenJDK 25** (Zulu JDK)
- **Maven 3.9.12** (已配置 settings.xml 阿里云镜像)
- 环境变量: `JAVA_HOME`, `MAVEN_HOME`

### Python
- **Python 3** (含 pip)
- 别名: `python` → `python3`, `pip` → `pip3`
- 适合: Django, FastAPI, Flask, 数据科学等

### Node.js
- **Node.js 24.x** (LTS)
- **npm** (随 Node 安装)
- 适合: React, Vue, Angular, Express, Next.js

### Rust
- **rustc** + **cargo**
- 已配置 cargo 环境
- 适合: 系统编程、WebAssembly、CLI 工具

### 开发工具
- git, curl, wget, unzip, tar, vim
- build-essential, software-properties-common
- gnupg, ca-certificates

---

## 🚀 快速开始

### 1. 构建镜像

```bash
cd /workspace/code/dev-ocean-docker/fullstack-dev-ubuntu

# 赋予执行权限
chmod +x run.sh

# 构建镜像（不使用缓存）
./run.sh
```

### 2. 运行容器

```bash
# 交互式启动（推荐开发使用）
docker run -it \
  --name fullstack-dev-container \
  --restart unless-stopped \
  -v "/path/to/your/code:/workspace/code" \
  -v "/path/to/.ssh:/root/.ssh" \
  -p 3000:3000 \
  fullstack-dev-env:v1.0.1

# 后台运行
docker run -d \
  --name fullstack-dev-container \
  -v "/path/to/code:/workspace/code" \
  fullstack-dev-env:v1.0.1
```

### 3. 进入容器

```bash
docker exec -it fullstack-dev-container bash
```

---

## 🔧 卷挂载建议

| 宿主机路径 | 容器路径 | 用途 |
|-----------|---------|------|
| `~/code` | `/workspace/code` | 代码目录 |
| `~/.ssh` | `/root/.ssh` | SSH 密钥（Git 操作） |
| `~/.m2` | `/root/.m2` | Maven 本地仓库（缓存依赖） |

---

## 🌐 端口映射

- `3000` → `3000` (前端开发服务器，如 React/Vue)
- 按需添加其他端口（后端 API: 8080, DB: 5432 等）

---

## 📁 目录结构

```
fullstack-dev-ubuntu/
├── Dockerfile          # 镜像定义
├── run.sh              # 构建脚本
├── settings.xml        # Maven 配置（阿里云镜像）
└── README.md           # 本文档
```

---

## 🎯 使用场景

### 1. Java/Spring Boot 后端项目
```bash
cd /workspace/code/my-spring-project
mvn clean install
mvn spring-boot:run
```

### 2. Python 微服务
```bash
cd /workspace/code/my-python-api
pip install -r requirements.txt
python app.py
```

### 3. Node.js 前端开发
```bash
cd /workspace/code/my-react-app
npm install
npm start
```

### 4. 多语言混合项目
```bash
# 同时使用多种语言
workspace/
├── backend-java/     # Spring Boot
├── frontend-react/   # React
├── service-python/   # FastAPI
└── cli-rust/         # Rust CLI tool
```

---

## 🔍 验证安装

进入容器后，运行：

```bash
# 检查各语言版本
java -version
javac -version
mvn -version
python --version
pip --version
node -v
npm -v
rustc --version
cargo --version

# 其他工具
git --version
curl --version
vim --version
```

---

## ⚙️ 自定义配置

### 修改 Maven 配置
编辑 `settings.xml` 以更改镜像或其他 Maven 设置。

### 添加额外工具
修改 `Dockerfile`，在对应部分添加 `apt-get install` 命令。

### 更换 Node 版本
修改 `Dockerfile` 中的 `setup_24.x` 为其他版本（如 22.x, 20.x）。

---

## 📊 镜像大小

- **基础大小**: ~2GB (包含所有语言 SDK)
- **构建后**: 约 2.5GB (含缓存和临时文件)
- **运行容器**: 可增量增加（取决于项目依赖）

---

## 🐛 故障排除

### 1. Maven 下载慢
检查 `settings.xml` 是否正确配置了阿里云镜像。

### 2. 中文乱码
```bash
# 设置 UTF-8 编码
export LANG=C.UTF-8
```

### 3. 时区问题
```bash
# 查看时区
timedatectl
# 修改时区（如需）
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
```

---

## 🔄 与 openclaw-dev-container 的区别

| 特性 | fullstack-dev-ubuntu | openclaw-dev-container |
|-----|---------------------|-----------------------|
| **用途** | 通用全栈开发环境 | OpenClaw AI 助手部署 |
| **核心服务** | 无（纯工具链） | Gateway + AI 服务 |
| **预装工具** | Java, Python, Node, Rust | 仅 OpenClaw 运行时 |
| **配置方式** | 直接使用镜像 | 环境变量 + 自动生成配置 |
| **适合场景** | 多语言项目开发 | Feishu AI 助手、聊天机器人 |
| **启动方式** | `docker run` | `./quick-start.sh` |
| **端口** | 按需映射 | 固定 18789 |

---

## 📚 相关资源

- [OpenClaw 文档](https://docs.openclaw.ai)
- [Ubuntu Docker 官方镜像](https://hub.docker.com/_/ubuntu)
- [Zulu JDK](https://www.azul.com/downloads/)
- [Apache Maven](https://maven.apache.org/)
- [Node.js](https://nodejs.org/)
- [Rust](https://www.rust-lang.org/)

---

**版本**: v1.0.1  
**更新**: 2025-03-26  
**维护**: dev-ocean-docker team
