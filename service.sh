#!/system/bin/sh
# service.sh：启动 WebUI 的 HTTP 服务 + 主逻辑

MODDIR=$(cd "$(dirname "$0")" && pwd)
PORT=8765
BB=/data/adb/magisk/busybox

# 启动 HTTP 服务（提供 WebUI 静态页 + /cgi-bin/ 配置读写）
"$BB" httpd -p "127.0.0.1:$PORT" -h "$MODDIR/webroot" >/dev/null 2>&1 &

# 启动主逻辑（后台，根据触发动作执行）
"$MODDIR/main.sh" >/dev/null 2>&1 &
