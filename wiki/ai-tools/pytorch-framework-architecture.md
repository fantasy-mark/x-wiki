# PyTorch 框架源码架构

> 收录: 2026-04-27 | 分类: AI 工程基础 | 标签: PyTorch, C++, CUDA, ATen, TorchDynamo

## 整体架构

PyTorch 源码由三层组成：

```
torch/          ← Python 前端（用户直接交互）
  ATen/        ← "A Tensor Library for C++11"（张量运算声明）
  c10/         ← "Caffe2 Tensor Library"（底层数据结构实现）
```

## 三层详解

### torch

Tensor 和 autograd 自动求导系统的 Python 命名空间。torch 层的 Tensor 比 ATen 多了梯度追踪能力。

自动求导核心模块：
- `torch.autograd.function` — 函数级反向传播
- `torch.autograd.functional` — 计算图反向传播
- `torch.autograd.gradcheck` — 数值梯度检查
- `torch.autograd.anomaly_mode` — 追踪反向传播错误路径
- `torch.autograd.grad_mode` — 控制是否追踪梯度
- `torch.autograd.profiler` — function 级性能分析

### ATen (A Tensor Library for C++11)

PyTorch 的 C++ 前端，定义 Tensor 概念和各种数学运算。几乎所有 Python/C++ 接口都在 ATen 之上构建。

- PyTorch 用 `aten/src/ATen/gen.py` 动态生成不同平台、数据类型的 aten 运算符
- 提供数百种 tensor 操作的定义

### C10

"Caffe2 Tensor Library" 的缩写，是 ATen 的底层基础：

- 包含 Tensor 和 Storage 数据结构的实际实现
- 统一 PyTorch 和 Caffe2 的张量计算后端代码
- 支持 CPU、GPU、TPU 等多种硬件平台

## TorchDynamo

PyTorch 的 Python-level JIT 编译器，通过拦截 CPython 的 frame evaluation API（PEP 523）动态修改 Python 字节码，将 PyTorch 操作提取为 FX Graph，然后用可定制后端进行 JIT 编译。

核心优势：混合 Python 执行和编译后端，兼具可用性和性能。

```python
graph: torch.fx.Graph = tracer_class().trace(m)
# 对 Graph 进行修改 ...
return torch.fx.GraphModule(m, graph)
```

## C++/CUDA 扩展

### 编写 C++/CUDA 扩展

PyTorch 支持用 C++/CUDA 编写自定义操作，通过 pybind11 暴露 Python 接口。

文件结构：
```
csrc/
  └── add.cpp
setup.py
```

核心编译工具：`torch.utils.cpp_extension.CUDAExtension` / `CppExtension` + `BuildExtension`

注意：`#define WITH_CUDA` 宏需要在每个 .cu 文件前添加，用于判断是否编译 CUDA 代码。

### 调用方式

通过 `torch.autograd.Function` 封装：

```python
class MyFunction(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input):
        return cpp_module.forward(input)

    @staticmethod
    def backward(ctx, grad_output):
        return cpp_module.backward(grad_output)
```

## 显存管理机制

PyTorch 显存分配器基于 Block + BlockPool 的双向链表实现：

- **Block**：基本分配单位，由 `(stream_id, size, ptr)` 标识
- **BlockPool**：用 `std::set` 管理空闲 Block，按 `(stream_id → block_size → addr)` 排序
- 释放时自动合并相邻空闲 Block，防止碎片化

## 相关

- [[attention-is-all-you-need-annotated]] — Transformer 逐行实现（基于 PyTorch）
- [[paper-reading-notes]] — 论文精读笔记
