#!/usr/bin/env python3
"""
使用 Python 发送邮件，支持 SMTP 认证
用法: python3 send_email.py <email_address> <subject> <content_file>
"""

import sys
import os
import smtplib
import ssl
from email.mime.text import MIMEText
from email.header import Header

def load_smtp_config(config_path):
    """加载 SMTP 配置文件"""
    config = {}
    if os.path.exists(config_path):
        with open(config_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    config[key.strip()] = value.strip()
    return config

def send_email_smtp(to_email, subject, content_file, config):
    """使用 SMTP 发送邮件"""
    host = config.get('SMTP_HOST', 'smtp.qq.com')
    port = int(config.get('SMTP_PORT', 587))
    user = config.get('SMTP_USER')
    password = config.get('SMTP_PASS')
    from_email = config.get('SMTP_FROM', user)

    if not all([user, password]):
        raise ValueError("SMTP 配置不完整，需要 SMTP_USER 和 SMTP_PASS")

    # 读取邮件内容
    with open(content_file, 'r', encoding='utf-8') as f:
        content = f.read()

    # 创建邮件
    msg = MIMEText(content, 'plain', 'utf-8')
    msg['Subject'] = Header(subject, 'utf-8')
    msg['From'] = from_email
    msg['To'] = to_email

    # 连接 SMTP 服务器并发送
    context = ssl.create_default_context()

    try:
        with smtplib.SMTP(host, port) as server:
            server.starttls(context=context)
            server.login(user, password)
            server.sendmail(from_email, [to_email], msg.as_string())
        print(f"Success: Email sent to {to_email}")
        return True
    except smtplib.SMTPAuthenticationError as e:
        print(f"Error: Authentication failed - {e}")
        print("请检查：")
        print("1. 授权码是否正确（注意不是邮箱密码）")
        print("2. SMTP服务是否已开启")
        print("3. 对于QQ邮箱，需要生成16位应用授权码")
        return False
    except Exception as e:
        print(f"Error: {e}")
        return False

def main():
    if len(sys.argv) != 4:
        print("Usage: python3 send_email.py <email_address> <subject> <content_file>")
        sys.exit(1)

    to_email = sys.argv[1]
    subject = sys.argv[2]
    content_file = sys.argv[3]

    if not os.path.exists(content_file):
        print(f"Error: Content file not found: {content_file}")
        sys.exit(1)

    # 获取配置文件路径
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_path = os.path.join(script_dir, '..', 'config', 'smtp.conf')

    # 加载配置
    config = load_smtp_config(config_path)

    if not config:
        print("Error: SMTP config not found")
        print(f"Please create {config_path}")
        sys.exit(1)

    # 发送邮件
    success = send_email_smtp(to_email, subject, content_file, config)
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
