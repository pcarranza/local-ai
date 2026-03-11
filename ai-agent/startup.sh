#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/bun/bin:/opt/opencode/bin:${PATH}"

# ------------------------------ Start opencode ------------------------------
opencode serve &

OPENCODE_PID=$!
echo "Spawned opencode (PID=${OPENCODE_PID})"

# Basic “wait for ready” hook – adjust or replace with a proper health check.
# For example, you could poll a specific port with `nc` or a custom script.
echo "Waiting 5s for opencode to become ready..."
sleep 5

# ------------------------------ Start opencode ------------------------------
opencode web --port 3001 --hostname 0.0.0.0 &

OPENCODE_WEB_PID=$!
echo "Spawned opencode web (PID=${OPENCODE_WEB_PID})"

# Basic “wait for ready” hook – adjust or replace with a proper health check.
# For example, you could poll a specific port with `nc` or a custom script.
echo "Waiting 5s for opencode to become ready..."
sleep 5

# ------------------------------ Start openchamber -------------------------
openchamber &
OPENCHAMBER_PID=$!
echo "Spawned openchamber (PID=${OPENCHAMBER_PID})"

# ------------------------------ Cleanup handling -----------------------
cleanup() {
  echo "Caught signal, shutting down…"

  # Let openchamber finish first (graceful stop)
  if kill -0 "$OPENCHAMBER_PID" 2>/dev/null; then
    echo "Stopping openchamber (PID=${OPENCHAMBER_PID})…"
    kill -TERM "$OPENCHAMBER_PID"
    wait "$OPENCHAMBER_PID" 2>/dev/null || true
  fi

  # Then kill opencode web
  if kill -0 "$OPENCODE_WEB_PID" 2>/dev/null; then
    echo "Stopping opencode (PID=${OPENCODE_WEB_PID})…"
    kill -TERM "$OPENCODE_WEB_PID"
    wait "$OPENCODE_WEB_PID" 2>/dev/null || true
  fi

  # Then kill opencode
  if kill -0 "$OPENCODE_PID" 2>/dev/null; then
    echo "Stopping opencode (PID=${OPENCODE_PID})…"
    kill -TERM "$OPENCODE_PID"
    wait "$OPENCODE_PID" 2>/dev/null || true
  fi

  exit 0
}
trap cleanup SIGINT SIGTERM

# ------------------------------ Main wait loop --------------------------
# Wait for either process to exit. If one falls, the other will be torn down by the trap.
wait -n $OPENCODE_PID $OPENCHAMBER_PID
caught=$?
echo "One of the services exited (status $caught); shutting down…"

# Give the trap a chance to do its cleanup
kill -TERM $$

