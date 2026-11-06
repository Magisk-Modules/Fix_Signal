#!/system/bin/sh
# 公共函数库

MODDIR=$(cd "$(dirname "$0")" && pwd)
CFG="$MODDIR/config"

# 读取配置（配置文件为 key=value 格式，直接 source）
load_config() {
  trigger="sim_unlock"
  wait_time=5
  airplane_duration=6
  retry_interval="5:00"
  [ -f "$CFG" ] && . "$CFG"
  # 数值兜底
  [ "$wait_time" -lt 1 ] 2>/dev/null && wait_time=5
  [ "$airplane_duration" -lt 1 ] 2>/dev/null && airplane_duration=6
}

# 开关一次飞行模式（参数：飞行模式持续时间，秒）
toggle_airplane() {
  local dur="$1"
  [ -z "$dur" ] && dur=6
  settings put global airplane_mode_on 1
  am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true >/dev/null 2>&1
  sleep "$dur"
  settings put global airplane_mode_on 0
  am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
}

# 检测 SIM 是否已解锁
sim_loaded() {
  getprop gsm.sim.state 2>/dev/null | grep -q "LOADED"
}

# 检测是否有信号（注册到运营商 = 有信号）
signal_ok() {
  local alpha
  alpha=$(getprop gsm.operator.alpha 2>/dev/null | tr -d ',')
  [ -n "$alpha" ] && [ "$alpha" != "null" ] && [ "$alpha" != "" ]
}

# 检测是否处于飞行模式（1 = 开启）
airplane_on() {
  [ "$(settings get global airplane_mode_on 2>/dev/null)" = "1" ]
}
