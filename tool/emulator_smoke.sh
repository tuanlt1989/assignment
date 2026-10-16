#!/usr/bin/env bash
# Smoke test on a running Android emulator:
# install, launch, tap the main button a few times, 500 random monkey events,
# screenshots + screen recording + logcat. Fails on a native crash or ANR.
#
#   tool/emulator_smoke.sh path/to/app.apk com.tuanapps.nailvi out-dir
set -u
APK="$1"; PKG="$2"; OUT="$3"
mkdir -p "$OUT"

shot() { adb exec-out screencap -p > "$OUT/$1.png"; echo "screenshot $1"; }

adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0
adb install -r "$APK"
adb logcat -c
adb shell screenrecord --time-limit 170 /sdcard/run.mp4 &
REC=$!

adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 12
shot 01-launch

# Screen size, e.g. "Physical size: 1080x2400".
SIZE=$(adb shell wm size | tr -d '\r' | awk '{print $3}')
W=${SIZE%x*}; H=${SIZE#*x}
CX=$((W / 2))

# The main button sits near the bottom on onboarding / paywall / home.
for i in 2 3 4; do
  adb shell input tap "$CX" $((H * 88 / 100))
  sleep 3
  shot "0$i-tap"
done
adb shell input keyevent BACK; sleep 2; shot 05-back
adb shell input tap "$CX" $((H * 45 / 100)); sleep 3; shot 06-middle

# Random taps/swipes inside the app only (no system keys).
adb shell monkey -p "$PKG" --pct-syskeys 0 --pct-appswitch 0 --throttle 150 -s 42 -v 500 \
  > "$OUT/monkey.txt" 2>&1 || true
sleep 2
adb shell monkey -p "$PKG" -c android.intent.category.LAUNCHER 1 >/dev/null
sleep 4
shot 07-after-monkey

wait $REC 2>/dev/null || true
sleep 2
adb pull /sdcard/run.mp4 "$OUT/run.mp4" >/dev/null 2>&1 || true
adb logcat -d > "$OUT/logcat.txt"
grep -E "E/flutter|E flutter" "$OUT/logcat.txt" > "$OUT/flutter-errors.txt" || true

FAIL=0
if grep -qE "FATAL EXCEPTION|ANR in $PKG" "$OUT/logcat.txt"; then
  echo "::error::$PKG crashed or froze (see logcat.txt)"
  grep -A20 -E "FATAL EXCEPTION|ANR in $PKG" "$OUT/logcat.txt" | head -60
  FAIL=1
fi
if grep -q "CRASH: $PKG" "$OUT/monkey.txt"; then
  echo "::error::monkey found a crash in $PKG"
  FAIL=1
fi
if [ -s "$OUT/flutter-errors.txt" ]; then
  echo "::warning::$PKG logged Flutter errors (see flutter-errors.txt)"
  head -40 "$OUT/flutter-errors.txt"
fi
echo "result: $([ $FAIL = 0 ] && echo OK || echo FAILED)" | tee "$OUT/result.txt"
exit $FAIL
