# Decision log

## Active decision index

- ADR-001 — Use the Python standard library for the first milestone (`accepted`)

ADR-002 remains proposed and therefore is not an active constraint.

## Decision records

## ADR-001: Start with the Python standard library

- Date: 2026-08-12
- Status: accepted
- Context: The first milestone tests continuity rather than framework features.
- Decision: Use Python's standard library for the HTTP boundary and tests.
- Rationale: A dependency-free example is portable and keeps the handoff focused.
- Consequences: Routing will be minimal; a framework may be adopted after the protocol trial.
- Alternatives: Flask and FastAPI were considered but add setup not needed for the milestone.
- Supersedes: None.

## ADR-002: Authentication model

- Date: 2026-08-12
- Status: proposed
- Context: A future write endpoint may need authentication.
- Decision: Not yet decided.
- Rationale: Authentication is outside the first milestone.
- Consequences: No write endpoint may be added until this decision is accepted.
- Alternatives: Static development token, OAuth, or keeping the API read-only.
- Supersedes: None.
