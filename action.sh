#!/system/bin/sh
# action.sh：Magisk 模块「操作」按钮，打开配置 WebUI

MODDIR=$(cd "$(dirname "$0")" && pwd)
PORT=8765
BB=/data/adb/magisk/busybox

# 确保 HTTP 服务已运行
if ! pgrep -f "httpd.*$PORT" >/dev/null 2>&1; then
  "$BB" httpd -p "127.0.0.1:$PORT" -h "$MODDIR/webroot" >/dev/null 2>&1 &
  sleep 1
fi

# 打开配置页
am start -a android.intent.action.VIEW -d "http://127.0.0.1:$PORT/" >/dev/null 2>&1
