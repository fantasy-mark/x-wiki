# LlamaIndex 使用指南

> 来源: 用户笔记, 2026-04-27; LlamaIndex GitHub; LlamaIndex 官方文档
> 项目: https://github.com/run-llama/llama_index

## SimpleDirectoryReader

LlamaIndex 最基础的数据加载器，支持多种文件格式：

| 类型 | 说明 |
|------|------|
| `.pdf` | Portable Document Format |
| `.docx` | Microsoft Word |
| `.md` | Markdown |
| `.csv` | Comma-separated values |
| `.epub` | EPUB ebook format |
| `.hwp` | Hangul Word Processor |
| `.ipynb` | Jupyter Notebook |
| `.jpeg/.jpg/.png` | 图片（需配合 OCR） |
| `.mp3/.mp4` | 音视频 |
| `.mbox` | MBOX email archive |
| `.ppt/.pptm/.pptx` | Microsoft PowerPoint |

### 基本用法

```python
from llama_index import SimpleDirectoryReader

# 从指定文件读取
documents = SimpleDirectoryReader(input_files=['2306.08302.pdf']).load_data()
for doc in documents:
    print(doc.text)
```

## 文档翻译 pipeline

结合 ChatGLM3 实现 PDF 文档批量翻译：

```python
from llama_index import SimpleDirectoryReader
from transformers import AutoTokenizer, AutoModel

MODEL_PATH = 'model/chatglm3-6b'

tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, trust_remote_code=True)
model = AutoModel.from_pretrained(
    MODEL_PATH,
    trust_remote_code=True,
    device_map="auto"
).eval()

history = []
documents = SimpleDirectoryReader(input_files=['docs/AlexNet-Paper.pdf']).load_data()

for current_page in range(len(documents)):
    current_length = 0
    query = '翻译以下文本。\n' + documents[current_page].text
    for response, history in model.stream_chat(
        tokenizer, query,
        history=history if len(history) <= 2 else history[-2:],
        top_p=1, temperature=0.01
    ):
        print(response[current_length:], end="", flush=True)
        current_length = len(response)
```

## Streamlit 图形化应用

使用 Streamlit 构建带界面的文档翻译工具：

```python
import os
import streamlit as st
import torch
from llama_index import SimpleDirectoryReader
from transformers import AutoModel, AutoTokenizer

MODEL_PATH = os.environ.get('MODEL_PATH', 'model/chatglm3-13b/')
UPLOAD_PATH = 'docs/upload/'

@st.cache_resource
def get_model():
    tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH, trust_remote_code=True)
    model = AutoModel.from_pretrained(MODEL_PATH, trust_remote_code=True, device_map="auto").eval()
    return tokenizer, model

tokenizer, model = get_model()

# 侧边栏参数
max_length = st.sidebar.slider("max_length", 0, 32768, value=8192, step=1)
top_p = st.sidebar.slider("top_p", 0.0, 1.0, value=1.0, step=0.01)
temperature = st.sidebar.slider("temperature", 0.0, 1.0, value=0.01, step=0.01)

# 文件上传
uploaded_file = st.sidebar.file_uploader(
    '请选择要翻译的文件',
    type=['pdf', 'txt']
)

if uploaded_file is not None:
    with open(UPLOAD_PATH + uploaded_file.name, 'wb+') as f:
        f.write(uploaded_file.getvalue())

    documents = SimpleDirectoryReader(
        input_files=[UPLOAD_PATH + uploaded_file.name]
    ).load_data()

    for page in documents:
        for response, _ in model.stream_chat(
            tokenizer,
            query='翻译以下文本。' + page.text,
            history=[],
            max_length=max_length,
            top_p=top_p,
            temperature=temperature,
        ):
            st.markdown(response)
```

## 相关资源

- [LlamaIndex 官方文档](https://docs.llamaindex.ai/)
- 配合 [Streamlit]([[streamlit]]) 可快速构建 LLM 应用界面
