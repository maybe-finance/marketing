#!/usr/bin/env bash

TARGET_URL="https://maybefinance.com/assets/tailwind-57c42a8a.css"
OUTPUT_DIR="./tailwind_failures"
mkdir -p "$OUTPUT_DIR"

while true; do
  TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
  RESPONSE_FILE="$OUTPUT_DIR/response_$TIMESTAMP.log"
  HEADER_FILE="$OUTPUT_DIR/headers_$TIMESTAMP.log"

  echo "----- $TIMESTAMP -----"
  STATUS=$(curl -s -w "%{http_code}" -D "$HEADER_FILE" -o "$RESPONSE_FILE" "$TARGET_URL")

  echo "Status: $STATUS"

  if [[ "$STATUS" == "500" || "$STATUS" == "502" ]]; then
    echo "⚠️  Failure logged at $TIMESTAMP"
    echo "Response body in: $RESPONSE_FILE"
    echo "Headers in:       $HEADER_FILE"
  else
    # Clean up successful requests to save space
    rm -f "$RESPONSE_FILE" "$HEADER_FILE"
  fi

  sleep 1
done