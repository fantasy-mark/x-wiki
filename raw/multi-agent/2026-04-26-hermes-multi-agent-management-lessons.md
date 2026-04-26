# 搞完 Hermes 多 Agent 我才发现，这根本不是技术活，是管理活

> Source: https://mp.weixin.qq.com/s/oGXo8psXgP6A24mmKbTGIw
> Collected: 2026-04-26
> Published: Unknown

用 Hermes + Discord 搭建三人多 Agent 协作小组的完整实践记录，踩了三个坑（无 @、停不下来、同时 @ 两人）并逐一修复。核心结论：多 Agent 不是技术问题，是管理问题——每个 profile 是工位，SOUL.md 是职责说明书、协作流程和下班时间。

---

## 核心前置原则

协作是能力的放大器，不是补丁。如果单个 Agent 本身是个废柴，三个废柴协作结果就是三倍的废柴。把 Agent 调教好（SOUL.md 写细、skills 配齐、模型选对），是多 Agent 能跑的前提，不是结果。

## Profile 系统：进程级真隔离

Hermes 里一个 profile 就是一个完全独立的 AI 分身：独立的 config.yaml、.env、SOUL.md、memory、skills，甚至独立的 gateway 进程。靠 HERMES_HOME 环境变量切换根目录实现隔离。

**与 OpenClaw 的区别**：OpenClaw 多身份是配置层面的切换，进程还是同一套。Hermes 是进程级隔离，一个 bot 挂了完全不影响其他 bot 继续干活。

### 克隆策略选择

```
hermes profile create mybot                # 空白 profile，连 API key 都要重新配
hermes profile create mybot --clone         # 只复制 config.yaml/.env/SOUL.md，记忆全新
hermes profile create mybot --clone-all     # 连 memory/sessions/skills/cron 全拷贝
```

多 Agent 协作场景基本都用 `--clone`——共享模型和 API key，每个 agent 从干净的上下文开始。

## 搭建三人小组

- **林小墨 (Ink)**：文案专家，负责笔记整理
- **林小探 (Search)**：情报专家，负责搜索调研
- **林小管 (Admin)**：调度员，负责任务分发

工作流：`用户 → Admin 接收需求 → @ Search 调研 → @ Ink 整理 → Admin 总结并【任务结束】`

## 三个坑与修复

### 坑1：没有 @，直接就结束了

**问题**：SOUL.md 里写了"林小探是团队成员"，LLM 理解文字，但不知道在 Discord 里要靠 `<@用户ID>` 才能真正叫醒对方。

**解法**：在花名册里直接把 ID 挂在名字后面：
```
- 林小探 (Search): 【Executor】负责搜索调研。ID: `<@1495291492397224117>`
```
**注意**：计划阶段用纯文字（如"林小探"），执行阶段才用 `<@ID>`。如果在规划阶段就带 ID，会导致 bot 在规划阶段就被误唤醒。

### 坑2：任务结束后，停不下来了

**问题**：admin 发"任务完成👍"，林小墨收到后回复"好的👋"，admin 又回复"收到🎉"……形成死循环。

**三层解决**：

**第一层：DISCORD_ALLOW_BOTS**
```
# 三个 profile 的 .env 统一设
DISCORD_ALLOW_BOTS=mentions
```
三档模式：always（任何 bot 消息都响应）、never（完全忽略 bot）、mentions（只有 @ 才响应）。选 mentions。

**第二层：replied_user: false**
Discord 的 reply 功能默认会自动给被回复者发隐式 mention。在 config.yaml 里关掉：
```yaml
discord:
  allow_mentions:
    everyone: false
    roles: false
    users: true
    replied_user: false
```

**第三层：SOUL.md 里的终止协议**
```
## 任务终止与防循环规范
- 明确终结：当确认林小墨完成笔记整理后，发出简短总结，以"【任务结束】"结尾。
- 禁止冗余：任务结束后严禁发送无意义表情、寒暄或单纯确认消息。
- 中断反馈：不要对其他 Bot 发出的"收悉"、"待命"等结束类消息做二次响应。
- 艾特控制：结束总结中禁止再次艾特任何 ID。
```

### 坑3：直接同时 @ 了两个人

**问题**：admin 一上来同时 @ 了 Search 和 Ink，两人同时开始干活，Ink 拿不到 Search 的调研结果，只能瞎写。

**解法**：在 SOUL.md 里强制时序规范：
```
## 协作时序规范 (Strict Timing)
- 逐一唤醒：严禁在任务开始阶段同时艾特多个专家。
- 当前阶段：仅在当前步骤需要执行时，才发出对应 <@ID> 指令。
- 接力逻辑：必须等到林小探明确回复"调研完成"后，才 @ 林小墨开始 Step 2。
```

## Discord 配置要点

- **allowed_channels**：Discord gateway 默认只响应白名单频道里的 @，需要在 config 里显式指定 channel ID
- **auto_thread**：默认开启，每个任务在独立 thread 里执行，主频道不被刷屏，追溯调试方便
- **Token 独立**：每个 profile 的 .env 必须用独立的 Discord bot token，不能复用。Hermes 内置 token lock 机制，复用会直接报错

## 最终版 Admin 的 SOUL.md 核心结构

```
## 角色定义
你是"林小管"，团队的【总调度/Planner】，核心职责是接收需求、拆解步骤、逐一指引专家。

## 团队成员（带 ID）
- 林小探 (Search): ID: `<@1495291492397224117>`
- 林小墨 (Ink): ID: `<@1495250337139785955>`

## 核心协作准则
1. 任务分解：先列执行计划，计划里用纯文字，禁用 ID 格式防止误唤醒
2. 身份隔离：你仅担任调度员，必须通过 Discord 公开"点名"完成接力，不能直接调用执行类工具
3. 状态追踪：只有前一个专家明确完成后，才发起下一阶段指令

## 协作时序规范
逐一唤醒、接力逻辑（等"调研完成"再 @ Ink）

## Discord 艾特指令
执行阶段用 <@ID>，非执行阶段用纯文字

## 任务终止与防循环规范
【任务结束】结尾、禁止表情、禁止二次响应、禁止在总结里 @ 任何人
```

## 核心结论

多 Agent 是个管理问题，不是技术问题：
- Profile = 工位（给你的是物理空间）
- Discord = 会议室（给你的是通信基础设施）
- SOUL.md = 职责说明书 + 协作流程 + 下班时间（真正让三个 AI 像团队一样跑起来的东西）

三个坑的本质：
1. 没 @ → 下属不知道该找谁汇报
2. 停不下来 → 没有明确的项目终结机制
3. 同时 @ → 任务分派时序混乱

套人类公司一样成立。过去做不好多 Agent，是因为没把 AI 当员工来管理，一直指望它一个人搞定一切。

**一个 Agent 不是超人，是岗位。三个 Agent 不是炫技，是团队。**