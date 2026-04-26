# 开源 Claude Code 工程级开发插件 Superpowers 完整上手攻略

> Source: https://mp.weixin.qq.com/s/n52dg8R2fzgHNIo9XX-HMA
> Collected: 2026-04-25
> Published: Unknown

Superpowers 为 Claude Code 等 AI 编程智能体提供工程化开发流程，将 TDD、代码审查、设计文档等传统工程实践与 AI Agent 能力结合，使开发过程更结构化。

---

## 什么是 Superpowers

Superpowers 为 AI 编程智能体（如 Claude Code、Cursor、Codex、OpenCode）提供完整的软件开发工作流程。由 20+ 个可组合 Skills 组成，覆盖需求梳理、架构设计、TDD、代码审查和分支管理。

核心思路：通过可组合 Skills 和初始指令，让 AI 智能体自动遵循最佳实践，而非随意生成代码。

### 架构设计

四层分层架构：

- 用户层：平台无关，可接入不同 AI 编程智能体
- 框架层：通过 Session Hook 机制自动注入技能上下文
- 执行层：负责子智能体调度，实现任务隔离和并行执行
- 输出层：所有产出物（设计文档、代码、测试等）统一通过 Git 管理

### 技能系统

技能文件使用 YAML Frontmatter + Markdown 格式，支持覆盖机制：

- 个人技能（~/.claude/skills/）优先级最高，可覆盖框架默认技能
- 使用完全限定名（superpowers:skill-name）强制使用特定版本

## 核心创新：Subagent-Driven Development

### 设计理念

- 上下文隔离：每个子智能体从全新上下文启动
- 职责分离：实现子智能体负责编码，审查子智能体负责质量
- 快速重试：审查未通过时直接创建新子智能体重试
- 并行执行：独立任务可并行分发给多个子智能体

### 两阶段审查

**第一阶段：规范合规审查（Spec Review）**
- 核心问题：实现是否满足需求？
- 关注：功能点完整性、边界条件、测试覆盖率
- 不关注：代码风格或实现细节

**第二阶段：代码质量审查（Code Quality Review）**
- 核心问题：实现是否易读、可维护？
- 关注：代码风格、DRY 原则、命名清晰度、过度工程化

### 两种执行模式对比

| 维度 | Subagent-Driven | Executing Plans |
|------|----------------|-----------------|
| 会话模型 | 当前会话内创建子智能体 | 并行独立会话 |
| 任务上下文 | 全新上下文 | 共享上下文 |
| 审查机制 | 自动两阶段审查循环 | 人工检查点 |
| 执行速度 | 快 | 较慢 |
| 适用场景 | 独立、明确的任务 | 需要中途调整策略 |
| 失败处理 | 自动重试 | 需人工介入 |

选择建议：
- 需求明确 + 测试完整 → Subagent-Driven（充分利用自动化）
- 探索性开发 + 频繁调整 → Executing Plans（保留人工决策节点）

## 完整工作流程

### 标准开发工作流

```
1. Brainstorming → 澄清需求，生成 design.md
2. Git Worktree → 创建独立 Git 工作树
3. Writing Plans → 拆解为 2-5 分钟小步骤
4. Subagent Development → 两阶段审查循环
5. TDD → RED–GREEN–REFACTOR 循环
6. Code Review → 最终质量检查
7. Finish Branch → 完成合并
```

### 关键阶段解析

**阶段1：Brainstorming**
AI 通过连续提问逐步澄清需求，给出 2-3 个方案供选择，输出完整设计文档。

**阶段2：Git Worktree**
使用 Git worktree 隔离开发环境，避免频繁 checkout 带来的 I/O 和 IDE 重新索引。

**阶段3：Writing Plans**
- 任务粒度控制在 2-5 分钟
- 每个任务包含明确验证步骤
- 尽量减少任务间依赖，便于并行执行

## 快速上手

### 安装（两步完成）

```
# 步骤一：加入插件市场
/plugin marketplace add obra/superpowers-marketplace

# 步骤二：安装插件
/plugin install superpowers@superpowers-marketplace
```

### 常用技能速查

| 技能 | 触发关键词 | 功能 |
|------|-----------|------|
| `brainstorming` | 需求描述不明确时自动触发 | 通过提问澄清需求 |
| `writing-plans` | 制定计划、规划 | 任务拆解 |
| `executing-plans` | 按既定计划推进 | 执行任务并设置检查点 |
| `test-driven-development` | TDD、测试驱动 | 红-绿-重构循环 |
| `subagent-driven-development` | 使用子代理 | 并行处理子任务 |
| `systematic-debugging` | 调试、bug | 结构化根因分析 |
| `using-git-worktrees` | 环境隔离 | Git worktree 隔离 |

### 常见问题

**Q1：Claude Code 没有触发技能**
→ 确认插件已加载：`/plugin list`
→ 尝试手动触发："使用 brainstorming 技能来规划这个功能"

**Q2：安装报错**
→ 清除缓存后重装：`rm -rf ~/.cache/superpowers && /plugin install superpowers@superpowers-marketplace --force`

**Q3：Git Worktree 失败**
→ 检查 Git 版本需 2.5+：`git worktree prune` 清理残留

## 总结

Superpowers 将传统工程实践（TDD、代码审查、设计文档）与 AI Agent 结合，减少"代码能跑但难维护"的情况。它不是取代开发者创造力，而是把重复、机械的部分系统化处理。

GitHub：https://github.com/obra/superpowers
