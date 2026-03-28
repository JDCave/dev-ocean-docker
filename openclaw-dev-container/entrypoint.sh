#!/bin/bash
set -e

echo "=========================================="
echo "OpenClaw Development Container"
echo "=========================================="

# 创建配置目录
mkdir -p /root/.openclaw

# 配置文件路径
CONFIG_FILE="/root/.openclaw/openclaw.json"

# 如果配置文件已存在，跳过生成
if [ -f "$CONFIG_FILE" ]; then
    echo "✅ 配置文件已存在: $CONFIG_FILE"
else
    echo "🔧 从环境变量生成配置文件..."

    # 提取 Feishu Group IDs（逗号分隔的数组）
    IFS=',' read -ra GROUP_ARR <<< "$FEISHU_GROUP_IDS"
    GROUP_JSON="["
    for i in "${!GROUP_ARR[@]}"; do
        if [ $i -gt 0 ]; then
            GROUP_JSON+=","
        fi
        # 转义双引号等
        GROUP_JSON+="\"${GROUP_ARR[$i]}\""
    done
    GROUP_JSON+="]"

    # 计算当前时间（用于占位符替换）
    CURRENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    # 生成 openclaw.json
    # 使用 cat + envsubst 避免特殊字符问题
    cat > "$CONFIG_FILE.template" << EOF
{
  "meta": {
    "lastTouchedVersion": "2026.3.23",
    "lastTouchedAt": "$CURRENT_TIME"
  },
  "wizard": {
    "lastRunAt": "$CURRENT_TIME",
    "lastRunVersion": "2026.3.23",
    "lastRunCommand": "gateway",
    "lastRunMode": "local"
  },
  "auth": {
    "profiles": {
      "openrouter:default": {
        "provider": "openrouter",
        "mode": "api_key"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "${OPENCLAW_MODEL:-openrouter/stepfun/step-3.5-flash:free}"
      },
      "models": {
        "openrouter/auto": {
          "alias": "OpenRouter"
        },
        "openrouter/stepfun/step-3.5-flash:free": {}
      },
      "workspace": "${OPENCLAW_WORKSPACE:-/root/.openclaw/workspace}",
      "compaction": {
        "mode": "safeguard"
      }
    }
  },
  "tools": {
    "profile": "coding",
    "web": {
      "search": {
        "enabled": true,
        "provider": "tavily"
      }
    }
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true,
    "ownerDisplay": "raw"
  },
  "session": {
    "dmScope": "per-channel-peer"
  },
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "command-logger": {
          "enabled": true
        },
        "session-memory": {
          "enabled": true
        }
      }
    }
  },
  "channels": {
    "feishu": {
      "enabled": true,
      "appId": "$FEISHU_APP_ID",
      "appSecret": "$FEISHU_APP_SECRET",
      "connectionMode": "websocket",
      "domain": "feishu",
      "groupPolicy": "allowlist",
      "groupAllowFrom": $GROUP_JSON
    }
  },
  "gateway": {
    "port": ${OPENCLAW_GATEWAY_PORT:-18789},
    "mode": "local",
    "bind": "${OPENCLAW_GATEWAY_BIND:-lan}",
    "controlUi": {
      "allowedOrigins": [
        "http://localhost:${OPENCLAW_GATEWAY_PORT:-18789}",
        "http://127.0.0.1:${OPENCLAW_GATEWAY_PORT:-18789}"
      ]
    },
    "auth": {
      "mode": "token",
      "token": "auto-generated-on-first-run"
    },
    "tailscale": {
      "mode": "off",
      "resetOnExit": false
    },
    "nodes": {
      "denyCommands": [
        "camera.snap",
        "camera.clip",
        "screen.record",
        "contacts.add",
        "calendar.add",
        "reminders.add",
        "sms.send"
      ]
    }
  },
  "skills": {
    "install": {
      "nodeManager": "npm"
    },
    "entries": {
      "notion": {
        "enabled": true,
        "apiKey": "${NOTION_API_KEY:-}"
      }
    }
  },
  "plugins": {
    "allow": ["feishu"],
    "entries": {
      "feishu": {
        "enabled": true
      }
    }
  }
}
EOF

    # 移动为最终配置
    mv "$CONFIG_FILE.template" "$CONFIG_FILE"

    echo "✅ 配置文件生成完成: $CONFIG_FILE"
    echo "📋 配置摘要:"
    echo "   - OpenRouter API Key: ****${OPENROUTER_API_KEY: -4}"
    echo "   - Tavily API Key: ****${TAVILY_API_KEY: -4}"
    echo "   - Feishu App ID: $FEISHU_APP_ID"
    echo "   - Feishu Groups: $FEISHU_GROUP_IDS"
    echo "   - Gateway Port: ${OPENCLAW_GATEWAY_PORT:-18789}"
    echo "   - Notion: $([ -n "$NOTION_API_KEY" ] && echo "已配置" || echo "未配置")"
fi

# 确保数据目录存在
mkdir -p /root/.openclaw/data

# 配置 SSH 目录权限（如果存在）
if [ -d "/root/.ssh" ]; then
    chmod 700 /root/.ssh
    if [ -f "/root/.ssh/id_rsa" ]; then
        chmod 600 /root/.ssh/id_rsa
    fi
    if [ -f "/root/.ssh/id_rsa.pub" ]; then
        chmod 644 /root/.ssh/id_rsa.pub
    fi
fi

# 设置权限
chmod 600 /root/.openclaw/openclaw.json

echo ""
echo "=========================================="
echo "Starting OpenClaw Gateway..."
echo "=========================================="

# 执行启动命令
exec openclaw "$@"