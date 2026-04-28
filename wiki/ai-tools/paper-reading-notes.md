# 论文精读笔记

> 收录: 2026-04-27 | 分类: AI 论文笔记 | 标签: CLIP, Diffusion, Transformer, RAG, CodeGen, LLM

## 骨干模型

| 论文 | 核心贡献 |
|------|---------|
| **CLIP** | 图片-文本对比学习，zero-shot 图像分类 |
| **MAE** | 掩码自编码器，可扩展视觉表示学习 |
| **MoCo** | 动量对比，无监督视觉表示 |
| **DETR** | Transformer 替代传统检测头，端到端目标检测 |
| **DALL-E 2** | CLIP 潜空间 + 扩散模型，层级文本条件图像生成 |
| **ViLT** | 统一 V&L 到 Transformer，无需 CNN 或区域监督 |

## 基础模型

| 论文 | 核心贡献 |
|------|---------|
| **Transformer** | 注意力机制大一统，NLP/CV/Audio 通用骨干 |
| **DDPM** | 扩散概率模型，当前 Sora/Stable Diffusion 的理论基础 |

详见：[[attention-is-all-you-need-annotated]]

## 推理优化

| 论文 | 核心贡献 |
|------|---------|
| **Lookahead** | 小模型预测 token 序列，大模型批量解码，加速推理 |
| **GaLore** | 梯度低秩投影，降低 LLM 训练的显存需求 |

## 代码生成

| 论文 | 核心贡献 |
|------|---------|
| **CodeX** | GitHub 代码预训练 GPT，pass@k 评估指标 |
| **AlphaCode** | 编程竞赛级别代码生成，n@k 指标 + GLOD 算法评估 |

## 数学辅助 LLM

- **Nature 论文**：通过 97 轮对话解决 P/NP 难题
- **P vs. NP 论文**：LLM + 演绎/变换/分解/验证/融合五步法

核心启示：能否恰当使用 prompt 是充分挖掘 LLM 能力的关键。

## RAG 与知识图谱

**Unifying Large Language Models and Knowledge Graphs: A Roadmap** — LLM 与知识图谱融合路线图。

详见：[[rag-system-overview]]

## 相关

- [[attention-is-all-you-need-annotated]] — Transformer 论文精读
- [[rag-system-overview]] — RAG 系统概述
- [[ml-core-concepts]] — Embedding、对比学习等基础概念
- [[reinforcement-learning-basics]] — 强化学习基础（RLHF/DPO 基础）
