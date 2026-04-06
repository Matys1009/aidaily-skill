# aiDaily Skill for Claude Code

aiDaily 是一个 Claude Code Skill，用于自动整理和汇总 AI 领域的最新资讯，生成精美的卡片式 HTML 日报。

## 功能特性

- **自动获取** - 从多个权威 AI 资讯源获取最新文章
- **智能整理** - 自动提取标题、日期和摘要（100-200字）
- **卡片式展示** - 生成精美的 HTML 邮件格式，支持多种主题色
- **一键发送** - 支持发送到指定邮箱或 Webhook
- **多源支持** - 默认支持 5 大 AI 资讯源，可自定义添加

## 默认资讯源

| 来源 | 名称 | URL |
|------|------|-----|
| @claude | Anthropic Claude | https://claude.com/blog |
| @openai | OpenAI Developer | https://developers.openai.com/blog |
| @deepmind | Google DeepMind | https://deepmind.google/blog/ |
| @huggingface | Hugging Face | https://huggingface.co/blog |
| @googleai | Google Research | https://research.google/blog/ |

## 系统要求

- **Claude Code** - 最新版本
- **Python 3.6+** - 用于邮件发送脚本（通常系统已预装）
- **curl** - 用于 Webhook 发送（macOS/Linux 自带）

## 安装步骤

### 1. 克隆到 Claude Code skills 目录

```bash
git clone https://github.com/YOUR_USERNAME/aidaily-skill.git ~/.claude/skills/aidaily
```

### 2. 配置 SMTP（可选，如需邮件功能）

```bash
# 复制配置模板
cp ~/.claude/skills/aidaily/config/smtp.conf.example ~/.claude/skills/aidaily/config/smtp.conf

# 编辑配置文件，填入你的 SMTP 信息
# 支持 QQ、Gmail、163、企业邮箱等
```

### 3. 开始使用

在 Claude Code 中说出以下任意一句话即可触发：

- "帮我整理今日的ai资讯"
- "整理每日ai资讯"
- "今天有什么ai新闻"
- "获取ai日报"

## 使用示例

### 基础使用

```
用户: 帮我整理今日的ai资讯
Claude: [生成卡片式 HTML 日报，包含 5 个来源的最新资讯]
```

### 发送到指定邮箱

```
用户: 帮我整理今日的ai资讯，发送到 admin@company.com
Claude: [整理资讯 → 发送 HTML 邮件到指定地址]
```

### 发送到 Webhook

```
用户: 整理ai资讯，推送到 https://hooks.slack.com/services/xxx
Claude: [整理资讯 → POST 到 Webhook]
```

### 指定自定义资讯源

```
用户: 整理今日的ai资讯，使用 https://x.ai/news
Claude: [从指定 URL 获取内容并整理]
```

### 英文输出

```
用户: 帮我整理今日的ai资讯，用英文输出
Claude: [生成英文版日报]
```

## 配置文件说明

### SMTP 配置 (config/smtp.conf)

```ini
SMTP_HOST=smtp.qq.com
SMTP_PORT=587
SMTP_FROM=your_email@qq.com
SMTP_USER=your_email@qq.com
SMTP_PASS=your_auth_code
```

**常见邮箱配置：**

| 邮箱 | SMTP_HOST | 端口 | 密码类型 |
|------|-----------|------|----------|
| QQ | smtp.qq.com | 587 | 授权码 |
| Gmail | smtp.gmail.com | 587 | 应用专用密码 |
| 163 | smtp.163.com | 587 | 授权码 |
| Outlook | smtp.office365.com | 587 | 邮箱密码 |

### 资讯源配置 (references/sources.json)

可以编辑此文件添加自定义资讯源：

```json
{
  "name": "@custom",
  "url": "https://example.com/blog",
  "description": "自定义资讯源"
}
```

## 项目结构

```
aidaily/
├── SKILL.md                  # Skill 主文件
├── README.md                 # 本说明文档
├── LICENSE                   # MIT 许可证
├── .gitignore                # Git 忽略配置
├── config/
│   └── smtp.conf.example     # SMTP 配置模板
├── references/
│   ├── sources.json          # 预配置资讯源
│   └── email-template.html   # HTML 邮件模板
└── scripts/
    ├── send_email.py         # 邮件发送脚本
    └── send_webhook.sh       # Webhook 发送脚本
```

## 更新 Skill

```bash
cd ~/.claude/skills/aidaily
git pull origin main
```

## 卸载

```bash
rm -rf ~/.claude/skills/aidaily
```

## 许可证

[MIT License](LICENSE)

## 贡献

欢迎提交 Issue 和 Pull Request！

## 免责声明

本 Skill 仅供学习交流使用，获取的内容版权归原作者所有。
