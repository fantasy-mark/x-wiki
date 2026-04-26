# 大模型推理时，数据在硬件间经历了什么？

> Source: https://mp.weixin.qq.com/s/XpHelvW8KULSNwCDw7jRXw
> Collected: 2026-04-26
> Published: Unknown

从磁盘到显存的 6 步全拆解：模型加载 → Prefill → Decode → KV Cache → 带宽瓶颈 → 多卡并行。CPU 与 GPU 的分工协作全景图，包含量化指标与优化方法。

---

## 1 模型加载

**数据流向**：SSD → CPU/DDR 内存 → PCIe 总线 → GPU HBM

- NVMe SSD 顺序读取约 7 GB/s
- CPU 通过 DMA（直接内存访问）经 PCIe 4.0 x16（单向带宽约 32 GB/s）送入 GPU
- CPU 是总指挥，GPU 在此阶段被动接收数据

**核心挑战**：模型太大装不下

| 精度 | 每参数字节 | 70B 模型总大小 |
|------|-----------|--------------|
| FP32 | 4 bytes | 280 GB |
| FP16/BF16 | 2 bytes | 140 GB |
| INT8 量化 | 1 byte | 70 GB |
| INT4 量化 | 0.5 bytes | 35 GB |

一张 A100 HBM 显存 80GB，FP16 的 70B 模型需要 140GB，解法：量化压缩（INT8/INT4）或多卡分担（Tensor Parallelism）。

## 2 Prefill 预填充

**CPU**：执行 Tokenization（把自然语言切分成 Token ID 序列），之后进入空闲等待状态。

**GPU**：Tensor Core 一次性并行处理所有 Prompt Token，执行大规模矩阵乘法（GEMM）。GPU 利用率最高的阶段。

| 指标 | Prefill 阶段 | 说明 |
|------|------------|------|
| 算力利用率 | ~80% | Tensor Core 接近满载 |
| 带宽利用率 | ~30% | HBM 绰绰有余 |
| 瓶颈类型 | **Compute-bound** | 计算是瓶颈，带宽够用 |

**反直觉事实**：处理 1000 个 Token 和处理 10 个 Token 耗时几乎一样——Tensor Core 是高度并行的，处理越多 Token 性价比越高。这也是长 Prompt 不显著增加首字延迟的原因。

## 3 Decode 逐 Token 生成

每生成 1 个 Token 的完整循环：
1. GPU 读取全部模型权重（140GB），计算下一个 Token 的概率分布（logits）
2. logits 通过 PCIe 传回 CPU
3. CPU 执行采样策略（Temperature、Top-P 等），选出最终 Token
4. CPU 将 Token ID 送回 GPU，开始下一轮

CPU 在 Decode 阶段扮演"调度员 + 裁判"角色：采样、请求调度（批处理）、KV Cache 内存管理、决定何时停止生成（EOS token）。

**为什么这么慢？**

| 指标 | Decode 阶段 | 说明 |
|------|------------|------|
| 算力利用率 | ~5% | Tensor Core 严重闲置 |
| 带宽利用率 | ~95% | HBM 几乎被打满 |
| 瓶颈类型 | **Memory-bound** | 数据搬运是瓶颈，计算够用 |

每步都要把全部模型权重（140GB）从 HBM 读一遍，但只做了极少量的计算。Tensor Core 大部分时间在干等 HBM 送数据——就像打字速度极快的打字员，但每打一个字之前都要等快递把键盘送来。

## 4 KV Cache 增长

Attention 计算中，每个 Token 生成一组 Key 和 Value 向量，缓存在 GPU 显存中就是 KV Cache。KV Cache 大小随序列长度线性增长。

| 架构 | KV 头数 | 4K 上下文 | 32K 上下文 | 128K 上下文 |
|------|--------|---------|-----------|------------|
| 无 GQA（64 头） | 64 | ~10 GB | ~80 GB | ~320 GB |
| GQA 优化（8 头） | 8 | ~1.3 GB | ~10 GB | ~40 GB |

LLaMA-2 70B 使用 GQA（分组查询注意力），将 KV 头数从 64 减少到 8，KV Cache 压缩到 1/8。128K 上下文时 GQA 版本仍需 40GB，加上模型权重 140GB，总计 180GB——至少需要 3 张 A100。

vLLM 的 PagedAttention 技术将 KV Cache 按页管理（类似操作系统虚拟内存），多个请求可共享 GPU 显存，大幅提升吞吐量。

## 5 带宽瓶颈

**高速公路比喻**：GPU 算力是 8 车道高速，Decode 阶段只有 1 辆车在跑（每步只算 1 个 Token），其余 7 条车道全空。HBM 带宽是 2 车道乡间小路，每步搬 140GB 模型权重，已经堵死。

**算术强度**：Decode 阶段 FLOPs/Bytes ≈ 1，而 A100 的计算-带宽比约为 200——实际只做了 1 次，有能力做 200 次。算力浪费了 99.5%。

**优化方法**：

| 方法 | 原理 | 效果 |
|------|------|------|
| 量化（INT8/INT4） | 减少模型权重位宽，降低搬运量 | INT4 减少 75% 搬运量，Decode 提速 2-4x |
| 推测解码（Speculative Decoding） | 小模型先猜多个 Token，大模型一次性验证 | 多步 Decode 合并为类似 Prefill 的操作，提升算力利用率 |
| FlashAttention | 优化 Attention 显存访问模式，减少 HBM 读写 | Attention 加速 2-4x，省显存 |
| GQA / MQA | 减少 KV 头数，降低 KV Cache 带宽需求 | KV Cache 带宽需求降至 1/8 或 1/64 |

## 6 多 GPU 张量并行

Tensor Parallelism：将每一层权重矩阵按列（或行）切分，每张 GPU 只计算自己负责的部分。计算完成后通过 All-Reduce 汇总结果。

**GPU 间通信带宽对比**：

| 互联方式 | 双向带宽 | 适用 GPU | vs PCIe |
|---------|---------|---------|---------|
| PCIe 4.0 x16 | ~64 GB/s | 所有 GPU | 基准 |
| NVLink 3.0 | 600 GB/s | A100 | 9 倍 |
| NVLink 4.0 | 900 GB/s | H100 | 14 倍 |

4 卡 Tensor Parallel 时，每张卡只读 1/4 模型权重，Decode 延迟可降低近 4 倍。高端推理服务器标配 NVLink——All-Reduce 通信量与模型大小成正比，用 PCIe 会成为新瓶颈。

## CPU 和 GPU 分工全景

| 阶段 | CPU 干什么 | GPU 干什么 | 瓶颈 |
|------|----------|----------|------|
| 模型加载 | 读 SSD、发起 DMA 传输 | 被动接收权重 | PCIe / SSD 带宽 |
| Prefill | Tokenization → 空闲等待 | 并行矩阵乘法 | GPU 算力 |
| Decode | 采样、调度、KV 管理 | 逐步读权重算 logits | HBM 带宽 |
| 多卡并行 | NCCL 初始化、跨卡调度 | 分片计算 + All-Reduce | NVLink 带宽 |