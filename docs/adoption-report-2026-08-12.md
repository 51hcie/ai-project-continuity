# Maintainer-commissioned clean-room trial

## Status

This trial was performed by an AI coding agent at the maintainer's request against a clean public clone. It is reproducible implementation evidence and **does not count as an independent external adopter**.

## Scenario

A contributor receives a fresh clone on a new machine, installs the `apc` command into an isolated prefix, validates the complete sample, initializes an existing project without overwriting its README, and produces a privacy-safe conformance report.

## Commands

```sh
git clone https://github.com/51hcie/ai-project-continuity.git
cd ai-project-continuity
sh scripts/install.sh "$TMPDIR/apc-prefix"
"$TMPDIR/apc-prefix/bin/apc" version
"$TMPDIR/apc-prefix/bin/apc" check examples/sample-project
mkdir "$TMPDIR/existing-project"
printf '# Existing project\n' > "$TMPDIR/existing-project/README.md"
"$TMPDIR/apc-prefix/bin/apc" init "$TMPDIR/existing-project"
"$TMPDIR/apc-prefix/bin/apc" report examples/sample-project
```

## Results

- Installation works without a package manager or elevated privileges.
- The installed command locates its bundled templates and validators.
- Validation passes for the complete sample project.
- Initialization preserves the existing README and creates only missing continuity files.
- The conformance report excludes absolute personal paths and secret values.
- The automated suite repeats the install and workflow on both Ubuntu and macOS.

## Issue found and resolved

The `v0.1.0` workflow required users to invoke scripts from a source checkout. The `v0.2.0` command and installer make initialization, validation, and reporting available from any working directory.

## Remaining evidence gap

There are no verified external adopters yet. The next useful signal is a report from a maintainer using the protocol in an unrelated repository over multiple sessions or machines.
