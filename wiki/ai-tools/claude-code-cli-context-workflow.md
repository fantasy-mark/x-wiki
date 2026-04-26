# Claude Code CLI「不丢上下文」工作流

> Sources: 卢灿伟同学, 2026-04-25
> Raw: [claude-code-cli-context-workflow](../../raw/ai-tools/2026-04-25-claude-code-cli-context-workflow.md)

## Overview

用 Claude Code CLI 半年搭建的完整工作流，解决三大痛点：compact 后记忆丢失、多项目上下文无法共享、批处理模式不适合连续性工作。核心思路是把 AI 需要的上下文从对话里搬到文件里——对话会 compact，文件不会。

## 核心痛点与解法

| 痛点 | 解法 |
|------|------|
| context 压缩后之前聊的全没了 | /checkpoint 流式存档 + 三层记忆系统 |
| 多项目上下文互相看不到 | 独立"指挥室"项目 + JSON 注册表 |
| 批处理模式不适合连续性工作 | 去掉 start/end，改成随时可存/可读的流式 |

## 指挥室模式

单独开一个 Claude Code 项目，不写代码，专门管理所有项目的节奏（产品决策、需求文档、进度追踪）。

- JSON 注册表记录所有项目的名称和路径
- **指挥室 `/recap`**：遍历所有项目进度，给出全局视图
- **项目内 `/recap`**：只看当前项目，避免跨项目噪音
- 任务管理挂 Linear（CLI 里直接查/改状态）

## 流式工作流：checkpoint + recap

**`/checkpoint` — 存档**
- 写入 `docs/memory/YYYY-MM-DD.md`（完成事项、决策、进行中工作）
- subagent 后台执行，不占主上下文，不打断工作流
- 触发时机：手动调用、对话快 compact 时、任务切换时 AI 自动触发
- 同时同步 `progress.md` 和 Linear 任务状态

**`/recap` — 恢复**
- 新 session 开头执行，读最近的 memory + progress
- 输出"上次到哪了，继续哪个？"
- 无顺序依赖，想存就存，想恢复就恢复

## 三层记忆系统

| 层 | 文件 | 作用 | 范围 |
|---|---|---|---|
| auto memory | `~/.claude/projects/*/memory/` | 你是谁、怎么工作、踩过什么坑 | 跨项目生效 |
| 工作日志 | `docs/memory/YYYY-MM-DD.md` | 今天干了什么、做了哪些决策 | 项目级 |
| 当前快照 | `docs/progress.md` | 现在在做什么、下一步是什么 | 项目级 |

`/recap` 开头三层全读，实现完整上下文恢复：从"这个人是谁"到"这个项目在做什么"到"上次聊到哪了"。

## 全局 CLAUDE.md

`~/.claude/CLAUDE.md`（项目级放在各项目根目录）实现跨项目一致性：
- 需求文档编号规则、commit message 风格、文件命名规范
- 项目级 CLAUDE.md 只放该项目的技术栈和架构信息

## /postmortem：踩坑复盘

参考 Google/Meta 事故复盘流程，踩坑后调用：
1. 还原时间线（问题发现→试错→解决）
2. 分析根因（表面原因 vs 真正原因）
3. 写入 `docs/postmortem/` 存档
4. 判断是否写入 memory 或全局 CLAUDE.md，让所有 session 受益

## /init-project：新项目快速起步

基于 `~/.claude/CLAUDE-TEMPLATE.md` 模板自动生成：
CLAUDE.md、docs 目录（requirements/features/memory/postmortem）、progress.md、.gitignore。模板引用全局 CLAUDE.md，新项目第一天就知道规范。

## 文件结构

**全局层（所有项目共享）**
```
~/.claude/CLAUDE.md              ← 全局规范
~/.claude/CLAUDE-TEMPLATE.md     ← 新项目模板
~/.claude/commands/recap.md      ← 恢复上下文
~/.claude/commands/checkpoint.md ← 存档进展
~/.claude/commands/init-project.md← 初始化新项目
~/.claude/projects/*/memory/     ← auto memory
```

**项目层（每个项目各一份）**
```
CLAUDE.md                        ← 项目专属信息
docs/progress.md                 ← 当前快照
docs/memory/YYYY-MM-DD.md        ← 工作日志
docs/requirements/README.md      ← 需求索引
docs/features/                   ← 功能文档
docs/postmortem/                 ← 复盘记录
```

## See Also

- [Claude Code Session 管理指南]([[claude-code-session-management]]) — Anthropic 官方的 session 管理决策树（Rewind/Compact/Subagent），与本文的 checkpoint/recap 互补
- [Superpowers 插件完全上手指南]([[superpowers-plugin-guide]]) — 工程化开发插件，子智能体隔离上下文机制
- [驾驭工程]([[harness-engineering]]) — Claude Code 源码架构分析
- [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) — 多 Agent 协调架构（六种模式）与本文的团队协作模式互为补充
