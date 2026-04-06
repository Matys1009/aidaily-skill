---
name: aiDaily
description: |
  整理和汇总 AI 领域最新资讯的 skill。当用户说出"帮我整理今日的ai资讯"、"整理每日ai资讯"、
  "今天有什么ai新闻"、"获取ai日报"等类似话语时触发。自动从配置的 AI 博客源获取最新文章，
  生成卡片式 HTML 日报。支持用户指定其他资讯源 URL，支持将结果发送到 webhook 或邮箱，
  支持语言切换（默认中文，可指定英文等）。
  必须使用此 skill 处理任何与 AI 资讯整理、AI 日报生成、AI 新闻汇总相关的请求。
---

# aiDaily - AI 资讯日报

## 概述

aiDaily 用于自动整理 AI 领域的最新资讯，从多个源获取博客文章，生成卡片式 HTML 格式的日报。

## 触发条件

当用户表达以下意图时触发此 skill：

- "帮我整理今日的ai资讯"
- "整理每日ai资讯"
- "今天有什么ai新闻"
- "获取ai日报"
- 任何与"AI资讯"、"AI新闻"、"AI日报"相关的请求

## 执行步骤

### 1. 识别资讯源

**读取默认源**：
从 `references/sources.json` 的 `default_sources` 数组读取默认资讯源。

**当前默认源**：
- @claude: https://claude.com/blog
- @openai: https://developers.openai.com/blog
- @deepmind: https://deepmind.google/blog/
- @huggingface: https://huggingface.co/blog
- @googleai: https://blog.google/technology/ai/

**用户指定源**：如果用户在提示中包含 URL，使用该 URL 作为额外或替代源

**来源命名**：使用 `source_name_mapping` 从 URL 域名映射到 @名称

### 2. 获取内容

对每个资讯源 URL：
1. 使用 WebFetch 获取页面内容
2. 提取文章列表：标题、发布日期、摘要、链接
3. 按发布日期倒序排序，取前 **5-8 条** 最新文章

### 3. 生成概要

- **长度**：100-200 字
- **语言**：默认简体中文，用户可指定英文等

### 4. 格式化输出

生成**卡片式 HTML**邮件，参考样式见 `references/email-template.html`：

**关键样式**：
- 卡片布局：左侧彩色边框（@claude蓝、@openai绿）+ 圆角 + 阴影
- 每卡包含：来源标签、日期、标题（链接）、概要
- 按日期倒序排列

**HTML 结构**：
```html
<div class="card">
  <div class="meta"><span class="source">@claude</span><span class="date">04-02</span></div>
  <div class="title"><a href="...">标题</a></div>
  <div class="summary">概要...</div>
</div>
```

### 5. 发送到指定地址（可选）

**识别意图**："发送到..."、"推送到..."、"转发到..."

**目标类型**：
- **Webhook**：http/https URL → 使用 `scripts/send_webhook.sh`
- **Email**：包含 @ 的地址 → 使用 `scripts/send_email.py`

## 来源命名规则

从 `references/sources.json` 的 `source_name_mapping` 读取域名到 @名称 的映射规则。

## 发送脚本使用

### Webhook
```bash
bash scripts/send_webhook.sh <url> <content_file>
```

### Email（HTML 邮件）
```bash
python3 scripts/send_email.py "收件人@公司.com" "AI资讯日报 - 日期" /tmp/ai_daily.html
```

**SMTP 配置**：
1. 复制模板：`cp config/smtp.conf.example config/smtp.conf`
2. 编辑配置填入 SMTP 信息（支持 QQ、Gmail、企业邮箱等）
3. 运行发送脚本

## 边界情况

- **网站无法访问/获取失败**:
  - 不得阻塞：单个源获取失败时立即跳过，继续处理下一个源
  - 失败限制：若超过50%的源获取失败，在日报开头添加提示“部分资讯源暂时不可用”
  - 最小生成条件：只要有≥1个源成功获取内容，就继续生成日报，不要等待或重试
- 文章无日期：按页面信息推断日期
- 发送失败：报告失败，但保留输出内容

## 示例

**基础使用**
用户："帮我整理今日的ai资讯"
输出：卡片式 HTML 邮件，包含 @claude 和 @openai 的最新资讯

**指定源和发送**
用户："整理ai资讯，使用 https://x.ai/news，发送到 webhook https://myapp.com/hook"
处理：获取 x.ai/news 内容 → 生成日报 → POST 到 webhook

**英文输出**
用户："整理今日的ai资讯，用英文输出"
输出：英文格式的日报
