#!/bin/sh
set -e
# Railway 注入 PORT；本地测试默认 8080
PORT="${PORT:-8080}"
UUID="${VLESS_UUID:-2bf20ab5-bbd6-40d6-9d23-b5a6ef676a19}"
WS_PATH="${VLESS_WS_PATH:-ws}"

cat > /app/config.json <<EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [{ "id": "${UUID}", "flow": "" }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": { "path": "/${WS_PATH}" }
      }
    }
  ],
  "outbounds": [{ "protocol": "freedom", "tag": "direct" }]
}
EOF

echo "[xray] listening on port ${PORT}, ws path /${WS_PATH}, uuid ${UUID}"
exec /usr/local/bin/xray run -c /app/config.json
