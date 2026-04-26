# Claude Code 源码深度解读：从 Harness 视角

> Sources: ChallengeHub, 2026-04-26; 基于泄露的 Claude Code 源码（npm .map 文件暴露）
> Raw: [claude-code-harness-architecture-deep-dive](../../raw/ai-tools/2026-04-26-claude-code-harness-architecture-deep-dive.md)

## Overview

基于泄露的 Claude Code 公开源码（~1900 文件、512K 行 TypeScript），从 Harness 工程视角系统性拆解其架构。核心公式：`Claude Code = one agent loop + tools + skill loading + context compression + subagent spawning + task system + team coordination + worktree isolation + permission governance`。核心结论：**模型即智能体，代码即缰绳**。

## 核心公式

```
Claude Code = one agent loop
            + tools (bash, read, write, edit, glob, grep, browser...)
            + on-demand skill loading
            + context compression
            + subagent spawning
            + task system with dependency graph
            + team coordination with async mailboxes
            + worktree isolation for parallel execution
            + permission governance
```

**哲学：模型决定做什么，Harness 负责执行怎么做。**

## 目录结构

| 目录 | Harness 角色 | 功能 |
|------|------------|------|
| `src/tools/` | Agent 的双手 | ~40 个工具：文件 I/O、Shell、代码搜索 |
| `src/commands/` | 用户指令接口 | ~50 个斜杠命令 |
| `src/services/` | 外部服务集成 | MCP、OAuth、LSP |
| `src/coordinator/` | 多智能体协调 | 子智能体编排、调度、协作 |
| `src/skills/` | 按需知识加载 | 可复用工作流，按需注入 |
| `src/bridge/` | IDE 桥接层 | VS Code / JetBrains 与 CLI 双向通信 |
| `src/hooks/` | 权限与生命周期 | 工具权限校验、会话生命周期 |
| `src/memdir/` | 持久记忆 | 跨会话记忆存储 |
| `src/tasks/` | 任务系统 | 带依赖图的任务管理 |
| `src/components/` | 终端 UI | ~140 个 React+Ink 组件 |

## 核心循环

`QueryEngine.ts`（~46K 行）作为大脑中枢，承担：
- **流式响应**：实时感知模型"思考过程"
- **工具调用循环**：`stop_reason="tool_use"` 时自动执行工具，结果追加到消息列表，再次调用模型
- **扩展思考**：允许模型执行前进行更深度推理
- **重试与 Token 计数**：应对 API 错误和速率限制

**关键认知**：循环属于 Agent，机制属于 Harness。所有其他机制（工具系统、技能加载、上下文压缩、子智能体）都在这个循环之上层层叠加，不改变循环本身结构。

## 工具系统设计原则

| 原则 | 说明 |
|------|------|
| **原子性** | 每个工具只做一件事，职责单一明确 |
| **可组合性** | 工具间灵活组合，上一输出自然成为下一输入 |
| **自我描述性** | 每个工具通过 Zod v4 Schema 定义输入输出；`ToolSearchTool` 实现延迟工具发现，节省上下文空间 |

**工具分层**：行动层（Bash/Write/Edit）、感知层（Read/Glob/Grep/WebFetch）、协调层（Agent/Task/SendMessage）、知识层（Skill）、调度层（Cron/Sleep）、隔离层（Worktree）。

## 知识系统：Progressive Disclosure

技能以 `.md` 文件存储，YAML frontmatter 定义触发条件。模型判断需要时通过 `SkillTool` 加载，内容通过 `tool_result` 注入上下文。

**三级渐进式披露**：
- Level 1：Metadata（触发描述）→ Agent 首先看到，决定是否需要
- Level 2：Body（详细信息）→ 判断需要后加载
- Level 3：References（参考资料）→ 深入分析时才加载

最大化上下文利用效率。

## 上下文三层压缩策略

| 层 | 机制 | 作用 |
|---|------|------|
| 第一层 | 子智能体隔离 | 子 Agent 拥有独立 `messages[]`，只返回摘要，不污染主会话 |
| 第二层 | Context Compression | 接近窗口限制时压缩对话历史，保留关键代码变更和决策理由 |
| 第三层 | 任务持久化 | `src/tasks/` + `src/memdir/`，通过 `/resume` 恢复，将记忆扩展到文件系统 |

## 多智能体六种架构模式

| 模式 | 适用场景 | 通信方式 |
|------|---------|---------|
| Pipeline | 顺序依赖任务（设计→前端→后端→测试） | 上一步输出作为下一步输入 |
| Fan-out/Fan-in | 并行独立任务（多维度代码审查） | 分发后聚合 |
| Expert Pool | 专业任务动态选择专家 | 根据任务类型选择 |
| Producer-Reviewer | 生成后验证（创作+审核） | 生产者-审核者交替 |
| Supervisor | 中心化动态调度 | Supervisor 统一分配 |
| Hierarchical Delegation | 复杂任务递归拆分 | 树状层级委派 |

**团队协作**：JSONL Mailbox 异步通信 + Teammates 持久化实例 + 自主任务认领机制。

**Worktree 隔离**：每个并行任务在独立 Worktree 中工作，通过 Git Merge 合并结果，互不干扰。

## 权限系统

| 模式 | 行为 | 适用场景 |
|------|------|---------|
| `default` | 每次工具调用前提示审批 | 安全优先 |
| `plan` | 规划阶段只读，执行需审批 | 大型重构 |
| `auto` | 低风险自动批准，高风险仍需审批 | 信任环境 |
| `bypassPermissions` | 跳过所有权限检查 | 沙箱/测试 |

**多层防护**：toolPermission hook + Git Worktree 文件系统沙箱。

## 性能优化

- **并行预取**：启动时副作用并行加载 MDM 设置、Keychain 凭据、API 预连接
- **懒加载**：重量级模块通过 `import()` 延迟加载
- **死代码消除**：利用 Bun `bun:bundle` 特性标志，编译时剔除未激活代码（VOICE_MODE、BRIDGE_MODE、DAEMON 等）

## 核心洞察

> "The model is the agent. The code is the harness."

Claude Code 完全信任模型决策能力，将工程精力投入为模型提供清晰、丰富、安全的工作环境。**你无法通过编程到达智能——智能是学来的，不是编出来的。**

### Harness 工程师的五大职责

1. **实现工具**（给 Agent 双手）
2. **策划知识**（给 Agent 专业知识）
3. **管理上下文**（给 Agent 清洁记忆）
4. **控制权限**（给 Agent 安全边界）
5. **收集训练信号**（改进下一代 Agent）

**最重要的启示**：最好的 Agent 产品来自于那些理解"自己的工作是为智能构建世界，而非制造智能"的工程师。

## See Also

- [驾驭工程]([[harness-engineering]]) — 基于 Claude Code 源码的开源技术书籍，专注架构细节
- [Claude Code Session 管理指南]([[claude-code-session-management]]) — Anthropic 官方 session 管理手册
- [Superpowers 插件完全上手指南]([[superpowers-plugin-guide]]) — 工程化开发插件，Subagent 驱动模式