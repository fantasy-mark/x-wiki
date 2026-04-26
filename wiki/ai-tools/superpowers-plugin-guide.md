# Superpowers：Claude Code 工程化开发插件

> Sources: 兔兔AGI, 2026-04-25; GitHub obra/superpowers
> Raw: [superpowers-claude-code-engineering-plugin](../../raw/ai-tools/2026-04-25-superpowers-claude-code-engineering-plugin.md)

## Overview

Superpowers 是面向 Claude Code 等 AI 编程智能体的工程化开发插件，通过 20+ 可组合 Skills 将 TDD、代码审查、设计文档、Git Worktree 等传统工程实践系统化，使 AI 协作开发更结构化、更可控。核心创新是 Subagent-Driven Development（子智能体驱动开发）和两阶段代码审查机制。

## 架构

四层分层架构，以 Skills 为核心抽象：

- **用户层**：平台无关，可接入不同 AI 编程智能体
- **框架层**：通过 Session Hook 自动注入技能上下文
- **执行层**：子智能体调度，任务隔离 + 并行执行
- **输出层**：所有产出物统一通过 Git 管理

技能文件格式：YAML Frontmatter + Markdown。支持覆盖机制——个人技能（`~/.claude/skills/`）优先级最高，可覆盖框架默认同名技能；使用完全限定名 `superpowers:skill-name` 强制调用特定版本。

## 核心创新：Subagent-Driven Development

### 设计理念

| 机制 | 说明 |
|------|------|
| 上下文隔离 | 每个子智能体从全新上下文启动，避免累积污染 |
| 职责分离 | 实现智能体编码，审查智能体负责质量检查 |
| 快速重试 | 审查未通过则创建新智能体重新执行 |
| 并行执行 | 独立任务可并行分发给多个子智能体 |

### 两阶段审查

将代码审查拆分为两个独立阶段：

**阶段一：Spec Review（规范合规）**
- 核心问题：是否满足需求？
- 关注：功能点完整性、边界条件、测试覆盖率
- 不关注：代码风格或实现细节

**阶段二：Code Quality Review（代码质量）**
- 核心问题：是否易读可维护？
- 关注：代码风格、DRY 原则、命名、过度工程化

**分阶段的好处**：避免在讨论代码风格时忽略功能缺陷，或因实现"看起来不错"而放松对需求完整性的检查。

### 两种执行模式对比

| 维度 | Subagent-Driven | Executing Plans |
|------|----------------|-----------------|
| 会话模型 | 当前会话内创建子智能体 | 并行独立会话 |
| 任务上下文 | 每个智能体全新上下文 | 共享上下文 |
| 审查机制 | 自动两阶段循环 | 人工检查点 |
| 执行速度 | 快 | 较慢 |
| 适用场景 | 独立、明确的任务 | 需中途调整策略 |
| 失败处理 | 自动重试 | 需人工介入 |

**选择原则**：需求明确 + 测试完整 → Subagent-Driven；探索性开发 + 频繁调整 → Executing Plans。

## 完整工作流程

```
1. Brainstorming  → 通过提问澄清需求，生成 design.md
2. Git Worktree   → 创建独立 Git 工作树，环境隔离
3. Writing Plans  → 拆解为 2-5 分钟可验证小步骤
4. Subagent Dev   → 每个任务独立子智能体 + 两阶段审查
5. TDD            → RED–GREEN–REFACTOR 循环
6. Code Review    → 最终质量检查
7. Finish Branch  → 合并完成
```

**关键阶段说明**：
- **Brainstorming**：先澄清需求再编码，输出 2-3 个方案供选择
- **Git Worktree**：避免频繁 checkout 带来的 I/O 和 IDE 重索引
- **Writing Plans**：任务粒度 2-5 分钟，每步包含明确验证步骤，尽量减少依赖以支持并行

## 常用技能速查

| 技能 | 触发词 | 功能 |
|------|--------|------|
| `brainstorming` | 需求不明确时自动触发 | 提问澄清需求 |
| `writing-plans` | 制定计划、规划 | 任务拆解 |
| `executing-plans` | 按既定计划推进 | 执行 + 检查点 |
| `test-driven-development` | TDD、测试驱动 | 红-绿-重构 |
| `subagent-driven-development` | 并行处理子任务 | 子智能体执行 |
| `systematic-debugging` | 调试、bug | 根因分析 |
| `using-git-worktrees` | 环境隔离 | worktree 隔离 |
| `requesting-code-review` | 提交前请求审查 | 代码审查 |

## 安装与配置

```bash
# 加入插件市场
/plugin marketplace add obra/superpowers-marketplace

# 安装插件
/plugin install superpowers@superpowers-marketplace
```

安装完成后重启 Claude Code 即可使用。

## See Also

- [Claude Code Session 管理指南]([[claude-code-session-management]]) — 上下文管理决策树，与 Superpowers 的子智能体隔离机制互补
- [驾驭工程]([[harness-engineering]]) — Claude Code 源码架构分析，包含 Agent Loop 等核心机制
