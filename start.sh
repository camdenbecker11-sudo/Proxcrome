#!/bin/bash
set -e

mkdir -p /data/profile

Xvfb :99 -screen 0 1440x900x24 &
export DISPLAY=:99
fluxbox &

VNC_PASS_FILE=/etc/x11vnc.pass
if [ -n "$VNC_PASSWORD" ]; then
  mkdir -p "$(dirname "$VNC_PASS_FILE")"
  x11vnc -storepasswd "$VNC_PASSWORD" "$VNC_PASS_FILE"
  echo "Using provided VNC password."
else
  GENERATED_PASS=$(python3 -c "import secrets; print(secrets.token_urlsafe(12))")
  mkdir -p "$(dirname "$VNC_PASS_FILE")"
  x11vnc -storepasswd "$GENERATED_PASS" "$VNC_PASS_FILE"
  echo "Generated VNC password: $GENERATED_PASS"
fi

x11vnc -display :99 -forever -rfbauth "$VNC_PASS_FILE" -shared -bg -listen 0.0.0.0 -rfbport 5900

if [ -d "/opt/noVNC" ]; then
  WEB_DIR=/opt/noVNC
else
  WEB_DIR=/usr/share/novnc
fi

if command -v websockify >/dev/null 2>&1; then
  websockify --web "$WEB_DIR" 8080 localhost:5900 &
else
  python3 /opt/noVNC/utils/websockify/run 8080 --web "$WEB_DIR" localhost:5900 &
fi

TARGET_URL="${TARGET_URL:-https://www.google.com}"
CHROME_BIN=google-chrome
$CHROME_BIN \
  --no-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --no-first-run \
  --disable-features=UseOzonePlatform \
  --user-data-dir=/data/profile \
  --start-maximized \
  "$TARGET_URL" &

wait
