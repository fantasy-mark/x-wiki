# RAG 系统概述

> 收录: 2026-04-27 | 分类: AI 应用架构 | 标签: RAG, LLM, 向量检索, 知识库

## 什么是 RAG

RAG（Retrieval-Augmented Generation）即检索增强生成，通过在推理阶段注入外部知识来解决 LLM 的知识过时和幻觉问题。

三个核心环节：

| 环节 | 说明 |
|------|------|
| **Indexing** | 将知识文档切分、嵌入后存入向量数据库 |
| **Retrieval** | 根据用户问题检索最相关的知识片段 |
| **Generation** | 将检索结果拼入 prompt，让 LLM 生成答案 |

## 典型 RAG Pipeline

```
文档 → 解析 → 分块(Chunk) → 向量化(Embedding) → 入库(VectorDB)
                                                    ↓
用户问题 → 向量化 → 相似度检索 → Top-K 块 → 拼 Prompt → LLM → 回答
```

## 技术栈

| 模块 | 常见选型 |
|------|---------|
| 文档解析 | PDF 解析、OCR 识别 |
| 分块策略 | 固定大小滑动窗口、语义分块、递归字符分割 |
| 向量模型 | text-embedding-ada-002、bge-m3、m3e |
| 向量数据库 | Milvus、Pinecone、Chroma、FAISS、Qdrant |
| 重排序 | BGE-Reranker、Cohere Rerank |
| LLM | GPT-4、Claude、GLM、Qwen、DeepSeek |

## 训练方案（Post-Training）

### DPO 偏好对齐

DPO（Direct Preference Optimization）训练目标：**增大正样本概率，减小负样本概率**。

- 不仅教模型什么是好的，也告诉模型什么是差的
- 对问答类场景特别有效
- 结合 SFT + DPO + RAG，可将准确率从 ~60% 提升至 ~90%

### 三阶段流程

1. **SFT**：基于领域数据有监督微调基础模型
2. **DPO**：基于人类偏好数据优化回答质量
3. **RAG**：推理时注入外部知识

## 相关

- [[llamaindex-usage-guide]] — LlamaIndex 使用指南（含文档加载代码）
- [[paper-reading-notes]] — 论文精读（LLM + Knowledge Graphs）
- [[ml-core-concepts]] — 机器学习核心概念（Embedding 等）
