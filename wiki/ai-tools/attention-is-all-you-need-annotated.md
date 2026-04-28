# Attention Is All You Need — 论文精读 + Annotated Transformer 实现

> 收录: 2026-04-27 | 分类: AI 基础模型 | 标签: Transformer, Attention, PyTorch, NLP

## 概述

2017 年 Vaswani 等人提出的 Transformer 论文，是深度学习历史上最重要的里程碑之一。Transformer 完全基于注意力机制，抛弃了 RNN/LSTM 的序列依赖，首次实现了真正的并行训练，并在 NLP、CV、Audio 等领域统一了骨干网络架构。

本文档基于 Harvard NLP 的 [The Annotated Transformer](https://nlp.seas.harvard.edu/annotated-transformer/)，逐行实现论文中的所有组件，配以详细注释。

## 核心创新

| 特性 | 说明 |
|------|------|
| **并行训练** | 注意力计算无时序依赖，可完全并行 |
| **全局感受野** | 每个 token 一步到位汇聚所有位置的信息 |
| **多头注意力** | 多组 QKV 并行计算，学习不同子空间的注意力模式 |
| **可扩展** | 通过增加层数和头数 scale up |

## 整体架构

```
输入 Embedding + 位置编码
       ↓
  编码器 (N=6层)
  ├── Multi-Head Self-Attention
  └── Feed Forward (MLP)
       ↓
  解码器 (N=6层)
  ├── Masked Self-Attention
  ├── Cross-Attention (attend to encoder)
  └── Feed Forward (MLP)
       ↓
  输出 Linear + Softmax
```

关键参数：d_model=512, d_ff=2048, h=8, dropout=0.1

## 注意力机制

### Scaled Dot-Product Attention

$$Attention(Q,K,V) = softmax(\frac{QK^T}{\sqrt{d_k}})V$$

除以 $\sqrt{d_k}$ 的原因：抑制 Q 值增大时 softmax 梯度消失。

可学习参数：$W_Q, W_K, W_V$ 三个矩阵。

### Multi-Head Attention

$$MultiHead(Q,K,V) = Concat(head_1,...,head_h)W^O$$
$$head_i = Attention(QW_i^Q, KW_i^K, VW_i^V)$$

多个头允许模型同时关注不同位置的不同表示子空间。

## 位置编码

采用正弦版本，无需学习，支持外推到训练集以外的序列长度：

$$PE_{(pos,2i)} = \sin(pos/1000^{2i/d_{model}})$$
$$PE_{(pos,2i+1)} = \cos(pos/1000^{2i/d_{model}})$$

## 训练技巧

- **Noam Warmup LR**：$d^{-0.5} \cdot \min(step^{-0.5}, step \cdot warmup^{-1.5})$
- **标签平滑 (Label Smoothing)**：正则化，防止 over-confidence
- **残差连接 + LayerNorm**：先 Norm 再残差，利于梯度流动
- **解码器 Mask**：防止看到未来 token

## 完整代码

详见 raw 文件：`raw/ai-tools/2026-04-27-attention-is-all-you-need-annotated.md`

包含完整 PyTorch 实现：
- Transformer 整体架构
- Encoder/Decoder 层
- LayerNorm / SublayerConnection
- MultiHeadedAttention（含 Masked Attention）
- PositionwiseFeedForward
- Embeddings / PositionalEncoding
- 学习率调度、标签平滑、贪心解码
- 分布式训练入口

## 结论

Transformer 在机器翻译任务上取得了 SOTA，并已被广泛应用于 ViT、DETR、GPT、T5 等后续工作，成为深度学习时代大一统的模型架构。

## 相关

- [[pytorch-framework-architecture]] — PyTorch 框架源码架构
- [[paper-reading-notes]] — 更多论文精读笔记
- [[rag-system-overview]] — RAG 系统概述
