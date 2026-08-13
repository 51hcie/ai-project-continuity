# Continuity protocol v0.3

This document defines the minimum repository state needed for a recoverable project handoff. The keywords MUST, MUST NOT, SHOULD, and MAY describe requirement strength.

## Required artifacts

A conforming repository MUST contain:

| Artifact | Purpose | Update trigger |
| --- | --- | --- |
| `AGENTS.md` | Reading order, working agreements, validation, and safety rules | Workflow or validation changes |
| `.ai/context.md` | Durable goal, scope, system boundaries, constraints, and commands | A durable fact changes |
| `.ai/decisions.md` | Architecture decisions and consequences | A decision affects future work |
| `.ai/tasks.md` | Current work, blockers, evidence, and next entry point | Work state changes |
| `.env.example` | Names and safe placeholders for required configuration | Configuration contract changes |
| `.gitignore` | Exclusion of local secrets and private continuity state | A new local artifact appears |

Reusable prompts and milestone summaries SHOULD live under `.ai/prompts/` and `.ai/sessions/`. Private notes MAY live under `.ai/private/`, which MUST be ignored.

## Session summary lifecycle

A session summary is a recovery checkpoint, not a transcript or per-commit log. Create one when work crosses a meaningful handoff boundary, such as a completed milestone, a change of developer or coding agent, a context reset, or a blocker that will outlive the current work session.

Session filenames SHOULD use `YYYY-MM-DD-short-topic.md`, with a lowercase, hyphen-separated topic. Each summary SHOULD state the goal, completed work, failed attempts when they affect the next step, current validation evidence, open questions, and the exact next entry point. The canonical fill-in structure lives in `.ai/sessions/_template.md`.

Published summaries SHOULD remain historically stable. Correct inaccurate or sensitive content when necessary; make other corrections explicit or supersede an earlier summary instead of silently rewriting project history.

## Recovery invariant

After a fresh clone, a contributor following `AGENTS.md` MUST be able to:

1. state the project's current goal and relevant boundaries;
2. identify accepted decisions that constrain implementation;
3. choose the next executable task without relying on private chat history;
4. find commands used to install, run, and validate the project;
5. distinguish verified facts from assumptions and incomplete work.

## Data rules

Continuity files MUST NOT contain credentials, access tokens, private keys, personal data, customer data, raw private chats, local logs, or absolute personal home paths. Use synthetic examples and relative paths.

They SHOULD contain dates, owners or roles where useful, exact validation commands, concise results, explicit blockers, and links to repository artifacts. They SHOULD NOT duplicate code documentation or become activity journals.

## Decision record lifecycle

Every durable decision SHOULD include status, context, decision, rationale, consequences, alternatives, and supersession information. Accepted records remain in history; later decisions supersede rather than silently rewrite them.

## Compatibility

The canonical format is UTF-8 Markdown plus conventional repository files. Consumers MUST NOT require a particular hosted service or coding agent to interpret the core protocol.
