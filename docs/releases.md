# Release process

1. Confirm the default branch passes `./scripts/test.sh` and both example validations.
2. Move relevant entries from `Unreleased` into a dated semantic version in `CHANGELOG.md`.
3. Review protocol compatibility and migration notes.
4. Create an annotated Git tag and a GitHub release using the changelog entry.
5. Open the next `Unreleased` section.

Protocol-breaking changes require a major version after `1.0.0`. Before then, breaking changes must be clearly documented in release notes.
