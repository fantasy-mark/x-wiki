# OpenCode + Chrome DevTools MCP：让你的AI能真正"看见"网页

> Source: https://www.toutiao.com/article/7608121275038384655/?wid=1775989077748
> Collected: 2026-04-14
> Published: 2026-02-18

OpenCode安装Chrome DevTools MCP后，AI可以直接控制浏览器、抓取动态网页内容、截图、自动化测试。本文手把手教你安装配置，并用实际案例演示如何抓取Twitter内容。

你好，我是郑工长。

最近在 OpenCode 里做了一个小升级——装了 Chrome DevTools MCP。

这个升级让我非常惊喜。装完之后，OpenCode 不再只是一个"能聊天的代码助手"，它变成了一个"能真正"看见"网页、操作浏览器的 AI 代理"。

今天我把这个配置过程和使用场景完整分享出来，包括 macOS 和 Windows 两种环境的操作步骤。

## 为什么需要 Chrome DevTools MCP？

在装这个工具之前，我在 OpenCode 里遇到过一个尴尬的场景。

我想让 AI 帮我分析一条 Twitter 的内容，于是我把链接丢给它，它说："我去抓取一下这个链接的内容。"

然后——失败了。

原因是 Twitter/X 是一个 JavaScript 渲染的网站，传统的 webfetch 工具只能抓取静态 HTML，无法处理动态内容。

我试过 Playwright 容器服务，但 Twitter 的反爬虫机制很强，容器里的浏览器没有登录状态，根本访问不了。

问题来了：如果 AI 能直接控制我电脑上已登录的 Chrome 浏览器，不就能解决这个问题了吗？

这就是 Chrome DevTools MCP 的价值。

## Chrome DevTools MCP 是什么？

Chrome DevTools MCP 是 Google 官方推出的一个 MCP 服务器，让 AI 编码助手能够：
- 控制浏览器：导航、点击、输入、截图
- 获取页面内容：完整的 DOM 快照，包括动态渲染的内容
- 性能分析：记录性能追踪、分析网络请求
- 调试功能：执行 JavaScript、检查控制台消息

关键点：它能连接你已打开的 Chrome 浏览器，使用你已有的登录状态、Cookie、历史记录。

## 安装步骤

### 第一步：确认环境

需要：
- Node.js v20.19+（检查：node --version）
- Chrome 浏览器
- npm（随 Node.js 安装）

### 第二步：创建配置文件

打开或创建 OpenCode 配置文件：

macOS / Linux：
```
# 创建目录（如果不存在）
mkdir -p ~/.config/opencode

# 创建配置文件
nano ~/.config/opencode/opencode.json
```

Windows：
```
# 创建目录
mkdir -Force "$env:USERPROFILE\.config\opencode"

# 创建配置文件
notepad "$env:USERPROFILE\.config\opencode\opencode.json"
```

写入以下内容：
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

保存退出。

### 第三步：启动带调试端口的 Chrome

为了让 MCP 能连接到你的 Chrome，需要以调试模式启动。

macOS：
```
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile
```

Windows：
```
# 方法1：PowerShell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="$env:TEMP\chrome-profile"

# 方法2：命令提示符 (CMD)
"C:\Program Files\Google\Chrome\Application\chrome.exe" --remote-debugging-port=9222 --user-data-dir="%TEMP%\chrome-profile"

# 如果 Chrome 安装在其他位置，调整路径即可
```

Linux：
```
google-chrome --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-profile
```

这会打开一个新的 Chrome 窗口，端口 9222 用于调试连接。

### 第四步：重启 OpenCode

退出当前的 OpenCode 会话，重新启动。

现在 OpenCode 会自动加载 Chrome DevTools MCP。

## 实际案例：抓取 Twitter 内容

我刚才用这个功能完成了一个完整的"郑工长观察"文章创作流程。

### 场景

有人给我一条 Twitter 链接，我让 AI 去：
- 打开链接
- 获取推文内容
- 分析要点
- 写一篇"郑工长观察"评论
- 入库

### 执行过程

- 打开链接：AI 调用 navigate_page，导航到 Twitter 链接
- 获取内容：AI 调用 take_snapshot，获取完整的 DOM 快照

### 结果

成功抓取到 Twitter 文章的全部内容，包括：
- 作者信息
- 推文正文
- 图片链接
- 互动数据

然后 AI 自动提炼要点、生成评论、保存到数据库。

整个过程不到 2 分钟。

## 核心工具一览

Chrome DevTools MCP 提供了丰富的工具：

**导航类**：
- navigate_page - 导航到指定 URL
- list_pages - 列出所有打开的页面
- select_page - 选择特定页面

**交互类**：
- click - 点击元素
- fill - 填写表单
- press_key - 按键

**信息类**：
- take_snapshot - 获取页面 DOM 快照
- take_screenshot - 截图
- get_console_message - 获取控制台消息

**性能类**：
- performance_start_trace - 开始性能追踪
- performance_stop_trace - 停止追踪
- performance_analyze_insight - 分析性能数据

## 使用场景

- 内容创作：抓取动态网页内容，生成观察评论
- 竞品分析：自动访问竞品网站，截图对比
- 自动化测试：操作网页，验证功能
- 数据采集：从需要登录的网站采集数据
- 性能调试：分析页面性能问题

## 注意事项

- 安全警告：调试端口开放时，任何应用都可以控制你的浏览器，不要同时访问敏感网站
- 独立配置文件：建议使用独立的 --user-data-dir，避免影响日常浏览
- 会话保持：调试模式下可以保持登录状态，但关闭浏览器后需要重新登录
- Windows 路径：Windows 用户注意路径中的空格（如 "Program Files"），建议用双引号包裹整个路径

## 总结一下

Chrome DevTools MCP 解决了一个核心问题：让 AI 从"只能读静态内容"升级到"能操作真实浏览器"。

这不是一个简单的效率提升，而是能力的质变。

当 AI 能看见你看见的内容、操作你操作的界面，它就不再只是一个"助手"，而是一个"数字同事"。

OpenCode + Chrome DevTools MCP，是每个 AI 时代工作者都应该尝试的组合。

安装只需要 3 分钟，但带来的可能性，是无限的。

---

*作者：AI工匠郑工长，以 AI 为工具的数字化工匠，专注打造自动化工作流与智能产品。*
