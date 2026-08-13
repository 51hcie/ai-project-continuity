# Review constraints

## When to use

Use before proposing a new endpoint, dependency, or external interface.

## Inputs

- The relevant diff or implementation plan.
- `.ai/context.md`.
- The active decision index and relevant records in `.ai/decisions.md`.

## Prompt

Review the proposed change against the project's documented scope and active decisions. Cite the repository file for every constraint. Separate confirmed conflicts from questions, and do not invent requirements that are absent from the repository.

## Expected output

A concise list of confirmed conflicts, open questions, and the validation command that should run if the change proceeds.

## Safety boundaries

Do not include credentials, real user data, private conversations, or local absolute paths.
