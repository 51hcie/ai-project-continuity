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

## Update cadence

Continuity files are checkpoints, not a per-commit activity log. Update them when repository state changes what the next contributor needs to know:

| Event | Required action |
| --- | --- |
| A task completes or changes direction | Update `.ai/tasks.md` with the outcome, evidence, and next entry point. |
| A blocker stops progress | Update `.ai/tasks.md` before stopping; include the cause and unblock condition. |
| A durable architecture or interface decision is accepted | Append a record to `.ai/decisions.md`. |
| A durable goal, boundary, constraint, or run command changes | Update `.ai/context.md`. |
| Work moves to another machine, agent, or developer at a meaningful milestone | Update the files above, add a `.ai/sessions/` summary when it adds recovery value, then run `apc check`. |

An autonomous agent SHOULD checkpoint after completing a bounded task and before a risky change, context reset, or expected interruption. It SHOULD NOT rewrite continuity files after every commit when the recoverable state has not changed.

## Moving between coding agents

Keep vendor-specific convenience files as optional adapters. `AGENTS.md` and `.ai/` remain the neutral source of truth. If an agent requires a special instruction file, make it point back to the canonical continuity artifacts instead of maintaining divergent state.

## Work across branches

A branch's continuity files describe the recoverable state of that branch. A feature branch may record its own next task and evidence while the target branch continues to represent the integrated project state.

Before opening or updating a pull request:

1. Keep only durable feature facts in `.ai/context.md` and `.ai/decisions.md`.
2. Update `.ai/tasks.md` with the feature result, validation evidence, and remaining merge-dependent work.
3. Include a session summary only when it adds recovery value beyond the commits and pull request.
4. Re-run `apc check` after bringing the branch up to date.

When continuity files conflict, do not resolve them with a blanket “ours” or “theirs.” Start from the target branch's current integrated state, incorporate the feature's verified outcome and still-relevant next steps, retain accepted decisions that remain active, and preserve superseded records as history.

After merge, the target branch should record the actual integrated result. Remove feature-only next steps that are complete, keep unresolved work explicit, and record validation from the merged state rather than copying a pre-merge claim.

## Coordinate concurrent agents on one branch

Separate branches are the safest default. If two agents must share a branch, use the optional `## Active claims` table in `.ai/tasks.md` to announce ownership and scope. Before writing, capture `git hash-object .ai/tasks.md`; re-check it immediately before the write and re-read and merge if it changed. Never treat a claim as a filesystem lock, and release or mark it stale when the work stops.

## Optional automation

Use `apc check --staleness 20` to emit a non-blocking warning when `.ai/tasks.md` has not changed in more than 20 commits. This is a review prompt, not proof that the handoff is wrong; repositories vary in commit size and update cadence. The warning is skipped outside a Git repository.

`apc hook` prints a small pre-commit hook to standard output. It never writes under `.git/hooks/`, because silently replacing or appending to an existing hook can break a project's workflow. Review the output and compose it with the repository's existing hook manager or hook only when local policy calls for commit-time validation.

On Windows, Git for Windows runs the default POSIX hook through its bundled shell; ensure the `apc` command is on the PATH seen by Git. Native PowerShell users can run `apc hook --shell powershell > .git/hooks/pre-commit.ps1`, then invoke that file from the repository's normal `pre-commit` shim. The generated PowerShell hook also checks for `apc`, `apc.ps1`, `apc.cmd`, or `apc.exe` and fails closed with a PATH instruction when none is available.

## Recover non-public resources safely

If a project needs credentials or machine-specific inputs, keep only a locator in `.ai/resources.md`: for example an environment-variable name, a credential-helper command, a logical secret-manager reference, or a repository-relative configuration path. Keep the value, host address, absolute path, and private data outside Git.

At resume time, read the locator, check the current environment or credential helper, and ask the user only if the resource is still unavailable. A handoff should reduce repeated explanation without turning the repository into a secret store. `apc bundle` excludes the resource inventory by default; use `apc bundle --resources` only when the safe metadata itself is appropriate to share, and review it before sending.
