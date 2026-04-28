# Hugging Face 实战笔记

> 收录: 2026-04-27 | 分类: AI 工程工具 | 标签: Huggingface, BERT, Wav2Vec2, 微调, SQuAD

## 概述

Hugging Face 是当前最流行的开源 ML 框架，提供超过 10 万个预训练模型和数据集。本文整理 Wav2Vec2 中文语音识别和 BERT 问答微调的实战代码。

国内镜像站：https://hf-mirror.com/

## 中文语音识别（Wav2Vec2）

Wav2Vec2 是 Facebook 提出的自监督语音表示学习模型，中文模型 `jonatasgrosman/wav2vec2-large-xlsr-53-chinese-zh-cn` 可直接用于中文 ASR。

核心流程：音频 → 重采样(16kHz) → 分词器编码 → 模型前向 → CTC 解码

详见 raw 文件：`raw/ai-tools/2026-04-27-huggingface-bert-wav2vec2.md`

## BERT 问答模型微调（SQuAD 2.0）

### 数据处理三件套

| 类 | 作用 | 格式 |
|----|------|------|
| SquadExample | 原始数据 | 字符串（passage/question/answer） |
| SquadFeatures | 模型输入 | tokenized + indexed tensors |
| SquadResult | 预测结果 | logits → start/end position |

### 模型结构

BERT QA 本质是预测答案在 passage 中的 start 和 end 位置：
- Encoder：12 层 Transformer（768 hidden, 12 heads）
- Output：Linear(768→2)，预测 start/end score

详见 raw 文件。

## 相关

- [[paper-reading-notes]] — BERT 论文精读（见 [[attention-is-all-you-need-annotated]] 延伸）
- [[rag-system-overview]] — RAG 中常用 BERT 作为检索编码器的方案
