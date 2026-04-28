# 强化学习基础

> 收录: 2026-04-27 | 分类: AI 理论基础 | 标签: RL, Agent, MDP, Q-Learning, DQN

## 定义

强化学习（Reinforcement Learning）是机器学习的一个分支，通过智能体（Agent）与环境交互，以最大化累积奖励为目标，学习最优策略。

## 核心组成

| 要素 | 说明 |
|------|------|
| **Agent** | 学习并决策的主体 |
| **Environment** | Agent 所在的外部世界 |
| **State (S)** | 环境在某一时刻的状态 |
| **Action (A)** | Agent 可采取的动作 |
| **Reward (R)** | 动作后的即时反馈 |
| **Policy (π)** | 状态 → 动作的映射 |
| **Value Function (V)** | 未来累积奖励的期望 |

## 学习过程

- **探索（Exploration）**：尝试随机动作以发现更好的策略
- **利用（Exploitation）**：选择当前最优动作以最大化奖励
- **学习**：通过奖励信号更新策略
- **评估**：评估当前策略效果并调整

## 典型算法

| 算法 | 类型 | 核心思想 |
|------|------|---------|
| Q-Learning | Off-policy TD | 通过 Q 表近似最优动作价值函数 |
| SARSA | On-policy TD | 同策略版本，考虑实际采取的动作 |
| DQN | Off-policy | 用深度网络近似 Q 函数，解决大规模状态空间 |
| Policy Gradient | On-policy | 直接优化策略网络的参数 |
| Actor-Critic | 混合 | 结合 value-based 和 policy-based 的优点 |
| PPO | On-policy | 对策略更新做裁剪，稳定训练 |
| DDPG | Off-policy | 连续动作空间的深度强化学习 |
| SAC | Off-policy | 最大熵强化学习，探索性更好 |

## 应用场景

- 游戏 AI（AlphaGo、Atari、Dota2）
- 机器人控制
- 自动驾驶
- 推荐系统
- 资源调度
- LLM 对齐（RLHF / DPO）

## 相关

- [[ml-core-concepts]] — 机器学习核心概念
- [[paper-reading-notes]] — 论文精读（CodeX、AlphaCode 等）
