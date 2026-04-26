# Hermes 多 Agent 协作：不是技术，是管理

> Sources: 林月半子聊AI, 2026-04-26; Hermes framework
> Raw: [hermes-multi-agent-management-lessons](../../raw/multi-agent/2026-04-26-hermes-multi-agent-management-lessons.md)

## Overview

用 Hermes + Discord 搭建三人多 Agent 协作小组的完整实践，踩了三个坑（无 @ 导致任务直接结束、死循环停不下来、同时 @ 两人）并逐一修复。核心结论：**多 Agent 是管理问题，不是技术问题**——profile 是工位，Discord 是会议室，SOUL.md 是职责说明书 + 协作流程 + 下班时间。

## 前置原则：协作是放大器，不是补丁

单个 Agent 是废柴，三个废柴协作结果是三倍废柴。先把 Agent 调教好（SOUL.md 写细、skills 配齐、模型选对），是多 Agent 能跑的前提。

## Profile 系统：进程级真隔离

Hermes 里一个 profile = 完全独立的 AI 分身：config.yaml、.env、SOUL.md、memory、skills、独立的 gateway 进程。进程级隔离，一个 bot 挂了不影响其他 bot。

| 克隆策略 | 说明 | 适用场景 |
|---------|------|---------|
| 无参数 | 空白 profile，连 API key 都重新配 | 从零搭完全独立的 agent |
| `--clone` | 只复制 config.yaml/.env/SOUL.md，记忆全新 | 多 Agent 协作（最常用） |
| `--clone-all` | 连 memory/sessions/skills/cron 全拷贝 | 备份或 fork 有上下文的 agent |

## 搭建三人小组

- **林小墨 (Ink)**：文案专家，笔记整理
- **林小探 (Search)**：情报专家，搜索调研
- **林小管 (Admin)**：总调度，任务分发

工作流：`用户 → Admin → @ Search 调研 → @ Ink 整理 → Admin【任务结束】`

## 三个坑与修复

### 坑1：没有 @，任务直接结束

**根因**：LLM 认识"林小探是团队成员"，但不知道 Discord 里要用 `<@用户ID>` 才能真正叫醒对方。

**解法**：花名册里直接挂 ID：
```
- 林小探 (Search): 【Executor】负责搜索调研。ID: `<@1495291492397224117>`
```
**关键**：计划阶段用纯文字，执行阶段才用 `<@ID>`——规划阶段带 ID 会导致 bot 在列出计划时就把执行者误唤醒。

### 坑2：死循环，停不下来

**根因**：admin 发"任务完成👍"，Ink 回复"好的👋"，admin 又回复"收到🎉"……无限循环。

**三层解决**：

**配置层1：DISCORD_ALLOW_BOTS**

| 值 | 行为 |
|----|------|
| `always` | 响应所有 bot 消息 |
| `never` | 完全忽略 bot |
| `mentions` | **只有 @ 才响应**（正确选择）|

**配置层2：replied_user: false**

Discord reply 功能默认给被回复者发隐式 mention。在 config.yaml 里关掉：
```yaml
discord:
  allow_mentions:
    replied_user: false   # 关闭 reply 自带的隐式 @
```

**LLM认知层：SOUL.md 终止协议**
```
- 明确终结：【任务结束】结尾
- 禁止冗余：不许发无意义表情、寒暄
- 中断反馈：不回应"收悉""待命"等结束类消息
- 艾特控制：总结里禁止再 @ 任何人
```

三层互相兜底才构成稳态。

### 坑3：同时 @ 了两个人

**根因**：admin 同时 @ Search 和 Ink，两人同时开始，Ink 拿不到调研结果。

**解法**：SOUL.md 强制时序规范：
```
- 逐一唤醒：严禁同时艾特多个专家
- 接力逻辑：等上一个人回复"调研完成"后，才 @ 下一个
```

## Discord 配置要点

| 配置项 | 说明 |
|--------|------|
| `allowed_channels` | 必须在白名单里才响应 @，需显式指定 channel ID |
| `auto_thread` | 默认开，每个任务独立 thread，主频道不刷屏 |
| Bot token | 每个 profile 必须独立，不能复用。Hermes 内置 token lock 保护 |

## Admin 的 SOUL.md 核心结构

```
## 角色定义
你是"林小管"，【总调度/Planner】，接收需求、拆解步骤、逐一指引专家。

## 团队成员（带 ID）
林小探 ID: `<@1495291492397224117>`
林小墨 ID: `<@1495250337139785955>`

## 核心协作准则
1. 任务分解：计划里用纯文字，禁用 ID 防止误唤醒
2. 身份隔离：仅做调度，必须通过 Discord 公开"点名"，不能直接调用执行工具
3. 状态追踪：等上一个专家明确完成后，才发起下一阶段

## 协作时序规范
逐一唤醒 + 接力逻辑（等"调研完成"再 @ Ink）

## Discord 艾特指令
执行阶段用 <@ID>，非执行阶段用纯文字

## 任务终止规范
【任务结束】结尾 + 禁止表情 + 禁止二次响应 + 总结里不 @ 任何人
```

## 核心结论

| 概念 | 含义 |
|------|------|
| Profile | 工位（给你物理空间） |
| Discord | 会议室（给你通信基础设施） |
| SOUL.md | 职责说明书 + 协作流程 + 下班时间（真正让 AI 像团队一样跑起来的东西） |

三个坑的本质就是三个管理漏洞：没指定汇报对象、没有项目终结机制、任务分派时序混乱。套人类公司完全成立。

**一个 Agent 不是超人，是岗位。三个 Agent 不是炫技，是团队。**

## See Also

- [Claude Code CLI「不丢上下文」工作流]([[claude-code-cli-context-workflow]]) — 单 Agent 记忆系统，与多 Agent 协作中的上下文管理互补
- [Superpowers 插件完全上手指南]([[superpowers-plugin-guide]]) — Subagent-Driven Development 的另一种多 Agent 实践