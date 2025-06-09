#!/bin/bash
# Listens on a Unix socket for URLs and opens them.

SOCKET_PATH="/tmp/local-open.sock"
LOG_FILE="/tmp/local-open.log" # For debugging and logging

# Ensure the socket is clean before starting
rm -f "$SOCKET_PATH"

echo "$(date): Starting URL handler listener on $SOCKET_PATH" >> "$LOG_FILE"

# The core logic: listen and open URLs
while read line; do
    echo "$(date): Received URL: $line" >> "$LOG_FILE"
    open "$line"
done < <(nc -klU "$SOCKET_PATH") # -k for keep-alive, -l for listen, -U for Unix domain socket

echo "$(date): URL handler listener stopped unexpectedly." >> "$LOG_FILE"
