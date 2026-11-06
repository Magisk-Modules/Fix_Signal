#!/system/bin/sh
# CGI 后端：读取/保存配置
# 读取：GET config.sh
# 保存：GET config.sh?set=1&trigger=xxx&wait_time=N&airplane_duration=N&retry_interval=xx:xx

CFG=/data/adb/modules/fix_signal_auto/config

echo "Content-Type: application/json"
echo ""

if [ -z "$QUERY_STRING" ]; then
  # 读取配置
  trigger=$(grep -m1 '^trigger=' "$CFG" 2>/dev/null | cut -d= -f2)
  wait_time=$(grep -m1 '^wait_time=' "$CFG" 2>/dev/null | cut -d= -f2)
  airplane_duration=$(grep -m1 '^airplane_duration=' "$CFG" 2>/dev/null | cut -d= -f2)
  retry_interval=$(grep -m1 '^retry_interval=' "$CFG" 2>/dev/null | cut -d= -f2)
  [ -z "$trigger" ] && trigger=sim_unlock
  [ -z "$wait_time" ] && wait_time=5
  [ -z "$airplane_duration" ] && airplane_duration=6
  [ -z "$retry_interval" ] && retry_interval="5:00"
  echo "{\"trigger\":\"$trigger\",\"wait_time\":$wait_time,\"airplane_duration\":$airplane_duration,\"retry_interval\":\"$retry_interval\"}"
else
  # 保存配置
  trigger=$(echo "$QUERY_STRING" | grep -oE 'trigger=[^&]*' | cut -d= -f2)
  wait_time=$(echo "$QUERY_STRING" | grep -oE 'wait_time=[^&]*' | cut -d= -f2)
  airplane_duration=$(echo "$QUERY_STRING" | grep -oE 'airplane_duration=[^&]*' | cut -d= -f2)
  retry_interval=$(echo "$QUERY_STRING" | grep -oE 'retry_interval=[^&]*' | cut -d= -f2)

  # 校验并兜底
  case "$trigger" in sim_unlock|no_signal|first_unlock) ;; *) trigger=sim_unlock ;; esac
  case "$wait_time" in [5-9]|1[0-5]) ;; *) wait_time=5 ;; esac
  case "$airplane_duration" in [3-9]) ;; *) airplane_duration=6 ;; esac
  case "$retry_interval" in [0-9]:[0-5][0-9]|[0-5][0-9]:[0-5][0-9]) ;; *) retry_interval="5:00" ;; esac

  printf 'trigger=%s\nwait_time=%s\nairplane_duration=%s\nretry_interval=%s\n' \
    "$trigger" "$wait_time" "$airplane_duration" "$retry_interval" > "$CFG"

  echo "{\"ok\":true,\"trigger\":\"$trigger\",\"wait_time\":$wait_time,\"airplane_duration\":$airplane_duration,\"retry_interval\":\"$retry_interval\"}"
fi
