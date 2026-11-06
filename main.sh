#!/system/bin/sh
# 主逻辑：根据配置的触发动作执行

MODDIR=$(cd "$(dirname "$0")" && pwd)
. "$MODDIR/common.sh"

load_config

case "$trigger" in
  no_signal)
    # 无信号时触发：常驻监控，检测到无信号就开关飞行模式，未恢复则按间隔重试
    min=${retry_interval%%:*}
    sec=${retry_interval##*:}
    retry_sec=$((min * 60 + sec))
    [ "$retry_sec" -lt 5 ] && retry_sec=30   # 间隔太短则兜底为 30 秒

    # 先等 SIM 解锁、首次注册尝试完成
    until sim_loaded; do sleep 3; done
    sleep "$wait_time"

    # 常驻监控循环
    while true; do
      if airplane_on; then
        # 用户主动开启飞行模式，不干预
        sleep 10
      elif ! signal_ok; then
        toggle_airplane "$airplane_duration"
        sleep "$retry_sec"
      else
        sleep 10
      fi
    done
    ;;

  first_unlock)
    # 开机后首次锁屏解锁触发
    until [ "$(getprop sys.user.0.ce_available)" = "true" ]; do
      sleep 2
    done
    sleep "$wait_time"
    toggle_airplane "$airplane_duration"
    ;;

  sim_unlock|*)
    # SIM 卡解锁后触发（默认）
    until sim_loaded; do sleep 2; done
    sleep "$wait_time"
    toggle_airplane "$airplane_duration"
    ;;
esac
