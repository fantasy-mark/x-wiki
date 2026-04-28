# 机器学习核心概念

> 收录: 2026-04-27 | 分类: AI 理论基础 | 标签: ML, Embedding, 对比学习, 自监督, 强化学习

## Embedding 的作用

| 作用 | 说明 |
|------|------|
| **降维** | 相比 one-hot 编码，解决数据稀疏问题 |
| **分类** | 在矩阵映射中切分稀疏特征、聚合稠密特征 |
| **可计算** | 向量间计算余弦相似度即可获得关联度 |

## 监督 / 半监督 / 无监督学习

- **无监督**：无标签，聚类（GAN/SOM/ART）、关联规则、维度缩减
- **自监督**：用一个样本构建多个代理任务（pretext task），从无标签数据中学习表示
- **监督学习**：有标签，分类或回归

## 对比学习（Contrastive Learning）

自监督学习的核心方法：通过构造正负样本对，让模型学习"哪些相似、哪些不同"。

关键概念：
- **正样本**：同一实例的不同增强视图（如同一图片的两次随机裁剪）
- **负样本**：其他所有实例
- **Pretext Task**：用于替代标签的代理任务，instance discrimination 是最常用的一种

核心思想：模型不需要知道图片是什么，只需要知道哪些图片类似。

## 强化学习

智能体通过与环境交互，以最大化累积奖励为目标学习策略。

核心组成：Agent、Environment、State、Action、Reward、Policy、Value Function。

典型算法：Q-Learning、SARSA、DQN（深度 Q 网络）、Policy Gradient、Actor-Critic。

## Instruct 与 Prompting 方法演进

| 方法 | 特点 |
|------|------|
| **早期 Prompting** | 人反复尝试写出能 work 的命令，本质是拟合训练分布 |
| **Instruct / Zero Shot** | 自然语言描述任务，让 LLM 理解意图 |
| **Few Shot / ICL** | 通过示例示范任务，LLM 举一反三 |

Instruct 的核心贡献：实现了理想 LLM 的接口层，让 LLM 适配人的习惯，而不是反过来。

## 相关

- [[attention-is-all-you-need-annotated]] — Transformer 架构（Attention 机制）
- [[rag-system-overview]] — RAG 系统
- [[reinforcement-learning-basics]] — 强化学习基础
