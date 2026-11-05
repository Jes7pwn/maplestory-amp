#!/usr/bin/env bash
# Start command for the AMP instance: brings Cosmic up, streams its log to AMP's console,
# and stops the server cleanly on AMP's "stop" (written to stdin) or a TERM/INT signal.
cd "$(dirname "$0")/.." || exit 1
DC=(docker compose -f docker-compose.yml)

stop_server() {
    echo "Stopping Cosmic..."
    kill "$LOGS" 2>/dev/null
    "${DC[@]}" stop -t 30 maplestory
    exit 0
}
trap stop_server TERM INT

"${DC[@]}" up -d --build maplestory || exit 1
"${DC[@]}" logs -f --no-log-prefix --no-color --since 1s maplestory &
LOGS=$!

while true; do
    read -r -t 2 line; rc=$?
    if (( rc == 0 )); then
        [[ "$line" == "stop" ]] && stop_server
    elif (( rc <= 128 )); then
        sleep 2 & wait $!    # stdin closed: keep waiting for a signal
    fi
    kill -0 "$LOGS" 2>/dev/null || { echo "Cosmic container exited"; exit 1; }
done
