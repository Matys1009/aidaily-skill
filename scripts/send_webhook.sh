#!/bin/bash

# send_webhook.sh - 发送内容到 Webhook URL
# 用法: send_webhook.sh <webhook_url> <content_file>

set -e

WEBHOOK_URL="$1"
CONTENT_FILE="$2"

if [ -z "$WEBHOOK_URL" ] || [ -z "$CONTENT_FILE" ]; then
    echo "Usage: $0 <webhook_url> <content_file>"
    exit 1
fi

if [ ! -f "$CONTENT_FILE" ]; then
    echo "Error: Content file not found: $CONTENT_FILE"
    exit 1
fi

# 发送 POST 请求
echo "Sending content to $WEBHOOK_URL ..."

RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
    -H "Content-Type: text/markdown" \
    -H "User-Agent: aiDaily/1.0" \
    --data-binary "@$CONTENT_FILE" \
    "$WEBHOOK_URL" 2>/dev/null || echo -e "\n000")

HTTP_CODE=$(echo "$RESPONSE" | tail -n 1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" -ge 200 ] && [ "$HTTP_CODE" -lt 300 ]; then
    echo "Success: HTTP $HTTP_CODE"
    echo "Response: $BODY"
    exit 0
else
    echo "Failed: HTTP $HTTP_CODE"
    echo "Response: $BODY"
    exit 1
fi
