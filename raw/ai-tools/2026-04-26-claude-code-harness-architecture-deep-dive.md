# 从Harness角度对Claude Code源码深度解读

> Source: https://mp.weixin.qq.com/s/zm7VmqLto-bxRTUFgru6AQ
> Collected: 2026-04-26
> Published: Unknown

基于泄露的 Claude Code 公开源码（npm 发布包中的 .map 文件暴露），从 Harness 工程视角系统性分析其架构。核心公式：Claude Code = one agent loop + tools + skill loading + context compression + subagent spawning + task system + team coordination + worktree isolation + permission governance。

源码来源：https://github.com/instructkr/claude-code，约 1900 个文件、512,000+ 行 TypeScript。

---

## 一、核心公式

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

核心哲学：**模型决定做什么，Harness 负责执行怎么做。**

## 二、整体架构

### 目录结构与模块划分

| 目录 | Harness 角色 | 功能说明 |
|------|-------------|---------|
| `src/tools/` | Agent 的双手 | 约 40 个工具实现，文件 I/O、Shell 执行、代码搜索 |
| `src/commands/` | 用户指令接口 | 约 50 个斜杠命令 |
| `src/services/` | 外部服务集成 | API 客户端、MCP 协议、OAuth、LSP |
| `src/coordinator/` | 多智能体协调 | 子智能体编排、调度、协作管理 |
| `src/skills/` | 按需知识加载 | 可复用工作流定义，按需注入 |
| `src/bridge/` | IDE 桥接层 | VS Code、JetBrains 等 IDE 与 CLI 双向通信 |
| `src/hooks/` | 权限与生命周期 | 工具权限校验、会话生命周期 |
| `src/plugins/` | 插件扩展 | 第三方插件加载管理 |
| `src/components/` | 终端 UI | 约 140 个 React+Ink 组件 |
| `src/screens/` | 全屏界面 | 诊断、REPL、恢复等全屏交互 |
| `src/memdir/` | 持久记忆 | 跨会话记忆存储 |
| `src/tasks/` | 任务系统 | 带依赖图的任务管理 |
| `src/state/` | 状态管理 | 全局应用状态 |
| `src/schemas/` | 配置 Schema | 基于 Zod 的配置验证 |

### 关键文件

| 文件 | 规模 | 职责 |
|------|------|------|
| `QueryEngine.ts` | ~46K 行 | LLM 查询引擎：流式响应、工具调用循环、思考模式、重试、Token 计数 |
| `Tool.ts` | ~29K 行 | 工具基础类型：输入 Schema、权限模型、进度状态 |
| `commands.ts` | ~25K 行 | 斜杠命令注册与执行 |
| `main.tsx` | 入口 | CLI 解析 + React/Ink 渲染器初始化，启动并行预取 |
| `context.ts` | — | 系统提示与用户上下文动态收集 |
| `cost-tracker.ts` | — | Token 成本追踪 |

## 三、核心循环：Agent Loop 的 Harness 实现

### QueryEngine：大脑中枢

约 46K 行，承担四个关键 Harness 职责：
1. **流式响应处理**：实时看到模型"思考过程"，与 React+Ink 终端 UI 紧密集成
2. **工具调用循环**：stop_reason="tool_use" 时自动执行工具，将结果追加到消息列表，再次调用模型
3. **扩展思考集成**：允许模型在执行工具前进行更深度推理
4. **重试逻辑与 Token 计数**：应对 API 错误和速率限制，精确追踪消耗

**工具调用循环伪代码**：
```
def agent_loop(messages):
    while True:
        response = client.messages.create(model=MODEL, system=SYSTEM, messages=messages, tools=TOOLS)
        messages.append({"role": "assistant", "content": response.content})
        if response.stop_reason != "tool_use": return
        results = []
        for block in response.content:
            if block.type == "tool_use":
                output = TOOL_HANDLERS[block.name](**block.input)
                results.append({"type": "tool_result", "tool_use_id": block.id, "content": output})
        messages.append({"role": "user", "content": results})
```

### 最小循环的 Harness 意义

**循环属于 Agent，机制属于 Harness**。所有其他机制（工具系统、技能加载、上下文压缩、子智能体）都在这个循环之上层层叠加，不改变循环本身的结构。

## 四、工具系统：Agent 的双手

### 核心工具清单

| 工具名称 | 功能描述 | Harness 层次 |
|---------|---------|------------|
| `BashTool` | Shell 命令执行 | 行动层 |
| `FileReadTool` | 文件读取（支持图片、PDF、Notebook） | 感知层 |
| `FileWriteTool` | 文件创建与覆写 | 行动层 |
| `FileEditTool` | 字符串替换式局部修改 | 行动层 |
| `GlobTool` | 文件模式匹配搜索 | 感知层 |
| `GrepTool` | 基于 ripgrep 的内容搜索 | 感知层 |
| `WebFetchTool` | 获取 URL 内容 | 感知层 |
| `WebSearchTool` | 网络搜索 | 感知层 |
| `AgentTool` | 子智能体生成 | 协调层 |
| `SkillTool` | 技能文件加载与执行 | 知识层 |
| `MCPTool` | MCP 服务器工具调用 | 扩展层 |
| `LSPTool` | 语言服务协议集成 | 感知层 |
| `TaskCreateTool`/`TaskUpdateTool` | 任务创建与管理 | 协调层 |
| `SendMessageTool` | 智能体间消息传递 | 协调层 |
| `TeamCreateTool`/`TeamDeleteTool` | 团队智能体管理 | 协调层 |
| `EnterPlanModeTool`/`ExitPlanModeTool` | 规划模式切换 | 认知层 |
| `EnterWorktreeTool`/`ExitWorktreeTool` | Git Worktree 隔离 | 隔离层 |
| `ToolSearchTool` | 延迟工具发现 | 元层 |
| `CronCreateTool` | 定时触发器创建 | 调度层 |
| `RemoteTriggerTool` | 远程触发 | 调度层 |
| `SyntheticOutputTool` | 结构化输出生成 | 元层 |

### 三条核心设计原则

- **原子性（Atomicity）**：每个工具只做一件事，职责单一明确
- **可组合性（Composability）**：工具间灵活组合，上一工具输出自然成为下一工具输入
- **自我描述性（Self-Describing）**：每个工具通过 Zod v4 Schema 定义输入输出格式；`ToolSearchTool` 实现"延迟工具发现"，允许运行时动态发现新工具，节省上下文空间

### 约50个斜杠命令

| 命令 | 功能 |
|------|------|
| `/commit` | 创建 git 提交 |
| `/review` | 代码审查 |
| `/compact` | 上下文压缩 |
| `/mcp` | MCP 服务器管理 |
| `/skills` | 技能管理 |
| `/tasks` | 任务管理 |
| `/memory` | 持久记忆管理 |
| `/resume` | 恢复上次会话 |

## 五、知识与技能系统：按需学习机制

### 按需知识加载（On-Demand Knowledge Loading）

1. 技能以 `.md` 文件存储在 `skills/` 目录
2. 每个技能文件包含 YAML frontmatter（触发条件）+ 详细知识体
3. 模型判断需要时通过 `SkillTool` 加载
4. 内容通过 `tool_result` 注入上下文

**优势**：避免上下文窗口浪费。在一个编码会话中，Agent 可能需要不同领域知识（前端、数据库、API），全部预加载会快速消耗 Token 预算。

### Progressive Disclosure（渐进式披露）

```
Level 1: Metadata — Agent 首先看到的触发描述
Level 2: Body — 判断需要后加载的详细信息
Level 3: References — 深入分析时才加载的参考资料
```

最大化上下文利用效率。

## 六、上下文管理：三层压缩策略

### 第一层：子智能体隔离

通过 `AgentTool` 生成的子智能体拥有独立的 `messages[]`，操作历史不污染主会话。主会话只接收子智能体返回的最终结果摘要。

```
Lead Agent (messages[]) ──> spawn SubAgent ──> SubAgent (fresh messages[])
                                                       |
                                                   execute task
                                                       |
                                             return summary ──> Lead Agent
```

### 第二层：上下文压缩

`src/services/compact/` 实现，当对话历史接近窗口限制时，将早期对话压缩为摘要，保留关键信息（代码变更、决策理由、用户反馈）。

### 第三层：任务持久化

`src/tasks/` + `src/memdir/` 实现，任务状态持久化到磁盘，单个会话结束后可通过 `/resume` 恢复。将 Agent 的"记忆"从易失的对话上下文扩展到持久化文件系统。

### 系统提示动态构建

`context.ts` 收集和组装系统提示（CLAUDE.md、项目配置、环境信息、代码结构摘要），每次请求可能生成略有不同的系统提示，最大化利用有限上下文。

## 七、多智能体协调：Team Harness 架构

### 六种架构模式

| 模式 | 适用场景 | 通信方式 |
|------|---------|---------|
| Pipeline | 顺序依赖任务（设计→前端→后端→测试） | 上一步输出作为下一步输入 |
| Fan-out/Fan-in | 并行独立任务（多维度代码审查） | 分发后聚合结果 |
| Expert Pool | 上下文依赖的专业任务选择 | 根据任务类型动态选择专家 |
| Producer-Reviewer | 生成后验证（内容创作+质量审核） | 生产者-审核者交替 |
| Supervisor | 中心化动态调度（YouTube 内容规划） | Supervisor 统一调度 |
| Hierarchical Delegation | 复杂任务的自顶向下递归拆分 | 树状层级委派 |

### 团队协作机制

- **Teammates**：持久化的团队成员智能体实例
- **JSONL Mailbox**：基于 JSONL 文件的异步邮箱通信
- **统一请求-响应模式**：包括关闭协商和计划审批等状态机管理
- **自主任务认领**：团队成员在空闲时自动扫描任务面板

### Worktree 隔离

每个子智能体或并行任务在独立 Worktree 中工作，修改自己文件副本不影响主分支或其他任务，任务完成后通过 Git Merge 合并回主分支。

```
main branch:  /project/ (shared)
├── worktree-task-1/ (agent A's sandbox)
├── worktree-task-2/ (agent B's sandbox)
└── worktree-task-3/ (agent C's sandbox)
```

## 八、权限系统：安全边界

### 多级权限模式

| 模式 | 行为 | 适用场景 |
|------|------|---------|
| `default` | 每次工具调用前提示用户审批 | 日常开发，安全优先 |
| `plan` | 规划阶段只读，执行阶段需审批 | 大型重构任务 |
| `auto` | 自动批准低风险操作，高风险仍需审批 | 信任环境快速迭代 |
| `bypassPermissions` | 跳过所有权限检查 | 沙箱/测试环境 |

### 细粒度权限控制

基于以下维度的规则配置：工具类型、操作类型、文件路径模式、命令白名单。

多层防护：权限 hook + Git Worktree 文件系统沙箱。

## 九、Bridge 系统：跨越终端的 Harness 延伸

通过 `src/bridge/` 实现的双向通信层，将 Agent 操作环境从纯终端扩展到 IDE（VS Code、JetBrains）：

| 组件 | 功能 |
|------|------|
| `bridgeMain.ts` | 管理 IDE 与 CLI 进程之间的通信生命周期 |
| `bridgeMessaging.ts` | 消息协议：请求类型、响应格式、错误处理 |
| `bridgePermissionCallbacks.ts` | 将权限审批流程桥接到 IDE UI |
| `jwtUtils.ts` | 基于 JWT 的认证机制 |
| `sessionRunner.ts` | 管理会话的启动、运行和终止生命周期 |

## 十、性能优化：工程细节

### 并行预取启动优化

`main.tsx` 在模块评估开始前，通过副作用代码并行启动：
```js
// fired as side-effects before other imports
startMdmRawRead()        // MDM 设置读取
startKeychainPrefetch()  // Keychain 凭据预取
// + GrowthBook 初始化 + API 预连接
```

用户看到提示符时，耗时操作已在后台完成。

### 懒加载与死代码消除

重量级模块通过动态 `import()` 延迟加载。利用 Bun 运行时的 `bun:bundle` 特性标志实现编译时死代码消除：

```js
import { feature } from 'bun:bundle'
const voiceCommand = feature('VOICE_MODE')
    ? require('./commands/voice/index.js').default
    : null
```

主要特性标志：PROACTIVE（主动模式）、KAIROS（时间感知调度）、BRIDGE_MODE（IDE 桥接）、DAEMON（守护进程）、VOICE_MODE（语音输入）。

### 技术栈

| 类别 | 技术选型 |
|------|---------|
| 运行时 | Bun（高性能 JS/TS，原生支持 bundle 特性标志）|
| 语言 | TypeScript (strict) |
| 终端 UI | React + Ink（140+ 组件）|
| CLI 解析 | Commander.js |
| Schema 验证 | Zod v4 |
| 代码搜索 | ripgrep |
| 外部协议 | MCP SDK, LSP |
| API | Anthropic SDK |
| 遥测 | OpenTelemetry + gRPC |
| 特性标志 | GrowthBook |
| 认证 | OAuth 2.0, JWT, Keychain |

## 十一、Harness 工程核心洞察

### 模型即智能体，代码即缰绳

> "The model is the agent. The code is the harness."

Claude Code 完全信任 Claude 模型的决策能力，将全部工程精力投入到为模型提供清晰、丰富、安全的工作环境。

> "Prompt plumbing 'agents' are the fantasy of programmers who don't train models. They attempt to brute-force intelligence by stacking procedural logic — massive rule trees, node graphs, chain-of-prompt waterfalls — and praying that enough glue code will somehow emergently produce autonomous behavior. It won't. You cannot engineer your way to agency. Agency is learned, not programmed."

### Harness 工程师的五大职责

1. **实现工具**（给 Agent 双手）— 原子性、可组合性、自我描述性
2. **策划知识**（给 Agent 专业知识）— 按需加载、渐进式披露
3. **管理上下文**（给 Agent 清洁记忆）— 三层压缩策略
4. **控制权限**（给 Agent 安全边界）— 多级模式 + 细粒度控制 + Worktree 沙箱
5. **收集训练信号**（改进下一代 Agent）— 每次感知-推理-行动序列都是宝贵训练数据

### 通用化启示

核心循环始终相同（模型接收→决定行动→执行工具→获取结果→再次决策），改变的只是工具、知识和权限——这些正是 Harness 工程师的工作范畴。

```
Estate management agent  = model + property sensors + maintenance tools + tenant comms
Agricultural agent       = model + soil/weather data + irrigation controls + crop knowledge
Medical research agent   = model + literature search + lab instruments + protocol docs
Manufacturing agent      = model + production line sensors + quality controls + logistics
```

**最重要的启示**：最好的 Agent 产品来自于那些理解"自己的工作是 Harness，而非智能"的工程师。当我们将工程精力从"试图编程智能"转向"为智能构建世界"时，Agent 系统的能力上限将由模型本身的智能水平决定，而非被差劲的 Harness 设计所限制。