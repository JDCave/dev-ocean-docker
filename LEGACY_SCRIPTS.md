# 遗留脚本说明

## 概述

本目录下包含一些历史遗留的脚本，这些脚本**已废弃**，仅供参考。当前推荐使用 `quick-start.sh` 作为唯一的启动入口。

---

## 废弃脚本列表

### 1. `docker_run.sh` ⚠️ Windows 专用（已过时）

**原用途**: 在 Windows 环境下启动 OpenClaw 容器

**问题**:
- 硬编码 Windows 路径（`C:/Users`, `D:/Code`）
- 在 Linux/macOS 上不可用
- 不支持版本控制
- 不支持环境变量配置

**替代方案**: 使用 `./quick-start.sh`

---

### 2. `docker_setup.sh` ⚠️ 配置脚本（已合并）

**原用途**: 初始环境设置

**现状**: 功能已集成到 `quick-start.sh` 的首次运行时检查

**替代方案**: `./quick-start.sh` 会自动创建 `.env` 文件

---

## 迁移指南

### 如果你之前使用 `docker_run.sh`

**旧方式**:
```bash
./docker_run.sh
```

**新方式**:
```bash
./quick-start.sh
```

### 如果你需要指定版本

```bash
# 使用特定版本
./quick-start.sh --version 1.0.1

# 强制重建
./quick-start.sh --build --version 1.0.1
```

---

## 为什么废弃这些脚本？

1. **平台不统一**: `docker_run.sh` 仅适用于 Windows
2. **功能重复**: 启动逻辑分散，现在统一到 `quick-start.sh`
3. **版本管理缺失**: 旧脚本无法管理多个镜像版本
4. **配置复杂**: 需要手动编辑多个文件，现在通过 `.env` 统一管理

---

## 当前推荐的工作流

```bash
# 1. 首次使用：复制环境变量模板
cp .env.example .env
vim .env  # 填入 API Keys

# 2. 启动容器（使用 latest 版本）
./quick-start.sh

# 3. 后续操作
./quick-start.sh --build              # 重建当前版本
./quick-start.sh --version 1.0.1     # 切换到 1.0.1
```

---

**注意**: 保留这些旧脚本仅作为历史参考，未来版本可能会删除。
