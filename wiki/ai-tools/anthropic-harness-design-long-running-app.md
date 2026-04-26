# Anthropic 工程博客：Harness 设计让 AI 在长程任务中"做对事"

> Sources: 魔卡AI, 2026-04-26; Prithvi Rajasekaran (Anthropic Labs), 《Harness Design for Long-Running Application Development》
> Raw: [anthropic-harness-design-long-running-app](../../raw/ai-tools/2026-04-26-anthropic-harness-design-long-running-app.md)

## Overview

Anthropic Labs 工程博客核心结论：决定 Agent 能力的，不再只是模型本身，而是你给它搭建的 Harness。模型负责做事，Harness 负责让它做对事。详细记录了三层 Agent 架构（planner/generator/evaluator）的搭建、测试与迭代过程。

## 核心命题

> "Harness 不是工具链，而是让 AI 在长程、复杂、容易跑偏的任务里'一直做对事'的指挥系统。模型负责做事，Harness 负责让它做对事。"

**模型越强，Harness 的空间反而越大。** 工程师真正有意思的工作，是不断找到下一组新的、有效的组合方式。

## 简单 Agent 为什么总失灵

长程任务里，模型容易出现两种顽固失效模式：

| 失效模式 | 表现 | 解法 |
|---------|------|------|
| **Context anxiety**（上下文焦虑） | 上下文窗口快满时，模型提前收尾 | Context reset（上下文重置），而不是简单压缩 |
| **Self-evaluation**（自我评估） | 自己打分永远偏高 | 把 generator 和 evaluator **彻底分开**，让独立 evaluator 以"怀疑主义者"心态打分 |

## 三层 Agent 架构

从 GAN（生成对抗网络）思路获得启发，把"生成"和"评估"拆开：

| Agent | 职责 | 说明 |
|-------|------|------|
| **planner** | 规划者 | 把 1-4 句话提示扩展成完整产品规格 |
| **generator** | 生成者 | 每次一个 sprint，技术栈如 React + FastAPI + PostgreSQL |
| **evaluator** | 评估者 | 通过 Playwright 像真实用户一样测试，打分 + 返工 |

**sprint contract（冲刺契约）**：每轮 sprint 前，generator 和 evaluator 先签订，确保方向正确。

## 从前端到全栈的演进

### 阶段一：让审美变得可评分

把审美拆成四个可评分维度：
- Design quality（设计质量）
- Originality（原创性）
- Craft（工艺）
- Functionality（功能性）

重点惩罚"AI slop"（AI 流水线式糊弄设计）。通过 5-15 轮迭代 + Playwright 实时交互，让 generator 不断被推向更有个性、更具博物馆级别的设计。

### 阶段二：全栈开发

- planner 扩展规格
- generator 做出 AI 集成
- QA 仍抓出功能完整性缺口，逼 generator 补齐

### 对比实验：单 Agent vs 完整 Harness

| | 单 Agent | 完整 Harness |
|--|---------|-------------|
| 时间 | 20 分钟 | 6 小时 |
| 成本 | 9 美元 | 200 美元 |
| 结果 | 实体不响应，游戏跑不起来 | 功能丰富、视觉一致、真正可玩 |

完整 Harness 的能力：planner 扩展出 16 个功能点，evaluator 抓出 27 条测试标准，最终实现 AI 辅助精灵生成、关卡设计和分享功能。

## 模型变强后的 harness 瘦身

Opus 4.6 发布后，开始简化 harness：**每次只删一个组件，测试效果**。

核心原则：harness 里的每个部件都隐含"模型自己还做不到"这一假设，必须不断压力测试。

**瘦身后的变化**：
- 去掉 sprint 拆解，让模型一次性跑完
- evaluator 只在最终做一次评估
- **是否保留 evaluator，取决于任务是否仍贴着当前模型的能力边界**

这意味着：随着模型能力提升，harness 可以精简，但**不是消失**。

## 与 Claude Code Harness 架构的关系

Anthropic 这篇工程博客是 Claude Code 源码分析（见 [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]])）的实践印证：

- **源码层**：Claude Code 的工具系统（40+ 原子工具）、上下文压缩、子智能体隔离——这些都是 Harness 的具体实现
- **实践层**：本文展示了在真实长程开发任务中，哪些 Harness 组件真正发挥作用，哪些可以随着模型变强而简化

两者共同指向同一个结论：**The model is the agent. The code is the harness.** 模型和 Harness 共同决定 Agent 的能力上限。

## See Also

- [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) — Claude Code 的 Harness 架构系统性拆解，与本文实践互为印证
- [驾驭工程]([[harness-engineering]]) — 基于 Claude Code 源码的开源技术书籍
- [Hermes 多 Agent 协作：不是技术，是管理]([[hermes-multi-agent-management-lessons]]) — 多 Agent 协作的管理视角，evaluator 分离机制与此相通