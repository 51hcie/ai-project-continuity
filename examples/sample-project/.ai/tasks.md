# Work state

## Doing

- [ ] Implement `GET /trails` with two synthetic records (primary maintainer; started 2026-08-12).

## Active claims

No shared-branch claims are active.

## Next

- [ ] Add unit tests for status filtering and unknown query values.
- [ ] Replace the temporary run command with the real API entry point.

## Blocked

- [ ] Write endpoints are blocked until ADR-002 is accepted.

## Done

- [x] Defined scope, response naming, and dependency constraint.

## Handoff

- Current branch: `main`.
- Latest validation: continuity validator passed on 2026-08-12; application tests do not exist yet.
- Next entry point: create `app.py` and implement only the read-only route.
- Important caution: do not add authentication or real trail data in this milestone.
