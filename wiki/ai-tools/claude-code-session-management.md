# Claude Code Session 管理指南

> Sources: stan的AI日报, 2026-04-25; Thariq (Anthropic), 2025
> Raw: [anthropic-claude-code-rewind-session-management](../../raw/ai-tools/2026-04-25-anthropic-claude-code-rewind-session-management.md)

## Overview

Anthropic Claude Code 团队发布官方 session 管理手册，系统讲解 1M context 上线后如何高效管理对话上下文。核心框架是每次 Claude 停下后的"五岔路口"决策树，以及 Rewind 作为最重要的上下文管理习惯。

## 五岔路口决策树

每次 Claude 响应结束后，你都面临 5 个选择：

| 动作 | 含义 | 适用场景 |
|------|------|----------|
| **Continue** | 在同一 session 继续发消息 | 默认选项，最舒服但也最贵 |
| **Rewind**（双击 Esc） | 跳回某条历史消息，从那里重发 | 尝试失败后，从干净状态重新开始 |
| **Clear** | 开全新 session，带一段 brief | 任务切换，需要完全干净的状态 |
| **Compact** | 让 Claude 自己总结历史 | 需要压缩但不明确保留什么时 |
| **Subagent** | 甩给子 agent，只取结论 | 只需结论，不需要中间过程 |

核心认知：**这不是五个并列功能，是一个决策树**。普通用户每天跑的是"要不要重新打开 Claude Code"，会用的用户跑的是这个决策树。

## Rewind：最值钱的习惯

> "If I had to pick one habit that signals good context management, it's rewind."
> — Thariq (Anthropic)

### 为什么是 Rewind

典型场景：Claude 读了 5 个文件，试了一个方案，失败了。用户的本能是发"那个不行，换 X 试试"——这是错的。

正确动作：双击 Esc，跳回刚读完 5 个文件、还没动手的时刻，把学到的教训直接写进 prompt：

```
别用方案 A，foo 模块根本没暴露那个接口——直接走 B。
```

**Rewind 不是回滚，是减法。** 你把"刚才那次失败"从 Claude 的 context 里切掉了。它接下来面对的是：5 个文件 + 你的新指令。

### 进阶用法：Summarize From Here

在 rewind 前让 Claude 写一段"我刚才试了什么、哪里卡住、学到了什么"——相当于给"过去的自己"留一封信，然后再 rewind 把这封信塞进新 prompt。

## Compact vs Clear

| | Compact | Clear |
|--|---------|-------|
| **决定权** | 交给 Claude 模型 | 握在自己手里 |
| **优点** | 省事 | 上下文完全由你决定 |
| **缺点** | 有损，赌 Claude 知道哪些以后还用 | 更累 |
| **陷阱** | 模型无法预测你下一步方向时发生 bad compact | — |

### Bad Compact 的典型场景

1. 刚结束一段 debug，autocompact 被触发，Claude 把调试过程总结成一行
2. 下一条消息："顺便把 bar.ts 里那个 warning 也修一下"
3. Boom——warning 在 debug 阶段是边角细节，被 compact 删掉了

**核心原因**：compact 触发时恰好是 context 最满、模型最累的时候，却要让它猜你接下来想干嘛。

### 主动 Compact 的正确姿势

1M context 带来的真正价值不是空间，是**时间窗口**——让你能在 context 还轻的时候主动做这件事：

```
/compact 重点保留 auth 重构相关内容，把 test 调试那段全部丢掉
```

## Subagent：判断题思维

> "Will I need this tool output again, or just the conclusion?"

只要结论就把活儿甩给 subagent，干完只把总结塞回来。原始中间过程一个 token 都不进主 context。

使用要点：**命令式，主动丢出去**，不是等 Claude 自己决定 spawn：

- "Spin off a subagent to verify the result of this work based on the following spec file."
- "Spin off a subagent to read through this codebase and summarize how it implemented the auth flow."
- "Spin off a subagent to write the docs on this feature based on my git changes."

## 1M Context 的真正含义

1M 不是让你一把梭，是给你从容管理 context 的**时间窗口**：

- 之前 200K：跑到撞墙，被迫在最不合适的时候 compact
- 有了 1M：在 context 还轻时主动选 compact/clear，在 Claude 状态最好时让它帮忙做总结

1M context 不是让你停止管理 context，是让管理 context 这件事第一次有了从容的时间。

## See Also

- [驾驭工程]([[harness-engineering]]) — Claude Code 源码架构分析，包含 Agent Loop 等核心机制
- [Chrome DevTools MCP 安装配置]([[chrome-devtools-mcp-setup]]) — 让 AI 能控制浏览器
- [实用开发者工具导航]([[useful-developer-tools-collection]]) — 开发者工具集合
- [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) — 源码系统性拆解，Context 管理机制互为印证
