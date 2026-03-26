#!/bin/bash

# OpenClaw Dev Container - 快速启动脚本（最终版）
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
VERSION="${IMAGE_VERSION:-latest}"  # 支持环境变量覆盖
IMAGE_NAME="openclaw-dev-container"
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

echo "🚀 OpenClaw Dev Container 快速启动"
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
        echo "⚠️  请编辑 .env 文件，填入你的 API Keys："
        echo "   - OPENROUTER_API_KEY"
        echo "   - TAVILY_API_KEY"
        echo "   - FEISHU_APP_ID"
        echo "   - FEISHU_APP_SECRET"
        echo "   - FEISHU_GROUP_IDS"
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
OPENCLAW_PORT=$(grep "^OPENCLAW_GATEWAY_PORT=" .env 2>/dev/null | cut -d'=' -f2 | tr -d '[:space:]')
OPENCLAW_PORT=${OPENCLAW_PORT:-18789}

if lsof -i :"$OPENCLAW_PORT" >/dev/null 2>&1; then
    echo "⚠️  端口 $OPENCLAW_PORT 已被占用"
    echo "占用进程："
    lsof -i :"$OPENCLAW_PORT" || true
    echo ""
    echo "解决方案："
    echo "  1. 停止占用进程"
    echo "  2. 修改 .env 中的 OPENCLAW_GATEWAY_PORT"
    echo ""
    read -p "是否继续？(y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
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
export OPENCLAW_PORT="$OPENCLAW_PORT"

# 保存当前版本
echo "$VERSION" > "$CURRENT_VERSION_FILE"

echo ""
echo "🌊 启动容器..."

# 检查并清理已存在的容器
if docker ps -a --format '{{.Names}}' | grep -q "^openclaw-dev-container$"; then
    echo "⚠️  检测到已存在的容器，正在清理..."
    docker-compose down || true
    echo "✅ 已清理旧容器"
fi

# docker-compose 会自动使用环境变量 DOCKER_IMAGE_TAG
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
docker-compose logs --tail=20 openclaw

# 测试 Gateway 健康检查
echo ""
echo "🏥 健康检查..."
if curl -s -f "http://localhost:${OPENCLAW_PORT}/health" > /dev/null 2>&1; then
    echo "✅ Gateway 健康: http://localhost:${OPENCLAW_PORT}/health"
else
    echo "⚠️  Gateway 健康检查失败，请查看日志"
fi

echo ""
echo "======================================"
echo "✅ 启动完成！"
echo ""
echo "📋 当前信息:"
echo "  镜像版本: $VERSION"
echo "  工作目录: $SCRIPT_DIR"
echo "  容器名称: openclaw-dev-container"
echo ""
echo "🛠️  常用命令:"
echo "  查看日志:    docker-compose logs -f openclaw"
echo "  进入容器:    docker-compose exec openclaw bash"
echo "  查看状态:    docker-compose exec openclaw openclaw gateway status"
echo "  停止容器:    docker-compose down"
echo "  重启容器:    docker-compose restart"
echo ""
echo "🔄 版本管理:"
echo "  查看当前版本:  cat .current-version"
echo "  切换到其他版本: $0 --version <tag>"
echo "  强制重建:      $0 --build --version <tag>"
echo ""
echo "🌐 访问地址:"
echo "  Gateway:     http://localhost:${OPENCLAW_PORT}"
echo ""
echo "📚 文档:"
echo "  README:      $(pwd)/README.md"
echo "  变更记录:    $(pwd)/CHANGES.md"
echo ""
echo "⚠️  如果遇到问题，请查看日志: docker-compose logs openclaw"
