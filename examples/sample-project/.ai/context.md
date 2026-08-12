# Durable project context

## Goal

Trail Status API is a fictional teaching project. Its first milestone is a read-only endpoint returning synthetic trail conditions so the team can test the handoff protocol across coding agents.

## Scope

- Included: one JSON endpoint, in-memory sample data, unit tests, and local documentation.
- Excluded: authentication, persistence, deployment, maps, and real trail data.

## Technology

- Runtime: Python 3 standard library.
- Data: in-memory synthetic fixtures.
- Infrastructure: none for the first milestone.

## Durable constraints

- The first milestone must not require third-party packages.
- API fixtures must be synthetic and contain no personal information.
- Response fields use `snake_case`.

## Development and validation

- Install: no dependencies.
- Run: `python3 -m http.server 8080` until the API entry point exists.
- Test: `python3 -m unittest discover` after tests are added.
- Continuity: run the parent repository's `scripts/check.sh` against this directory.

## Current state

- Completed: API boundary and first response shape agreed.
- In progress: initial endpoint implementation.
- Known risks: the run command is temporary and does not serve the planned JSON response.

## Last updated

- Date: 2026-08-12
- By: primary maintainer
