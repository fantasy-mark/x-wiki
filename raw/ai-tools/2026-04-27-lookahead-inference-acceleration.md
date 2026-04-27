# Lookahead 推理加速框架

> 来源: 用户笔记, 2026-04-27
> 论文: [Lookahead: An Inference Acceleration Framework for Large Language Model with Lossless Generation Accuracy](https://arxiv.org/pdf/2312.12728.pdf)
> 代码: [alipay/PainlessInferenceAcceleration](https://github.com/alipay/PainlessInferenceAcceleration)

## 核心思想

推理产生 token 的过程，本质是计算全局 token 概率最大。

传统方法：逐 token 自回归生成，每个 token 依赖前一个 token，无法并行。

**Lookahead 的核心**：通过多分支预测，并行处理多个 token 序列，显著提高推理速度，同时保证生成精度无损。

## 方法概述

```
传统 Decode（串行）:
Token1 → Token2 → Token3 → Token4 → ...

Lookahead（并行多分支）:
  Branch A: Token1 → Token2 → Token3 → Token4
  Branch B: Token1 → Token2' → Token3' → ...
  Branch C: Token1 → ...
         ↓
  选择概率最大路径继续
```

关键洞察：推理加速的核心瓶颈不在计算量，而在 token 生成的串行依赖。多分支预测通过探索多个候选序列来并行化这一过程。

## 相关

- [[paper-reading-notes]] — 论文精读笔记
- [[llm-inference-hardware-dataflow]] — LLM 推理硬件数据流全解
