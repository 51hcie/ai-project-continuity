# ai-project-continuity

**一个用于在不同电脑、会话、开发者和 AI 编程助手之间交接 AI 原生软件项目的轻量开放协议。**

Git 保存代码；本项目补齐继续开发所需的上下文：项目目标、约束、架构决策、任务状态、验证命令和 agent instructions。

> 克隆、恢复、阅读交接，然后用验证结果继续推进。

[English](README.md) · [协议](docs/protocol.md) · [交接流程](docs/handoff-workflow.md) · [完整示例](examples/sample-project)

## 为什么需要它

项目换电脑、换会话或换 AI 编程助手后，聊天记录往往不完整，本地笔记也不会跟随代码。仅看代码无法得知某项设计为何存在、已经试过什么以及下一步做什么。`ai-project-continuity` 用一组可版本管理的纯文本文件保存这些信息：

```text
your-project/
├── AGENTS.md              # 与具体 agent 无关的协作规则和阅读顺序
├── .ai/
│   ├── context.md         # 目标、边界、约束和运行命令
│   ├── decisions.md       # 长期有效的架构决策
│   ├── tasks.md           # 当前任务、阻塞项、验证证据和下一入口
│   ├── prompts/           # 可复用的项目提示词，不保存私人对话
│   └── sessions/          # 简短里程碑交接
├── .env.example           # 安全的配置契约
└── .gitignore             # 本地状态和密钥只留在本地
```

## 快速开始

在本仓库中运行：

```sh
./scripts/init.sh ../my-project
./scripts/check.sh ../my-project
```

初始化脚本只创建缺少的文件，绝不会覆盖现有文件。随后按顺序填写：

1. `.ai/context.md`：项目目标、边界、技术和运行方式；
2. `.ai/decisions.md`：以后不应重新讨论或猜测的决策；
3. `.ai/tasks.md`：当前状态、阻塞项、验证结果和下一步；
4. `AGENTS.md`：本项目特有的协作规则和验证要求。

运行完整示例和自测：

```sh
./scripts/check.sh examples/sample-project
./scripts/test.sh
```

## 核心原则

- 与仓库同行：上下文和代码一起克隆、评审、演进；
- 与工具无关：人类、Codex、Claude Code 及其他 coding agent 都能读取；
- 保持最小：只记录会影响未来决策或执行的信息；
- 以证据为准：保存验证命令和结果，不写模糊的“应该可用”；
- 隐私优先：不保存密钥、个人数据、绝对个人路径、完整聊天或本地日志；
- 可恢复：一次全新克隆后能够确定并验证下一个动作。

更多细节见[协议定义](docs/protocol.md)和[交接流程](docs/handoff-workflow.md)。项目当前为 `v0.1`，欢迎用真实仓库验证并反馈，参见 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT](LICENSE)
