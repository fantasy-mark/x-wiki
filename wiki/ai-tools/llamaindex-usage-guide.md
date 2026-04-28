# LlamaIndex 使用指南

> 收录: 2026-04-27 | 分类: AI 工程工具 | 标签: LlamaIndex, LLM, RAG, Streamlit, 文档处理

## 简介

LlamaIndex 是一个专注于 LLM 数据摄入（Data Ingestion）的框架，核心能力是将各种格式的文档加载、切分、向量化，为 RAG 应用提供数据 pipeline。

## SimpleDirectoryReader

最基础的数据加载器，支持格式：

`.pdf` · `.docx` · `.md` · `.csv` · `.epub` · `.ipynb` · `.jpeg` · `.mp3` · `.mp4` · `.mbox` · `.pptx`

```python
from llama_index import SimpleDirectoryReader

documents = SimpleDirectoryReader(input_files=['doc.pdf']).load_data()
for doc in documents:
    print(doc.text)
```

## 典型应用场景

### 文档翻译 pipeline

加载 PDF → 逐页拼入翻译 prompt → 调用 LLM 流式输出 → 保存翻译结果

### Streamlit 图形化界面

配合 Streamlit 构建带上传功能的翻译/问答工具：
- 侧边栏上传 PDF/TXT 文件
- LlamaIndex 加载文档内容
- 调用本地 LLM（ChatGLM3/Qwen 等）处理
- 实时流式展示结果

关键组件：
- `st.cache_resource` 缓存模型加载
- `st.chat_input` / `st.chat_message` 构建对话 UI
- `model.stream_chat` 流式调用 LLM

## 相关

- [[rag-system-overview]] — RAG 系统全貌
- [[llm-inference-hardware-dataflow]] — LLM 推理硬件数据流
