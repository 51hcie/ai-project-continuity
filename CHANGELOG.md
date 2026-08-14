# Changelog

All notable changes are documented here. The project follows [Semantic Versioning](https://semver.org/) once releases are published.

## [Unreleased]

## [0.5.0] - 2026-08-14

### Added

- Optional `.ai/resources.md` safe-locator convention for recovering non-public inputs without storing their values.
- `apc bundle --resources` opt-in output for reviewing safe resource metadata.

### Changed

- Agent and handoff guidance now requires checking safe locators before asking for unavailable resources and forbids reconstructing or copying secrets.
- README and examples document resource metadata boundaries and the v0.5 Action pin.

## [0.4.0] - 2026-08-13

### Added

- Deterministic `apc bundle` output for manually handing core context to people or web LLMs.
- Optional non-blocking `apc check --staleness COMMITS` warnings.
- Root composite `action.yml` for pinned GitHub Actions validation.
- Reviewable `apc hook` output that never modifies an existing Git hook.
- Prompt naming, metadata, index, template, and complete sample prompt.

### Changed

- Decision logs now expose currently active constraints separately from historical records.
- Protocol and workflow guidance now define branch-local continuity and semantic merge resolution.

## [0.3.0] - 2026-08-13

### Added

- No-clone bootstrap for initializing or installing from a temporary source archive.
- Explicit update-cadence guidance for humans and autonomous coding agents.
- Session-summary naming, creation, content, and correction lifecycle rules.
- Inline examples that show the intended level of detail in continuity templates.

### Changed

- README value proposition now includes a concrete recovery scenario.
- Quickstarts now link the complete sample project before users fill in templates.

## [0.2.0] - 2026-08-12

### Added

- Installable `apc` command with `init`, `check`, `report`, and `version` subcommands.
- Non-privileged prefix installer that refuses to overwrite unrelated commands.
- Privacy-safe Markdown conformance reports.
- Evidence-based adoption registry, issue form, and clean-room trial report.
- Ubuntu and macOS CI coverage for the installed workflow.

### Changed

- Quickstart now uses the installed command while retaining a source-checkout fallback.
- Initializer follow-up guidance now points to the installed validation command.

## [0.1.0] - 2026-08-12

### Added

- Initial continuity template using `AGENTS.md`, `.ai/`, `.env.example`, and `.gitignore`.

[Unreleased]: https://github.com/51hcie/ai-project-continuity/compare/v0.5.0...HEAD
[0.5.0]: https://github.com/51hcie/ai-project-continuity/compare/v0.4.0...v0.5.0
[0.4.0]: https://github.com/51hcie/ai-project-continuity/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/51hcie/ai-project-continuity/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/51hcie/ai-project-continuity/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/51hcie/ai-project-continuity/releases/tag/v0.1.0
