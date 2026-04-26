# 我用 Claude Code CLI 搭了一套「不丢上下文」的工作流

> Source: https://mp.weixin.qq.com/s/I7aZM-aWYtnEPktZ4mZtGg
> Collected: 2026-04-25
> Published: Unknown

用 Claude Code CLI 半年，搭建了一套完整的工作流解决核心痛点：context 压缩后记忆丢失、多项目上下文无法共享、批处理模式与连续性工作方式不匹配。

---

## 核心痛点

1. **context 一压缩，之前聊的全没了** — 2 小时的架构决策讨论，compact 后 Claude 完全不记得
2. **多项目上下文来回切** — 每个项目一个 session，互相看不到，变成"人肉信息搬运工"
3. **批处理模式不适合连续性工作** — start/end 打卡制设计，凌晨随手写两行代码的人根本用不上

## 指挥室：跨项目感知

单独开一个 Claude Code 项目，不写代码，专门管所有项目的节奏：产品决策、需求文档、进度追踪。

- 用一个 JSON 注册表记录所有项目的名称和路径
- 在指挥室打 `/recap` → 遍历所有项目进度，全局视图
- 在具体项目里打 `/recap` → 只看当前项目，避免噪音
- 任务管理挂 Linear（CLI 里直接查/改状态）

## 工作流演进：从批处理到流式

### 第一版：start-working + end-working

开工时跑环境检查，收工时跑同步。跑了一周就废了——本质是"打卡制"，不适合窗口一直开着、凌晨随手写的连续性工作方式。

### 第二版：checkpoint + recap

流式设计，随时可存，随时可恢复。

**`/checkpoint` — 存档**
- 写入 `docs/memory/YYYY-MM-DD.md`，记录当日完成事项、决策、进行中工作
- 交给 subagent 后台执行，不占主上下文
- 触发时机：手动调用、对话太长快 compact 时、AI 自动触发
- 同时同步 `progress.md` 和 Linear 任务状态

**`/recap` — 恢复**
- 新 session 开头执行，读最近 memory 和 progress
- 告诉你"上次到哪了，继续哪个？"

从批处理变成流式，跟实际工作节奏完全对上。

## 三层记忆系统

| 层 | 文件 | 解决什么 | 谁写 |
|---|---|---|---|
| auto memory | `~/.claude/projects/*/memory/` | 你是谁、怎么工作、踩过什么坑 | Claude 自动 + 你触发 |
| 工作日志 | `docs/memory/YYYY-MM-DD.md` | 今天干了什么、做了什么决策 | /checkpoint 写入 |
| 当前快照 | `docs/progress.md` | 现在在做什么、下一步是什么 | /checkpoint 同步更新 |

- auto memory 跨项目生效（A 项目纠正的行为，B 项目也知道）
- `/recap` 开头把三层都读一遍，完整恢复上下文

## 全局 CLAUDE.md：跨项目一致性

`~/.claude/CLAUDE.md` 放全局规范，所有项目 session 自动加载：
- 需求文档编号规则
- commit message 风格
- 文件命名规范

项目级 `CLAUDE.md` 只放该项目特有的技术栈和架构信息。

## 踩坑不白踩：/postmortem

参考 Google/Meta 的事故复盘流程，写了一个 `/postmortem` 命令：
1. 还原时间线 — 问题怎么发现、试了哪些方案、怎么解决
2. 分析根因 — 表面原因 vs 真正原因
3. 写入 `docs/postmortem/` 存档
4. 判断教训是否要写入 memory 或全局 CLAUDE.md，让所有 session 都受益

## 新项目起步：/init-project

基于模板 `~/.claude/CLAUDE-TEMPLATE.md` 自动生成：
- CLAUDE.md
- docs 目录（requirements、features、memory、postmortem）
- progress.md
- .gitignore

模板引用全局 CLAUDE.md 规范，新项目从第一天就知道文档怎么写。

## 整体文件结构

**全局层（所有项目共享）**
```
~/.claude/CLAUDE.md               ← 全局规范
~/.claude/CLAUDE-TEMPLATE.md      ← 新项目模板
~/.claude/commands/recap.md       ← 恢复上下文
~/.claude/commands/checkpoint.md  ← 存档进展
~/.claude/commands/init-project.md ← 初始化新项目
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

## 四个核心命令

```
/checkpoint   — 随时存档，不丢上下文
/recap        — 新 session 秒恢复，不用重新解释
/postmortem  — 踩坑变记忆，同一个错不犯两次
/init-project — 新项目自带规范，不用从头教
```

**本质**：把 AI 需要的上下文从对话里搬到文件里。对话会 compact，文件不会。
