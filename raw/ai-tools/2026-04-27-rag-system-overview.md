# RAG 系统概述

> 来源: 用户笔记, 2026-04-27; InfoQ; CSDN
> 参考: [大模型开发流程及架构](https://blog.csdn.net/qq_45126275/article/details/134496661); [解码 RAG：智谱 RAG 技术的探索与实践](https://www.infoq.cn/article/OfSAi8R4p5OKlI0sBy6Z)

## 什么是 RAG

RAG（Retrieval-Augmented Generation）包含三个核心环节：

1. **Indexing（索引）**：如何更好地把知识存起来
2. **Retrieval（检索）**：如何在大量知识中找到有用的部分给模型参考
3. **Generation（生成）**：如何结合用户提问和检索到的知识生成有用的答案

## RAG 流程

```
文档 → 分块(Chunking) → 向量化(Embedding) → 存入向量数据库
                                              ↓
用户提问 → 向量化 → 相似度检索 → Top-K 相关块 → 拼入 Prompt → LLM 生成答案
```

## 技术方案

RAG 的工程实现涉及多个关键模块：

| 模块 | 技术选型 |
|------|---------|
| 文档解析 | PDF 解析、OCR |
| 分块策略 | 固定大小滑动窗口、语义分块 |
| 向量模型 | text-embedding-ada-002、bge 等 |
| 向量数据库 | Milvus、Pinecone、Chroma、FAISS |
| 重排序 | BGE-Reranker、Cohere Rerank |
| LLM | GPT-4、Claude、GLM、Qwen 等 |

## 训练方案（Post-Training）

### DPO 对齐训练

DPO（Direct Preference Optimization）的训练目标：**让正样本概率加大，负样本概率变低**。

- 不仅教会模型什么是好的
- 也会告诉模型什么是差的
- 对问答类场景非常有效，让模型更好地向人类真实需求对齐

通过 RAG + SFT + DPO 的完整 pipeline，可以将原本只有 60% 左右的正确率提升到 90% 以上。

### 三阶段

1. **SFT（有监督微调）**：基于领域数据微调基础模型
2. **DPO（偏好对齐）**：基于人类偏好数据优化回答质量
3. **RAG（知识增强）**：在推理阶段注入外部知识

## 实施方案

1. **部署**：向量数据库 + LLM 服务
2. **导入数据**：文档解析 → 分块 → 向量化 → 入库
3. **SFT + DPO**：模型后训练优化
