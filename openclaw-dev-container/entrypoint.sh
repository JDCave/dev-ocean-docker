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

    # 生成 openclaw.json
    # 使用 cat + envsubst 避免特殊字符问题
    cat > "$CONFIG_FILE.template" << 'EOF'
{
  "meta": {
    "lastTouchedVersion": "2026.3.13",
    "lastTouchedAt": "__CURRENT_TIME__"
  },
  "wizard": {
    "lastRunAt": null,
    "lastRunVersion": null,
    "lastRunCommand": null,
    "lastRunMode": null
  },
  "auth": {
    "profiles": {
      "openrouter:default": {
        "provider": "openrouter",
        "mode": "api_key",
        "apiKey": "__OPENROUTER_API_KEY__"
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "__OPENCLAW_MODEL__"
      },
      "models": {
        "openrouter/auto": {
          "alias": "OpenRouter"
        },
        "openrouter/stepfun/step-3.5-flash:free": {}
      },
      "workspace": "__OPENCLAW_WORKSPACE__",
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
        "provider": "tavily",
        "apiKey": "__TAVILY_API_KEY__"
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
      "appId": "__FEISHU_APP_ID__",
      "appSecret": "__FEISHU_APP_SECRET__",
      "connectionMode": "websocket",
      "domain": "feishu",
      "groupPolicy": "allowlist",
      "groupAllowFrom": __FEISHU_GROUP_IDS__
    }
  },
  "gateway": {
    "port": __OPENCLAW_GATEWAY_PORT__,
    "mode": "local",
    "bind": "__OPENCLAW_GATEWAY_BIND__",
    "controlUi": {
      "allowedOrigins": [
        "http://localhost:__OPENCLAW_GATEWAY_PORT__",
        "http://127.0.0.1:__OPENCLAW_GATEWAY_PORT__"
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
        "apiKey": "__NOTION_API_KEY__"
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

    # 替换占位符
    CURRENT_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    sed -i "s|__CURRENT_TIME__|$CURRENT_TIME|g" "$CONFIG_FILE.template"
    sed -i "s|__OPENROUTER_API_KEY__|${OPENROUTER_API_KEY}|g" "$CONFIG_FILE.template"
    sed -i "s|__OPENCLAW_MODEL__|${OPENCLAW_MODEL:-openrouter/stepfun/step-3.5-flash:free}|g" "$CONFIG_FILE.template"
    sed -i "s|__OPENCLAW_WORKSPACE__|${OPENCLAW_WORKSPACE:-/root/.openclaw/workspace}|g" "$CONFIG_FILE.template"
    sed -i "s|__TAVILY_API_KEY__|${TAVILY_API_KEY}|g" "$CONFIG_FILE.template"
    sed -i "s|__FEISHU_APP_ID__|${FEISHU_APP_ID}|g" "$CONFIG_FILE.template"
    sed -i "s|__FEISHU_APP_SECRET__|${FEISHU_APP_SECRET}|g" "$CONFIG_FILE.template"
    sed -i "s|__FEISHU_GROUP_IDS__|${GROUP_JSON}|g" "$CONFIG_FILE.template"
    sed -i "s|__OPENCLAW_GATEWAY_PORT__|${OPENCLAW_GATEWAY_PORT:-18789}|g" "$CONFIG_FILE.template"
    sed -i "s|__OPENCLAW_GATEWAY_BIND__|${OPENCLAW_GATEWAY_BIND:-lan}|g" "$CONFIG_FILE.template"
    sed -i "s|__NOTION_API_KEY__|${NOTION_API_KEY:-}|g" "$CONFIG_FILE.template"

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

# 设置权限
chmod 600 /root/.openclaw/openclaw.json

echo ""
echo "=========================================="
echo "Starting OpenClaw Gateway..."
echo "=========================================="

# 执行启动命令
exec openclaw "$@"