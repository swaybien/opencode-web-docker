#!/bin/bash
set -e

# 如果不存在 .chsrced 文件且 DISABLE_CHSRC 不为 true，执行 chsrc 设置 | If .chsrced file doesn't exist and DISABLE_CHSRC is not true, execute chsrc setup
if [ ! -f "/home/node/.chsrced" ] && [ "$DISABLE_CHSRC" != "true" ] && [ "$DISABLE_CHSRC" != "1" ]; then
    chsrc set cargo && chsrc set node && chsrc set debian && touch "/home/node/.chsrced"
fi

# 构建启动参数 | Build arguments array for opencode web
args=()

# 端口 | Port configuration
PORT=${OPENCODE_SERVER_PORT:-4096}
args+=("--port" "$PORT")

# 主机名 | Hostname configuration
HOSTNAME=${OPENCODE_SERVER_HOSTNAME:-0.0.0.0}
args+=("--hostname" "$HOSTNAME")

# 局域网多播 DNS | mDNS configuration
if [ "$OPENCODE_SERVER_MDNS" = "true" ] || [ "$OPENCODE_SERVER_MDNS" = "1" ]; then
    args+=("--mdns")
    if [ -n "$OPENCODE_SERVER_MDNS_DOMAIN" ]; then
        args+=("--mdns-domain" "$OPENCODE_SERVER_MDNS_DOMAIN")
    fi
fi

# CORS
if [ -n "$OPENCODE_SERVER_CORS" ]; then
    # 多个项 | Split by comma if multiple domains provided
    IFS=',' read -ra cors_domains <<< "$OPENCODE_SERVER_CORS"
    for domain in "${cors_domains[@]}"; do
        args+=("--cors" "$domain")
    done
fi

# 用户名密码验证通过环境传入并 | Authentication is handled via environment variables OPENCODE_SERVER_USERNAME and OPENCODE_SERVER_PASSWORD
# 自动应用 | OpenCode automatically picks these up, no need to pass as arguments.

echo "Starting OpenCode web server with arguments: ${args[@]}"

# 修复挂载卷的权限（如果以 root 身份运行）| Fix permission of home if I am root
if [ "$(id -u)" = "0" ]; then
    chown -R node:node /home/node 2>/dev/null || true
fi

# 使用 gosu 以 node 用户身份运行 opencode web | Run opencode web as node
exec gosu node opencode web "${args[@]}"
