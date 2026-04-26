# Harness彻底把Claude榨干了！Anthropic最新工程博客

> Source: https://mp.weixin.qq.com/s/QjZa3T9lAQxgy3nLm6g5mw
> Collected: 2026-04-26
> Published: Unknown

Anthropic Labs Prithvi Rajasekaran 发布工程博客《Harness Design for Long-Running Application Development》，核心结论：决定 Agent 能力的，不再只是模型本身，而是你给它搭建的 Harness。模型负责做事，Harness 负责让它做对事。

---

## 一、长程开发真正难的是"别跑偏"

Prithvi 过去几个月做两件事：让 Claude 产出高质量前端设计，让 Claude 在几乎没有人工介入的情况下持续数小时构建出完整应用。

从生成对抗网络（GAN）思路获得启发，把"生成"和"评估"拆开，设计三层 Agent 架构：planner（规划者）、generator（生成者）、evaluator（评估者）。

## 二、简单 Agent 为什么总失灵

长程任务里，模型容易出现两种顽固失效模式：

**Context anxiety（上下文焦虑）**：上下文窗口快满时，模型提前收尾。

**Self-evaluation（自我评估）**：自己打分永远偏高。

解决方案：
- **Context reset**（上下文重置）而不是简单压缩
- 把 generator 和 evaluator **彻底分开**，让独立 evaluator 以"怀疑主义者"心态打分

## 三、先让审美变得可评分

把审美拆成四个可评分维度：
- Design quality（设计质量）
- Originality（原创性）
- Craft（工艺）
- Functionality（功能性）

重点惩罚"AI slop"（AI 流水线式糊弄设计）。

通过 5-15 轮迭代 + Playwright 实时交互，让 generator 不断被推向更有个性、更具博物馆级别的设计。

## 四、三层 Agent 接管完整应用构建

扩展到全栈开发：

- **planner**：把 1-4 句话提示扩展成完整产品规格
- **generator**：每次一个 sprint，React + FastAPI + PostgreSQL 技术栈
- **evaluator**：通过 Playwright 像真实用户一样测试，打分 + 返工

每轮 sprint 前，generator 和 evaluator 先签订 **sprint contract（冲刺契约）**，确保方向正确。

## 五、完整 Harness vs 单 Agent 对比

同一个提示"创建一个 2D 复活游戏制作器"：

| | 单 Agent | 完整 Harness |
|--|---------|-------------|
| 时间 | 20 分钟 | 6 小时 |
| 成本 | 9 美元 | 200 美元 |
| 结果 | 实体不响应，游戏跑不起来 | 功能丰富、视觉一致、真正可玩 |

完整 Harness：planner 扩展出 16 个功能点，evaluator 抓出 27 条测试标准，最终实现 AI 辅助精灵生成、关卡设计和分享功能。

## 六、模型变强了，框架也得瘦身

Opus 4.6 发布后，开始简化 harness：每次只删一个组件，测试效果。

核心原则：harness 里的每个部件都隐含"模型自己还做不到"这一假设，必须不断压力测试。

## 七、去掉 Sprint 后，Evaluator 不再是必选项

新模型能力提升后：
- 去掉 sprint 拆解，让模型一次性跑完
- evaluator 只在最终做一次评估
- 是否保留 evaluator，取决于任务是否仍贴着当前模型的能力边界

## 八、4 小时做出网页版数字音频工作站

新提示"在浏览器中用 Web Audio API 构建完整 DAW"：
- 4 小时、124 美元
- planner 扩展规格，generator 做出 AI 集成
- QA 仍抓出功能完整性缺口（如音频拖拽、EQ 曲线等），逼 generator 补齐

## 九、核心结论

> **模型负责做事，Harness 负责让它做对事。**

模型越强，Harness 的空间反而越大。工程师真正有意思的工作，就是不断找到下一组新的、有效的组合方式。

Harness 不是工具链，而是让 AI 在长程、复杂、容易跑偏的任务里"一直做对事"的**指挥系统**。