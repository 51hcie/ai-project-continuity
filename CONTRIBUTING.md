# Contributing

Thank you for improving `ai-project-continuity`. Contributions should keep the protocol small, portable, agent-neutral, and safe to commit.

## Before opening a pull request

1. Search existing issues and open one before proposing a substantial protocol change.
2. Fork the repository and create a focused branch.
3. Use synthetic data in tests and examples. Never add credentials, personal paths, chat transcripts, customer data, or private project content.
4. Update documentation and `CHANGELOG.md` when behavior or the public format changes.
5. Run:

   ```sh
   ./scripts/test.sh
   ./scripts/check.sh template
   ./scripts/check.sh examples/sample-project
   ```

## Design expectations

- Prefer plain Markdown and POSIX shell over required runtimes or services.
- Treat field additions as protocol changes and explain their migration impact.
- Keep examples small enough to inspect during review.
- Preserve compatibility with a clean clone and common coding-agent workflows.
- Include a test for validator or initializer behavior changes.

## Pull requests

Use the pull request template. Describe the problem, protocol impact, security/privacy impact, and validation evidence. Maintainers may ask to split unrelated changes.

## Community

Participation is governed by [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Report security-sensitive findings according to [SECURITY.md](SECURITY.md).

By contributing, you agree that your contribution is licensed under the MIT License.
