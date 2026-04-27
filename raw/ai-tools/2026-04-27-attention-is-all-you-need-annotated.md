# Attention Is All You Need — 论文精读 + Annotated Transformer 实现

> 来源: 用户笔记, 2026-04-27; Harvard NLP The Annotated Transformer; Attention is All You Need (Vaswani et al., 2017)
> 原文: https://arxiv.org/abs/1706.03762

## 背景与动机

自2012年起，深度学习催生了几篇里程碑式论文：

- **AlexNet (2012)** — 掀起深度学习浪潮，发现网络深度对提升模型泛化尤为关键
- **Transformer (2017)** — 统一了 CV、NLP 等领域的骨干网络
- **LLMs + 多模态 (2023+)** — 当前正在进行中

传统 RNN/LSTM/GRN 作为序列建模的 SOTA 方法，存在两个核心瓶颈：

1. **序列顺序特性**导致无法并行运算
2. **存储的内存开销**约束了模型扩展

Transformer 通过注意力机制实现了：
- 序列上下文的**全局依赖建模**
- **并行化运算**（一次输入所有数据 + 嵌入位置信息，而非时序逐步输入）

> 对比：RNN 需要根据时序逐步获取全局信息；Transformer 在做 Attention 运算时已经汇聚了全局信息。

## 摘要

提出了一个新的简单网络模型，基于注意力机制，用于替代 RNN 和 CNN 处理序列变换问题。Transformer 在具有大量和有限数据的英语相关任务上都表现良好，证明可以很好推广到其他任务。

## 模型架构

### 整体结构

Transformer 遵循编码器连接到解码器的整体架构：
- **编码器**：由 N=6 个结构相同的编码器层堆叠，每层含 2 个 sublayer（多头自注意力 + 前馈网络）
- **解码器**：同样 6 层，每层含 3 个 sublayer（新增一个对编码器输出的 cross-attention）

为方便残差连接，所有子层及嵌入层的维度统一为 512 维。

```
Transformer(encoder, decoder, src_embed, tgt_embed, generator)
  ├── encode(src, src_mask) → encoder
  ├── decode(memory, src_mask, tgt, tgt_mask) → decoder
  └── generator → Linear + LogSoftmax
```

### 编码器

```python
class EncoderLayer(nn.Module):
    "Encoder is made up of self-attn and feed forward"

    def __init__(self, size, self_attn, feed_forward, dropout):
        super().__init__()
        self.self_attn = self_attn
        self.feed_forward = feed_forward
        self.sublayer = clones(SublayerConnection(size, dropout), 2)
        self.size = size

    def forward(self, x, mask):
        x = self.sublayer[0](x, lambda x: self.self_attn(x, x, x, mask))
        return self.sublayer[1](x, self.feed_forward)


class Encoder(nn.Module):
    "Core encoder is a stack of N layers"

    def __init__(self, layer, N):
        super().__init__()
        self.layers = clones(layer, N)
        self.norm = LayerNorm(layer.size)

    def forward(self, x, mask):
        for layer in self.layers:
            x = layer(x, mask)
        return self.norm(x)
```

### 解码器

每个解码器层含 3 个 sublayer，其中对应 Output Embedding 的自注意力层添加了掩码，确保位置 i 的预测只能依赖于小于 i 的已知输出（不能"偷看"未来）。

```python
class DecoderLayer(nn.Module):
    "Decoder is made of self-attn, src-attn, and feed forward"

    def __init__(self, size, self_attn, src_attn, feed_forward, dropout):
        super().__init__()
        self.size = size
        self.self_attn = self_attn
        self.src_attn = src_attn
        self.feed_forward = feed_forward
        self.sublayer = clones(SublayerConnection(size, dropout), 3)

    def forward(self, x, memory, src_mask, tgt_mask):
        m = memory
        x = self.sublayer[0](x, lambda x: self.self_attn(x, x, x, tgt_mask))
        x = self.sublayer[1](x, lambda x: self.src_attn(x, m, m, src_mask))
        return self.sublayer[2](x, self.feed_forward)


class Decoder(nn.Module):
    "Generic N layer decoder with masking."

    def __init__(self, layer, N):
        super().__init__()
        self.layers = clones(layer, N)
        self.norm = LayerNorm(layer.size)

    def forward(self, x, memory, src_mask, tgt_mask):
        for layer in self.layers:
            x = layer(x, memory, src_mask, tgt_mask)
        return self.norm(x)
```

### 归一化与残差连接

```python
class LayerNorm(nn.Module):
    "Construct a layernorm module"

    def __init__(self, features, eps=1e-6):
        super().__init__()
        self.a_2 = nn.Parameter(torch.ones(features))
        self.b_2 = nn.Parameter(torch.zeros(features))
        self.eps = eps

    def forward(self, x):
        mean = x.mean(-1, keepdim=True)
        std = x.std(-1, keepdim=True)
        return self.a_2 * (x - mean) / (std + self.eps) + self.b_2


class SublayerConnection(nn.Module):
    """
    A residual connection followed by a layer norm.
    Note for code simplicity the norm is first as opposed to last.
    """

    def __init__(self, size, dropout):
        super().__init__()
        self.norm = LayerNorm(size)
        self.dropout = nn.Dropout(dropout)

    def forward(self, x, sublayer):
        return x + self.dropout(sublayer(self.norm(x)))
```

## 注意力机制

### 可缩放点乘注意力（Scaled Dot-Product Attention）

Query 表示输入向量，Key 表示查询后命中（索引）向量，Value 表示真实向量。

类比淘宝搜索：搜索栏输入 = Query，系统推荐的商品 = Key，真正想要的商品 = Value。

计算公式：
$$Attention(Q, K, V) = softmax(\frac{QK^T}{\sqrt{d_k}})V$$

- 除以 $\sqrt{d_k}$ 是为了抑制 Q 规模变大带来的 softmax 梯度消失问题
- 使用点积注意力是为了利用矩阵运算，减少计算量并实现并行
- 可学习的参数是 $W_Q, W_K, W_V$ 三个矩阵

```python
def attention(query, key, value, mask=None, dropout=None):
    "Compute 'Scaled Dot Product Attention'"
    d_k = query.size(-1)
    scores = torch.matmul(query, key.transpose(-2, -1)) / math.sqrt(d_k)
    if mask is not None:
        scores = scores.masked_fill(mask == 0, -1e9)
    p_attn = scores.softmax(dim=-1)
    if dropout is not None:
        p_attn = dropout(p_attn)
    return torch.matmul(p_attn, value), p_attn
```

### 多头注意力（Multi-Head Attention）

将 Q、K、V 分别分割为 h 个 dk 维，并行计算。多头注意力允许模型在不同位置共同注意来自不同表示子空间的信息。相比单注意头，模型计算量相当，但每个注意力头的维度缩减了。

$$MultiHead(Q, K, V) = Concat(head_1, ..., head_h)W^O$$
$$where\ head_i = Attention(QW_i^Q, KW_i^K, VW_i^V)$$

```python
class MultiHeadedAttention(nn.Module):
    def __init__(self, h, d_model, dropout=0.1):
        super().__init__()
        assert d_model % h == 0
        self.d_k = d_model // h
        self.h = h
        self.linears = clones(nn.Linear(d_model, d_model), 4)
        self.attn = None
        self.dropout = nn.Dropout(p=dropout)

    def forward(self, query, key, value, mask=None):
        if mask is not None:
            mask = mask.unsqueeze(1)
        nbatches = query.size(0)

        # 1) Do all the linear projections in batch from d_model => h x d_k
        query, key, value = [
            lin(x).view(nbatches, -1, self.h, self.d_k).transpose(1, 2)
            for lin, x in zip(self.linears, (query, key, value))
        ]

        # 2) Apply attention on all the projected vectors in batch.
        x, self.attn = attention(query, key, value, mask=mask, dropout=self.dropout)

        # 3) "Concat" using a view and apply a final linear.
        x = (x.transpose(1, 2).contiguous()
             .view(nbatches, -1, self.h * self.d_k))
        del query, key, value
        return self.linears[-1](x)
```

### 掩码注意力（后续位置掩码）

解码器自注意力需要掩码，防止位置 i 的预测看到位置 i 之后的内容：

```python
def subsequent_mask(size):
    "Mask out subsequent positions."
    attn_shape = (1, size, size)
    subsequent_mask = torch.triu(torch.ones(attn_shape), diagonal=1).type(torch.uint8)
    return subsequent_mask == 0
```

## 位置前馈网络（FFN）

FFN 即 MLP（多层感知机），两层线性变换中间接 ReLU 激活：

```python
class PositionwiseFeedForward(nn.Module):
    "Implements FFN equation."

    def __init__(self, d_model, d_ff, dropout=0.1):
        super().__init__()
        self.w_1 = nn.Linear(d_model, d_ff)
        self.w_2 = nn.Linear(d_ff, d_model)
        self.dropout = nn.Dropout(p=dropout)

    def forward(self, x):
        return self.w_2(self.dropout(self.w_1(x).relu()))
```

## 嵌入与位置编码

### 词嵌入

```python
class Embeddings(nn.Module):
    def __init__(self, d_model, vocab):
        super().__init__()
        self.lut = nn.Embedding(vocab, d_model)
        self.d_model = d_model

    def forward(self, x):
        return self.lut(x) * math.sqrt(self.d_model)
```

### 位置编码（正弦版本）

采用 sin/cos 函数实现位置编码，使模型可以通过相对位置实现注意力机制，且序列长度方便扩展：

$$PE_{(pos,2i)} = \sin(pos/1000^{2i/d_{model}})$$
$$PE_{(pos,2i + 1)} = \cos(pos/1000^{2i/d_{model}})$$

好处：
- 正余弦函数范围在 [-1, +1]，与词嵌入相加不会偏离过远破坏语义
- 第 pos+k 个位置的编码是第 pos 个位置编码的线性组合，蕴含相对距离信息

```python
class PositionalEncoding(nn.Module):
    def __init__(self, d_model, dropout, max_len=5000):
        super().__init__()
        self.dropout = nn.Dropout(p=dropout)
        pe = torch.zeros(max_len, d_model)
        position = torch.arange(0, max_len).unsqueeze(1)
        div_term = torch.exp(
            torch.arange(0, d_model, 2) * -(math.log(10000.0) / d_model)
        )
        pe[:, 0::2] = torch.sin(position * div_term)
        pe[:, 1::2] = torch.cos(position * div_term)
        pe = pe.unsqueeze(0)
        self.register_buffer("pe", pe)

    def forward(self, x):
        x = x + self.pe[:, :x.size(1)].requires_grad_(False)
        return self.dropout(x)
```

## 训练细节

### 模型构建

```python
def make_model(src_vocab, tgt_vocab, N=6, d_model=512, d_ff=2048, h=8, dropout=0.1):
    c = copy.deepcopy
    attn = MultiHeadedAttention(h, d_model)
    ff = PositionwiseFeedForward(d_model, d_ff, dropout)
    position = PositionalEncoding(d_model, dropout)
    model = Transformer(
        Encoder(EncoderLayer(d_model, c(attn), c(ff), dropout), N),
        Decoder(DecoderLayer(d_model, c(attn), c(attn), c(ff), dropout), N),
        nn.Sequential(Embeddings(d_model, src_vocab), c(position)),
        nn.Sequential(Embeddings(d_model, tgt_vocab), c(position)),
        Generator(d_model, tgt_vocab),
    )
    for p in model.parameters():
        if p.dim() > 1:
            nn.init.xavier_uniform_(p)
    return model
```

### 学习率调度（Noam Warmup）

$$\alpha(step) = d_{model}^{-0.5} \cdot \min(step^{-0.5}, step \cdot warmup^{-1.5})$$

```python
def rate(step, model_size, factor, warmup):
    if step == 0:
        step = 1
    return factor * (model_size ** (-0.5) * min(step ** (-0.5), step * warmup ** (-1.5)))
```

### 标签平滑

```python
class LabelSmoothing(nn.Module):
    def __init__(self, size, padding_idx, smoothing=0.0):
        super().__init__()
        self.criterion = nn.KLDivLoss(reduction="sum")
        self.padding_idx = padding_idx
        self.confidence = 1.0 - smoothing
        self.smoothing = smoothing
        self.size = size
        self.true_dist = None

    def forward(self, x, target):
        assert x.size(1) == self.size
        true_dist = x.data.clone()
        true_dist.fill_(self.smoothing / (self.size - 2))
        true_dist.scatter_(1, target.data.unsqueeze(1), self.confidence)
        true_dist[:, self.padding_idx] = 0
        mask = torch.nonzero(target.data == self.padding_idx)
        if mask.dim() > 0:
            true_dist.index_fill_(0, mask.squeeze(), 0.0)
        self.true_dist = true_dist
        return self.criterion(x, true_dist.clone().detach())
```

### 数据批处理

```python
class Batch:
    def __init__(self, src, tgt=None, pad=2):
        self.src = src
        self.src_mask = (src != pad).unsqueeze(-2)
        if tgt is not None:
            self.tgt = tgt[:, :-1]
            self.tgt_y = tgt[:, 1:]
            self.tgt_mask = self.make_std_mask(self.tgt, pad)
            self.ntokens = (self.tgt_y != pad).data.sum()

    @staticmethod
    def make_std_mask(tgt, pad):
        tgt_mask = (tgt != pad).unsqueeze(-2)
        tgt_mask = tgt_mask & subsequent_mask(tgt.size(-1)).type_as(tgt_mask.data)
        return tgt_mask
```

### 贪心解码

```python
def greedy_decode(model, src, src_mask, max_len, start_symbol):
    memory = model.encode(src, src_mask)
    ys = torch.zeros(1, 1).fill_(start_symbol).type_as(src.data)
    for i in range(max_len - 1):
        out = model.decode(
            memory, src_mask, ys,
            subsequent_mask(ys.size(1)).type_as(src.data)
        )
        prob = model.generator(out[:, -1])
        _, next_word = torch.max(prob, dim=1)
        next_word = next_word.data[0]
        ys = torch.cat(
            [ys, torch.zeros(1, 1).type_as(src.data).fill_(next_word)], dim=1
        )
    return ys
```

## 训练数据与分布式训练

### 环境配置

```bash
pip install torch==2.0.0+cu117 torchvision==0.15.1+cu117 torchaudio==2.0.1 --index-url https://download.pytorch.org/whl/cu117
pip install spacy==3.7.2
pip install torchtext==0.15.1 --no-deps
```

> 环境版本很重要，torchtext 等 API 变动大，不对应则代码无法运行。

### 词汇表构建

```python
def build_vocabulary(spacy_de, spacy_en):
    train, val, test = datasets.Multi30k(language_pair=("de", "en"))
    vocab_src = build_vocab_from_iterator(
        yield_tokens(train + val + test, tokenize_de, index=0),
        min_freq=2,
        specials=["<s>", "</s>", "<blank>", "<unk>"],
    )
    vocab_tgt = build_vocab_from_iterator(
        yield_tokens(train + val + test, tokenize_en, index=1),
        min_freq=2,
        specials=["<s>", "</s>", "<blank>", "<unk>"],
    )
    return vocab_src, vocab_tgt
```

### 分布式训练入口

```python
def train_distributed_model(vocab_src, vocab_tgt, spacy_de, spacy_en, config):
    ngpus = torch.cuda.device_count()
    os.environ["MASTER_ADDR"] = "localhost"
    os.environ["MASTER_PORT"] = "12356"
    mp.spawn(
        train_worker,
        nprocs=ngpus,
        args=(ngpus, vocab_src, vocab_tgt, spacy_de, spacy_en, config, True),
    )
```

训练超参数配置：
```python
config = {
    "batch_size": 32,
    "distributed": False,
    "num_epochs": 8,
    "accum_iter": 10,
    "base_lr": 1.0,
    "max_padding": 72,
    "warmup": 3000,
    "file_prefix": "multi30k_model_",
}
```

## 常见问题

### Multi30k 数据问题

- 必须使用对应版本的 spacy
- 需手动下载对应 tar.gz 压缩包到对应目录

## 结论

Transformer 在机器翻译等多种任务上取得了 SOTA 成绩。论文计划将模型推广到图像、视频等领域——这一愿景在 2020 年后已被 Vision Transformer (ViT)、DETR 等工作完美实现。

## 参考资料

- [The Annotated Transformer](https://nlp.seas.harvard.edu/annotated-transformer/)
- [Understanding LSTM Networks](https://colah.github.io/posts/2015-08-Understanding-LSTMs/)
- [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/)
- [Attention is All You Need — 论文](https://arxiv.org/abs/1706.03762)
