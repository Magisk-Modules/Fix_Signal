#!/system/bin/sh
# Auto-fix signal after boot: toggle airplane mode once SIM is unlocked.
# Fixes "no signal after reboot" caused by CS-domain (2G/3G) registration
# being rejected after the carrier retired 2G/3G.

# Wait for full boot
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 3
done

# Wait for SIM to be unlocked (LOADED), up to 5 minutes
COUNT=0
until getprop gsm.sim.state 2>/dev/null | grep -q "LOADED" || [ "$COUNT" -ge 150 ]; do
  sleep 2
  COUNT=$((COUNT+1))
done

# Give the first registration attempt a moment, then force re-register
sleep 5

settings put global airplane_mode_on 1
am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true >/dev/null 2>&1
sleep 6
settings put global airplane_mode_on 0
am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false >/dev/null 2>&1
