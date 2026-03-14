#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/bun/bin:/opt/opencode/bin:${PATH}"

# Show opencode version first
echo "Opencode version - $(opencode --version)"

# ------------------------------ Start opencode ------------------------------
opencode --log-level "${OPENCODE_DEBUG_LEVEL:-INFO}" serve &

OPENCODE_PID=$!
echo "Spawned opencode (PID=${OPENCODE_PID})"

echo "Waiting 5s for opencode to become ready..."
sleep 5

# ------------------------------ Start opencode ------------------------------
opencode web --port 3001 --hostname 0.0.0.0 --log-level "${OPENCODE_DEBUG_LEVEL:-INFO}" &

OPENCODE_WEB_PID=$!
echo "Spawned opencode web (PID=${OPENCODE_WEB_PID})"

echo "Waiting 5s for opencode to become ready..."
sleep 5

# ------------------------------ Start openchamber -------------------------
openchamber &
OPENCHAMBER_PID=$!
echo "Spawned openchamber (PID=${OPENCHAMBER_PID})"

echo "Waiting 5s for openchamber to become ready..."
sleep 5

# ------------------------------ Cleanup handling -----------------------
cleanup() {
  echo "Caught signal, shutting down"

  # Let openchamber finish first (graceful stop)
  if kill -0 "$OPENCHAMBER_PID" 2>/dev/null; then
    echo "Stopping openchamber (PID=${OPENCHAMBER_PID})"
    kill -TERM "$OPENCHAMBER_PID"
    wait "$OPENCHAMBER_PID" 2>/dev/null || true
  fi

  # Then kill opencode web
  if kill -0 "$OPENCODE_WEB_PID" 2>/dev/null; then
    echo "Stopping opencode (PID=${OPENCODE_WEB_PID})"
    kill -TERM "$OPENCODE_WEB_PID"
    wait "$OPENCODE_WEB_PID" 2>/dev/null || true
  fi

  # Then kill opencode
  if kill -0 "$OPENCODE_PID" 2>/dev/null; then
    echo "Stopping opencode (PID=${OPENCODE_PID})"
    kill -TERM "$OPENCODE_PID"
    wait "$OPENCODE_PID" 2>/dev/null || true
  fi

  exit 0
}
trap cleanup SIGINT SIGTERM

# ------------------------------ Main wait loop --------------------------
# Wait for either process to exit. If one falls, the other will be torn down by the trap.
wait -n $OPENCODE_PID $OPENCHAMBER_PID $OPENCODE_WEB_PID
caught=$?
echo "One of the services exited (status $caught); shutting down"

# Give the trap a chance to do its cleanup
kill -TERM $$

