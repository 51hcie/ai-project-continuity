# ai-project-continuity

**A small, open protocol for handing AI-native software projects across computers, sessions, developers, and coding agents.**

Git preserves code. This project preserves the context required to continue: project goals, operating constraints, architecture decisions, task state, validation commands, and agent instructions.

> Clone. Restore. Read the handoff. Continue with evidence.

[简体中文](README.zh-CN.md) · [Protocol](docs/protocol.md) · [Handoff workflow](docs/handoff-workflow.md) · [Example](examples/sample-project)

## Why this exists

AI-assisted projects often lose momentum when work moves to a new machine or agent. Chat history is incomplete, local notes are missing, and the code alone cannot explain why a design exists or what has already failed. `ai-project-continuity` adds a versioned continuity layer that stays with the repository:

```text
your-project/
├── AGENTS.md              # agent-neutral collaboration rules and reading order
├── .ai/
│   ├── context.md         # goals, boundaries, constraints, and run commands
│   ├── decisions.md       # durable architecture decision records
│   ├── tasks.md           # current work, blockers, evidence, and next entry point
│   ├── prompts/           # reusable project prompts, never private transcripts
│   └── sessions/          # concise milestone handoffs
├── .env.example           # safe configuration contract
└── .gitignore             # local state and secrets remain local
```

Everything is plain Markdown and standard shell. There is no hosted service, account, database, or vendor lock-in.

## Quickstart

### 1. Add continuity files to a project

From this repository:

```sh
sh scripts/init.sh ../my-project
```

The initializer creates only missing files and refuses to overwrite existing ones. Review the new placeholders, then tailor them to the project.

### 2. Create the handoff

Fill in these files in order:

1. `.ai/context.md` — what the project is, its boundaries, and how to run it.
2. `.ai/decisions.md` — decisions a future contributor must not rediscover.
3. `.ai/tasks.md` — what is happening now, what is blocked, and the next executable step.
4. `AGENTS.md` — repository-specific working agreements and validation requirements.

### 3. Validate before committing

```sh
sh scripts/check.sh ../my-project
```

Expected output:

```text
continuity check passed: ../my-project
```

The validator checks required files, placeholder completion, ignore rules, tracked sensitive filenames, absolute home paths, and common secret-shaped content. It is a guardrail, not a replacement for a dedicated secret scanner.

### Try the complete example

```sh
sh scripts/check.sh examples/sample-project
sh scripts/test.sh
```

Then read [`examples/sample-project/AGENTS.md`](examples/sample-project/AGENTS.md) followed by its `.ai/` files. The example shows the exact state a new human or coding agent receives after a clean clone.

## Start and end every session

At the start:

1. Read `AGENTS.md`, then `.ai/context.md`, `.ai/decisions.md`, and `.ai/tasks.md`.
2. Confirm the next task, relevant constraints, and validation command.
3. Inspect the code before making changes.

At a meaningful milestone:

1. Update `.ai/tasks.md` with the actual state and validation evidence.
2. Add durable decisions to `.ai/decisions.md`.
3. Add a short milestone note to `.ai/sessions/` only when it helps the next contributor resume.
4. Run project tests and the continuity validator before pushing.

## Protocol principles

- **Repository-native:** context travels with the code and participates in review.
- **Agent-neutral:** the same handoff works with Codex, Claude Code, other coding agents, and humans.
- **Minimal:** maintain only facts that change future decisions or execution.
- **Evidence-based:** record commands and results, not vague claims that something works.
- **Privacy-aware:** exclude credentials, personal data, absolute home paths, raw chats, and local logs.
- **Recoverable:** a fresh clone should contain enough state to choose and validate the next action.

See the normative [protocol definition](docs/protocol.md) and practical [handoff workflow](docs/handoff-workflow.md).

## Project status

The protocol is intentionally small and is currently at `v0.1`. Feedback from real repositories is especially valuable. See [CHANGELOG.md](CHANGELOG.md), the [roadmap](docs/roadmap.md), and [CONTRIBUTING.md](CONTRIBUTING.md).

## Security and privacy

Continuity documents must never contain tokens, private keys, customer data, private chat transcripts, or machine-specific secrets. Read [SECURITY.md](SECURITY.md) before reporting a sensitive issue.

## License

[MIT](LICENSE)
