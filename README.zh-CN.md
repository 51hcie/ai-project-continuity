# ai-project-continuity

**一个用于在不同电脑、会话、开发者和 AI 编程助手之间交接 AI 原生软件项目的轻量开放协议。**

Git 保存代码；本项目补齐继续开发所需的上下文：项目目标、约束、架构决策、任务状态、验证命令和 agent instructions。

> 克隆、恢复、阅读交接，然后用验证结果继续推进。

[English](README.md) · [协议](docs/protocol.md) · [交接流程](docs/handoff-workflow.md) · [完整示例](examples/sample-project) · [采用情况](ADOPTERS.md)

## 为什么需要它

项目换电脑、换会话或换 AI 编程助手后，聊天记录往往不完整，本地笔记也不会跟随代码。仅看代码无法得知某项设计为何存在、已经试过什么以及下一步做什么。`ai-project-continuity` 用一组可版本管理的纯文本文件保存这些信息：

> **没有交接协议：** 全新克隆只能看到代码，无法得知某模块为什么停用、哪些方案已经失败，以及哪条验证命令最后一次通过。
>
> **使用本协议：** 下一位开发者或 coding agent 先读取仓库内的交接状态，找到受约束的下一项可执行任务，再在修改代码前验证已记录的基线。

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

首先从本仓库安装命令，无需包管理器或管理员权限：

```sh
sh scripts/install.sh "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
apc version
```

如果只想初始化现有项目而不克隆本仓库，可先检查 [`scripts/bootstrap.sh`](scripts/bootstrap.sh)，再运行：

```sh
curl -fsSL https://raw.githubusercontent.com/51hcie/ai-project-continuity/main/scripts/bootstrap.sh \
  | sh -s -- init ../my-project
```

该方式需要 `curl` 和 `tar`；脚本会下载临时源码包、仅创建缺失文件，然后清理临时文件。

然后在任意目录运行：

```sh
apc init ../my-project
apc check ../my-project
```

初始化脚本只创建缺少的文件，绝不会覆盖现有文件。随后按顺序填写：

填写前建议先查看[完整示例项目](examples/sample-project)，了解每类信息合适的详细程度。

1. `.ai/context.md`：项目目标、边界、技术和运行方式；
2. `.ai/decisions.md`：以后不应重新讨论或猜测的决策；
3. `.ai/tasks.md`：当前状态、阻塞项、验证结果和下一步；
4. `AGENTS.md`：本项目特有的协作规则和验证要求。

运行完整示例和自测：

```sh
apc check examples/sample-project
apc report examples/sample-project
sh scripts/test.sh
```

如需在任务状态长期未更新时收到启发式提示，可运行：

```sh
apc check --staleness 20 ../my-project
```

该提示不会导致检查失败，并且只在 Git 仓库内生效。

如需把核心交接上下文粘贴到网页 LLM 或交给其他人：

```sh
apc bundle ../my-project > handoff.md
```

`bundle` 会先要求项目通过 `apc check`，再按固定顺序输出 `AGENTS.md`、`.ai/context.md`、`.ai/decisions.md` 和 `.ai/tasks.md`；它不会包含环境文件、prompts、session notes 或私有文件。自动检查无法识别所有敏感事实，分享前仍须人工阅读 `handoff.md`。

GitHub Actions 可固定使用已发布版本：

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: 51hcie/ai-project-continuity@v0.4.0
    with:
      target: .
```

本地提交前检查可用 `apc hook` 生成一段可审查的 hook 脚本；该命令不会擅自修改 `.git/hooks/`，以免覆盖项目已有流程。

## 核心原则

- 与仓库同行：上下文和代码一起克隆、评审、演进；
- 与工具无关：人类、Codex、Claude Code 及其他 coding agent 都能读取；
- 保持最小：只记录会影响未来决策或执行的信息；
- 以证据为准：保存验证命令和结果，不写模糊的“应该可用”；
- 隐私优先：不保存密钥、个人数据、绝对个人路径、完整聊天或本地日志；
- 可恢复：一次全新克隆后能够确定并验证下一个动作。

更多细节见[协议定义](docs/protocol.md)和[交接流程](docs/handoff-workflow.md)。工具当前为 `v0.4`，不会在缺少公开证据时声称外部采用。欢迎用真实仓库验证并通过 Adoption report 反馈，参见 [ADOPTERS.md](ADOPTERS.md) 和 [CONTRIBUTING.md](CONTRIBUTING.md)。

## 许可证

[MIT](LICENSE)
