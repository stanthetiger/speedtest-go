#!/bin/sh
set -eu
cd /app
: "${GID:=1000} ${UID:=1000}"
getent group speedtest >/dev/null || addgroup -g "${GID}" speedtest
getent passwd speedtest >/dev/null || adduser -h /data -s /bin/sh -G speedtest -D -u "${UID}" speedtest
chown -R speedtest:speedtest /app /config
[ -f /config/settings.toml ] || mv /app/settings.toml /config/
[ -f /app/assets/index.html ] || mv /app/assets-default /app/assets
exec su-exec speedtest:speedtest "$@"