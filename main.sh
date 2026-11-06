#!/system/bin/sh
# 主逻辑：根据配置的触发动作执行

MODDIR=$(cd "$(dirname "$0")" && pwd)
. "$MODDIR/common.sh"

load_config

case "$trigger" in
  no_signal)
    # 无信号时触发：常驻监控，检测到无信号就开关飞行模式，未恢复则按间隔重试
    # v3.0 新增 SIM 卡检测：拔卡 / SIM 锁死时绝不切飞行模式，安静等待
    min=${retry_interval%%:*}
    sec=${retry_interval##*:}
    retry_sec=$((min * 60 + sec))
    [ "$retry_sec" -lt 5 ] && retry_sec=30   # 间隔太短则兜底为 30 秒

    # 先等 SIM 卡在位、首次注册尝试完成（无卡则一直等，不干预）
    until sim_present; do sleep 3; done
    sleep "$wait_time"

    # 常驻监控循环
    while true; do
      if airplane_on; then
        # 用户主动开启飞行模式，不干预
        sleep 10
      elif ! sim_present; then
        # SIM 拔出/未识别：切飞行模式毫无意义，等卡回来
        sleep 10
      elif ! sim_loaded; then
        # 卡在但未解锁（PIN/PUK）：等用户输 PIN，切飞行也救不了
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
