# Lookahead 推理加速框架

> 收录: 2026-04-27 | 分类: LLM 推理优化 | 标签: Lookahead, 推理加速, 预测解码

## 核心思想

推理产生 token 的过程，本质是计算全局 token 概率最大。

传统 Decode 是串行的——每个 token 依赖前一个 token，无法并行。

**Lookahead 的关键创新**：多分支并行预测，同时探索多条候选 token 序列，从中选择概率最大的路径继续。

## 方法

```
传统（串行）:
Token1 → Token2 → Token3 → Token4 → ...

Lookahead（并行多分支）:
  Branch A: T1 → T2 → T3 → T4
  Branch B: T1 → T2' → T3' → ...
  Branch C: T1 → ...
         ↓
    选择概率最大路径
```

## 优势

- 在不损失生成精度的前提下加速推理
- 核心洞察：推理瓶颈不在计算量，而在 token 生成的串行依赖

## 参考

- 论文: [Lookahead: An Inference Acceleration Framework for LLM](https://arxiv.org/pdf/2312.12728.pdf)
- 代码: [alipay/PainlessInferenceAcceleration](https://github.com/alipay/PainlessInferenceAcceleration)

## 相关

- [[llm-inference-hardware-dataflow]] — LLM 推理硬件数据流全解
- [[paper-reading-notes]] — 论文精读笔记
