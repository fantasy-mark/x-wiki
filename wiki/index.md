## ai-tools

AI 工具、开发助手、自动化工作流相关文章。

| Article | Summary | Updated |
|---------|---------|---------|
| [Chrome DevTools MCP 安装配置]([[chrome-devtools-mcp-setup]]) | 完整安装配置指南，让 AI 能够控制浏览器获取动态网页内容 | 2026-04-14 |
| [实用开发者工具导航]([[useful-developer-tools-collection]]) | 分类整理的各类开发者实用工具、网站、插件和代码片段 | 2026-04-15 |
| [驾驭工程]([[harness-engineering]]) | 基于 Claude Code 源码分析的开源技术书籍，拆解 AI 编码工具内部架构 | 2026-04-15 |
| [Claude Code Session 管理指南]([[claude-code-session-management]]) | Anthropic 官方手册：五岔路口决策树 + Rewind/Compact/Subagent 使用心法 | 2026-04-25 |
| [Superpowers 插件完全上手指南]([[superpowers-plugin-guide]]) | 开源工程化开发插件：将 TDD、代码审查、Git Worktree 等工程实践与 AI Agent 结合的 20+ 可组合 Skills 系统 | 2026-04-25 |
| [Claude Code CLI「不丢上下文」工作流]([[claude-code-cli-context-workflow]]) | 用 CLI 半年搭建的流式存档恢复系统：checkpoint/recap/postmortem/init-project 四个命令 + 三层记忆 + 指挥室模式 | 2026-04-25 |
| [PrfaaS：跨数据中心万亿模型推理架构]([[prfaas-cross-datacenter-llm-inference]]) | 月之暗面论文：普通以太网即可调度万亿模型跨中心推理，1T 模型吞吐量+54%，延迟-64% | 2026-04-26 |
| [Claude Code 源码深度解读：从 Harness 视角]([[claude-code-harness-architecture-deep-dive]]) | 基于泄露源码系统性拆解：工具系统/知识系统/上下文压缩/多智能体协调/权限治理，核心：模型即智能体，代码即缰绳 | 2026-04-26 |
| [CLI：Agent 时代的执行层]([[cli-the-future-of-agent]]) | CLI 为何成为 Agent 核心执行层：历史逻辑（三段证据）+ CLI vs MCP 互补分析 + 三种 CLI 形态（工具型/平台型/Agent型） | 2026-04-26 |
| [大模型推理的硬件数据流全解]([[llm-inference-hardware-dataflow]]) | 从磁盘到显存的 6 步拆解：Prefill（Compute-bound）vs Decode（Memory-bound）+ KV Cache + 多卡张量并行，核心：Decode 慢不是算不够，是搬运慢 | 2026-04-26 |
| [Anthropic 工程博客：Harness 设计让 AI 做对事]([[anthropic-harness-design-long-running-app]]) | Anthropic 官方工程博客：三层 Agent 架构（planner/generator/evaluator）+ context reset + 模型变强后 harness 瘦身，核心：模型负责做事，Harness 负责让它做对事 | 2026-04-26 |
| [Attention Is All You Need — 论文精读 + Annotated Transformer 实现]([[attention-is-all-you-need-annotated]]) | 1073 行逐行 PyTorch 实现，包含所有组件代码：Encoder/Decoder/Attention/FFN/位置编码/Warmup LR/Label Smoothing，附完整分布式训练入口 | 2026-04-27 |
| [PyTorch 框架源码架构]([[pytorch-framework-architecture]]) | PyTorch 三层架构（torch/ATen/C10）+ TorchDynamo JIT 编译 + C++/CUDA 扩展编写 + 显存管理机制（Block/BlockPool） | 2026-04-27 |
| [RAG 系统概述]([[rag-system-overview]]) | RAG 三大环节（Indexing/Retrieval/Generation）+ 技术栈选型 + SFT/DPO/RAG 三阶段训练方案，准确率从 60% 提升至 90%+ | 2026-04-27 |
| [机器学习核心概念]([[ml-core-concepts]]) | Embedding 作用、监督/自监督/无监督学习、对比学习（Pretext Task）、强化学习基础、Instruct 与 Prompting 方法演进 | 2026-04-27 |
| [LlamaIndex 使用指南]([[llamaindex-usage-guide]]) | SimpleDirectoryReader 多格式加载 + PDF 翻译 pipeline + Streamlit 图形化应用代码，完整可运行示例 | 2026-04-27 |
| [强化学习基础]([[reinforcement-learning-basics]]) | RL 核心概念（Agent/Environment/State/Action/Reward）+ Q-Learning/SARSA/DQN/PPO/DDPG/SAC 等算法分类 + 应用场景 | 2026-04-27 |
| [论文精读笔记]([[paper-reading-notes]]) | CLIP/MAE/MoCo/DETR/DALL-E2/ViT/DDPM + 推理优化（Lookahead/GaLore）+ 代码生成（CodeX/AlphaCode）+ 数学辅助 LLM | 2026-04-27 |
| [Hugging Face 实战笔记]([[huggingface-bert-wav2vec2]]) | Wav2Vec2 中文 ASR + BERT QA SQuAD 2.0 微调（Example→Features→Result 全流程）+ 模型结构解析 | 2026-04-27 |
| [Lookahead 推理加速框架]([[lookahead-inference-acceleration]]) | 蚂蚁集团 KDD 2024 论文：Trie树检索 + 多分支草稿 + 并行VA验证，AntGLM-10B 5.36x 加速；补充区分同名工作 Lookahead Decoding | 2026-04-28 |

## macro-trading

宏观交易与投研框架相关文章。

| Article | Summary | Updated |
|---------|---------|---------|
| [AI 宏观投研系统：从流程到系统]([[ai-macro-framework-workflow-to-system]]) | 10 条可直接用的 AI 投研 Prompt + 三层系统架构 + 五层宏观系统结构，核心：没有系统 AI 是噪音放大器，有系统 AI 是杠杆 | 2026-04-26 |
| [真正的顺势框架：三步法 + 四问自保]([[trend-following-framework-4-questions]]) | 顺势不是动作问题，是责任关系问题：三层势（结构/资金/行为）+ 三步法（走出来的结构/回撤中介入/用止损了结错误）+ 4问自保清单 | 2026-04-26 |

## multi-agent

多 Agent 系统架构与协作实践相关文章。

| Article | Summary | Updated |
|---------|---------|---------|
| [Hermes 多 Agent 协作：不是技术，是管理]([[hermes-multi-agent-management-lessons]]) | Hermes + Discord 三人小组完整搭建记录，踩三个坑（无@、死循环、同时@）并修复，核心：Profile=工位，SOUL.md=职责说明书 | 2026-04-26 |

## dev-tools

开发工具、文档系统相关文章。

| Article | Summary | Updated |
|---------|---------|---------|
| [MkDocs 使用指南]([[mkdocs-user-guide]]) | MkDocs + Material 主题 + drawio 集成 + markmap 思维导图 + 阿里云 Nginx 私有化部署完整指南 | 2026-04-27 |
| [MkDocs 源码走读笔记]([[mkdocs-code-walkthrough]]) | v0.2 → v0.13 → v1.4.3 演化：Click 装饰器机制、插件事件系统、CLI 架构理解 | 2026-04-27 |