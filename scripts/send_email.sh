#!/bin/bash

# send_email.sh - 发送内容到邮箱地址
# 支持 SMTP 配置（推荐）和本地邮件命令（备用）
# 用法: send_email.sh <email_address> <subject> <content_file>

set -e

EMAIL_ADDRESS="$1"
SUBJECT="$2"
CONTENT_FILE="$3"

if [ -z "$EMAIL_ADDRESS" ] || [ -z "$SUBJECT" ] || [ -z "$CONTENT_FILE" ]; then
    echo "Usage: $0 <email_address> <subject> <content_file>"
    exit 1
fi

if [ ! -f "$CONTENT_FILE" ]; then
    echo "Error: Content file not found: $CONTENT_FILE"
    exit 1
fi

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SMTP_CONFIG="$SCRIPT_DIR/../config/smtp.conf"

echo "Sending email to $EMAIL_ADDRESS ..."

# 方案 0: 使用 Python 脚本（最可靠，支持所有 SMTP 服务器）
if command -v python3 &> /dev/null && [ -f "$SCRIPT_DIR/send_email.py" ]; then
    python3 "$SCRIPT_DIR/send_email.py" "$EMAIL_ADDRESS" "$SUBJECT" "$CONTENT_FILE"
    exit $?
fi

# 方案 1: 使用 msmtp + SMTP 配置
if command -v msmtp &> /dev/null && [ -f "$SMTP_CONFIG" ]; then
    echo "Using msmtp with SMTP configuration..."

    # 读取 SMTP 配置
    source "$SMTP_CONFIG"

    if [ -z "$SMTP_HOST" ] || [ -z "$SMTP_USER" ] || [ -z "$SMTP_PASS" ]; then
        echo "Warning: SMTP config incomplete, falling back to local mail"
    else
        # 创建临时 msmtp 配置文件
        MSMTP_CONF=$(mktemp)
        cat > "$MSMTP_CONF" << EOF
account default
host $SMTP_HOST
port ${SMTP_PORT:-587}
from ${SMTP_FROM:-$SMTP_USER}
auth on
user $SMTP_USER
password $SMTP_PASS
tls on
tls_starttls on
EOF

        # 发送邮件
        {
            echo "Subject: $SUBJECT"
            echo "To: $EMAIL_ADDRESS"
            echo "Content-Type: text/plain; charset=utf-8"
            echo ""
            cat "$CONTENT_FILE"
        } | msmtp --file="$MSMTP_CONF" "$EMAIL_ADDRESS"

        rm -f "$MSMTP_CONF"
        echo "Success: Email sent via SMTP to $EMAIL_ADDRESS"
        exit 0
    fi
fi

# 方案 2: 使用 sendemail 工具
if command -v sendemail &> /dev/null && [ -f "$SMTP_CONFIG" ]; then
    echo "Using sendemail with SMTP configuration..."

    source "$SMTP_CONFIG"

    if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_USER" ] && [ -n "$SMTP_PASS" ]; then
        sendemail -f "${SMTP_FROM:-$SMTP_USER}" \
                  -t "$EMAIL_ADDRESS" \
                  -u "$SUBJECT" \
                  -s "${SMTP_HOST}:${SMTP_PORT:-587}" \
                  -xu "$SMTP_USER" \
                  -xp "$SMTP_PASS" \
                  -o message-file="$CONTENT_FILE" \
                  -o tls=yes

        echo "Success: Email sent via SMTP to $EMAIL_ADDRESS"
        exit 0
    else
        echo "Warning: SMTP config incomplete, falling back to local mail"
    fi
fi

# 方案 3: 使用 curl + SMTP（如 Gmail API 或通用 SMTP）
if command -v curl &> /dev/null && [ -f "$SMTP_CONFIG" ]; then
    source "$SMTP_CONFIG"

    # 检查是否有 curl smtp 配置
    if [ -n "$SMTP_HOST" ] && [ -n "$SMTP_USER" ] && [ -n "$SMTP_PASS" ] && [ "$SMTP_USE_CURL" = "yes" ]; then
        echo "Using curl with SMTP configuration..."

        # 构建邮件内容
        MAIL_CONTENT=$(mktemp)
        {
            echo "Subject: $SUBJECT"
            echo "To: $EMAIL_ADDRESS"
            echo "Content-Type: text/plain; charset=utf-8"
            echo ""
            cat "$CONTENT_FILE"
        } > "$MAIL_CONTENT"

        # 使用 curl 发送
        curl -s --url "smtp://${SMTP_HOST}:${SMTP_PORT:-587}" \
             --mail-from "${SMTP_FROM:-$SMTP_USER}" \
             --mail-rcpt "$EMAIL_ADDRESS" \
             --user "$SMTP_USER:$SMTP_PASS" \
             --upload-file "$MAIL_CONTENT" \
             --ssl-reqd

        rm -f "$MAIL_CONTENT"
        echo "Success: Email sent via curl SMTP to $EMAIL_ADDRESS"
        exit 0
    fi
fi

# 方案 4: 本地邮件命令（仅适用于本地邮箱或已配置的系统）
echo "SMTP not configured. Falling back to local mail command..."

if command -v mail &> /dev/null; then
    MAIL_CMD="mail"
elif command -v sendmail &> /dev/null; then
    MAIL_CMD="sendmail"
else
    echo "Error: No mail command found."
    echo ""
    echo "To send email externally, please:"
    echo "1. Install msmtp: brew install msmtp"
    echo "2. Configure SMTP: cp config/smtp.conf.example config/smtp.conf"
    echo "3. Edit config/smtp.conf with your SMTP credentials"
    echo ""
    exit 1
fi

if [ "$MAIL_CMD" = "mail" ]; then
    cat "$CONTENT_FILE" | mail -s "$SUBJECT" "$EMAIL_ADDRESS"
else
    {
        echo "To: $EMAIL_ADDRESS"
        echo "Subject: $SUBJECT"
        echo "Content-Type: text/plain; charset=utf-8"
        echo ""
        cat "$CONTENT_FILE"
    } | sendmail "$EMAIL_ADDRESS"
fi

# 检查本地邮件是否成功（注意：本地邮件通常只能发送到本地系统）
echo "Warning: Email queued locally. May not reach external addresses without SMTP."
echo "To verify: run 'mailq' to check queue status"
exit 0
