# PyTorch 框架源码架构研究

> 来源: 用户笔记, 2026-04-27; PyTorch GitHub; Harvard NLP Annotated Transformer
> 源码: https://github.com/pytorch/pytorch

## 整体架构

PyTorch 项目主要由三部分组成：

```
┌─────────────────────────────────────────────┐
│                  torch                      │  ← Python 前端，用户直接交互
│  (Tensor + autograd 自动求导系统)            │
├─────────────────────────────────────────────┤
│                  ATen                       │  ← "A Tensor Library for C++11"
│  (张量运算声明定义，C++ 实现)                 │
├─────────────────────────────────────────────┤
│                   C10                       │  ← "Caffe2 Tensor Library"
│  (Tensor/Storage 数据结构实际实现)           │
└─────────────────────────────────────────────┘
```

- **torch**：Tensor 和 autograd 的 Python 层命名空间，提供用户接口
- **ATen (A Tensor Library for C++11)**：PyTorch 的 C++ 前端，定义 Tensor 概念和各种数学运算。几乎所有 Python/C++ 接口都在 ATen 之上构建
- **C10**：ATen 的底层基础，统一 PyTorch 和 Caffe2 的张量计算后端代码，支持 CPU/GPU/TPU 多种硬件平台

## TorchDynamo

TorchDynamo 是 PyTorch 对 Python bytecode 的 JIT 优化编译器。

> TorchDynamo is a Python-level JIT compiler designed to make unmodified PyTorch programs faster. TorchDynamo hooks into the frame evaluation API in CPython (PEP 523) to dynamically modify Python bytecode right before it is executed.

核心机制：通过 `torch.fx` 生成计算图（FX Graph），可以拦截 Python 字节码并提取 PyTorch 操作序列，然后用可定制的后端进行 JIT 编译。实现 Python 执行和编译后端的混合，取两者之长——可用性和性能。

```python
import torch
import torch.fx

def transform(m: nn.Module, tracer_class: type = torch.fx.Tracer) -> torch.nn.Module:
    # Step 1: Acquire a Graph representing the code in `m`
    graph: torch.fx.Graph = tracer_class().trace(m)

    # Step 2: 对 Graph 进行修改
    graph = ...

    # Step 3: Construct a Module to return
    return torch.fx.GraphModule(m, graph)
```

参考：[动态调整网络](https://blog.51cto.com/godweiyang/5333472)

## ATen（C++/CUDA 扩展）

AT 负责声明和定义 Tensor 运算，是最常用的命名空间。PyTorch 使用 `aten/src/ATen/gen.py` 动态生成不同平台、不同数据类型相应的 aten 运算符。

### C++/CUDA 扩展编写流程

1. **编写**：C++/CUDA 拓展源文件（pybind11）
2. **编译**：setuptools 工具指导 C++/CUDA 拓展的编译

```python
# 文件结构
# ├── csrc/
# │   └── add.cpp
# └── setup.py

from setuptools import setup
import torch
import os, glob
from torch.utils.cpp_extension import CUDAExtension, CppExtension, BuildExtension

def get_extensions():
    extensions = []
    ext_name = 'add_extension'

    os.environ.setdefault('MAX_JOBS', '4')
    define_macros = []

    if torch.cuda.is_available():
        print(f'Compiling {ext_name} with CUDA')
        define_macros += [('WITH_CUDA', None)]  # 在每个 .h/.cpp/.cu/.cuh 源文件前添加 #define WITH_CUDA
        op_files = glob.glob('./csrc/*')
        extension = CUDAExtension
    else:
        print(f'Compiling {ext_name} without CUDA')
        op_files = glob.glob('./csrc/*.cpp')
        extension = CppExtension

    include_path = os.path.abspath('./csrc')
    ext_ops = extension(
        name=ext_name,
        sources=op_files,
        include_dirs=[include_path],
        define_macros=define_macros)
    extensions.append(ext_ops)
    return extensions

setup(
    name='extension_example',
    ext_modules=get_extensions(),
    cmdclass={'build_ext': BuildExtension},
)
```

### 调用方式

通过 `torch.autograd.Function` 类封装自定义 C++/CUDA 操作：

```python
class MyFunction(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input):
        return my_cpp_module.forward(input)

    @staticmethod
    def backward(ctx, grad_output):
        return my_cpp_module.backward(grad_output)
```

## Torch 自动求导系统

torch 命名空间下定义的 Tensor 相比于 ATen 增加自动求导功能：

```python
torch.autograd.function       # 函数的反向传播
torch.autograd.functional     # 计算图的反向传播
torch.autograd.gradcheck      # 数值梯度检查
torch.autograd.anomaly_mode   # 在自动求导时检测错误产生路径
torch.autograd.grad_mode      # 设置是否需要梯度
torch.autograd.profiler       # 提供 function 级别的统计信息
```

- `model.eval()` 与 `torch.no_grad()` 的区别：eval 切换 BN/Dropout 行为，no_grad 禁用梯度计算
- `torch.autograd.profiler` 可用于性能分析

## PyTorch 显存管理机制

参考：[PyTorch 显存管理机制](https://zhuanlan.zhihu.com/p/486360176)

### Block

分配/管理内存块的基本单位，由 `(stream_id, size, ptr)` 三元组特异性定位：

- Block 维护一个 ptr 指向大小为 size 的内存块，隶属于 stream_id 的 CUDA Stream
- 所有地址连续的 Block（不论是否空闲，只要是 Allocator::malloc 得来的）都被组织在一个双向链表中
- 释放时快速检查前后是否存在相邻碎片，若存在则合并为一个大 Block

### BlockPool

内存池，用 `std::set` 存储 Block 指针，按 `(cuda_stream_id -> block size -> addr)` 优先级从小到大排序。所有保存在 BlockPool 中的 Block 都是空闲的。
