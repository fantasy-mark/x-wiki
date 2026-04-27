# Hugging Face 实战笔记

> 来源: 用户笔记, 2026-04-27; Huggingface.co
> 模型镜像: https://hf-mirror.com/

## 中文语音识别（Wav2Vec2）

```python
import librosa
import torch
from transformers import Wav2Vec2ForCTC, Wav2Vec2Tokenizer
import warnings
warnings.filterwarnings("ignore")

# 加载预训练模型和分词器
tokenizer = Wav2Vec2Tokenizer.from_pretrained("jonatasgrosman/wav2vec2-large-xlsr-53-chinese-zh-cn")
model = Wav2Vec2ForCTC.from_pretrained("jonatasgrosman/wav2vec2-large-xlsr-53-chinese-zh-cn")

# 提取音频（时间不要太长否则内存会爆）
# ffmpeg -i input.mp4 -ss 00:01:00 -to 00:02:00 -vn -c copy output3.wav
audio_file = "files/output3.wav"
audio, sampling_rate = librosa.load(audio_file, sr=16_000)

input_values = tokenizer(audio, return_tensors="pt").input_values

# 获取预测结果
logits = model(input_values).logits
predicted_ids = torch.argmax(logits, dim=-1)
transcriptions = tokenizer.decode(predicted_ids[-1])
print(transcriptions)
```

## BERT 问答模型微调（SQuAD 2.0）

### 数据预处理（SquadExample → SquadFeatures）

SQuAD 数据处理的三个核心类：
- **SquadExample**：原始数据，字符串格式，含 passage/question/answer
- **SquadFeatures**：可直接输入模型的实例格式（tokenized + indexed）
- **SquadResult**：模型预测结果

```python
from transformers.data.processors.squad import SquadV2Processor, squad_convert_examples_to_features
from transformers import BertTokenizer

processor = SquadV2Processor()
train_examples = processor.get_train_examples('SQuAD')
tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

train_features = squad_convert_examples_to_features(
    examples=train_examples,
    tokenizer=tokenizer,
    max_seq_length=384,
    doc_stride=128,
    max_query_length=64,
    is_training=True,
    return_dataset=False,
    threads=1
)

with open('train_features.pkl', 'wb') as f:
    pickle.dump(train_features, f)
```

### BERT QA 模型结构

```
BertForQuestionAnswering
  (bert): BertModel
    (embeddings): BertEmbeddings
      (word_embeddings): Embedding(30522, 768)
      (position_embeddings): Embedding(512, 768)
      (token_type_embeddings): Embedding(2, 768)
      (LayerNorm): LayerNorm((768,), eps=1e-12)
      (dropout): Dropout(p=0.1)
    (encoder): BertEncoder
      (layer): ModuleList(12 x BertLayer)
        (attention): BertAttention
          (self): BertSelfAttention (Q/K/V 各 768→768)
          (output): BertSelfOutput (768→768 + LayerNorm + Dropout)
        (intermediate): BertIntermediate (768→3072 + GELU)
        (output): BertOutput (3072→768 + LayerNorm + Dropout)
  (qa_outputs): Linear(768→2)  # 预测 start/end 位置
```

关键组件：
- **Linear**：全连接层
- **Embedding**：将特征转换为低维向量（30522 词表 → 768 维）
- **LayerNorm**：归一化，加速收敛
- **Dropout**：防止过拟合

### 训练微调

```python
import torch
from transformers import BertForQuestionAnswering, AdamW
from torch.utils.data import DataLoader, RandomSampler, TensorDataset

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model = BertForQuestionAnswering.from_pretrained('bert-base-uncased').to(device)
optimizer = AdamW(model.parameters(), lr=5e-5)

for epoch in range(num_epochs):
    for step, batch in enumerate(train_dataloader):
        model.train()
        optimizer.zero_grad()
        input_ids, attention_mask, token_type_ids, start_positions, end_positions = tuple(t.to(device) for t in batch)
        outputs = model(input_ids, attention_mask, token_type_ids, start_positions, end_positions)
        loss = outputs.loss
        loss.backward()
        optimizer.step()

model.save_pretrained("SQuAD_finetune_bert")
```

### 加载微调模型推理

```python
from transformers import BertForQuestionAnswering, BertTokenizer
import torch

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
model_path = "SQuAD_finetuned_bert"
model = BertForQuestionAnswering.from_pretrained(model_path)
tokenizer = BertTokenizer.from_pretrained(model_path)

question, text = "national treasure of China?", "The giant panda is known as a national treasure of china."
inputs = tokenizer.encode_plus(question, text, add_special_tokens=True, return_tensors="pt")
with torch.no_grad():
    outputs = model(**inputs.to(device))

answer_start_index = torch.argmax(outputs.start_logits)
answer_end_index = torch.argmax(outputs.end_logits) + 1
predict_answer_tokens = inputs['input_ids'][0][answer_start_index:answer_end_index]
predicted_answer = tokenizer.decode(predict_answer_tokens)
print(predicted_answer)
```

## Kaggle 基础配置

```python
import os
os.environ["KMP_DUPLICATE_LIB_OK"] = "TRUE"
import numpy as np
import pandas as pd
```
