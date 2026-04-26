# 驾驭工程 (Harness Engineering)

> Sources: ZhangHandong, 2026-04-15
> Raw: [2026-04-15-harness-engineering-preface.md](../../raw/ai-tools/2026-04-15-harness-engineering-preface.md)
> Updated: 2026-04-15

## Overview

《驾驭工程》（中文别名《马书》）是一本基于泄露的 Claude Code v2.1.88 TypeScript 源码，由 AI 提取整理而成的开源技术书籍。该书系统分析 Claude Code 的内部架构设计与实现，目标是帮助读者深入理解 AI 编码工具的工作原理。书籍采用开源协作模式持续完善，旨在共建一本有价值的公版书。

## 书籍创作流程

为保证 AI 写作质量，本书遵循严格的工程化流程：

1. **设计阶段**：根据源码梳理出 `DESIGN.md`，确定整本书的大纲和整体设计
2. **规格定义**：为每一章编写 spec，基于 `agent-spec` 框架约束章节目标、边界和验收标准
3. **规划阶段**：拆分具体执行步骤
4. **写作阶段**：叠加技术写作 skill，由 AI 正式写作

## 阅读准备

### 前置知识

本书假设读者具备：
- **TypeScript / JavaScript**：能读懂 `async/await`、接口定义、泛型等基础语法
- **CLI 开发概念**：理解进程、环境变量、标准 IO、子进程通信
- **LLM API 基础**：了解 messages API、工具调用、流式响应

不需要：React/Ink 开发经验、Bun 知识、Claude Code 使用经验。

### 推荐阅读路径

全书 30 章分为 7 篇，针对不同读者目标有不同阅读路径：

**路径 A：Agent 构建者**（想构建自己的 AI Agent）
> 第1章（技术栈）→ 第3章（Agent Loop）→ 第5章（系统提示词）→ 第9章（自动压缩）→ 第20章（Agent 派生）→ 第25-27章（模式提炼）→ 第30章（实战）
>
> 覆盖从架构到循环、提示词、上下文管理、多 Agent，最后实战用 Rust 实现完整代码审查 Agent。

**路径 B：安全工程师**（关注 AI Agent 安全边界）
> 第16章（权限系统）→ 第17章（YOLO 分类器）→ 第18章（Hooks）→ 第19章（CLAUDE.md）→ 第4章（工具编排）→ 第25章（失败关闭原则）
>
> 聚焦纵深防御，理解 Claude Code 如何在自主性和安全性之间取得平衡。

**路径 C：性能优化**（关注 LLM 应用成本和延迟）
> 第9章（自动压缩）→ 第11章（微压缩）→ 第12章（Token 预算）→ 第13章（缓存架构）→ 第14章（缓存中断检测）→ 第15章（缓存优化）→ 第21章（Effort/Thinking）
>
> 理解 Claude Code 如何将 API 成本降低 90%，从上下文管理到提示词缓存到推理控制。

### 知识地图结构

第 3 章 **Agent Loop** 是全书锚点，定义了从用户输入到模型响应的完整循环。其他各篇分别分析循环中不同阶段的深层机制：

| 篇章 | 主题 |
|------|------|
| 第一篇 | 架构 |
| 第二篇 | 提示工程 |
| 第三篇 | 上下文管理 |
| 第四篇 | 提示词缓存 |
| 第五篇 | 安全与权限 |
| 第六篇 | 高级子系统 |
| 第七篇 | 经验教训 |

### 标记说明

- **源码引用**：`restored-src/src/path/file.ts:line` 指向 Claude Code v2.1.88 还原源码
- **证据分级**：
  - `v2.1.88 源码证据`：有完整源码和行号引用，最高可信度
  - `v2.1.91/v2.1.92 bundle 逆向`：基于 bundle 推断，source map 已被移除
  - `推断`：仅从事件名/变量名推测，无直接源码证据
- **Mermaid 图表**：流程图和架构图使用 Mermaid 语法
- **交互式可视化**：部分章节提供 D3.js 交互动画

## 相关资源

- 仓库地址：https://github.com/ZhangHanDong/harness-engineering-from-cc-to-ai-coding
- 在线阅读：https://zhanghandong.github.io/harness-engineering-from-cc-to-ai-coding/
- 可视化站点：https://ccunpacked.dev（配合阅读更好理解内部机制）
- 讨论区：https://github.com/ZhangHanDong/harness-engineering-from-cc-to-ai-coding/discussions

## See Also

- [chrome-devtools-mcp-setup]([[chrome-devtools-mcp-setup]])
- [useful-developer-tools-collection]([[useful-developer-tools-collection]])
- [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) — 同源分析，源码架构与本书互为补充
