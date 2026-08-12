# Handoff workflow

## Create continuity once

Run `sh scripts/init.sh PATH`, then replace the placeholders with repository facts. Treat this as project documentation, not a transcript export.

## Resume on any machine or agent

1. Clone the repository and install dependencies using `.ai/context.md`.
2. Read `AGENTS.md` and its linked continuity files in order.
3. Verify that `.ai/tasks.md` agrees with the branch and current code.
4. Run the recorded baseline check before editing when practical.
5. Continue the first unblocked task, observing accepted decisions.

If the handoff is stale, update it as part of the work. Never guess that a recorded validation still passes.

## Hand off at a milestone

Update state when a task completes, changes direction, or becomes blocked. A useful handoff answers:

- What changed and why?
- What is verified, with which command and result?
- What remains incomplete?
- What is the exact next entry point?
- Which constraints or risks could surprise the next contributor?

Add a session summary only for a meaningful milestone. Keep it short and link to commits, issues, or decision records instead of copying discussions.

## Moving between coding agents

Keep vendor-specific convenience files as optional adapters. `AGENTS.md` and `.ai/` remain the neutral source of truth. If an agent requires a special instruction file, make it point back to the canonical continuity artifacts instead of maintaining divergent state.
