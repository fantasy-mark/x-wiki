# 论文精读笔记

> 来源: 用户笔记, 2026-04-27; Various papers

## 骨干模型

### CLIP [Learning Transferable Visual Models From Natural Language Supervision](https://arxiv.org/abs/2103.00020)

CLIP 的输入是一对对配对好的图片-文本对（如一张狗的图片，对应文本也表示这是一只狗）。文本和图片分别通过 Text Encoder 和 Image Encoder 输出对应特征，然后在这些特征上进行对比学习。

假如模型输入 n 对图片-文本对：
- n 对互相配对的图像-文本对是**正样本**（对角线）
- n² - n 对不匹配的样本是**负样本**

训练目标：最大化 n 个正样本的相似度，最小化 n² - n 个负样本的相似度。

CLIP 的亮点和强大之处：可以直接实现 **zero-shot 图像分类**，即不需要任何训练和微调。

### MAE [Masked Autoencoders Are Scalable Vision Learners](https://arxiv.org/abs/2111.06377)

MAE 核心思想：用随机遮挡（Mask）的方式训练视觉模型，将图片 patch 大比例遮挡后，让模型重建被遮挡的像素内容。

### MoCo [Momentum Contrast for Unsupervised Visual Representation Learning](https://arxiv.org/abs/1911.05722)

MoCo 提出用对比学习做无监督视觉表示学习，通过动量更新（momentum update）维持一个动态的队列作为负样本库。

### DETR [End-to-End Object Detection with Transformers](https://arxiv.org/abs/2005.12872)

DETR 将目标检测建模为集合预测问题，用 Transformer 编码器-解码器架构替代传统检测头，简化了检测 pipeline。

代码：https://github.com/facebookresearch/detr

### DALL-E 2 [Hierarchical Text-Conditional Image Generation with CLIP Latents](https://cdn.openai.com/papers/dall-e-2.pdf)

层级文本条件图像生成：用 CLIP 潜空间作为中间表示，先生成 CLIP image embedding，再通过扩散模型解码生成图像。

解读参考：https://zhuanlan.zhihu.com/p/593896912

### ViLT [Vision-and-Language Transformer Without Convolution or Region Supervision](https://arxiv.org/abs/2102.03334)

将视觉语言模型统一到 Transformer 架构中，无需 CNN 特征或区域监督，用 ViT 处理图像 tokens。

## 基础模型

### Diffusion [Denoising Diffusion Probabilistic Models](https://arxiv.org/abs/2006.11239)

扩散概率模型：通过逐步加噪（forward process）和去噪（reverse process）学习数据分布。DDPM 是当前文生图模型（如 Stable Diffusion、DALL-E 3）的理论基础。

### Transformer [Attention is All You Need](https://arxiv.org/abs/1706.03762)

详见：[Attention Is All You Need — 逐行实现]([[attention-is-all-you-need-annotated]])

## 推理优化

### Lookahead

预测性解码策略，用小型模型预测多个 token 后，大模型一次解码更多内容，加速推理。

### GaLore [Memory-Efficient LLM Training by Gradient Low-Rank Projection](https://arxiv.org/pdf/2403.03507)

核心思想：将权重矩阵的**梯度**转为低秩矩阵，从而降低参数训练时的内存需求。

## 机器翻译

### Unsupervised NMT [Unsupervised Neural Machine Translation](https://arxiv.org/abs/1710.11041)

无监督机器翻译的关键：

1. **二元结构（Dual structure）**：系统同时进行双向翻译
2. **共享编码器**：法语和英语使用同一个编码器，产生语言独立的表征
3. **固定 embedding**：使用预训练的跨语言 embedding，训练过程中保持不变

## 视频理解

### I3D [Quo Vadis, Action Recognition? A New Model and the Kinetics Dataset](https://arxiv.org/abs/1705.07750)

主要贡献：
1. 提出 Kinetics 大规模视频行为识别数据集（400 个人类动作类别）
2. 提出 Two-Stream Inflated 3D ConvNets（I3D），将 2D 卷积膨胀为 3D

## 代码生成

### CodeX [Evaluating Large Language Models Trained on Code](https://arxiv.org/abs/2107.03374)

以 GitHub Python 代码作为数据集，评估指标 **pass@k**：K 个解中有一个通过测试即为通过。

关键问题：代码补全任务不同于传统 NLP，代码但凡有一点小 Bug 都可能造成毁灭性结果，所以使用单元测试（unit test）评估。

### AlphaCode [Competition-Level Code Generation with AlphaCode](https://arxiv.org/abs/2212.08608)

编程竞赛题目作为部分数据集，使用 n@k 指标（K 个解中提交 n 个），用 GLOD 算法评估最优解。

## 多模态

多模态大模型研究，融合视觉、语言等多种模态的表示学习。

## 数学辅助

### Advancing Mathematics by Guiding Human Intuition with AI

论文：https://www.nature.com/articles/s41586-021-04086-x

核心启示：关注问题本身，而不应该将太多精力花费在算法上。

流程：猜想两个 function 之间联系 → 收集数据 → 训练数据辅助直觉找出联系 → 归因缩小特征空间

### Large Language Model for Science: A Study on P vs. NP

论文：https://arxiv.org/abs/2309.05689

论文阐述通过 97 轮对话解决 P/NP 数学难题，可见能否恰当使用 prompt 是充分挖掘 LLM 能力的关键。

核心策略：
- **演绎（Deduction）**：在较小的问题上 LLM 直接给出推理结果
- **变换（Transformation）**：把问题转化为相似问题
- **分解（Decomposition）**：将问题分解为多个子问题
- **验证（Verification）**：得出新结论时进行验证和完善
- **融合（Integration）**：根据子问题结果综合结论

## RAG

### Unifying Large Language Models and Knowledge Graphs: A Roadmap

论文：https://arxiv.org/abs/2306.08302

详见：[RAG 系统概述]([[rag-system-overview]])
