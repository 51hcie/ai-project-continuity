# Project collaboration guide

Before changing the project, read these files in order:

1. `.ai/context.md`
2. The active decision index at the top of `.ai/decisions.md`, then any records relevant to the task
3. `.ai/tasks.md`

Reusable, reviewed prompts are indexed in `.ai/prompts/README.md`. Use them only when their stated inputs and expected output match the task.

Working agreements:

- Preserve the current architecture and user changes unless the task requires otherwise.
- Inspect relevant code and tests before implementation; validate in proportion to risk afterward.
- Put durable project constraints in `.ai/context.md`.
- Record decisions that affect architecture, data models, or external interfaces in `.ai/decisions.md`.
- Update `.ai/tasks.md` when work state changes.
- Add a concise summary to `.ai/sessions/` after a meaningful milestone, not after every interaction.
- Keep secrets and real credentials in local environment files only. Never place them in documentation, logs, prompts, or version control.
