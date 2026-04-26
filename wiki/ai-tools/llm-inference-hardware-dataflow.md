# 大模型推理的硬件数据流全解

> Sources: sky饼 / 张昺华, 2026-04-26
> Raw: [llm-inference-hardware-dataflow](../../raw/ai-tools/2026-04-26-llm-inference-hardware-dataflow.md)

## Overview

从磁盘到显存的 6 步全拆解：模型加载 → Prefill → Decode → KV Cache → 带宽瓶颈 → 多卡并行。核心结论：Prefill 是 Compute-bound（GPU 算力是瓶颈），Decode 是 Memory-bound（HBM 带宽是瓶颈）——大模型一个字一个字蹦出来不是因为 GPU 算不够，而是数据搬运太慢。

## 六步全景图

```
SSD → CPU/DDR → PCIe → GPU HBM → Tensor Core → logits → CPU 采样 → Token → GPU（循环）
```

| 阶段 | CPU 角色 | GPU 角色 | 瓶颈类型 |
|------|---------|---------|---------|
| 模型加载 | 总指挥，读 SSD，发 DMA | 被动接收 | PCIe / SSD 带宽 |
| Prefill | Tokenization 后空闲 | 并行矩阵乘法（GEMM） | **Compute-bound** |
| Decode | 采样 + 调度 + KV 管理 | 逐步读权重算 logits | **Memory-bound** |
| 多卡并行 | NCCL 初始化、跨卡调度 | 分片计算 + All-Reduce | NVLink 带宽 |

## 模型加载

**数据流**：SSD → CPU/DDR 内存 → PCIe 总线 → GPU HBM

- NVMe SSD 顺序读约 7 GB/s
- PCIe 4.0 x16 单向带宽约 32 GB/s
- CPU 是总指挥，发起和管理 DMA 传输

**核心挑战**：模型装不下显存

| 精度 | 70B 模型大小 | 一张 A100（80GB）能否装下 |
|------|------------|----------------------|
| FP32 | 280 GB | ❌ 需要 4 张 |
| FP16/BF16 | 140 GB | ❌ 需要 2 张 |
| INT8 | 70 GB | ❌ 需要 1 张但紧张 |
| INT4 | 35 GB | ✅ 可以 |

解法：量化压缩（INT8/INT4 降低位宽）或多卡 Tensor Parallelism。

## Prefill：Compute-Bound

**CPU**：Tokenization 把自然语言切分成 Token ID 序列，然后空闲等待。

**GPU**：Tensor Core 一次性并行处理所有 Prompt Token，执行大规模矩阵乘法（GEMM）。

| 指标 | 数值 | 说明 |
|------|------|------|
| 算力利用率 | ~80% | Tensor Core 接近满载 |
| 带宽利用率 | ~30% | HBM 有大量富余 |
| 瓶颈 | **计算** | 带宽够用，算力是限制 |

**反直觉**：处理 1000 个 Token 和处理 10 个 Token 耗时几乎一样——Tensor Core 并行度极高，Token 越多性价比越高。这解释了为什么长 Prompt 不显著增加首字延迟。

## Decode：Memory-Bound

每步循环：
1. GPU 从 HBM 读全部模型权重（140GB），算 logits
2. logits 经 PCIe 传回 CPU
3. CPU 执行采样（Temperature/Top-P），选 Token
4. Token ID 回 GPU，开始下一轮

**核心瓶颈**：每步搬 140GB 数据，但只做极少计算。

| 指标 | 数值 | 说明 |
|------|------|------|
| 算力利用率 | ~5% | Tensor Core 严重闲置 |
| 带宽利用率 | ~95% | HBM 几乎被打满 |
| 瓶颈 | **数据搬运** | 计算够用，带宽是限制 |

**高速公路比喻**：GPU 算力是 8 车道高速，Decode 只有 1 辆车（每步算 1 个 Token），7 条车道空着。HBM 是 2 车道乡间小路，搬 140GB 权重已经堵死。

**算术强度**：Decode 阶段 FLOPs/Bytes ≈ 1，而 A100 计算-带宽比约为 200。实际做了 1 次，有能力做 200 次——算力浪费 99.5%。

## KV Cache

每个 Token 的 K/V 向量缓存在 GPU 显存中，随序列长度线性增长。

| 架构 | KV 头数 | 4K | 32K | 128K |
|------|--------|-----|-----|------|
| 无 GQA | 64 | ~10 GB | ~80 GB | ~320 GB |
| GQA | 8 | ~1.3 GB | ~10 GB | ~40 GB |

GQA（分组查询注意力）将 KV 头数从 64 减到 8，KV Cache 压缩到 1/8。128K 上下文时 70B 模型总计 180GB，需 3 张 A100。

**PagedAttention**（vLLM）：将 KV Cache 按页管理（类似 OS 虚拟内存），多请求共享显存，大幅提升吞吐量。

## 优化方法

| 方法 | 原理 | 效果 |
|------|------|------|
| INT8/INT4 量化 | 减少权重位宽 | INT4 减少 75% 搬运量，Decode 提速 2-4x |
| 推测解码 | 小模型猜多个 Token，大模型一次验证 | 多步 Decode 合并为类 Prefill 操作 |
| FlashAttention | 优化 Attention 显存访问，减少 HBM 读写 | Attention 加速 2-4x，省显存 |
| GQA/MQA | 减少 KV 头数 | KV Cache 带宽需求降至 1/8~1/64 |

## 多 GPU 张量并行

Tensor Parallelism：每层权重按列/行切分，每张卡只算自己负责的部分，计算后 All-Reduce 汇总。

| 互联方式 | 双向带宽 | 适用 GPU | vs PCIe |
|---------|---------|---------|---------|
| PCIe 4.0 x16 | ~64 GB/s | 通用 | 基准 |
| NVLink 3.0 | 600 GB/s | A100 | 9 倍 |
| NVLink 4.0 | 900 GB/s | H100 | 14 倍 |

4 卡并行：每张卡只读 1/4 权重，Decode 延迟降低近 4 倍。高端推理服务器标配 NVLink——All-Reduce 通信量与模型大小成正比，PCIe 会成为新瓶颈。

## See Also

- [PrfaaS：跨数据中心万亿模型推理架构]([[prfaas-cross-datacenter-llm-inference]]) — 跨数据中心推理调度，与本文单卡/多卡内计算互补
- [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) — 推理引擎的 Harness 实现