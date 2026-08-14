# ai-project-continuity

**A small, open protocol for handing AI-native software projects across computers, sessions, developers, and coding agents.**

Git preserves code. This project preserves the context required to continue: project goals, operating constraints, architecture decisions, task state, validation commands, and agent instructions.

> Clone. Restore. Read the handoff. Continue with evidence.

[简体中文](README.zh-CN.md) · [Protocol](docs/protocol.md) · [Handoff workflow](docs/handoff-workflow.md) · [Example](examples/sample-project) · [Adoption](ADOPTERS.md)

## Why this exists

AI-assisted projects often lose momentum when work moves to a new machine or agent. Chat history is incomplete, local notes are missing, and the code alone cannot explain why a design exists or what has already failed. `ai-project-continuity` adds a versioned continuity layer that stays with the repository:

> **Without a continuity handoff:** a fresh clone shows the code, but not why a module is disabled, which approach already failed, or what command last passed.
>
> **With this protocol:** the next human or coding agent reads the repository-owned handoff, finds the next executable task and its constraints, then verifies the recorded baseline before editing.

```text
your-project/
├── AGENTS.md              # agent-neutral collaboration rules and reading order
├── .ai/
│   ├── context.md         # goals, boundaries, constraints, and run commands
│   ├── decisions.md       # durable architecture decision records
│   ├── tasks.md           # current work, optional active claims, and next entry point
│   ├── prompts/           # reusable project prompts, never private transcripts
│   ├── resources.md       # optional safe locators for non-public inputs, never values
│   └── sessions/          # concise milestone handoffs
├── .env.example           # safe configuration contract
└── .gitignore             # local state and secrets remain local
```

Everything is plain Markdown and standard shell. There is no hosted service, account, database, or vendor lock-in.

## Quickstart

### 1. Install the command

From a clone of this repository:

```sh
sh scripts/install.sh "$HOME/.local"
export PATH="$HOME/.local/bin:$PATH"
apc version
```

No package manager or elevated privileges are required. You can also skip installation and replace `apc` below with `sh ./apc` from this repository.

For a no-clone initialization, inspect [`scripts/bootstrap.sh`](scripts/bootstrap.sh), then run:

```sh
curl -fsSL https://raw.githubusercontent.com/51hcie/ai-project-continuity/main/scripts/bootstrap.sh \
  | sh -s -- init ../my-project
```

The bootstrap downloads a temporary source archive, initializes only missing files, and removes the archive. It requires `curl` and `tar`; use the clone-based flow when you need to review or pin every downloaded file before execution.

### 2. Add continuity files to a project

```sh
apc init ../my-project
```

The initializer creates only missing files and refuses to overwrite existing ones. Review the new placeholders, then tailor them to the project.

Before filling them in, review the [complete sample project](examples/sample-project) to see the intended level of detail.

### 3. Create the handoff

Fill in these files in order:

1. `.ai/context.md` — what the project is, its boundaries, and how to run it.
2. `.ai/decisions.md` — decisions a future contributor must not rediscover.
3. `.ai/tasks.md` — what is happening now, what is blocked, and the next executable step.
4. `AGENTS.md` — repository-specific working agreements and validation requirements.

### 4. Validate before committing

```sh
apc check ../my-project
```

Expected output:

```text
continuity check passed: ../my-project
```

The validator checks required files, placeholder completion, ignore rules, tracked sensitive filenames, absolute home paths, and common secret-shaped content. It is a guardrail, not a replacement for a dedicated secret scanner.

To get a heuristic warning when task state may be stale:

```sh
apc check --staleness 20 ../my-project
apc check --staleness 3d ../my-project
apc check --staleness 1w ../my-project
```

Numbers count commits after the last committed `.ai/tasks.md` update; a `d` or `w` suffix checks elapsed time instead. The warning is non-blocking and uses the task file's latest Git timestamp when available.

### 5. Create a reviewable context bundle

```sh
apc bundle ../my-project > handoff.md
```

`bundle` first requires the project to pass `apc check`, then writes `AGENTS.md`, `.ai/context.md`, `.ai/decisions.md`, and `.ai/tasks.md` in deterministic order. It never copies environment files, prompts, session notes, resources, or private files by default. Add `--resources` only when safe locator metadata is appropriate to share. Automated checks cannot recognize every sensitive fact, so read `handoff.md` before pasting it into a web LLM or sharing it with another person.

For a token-constrained handoff, use `apc bundle --minimal ../my-project`. It includes durable constraints, current and next task state, blockers, handoff evidence, and the latest published session summary while leaving out decision history, prompts, and resources by default. `--resources` remains an explicit opt-in and adds a review warning.

### GitHub Actions

Pin a released version in your workflow:

```yaml
steps:
  - uses: actions/checkout@v4
  - uses: 51hcie/ai-project-continuity@v0.5.0
    with:
      target: .
```

The composite action runs the same repository-owned validator. For optional local commit-time checks, `apc hook` prints a reviewable hook script but intentionally does not change `.git/hooks/`.

On Windows, Git for Windows can use the default `sh` hook when `apc` is on Git's PATH. Native PowerShell users can generate `apc hook --shell powershell` and invoke the resulting `.ps1` file from the repository's normal `pre-commit` shim. The generated hook checks for `apc`, `apc.ps1`, `apc.cmd`, or `apc.exe` and fails with a PATH instruction if it cannot find one.

### Try the complete example

```sh
apc check examples/sample-project
apc report examples/sample-project
sh scripts/test.sh
```

Then read [`examples/sample-project/AGENTS.md`](examples/sample-project/AGENTS.md) followed by its `.ai/` files. The example shows the exact state a new human or coding agent receives after a clean clone.

## Start and end every session

At the start:

1. Read `AGENTS.md`, then `.ai/context.md`, the active decision index and relevant records in `.ai/decisions.md`, and `.ai/tasks.md`.
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

The protocol is intentionally small and the tooling is currently at `v0.5`. External adoption is not claimed without public evidence. See [ADOPTERS.md](ADOPTERS.md), [CHANGELOG.md](CHANGELOG.md), the [roadmap](docs/roadmap.md), and [CONTRIBUTING.md](CONTRIBUTING.md).

## Security and privacy

Continuity documents must never contain tokens, private keys, customer data, private chat transcripts, or machine-specific secrets. Read [SECURITY.md](SECURITY.md) before reporting a sensitive issue.

## License

[MIT](LICENSE)
