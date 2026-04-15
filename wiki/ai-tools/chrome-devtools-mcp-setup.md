# Chrome DevTools MCP 安装配置

> Sources: AI工匠郑工长, 2026-02-18
> Raw: [2026-02-18-opencode-chrome-devtools-mcp-ai-see-web.md](../../raw/ai-tools/2026-02-18-opencode-chrome-devtools-mcp-ai-see-web.md)
> Updated: 2026-04-15

## Overview

Chrome DevTools MCP 是 Google 官方推出的 MCP 服务器，让 AI 编码助手能够直接控制本地 Chrome 浏览器，获取动态渲染的网页内容。这解决了传统爬虫无法处理 JavaScript 渲染网站（如 Twitter/X）的问题，并且可以利用已有的登录状态。

## 什么是 Chrome DevTools MCP

Chrome DevTools MCP  enables AI 编码助手 to:

- **控制浏览器**：导航、点击、输入、截图
- **获取页面内容**：完整的 DOM 快照，包括动态渲染的内容
- **性能分析**：记录性能追踪、分析网络请求
- **调试功能**：执行 JavaScript、检查控制台消息

**核心优势**：连接你已打开的 Chrome 浏览器，使用你已有的登录状态、Cookie 和历史记录。

## 安装步骤

### 环境要求

- Node.js v20.19+
- Chrome 浏览器
- npm（随 Node.js 安装）

### 配置 OpenCode

**macOS / Linux：**
```bash
# 创建目录（如果不存在）
mkdir -p ~/.config/opencode

# 创建配置文件
nano ~/.config/opencode/opencode.json
```

**Windows：**
```powershell
# 创建目录
mkdir -Force "$env:USERPROFILE\.config\opencode"

# 创建配置文件
notepad "$env:USERPROFILE\.config\opencode\opencode.json"
```

**配置内容：**
```json
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "chrome-devtools": {
      "type": "local",
      "command": ["npx", "-y", "chrome-devtools-mcp@latest"],
      "enabled": true
    }
  }
}
```

### 启动调试模式 Chrome

**macOS：**
```bash
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-profile
```

**Windows PowerShell：**
```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
  --remote-debugging-port=9222 `
  --user-data-dir="$env:TEMP\chrome-profile"
```

**Windows CMD：**
```cmd
"C:\Program Files\Google\Chrome\Application\chrome.exe" ^
  --remote-debugging-port=9222 ^
  --user-data-dir="%TEMP%\chrome-profile"
```

**Linux：**
```bash
google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile
```

这会打开一个新的 Chrome 窗口，端口 9222 用于调试连接。

### 重启 OpenCode

退出当前 OpenCode 会话，重新启动。OpenCode 会自动加载 Chrome DevTools MCP。

## 典型使用场景

1. **内容创作**：抓取动态网页内容，生成观察评论
2. **竞品分析**：自动访问竞品网站，截图对比
3. **自动化测试**：操作网页，验证功能
4. **数据采集**：从需要登录的网站采集数据
5. **性能调试**：分析页面性能问题

## 注意事项

- **安全警告**：调试端口开放时，任何应用都可以控制你的浏览器，不要同时访问敏感网站
- **独立配置文件**：建议使用独立的 `--user-data-dir`，避免影响日常浏览
- **会话保持**：调试模式下可以保持登录状态，但关闭浏览器后需要重新登录
- **Windows 路径**：路径包含空格时（如 `Program Files`），建议用双引号包裹整个路径

## 工具清单

| 分类 | 工具 | 功能 |
|------|------|------|
| 导航 | `navigate_page` | 导航到指定 URL |
| 导航 | `list_pages` | 列出所有打开的页面 |
| 导航 | `select_page` | 选择特定页面 |
| 交互 | `click` | 点击元素 |
| 交互 | `fill` | 填写表单 |
| 交互 | `press_key` | 按键 |
| 信息 | `take_snapshot` | 获取页面 DOM 快照 |
| 信息 | `take_screenshot` | 截图 |
| 信息 | `get_console_message` | 获取控制台消息 |
| 性能 | `performance_start_trace` | 开始性能追踪 |
| 性能 | `performance_stop_trace` | 停止追踪 |
| 性能 | `performance_analyze_insight` | 分析性能数据 |

## See Also

- [驾驭工程]([[harness-engineering]])
- [实用开发者工具导航]([[useful-developer-tools-collection]])
