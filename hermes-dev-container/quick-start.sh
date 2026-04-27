#!/bin/bash

# Hermes Dev Container - 快速启动脚本
# 用法: ./quick-start.sh [OPTIONS]
#
# 版本控制：
#   - 默认使用 "latest" 标签
#   - 通过 --version 指定版本（如 1.0.0, 1.0.1）
#   - 自动检测本地镜像是否存在，不存在则拉取或构建
#   - 支持 --build 强制重建

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 默认参数
FORCE_BUILD=0
VERSION="${IMAGE_VERSION:-latest}"
IMAGE_NAME="hermes-dev-container"
CURRENT_VERSION_FILE=".current-version"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        --build)
            FORCE_BUILD=1
            shift
            ;;
        --version|-v)
            VERSION="$2"
            shift 2
            ;;
        -h|--help)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --build       强制重新构建镜像（即使本地存在）"
            echo "  -v, --version TAG  指定镜像版本标签（默认: latest，可通过 IMAGE_VERSION 环境变量覆盖）"
            echo "  -h, --help    显示此帮助信息"
            echo ""
            echo "示例:"
            echo "  $0                      # 使用 latest 版本（智能判断是否需要构建）"
            echo "  $0 --build            # 强制重新构建 latest 版本"
            echo "  $0 --version 1.0.1    # 使用 1.0.1 版本（如不存在则拉取或构建）"
            echo "  $0 -v 1.0.1 --build  # 强制构建 1.0.1 版本"
            echo ""
            echo "版本管理:"
            echo "  查看当前版本:  cat .current-version"
            echo "  切换版本:      $0 --version <tag>"
            echo "  构建新版本:    修改 Dockerfile 后 $0 --build --version <new-tag>"
            exit 0
            ;;
        *)
            echo "错误: 未知参数 '$1'"
            echo "使用 -h 或 --help 查看帮助"
            exit 1
            ;;
    esac
done

echo "🚀 Hermes Dev Container 快速启动"
echo "======================================"
echo "📦 目标镜像版本: $VERSION"
echo ""

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo "⚠️  未找到 .env 配置文件"
    echo "📋 从模板创建 .env ..."
    if [ -f ".env.example" ]; then
        cp .env.example .env
        echo "✅ .env 已创建"
        echo ""
        echo "⚠️  请编辑 .env 文件，确认以下配置："
        echo "   - HERMES_DATA_PATH (Hermes 数据目录)"
        echo "   - HERMES_GATEWAY_PORT (Gateway 端口)"
        echo "   - HERMES_DASHBOARD_PORT (Dashboard 端口)"
        echo "   - CODE_PATH (代码目录)"
        echo "   - SSH_PATH (SSH 密钥目录)"
        echo ""
        echo "完成后重新运行: $0"
        exit 1
    else
        echo "❌ 找不到 .env.example 模板文件"
        exit 1
    fi
fi

echo "✅ 配置文件: .env"
echo ""

# 检查 Docker 是否运行
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查端口占用
HERMES_PORT=$(grep "^HERMES_GATEWAY_PORT=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]')
HERMES_PORT=${HERMES_PORT:-8301}
DASHBOARD_PORT=$(grep "^HERMES_DASHBOARD_PORT=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]')
DASHBOARD_PORT=${DASHBOARD_PORT:-9119}

check_port() {
    local port=$1
    local name=$2
    if netstat -ano 2>/dev/null | grep -q ":${port}.*LISTEN" 2>/dev/null || \
       lsof -i :"$port" >/dev/null 2>&1; then
        echo "⚠️  端口 $port ($name) 已被占用"
        return 1
    fi
    return 0
}

PORT_CONFLICT=0
if ! check_port "$HERMES_PORT" "Gateway"; then
    PORT_CONFLICT=1
fi
if ! check_port "$DASHBOARD_PORT" "Dashboard"; then
    PORT_CONFLICT=1
fi

if [ "$PORT_CONFLICT" -eq 1 ]; then
    echo ""
    echo "解决方案："
    echo "  1. 停止占用进程"
    echo "  2. 修改 .env 中的 HERMES_GATEWAY_PORT 或 HERMES_DASHBOARD_PORT"
    echo ""
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# ===============================================
# 检查 Hermes 源代码
# ===============================================
HERMES_SOURCE_PATH="${HERMES_SOURCE_PATH:-D:/Code/opensource/NousResearch/hermes-agent}"
export HERMES_SOURCE_PATH
export DOCKERFILE_PATH="$SCRIPT_DIR/Dockerfile"

if [ ! -f "$HERMES_SOURCE_PATH/package.json" ]; then
    echo "❌ Hermes 源代码不存在: $HERMES_SOURCE_PATH"
    echo ""
    echo "请从 GitHub 克隆或下载 Hermes Agent 源码:"
    echo "  git clone --depth 1 https://github.com/NousResearch/hermes-agent.git $HERMES_SOURCE_PATH"
    echo ""
    echo "中国大陆用户可尝试代理:"
    echo "  git clone --depth 1 https://ghproxy.com/https://github.com/NousResearch/hermes-agent.git $HERMES_SOURCE_PATH"
    echo ""
    echo "或通过环境变量指定其他路径:"
    echo "  HERMES_SOURCE_PATH=/your/path $0"
    exit 1
else
    echo "✅ Hermes 源代码: $HERMES_SOURCE_PATH"
fi

# 版本管理：检查镜像
FULL_IMAGE_TAG="${IMAGE_NAME}:${VERSION}"
echo "🔍 检查镜像: $FULL_IMAGE_TAG"

if docker image inspect "$FULL_IMAGE_TAG" >/dev/null 2>&1; then
    echo "✅ 本地镜像存在"

    if [ "$FORCE_BUILD" -eq 1 ]; then
        echo "🔨 强制重建镜像..."
        docker-compose build --no-cache
    else
        echo "💡 使用现有镜像（如需重建: $0 --build）"
    fi
else
    echo "❌ 本地镜像不存在"

    # 尝试从仓库拉取
    echo "📥 尝试从 Docker registry 拉取..."
    if docker pull "$FULL_IMAGE_TAG" >/dev/null 2>&1; then
        echo "✅ 拉取成功: $FULL_IMAGE_TAG"
    else
        echo "❌ 远程仓库不存在，开始本地构建..."
        docker-compose build
        # 给构建的镜像打标签
        if [ "$VERSION" != "latest" ]; then
            docker tag "${IMAGE_NAME}:latest" "$FULL_IMAGE_TAG"
            echo "✅ 已标记为: $FULL_IMAGE_TAG"
        fi
    fi
fi

# 通过环境变量控制 docker-compose 使用的镜像版本
export DOCKER_IMAGE_TAG="${IMAGE_NAME}:${VERSION}"

# ===============================================
# 设置路径映射环境变量
# ===============================================
# Hermes 数据目录映射
export HERMES_DATA_PATH="${HERMES_DATA_PATH:-D:/Hermes}"
if [ ! -d "$HERMES_DATA_PATH" ]; then
    echo "⚠️  Hermes 数据目录不存在: $HERMES_DATA_PATH"
    echo "   将创建此目录以供 Docker 使用"
    mkdir -p "$HERMES_DATA_PATH"
fi

# 代码目录映射
export CODE_PATH="${CODE_PATH:-D:/Code}"
if [ ! -d "$CODE_PATH" ]; then
    echo "⚠️  代码目录不存在: $CODE_PATH"
    echo "   将创建此目录以供 Docker 使用"
    mkdir -p "$CODE_PATH"
fi

# SSH 密钥目录映射
if [ -n "$HOME" ]; then
    export SSH_PATH="${SSH_PATH:-$HOME/.ssh}"
    if [ ! -d "$SSH_PATH" ]; then
        echo "⚠️  SSH 目录不存在: $SSH_PATH"
        echo "   请确保您有 SSH 密钥，或创建该目录"
    fi
else
    export SSH_PATH="${SSH_PATH:-$USERPROFILE/.ssh}"
fi

echo "✅ 路径映射配置:"
echo "   - HERMES_DATA_PATH=$HERMES_DATA_PATH -> /opt/data"
echo "   - CODE_PATH=$CODE_PATH -> /workspace/code"
echo "   - SSH_PATH=$SSH_PATH -> /root/.ssh"

# 保存当前版本
echo "$VERSION" > "$CURRENT_VERSION_FILE"

echo ""
echo "🌊 启动容器..."

# 检查并清理已存在的容器
if docker ps -a --format '{{.Names}}' | grep -q "^hermes-dev-container$"; then
    echo "⚠️  检测到已存在的容器，正在清理..."
    docker-compose down -v 2>/dev/null || true
    if docker ps -a --format '{{.Names}}' | grep -q "^hermes-dev-container$"; then
        echo "🔧 强制删除残留容器..."
        docker rm -f hermes-dev-container 2>/dev/null || true
    fi
    echo "✅ 已清理旧容器"
fi

# 启动容器
docker-compose up -d

# 等待启动
echo ""
echo "⏳ 等待服务启动..."
sleep 5

# 检查状态
echo ""
echo "📊 容器状态:"
docker-compose ps

echo ""
echo "🔍 查看日志 (最后20行):"
docker-compose logs --tail=20 hermes

echo ""
echo "======================================"
echo "✅ 启动完成！"
echo ""
echo "📋 当前信息:"
echo "  镜像版本: $VERSION"
echo "  工作目录: $SCRIPT_DIR"
echo "  容器名称: hermes-dev-container"
echo ""
echo "📁 路径映射:"
echo "  主机Hermes数据 -> 容器: $HERMES_DATA_PATH -> /opt/data"
echo "  主机代码目录 -> 容器: $CODE_PATH -> /workspace/code"
echo "  主机SSH目录 -> 容器: $SSH_PATH -> /root/.ssh"
echo ""
echo "🛠️  常用命令:"
echo "  查看日志:    docker-compose logs -f hermes"
echo "  进入容器:    docker-compose exec hermes bash"
echo "  停止容器:    docker-compose down"
echo "  重启容器:    docker-compose restart"
echo ""
echo "🔄 版本管理:"
echo "  查看当前版本:  cat .current-version"
echo "  切换到其他版本: $0 --version <tag>"
echo "  强制重建:      $0 --build --version <tag>"
echo ""
echo "🌐 访问地址:"
echo "  Gateway:     http://localhost:${HERMES_PORT}"
echo "  Dashboard:   http://localhost:${DASHBOARD_PORT}"
echo ""
echo "📝 首次使用:"
echo "  1. 编辑 Hermes 配置: ${HERMES_DATA_PATH}/config.yaml"
echo "  2. 填入 LLM API Key 等配置"
echo "  3. 重启容器: docker-compose restart"
echo ""
echo "⚠️  如果遇到问题，请查看日志: docker-compose logs hermes"
