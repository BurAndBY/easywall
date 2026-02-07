#!/usr/bin/env sh
set -eu

JAR_PATH="${1:-}"
LOG_PATH="${2:-$HOME/.config/waywall/ninjabrain.log}"

if [ -z "$JAR_PATH" ] || [ ! -f "$JAR_PATH" ]; then
  echo "[ninbot_launch] jar missing: $JAR_PATH" >> "$LOG_PATH"
  exit 1
fi

if pgrep -f '[j]ava .*Ninjabrain.*\.jar' >/dev/null 2>&1; then
  exit 0
fi

nohup java -Dawt.useSystemAAFontSettings=on -jar "$JAR_PATH" >> "$LOG_PATH" 2>&1 &
exit 0
